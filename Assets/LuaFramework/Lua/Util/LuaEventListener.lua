-- 侦听类的基类

local M = class( "LuaEventListener" )

M.Type = {}

M.Type.UNKNOWN = 0
M.Type.CUSTOM  = 1


function M:ctor( _type, _listenerId, handler )
	self._type = _type
	self._listenerId = _listenerId
	self._onEvent = handler

	self._isRegistered = false
	self._paused = true
	self._isEnabled = true
end

function M:setEnabled( enabled )
	self._isEnabled = enabled
end


function M:isEnabled()
	return self._isEnabled
end


function M:setPaused( paused )
	self._paused = paused
end

function M:isPaused()
	return self._paused
end

function M:setRegistered( registered )
	self._isRegistered = registered
end

function M:isRegistered()
	return self._isRegistered
end

function M:getType()
	return self._type
end

function M:getListenerID()
	return self._listenerId
end

function M:checkAvailable()
	return self._onEvent ~= nil
end

return M