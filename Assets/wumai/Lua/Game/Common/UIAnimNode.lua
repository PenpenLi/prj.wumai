local super = LuaObject
local M = class( "UIAnimNode", super )

M.layer = LayerMask.NameToLayer("UIRenderTexture")

M.MODE_NORMAL = 1
M.MODE_DRAG = 2

function M:ctor(node, modelId, actionId, mode)
	super.ctor(self, node.gameObject)

	local image = node:GetComponent("RawImage")
	local camera = node:FindChild("Node/Camera"):GetComponent("Camera")

	local texture = RenderTexture.New(512, 512, 16)
	camera.targetTexture = texture
	image.texture = texture

	local shadowTransfrom = node:FindChild("Node/Shadow")
	if shadowTransfrom then
		self.shadow = shadowTransfrom.gameObject
	end
	self.modelNode = node:FindChild("Node")
	self.modelId = 0
	self.defaultRotate = nil

	if modelId ~= nil and modelId > 0 then
		self:setRole(modelId, actionId)
	end

	mode = mode or M.MODE_DRAG

	if mode == M.MODE_NORMAL then
		local image = node:GetComponent("RawImage")
		image.raycastTarget = false
	else
		self:addDragListener( node.gameObject, handler(self, self.dragImage) )
		UIEventListener.Get( node.gameObject ).onClick = handler(self, self.onClick)
	end
end


function M:clean()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end

	super.clean(self)
end


function M:setDefaultRotation( x, y, z )
	self.defaultRotate = Quaternion.Euler( x, y, z )
	if self.baseObj then
		self.baseObj.transform.localRotation = self.defaultRotate
	end
end


function M:onCreateObj(obj)

	if self.baseObj then
		GameObject.Destroy(self.baseObj)
		self.baseObj = nil
	end

	self.baseObj = GameObject.Instantiate(obj).gameObject
	self.baseObj.transform:SetParent(self.modelNode)

	local scale = self.data.uiScale
	local rotate = self.data.uiRotate
	local sScale = 0.5
	self.baseObj.transform.localScale = Vector3.New(scale, scale, scale)
	self.baseObj.transform.localPosition = Vector3.zero
	self.baseObj.transform.localRotation = self.defaultRotate or Quaternion.Euler( 0, rotate, 0 )
	if self.shadow then
		self.shadow.transform.localScale = Vector3.New(sScale, sScale, 1)
	end

	self.animator = self.baseObj:GetComponent("Animator")
	self:setAction(self.actionId)
	self.baseObj.layer = M.layer
	
	-- local children = self.baseObj:GetComponentsInChildren(typeof(Transform), true)
	-- local childCount = children.Length
	-- for i = 0, childCount-1 do
	-- 	local child = children[i]
	-- 	child.gameObject.layer = M.layer
	-- end

	self:setTransformLayer(self.baseObj.transform, M.layer)
	-- self.baseObj.transform

	if self.timer then
		self.timer:Stop()
		self.timer:Reset(handler(self, self.playRandomAnim), self.rndTime, -1)
		self.timer:Start()
	end
end


function M:setTransformLayer(transform, layer)
	-- local children = transform:GetComponentsInChildren(typeof(Transform), true)
	-- local childCount = children.Length

	local childCount = transform.childCount
	for i = 0, childCount-1 do
		local child = transform:GetChild(i)
		child.gameObject.layer = layer
		self:setTransformLayer(child, layer)
	end
end

function M:setRole(modelId, actionId)
	if self.modelId ~= modelId then
		self.modelId = modelId

		local data = ModuleCfg:getRoleDb(modelId)
		self.data = data
		self.actionId = actionId or CREATURE_ACTION.Idle
		MgrRes:loadPrefab(data.prefab, nil, handler(self, self.onCreateObj))
	end
end


function M:setAction(actionId)
	-- if self.actionId == actionId then return end
	if not self.animator then return end

	self.actionId = actionId
	if self:getVisible() then
		self.animator:SetInteger("Action", actionId)
	end
end


function M:OnEnable()
	if self.animator and self.actionId then
		self.animator:SetInteger("Action", self.actionId)
	end
end


function M:dragImage(luaObj, go, eventData)
	self.baseObj.transform:Rotate(Vector3.New(0, -eventData.delta.x, 0))
	self.bDrag = true
end


function M:onClick(luaObj, go, eventData)
	if self.bDrag then
		self.bDrag = false
		return
	end

	if self.clickCallback then
		self.clickCallback(self.data)
	end
end


function M:addDragListener( gameObject, func )
	if func and type( func ) == "function" then
		UIEventListener.Get( gameObject ).onDrag  = function( go, point ) func( self, go, point ) end
	end
end


function M:addClickListener(func)
	self.clickCallback = func
end


function M:showRandomAnim( rndTime, ...)
	self.rndTime = rndTime
	self.actions = {...}
	
	if self.timer then
		self.timer:Stop()
		self.timer:Reset(handler(self, self.playRandomAnim), rndTime, -1)
	else
		self.timer = Timer.New(handler(self, self.playRandomAnim), rndTime, -1)
	end
	
	self.timer:Start()
end


function M:playRandomAnim()
	self:setAction(self.actions[math.random( 1, #self.actions )])
end


function M:showShadow()
	self.shadow:SetActive(true)
end



return M