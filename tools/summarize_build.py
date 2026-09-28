#!/usr/bin/env python3
"""Summarize compiler failures and cache reuse while retaining original logs."""
import os
import re
from pathlib import Path

diagnostics = Path("diagnostics")
diagnostics.mkdir(exist_ok=True)
lines = []
fence = chr(96) * 3
for name in ("vcpkg.log", "configure.log", "build.log", "tests.log"):
    source = diagnostics / name
    if not source.exists():
        continue
    content = source.read_text(encoding="utf-8-sig", errors="replace").splitlines()
    failures = list(dict.fromkeys(
        line.strip() for line in content
        if re.search(r"(?:fatal )?error C\d+|error LNK\d+|CMake Error|FAILED:|sccache: error|FAILED TEST", line)
    ))
    reused = [line.strip() for line in content if re.search(r"Restored \d+ package", line)]
    if failures or reused:
        lines.append(f"### {name}")
        lines.extend(reused)
        if failures:
            lines.append(f"{len(failures)} distinct diagnostic lines; first 40 shown:")
            lines.extend([fence + "text", *[line[:700] for line in failures[:40]], fence])
for name in ("dependency-cache.txt", "compiler-cache.txt"):
    source = diagnostics / name
    if source.exists():
        stats = [line for line in source.read_text(encoding="utf-8-sig", errors="replace").splitlines()
                 if re.match(r"Cache hits |Cache misses |Cache writes |Compilation failures |Non-cacheable", line)]
        if stats:
            lines.extend([f"### {name}", fence + "text", *stats, fence])
report = "\n".join(lines) + "\n" if lines else "No compiler or cache diagnostics were produced. See individual steps.\n"
(diagnostics / "summary.md").write_text(report, encoding="utf-8")
if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
    with open(summary, "a", encoding="utf-8") as output:
        output.write(report)
print(report)
