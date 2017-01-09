--[[
	角色
]]


local ModuleRole = class( "ModuleRole" )




local function sortRole(db1, db2)
	local value1 = db1.order + (ModuleUp:query(db1.upId) > 0 and 0 or 1000)
	local value2 = db2.order + (ModuleUp:query(db2.upId) > 0 and 0 or 1000)
	return value1 < value2
end


-- ui排序
local ROLE_GID_ORDER = {}




-- 初始化进行数据加载
function ModuleRole:Awake()
	self.allRoleDb = MgrCfg.allDatas.role_db
	self.allHerosByGid = {}
	self.allHerosList = {}
	self.allPets = {}
	for id, db in pairs( self.allRoleDb ) do
		if db.type == CREATURE_TYPE.HERO then
			if not self.allHerosByGid[db.gid] then
				self.allHerosByGid[db.gid] = {dbs = {}}
				table.insert(ROLE_GID_ORDER, db.gid)
			end

			if db.rob then
				self.allHerosByGid[db.gid].robId = id
			else
				self.allHerosByGid[db.gid].order = db.order
				table.insert(self.allHerosByGid[db.gid].dbs, db)
				table.insert(self.allHerosList, db)
			end
		elseif db.type == CREATURE_TYPE.PET then
			table.insert(self.allPets, db)
		end
	end

	local sortFunc = function ( db1, db2 )
		return db1.order < db2.order
	end

	for gid, list in pairs(self.allHerosByGid) do
		table.sort(list.dbs, sortFunc)
	end


	-- PrintTable(self.allHerosList, "allHerosList" .. #self.allHerosList)
	-- PrintTable(self.allHerosByGid, "allHerosByGid" .. #self.allHerosByGid)
	-- PrintTable(ROLE_GID_ORDER, "ROLE_GID_ORDER")
end


function ModuleRole:Start()
	table.sort(self.allPets, sortRole)
	table.sort(self.allHerosList, sortRole)
	table.sort(ROLE_GID_ORDER)
end


-- 获取所有角色db
function ModuleRole:getAllRoleDb()
	return self.allRoleDb
end


-- 获取角色db
function ModuleRole:getRoleDb( roleId )
	return self.allRoleDb[ roleId ] or printError( "can't find role db by id %s %s", roleId, type(roleId) )
end


function ModuleRole:getAllPet()
	return self.allPets
end


function ModuleRole:getAllHeroInfo( gid )
	if gid then
		return self.allHerosByGid[gid]
	else
		return self.allHerosByGid
	end
end


-- 找到下一组角色
function ModuleRole:getNextGid( curDid )
	local index = 1
	for i, gid in ipairs(ROLE_GID_ORDER) do
		if gid == curDid then
			index = i + 1
			break
		end
	end

	if index > #ROLE_GID_ORDER then
		index = 1
	end

	return ROLE_GID_ORDER[index]
end


function ModuleRole:getPreGid(curDid)
	local index = 1
	for i, gid in ipairs(ROLE_GID_ORDER) do
		if gid == curDid then
			index = i - 1
			break
		end
	end

	if index < 1 then
		index = #ROLE_GID_ORDER
	end

	return ROLE_GID_ORDER[index]
end


-- 根据角色分组找到相应的机甲id
-- 如果传入机甲id则返回机甲id本身
-- 如果传入宠物或者怪物则返回空
function ModuleRole:getRobId(roleId)
	local gid = self:getRoleDb(roleId).gid
	if self:getAllHeroInfo(gid) then
		--print(roleId, gid, self:getAllHeroInfo(gid).robId)
		return self:getAllHeroInfo(gid).robId
	end
end


-- 找到一个已解锁中最高级的
function ModuleRole:findLastRoleDb( gid )
	local dbs = self:getAllHeroInfo( gid ).dbs
	for i = #dbs, 1, -1 do
		if ModuleUp:query(dbs[i].upId) > 0 then
			return dbs[i]
		end
	end

	return dbs[1]
end


function ModuleRole:canUnlock(roleId)
	local db = self:getRoleDb(roleId)
	if not db.rob then
		return true
	end

	local data = self:getAllHeroInfo(db.gid)
	for _, heroDb in ipairs(data.dbs) do
		if ModuleUp:query(heroDb.upId) > 0 then
			return true
		end
	end

	return false
end


function ModuleRole:isUnlock(roleId)
	local db = self:getRoleDb(roleId)
	return ModuleUp:query(db.upId) > 0
end


function ModuleRole:getCurRoleId()
	return ModuleRecord:getData( "UI_ROLE" ) or self.allHerosByGid[ROLE_GID_ORDER[1]].dbs[1].id
end


function ModuleRole:getCurPetId()
	return ModuleRecord:getData( "UI_PET" ) or self.allPets[1].id
end


function ModuleRole:setCurRoldId(roleId)
	ModuleRecord:setData( "UI_ROLE", roleId )
end


function ModuleRole:setCurPetId(petId)
	ModuleRecord:setData( "UI_PET", petId )
end


function ModuleRole:getRoleIndex( roleId )
	local db = self:getRoleDb(roleId)
	local dbs = self.allHerosByGid[db.gid].dbs
	for i, roleDb in ipairs(dbs) do
		if roleDb.id == roleId then
			return i
		end
	end

	return 0
end


-- 超过返回自动滚动
function ModuleRole:getRoleByIndex( gid, index )
	local dbs = self.allHerosByGid[gid].dbs

	if index > #dbs then
		index = 1
	elseif index < 1 then
		index = #dbs
	end

	return dbs[index]
end


function ModuleRole:getNextRoleDb(roleId)
	local db = self:getRoleDb(roleId)
	local index = self:getRoleIndex(roleId) + 1
	return self:getRoleByIndex(db.gid, index)
end


function ModuleRole:getPreRoleDb(roleId)
	local db = self:getRoleDb(roleId)
	local index = self:getRoleIndex(roleId) - 1
	return self:getRoleByIndex(db.gid, index)
end


function ModuleRole:unlock(roleId, onResult, COP)
	local db = self:getRoleDb( roleId )
	ModuleUp:unlock( db.upId, function (suc)
			if suc then
				if db.type == CREATURE_TYPE.HERO and not db.rob then
					table.sort(self.allHerosList, sortRole)
				elseif db.type == CREATURE_TYPE.PET then
					table.sort(self.allPets, sortRole)
				end

				sendMsg("MSG_ROLE_UNLOCK_SUC", db)
				AudioPlayer.instance:playSound("Voi-Good-00" .. math.random( 3, 4 ))
			end
			
			if onResult then
				onResult(suc)
			end
		end, COP )
end


function ModuleRole:tryNotifyUnlock(upId)
	for id, db in pairs(self.allRoleDb) do
		if db.upId == upId then
			if db.type == CREATURE_TYPE.HERO and not db.rob then
				table.sort(self.allHerosList, sortRole )
			elseif db.type == CREATURE_TYPE.PET then
				table.sort(self.allPets, sortRole)
			end

			sendMsg("MSG_ROLE_UNLOCK_SUC", db)
			break
		end
	end
end


function ModuleRole:lvup(roleId)
	local db = self:getRoleDb( roleId )
	if ModuleUp:lvup( db.upId ) then
		sendMsg("MSG_ROLE_LVUP_SUC", db)
		AudioPlayer.instance:playSound("Voi-Good-00" .. math.random( 3, 4 ))
		return true
	end

	return false
end


function ModuleRole:lvupQuick(roleId, callback)
	local db = self:getRoleDb( roleId )
	ModuleUp:lvupQuick( db.upId, function ()
		if callback then
			callback()
		end
		sendMsg("MSG_ROLE_LVUP_SUC", db)
		AudioPlayer.instance:playSound("Voi-Good-00" .. math.random( 3, 4 ))
	end )
end


-- 获取角色当前等级
function ModuleRole:getRoleLevel( roleId )
	local roleDb = self:getRoleDb( roleId )
	if not roleDb then return nil end

	local level = ModuleUp:query(roleDb.upId)
	return level
end


-- 获取角色最大等级
function ModuleRole:getRoleMaxLevel( roleId )
	local roleDb = self:getRoleDb( roleId )
	if not roleDb then return nil end

	return ModuleUp:getMaxLv(roleDb.upId)
end


-- 获取角色养成数据
-- level 不指定等级则使用当前等级
function ModuleRole:getRoleUpDb( roleId, level )
	local roleDb = self:getRoleDb( roleId )
	if not roleDb then return nil end

	return ModuleUp:getUpDbByLevel(roleDb.upId, level)
end


-- 获取机甲的养成属性(根据相应角色属性进行提升)
-- @param roleId 角色id，不是机甲id
function ModuleRole:getRobUpDb( roleId, level)
	local index = self:getRoleIndex(roleId)
	if index == 0 then
		printWarn("can't find rob by roleId", roleId)
		return nil
	end

	local upDb = self:getRoleUpDb(roleId, level)
	local robUpDb = table.deepCopy(upDb)

	local rate = ROB_UP_RATE[index]
	if rate then
		for k, v in pairs(rate) do
			if robUpDb[k] then
				robUpDb[k] = robUpDb[k] * v
			end
		end
	end

	return robUpDb
end


function ModuleRole:calcPowerWithAttribute( attribute )
	-- 攻击*25/6+防御*20/8+生命/4+闪避*80/100+暴击*80/100+回血*15/5+回血*15/5 +魔法/2
	attribute = attribute or {}
	local atk = attribute.atk or 0
	local def = attribute.def or 0
	local maxHp = attribute.maxHp or 0
	local maxMp = attribute.maxMp or 0
	local cri   = attribute.cri or 0
	local regenHp   = attribute.regenHp or 0
	local regenMp   = attribute.regenMp or 0		
	local power = math.ceil( atk *25 / 6 + def * 30 / 6 + maxHp / 5 + maxMp / 3 + cri * 80 / 100 + regenHp * 15 / 5 + regenMp * 15 / 5)

	return power
end


function ModuleRole:calcPowerWithRoleId( roleId, level )
	return self:calcPowerWithAttribute(self:getRoleUpDb(roleId, level))
end


-- 计算所有宠物和角色战力
function ModuleRole:getGetAllRolePower()
	local power = 0
	for _, db in ipairs(self.allPets) do
		if self:isUnlock(db.id) then
			power = power + self:calcPowerWithRoleId(db.id)
		end
	end

	for _, db in ipairs(self.allHerosList) do
		if self:isUnlock(db.id) then
			power = power + self:calcPowerWithRoleId(db.id)
		end
	end

	return power
end


-- 计算平均等级
function ModuleRole:getPetAverageLevel()
	local totalLv = 0
	for _, db in pairs(self.allPets) do
		if self:isUnlock(db.id) then
			totalLv = totalLv + ModuleUp:query(db.upId)
		end
	end

	return totalLv / #self.allPets
end


function ModuleRole:getMaxPowerRoleId()
	local max = 0
	local roleId = nil
	for idx, db in ipairs(self.allHerosList) do
		if self:isUnlock(db.id) then
			local power = self:calcPowerWithRoleId(db.id)
			if max < power then
				max = power
				roleId = db.id
			end
		end
	end

	return roleId
end


function ModuleRole:getMaxPowerPetId()
	local max = 0
	local roleId = nil
	for idx, db in ipairs(self.allPets) do
		if self:isUnlock(db.id) then
			local power = self:calcPowerWithRoleId(db.id)
			if max < power then
				max = power
				roleId = db.id
			end
		end
	end

	return roleId
end


function ModuleRole:getUnlockRoleList()
	local unlockList = {}
	for i, db in ipairs(self.allHerosList) do
		if self:isUnlock(db.id) then
			table.insert(unlockList, db)
		end
	end

	return unlockList
end


function ModuleRole:refreshTip()
	local list = self:getUnlockRoleList()
	for i, db in ipairs(list) do
		if ModuleUp:checkUpCanLvup(db.upId) then
			return true
		end
	end
	
	return false
end





return ModuleRole
