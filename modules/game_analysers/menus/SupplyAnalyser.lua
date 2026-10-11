if not SupplyAnalyser then
	SupplyAnalyser = {
		graphVisible = true,
		gaugeVisible = true,
		target = 0,
		goldHour = 0,
		goldValue = 0,
		session = 0,
		launchTime = 0,
		listDirty = false,
		items = {}
	}
	SupplyAnalyser.__index = SupplyAnalyser
end

local targetMaxMargin = 142
local ROLLING_WINDOW_MS = 3600000
local EVENT_COMPACTION_THRESHOLD = 4096

local function createSupplyEventQueue()
	return {
		first = 1,
		last = 0,
		entries = {}
	}
end

local function recordSupplyEvent(itemId, value)
	local supplyEvents = SupplyAnalyser.supplyEvents
	local tick = g_clock.millis()
	local lastEvent = supplyEvents.entries[supplyEvents.last]

	if lastEvent and lastEvent.itemId == itemId and lastEvent.value == value and math.floor(lastEvent.tick / 1000) == math.floor(tick / 1000) then
		lastEvent.count = (lastEvent.count or 1) + 1
		lastEvent.tick = tick

		return
	end

	supplyEvents.last = supplyEvents.last + 1
	supplyEvents.entries[supplyEvents.last] = {
		count = 1,
		itemId = itemId,
		value = value,
		tick = tick
	}
end

local function expireSupplyEvents()
	local supplyEvents = SupplyAnalyser.supplyEvents

	if not supplyEvents then
		return false
	end

	local cutoffTime = g_clock.millis() - ROLLING_WINDOW_MS
	local suppliesChanged = false

	while supplyEvents.first <= supplyEvents.last do
		local expiredEvent = supplyEvents.entries[supplyEvents.first]

		if not expiredEvent or cutoffTime < expiredEvent.tick then
			break
		end

		local numericValue = tonumber(SupplyAnalyser.items[expiredEvent.itemId]) or 0
		local expiredCount = math.min(numericValue, tonumber(expiredEvent.count) or 1)

		if expiredCount > 0 then
			local remainingCount = numericValue - expiredCount

			if remainingCount > 0 then
				SupplyAnalyser.items[expiredEvent.itemId] = remainingCount
			else
				SupplyAnalyser.items[expiredEvent.itemId] = nil
			end

			SupplyAnalyser.goldValue = math.max(0, SupplyAnalyser.goldValue - (tonumber(expiredEvent.value) or 0) * expiredCount)
			suppliesChanged = true
		end

		supplyEvents.entries[supplyEvents.first] = nil
		supplyEvents.first = supplyEvents.first + 1
	end

	if supplyEvents.first > supplyEvents.last then
		SupplyAnalyser.supplyEvents = createSupplyEventQueue()
	elseif supplyEvents.first > EVENT_COMPACTION_THRESHOLD and supplyEvents.first > math.floor(supplyEvents.last / 2) then
		local compactedSupplyEvents = createSupplyEventQueue()

		for eventIndex = supplyEvents.first, supplyEvents.last do
			compactedSupplyEvents.last = compactedSupplyEvents.last + 1
			compactedSupplyEvents.entries[compactedSupplyEvents.last] = supplyEvents.entries[eventIndex]
		end

		SupplyAnalyser.supplyEvents = compactedSupplyEvents
	end

	if suppliesChanged then
		SupplyAnalyser.listDirty = true
	end

	return suppliesChanged
end

local function updateSupplyTargetArrow()
	local supplyTargetBG = SupplyAnalyser.window and SupplyAnalyser.window.contentsPanel and SupplyAnalyser.window.contentsPanel.supplyTargetBG

	if not supplyTargetBG or not supplyTargetBG.supplyArrow then
		return
	end

	local arrow = supplyTargetBG.supplyArrow
	local target = SupplyAnalyser.target or 0
	local goldHour = SupplyAnalyser.goldHour or 0

	if target <= 0 and goldHour <= 0 then
		arrow:setMarginLeft(math.floor(targetMaxMargin / 2))

		return
	end

	local targetValue = math.max(1, target)
	local marginLeft

	if goldHour < targetValue then
		marginLeft = 0
	elseif goldHour >= 2 * targetValue then
		marginLeft = targetMaxMargin
	else
		local progress = (goldHour - targetValue) / targetValue

		marginLeft = math.floor(targetMaxMargin * progress + 0.5)
	end

	arrow:setMarginLeft(marginLeft)
