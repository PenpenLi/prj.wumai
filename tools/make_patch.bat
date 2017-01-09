@echo off

set TOOLS_DIR=%CD%\tools

pushd %TOOLS_DIR%

python make_patch.py

popd

pause
