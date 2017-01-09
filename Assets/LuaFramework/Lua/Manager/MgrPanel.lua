--[[
	面板管理器，概念更新，都叫面板


	2016-9-23
	1、与LuaPanel高度耦合
	2、三种类型面板common，full，dialog
	3、五个大层级
	4、不同层互不干扰，互不越界

	弹出规则:
		弹出fulll类型会hide当前full和dialog类型
		弹出dialog类型只会hide当前的dialog类型
		添加common类型不会hide其他类型(也不会被hide)
]]




local M = class( "MgrPanel" )




-- panel类型
M.STYLE_COMMON = 1 	-- 通用类型
M.STYLE_FULL = 2 	-- 全屏类型
M.STYLE_DIALOG = 3 	-- 对话框类型




-- panel层级
M.LAYER_BOTTOM = 1
M.LAYER_UI = 2
M.LAYER_DIALOG = 3
M.LAYER_TIP = 4
M.LAYER_TOP = 5





M.canvas = nil
M.layerNodes = {}



-- view 搜索路劲列表
local view_roots = {}



-- 各层面板堆栈
local view_stack = {
	[ M.LAYER_BOTTOM ] = {},
	[ M.LAYER_UI ] = {},
	[ M.LAYER_DIALOG ] = {},
	[ M.LAYER_TIP ] = {},
	[ M.LAYER_TOP ] = {},
}





--这里说明下，runningScene只会出现在mgrScene中
--M.runningScene = nil


function M:getCanvas()
	if not M.canvas then
		M.canvas = GameObject.FindWithTag( "Canvas" )
		self:initLayers( M.canvas )
	end
	return M.canvas
end


function M:initLayers( canvas )
	local layerTemplate = canvas.transform:FindChild( "LayerNode" )
	for i = M.LAYER_BOTTOM, M.LAYER_TOP do
		local node = newObject( layerTemplate )
		node.name = "Layer" .. i
		local transform = node.transform
		transform:SetParent( canvas.transform )
		transform.offsetMin = Vector2.zero
		transform.offsetMax = Vector2.zero
		transform.localScale = Vector3.one

		node.gameObject:SetActive( true )

		M.layerNodes[ i ] = node
	end
end


function M:getLayerNode( layer )
	local node = M.layerNodes[ layer ]
	return node or printError( "can't find layer node :%s", tostring( layer ) )
end


function M:pushStack( panel, layer )
	local stack = view_stack[ layer ]
	if stack then
		table.insert( stack, panel )
	else
		printError( "push panel invalid layer:%s", layer )
	end
end


function M:popStack( layer )
	local stack = view_stack[ layer ]
	if stack then
		return table.remove( stack )
	else
		printError( "pop panel invalid layer:%s", layer )
		return
	end

end


function M:peekStack( layer )
	local stack = view_stack[ layer ]
	if stack then
		return stack[ #stack ]
	else
		printError( "peek panel invalid layer:%s", layer )
	end

	return nil
end


-- 销毁一个面板,从等待队列中移除,并调用销毁方法,从内存中卸载
function M:removeAndDispose( panel )
	if panel then
		self:removePanel( panel )
		panel:dispose()
	end
end


-- 允许关闭中间面板
function M:removePanel( panel )
	local stack = view_stack[ panel.panelLayer ]
	if stack then
		for i, v in ipairs( stack ) do
			if v == panel then
				table.remove( stack, i )
				return
			end
		end
	end

	printError( "can't remove panel:%s in layer:%s", panel._view_name, panel.panelLayer )
end




--顶级用法
function M:closePanel( panel )
	if not panel then return end

	local layer = panel.panelLayer

	local curPanel = self:peekStack( layer )

	if curPanel == panel then
		-- 是最上面的面板则pop掉
		self:removeAndDispose( panel )
		curPanel = self:peekStack( layer )
		if curPanel then
			curPanel:show()
		end
	else
		-- 没有在最上面则直接移除销毁
		self:removeAndDispose( panel )
	end
end


-- 设置搜索路径
function M:setViewRoots( ... )
	local paths = { ... }
	view_roots = {}
	for _, path in ipairs( paths ) do
		table.insert( view_roots, path )
	end
end


function M:getViewClass( name )
    if not name or name == "" then return nil end

    for _, root in ipairs( view_roots ) do
        local packageName = string.format("%s.%s", root, name)
        local status, view = xpcall(function()
            return require( packageName )
        end, function( msg )
	        if not string.find( msg, string.format("'%s' not found:", packageName ) ) then
	            printError("load view error: %s", msg)
	        end
        end)

        local t = type( view )
        if status and ( t == "table" or t == "userdata" ) then
        	view._view_name = name
            return view
        end
    end
end


function M:openPanel( name, context )
	local viewClass = self:getViewClass( name )
	if viewClass then
		local inst = viewClass.New( context )

		-- self:addPanel( inst )
	end
end


function M:openPanelWithSingleton( name, context )
	local view = self:findViewByName( name )
	if view then
		view:setContext( context )
		self:setTop( view )
		-- 这里没有处理hide逻辑，而是直接移动到最上层
	else
		self:openPanel( name, context )
	end
end


function M:findViewByName( name )
	for layer, stack in pairs( view_stack ) do
		for i, panel in ipairs( stack ) do
			if panel._view_name == name then
				return panel, i
			end
		end
	end
end


--[[
	打开面板，如果该面板已经存在，那么将放在最顶层
]]
function M:addPanel( panel )
	local layer = panel.panelLayer or M.LAYER_UI
	local style = panel.panelStyle

	local topPanel = self:peekStack( layer )

	if topPanel then
		if topPanel.panelStyle == M.STYLE_COMMON then
			-- do nothing
		elseif topPanel.panelStyle == style then
			topPanel:hide()
		elseif style == M.STYLE_FULL then
			topPanel:hide()
		end
	end

	self:pushStack( panel, layer )
	panel:addTo( self:getLayerNode( layer ) )
	
	panel:hide()
	panel:show()
	-- self:setTop( panel )
end


function M:setTop( panel )
	local stack = view_stack[ panel.panelLayer ]
	if stack then
		panel:setSiblingIndex( #stack )
	else
		printError( "set top an invalid layer:%s", panel.panelLayer )
	end
end


function M:disposeAllPanel()
	for layer, stack in pairs( view_stack ) do
		for i, panel in ipairs( stack ) do
			panel:dispose()
		end

		view_stack[ layer ] = {}
	end
end




return M




