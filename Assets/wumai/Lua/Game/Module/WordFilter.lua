--[[--
	关键字过滤管理器

	两个配置文件：
	badwords：关键字，只要文字中带有关键字库中的单词，则无法通过检测
	badnames: 关键名字，只有名字全等于关键字库中的名字，才无法通过检测

	提供关键字过滤相关接口
	1. 检查
	2. 替换
	3. 提示
]]

local WordFilter = class("WordFilter")

-------------------- 常量区 --------------------
-- 屏蔽字
-- local FILE_BADWORDS = "r/cfg/badwords.lua"
-- 屏蔽名字
-- local FILE_BADNAMES = gfGetCfgPath( "badnames.lua" )

-- 被过滤的词语
local REP_STR = "**"
-- 需要屏蔽的符号
local REP_NO_SYMBOL = "[!@#$%%^&*()`~<>,./?;:\'\"%[%]{}\\%|-=_+\n\r\t\b ]"









-------------------- 生命周期 --------------------
function WordFilter:Awake()
	self.badwords = nil
	-- self.badnames = nil

	self:loadWords()
end


function WordFilter:Start()
end










-------------------- 配置文件读取相关 --------------------

function WordFilter:loadWords()
	if not self.badwords then
		self.badwords = MgrCfg.allDatas.badword_db

		-- 处理为头字符的模式
		local dict = {
			-- [headChar] = words
			}

		-- words = {
		-- 	[1] = { "h", "e", "l", "l", "o" },
		-- 	[2] = { "h", "e", "l", "l", "o" },
		-- 	}
		for k, v in pairs( self.badwords ) do
			local headChar = string.u8sub( v, 1, 1 )
			local words = dict[ headChar ]
			if not words then
				words = {}
				dict[ headChar ] = words
			end

			local word = {}
			string.u8foreach( v, function( c ) 
				table.insert( word, c )
				end )

			table.insert( words, word )
		end

		self.badwordDict = dict
	end
end










-------------------- 检查 --------------------

--- 检查传入的字符串
function WordFilter:checkStr( str )
	if not str then return true end

	local badwords = self.badwords
	local string_find = string.find

	local p1, p2
	for i = 1, #badwords do
		p1, p2 = string_find( str, badwords[i] )
		if p1 then 
			return false 
		end
	end

	return true
end

-- --- 检查传入的名字
-- function WordFilter:checkName( name )
-- 	if not name then return true end

-- 	-- 全字匹配检测名字
-- 	local badnames = self.badnames
-- 	for i = 1, #badnames do
-- 		if name == badnames[i] then
-- 			return false
-- 		end
-- 	end

-- 	-- 使用常规关键字检测
-- 	if not self:checkStr( name ) then
-- 		return false
-- 	end

-- 	return true
-- end

--- 检测传入的字符串是否有特殊符号
function WordFilter:hasSymbol( str )
	-- 检测英文字符
	local p1, p2 = string.find( str, REP_NO_SYMBOL)
	if p1 then return true end

	-- 检测全角中文空格
	local hasSpace = false
	string.u8foreach( str, function( char ) 
			if "　" == char then 
				hasSpace = true 
				return true 
			end
		end )

	return hasSpace
end

-- --- 检测名字长度
-- function WordFilter:checkNameLen( name )
-- 	if not name then return true end

-- 	if string.len( name ) > NAME_MAX_BYTE_LEN then return false end

-- 	if string.u8len( name ) > NAME_MAX_CHAR_LEN then return false end

-- 	return true
-- end









-------------------- 替换 --------------------

--- 过滤关键字
-- <b>警告！</>这个方法很慢，在模拟器上，一次完整替换需要3ms
function WordFilter:_slow_filterStr( str )
	if not str then return str end

	local badwords = self.badwords
	local string_gsub = string.gsub
	local REP_STR = REP_STR

	local badword
	for i = 1, #badwords do
		str = string_gsub( str, badwords[i], REP_STR )
	end

	return str
end

