--[[
]]


local ModulePay = class( "ModulePay" )






function ModulePay:Awake()
	-- 当前正在支付的商品id，同一时间只允许一个购买行为
	self._curPayPoint = nil

	self:convertPayDb()

	if ModuleSwitch.dailyActive then
		ModuleRecord:setData( "PAY_LIMIT", 0 )
	end
end


function ModulePay:Start()
end


function ModulePay:hotFixPayDb( payCodes )
	if not payCodes then return end
	
	local allPayDb = self.allPayDb
	local db
	for payId, data in pairs( payCodes ) do
		db = allPayDb[tonumber(payId)]
		if db then
			db.payPoint = tonumber( payId )
			-- 替换为人民币
			db.costItem = { ID_ITEM_RMB, (tonumber( data.price ) or 0) / 100 }
		end
	end
end


function ModulePay:convertPayDb()
	local allPayDb = MgrCfg.allDatas.pay_db
	self.allPayDb = allPayDb

	local function sortPay( data1, data2 )
		return data1.sort > data2.sort
	end

	-- 商品分组
	local shopData = {}
	for id, data in pairs( allPayDb ) do
		if data.gid > 0 then
			if not shopData[data.gid] then
				shopData[data.gid] = {}
			end
			
			table.insert( shopData[data.gid], data )
		end
	end

	for k, datas in pairs( shopData ) do
		table.sort( datas, sortPay )
	end

	self.shopGroupData = shopData
end


-- 获取当前支付限额
function ModulePay:getCurPayLimit()
	return ModuleRecord:getData( "PAY_LIMIT", 0 )
end


function ModulePay:addCurPayLimit( value )
	ModuleRecord:setData( "PAY_LIMIT", self:getCurPayLimit() + value )
end


function ModulePay:getPayDb( id )
	return self.allPayDb[ id ] or printError( "can't find pay db by id %s", id )
end


function ModulePay:getPaysByGid( gid )
	local allPays = {}
	for i, data in ipairs(self.shopGroupData[gid]) do
		if ModuleSwitch:check(data.switchId) then
			table.insert(allPays, data)
		end
	end

	return allPays
end


function ModulePay:getActive( payId )
	if payId == 0 then return false end
	local payDb = self:getPayDb( payId )
	return ModuleSwitch:check( payDb.switchId )
end


--[[	-- 不再用档位推送
-- 根据相差数量弹相应档位的礼包
--@return payId, 商店gid
local function _getPayStage( itemId, count )
	local stage, gid
	if itemId == ID_ITEM_MONEE_DIAMOND then
		stage = PUSH_PAY_DIAMOND
		-- gid = GID_SHOP_DIAMOND
		return nil, nil
	elseif itemId == ID_ITEM_MONEY_COINS then
		stage = PUSH_PAY_COINS
		-- gid = GID_SHOP_COIN
		return nil, nil
	elseif itemId == ID_ITEM_VITALITY then
		return nil, nil
	else
		return nil, nil
	end

	local payId
	for i = #stage, 1, -1 do
		payId = stage[i][2]
		if count > stage[i][1] then
			break
		end
	end

	return payId, gid
end


function ModulePay:openCurrencyPushGift( itemId, count, callback )
	callback = callback or function () end

	local itemCount = ModuleItem:getItemCount( itemId )
	local needMore = count - itemCount

	local payId, gid = _getPayStage( itemId, needMore )
	if payId then
		ModuleAlert:alertGift( payId, callback, false, gid )
		return
	elseif gid then
		callback( false )
		MgrPanel:openPanelWithSingleton( "PanelShop", gid )
		return
	else
		local itemDb = ModuleItem:getItemDb( itemId )
		local payId = itemDb.payId
		
		if payId and payId > 0 then
		-- 	ModuleAlert:alertGift( payId, callback )
			self:quickBuyGoods( itemId, callback, needMore )
			return
		end
	end

	callback( false )
end
]]


