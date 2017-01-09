--[[
	场景资源管理器



	PanelTransition 作为配合scene的存在，不受MgrPanel管理，不然会乱套
]]




local M = class( "MgrScene")


M.runningSceneName = nil

M.runningScene = nil

M.nextScene = nil
M.nextSceneName = nil

M.registeredSceneList = {}

M.registeredPanelTransition = {}




function M:registerScene(sceneName, scene)
	if M.registeredSceneList[sceneName] then
		print( string.format("MgrScene:registerScene [%s] 已存在,请检查是否已注册过!!", sceneName))
	end

	M.registeredSceneList[sceneName] = scene
end


function M:registerTransitionPanel(name, panelTransition)
	if M.registeredPanelTransition[name] then
		print( string.format("MgrScene:registerTransitionPanel [%s] 已存在,请检查是否已注册过!!", sceneName))
	end
	M.registeredPanelTransition[name] = panelTransition
end

function M:clearRegisteredScene()

	M.registeredSceneList()
end


function M:executeScene(sceneName, panelTransitionName)
	if self.busy then
		printWarn("MgrScene:executeScene Is Busy Now! return")
		return
	end
	local nextScene = M.registeredSceneList[sceneName]

	local panelTransition = nil
	if panelTransitionName then
		panelTransition = M.registeredPanelTransition[panelTransitionName]
	end

	if not nextScene then
		printError("MgrScene:executeScene(sceneName) sceneName is not registered : ", sceneName)
		return
	end


	if M.runningScene == nextScene then

		return
	end

	M.nextScene = nextScene

	self.busy = true

	if M.runningScene then
		MgrResLoader:insertRemoving(M.runningScene:getLoadingList())
	end
	--清理上个场景
	self:removeRunningScene()


	if panelTransition then
		panelTransition:show()
	end


	--将资源卸载加载交给loader
	MgrResLoader:insertLoading(nextScene:getLoadingList())
	
	MgrResLoader:preProcess()

	MgrRes:clearObjectCacheAll()
	MgrRes:clearMemory()

	MgrResLoader:process(handler(self, self.executeSceneDown))


	--加载下个场景
	-- self:loadNextScene()
end



function M:executeSceneDown()

	self:loadNextScene()
	self.busy = false
end



--加载某个场景
function M:loadNextScene()

    if M.runningScene then
    	printError("MgrScene:loadNextScene(sceneName) runningScene already exists.")
    end
    M.runningScene = M.nextScene


    M.nextScene:onEnter()


end



--卸载某个场景
function M:removeRunningScene()

	if not M.runningScene then
		return false
	end
	M.runningScene:onExit()

	M.runningScene = nil
	return true
end


return M




