import base64
import json
import os
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
            "android_client_info": {"package_name": release.APP_ID}}}]}
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


if __name__ == "__main__":
    unittest.main()
