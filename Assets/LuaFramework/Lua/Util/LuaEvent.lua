local M = class( "LuaEvent" )



function M:ctor( _type )
	self._type = _type
	self._isStopped = false
end


function M:isStoped()
	return self._isStopped
end

function M:StopEvent()
	self._isStopped = true
end


function M:getType()
	return self._type
end



function M:setData( data )
	self.eventData = data
end

function M:getData()
	return self.eventData
end


return M