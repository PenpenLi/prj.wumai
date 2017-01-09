--[[
	File Desc:ModuleDrop
]]



local ModuleDrop = class( "ModuleDrop" )




-- 几率计算方法相关常数
local METHOD_BASE1 = 1 -- 独立几率算法
local METHOD_BASE2 = 2 -- 圆桌算法




function ModuleDrop:Awake()
	self.allDropDb = MgrCfg.allDatas.drop_db or {}
end


function ModuleDrop:Start()
end


function ModuleDrop:getDropDb( dropId )
	return self.allDropDb[ dropId ] or printError( "can't find drop db by id %s", dropId )
end


-- 独立几率算法
local function lfMakeDropBase1_singleRate( itemList )
	local ret = {}
	local random, oneDrop

	if itemList then
		for i, itemInfo in ipairs(itemList) do
			random = math.random( 1, 10000 )
			if random <= itemInfo.rate then
				oneDrop = {
					itemId = itemInfo.id,
					count = math.random( itemInfo.min, itemInfo.max )
				}
				table.insert( ret, oneDrop )
			end
		end
	end

	return ret 
end


-- 圆桌算法
local function lfMakeDropBase2_roundRate( itemList, sum )
	if not sum then
		sum = 0
		for i, item in ipairs( itemList ) do
			sum = sum + item.rate
		end
	end

	if sum <= 0 then return {} end

	if itemList then
		local random = math.random( 1, sum )
		-- 遍历所有掉落物品
		for i, itemInfo in ipairs( itemList ) do
			if random <= itemInfo.rate then -- 需要掉落
				local oneDrop = {
					itemId = itemInfo.id, -- 物品id
					count = math.random( itemInfo.min, itemInfo.max )
				}
				return { oneDrop }
			end

			random = random - itemInfo.rate
		end
	end

	return {}
end


local DROP_CALC_FUNCS = {
	[METHOD_BASE1] = lfMakeDropBase1_singleRate,
	[METHOD_BASE2] = lfMakeDropBase2_roundRate,
}


-- 获取掉落的所有物品
function ModuleDrop:getDropAllItems( dropId )
	if not dropId or dropId == 0 then
		return {}
	end

	local db = self:getDropDb( dropId )
	local itemList = db.items
	local ret = {}
	-- 遍历所有掉落物品
	for i, itemInfo in ipairs( itemList ) do
		local oneDrop = {
			itemId = itemInfo.id,
			count = itemInfo.max,
		}
		table.insert( ret, oneDrop )
	end

	return ret
end


-- 进行掉落(用drop封装物品)
function ModuleDrop:makeDrop( dropId, forPreview )
	if forPreview then return self:getDropAllItems( dropId ) end

	if not dropId or dropId == 0 then
		return {}
	end

	local db = self:getDropDb( dropId )
	local itemList = db.items

	local calcFunc = DROP_CALC_FUNCS[ db.type ]
	local drops
	if calcFunc then
		drops = calcFunc( itemList, db.sum )
	end
	
	return drops
end




return ModuleDrop