function ModulePay:openCurrencyPushGift( itemId, count, callback )
	callback = callback or function () end

	local itemCount = ModuleItem:getItemCount( itemId )
	local needMore = count - itemCount

	if itemId == ID_ITEM_MONEE_DIAMOND then
		ModuleAlert:alertPushGift(ModuleSDK.COP.PUSH_DIAMOND, callback)
		return
	elseif itemId == ID_ITEM_MONEY_COINS then
		ModuleAlert:alertPushGift(ModuleSDK.COP.PUSH_COINS, callback)
		return
	else
		local itemDb = ModuleItem:getItemDb( itemId )
		local payId = itemDb.payId
		
		if payId and payId > 0 then
		-- 	ModuleAlert:alertGift( payId, callback )
			self:quickBuyGoods( itemId, callback, needMore )
			return
		end
	end

	callback( false )
end


--@param quiet 不用弹窗提示
--@param confirmInfo RMB时二次确认信息
function ModulePay:buyGoods( payId, callback, quiet, count, confirmInfo, callbackWhenPushCurrency )
	callback = callback or function() end
	count = count or 1

	local payDb = self:getPayDb( payId )
	if not payDb then
		callback(false)
		return
	end

	-- if reason then
	-- 	reason = string.format( "[%s]购买[%s]", reason, payDb.name )
	-- else
	-- 	reason = string.format( "未知购买%s: %s", payDb.name, debug.traceback() )
	-- end

	if ModuleSDK:isPaying() then
		ModuleAlert:alertText(string.format("正在购买[%s]，请稍后再购买。", payDb.name))
		callback(false)
		return
	end

	if not self:getActive(payId) then
		ModuleAlert:alertText(string.format( "%s礼包已售完", payDb.name ))
		callback(false)
		return
	end

	local payCallback = function ( suc, timeout )
		if timeout then
			ModuleAlert:alertText( string.format( "购买%s超时", payDb.name ) )
		else
			if suc then
				self:_onGetGoods( payId, quiet, count, callback )
				sendMsg( "MSG_ON_PAY_SUCCESS", payId )
				AudioPlayer.instance:playSound("Game-Buy")
			else
				ModuleAlert:alertText( string.format( "购买%s失败", payDb.name ) )
				callback(false)
			end
		end
	end

	-- 如果是计费点则转到计费点
	local payPoint = payDb.payPoint
	if payPoint and payPoint ~= 0 then
		self._curPayPoint = payPoint

		if count ~= 1 then
			printError( "can't buy mult goods with SDK." )
		end

		self:_openSdk( payPoint, payCallback )
		-- if mgrSDK.COP.RMB_CONSUME_CONFIRM and confirmInfo then
		-- 	______mgrTip:openRMBConfirm( confirmInfo.title, confirmInfo.text, payDb.costItem[2],
		-- 	{
		-- 		function ()
		-- 			self:_openSdk( payPoint, payCallback )
		-- 		end,
		-- 		function ()
		-- 			payCallback( false )
		-- 		end
		-- 	}
		-- 	)
		-- else
		-- 	-- 调用SDK
		-- 	self:_openSdk( payPoint, payCallback )
		-- end
	else
		local itemId = payDb.costItem[1]
		local costCount  = payDb.costItem[2]

		local result = ModuleItem:consumeItem( itemId, costCount * count, not callbackWhenPushCurrency )
		if result then
			payCallback( true )
		else
			local itemDb = ModuleItem:getItemDb( itemId )
			if callbackWhenPushCurrency then
				if itemDb.type == ITEM_TYPE_CURRENCY then
					-- 货币不足则根据不同档位弹相应礼包
					self:openCurrencyPushGift( itemId, costCount, payCallback )
				else
					payCallback( false )
				end
			else
				payCallback( false )
				ModuleAlert:alertText( string.format( "%s不足", itemDb.name ) )
			end

		end
	end
end


