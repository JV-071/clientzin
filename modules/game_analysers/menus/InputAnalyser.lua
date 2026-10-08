if not InputAnalyser then
	InputAnalyser = {
		monsterName = "",
		maxDPS = 0,
		total = 0,
		session = 0,
		launchTime = 0,
		sourceVisible = true,
		typesVisible = true,
		graphVisible = true,
		inputValues = {},
		damageTicks = {},
		damageEffect = {}
	}
	InputAnalyser.__index = InputAnalyser
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

local function applyDamageTypesAnchors(contentsPanel, arg_1_1)
	if not contentsPanel then
		return
	end

	function contentsPanel.onMousePress(unusedArgument, arg_2_1, arg_2_2)
		if arg_2_2 == MouseRightButton then
			onInputExtra(arg_2_1, arg_1_1)

			return true
		end
	end
end

local function var_0_3(contentsPanel)
	if not contentsPanel.damageTypeLabel:isVisible() then
		return
	end

	local hasEffects = next(InputAnalyser.damageEffect) ~= nil

	contentsPanel.noDataLabel1:setVisible(not hasEffects)
	contentsPanel.dmgTypes:setVisible(hasEffects)
	contentsPanel.noDataLabel1:removeAnchor(AnchorTop)
	contentsPanel.noDataLabel1:addAnchor(AnchorTop, "damageTypeLabel", AnchorBottom)
	contentsPanel.noDataLabel1:setMarginTop(4)
	contentsPanel.dmgTypes:removeAnchor(AnchorTop)

	if hasEffects then
		contentsPanel.dmgTypes:addAnchor(AnchorTop, "damageTypeLabel", AnchorBottom)
		contentsPanel.dmgTypes:setMarginTop(5)
	else
		contentsPanel.dmgTypes:addAnchor(AnchorTop, "noDataLabel1", AnchorBottom)
		contentsPanel.dmgTypes:setMarginTop(0)
	end

	contentsPanel.separatorDmgType:removeAnchor(AnchorTop)

	if hasEffects then
		contentsPanel.separatorDmgType:addAnchor(AnchorTop, "dmgTypes", AnchorBottom)
	else
		contentsPanel.separatorDmgType:addAnchor(AnchorTop, "noDataLabel1", AnchorBottom)
	end

	contentsPanel.separatorDmgType:setMarginTop(7)
end

local function syncDamageSourcesEmptyState(contentsPanel)
	if not contentsPanel.damageSource:isVisible() then
		contentsPanel.noDataLabel2:setVisible(false)

		return
	end

	local emptyGlobal = table.empty(InputAnalyser.inputValues)

	contentsPanel.noDataLabel2:setVisible(emptyGlobal)
	contentsPanel.dmgSrc:setVisible(not emptyGlobal)
end

local function valueInSeconds(t)
	local d = t.dmgSourceTypes
	local var_5_1 = {}
	local var_5_2 = InputAnalyser.inputValues[InputAnalyser.monsterName]

	if var_5_2 then
		local var_5_3 = 1

		for iter_5_0, damage in pairs(var_5_2) do
			local var_5_4 = "sourceEffect" .. tostring(iter_5_0)
			local widget = d:getChildById(var_5_4)

			if not widget then
				widget = g_ui.createWidget("DamagePanel", d)

				widget:setId(var_5_4)
				applyDamageTypesAnchors(widget, "sources")
				widget.icon:setImageSource(string.format(imageDir, effectsFiles[iter_5_0]))
				widget.icon:setTooltip(getCombatName(iter_5_0))
			end

			var_5_1[var_5_4] = true
			var_5_3 = var_5_3 + 1

			local percent = damage * 100 / InputAnalyser.total

			widget.desc:setText(formatMoney(damage, ",") .. " (" .. string.format("%.1f", percent) .. "%)")
		end

		d:setHeight(15 * var_5_3)
	elseif table.empty(InputAnalyser.inputValues) then
		d:setHeight(1)
	end

	for unusedValue, noData in pairs(d:getChildren()) do
		if not var_5_1[noData:getId()] then
			noData:destroy()
		end
	end
end

