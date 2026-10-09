if not XPAnalyser then
	XPAnalyser = {
		xpGain = 0,
		rawXPGain = 0,
		startExp = 0,
		session = 0,
		launchTime = 0,
		target = 0,
		level = 0,
		rawXpHour = 0,
		xpHour = 0
	}
	XPAnalyser.__index = XPAnalyser
end

local targetMaxMargin = 144
local var_0_1 = 900000

function expForLevel(level)
	return math.floor(50 * level * level * level / 3 - 100 * level * level + 850 * level / 3 - 200)
end

function expToAdvance(currentLevel, currentExp)
	return expForLevel(currentLevel + 1) - currentExp
end

local function formatXpShown(n)
	return formatMoney(math.floor((tonumber(n) or 0) + 0.5))
end

local function setLabelTextIfPresent(label, text)
	if label then
		label:setText(text)
		label:setTooltip(text)
	end
end

function XPAnalyser.refreshXpRatesFromSession(unusedArgument)
	XPAnalyser.xpHour = AnalyserSession:rollingRate(XPAnalyser.xpWindow, var_0_1, 3600000)
	XPAnalyser.rawXpHour = AnalyserSession:rollingRate(XPAnalyser.rawXpWindow, var_0_1, 3600000)
end

local function percent(arg_6_0)
	local numericValue = tonumber(arg_6_0) or 0

	if g_game.getFeature and g_game.getFeature(GameLevelPercentU16) then
		numericValue = numericValue / 100
	end

	return math.min(100, math.max(0, numericValue))
end

local function updateXpTargetArrow()
	local xpBG = XPAnalyser.window and XPAnalyser.window.contentsPanel and XPAnalyser.window.contentsPanel.xpBG

	if not xpBG or not xpBG.xpArrow then
		return
	end

	local arrow = xpBG.xpArrow
	local target = XPAnalyser.target or 0
	local current = XPAnalyser.xpHour or 0

	if target <= 0 and current <= 0 then
		arrow:setMarginLeft(math.floor(targetMaxMargin / 2))

		return
	end

	if target <= 0 then
		arrow:setMarginLeft(targetMaxMargin)

		return
	end

	local var_7_4 = current / math.max(1, target)

	if var_7_4 < 0 then
		var_7_4 = 0
	elseif var_7_4 > 1 then
		var_7_4 = 1
	end

	arrow:setMarginLeft(math.floor(targetMaxMargin * var_7_4 + 0.5))
end

function XPAnalyser.create()
	XPAnalyser.window = openedWindows.xpButton
	XPAnalyser.launchTime = g_clock.millis()
	XPAnalyser.session = 0
	XPAnalyser.startExp = 0
	XPAnalyser.rawXPGain = 0
	XPAnalyser.xpGain = 0
	XPAnalyser.xpHour = 0
	XPAnalyser.rawXpHour = 0
	XPAnalyser.rawXpWindow = AnalyserSession:newRollingWindow(var_0_1, true)
	XPAnalyser.xpWindow = AnalyserSession:newRollingWindow(var_0_1, true)
	XPAnalyser.level = 0
	XPAnalyser.target = 0

	function XPAnalyser.window.contentsPanel.xpBG.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onXPExtra(mousePosition, "gaude")

			return true
		end
	end

	function XPAnalyser.window.contentsPanel.graphPanel.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onXPExtra(mousePosition, "graph")

			return true
		end
	end

	function XPAnalyser.window.onMaximize()
		XPAnalyser:checkAnchos()
	end
end

function XPAnalyser.reset(unusedArgument, unusedArgument, unusedArgument)
	XPAnalyser.launchTime = g_clock.millis()
	XPAnalyser.session = 0
	XPAnalyser.startExp = 0
	XPAnalyser.rawXPGain = 0
	XPAnalyser.xpGain = 0
	XPAnalyser.xpHour = 0
	XPAnalyser.rawXpHour = 0
	XPAnalyser.rawXpWindow = AnalyserSession:resetRollingWindow(XPAnalyser.rawXpWindow, var_0_1, true)
	XPAnalyser.xpWindow = AnalyserSession:resetRollingWindow(XPAnalyser.xpWindow, var_0_1, true)
	XPAnalyser.level = 0
	XPAnalyser.target = 0

	if XPAnalyser.window and XPAnalyser.window.contentsPanel and XPAnalyser.window.contentsPanel.graphPanel then
		local graphPanel = XPAnalyser.window.contentsPanel.graphPanel

		analyserUIGraphReset(graphPanel, nil, ANALYSER_GRAPH_CAPACITY_60_MIN)
		analyserUIGraphPushValue(graphPanel, 0)
	end

	pcall(function()
		XPAnalyser:updateWindow(true)
	end)

	if LoadedPlayer and LoadedPlayer.isLoaded and LoadedPlayer:isLoaded() then
		pcall(function()
			XPAnalyser:loadConfigJson()
		end)
		pcall(function()
			XPAnalyser:updateWindow(true)
		end)
	end
