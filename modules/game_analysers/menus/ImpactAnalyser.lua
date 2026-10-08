if not ImpactAnalyser then
	ImpactAnalyser = {
		dps = 0,
		maxHPS = 0,
		healingTotal = 0,
		targetHPS = 1,
		damageTypeVisible = true,
		graphHPSVisible = true,
		gaugeHPSVisible = true,
		graphDPSVisible = true,
		gaugeDPSVisible = true,
		targetDPS = 1,
		allTimeHightHps = 0,
		allTimeHightDps = 0,
		damageTotal = 0,
		session = 0,
		launchTime = 0,
		maxDPS = 0,
		gaugeHps = 0,
		gaugeDps = 0,
		damageEffect = {},
		damageEffectWindows = {}
	}
	ImpactAnalyser.__index = ImpactAnalyser
end

local targetMaxMargin = 142
local var_0_1 = 3600000
local var_0_2 = 10000

local function updateSessionMaxRates()
	local var_1_0 = g_clock.millis()

	ImpactAnalyser.damageTotal = AnalyserSession:rollingTotal(ImpactAnalyser.damageWindow, var_1_0)
	ImpactAnalyser.healingTotal = AnalyserSession:rollingTotal(ImpactAnalyser.healingWindow, var_1_0)
	ImpactAnalyser.gaugeDps = AnalyserSession:rollingRate(ImpactAnalyser.damageWindow, var_0_2, 1000, var_1_0)
	ImpactAnalyser.gaugeHps = AnalyserSession:rollingRate(ImpactAnalyser.healingWindow, var_0_2, 1000, var_1_0)
	ImpactAnalyser.dps = ImpactAnalyser.gaugeDps

	for key, damageEffectWindow in pairs(ImpactAnalyser.damageEffectWindows) do
		local var_1_1 = AnalyserSession:rollingTotal(damageEffectWindow, var_1_0)

		if var_1_1 > 0 then
			ImpactAnalyser.damageEffect[key] = var_1_1
		else
			ImpactAnalyser.damageEffect[key] = nil
			ImpactAnalyser.damageEffectWindows[key] = nil
		end
	end

	ImpactAnalyser.maxDPS = math.max(tonumber(ImpactAnalyser.maxDPS) or 0, ImpactAnalyser.gaugeDps or 0)
	ImpactAnalyser.maxHPS = math.max(tonumber(ImpactAnalyser.maxHPS) or 0, ImpactAnalyser.gaugeHps or 0)
end

local function parseImpactTargetAmount(text)
	if not text or text == "" then
		return 0
	end

	local digits = tostring(text):gsub("%D", "")

	if digits == "" then
		return 0
	end

	return tonumber(digits) or 0
end

local function updateImpactTargetArrow(arrow, numericValue, target)
	if not arrow then
		return
	end

	numericValue = tonumber(numericValue) or 0
	target = tonumber(target) or 0

	if target <= 0 and numericValue <= 0 then
		arrow:setMarginLeft(math.floor(targetMaxMargin / 2))

		return
	end

	if target <= 0 then
		arrow:setMarginLeft(targetMaxMargin)

		return
	end

	local var_3_0 = numericValue / math.max(1, target)

	if var_3_0 < 0 then
		var_3_0 = 0
	elseif var_3_0 > 1 then
		var_3_0 = 1
	end

	arrow:setMarginLeft(math.floor(targetMaxMargin * var_3_0 + 0.5))
end

local imageDir = "/modules/game_cyclopedia/images/bestiary/icons/monster-icon-%s-resist"
local effectsFiles = {
	[0] = "physical",
	"fire",
	"earth",
	"energy",
	"ice",
	"holy",
	"death",
	"healing",
	"drowning",
	"lifedrain",
	"manadrain",
	"agony",
	"agony"
}