local function var_0_6(t)
	local d = 0
	local time = 0
	local now = g_clock.millis()

	if #t > 0 then
		local itemsToBeRemoved = 0

		for i, v in ipairs(t) do
			if now - v.tick <= 3000 then
				if time == 0 then
					time = v.tick
				end

				d = d + v.amount
			else
				itemsToBeRemoved = itemsToBeRemoved + 1
			end
		end

		for i = 1, itemsToBeRemoved do
			table.remove(t, 1)
		end
	end

	return math.ceil(d / ((now - time) / 1000))
end

function InputAnalyser.create(unusedArgument)
	InputAnalyser.window = openedWindows.damageButton
	InputAnalyser.launchTime = g_clock.millis()
	InputAnalyser.session = 0
	InputAnalyser.total = 0
	InputAnalyser.maxDPS = 0
	InputAnalyser.monsterName = ""
	InputAnalyser.inputValues = {}
	InputAnalyser.damageEffect = {}
	InputAnalyser.damageTicks = {}

	local contentsPanel = InputAnalyser.window.contentsPanel

	for unusedValue, iter_7_1 in ipairs({
		contentsPanel.graphPanel,
		contentsPanel.horizontalGraph
	}) do
		applyDamageTypesAnchors(iter_7_1, "graph")
	end

	for unusedValue, iter_7_3 in ipairs({
		contentsPanel.damageTypeLabel,
		contentsPanel.noDataLabel1,
		contentsPanel.dmgTypes
	}) do
		applyDamageTypesAnchors(iter_7_3, "types")
	end

	for unusedValue, iter_7_5 in ipairs({
		contentsPanel.damageSource,
		contentsPanel.noDataLabel2,
		contentsPanel.damageSourceName,
		contentsPanel.dmgSrc,
		contentsPanel.dmgSourceTypes
	}) do
		applyDamageTypesAnchors(iter_7_5, "sources")
	end
end

function InputAnalyser.reset(self)
	InputAnalyser.launchTime = g_clock.millis()
	InputAnalyser.session = 0
	InputAnalyser.total = 0
	InputAnalyser.maxDPS = 0
	InputAnalyser.monsterName = ""
	InputAnalyser.inputValues = {}
	InputAnalyser.damageEffect = {}
	InputAnalyser.damageTicks = {}

	analyserUIGraphReset(InputAnalyser.window.contentsPanel.graphPanel, nil, ANALYSER_GRAPH_CAPACITY_4_MIN)
	InputAnalyser:toggleDamageSource(false)

	local contentsPanel = InputAnalyser.window.contentsPanel

	contentsPanel.dmgTypes:destroyChildren()
	contentsPanel.dmgSrc:destroyChildren()
	InputAnalyser:updateWindow(true)
end

