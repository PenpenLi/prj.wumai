
--[[

		面板
		待扩展（TODO）
]]

local super = require( "Util.LuaWidget" )
local M = class( "LuaPanel", super )



------ 静态变量 -------------------

-- panel类型
M.panelStyle = MgrPanel.STYLE_COMMON

-- 所处layer
M.panelLayer = MgrPanel.LAYER_UI






function M:onCreateCompleted( context )
	-- 放在onCreateCompleted前头原因之一：onCreateCompleted里面若再弹面板，反而放在了更前面
	MgrPanel:addPanel( self )

	super.onCreateCompleted( self, context )
end


function M:setContext( context )
	self.arguments = context
	if self:isRegisterd() then
		self:onContextChange( context )
	end
end


-- context 改变回调
function M:onContextChange( context )
end



function M:showTop()
	self:show()
	MgrPanel:setTop(self)
end


function M:close()
	MgrPanel:closePanel(self)
end



return M