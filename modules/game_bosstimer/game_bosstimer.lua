local bossTimerPanel
local countdownEvent
local deadlineMs = 0
local currentBossId
local warningThresholdSeconds = 30

local function cancelCountdownEvent()
	if countdownEvent then
		removeEvent(countdownEvent)

		countdownEvent = nil
	end
end

local function hideBossTimer()
	cancelCountdownEvent()

	deadlineMs = 0
	currentBossId = nil

	if bossTimerPanel and not bossTimerPanel:isDestroyed() then
		bossTimerPanel:hide()

		local previewCreature = bossTimerPanel:getChildById("bossCreature"):getCreature()

		if previewCreature then
			previewCreature:setStaticWalking(0)
		end
	end
end

local function destroyBossTimer()
	hideBossTimer()

	if bossTimerPanel and not bossTimerPanel:isDestroyed() then
		bossTimerPanel:destroy()
	end

	bossTimerPanel = nil
end

local function ensureBossTimerPanel()
	if not bossTimerPanel or bossTimerPanel:isDestroyed() then
		bossTimerPanel = g_ui.createWidget("BossTimerPanel", modules.game_interface.getMapPanel())
	end

	return bossTimerPanel
end

local function updateCountdown()
	countdownEvent = nil

	if not bossTimerPanel or bossTimerPanel:isDestroyed() then
		hideBossTimer()

		return
	end

	local remainingMs = math.max(0, deadlineMs - g_clock.millis())
	local remainingSeconds = math.ceil(remainingMs / 1000)
	local timeLeftLabel = bossTimerPanel:getChildById("timeLeftLabel")

	timeLeftLabel:setText(string.format("%02d:%02d", math.floor(remainingSeconds / 60), remainingSeconds % 60))
	timeLeftLabel:setOn(remainingSeconds > 0 and remainingSeconds <= warningThresholdSeconds)

	if remainingSeconds == 0 then
		hideBossTimer()

		return
	end

	local nextTickDelayMs = remainingMs - (remainingSeconds - 1) * 1000

	countdownEvent = scheduleEvent(updateCountdown, nextTickDelayMs)
end

function onBossTimer(bossId, durationSeconds)
	g_logger.info(string.format("[boss_timer] Lua event: bossId=%s, seconds=%s", tostring(bossId), tostring(durationSeconds)))

	if bossId == 0 or not durationSeconds or durationSeconds <= 0 then
		hideBossTimer()

		return
	end

	local panel = ensureBossTimerPanel()

	if currentBossId ~= bossId then
		local raceData = g_things.getRaceData(bossId)
		local hasKnownBossName = raceData and raceData.name and raceData.name ~= ""
		local bossName = hasKnownBossName and raceData.name or string.format("%s #%d", tr("Unknown Boss"), bossId)

		panel:getChildById("bossNameLabel"):setText(bossName)

		local portrait = panel:getChildById("bossCreature")

		portrait:setVisible(hasKnownBossName and raceData.outfit ~= nil)

		if hasKnownBossName and raceData.outfit then
			portrait:setOutfit(raceData.outfit)
			portrait:getCreature():setStaticWalking(500)
		elseif portrait:getCreature() then
			portrait:getCreature():setStaticWalking(0)
		end

		currentBossId = bossId
	end

	cancelCountdownEvent()

	deadlineMs = g_clock.millis() + durationSeconds * 1000

	panel:show()
	panel:raise()
	updateCountdown()
end

function init()
	g_ui.importStyle("game_bosstimer")
	connect(g_game, {
		onBossTimer = onBossTimer,
		onGameEnd = destroyBossTimer
	})
end

function terminate()
	disconnect(g_game, {
		onBossTimer = onBossTimer,
		onGameEnd = destroyBossTimer
	})
	destroyBossTimer()
end
