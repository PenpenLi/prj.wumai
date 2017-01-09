local function call( funcName ) return function ( ... ) local arg = {...} return function ( self ) if self[funcName] then self[funcName]( self, unpack( arg ) ) else
 printError( "can't find guide function by name %s", funcName ) end end end end
--[[
	新手引导脚本

	-- 等待一段时间下一步响应
	wait				参数:(时间)

	-- 将手指移动到某个地方(本方法会阻塞引导，直到用户响应后继续)
	showFingerTo		参数:(按钮名字<找程序要名字>,freeClick（是否自由点击）)

	-- 隐藏手指
	hideFinger			参数:()

	-- 显示消息
	showMsg				参数:(头像索引, x坐标, y坐标, "测试消息")

	-- 隐藏消息
	hideMsg				参数:(头像索引)
	
	-- 关闭新手引导
	close				参数:()

	-- 关闭引导并保存(保存后引导不会再执行)
	closeAndSave		参数:()

	-- 设置头像
	setHeadAnim

	-- 发送消息
	sendMsg				参数:( msg, param )

	-- 继续游戏
	resumeGame			参数:()

	-- 暂停游戏
	pauseGame			参数:()
	
	--遮罩控制
	hideCollider

	showCollider

	--添加道具
	addItem( itemId, count )

	-- 运行自定义脚本
	runCustomScript

	-- 锁定功能, SceneReady, SceneBattle
	lock( sceneName, uiName, text )

	-- 解锁功能
	unlock( sceneName, uiName )

	
	-- 事件触发命名
	
	GUD_GAME_%s_%s_%s 第x关第y个区域第z波会触发

    --设置剧情
	setHeadAnim( headIdx, view, name, x, y )

	-- closeAndSave 保存并关闭
	-- close 不保存
	-- 开启自由控制

	 setFreeClick 

	GUD_HERO_HP50
	GUD_HERO_HP30


call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn1"),进入战斗

]]



local M = {}

M["GUD_ENTER_SPLASH_"] = {
	-- call "setHeadAnim"(1),
	-- call "setHeadAnim"(2),
	-- call "showMsg" (1, "hello world1"),
	-- call "showMsg" (2, "hello earth2"),

	-- call "showMsg" (1, "hello world3"),
	-- call "showMsg" (2, "hello earth4"),
	-- call "showMsg" (1, "hello world5"),
	-- call "showMsg" (2, "hello earth6"),
	-- call "showFingerTo" ("Layer2/PanelSplash(Clone)/BtnPlay"),
	-- call "close"(),
}

M["GUD_GAME_1_1"] = {
	call "wait" (3),
	call "hideCollider" (),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_dongfangmo/prefab","东方末"),
	call "showMsg" (1, "东方末，城市一片混乱，到底发生了什么事。",false,"Voi-Story01"),
	call "showMsg" (2, "好像有人看到了恐龙，我们必须要阻止他们。",false,"Voi-Story02"),
	call "setHeadAnim"(2, "SpineAnim/ui_senmeila/prefab","森美拉",0,150),
	call "showMsg" (2, "天画，有敌人来了！",false,"Voi-Story03"),
	call "showMsg" (1, "竟然关键时候打断我，森美拉，让我们一起战斗吧！",false,"Voi-Story04"),
	call "hideMsg" (1),
	call "hideMsg" (2),
	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (2, "操作摇杆向着前方移动。",true,"Voi-Move"),
	call "hideCollider" (),
	call "moveFingerBetween" ("Layer2/JoyStick(Clone)/Collider"),
	call "hideMsg" (2),
	call "closeAndSave"(),
}
M["GUD_GAME_1_2_1"] = {

	call "pauseGame" (),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "发现敌人，快进行攻击。",true,"Voi-Attack"),
	call "resumeGame"(),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/B"),
	call "hideMsg" (2),
	call "closeAndSave"(),

}

M["GUD_GAME_1_2_2"] = {
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "前方出现大量敌人，点击施放技能，对敌人造成大量伤害。", true,"Voi-Skill",4),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/X"),
	call "closeAndSave"(),
}

M["GUD_GAME_END_1_2"] = {
	call "pauseGame"(),
	call "wait"(0.5),
	call "resumeGame"(),
	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (2, "接下来，跟着箭头指示的方向移动。",true,"Voi-Arrow"),
	call "moveFingerBetween" ("Layer2/JoyStick(Clone)/Collider"),

	call "closeAndSave"(),
}


