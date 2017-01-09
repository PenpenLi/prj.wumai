@echo off

set TOOLS_DIR=%CD%\tools\common
set LUA=%TOOLS_DIR%\lua\lua.exe
set SQUISH=%TOOLS_DIR%\squish\squish

set LUA_PATH=%1%


REM echo curCd %CD%
REM echo lua %LUA%
REM echo squish %SQUISH%
REM echo luaPath %LUA_PATH%


pushd %LUA_PATH%

REM %LUA% %SQUISH% --del_packed_file --minify --uglify
REM copy blbl.lua.uglified bin\main.lua 
REM --del_packed_file

%LUA% %SQUISH% --gzip --compile

popd

