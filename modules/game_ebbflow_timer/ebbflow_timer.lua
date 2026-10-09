ebbFlowController = Controller:new()
EbbFlowTimer = EbbFlowTimer or {}

local var_0_0 = ExtendedIds and ExtendedIds.EbbFlowTimer or 25
local var_0_1 = "textmessageblue-13px_cp1252"
local var_0_2 = "textmessagered-13px_cp1252"
local var_0_3 = "verdana-11px-rounded"
local var_0_4 = 100
local var_0_5 = 30000
local var_0_6 = 1000
local imageSourcePath = "/images/game/ranked-queue/game-hud-ui"
local ebbFlowTimerPanelWidget
local var_0_9
local numericValue = 0
local var_0_11 = false
local var_0_12

local function var_0_13(fontName)
	return g_fonts and g_fonts.fontExists and g_fonts.fontExists(fontName)
end

local function var_0_14()
	if not var_0_13(var_0_1) then
		var_0_1 = var_0_3
	end

	if not var_0_13(var_0_2) then
		var_0_2 = var_0_3
	end
end

local function var_0_15()
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

local function var_0_16(arg_4_0)
	if arg_4_0 < 0 then
		arg_4_0 = 0
	end

	local var_4_0 = math.floor(arg_4_0 / 60000)
	local var_4_1 = math.floor(arg_4_0 % 60000 / 1000)
	local var_4_2 = math.floor(arg_4_0 % 1000 / 10)

	return string.format("%02d : %02d . %02d", var_4_0, var_4_1, var_4_2)
end

local function var_0_17(arg_5_0)
	if not ebbFlowTimerPanelWidget then
		return
	end

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if not timeLeftTimer then
		return
	end

	if arg_5_0 > 0 and arg_5_0 <= var_0_5 then
		timeLeftTimer:setFont(var_0_2)
	else
		timeLeftTimer:setFont(var_0_1)
	end
end

local function var_0_18()
	if var_0_9 then
		removeEvent(var_0_9)

		var_0_9 = nil
	end
end

local function var_0_19()
	var_0_18()

	numericValue = 0

	if ebbFlowTimerPanelWidget then
		g_effects.cancelFade(ebbFlowTimerPanelWidget)
		ebbFlowTimerPanelWidget:hide()
		ebbFlowTimerPanelWidget:setOpacity(1)
	end
end

local function var_0_20()
	if not ebbFlowTimerPanelWidget or var_0_11 or ebbFlowTimerPanelWidget:isVisible() then
		return
	end

	ebbFlowTimerPanelWidget:show()
	ebbFlowTimerPanelWidget:raise()
	ebbFlowTimerPanelWidget:setOpacity(0)
	g_effects.fadeIn(ebbFlowTimerPanelWidget, var_0_6)
end

local function var_0_21()
	numericValue = numericValue - var_0_4

	if numericValue <= 0 then
		if ebbFlowTimerPanelWidget then
			local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

			if timeLeftTimer then
				timeLeftTimer:setText("00 : 00 . 00")
			end
		end

		var_0_19()

		var_0_11 = false

		return
	end

	if not ebbFlowTimerPanelWidget then
		return
	end

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if timeLeftTimer then
		timeLeftTimer:setText(var_0_16(numericValue))
	end

	var_0_17(numericValue)
	var_0_20()
end

function onManageEbbFlowTimer(arg_10_0, arg_10_1)
	if not arg_10_0 or not arg_10_1 or arg_10_1 <= 0 then
		var_0_19()

		var_0_11 = false

		return
	end

	if not var_0_12() then
		return
	end

	var_0_18()

	numericValue = tonumber(arg_10_1) or 0
	var_0_11 = false

	local timeLeftTimer = ebbFlowTimerPanelWidget:getChildById("timeLeftTimer")

	if timeLeftTimer then
		timeLeftTimer:setText(var_0_16(numericValue))
	end

	var_0_17(numericValue)
	var_0_20()

	var_0_9 = cycleEvent(var_0_21, var_0_4)
end

