--[[
	养成模块
]]
local ModuleUp = class( "ModuleUp", MsgHandler )






local lock_id


-- 切换scene时需要调用
function ModuleUp:Awake()
	-- 存档的数据
	self.rtData = ModuleRecord:getData( "UP" ) or {
		-- [ upId ] = { curExp = exp, level = level },
	}


	local allUpDb = MgrCfg.allDatas.up_db
	--allUpDb = {}
	self.allUpDb = allUpDb
end


function ModuleUp:Start()
	-- 激活所有养成
	local allUpDb = self.allUpDb

	local unlockItems = {
		-- itemId = {{upId = upId1, itemCount = xxx}, ...}
	}
	for upId, _ in pairs(allUpDb) do
		self:active(upId)

		if self:query(upId) < 1 then
			if not self:_tryUnlockEmptyUp(upId) then
				local itemId, itemCount = self:_getUnlockReqItem(upId)
				if not unlockItems[itemId] then unlockItems[itemId] = {} end

				table.insert(unlockItems[itemId], {upId = upId, itemCount = itemCount})
			end
		end
	end

	-- 自动升级监听列表
	self.unlockItems = unlockItems

	self:setMsgListeners({
		{"MSG_ITEM_CHANGE", handler(self, self.onItenChange)},
	})
	self:startProcMsg()
end


function ModuleUp:onItenChange( e )
	local itemData = e:getUserData()
	if itemData.curCount <= itemData.lastCount then
		return
	end

	if ModuleItem:getItemDb(itemData.itemId).type == ITEM_TYPE_CURRENCY then
		return
	end

	local ups = self.unlockItems[itemData.itemId]
	if ups then
		for idx, data in ipairs(ups) do
			if data.itemCount <= itemData.curCount then
				table.remove(ups, idx)
				self:unlock(data.upId, function (suc)
					if suc then
						ModuleRole:tryNotifyUnlock(data.upId)
					end
				end)
				break
			end
		end
	end
end


-- 获取当前等级的养成数据
function ModuleUp:getUpDbByLevel( upId, level )
	if not upId or upId == "" then printError( "ModuleUp.getUpDbByLevel: upId is nil." ) return nil end

	level = level or self:query(upId)
	if not level then printError("ModuleUp.getUpDbByLevel: level is nil.") return nil end

	local db = self:getUpDb( upId )
	local curUpDb = db[ level ]
	return curUpDb
end


function ModuleUp:getUpDb( upId )
	return self.allUpDb[ upId ] or printError( "can't find up db by id %s", upId )
end


function ModuleUp:saveData()
	ModuleRecord:setData( "UP", self.rtData )
end