--- 过滤关键字
-- 深度优化的版本，比上面的方法快20-50倍
-- 优化思路：
-- 首先将关键字拆分为逐个的utf-8字符串
-- 通过首字符作为key，保存为hash表（提升访问速度）
-- 遍历一个关键字的时候，只需要按照传入的字符串遍历一次，每个字符通过关键字首字符的索引进行遍历
-- 生成一张涉及到违规词汇的keywords
-- string.gsub的时候只针对这个keywords进行替换即可
function WordFilter:filterStr( str, repStr )
	if not str then return str end

	local u2a = string.u2a
	-- print("filterStr2", u2a( str ))

	local string_gsub = string.gsub
	local table_insert = table.insert
	local table_remove = table.remove
	local table_concat = table.concat
	local clone = clone
	local REP_STR = repStr or REP_STR

	local dict = self.badwordDict
	local wordsArr = nil
	local words = nil

	local suspectBeginIdxs = {}
	local suspectWordses = {}

	local keywords = {
		-- [1] = word,
		}

	local i = 1
	local beginIdx, words, word, swci, swc
	string.u8foreach( str, function( char ) 
		-- print( "  echo", i, u2a( char ) )
		words = dict[ char ]

		-- 1. 不断将“嫌疑词”记录下来
		if words then
			words = clone( words )

			table_insert( suspectBeginIdxs, i )
			table_insert( suspectWordses, words )
		end

		-- 2. 清理“嫌疑词”
		for si = #suspectBeginIdxs, 1, -1 do
			beginIdx	= suspectBeginIdxs[ si ]
			words		= suspectWordses[ si ]

			-- print("    suspect", beginIdx, #words )
			for swi = #words, 1, -1 do
				word = words[ swi ]

				swci = i - beginIdx + 1
				swc = word[ swci ]

				-- print("      swc", swci, u2a( swc ) )

				-- 不匹配，删掉
				if swc ~= char then
					table_remove( words, swi )
				else
					-- 匹配，如果是最后一个字，则关键字匹配成功
					if swci == #word then
						-- print("        last word")
						table_insert( keywords, table_concat( word ) )
						table_remove( words, swi )
					end
				end
			end

			if #words <= 0 then
				table_remove( suspectBeginIdxs, si )
				table_remove( suspectWordses, si )
			end
		end

		i = i + 1
		end )

	for k, v in pairs( keywords ) do
		str = string_gsub( str, v, REP_STR )
	end

	return str
end

-- 过滤所有的英文字符
function WordFilter:filterSymbol( ustr )
	local result = string.gsub( ustr, REP_NO_SYMBOL, "" )

	result = string.gsub( result, "　", "" )

	return result
end









-------------------- 提示 --------------------

-- --- 检测传入的字符串是否有特殊符号，并通过对话框进行提示
-- -- @param str 需要检测的字符串
-- -- @param fPassCallback 通过检测后的回调
-- function WordFilter:checkSymbolWithDialog( str, fPassCallback )
-- 	if not fPassCallback then return end

-- 	-- 空串直接通过验证
-- 	if not str or str == "" then 
-- 		fPassCallback( "" ) 
-- 		return 
-- 	end

-- 	if self:hasSymbol( str ) then
-- 		-- 不通过，弹窗提示
-- 		local result = self:filterSymbol( str )

-- 		local tip = string.format( cfg:getText(5500001), str, result )
-- 		-- local tip = string.format( "您输入的[<instance_07>%s</>]含有<prompt_red>非法字符</>\n\n是否使用[<instance_07>%s</>]替换？", str, result )

-- 		local fOk = function() 
-- 			fPassCallback( result )
-- 		end

-- 		mgrTip:alertPrompt2( tip, fOk, nil, cfg:getText(105032), cfg:getText(105007) )
-- 		-- mgrTip:alertPrompt2( tip, fOk, nil, "替换", "取消" )
-- 	else

-- 		-- 通过
-- 		fPassCallback( str )
-- 	end
-- end




----- 随机名字相关 -----
-- function WordFilter:createRandomName()
-- 	local part1 = mgrCfg.allDatas.random_name_part1_db
-- 	local part2 = mgrCfg.allDatas.random_name_part2_db

-- 	-- 创建随机名字
-- 	-- 由于随机名字可能会被屏蔽掉，这里处理一下
-- 	local name = ""
-- 	for i = 1, 1000 do
-- 		local data1 = part1[math.random(#part1)]
-- 		local data2 = part2[math.random(#part2)]
		
-- 		name = ( data1 and data1.word or "") .. (data2 and data2.word or "")

-- 		if not self:hasSymbol(name) and self:checkStr(name) then
-- 			-- 通过
-- 			break
-- 		end
-- 	end

-- 	return name
-- end


return WordFilter