end

function XPAnalyser.updateWindow(unusedArgument, ignoreVisible)
	if not XPAnalyser.window:isVisible() and not ignoreVisible then
		return
	end

	local contentsPanel = XPAnalyser.window.contentsPanel

	XPAnalyser:refreshXpRatesFromSession()

	if contentsPanel.xpGain then
		setLabelTextIfPresent(contentsPanel.xpGain, formatXpShown(XPAnalyser.xpGain))
	end

	if contentsPanel.rawXpGain then
		setLabelTextIfPresent(contentsPanel.rawXpGain, formatXpShown(XPAnalyser.rawXPGain))
	end

	if contentsPanel.xpHour then
		setLabelTextIfPresent(contentsPanel.xpHour, formatXpShown(XPAnalyser.xpHour))
	end

	if contentsPanel.rawXpHour then
		setLabelTextIfPresent(contentsPanel.rawXpHour, formatXpShown(XPAnalyser.rawXpHour))
	end

	updateXpTargetArrow()
	XPAnalyser:updateTooltip()
end

function XPAnalyser.setupStartExp(self, value)
	if XPAnalyser.startExp == 0 then
		XPAnalyser.startExp = value
	end
end

function XPAnalyser.setupLevel(unusedArgument, level, arg_18_2)
	XPAnalyser.level = level

	XPAnalyser.window.contentsPanel.percent:setPercent(math.floor(percent(arg_18_2)))
	setLabelTextIfPresent(XPAnalyser.window.contentsPanel.nextLevel, "-")
end

function XPAnalyser.updateNextLevel(unusedArgument, hours, minutes)
	local nl = XPAnalyser.window and XPAnalyser.window.contentsPanel and XPAnalyser.window.contentsPanel.nextLevel
	local text = "-"

	if not nl then
		return
	end

	if XPAnalyser.xpHour == 0 then
		setLabelTextIfPresent(nl, text)

		return
	end

	if hours < 80 then
		if hours > 0 then
			text = tr("%dh %dmin", hours, minutes)
		elseif minutes > 0 then
			text = tr("%d minutes", minutes)
		else
			text = tr("1 minute")
		end
	end

	setLabelTextIfPresent(nl, text)
end

function XPAnalyser.pushGraphSample(self)
	if not XPAnalyser.window or not XPAnalyser.window.contentsPanel then
		return
	end

	local panel = XPAnalyser.window.contentsPanel.graphPanel

	if not panel then
		return
	end

	XPAnalyser:refreshXpRatesFromSession()

	local xpHr = tonumber(XPAnalyser.xpHour) or 0

	analyserUIGraphPushValue(panel, math.max(0, math.floor(xpHr + 0.5)))
end

function XPAnalyser.checkExpHour(unusedArgument)
	local player = g_game.getLocalPlayer()

	if not player or not XPAnalyser.window or XPAnalyser.window:isDestroyed() then
		return
	end

	local contentsPanel = XPAnalyser.window.contentsPanel

	if not contentsPanel then
		return
	end

	XPAnalyser:refreshXpRatesFromSession()

	if contentsPanel.xpHour then
		setLabelTextIfPresent(contentsPanel.xpHour, formatXpShown(XPAnalyser.xpHour))
	end

	if contentsPanel.rawXpHour then
		setLabelTextIfPresent(contentsPanel.rawXpHour, formatXpShown(XPAnalyser.rawXpHour))
	end

	local xpHr = tonumber(XPAnalyser.xpHour) or 0

	if xpHr > 0 then
		local curExp = tonumber(player:getExperience()) or 0
		local level = (expForLevel(math.max(0, player:getLevel() + 1)) - curExp) / xpHr
		local minutesLeft = math.floor(math.max(0, (level - math.floor(level)) * 60))
		local hoursLeft = math.floor(level)

		XPAnalyser:updateNextLevel(hoursLeft, minutesLeft)
	else
		XPAnalyser:updateNextLevel(0, 0)
	end

	updateXpTargetArrow()

	local pct = percent(player:getLevelPercent())

	if contentsPanel.percent then
		if pct ~= pct then
			pct = 0
		end

		contentsPanel.percent:setPercent(math.floor(pct))
	end

	XPAnalyser:updateTooltip()
end

function XPAnalyser.addRawXPGain(unusedArgument, value)
	XPAnalyser.rawXPGain = XPAnalyser.rawXPGain + value

	AnalyserSession:addRollingValue(XPAnalyser.rawXpWindow, value)
	XPAnalyser:updateWindow(true)
