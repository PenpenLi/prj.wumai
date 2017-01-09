--[[
	File Desc:
	抽奖，每次抽奖只会产生一个物品，若想多物品需将物品包装城掉落
	如果是通过unpackItem来预览，则通常 lottery 每次都会有不同的结果
]]



local ModuleLottery = class( "ModuleLottery" )



function ModuleLottery:Awake()
	self.lotteryData = ModuleRecord:getData( "LOTTERY" ) or {
		-- id1 = index1,
		-- id2 = index2,
	}

	self.allLotteryDb = MgrCfg.allDatas.lottery_db or {}
end


function ModuleLottery:Start()
	if ModuleSwitch.dailyActive then
		for _, id in ipairs(UI_GIFT_LOTTERY) do
			self:reset(id)
		end

		ModuleRecord:setData( "GIFT_TIME", nil )
	end
end


function ModuleLottery:saveData()
	ModuleRecord:setData( "LOTTERY", self.lotteryData )
end


function ModuleLottery:getLotteryDb( id )
	return self.allLotteryDb[ id ] or printError( "can't find lottery by id %s", id )
end


function ModuleLottery:getActive( id )
	local db = self:getLotteryDb( id )
	if not db then return false end

	return ModuleSwitch:check( db.switchId )
end


function ModuleLottery:getCurIndex( id )
	local index = self.lotteryData[ id ] or 0
	return index, #self:getLotteryDb(id).items
end


function ModuleLottery:reset(id)
	if self.lotteryData[id] then
		self.lotteryData[id] = nil
	end
end


-- 不会自动添加物品(抽奖只会返回抽奖内的一个物品，不会unpackItem)
-- @return { itemId = xx, count = yy }
function ModuleLottery:makeLottery( id, forPreview )
	-- print( "---> makeLottery", id )
	if not id or id == 0 then return {} end

	local db = self:getLotteryDb( id )

	-- 开关判断
	if not ModuleSwitch:check( db.switchId ) then
		-- printf( "---> lottery not active %s", id )
		return {}
	else
		if not forPreview then
			ModuleSwitch:active( db.switchId )
		end
	end

	local index = self.lotteryData[ id ]
	if not index then
		index = 1
	else
		index = index + 1
	end

	if index > #db.items then
		if db.reset then
			index = 1
		else
			index = #db.items
		end
	end

	if not forPreview and self.lotteryData[ id ] ~= index then
		self.lotteryData[ id ] = index
		self:saveData()
	end

	local item = db.items[ index ]

	return { itemId = item[1], count = item[2] or 0 }
end


function ModuleLottery:makeGiftLottery( id, forPreview )
	local payId
	local giftItem

	if not forPreview then
		self:makeLottery( id )
	end

	giftItem = self:makeLottery( id, true )
	payId = giftItem.itemId
	
	local count = 0
	repeat
		count = count + 1
		if not payId then return nil end
		-- 检查gift开关，若gift关闭，则尝试再次抽奖
		if ModulePay:getActive( payId ) then
			return payId
		else
			self:makeLottery( id )
			giftItem = self:makeLottery( id, true )
			payId = giftItem.itemId
		end

		if count > 3 then
			break
		end
	until false
end








return ModuleLottery