--[[
	所有配置表读取入口
]]


local ModuleCfg = class( "ModuleCfg" )







-- 初始化进行数据加载
function ModuleCfg:Awake()
	self.allDatas = MgrCfg.allDatas
end


function ModuleCfg:Start()
end


-- 获取角色db
function ModuleCfg:getRoleDb( roleId )
	return self.allDatas.role_db[ roleId ] or printError( "can't find role db by id %s", roleId )
end
-- 获取技能db
function ModuleCfg:getSkillDb( skillId )
	return self.allDatas.skill_db[ skillId ] or printError( "can't find skill db by id %s", skillId )
end

function ModuleCfg:getBulletDb( bulletId )
	return self.allDatas.bullet_db[ bulletId ] or printError( "can't find bullet db by id %s", bulletId )
end

function ModuleCfg:getBuffDb( buffId )
	return self.allDatas.buff_db[ buffId ] or printError( "can't find buff db by id %s", buffId )
end

function ModuleCfg:getEffectDb( effectId )
	return self.allDatas.effect_db[ effectId ] or printError( "can't find effect db by id %s", effectId )
end

function ModuleCfg:getTrapDb( trapId )
	return self.allDatas.trap_db[ trapId ] or printError( "can't find trap db by id %s", trapId )
end

function ModuleCfg:getMapDb( mapId )
	return self.allDatas.map_db[ mapId ] or printError( "can't find map db by id %s", mapId )
end

function ModuleCfg:getSpawnDb( spawnId )
	return self.allDatas.spawn_db[ spawnId ] or printError( "can't find spawn db by id %s", spawnId )
end





































































-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
---------------------------------------- 以下待清理 ----------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function ModuleCfg:getActionMaskDb( fabName )
	local db = self.allDatas.action_mask_db
	local data = db[fabName]
	return data
end


function ModuleCfg:getActionMaterialsActionDb( fabName )
	local db = self.allDatas.action_materials_db
	local data = db[fabName]
	return data
end


function ModuleCfg:getEffectEmitterDb( id )
	local db = self.allDatas.effect_emitter_db or {}
	return db[ id ] or printError( "can't find effect_emitter_db by id %s", id )
end


function ModuleCfg:getEgidBySkillDb(eGid)
	local skilldb
	for id,db in pairs(self.allDatas.skill_db) do
		local data = db["castWeaponGids"]
		if data and data[1] == eGid then
			skilldb = db
		end
	end 

	return skilldb
end












































function ModuleCfg:getPveDb()
	return self.allDatas.pve_db
end


function ModuleCfg:getPveMapDb(mapid)
	return self.allDatas.pve_map_db[mapid];
end


function ModuleCfg:convertPveGroupDb()
	local dbs = self.allDatas.pve_group_db
	local ArrayIds = {}
	for k, v in pairs( dbs ) do
		table.insert( ArrayIds, v.groupId )
	end

	table.sort( ArrayIds, function( a, b )
		return a < b
	end)

	self.PveGroupArrayIds = ArrayIds
end


function ModuleCfg:getPveGroupDb( id )
	return self.allDatas.pve_group_db[ id ] or printError( "can't find pve_group db by id %s", id )
end


function ModuleCfg:getPveAllGroupIdsWithArray()
	return self.PveGroupArrayIds
end


function ModuleCfg:checkInvalid( id )
	return  id and id ~= "" and id ~= 0
end


function ModuleCfg:getInerestDb()
	return self.allDatas.interest_db
end

function ModuleCfg:getTabActTimeline( id )
	return self.allDatas.action_timeline_db[ id ] or printError( "can't find action_timeline_db db by id %s", id )
end

function ModuleCfg:getTabBuff( id )
	return self.allDatas.action_buff_db[ id ] or printError( "can't find action_buff_db db by id %s", id )
end

function ModuleCfg:getDropViewDB( id )
	return self.allDatas.drop_view_db[ id ] or printError( "can't find drop_view_db db by id %s", id )
end

function ModuleCfg:getDropViewDB( id )
	return self.allDatas.drop_view_db[ id ] or printError( "can't find drop_view_db db by id %s", id )
end

function ModuleCfg:getRnkDB()
	return self.allDatas.rank_false_db;
end

function ModuleCfg:getTalkDB(conditionType,conditionPars)
	local key = conditionType .. "_" .. conditionPars;
	return self.allDatas.role_talk_db[key];
end

function ModuleCfg:getTalkDBById( id )
	return self.allDatas.role_talk_db[ id ] or printError( "can't find drop_view_db db by id %s", id )
end

function ModuleCfg:getTalkSomeDB(conditionType)
	local key = "Type_" .. conditionType;
	return self.allDatas.role_talk_db[key];
end

function ModuleCfg:getTabActEffectTimeline( id )
	return self.allDatas.action_effect_db[ id ] or printError( "can't find action_effect_db db by id %s", id )
end

return ModuleCfg
