ebbFlowController = Controller:new()
EbbFlowTimer = EbbFlowTimer or {}

local EBB_FLOW_OPCODE = ExtendedIds and ExtendedIds.EbbFlowTimer or 25
local normalTimerFont = "textmessageblue-13px_cp1252"
local warningTimerFont = "textmessagered-13px_cp1252"
local FALLBACK_TIMER_FONT = "verdana-11px-rounded"
local TICK_INTERVAL_MS = 100
local WARNING_THRESHOLD_MS = 30000
local FADE_DURATION_MS = 1000
local imageSourcePath = "/images/game/ranked-queue/game-hud-ui"
local ebbFlowTimerPanelWidget
local timerTickEvent
local remainingTimeMs = 0
local closedByUser = false
local ensureTimerPanel

local function fontExists(fontName)
	return g_fonts and g_fonts.fontExists and g_fonts.fontExists(fontName)
end

local function resolveTimerFonts()
	if not fontExists(normalTimerFont) then
		normalTimerFont = FALLBACK_TIMER_FONT
	end

	if not fontExists(warningTimerFont) then
		warningTimerFont = FALLBACK_TIMER_FONT
	end
end

local function getTimerParent()
	if modules.game_interface then
		if modules.game_interface.getMapPanel then
			local mapPanel = modules.game_interface.getMapPanel()

			if mapPanel then
				return mapPanel
			end
		end

		if modules.game_interface.getRootPanel then
			return modules.game_interface.getRootPanel()
		end
	end

	return rootWidget
end

local function formatRemainingTime(remainingMs)
	if remainingMs < 0 then
		remainingMs = 0
	end

	local minutes = math.floor(remainingMs / 60000)
	local seconds = math.floor(remainingMs % 60000 / 1000)
	local centiseconds = math.floor(remainingMs % 1000 / 10)

	return string.format("%02d : %02d . %02d", minutes, seconds, centiseconds)
end

local function updateTimerColor(remainingMs)
	if not ebbFlowTimerPanelWidget then
		return
	end

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if not timeLeftTimer then
		return
	end

	if remainingMs > 0 and remainingMs <= WARNING_THRESHOLD_MS then
		timeLeftTimer:setFont(warningTimerFont)
	else
		timeLeftTimer:setFont(normalTimerFont)
	end
end

local function stopTimerEvent()
	if timerTickEvent then
		removeEvent(timerTickEvent)

		timerTickEvent = nil
	end
end

local function hideTimerPanel()
	stopTimerEvent()

	remainingTimeMs = 0

	if ebbFlowTimerPanelWidget then
		g_effects.cancelFade(ebbFlowTimerPanelWidget)
		ebbFlowTimerPanelWidget:hide()
		ebbFlowTimerPanelWidget:setOpacity(1)
	end
end

local function showTimerPanel()
	if not ebbFlowTimerPanelWidget or closedByUser or ebbFlowTimerPanelWidget:isVisible() then
		return
	end

	ebbFlowTimerPanelWidget:show()
	ebbFlowTimerPanelWidget:raise()
	ebbFlowTimerPanelWidget:setOpacity(0)
	g_effects.fadeIn(ebbFlowTimerPanelWidget, FADE_DURATION_MS)
end

local function onTimerTick()
	remainingTimeMs = remainingTimeMs - TICK_INTERVAL_MS

	if remainingTimeMs <= 0 then
		if ebbFlowTimerPanelWidget then
			local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

			if timeLeftTimer then
				timeLeftTimer:setText("00 : 00 . 00")
			end
		end

		hideTimerPanel()

		closedByUser = false

		return
	end

	if not ebbFlowTimerPanelWidget then
		return
	end

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if timeLeftTimer then
		timeLeftTimer:setText(formatRemainingTime(remainingTimeMs))
	end

	updateTimerColor(remainingTimeMs)
	showTimerPanel()
end

function onManageEbbFlowTimer(showTimer, remainingMs)
	if not showTimer or not remainingMs or remainingMs <= 0 then
		hideTimerPanel()

		closedByUser = false

		return
	end

	if not ensureTimerPanel() then
		return
	end

	stopTimerEvent()

	remainingTimeMs = tonumber(remainingMs) or 0
	closedByUser = false

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if timeLeftTimer then
		timeLeftTimer:setText(formatRemainingTime(remainingTimeMs))
	end

	updateTimerColor(remainingTimeMs)
	showTimerPanel()

	timerTickEvent = cycleEvent(onTimerTick, TICK_INTERVAL_MS)
end

