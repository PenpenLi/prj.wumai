@echo off
set TOOL_ROOT=%1%cfgParser

echo ROOT:%TOOL_ROOT%


set RES_PATH=../../_config/lua
set SAVE_PATH=../../Assets/wumai/Lua/Game/Config
set DB_CFG=cfg_db

pushd %TOOL_ROOT%

export.lua %RES_PATH% %SAVE_PATH% %DB_CFG%

popd

