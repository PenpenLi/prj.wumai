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
	["random_name_db"] = { mode = "a" },
	["rank_db"] = { mode = "ma" },
	["map_db"] = { mode = "m" },
	["item_db"] = { mode = "-m" },
	["drop_db"] = { mode = "-m", formater = function( rawDb )
		local oneDb
		for k, db in pairs( rawDb ) do
			oneDb = db
			break
		end

		local DROP_LIST = {}
		local index = 1
		-- 找到所有掉落字段
		while true do
			local key = string.format( "drop%d", index )
			if not oneDb[ key ] then break end

			table.insert( DROP_LIST, key )
			index = index + 1
		end

		-- 将掉落转化为table
		for k, db in pairs( rawDb ) do
			-- 圆桌概率的总和
			local rateSum = 0
			local mType = db.type
			local items = {}
			for i, key in ipairs( DROP_LIST ) do
				local data = db[ key ]

				if #data > 0 then
					local item = { id = data[1], min = data[2], max = data[3], rate = data[4] }
					table.insert( items, item )

					-- 圆桌概率计算和
					if mType == 2 then
						rateSum = rateSum + item.rate
					end
				end

				-- 清理字段
				db[ key ] = nil
			end

			db.items = items
			db.sum = rateSum
		end
	end },
	["lottery_db"] = { mode = "-m", formater = function ( rawDb )
		for id, data in ipairs( rawDb ) do
			local items = {}
			for _, item in ipairs( data.items ) do
				table.insert( { itemId = item[1], count = item[2] } )
			end
			data.items = items
		end
	end },
	["switch_db"] = { mode = "m" },
	["pay_db"] = { mode = "m" },
	["role_db"] = { mode = "m" },
	["skill_db"] = { mode = "-m" },
	["bullet_db"] = { mode = "-m" },
	["buff_db"] = { mode = "-m" },
	["trap_db"] = { mode = "-m" },
	["effect_db"] = { mode = "-m" },
	["up_db"] = { mode = "-mm" },
	["spawn_db"] = { mode = "-mmma" },
	["badword_db"] = { mode = "a", formater = function( rawDb )
		for idx, v in pairs(rawDb) do
			rawDb[idx] = v.word
			v.word = nil
		end
	end },
	["goal_db"] = { mode = "-m" },
	["quest_db"] = { mode = "m", formater = function( rawDb )
		-- 建立前置任务的反向列表
		local preDb
		for questId, db in pairs( rawDb ) do

			if not db.nextIds then db.nextIds = {} end

			for _, preId in ipairs( db.preIds ) do
				local preDb = rawDb[ preId ]
				if preDb then
					local nextIds = preDb.nextIds
					if not nextIds then nextIds = {} preDb.nextIds = nextIds end

					table.insert( nextIds, questId )
				end
			end
		end
	end },
}


return loader

