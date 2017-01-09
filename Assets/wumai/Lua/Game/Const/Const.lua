_G.Const = {
	DB_TEST = "test_db",

	STATE_NONE = "None",
	STATE_IDLE = "Idel",
	STATE_ATTACK = "Attack",
	STATE_WALK = "Walk",
	STATE_MOVE = "Move",
	STATE_ROLL = "Roll",
	STATE_SKILL = "Skill",
	STATE_UNIQUE = "Unique",
	STATE_ESOTERIC = "Esoteric",
	STATE_ULTIMATE_SLAY = "UltimateSlay",
	STATE_DEATH = "Death",
	STATE_HIT = "Hit",
	STATE_DOWN = "Down",
	STATE_FLY = "Fly",
	STATE_FREE_FALL = "FreeFall",
	STATE_REPEL = "Repel",
	STATE_TRANSFORM = "Transform",
	STATE_TRANSFORM_ATTACK = "TransformAttack",
	STATE_SHOW = "Show",
	STATE_DIZZY = "Dizzy",
	STATE_FREEZE = "Freeze",
}



-----------------------------------------------------------
local add = { index = 0 }
add.add = function () add.index = add.index + 1 return add.index end
add.reset = function () add.index = 0 end

_G.CREATURE_TYPE = {
	CREATURE = 1,
	HERO = 1,
	MONSTER = 2,
	BOSS = 3,
	PET = 4,
	NPC = 6,
}

_G.CREATURE_ACTION = {
	Idle = 1,
	Move = 2,
	Attack1 = 3,
	Death = 4,
	Skill = 5,
	Roll1 = 6,
	Roll2 = 7,
	MoveAttack1 = 8,
	Change = 9,

	Hit = 20,
	Down = 21,
	DownUp = 22,
	Fly = 23,
	Dizzy = 24,
	Show1 = 25,
	Show2 = 26,
	Attack2 = 31,
	MoveAttack2 = 32,
	Attack3 = 33,
	MoveAttack3 = 34,

	Win = 40,
	Lost = 41,

	BossAtk1_B = 50,
	BossAtk1 = 51,
	BossAtk2_B = 60,
	BossAtk2 = 61,
	BossAtk3_B = 70,
	BossAtk3 = 71,
	BossAtk4_B = 80,
	BossAtk4 = 81,
	BossAtk5_B = 90,
	BossAtk5 = 91,
}

_G.GAME_MODE_NORMAL = 1
_G.GAME_MODE_TIME = 2

_G.GAME_TYPE_NORMAL = 1
_G.GAME_TYPE_BOSS = 2
_G.GAME_TYPE_PETS = 3
_G.GAME_TYPE_CATCH = 4

_G.GAME_BOSS_SCORE = "GameBossBattle"
_G.GAME_PET_SCORE = "GamePetBattle"

_G.FACTION_A = 1
_G.FACTION_B = 2

_G.SKILL_TARGET_ENEMY = 1
_G.SKILL_TARGET_COMPANION = 2

_G.ATTACK_NORMAL1 = 1 --普通攻击1
_G.ATTACK_SKILL = 2 --技能
_G.ATTACK_UNIQUE = 3 --必杀技
_G.ATTACK_ESOTERIC = 4 --奥义
_G.ATTACK_ULTIMATE_SLAY = 5 --终极必杀
_G.ATTACK_TRANSFORM = 6 --变身

_G.ATTACK_NORMAL2 = 10 --普通攻击2
_G.ATTACK_NORMAL3 = 11 --普通攻击3
_G.ATTACK_NORMAL4 = 12 --普通攻击4
_G.ATTACK_NORMAL5 = 13 --普通攻击5

_G.HIT_TYPE_NORMAL = 1
_G.HIT_TYPE_HIT = 2
_G.HIT_TYPE_REPEL = 3
_G.HIT_TYPE_DOWN = 4
_G.HIT_TYPE_FLY = 5
_G.HIT_TYPE_HOVER = 6
_G.HIT_TYPE_FREEZE = 7

