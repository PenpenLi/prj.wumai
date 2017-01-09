--[[
	File Desc:任务

	开启一个任务需要注册任务的目标
	任务完成后，需要注销任务对应的目标
]]


local function getQuestValue( state )
	if state == QUEST_STATE_COMMITABLE then
		return 10000000
	elseif state == QUEST_STATE_FINISHED then
		return -10000000
	else
		return 0
	end
end


local function sortFunction ( id1, id2 )
	local state1 = ModuleQuest:getQuestState( id1 )
	local state2 = ModuleQuest:getQuestState( id2 )

	local db1 = ModuleQuest:getQuestDb( id1 )
	local db2 = ModuleQuest:getQuestDb( id2 )

	-- if state1 == QUEST_STATE_COMMITABLE and state2 == QUEST_STATE_COMMITABLE then
	-- 	return db1.order >= db2.order
	-- elseif state1 == QUEST_STATE_COMMITABLE then
	-- 	return true
	-- elseif state2 == QUEST_STATE_COMMITABLE then
	-- 	return false
	-- -- elseif state1 == QUEST_STATE_FINISHED and state2 == QUEST_STATE_FINISHED then
	-- -- 	return db1.order >= db2.order
	-- -- elseif state1 == QUEST_STATE_FINISHED then
	-- -- 	return false
	-- -- elseif state2 == QUEST_STATE_FINISHED then
	-- -- 	return true
	-- end
	local v1 = getQuestValue( state1 ) + db1.order
	local v2 = getQuestValue( state2 ) + db2.order
	return v1 > v2
end





local ModuleQuest = class( "ModuleQuest", super )




function ModuleQuest:Awake()
	self.questData = ModuleRecord:getData( "QUEST" ) or {}
	--[[
	{
		questId = { state = xx, goals = {}, first = false }
	}
	--]]

	local allDb = MgrCfg.allDatas.quest_db
	self.allQuestDb = allDb

	-- 接所有成就任务
	-- QUEST_TYPE_NORMALL
	-- QUEST_TYPE_ACHIEVEMENT
	-- QUEST_TYPE_DAILY

	local dailyQuestActive = ModuleSwitch.dailyActive

	for id, db in pairs( allDb ) do
		if db.type == QUEST_TYPE_ACHIEVEMENT or
			db.type == QUEST_TYPE_SIGN or
			db.type == QUEST_TYPE_STATISTICS then
			-- 接成就、统计、签到
			if self:getQuestState( id ) == QUEST_STATE_NONE then
				self:accept( id )
			end
		elseif dailyQuestActive and (db.type == QUEST_TYPE_DAILY or db.type == QUEST_TYPE_DLZBS)then
			-- 接日常任务、斗龙争霸赛
			self:accept( id )
		end
	end

	local allQuestByType = {{},{},{},{},{},{},{}}
	self.allQuestByType = allQuestByType

	local db
	for questId, data in pairs( self.questData ) do
		db = self:getQuestDb( questId )
		-- 前置任务仅用来显示
		self:checkVisible(db)
	end
end


function ModuleQuest:checkVisible(db)
	local visible = true

	-- 前置任务仅用来显示
	for _, preId in ipairs( db.preIds ) do
		if self:getQuestState( preId ) < QUEST_STATE_COMMITABLE then
			visible = false
			break
		end
	end
	
	if visible then
		table.insert(self.allQuestByType[db.type], db.id)
	end
end


function ModuleQuest:getQuestDb( id )
	return self.allQuestDb[ id ] or printError( "can't find quest db by id %s", id )
end


-- 调试
function ModuleQuest:printAllQuest()
	PrintTable( self.questData, "questData" )
end


function ModuleQuest:saveData()
	ModuleRecord:setData( "QUEST", self.questData )
end


function ModuleQuest:Start()
	ModuleGoal:setGoalStateChangeListener( handler( self, self.onGoalStateChange ) )
end


-- 接任务，同一个任务第二次被接会被重置
function ModuleQuest:accept( questId )
	-- printf( "---> accept quest %s", questId )
	local db = self:getQuestDb( questId )
	if not db then return end

	-- 检查前置任务
	-- for _, preId in ipairs( db.preIds ) do
	-- 	if self:getQuestState( preId ) ~= QUEST_STATE_FINISHED then return end
	-- end

	local first = true

	-- 若当前任务存在，则解除旧目标
	local quest = self.questData[ questId ]
	if quest then
		for idx, entryId in ipairs( quest.goals ) do
			ModuleGoal:unregister( db.goads[ idx ], entryId )
		end

		if quest.state == QUEST_STATE_FINISHED then
			first = false
		else
			first = quest.first
		end
	end


	-- 创建目标
	local goals = {}
	for _, goalId in ipairs( db.goads ) do
		local entryId = ModuleGoal:registerGold( goalId, questId )
		if not entryId then
			printError( "can't accept quest[%s], because register gold[%s] error", questId, goalId )
			self.questData[ questId ] = nil
			return
		end
		table.insert( goals, entryId )
	end

	-- 若没有目标，则可以直接提交
	local state = #goals ~= 0 and QUEST_STATE_UPDATEABLE or QUEST_STATE_COMMITABLE
	
	self.questData[ questId ] = { state = state, goals = goals, first = first }

	self:saveData()
	-- printf( "accept quest success %s", questId )
