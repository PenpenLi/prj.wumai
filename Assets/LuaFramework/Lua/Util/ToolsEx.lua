--[[
	Tools.cs的lua扩展
	由于无法直接修改Tools，故采用元表模拟继承
--]]

local csTools = Tools
Tools = {}


setmetatable( Tools, { __index = function ( t, key ) return csTools[ key ] end } )




function PrintTable( tb , title, bNotSort )
	local tabNum = 0
	local function stab( numTab )
		return string.rep("    ", numTab)
	end
	local str = {}


	local function _printTable( t )
		table.insert( str, "{" )
		tabNum = tabNum + 1

		local keys = {}
		for k, v in pairs( t ) do
			table.insert( keys, k )
		end
		if not bNotSort then table.sort(keys) end

		for _, k in pairs( keys ) do
			local v = t[ k ]
			local kk
			if type(k) == "string" then
				kk = "['" .. k .. "']"
			else
				kk = "[" .. tostring(k) .. "]"
			end
			if type(v) == "table" then
				table.insert( str, string.format('\n%s%s = ', stab(tabNum),kk))
				_printTable( v )
			else
				local vv = ""
				if type(v) == "string" then
					vv = string.format("\"%s\"", v)
				elseif type(v) == "number" or type(v) == "boolean" then
					vv = tostring(v)
				else
					vv = "[" .. type(v) .. "]"
				end

				if type(k) == "string" then
					table.insert( str, string.format("\n%s%-18s = %s,", stab(tabNum), kk, string.gsub(vv, "%%", "?") ) )
				else
					table.insert( str, string.format("\n%s%-4s = %s,", stab(tabNum), kk, string.gsub(vv, "%%", "?") ) )
					--print( string.format("%s%s", stab(tabNum), vv) )
				end

			end
		end
		tabNum = tabNum - 1

		if tabNum == 0 then
			table.insert( str, '}' )
		else
			table.insert( str, '},' )
		end
	end


	local titleInfo = title or "table"
	table.insert( str, string.format("\n----------begin[%s]----------[%s]", titleInfo, os.date("%H:%M:%S") )  )
	if not tb or type(tb) ~= "table" then
		print( tb)
	else
		_printTable( tb )
	end

	table.insert( str, string.format("\n----------end  [%s]----------\n", titleInfo))
	print( table.concat(str, "") )
end

function PrintTime(...)
	print(...,Time.time)
end

function Tools.serializeTable( originTable )
	-- print("serializeTable")
	-- dump(originTable)
	local buffer = {}

	buffer[#buffer + 1] = "return "

	local function _serialize(t, buffer)
		buffer[#buffer + 1] = "{"

		for k, v in pairs(t) do
			buffer[#buffer + 1] = "["
			if type(k) == "number" then
				buffer[#buffer + 1] = k

			elseif type(k) == "string" then
				buffer[#buffer + 1] = "'"
				buffer[#buffer + 1] = k
				buffer[#buffer + 1] = "'"

			elseif type(k) == "table" then
				_serialize(k, buffer)

			elseif type(k) == "boolean" then
				buffer[#buffer + 1] = tostring(k)
			end

			buffer[#buffer + 1] = "]"

			buffer[#buffer + 1] = "="

			if type(v) == "number" then
				buffer[#buffer + 1] = v

			elseif type(v) == "string" then
				buffer[#buffer + 1] = "'"
				buffer[#buffer + 1] = v
				buffer[#buffer + 1] = "'"

			elseif type(v) == "table" then
				_serialize(v, buffer)

			elseif type(v) == "boolean" then
				buffer[#buffer + 1] = tostring(v)
			end

			buffer[#buffer + 1] = ","
		end

		buffer[#buffer + 1] = "}"
	end

	_serialize(originTable, buffer)

	return table.concat(buffer)
end


-- 发送一条全局的通知消息
function sendMsg( msgId, data )
	local dispatcher = EventDispatcher.getInstance()
	dispatcher:dispatchCustomEvent( msgId, data )
end





--------------------------------------------------------------------------------
---------------------------------以下类方法--------------------------------------
--------------------------------------------------------------------------------




function Tools.deserializeTable(text)
	if not text then return nil end

	-- print("deserializeTable", text)
	local func = loadstring( text )
	-- print("func", tostring(func))
	if func then
		return func()
	end
	return nil
end


-- 将秒数转换为制定格式显示的字符串
function Tools.convertSecondToFormatString(second)
	if not second or second <= 0 then
		return "00:00"
	end

	second          = tonumber(second)
	local hour      = math.floor( second / 3600 )
	local minute    = math.floor( ( second - hour * 3600) / 60 )
	local tmsecond  = math.floor(second - hour * 3600 -  minute * 60)

	if hour > 0 then
		return string.format("%02d:%02d:%02d", hour, minute, tmsecond )
	else
		return string.format("%02d:%02d", minute, tmsecond )
	end
end 


function Tools.convertSecondToDate( second )

	if not second or second == 0 then
		return 0,0,0,0
	end

	second = tonumber( second )

	local day = math.floor( second / (3600*24) )
	local hour = math.floor( (second-day*3600*24) / 3600 )
	local minute = math.floor( (second-day*3600*24 - hour*3600) / 60 )
	local tmsecond = math.floor( (second-day*3600*24 - hour*3600 -minute*60 ) )

	return day,hour,minute,tmsecond
end


function Tools.callLaterTime( time, func )
	Timer.New( function ()
		if func then
			func()
		end
	end, time, 1 ):Start()
end




function Tools.getCurrentTime()
	return os.time()
end


-- 获取天数间隔
local DAY_SEC = 3600 * 24
-- return date1 - date2
function Tools.getDeltaDay( date1, date2 )
	local delta = os.time( { year = date1.year, month = date1.month, day = date1.day } ) - os.time( { year = date2.year, month = date2.month, day = date2.day } )
	return delta / DAY_SEC
end


-- return Tools
