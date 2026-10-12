if not AnalyserSession then
	AnalyserSession = {
		startUnix = 0,
		startMs = 0
	}
	AnalyserSession.__index = AnalyserSession
end

local SESSION_STABILIZE_TIME = 1000
local ROLLING_WINDOW_COMPACTION_THRESHOLD = 4096

local function compactRollingWindow(window)
	if window.first <= ROLLING_WINDOW_COMPACTION_THRESHOLD or window.first <= math.floor(window.last / 2) then
		return
	end

	local buckets = {}
	local last = 0

	for bucketIndex = window.first, window.last do
		last = last + 1
		buckets[last] = window.buckets[bucketIndex]
	end

	window.buckets = buckets
	window.first = 1
	window.last = last
end

function AnalyserSession.reset(self)
	self.startMs = g_clock.millis()
	self.startUnix = os.time()
end

function AnalyserSession.isActive(self)
	return self.startMs > 0 and self.startUnix > 0
end

function AnalyserSession.elapsedMs(self)
	if self.startMs <= 0 then
		return 0
	end

	return math.max(1, g_clock.millis() - self.startMs)
end

function AnalyserSession.durationSeconds(self)
	if self.startUnix <= 0 then
		return 0
	end

	return math.max(0, os.time() - self.startUnix)
end

function AnalyserSession.perHourFromTotal(self, total, startMs, maximumElapsedMs)
	local amount = tonumber(total) or 0

	if amount <= 0 then
		return 0
	end

	local numericValue = tonumber(startMs) or self.startMs

	if numericValue <= 0 then
		return 0
	end

	local usedElapsed = math.max(SESSION_STABILIZE_TIME, g_clock.millis() - numericValue)

	if maximumElapsedMs and maximumElapsedMs > 0 then
		usedElapsed = math.min(usedElapsed, maximumElapsedMs)
	end

	return math.floor(amount * 3600000 / usedElapsed)
end

function AnalyserSession.newRollingWindow(unusedArgument, durationMs, allowNegative)
	return {
		total = 0,
		last = 0,
		first = 1,
		durationMs = math.max(SESSION_STABILIZE_TIME, tonumber(durationMs) or SESSION_STABILIZE_TIME),
		allowNegative = allowNegative == true,
		startMs = g_clock.millis(),
		buckets = {}
	}
end

function AnalyserSession.resetRollingWindow(unusedArgument, window, durationMs, allowNegative)
	window = window or {}
	window.durationMs = math.max(SESSION_STABILIZE_TIME, tonumber(durationMs) or window.durationMs or SESSION_STABILIZE_TIME)

	if allowNegative ~= nil then
		window.allowNegative = allowNegative == true
	end

	window.startMs = g_clock.millis()
	window.buckets = {}
	window.first = 1
	window.last = 0
	window.total = 0

	return window
end

function AnalyserSession.pruneRollingWindow(unusedArgument, window, numericValue)
	if not window then
		return 0
	end

	numericValue = tonumber(numericValue) or g_clock.millis()

	local cutoffMs = numericValue - math.max(SESSION_STABILIZE_TIME, tonumber(window.durationMs) or SESSION_STABILIZE_TIME)
	local expiredAmount = 0

	while window.first <= window.last do
		local bucket = window.buckets[window.first]

		if not bucket or cutoffMs < bucket.tick then
			break
		end

		expiredAmount = expiredAmount + (tonumber(bucket.amount) or 0)
		window.buckets[window.first] = nil
		window.first = window.first + 1
	end

	local remainingTotal = (tonumber(window.total) or 0) - expiredAmount

	window.total = window.allowNegative and remainingTotal or math.max(0, remainingTotal)

	if window.first > window.last then
		window.buckets = {}
		window.first = 1
		window.last = 0
		window.total = 0
	else
		compactRollingWindow(window)
	end

	return expiredAmount
end

function AnalyserSession.addRollingValue(self, window, numericValue, tick)
	numericValue = tonumber(numericValue) or 0

	if not window or numericValue == 0 or numericValue < 0 and not window.allowNegative then
		return
	end

	tick = tonumber(tick) or g_clock.millis()

	self:pruneRollingWindow(window, tick)

	local bucketSlot = math.floor(tick / SESSION_STABILIZE_TIME)
	local lastBucket = window.buckets[window.last]

	if lastBucket and lastBucket.slot == bucketSlot then
		lastBucket.amount = lastBucket.amount + numericValue
		lastBucket.tick = tick
	else
		window.last = window.last + 1
		window.buckets[window.last] = {
			amount = numericValue,
			tick = tick,
			slot = bucketSlot
		}
	end

	window.total = (tonumber(window.total) or 0) + numericValue
end

function AnalyserSession.rollingTotal(self, window, nowMs)
	self:pruneRollingWindow(window, nowMs)

	return window and (tonumber(window.total) or 0) or 0
end

function AnalyserSession.rollingRate(self, window, durationMs, rateIntervalMs, numericValue)
	if not window then
		return 0
	end

	numericValue = tonumber(numericValue) or g_clock.millis()

	self:pruneRollingWindow(window, numericValue)

	durationMs = math.max(SESSION_STABILIZE_TIME, tonumber(durationMs) or window.durationMs or SESSION_STABILIZE_TIME)
	rateIntervalMs = math.max(1, tonumber(rateIntervalMs) or SESSION_STABILIZE_TIME)

	local cutoffMs = numericValue - durationMs
	local recentAmount = 0

	for bucketIndex = window.last, window.first, -1 do
		local bucket = window.buckets[bucketIndex]

		if not bucket or cutoffMs >= bucket.tick then
			break
		end

		recentAmount = recentAmount + (tonumber(bucket.amount) or 0)
	end

	if recentAmount <= 0 then
		return 0
	end

	local elapsedMs = math.max(SESSION_STABILIZE_TIME, numericValue - (tonumber(window.startMs) or numericValue))
	local effectiveDurationMs = math.min(durationMs, elapsedMs)

	return math.floor(recentAmount * rateIntervalMs / effectiveDurationMs + 0.5)
end
