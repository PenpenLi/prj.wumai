--[[
	本类是从mgrSDK脱离出来的通信桥类，
	之所以要独立封装是因为updater中需要获取渠道信息，故而和SDK的通信会提前到更新器中。
--]]

local cjson = require("cjson")
local M = {}


local PLATFORM_EDITOR = Tools.isEditorPlatform


local mListeners = {}


local function receiveFromSdk( json )
	local data = cjson.decode( json )
	if data then
		local cmd = data.cmd
		local param = data.data
		
		if mListeners[cmd] then
			mListeners[cmd]( param )
		else
			print( "LuaBridge:can't find listener with cmd[%s].", tostring(cmd) )
		end
	else
		print( "LuaBridge:can't decode json[%s].", tostring(json) )
	end
end


if not PLATFORM_EDITOR then
	local bridge = GameObject.Find(ULNativeBridge.NAME)
	if not bridge then
	    bridge = GameObject.New(ULNativeBridge.NAME)
	    bridge:AddComponent(typeof(ULNativeBridge))
	end
    
	ULNativeBridge.Init( receiveFromSdk )
end





function M.setListener( cmd, listener )
	if cmd then
		mListeners[cmd] = listener
	end
end


function M.sendToSdk( cmd, data )
	local json = {
		cmd = cmd,
		data = data
	}

	local jsonStr = cjson.encode( json )

	if not PLATFORM_EDITOR then
		ULNativeBridge.SendToSdk( jsonStr )
	else
		-- print( "send to sdk ", jsonStr )
	end
end








return M

