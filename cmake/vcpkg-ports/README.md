# ANGLE static exception ABI

The angle overlay is copied from microsoft/vcpkg commit
9e593bb18ea69cc5095e012465dcd675a822ed0d. The only build change sets
`_HAS_EXCEPTIONS=1` instead of `0`; the port version is incremented.

Clientzin and its tests use MSVC C++ exceptions. A statically linked ANGLE
must use the same MSVC standard exception layout. The upstream setting
can introduce incompatible definitions of standard exception constructors
and virtual methods into the client executable.

Keep this overlay synchronized with the pinned vcpkg revision. The runtime
exception integrity tests, including the standalone control, verify the
linked result in Debug and Release for both renderer configurations.
