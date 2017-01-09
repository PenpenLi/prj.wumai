
local LuaEventListener = require( "Util.LuaEventListener")
local LuaEvent = require( "Util.LuaEvent")
local M = class( "LuaEventCustom", LuaEvent )



function M:ctor( eventName )
	LuaEvent.ctor( self, LuaEventListener.Type.CUSTOM )
	self.eventName = eventName
end

function M:setUserData( userData )
	self.userData = userData
end



function M:getUserData()
	return self.userData
end



function M:getEventName()
	return self.eventName
end





return M