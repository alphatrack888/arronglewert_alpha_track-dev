from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET

from check_android_permissions import check_release_manifests, FORBIDDEN


class AndroidPermissionsTest(unittest.TestCase):
    def test_source_variants_do_not_request_broad_access(self):
        root = Path(__file__).resolve().parents[1]
        android_name = "{http://schemas.android.com/apk/res/android}name"
        tools_node = "{http://schemas.android.com/tools}node"
        for manifest in (root / "android/app/src").glob("*/AndroidManifest.xml"):
            for node in ET.parse(manifest).getroot():
                if node.tag.startswith("uses-permission") and node.get(android_name) in FORBIDDEN:
                    self.assertEqual(node.get(tools_node), "remove", str(manifest))

    def test_missing_artifact_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "missing"):
                check_release_manifests(directory)

    def test_final_manifest_accepts_camera_microphone_and_rejects_broad_access(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = Path(directory) / "app/intermediates/packaged_manifests/release/processReleaseManifestForPackage/AndroidManifest.xml"
            manifest.parent.mkdir(parents=True)
            for permission in ["android.permission.CAMERA", "android.permission.RECORD_AUDIO", *FORBIDDEN]:
                for element in ("uses-permission", "uses-permission-sdk-23"):
                    with self.subTest(permission=permission, element=element):
                        manifest.write_text(
                            '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
                            f'<{element} android:name="{permission}"/></manifest>',
                            encoding="utf-8",
                        )
                        if permission in FORBIDDEN:
                            with self.assertRaisesRegex(ValueError, "prohibited"):
                                check_release_manifests(directory)
                        else:
                            self.assertEqual(check_release_manifests(directory), 1)


if __name__ == "__main__":
    unittest.main()