-- 物品类型
_G.ITEM_TYPE_RMB			= 0		-- 人民币（无法持有）
_G.ITEM_TYPE_CURRENCY		= 1		-- 货币
_G.ITEM_TYPE_NORMAL			= 2		-- 物品
_G.ITEM_TYPE_DROP			= 3		-- 掉落
_G.ITEM_TYPE_LOTTERY		= 4		-- 抽奖


-- 特殊物品ID
_G.ID_ITEM_MONEE_DIAMOND 	= 1000 -- 钻石
_G.ID_ITEM_MONEY_COINS 		= 1001 -- 金币
_G.ID_ITEM_VITALITY			= 1002 -- 体力
_G.ID_ITEM_RMB				= 1003 -- 人名币
_G.ID_ITEM_POTION			= 1100 -- 药水
_G.ID_ITEM_RELIVE 			= 1101
_G.ID_ITEM_ACT 				= 1204 -- 活动碎片

-- 商店gid
add.reset()
_G.GID_SHOP_NONE 			= 0	 			-- 0、不显示
_G.GID_SHOP_GIFT 			= add.add()		-- 1、礼包
_G.GID_SHOP_ROLE	        = add.add()		-- 2、角色
_G.GID_SHOP_FASHIO 			= add.add()		-- 3、时装
_G.GID_SHOP_PET		        = add.add()		-- 4、宠物
_G.GID_SHOP_PROP 			= add.add()		-- 5、道具
_G.GID_SHOP_EX_ROLE			= add.add()		-- 6、兑换角色
_G.GID_SHOP_EX_FASHIO		= add.add()		-- 7、兑换时装
_G.GID_SHOP_EX_PET	        = add.add()		-- 8、兑换宠物
_G.GID_SHOP_EX_PROP			= add.add()		-- 9、兑换道具


-- 任务类型
_G.QUEST_TYPE_NORMALL 	 	= 1 	-- 普通任务
_G.QUEST_TYPE_ACHIEVEMENT 	= 2 	-- 成就任务
_G.QUEST_TYPE_DAILY 	 	= 3 	-- 每日任务 
_G.QUEST_TYPE_SIGN			= 4		-- 签到
_G.QUEST_TYPE_STATISTICS	= 5		-- 统计任务
_G.QUEST_TYPE_DLZBS			= 6		-- 斗龙争霸赛


-- 任务状态
add.reset()
_G.QUEST_STATE_NONE       	= add.add() -- 1 目标状态 无状态（任务不存在）
_G.QUEST_STATE_UPDATEABLE 	= add.add() -- 2 目标状态 可更新
_G.QUEST_STATE_FAIL		 	= add.add() -- 3 失败
_G.QUEST_STATE_COMMITABLE 	= add.add() -- 4 目标状态 可提交（领取奖励）
_G.QUEST_STATE_FINISHED   	= add.add() -- 5 目标状态 已完成


_G.LEVEL_TYPE_NORMAL = 1		-- 普通关卡
_G.LEVEL_TYPE_DOU_LONG = 2		-- 斗龙争霸赛
_G.LEVEL_TYPE_PET = 3			-- 宠物大乱斗
_G.LEVEL_TYPE_BU_LONG = 4 		-- 捕龙达人


_G.PAY_DIALOG_STYLE_NORMAL = 0
_G.PAY_DIALOG_STYLE_SIMPLE = 1
_G.PAY_DIALOG_STYLE_PAY = 2
_G.PAY_DIALOG_STYLE_UNLICK = 3


-- 关卡解锁开关
_G.UNLOCK_ALL_LEVEL = false


-- layer
_G.LAYER = {
	Default = LayerMask.NameToLayer("Default"),
	UI = LayerMask.NameToLayer("UI"),
	UIRenderTexture = LayerMask.NameToLayer("UIRenderTexture"),
}


-- 战力排行
_G.RANK_POWER = 1
-- 宠物大乱斗排行
_G.RANK_CWDLD = 2
-- 斗龙争霸赛排行
_G.RANK_DLZBS = 3


_G.RANK_DATA = {
	[RANK_POWER] = {
		image = "text/rank2",
		id = "17",
	},
	[RANK_CWDLD] = {
		image = "text/rank1",
		id = "18",
	},
	[RANK_DLZBS] = {
		image = "text/rank3",
		id = "19",
	},
}