M["GUD_GAME_1_3"] = {
	call "pauseGame"(),
	call "showDesc" ("Traps/Trap06_0/trap_06","刺球","碰到的话，会很痛的样子。",0,40,true),
	call "hideDesc" (),
	call "resumeGame" (),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "注意前面的刺球，看准时机，我们可以用“回避”技能来躲过它。", true,"Voi-Dod"),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/A"),
	call "hideMsg" (1),
	call "hideFinger" (),
	call "hideCollider" (),
	call "wait" (0.5),
	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (2, "做得真棒！让我们继续前进吧！",false,"Voi-Good-003"),
	call "closeAndSave"(),
}


M["GUD_GAME_1_5_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	call "showBoss" ("首领：千敌暗龙", "属性：金木水火土\n介绍：混合千帆基因而诞生，具备六大暴龙的特征，坚不可摧所向无敌！", 0, 0),
	call "hideDesc" (),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_dongfangmo/prefab","东方末"),
	call "showMsg" (1, "竟、竟然是千敌暗龙！"),
	call "showMsg" (2, "他们这次来地球的目的到底是什么？"),
	call "showMsg" (1, "管他的，森美拉，上去击败千敌暗龙吧！",false,"Voi-Story04"),
	call "resumeGame"(),
	call "closeAndSave"(),

}

M["GUD_GAME_WIN_1"] = {

	--call "showFingerTo" ("Layer3/PanelEnding(Clone)/BG/Button"),
	call "wait"(1),
	call "showFingerTo" ("Layer3/PanelSettle(Clone)/AnchorBottom/PanelBtn/Grid/BtnNext"),
	call "closeAndSave"(),
}


M["GUD_GAME_2_1_1"] = {
	call "pauseGame"(),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_luoxiaoyi/prefab","洛小熠"),
	call "showMsg" (1, "小熠，我看见一只暴龙进了我们学校！"),
	call "showMsg" (2, "等等，前面有只哈巴龙，他好像希望我们跟着他。"),
	call "showMsg" (1, "那我们就来保护他到达终点吧。"),
	call "hideMsg" (1),
	call "hideMsg" (2),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_GAME_2_2"] = {
	call "pauseGame"(),
	call "wait"(0.5),
	call "showDesc" ("Traps/trap_05 (1)_9/","定时炸弹","轻易靠近的话，就会“嘭”地一下被炸飞哦。",20,20,true),
	call "resumeGame"(),
	call "closeAndSave"(),
}
M["GUD_GAME_2_3_2"] = {

	call "pauseGame"(),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_kaifeng/prefab","凯风"),
	call "showMsg" (2, "天画，我来帮你！"),
	call "showMsg" (1, "凯风，我需要你的力量。"),
	call "showMsg" (2, "这里就交给我的加比纳吧！"),
	call "hideMsg" (1),
	call "hideMsg" (2),
	call "tryRole" (11,5,"Voi-JBN-001"),
	call "wait"(0.5),
	call "showFingerTo" ("Layer3/PanelEquTry(Clone)/BG/BtnBuy"),
	call "hideFinger" (),
	call "hideCollider" (),
	call "setFreeClick" ( true ),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/B"),
	call "close"(),
}

M["GUD_GAME_2_3_3"] = {
	call "setHeadAnim"(1, "SpineAnim/ui_kaifeng/prefab","凯风"),
	call "showMsg" (1, "让我们来试试加比纳的技能，召唤水元素哨塔！", true),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/X"),
	call "closeAndSave"(),
}
M["GUD_GAME_2_4_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	--call "showBoss" ("首领：雷鹰魔龙", "属性：光\n攻略：会召唤光系魔法，最好选择近距离作战。", 0, 0),
	call "showBoss" ("首领：暴烈骸龙", "属性：火\n攻略：近战远程兼顾的暴龙，战斗时注意与他保持距离。", 0, 0),
	call "hideDesc" (),
	call "resumeGame"(),
	call "wait"(3),
	call "setHeadAnim"(1, "SpineAnim/ui_kaifeng/prefab","凯风"),
	call "showMsg" (1, "强敌登场，快让加比纳进化吧！", true),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/R2"),
	call "closeAndSave"(),
}




