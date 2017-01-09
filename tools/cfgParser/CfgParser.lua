local M = {}


local cjson = require("json")
local DELIMIT = ";"

--[[
	将标准excel导出的数据解析成各种结构的lua表
	导出的json文件请用parseFile方法解析l

	解析参数rules分为两部分：前缀和解析方式：
	1、解析方式是一个规则的字符串,包含两种类型
		"m"为map类型，"a"为array类型
		两者可组合使用，但必须满足以下条件
		1>"m"可出现多次
		2>"a"最多出现一次，且只能在末端

		以下为有效规制:
		"mm"，"mmma"，"a"
		以下为无效规则:
		"aa"，"mam"

		例子:
		"m"解析成如下格式:						"mm"解析成如下格式:
		data = {								data = {
			key1 = {},								key1 = {
			key2 = {},									key11 = {},
		}												key12 = {},
													},
													key2 = {
														key21 = {},
														key22 = {},
													}
												}

		"a"解析成如下格式:						"ma"解析成如下格式:
		data = {								data = {
			{},										key1 = {
			{},											{},
		}												{},
													},
													key2 = {
														{},
														{},
													},
												}		

	2、前缀符号位“-”
		若不带前缀，则表示导出的数据末端拥有完整的数据，即table的key也会以 key - value 的形式保存在数据末端
		若带前缀，则表示导出的数据末端只包含除key之外的值

		例如：
		"m"规则解析成如下数据
		data = {
			key1 = { feild1 = key1, keyA = valueB },
			key2 = { feild2 = key2, keyB = valueB },
		}

		"-m"则解析成如下
		data = {
			key1 = { keyA = valueB },
			key2 = { keyB = valueB },
		}
--]]


