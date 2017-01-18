require "Common/import"
require "Game/Common/import"

local MyApp = class( "MyApp" )

local PanelLoading = require("Game/Ui/PanelLoading")
local SceneMain = require("Game/Scene/SceneMain")
local SceneRoom = require("Game/Scene/SceneRoom")
local SceneSplash = require("Game/Scene/SceneSplash")
local SceneBattle = require("Game/Scene/SceneBattle")


function MyApp:ctor( configs )

end


function MyApp:run( sceneName )
	self:initGame()

	MgrScene:registerScene("SceneSplash", SceneSplash.New())
	MgrScene:registerScene("SceneMain", SceneMain.New())
	MgrScene:registerScene("SceneRoom", SceneRoom.New())
	MgrScene:registerScene("SceneBattle", SceneBattle.New())

	MgrScene:registerTransitionPanel("PanelLoading", PanelLoading.New())

	MgrScene:executeScene("SceneSplash", "PanelLoading")
end




function MyApp:initGame()
	math.randomseed(os.time())
	
	MgrPanel:setViewRoots( "Game.UI" )
	ModuleLoader.init()

	LuaObject.setDefaultClickSound("Game-Button")
end







return MyApp