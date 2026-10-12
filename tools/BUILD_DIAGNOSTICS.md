# Build cache and diagnostics

The Windows workflow builds Debug and Release for D3D9 and D3D11. Dependencies are installed once per run and their binary packages are shared with the four jobs. Compiler objects are restored and saved separately; configuration probes have separate statistics. Cache maintenance retains the newest generated compiler snapshot per configuration, renderer, compiler and Git ref. Dependency caches are preserved.

Release fast-test presets use a separate core compiled from the same sources and dependency settings without LTO. The production core and executable retain Release IPO/LTO and their matching PDB. This adds a first compilation of the test core but avoids four repeated optimized test links. Tests still run as separate CTest processes, including the independent exception-integrity control executable. The ENABLE_TEST_LTO option defaults to ON, and the original release presets remain available.

Local fast-test profiles:

```powershell
cmake --preset windows-cmake-release-d3d11-fast-tests
cmake --build --preset windows-cmake-release-d3d11-fast-tests --parallel 4
ctest --preset windows-cmake-release-d3d11-fast-tests --no-tests=error --output-on-failure
```

The corresponding d3d9 preset is also available. CI collects JUnit, compiler/configuration cache statistics, CMake configuration, build.ninja, compile commands and Ninja timings. Executable/PDB packaging and static DLL dependency checks remain mandatory. Compare actual compile and link stages separately from dependency preparation, artifact transfer and cache upload; cold runs and warm runs are different workloads.
