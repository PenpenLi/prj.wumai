local luaEventCustom        = require( "Util.LuaEventCustom")
local EventListenerCustom   = require( "Util.EventListenerCustom")

local EventProtocol         = class( "EventProtocol" )

local DEBUG = false 

function EventProtocol:ctor()
	self.listeners_ = {}
    self.nextListenerHandleIndex_ = 0
end


function EventProtocol:addEventListener(eventName, callback, tag)
	assert(type(eventName) == "string" and eventName ~= "")
	eventName = string.upper(eventName)

	if self.listeners_[eventName] == nil then
        self.listeners_[eventName] = {}
    end
    local ttag = type(tag)
    if ttag == "table" or ttag == "userdata" then
        -- PRINT_DEPRECATED("EventProtocol:addEventListener(eventName, listener, target) is deprecated, please use EventProtocol:addEventListener(eventName, handler(target, listener), tag)")
        callback = handler(tag, callback)
        tag = ""
    end

    local listener = EventListenerCustom.New( eventName, callback )
    -- 检查回调是否有效
    if not listener:checkAvailable() then 
        printInfo( "EventProtocol:addEventListener(eventName, listener, target) checkAvailable is invalid!!")
        return 
    end
    
    listener:setRegistered( true )
    listener:setEnabled( true )
    listener:setPaused( false )

	self.nextListenerHandleIndex_ = self.nextListenerHandleIndex_ + 1
    local handle = tostring(self.nextListenerHandleIndex_)

    tag = tag or ""
    self.listeners_[eventName][handle] = {listener, tag }


    if DEBUG then
        printInfo("%s [EventProtocol] addEventListener() - event: %s, handle: %s, tag: %s", tostring(self), eventName, handle, tostring(tag))
    end
    return handle
end



function EventProtocol:getListeners( listenerid )
    return self.listeners_[listenerid] or {}
end




function EventProtocol:dispatchEvent(eventName, userData )
	assert(type(eventName) == "string" and eventName ~= "")
    eventName = string.upper(eventName)

    if DEBUG then
        printInfo("%s [EventProtocol] dispatchEvent() - event %s", tostring(self), eventName)
    end

    if self.listeners_[eventName] == nil then 
        printInfo( string.format("EventProtocol:dispatchEvent(eventName, userData) don't have listeners with [%s]!!", eventName))
        return 
    end
    
    userData = userData or {}
    userData.target = self

    local event = luaEventCustom.New( eventName )
    event:setUserData( userData )
    
    -- 1.创建一个listener回调方法
    local _onEvent = function( lData )
        local listener = lData[ 1 ]
        event.tag = lData[ 2 ]
        listener:onEvent( event )
        return event:isStoped()
    end

    local listeners = self:getListeners( eventName )
    self:dispatchEventToListeners( listeners, _onEvent)
    return self
end





function EventProtocol:dispatchEventToListeners( listeners, callback)
    assert( listeners )
    assert( callback )
    

    local shouldStopPropagation = false
    for k, lData in pairs( listeners ) do
        local l = lData[ 1 ]
        -- print( "l:isEnabled ->", l:isEnabled() )
        -- print( "l:isPaused ->", l:isPaused() )
        -- print( "l:isRegistered ->", l:isRegistered() )
        
        if l:isEnabled() and not l:isPaused() and l:isRegistered() and callback( lData ) then
            shouldStopPropagation = true
            break
        end
    end

    -- 进行其他消息的转发
    -- if not shouldStopPropagation then

    -- end
end





function EventProtocol:removeEventListener(handleToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        for handle, _ in pairs(listenersForEvent) do
            if handle == handleToRemove then
                listenersForEvent[handle] = nil
                if DEBUG then
                    printInfo("%s [EventProtocol] removeEventListener() - remove listener [%s] for event %s", tostring(self), handle, eventName)
                end
                return self
            end
        end
    end

    return self
end



function EventProtocol:removeEventListenersByTag(tagToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        for handle, listener in pairs(listenersForEvent) do
            if listener[2] == tagToRemove then
                listenersForEvent[handle] = nil
                if DEBUG then
                    printInfo("%s [EventProtocol] removeEventListener() - remove listener [%s] for event %s", tostring(self), handle, eventName)
                end
            end
        end
    end

    return self
end


function EventProtocol:removeEventListenersByEvent(eventName)
    self.listeners_[string.upper(eventName)] = nil
    if DEBUG then
        printInfo("%s [EventProtocol] removeAllEventListenersForEvent() - remove all listeners for event %s", tostring(self), eventName)
    end
    return self
end


function EventProtocol:removeAllEventListeners()
    self.listeners_ = {}
    if DEBUG then
        printInfo("%s [EventProtocol] removeAllEventListeners() - remove all listeners", tostring(self))
    end
    return self
end


function EventProtocol:hasEventListener(eventName)
    eventName = string.upper(tostring(eventName))
    local t = self.listeners_[eventName]
    if not t then
        return false
    end
    for _, __ in pairs(t) do
        return true
    end
    return false
end



return EventProtocol