function ImpactAnalyser.create(unusedArgument)
	ImpactAnalyser.launchTime = 0
	ImpactAnalyser.session = 0
	ImpactAnalyser.damageTotal = 0
	ImpactAnalyser.dps = 0
	ImpactAnalyser.maxDPS = 0
	ImpactAnalyser.damageWindow = AnalyserSession:newRollingWindow(var_0_1)
	ImpactAnalyser.healingWindow = AnalyserSession:newRollingWindow(var_0_1)
	ImpactAnalyser.damageEffect = {}
	ImpactAnalyser.damageEffectWindows = {}
	ImpactAnalyser.allTimeHightDps = 0
	ImpactAnalyser.allTimeHightHps = 0
	ImpactAnalyser.targetDPS = 1
	ImpactAnalyser.gaugeDPSVisible = true
	ImpactAnalyser.graphDPSVisible = true
	ImpactAnalyser.gaugeHPSVisible = true
	ImpactAnalyser.graphHPSVisible = true
	ImpactAnalyser.damageTypeVisible = true
	ImpactAnalyser.targetHPS = 1
	ImpactAnalyser.healingTotal = 0
	ImpactAnalyser.maxHPS = 0
	ImpactAnalyser.window = openedWindows.impactButton

	function ImpactAnalyser.window.contentsPanel.dpsBG.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onImpactExtra(mousePosition, "dpsBG")

			return true
		end
	end

	function ImpactAnalyser.window.contentsPanel.graphDpsPanel.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onImpactExtra(mousePosition, "graphDpsPanel")

			return true
		end
	end

	function ImpactAnalyser.window.contentsPanel.hpsBG.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onImpactExtra(mousePosition, "hpsBG")

			return true
		end
	end

	function ImpactAnalyser.window.contentsPanel.graphHealPanel.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onImpactExtra(mousePosition, "graphHealPanel")

			return true
		end
	end

	local contentsPanel = ImpactAnalyser.window.contentsPanel

	local function handleMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseLeftButton then
			ImpactAnalyser:openTargetConfig(true)

			return true
		end
	end

	local function var_4_2(widget, mousePosition, mouseButton)
		if mouseButton == MouseLeftButton then
			ImpactAnalyser:openTargetConfig(false)

			return true
		end
	end

	contentsPanel.targetDpsLabel.onMousePress = handleMousePress
	contentsPanel.targetDps.onMousePress = handleMousePress
	contentsPanel.targetHpsLabel.onMousePress = var_4_2
	contentsPanel.targetHps.onMousePress = var_4_2
end

function ImpactAnalyser.reset(unusedArgument, allTimeDps, allTimeHps)
	ImpactAnalyser.launchTime = g_clock.millis()
	ImpactAnalyser.session = 0
	ImpactAnalyser.damageTotal = 0
	ImpactAnalyser.dps = 0
	ImpactAnalyser.gaugeDps = 0
	ImpactAnalyser.gaugeHps = 0
	ImpactAnalyser.maxDPS = 0
	ImpactAnalyser.maxHPS = 0

	if allTimeDps then
		ImpactAnalyser.allTimeHightDps = 0
	end

	if allTimeHps then
		ImpactAnalyser.allTimeHightHps = 0
	end

	ImpactAnalyser.damageWindow = AnalyserSession:resetRollingWindow(ImpactAnalyser.damageWindow, var_0_1)
	ImpactAnalyser.healingWindow = AnalyserSession:resetRollingWindow(ImpactAnalyser.healingWindow, var_0_1)
	ImpactAnalyser.damageEffect = {}
	ImpactAnalyser.damageEffectWindows = {}
	ImpactAnalyser.healingTotal = 0

	analyserUIGraphReset(ImpactAnalyser.window.contentsPanel.graphDpsPanel, nil, ANALYSER_GRAPH_CAPACITY_4_MIN)
	analyserUIGraphReset(ImpactAnalyser.window.contentsPanel.graphHealPanel, nil, ANALYSER_GRAPH_CAPACITY_4_MIN)
	ImpactAnalyser:updateWindow(true)
end

function ImpactAnalyser.refreshGaugeRates(unusedArgument)
	updateSessionMaxRates()
