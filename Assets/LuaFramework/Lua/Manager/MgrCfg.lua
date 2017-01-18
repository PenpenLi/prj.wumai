local M = class( "MgrCfg" )
local CONFIG_PATH = "Game/Config"
local cfgFiles = require(string.format("%s.CfgFiles", CONFIG_PATH))


local allDatas = {}
for i,v in ipairs( cfgFiles ) do
	allDatas[v] = require( string.format( "%s.%s", CONFIG_PATH, v ) )
end
M.allDatas = allDatas


function M.getData(dbName)
	return allDatas[dbName]
end


function M.getKeys(dbName)
	local db = allDatas[dbName]
	local keys = {}
	for k, _ in pairs(db) do
		table.insert(keys, k)
	end

	return unpack(keys)
end


return M