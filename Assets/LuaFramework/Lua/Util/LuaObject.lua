local M = class( "LuaObject" )
local DEBUG = false





--每个luaobj唯一hashcode，能在多个场景应用（回调、 安全获取对象引用）
M.luaHashCodeIdx = 1

--每个创建的lua对象必须在这里注册，不然就属于黑户
-- M.luaObjTable = {}


-- lua类初始化函数
-- ctor<prefab>
-- prefab is abName or unityGameObject
-- arguments 参数列表
function M:ctor( prefab, arguments, callback )
	-- gameObject, transform 在绑定脚本后在c#中自动赋值 userdata

	--对象名
	self.abName = nil
	--资源名
	self.resName = nil
	self.luaBehaviour = nil

	self.gameObject = nil
	self.transform 	= nil
	self.luaHashCode = nil
	self.registered = false

	self.onCreateCompletedCallback = callback

	-- 参数列表，由于是异步加载，参数列表需要保存在某个地方
	self.arguments = arguments or {}

	if not prefab then
		--这里理解成创建一个空的GameObject
		local obj = GameObject.New()
		
		self:init( obj )
		return
	end

	if type( prefab ) == "string" then
		--这里需要创建
		self:loadUnitGameObject( prefab )
	else
		self:init( prefab )
	end
end


function M:init( obj )
	--在有unity GameObject 的前提下，此类才有存在的意义
	self:register()
	self.luaBehaviour = Util.AddLuaScript( obj, self )

	self:onCreateCompleted( self.arguments )

	if self.onCreateCompletedCallback then
		self.onCreateCompletedCallback( self )
	end
end


--unityGameObject创建完成回调
function M:onCreateCompleted( arguments )
end



function M:setOnCreateCompletedCallback( callback )
	self.onCreateCompletedCallback = callback
end







--在这里一次性绑定unityobject
--一个luatable+成功创建的unityGameObject才能叫luaobj（生命周期依赖unity GameObject）

function M:loadUnitGameObject( abName )
	--记录key名（TODO，放在lua层再修改
	self.abName = abName
	self.resName = MgrRes:loadPrefab(abName, nil, handler(self, self.onCreateUnityGameObject))
end


function M:onCreateUnityGameObject(obj)
	--这里是异步的过程（可以改成同步）。
	--如果创建失败不会调用此函数，直接会弹出异常，理论上会泄露（将resourcemanager搬到lua这一层再做处理）(TODO)
	if self.bDisposed then
		if self.abName then
			MgrRes:putPrefab(self.abName)
			self.abName = nil
		end
	else
		self:init(Object.Instantiate(obj))
	end
end




function M:setHashCode()
	if self.luaHashCode then
		return self.luaHashCode
	end
	M.luaHashCodeIdx = M.luaHashCodeIdx + 1
	self.luaHashCode = M.luaHashCodeIdx
	return self.luaHashCode
end

function M:getHashCode()
	return self.luaHashCode
end


--obj诞生了第一件事就是上户
function M:register()
	-- M.luaObjTable[self:setHashCode()] = self
	self.registered = true
end


--注销户口
function M:unregister()
	-- M.luaObjTable[self:getHashCode()] = nil
	self.registered = false
end


function M:isRegisterd()
	return self.registered
end


function M:getResName()
	return self.resName
end


function M:getAbName()
	return self.abName

end








-------------------- unit3d 生命周期-------------------
-- --启动事件--
function M:Awake()
	if DEBUG then printWarn('LuaObject:Awake--->>>') end
end


-- 启动事件--
function M:Start()
	if DEBUG then printWarn('LuaObject:Start--->>>') end
end



function M:OnDisable()
end


function M:OnEnable()
end


--销毁--
function M:OnDestroy()

	if DEBUG then printWarn('LuaObject:OnDestroy--->>>') end

	if self.abName then
		printWarn("you must put resource[%s] back to manager in class[%s]", self.abName, self.__cname)
		MgrRes:putPrefab(self.abName)
		self.abName = nil
	end

	-- 这里加一个，是因为并非所有lua对象都需要dispose，但是状态(最好)还是需要被记录
	self.bDisposed = true

	self:clean()
end


function M:clean()
	
	self.gameObject = nil
	self.transform = nil

	self:unregister()
end


-----------------------------------------------------
-- 扩展
-----------------------------------------------------


function M:getVisible()
	return self.gameObject.activeInHierarchy
end



function M:setVisible( _visible )
	--异步加载,做非空判断
	if self.gameObject then
		self.gameObject:SetActive( _visible )
	end
end


-- 显示当前对象
function M:show()
	self:setVisible( true )
	return self
end


-- 隐藏当前对象
function M:hide()
	self:setVisible( false )
	return self
end


function M:setLocalScale( x, y, z )
	if y and z then
		self.transform.localScale = Vector3( x, y, z )
	else
		self.transform.localScale = x
	end

	return self
end


function M:getLocalScale()
	return self.transform.localScale
