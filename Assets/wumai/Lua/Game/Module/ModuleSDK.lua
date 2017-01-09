--[[
	File Desc:ModuleSDK
]]

local cjson = require( "cjson" )

local ModuleSDK = class( "ModuleSDK" )



local D_LEVEL_START = "/d/gameLevelStart"
local D_LEVEL_COMPLETE = "/d/gameLevelComplete"
local D_PAY_SUC = "/d/userPaySuccess"
local D_COIN_ADD = "/d/gameCoinAdd"
local D_COIN_LOST = "/d/gameCoinLost"
local D_COMMON_EVENT = "/d/commonEvent"
local C_EXIT_GAME = "/c/exitGame"
local D_MORE_GAME = "/d/openMoreGame"

-- local D_ITEM_BUY = "/d/itemBuy"
-- local D_ITEM_COST = "/d/itemConsume"


local C_SETVERSION = "setVersion"
local C_OPEN_PAY = "/c/openPay"
local C_CALL_PHONE = "/c/callPhone"
local C_USE_CDKEY = "/cdk/useCdkey"


-- 创酷统计
local CK_GAME_LEVEL = "/ck/gameLevel"
local CK_GAME_SHOP = "/ck/gameShop"
local CK_GAME_MAIN = "/ck/gameMain"
local CK_GAME_SETTLEMENT = "/ck/gameSettlement"
local CK_GAME_ITEM = "/ck/gameItem"
local CK_USE_ITEM = "/ck/useItem"
local CK_POPUP_SALE = "/ck/popupSale"
local CK_CURRENCY_CHANGE = "/ck/currencyChange"


local RESULT = {
	["/c/channelInfoResult"] = "onChannelInfoResult",
	["/c/payResult"] = "onPayResult",
	["/c/exitGame"] = "onExitGame",
}



local PLATFORM_EDITOR = Tools.isEditorPlatform

local UID = Tools.getUID()

SDK_VERSION = 2


-- cop配置
ModuleSDK.COP = {
	-- 购买限额
	PAY_DAILY_LIMIT = 2000,
	-- 主界面变强按钮引导
	MAIN_MENU_FINGER = true,

	CLOSE_CONFIRM = false,
}




function ModuleSDK:Awake()
	LuaBridge.setListener( "/c/channelInfoResult", handler( self, self.onChannelInfoResult ) )
	LuaBridge.setListener( "/c/payResult", handler( self, self.onPayResult ) )
	LuaBridge.setListener( "/c/exitGame", handler( self, self.onExitGame ) )
	LuaBridge.setListener( "/cdk/useCdkey", handler( self, self.onUseCDKResult ) )
	LuaBridge.setListener( "/c/pushRewards", handler( self, self.onPushRewards ) )

	self.leftPayTime = -1
end


function ModuleSDK:Start()
	if PLATFORM_EDITOR then
		-- 测试数据
		local channelInfo = cjson.decode( CHANNEL_INFO )
		self:onChannelInfoResult(channelInfo)
	else
		-- mgrRes:getPayInfo( function ( payInfo )
		-- 	mgrCfg:hotFixPayDb( payInfo )
		-- end )
		LuaBridge.sendToSdk( C_SETVERSION, SDK_VERSION )
	end

	-- SDK超时处理（创酷不用超时处理）
	-- Timer.New( handler( self, self.onCheckTimeOut ), 1, -1 ):Start()
end






-- 渠道SDK相关 ---------------------------------------------------
-- 初次回调
function ModuleSDK:onChannelInfoResult(data)
	ModulePay:hotFixPayDb(data.payCode)

	self.isThirdExit = data.isThirdExit
	self.isMoreGame = data.isMoreGame
	self.isAbout = data.isAbout

	-- 创酷的url
	self.ckurl = data.ckurl
	self.imsi = data.imsi

	self:hotFixCop(data.configInfo)

	self.chn = data.chn
	self.openAllLevel = true
	print("---> chn:", self.chn)

	-- mgrRes:getLocalConfig( function ( localConfig )
	-- 	-- PrintTable( localConfig, "localConfig" )
	-- 	xpcall(
	-- 		function()
	-- 			self.openAllLevel = localConfig.OPEN_ALL_LEVEL
	-- 			local chnConfig = localConfig[self.chn]
	-- 			local exclude_pay = chnConfig.EXCLUDE_PAYCODES
	-- 			if exclude_pay and type(exclude_pay) == "table" then
	-- 				mgrCfg:revertHotFixPayDb( exclude_pay )
	-- 			end
	-- 		end,
	-- 		function(err)
	-- 		end
	-- 		)
	-- end )
