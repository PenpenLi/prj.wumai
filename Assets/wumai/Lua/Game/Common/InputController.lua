local M = class( "InputController" )

--[[
                          
                            R2
                          
      V                      Y
  -H  o  H                X      
     -V        L1  R1   A    B  
                          
                                                
--]]

M.H = "Horizontal"
M.V = "Vertical"

M.A = KeyCode.N
M.B = KeyCode.M
M.X = KeyCode.J
M.Y = KeyCode.K
M.L1 = KeyCode.Q
M.L2 = KeyCode.E
M.R1 = KeyCode.B
M.R2 = KeyCode.I

function M:ctor()

	self.axisTable = {
		[M.H] = 0,
		[M.V] = 0,
	}

	self.keyTable = {
		[M.A] = false,
		[M.B] = false,
		[M.X] = false,
		[M.Y] = false,
		[M.L1] = false,
		[M.L2] = false,
		[M.R1] = false,
		[M.R2] = false,
	}
end

function M:getAxis(axis)
	return self.axisTable[axis] ~= 0 and self.axisTable[axis] or Input.GetAxis (axis)
end

function M:setAxis(axis, value)
	self.axisTable[axis] = value
end

function M:getKey(key)
	return self.keyTable[key] or Input.GetKey(key)
end

function M:getKeyDown(key)
	return Input.GetKeyDown(key)
end

function M:getKeyUp(key)
	return Input.getKeyUp(key)
end

function M:setKeyDown(key)
	self.keyTable[key] = true
end

function M:setKeyUp(key)
	self.keyTable[key] = false
end


return M