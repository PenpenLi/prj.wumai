--[[
	File Desc: module 加载器，起动所有module
]]



local ModuleLoader = {}



local module_class_name = {
	"ModuleCfg",
	"ModuleRecord",
	"ModuleDrop",
	"ModuleSwitch",
	"ModuleLottery",
	"ModuleItem",
	"ModuleUp",
	"ModulePay",
	"ModuleAlert",
	"ModuleGoal",
	"ModuleQuest",
	"ModuleRole",
	"ModuleLevel",
	"ModuleRank",
	"ModuleGuide",
	"WordFilter",
	"ModuleSDK",
}





function ModuleLoader.init()
	local function createModule( name )
		local class = require( "Game.Module." .. name )
		local instance = class.New()
		return instance
	end

	local moduleList = {}
	for _, name in ipairs( module_class_name ) do
		local mod = createModule( name )
		_G[ name ] = mod
		mod:Awake()
		table.insert( moduleList, mod )
	end

	for _, mod in ipairs( moduleList ) do
		mod:Start()
	end
end



return ModuleLoader