function InputAnalyser.updateWindow(unusedArgument, ignoreVisible)
	if not InputAnalyser.window then
		return
	end

	if not InputAnalyser.window:isVisible() and not ignoreVisible then
		return
	end

	InputAnalyser:checkAnchos()

	local contentsPanel = InputAnalyser.window.contentsPanel
	local numericValue = tonumber(InputAnalyser.maxDPS) or 1

	contentsPanel.rcvDmg:setText(formatMoney(InputAnalyser.total, ","))
	contentsPanel.maxDps:setText(formatMoney(numericValue, ","))

	local var_9_2 = 1
	local widgets = {}

	for monsterName, iter_9_1 in pairs(InputAnalyser.damageEffect) do
		local widget = contentsPanel.dmgTypes:recursiveGetChildById(tostring(monsterName))

		if not widget then
			widget = g_ui.createWidget("DamagePanel", contentsPanel.dmgTypes)

			applyDamageTypesAnchors(widget, "types")
		end

		local percent = iter_9_1 * 100 / InputAnalyser.total

		widget:setId(monsterName)
		widget.icon:setImageSource(string.format(imageDir, effectsFiles[monsterName]))
		widget.icon:setTooltip(getCombatName(monsterName))
		widget.desc:setText(formatMoney(iter_9_1, ",") .. " (" .. string.format("%.1f", percent) .. "%)")

		var_9_2 = var_9_2 + 1

		table.insert(widgets, {
			widget = widget,
			percent = percent
		})
	end

	table.sort(widgets, function(a, b)
		return a.percent > b.percent
	end)

	for index, item in ipairs(widgets) do
		contentsPanel.dmgTypes:moveChildToIndex(item.widget, index)
	end

	if next(InputAnalyser.damageEffect) ~= nil then
		contentsPanel.dmgTypes:setHeight(15 * var_9_2)
	else
		contentsPanel.dmgTypes:setHeight(1)
	end

	if var_9_2 > 1 then
		local nodata = contentsPanel.dmgTypes:recursiveGetChildById("nodata")

		if nodata then
			nodata:destroy()
		end
	end

	var_0_3(contentsPanel)

	local count = 1
	local widgets = {}

	for key, inputValue in pairs(InputAnalyser.inputValues) do
		local var_9_9 = 0

		for unusedValue, entry in pairs(inputValue) do
			var_9_9 = var_9_9 + entry
		end

		local damageSourcePanelWidget = contentsPanel.dmgSrc:recursiveGetChildById(key)

		if not damageSourcePanelWidget then
			damageSourcePanelWidget = g_ui.createWidget("DamageSourcePanel", contentsPanel.dmgSrc)

			applyDamageTypesAnchors(damageSourcePanelWidget, "sources")
		end

		count = count + 1

		damageSourcePanelWidget:setId(key)
		damageSourcePanelWidget.name:setText(short_text(string.capitalize(key), 17))
		damageSourcePanelWidget:setTooltip(string.capitalize(key))

		local percent = var_9_9 * 100 / InputAnalyser.total

		damageSourcePanelWidget.desc:setText(string.format("%.1f", percent) .. "%")

		function damageSourcePanelWidget.onClick()
			if InputAnalyser.monsterName == key then
				InputAnalyser.monsterName = ""

				InputAnalyser:toggleDamageSource(false)
			else
				InputAnalyser.monsterName = key

				InputAnalyser:toggleDamageSource(true)
			end
		end

		table.insert(widgets, {
			widget = damageSourcePanelWidget,
			percent = percent
		})
	end

	table.sort(widgets, function(a, b)
		return a.percent > b.percent
	end)

	for index, item in ipairs(widgets) do
		contentsPanel.dmgSrc:moveChildToIndex(item.widget, index)
	end

	if next(InputAnalyser.inputValues) == nil then
		contentsPanel.dmgSrc:setHeight(1)
	else
		contentsPanel.dmgSrc:setHeight(15 + 10 * count)
	end

	if count > 1 then
		local noData = contentsPanel.dmgSrc:recursiveGetChildById("nodata")

		if noData then
			noData:destroy()
		end
	end

	valueInSeconds(contentsPanel)
	syncDamageSourcesEmptyState(contentsPanel)
	InputAnalyser:checkAnchos()
end

function InputAnalyser.checkDPS(unusedArgument)
	local curDPS = var_0_6(InputAnalyser.damageTicks)

	if not curDPS or not tonumber(curDPS) then
		curDPS = 0
	end

	InputAnalyser.curDPS = curDPS

	local lastDps = tonumber(InputAnalyser.maxDPS) or 1

	InputAnalyser.maxDPS = curDPS < InputAnalyser.maxDPS and InputAnalyser.maxDPS or curDPS

	if not tonumber(InputAnalyser.maxDPS) then
		InputAnalyser.maxDPS = lastDps
	end

	InputAnalyser.window.contentsPanel.maxDps:setText(formatMoney(InputAnalyser.maxDPS, ","))
	analyserUIGraphPushValue(InputAnalyser.window.contentsPanel.graphPanel, InputAnalyser.curDPS)
end

function InputAnalyser.addInputDamage(self, amount, effect, target)
	if not InputAnalyser.inputValues[target] then
		InputAnalyser.inputValues[target] = {}
	end

	if not InputAnalyser.inputValues[target][effect] then
		InputAnalyser.inputValues[target][effect] = 0
	end

	InputAnalyser.inputValues[target][effect] = InputAnalyser.inputValues[target][effect] + amount
	InputAnalyser.total = InputAnalyser.total + amount
	InputAnalyser.damageTicks[#InputAnalyser.damageTicks + 1] = {
		amount = amount,
		tick = g_clock.millis()
	}

	if not InputAnalyser.damageEffect[effect] then
		InputAnalyser.damageEffect[effect] = 0
	end

	InputAnalyser.damageEffect[effect] = InputAnalyser.damageEffect[effect] + amount
