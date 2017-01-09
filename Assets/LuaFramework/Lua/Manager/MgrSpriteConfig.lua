
--[[

	使用spritePacker，合图后assetBundleName 和assetName 使用者自己处理
	此类废弃2016-09-26

]]
local M = class( "MgrSpriteConfig")

-- function M:load()
-- 	-- self.sprites = {}
-- 	-- for i,v in ipairs(SpriteConfig) do
-- 	-- 	MgrRes:loadPrefab(v, nil, handler(self, self.OnCreateObj))
-- 	-- end
	
-- end

-- function M:OnCreateObj(obj)
-- 	local config = obj:GetComponent("UISpriteConfig")

-- 	local count = config:Count()

-- 	for i = 0, count - 1 do
-- 		local v = config:GetSprite(i)
-- 		local name = string.format("%s/%s", obj.name, v.name)
-- 		self.sprites[name] = v
-- 	end
-- end

-- function M:getSprite(name)
-- 	return self.sprites[name]
-- end
--SpriteConfig/ui/prefab

-- function M:setSprite(image, assetBundle, spriteName)
-- 	MgrRes:loadPrefab(assetBundle, nil, 
-- 		function(obj)
-- 			local config = obj:GetComponent("UISpriteConfig")
-- 			print("config loadPrefab" )
-- 			image.sprite = config:GetSprite(spriteName)


-- 		end)

-- end

return M