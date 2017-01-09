
--输出日志--
function log(str)
	Util.Log(str);
end

--错误日志--
function logError(str) 
	Util.LogError(str);
end

--警告日志--
function logWarn(str) 
	Util.LogWarning(str);
end



-- local DEBUG = AppConst.DebugMode
function printf(fmt, ...)
  -- if DEBUG then
	print( string.format(tostring(fmt), ...))
  -- end
end




function printLog(tag, fmt, ...)
	local t = {
		"[",
		string.upper(tostring(tag)),
		"] ",
		string.format(tostring(fmt), ...)
	}
	if tag == "ERR" then
		table.insert(t, debug.traceback("", 2))
		local str = table.concat(t)
		logError(str)
		return
	elseif tag == "WARN" then
		logWarn(table.concat(t))
		return
	end
	
	print(table.concat(t))
end

function printError(fmt, ...)
	printLog("ERR", fmt, ...)
end

function printDebug(fmt, ...)
	if DEBUG then
		printLog("DEBUG", fmt, ...)
	end
end

function printInfo(fmt, ...)
	if DEBUG then
		printLog("INFO", fmt, ...)
	end
end

function printWarn(fmt, ...)
	printLog("WARN", fmt, ...)
end




--查找对象--
function find(str)
  return GameObject.Find(str);
end

function destroy(obj)
  GameObject.Destroy(obj);
end

function newObject(prefab)
  return GameObject.Instantiate(prefab);
end


function child(str)
  return transform:FindChild(str);
end

function subGet(childNode, typeName)    
  return child(childNode):GetComponent(typeName);
end

function findPanel(str) 
  local obj = find(str);
  if obj == nil then
	error(str.." is null");
	return nil;
  end
  return obj:GetComponent("BaseLua");
end



function handler( obj, method )
	return function( ... )
		return method( obj, ... )
	end
end

-- 发送一条全局的通知消息
function sendMsg( msgId, data )
  local dispatcher = EventDispatcher.getInstance()
  dispatcher:dispatchCustomEvent( msgId, data )
end