local function handleMouseRelease(unusedArgument, mousePosition, mouseButton)
	if mouseButton ~= MouseRightButton then
		return false
	end

	local popupMenuWidget = g_ui.createWidget("PopupMenu")

	popupMenuWidget:setGameMenu(true)
	popupMenuWidget:addOption(tr("Close"), function()
		closedByUser = true

		if ebbFlowTimerPanelWidget then
			g_effects.cancelFade(ebbFlowTimerPanelWidget)
			ebbFlowTimerPanelWidget:hide()
		end
	end)
	popupMenuWidget:setWidth(70)
	popupMenuWidget:display(mousePosition)

	return true
end

function ensureTimerPanel()
	if ebbFlowTimerPanelWidget then
		return ebbFlowTimerPanelWidget
	end

	local parentWidget = getTimerParent()

	if not parentWidget then
		return nil
	end

	ebbFlowTimerPanelWidget = g_ui.createWidget("EbbFlowTimerPanel", parentWidget)

	if not ebbFlowTimerPanelWidget then
		g_logger.error("game_ebbflow_timer: failed to create HUD widget")

		return nil
	end

	ebbFlowTimerPanelWidget:setImageSource(imageSourcePath)

	ebbFlowTimerPanelWidget.onMouseRelease = handleMouseRelease

	function ebbFlowTimerPanelWidget.onHoverChange(timerPanel, hovered)
		timerPanel:setOpacity(hovered and 0.5 or 1)
	end

	ebbFlowTimerPanelWidget:hide()

	return ebbFlowTimerPanelWidget
end

local function readLittleEndianU32(buffer, offset)
	local byte0, byte1, byte2, byte3 = buffer:byte(offset, offset + 3)

	if not byte3 then
		return nil
	end

	return byte0 + byte1 * 256 + byte2 * 65536 + byte3 * 16777216
end

local function readLittleEndianU64(buffer, offset)
	local lowWord = readLittleEndianU32(buffer, offset)
	local highWord = readLittleEndianU32(buffer, offset + 4)

	if not lowWord or not highWord then
		return nil
	end

	return lowWord + highWord * 4294967296
end

local function decodeTimerPayload(payload)
	if type(payload) ~= "string" or #payload < 1 then
		return nil
	end

	if payload:sub(1, 1) == "{" then
		local decodeSucceeded, decodedPayload = pcall(function()
			return json.decode(payload)
		end)

		if decodeSucceeded and type(decodedPayload) == "table" then
			local show = decodedPayload.show

			if show == nil then
				show = decodedPayload.visible
			end

			local remainingMs = decodedPayload.remaining or decodedPayload.endTime or decodedPayload.ms or 0

			return show ~= false and show ~= 0, tonumber(remainingMs) or 0
		end
	end

	local visibilityByte = payload:byte(1)
	local remainingMs = 0

	if #payload >= 9 then
		remainingMs = readLittleEndianU64(payload, 2) or 0
	elseif #payload >= 5 then
		remainingMs = readLittleEndianU32(payload, 2) or 0
	end

	return visibilityByte == 1, remainingMs
end

local function onTimerOpcode(unusedArgument, unusedArgument, payload)
	local showTimer, remainingMs = decodeTimerPayload(payload)

	if showTimer == nil then
		return
	end

	onManageEbbFlowTimer(showTimer, remainingMs)
end

function EbbFlowTimer.test(durationMs)
	ensureTimerPanel()
	onManageEbbFlowTimer(true, durationMs or 900000)
end

function EbbFlowTimer.hide()
	onManageEbbFlowTimer(false, 0)
end

function ebbFlowController.onInit(controller)
	resolveTimerFonts()
	g_ui.importStyle("ebbflow_timer")
	controller:registerExtendedOpcode(EBB_FLOW_OPCODE, onTimerOpcode)
	pcall(function()
		connect(g_game, {
			onManageEbbFlowTimer = onManageEbbFlowTimer
		})
	end)
end

function ebbFlowController.onGameStart(unusedArgument)
	ensureTimerPanel()
end

function ebbFlowController.onGameEnd(unusedArgument)
	hideTimerPanel()

	closedByUser = false
end

function ebbFlowController.onTerminate(unusedArgument)
	pcall(function()
		disconnect(g_game, {
			onManageEbbFlowTimer = onManageEbbFlowTimer
		})
	end)
	hideTimerPanel()

	if ebbFlowTimerPanelWidget then
		ebbFlowTimerPanelWidget:destroy()

		ebbFlowTimerPanelWidget = nil
	end
end

function init()
	ebbFlowController:init()

	if g_game.isOnline() then
		ensureTimerPanel()
	end
end

function terminate()
	ebbFlowController:terminate()
end