end

function XPAnalyser.addXpGain(unusedArgument, value)
	XPAnalyser.xpGain = XPAnalyser.xpGain + value

	AnalyserSession:addRollingValue(XPAnalyser.xpWindow, value)
	XPAnalyser:updateWindow(true)
end

function XPAnalyser.updateTooltip(unusedArgument)
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local text = ((((("Raw XP Gain: " .. formatMoney(XPAnalyser.rawXPGain)) .. "\nXP Gain: " .. formatMoney(XPAnalyser.xpGain)) .. "\nCurrent Raw XP Per Hour: " .. formatMoney(XPAnalyser.rawXpHour)) .. "\nCurrent XP Per Hour: " .. formatMoney(XPAnalyser.xpHour)) .. "\nTarget XP Per Hour: " .. (XPAnalyser.target and formatMoney(XPAnalyser.target) or "0")) .. "\n" .. formatMoney(expToAdvance(player:getLevel(), player:getExperience())) .. " XP until next level."
	local percentToGo = 100 - percent(player:getLevelPercent())
	local text = text .. "\nYou have " .. string.format("%.2f", math.max(0, percentToGo)) .. " percent to go."

	if XPAnalyser.window and not XPAnalyser.window:isDestroyed() then
		XPAnalyser.window:setTooltip(text)
	end
end

function onXPExtra(mousePosition, mode)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	local rawXpVisible = XPAnalyser.window.contentsPanel.rawXpLabel:isVisible()
	local gaugeVisible = XPAnalyser.window.contentsPanel.xpBG:isVisible()
	local graphVisible = XPAnalyser.window.contentsPanel.graphPanel:isVisible()
	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	if mode == "false" then
		menu:addOption(tr("Reset Data"), function()
			XPAnalyser:reset()
		end)
		menu:addSeparator()
		menu:addCheckBoxOption(tr("Show Raw XP"), function()
			XPAnalyser:setRawXPVisible(not rawXpVisible)
		end, "", rawXpVisible)
		menu:addSeparator()
		menu:addOption(tr("Set XP Per Hour Target"), function()
			XPAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("XP Per Hour Gauge"), function()
			XPAnalyser:setGaugeVisible(not gaugeVisible)
		end, "", gaugeVisible)
		menu:addCheckBoxOption(tr("XP Per Hour Graph"), function()
			XPAnalyser:setGraphVisible(not graphVisible)
		end, "", graphVisible)
		menu:display(mousePosition)

		return true
	end

	if mode == "gaude" then
		menu:addOption(tr("Set XP Per Hour Target"), function()
			XPAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("XP Per Hour Gauge"), function()
			XPAnalyser:setGaugeVisible(not gaugeVisible)
		end, "", gaugeVisible)
	end

	if mode == "graph" then
		menu:addCheckBoxOption(tr("XP Per Hour Graph"), function()
			XPAnalyser:setGraphVisible(not graphVisible)
		end, "", graphVisible)
	end

	menu:display(mousePosition)

	return true
end

function XPAnalyser.checkAnchos(unusedArgument)
	local maximizedHeight = 218

	if XPAnalyser.window.contentsPanel.rawXpLabel:isExplicitlyVisible() then
		XPAnalyser.window.contentsPanel.xpLabel:addAnchor(AnchorTop, "rawXpLabel", AnchorBottom)
		XPAnalyser.window.contentsPanel.xpGain:addAnchor(AnchorTop, "xpLabel", AnchorTop)
		XPAnalyser.window.contentsPanel.xpLabel:setMarginTop(4)
		XPAnalyser.window.contentsPanel.xpGain:setMarginTop(0)

		maximizedHeight = 254
	else
		XPAnalyser.window.contentsPanel.xpLabel:setMarginTop(-2)
		XPAnalyser.window.contentsPanel.xpLabel:addAnchor(AnchorTop, "topParent", AnchorBottom)
		XPAnalyser.window.contentsPanel.xpGain:addAnchor(AnchorTop, "xpLabel", AnchorTop)
		XPAnalyser.window.contentsPanel.xpGain:setMarginTop(0)
	end

	XPAnalyser.window:getChildById("bottomResizeBorder"):setMaximum(maximizedHeight)

	XPAnalyser.window.maximizedHeight = maximizedHeight

	if not XPAnalyser.window:isOn() then
		XPAnalyser.window:setHeight(maximizedHeight)
	end

	if XPAnalyser.window.contentsPanel.rawXpHourLabel:isExplicitlyVisible() then
		XPAnalyser.window.contentsPanel.xpHourLabel:addAnchor(AnchorTop, "rawXpHourLabel", AnchorBottom)
		XPAnalyser.window.contentsPanel.xpHour:addAnchor(AnchorTop, "xpHourLabel", AnchorTop)
	else
		XPAnalyser.window.contentsPanel.xpHourLabel:addAnchor(AnchorTop, "xpLabel", AnchorBottom)
		XPAnalyser.window.contentsPanel.xpHour:addAnchor(AnchorTop, "xpHourLabel", AnchorTop)
	end

	if XPAnalyser.window.contentsPanel.xpBG:isExplicitlyVisible() then
		XPAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorGauge", AnchorBottom)
	else
		XPAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorPercent", AnchorBottom)
	end
