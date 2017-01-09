--[[
	下载器
--]]
local WWW = UnityEngine.WWW


local this = {}


-- @param timeout 超时时间，默认30秒
function wwwInTime( www, timeout, timeoutCallback )
	local co = coroutine.running()
	local timer = nil
	timeout = timeout or 30

	local stopFun = function ()
		timer:Stop()
		local flag, msg = coroutine.resume( co )
		
		if not flag then
			msg = debug.traceback( co, msg )
			error(msg)
		end
	end
	
	local action = function()
		timeout = timeout - Time.unscaledDeltaTime
		if not www.isDone then
			if timeout <= 0 then
				if timeoutCallback then
					timeoutCallback()
				end
				stopFun()

				-- 这个是放在后头还是放在前头?
				www:Dispose()
			end
			return
		end
		
		stopFun()
	end
	
	timer = FrameTimer.New(action, 1, -1)
	timer:Start()
	return coroutine.yield()
end



local function getWWWCoroutine( uri, sucCallback, failCallback, timeout, timeoutCallback )
	return function ()
		local www = WWW.New( uri )
		local bTimeout = false

		wwwInTime( www, timeout, function ()
			bTimeout = true
		end )

		if bTimeout then
			-- www:Dispose()
			-- www = nil
			
			if timeoutCallback then
				timeoutCallback()
			end
		else
			if not www.error or www.error == "" then
				if sucCallback then sucCallback( www ) end
			else
				if failCallback then failCallback( www ) end
			end
			
			www:Dispose()
			www = nil
		end
	end
end


-- 包内文件加载或远程加载(异步加载)
function this.load( uri, sucCallback, failCallback, timeout, timeoutCallback )
	coroutine.start( getWWWCoroutine( uri, sucCallback, failCallback, timeout, timeoutCallback ) )
end


-- 同步加载
function this.loadAssetBundleFromFileImm( releaseUri, publishUri, relativeUri )
	return Tools.CreateAssetBundleFromFileImm( releaseUri, publishUri, relativeUri )
end


function this.loadTextFromFileImm( uri )
	return Tools.ReadAllText( uri )
end


function this.loadTextFromFileBySearchImm(uri)
	local releaseUri = AppConst.ReleasePathRoot .. uri
	local publishUri = AppConst.PublishPathRoot .. uri
	local relativeUri = "assets/"..uri

	return Tools.ReadAllTextBySearch(releaseUri, publishUri, relativeUri)
end


function this.test()
	print( "--------- test" )
	coroutine.start( getWWWCoroutine( "127.0.0.1:51234/test.mkv", function ( www )
		print( "============ complete" )
		print( www.error )
		print( "www.bytesDownloaded", www.bytesDownloaded )
		print( "www.progress", www.progress )

		print( www.bytes )
		print( type( www.bytes ) )
	end ) )
end







return this
