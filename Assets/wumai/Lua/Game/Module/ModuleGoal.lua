
local ModuleGoal = class( "ModuleGoal")













-- 内部初始化
function ModuleGoal:Awake()
	self.goalStateChangeListener = nil
	self.goalData = ModuleRecord:getData( "GOAL" ) or {lastGoalEntryId = 0}

	self.allGoalDb = MgrCfg.allDatas.goal_db

	self.notifyQuestIds = {}
	--[[
	{
		actionId = {
			targetId = {
				goal1 = { goalId = goalId1, questId = questId1, commits = count1 },
				goal2 = { goalId = goalId2, questId = questId2, commits = count2 },
			},
		},
		lastGoalEntryId = 0,
	}
	--]]
end


function ModuleGoal:saveData()
	ModuleRecord:setData( "GOAL", self.goalData )
end


-- 全局初始化
function ModuleGoal:Start()
end


function ModuleGoal:getGoalDb( goalId )
	return self.allGoalDb[ goalId ] or printError( "can't find goal db by id %s", goalId )
end


function ModuleGoal:printAllGoal()
	PrintTable( self.goalData, "goalData" )
end


function ModuleGoal:setGoalStateChangeListener( listener )
	self.goalStateChangeListener = listener
end


-- 设置需要即使通知的任务id(当任务更新时发送消息)
function ModuleGoal:addNotifyQuestId( questId )
	self.notifyQuestIds[questId] = true
end


function ModuleGoal:clearNotify()
	self.notifyQuestIds = {}
end


function ModuleGoal:getGoalList( actionId, targetId, createIfNotExists )
	local actionList = self.goalData[ actionId ]
	if not actionList then
		if createIfNotExists then
			actionList = {}
			self.goalData[ actionId ] = actionList
			self:saveData()
			-- printf( "create action %s", actionId )
		else
			-- printWarn( "can't find action list by actionId:%s", actionId )
			return nil
		end
	end

	if not actionList[ targetId ] then
		if createIfNotExists then
			actionList[ targetId ] = {}
			self:saveData()
			-- printf( "create action[%s] by targetId:%s", actionId, targetId )
		else
			-- printWarn( "can't find action[%s] by targetId:%s", actionId, targetId )
			return nil
		end
	end

	return actionList[ targetId ]
end


-- @questId 目标对应的任务id
-- @return 返回一个目标实例 
function ModuleGoal:registerGold( goalId, questId )
	local db = self:getGoalDb( goalId )
	if not db then return end
	local goalData = self.goalData

	local entryId = goalData.lastGoalEntryId + 1
	local goalList = self:getGoalList( db.actionId, db.targetId, true )
	goalList[ entryId ] = { goalId = goalId, questId = questId, commits = 0 }
	goalData.lastGoalEntryId = entryId
	self:saveData()

	return entryId
end


function ModuleGoal:unregister( goalId, entryId )
	local db = self:getGoalDb( goalId )
	if not db then return end
	local goalList = self:getGoalList( db.actionId, db.targetId, false )

	if goalList then
		goalList[ entryId ] = nil
		self:saveData()
	end
end


--@param reset 重置数量为count（会重置通用行为数量）
function ModuleGoal:commit( actionId, targetId, count, reset )
	targetId = targetId or 0
	count = count or 1

	-- targetId 为0时表示同类目标的累计统计
	if targetId ~= 0 then
		self:commit( actionId, 0, count, reset )
	end

	local goalList = self:getGoalList( actionId, targetId, false )

	if not goalList then return end
	local db
	for entryId, goal in pairs( goalList ) do
		local db = self:getGoalDb( goal.goalId )
		if db then
			local lastState = self:_isDone( goal.commits, db.value, db.type )
			if reset then
				goal.commits = count
			else
				goal.commits = goal.commits + count
			end

			if self:_isDone( goal.commits, db.value, db.type ) ~= lastState then
				self:onStateGoalChange( goal.questId, entryId, not lastState )
			end

			-- 目标更新后，通知任务有更新
			self:notifyQuest( goal.questId, goal.goalId )

			self:saveData()
		end
	end
end


-- @return 当前值、标准值
function ModuleGoal:getValue( goalId, entryId )
	local db = self:getGoalDb( goalId )
	if not db then return 0 end

	local goalList = self:getGoalList( db.actionId, db.targetId, false )
	if not goalList then
		printWarn( "can't find goal list by goalId %s", goalId )
		return 0, 0
	end

	local goal = goalList[ entryId ]
	if not goal then
		printWarn( "can't find goal entry by entryId %s", entryId )
		return 0, 0
	end

	return goal.commits, db.value
end


function ModuleGoal:getDbValue( goalId )
	local db = self:getGoalDb( goalId )
	if not db then return 0 end

	return db.value
end


function ModuleGoal:getActionId( goalId )
	local db = self:getGoalDb( goalId )
	if not db then return nil end

	return db.actionId
end


function ModuleGoal:isDone( goalId, entryId )
	local db = self:getGoalDb( goalId )
	if not db then return false end
	
	local commits = self:getValue( goalId, entryId )

	return self:_isDone( commits, db.value, db.type )
end


function ModuleGoal:_isDone( commits, value, type )
	if type == "min" then
		return commits >= value
	elseif type == "max" then
		return commits <= value
	else
		printError( "can't find goal type %s", type )
	end

	return false
end


function ModuleGoal:notifyQuest( questId, goalId )
	if self.notifyQuestIds[questId] then
		sendMsg( "MSG_QUEST_UPDATE", { questId = questId, goalId = goalId } )
	end
end


function ModuleGoal:onStateGoalChange( questId, entryId, isDone )
	if self.goalStateChangeListener then
		self.goalStateChangeListener( questId, entryId, isDone )
	end
end









return ModuleGoal
