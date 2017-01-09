--[[
	UGUI工具

	不依赖任何lua封装方法
]]

local UGUITools = {}







function UGUITools.getChild( gObj, name )
	return gObj.transform:FindChild( name )
end


function UGUITools.getLuaTable( gObj )
	local component = gObj.gameObject:GetComponent( "LuaBehaviour" )
	if component then
		return component:getLuaScript()
	end

	return nil
end


function UGUITools.setText(gObj, text)
	local component = gObj.gameObject:GetComponent(typeof(Text))
	if component then
		component.text = tostring(text)
	end

	return component
end


-- spriteName like Icon/buff1
function UGUITools.setSprite(gObj, spriteName, container)
	local image = gObj.gameObject:GetComponent(typeof(Image))
	if image and spriteName then
		local assetBundleKey, assetName = unpack( string.split( spriteName, "/" ) )
		MgrRes:loadPrefab(assetBundleKey, assetName, function(obj)
			if not container then
				printError("check this container %s", debug.traceback())
				image.sprite = obj
				return
			end

			if not container.bDisposed then
				image.sprite = obj
			end
		end, true)
	end

	return image
end


-- toggle
function UGUITools.addToggleListener(gObj, listener)
	local com = gObj.gameObject:GetComponent(typeof(Toggle))
	com.onValueChanged:AddListener(listener)
	return com
end


function UGUITools.addULToggleListener(gObj, listener)
	local com = gObj.gameObject:GetComponent(typeof(ULToggle))
	com.onValueChanged:AddListener(listener)
	return com
end


function UGUITools.changeULToggle(gObj, isOn)
	local com = gObj.gameObject:GetComponent(typeof(ULToggle))
	com.isOn = isOn
	return com
end



function UGUITools.getTimeString(time)
	-- time = math.modf(time)
	local min = math.modf(time / 60)
	local sec = time - min * 60
	return string.format("%02d:%02d", min, sec)
end



return UGUITools