function ModuleUp:getMaxDb( upId )
	local upDb = self:getUpDb( upId )
	return upDb[#upDb]
end


-- 获取养成的最大等级
function ModuleUp:getMaxLv( upId )
	local upDb = self:getUpDb( upId )
	return #upDb
end


function ModuleUp:_getCurUpData( upId )
	local rtData = self.rtData[ upId ]

	return rtData
end


-- 检查需求物品信息(普通升级)
function ModuleUp:_checkReqItem( upId, level )
	local id, count = self:_getLackItemInfo( upId, level )

	-- 没有缺少的物品则表示满足需求
	return id == nil
end


-- 获取缺少的物品id及数量
function ModuleUp:_getLackItemInfo( upId, level )
	local curLvDb = self:getUpDbByLevel( upId, level )

	if not self:_checkItem( curLvDb.reqId, curLvDb.reqCnt ) then
		return curLvDb.reqId, curLvDb.reqCnt
	end

	return nil, nil
end


function ModuleUp:_checkItem( itemId, itemCount )
	return itemCount <= ModuleItem:getItemCount( itemId )
end


-- 生产(目前的逻辑，不能支持计费点)
function ModuleUp:_produce( upId )
	local rtData = self.rtData[ upId ]
	local upDb = self:getUpDbByLevel( upId )

	-- 最大等级检查
	local curLv = rtData.level
	local maxLv = self:getMaxLv( upId )
	if curLv >= maxLv then
		return false
	end

	-- 检查物品是否足够
	if not self:_checkReqItem( upId, curLv ) then
		print( "ModuleUp._produce _checkReqItem not match!" )
		return false
	end
	
	local itemId = upDb.reqId
	local itemCount = upDb.reqCnt
	
	-- 扣除物品
	if ModuleItem:consumeItem( itemId, itemCount, true ) then
		-- 升级
		curLv = curLv + 1
		rtData.level = curLv
		self:saveData()
		ModuleGoal:commit( "ACTION_LV_UP", tonumber(upId) )
		ModuleGoal:commit( "ACTION_UP_LEVEL", tonumber(upId), curLv, true )
		return true
	end

	if false then
		-- mgrSet:playSoundWithSoundFile( 'snd/sfx/Lvup')
	end

	return false
end


function ModuleUp:getReqItem( upId )
	local curLvDb = self:getUpDbByLevel( upId, level )
	return curLvDb.reqId, curLvDb.reqCnt
end


-- 获取当前快速升级所需物品列表
function ModuleUp:getQuickReqItem( upId )
	local payId
	local reqQuickId, reqQuickCnt

	local curLvDb = self:getUpDbByLevel( upId )
	
	payId = curLvDb.payId
	if payId ~= 0 then
		reqQuickId, reqQuickCnt = ModulePay:getPayCostItem( payId )
	else
		reqQuickId	= curLvDb.reqQuickId
		reqQuickCnt = curLvDb.reqQuickCnt
	end

	-- 返回消耗的物品和即将升级的等级
	return reqQuickId, reqQuickCnt, payId
end


-- 快速升级
function ModuleUp:_produceQuick( upId, onSuccess )
	local rtData = self.rtData[ upId ]

	-- 最大等级检查
	local curLv = rtData.level
	local maxLv = self:getMaxLv( upId )
	if curLv >= maxLv then
		printInfo( " ModuleUp._produceQuick level full!" )
		return
	end

	local reqId, reqCnt, payId = self:getQuickReqItem( upId )
	local _doLvup = function( suc )
		if suc then
			rtData.level = maxLv
			self:saveData()
			-- mgrSet:playSoundWithSoundFile( 'snd/sfx/Lvup' )
			onSuccess()
			ModuleGoal:commit( "ACTION_UP_LEVEL", tonumber(upId), maxLv, true )
		end
	end

	-- 调用支付
	if payId ~= 0 then
			-- 扣除物品回调
		ModuleAlert:alertGift( payId, _doLvup )
	else
		-- 扣除物品
		_doLvup( ModuleItem:consumeItem( reqId, reqCnt, true ) )
	end
end



---------------------------- 功能接口 --------------------------------

-- 自动激活没有需求的养成
function ModuleUp:_tryUnlockEmptyUp( upId )
	local reqId, reqCnt, payId = self:_getUnlockReqItem( upId )

	if reqCnt == 0 then
		self:unlock(upId)
		return true
	end

	return false
end


-- 激活
function ModuleUp:active( upId )
	if not upId or upId == "" then return false end

	local rtData = self.rtData[ upId ]
	if rtData then
		return false
	end

	local rtData = {
		id = upId,
		level = 0,
	}

	self.rtData[upId] = rtData

	return true
end


-- 获取养成解锁所需物品
function ModuleUp:_getUnlockReqItem( UpId, level )
	local curUpDb = self:getUpDbByLevel( UpId, level )	
	return curUpDb.reqId, curUpDb.reqCnt, curUpDb.payId
end


-- 解锁价格
function ModuleUp:getUnlockPrice(upId, level)
	local curUpDb = self:getUpDbByLevel( upId, level )
	
	local payId = curUpDb.payId
	if payId ~= 0 then
		local itemId, itemCount = ModulePay:getPayCostItem( payId )
		return itemId, itemCount, payId
	else
		return curUpDb.reqId, curUpDb.reqCnt, payId
	end
end


-- 请求解锁
function ModuleUp:unlock(upId, onResult, COP)
	if not upId or upId == "" then printError( "ModuleUp.unlock upId is nil." ) return false end

	if lock_id == upId then
		return
	end

	lock_id = upId

	-- 激活当前养成
	local rtData = self:_getCurUpData( upId )

	-- 等级检查
	local curLv = rtData.level
	if curLv ~= 0 then
		printWarn( "ModuleUp.unlock currentUpId is unlocked! upId:%s", upId )
		return
	end

	local reqId, reqCnt, payId = self:_getUnlockReqItem( upId, curLv )

	local _doLvup = function()
		-- 扣除物品
		local result = ModuleItem:consumeItem( reqId, reqCnt, false )
		if result then
			rtData.level = 1
			ModuleGoal:commit( "ACTION_UP_LEVEL", tonumber(upId), 1, true )
			self:saveData()
		end

		-- 这个地方是因为：获得物品后会自动解锁，导致扣除物品后正常的解锁反而失败
		if rtData.level > 0 then
			result = true
		end

		if onResult then
			onResult(result)
		end
		lock_id = nil
	end
	
	-- 检查物品是否满足
	if not self:_checkItem( reqId, reqCnt ) then
		-- 如果有pay则优先pay
		if ModulePay:getActive(payId) then
			-- 这里payId不能由COP控制
			if COP then
				COP.payId = payId
			end

			ModuleAlert:alertGift(payId, _doLvup, nil, nil, COP)
		else
			ModulePay:openCurrencyPushGift( reqId, reqCnt, _doLvup )
			local itemDb = ModuleItem:getItemDb(reqId)
			ModuleAlert:alertText( string.format( "%s不足", itemDb.name ) )
		end
	else
		_doLvup()
	end
	
end


-- 升级
function ModuleUp:lvup( upId )
	if not upId or upId == "" then printError( "ModuleUp.lvup upId is nil." ) return false end

	local rtData = self:_getCurUpData( upId )
	if not rtData then printError( string.format( "ModuleUp.lvup rtData is nil. upId:%s", upId ) ) return false end

	local reqId, reqCnt = self:_getLackItemInfo( upId, rtData.level )
	if reqId then
		-- 物品不足，尝试推送(如果是货币的话)
		local db = ModuleItem:getItemDb( reqId )
		ModuleAlert:alertText( string.format( "%s不足", tostring( db.name ) ) )
		ModulePay:openCurrencyPushGift(reqId, reqCnt)
		return
	end

	return self:_produce(upId)
end


-- 快速升级
function ModuleUp:lvupQuick( upId, onSuccess )
	local sucCallback = function()
		if onSuccess then
			onSuccess()
		end
		-- 发送一键满级成功消息
		sendMsg( "MSG_UP_QUICK_LEVEL_FULL", { upId = upId, changedLevel = changedLevel } )
	end

	self:_produceQuick( upId, sucCallback )
end


-- 查询当前养成的等级和经验
function ModuleUp:query( upId )
	if not upId or upId == "" then printError( "ModuleUp.query upId is nil." ) return nil end

	local rtData = self:_getCurUpData( upId )
	if not rtData then printError( string.format( "ModuleUp.query rtData is nil. upId:%s", upId ) ) return nil end

	return rtData.level
end


-- 判断是否可升级
function ModuleUp:checkUpCanLvup( upId )
	local level = self:query( upId )
	local maxLv = self:getMaxLv( upId )
	if level >= maxLv then return false end

	return self:_checkReqItem( upId, level )
end










return ModuleUp

