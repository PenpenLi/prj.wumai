--[[
	File Desc:物品系统
]]



local ModuleItem = class( "ModuleItem" )



function ModuleItem:Awake()
	self.allItems = ModuleRecord:getData( "ITEM" ) or {
		-- [itemId] ={ count = cnt }
	}

	self.allItemDb = MgrCfg.allDatas.item_db or {}
end


function ModuleItem:Start()
	if not ModuleRecord:getData( "GET_INIT_ITEMS" ) then
		for _, item in ipairs( INIT_ITEMS ) do
			self:addItem( item.id, item.count )
		end

		ModuleRecord:setData( "GET_INIT_ITEMS", true )
	end

	Timer.New(handler(self, self.updateVit), 1, -1):Start()
	ModuleSDK:ckCurrencyChange(self:getItemCount(ID_ITEM_MONEY_COINS), self:getItemCount(ID_ITEM_MONEE_DIAMOND), self:getItemCount(ID_ITEM_VITALITY))
end


function ModuleItem:updateVit()
	local curCount = self:getItemCount(ID_ITEM_VITALITY)
	if curCount < VIT_MAX_LIMIT then
		local curTime = Tools.getCurrentTime()
		local addTime = ModuleRecord:getData( "VIT_ADD_TIME", curTime )
		if addTime <= curTime then
			local count = math.floor((curTime - addTime) / VIT_ADD_DELTA)

			local nowCount = math.min(curCount + count + 1, VIT_MAX_LIMIT)
			self:addItem(ID_ITEM_VITALITY, nowCount - curCount)

			ModuleRecord:setData("VIT_ADD_TIME", addTime + (count + 1) * VIT_ADD_DELTA)
		end
	end
end


function ModuleItem:saveData()
	ModuleRecord:setData( "ITEM", self.allItems )
end


function ModuleItem:getItemDb( itemId )
	return self.allItemDb[ itemId ] or printError( "can't find item db by id %s", itemId )
end


function ModuleItem:addItem( itemId, itemCount, sources )
	itemCount = itemCount or 1
	
	local itemData = self.allItems[itemId]
	if not itemData then	
		itemData = { count = 0 }
		self.allItems[itemId] = itemData
	end


	local lastCount = itemData.count
	local curCount = lastCount + itemCount
	
	itemData.count = curCount

	local db = self:getItemDb( itemId )
	-- 物品触发开关
	ModuleSwitch:active( db.switchId or 0 )
	
	-- 统计
	if db.type == ITEM_TYPE_CURRENCY then
		ModuleSDK:ckCurrencyChange(self:getItemCount(ID_ITEM_MONEY_COINS), self:getItemCount(ID_ITEM_MONEE_DIAMOND), self:getItemCount(ID_ITEM_VITALITY))
	elseif sources then
		ModuleSDK:ckGetItem(itemId, sources)
	end

	ModuleGoal:commit( "ACTION_GET_ITEM", itemId, itemCount )
	sendMsg( "MSG_ITEM_CHANGE", { itemId = itemId, lastCount = lastCount, curCount = curCount } )

	self:saveData()
end


function ModuleItem:subItem( itemId, itemCount )
	itemCount = itemCount or 1

	local itemData = self.allItems[itemId]

	if not itemData then return false end -- 未持有该物品
	if itemData.count < itemCount then return false end -- 持有数量比要求减去的少

	local lastCount = itemData.count
	local curCount = lastCount - itemCount

	itemData.count = curCount
	self:saveData()

	ModuleGoal:commit( "ACTION_USE_ITEM", itemId, itemCount )
	sendMsg( "MSG_ITEM_CHANGE", { itemId = itemId, lastCount = lastCount, curCount = curCount } )
	
	-- -- 统计
	local db = self:getItemDb( itemId )
	if db.type == ITEM_TYPE_CURRENCY then
		ModuleSDK:ckCurrencyChange(self:getItemCount(ID_ITEM_MONEY_COINS), self:getItemCount(ID_ITEM_MONEE_DIAMOND), self:getItemCount(ID_ITEM_VITALITY))
	end
	
	return true
