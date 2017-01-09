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



local _htmlSpecialCharsTable = {}
_htmlSpecialCharsTable["&"] = "&amp;"
_htmlSpecialCharsTable["\""] = "&quot;"
_htmlSpecialCharsTable["'"] = "&#039;"
_htmlSpecialCharsTable["<"] = "&lt;"
_htmlSpecialCharsTable[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(_htmlSpecialCharsTable) do
        input = string_gsub(input, k, v)
    end
    return input
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(_htmlSpecialCharsTable) do
        input = string_gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string_gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string_gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string_gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(input, delimiter)
    input = tostring(input)
    if input == nil or input == "" then
    return {};
    end;
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string_find(input, delimiter, pos, true) end do
        table_insert(arr, string_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table_insert(arr, string_sub(input, pos))
    return arr
end

function string.ltrim(input)
    return string_gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string_gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string_gsub(input, "^[ \t\n\r]+", "")
    return string_gsub(input, "[ \t\n\r]+$", "")
end

function string.ucfirst(input)
    return string_upper(string_sub(input, 1, 1)) .. string_sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. table_format("%02X", string_byte(char))
end
function string.urlencode(input)
    input = string_gsub(tostring(input), "\n", "\r\n")
    input = string_gsub(input, "([^%w%.%- ])", urlencodechar)
    return string_gsub(input, " ", "+")
end

local _checknumber = checknumber
function string.urldecode(input)
    input = string_gsub (input, "+", " ")
    input = string_gsub (input, "%%(%x%x)", function(h) return string_char(_checknumber(h, 16)) end)
    input = string_gsub (input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len  = string_len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function string.formatByNum(num,lens)
    local ret = "";
    lens = tonumber(lens) or 5;
    local tmp = tostring(num);
    lens = lens - #tmp;
    
    if lens > 0 then
        for i = 1,lens do
            ret = ret .. "0";
        end;
    end
    return ret .. num;
end



function string.u8foreach(str, callback)
    if not str or not callback then return end

    local i = 1
    local multiLen = #str

    local string_sub = string.sub
    local string_byte = string.byte

    local b, skip, i2
    while i <= multiLen do
        b = string_byte( str, i, i )
        skip = 0

        if b >= 0xf0 and b <= 0xf7 then     skip = 3
        elseif b >= 0xe0 then               skip = 2
        elseif b >= 0xc0 then               skip = 1
        end

        i2 = i + skip
        if callback( string_sub( str, i, i2 ), i, i2 ) then
            break
        end
        i = i2 + 1
    end
end

function string.u8len(str)
    local len = 0
    string.u8foreach(str, function() len = len + 1 end)
    return len
end

function string.u8sub(str, idx1, idx2)
    if not str or not idx1 then
        return nil
    end
    idx2 = idx2 or 0xffffffff
    if idx1 > idx2 then
        return nil
    end
    local loc = 1
    local st, ed = 1,1
    local function _each(ch, starti, endi )
        if loc == idx1 then
            st = starti
        end
        if loc <= idx2 then
            ed = endi
        else
          return true
        end
        loc = loc + 1
    end
    string.u8foreach(str, _each)
    return string.sub(str, st, ed)
end