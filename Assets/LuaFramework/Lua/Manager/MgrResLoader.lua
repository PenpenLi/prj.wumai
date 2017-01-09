--[[

	资源加载管理
]]


local M = class("MgrResLoader")


--加载完毕的场景资源




--原始资源加载列表
M.loadingResList = {}
--原始资源卸载列表
M.removingResList = {}

--计算完毕的加载资源列表（兼顾卸载和加载后）
M.calculatedLoadResList = {}

------------------------------------
M.looperTimer = nil
M.UPDATE_INTERVAL = 0.01
--最大同时处理任务数
M.MAX_LOAD_TASK = 30

function M:start(callback)
	-- if not M.looperTimer then
	-- 	M.looperTimer = Timer.New( handler( self, self.process ), M.UPDATE_INTERVAL, -1 )
	-- end
 --    M.looperTimer:Start()
 	self:process(callback)
end



function M:stop()

	-- M.looperTimer:Stop()
end




function M:insert(abName)

	M.loadingResList[abName] = true
end



function M:remove(abName)

	M.removingResList[abName] = true

end

function M:insertLoading(list)
	for i, v in ipairs(list) do
		M.loadingResList[v] = true
	end
end

function M:insertRemoving(list)
	for i, v in ipairs(list) do
		M.removingResList[v] = true
	end
end


--预处理资源的引用，方便mgrres统一清理资源
function M:preProcess()
	M.calculatedLoadResList = {}
	for assetBundleKey, _ in pairs(M.removingResList) do
		MgrRes:putPrefab(assetBundleKey)
	end

	for assetBundleKey, _ in pairs(M.loadingResList) do
		if not MgrRes:loadReferencedPrefab(assetBundleKey) then
			M.calculatedLoadResList[assetBundleKey] = true
		end
	end

	--清空待卸载列表
	M.removingResList = {}
	M.loadingResList = {}

	
end



--mainlooper
function M:process(callback)
	--print("MgrResLoader Start Work", Time.frameCount)
	local total = 0
	local current = 0


	


	local loadTaskQueue = {}

	local function onloaded()
		current = current + 1
		sendMsg( "MSG_SCENETRANSITION", math.ceil(current*100/total) )
		if current>= total then

			--加载完毕，通知MgrScene加载完毕
			
			sendMsg( "MSG_SCENETRANSITION_DONE")
			--MgrScene:executeSceneDown()
			callback()
			return
		end



		--继续处理下个任务
		--开始加载新的资源
		local abName = table.remove(loadTaskQueue)
		if abName then
			MgrRes:loadPrefab(abName, nil, onloaded)
			-- print("loadPrefab frameCount", Time.frameCount)
		end
	end
	
	for k, _ in pairs(M.calculatedLoadResList) do
		--先将需要加载的资源数计算出，因为通过模拟器加载时，
		--会立刻调用到onloaded，导致current 始终等于 total， callback会被多次调用
		total = total + 1
		table.insert(loadTaskQueue, k)
	end

	--根据最大任务数开启任务处理线
	for i = 1, M.MAX_LOAD_TASK do
		--开始加载新的资源
		local abName = table.remove(loadTaskQueue)
		if abName then
			MgrRes:loadPrefab(abName, nil, onloaded)
			-- print("loadPrefab frameCount", Time.frameCount)
		end
	end

	--加载完毕，清空待加载列表
	M.calculatedLoadResList = {}

	if total == 0 then
		printWarn("MgrResLoader process : no calculatedLoadResList return")
		sendMsg( "MSG_SCENETRANSITION_DONE")
		callback()
		return
	end
end


--TODO(待增加加载超时无响应检测，加载出错能交互)


------------------------------------

return M