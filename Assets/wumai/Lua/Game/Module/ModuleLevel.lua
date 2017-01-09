--[[
]]

local ModuleLevel = class( "ModuleLevel" )





function ModuleLevel:Awake()
	local allLevelDb = MgrCfg.allDatas.map_db

	self.startLevelId = 0

	for id, db in pairs(allLevelDb) do
		if db.type == LEVEL_TYPE_NORMAL then
			if db.pre == 0 then
				self.startLevelId = id
			else
				allLevelDb[db.pre].next = id
			end
		elseif db.type == LEVEL_TYPE_DOU_LONG then
			self.douLongZhengBaSai = db
		elseif db.type == LEVEL_TYPE_PET then
			self.chongWuDaLuanDou = db
		elseif db.type == LEVEL_TYPE_BU_LONG then
			self.buLongDaRen = db
		end
	end

	self.allLevelDb = allLevelDb

	-- 建立一个顺序记录的表
	local allOrderedLevel = {}
	local nextId = self.startLevelId
	local db
	while nextId do
		db = self:getLevelDb(nextId)
		table.insert(allOrderedLevel, db)
		nextId = db.next
	end

	self.allOrderedLevel = allOrderedLevel

	-- PrintTable(allLevelDb, "allLevelDb")
end


function ModuleLevel:Start()
end


function ModuleLevel:getLevelDb( levelId )
	return self.allLevelDb[levelId] or printError( "can't find level db by id %s", levelId )
end


function ModuleLevel:getLevelByIndex(index)
	return self.allOrderedLevel[index]
end


function ModuleLevel:getLevelIndex(levelId)
	for idx, db in ipairs(self.allOrderedLevel) do
		if db.id == levelId then
			return idx
		end
	end
	return nil
end


function ModuleLevel:getFirstLevel()
	return self.startLevelId
end


function ModuleLevel:getLastLevel()
	local headId = self:getFirstLevel()
	if not self:isUnlock(headId) then
		return headId
	end

	local nextId
	while true do
		nextId = self:getNextLevel(headId)
		if not nextId then
			return headId
		end

		if not self:isUnlock(nextId) then
			return nextId
		end

		headId = nextId
	end

	return headId
end


function ModuleLevel:isUnlock(id)
	if UNLOCK_ALL_LEVEL then return true end
	if id == 0 then return true end

	local db = self:getLevelDb(id)
	local questIds = db.questIds
	-- 只看第一个任务
	if questIds[1] then
		return ModuleQuest:isPassed(questIds[1])
	end

	return true
end


function ModuleLevel:getNextLevel( id )
	local db = self:getLevelDb(id)
	return db.next
end


function ModuleLevel:getPreLevel( id )
	local db = self:getLevelDb(id)
	return db.pre
end


function ModuleLevel:setCurLevel( id )
	self.curLevelId = id
end


function ModuleLevel:setLevelData(data)
	self.curLevelData = data
end


function ModuleLevel:getDLZBSPassedWave()
	return ModuleRecord:getData("DLZBS", 0)
end


function ModuleLevel:setDLZBSPassedWave(value)
	ModuleRecord:getData("DLZBS", value)
end


function ModuleLevel:checkVit(id)
	local db = self:getLevelDb(id)
	if not db then return false end

	-- 扣体力
	if ModuleItem:getItemCount( ID_ITEM_VITALITY ) < db.vit then
		ModuleAlert:alertText("体力不足")
		return false
	end

	return true
end


function ModuleLevel:checkIn(id)
	local db = self:getLevelDb(id)
	if not db then return false end

	-- 扣体力
	if not ModuleItem:consumeItem( ID_ITEM_VITALITY, db.vit, true ) then
		ModuleAlert:alertText("体力不足")
		return false
	end

	-- 激活开关
	ModuleSwitch:active(db.switchId)

	return true
end

















return ModuleLevel