end

function ImpactAnalyser.updateGraphics(unusedArgument)
	updateSessionMaxRates()

	local var_13_0 = ImpactAnalyser.window and ImpactAnalyser.window.contentsPanel

	if not var_13_0 then
		return
	end

	analyserUIGraphPushValue(var_13_0.graphDpsPanel, ImpactAnalyser.gaugeDps or 0)
	analyserUIGraphPushValue(var_13_0.graphHealPanel, ImpactAnalyser.gaugeHps or 0)
end

function ImpactAnalyser.updateWindow(unusedArgument, ignoreVisible)
	if not ImpactAnalyser.window:isVisible() and not ignoreVisible then
		return
	end

	ImpactAnalyser:checkAnchos()
	ImpactAnalyser:refreshGaugeRates()

	local contentsPanel = ImpactAnalyser.window.contentsPanel

	contentsPanel.dmg:setText(formatMoney(ImpactAnalyser.damageTotal, ","))
	contentsPanel.allTimeHigh:setText(formatMoney(ImpactAnalyser.allTimeHightDps, ","))

	local var_14_1 = ImpactAnalyser.gaugeDps or 0
	local var_14_2 = math.max(tonumber(ImpactAnalyser.maxDPS) or 0, var_14_1)

	contentsPanel.maxDps:setText(formatMoney(var_14_2, ","))
	contentsPanel.dps:setText(formatMoney(var_14_1, ","))
	contentsPanel.targetDps:setText(formatMoney(ImpactAnalyser.targetDPS or 0, ","))
	updateImpactTargetArrow(contentsPanel.dpsBG and contentsPanel.dpsBG.dpsArrow, var_14_1, ImpactAnalyser.targetDPS)
	contentsPanel.dpsBG:setTooltip(string.format("Current: %d\nTarget: %d", var_14_1, ImpactAnalyser.targetDPS or 0))

	local noData = contentsPanel.dmgTypes:getChildById("noData")
	local var_14_4 = not table.empty(ImpactAnalyser.damageEffect)

	for unusedValue, child in pairs(contentsPanel.dmgTypes:getChildren()) do
		child.toBeRemoved = child:getId() ~= "noData"
	end

	if var_14_4 then
		for effect, damage in pairs(ImpactAnalyser.damageEffect) do
			local widget = contentsPanel.dmgTypes:getChildById("DamageEffect_" .. effect)

			if not widget then
				widget = g_ui.createWidget("DamagePanel", contentsPanel.dmgTypes)

				widget:setId("DamageEffect_" .. effect)
				widget.icon:setImageSource(string.format(imageDir, effectsFiles[effect]))
				widget.icon:setTooltip(getCombatName(effect))
			end

			local percent = damage * 100 / ImpactAnalyser.damageTotal

			widget.desc:setText(formatMoney(damage, ",") .. " (" .. string.format("%.1f", percent) .. "%)")

			widget.toBeRemoved = false
		end
	end

	for _, child in pairs(contentsPanel.dmgTypes:getChildren()) do
		if child.toBeRemoved then
			child:destroy()
		end
	end

	if not var_14_4 and not noData then
		noData = g_ui.createWidget("NoDataLabel", contentsPanel.dmgTypes)

		noData:setId("noData")
	end

	if noData then
		noData:setVisible(not var_14_4)
	end

	contentsPanel.hpsTotal:setText(formatMoney(ImpactAnalyser.healingTotal, ","))
	contentsPanel.allTimeHighHealing:setText(formatMoney(ImpactAnalyser.allTimeHightHps, ","))

	local sessionHps = ImpactAnalyser.gaugeHps or 0
	local maxHps = math.max(tonumber(ImpactAnalyser.maxHPS) or 0, sessionHps)

	contentsPanel.maxHps:setText(formatMoney(maxHps, ","))
	contentsPanel.hps:setText(formatMoney(sessionHps, ","))
	contentsPanel.targetHps:setText(formatMoney(ImpactAnalyser.targetHPS or 0, ","))
	updateImpactTargetArrow(contentsPanel.hpsBG and contentsPanel.hpsBG.hpsArrow, sessionHps, ImpactAnalyser.targetHPS)
	contentsPanel.hpsBG:setTooltip(string.format("Current: %d\nTarget: %d", sessionHps, ImpactAnalyser.targetHPS or 0))