end


function ModuleItem:getItemCount( itemId )
	if not self.allItems[itemId] then
		return 0
	end

	return self.allItems[itemId].count
end


function ModuleItem:getItemType( itemId )
	local db = self:getItemDb( itemId )
	if db then
		return db.type
	end
end


-- 使用物品
-- 对于掉落和抽奖类物品会直接返回掉落和抽奖的最终结果，如果是货币和普通物品类型则返回自己
-- 不会改变物品数量，但是会对抽奖造成影响
-- 若有掉落，则每次unpackItem可能会产生不同的结果
-- @param forPreview 是否预览(true时：对抽奖有影响，并且会被排序)
-- @return 物品列表 { itemId1 = count1, itemId2 = count2 }
function ModuleItem:unpackItem( itemId, count, forPreview )
	if not itemId or itemId == 0 then return {} end
	
	local items = self:_unpackItem( itemId, count, {}, forPreview )
	local itemArr = {}
	for id, count in pairs( items ) do
		table.insert( itemArr, { itemId = id, count = count } )
	end

	if forPreview then
		table.sort( itemArr, function ( itemA, itemB )
			local dbA = self:getItemDb( itemA.itemId )
			local dbB = self:getItemDb( itemB.itemId )
			return dbA.sort > dbB.sort
		end )
	end

	return itemArr
end


function ModuleItem:_unpackItem( itemId, count, itemList, forPreview )
	count = count or 1
	itemList = itemList or {}
	local iType = self:getItemType( itemId )
	for i = 1, count do
		if iType == ITEM_TYPE_CURRENCY
		or iType == ITEM_TYPE_NORMAL then
			local amount = itemList[ itemId ] or 0
			amount = amount + count
			itemList[ itemId ] = amount
			break
		elseif iType == ITEM_TYPE_DROP then
			local db = self:getItemDb( itemId )
			local items = ModuleDrop:makeDrop( db.wrapId, forPreview )
			for _, item in ipairs( items ) do
				self:_unpackItem( item.itemId, item.count, itemList, forPreview )
			end
		elseif iType == ITEM_TYPE_LOTTERY then
			local db = self:getItemDb( itemId )
			local item = ModuleLottery:makeLottery( db.wrapId, forPreview )
			self:_unpackItem( item.itemId, item.count, itemList, forPreview )
		elseif iType == ITEM_TYPE_RMB then
			printError( "useItem error, can't use RMB." )
		else
			printError( "useItem error, invalid item type." )
		end
	end

	return itemList
end


-- 针对礼包的掉落处理，故只能是一个掉落物品（物品不需要合并，主要用于显示）
function ModuleItem:unpackDropItem( itemId, count, forPreview )
	local iType = self:getItemType( itemId )

	if iType == ITEM_TYPE_DROP then
		local db = self:getItemDb( itemId )
		local items = ModuleDrop:makeDrop( db.wrapId, forPreview )
		table.sort( items, function( itemA, itemB )
			local dbA = self:getItemDb( itemA.itemId )
			local dbB = self:getItemDb( itemB.itemId )
			return dbA.sort > dbB.sort
		end )
		return items
	else
		return self:unpackItem( itemId, count, forPreview )
	end
end


-- 添加wrap物品，会把掉落和抽奖类物品转化为普通物品，并添加到背包
function ModuleItem:addWrapItem( itemId, count, sources )
	local items = self:unpackItem( itemId, count, false )
	for _, item in ipairs( items ) do
		self:addItem( item.itemId, item.count, sources )
	end

	return items
end


-- 消耗物品(非wrap类型)，只有物品数量都是足够的情况下才会消耗物品
function ModuleItem:consumeItem( costItemId, costItemCount, pushGiftIfLack )
	if costItemId and costItemCount >= 0 then		
		if costItemId == 0 or costItemCount == 0 then return true end
		
		if self:subItem(costItemId, costItemCount) then
			return true
		else
			if pushGiftIfLack then
				ModulePay:openCurrencyPushGift(costItemId, costItemCount)
			end

			return false
		end
	else
		return false
	end
end








return ModuleItem