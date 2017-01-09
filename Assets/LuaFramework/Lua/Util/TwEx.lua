--- tween动作工具Ex
-- Anchor : Canyon
-- Time : 2016-06-08


local M = {};

function M:bindPlayTween(gobj,callFinish)
	local _tw = gobj:GetComponent("UIPlayTween");
	if isAdd == true or nil == _tw then
		_tw = gobj:AddComponent("UIPlayTween");
	end

	if callFinish then
		_tw.onFinished:Add(EventDelegate.New(callFinish));
	end

	return _tw;
end

function M:tweenScale(gobj,scaleFrom,scaleTo,delay,duration,isAdd)
	local _tw = gobj:GetComponent("TweenScale");
	if isAdd == true or nil == _tw then
		_tw = gobj:AddComponent("TweenScale");
	end

	_tw.from = Vector3.New(scaleFrom, scaleFrom, scaleFrom)
	_tw.to = Vector3.New(scaleTo, scaleTo, scaleTo)
	_tw.delay = delay
	_tw.duration = duration
	_tw.method = UITweener.Method.EaseInOut
	if not isAdd then
		_tw:ResetToBeginning();
	end
	_tw.ignoreTimeScale = false;
	_tw.enabled = false;
	return _tw;
end

function M:tweenScalePlay(gobj,scaleFrom,scaleTo,delay,duration,isAdd)
	local _tw = self:tweenScale(gobj,scaleFrom,scaleTo,delay,duration,isAdd);
	_tw:Play(true);
	return _tw;
end

function M:tweenPostion(gobj,form,to,delay,duration,isAdd)
	local _tw = gobj:GetComponent("TweenPosition");
	if isAdd == true or nil == _tw then
		_tw = gobj:AddComponent("TweenPosition");
	end

	_tw.from = form
	_tw.to = to
	_tw.delay = delay
	_tw.duration = duration
	_tw.method = UITweener.Method.EaseInOut
	if not isAdd then
		_tw:ResetToBeginning();
	end
	_tw.ignoreTimeScale = false;
	_tw.enabled = false;
	return _tw;
end

function M:tweenPostionPlay(gobj,form,to,delay,duration,isAdd)
	local _tw = self:tweenPostion(gobj,form,to,delay,duration,isAdd)
	_tw:Play(true);
	return _tw;
end

function M:tweenTrsf(gobj,form,to,delay,duration,isAdd)
	local _tw = gobj:GetComponent("TweenTransform");
	if isAdd == true or nil == _tw then
		_tw = gobj:AddComponent("TweenTransform");
	end

	_tw.from = form
	_tw.to = to
	_tw.delay = delay
	_tw.duration = duration
	_tw.method = UITweener.Method.EaseInOut
	if not isAdd then
		_tw:ResetToBeginning();
	end
	_tw.ignoreTimeScale = false;
	_tw.enabled = false;
	return _tw;
end

function M:tweenTrsfPlay(gobj,form,to,delay,duration,isAdd)
	local _tw = self:tweenTrsf(gobj,form,to,delay,duration,isAdd)
	_tw:Play(true);
	return _tw;
end

TwEx = M;

return M;