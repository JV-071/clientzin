if not LootAnalyser then
	LootAnalyser = {
		listDirty = false,
		graphVisible = true,
		gaugeVisible = true,
		target = 0,
		goldHour = 0,
		goldValue = 0,
		session = 0,
		launchTime = 0,
		lootedItems = {}
	}
	LootAnalyser.__index = LootAnalyser
end

local targetMaxMargin = 142
local var_0_1 = 3600000
local var_0_2 = 4096

local function var_0_3()
	return {
		last = 0,
		first = 1,
		entries = {}
	}
end

local function var_0_4(arg_2_0, arg_2_1)
	local lootEvents = LootAnalyser.lootEvents
	local var_2_1 = g_clock.millis()
	local var_2_2 = lootEvents.entries[lootEvents.last]

	if var_2_2 and var_2_2.itemId == arg_2_0 and math.floor(var_2_2.tick / 1000) == math.floor(var_2_1 / 1000) then
		var_2_2.count = var_2_2.count + arg_2_1
		var_2_2.tick = var_2_1

		return
	end

	lootEvents.last = lootEvents.last + 1
	lootEvents.entries[lootEvents.last] = {
		itemId = arg_2_0,
		count = arg_2_1,
		tick = var_2_1
	}
end

local function var_0_5()
	local lootEvents = LootAnalyser.lootEvents

	if not lootEvents then
		return false
	end

	local var_3_1 = g_clock.millis() - var_0_1
	local var_3_2 = false

	while lootEvents.first <= lootEvents.last do
		local var_3_3 = lootEvents.entries[lootEvents.first]

		if not var_3_3 or var_3_1 < var_3_3.tick then
			break
		end

		local var_3_4 = LootAnalyser.lootedItems[var_3_3.itemId]

		if var_3_4 then
			local var_3_5 = math.min(var_3_4.count, var_3_3.count)

			var_3_4.count = var_3_4.count - var_3_5
			LootAnalyser.goldValue = math.max(0, LootAnalyser.goldValue - var_3_4.basePrice * var_3_5)

			if var_3_4.count <= 0 then
				LootAnalyser.lootedItems[var_3_3.itemId] = nil
			end

			var_3_2 = true
		end

		lootEvents.entries[lootEvents.first] = nil
		lootEvents.first = lootEvents.first + 1
	end

	if lootEvents.first > lootEvents.last then
		LootAnalyser.lootEvents = var_0_3()
	elseif lootEvents.first > var_0_2 and lootEvents.first > math.floor(lootEvents.last / 2) then
		local var_3_6 = var_0_3()

		for iter_3_0 = lootEvents.first, lootEvents.last do
			var_3_6.last = var_3_6.last + 1
			var_3_6.entries[var_3_6.last] = lootEvents.entries[iter_3_0]
		end

		LootAnalyser.lootEvents = var_3_6
	end

	if var_3_2 then
		LootAnalyser.listDirty = true
	end

	return var_3_2
end

local function parseLootTargetAmount(text)
	if not text or text == "" then
		return 0
	end

	local digits = tostring(text):gsub("%D", "")

	if digits == "" then
		return 0
	end

	return tonumber(digits) or 0
end

local function updateLootTargetArrow()
	local lootTargetBG = LootAnalyser.window and LootAnalyser.window.contentsPanel and LootAnalyser.window.contentsPanel.lootTargetBG

	if not lootTargetBG or not lootTargetBG.lootArrow then
		return
	end

	local arrow = lootTargetBG.lootArrow
	local target = LootAnalyser.target or 0
	local current = LootAnalyser.goldHour or 0

	if target <= 0 and current <= 0 then
		arrow:setMarginLeft(math.floor(targetMaxMargin / 2))

		return
	end

	if target <= 0 then
		arrow:setMarginLeft(targetMaxMargin)

		return
	end

	local ratio = current / target

	if ratio < 0 then
		ratio = 0
	elseif ratio > 1 then
		ratio = 1
	end

	arrow:setMarginLeft(math.floor(targetMaxMargin * ratio + 0.5))
end

