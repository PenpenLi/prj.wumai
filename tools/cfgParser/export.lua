--[[
	需要3个参数
	1、资源路径
	2、保存的路径
	cfg_db.lua文件(被require进来)(db导出配置文件)

	导出后会在保存目录生成一个叫CfgFiles.lua的文件列表，包含所有cfg文件名
--]]
local len = #arg

if len < 3 then
	print(string.format( "arg len need 3, but %s", len ))
	return
else
	-- print( string.format( "RES_PATH:%s\nSAVE_PATH:%s\nDB_CFG:%s", arg[1], arg[2], arg[3] ) )
end

------ 解析参数 ------
RES_PATH = arg[1]:gsub("\\", "/")
if RES_PATH:sub(-1) ~= "" then RES_PATH = RES_PATH.."/" end
SAVE_PATH = arg[2]:gsub("\\", "/")
if SAVE_PATH:sub(-1) ~= "" then SAVE_PATH = SAVE_PATH.."/" end
DB_CFG = arg[3]:gsub("\\", "/")


------ 处理luapath ------
package.path = package.path..";./?.lua"..";../?.lua"
package.path = package.path..(string.format(";%s?.lua;", RES_PATH))


------ 加载依赖库 ------
local CfgParser = require("CfgParser")
require("saveTable")
local CSClass = require("CSClass")


------ 加载cfg_db ------
local dbCfg = require(DB_CFG)
if not dbCfg then
	print( string.format( "can't find file dbCfg in %s", DB_CFG ) )
	return
end


------ 解析数据 ------
local allDatas = {}
for file, cfg in pairs( dbCfg ) do
	allDatas[file] = CfgParser.parseFileWithFormater( file, cfg.mode, cfg.formater )
end


------ 保存解析table，覆盖原文件 ------
local fileNames = {}
for file, data in pairs( allDatas ) do
	SaveTable( data, string.format( "%s%s.lua", SAVE_PATH, file ) )
	table.insert( fileNames, file )
end


------ 保存文件列表 ------
-- 保证顺序
table.sort( fileNames )
SaveTable( fileNames, string.format( "%s%s.lua", SAVE_PATH, "CfgFiles" ) )


------ 导出CS数据结构
local CS_PATH = "../../Assets/wumai/Lua/Game/Config/"
for name, data in pairs(dbCfg) do
	data = dofile(name)
	local types, fields = data.types, data.fields

	local cs = CSClass.New()
	-- cs:addNameSpace("Game")
	cs:addClassName(name)

	local key
	for idx, fType in ipairs(types) do
		key = fields[idx]
		if fType == "S" then
			cs:addStringField(key)
		elseif fType == "I" then
			cs:addIntField(key)
		elseif fType == "F" then
			cs:addFloatField(key)
		elseif fType == "boolean" then
			cs:addBoolField(key)
		else
			print(string.format("can't find type %s by key %s", fType, key))
		end			
	end

	cs:save(CS_PATH .. name)
end



print( "======> save complete! <======" )



-- os.execute("pause")
-- daimao={name="cat",niu = false, age=2,body={eyes="green",mouth="big"}}
-- table.save(daimao, "test2.lua")
-- SaveTable(daimao, "test3.lua")