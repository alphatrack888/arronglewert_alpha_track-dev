"""Prepare ephemeral CI inputs without printing secret contents."""
import base64
import json
import os
from pathlib import Path
import plistlib
import re
import sys
import subprocess

ROOT = Path(__file__).resolve().parents[1]
ANDROID_APP_ID = "com.marcgelwertz.alphatrack"
IOS_APP_ID = "com.marc.alphatrack"


class ConfigurationError(ValueError):
    pass


def required(name):
    value = os.environ.get(name, "")
    if not value:
        raise ConfigurationError(f"Missing GitHub Secret: {name}")
    return value


def decoded(name):
    return base64.b64decode("".join(required(name).split()), validate=True)


def write_private(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    path.chmod(0o600)


def property_value(value):
    # Java Properties uses Latin-1 plus unicode escapes; preserve password characters.
    result = []
    for char in value:
        if char in "\\ =:#!":
            result.append("\\" + char)
        elif char == "\n":
            result.append("\\n")
        elif char == "\r":
            result.append("\\r")
        elif char == "\t":
            result.append("\\t")
        elif ord(char) > 126:
            for offset in range(0, len(char.encode("utf-16-be")), 2):
                unit = char.encode("utf-16-be")[offset:offset + 2]
                result.append("\\u" + unit.hex())
        else:
            result.append(char)
    return "".join(result)


def validate():
    ref = os.environ.get("RELEASE_REF", "")
    tagged = os.environ.get("GITHUB_EVENT_NAME") == "push" and re.fullmatch(r"refs/tags/v[0-9]+\.[0-9]+\.[0-9]+", ref)
    if not tagged and ref != "refs/heads/main":
        raise ConfigurationError("Release requires main or a version tag vX.Y.Z.")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", required("RELEASE_VERSION")):
        raise ConfigurationError("Version must have the form 1.2.3.")
    number = required("RELEASE_BUILD_NUMBER")
    if not re.fullmatch(r"[1-9][0-9]*", number) or int(number) > 2100000000:
        raise ConfigurationError("Build number must be 1..2100000000.")



def resolve():
    if os.environ.get("GITHUB_EVENT_NAME") == "push":
        tag = re.fullmatch(r"refs/tags/v([0-9]+\.[0-9]+\.[0-9]+)", os.environ.get("RELEASE_REF", ""))
        if not tag:
            raise ConfigurationError("Automatic releases require a version tag vX.Y.Z.")
        ancestry = subprocess.run(["git", "merge-base", "--is-ancestor", "HEAD", "refs/remotes/origin/main"], cwd=ROOT, capture_output=True)
        if ancestry.returncode != 0:
            raise ConfigurationError("The tagged commit must belong to main.")
        match = re.search(r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$",
                          (ROOT / "pubspec.yaml").read_text(), re.MULTILINE)
        if not match:
            raise ConfigurationError("pubspec.yaml needs version: x.y.z+build.")
        run_number = required("GITHUB_RUN_NUMBER")
        if not re.fullmatch(r"[1-9][0-9]*", run_number):
            raise ConfigurationError("Invalid GitHub run number.")
        os.environ["RELEASE_VERSION"] = tag[1]
        os.environ["RELEASE_BUILD_NUMBER"] = str(int(match[2]) + int(run_number))
    elif os.environ.get("GITHUB_EVENT_NAME") != "workflow_dispatch":
        raise ConfigurationError("Unsupported release event.")
    validate()
    with open(required("GITHUB_OUTPUT"), "a", encoding="utf-8") as output:
        output.write(f"version={os.environ['RELEASE_VERSION']}\n")
        output.write(f"build_number={os.environ['RELEASE_BUILD_NUMBER']}\n")


def android():
    config = decoded("ANDROID_GOOGLE_SERVICES_JSON_BASE64")
    packages = [
        c.get("client_info", {}).get("android_client_info", {}).get("package_name")
        for c in json.loads(config).get("client", [])
    ]
    if ANDROID_APP_ID not in packages:
        raise ConfigurationError("Android Firebase config must include " + ANDROID_APP_ID)
    key = decoded("ANDROID_KEYSTORE_BASE64")
    properties = {
        "storeFile": str(ROOT / "android/ci-upload.jks"),
        "storePassword": required("ANDROID_STORE_PASSWORD"),
        "keyAlias": required("ANDROID_KEY_ALIAS"),
        "keyPassword": required("ANDROID_KEY_PASSWORD"),
    }
    write_private(ROOT / "android/app/google-services.json", config)
    write_private(ROOT / "android/ci-upload.jks", key)
    content = "".join(f"{k}={property_value(v)}\n" for k, v in properties.items())
    write_private(ROOT / "android/key.properties", content.encode("ascii"))


def ios():
    config = decoded("IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64")
    if plistlib.loads(config).get("BUNDLE_ID") != IOS_APP_ID:
        raise ConfigurationError("iOS Firebase config must use " + IOS_APP_ID)
    write_private(ROOT / "ios/Runner/GoogleService-Info.plist", config)


def cleanup_android():
    # Only generated CI credentials; never remove the developer's upload-keystore.jks.
    for name in ("android/ci-upload.jks", "android/key.properties"):
        (ROOT / name).unlink(missing_ok=True)


if __name__ == "__main__":
    commands = {
        "resolve": resolve, "validate": validate, "android": android, "ios": ios,
        "cleanup-android": cleanup_android,
    }
    try:
        if sys.argv[1] not in ("validate", "resolve") and os.environ.get("GITHUB_ACTIONS") != "true":
            raise ConfigurationError("Signing preparation is restricted to disposable GitHub runners.")
        commands[sys.argv[1]]()
    except ConfigurationError as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
    except (ValueError, KeyError, IndexError, plistlib.InvalidFileException):
        # Malformed JSON/base64 errors can contain input: report no secret values.
        print("Release preparation failed. Check the selected command, inputs and required secrets.", file=sys.stderr)
        sys.exit(1)
