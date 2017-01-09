--[[
	2016 , ck(abner)
	自定义任务执行队列 version 1.0
	可以设置任务同时进行的数量
	通过add task 来添加需要执行的任务

	缺点:
		执行任务时候的参数必须封装到一个table中供外部调用
	同时在执行任务的时候需要要把当前任务的完成回调传到任务执行方法中

	改进:
		需要封装一个任务的类,在任务类中将任务注册到当前任务队列中,自动处理任务完成的回调
]]

local CustomQueue = class( "CustomQueue" )

local interval = 1/30

function CustomQueue:ctor()

	self._maxAsyncCnt = 20

	self._asyncTask = {}	
	self._runningCount = 0
	self._timer = Timer.New( handler( self, self._onEnterFrame), interval, -1 )
end






-- 设置最大运行数
function CustomQueue:SetMaxRunningTask( value )
	self._maxAsyncCnt = value
end




-- 添加任务
function CustomQueue:AddTask( handler, param )
	table.insert( self._asyncTask, {
		handler = handler,
		param = param or {},
	})
end



function CustomQueue:Start()
	self._timer:Start()
end



function CustomQueue:Stop()
	self.timer:Stop()
end



-- 完成回调
function CustomQueue:_doneCallback()
	self._runningCount = self._runningCount - 1
end



function CustomQueue:_onEnterFrame()
	if #self._asyncTask > 0 then
		while true do
			if self._runningCount >= self._maxAsyncCnt then
				break
			end

			local task = table.remove( self._asyncTask, 1)
			if task then
				local _handler = task.handler
				local param   = task.param
				
				_handler( param, handler( self, self._doneCallback) )

				self._runningCount = self._runningCount + 1
			else
				break
			end
		end
	end
end


return CustomQueue