end

function InputAnalyser.toggleDamageSource(unusedArgument, bool)
	local cp = InputAnalyser.window.contentsPanel

	cp.dmgSourceTypes:setVisible(bool)
	cp.damageSourceName:setText(string.capitalize(InputAnalyser.monsterName))
	valueInSeconds(cp)
	syncDamageSourcesEmptyState(cp)
end

function onInputExtra(arg_16_0, mousePosition)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	mousePosition = mousePosition or "full"

	local graphVisible = InputAnalyser.window.contentsPanel
	local var_16_1 = graphVisible.graphPanel:isVisible()
	local typesVisible = graphVisible.damageTypeLabel:isVisible()
	local sourceVisible = graphVisible.damageSource:isVisible()
	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	if mousePosition == "full" then
		menu:addOption(tr("Reset Data"), function()
			InputAnalyser:reset()
		end)
		menu:addSeparator()
	end

	if mousePosition == "full" or mousePosition == "graph" then
		menu:addCheckBoxOption(tr("Show Damage Graph"), function()
			InputAnalyser:setDamageGraph(not var_16_1, true)
		end, "", var_16_1)
	end

	if mousePosition == "full" or mousePosition == "types" then
		menu:addCheckBoxOption(tr("Show Damage Types"), function()
			InputAnalyser:setDamageTypes(not typesVisible, true)
		end, "", typesVisible)
	end

	if mousePosition == "full" or mousePosition == "sources" then
		menu:addCheckBoxOption(tr("Show Damage Sources"), function()
			InputAnalyser:setDamageSource(not sourceVisible, true)
		end, "", sourceVisible)
	end

	if mousePosition == "full" then
		menu:addSeparator()
		menu:addOption(tr("Copy to Clipboard"), function()
			InputAnalyser:clipboardData()
		end)
	end

	menu:display(arg_16_0)

	return true
end

function InputAnalyser.checkAnchos(self)
	if InputAnalyser.window.contentsPanel.graphPanel:isVisible() then
		InputAnalyser.window.contentsPanel.damageTypeLabel:addAnchor(AnchorTop, "separatorGraph", AnchorBottom)
	else
		InputAnalyser.window.contentsPanel.damageTypeLabel:addAnchor(AnchorTop, "separatorMaxDps", AnchorBottom)
	end

	if InputAnalyser.window.contentsPanel.damageTypeLabel:isVisible() then
		InputAnalyser.window.contentsPanel.damageSource:addAnchor(AnchorTop, "separatorDmgType", AnchorBottom)
	elseif InputAnalyser.window.contentsPanel.graphPanel:isVisible() then
		InputAnalyser.window.contentsPanel.damageSource:addAnchor(AnchorTop, "separatorGraph", AnchorBottom)
	else
		InputAnalyser.window.contentsPanel.damageSource:addAnchor(AnchorTop, "separatorMaxDps", AnchorBottom)
	end
end

function InputAnalyser.setDamageGraph(self, value, check)
	InputAnalyser.window.contentsPanel.graphPanel:setVisible(value)
	InputAnalyser.window.contentsPanel.horizontalGraph:setVisible(value)
	InputAnalyser.window.contentsPanel.separatorGraph:setVisible(value)

	InputAnalyser.graphVisible = value

	if check then
		InputAnalyser:checkAnchos()
	end
end

function InputAnalyser.setDamageTypes(self, value, check)
	InputAnalyser.typesVisible = value

	InputAnalyser.window.contentsPanel.damageTypeLabel:setVisible(value)
	InputAnalyser.window.contentsPanel.separatorDmgType:setVisible(value)

	if value then
		InputAnalyser:updateWindow(true)
	else
		InputAnalyser.window.contentsPanel.noDataLabel1:setVisible(false)
		InputAnalyser.window.contentsPanel.dmgTypes:setVisible(false)
	end

	if check then
		InputAnalyser:checkAnchos()
	end
end