local function handleMouseRelease(unusedArgument, arg_11_1, arg_11_2)
	if arg_11_2 ~= MouseRightButton then
		return false
	end

	local popupMenuWidget = g_ui.createWidget("PopupMenu")

	popupMenuWidget:setGameMenu(true)
	popupMenuWidget:addOption(tr("Close"), function()
		var_0_11 = true

		if ebbFlowTimerPanelWidget then
			g_effects.cancelFade(ebbFlowTimerPanelWidget)
			ebbFlowTimerPanelWidget:hide()
		end
	end)
	popupMenuWidget:setWidth(70)
	popupMenuWidget:display(arg_11_1)

	return true
end

function var_0_12()
	if ebbFlowTimerPanelWidget then
		return ebbFlowTimerPanelWidget
	end

	local parentWidget = var_0_15()

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

	function ebbFlowTimerPanelWidget.onHoverChange(arg_14_0, arg_14_1)
		arg_14_0:setOpacity(arg_14_1 and 0.5 or 1)
	end

	ebbFlowTimerPanelWidget:hide()

	return ebbFlowTimerPanelWidget
end

local function var_0_23(arg_15_0, arg_15_1)
	local var_15_0, var_15_1, var_15_2, var_15_3 = arg_15_0:byte(arg_15_1, arg_15_1 + 3)

	if not var_15_3 then
		return nil
	end

	return var_15_0 + var_15_1 * 256 + var_15_2 * 65536 + var_15_3 * 16777216
end

local function var_0_24(arg_16_0, arg_16_1)
	local var_16_0 = var_0_23(arg_16_0, arg_16_1)
	local var_16_1 = var_0_23(arg_16_0, arg_16_1 + 4)

	if not var_16_0 or not var_16_1 then
		return nil
	end

	return var_16_0 + var_16_1 * 4294967296
end

local function var_0_25(arg_17_0)
	if type(arg_17_0) ~= "string" or #arg_17_0 < 1 then
		return nil
	end

	if arg_17_0:sub(1, 1) == "{" then
		local var_17_0, var_17_1 = pcall(function()
			return json.decode(arg_17_0)
		end)

		if var_17_0 and type(var_17_1) == "table" then
			local show = var_17_1.show

			if show == nil then
				show = var_17_1.visible
			end

			local var_17_3 = var_17_1.remaining or var_17_1.endTime or var_17_1.ms or 0

			return show ~= false and show ~= 0, tonumber(var_17_3) or 0
		end
	end

	local var_17_4 = arg_17_0:byte(1)
	local var_17_5 = 0

	if #arg_17_0 >= 9 then
		var_17_5 = var_0_24(arg_17_0, 2) or 0
	elseif #arg_17_0 >= 5 then
		var_17_5 = var_0_23(arg_17_0, 2) or 0
	end

	return var_17_4 == 1, var_17_5
end

local function var_0_26(unusedArgument, unusedArgument, arg_19_2)
	local var_19_0, var_19_1 = var_0_25(arg_19_2)

	if var_19_0 == nil then
		return
	end

	onManageEbbFlowTimer(var_19_0, var_19_1)
end

function EbbFlowTimer.test(arg_20_0)
	var_0_12()
	onManageEbbFlowTimer(true, arg_20_0 or 900000)
end

function EbbFlowTimer.hide()
	onManageEbbFlowTimer(false, 0)
end

function ebbFlowController.onInit(arg_22_0)
	var_0_14()
	g_ui.importStyle("ebbflow_timer")
	arg_22_0:registerExtendedOpcode(var_0_0, var_0_26)
	pcall(function()
		connect(g_game, {
			onManageEbbFlowTimer = onManageEbbFlowTimer
		})
	end)
end

function ebbFlowController.onGameStart(unusedArgument)
	var_0_12()
end

function ebbFlowController.onGameEnd(unusedArgument)
	var_0_19()

	var_0_11 = false
end

function ebbFlowController.onTerminate(unusedArgument)
	pcall(function()
		disconnect(g_game, {
			onManageEbbFlowTimer = onManageEbbFlowTimer
		})
	end)
	var_0_19()

	if ebbFlowTimerPanelWidget then
		ebbFlowTimerPanelWidget:destroy()

		ebbFlowTimerPanelWidget = nil
	end
end

function init()
	ebbFlowController:init()

	if g_game.isOnline() then
		var_0_12()
	end
end

function terminate()
	ebbFlowController:terminate()
end
