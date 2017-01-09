--- 时间Ex
-- Anchor : Canyon
-- Time : 2016-06-02

local _os = os;

local M = {};

-- 取得当前时间(单位:second)
function M:getCurrentTime()
  return _os.time();
end

function M:getCurrZero()
  return self:getZeroTime(self:getCurrentTime());
end

-- 当前时间的零点时间
function M:getZeroTime( sec )
  local date = self:format(sec,"*t");
  return _os.time({ year = date.year, month = date.month, day = date.day, hour = 0 });
end

function M:format(sec,fmtStr)
	sec = sec or self:getCurrentTime();
	fmtStr = fmtStr or "%Y%m%d";
	return _os.date(fmtStr,sec);
end

-- 取得当前时间的yyyyMMdd
function M:getYyyyMMdd()
  return self:format();
end

-- 相差时间秒
function M:diffSec(t1,t2)
  t2 = t2 or self:getCurrentTime();
  return _os.difftime(t2,t1);
end

TimeEx = M;

return M;