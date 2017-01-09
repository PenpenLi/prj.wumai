
--[[

		面板
		待扩展（TODO）
]]

local super = require( "Util.LuaObject")
local MsgHandler   = require( "Util.MsgHandler" )
local M = class( "LuaPanelTransition", super, MsgHandler)


function M:ctor(...)

	--异步加载数据，以后都这么做
	--凡是涉及到数据操作的，面板都需要封装数据，方便异步加载处理
	self.hideFlag = false




	super.ctor(self, ...)



	self:setMsgListeners({
        { "MSG_SCENETRANSITION",   handler( self, self.onProgress)},
        { "MSG_SCENETRANSITION_DONE",   handler( self, self.onProgressDone)},
    })
end

function M:onCreateCompleted(obj)
	super.onCreateCompleted(self,obj)

	--先放入canvas，但不受MgrPanel管理
	self:addTo( MgrPanel:getCanvas() )
	if self.hideFlag then
		self:hide()
	else
		self:show()
	end
end

function M:show()
	self.hideFlag = false

	--settop
	if self:isRegisterd() then
		self:setSiblingIndex(self:getParent():getChildCount())
		super.show(self)

		self:startProcMsg()
	end

end


function M:hide()
	self.hideFlag = true
	if self:isRegisterd() then
		super.hide(self)

		self:stopProcMsg()
	end

end



function M:onProgress(event)
 

end

function M:onProgressDone()


end





return M