local FileLoader = require( "updater.FileLoader" )
local cjson = require( "cjson" )
local ModuleRank = class( "ModuleRank", super )

local DATA_FILE



local sortFunc = function ( a, b )
	return a.score > b.score
end


function ModuleRank:Awake()
	DATA_FILE = ModuleRecord.RECORD_PATH_ROOT .. ".rank"

	self.allWords = MgrCfg.allDatas.random_name_db
end


function ModuleRank:Start()
	ModuleRecord:initFile(DATA_FILE)
	
	self.rankData = {
		ModuleRecord:getCustomData(DATA_FILE, "RANK1", MgrCfg.allDatas.rank_db[1]),
		ModuleRecord:getCustomData(DATA_FILE, "RANK2", MgrCfg.allDatas.rank_db[2]),
		ModuleRecord:getCustomData(DATA_FILE, "RANK3", MgrCfg.allDatas.rank_db[3]),
	}

	for i, data in ipairs(self.rankData) do
		table.sort( data, sortFunc )
	end

	self:downloadRank(RANK_POWER)
	self:downloadRank(RANK_CWDLD)
	self:downloadRank(RANK_DLZBS)

	--[[
		{score = xx, name = xx, roleId = xx, roleLv = xx ,petId = xxx, petLv = xxx, power = xxx}
	]]
end


function ModuleRank:saveData(index)
	ModuleRecord:setCustomData(DATA_FILE, "RANK" .. index, self.rankData[index])
end


function ModuleRank:getData(index)
	return self.rankData[index]
end


function ModuleRank:getPlayerName()
	return ModuleRecord:getCustomData(DATA_FILE, "NAME")
end


function ModuleRank:setPlayerName(name)
	ModuleRecord:setCustomData(DATA_FILE, "NAME", name)
end


function ModuleRank:getPlayerScore(index)
	return ModuleRecord:getCustomData(DATA_FILE, "MY_RANK" .. index, 0)
end


function ModuleRank:setPlayerScore(index, score)
	ModuleRecord:setCustomData(DATA_FILE, "MY_RANK" .. index, score)
end


function ModuleRank:getRandomName()
	local words1 = self.allWords[math.random( 1, #self.allWords )].words1
	local words2 = self.allWords[math.random( 1, #self.allWords )].words2

	return string.format("%s%s", tostring(words1), tostring(words2))
end


function ModuleRank:commit(index, score)
	local myName = self:getPlayerName()
	if not myName then return end

	self:upPlayerScore(index, score)

	local data = self:getData(index)
	local rank = self:getMyRank(index)

	local cur = self:getPlayerScore(index)
	if cur < score then
		self:setPlayerScore(index, score)
	end

	local item
	if rank then
		item = data[rank]
	else
		item = data[#data]
	end

	if item.score < score then
		local roleId = ModuleRole:getCurRoleId()
		local petId = ModuleRole:getCurPetId()

		table.insert(data, {
			name = myName,
			score = score,
			roleId = roleId,
			roleLv = ModuleRole:getRoleLevel(roleId),
			petId = petId,
			petLv = ModuleRole:getRoleLevel(petId),
			uid = Tools.getUID(),
			-- power = (ModuleRole:calcPowerWithRoleId(roleId) + ModuleRole:calcPowerWithRoleId(petId))
		})

		table.sort(data, sortFunc)
		data[#data] = nil

		self:saveData(index)
		return true
	end

	return false
end


function ModuleRank:getMyRank(index)
	local data = self:getData(index)
	local myName = self:getPlayerName()
	if not myName then return end

	if not data then
		printError("can't find rank data by index %s", index)
		return nil
	end

	local uid = Tools.getUID()

	for idx, item in ipairs(data) do
		if item.uid == uid then
			return idx
		end
	end

	return nil
end


--------------------------------------------------------------

local RANK_URI = "http://h005.ultralisk.cn:6112/ultralisk/"
local CMD_UPDATE_SCORE = "/set/setPlayerInfoWithScoreArray"
local CMD_QUERY_SCORE = "/get/getPlayerInoByRankid"

local APP_KEY = "17"

local RANK_ARRY = {}
for i = 1, 20 do table.insert(RANK_ARRY, tostring(i)) end


-- 上传个人数据
function ModuleRank:upPlayerScore(index, score)
	local roleId = ModuleRole:getCurRoleId()
	local petId = ModuleRole:getCurPetId()

	local data = {
		cmd = CMD_UPDATE_SCORE,
		info = {
			uidarray = {Tools.getUID()},
			dataarray = {cjson.encode({
				name = self:getPlayerName(),
				roleId = roleId,
				roleLv = ModuleRole:getRoleLevel(roleId),
				petId = petId,
				petLv = ModuleRole:getRoleLevel(petId),
			})},
			scorearray = {tostring(score)},
			rankid = RANK_DATA[index].id,
		}
	}

	local josnStr = cjson.encode(data)
	if josnStr then
		self:request(josnStr, function ( www )
			print("up score done.", www.text)
		end, function ( www )
			print("up score fail")
			print(www.error)
		end)
	end
end


-- 下载排行榜
function ModuleRank:downloadRank(index)
	local data = {
		cmd = CMD_QUERY_SCORE,
		info = {
			rankarry = RANK_ARRY,
			rankid = RANK_DATA[index].id,
			sorttype = "REVRANGE",
		}
	}

	local josnStr = cjson.encode(data)
	-- print("downloadRank:", josnStr)
	if josnStr then
		self:request(josnStr, function (www)
			self:refreshRankData(www, index)
		end, function ( www )
			print("fail download.")
			print(www.error)
		end)
	end
end


function ModuleRank:refreshRankData(www, index)
	local josnStr = www.text
	-- print("refreshRankData", josnStr)
	local data = cjson.decode(josnStr)
	if not data then return end

	if tonumber(data.code) ~= 1 then return end

	local ranks = data.msg
	if not ranks then return end

	local curRanks = self:getData(index)

	for rank, rData in pairs(ranks) do
		if rData.data then
			local playerData = cjson.decode(rData.data)
			table.insert(curRanks, {
				name = playerData.name,
				score = tonumber(rData.score),
				roleId = playerData.roleId,
				roleLv = playerData.roleLv,
				petId = playerData.petId,
				petLv = playerData.petLv,
				uid = tostring(rData.uid),
			})
		end
	end

	table.sort(curRanks, sortFunc)
	local len = #curRanks
	for i = 21, len do
		curRanks[i] = nil
	end

	-- self:saveData(index)
end


function ModuleRank:request(dataJson, sucCallback, failCallback)
	local form = UnityEngine.WWWForm.New()
	form:AddField("signkey", "ultralisk")
	form:AddField("appid", APP_KEY)
	form:AddField("channel", "xiaomi")
	form:AddField("platform", "pc")
	form:AddField("data", dataJson)

	coroutine.start( function ()
		local www = WWW.New( RANK_URI, form )

		coroutine.www(www)

		if not www.error or www.error == "" then
			if sucCallback then sucCallback( www ) end
		else
			if failCallback then failCallback( www ) end
		end
		
		www:Dispose()
		www = nil
	end )
end













return ModuleRank