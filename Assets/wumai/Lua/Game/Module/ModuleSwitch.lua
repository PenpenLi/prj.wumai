--[[
	File Desc: 开关
]]



local ModuleSwitch = class( "ModuleSwitch" )



-- 保存间隔
local UPDATE_INTERVAL = 1


local TYPE_DAY_BY_DAY = 1		-- 按天间隔
local TYPE_TIME_TO_TIME = 2		-- 按时段



-- 获取一个按天算的标准时间( 凌晨12点的时间 )
local function getStandardTime( sec )
	local date = os.date( "*t", sec )
	return os.time( { year = date.year, month = date.month, day = date.day, hour = 0 } )
end


function ModuleSwitch:Awake()
	self.switchData = ModuleRecord:getData( "SWITCH" ) or {
		-- id = { active = false, ... }
	}

	local allDb = MgrCfg.allDatas.switch_db
	self.allSwitchDb = allDb

	for k, db in pairs( allDb ) do
		self:addSwitch( db )
	end

	self:_onUpdate()

	-- 是否当日首次激活
	self.dailyActive = self:active( ID_DAILY_SWITCH )
	print("dailyActive", self.dailyActive)
end


function ModuleSwitch:Start()
	local timer = Timer.New( handler( self, self._onUpdate ), UPDATE_INTERVAL, -1 )
	timer:Start()
end


function ModuleSwitch:getSwitchDb( id )
	return self.allSwitchDb[ id ] or printError( "can't find switch by id %s", id )
end


function ModuleSwitch:saveData()
	ModuleRecord:setData( "SWITCH", self.switchData )
end


-- 调试
function ModuleSwitch:printAllSwitch()
	PrintTable( self.switchData, "switch data" )
end


function ModuleSwitch:_onUpdate()
	local curTime = Tools.getCurrentTime()
	for id, data in pairs( self.switchData ) do
		local db = self:getSwitchDb( id )
		if db.type == TYPE_DAY_BY_DAY then
			self:updateSwitchByTypeDayByDay( data, curTime, db )
		elseif db.type == TYPE_TIME_TO_TIME then
			self:updateSwitchByTypeTimeToTime( data, curTime, db )
		end
	end
end









-------------------------添加---------------------------
function ModuleSwitch:addSwitch( switchDb )
	if self.switchData[ switchDb.id ] then return end

	local data = { active = switchDb.active }
	local sType = switchDb.type
	if sType == TYPE_DAY_BY_DAY then
		data.switchTime = getStandardTime( Tools.getCurrentTime() + 3600 * 24 * tonumber( switchDb.value ) )
	elseif sType == TYPE_TIME_TO_TIME then
		local hour, min = string.match( switchDb.value, "(%d*):(%d*)" )
		data.startTime = hour * 3600 + min * 60
		data.endTime = data.startTime + switchDb.duration
		data.lastCheckDay = getStandardTime( Tools.getCurrentTime() )
	end

	data.count = switchDb.count

	self.switchData[ switchDb.id ] = data
	self:saveData()
	-- print( "---> add switch", switchDb.id, data.active, data.count )
end












-------------------------更新---------------------------
function ModuleSwitch:updateSwitchByTypeDayByDay( recordData, curTime, db )
	if recordData.switchTime <= curTime then
		recordData.switchTime = getStandardTime( curTime + 3600 * 24 * tonumber( db.value ) )
		recordData.active = true
		recordData.count = db.count
		self:saveData()
	end
end


function ModuleSwitch:updateSwitchByTypeTimeToTime( recordData, curTime, db )
	local standardTime = getStandardTime( curTime )

	local intime = false
	local curSec = curTime - standardTime
	if curSec >= recordData.startTime and curSec <= recordData.endTime then
		intime = true
	end

	-- 已经不是同一天了
	if standardTime ~= recordData.lastCheckDay then
		recordData.lastCheckDay = standardTime
		if intime then
			recordData.count = db.count
		end

		recordData.active = intime
		self:saveData()
	else
		if recordData.active ~= intime then
			recordData.active = intime
			if intime then
				recordData.count = db.count
			end
			self:saveData()
		end
	end
end


















-------------------------重置---------------------------
function ModuleSwitch:check( id )
	-- print( "---> check", id, debug.traceback() )
	if id == 0 then return true end

	local data = self.switchData[ id ]
	if not data then
		printError( "can't check switch by id %s", id )
		return false
	end

	-- print( "---> check", id, data.active and data.count ~= 0 )

	return data.active and data.count ~= 0
end


-- 激活一次
function ModuleSwitch:active( id )
	if id == 0 then return true end
	if not self:check( id ) then return false end

	local data = self.switchData[ id ]
	data.count = data.count - 1

	return true
end


--@return 返回当前次数和最大次数 
function ModuleSwitch:getCount( id )
	if id == 0 then return 0, 0 end

	local data = self.switchData[ id ]
	if not data then
		printError( "can't check switch by id %s", id )
		return 0, 0
	end

	local db = self:getSwitchDb( id )

	return data.count, db.count
end


function ModuleSwitch:reset( id, count )
	if id == 0 then return end
	
	local data = self.switchData[ id ]
	if not data then
		printError( "can't check switch by id %s", id )
		return 0, 0
	end

	local switchDb = self:getSwitchDb( id )
	local sType = switchDb.type
	if sType == TYPE_DAY_BY_DAY then
	elseif sType == TYPE_TIME_TO_TIME then
		local curTime = Tools.getCurrentTime()
		data.startTime = curTime - getStandardTime( curTime )
		data.endTime = data.startTime + switchDb.duration
		-- data.lastCheckDay = getStandardTime( Tools.getCurrentTime() )
	end

	data.active = switchDb.active
	data.count = count or switchDb.count

	self:saveData()
end







return ModuleSwitch