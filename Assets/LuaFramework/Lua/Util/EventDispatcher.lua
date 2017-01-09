

local luaEventListener = require( "Util.LuaEventListener")

local luaEventCustom 	  = require( "Util.LuaEventCustom")
local EventListenerCustom = require( "Util.EventListenerCustom")


local EventDispatcher = class( "EventDispatcher" )

local _instacne

function EventDispatcher.getInstance( )
	if not _instacne then
		_instacne = EventDispatcher.New()
	end
	return _instacne 
end



function EventDispatcher:ctor()
	self._listeners = {}
end

function EventDispatcher:getListenerId( event )
	local _type = event:getType()
	local ret
	if _type == luaEventListener.Type.CUSTOM then
		ret = event:getEventName()
	end

	return ret
end

function EventDispatcher:getListeners( listenerid )
	return self._listeners[ listenerid ] or {}
end



-- 添加一个eventListener
function EventDispatcher:addEventListener( listener )
	if not self._listeners then
		self._listeners = {}
	end

	-- 检查回调是否有效
	if not listener:checkAvailable() then return end
	listener:setRegistered( true )
	listener:setEnabled( true )
	listener:setPaused( false )
	
	local listenerid = listener:getListenerID()
	local listeners = self._listeners[ listenerid ]
	if not listeners then
		listeners = {}
		self._listeners[ listenerid ] = listeners
	end

	table.insert( listeners, listener )
end


function EventDispatcher:addCustomEventListener( eventName, callback )
	local listener = EventListenerCustom.New( eventName, callback )
	self:addEventListener( listener )
end



-- 删除一个eventListener
function EventDispatcher:removeEventListener( listener )
	if not self._listeners then return end 
	local listenerid = listener:getListenerID()
	local listeners = self:getListeners( listenerid )
	for k, v in pairs( listeners )do
		if v == listener then
			table.remove( listeners, k )
			break
		end
	end
end



function EventDispatcher:dispatchEvent( event )
	-- 1.创建一个listener回调方法
	local onEvent = function( listener )
		-- print( " --------- > EventDispatcher.dispatchEvent")
		listener:onEvent( event )
		return event:isStoped()
	end

	-- 2.找到对应的所有的listeners
	local listenerid = self:getListenerId( event )
	local listeners = self:getListeners( listenerid)

	self:dispatchEventToListeners( listeners, onEvent)
end


function EventDispatcher:dispatchCustomEvent( eventName, userData )
	local event = luaEventCustom.New( eventName )
	event:setUserData( userData )
	self:dispatchEvent( event )
end


function EventDispatcher:dispatchEventToListeners( listeners, callback)
	assert( listeners )
	assert( callback )
	
	if #listeners <= 0 then return end

	local shouldStopPropagation = false
	for k, l in ipairs( listeners ) do
		-- print( "l:isEnabled ->", l:isEnabled() )
		-- print( "l:isPaused ->", l:isPaused() )
		-- print( "l:isRegistered ->", l:isRegistered() )
		
		if l:isEnabled() and not l:isPaused() and l:isRegistered() and callback( l ) then
			shouldStopPropagation = true
			break
		end
	end

	-- 进行其他消息的转发
	-- if not shouldStopPropagation then

	-- end

end


return EventDispatcher