--[[
	File Desc: 基础UI控件
	只能通过预设文件创建

	若非不得已，子类尽量不要重写构造函数 (ctor)，用onCreate替代
]]



local super = LuaObject
local M = class( "LuaWidget", super )



-- 提供子类重写
M.prefabName = nil


function M:ctor( arguments, callback )
	assert( self.prefabName, string.format( "can't find prefabName by class:%s", self.__cname ) )
	super.ctor( self, self.prefabName, arguments, callback )
end


function M:onCreateCompleted( context )
	super.onCreateCompleted( self, context )
	self:buildUi( context )
end


-- 虚方法
function M:buildUi( context ) end


return M