end


function M:setPosition( x, y, z )
	if y and z then
		self.transform.position = Vector3( x, y, z )
	else
		self.transform.position = x
	end

	return self
end


function M:getPosition()
	return self.transform.position
end


function M:setLocalPosition( x, y, z )
	if y and z then
		self.transform.localPosition = Vector3( x, y, z )
	else
		self.transform.localPosition = x
	end

	return self
end


function M:getLocalPosition()
	return self.transform.localPosition
end


function M:setLocalRotation( x, y, z )
	if y and z then
		self.transform.localRotation = Quaternion.Euler( x, y, z )
	else
		self.transform.localRotation = x
	end

	return self
end


function M:getLocalRotation()
	return self.transform.localRotation
end


-- 添加一个 继承自viewbase的对象( table )
function M:setName( name )
	self.gameObject.name = name
	return self
end


function M:setSiblingIndex(idx)
	if self.transform then
		self.transform:SetSiblingIndex(idx)
	end
end

function M:addChild( child )
	child:setParent( self )
	return self
end


function M:addTo( parent )
	return self:setParent( parent )
end


function M:setParent( parent )
	self.transform:SetParent( parent.transform, false )
	return self
end

function M:getChildCount()
	return self.transform.childCount
end

function M:getParent()
	local parent = self.transform.parent
	return self:_checkAndBind( parent )
end


function M:_checkAndBind( child )
	local gameObject = child.gameObject
	local component = gameObject:GetComponent( "LuaBehaviour" )
	local luaScript = nil
	if component then
		luaScript = component:getLuaScript()
		if not luaScript then
			printError( "can't find LuaBehaviour script." )
		end
	else
		-- 这里需要保证是同步的
		luaScript = M.New(gameObject)
	end
	return luaScript
end


--@return Lua Object
function M:getChild( name )
	local child = self:findChild( name )
	if not child then return nil end
	return self:_checkAndBind( child )
end


function M:getChildren()
	local children = {}

	local childCount = self.transform.childCount
	for k = 1, childCount do
		local child = self.transform:GetChild( k - 1)
	    if child then
	        local luaScript = self:_checkAndBind( child )
	        table.insert( children, luaScript)
	    end
	end

    return children
end


--@return UnityEngine.GameObject
function M:findChild( name )
	return self.transform:FindChild( name )
end


function M:changeRenderSort( order )
	Tools.ChangeRendererSort( self.transform, order )
	return self
end


function M:setShader( shaderName )
	local shader = UnityEngine.Shader.Find( shaderName )
	if shader then
		Tools.setShaderInChildren( self.transform, shader )
	else
		printWarn( "can't find shader by name %s", shaderName )
	end
end


-- 由于click功能在这里，故音效也只能放这里比较合适
local CLICK_SOUND_FILE = nil
function M.setDefaultClickSound(file)
	CLICK_SOUND_FILE = file
end


function M:addClickListener(func)
	if func and type( func ) == "function" then
		self.luaBehaviour:AddClick(self.gameObject, function( go )
			func( go )
			if CLICK_SOUND_FILE then
				AudioPlayer.instance:playSound(CLICK_SOUND_FILE)
			end
		end)
	end

	return self
end

function M:removeClickListener()
	self.luaBehaviour:RemoveClick(self.gameObject)
end

function M:addPointClientListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onClick  = function( go, point ) func( self, go, point ) end
	end
	return self
end

function M:addPointDownListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onDown  = function( go, point ) func( self, go, point ) end
	end
	return self
end

function M:addPointUpListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onUp  = function( go, point ) func( self, go, point ) end
	end
	return self
end

function M:addPointEnterListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onEnter  = function( go, point ) func( self, go, point ) end
	end
	return self
end

function M:addPointExitListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).OnPointerExit  = function( go, point ) func( self, go, point ) end
	end
	return self
end


function M:addBeginDragListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onBeginDrag  = function( go, point ) func( self, go, point ) end
	end
	return self
end

function M:addDragListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onDrag  = function( go, point ) func( self, go, point ) end
	end
	return self
end


function M:addEndDragListener( func )
	if func and type( func ) == "function" then
		UIEventListener.Get( self.gameObject ).onEndDrag  = function( go, point ) func( self, go, point ) end
	end
	return self
end


function M:setLayer(layer)
	self.gameObject.layer = layer
end


function M:getComponent( comName )
	return self.gameObject:GetComponent( comName )
end


function M:addComponent( comName )
	return self.gameObject:AddComponent( comName )
end


function M:dispose()
	-- MgrRes:putGameObject( self.gameObject )

	self.bDisposed = true
	
	--调用底层引用
	-- GameObject.DestroyImmediate( self.gameObject, true )
	GameObject.Destroy( self.gameObject )
	--资源层面的归还,有可能是空的gameobject，所以这里要做空判断
	if self:isRegisterd() and self.abName then
		MgrRes:putPrefab(self.abName)
		self.abName = nil
	end
end


return M