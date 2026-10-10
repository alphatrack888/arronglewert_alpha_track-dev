"""Check packaged release manifests before publishing the Android bundle."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ANDROID_NAME = "{http://schemas.android.com/apk/res/android}name"
FORBIDDEN = {
    "android.permission." + permission
    for permission in (
        "READ_MEDIA_IMAGES", "READ_MEDIA_VIDEO",
        "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE",
        "MANAGE_EXTERNAL_STORAGE",
    )
}


def check_release_manifests(build_dir):
    manifests = sorted(Path(build_dir).glob(
        "app/intermediates/packaged_manifests/release/**/AndroidManifest.xml"
    ))
    if not manifests:
        raise ValueError("Packaged release manifest missing; build the release AAB first.")
    for manifest in manifests:
        tree = ET.parse(manifest)
        permissions = {
            node.get(ANDROID_NAME)
            for node in tree.getroot()
            if node.tag.startswith("uses-permission")
        }
        forbidden = permissions & FORBIDDEN
        if forbidden:
            raise ValueError(f"{manifest}: prohibited permissions: {', '.join(sorted(forbidden))}")
    return len(manifests)


if __name__ == "__main__":
    try:
        count = check_release_manifests(sys.argv[1] if len(sys.argv) > 1 else "build")
        print(f"Verified {count} packaged release manifest(s): no broad photo/storage access.")
    except (ValueError, ET.ParseError) as error:
        sys.exit(str(error))