M["GUD_GAME_WIN_2"] = {

	call "wait"(1),
	call "showFingerTo" ("Layer3/PanelSettle(Clone)/AnchorBottom/PanelBtn/Grid/BtnReturn"),
	call "closeAndSave"(),
}



M["GUD_BACK_MAIN_2"] = {
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_luoxiaoyi/prefab","洛小熠"),
	call "showMsg" (2, "好样的，我们维护了城市的和平。"),
	call "showMsg" (1, "哈巴龙非常感谢我们，希望能够加入我们。"),
	call "showMsg" (2, "那我们就马上用斗龙手环召唤哈巴龙吧。"),
	call "hideMsg" (1),
	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (2, "进入“变强”界面，可以为自己的宝贝龙进行升级。",true),
	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Pnl/Grid/Btn1/Icon"),
	call "hideMsg" (2),
	call "showFingerTo" ("Layer3/PanelStrong(Clone)/AnchorBottom/ToggleChange"),
	--call "showFingerTo" ("Layer3/PanelStrong(Clone)/AnchorBottom/PanelButton/ScrollRole/Viewport/Content/Toggle(Clone)2"),
	call "showMsg" (2, "接下来召唤哈巴龙为我们作战。",true),
	call "showFingerTo" ("Layer3/PanelStrong(Clone)/PetInfo(Clone)/ButtonUnlock"),
	call "hideMsg" (2),
	call "showFingerTo" ("Layer3/PanelStrong(Clone)/PetInfo(Clone)/Button"),
	call "showFingerTo" ("Layer3/PanelStrong(Clone)/PetInfo(Clone)/Button"),
	call "showFingerTo" ("Layer3/PanelStrong(Clone)/AnchorTop/PlayerInfo/BtnBack"),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "让我们带着宠物继续战斗吧。",true),
	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn1"),
	call "hideMsg" (1),
	call "hideFinger" (),
	call "hideCollider" (),
	call "wait" (1.5),
	call "showFingerToLeveL" ("MainMap(Clone)/WorldCanvas/Normal/RotateNode/LvNode/Level3", 3),
	call "hideFinger" (),
	call "hideCollider" (),
	call "wait" (1.5),
	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottomPet/BtnStart"),
	call "closeAndSave"(),

	-- call "wait"(0.2),
	-- call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	-- call "showMsg" (1, "接下来我们让哈巴龙参加一次宠物大乱斗吧。"),
	-- call "showMsg" (1, "如果胜利的话，可以获得丰厚奖励哦。"),
	-- call "hideMsg" (1),
	-- call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn2"),
	-- call "showFingerTo" ("Layer3/PanelActivity4(Clone)/ActivityBtn2/Btn"),
	-- call "showFingerTo" ("Layer3/PanelActivity2(Clone)/AnchorBottom/Plate/Ready"),
	-- call "wait"(0.7),
	-- call "showFingerTo" ("Layer3/PanelActivity2(Clone)/AnchorBottom/AnchorBottomPet/PanelButton/ScrollPet/Viewport/Content/TogglePet(Clone)1"),
	-- call "showFingerTo" ("Layer3/PanelActivity2(Clone)/AnchorBottom/AnchorBottomPet/BtnStart"),
}

M["GUD_GAME_3_1_1"] = {
	call "pauseGame"(),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "出战宠物不一样，获得的宠物技能就不一样。"),
	call "showMsg" (1, "哈巴龙的技能是为我们提供护盾，快来试试吧",true),
	call "resumeGame"(),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/Y"),
	call "closeAndSave"(),
}

M["GUD_GAME_3_2"] = {
	call "pauseGame"(),
	call "wait"(0.5),
	call "showDesc" ("Traps/bing_di_10/","冰刺","被冻住的话，就什么也不能做了……",0,40,true),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_GAME_3_4_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	call "showBoss" ("首领：巨鳄霸龙", "属性：水\n攻略：他巨大的嘴巴伤害极高，也是要害所在。", 0, 0),
	call "resumeGame"(),
	call "closeAndSave"(),
}


M["GUD_GAME_WIN_3"] = {
	call "wait"(1),
	call "showFingerTo" ("Layer3/PanelSettle(Clone)/AnchorBottom/PanelBtn/Grid/BtnReturn"),
	call "closeAndSave"(),
}

