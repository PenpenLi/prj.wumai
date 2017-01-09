local luaEventListener = require( "Util.LuaEventListener")

local EventListenerCustom = class( "EventListenerCustom", luaEventListener )


function EventListenerCustom:ctor( _listenerId, handler )
	luaEventListener.ctor( self, luaEventListener.Type.CUSTOM, _listenerId, handler )
end




function EventListenerCustom:onEvent( e )
	if self._onEvent and type( self._onEvent ) == "function" then
		self._onEvent( e )
	end
end


return EventListenerCustom