function LootAnalyser.create(unusedArgument)
	LootAnalyser.launchTime = g_clock.millis()
	LootAnalyser.session = 0
	LootAnalyser.goldValue = 0
	LootAnalyser.goldHour = 0
	LootAnalyser.target = 0
	LootAnalyser.gaugeVisible = true
	LootAnalyser.graphVisible = true
	LootAnalyser.lootedItems = {}
	LootAnalyser.lootEvents = var_0_3()
	LootAnalyser.listDirty = false
	LootAnalyser.forceUpdateBalance = false
	LootAnalyser.updateBalance = true
	LootAnalyser.window = openedWindows.lootButton
	LootAnalyser.eventGraph = nil

	local contentsPanel = LootAnalyser.window.contentsPanel

	contentsPanel.separatorLootedItems:setVisible(false)
	contentsPanel.targetLabel:addAnchor(AnchorTop, "separator", AnchorBottom)

	local function openTargetConfigOnLeftClick(widget, mousePosition, mouseButton)
		if mouseButton == MouseLeftButton then
			LootAnalyser:openTargetConfig()

			return true
		end
	end

	contentsPanel.targetLabel.onMousePress = openTargetConfigOnLeftClick
	contentsPanel.goldTarget.onMousePress = openTargetConfigOnLeftClick

	function contentsPanel.lootTargetBG.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onLootingExtra(mousePosition, "gaude")

			return true
		end
	end

	function LootAnalyser.window.contentsPanel.graphPanel.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onLootingExtra(mousePosition, "graph")

			return true
		end
	end
end

function onLootingExtra(mousePosition, mode)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	if mode == "false" then
		menu:addOption(tr("Reset Data"), function()
			LootAnalyser:reset()
		end)
		menu:addSeparator()
		menu:addOption(tr("Set Loot Per Hour Target"), function()
			LootAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("Loot Per Hour Gauge"), function()
			LootAnalyser:setLootPerHourGauge(not LootAnalyser.window.contentsPanel.targetLabel:isVisible())
		end, "", LootAnalyser.window.contentsPanel.targetLabel:isVisible())
		menu:addCheckBoxOption(tr("Loot Per Hour Graph"), function()
			LootAnalyser:setLootPerHourGraph(not LootAnalyser.window.contentsPanel.graphPanel:isVisible())
		end, "", LootAnalyser.window.contentsPanel.graphPanel:isVisible())
		menu:display(mousePosition)

		return true
	end

	if mode == "gaude" then
		menu:addOption(tr("Set Loot Per Hour Target"), function()
			LootAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("Loot Per Hour Gauge"), function()
			LootAnalyser:setLootPerHourGauge(not LootAnalyser.window.contentsPanel.targetLabel:isVisible())
		end, "", LootAnalyser.window.contentsPanel.targetLabel:isVisible())
	end

	if mode == "graph" then
		menu:addCheckBoxOption(tr("Loot Per Hour Graph"), function()
			LootAnalyser:setLootPerHourGraph(not LootAnalyser.window.contentsPanel.graphPanel:isVisible())
		end, "", LootAnalyser.window.contentsPanel.graphPanel:isVisible())
	end

	menu:display(mousePosition)

	return true
end

function LootAnalyser.reset(unusedArgument)
	LootAnalyser.launchTime = g_clock.millis()
	LootAnalyser.session = 0
	LootAnalyser.goldValue = 0
	LootAnalyser.goldHour = 0
	LootAnalyser.target = 0
	LootAnalyser.lootedItems = {}
	LootAnalyser.lootEvents = var_0_3()
	LootAnalyser.listDirty = false
	LootAnalyser.forceUpdateBalance = false
	LootAnalyser.updateBalance = true

	analyserUIGraphReset(LootAnalyser.window.contentsPanel.graphPanel, nil, ANALYSER_GRAPH_CAPACITY_60_MIN)
	LootAnalyser:updateWindow(true, true)
end

function LootAnalyser.updateBasePriceFromLootedItems(self, itemId, newPriceValue)
	local itemInfo = self.lootedItems[itemId]

	if itemInfo then
		if not newPriceValue then
			newPriceValue = Item.create(itemId, 1):getPriceValue()

			local unusedValue
		end

		if itemInfo.basePrice ~= newPriceValue then
			itemInfo.basePrice = newPriceValue
			LootAnalyser.forceUpdateBalance = true

			LootAnalyser:updateWindow(true, true)
		end
	end