M["GUD_BACK_MAIN_3"] = {
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_senmeila/prefab","森美拉",0,150),
	call "showMsg" (1, "六大暴龙又再次复活，他们到底有什么阴谋"),
	call "showMsg" (2, "无论怎样，我们都要阻止他们。"),
	call "showMsg" (1, "森美拉，你也要变得更加强大才行。"),
	call "hideMsg" (2),
	call "showMsg" (1, "点击升级按钮为森美拉进行2次升级。",true),
	call "showFingerToMap" ("MainMap(Clone)/WorldCanvas/RoleNode/RoleInfoMain/Button"),
	call "showMsg" (1, "还有1次升级哦。",true),
	call "showFingerToMap" ("MainMap(Clone)/WorldCanvas/RoleNode/RoleInfoMain/Button"),
	call "showMsg" (1, "做得真棒，让我们继续下面的关卡吧。",true),
	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn1"),
	call "hideMsg" (1),
	call "hideFinger" (),
 	call "hideCollider" (),
	call "wait" (1.5),
	call "showFingerToLeveL" ("MainMap(Clone)/WorldCanvas/Normal/RotateNode/LvNode/Level4", 4),
	call "hideFinger" (),
 	call "hideCollider" (),
 	call "wait" (1.5),
 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottomPet/BtnStart"),


 	call "closeAndSave"(),
}
-- M["GUD_BACK_MAIN_1002"] = {
-- 	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
-- 	call "showMsg" (1, "宠物还可以和我们一起出战，让我们快来试试吧。"),
-- 	call "hideMsg" (1),
-- 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn1"),
-- 	call "hideFinger" (),
-- 	call "hideCollider" (),
-- 	call "wait" (1.5),
-- 	call "showFingerToLeveL" ("MainMap(Clone)/WorldCanvas/Normal/RotateNode/LvNode/Level3", 3),
-- 	call "hideFinger" (),
-- 	call "hideCollider" (),
-- 	call "wait" (1.5),
-- 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottomPet/BtnStart"),
-- 	call "closeAndSave"(),
-- }


M["GUD_GAME_4_2_1"] = {
	call "wait"(0.1),
	call "pauseGame"(),
	call "showDesc" ("Creatures/Monster/","敌人：地灰龙","技能：生成流沙限制敌人行动。\n特性：胆子很小，会钻进地里躲起来。",0,30,true),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_GAME_4_2_2"] = {

	call "pauseGame"(),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_bainuo/prefab","百诺"),
	call "showMsg" (2, "天画，博士为森美拉研发了新的装备。"),
	call "showMsg" (1, "太好了，现在就试试看吧"),
	call "showMsg" (2, "好的，让森美拉穿上这套装甲吧。"),
	call "hideMsg" (1),
	call "hideMsg" (2),
	call "tryRole" (33,3,"Voi-Story04"),
	call "wait"(0.5),
	call "showFingerTo" ("Layer3/PanelEquTry(Clone)/BG/BtnBuy"),
	call "close"(),
}



M["GUD_GAME_4_3_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	call "showBoss" ("首领：蜘蛛毒龙", "属性：土\n攻略：注意吐出的蜘蛛网，远距离战斗是最好的选择。", 0, 0),
	call "resumeGame"(),
	call "closeAndSave"(),
}

-- M["GUD_GAME_WIN_4"] = {
-- 	call "wait"(1),
-- 	call "showFingerTo" ("Layer3/PanelSettle(Clone)/AnchorBottom/PanelBtn/Grid/BtnReturn"),
-- 	call "closeAndSave"(),
-- }