end

function ImpactAnalyser.addDealDamage(unusedArgument, amount, numericValue)
	amount = tonumber(amount) or 0
	numericValue = tonumber(numericValue) or 0

	if amount <= 0 then
		return
	end

	if amount > ImpactAnalyser.allTimeHightDps then
		ImpactAnalyser.allTimeHightDps = amount
	end

	AnalyserSession:addRollingValue(ImpactAnalyser.damageWindow, amount)

	if not ImpactAnalyser.damageEffectWindows[numericValue] then
		ImpactAnalyser.damageEffectWindows[numericValue] = AnalyserSession:newRollingWindow(var_0_1)
	end

	AnalyserSession:addRollingValue(ImpactAnalyser.damageEffectWindows[numericValue], amount)
	updateSessionMaxRates()
	ImpactAnalyser:updateWindow(true)
end

function ImpactAnalyser.addHealing(unusedArgument, amount)
	amount = tonumber(amount) or 0

	if amount <= 0 then
		return
	end

	if amount > ImpactAnalyser.allTimeHightHps then
		ImpactAnalyser.allTimeHightHps = amount
	end

	AnalyserSession:addRollingValue(ImpactAnalyser.healingWindow, amount)
	updateSessionMaxRates()
	ImpactAnalyser:updateWindow(true)
end