end

function LootAnalyser.checkBalance(unusedArgument)
	local oldBalance = LootAnalyser.goldValue

	if LootAnalyser.forceUpdateBalance then
		local loot = 0

		for itemId, itemInfo in pairs(LootAnalyser.lootedItems) do
			loot = loot + itemInfo.count * itemInfo.basePrice
		end

		LootAnalyser.goldValue = loot
		LootAnalyser.forceUpdateBalance = false
	end

	local oldGoldHour = LootAnalyser.goldHour
	local var_20_3 = LootAnalyser:refreshGoldHour()

	if LootAnalyser.updateBalance or LootAnalyser.listDirty or var_20_3 or oldBalance ~= LootAnalyser.goldValue or oldGoldHour ~= LootAnalyser.goldHour then
		LootAnalyser:updateWindow(LootAnalyser.listDirty or var_20_3, true)

		LootAnalyser.updateBalance = false
	end
end

function LootAnalyser.updateWindow(unusedArgument, updateScroll, ignoreVisible)
	if not LootAnalyser.window:isVisible() and not ignoreVisible then
		return
	end

	local contentsPanel = LootAnalyser:refreshGoldHour()

	updateScroll = LootAnalyser.listDirty or contentsPanel or updateScroll

	local contentsPanel = LootAnalyser.window.contentsPanel

	contentsPanel.gold:setText(formatMoney(LootAnalyser.goldValue, ","))
	contentsPanel.goldHour:setText(formatMoney(math.floor(LootAnalyser.goldHour), ","))
	contentsPanel.goldTarget:setText(formatMoney(LootAnalyser.target, ","))
	updateLootTargetArrow()
	LootAnalyser.window.contentsPanel.lootTargetBG:setTooltip(string.format("Current: %d\nTarget: %d", LootAnalyser.goldHour, LootAnalyser.target))

	if not updateScroll then
		return
	end

	local numOfItems = 0
	local numOfLines = 0

	for unusedValue, child in pairs(contentsPanel.lootedItems:getChildren()) do
		child.toBeRemoved = true
	end

	if table.empty(LootAnalyser.lootedItems) and #contentsPanel.lootedItems:getChildren() then
		contentsPanel.lootedItems:destroyChildren()
		contentsPanel.separatorLootedItems:setVisible(false)
		LootAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separator", AnchorBottom)
	else
		contentsPanel.separatorLootedItems:setVisible(true)
		LootAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separatorLootedItems", AnchorBottom)

		for itemId, info in pairs(LootAnalyser.lootedItems) do
			local idStr = tostring(itemId)
			local widget = contentsPanel.lootedItems:getChildById(idStr)

			if not widget then
				widget = g_ui.createWidget("LootAnalyserItem", contentsPanel.lootedItems)

				widget:setId(idStr)
				widget:setItemId(tonumber(itemId) or itemId)

				if widget.setFont then
					widget:setFont("verdana-11px-rounded")
				end
			end

			widget.toBeRemoved = false

			widget:setShowCount(true)
			widget:setItemCount(info.count)
			widget:setTooltip(string.format("%s (Value: %dgp, Sum: %dgp)", string.capitalize(info.name), info.basePrice, info.basePrice * info.count))

			numOfItems = numOfItems + 1

			if numOfItems == 4 then
				numOfItems = 0
				numOfLines = numOfLines + 1
			end
		end

		for unusedValue, child in pairs(contentsPanel.lootedItems:getChildren()) do
			if child.toBeRemoved then
				child:destroy()
			end
		end
	end

	local var_21_6

	var_21_6 = not table.empty(LootAnalyser.lootedItems) and numOfLines + 1 or 0

	contentsPanel.lootedItems:setHeight(35 * (var_21_6 + (var_21_6 > 0 and numOfItems == 0 and -1 or 0)))

	LootAnalyser.listDirty = false
end

