--[[
	游戏存档数据

	目前没有存档版本的解决方案，需在开发中自行进行兼容性调整，故这里只是简单的文件读写，没有版本及数据结构的验证判断
]]

local util = require "3rd.cjson.util"



local ModuleRecord = class( "ModuleRecord" )




-- 路径
ModuleRecord.RECORD_PATH_ROOT = Application.persistentDataPath .. "/.rd/"
local FAST_RECORD_FILE = ModuleRecord.RECORD_PATH_ROOT .. ".rd"

-- 保存间隔
local SAVE_INTERVAL = 1

-- 每次起动游戏重置存档
local ALWAYS_RESET_RECORD = false



function ModuleRecord:Awake()
	self.dataList = {}

	self:initFile(FAST_RECORD_FILE)
	print("record path:" .. FAST_RECORD_FILE)
end


function ModuleRecord:Start()
	local timer = Timer.New( handler( self,self._onEnterFrame ), SAVE_INTERVAL, -1 )
	timer:Start()
end


function ModuleRecord:initFile(fileName)
	assert(fileName)
	self:_readRecord(fileName)
end


function ModuleRecord:_onEnterFrame()
	for fileName, data in pairs(self.dataList) do
		if data.needSave then
			self:_saveData(fileName)
			data.needSave = false
		end
	end
end


function ModuleRecord:resetRecord(fileName)
	-- 创建存档文件价
	if not Tools.ExistsDirectory( ModuleRecord.RECORD_PATH_ROOT ) then
		Tools.CreateDirectory( ModuleRecord.RECORD_PATH_ROOT )
	end

	self.dataList[fileName] = {needSave = true, data = {}}
end


function ModuleRecord:_readRecord(fileName)
	if not Tools.ExistsFile(fileName) or ALWAYS_RESET_RECORD then
		self:resetRecord(fileName)
		return
	end

	local data = Tools.ReadAllText(fileName)

	local dataStr = Tools.Decode( data )		-- Base64.decode( data )
	local dataTable = Tools.deserializeTable( dataStr ) --json.decode( data )

	self.dataList[fileName] = {data = dataTable}

	-- PrintTable( dataTable, "-----------> read dataTable" )
end


function ModuleRecord:_writeRecord(fileName)
	local dataTable = (self.dataList[fileName] or {}).data or {}
	
	-- PrintTable( dataTable, "-----------> write dataTable" )

	local dataStr = Tools.serializeTable( dataTable ) --json.encode( dataTable )
	
	if dataStr then
		local base64Text = Tools.Encode( dataStr )		-- Base64.encode( jsonText )
		Tools.WriteAllText( fileName, base64Text )
	end
end


function ModuleRecord:_saveData(fileName)
	self:_writeRecord(fileName)
end






----- 常用数据读写 -----
function ModuleRecord:getData( key, default )
    if self.dataList[FAST_RECORD_FILE].data[key] ~= nil then
    	return self.dataList[FAST_RECORD_FILE].data[key]
    else
    	return default
    end
end


function ModuleRecord:setData( key, value )
	self.dataList[FAST_RECORD_FILE].data[key] = value
	self.dataList[FAST_RECORD_FILE].needSave = true
end



-- 不同写入频率的数据，分文件进行存档
function ModuleRecord:getCustomData(fileName, key, default)
	local data = self.dataList[fileName]
	if not data then
		printWarn(fileName .. " uninitialized get.")
		self:initFile(fileName)
		data = self.dataList[fileName]
	end

	if data.data[key] ~= nil then
		return data.data[key]
	else
		return default
	end
end


function ModuleRecord:setCustomData(fileName, key, value)
	local data = self.dataList[fileName]
	if not data then
		printWarn(fileName .. " uninitialized set.")
		self:initFile(fileName)
		data = self.dataList[fileName]
	end

	data.data[key] = value
	data.needSave = true
end














return ModuleRecord