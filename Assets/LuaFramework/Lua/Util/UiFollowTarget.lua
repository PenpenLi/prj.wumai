--[[
	ui对象跟随object目标
]]


local M = class( "UiFollowTarget" )


function M:ctor( uiObj, gameCamera, uiCamera)

	self.target 	= nil -- 跟随的目标
	self.uiObject 	= uiObj -- ui对象

	self.gameCamera = nil -- 游戏主摄像头
	self.uiCamera 	= nil	 -- ui摄像头

	self:setCamera( gameCamera, uiCamera)

	self.offsetPos = Vector3.zero -- 便宜坐标 如:需要将UI显示在 目标的上方多少像素

	self.mIsVisible = true   -- ui是否可见
	self.isInitFinish = false -- 初始化是否完成
end




function M:SetVisible( val )
	self.mIsVisible = val
end




-- 每帧更新 由ui对象的LateUpdate方法调用
function M:LateUpdate()
	-- 没有初始化就不用更新了
	if not self.isInitFinish then return end
	-- 如果不可见也不用更新了
	if not self.target.transform then return end

	local pos = self.gameCamera:WorldToViewportPoint( self.target.transform.position)
	
	local isVisible = true
	if (pos.z > 0 and pos.x > 0 and pos.x < 1 and pos.y > 0 and pos.y < 1 ) then
		isVisible = true
	else
		isVisible = false
	end


	if self.mIsVisible ~= isVisible then
		self:SetVisible( isVisible )
	end

	if isVisible then
		self.uiObject.transform.position = self.uiCamera:ViewportToWorldPoint( pos )

		pos = self.uiObject:getLocalPosition():Add( self.offsetPos )
		pos.x = math.ceil( pos.x )
		pos.y = math.ceil( pos.y )
		pos.z = 0

		self.uiObject:setLocalPosition( pos )
	else
		-- 不可见就移除到屏幕外面去
		self.uiObject:setLocalPosition( Screen.width * 2, 0, 0)
	end
end




-- 获取当前显示的屏幕坐标
function M:getViewPos()
	if not self.isInitFinish then return Vector3.zero end
	local pos = self.gameCamera:WorldToViewportPoint( self.target.transform.position)
	pos.z = 0
	return pos
end





function M:setTarget( target, offset )
	self.target 	= target
	self.offsetPos  = offset or Vector3.zero

	if self.gameCamera and self.uiCamera then
		self.isInitFinish = true
	end
end

function M:setOffsetPos(offset)
	self.offsetPos  = offset or Vector3.zero
end



function M:setCamera( gameCamera, uiCamera )
	self.gameCamera = gameCamera:getCamera(); -- 游戏主摄像头
	self.uiCamera 	= uiCamera:by( "LuaCamera")	 -- ui摄像头

	if self.target and self.uiObject then
		-- 设置了主摄像头 则表示已经完成了初始化
		self.isInitFinish = true
	end
end


return M