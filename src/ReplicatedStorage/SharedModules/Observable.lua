local ReplicatedStorage = game:GetService("ReplicatedStorage")
local maidTaskUtils = require(ReplicatedStorage.SharedModules.Maid.MaidTaskUtils)

local ENABLE_STACK_TRACING = true;

local Subscription = {}
Subscription.__index = Subscription
Subscription.ClassName = "Subscription"

local stateTypes = {
	PENDING = "pending";
	FAILED = "failed";
	COMPLETE = "complete";
	CANCELLED = "cancelled";
}

function Subscription.new(fireCallback, failCallback, completeCallback)
    assert(type(fireCallback) == "function" or fireCallback == nil, "Bad fireCallback")

    return setmetatable({
        _state = stateTypes.PENDING;
        _source = ENABLE_STACK_TRACING and debug.traceback() or "";
        _fireCallback = fireCallback;
        _failCallback = failCallback;
		_completeCallback = completeCallback;
    }, Subscription)
end

function Subscription:Fire(...)
	if self._state == stateTypes.PENDING then
		if self._fireCallback then
			self._fireCallback(...)
		end
	elseif self._state == stateTypes.CANCELLED then
		warn("[Subscription.Fire] - We are cancelled, but events are still being pushed")

		if ENABLE_STACK_TRACING then
			print(debug.traceback())
			print(self._source)
		end
	end
end

function Subscription:Fail()
	if self._state ~= stateTypes.PENDING then
		return
	end

	self._state = stateTypes.FAILED

	if self._failCallback then
		self._failCallback()
	end

	self:_doCleanup()
end

function Subscription:Complete()
	if self._state ~= stateTypes.PENDING then
		return
	end

	self._state = stateTypes.COMPLETE
	if self._completeCallback then
		self._completeCallback()
	end

	self:_doCleanup()
end

function Subscription:_doCleanup()
	if self._cleanupTask then
		local task = self._cleanupTask
		self._cleanupTask = nil
		maidTaskUtils.doTask(task)
	end
end

function Subscription:_giveCleanup(task)
	assert(task, "Bad task")
	assert(not self._cleanupTask, "Already have _cleanupTask")

	if self._state ~= stateTypes.PENDING then
		maidTaskUtils.doTask(task)
		return
	end

	self._cleanupTask = task
end

function Subscription:Destroy()
	if self._state == stateTypes.PENDING then
		self._state = stateTypes.CANCELLED
	end

	self:_doCleanup()
    table.clear(self)
    setmetatable(self, nil)
end

function Subscription:Disconnect()
	self:Destroy()
end

-- Observable class
local Observable = {}
Observable.__index = Observable
Observable.ClassName = "Observable"

function Observable.isObservable(object)
    return typeof(object) == "table" and object.ClassName == "Observable"
end

function Observable.new(onSubscribe)
    assert(type(onSubscribe) == "function", "Bad onSubscribe")

    return setmetatable({
        _onSubscribe = onSubscribe;
        _source = ENABLE_STACK_TRACING and debug.traceback() or "";
    }, Observable)
end

function Observable:Subscribe(fireCallback, failCallback, completeCallback)
    local sub = Subscription.new(fireCallback, failCallback, completeCallback)
    local cleanup = self._onSubscribe(sub)

    if cleanup then
        sub:_giveCleanup(cleanup)
    end

    return sub
end

function Observable:Destroy()
    table.clear(self)
    setmetatable(self, nil)
end

return Observable