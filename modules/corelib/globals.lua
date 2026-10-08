rootWidget = g_ui.getRootWidget()
modules = package.loaded
G = G or {}
__dispatcherNative = {
	addEvent = g_dispatcher.addEvent,
	scheduleEvent = g_dispatcher.scheduleEvent,
	cycleEvent = g_dispatcher.cycleEvent,
	setNextEventSource = g_dispatcher.setNextEventSource,
	hasNextEventSource = g_dispatcher.hasNextEventSource,
	setActiveEventSource = g_dispatcher.setActiveEventSource
}

local _skipSourcePatterns = {
	"corelib/globals%.lua",
	"modulelib/controller%.lua"
}
local _genericSourceNames = {
	callback = true,
	action = true
}

local function _isGenericSourceName(name)
	if not name or name == "" then
		return true
	end

	if _genericSourceNames[name] then
		return true
	end

	if name:sub(1, 1) == "(" and name:sub(-1) == ")" then
		return true
	end

	return false
end

local function _hasValidLine(info)
	return info and type(info.currentline) == "number" and info.currentline > 0
end

local function _shouldSkipEventSource(info)
	if not info or not info.short_src then
		return true
	end

	if info.what == "C" then
		return true
	end

	local src = info.short_src

	for _, pattern in ipairs(_skipSourcePatterns) do
		if src:find(pattern) then
			return true
		end
	end

	return false
end

local function _formatEventSource(info)
	if not info or not info.short_src then
		return nil
	end

	local src = info.short_src

	if _hasValidLine(info) then
		if not _isGenericSourceName(info.name) then
			return string.format("%s:%s:%d", src, info.name, info.currentline)
		end

		return string.format("%s:%d", src, info.currentline)
	end

	if not _isGenericSourceName(info.name) then
		return string.format("%s:%s:?", src, info.name)
	end

	return nil
end

local function _captureFunctionSource(...)
	local debugLibrary = debug

	if type(debugLibrary) ~= "table" then
		return nil
	end

	local callback = debugLibrary.getinfo

	if type(callback) ~= "function" then
		return nil
	end

	local ok, err = pcall(callback, ...)

	if not ok then
		return nil
	end

	return err
end

local function unusedValue(eventCallback)
	if type(eventCallback) ~= "function" then
		return nil
	end

	return _formatEventSource(_captureFunctionSource(eventCallback, "Snl"))
end

local function captureCallerEventSource(firstStackDepth, lastStackDepth)
	firstStackDepth = firstStackDepth or 3
	lastStackDepth = lastStackDepth or 20

	local fallbackEventSource

	for stackDepth = firstStackDepth, lastStackDepth do
		local frameInfo = _captureFunctionSource(stackDepth, "Snl")

		if not frameInfo then
			break
		end

		if not _shouldSkipEventSource(frameInfo) then
			local eventSource = _formatEventSource(frameInfo)

			if eventSource then
				if _hasValidLine(frameInfo) then
					return eventSource
				end

				fallbackEventSource = fallbackEventSource or eventSource
			end
		end
	end

	return fallbackEventSource
end

local function _tagEventSourceIfUnset()
	local nativeDispatcher = __dispatcherNative

	if not nativeDispatcher or type(nativeDispatcher.setNextEventSource) ~= "function" then
		return
	end

	if type(nativeDispatcher.hasNextEventSource) == "function" then
		local sourceCheckSucceeded, nextSourceAlreadySet = pcall(nativeDispatcher.hasNextEventSource)

		if sourceCheckSucceeded and nextSourceAlreadySet then
			return
		end
	end

	pcall(nativeDispatcher.setNextEventSource, captureCallerEventSource(3, 12) or "?")
end

function tagHitchEventSource(hitchSource)
	if type(hitchSource) ~= "string" or hitchSource == "" then
		return
	end

	__dispatcherNative.setNextEventSource("hitch:" .. hitchSource)
end

local function _wrapEventCallback(callback)
	return callback
end

function scheduleEvent(callback, delay)
	_tagEventSourceIfUnset()

	callback = _wrapEventCallback(callback)

	local event = __dispatcherNative.scheduleEvent(callback, delay)

	event._callback = callback

	return event
end

function addEvent(callback, front)
	_tagEventSourceIfUnset()

	callback = _wrapEventCallback(callback)

	local immediateEvent = __dispatcherNative.addEvent(callback, front)

	immediateEvent._callback = callback

	return immediateEvent
end

function cycleEvent(callback, interval)
	_tagEventSourceIfUnset()

	callback = _wrapEventCallback(callback)

	local repeatingEvent = __dispatcherNative.cycleEvent(callback, interval)

	repeatingEvent._callback = callback

	return repeatingEvent
end

g_dispatcher.addEvent = addEvent
g_dispatcher.scheduleEvent = scheduleEvent
g_dispatcher.cycleEvent = cycleEvent

function periodicalEvent(eventFunc, conditionFunc, delay, autoRepeatDelay)
	delay = delay or 30
	autoRepeatDelay = autoRepeatDelay or delay

	local func

	local function func()
		if conditionFunc and not conditionFunc() then
			func = nil

			return
		end

		eventFunc()
		scheduleEvent(func, delay)
	end

	scheduleEvent(function()
		func()
	end, autoRepeatDelay)
end

function removeEvent(event)
	if event then
		event:cancel()

		event._callback = nil
	end
end

function flushGameSettingsOnLogout()
	if not g_game.isOnline() then
		g_settings.save()
	end
end
