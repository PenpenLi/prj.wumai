--- 摄像机

local super = require( "Util.LuaObject")

local M = class( "LuaCamera", super )

M.instance = nil




M.CAMERA_HEIGHT = 4.5
M.CAMERA_DISTANCE = 5.5




function M:ctor( )

	--参数声明(请保持良好习惯)
	self.target = nil
	self.distance = 0
	self.height = 0
	self.heightDamping = 0
	self.rotationDamping = 0
	self.offsetY = 0
	self.isCanRotate = false


	


	super.ctor( self )
	

	


end


--创建完成回掉，支持异步加载
function M:onCreateCompleted(obj)
	super.onCreateCompleted(self, obj)

	self:reset()


	--绑定camera
	self.camera = self:addComponent(typeof(Camera))
	self.camera.depth = -1
	-- self:setDepth( -1, "Camera" )
	-- self.tweenPosition = self.gameObject:AddComponent("TweenPosition")
	-- self.tweenPosition.enabled = false
	self.shakeTimer = nil
	-- self.gameObject:AddComponent("GUILayer")
	-- self.gameObject:AddComponent("FlareLayer")

	--镜头抖动（TODO）


end


function M:reset()

	self.target = nil
	self.distance = M.CAMERA_HEIGHT
	self.height = M.CAMERA_DISTANCE
	self.heightDamping = 20
	self.rotationDamping = 3
	self.offsetY = 0
	self.isCanRotate = false

end


function M:resetOffY(offsetY)
	self.offsetY = tonumber(offsetY) or 0.5;
end

function M:resetDH(distance,height)
	distance = distance or defDistance;
	height = height or defHeight;
	if distance == 0 or height == 0 then
		return;
	end

	self.distance = distance;
	self.height = height;
end


function M:setBgColor(r,g,b,a)
	self.camera.backgroundColor = Color.New(r, g, b, a);
end


function M:shake(strength)
	-- if self.shakeTimer then
	-- 	return
	-- end
	-- local oldPos = self.transform.position

	-- self.tweenPosition.method = UITweener.Method.EaseInOut
	-- self.tweenPosition.style = UITweener.Style.PingPong
	-- self.tweenPosition.duration = 0.03
	-- local strengthVector3 = Vector3.New(strength, strength, strength)
	-- self.tweenPosition.from = oldPos:Sub(strengthVector3)
	-- self.tweenPosition.from.y = 0
	-- self.tweenPosition.to = oldPos:Add(strengthVector3)
	-- self.tweenPosition.to.y = 0
	-- self.tweenPosition.enabled = true;
	-- self.shakeTimer = Timer.New( function() self:shakeDown(oldPos) end, 0.2, 1)
	-- self.shakeTimer:Start()
end

function M:shakeDown(oldPos)
	-- self.tweenPosition.enabled = false
	-- self.shakeTimer:Stop()
	-- self.shakeTimer = nil
	-- self.transform.position = oldPos
end

function M:setTarget(target)
	self.target = target
end

function M:setLuaTarget(luaObject)
	self.target = luaObject.transform
end

function M:getTarget()
	return self.target
end

-- function M:Update()
-- end

function M:LateUpdate()
	-- Early out if we don't have a target
	if not self.target then
		return
	end
	local target = self.target
	local distance = self.distance
	local height = self.height
	local transform = self.transform
	local heightDamping = self.heightDamping
	local rotationDamping = self.rotationDamping
	local isCanRotate = self.isCanRotate

	-- Calculate the current rotation angles
	local wantedRotationAngle = target.eulerAngles.y
	local wantedHeight = target.position.y + height

	local currentRotationAngle = transform.eulerAngles.y
	local currentHeight = transform.position.y

	if math.abs (wantedRotationAngle - currentRotationAngle) < 160 then
		-- Damp the rotation around the y-axis
		currentRotationAngle = Mathf.LerpAngle (currentRotationAngle, wantedRotationAngle, rotationDamping * Time.deltaTime)
	end

	-- Damp the height
	-- print( currentHeight, wantedHeight, heightDamping)
	currentHeight = Mathf.Lerp (currentHeight, wantedHeight, heightDamping * Time.deltaTime)

	-- Convert the angle into a rotation
	currentRotation = Quaternion.Euler (0, currentRotationAngle, 0)

	-- Set the position of the camera on the x-z plane to:
	-- distance meters behind the target
	if isCanRotate then
		transform.position = target.position
		transform.position:Sub(Vector3.__mul(Vector3.__mul(currentRotation, Vector3.forward), distance))
		-- transform.position -= currentRotation * Vector3.forward * distance;
	else
		local newPos = target.position:Clone()
		newPos.y = newPos.y - distance
		newPos.z = newPos.z - distance
		--newPos.x -= 5
		transform.position = newPos
		-- print("transform.position", transform.position.x, transform.position.y, transform.position.z)
		-- print("newPos", newPos.x, newPos.y, newPos.z)
	end

	-- Set the height of the camera
	local pos = transform.position:Clone()
	-- print("currentHeight", currentHeight, Time.deltaTime)
	pos.y = currentHeight
	transform.position = pos

	-- Always look at the target
	if not self.shakeTimer then
		local tPos = target.position:Clone();
		tPos.y = tPos.y + self.offsetY;
		transform:LookAt (tPos);
	end

end

-- function M:FixedUpdate()
-- end

function M:clean()

	if self.shakeTimer then
		self.shakeTimer:Stop()
		self.shakeTimer = nil
	end

end


return M
