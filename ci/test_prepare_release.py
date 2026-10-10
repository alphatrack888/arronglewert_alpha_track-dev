import base64
import json
import os
import plistlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import prepare_release as release


class ReleaseInputsTest(unittest.TestCase):
    def test_version_and_main_branch_required(self):
        valid = {"RELEASE_REF": "refs/heads/main", "RELEASE_VERSION": "1.2.3",
                 "RELEASE_BUILD_NUMBER": "42"}
        with patch.dict(os.environ, valid, clear=True):
            release.validate()
        for key, bad in (("RELEASE_REF", "refs/heads/feature"),
                         ("RELEASE_VERSION", "1.2.3; echo unsafe"),
                         ("RELEASE_BUILD_NUMBER", "0"),
                         ("RELEASE_BUILD_NUMBER", "2100000001")):
            with self.subTest(key=key, bad=bad):
                with patch.dict(os.environ, {**valid, key: bad}, clear=True):
                    with self.assertRaises(ValueError):
                        release.validate()

    def test_java_properties_preserve_special_password_characters(self):
        self.assertEqual(release.property_value(" a=b:c!#\\x\n\t"),
                         r"\ a\=b\:c\!\#\\x\n\t")
        self.assertEqual(release.property_value("\u00e9"), r"\u00e9")

    def test_android_writes_inputs_and_cleans_only_ci_key(self):
        config = {"client": [{"client_info": {
            "android_client_info": {"package_name": "com.marcgelwertz.alphatrack"}}}]}
        env = {
            "ANDROID_GOOGLE_SERVICES_JSON_BASE64": base64.b64encode(
                json.dumps(config).encode()).decode(),
            "ANDROID_KEYSTORE_BASE64": base64.b64encode(b"test-only-key").decode(),
            "ANDROID_STORE_PASSWORD": "fake:password",
            "ANDROID_KEY_PASSWORD": "fake=password",
            "ANDROID_KEY_ALIAS": "upload",
        }
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            existing = root / "upload-keystore.jks"
            existing.write_bytes(b"existing")
            with patch.object(release, "ROOT", root), patch.dict(os.environ, env, clear=True):
                release.android()
                self.assertIn(r"storePassword=fake\:password",
                              (root / "android/key.properties").read_text())
                self.assertEqual((root / "android/ci-upload.jks").read_bytes(), b"test-only-key")
                release.cleanup_android()
                self.assertFalse((root / "android/key.properties").exists())
                self.assertFalse((root / "android/ci-upload.jks").exists())
                self.assertEqual(existing.read_bytes(), b"existing")

    def test_wrong_firebase_app_rejected_before_signing_files_written(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(release, "ROOT", Path(directory)), patch.dict(
                os.environ, {"ANDROID_GOOGLE_SERVICES_JSON_BASE64":
                             base64.b64encode(b'{"client": []}').decode()}, clear=True
            ):
                with self.assertRaises(ValueError):
                    release.android()
                self.assertEqual(list(Path(directory).iterdir()), [])

    def test_android_rejects_ios_only_firebase_client(self):
        config = {"client": [{"client_info": {
            "android_client_info": {"package_name": "com.marc.alphatrack"}}}]}
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(release, "ROOT", Path(directory)), patch.dict(
                os.environ, {"ANDROID_GOOGLE_SERVICES_JSON_BASE64":
                    base64.b64encode(json.dumps(config).encode()).decode()}, clear=True
            ):
                with self.assertRaises(release.ConfigurationError):
                    release.android()
                self.assertEqual(list(Path(directory).iterdir()), [])

    def test_ios_retains_its_own_bundle_id(self):
        for bundle_id, accepted in (("com.marc.alphatrack", True),
                                    ("com.marcgelwertz.alphatrack", False)):
            with self.subTest(bundle_id=bundle_id), tempfile.TemporaryDirectory() as directory:
                config = plistlib.dumps({"BUNDLE_ID": bundle_id})
                with patch.object(release, "ROOT", Path(directory)), patch.dict(
                    os.environ, {"IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64":
                                 base64.b64encode(config).decode()}, clear=True
                ):
                    if accepted:
                        release.ios()
                        self.assertEqual(
                            (Path(directory) / "ios/Runner/GoogleService-Info.plist").read_bytes(),
                            config)
                    else:
                        with self.assertRaises(release.ConfigurationError):
                            release.ios()
                        self.assertEqual(list(Path(directory).iterdir()), [])

    def test_tag_release_resolves_version_and_incremented_code(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "pubspec.yaml").write_text("version: 1.0.1+1\n")
            output = root / "outputs"
            with patch.object(release.subprocess, "run") as ancestry, patch.object(release, "ROOT", root), patch.dict(os.environ, {
                "GITHUB_EVENT_NAME": "push", "GITHUB_RUN_NUMBER": "5",
                "RELEASE_REF": "refs/tags/v1.0.2", "GITHUB_OUTPUT": str(output)
            }, clear=True):
                ancestry.return_value.returncode = 0
                release.resolve()
            self.assertEqual(output.read_text(), "version=1.0.2\nbuild_number=6\n")

    def test_manual_release_preserves_inputs(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "outputs"
            with patch.dict(os.environ, {
                "GITHUB_EVENT_NAME": "workflow_dispatch",
                "RELEASE_VERSION": "2.0.0", "RELEASE_BUILD_NUMBER": "99",
                "RELEASE_REF": "refs/heads/main", "GITHUB_OUTPUT": str(output)
            }, clear=True):
                release.resolve()
            self.assertEqual(output.read_text(), "version=2.0.0\nbuild_number=99\n")

    def test_tag_release_rejects_branch_and_malformed_tags(self):
        for ref in ("refs/heads/main", "refs/tags/v1.2", "refs/tags/v1.2.3-beta"):
            with self.subTest(ref=ref), patch.dict(os.environ, {
                "GITHUB_EVENT_NAME": "push", "RELEASE_REF": ref
            }, clear=True):
                with self.assertRaises(release.ConfigurationError):
                    release.resolve()

    def test_tag_release_rejects_commit_outside_main(self):
        with patch.object(release.subprocess, "run") as ancestry, patch.dict(os.environ, {
            "GITHUB_EVENT_NAME": "push", "RELEASE_REF": "refs/tags/v1.2.3"
        }, clear=True):
            ancestry.return_value.returncode = 1
            with self.assertRaises(release.ConfigurationError):
                release.resolve()


if __name__ == "__main__":
    unittest.main()
