--[[
	弹出模块，包括panel，dialog，tip
]]

local ModuleAlert = class( "ModuleAlert" )


local FONT_HIT = "Font/number3/fontsettings"
local FONT_CRIT = "Font/number4/fontsettings"




function ModuleAlert:Awake()
	self.camera = GameObject.Find( "UICamera" ):GetComponent( typeof( Camera ) )
end


function ModuleAlert:Start()
	
end



function ModuleAlert:getUiPosition( transform, screenPos )
	local _, pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(transform, screenPos, self.camera, nil)
	return pos
end


function ModuleAlert:getScreenPosition(worldPos, camera)
	camera = camera or self.camera
	return camera:WorldToScreenPoint(worldPos)
end



function ModuleAlert:alertText( text )
	MgrPanel:openPanelWithSingleton( "PanelTip", text )
end


function ModuleAlert:alertDamage(pos, text, dir)
	if tonumber(text) then
		self:alertHitDamage(pos, text, dir)
	else
		self:alertCritDamage(pos, text:match( "%a*(%d*)" ), dir)
	end
end


function ModuleAlert:alertHitDamage( pos, text, dir)
	MgrPanel:openPanelWithSingleton( "PanelDamage", { pos = pos, text = text, font = FONT_HIT, dir = dir } )
end


function ModuleAlert:alertCritDamage( pos, text, dir)
	MgrPanel:openPanelWithSingleton( "PanelDamage", { pos = pos, head = "b", text = text, font = FONT_CRIT, dir = dir } )
end


function ModuleAlert:alertHpBar( creature )
	MgrPanel:openPanelWithSingleton( "PanelHpBar", {creature = creature} )
end


function ModuleAlert:alertGift(payId, callback, quiet, shopGid, COP)
	local payDb = ModulePay:getPayDb(payId)
	if payDb.dialogStyle == PAY_DIALOG_STYLE_NORMAL then
		MgrPanel:openPanel("PanelGift", {payId = payId, callback = callback, shopGid = shopGid, quiet = quiet, COP = COP})
	elseif payDb.dialogStyle == PAY_DIALOG_STYLE_SIMPLE then
		MgrPanel:openPanel("PanelGift1", {payId = payId, callback = callback, shopGid = shopGid, quiet = quiet, COP = COP})
	elseif payDb.dialogStyle == PAY_DIALOG_STYLE_UNLICK then
		if ModuleSDK.COP.CLOSE_CONFIRM then
			ModulePay:buyGoods( payId, callback, false, 1 )
		else
			MgrPanel:openPanel("PanelUnlock", {payId = payId, callback = callback, quiet = quiet, COP = COP})
		end
	elseif payDb.dialogStyle == PAY_DIALOG_STYLE_PAY then
		ModulePay:buyGoods( self.payId, callback, quiet, 1 )
	end
end


function ModuleAlert:alertPushGift(COP, callback)
	callback = callback or function () end

	if not COP
		or not COP.enable
		or not ModulePay:getActive(COP.payId)
		or ModuleGuide:isGuiding() then
		callback(false)
		return
	end

	self:alertGift(COP.payId, callback, false, nil, COP)
end


function ModuleAlert:alertDialog( text, onConfirm, onCancel, confirmText, cancelText )
	MgrPanel:openPanel("PanelDialog", {text = text, onConfirm = onConfirm, onCancel = onCancel, confirmText = confirmText, cancelText = cancelText})
end


function ModuleAlert:alertItems(items, callback)
	local str = ""
	for i, item in ipairs(items) do
		local db = ModuleItem:getItemDb(item.itemId)
		if i == 1 then
			str = string.format("%s获得%s个%s", str, item.count, db.name)
		else
			str = string.format("%s, 获得%s个%s", str, item.count, db.name)
		end
	end

	self:alertText(str)
	if callback then
		callback()
	end
	-- MgrPanel:openPanelWithSingleton()

	self:alertEffect("Effect/lingqu_bao/prefab", nil, 1.5)
end


-- function ModuleAlert:openInput( title, tip, callback )
-- 	MgrPanel:openPanel("PanelInput", {bRnd = false, title = title, tip = tip, callback = callback})
-- end


function ModuleAlert:openInputName(callback)
	MgrPanel:openPanel("PanelInput", {bRnd = true, title = "取个名字", tip = "请输入名字", len = 7, callback = callback})
end


function ModuleAlert:alertEffect(res, target, time, callback, x, y)
	target = target or MgrPanel:getLayerNode(MgrPanel.LAYER_TOP)
	SimpleEffect.New(res, {time = time, callback = callback}, function (obj)
		obj:addTo(target)
		if x and y then
			obj:setLocalPosition(x, y, 0)
		end
	end)
end


function ModuleAlert:alertLvupEffect(target, camera)
	if not target or not target.transform then return end

	local pos = self:getScreenPosition(target.transform.position, camera)
	local transform = MgrPanel:getLayerNode(MgrPanel.LAYER_TOP)
	pos = self:getUiPosition(transform, pos)
	self:alertEffect("Effect/shengji/prefab", transform, 0.8, nil, pos.x, pos.y)
end


function ModuleAlert:alertClickEffect(screenPos)
	local transform = MgrPanel:getLayerNode(MgrPanel.LAYER_TOP)
	local pos = self:getUiPosition( transform, screenPos )
	self:alertEffect("Effect/dianji/prefab", transform, 0.6, nil, pos.x, pos.y)
end


function ModuleAlert:alertChangeEffect( target, camera )
	if not target or not target.transform then return end

	local pos = self:getScreenPosition(target.transform.position, camera)
	local transform = MgrPanel:getLayerNode(MgrPanel.LAYER_TOP)
	pos = self:getUiPosition(transform, pos)
	self:alertEffect("Effect/qiehuan/prefab", transform, 0.8, nil, pos.x, pos.y)
end























--------------------------------- 通用弹出 ----------------------------------------

-- 二次确认框
function ModuleAlert:openDialog( title, text, callbacks, btnSkins, btnTexts )
end


-- RMB购买2次确认
function ModuleAlert:openRMBConfirm( title, text, price, callbacks )
end


-- 弹出输入框
function ModuleAlert:openEditDialog( titleStr, callback, clear )
end





return ModuleAlert
