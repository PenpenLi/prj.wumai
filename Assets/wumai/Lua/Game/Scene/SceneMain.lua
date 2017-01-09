
--[[

	场景基类


]]

local super = require( "Util.Scene")

local M = class( "SceneMain", super )


M.loadingList = {
	"UI/PanelActivity1/prefab",
	"UI/PanelActivity2/prefab",
	"UI/PanelActivity3/prefab",
	"UI/PanelActivity4/prefab",
	"UI/PanelGift/prefab",
	"UI/PanelGift1/prefab",
	"UI/PanelMainMenu/prefab",
	"UI/PanelQuest/prefab",
	"UI/PanelRanking/prefab",
	"UI/PanelService/prefab",
	"UI/PanelSetting/prefab",
	"UI/PanelShop/prefab",
	"UI/PanelStrong/prefab",
	"UI/PanelTip/prefab",
	"UI/PanelDialog/prefab",
	"UI/PanelGuide/prefab",
	"UI/PanelUnlock/prefab",
	
	"Widget/PetInfo/prefab",
	"Widget/RoleInfo/prefab",
	"Widget/ProgressPoints/prefab",
	"Widget/LevelNode/mat",
	
	"Map/MainMap/prefab",
	
	"Effect/lingqu_bao/prefab",
	"Effect/shengji/prefab",
	"Effect/dianji/prefab",
	"Effect/qiehuan/prefab",
}



function M:ctor()

	super.ctor(self)
	self.loadingList = M.loadingList
end


function M:onEnter()
	super.onEnter(self)
	
	AudioPlayer.instance:playMusic("Main-Mainmenu")
	MgrPanel:openPanel("PanelMainMenu")
end


function M:onExit()
	MgrPanel:disposeAllPanel()

	super.onExit(self)
end


return M