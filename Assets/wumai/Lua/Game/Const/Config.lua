-- 初始化物品
_G.INIT_ITEMS = {
	{ id = 1000, count = 0 },
	{ id = 1001, count = 2000 },
	{ id = 1002, count = 100 },
}


-- 体力自动恢复上限
_G.VIT_MAX_LIMIT = 100

-- 恢复1点体力的时间(秒)
_G.VIT_ADD_DELTA = 12

-- 每日开关(签到或者需要每日重置的统一开关)
_G.ID_DAILY_SWITCH = 105		-- 每日开关

-- 签到抽奖id
_G.ID_SIGN_LOTTERY = 202		-- 每日签到

_G.ID_PAY_SWITCH = 810			-- 活动次数

-- 金币推送
_G.PUSH_PAY_COINS = {
	-- 推送阀值，商品id
	{ 15000, 610 },
	{ 30000, 610 },
}


-- 钻石推送
_G.PUSH_PAY_DIAMOND = {
	{ 10, 622 },
	{ 60, 622 },
	{ 200, 622 },
}


-- 界面礼包推送(抽奖ID)
_G.UI_GIFT_LOTTERY = {101, 102, 103, 104}


-- 礼包倒计时(秒)
_G.GIFT_COUNTDOWN_TIME = {60, 120, 180, 240, 300}


-- 机甲养成比率
_G.ROB_UP_RATE = {
	[1] = {
		atk = 1.2,
		def = 1.2,
		maxHp = 1.2,
		maxMp = 1.2,
		crit = 1.2,
		critDamage = 1.2,
		regenHp = 1.2,
	},
	[2] = {
		atk = 1.5,
		def = 1.5,
		maxHp = 1.5,
		maxMp = 1.2,
		crit = 1.2,
		critDamage = 1.2,
		regenHp = 1.2,
	},
	[3] = {
		atk = 2.2,
		def = 2.2,
		maxHp = 2.2,
		maxMp = 1.2,
		crit = 1.2,
		critDamage = 1.2,
		regenHp = 1.2,
	}
}

_G.QTE_SKILL_LIST = {
	20001,
	20002,
	20003,
	20004,
	20005,
	20006,
	20007,
	20008,
}

--怪物提升比例
_G.MONSTER_UP_RATE = {
	[1] = {atk = 1, hp = 1},
	[2] = {atk = 1.2, hp = 1.2},
	[3] = {atk = 1.3, hp = 1.3},
	[4] = {atk = 1.4, hp = 1.4},
	[5] = {atk = 1.5, hp = 1.5},
	[6] = {atk = 1.6, hp = 1.6},
	[7] = {atk = 1.7, hp = 1.7},
	[8] = {atk = 1.8, hp = 1.8},
	[9] = {atk = 1.9, hp = 1.9},
	[10] = {atk = 2, hp = 2},
	[11] = {atk = 2.1, hp = 2.1},
	[12] = {atk = 2.2, hp = 2.2},
	[13] = {atk = 2.3, hp = 2.3},
	[14] = {atk = 2.4, hp = 2.4},
	[15] = {atk = 2.5, hp = 2.5},
	[16] = {atk = 2.6, hp = 2.6},
	[17] = {atk = 2.7, hp = 2.7},
	[18] = {atk = 2.8, hp = 2.8},
}


-- 宠物大乱斗等级计算
_G.GetRndPetsLevel = function ( cur, max, averageLv, count )
	local minLev = 1
	local maxLev = 50
	cur = max - cur
	local x = 0
	x = averageLv + (cur - max)*averageLv/5
	if x < minLev then
		x = minLev
	elseif x > maxLev then
		x = maxLev
	end
	x = math.floor(x)

	-----------------------------------------
	local offset = math.floor(maxLev / 2)
	offset = math.min(offset, x - minLev)
	offset = math.min(offset, maxLev - x)

	local rndMin = x - offset
	local rndMax = x + offset

	if count == 3 then
		local lv1 = math.random(rndMin, x)
		local lv2 = math.random(x, rndMax)
		local lv3 = x * 3 - lv1 - lv2
		return {lv1, lv2, lv3}
	elseif count == 2 then
		local lv1 = math.random( rndMin, rndMax )
		local lv2 = x * 2 - lv1
		return {lv1, lv2}
	elseif count == 1 then
		return {x}
	else
		return {}
	end
end


-- 角色说话间隔
_G.ROLE_TALK_DELTA = 8


_G.CHANNEL_INFO = [[
{
	"payCode":{
		"522":{"proName":"超值钻石礼盒", "price":"2800", "payCode":"1"},
		"622":{"proName":"超值钻石礼盒", "price":"2800", "payCode":"1"},
		"510":{"proName":"金币大礼盒", "price":"2800", "payCode":"2"},
		"610":{"proName":"金币大礼盒", "price":"2800", "payCode":"2"},
		"800":{"proName":"一键满级", "price":"2800", "payCode":"3"},
		"801":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"802":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"803":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"804":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"805":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"806":{"proName":"变身特权", "price":"600", "payCode":"4"},
		"106":{"proName":"超值道具礼盒", "price":"1000", "payCode":"5"},
		"107":{"proName":"新手礼盒", "price":"10", "payCode":"6"},
		"101":{"proName":"吉亚多礼盒", "price":"600", "payCode":"7"},
		"103":{"proName":"卡维力礼盒", "price":"1500", "payCode":"8"},
		"108":{"proName":"三星过关奖励", "price":"2900", "payCode":"9"},
		"104":{"proName":"加比纳礼盒", "price":"2200", "payCode":"10"},
		"105":{"proName":"雷古曼礼盒", "price":"2800", "payCode":"11"},
		"110":{"proName":"炫冰龙礼盒", "price":"600", "payCode":"12"},
		"111":{"proName":"阴影龙礼盒", "price":"2000", "payCode":"13"},
		"112":{"proName":"旋风龙礼盒", "price":"2800", "payCode":"14"},
		"109":{"proName":"炫酷时装礼盒", "price":"1500", "payCode":"15"}
	},
	"configInfo":{
		"PAY_DAILY_LIMIT":2000,
		"PUSH_UNLOCK":"0;0;0;0;0",
		"MAIN_MENU_FINGER":"1",
		"PUSH_3STAR":"1;1;2;108;1",
		"PUSH_LEVEL":"1;1;2;105;1",
		"PUSH_STRONG_ROLE":"1;1;2;104;0",
		"PUSH_STRONG_PET":"1;1;1;112;1",
		"PUSH_MAIN":"1;1;0;111;1",
		"PUSH_DIAMOND":"1;1;2;622;1",
		"PUSH_COINS":"1;1;2;610;1",
		"PUSH_LOSE":"1;1;2;106;1",
		"SUPER_FINGER":"1",
		"CLOSE_CONFIRM":"0",
		"ACT_TIME":"2016;1;1;2016;2;1",
		"ACT_TITLE":"新春集卡活动",
		"ACT_DESC":"1、挑战游戏关卡获得图书碎片道具。;2、点击兑换，进入兑换界面换取道具；点击前往关卡获取图书碎片。;3、点击京东礼品卡更有30张京东礼品卡等你来拿，京东卡换完即止。"
	},
	"isThirdExit":false,
	"isMoreGame":true
}
]]