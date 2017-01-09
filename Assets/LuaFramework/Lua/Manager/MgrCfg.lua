local M = class( "MgrCfg" )
local CONFIG_PATH = "Game/Config"
local cfgFiles = require(string.format("%s.CfgFiles", CONFIG_PATH))

function M:load()
	local allDatas = {}
	for i,v in ipairs( cfgFiles ) do
		allDatas[v] = require( string.format( "%s.%s", CONFIG_PATH, v ) )
	end
	self.allDatas = allDatas
end

function M:getData(name)
	return self.allDatas[name]
end

return M