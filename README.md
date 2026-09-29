# Clientzin

Windows client under integration with the supplied assets, mods and modules.
The local crystalserver summer-update server uses protocol 15.30.

## Windows builds

GitHub Actions builds four combinations using MSVC, Ninja, vcpkg and ANGLE:

- windows-cmake-debug-d3d9
- windows-cmake-debug-d3d11
- windows-cmake-release-d3d9
- windows-cmake-release-d3d11

The windows-cmake-debug and windows-cmake-release presets default to D3D11.
ANGLE translates the existing GLSL shaders to Direct3D; these are not custom
native D3D renderers. Backend initialization fails explicitly rather than
silently switching to another graphics API. Runtime GPU support still needs
validation on real Windows hardware.

Builds and unit tests run on GitHub, not on the development PC. Download the
Clientzin artifact for the desired configuration from this repository's Actions
tab. Each of the four Clientzin artifacts contains exactly the executable and
its matching PDB (including optimized Release symbols). These are binary update
packages: keep assets/modules/mods from your existing installation. Windows builds
use static dependencies and a static MSVC runtime, including ANGLE, so third-party
runtime DLLs do not need to be distributed. Windows and graphics-driver system
libraries remain required. Diagnostics are
uploaded separately, including after failed builds.

## Local game data

**assets/things/assets is intentionally excluded from Git and public packages.**
If `assets.json.sha256` is absent, the client derives its login asset identifier
from the SHA-256 of `catalog-content.json`. This identifies the local catalog;
it is not the official launcher's hash or a verification of every asset file.
The supplied crystalserver records this identifier without enforcing its value.
Copy your existing local game data into that directory before running the client.
No external download endpoint is configured. Other assets, modules and mods are
tracked in the repository, but are not copied into binary update artifacts.
The default login endpoint is http://127.0.0.1/login.php.

## Integration diagnostics

Run python tools/audit_runtime.py for a lightweight static inventory, without
compiling. The JSON report lists module scripts, missing files and unresolved
Lua binding candidates. A candidate can be a guarded call or a dynamically
provided method; this report alone does not certify functional compatibility.
Integration is ongoing: successful compilation does not certify every game
window or every protocol packet. No unsupported function is replaced by a no-op.

## Cache behavior

Completed vcpkg packages and compiler results have separate caches, saved even
if a later build step fails. Keys include compiler version, dependency manifest
and configuration, and use unique run/attempt suffixes with restore prefixes.
They do not include the repository name. Compiler paths are normalized through
SCCACHE_BASEDIRS. Debug and Release are isolated; Release retains optimization.
Dependencies are installed once before the four build jobs.

A failed compilation itself cannot be reused as a successful object. Cache
retention, eviction, changed toolchains and uncacheable compiler invocations can
require recompilation. The cache statistics artifact records hits, misses and
non-cacheable requests. Dependency build trees are not treated as portable
compiled packages.

References: [GitHub cache save](https://github.com/actions/cache/tree/main/save),
[sccache](https://github.com/mozilla/sccache),
[ANGLE](https://github.com/google/angle).

## Credits

Derived from OTClient - Redemption by mehah and contributors, via Kokekanon's
fork, and the original OTClient by edubart and contributors. See LICENSE and
AUTHORS. Upstream copyright notices are preserved.
