"""Exercise the public artifact allowlist without compiling or copying game data."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


class PackageClientTest(unittest.TestCase):
    def test_artifact_contains_only_matching_executable_and_symbols(self):
        for renderer in ("d3d9", "d3d11"):
            with self.subTest(renderer=renderer), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                binary = root / "build" / "bin"
                binary.mkdir(parents=True)
                expected = {f"Clientzin-{renderer}.exe", f"Clientzin-{renderer}.pdb"}
                for name in expected | {"libEGL.dll", "other.pdb", "LICENSE", "test.exe"}:
                    (binary / name).write_bytes(name.encode())
                result = subprocess.run(
                    [sys.executable, str(Path(__file__).with_name("package_client.py")),
                     "--build", str(root / "build"), "--output", str(root / "package")],
                    capture_output=True, text=True,
                )
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual(expected, {p.name for p in (root / "package").iterdir()})

    def test_missing_symbols_rejects_the_package(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / "build" / "bin"
            binary.mkdir(parents=True)
            (binary / "Clientzin-d3d9.exe").write_bytes(b"test")
            result = subprocess.run(
                [sys.executable, str(Path(__file__).with_name("package_client.py")),
                 "--build", str(root / "build"), "--output", str(root / "package")],
                capture_output=True, text=True,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("Matching linker PDB missing", result.stderr)
            self.assertFalse((root / "package").exists())


if __name__ == "__main__":
    unittest.main()
