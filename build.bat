@echo off
setlocal
rem Clientzin: optional manual build entrypoint. CI is the normal build environment.
set "PRESET=%~1"
if not defined PRESET set "PRESET=windows-cmake-release-d3d11"
cmake --preset "%PRESET%"
if errorlevel 1 exit /b %errorlevel%
cmake --build --preset "%PRESET%"
exit /b %errorlevel%