end

function XPAnalyser.setRawXPVisible(self, value)
	XPAnalyser.window.contentsPanel.rawXpLabel:setVisible(value)
	XPAnalyser.window.contentsPanel.rawXpGain:setVisible(value)
	XPAnalyser.window.contentsPanel.rawXpHourLabel:setVisible(value)
	XPAnalyser.window.contentsPanel.rawXpHour:setVisible(value)

	XPAnalyser.rawXpVisible = value

	XPAnalyser:checkAnchos()
end

function XPAnalyser.setGaugeVisible(self, value)
	XPAnalyser.window.contentsPanel.xpBG:setVisible(value)
	XPAnalyser.window.contentsPanel.separatorGauge:setVisible(value)

	XPAnalyser.gaugeVisible = value

	XPAnalyser:checkAnchos()
end

function XPAnalyser.setGraphVisible(self, value)
	XPAnalyser.window.contentsPanel.graphPanel:setVisible(value)
	XPAnalyser.window.contentsPanel.graphHorizontal:setVisible(value)

	XPAnalyser.graphVisible = value

	XPAnalyser:checkAnchos()
end

function XPAnalyser.openTargetConfig(self)
	local window = configPopupWindow.xpButton

	window:show()
	window:setText("Set XP Per Hour Target")
	window.contentPanel.text:setImageSource("/images/game/analyzer/labels/xp")

	local function applyTarget()
		local value = window.contentPanel.xpTarget:getText()

		XPAnalyser.target = tonumber(value) or 0

		XPAnalyser:updateWindow(true)
		window:hide()
	end

	window.onEnter = applyTarget

	window.contentPanel.xpTarget:setText(tonumber(XPAnalyser.target) or "0")

	window.contentPanel.ok.onClick = applyTarget

	function window.contentPanel.cancel.onClick()
		window:hide()
	end
end

function XPAnalyser.gaugeIsVisible(self)
	return XPAnalyser.gaugeVisible
end

function XPAnalyser.graphIsVisible(self)
	return XPAnalyser.graphVisible
end

function XPAnalyser.rawXPIsVisible(self)
	return XPAnalyser.rawXpVisible
end

function XPAnalyser.getTarget(self)
	return XPAnalyser.target
end

function XPAnalyser.loadConfigJson(self)
	local config = {
		desiredXPGraphVisible = true,
		desiredExperienceGaugeVisible = true,
		showBaseXp = false,
		experienceGaugeTargetValue = 0
	}
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local file = "/characterdata/" .. player:getId() .. "/xpanalyser.json"

	if g_resources.fileExists(file) then
		local status, result = pcall(function()
			return json.decode(g_resources.readFileContents(file))
		end)

		if not status then
			return g_logger.error("Error while reading characterdata file. Details: " .. result)
		end

		config = result
	end

	XPAnalyser:setRawXPVisible(config.showBaseXp)
	XPAnalyser:setGaugeVisible(config.desiredExperienceGaugeVisible)
	XPAnalyser:setGraphVisible(config.desiredXPGraphVisible)

	XPAnalyser.target = config.experienceGaugeTargetValue

	XPAnalyser:checkAnchos()
end

function XPAnalyser.saveConfigJson(self)
	local config = {
		desiredExperienceGaugeVisible = XPAnalyser:gaugeIsVisible(),
		desiredXPGraphVisible = XPAnalyser:graphIsVisible(),
		experienceGaugeTargetValue = XPAnalyser:getTarget(),
		showBaseXp = XPAnalyser:rawXPIsVisible()
	}

	if not LoadedPlayer:isLoaded() then
		return
	end

	local file = "/characterdata/" .. LoadedPlayer:getId() .. "/xpanalyser.json"
	local status, result = pcall(function()
		return json.encode(config, 2)
	end)

	if not status then
		return g_logger.error("Error while saving profile XP Analyzer data. Data won't be saved. Details: " .. result)
	end

	if result:len() > 104857600 then
		return g_logger.error("Something went wrong, file is above 100MB, won't be saved")
	end

	g_resources.writeFileContents(file, result)
end
