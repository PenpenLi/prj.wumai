--- 随机数
-- Anchor : Canyon
-- Time : 2016-05-25

local M = {};

function M:onSeek()
	local _time = os.time();
	local _seed = tostring(_time):reverse():sub(1, 6);
	math.randomseed(_seed);
end

-- 保留小数
function M:retainDecimal(v,fnum)
	if fnum and fnum >= 0 then
		local fmt = "%.".. fnum .. "f"
		v = string.format(fmt, v);
		v = tonumber(v);
	end
	return v;
end

-- isSeek 是否重置随机种子
-- base : 随机数值最大值
-- fnum : 保留小数
function M:rnd(isSeek,base,fnum)
	if isSeek then
		self:onSeek();
	end
	base = base or 10000;
	local v = math.random() * base;
	return self:retainDecimal(v,fnum);
end

function M:rndTrue(base,fnum)
	return self:rnd(true,base,fnum);
end

function M:rndFalse(base,fnum)
	return self:rnd(false,base,fnum);
end

function M:rndW()
	return self:rndTrue();
end

function M:rndK()
	return self:rndTrue(1000);
end

function M:rndB()
	return self:rndTrue(100);
end

RndEx = M;

return M;