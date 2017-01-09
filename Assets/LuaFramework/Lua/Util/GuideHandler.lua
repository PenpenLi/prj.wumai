--[[
	新手引导辅助类，超类必须是MsgHandler的子类
]]

local M = class( "GuideHandler" )




function M:ctor()
	assert( self.addMsgListeners )

	self.uiCallbacks = {}

	self:addMsgListeners({
		{ 'MSG_GUIDE_GET_UI',              handler( self, self.onGuideGetUi ) }
	})

	self.bIn3DCamera = false
end



function M:onGuideGetUi( e )
	local data = e:getUserData()
	local uiName = data.uiName

	local ui = self:getChild( uiName )

	if ui then
		-- 非按钮需要注册事件（非必须项）
		local callback = self.uiCallbacks[uiName]
		sendMsg( "MSG_GUIDE_SET_UI", { ui = ui, uiName = uiName, callback = callback, b3D = self.bIn3DCamera } )
	end
end


function M:registerUiCallback( uiName, callback )
	self.uiCallbacks[uiName] = callback
end



return M