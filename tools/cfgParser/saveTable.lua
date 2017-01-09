local function SaveTableContent(file, obj)
	local szType = type(obj);
	--print(szType);
	if szType == "number" then
		file:write(obj);
	elseif szType == "boolean" then
		file:write(tostring(obj));
	elseif szType == "string" then
		-- %q 会自动匹配转义符并自动转义，这里需要的是导出表中的原始数据
		-- file:write(string.format("%q", obj));
		file:write(string.format("\"%s\"", obj));
	elseif szType == "table" then
		--把table的内容格式化写入文件
		file:write("{");
		for i, v in pairs(obj) do
			file:write("[");
			SaveTableContent(file, i);
			file:write("]=");
			SaveTableContent(file, v);
			file:write(",");
		end
		file:write("}");
	else
		error("can't serialize a "..szType);
	end
end


function SaveTable(tab, fileName)
	local file = io.open(fileName, "wb");
	assert(file);
	file:write("return ");
	--file:write("cha[1] = \n");
	SaveTableContent(file, tab);
	file:write("\n");
	file:close();
end