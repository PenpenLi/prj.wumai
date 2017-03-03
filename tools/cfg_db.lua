--[[
	loader按照mode解析表格，并根据formater进行二次加工
	拆分表格、合并表格或者依赖上下文的需求请在游戏内写
	loader = {
		[文件名] = {
			mode = 原始数据解析方式,

			-- 可选项
			formater = function(解析后数据)
				二次加工过程
			end },

		...
	}
--]]


-- 本项目只能用 m来解析，因为数据结构会转到C#端


local loader = {
	["role_db"] = { mode = "m" },
	["product_db"] = { mode = "m" },
}


return loader

