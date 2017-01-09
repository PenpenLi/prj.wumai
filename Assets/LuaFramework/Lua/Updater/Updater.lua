--[[
	更新器

	更新流程：

	1. 准备更新
		检测patch_info是否存在，如果不存在则不需要更新
		检测包的版本和本地存档的版本是否相同，如果不相同则重置补丁（在不删除存档的情况下换包）
		提取本地pid


	PS: .cs无法被更新，导致依赖cs的lua代码也不能更新，注定某些更新无法进行，此更新器仅保证自身和业务逻辑代码的更新
		本更新最大的问题在于所有代码被合并到了一个lua文件，故
]]



-- SDK版本
_G.SDK_VERSION = 2



TIP_MSG_READY 		= "准备更新"					-- 准备更新
TIP_MSG_CHECK 		= "斗龙能量准备中"			-- 检查新版本
TIP_MSG_UPDATE 		= "斗龙能量收集中(%s/%s)"		-- 正在更新
TIP_MSG_START 		= "开始游戏"					-- 开始游戏
TIP_MSG_REBOOT 		= "重新启动"					-- 重新启动



----- 工具函数 ------
local function string_split( self, delim, toNumber )
	
	local start = 1
	local t = {}  -- results table
	local newElement
	-- find each instance of a string followed by the delimiter
	while true do
		local pos = string.find (self, delim, start, true) -- plain find
		if not pos then
			break
		end
		-- force to number
		newElement = string.sub (self, start, pos - 1)
		if toNumber then
			newElement = string.toNumber(newElement) --newElement:toNumber()
		end
		table.insert (t, newElement)
		start = pos + string.len (delim)
	end -- while

	-- insert final one (after last delimiter)
	local value =  string.sub (self, start)
	if toNumber then
		value = string.toNumber(value) --value:toNumber()
	end
	table.insert (t,value )
	return t
end


local function string_trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")
	return string.gsub(input, "[ \t\n\r]+$", "")
end


