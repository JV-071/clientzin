#!/usr/bin/env python3
"""Package a Windows build; never include local assets/things/assets data."""
import argparse
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = ROOT / "assets/things/assets"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        parser.error("Output must be empty to prevent stale files in a release")
    executables = list((args.build / "bin").glob("Clientzin-*.exe"))
    if len(executables) != 1:
        parser.error(f"Expected one Clientzin executable, found {len(executables)}")
    output.mkdir(parents=True, exist_ok=True)
    for root in ("assets", "mods", "modules"):
        for src in sorted((ROOT / root).rglob("*")):
            if not src.is_file() or src.is_relative_to(EXCLUDED):
                continue
            dst = output / src.relative_to(ROOT)
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    for name in ("init.lua", "config.ini", "otclientrc.lua", "LICENSE", "AUTHORS"):
        shutil.copy2(ROOT / name, output / name)
    for src in (args.build / "bin").iterdir():
        if src.suffix.lower() in (".exe", ".dll", ".pdb"):
            shutil.copy2(src, output / src.name)
    # vcpkg app-local copying normally provides DLLs; reject unusable packages.
    for name in ("libEGL.dll", "libGLESv2.dll"):
        if not (output / name).is_file():
            parser.error(f"Required ANGLE runtime DLL missing: {name}")
    (output / "GAME-DATA.txt").write_text(
        "Copy your local game data into assets/things/assets before playing.\n"
        "These files are intentionally absent from this public package.\n", encoding="utf-8")
    if (output / "assets/things/assets").exists():
        raise RuntimeError("Local game data unexpectedly entered the package")
    print(f"Packaged {executables[0].name}: {output}")


if __name__ == "__main__":
    main()