end


function ModuleSDK:hotFixCop( data )
	data = data or {}
	
	local empty = true
	for k,v in pairs( data ) do
		empty = false
		break
	end

	local COP = self.COP
	-- 更新COP
	if not empty then
		COP.PAY_DAILY_LIMIT = tonumber( data.PAY_DAILY_LIMIT ) or 2000

		local decodeStr = function (str)
			str = str or ""
			local data = string.split(str, ";")
			-- 是否开启该逻辑、小手、区域点击、推送的礼包、领取字眼、具体字眼、关闭时间
			return {
				enable = tonumber(data[1]) == 1,
				finger = tonumber(data[2]) == 1,
				click = tonumber(data[3]) or 0,
				payId = tonumber(data[4]) or 0,
				free = tonumber(data[5]) == 1,
				freeType = tonumber(data[6]) or 0,
				close = tonumber(data[7]) or 0
			}
		end

		COP.PUSH_UNLOCK = decodeStr(data.PUSH_UNLOCK)
		COP.MAIN_MENU_FINGER = decodeStr(data.MAIN_MENU_FINGER).enable
		COP.PUSH_3STAR = decodeStr(data.PUSH_3STAR)
		COP.PUSH_LEVEL = decodeStr(data.PUSH_LEVEL)
		COP.PUSH_STRONG_ROLE = decodeStr(data.PUSH_STRONG_ROLE)
		COP.PUSH_STRONG_PET = decodeStr(data.PUSH_STRONG_PET)
		COP.PUSH_MAIN = decodeStr(data.PUSH_MAIN)
		COP.PUSH_DIAMOND = decodeStr(data.PUSH_DIAMOND)
		COP.PUSH_COINS = decodeStr(data.PUSH_COINS)
		COP.PUSH_LOSE = decodeStr(data.PUSH_LOSE)
		COP.SUPER_FINGER = decodeStr(data.SUPER_FINGER).enable
		COP.CLOSE_CONFIRM = decodeStr(data.CLOSE_CONFIRM).enable


		COP.ACT_TIME = string.split(data.ACT_TIME or "", ";")
		COP.ACT_TITLE = data.ACT_TITLE or ""
		local actDescs = string.split(data.ACT_DESC or "", ";")
		local actStr = ""
		for i,v in ipairs(actDescs) do
			actStr = actStr .. tostring(v)
			if i ~= #actDescs then
				actStr = actStr .. "\n"
			end
		end
		COP.ACT_DESC = actStr

		-- mgrCfg:revertHotFixPayDb( COP.EXCLUDE_PAYCODES )
		PrintTable( COP, "cop" )
	else
		printWarn( "cop is empty!" )
	end


	self.ACT_ACTIVE = self:checkActActive()
end










function ModuleSDK:exitGame()
	if self.isThirdExit then
		self:thirdExitGame()
	else
		self:_exitGame()
	end
end


local EXIT_OPEN = false
function ModuleSDK:_exitGame()
	if EXIT_OPEN then return end

	EXIT_OPEN = true
	ModuleAlert:alertDialog( "要离开斗龙宝宝了吗？", function ()
			Application.Quit()
		end, function ()
			EXIT_OPEN = false
		end, "离开游戏", "继续战斗" )
end


function ModuleSDK:thirdExitGame()
    LuaBridge.sendToSdk( C_EXIT_GAME, {} )
end


function ModuleSDK:openMoreGame()
	LuaBridge.sendToSdk( D_MORE_GAME, {} )
end


function ModuleSDK:callPhone( num )
	LuaBridge.sendToSdk( C_CALL_PHONE, { phoneNum = tostring( num ) } )
end


-- 请求支付
function ModuleSDK:openPay( payId, callback, reason )
	local payInfo = {
        payId   = payId
    }

    local data = {
    	reason = reason
	}

	self.callback = callback

	-- 创酷不用超时处理
	-- self.leftPayTime = 15
    
	LuaBridge.sendToSdk( C_OPEN_PAY, { payInfo = payInfo, userInfo = { roleId = tostring( UID ), data = data } } )

	if PLATFORM_EDITOR then
		self:onPayResult( { code = 1 } )
	end
