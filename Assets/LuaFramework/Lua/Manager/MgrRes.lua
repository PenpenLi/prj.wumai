--[[
	资源管理器
]]


--[[



		名词解释：请区分assetBundle asset以及assetBundleName assetName
	




		这里对资源名做二次封装

		资源封装（资源有常驻资源和非常驻资源）resObject.name resObject.level
		resObject = {
			assetBundleName = xxx  //这个object是属于哪个assetBundle
			object = xxx //真正的object
			referencedCount = xxx //引用计数

		}

		游戏调用资源例子：
		比如Build下面的资源test/cube.prefab  
		assetBundleKey就是"test/cube/prefab" 
		assetName就是"cube"
		objectCacheKey就是test/cube/prefab|cube
		此函数处理成真正的资源名（assetBundleName）"assets_luaframework_examples_builds_test_cube_prefab"

		请区分4个变量




	]]

local M = class( "MgrRes")


local DEBUG = false



-- 依赖资源

local OBJECT_CACHE = {}

--异步原因，需要判断是否在loading
local loadingRequestCallbackList = {}





function M:loadPrefab(assetBundleKey, assetName, callback, fullPath)

	--objectcache中的唯一key
	local objectCacheKey
	assetName = assetName or M.getAssetNameByKey(assetBundleKey)

	objectCacheKey = M.getObjectCacheKey(assetBundleKey, assetName)


	local resObject = OBJECT_CACHE[objectCacheKey]
	if resObject then
		--引用计数加1
		resObject.referencedCount = resObject.referencedCount + 1
		callback(resObject.object)
		return
	end

	local assetBundleName
	--全路径和非全路径
	if not fullPath then
		assetBundleName = M.getAssetBundleNameByKey(assetBundleKey)
	else
		assetBundleName = assetBundleKey
	end


	--将callback挂载loadingRequest中，当加载完毕后再依次调用callback
	if not loadingRequestCallbackList[objectCacheKey] then
		loadingRequestCallbackList[objectCacheKey] = {}
		table.insert(loadingRequestCallbackList[objectCacheKey], callback)
	else
		--loading中
		table.insert(loadingRequestCallbackList[objectCacheKey], callback)
		return 
	end
	


	AssetBundleMgr:LoadAsyncPrefab(assetBundleName, assetName, function(obj) self:onLoadPrefab(assetBundleName, objectCacheKey, obj) end)
	return assetBundleName

end

function M:loadReferencedPrefab(assetBundleKey)
	objectCacheKey = M.getObjectCacheKey(assetBundleKey)


	local resObject = OBJECT_CACHE[objectCacheKey]
	if resObject then
		--引用计数加1
		resObject.referencedCount = resObject.referencedCount + 1
		return true
	end
	--reference中无，需要加载
	return false
end



function M:onLoadPrefab(assetBundleName, objectCacheKey, obj)

	-- print("onLoadPrefab: assetBundleKey is", assetBundleKey, objList[0])
	--将获取到的资源cache
	local resObject = {}
	resObject.assetBundleName = assetBundleName
	resObject.object = obj
	resObject.referencedCount = 0

	--放入缓存
	OBJECT_CACHE[objectCacheKey] = resObject

	--处理callback
	local callbackList =loadingRequestCallbackList[objectCacheKey]
	if callbackList then
		--引用计数
		resObject.referencedCount = #callbackList
		for i, v in ipairs(callbackList) do
			v(obj)
			--print("callback", objectCacheKey, Time.frameCount)
		end
		loadingRequestCallbackList[objectCacheKey] = nil

		
	else

		--没有回调？ 本身已经失去意义
		printWarn("onLoadPrefab: No Loaded Callback Exists, Mark Destroyable Object ! ", objectCacheKey)


	end
	
end

function M:putPrefab(assetBundleKey, assetName)
	local objectCacheKey = M.getObjectCacheKey(assetBundleKey, assetName)

	local resObject = OBJECT_CACHE[objectCacheKey]

	--有缓存
	if resObject then
		resObject.referencedCount = resObject.referencedCount - 1
		if resObject.referencedCount < 0 then
			resObject.referencedCount = 0
		end
		-- local assetBundleName = resObject.assetBundleName
		-- OBJECT_CACHE[objectCacheKey] = nil
		-- -- resMgr:UnloadAssetBundle(M.getAssetBundleNameByKey(assetBundleKey))
		-- AssetBundleMgr.UnloadAssetBundle(assetBundleName)

		--是统一销毁还是当引用计数为0时立即销毁，这里需要看项目的实际使用情况，
		--为了减少游戏卡顿，我们这里牺牲下内存，让引用计数为0的资源多存活点时间（增加资源访问命中率）
	end
	--没有缓存的情况？？ 报警还是无视？？
end


function M:getObjCache()
	return OBJECT_CACHE
end


function M:clearObjectCache(assetBundleKey)
	
end


--TODO(这里可能需要加资源等级)
function M:clearObjectCacheAll()
	for key,resObject in pairs(OBJECT_CACHE) do



		if resObject.referencedCount <= 0 then
			
			AssetBundleMgr.UnloadAssetBundle(resObject.assetBundleName)
			OBJECT_CACHE[key] = nil
		end
		
		

	end

	--OBJECT_CACHE是无法清理干净的

end


function M:clearMemory()
	Util.ClearMemory()
end


--将key转化为真正的资源名
function M.getAssetBundleNameByKey(assetBundleKey)
	--[[
	assetBundleKey就是"test/cube/prefab" 
	此函数处理成真正的资源名（assetBundleName）"assets_luaframework_examples_builds_test_cube_prefab"
	]]
	return string.format("%s_%s_%s_%s_%s", AppConst.AssetName, AppConst.AppPath, AppConst.AppResName, AppConst.EditorBuildsName, string.gsub(string.gsub(assetBundleKey, "/", "_"), " ", "_"))
end


function M.getAssetNameByKey(assetBundleKey)

	--根据key获取资源名 exp:test/cube/prefab 获取cube
	return string.match(assetBundleKey, ".+%/(.+)%/%w+$")
	
end


function M.getObjectCacheKey(assetBundleKey, assetName)
	assetName = assetName or M.getAssetNameByKey(assetBundleKey)
	--assetBundle和asset组合成的唯一key
	return assetBundleKey .. "|" .. assetName
end

















return M




