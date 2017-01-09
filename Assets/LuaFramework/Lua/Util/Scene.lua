
--[[

	场景基类


]]



local M = class( "Scene" )


function M:ctor()
	self.loadingList = {}
	
end

function M:getLoadingList()
	return self.loadingList
end

function M:onEnter()

end



function M:onExit()


end

return M