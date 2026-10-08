if not AnalyserSession then
	AnalyserSession = {
		startUnix = 0,
		startMs = 0
	}
	AnalyserSession.__index = AnalyserSession
end

local SESSION_STABILIZE_TIME = 1000
local var_0_1 = 4096

local function var_0_2(arg_1_0)
	if arg_1_0.first <= var_0_1 or arg_1_0.first <= math.floor(arg_1_0.last / 2) then
		return
	end

	local var_1_0 = {}
	local var_1_1 = 0

	for iter_1_0 = arg_1_0.first, arg_1_0.last do
		var_1_1 = var_1_1 + 1
		var_1_0[var_1_1] = arg_1_0.buckets[iter_1_0]
	end

	arg_1_0.buckets = var_1_0
	arg_1_0.first = 1
	arg_1_0.last = var_1_1
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

function AnalyserSession.perHourFromTotal(arg_6_0, total, arg_6_2, arg_6_3)
	local amount = tonumber(total) or 0

	if amount <= 0 then
		return 0
	end

	local numericValue = tonumber(arg_6_2) or arg_6_0.startMs

	if numericValue <= 0 then
		return 0
	end

	local usedElapsed = math.max(SESSION_STABILIZE_TIME, g_clock.millis() - numericValue)

	if arg_6_3 and arg_6_3 > 0 then
		usedElapsed = math.min(usedElapsed, arg_6_3)
	end

	return math.floor(amount * 3600000 / usedElapsed)
end

function AnalyserSession.newRollingWindow(unusedArgument, arg_7_1, arg_7_2)
	return {
		total = 0,
		last = 0,
		first = 1,
		durationMs = math.max(SESSION_STABILIZE_TIME, tonumber(arg_7_1) or SESSION_STABILIZE_TIME),
		allowNegative = arg_7_2 == true,
		startMs = g_clock.millis(),
		buckets = {}
	}
end

function AnalyserSession.resetRollingWindow(unusedArgument, arg_8_1, arg_8_2, arg_8_3)
	arg_8_1 = arg_8_1 or {}
	arg_8_1.durationMs = math.max(SESSION_STABILIZE_TIME, tonumber(arg_8_2) or arg_8_1.durationMs or SESSION_STABILIZE_TIME)

	if arg_8_3 ~= nil then
		arg_8_1.allowNegative = arg_8_3 == true
	end

	arg_8_1.startMs = g_clock.millis()
	arg_8_1.buckets = {}
	arg_8_1.first = 1
	arg_8_1.last = 0
	arg_8_1.total = 0

	return arg_8_1
end

function AnalyserSession.pruneRollingWindow(unusedArgument, arg_9_1, numericValue)
	if not arg_9_1 then
		return 0
	end

	numericValue = tonumber(numericValue) or g_clock.millis()

	local var_9_0 = numericValue - math.max(SESSION_STABILIZE_TIME, tonumber(arg_9_1.durationMs) or SESSION_STABILIZE_TIME)
	local var_9_1 = 0

	while arg_9_1.first <= arg_9_1.last do
		local var_9_2 = arg_9_1.buckets[arg_9_1.first]

		if not var_9_2 or var_9_0 < var_9_2.tick then
			break
		end

		var_9_1 = var_9_1 + (tonumber(var_9_2.amount) or 0)
		arg_9_1.buckets[arg_9_1.first] = nil
		arg_9_1.first = arg_9_1.first + 1
	end

	local var_9_3 = (tonumber(arg_9_1.total) or 0) - var_9_1

	arg_9_1.total = arg_9_1.allowNegative and var_9_3 or math.max(0, var_9_3)

	if arg_9_1.first > arg_9_1.last then
		arg_9_1.buckets = {}
		arg_9_1.first = 1
		arg_9_1.last = 0
		arg_9_1.total = 0
	else
		var_0_2(arg_9_1)
	end

	return var_9_1
end

function AnalyserSession.addRollingValue(arg_10_0, arg_10_1, numericValue, arg_10_3)
	numericValue = tonumber(numericValue) or 0

	if not arg_10_1 or numericValue == 0 or numericValue < 0 and not arg_10_1.allowNegative then
		return
	end

	arg_10_3 = tonumber(arg_10_3) or g_clock.millis()

	arg_10_0:pruneRollingWindow(arg_10_1, arg_10_3)

	local var_10_0 = math.floor(arg_10_3 / SESSION_STABILIZE_TIME)
	local var_10_1 = arg_10_1.buckets[arg_10_1.last]

	if var_10_1 and var_10_1.slot == var_10_0 then
		var_10_1.amount = var_10_1.amount + numericValue
		var_10_1.tick = arg_10_3
	else
		arg_10_1.last = arg_10_1.last + 1
		arg_10_1.buckets[arg_10_1.last] = {
			amount = numericValue,
			tick = arg_10_3,
			slot = var_10_0
		}
	end

	arg_10_1.total = (tonumber(arg_10_1.total) or 0) + numericValue
end

function AnalyserSession.rollingTotal(arg_11_0, arg_11_1, arg_11_2)
	arg_11_0:pruneRollingWindow(arg_11_1, arg_11_2)

	return arg_11_1 and (tonumber(arg_11_1.total) or 0) or 0
end

function AnalyserSession.rollingRate(arg_12_0, arg_12_1, arg_12_2, arg_12_3, numericValue)
	if not arg_12_1 then
		return 0
	end

	numericValue = tonumber(numericValue) or g_clock.millis()

	arg_12_0:pruneRollingWindow(arg_12_1, numericValue)

	arg_12_2 = math.max(SESSION_STABILIZE_TIME, tonumber(arg_12_2) or arg_12_1.durationMs or SESSION_STABILIZE_TIME)
	arg_12_3 = math.max(1, tonumber(arg_12_3) or SESSION_STABILIZE_TIME)

	local var_12_0 = numericValue - arg_12_2
	local var_12_1 = 0

	for iter_12_0 = arg_12_1.last, arg_12_1.first, -1 do
		local var_12_2 = arg_12_1.buckets[iter_12_0]

		if not var_12_2 or var_12_0 >= var_12_2.tick then
			break
		end

		var_12_1 = var_12_1 + (tonumber(var_12_2.amount) or 0)
	end

	if var_12_1 <= 0 then
		return 0
	end

	local var_12_3 = math.max(SESSION_STABILIZE_TIME, numericValue - (tonumber(arg_12_1.startMs) or numericValue))
	local var_12_4 = math.min(arg_12_2, var_12_3)

	return math.floor(var_12_1 * arg_12_3 / var_12_4 + 0.5)
end