end

function SupplyAnalyser.create(unusedArgument)
	SupplyAnalyser.launchTime = g_clock.millis()
	SupplyAnalyser.session = 0
	SupplyAnalyser.goldValue = 0
	SupplyAnalyser.goldHour = 0
	SupplyAnalyser.target = 0
	SupplyAnalyser.gaugeVisible = true
	SupplyAnalyser.graphVisible = true
	SupplyAnalyser.items = {}
	SupplyAnalyser.supplyEvents = createSupplyEventQueue()
	SupplyAnalyser.listDirty = false
	SupplyAnalyser.forceUpdateBalance = false
	SupplyAnalyser.updateBalance = true
	SupplyAnalyser.window = openedWindows.supplyButton

	SupplyAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separator", AnchorBottom)

	function SupplyAnalyser.window.contentsPanel.supplyTargetBG.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onSupplyExtra(mousePosition, "gaude")

			return true
		end
	end

	function SupplyAnalyser.window.contentsPanel.graphPanel.onMousePress(widget, mousePosition, mouseButton)
		if mouseButton == MouseRightButton then
			onSupplyExtra(mousePosition, "graph")

			return true
		end
	end
end

function onSupplyExtra(mousePosition, mode)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	if mode == "false" then
		menu:addOption(tr("Reset Data"), function()
			SupplyAnalyser:reset()
		end)
		menu:addSeparator()
		menu:addOption(tr("Set Supply Per Hour Target"), function()
			SupplyAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("Supply Per Hour Gauge"), function()
			SupplyAnalyser:setSupplyPerHourGauge(not SupplyAnalyser.window.contentsPanel.targetLabel:isVisible())
		end, "", SupplyAnalyser.window.contentsPanel.targetLabel:isVisible())
		menu:addCheckBoxOption(tr("Supply Per Hour Graph"), function()
			SupplyAnalyser:setSupplyPerHourGraph(not SupplyAnalyser.window.contentsPanel.graphPanel:isVisible())
		end, "", SupplyAnalyser.window.contentsPanel.graphPanel:isVisible())
		menu:display(mousePosition)

		return true
	end

	if mode == "gaude" then
		menu:addOption(tr("Set Supply Per Hour Target"), function()
			SupplyAnalyser:openTargetConfig()
		end)
		menu:addCheckBoxOption(tr("Supply Per Hour Gauge"), function()
			SupplyAnalyser:setSupplyPerHourGauge(not SupplyAnalyser.window.contentsPanel.targetLabel:isVisible())
		end, "", SupplyAnalyser.window.contentsPanel.targetLabel:isVisible())
	end

	if mode == "graph" then
		menu:addCheckBoxOption(tr("Supply Per Hour Graph"), function()
			SupplyAnalyser:setSupplyPerHourGraph(not SupplyAnalyser.window.contentsPanel.graphPanel:isVisible())
		end, "", SupplyAnalyser.window.contentsPanel.graphPanel:isVisible())
	end

	menu:display(mousePosition)

	return true
end