-----------------------------------------------------------------------------------------------
------------------------------------vvvv解析数据vvvv-------------------------------------------
local table_insert = table.insert
local table_remove = table.remove
local table_format = string.format
local string_upper = string.upper
local string_len = string.len
local string_rep = string.rep
local string_find = string.find
local string_gsub = string.gsub
local string_sub = string.sub
local string_byte = string.byte
local string_char = string.char
function string.split(input, delimiter)
    input = tostring(input)
    if input == nil or input == "" then
    return {};
    end;
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table_insert(arr, string_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table_insert(arr, string_sub(input, pos))
    return arr
end
local function parseNum(srcValue,default )
	local value = default or 0
	value = tonumber(srcValue)

	if value == nil then
		value = 0
		if srcValue ~= "" then
			return nil, string.format( "parseNum err: value:[%s]", srcValue )
		end
	end

	return value
end

 -- 解析为整数
local function parseInt(srcValue,default )
	local value
	value = tonumber( srcValue )

	if value == nil then
		value = 0
		if srcValue ~= "" then
			return nil, string.format( "parseInt err: value:[%s]", srcValue )
		end
	end

	return value
end

-- 解析为字符串
local function parseStr(srcValue,default )
	local value = default or ""
	if srcValue ~= nil then
		value = srcValue
	end
	-- 处理英文逗号和\n
	-- value = string.gsub(value,",","，")
	value = string.gsub(value,"\n","\\n")
	return value
end


-- 解析为table
local function parseTable(srcStr,default )
	local value
	local err
	if srcStr ~= nil and srcStr ~= "" then
		xpcall( function ()		
			value = loadstring( 'return ' .. srcStr )()
		end, function ( e )
			err = e
		end )

		if not value or type(value) ~= "table" then
			print("error:", "parseTable err: srcStr is invalid( " .. srcStr .. ")")
			value = nil
		end
	end

	if not value then
		value = default or {}
	end
	return value, err
end


-- 解析字符串格式的table
-- 用冒号分割
local function parseStrTable( srcValue, default )
	local str = parseStr( srcValue, default )

	if not str or str == "" then return {} end
	return string.split( str, DELIMIT )
end


-- 解析数组格式的table
local function parseIntTable(srcValue, default)
	local str = parseStr( srcValue, default )
--	print( "parseIntTable str == ", str)
	if not str or str == "" then return {} end
	local t = string.split( str, DELIMIT )
	for k, v in ipairs( t ) do 
		t[k] = tonumber(v)
	end
	return t
end


-- 解析为boolean
local function parseBool(srcBool,default )
	local value = default or false
	if srcBool ~= nil and srcBool ~= "" then
		value = srcBool:lower() == "true"
	end
	return value
end


local function parseNothing()
	return nil
end


local function parseRef(srcValue,default)
	local key = parseStr( srcValue, "" )
	local value = _G[ key ]

	if value == nil then
		print("warn", "warn: parseRef has a nil value!", key )
	end

	return value
end


local parseFuncs = {
	T  = parseTable,
	S  = parseStr,
	ST = parseStrTable,
	IT = parseIntTable,
	I  = parseInt,
	B  = parseBool,
	-- 关于N类型暂时为处理解析过程，这里直接当成字符串导出
	N  = parseStr,	--parseNothing,
	F  = parseNum,
	R  = parseRef,
}

-- 提供外部接口（多用于多次类型解析的数据结构）
function M.parseValue( value, vType )
	local parseFunc = parseFuncs[ vType ]

	if parseFunc then
		return parseFunc( value )
	else
		print("error:",  string.format( "no such type:%s value:%s", vType, value ) )
		return nil
	end
end
------------------------------------^^^^解析数据^^^^-------------------------------------------
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-------------------------------------vvvv解析表vvvv--------------------------------------------

local function _getRule( rules, index )
	return string.sub( rules, index, index )
end


-- 找到相应递归层次的值
local function _findValue( result, lValues, index )
	local tValue = result
	local key
	for i = 1, index - 1 do
		-- 1000 和 "1000" 是不同的key
		key = lValues[ i ]
		tValue = tValue[ key ]
		if not tValue then
			return nil, string.format( "_findValue worning, row:%s, index:%s, key:%s", i, index, key )
		end
	end

	return tValue, nil
end


local function _doParse( data, rules, result,   index, fullData )
	if not rules 					then return data end
	if type( rules ) ~= "string" 	then return data end
	if not data then
		return nil, "data is invalid!"
	end
	-- if #rules < 1 					then return data end
	if not result then
		return nil, "result is invalid!"
	end

	if not index then
		return nil, "index is invalid!"
	end

	local rule = _getRule( rules, index )
	local nextRule = _getRule( rules, index + 1 )
	local fields = data.fields
	local values = data.values

	local maxIndex = #fields
	local dataLen = #values

	local key, value, lValues, pValue, curValue, err, _
	if rule == "a" then
		for i = 1, dataLen do
			lValues = values[ i ]
			pValue, err = _findValue( result, lValues, index )
			if err then
				return nil, err
			end
			curValue = {}
			local startIndex = index
			if fullData then
				startIndex = 1
			end
			for j = startIndex, maxIndex do
				key, value = fields[ j ], lValues[ j ]
				curValue[ key ] = value
			end
			table.insert( pValue, curValue )
		end
	elseif rule == "" then
		for i = 1, dataLen do
			lValues = values[ i ]
			pValue, err = _findValue( result, lValues, index )
			if err then
				return nil, err
			end
			local startIndex = index
			if fullData then
				startIndex = 1
			end
			for j = startIndex, maxIndex do
				key, value = fields[ j ], lValues[ j ]
				pValue[ key ] = value
			end
		end
	elseif rule == "m" then
		for i = 1, dataLen do
			lValues = values[ i ]
			pValue, err = _findValue( result, lValues, index )
			if err then
				return nil, err
			end
			-- value当做下一层的key
			value = lValues[ index ]
			if pValue[ value ] then
				-- 最后一层不是数组时，若key有重复则数据会被覆盖
				if nextRule == "" then
					-- 这个根据容忍程度选择是警告还是报错，通常这个警告都是因为填表有误
					-- print("warn", string.format( "Data will be overwrite in row:%s, index:%s", i, index ) )
					-- print("warn", string.u2a( "这个警告通常是因为填表有误!" ) )

					-- 若不容忍这类错误直接请打开以下语句返回函数，可查看详细信息
					return nil, string.format( "Data will be overwrite in row: %s, index: %s", i, index )
				end
			else
				pValue[ value ] = {}
			end
		end
		index = index + 1
		if index <= maxIndex then
			_, err = _doParse( data, rules, result, index, fullData )
			if err then
				return nil, err
			end
		end
	end

	return result, nil
end


-- 本方法对data有严格的格式要求，故私有
local function _parseCommonFunc( data, rules )
	if not rules or type( rules ) ~= "string" then
		rules = "a"
	end

	local rule, fullData = _getRule( rules, 1 ), true
	if rule == "-" then
		fullData = false
		rules = string.sub( rules, 2, #rules )
	end

	return _doParse( data, rules, {}, 1, fullData )
end


-------------------------------------^^^^解析表^^^^--------------------------------------------
-----------------------------------------------------------------------------------------------

-- 根据类型解析对应的值
-- types和values是长度相同的数组
function M.parseRawLuaValues( types, values )
	if #types ~= #values then
		return nil, "#types ~= #values"
	end

	local parseValues, parseFunc, value, err = {}, nil

	for i, vType in ipairs( types ) do
		parseFunc = parseFuncs[ vType ]

		if parseFunc then
			value, err = parseFunc( values[ i ] )
			if err then
				return nil, string.format( "%s, type:%s, index:%s", err, vType, i )
			end
			table.insert( parseValues, value )
		else
			return nil, string.format( "no such type:%s, index:%s", vType, i )
		end
	end

	return parseValues, nil
end


-- 根据类型解析原始表，并去掉类型字段（解析后已无价值）
function M.parseRawData( data )
	local types, values = data.types, data.values
	local result, err = nil

	for i, lValue in ipairs( values ) do
		result, err = M.parseRawLuaValues( types, lValue )
		if err then
			return nil, string.format( "%s, row:%s", err, i )
		else
			values[ i ] = result
		end
	end

	-- 去掉type信息
	data.types = nil

	return data, nil
end


--[[ 
获取原始lua表
keyMap ~ fields的键值映射表，内容类似于下表
keyMap = {
	["SRC_KEY1"] = "targetKey1",
	["SRC_KEY2"] = "targetKey2",
	["SRC_KEY3"] = "targetKey3",
}
]]
function M.getRawDataFromJsonFile( fileName, keyMap )
    local jsonStr = cc.FileUtils:getInstance():getStringFromFile( fileName )

	if not jsonStr then
		print("error:",  string.format( "loadFile %s error!", fileName ) )
		return nil
	end

	local data = cjson.decode( jsonStr )

	if keyMap then
		local fields = data.fields
		for k,v in pairs(fields) do
			fields[k] = keyMap[v] or v
		end
	end

	return data
end


function M.getRawDataFromLuaFile( fileName )
	
end


-- 解析json文件
-- @param fileName json文件
-- @param rules 解析规则，具体使用请看上面说明
function M.parseFile( fileName, rules ,keyMap)
	local data, err

	local ext = fileName:match(".+%.(%w+)$")

	xpcall(
		function ()
			if ext == "json" then
				data = M.getRawDataFromJsonFile( fileName, keyMap )
			elseif ext == "lua" then
				data = dofile( fileName )
			elseif ext == nil then
				data = require( fileName )
			else
				print("error:",  string.format( "decode %s error! unknow ext.", fileName ) )
			end
		end,
		function ( e )
			data = nil
			err = e
		end
	)

	if not data then
		print("error:",  string.format( "decode %s error!", fileName ) )
		print( debug.traceback() )
		os.execute("pause")
		return nil
	end

	data, err = M.parseLuaTable( data, rules )
	if err then
		print("error:",  string.format( "Parse %s error: %s", fileName, err ) )
		print( debug.traceback() )
		os.execute("pause")
		return nil
	end

	return data
end



function M.parseLuaTable( data, rules )
	local err = nil
	data, err = M.parseRawData( data )
	if err then return data, err end

	data, err = _parseCommonFunc( data, rules )
	if err then return data, err end

	return data
end


function M.parseFileWithFormater( fileName, rules, formater )
	local data = M.parseFile( fileName, rules )
	if data and formater then
		formater( data )
	end

	return data
end


-- TODO:自定义解析
function M.customParseFile( fileName, parseFunc )
	
end


return M