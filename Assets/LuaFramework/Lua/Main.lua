require "Common/import"
_G.UPDATER_BOOTED = false


Main = {}
--主入口函数。从这里开始lua逻辑
function Main.main()					
	Main.startUpdater()
end

-- 开启更新器
function Main.startUpdater()
	local unloadModules = {
		"FileLoader",
		"Updater",
	}

	for _, name in pairs( unloadModules ) do
		local fullName = "Updater." .. name
		package.preload[fullName] = nil
		package.loaded[fullName] = nil
	end

	local updater = require( "Updater.Updater" )
	
	updater.start( UPDATER_BOOTED )

	_G.UPDATER_BOOTED = true
end


-- 开始启动游戏
function Main.startApp()
	local MyApp = require "Game/MyApp"
	MyApp.New():run()
end