end


-- 支付结果返回
function ModuleSDK:onPayResult( data )
	-- PrintTable( data, "onPayResult" )
	if self.callback then
		-- code: 1 成功，0 失败，2 超时
		self.callback( data.code == 1, data.msg, data.code == 2 )
	end

	self.leftPayTime = -1
end


function ModuleSDK:isPaying()
	return self.leftPayTime ~= -1
end


function ModuleSDK:onCheckTimeOut()
	local leftPayTime = self.leftPayTime
	if leftPayTime < 0 then
		return
	end

	self.leftPayTime = leftPayTime - 1

	if leftPayTime == 0 then
		self:onPayResult( { code = 2, msg = "支付超时" } )
	end
end


function ModuleSDK:onExitGame( data )
	local code = data.code or 1
	if code == 0 then
		-- 取消退出
	elseif code == 1 then
		-- 退出成功
	elseif code == 2 then
		-- 弹默游戏认退出界面
		self:_exitGame()
	end
end


--[[
local CK_APP_ID = "1042"
local CK_KEY = "b4c862c6d7aadb6da3fcc80187603651"
function ModuleSDK:requestQQActivity( qq, callback )
	if PLATFORM_EDITOR then
		callback( true )
		return
	end

	if self.ckurl and self.ckurl ~= "" and qq then
		local md5Value = md5( string.format( "%s%s", CK_KEY, qq ) )
		local url = self.ckurl .. "/ck/app/qqactivity?ckAppId=%s&qq=%s&sign=%s&imsi=%s"
		url = string.format( url, CK_APP_ID, qq, md5Value, self.imsi )

		printf( "request qq activity : %s", url )

		FileLoader.load( url, function ( www )
			local result = www.text
			printf( "qq activity suc result: %s", result )
			if result == "SUCCESS" then
				callback( true )
			else
				callback( result )
			end
		end, function ( www )
			printError( "qq activity fail, msg:%s", www.error )
			callback( "连接失败，请检查网络!" )
		end, 5, function ()
			printError( "qq activity time out." )
			callback( "连接超时，请检查网络!" )
		end )
	else
		printError( "invalid param url:%s qq:%s", self.ckurl, qq )
		callback( "服务器地址异常!" )
	end
end
]]












-- dataeye 统计相关 ---------------------------------------------------
-- 关卡开始统计
function ModuleSDK:dataeyeStartStage( levelUid )
    local db = ModuleLevel:getLevelDb( levelUid )
    if db then
	    -- LuaBridge.sendToSdk( D_LEVEL_START, { levelName = db.name } )
	    LuaBridge.sendToSdk( CK_GAME_LEVEL, { id = levelUid, type = 0 } )
    end
end


function ModuleSDK:dataeyeEndStage( levelUid, bPass )
    local db = ModuleLevel:getLevelDb( levelUid )
    if db then
		-- LuaBridge.sendToSdk( D_LEVEL_COMPLETE, { levelName = db.name, isPass = bPass, reason = "" } )
		LuaBridge.sendToSdk( CK_GAME_LEVEL, { id = levelUid, type = 1, isSuccess = bPass } )
    end
end


--  进入商城
function ModuleSDK:ckEnterShop()
	LuaBridge.sendToSdk( CK_GAME_SHOP, { type = 0 } )
end

-- 退出商城
function ModuleSDK:ckLeaveShop()
	LuaBridge.sendToSdk( CK_GAME_SHOP, { type = 1 } )
end

-- 进入主界面
function ModuleSDK:ckEnterMain()
	LuaBridge.sendToSdk(CK_GAME_MAIN, {type = 0})
end

-- 退出主界面
function ModuleSDK:ckLeaveMain()
	LuaBridge.sendToSdk(CK_GAME_MAIN, {type = 1})
end

-- 进入结算
function ModuleSDK:ckEnterSettlement()
	LuaBridge.sendToSdk(CK_GAME_SETTLEMENT, {type = 0})
end

-- 退出结算
function ModuleSDK:ckLeaveSettlement()
	LuaBridge.sendToSdk(CK_GAME_SETTLEMENT, {type = 1})
end


-- RMB获取
ModuleSDK.SOURCES_TYPE_DIR = 1
-- 兑换获取
ModuleSDK.SOURCES_TYPE_EXCHANGE = 2