function SupplyAnalyser.reset(unusedArgument)
	SupplyAnalyser.launchTime = g_clock.millis()
	SupplyAnalyser.session = 0
	SupplyAnalyser.goldValue = 0
	SupplyAnalyser.goldHour = 0
	SupplyAnalyser.target = 0
	SupplyAnalyser.items = {}
	SupplyAnalyser.supplyEvents = createSupplyEventQueue()
	SupplyAnalyser.listDirty = false
	SupplyAnalyser.forceUpdateBalance = false
	SupplyAnalyser.updateBalance = true

	analyserUIGraphReset(SupplyAnalyser.window.contentsPanel.graphPanel, nil, ANALYSER_GRAPH_CAPACITY_60_MIN)
	SupplyAnalyser.window.contentsPanel.lootedItems:setVisible(false)
	SupplyAnalyser.window.contentsPanel.separatorLootedItems:setVisible(false)
	SupplyAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separator", AnchorBottom)
	SupplyAnalyser.window.contentsPanel.lootedItems:destroyChildren()
	SupplyAnalyser:updateWindow(true, true)
end

function SupplyAnalyser.updateWindow(unusedArgument, updateScroll, ignoreVisible)
	if not SupplyAnalyser.window:isVisible() and not ignoreVisible then
		return
	end

	local supplyEventsChanged = SupplyAnalyser:refreshGoldHour()

	updateScroll = SupplyAnalyser.listDirty or supplyEventsChanged or updateScroll

	local target = SupplyAnalyser.target or 0
	local goldHour = SupplyAnalyser.goldHour or 0
	local goldValue = SupplyAnalyser.goldValue or 0
	local contentsPanel = SupplyAnalyser.window.contentsPanel

	contentsPanel.gold:setText(formatMoney(goldValue, ","))
	contentsPanel.goldHour:setText(formatMoney(math.floor(goldHour), ","))
	contentsPanel.goldTarget:setText(formatMoney(target, ","))
	updateSupplyTargetArrow()
	SupplyAnalyser.window.contentsPanel.supplyTargetBG:setTooltip(string.format("Current: %d\nTarget: %d", goldHour, target))

	if not updateScroll then
		return
	end

	for _, itemWidget in pairs(contentsPanel.lootedItems:getChildren()) do
		itemWidget.toBeRemoved = true
	end

	for key, unusedValue in pairs(SupplyAnalyser.items) do
		SupplyAnalyser:updateWidget(key)

		local childById = contentsPanel.lootedItems:getChildById(tostring(key))

		if childById then
			childById.toBeRemoved = false
		end
	end

	for unusedValue, child in pairs(contentsPanel.lootedItems:getChildren()) do
		if child.toBeRemoved then
			child:destroy()
		end
	end

	local numOfItems = 0

	for itemId, itemCount in pairs(SupplyAnalyser.items) do
		numOfItems = numOfItems + 1
	end

	if numOfItems > 0 then
		contentsPanel.lootedItems:setVisible(true)
		contentsPanel.separatorLootedItems:setVisible(true)
		SupplyAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separatorLootedItems", AnchorBottom)
	else
		contentsPanel.lootedItems:setVisible(false)
		contentsPanel.separatorLootedItems:setVisible(false)
		SupplyAnalyser.window.contentsPanel.targetLabel:addAnchor(AnchorTop, "separator", AnchorBottom)
	end

	contentsPanel.lootedItems:setHeight(35 * math.ceil(numOfItems / 4))

	SupplyAnalyser.listDirty = false
end

function SupplyAnalyser.refreshGoldHour(unusedArgument)
	local supplyEventsChanged = expireSupplyEvents()

	SupplyAnalyser.goldHour = AnalyserSession:perHourFromTotal(SupplyAnalyser.goldValue, SupplyAnalyser.launchTime, ROLLING_WINDOW_MS)

	return supplyEventsChanged
end

function SupplyAnalyser.updateGraphics(self)
	SupplyAnalyser:refreshGoldHour()

	if SupplyAnalyser.window and SupplyAnalyser.window.contentsPanel then
		analyserUIGraphPushValue(SupplyAnalyser.window.contentsPanel.graphPanel, SupplyAnalyser.goldHour)
	end
end

function SupplyAnalyser.getItemCount(self, itemId)
	local c = SupplyAnalyser.items[itemId]

	if c == nil and itemId ~= nil then
		local idn = tonumber(itemId)

		if idn ~= nil then
			c = SupplyAnalyser.items[idn]
		end
	end

	return tonumber(c) or 0