end


function ModuleQuest:getQuestState( questId )
	local quest = self.questData[ questId ]
	if not quest then return QUEST_STATE_NONE, true end

	return quest.state, quest.first
end


function ModuleQuest:isPassed( questId )
	local state, first = self:getQuestState( questId )
	return not first or state == QUEST_STATE_FINISHED
end


function ModuleQuest:isDone( questId )
	local state = self:getQuestState( questId )
	return state == QUEST_STATE_FINISHED
end


function ModuleQuest:isCommitable(questId)
	local state = self:getQuestState(questId)
	return state == QUEST_STATE_COMMITABLE
end


-- @param includeCurValue 是否包含当前值
-- @return 返回任务完成情况{ cur1, conf1, cur2, conf2 ... }, goalIds
function ModuleQuest:getGoalValue( questId, includeCurValue )
	local quest = self.questData[ questId ]
	local db = self:getQuestDb( questId )

	local values = {}
	if not db then return values end

	-- 如果没有任务，则返回db值
	if not quest then
		if includeCurValue then
			printError( "include cur value but quest is not accept %s", questId )
		end

		for _, gid in ipairs( db.goads ) do
			if includeCurValue then
				table.insert( values, 0 )
			end
			table.insert( values, ModuleGoal:getDbValue( gid ) )
		end

		return values
	end

	for idx, entryId in ipairs( quest.goals ) do
		local cur, value = ModuleGoal:getValue( db.goads[idx], entryId )
		if includeCurValue then
			table.insert( values, cur )
		end
		table.insert( values, value )
	end

	return values, db.goads
end


function ModuleQuest:getGoalDbValue( questId )
	local db = self:getQuestDb( questId )
	local values = {}
	for idx, id in ipairs( db.goads ) do
		table.insert( values, ModuleGoal:getDbValue( id ) )
	end

	return values
end


function ModuleQuest:onGoalStateChange( questId, entryId, isDone )
	local quest = self.questData[ questId ]
	if not quest or quest.state ~= QUEST_STATE_UPDATEABLE then return end

	local db = self:getQuestDb( questId )

	for idx, eId in ipairs( quest.goals ) do
		-- 查看所有目标
		if eId ~= entryId then
			-- 如果目标状态不一样则返回（此时还不能确定任务是否完成）
			if ModuleGoal:isDone( db.goads[idx], eId ) ~= isDone then
				return
			end
		end
	end

	self:onQuestFinish( questId, isDone )
end


-- 预览奖励
function ModuleQuest:getReward( questId, forPreview )
	local db = self:getQuestDb( questId )
	if not db then return {} end

	local quest = self.questData[ questId ]

	local first = true
	if quest then
		first = quest.first
	end

	local items
	if first then
		items = ModuleItem:unpackItem( db.firstReward[1], db.firstReward[2], forPreview )
	else
		items = ModuleItem:unpackItem( db.aginReward[1], db.aginReward[2], forPreview )
	end

	return items
end


function ModuleQuest:onQuestFinish( questId, isDone )
	local quest = self.questData[ questId ]
	if not quest or quest.state ~= QUEST_STATE_UPDATEABLE then return end

	if isDone then
		-- 任务成功
		quest.state = QUEST_STATE_COMMITABLE
	else
		-- 任务失败
		quest.state = QUEST_STATE_FAIL
	end

	-- 解除目标
	local db = self:getQuestDb( questId )
	for idx, eId in ipairs( quest.goals ) do
		ModuleGoal:unregister( db.goads[idx], eId )
	end

	quest.goals = {}

	sendMsg( "MSG_QUEST_COMPLETE", questId )
	-- printf( "任务id:%s 完成情况:%s", questId, isDone )

	if db.type == QUEST_TYPE_ACHIEVEMENT or db.type == QUEST_TYPE_DAILY then
		ModuleAlert:alertText( self:getQuestDesc( questId ) )
	end

	self:saveData()
end


