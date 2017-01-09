local EventListenerCustom = require( "Util.EventListenerCustom")
local EventDispatcher = require("Util.EventDispatcher")

local MsgHandler = class( "MsgHandler" )

--- 开始处理Msg
function MsgHandler:startProcMsg()

	-- 没有监听器配置，可以理解为不需要监听器
	local conf = self._listenerConf
	if not conf then return end

	local listeners = self._msgListeners
	
	-- 已经有监听器了，不需要重复添加
	if listeners then return end

	local dispatcher = EventDispatcher.getInstance()

	listeners = {}
	local listenerid, handler, listener
	for k, v in ipairs( conf ) do
		listenerid, handler = v[ 1 ], v[ 2 ]
		listener = EventListenerCustom.New( listenerid, handler )
		dispatcher:addEventListener( listener )
		listeners[ #listeners + 1] = listener
	end

	self._msgListeners = listeners
end




--- 停止处理Msg
function MsgHandler:stopProcMsg()
	local listeners = self._msgListeners
	if not listeners then return end
	
	local dispatcher = EventDispatcher.getInstance()
	for k, listener in ipairs( listeners ) do
		dispatcher:removeEventListener( listener )
	end
	self._msgListeners = nil
end




--- 设置msg监听器
-- @param listenerConf { { msgName, msgHandler }, { msgName, msgHandler } }
function MsgHandler:setMsgListeners(listenerConf)
	self._listenerConf = listenerConf
end


--- 设置msg监听器
-- @param listenerConf { { msgName, msgHandler }, { msgName, msgHandler } }
function MsgHandler:addMsgListeners(listenerConf)
	local listeners = self._listenerConf or {}
	for _, listener in pairs( listenerConf ) do
		table.insert( listeners, listener )
	end

	self._listenerConf = listeners
end



return MsgHandler