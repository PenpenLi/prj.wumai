local CSClass = {}



local CLASS_SPACE = ""
local FIELD_SPCAE = "    "


function CSClass.New()
	local cs = {
		-- csText = "\n\n",
		usings = {},
		sField = {},
		iField = {},
		fField = {},
		bField = {},
		cCustom = {},
	}

	return setmetatable(cs, {__index = CSClass})
end


function CSClass:addUsing(name)
	table.insert(self.usings, name)
end


function CSClass:addNameSpace(name)
	if self.nameSpace then print("name space is already exists.") return end
	self.nameSpace = name
end


function CSClass:addClassName(name)
	if self.className then print("class name is already exists.") return end
	self.className = name
end


function CSClass:addStringField(name)
	table.insert(self.sField, name)
end


function CSClass:addIntField(name)
	table.insert(self.iField, name)
end


function CSClass:addFloatField(name)
	table.insert(self.fField, name)
end


function CSClass:addBoolField(name)
	table.insert(self.bField, name)
end


function CSClass:addCustom(str)
	table.insert(self.cCustom, FIELD_SPCAE .. str)
end



-- startFuncName & addFuncContent & endFuncName是一个方法组，不能分开使用
function CSClass:startFunction(func)
	self.funcText = string.format("%s%s\n%s{", FIELD_SPCAE, func, FIELD_SPCAE)
end


function CSClass:addFuncContent(str)
	self.funcText = string.format("%s\n%s%s", self.funcText, FIELD_SPCAE .. FIELD_SPCAE, str)
end


function CSClass:endFunction()
	if not self.funcText then return end

	table.insert(self.cCustom, string.format("%s\n%s}\n", self.funcText, FIELD_SPCAE))
	self.funcText = nil
end





-- function CSClass:addEmptyLine()
-- 	self.csText = string.format("%s\n", self.csText)
-- end


function CSClass:save(fileName)
	if not self.className then print("can't find class name.") return end


	-- if self.nameSpace then
	-- 	CLASS_SPACE = CLASS_SPACE .. FIELD_SPCAE
	-- 	FIELD_SPCAE = FIELD_SPCAE .. FIELD_SPCAE
	-- end

	local csText = ""

	-- 所有字段预设
	for _, name in ipairs(self.sField) do
		csText = string.format("%s%spublic string %s = null;\n", csText, FIELD_SPCAE, name)
	end
	csText = csText .. "\n"

	for _, name in ipairs(self.iField) do
		csText = string.format("%s%spublic int %s = 0;\n", csText, FIELD_SPCAE, name)
	end
	csText = csText .. "\n"

	for _, name in ipairs(self.fField) do
		csText = string.format("%s%spublic float %s = 0f;\n", csText, FIELD_SPCAE, name)
	end
	csText = csText .. "\n"

	for _, name in ipairs(self.bField) do
		csText = string.format("%s%spublic bool %s = false;\n", csText, FIELD_SPCAE, name)
	end
	csText = csText .. "\n"

	for _, str in ipairs(self.cCustom) do
		csText = string.format("%s\n%s", csText, str)
	end


	-- 填充class
	csText = string.format("%spublic class %s\n%s{\n%s\n%s}", CLASS_SPACE, self.className, CLASS_SPACE, csText, CLASS_SPACE)

	-- 填充nameSpace
	if self.nameSpace then
		csText = string.format("namespace %s\n{\n%s\n}", self.nameSpace, csText)
	end

	-- 填充using
	for idx, name in ipairs(self.usings) do
		if idx == 1 then
			csText = string.format("using %s;\n\n%s", name, csText)
		else
			csText = string.format("using %s;\n%s", name, csText)
		end
	end

	local file = io.open(fileName, "wb")
	assert(file)
	file:write(csText)
	file:close()
end




return CSClass