end

function SupplyAnalyser.updateWidget(self, itemId)
	local contentsPanel = SupplyAnalyser.window.contentsPanel
	local idStr = tostring(itemId)
	local widget = contentsPanel.lootedItems:getChildById(idStr)

	if not widget then
		widget = g_ui.createWidget("SupplyAnalyserItem", contentsPanel.lootedItems)

		widget:setId(idStr)
		widget:setItemId(tonumber(itemId) or itemId)

		if widget.setFont then
			widget:setFont("verdana-11px-rounded")
		end
	end

	local count = SupplyAnalyser:getItemCount(itemId)

	if count < 1 then
		count = 1
	end

	widget:setShowCount(true)
	widget:setItemCount(count)

	local value = getCurrentPrice(itemId)

	widget:setTooltip(string.format("%s ×%d (Value: %sgp, Sum: %sgp)", getItemServerName(itemId), count, formatMoney(value, ","), formatMoney(value * count, ",")))
end

function SupplyAnalyser.addSuppliesItems(unusedArgument, itemId)
	if SupplyAnalyser.items[itemId] then
		SupplyAnalyser.items[itemId] = SupplyAnalyser.items[itemId] + 1
	else
		SupplyAnalyser.items[itemId] = 1
	end

	local value = getCurrentPrice(itemId)

	recordSupplyEvent(itemId, value)

	SupplyAnalyser.goldValue = SupplyAnalyser.goldValue + value
	SupplyAnalyser.updateBalance = true

	SupplyAnalyser:updateWidget(itemId)
	SupplyAnalyser:updateWindow(true, true)
end

function SupplyAnalyser.setSupplyPerHourGauge(self, value)
	SupplyAnalyser.window.contentsPanel.targetLabel:setVisible(value)
	SupplyAnalyser.window.contentsPanel.goldLabelIcon:setVisible(value)
	SupplyAnalyser.window.contentsPanel.goldTarget:setVisible(value)
	SupplyAnalyser.window.contentsPanel.supplyTargetBG:setVisible(value)
	SupplyAnalyser.window.contentsPanel.separatorGauge:setVisible(value)

	SupplyAnalyser.gaugeVisible = value

	if value then
		SupplyAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorGauge", AnchorBottom)
	else
		SupplyAnalyser.window.contentsPanel.graphPanel:addAnchor(AnchorTop, "separatorLootedItems", AnchorBottom)
	end
end

function SupplyAnalyser.setSupplyPerHourGraph(self, value)
	SupplyAnalyser.window.contentsPanel.graphPanel:setVisible(value)
	SupplyAnalyser.window.contentsPanel.graphHorizontal:setVisible(value)

	SupplyAnalyser.graphVisible = value
end

function SupplyAnalyser.gaugeIsVisible(self)
	return SupplyAnalyser.gaugeVisible
end

function SupplyAnalyser.graphIsVisible(self)
	return SupplyAnalyser.graphVisible
end

function SupplyAnalyser.getTarget(self)
	return SupplyAnalyser.target
end

function SupplyAnalyser.setTarget(self, value)
	SupplyAnalyser.target = tonumber(value) or 0

	if SupplyAnalyser.window and SupplyAnalyser.window.contentsPanel then
		SupplyAnalyser.window.contentsPanel.goldTarget:setText(formatMoney(SupplyAnalyser.target, ","))
	end

	SupplyAnalyser:updateWindow(true, true)
end

function SupplyAnalyser.openTargetConfig(self)
	local window = configPopupWindow.supplyButton

	if not window then
		return
	end

	window:show()
	window:raise()
	window:focus()
	window:setText(tr("Set Supply Target"))
	window.contentPanel.text:setImageSource("/images/game/analyzer/labels/supply")
	window.contentPanel.supplyTarget:setText(tostring(SupplyAnalyser.target or 0))
	window.contentPanel.supplyTarget:focus()

	local function applyTarget()
		SupplyAnalyser:setTarget(window.contentPanel.supplyTarget:getText())

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
