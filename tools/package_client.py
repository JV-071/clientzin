#!/usr/bin/env python3
"""Package only the Windows client executable and its matching linker PDB."""
import argparse
import shutil
from pathlib import Path

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
    executable = executables[0]
    symbols = executable.with_suffix(".pdb")
    if not symbols.is_file():
        parser.error(f"Matching linker PDB missing: {symbols}")
    output.mkdir(parents=True, exist_ok=True)
    for src in (executable, symbols):
        shutil.copy2(src, output / src.name)
    if {p.name for p in output.iterdir()} != {executable.name, symbols.name}:
        raise RuntimeError("Unexpected files entered the binary update package")
    print(f"Packaged exactly {executable.name} and {symbols.name}: {output}")


if __name__ == "__main__":
    main()
