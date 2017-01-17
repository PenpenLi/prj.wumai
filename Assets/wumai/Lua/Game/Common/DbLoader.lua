--[[
	读取数据到CS
]]
local MgrCfg = require "Manager/MgrCfg"
local M = {}

MgrCfg:load()

function M.init(dbName, creator)
	local db = MgrCfg.allDatas[dbName]

	for id, data in pairs(db) do
		print("init-->", dbName, id)
		print("creator", creator)
		local item = creator:Invoke()
		item:init(id, data)
	end
end







return M