function ModulePay:_openSdk( payPoint, callback )
	local curLimit = self:getCurPayLimit()
	if curLimit >= ModuleSDK.COP.PAY_DAILY_LIMIT then
		ModuleAlert:alertText( "已达到每日消费限额。" )
		callback( false )
		-- printDebug( "pay limit:%s cur:%s", ModuleSDK.COP.PAY_DAILY_LIMIT, curLimit )
	else
		ModuleSDK:openPay( payPoint, function ( suc, msg, timeout )
			printf( "openSdk suc:%s msg:%s", tostring( suc ), tostring( msg ) )
			if suc then
				local payDb = self:getPayDb( self._curPayPoint )
				ModuleItem:addItem(payDb.costItem[1], payDb.costItem[2])
			end

			callback( suc, timeout )
		end )
	end
end


function ModulePay:_onGetGoods( payId, quiet, count, onSuc )
	local payDb = self:getPayDb( payId )

	ModuleSwitch:active( payDb.switchId )

	
	-- 提示获得物品
	if #payDb.item == 2 then
		local sources = payDb.costItem[1] == ITEMID_RMB and ModuleSDK.SOURCES_TYPE_DIR or ModuleSDK.SOURCES_TYPE_EXCHANGE
		local items = ModuleItem:addWrapItem(payDb.item[1], payDb.item[2] * count, sources )
		
		if quiet then
			onSuc(true)
		else
			ModuleAlert:alertItems(items, function ()
				onSuc(true)
			end)
		end
	else
		onSuc(true)
	end
		

	if payDb.costItem[1] == ID_ITEM_RMB then
		-- mgrSDK:dataeyePaySuccess( payDb.name, payDb.costItem[2] )
		self:addCurPayLimit( payDb.costItem[2] )
	end
	-- PrintTable( items, "pay get items" )
end


function ModulePay:quickBuyGoods( itemId, callback, count, callbackWhenPushCurrency )
	count = count or 1
	local itemDb = ModuleItem:getItemDb( itemId )
	local payId = itemDb.payId
	local payDb = self:getPayDb( payId )

	if not payDb then
		printError( "can't quick buy goods %s, invalid payId %s", itemId, payId )
		callback( false )
		return
	end
	
	local costItemId = payDb.costItem[1]
	local costCount = payDb.costItem[2]
	
	local costItemTemp = ModuleItem:getItemDb( costItemId )
	
	local _confirm = function ()
		self:buyGoods( payId, callback, false, count, nil, callbackWhenPushCurrency )
	end
	
	local _cannel = function()
		callback( false )
	end

	ModuleAlert:alertDialog( string.format( "是否花费%d%s购买%s个%s。", costCount * count, costItemTemp.name, count, itemDb.name), _confirm, _cannel, "购买", "取消" )
end


function ModulePay:quickPay( payId, callback, count, callbackWhenPushCurrency )
	count = count or 1
	local payDb = self:getPayDb( payId )

	if not payDb then
		printError( "can't quick pay, invalid payId %s", payId )
		callback( false )
		return
	end
	
	local costItemId = payDb.costItem[1]
	local costCount = payDb.costItem[2]
	
	local costItemTemp = ModuleItem:getItemDb( costItemId )
	
	local _confirm = function ()
		self:buyGoods( payId, callback, false, count, nil, callbackWhenPushCurrency )
	end
	
	local _cannel = function()
		callback( false )
	end

	ModuleAlert:alertDialog( string.format( "是否花费%d%s购买%s个%s。", costCount * count, costItemTemp.name, count, payDb.name), _confirm, _cannel, "购买", "取消" )
end


function ModulePay:getQuickBuyCost( itemId )
	local db = ModuleItem:getItemDb( itemId )
	local payId = db.payId
	local payDb = self:getPayDb( payId )
	if not payDb then
		printError( "can't get quick buy goods price %s, invalid payId %s", itemId, payId )
		return
	end

	return 	payDb.costItem[1], payDb.costItem[2]
end


function ModulePay:getPayCostItem( payId )
	local payDb = self:getPayDb( payId )
	if not payDb then return end

	local itemId = payDb.costItem[1]
	local itemCount = payDb.costItem[2]
	return itemId, itemCount
end



















return ModulePay