function onImpactExtra(mousePosition, mode)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	if mode == "false" then
		menu:addOption(tr("Reset Data"), function()
			ImpactAnalyser:reset(false)
		end)
		menu:addOption(tr("Reset All-Time High"), function()
			ImpactAnalyser:setAllTimeHightDps(0)
			ImpactAnalyser:setAllTimeHightHps(0)
		end)
		menu:addOption(tr("Show Session Values"), function()
			return
		end)
		menu:addSeparator()
		menu:addOption(tr("Set DPS target"), function()
			ImpactAnalyser:openTargetConfig(true)
		end)
		menu:addCheckBoxOption(tr("DPS gauge"), function()
			ImpactAnalyser:setDPSGauge(not ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible())
		menu:addCheckBoxOption(tr("DPS graph"), function()
			ImpactAnalyser:setDPSGraph(not ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible())
		menu:addSeparator()
		menu:addCheckBoxOption(tr("Damage Types"), function()
			ImpactAnalyser:setDamageType(not ImpactAnalyser.window.contentsPanel.damageTypeLabel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.damageTypeLabel:isVisible())
		menu:addSeparator()
		menu:addOption(tr("Set HPS target"), function()
			ImpactAnalyser:openTargetConfig(false)
		end)
		menu:addCheckBoxOption(tr("HPS gauge"), function()
			ImpactAnalyser:setHPSGauge(not ImpactAnalyser.window.contentsPanel.targetHpsLabel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.targetHpsLabel:isVisible())
		menu:addCheckBoxOption(tr("HPS graph"), function()
			ImpactAnalyser:setHPSGraph(not ImpactAnalyser.window.contentsPanel.graphHealPanel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.graphHealPanel:isVisible())
		menu:display(mousePosition)

		return true
	end

	if mode == "dpsBG" then
		menu:addOption(tr("Set DPS target"), function()
			ImpactAnalyser:openTargetConfig(true)
		end)
		menu:addCheckBoxOption(tr("DPS gauge"), function()
			ImpactAnalyser:setDPSGauge(not ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible())
	end

	if mode == "graphDpsPanel" then
		menu:addCheckBoxOption(tr("DPS graph"), function()
			ImpactAnalyser:setDPSGraph(not ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible())
	end

	if mode == "hpsBG" then
		menu:addOption(tr("Set HPS target"), function()
			ImpactAnalyser:openTargetConfig(false)
		end)
		menu:addCheckBoxOption(tr("HPS gauge"), function()
			ImpactAnalyser:setHPSGauge(not ImpactAnalyser.window.contentsPanel.targetHpsLabel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.targetHpsLabel:isVisible())
	end

	if mode == "graphHealPanel" then
		menu:addCheckBoxOption(tr("HPS graph"), function()
			ImpactAnalyser:setHPSGraph(not ImpactAnalyser.window.contentsPanel.graphHealPanel:isVisible(), true)
		end, "", ImpactAnalyser.window.contentsPanel.graphHealPanel:isVisible())
	end

	menu:display(mousePosition)

	return true
end

function ImpactAnalyser.setTargetDPS(unusedArgument, value)
	ImpactAnalyser.targetDPS = math.max(0, parseImpactTargetAmount(value))

	if ImpactAnalyser.window and ImpactAnalyser.window.contentsPanel then
		ImpactAnalyser.window.contentsPanel.targetDps:setText(formatMoney(ImpactAnalyser.targetDPS, ","))
	end

	ImpactAnalyser:updateWindow(true)
end

function ImpactAnalyser.setTargetHPS(unusedArgument, value)
	ImpactAnalyser.targetHPS = math.max(0, parseImpactTargetAmount(value))

	if ImpactAnalyser.window and ImpactAnalyser.window.contentsPanel then
		ImpactAnalyser.window.contentsPanel.targetHps:setText(formatMoney(ImpactAnalyser.targetHPS, ","))
	end

	ImpactAnalyser:updateWindow(true)
end

function ImpactAnalyser.openTargetConfig(self, isDps)
	local window = configPopupWindow.impactButton

	if not window then
		return
	end

	window:show()
	window:raise()
	window:focus()
	window:setText(tr("Set ") .. (isDps and tr("DPS") or tr("HPS")) .. tr(" Target"))
	window.contentPanel.dps:setVisible(isDps)
	window.contentPanel.hps:setVisible(not isDps)

	if isDps then
		window.contentPanel.dps.target:setText(tostring(ImpactAnalyser.targetDPS or 0))
		window.contentPanel.dps.target:focus()
	else
		window.contentPanel.hps.target:setText(tostring(ImpactAnalyser.targetHPS or 0))
		window.contentPanel.hps.target:focus()
	end

	local function applyTarget()
		if isDps then
			ImpactAnalyser:setTargetDPS(window.contentPanel.dps.target:getText())
		else
			ImpactAnalyser:setTargetHPS(window.contentPanel.hps.target:getText())
		end

		ImpactAnalyser:saveConfigJson()
		window:hide()
	end

	window.onEnter = applyTarget
	window.contentPanel.ok.onClick = applyTarget

	function window.contentPanel.cancel.onClick()
		window:hide()
	end
end

function ImpactAnalyser.setDPSGauge(self, value, check)
	ImpactAnalyser.window.contentsPanel.targetDpsLabel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.targetDps:setVisible(value)
	ImpactAnalyser.window.contentsPanel.dpsBG:setVisible(value)
	ImpactAnalyser.window.contentsPanel.dpsLabel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.dps:setVisible(value)
	ImpactAnalyser.window.contentsPanel.separatorDps:setVisible(value)

	ImpactAnalyser.gaugeDPSVisible = value

	if check then
		ImpactAnalyser:checkAnchos()
	end
end

function ImpactAnalyser.setDPSGraph(self, value, check)
	ImpactAnalyser.window.contentsPanel.graphDpsPanel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.graphHorizontal:setVisible(value)
	ImpactAnalyser.window.contentsPanel.separatorGraphHorizontalDps:setVisible(value)

	ImpactAnalyser.graphDPSVisible = value

	if check then
		ImpactAnalyser:checkAnchos()
	end
end

function ImpactAnalyser.setDamageType(self, value, check)
	ImpactAnalyser.window.contentsPanel.damageTypeLabel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.dmgTypes:setVisible(value)
	ImpactAnalyser.window.contentsPanel.separatorDmgType:setVisible(value)

	ImpactAnalyser.damageTypeVisible = value

	if check then
		ImpactAnalyser:checkAnchos()
	end
end

function ImpactAnalyser.setHPSGauge(self, value, check)
	ImpactAnalyser.window.contentsPanel.targetHpsLabel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.targetHps:setVisible(value)
	ImpactAnalyser.window.contentsPanel.hpsBG:setVisible(value)
	ImpactAnalyser.window.contentsPanel.hpsLabelGauge:setVisible(value)
	ImpactAnalyser.window.contentsPanel.hps:setVisible(value)
	ImpactAnalyser.window.contentsPanel.separatorHps:setVisible(value)

	ImpactAnalyser.gaugeHPSVisible = value

	if check then
		ImpactAnalyser:checkAnchos()
	end
end

function ImpactAnalyser.setHPSGraph(self, value, check)
	ImpactAnalyser.window.contentsPanel.graphHealPanel:setVisible(value)
	ImpactAnalyser.window.contentsPanel.graphHPSHorizontal:setVisible(value)

	ImpactAnalyser.graphHPSVisible = value

	if check then
		ImpactAnalyser:checkAnchos()
	end
end

function ImpactAnalyser.checkAnchos(self)
	if ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible() then
		ImpactAnalyser.window.contentsPanel.graphDpsPanel:addAnchor(AnchorTop, "separatorDps", AnchorBottom)
	else
		ImpactAnalyser.window.contentsPanel.graphDpsPanel:addAnchor(AnchorTop, "separatorAllTimeHigh", AnchorBottom)
	end

	if ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible() then
		ImpactAnalyser.window.contentsPanel.damageTypeLabel:addAnchor(AnchorTop, "separatorGraphHorizontalDps", AnchorBottom)
	elseif ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible() then
		ImpactAnalyser.window.contentsPanel.damageTypeLabel:addAnchor(AnchorTop, "separatorDps", AnchorBottom)
	else
		ImpactAnalyser.window.contentsPanel.damageTypeLabel:addAnchor(AnchorTop, "separatorAllTimeHigh", AnchorBottom)
	end

	if ImpactAnalyser.window.contentsPanel.damageTypeLabel:isVisible() then
		ImpactAnalyser.window.contentsPanel.healingLabel:addAnchor(AnchorTop, "separatorDmgType", AnchorBottom)
	elseif ImpactAnalyser.window.contentsPanel.graphDpsPanel:isVisible() then
		ImpactAnalyser.window.contentsPanel.healingLabel:addAnchor(AnchorTop, "separatorGraphHorizontalDps", AnchorBottom)
	elseif ImpactAnalyser.window.contentsPanel.targetDpsLabel:isVisible() then
		ImpactAnalyser.window.contentsPanel.healingLabel:addAnchor(AnchorTop, "separatorDps", AnchorBottom)
	else
		ImpactAnalyser.window.contentsPanel.healingLabel:addAnchor(AnchorTop, "separatorAllTimeHigh", AnchorBottom)
	end

	if ImpactAnalyser.window.contentsPanel.targetHpsLabel:isVisible() then
		ImpactAnalyser.window.contentsPanel.graphHealPanel:addAnchor(AnchorTop, "separatorHps", AnchorBottom)
	else
		ImpactAnalyser.window.contentsPanel.graphHealPanel:addAnchor(AnchorTop, "separatorAllTimeHighHealing", AnchorBottom)
	end
end

function ImpactAnalyser.getAllTimeHightDps(self)
	return ImpactAnalyser.allTimeHightDps
end

function ImpactAnalyser.gaugeDPSIsVisible(self)
	return ImpactAnalyser.gaugeDPSVisible
end

function ImpactAnalyser.graphDPSIsVisible(self)
	return ImpactAnalyser.graphDPSVisible
end

function ImpactAnalyser.gaugeHPSIsVisible(self)
	return ImpactAnalyser.gaugeHPSVisible
end

function ImpactAnalyser.graphHPSIsVisible(self)
	return ImpactAnalyser.graphHPSVisible
end

function ImpactAnalyser.damageTypeIsVisible(self)
	return ImpactAnalyser.damageTypeVisible
end

function ImpactAnalyser.setAllTimeHightDps(self, value)
	ImpactAnalyser.allTimeHightDps = value
end

function ImpactAnalyser.setAllTimeHightHps(self, value)
	ImpactAnalyser.allTimeHightHps = value
end

function ImpactAnalyser.loadConfigJson(self)
	local config = {
		showSessionValues = true,
		maxHealingImpact = 0,
		maxDamageImpact = 0,
		hpsGaugeTargetValue = 1,
		dpsGaugeTargetValue = 1,
		desiredHpsGraphVisible = true,
		desiredHpsGaugeVisible = true,
		desiredDpsGraphVisible = true,
		desiredDpsGaugeVisible = true,
		desiredDamageTypesVisible = true
	}
	local player = g_game.getLocalPlayer()
	local file = "/characterdata/" .. player:getId() .. "/impactanalyser.json"

	if g_resources.fileExists(file) then
		local status, result = pcall(function()
			return json.decode(g_resources.readFileContents(file))
		end)

		if not status then
			return g_logger.error("Error while reading characterdata file. Details: " .. result)
		end

		config = result
	end

	ImpactAnalyser:setDPSGauge(config.desiredDpsGaugeVisible, false)
	ImpactAnalyser:setDPSGraph(config.desiredDpsGraphVisible, false)
	ImpactAnalyser:setDamageType(config.desiredDamageTypesVisible, false)
	ImpactAnalyser:setHPSGauge(config.desiredHpsGaugeVisible, false)
	ImpactAnalyser:setHPSGraph(config.desiredHpsGraphVisible, false)

	ImpactAnalyser.allTimeHightDps = config.maxDamageImpact
	ImpactAnalyser.allTimeHightHps = config.maxHealingImpact

	ImpactAnalyser:setTargetDPS(config.dpsGaugeTargetValue or 0)
	ImpactAnalyser:setTargetHPS(config.hpsGaugeTargetValue or 0)
	ImpactAnalyser:checkAnchos()
end

function ImpactAnalyser.saveConfigJson(self)
	local function checkFinite(value)
		if value == math.huge or value == -math.huge or type(value) ~= "number" then
			return 0
		end

		return value
	end

	local config = {
		showSessionValues = true,
		desiredDamageTypesVisible = ImpactAnalyser:damageTypeIsVisible(),
		desiredDpsGaugeVisible = ImpactAnalyser:gaugeDPSIsVisible(),
		desiredDpsGraphVisible = ImpactAnalyser:graphDPSIsVisible(),
		desiredHpsGaugeVisible = ImpactAnalyser:gaugeHPSIsVisible(),
		desiredHpsGraphVisible = ImpactAnalyser:graphHPSIsVisible(),
		dpsGaugeTargetValue = checkFinite(ImpactAnalyser.targetDPS),
		hpsGaugeTargetValue = checkFinite(ImpactAnalyser.targetHPS),
		maxDamageImpact = checkFinite(ImpactAnalyser.allTimeHightDps),
		maxHealingImpact = checkFinite(ImpactAnalyser.allTimeHightHps)
	}

	if not LoadedPlayer:isLoaded() then
		return
	end

	local file = "/characterdata/" .. LoadedPlayer:getId() .. "/impactanalyser.json"
	local status, result = pcall(function()
		return json.encode(config, 2)
	end)

	if not status then
		return g_logger.error("Error while saving profile ImpactAnalyzer data. Data won't be saved. Details: " .. result)
	end

	if result:len() > 104857600 then
		return g_logger.error("Something went wrong, file is above 100MB, won't be saved")
	end

	g_resources.writeFileContents(file, result)
end