function LootAnalyser.refreshGoldHour(unusedArgument)
	local var_22_0 = var_0_5()

	LootAnalyser.goldHour = AnalyserSession:perHourFromTotal(LootAnalyser.goldValue, LootAnalyser.launchTime, var_0_1)

	return var_22_0
end

function LootAnalyser.updateGraphics(self)
	LootAnalyser:refreshGoldHour()

	if LootAnalyser.window and LootAnalyser.window.contentsPanel then
		analyserUIGraphPushValue(LootAnalyser.window.contentsPanel.graphPanel, LootAnalyser.goldHour)
	end
end

function LootAnalyser.addLootedItems(unusedArgument, item, name)
	local itemId = item:getId()
	local itemInfo = LootAnalyser.lootedItems[itemId]

	if not itemInfo then
		LootAnalyser.lootedItems[itemId] = {
			count = 0,
			basePrice = 0,
			name = name
		}
		itemInfo = LootAnalyser.lootedItems[itemId]
	end

	local count = item:getCount()
	local var_24_3 = getLootPrice(itemId)

	if itemInfo.basePrice ~= var_24_3 and not LootAnalyser.forceUpdateBalance then
		LootAnalyser.goldValue = math.max(0, LootAnalyser.goldValue + (var_24_3 - itemInfo.basePrice) * itemInfo.count)
	end

	itemInfo.basePrice = var_24_3
	itemInfo.count = itemInfo.count + count

	var_0_4(itemId, count)

	LootAnalyser.goldValue = LootAnalyser.goldValue + itemInfo.basePrice * count
	LootAnalyser.updateBalance = true

	LootAnalyser:checkBalance()
	LootAnalyser:updateWindow(true, true)
end

function LootAnalyser.setLootPerHourGauge(self, value)
	LootAnalyser.window.contentsPanel.targetLabel:setVisible(value)
	LootAnalyser.window.contentsPanel.goldLabelIcon:setVisible(value)
	LootAnalyser.window.contentsPanel.goldTarget:setVisible(value)
	LootAnalyser.window.contentsPanel.lootTargetBG:setVisible(value)
	LootAnalyser.window.contentsPanel.separatorGauge:setVisible(value)

	LootAnalyser.gaugeVisible = value

	if value then
		LootAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorGauge", AnchorBottom)
	else
		LootAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorLootedItems", AnchorBottom)
	end
end

function LootAnalyser.setLootPerHourGraph(self, value)
	LootAnalyser.window.contentsPanel.graphPanel:setVisible(value)
	LootAnalyser.window.contentsPanel.graphHorizontal:setVisible(value)

	LootAnalyser.graphVisible = value
end

function LootAnalyser.gaugeIsVisible(self)
	return LootAnalyser.gaugeVisible
end

function LootAnalyser.graphIsVisible(self)
	return LootAnalyser.graphVisible
end

function LootAnalyser.getTarget(self)
	return LootAnalyser.target
end

function LootAnalyser.setTarget(unusedArgument, value)
	LootAnalyser.target = parseLootTargetAmount(value)

	if LootAnalyser.window and LootAnalyser.window.contentsPanel then
		LootAnalyser.window.contentsPanel.goldTarget:setText(formatMoney(LootAnalyser.target, ","))
	end

	LootAnalyser:updateWindow(false, true)
end

function LootAnalyser.openTargetConfig(self)
	local window = configPopupWindow.lootButton

	if not window then
		return
	end

	window:show()
	window:raise()
	window:focus()
	window:setText(tr("Set Loot Target"))
	window.contentPanel.text:setImageSource("/images/game/analyzer/labels/loot")
	window.contentPanel.lootTarget:setText(tostring(LootAnalyser.target or 0))
	window.contentPanel.lootTarget:focus()

	local function applyTarget()
		LootAnalyser:setTarget(window.contentPanel.lootTarget:getText())

		if saveGainAndWastConfigJson then
			saveGainAndWastConfigJson()
		end

		window:hide()
	end

	window.onEnter = applyTarget
	window.contentPanel.ok.onClick = applyTarget

	function window.contentPanel.cancel.onClick()
		window:hide()
	end
end
