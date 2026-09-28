#!/usr/bin/env python3
"""Audit the runtime/source contract without compiling or changing runtime files.

The binding report is deliberately a candidate list, not proof that a call fails:
Lua can define methods dynamically and some calls are guarded capability checks.
"""
import argparse
import collections
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(path):
    return path.read_text(encoding="utf-8-sig", errors="replace")


def audit():
    sources = {p.relative_to(ROOT).as_posix(): text(p)
               for p in (ROOT / "src").rglob("*") if p.suffix in (".cpp", ".h")}
    runtime = {p.relative_to(ROOT).as_posix(): text(p)
               for root in ("modules", "mods") for p in (ROOT / root).rglob("*")
               if p.suffix in (".lua", ".otui", ".otmod", ".html")}
    bindings = set()
    class_bindings = collections.defaultdict(set)
    for content in sources.values():
        bindings.update(".".join(m) for m in re.findall(
            r'(?:bindSingletonFunction|bindClassStaticFunction)\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"', content))
        for cls, method in re.findall(
                r'bindClass(?:Member|Static)Function\s*<\s*(\w+)\s*>\s*\(\s*"([^"]+)"', content):
            class_bindings[cls].add(method)
    # g_settings is a Config Lua object, not a singleton.
    bindings.update("g_settings." + method for method in class_bindings["Config"])
    for content in runtime.values():
        bindings.update("g_settings." + method for method in re.findall(r"function\s+Config[.:](\w+)\s*\(", content))
    lua_definitions = set()
    for content in runtime.values():
        lua_definitions.update(".".join(m) for m in re.findall(
            r'function\s+(g_\w+)\.(\w+)\s*\(', content))
        lua_definitions.update(".".join(m) for m in re.findall(
            r'\b(g_\w+)\.(\w+)\s*=\s*function\b', content))
    calls = collections.defaultdict(list)
    modules = {}
    missing_scripts = []
    for name, content in runtime.items():
        for number, line in enumerate(content.splitlines(), 1):
            if line.lstrip().startswith("--"):
                continue
            for obj, method in re.findall(r'\b(g_\w+)\.(\w+)\s*\(', line):
                calls[obj + "." + method].append(f"{name}:{number}")
        if name.endswith(".otmod"):
            match = re.search(r'^\s*name:\s*(\S+)', content, re.M)
            if not match:
                continue
            module = match.group(1)
            modules[module] = {"file": name, "description": "", "scripts": []}
            description = re.search(r'^\s*description:[ \t]*(.*)', content, re.M)
            if description:
                modules[module]["description"] = description.group(1).strip()
            scripts = re.search(r'^\s*scripts:\s*\[([^\]]*)\]', content, re.M)
            if scripts:
                for script in scripts.group(1).split(","):
                    script = script.strip().strip("'\"")
                    if not script:
                        continue
                    script_path = (ROOT / name).parent / (script if script.endswith(".lua") else script + ".lua")
                    if "*" in script:
                        matches = sorted(script_path.parent.rglob(script_path.name))
                        modules[module]["scripts"].extend(p.relative_to(ROOT).as_posix() for p in matches)
                        if not matches:
                            missing_scripts.append(str(script_path.relative_to(ROOT)))
                        continue
                    modules[module]["scripts"].append(script_path.relative_to(ROOT).as_posix())
                    if not script_path.is_file():
                        missing_scripts.append(str(script_path.relative_to(ROOT)))
    unresolved = []
    for call in sorted(calls.keys() - bindings - lua_definitions):
        method = call.split(".")[1]
        unresolved.append({"call": call, "locations": sorted(set(calls[call])),
                           "source_candidates": [p for p, content in sources.items()
                                                 if re.search(r'\b' + re.escape(method) + r'\b', content)]})
    required = ["assets/setup.otml",
                "init.lua", "config.ini"]
    missing_files = [p for p in required if not (ROOT / p).is_file()]
    # Validate catalog references without decoding large binary sprite resources.
    missing_catalog = []
    for folder in (ROOT / "assets/things/assets", ROOT / "assets/sounds"):
        for catalog in folder.glob("catalog*.json"):
            data = json.loads(text(catalog))
            entries = data if isinstance(data, list) else []
            for entry in entries:
                filename = entry.get("file") if isinstance(entry, dict) else None
                if filename and not (folder / filename).is_file():
                    missing_catalog.append(str((folder / filename).relative_to(ROOT)))
    return {"module_count": len(modules), "singleton_calls": len(calls),
            "unresolved_candidates": unresolved, "modules": modules,
            "missing_scripts": missing_scripts, "missing_runtime_files": missing_files,
            "missing_catalog_files": missing_catalog}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "diagnostics/runtime-audit.json")
    args = parser.parse_args()
    result = audit()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Modules: {result['module_count']}; singleton calls: {result['singleton_calls']}")
    print(f"Unresolved binding candidates: {len(result['unresolved_candidates'])}")
    print(f"Report: {args.output}")
    missing = result["missing_scripts"] + result["missing_runtime_files"] + result["missing_catalog_files"]
    for path in missing:
        print(f"ERROR: missing runtime resource: {path}")
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