-- M["GUD_BACK_MAIN_4"] = {
-- 	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
-- 	call "showMsg" (2, "来获得每日签到奖励吧。",true),
-- 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorLeft/Grid/Btn2/Icon"),
-- 	call "hideMsg" (2),
-- 	call "hideFinger" (),
--  	call "hideCollider" (),
-- 	call "wait"(1),
-- 	call "showFingerTo" ("Layer3/PanelQuest(Clone)/Scrolls/Scroll3/Viewport/Content/Cell(Clone)1/BtnGet/"),--签到领奖
-- 	call "showFingerTo" ("Layer3/PanelQuest(Clone)/AnchorTop/PlayerInfo/BtnBack"),--返回
-- 	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
-- 	call "showMsg" (1, "做得真棒，让我们继续下面的关卡吧。",true),
-- 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Btn1"),
-- 	call "hideMsg" (1),
-- 	call "hideFinger" (),
--  	call "hideCollider" (),
-- 	call "wait" (1.5),
-- 	call "showFingerToLeveL" ("MainMap(Clone)/WorldCanvas/Normal/RotateNode/LvNode/Level5", 5),
-- 	call "hideFinger" (),
--  	call "hideCollider" (),
--  	call "wait" (1.5),
--  	call "setHeadAnim"(2, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
-- 	call "showMsg" (2, "选择地灰龙进行出战吧。",true),
-- 	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottomPet/PanelButton/ScrollPet/Viewport/Content/TogglePet(Clone)2"),
-- 	call "hideMsg" (2),
--  	call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottomPet/BtnStart"),
--  	call "closeAndSave"(),
-- }

M["GUD_GAME_5_1_1"] = {
	call "pauseGame"(),
	call "wait"(1),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "setHeadAnim"(2, "SpineAnim/ui_ziyao/prefab","子耀"),
	call "showMsg" (2, "龙鳞谷里面好热呀。"),
	call "showMsg" (1, "对呀，路上还喷出了好多的岩浆！"),
	call "showMsg" (2, "对了，我们让炫冰龙出来帮帮我们吧。"),
	call "hideMsg" (1),
	call "hideMsg" (2),
	call "tryRole" (210,3),
	call "wait"(0.5),
	call "showFingerTo" ("Layer3/PanelEquTry(Clone)/BG/BtnBuy"),
	call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab","蓝天画"),
	call "showMsg" (1, "快来试试炫冰龙的必杀技：冰冻领域！",true),
	call "resumeGame"(),
	call "showFingerTo" ("Layer2/SkillButton(Clone)/Y"),
	call "closeAndSave"(),
}


M["GUD_GAME_5_2_1"] = {
	call "pauseGame"(),
	call "wait"(1),
	call "showDesc" ("Traps/yanjiang (1)_1/","岩浆口","喷出岩浆的时候不要站在上面，会把屁股烧着的。",0,0,true),
	call "resumeGame"(),
	call "closeAndSave"(),
}
M["GUD_GAME_5_3_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	call "showBoss" ("首领：骷髅煞龙", "属性：金\n攻略：会分身，有极高机动性，掌握躲避的时机是战斗胜利的关键。", 0, 0),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_GAME_6_2"] = {
	call "pauseGame"(),
	call "wait"(0.5),
	call "showDesc" ("Traps/trap_09 (1)_0/","毒蘑菇","能喷出剧毒瘴气，这味道肯定很酸爽……",0,40,true),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_GAME_6_4_1"] = {
	call "hideCollider" (),
	call "wait"(5),
	call "pauseGame"(),
	call "showBoss" ("首领：森林古龙", "属性：木\n攻略：会放各种远程攻击法术，保持中距离进行进攻是十分有效的。", 0, 0),
	call "resumeGame"(),
	call "closeAndSave"(),
}

M["GUD_BACK_MAIN_nil"] = {
	-- call "setHeadAnim"(1, "SpineAnim/ui_lantianhua/prefab"),
	-- call "setHeadAnim"(2, "SpineAnim/ui_dongfangmo/prefab"),
	-- call "showMsg" (1, "东方末，我们"),
	-- call "showMsg" (2, "hello earth2"),
	-- call "showMsg" (1, "hello world3"),
	-- call "showMsg" (2, "hello earth4"),
	-- call "hideMsg" (1),
	-- call "hideMsg" (2),

	-- call "showFingerTo" ("Layer3/PanelMainMenu(Clone)/AnchorBottom/Pnl/Grid/Btn1/Icon"),
	-- call "showFingerTo" ("Layer3/PanelStrong(Clone)/AnchorBottom/PanelButton/ScrollRole/Viewport/Content/Toggle(Clone)4"),
	-- call "showFingerTo" ("Layer3/PanelStrong(Clone)/RoleInfo(Clone)/Button"),
	call "closeAndSave"(),

}






return M


