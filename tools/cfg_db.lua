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


local loader = {
	["role_db"] = { mode = "m" },
}


return loader