-- 提交任务(自动获取奖励)
-- @return 是否提交成功，是否首次提交，任务奖励
function ModuleQuest:commit( questId, notGet )
	local quest = self.questData[ questId ]
	if not quest then return false, false, {} end

	local db = self:getQuestDb( questId )

	if quest.state == QUEST_STATE_UPDATEABLE then
		-- 检查所有目标
		local isDone = true
		for idx, eId in ipairs( quest.goals ) do
			if not ModuleGoal:isDone( db.goads[idx], eId ) then
				-- 任务失败
				isDone = false
				break
			end
		end

		self:onQuestFinish( questId, isDone )
	end

	if quest.state ~= QUEST_STATE_COMMITABLE then return false, false, {} end

	-- 发放奖励
	local first = quest.first
	local items

	if quest.first then
		-- quest.first = false
		if not notGet then
			items = ModuleItem:addWrapItem( db.firstReward[1], db.firstReward[2] )
		else
			items = ModuleItem:unpackItem( db.firstReward[1], db.firstReward[2], false )
		end
	else
		if not notGet then
			items = ModuleItem:addWrapItem( db.aginReward[1], db.aginReward[2] )
		else
			items = ModuleItem:unpackItem( db.aginReward[1], db.aginReward[2], false )
		end
	end

	quest.state = QUEST_STATE_FINISHED
	self:saveData()

	-- 尝试接后置任务
	for _, nextId in ipairs( db.nextIds ) do
		-- self:accept( nextId )

		-- 更新任务列表(这里默认后置任务是同一类型)
		local list = self.allQuestByType[db.type]
		if list then
			local exists = false
			for i, id in ipairs(list) do
				if id == nextId then
					exists = true
					break
				end
			end

			if not exists then
				self:checkVisible(self:getQuestDb(nextId))
				table.sort(list, sortFunction)
			end
		end

	end

	sendMsg( "MSG_QUEST_FINISH", questId )

	return true, first, items
end


-- 快速消费强制完成任务
function ModuleQuest:quickCommit( questId )
	-- local state, first = self:getQuestState( questId )
	-- if state == QUEST_STATE_NONE then return false end

	-- local payId = self:getQuestPayId( questId )

	-- ModuleAlert:alertGift( payId, function ( suc )
	-- 	if suc then
	-- 		self:onQuestFinish( questId, true )
	-- 		self:commit( questId )
	-- 	end
	-- end)
end


function ModuleQuest:sortQuestList( qType )
	local allIds = self.allQuestByType[qType]
	if not allIds then return end

	table.sort( allIds, sortFunction )
end


function ModuleQuest:getAllQuestByType( qType, bSort )
	if bSort then
		self:sortQuestList( qType )
	end

	return self.allQuestByType[qType]
end


-- 获取任务描述（根据状态返回不同的描述信息）
function ModuleQuest:getQuestDesc( questId )
	local db = self:getQuestDb( questId )
	local state = self:getQuestState( questId )

	if state == QUEST_STATE_NONE then
-- 		local values = self:getGoalValue( questId )
-- 		return string.format( db.desc, unpack( values ) )
		return db.desc
	elseif state == QUEST_STATE_UPDATEABLE then
-- 		local values, goals = self:getGoalValue( questId, true )
-- 		-- 到计时，目前当单目标处理
-- 		if ModuleGoal:getActionId( goals[1] ) == "LIMIYTED_TIME" then
-- 			local left, max = unpack( values )
-- 			local dis = max - left
-- 			return string.format( db.desc2, Tools.convertSecondToFormatString( dis < 0 and 0 or dis ), "" )
-- 		else
-- 			return string.format( db.desc2, unpack( values ) )
-- 		end
		return db.desc
	elseif state == QUEST_STATE_FAIL then
-- 		local values = self:getGoalValue( questId )
-- 		return string.format( db.desc4, unpack( values ) )
		return db.desc .. "(失败)"
	elseif state == QUEST_STATE_COMMITABLE then
-- 		local values = self:getGoalValue( questId )
-- 		-- return string.format( db.desc3, unpack( values ) )
-- 		return string.format( db.desc3, unpack( values ) )
		return db.desc .. "(完成)"
	elseif state == QUEST_STATE_FINISHED then
-- 		local values = self:getGoalValue( questId )
-- 		return string.format( db.desc3, unpack( values ) )
		return db.desc .. "(完成)"
	end
end


function ModuleQuest:getQuestPayId( questId )
	local db = self:getQuestDb( questId )
	if not db then return end
	return db.payId
end


-- 刷新成就、每日任务
function ModuleQuest:refreshQuestTip()
	return self:checkAchTip() or self:checkDailyTip() or self:checkSignTip()
end


function ModuleQuest:checkAchTip()
	for _, id in ipairs( self.allQuestByType[QUEST_TYPE_ACHIEVEMENT] ) do
		if self:getQuestState( id ) == QUEST_STATE_COMMITABLE then
			return true
		end
	end

	return false
end


function ModuleQuest:checkDailyTip()
	for _, id in ipairs( self.allQuestByType[QUEST_TYPE_DAILY] ) do
		if self:getQuestState( id ) == QUEST_STATE_COMMITABLE then
			return true
		end
	end

	return false
end


function ModuleQuest:checkSignTip()
	if not ModuleLottery:getActive(ID_SIGN_LOTTERY) then
		return false
	end

	local all = self:getAllQuestByType(QUEST_TYPE_SIGN, true)
	return self:getQuestState( all[1] ) == QUEST_STATE_COMMITABLE
end








return ModuleQuest