-- 道具获取
function ModuleSDK:ckGetItem(itemId, sources)
	LuaBridge.sendToSdk(CK_GAME_ITEM, {id = itemId, type = sources})
end

-- 道具使用
function ModuleSDK:ckUseItem(itemId, remain)
	ModuleItem:getItemCount(itemId)
	LuaBridge.sendToSdk(CK_USE_ITEM, {id = itemId, remain = remain})
end

-- 弹出礼包
function ModuleSDK:ckPopupSale(payId)
	LuaBridge.sendToSdk(CK_POPUP_SALE, {payId = payId})
end

-- 货币变化
function ModuleSDK:ckCurrencyChange(coin, diamon, vit)
	LuaBridge.sendToSdk(CK_CURRENCY_CHANGE, {coin = coin, diamon = diamon, vit = vit})
end




















function ModuleSDK:dataeyePaySuccess( goodsName, money )
    LuaBridge.sendToSdk( D_PAY_SUC, { goodsName = tostring( goodsName ), payAmount = tostring( money ) } )
end


-- 玩家获得游戏币
function ModuleSDK:dataeyeAddMoney( reasonStr, moneyName, gainNum, totalNum )
    local moneyName = moneyName or "未知"

    LuaBridge.sendToSdk( D_COIN_ADD,
		{
			reason = tostring(reasonStr),
			coinName = tostring( moneyName ),
			gainNum = tonumber( gainNum ),
			totalNum = tonumber( totalNum )
        }
	)
end


-- 玩家消耗游戏币
function ModuleSDK:dataeyeMinusMoney(reasonStr, moneyName, lostNum, totalNum)
    moneyName = moneyName or string.format( "未知:%s", debug.traceback() )

    LuaBridge.sendToSdk( D_COIN_LOST,
		{
			reason = tostring(reasonStr),
			coinName = tostring( moneyName ),
			lostNum = tonumber(lostNum),
			totalNum = tonumber(totalNum)
		}
	)
end


-- 自定义事件统计
function ModuleSDK:dataeyeCommonEvent( eventName )
	-- printf( "sdk event: %s", eventName )
	LuaBridge.sendToSdk( D_COMMON_EVENT, { eventName = eventName } )
end



function ModuleSDK:sendCDK( cdkStr )
    if string.len(cdkStr) < 1 then
    	ModuleAlert:alertText( "请输入兑换码!" )
        return
    end

    local curData = {
        userId = tostring( UID ),
        cdkStr = cdkStr,
        channelId = 0
    }

    LuaBridge.sendToSdk( C_USE_CDKEY, curData )
end


function ModuleSDK:onUseCDKResult( data )
    if data.code == "1" then
        local items = {}
        ModuleAlert:alertText( "兑换码兑换成功！" )

        for k, v in pairs(data.data) do
            local itemid   = v["goodsid"]
            local count     = v["count"]

			items = ModuleItem:addWrapItem(itemid, count)
			ModuleAlert:alertItems( items )
        end
    elseif data.code == "-1" then
        local str = data.data
        if str == "兑换码不在有效使用期" then
            str = "兑换码兑换失败"
        end

        ModuleAlert:alertText( str )
    end
end


function ModuleSDK:onPushRewards( data )
	local id = data.goodsId or "default"
	local count = data.goodsCount

	if count then
		ModuleAlert:alertText( string.format( "推送数量:%s(仅显示)", count ) )
		-- local items = mgrItem:addUseItem( id, count, "创酷推送" )
	else
		printError( "onPushRewards error. %s %s", id, count )
	end
end



function ModuleSDK:checkActActive()
	local actTime = self.COP.ACT_TIME
	if actTime and #actTime == 6 then
		local curTime = self:getTimes()
		local startTime = self:getTimes( actTime[1], actTime[2], actTime[3] )
		local endTime = self:getTimes( actTime[4], actTime[5], actTime[6] )

		if startTime <= curTime and endTime >= curTime then
			return true
		else
			return false
		end
	else
		return false
	end
end

function ModuleSDK:getTimes( year, month, day, hour, minute, second )
	local date
	if year or month or day or hour or minute or second then
		date = { year = year, month = month, day = day, hour = hour, min = minute, sec = second }
	end

	if date then
		return os.time( date ) or 0
	end
	
	return os.time()
end




return ModuleSDK
 
 
 