local function dump_value_(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end
	return tostring(v)
end


function dump(value, desciption, nesting)
	if type(nesting) ~= "number" then nesting = 3 end

	local lookupTable = {}
	local result = {}

	local traceback = string_split(debug.traceback("", 2), "\n")
	print("dump from: " .. string_trim(traceback[3] or ""))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		print(line)
	end
end


local function PrintTable( tb , title, bNotSort )
	local tabNum = 0
	local function stab( numTab )
		return string.rep("    ", numTab)
	end
	local str = {}


	local function _printTable( t )
		table.insert( str, "{" )
		tabNum = tabNum + 1

		local keys = {}
		for k, v in pairs( t ) do
			table.insert( keys, k )
		end
		if not bNotSort then table.sort(keys) end

		for _, k in pairs( keys ) do
			local v = t[ k ]
			local kk
			if type(k) == "string" then
				kk = "['" .. k .. "']"
			else
				kk = "[" .. tostring(k) .. "]"
			end
			if type(v) == "table" then
				table.insert( str, string.format('\n%s%s = ', stab(tabNum),kk))
				_printTable( v )
			else
				local vv = ""
				if type(v) == "string" then
					vv = string.format("\"%s\"", v)
				elseif type(v) == "number" or type(v) == "boolean" then
					vv = tostring(v)
				else
					vv = "[" .. type(v) .. "]"
				end

				if type(k) == "string" then
					table.insert( str, string.format("\n%s%-18s = %s,", stab(tabNum), kk, string.gsub(vv, "%%", "?") ) )
				else
					table.insert( str, string.format("\n%s%-4s = %s,", stab(tabNum), kk, string.gsub(vv, "%%", "?") ) )
					--print( string.format("%s%s", stab(tabNum), vv) )
				end

			end
		end
		tabNum = tabNum - 1

		if tabNum == 0 then
			table.insert( str, '}' )
		else
			table.insert( str, '},' )
		end
	end


	local titleInfo = title or "table"
	table.insert( str, string.format("\n----------begin[%s]----------[%s]", titleInfo, os.date("%H:%M:%S") )  )
	if not tb or type(tb) ~= "table" then
		print( tb)
	else
		_printTable( tb )
	end

	table.insert( str, string.format("\n----------end  [%s]----------\n", titleInfo))
	print( table.concat(str, "") )
end




local Updater = {}

-- 这里只能引用：
--     C模块
--     updater模块内的代码
local cjson = require("cjson")
local FileLoader = require( "updater.FileLoader" )


Updater.isWorking = false







----- 变量定义区 ------
local DEBUG = true

-- 是否包含SDK
local USE_SDK = true

-- 强制先检查更新
local FORCE_CHECK_PATCH = true


Updater.patchInfo = nil
Updater.localPid = nil
Updater.patchs = nil
Updater.patchIdx = nil

local TIMEOUT = 3


local mChannel = "ultralisk"




--- 发送ui消息
local function sendUpdateMsg( msg )
	if DEBUG then print( msg ) end
	Tools.SendMessageCommand( NotiConst.UPDATE_MESSAGE, msg )
end



-- 打印日志，独立管理
local function printf(fmt, ...)
	if DEBUG then
		print( string.format(tostring(fmt), ...))
	end
end



-- 获取渠道信息
local function getChannel()
	return mChannel
end









----- 生命周期 -----
local timer = nil
function Updater.start( bFirstBoot )
	Updater.isWorking = true

	if not FORCE_CHECK_PATCH and ( Tools.isEditorPlatform or not USE_SDK ) then
		Updater.startApp()
	else
		sendUpdateMsg( "获取配置数据" )

		LuaBridge.setListener( "/c/channelInfoResult", Updater.onChannelInfoResult )
		LuaBridge.sendToSdk( "setVersion", SDK_VERSION )

		if timer then timer:Stop() end
		timer = Timer.New( function ()
			-- 超时
			LuaBridge.setListener( "/c/channelInfoResult", nil )
			Updater.prepareUpdate()
			timer = nil
		end, TIMEOUT, 1 )
		timer:Start()
	end
end


-- 开始app
function Updater.startApp()
	sendUpdateMsg( TIP_MSG_START )

	Tools.SendMessageCommand( NotiConst.LOADING_END, "" )

	-- 只能启动一次
	if not Updater.isWorking then return end

	Updater.isWorking = false

	local status, msg = xpcall(Main.startApp, function( ... )
		-- if __G__TRACKBACK__ then
		--     __G__TRACKBACK__(...)
		-- end
		print( ... )
		print( debug.traceback() )
	end)
	
	if not status then
		print(msg)
	end
end


function Updater.onChannelInfoResult( data )
	mChannel = data.chn or "none"
	printf( "channel:%s", mChannel )

	if timer then
		timer:Stop()
		timer = nil
	end

	LuaBridge.setListener( "/c/channelInfoResult", nil )
	Updater.prepareUpdate()
end


-- 重启更新器
function Updater.reboot()
	sendUpdateMsg( TIP_MSG_REBOOT )
	Tools.SendMessageCommand( NotiConst.REBOOT_GAME, "" )
	Main.startUpdater()
end












----- 更新器逻辑 -----
function Updater.loalLocalPatchRecord()
	local recordText = FileLoader.loadTextFromFileImm( AppConst.PatchRecordFile )
	local record = {}
	if recordText ~= "" then
		record = cjson.decode( recordText )
	end

	local localPatchRecord = {
		bid = record.bid or -1,
		pid = record.pid or 0,
		ppid = record.ppid or 0,
	}

	Updater.localPatchRecord = localPatchRecord
end


--- 重置补丁
-- 重置存档中的bid、pid
-- 删除已下载的补丁文件
function Updater.resetPatcher(tip, bid, pid)
	-- 1. 清理已下载补丁
	if Tools.ExistsDirectory( AppConst.PatchTempPath ) then
		Tools.DeleteDirectory( AppConst.PatchTempPath )
	end

	Tools.CreateDirectory( AppConst.PatchTempPath )

	-- 2. 更新存档
	local localPatchRecord = {
		bid = bid,
		pid = pid,
		ppid = pid,
	}

	Updater.localPatchRecord = localPatchRecord

	Updater.saveLocalPatchRecord()

	printf( "resetPatcher: %s", tip )
end


function Updater.saveLocalPatchRecord()
	if not Updater.localPatchRecord then return end

	local str = cjson.encode( Updater.localPatchRecord )

	Tools.WriteAllText( AppConst.PatchRecordFile, str )
end


--- 准备更新
function Updater.prepareUpdate()
	sendUpdateMsg( TIP_MSG_READY )
	-- 1. 检查本地patch_info.json
	--只在release模式下,所以很简单

	local jsonText
	xpcall( function ()
		jsonText = FileLoader.loadTextFromFileBySearchImm( AppConst.PatchFileName )
		printf( "Patch Text:%s", jsonText )
	end, function ( err )
		printError( "get %s err:%s", AppConst.PatchFileName, err )
	end )

	local patchInfo = nil
	if jsonText and jsonText ~= "" then
		patchInfo = cjson.decode(jsonText)
		Updater.patchInfo = patchInfo
	end

	if not patchInfo then
		printError("patch_info.json invalid, can't update game.")
		Updater.startApp()
		return
	end


	-- 2. 检测包版本和存档版本，判断是否需要重置补丁
	-- 安装包的bid
	local packageBid = patchInfo.B_ID
	-- 安装包的pid
	local packagePid = patchInfo.P_ID
	-- 当前当前游戏版本
	_G.GAME_VERSION = patchInfo.B_ID

	-- 检查本地存档的版本
	Updater.loalLocalPatchRecord()

	local recordBid        = Updater.localPatchRecord.bid
	local recordPid        = Updater.localPatchRecord.pid
	local recordPackagePid = Updater.localPatchRecord.ppid

	printf( "loacal bid:%s, pid:%s", recordBid, recordPid )

	local resetTip = nil

	-- 如果本地还未有存档，则重置存档
	if recordBid < 0 then
		resetTip = string.format("bid not match! package = %s, record = %s", packageBid, recordBid)

	-- 如果package中的pid比存档的pid高，则重置存档
	elseif packagePid > (recordPid or 0) then
		resetTip = string.format("package pid is higher! package = %s, record = %s", packagePid, recordPid)
	end

	if resetTip then
		Updater.resetPatcher(resetTip, packageBid, packagePid)
	end



	-- 3. 提取当前本地的pid
	local localPid = nil
	recordPid = Updater.localPatchRecord.pid
	if recordPid then
		-- 使用存档中的pid
		localPid = recordPid
	else
		-- 使用随包写到的patch_info中的pid
		localPid = patchInfo.P_ID or 0
		printError( "can't find local pid." )
	end

	Updater.localPid = localPid



	-- 4. 准备下载路径
	Tools.CreateDirectory( AppConst.PatchTempPath )
	if not Tools.ExistsDirectory( AppConst.PatchTempPath ) then
		-- 下载路径创建失败
		printError( "create download path err:%s", AppConst.PatchTempPath )
		Updater.startApp()
		return
	end

	Updater.checkNewVersion()
end


--- 检测更新
function Updater.checkNewVersion()
	sendUpdateMsg( TIP_MSG_CHECK )

	local patchInfo = Updater.patchInfo

	local patchInfoUrl = string.format("http://%s/%s/%s/%s/%s",
		patchInfo.HOST,
		patchInfo.PATCH_PATH,
		patchInfo.APP,
		patchInfo.B_ID,
		patchInfo.PATCH_INFO_FILENAME
	)
	
	printf( "patchInfoUrl: %s", patchInfoUrl )

	local function sucCallback( www )
		printf( "load remote path_info:%s", www.text )
		local remotePatchInfo = cjson.decode( www.text )

		if remotePatchInfo and remotePatchInfo ~= "" then
			Updater.onPatchInfoDownloadSuccess(remotePatchInfo)
		else
			-- patch_info错误，直接进入游戏
			printError( "can't decode path_info" )
			Updater.startApp()
		end
	end

	local function failCallback( www )
		-- 网络错误，直接进入游戏不更新
		printWarn( "can't download path_info:%s", www.error )
		sendUpdateMsg( www.error or "can't download path_info" )
		Updater.startApp()
	end


	local function timeoutCallback()
		printWarn( "can't download path_info: time out." )
		sendUpdateMsg( "启动超时" )
		Updater.startApp()
	end

	FileLoader.load( patchInfoUrl, sucCallback, failCallback, TIMEOUT, timeoutCallback )
end


function Updater.onPatchInfoDownloadSuccess(remotePatchInfo)
	if not Updater.isWorking then return end

	-- 保存patchInfo
	Updater.patchInfo = remotePatchInfo

	if DEBUG then PrintTable( remotePatchInfo, "remotePatchInfo" ) end

	-- 获取当前渠道
	local channelName = getChannel()

	printf("check Pid by channelName: %s", tostring(channelName))

	-- 根据渠道提取最新pid
	local remotePid = 0
	if remotePatchInfo.CHANNEL_INFO then
		remotePid = remotePatchInfo.CHANNEL_INFO[channelName] or 0
	end

	local localPid = Updater.localPid

	-- 获取本地大版本(无法跨大版本更新)
	local localBid = Updater.localPatchRecord.bid

	-- 验证大版本
	if localBid ~= remotePatchInfo.B_ID then
		printError( "path info mixed local:%s remote:%s", localBid, remotePatchInfo.B_ID )
		Updater.startApp()
		return
	end

	-- 验证可更新补丁
	if localPid >= remotePid then
		printWarn( "local pid(%s) bigger than remote pid(%s)", localPid, remotePid )
		Updater.startApp()
		return
	end

	-- 提取需要下载的补丁
	local patchs = {}
	for i, v in ipairs(remotePatchInfo.PATCH_LIST) do
		if v.pid > localPid and v.pid <= remotePid then
			-- 版本号比本地pid高，比配置低，需要更新
			table.insert(patchs, v)
		end
	end

	if #patchs > 0 then
		Updater.patchs = patchs
		Updater.patchIdx = 1

		Updater.downloadPatchByIndexed()
	else
		-- 不需要下载补丁
		Updater.startApp()
	end
end


--- 下载idx对应的补丁
function Updater.downloadPatchByIndexed()
	if not Updater.isWorking then return end

	local function onError( www )
		printError( "download path by index error, index:%s, msg:%s", Updater.patchIdx, www.error )
		-- 失败后进入游戏
		Updater.startApp()
	end

	local function onSuccess( www )
		-- Updater.sendUiMsg( "UPDATER_UI_MSG_DOWNLOAD_SUCCESS" )
		Updater.onPatchDownloadSuccess( www )
	end

	local function onTimeout()
		printError( "download path by index error, index:%s, msg: time out.", Updater.patchIdx )
		-- 超时后进入游戏
		Updater.startApp()
	end

	local patchInfo = Updater.patchInfo
	local patch = Updater.patchs[Updater.patchIdx]
	local patchUrl = string.format("http://%s/%s/%s/%s/%s.zip",
		patchInfo.HOST_CDN or patchInfo.HOST, -- 尝试使用CDN地址下载zip包
		patchInfo.PATCH_PATH,
		patchInfo.APP,
		patchInfo.B_ID,
		patch.pid
	)

	if DEBUG then printf("patchUrl:%s", patchUrl) end

	FileLoader.load( patchUrl, onSuccess, onError, TIMEOUT, onTimeout )

	local cur = Updater.patchIdx
	local max = #Updater.patchs

	sendUpdateMsg( string.format( TIP_MSG_UPDATE, cur, max ) )

	Tools.SendMessageCommand( NotiConst.UPDATE_PROGRESS, tostring( cur / max ) )
end


function Updater.onPatchDownloadSuccess( www )
	printf("onPatchDownloadSuccess %s", Updater.isWorking)
	if not Updater.isWorking then return end

	local patch = Updater.patchs[Updater.patchIdx]

	local zipFile = string.format( "%s%s.zip", AppConst.PatchTempPath, patch.pid )

	-- 写入临时文件
	Tools.WriteAllBytes( zipFile, www.bytes )

	-- 解压
	if not Tools.Decompress( zipFile, AppConst.PatchTempPath ) then
		printError( "decompress patch error, localPid:%s, patchIdx:%s", Updater.localPid, Updater.patchIdx )
		
		-- 删除临时文件
		Tools.DeleteFile( zipFile )

		Updater.startApp()
		return
	else
		-- 删除临时文件
		Tools.DeleteFile( zipFile )
		-- 覆盖到资源目录
		Tools.CopyDirectory( AppConst.PatchTempPath, AppConst.ReleasePathRoot, true )
	end

	-- 保存pid
	Updater.localPid = patch.pid
	Updater.localPatchRecord.pid = patch.pid
	Updater.saveLocalPatchRecord()

	if DEBUG then printf("onPatchDownloadSuccess save pid:%s", Updater.localPid) end

	-- TODO:暂时不支持reboot
	if patch.reboot then
		-- 需要重启更新器
		-- return
	end

	-- 判断补丁是否下载完毕
	if Updater.patchIdx < #Updater.patchs then 
		Updater.patchIdx = Updater.patchIdx + 1
		Updater.downloadPatchByIndexed()
	else
		Updater.reboot()
	end
end













return Updater




