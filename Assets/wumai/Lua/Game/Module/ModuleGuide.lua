--[[
	新手引导
]]

local ModuleGuide = class( "ModuleGuide" )

local SCRIPTS = require("Game/Const/GuideScript")




function ModuleGuide:Awake()
	self.guideData = ModuleRecord:getData( "GUIDE" ) or {}
end


function ModuleGuide:Start()
	local canvas = MgrPanel:getCanvas()
	self.guideHelper = canvas:GetComponent("ULGuideHelper")
end


function ModuleGuide:saveData()
	ModuleRecord:setData( "GUIDE", self.guideData )
end


function ModuleGuide:check(guideId)
	return self.guideData[guideId]
end


function ModuleGuide:dispatchGuide(guideId)
	-- print("--> dispatchGuide", guideId)
	if self.curGuideId then
		-- printWarn( "can't run %s guide, because %s is runing.", guideId, self.curGuideId )
		return false
	end

	if self:check(guideId) then return false end

	local guideScript = SCRIPTS[guideId]
	if not guideScript then return false end

	self.curGuideId = guideId

	MgrPanel:openPanel("PanelGuide", {script = guideScript, guideId = guideId})
	return true
end


function ModuleGuide:finish(save)
	if save and self.curGuideId then
		self.guideData[self.curGuideId] = true
		self:saveData()
	end
	self.curGuideId = nil
end


function ModuleGuide:isGuiding()
	return self.curGuideId ~= nil
end


-- local pos = self.guideHelper:getUiPosition(uiName)
-- guideHelper:uiExists(uiName)




return ModuleGuide