function InputAnalyser.setDamageSource(unusedArgument, value, check)
	local cp = InputAnalyser.window.contentsPanel

	cp.damageSource:setVisible(value)

	InputAnalyser.sourceVisible = value

	if not value then
		cp.dmgSrc:setVisible(false)
		cp.noDataLabel2:setVisible(false)
	end

	InputAnalyser:toggleDamageSource(value)

	if value then
		syncDamageSourcesEmptyState(cp)
	end

	if check then
		InputAnalyser:checkAnchos()
	end
end

function InputAnalyser.clipboardData(unusedArgument)
	local text = (("Received Damage" .. "\nTotal: " .. formatMoney(InputAnalyser.total, ",")) .. "\nMax-DPS: " .. formatMoney(InputAnalyser.maxDPS, ",")) .. "\nDamage Types"

	if table.empty(InputAnalyser.inputValues) then
		text = text .. "\n\tNo Data"
	else
		local count = 1

		for effect, damage in pairs(InputAnalyser.damageEffect) do
			local percent = damage * 100 / InputAnalyser.total

			text = text .. "\n\t" .. getCombatName(effect) .. " " .. formatMoney(damage, ",") .. " (" .. string.format("%.1f", percent) .. "%)"
		end
	end

	local text = text .. "\nDamage Sources"

	if table.empty(InputAnalyser.inputValues) then
		text = text .. "\n\tNo Data"
	else
		for monsterName, damageInfo in pairs(InputAnalyser.inputValues) do
			local damageMonster = 0

			for effect, damage in pairs(damageInfo) do
				damageMonster = damageMonster + damage
			end

			local percent = damageMonster * 100 / InputAnalyser.total

			text = text .. "\n\t" .. string.capitalize(monsterName) .. " " .. formatMoney(damageMonster, ",") .. " (" .. string.format("%.1f", percent) .. "%)"
		end
	end

	if InputAnalyser.inputValues[InputAnalyser.monsterName] then
		text = text .. "\n" .. string.capitalize(InputAnalyser.monsterName)

		for effect, damage in pairs(InputAnalyser.inputValues[InputAnalyser.monsterName]) do
			local percent = damage * 100 / InputAnalyser.total

			text = text .. "\n\t" .. getCombatName(effect) .. " " .. formatMoney(damage, ",") .. " (" .. string.format("%.1f", percent) .. "%)"
		end
	end

	g_window.setClipboardText(text)
end

function InputAnalyser.damageGraphIsVisible(self)
	return InputAnalyser.graphVisible
end

function InputAnalyser.damageTypesIsVisible(self)
	return InputAnalyser.typesVisible
end

function InputAnalyser.damageSourceIsVisible(self)
	return InputAnalyser.sourceVisible
end

function InputAnalyser.loadConfigJson(self)
	local config = {
		showDamageSources = true,
		showDamageGraph = true,
		showSessionValues = false,
		showDamageTypes = true
	}
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local file = "/characterdata/" .. player:getId() .. "/damageinputanalyser.json"

	if g_resources.fileExists(file) then
		local status, result = pcall(function()
			return json.decode(g_resources.readFileContents(file))
		end)

		if not status then
			return g_logger.error("Error while reading characterdata file. Details: " .. result)
		end

		config = result
	end

	InputAnalyser:setDamageGraph(config.showDamageGraph, false)
	InputAnalyser:setDamageSource(config.showDamageSources, false)
	InputAnalyser:setDamageTypes(config.showDamageTypes, false)
	InputAnalyser:checkAnchos()
end

function InputAnalyser.saveConfigJson(self)
	if not LoadedPlayer:isLoaded() then
		return
	end

	local config = {
		showSessionValues = false,
		showDamageGraph = InputAnalyser:damageGraphIsVisible(),
		showDamageSources = InputAnalyser:damageSourceIsVisible(),
		showDamageTypes = InputAnalyser:damageTypesIsVisible()
	}
	local file = "/characterdata/" .. LoadedPlayer:getId() .. "/damageinputanalyser.json"
	local status, result = pcall(function()
		return json.encode(config, 2)
	end)

	if not status then
		return g_logger.error("Error while saving profile itemsData. Data won't be saved. Details: " .. result)
	end

	if result:len() > 104857600 then
		return g_logger.error("Something went wrong, file is above 100MB, won't be saved")
	end

	g_resources.writeFileContents(file, result)
end
