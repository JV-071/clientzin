containerSettings = nil

local containerDragHoveredSlot

local function getGridSpacing(layout)
	local spacing = layout:getCellSpacing()

	if spacing > 0 then
		return spacing, spacing
	end

	local spacingX = layout:getCellSpacingWidth()
	local spacingY = layout:getCellSpacingHeight()

	if spacingX <= 0 then
		spacingX = spacing
	end

	if spacingY <= 0 then
		spacingY = spacing
	end

	return spacingX, spacingY
end

local function getContainerSlotItemWidget(slotWidget)
	if not slotWidget then
		return nil
	end

	if slotWidget.item and slotWidget.item:getClassName() == "UIItem" then
		return slotWidget.item
	end

	if slotWidget:getClassName() == "UIItem" then
		return slotWidget
	end

	return nil
end

local function setContainerSlotAmount(slotWidget, item)
	local amountLabel = slotWidget and slotWidget.amount

	if not amountLabel then
		return
	end

	if not item then
		amountLabel:setText("")
		amountLabel:setVisible(false)

		return
	end

	if item:isFluidContainer() or not item:isStackable() then
		amountLabel:setText("")
		amountLabel:setVisible(false)

		return
	end

	local count = item:getCount() or 0

	if count > 1 then
		amountLabel:setText(tostring(count))
		amountLabel:setVisible(true)
	else
		amountLabel:setText("")
		amountLabel:setVisible(false)
	end
end

local function refreshContainerSlotQuickLootIcon(slotWidget, item)
	local icon = slotWidget.quickloot or slotWidget:getChildById("quickloot")

	if not icon then
		return
	end

	local show = false

	if item and item:isContainer() then
		show = item:getQuickLootFlags() ~= 0 or item:getObtainLootFlags() ~= 0
	end

	icon:setVisible(show)

	if show then
		local iconTooltip = ""

		if modules.game_quickloot and modules.game_quickloot.QuickLoot and modules.game_quickloot.QuickLoot.getQuickLootIconTooltip then
			iconTooltip = modules.game_quickloot.QuickLoot.getQuickLootIconTooltip(item:getQuickLootFlags(), item:getObtainLootFlags())
		end

		icon:setTooltip(iconTooltip)
	else
		icon:setTooltip("")
	end
end

local function refreshContainerSlotBoxedIcon(slotWidget, item)
	local icon = slotWidget.boxed or slotWidget:getChildById("boxed")

	if not icon then
		return
	end

	local show = item ~= nil and item:isDecoKit()

	icon:setVisible(show)
end

function applyContainerSlotVisuals(slotWidget, item)
	if not slotWidget then
		return
	end

	local itemUi = getContainerSlotItemWidget(slotWidget)

	if itemUi then
		itemUi:setUseDecoKitContainerSprite(item ~= nil and item:isDecoKit())
		itemUi:setItem(item)
	end

	if slotWidget.rarity then
		if item then
			ItemsDatabase.setRarityItem(slotWidget.rarity, item)
			ItemsDatabase.syncRarityWidgetVisibility(slotWidget.rarity)
		else
			ItemsDatabase.setRarityItem(slotWidget.rarity, nil)
			slotWidget.rarity:setVisible(false)
		end

		ItemsDatabase.applyContainerRarityStackOrder(slotWidget)
	end

	ItemsDatabase.setTier(slotWidget, item or 0)
	setContainerSlotAmount(slotWidget, item)
	refreshContainerSlotQuickLootIcon(slotWidget, item)
	refreshContainerSlotBoxedIcon(slotWidget, item)

	if modules.client_options.getOption("showExpiryInContainers") then
		ItemsDatabase.setCharges(slotWidget, item)
		ItemsDatabase.setDuration(slotWidget, item)
	else
		if slotWidget.charges then
			slotWidget.charges:setText("")
		end

		if slotWidget.duration then
			ItemsDatabase.setDurationText(slotWidget, nil)
		end
	end
end

local function bindContainerSlotPosition(slotWidget, position)
	if not slotWidget or not position then
		return
	end

	local itemUi = getContainerSlotItemWidget(slotWidget)

	if itemUi then
		itemUi.position = position
	end
end

local CONTAINER_TITLE_COLOR_DEFAULT = "#9d9d9dff"
local CONTAINER_TITLE_COLOR_MANUAL_SORT = "#c28400"

local function applyContainerTitleStyle(containerWindow)
	if not containerWindow or containerWindow:isDestroyed() then
		return
	end

	local titleWidget = containerWindow:getChildById("miniwindowTitle")

	if not titleWidget then
		return
	end

	if containerSettings and containerSettings.useManualSortMode == 1 then
		titleWidget:setColor(CONTAINER_TITLE_COLOR_MANUAL_SORT)
	else
		titleWidget:setColor(CONTAINER_TITLE_COLOR_DEFAULT)
	end
end

local function var_0_10(arg_9_0, arg_9_1)
	if not arg_9_0 or arg_9_0:isDestroyed() then
		return
	end

	local miniwindowTitle = arg_9_0:getChildById("miniwindowTitle")

	if not miniwindowTitle or not arg_9_1 or arg_9_1.isDestroyed and arg_9_1:isDestroyed() then
		return
	end

	miniwindowTitle:breakAnchors()
	miniwindowTitle:addAnchor(AnchorTop, "miniwindowHeader", AnchorTop)
	miniwindowTitle:addAnchor(AnchorLeft, "miniwindowHeader", AnchorLeft)
	miniwindowTitle:addAnchor(AnchorRight, arg_9_1:getId(), AnchorLeft)
	miniwindowTitle:setMarginTop(1)
	miniwindowTitle:setMarginLeft(19)
	miniwindowTitle:setMarginRight(3)
end

local function refreshAllContainerTitleStyles()
	for _, container in pairs(g_game.getContainers()) do
		if container.window and not container.window:isDestroyed() then
			applyContainerTitleStyle(container.window)
		end
	end
end

local SORT_MODE_TO_INDEX = {
	sortAscByName = 0,
	sortDescByStackSize = 7,
	sortAscByStackSize = 6,
	sortDescByExpiry = 5,
	sortAscByExpiry = 4,
	sortDescByWeight = 3,
	sortAscByWeight = 2,
	sortDescByName = 1
}
local shouldApplyContainerSort

local function getContainerFromWidget(widget)
	while widget do
		local id = widget.getId and widget:getId() or nil

		if id then
			local containerId = tonumber(id:match("^container(%d+)$"))

			if containerId then
				return g_game.getContainer(containerId)
			end
		end

		widget = widget:getParent()
	end

	return nil
end

local function getContainerOrganizeFlags()
	local containersFirst = containerSettings and containerSettings.sortContainersFirst == 1
	local nestedContainers = containerSettings and containerSettings.sortNestedContainers == 1

	return containersFirst, nestedContainers
end

local function requestContainerSort(container, sortMode, onlyThisContainer)
	if not container or not sortMode or sortMode == "none" then
		return
	end

	if not shouldApplyContainerSort(container) then
		return
	end

	local index = SORT_MODE_TO_INDEX[sortMode]

	if index == nil then
		return
	end

	local containersFirst, nestedContainers = getContainerOrganizeFlags()

	if onlyThisContainer then
		nestedContainers = false
	end

	g_game.organizeContainer(container, false, index, containersFirst, nestedContainers, false)
end

local function requestMoveToObtainContainers(container)
	if not container then
		return
	end

	local moveNested = containerSettings and containerSettings.moveNestedContainers == 1 and 1 or 0
	local containersFirst, nestedContainers = getContainerOrganizeFlags()

	g_game.organizeContainer(container, true, moveNested, containersFirst, nestedContainers, false)
end

local function getLowestOpenContainer()
	local lowestContainer
	local lowestId

	for id, container in pairs(g_game.getContainers()) do
		if shouldApplyContainerSort(container) and container.window and container.window:isVisible() and (lowestId == nil or id < lowestId) then
			lowestId = id
			lowestContainer = container
		end
	end

	return lowestContainer
end

local function requestNestedContainersSort(sortMode)
	local rootContainer = getLowestOpenContainer()

	if not rootContainer then
		return
	end

	local index = SORT_MODE_TO_INDEX[sortMode]

	if index == nil then
		return
	end

	local containersFirst = containerSettings and containerSettings.sortContainersFirst == 1

	g_game.organizeContainer(rootContainer, false, index, containersFirst, true, false)
end

local function shouldAskBeforeSortNestedContainers()
	if modules.client_options and modules.client_options.getOption then
		local value = modules.client_options.getOption("askBeforeSorting")

		if value ~= nil then
			return value
		end
	end

	return true
end

local function closeSortNestedConfirmWindow(confirmWindow)
	if not confirmWindow then
		return
	end

	if g_modalManager then
		g_modalManager.hide(confirmWindow)
	end

	if not confirmWindow:isDestroyed() then
		confirmWindow:destroy()
	end
end

local function displaySortNestedContainersConfirmBox(onConfirm)
	local confirmWindow = g_ui.createWidget("SortNestedContainersConfirmModal", rootWidget)

	confirmWindow:getChildById("title"):setText(tr("Confirmation to Sort Nested Containers"))
	confirmWindow:getChildById("content"):setText(tr("You are about to sort the contents of all containers and their nested subcontainers. Do you want to proceed?"))

	local doNotShowAgain = confirmWindow:recursiveGetChildById("doNotShowAgain")

	local function cancelFunc()
		closeSortNestedConfirmWindow(confirmWindow)
	end

	local function confirmFunc()
		if doNotShowAgain and doNotShowAgain:isChecked() and modules.client_options and modules.client_options.setOption then
			modules.client_options.setOption("askBeforeSorting", false, true)
		end

		closeSortNestedConfirmWindow(confirmWindow)
		onConfirm()
	end

	local buttonNo = confirmWindow:recursiveGetChildById("buttonNo")
	local buttonYes = confirmWindow:recursiveGetChildById("buttonYes")

	if buttonNo then
		buttonNo.onClick = cancelFunc
	end

	if buttonYes then
		buttonYes.onClick = confirmFunc
	end

	connect(confirmWindow, {
		onEnter = confirmFunc,
		onEscape = cancelFunc
	})
	confirmWindow:raise()
	confirmWindow:focus()

	if g_modalManager then
		g_modalManager.show(confirmWindow)
	end

	return confirmWindow
end

local function handleContainerSortAction(container, sortMode)
	containerSettings.currentSortMode = sortMode

	g_settings.setNode("containers", containerSettings)

	local _, nestedContainersEnabled = getContainerOrganizeFlags()

	if nestedContainersEnabled then
		local function doSort()
			requestNestedContainersSort(sortMode)
		end

		if shouldAskBeforeSortNestedContainers() then
			displaySortNestedContainersConfirmBox(doSort)
		else
			doSort()
		end
	elseif container then
		requestContainerSort(container, sortMode, true)
	else
		applySortToOpenContainers(sortMode, true)
	end
end

local function applySortToOpenContainers(sortMode, skipConfirm)
	if not sortMode or sortMode == "none" then
		return
	end

	local _, nestedContainers = getContainerOrganizeFlags()

	if nestedContainers then
		if skipConfirm then
			requestNestedContainersSort(sortMode)
		else
			handleContainerSortAction(nil, sortMode)
		end

		return
	end

	for _, container in pairs(g_game.getContainers()) do
		if shouldApplyContainerSort(container) and container.window and container.window:isVisible() then
			requestContainerSort(container, sortMode, true)
		end
	end
end

local function applyMoveToObtainToOpenContainers()
	local _, nestedContainers = getContainerOrganizeFlags()
	local containers = g_game.getContainers()

	if nestedContainers then
		local lowestContainer
		local lowestId

		for id, container in pairs(containers) do
			if container.window and container.window:isVisible() and (lowestId == nil or id < lowestId) then
				lowestId = id
				lowestContainer = container
			end
		end

		if lowestContainer then
			requestMoveToObtainContainers(lowestContainer)
		end
	else
		for _, container in pairs(containers) do
			if container.window and container.window:isVisible() then
				requestMoveToObtainContainers(container)
			end
		end
	end
end

local function getContainerSeekFilter(container)
	if container and container.getSelectedFilter then
		return container:getSelectedFilter()
	end

	return 0
end

local STORE_INBOX_FILTER_ALL = 0
local STORE_INBOX_FILTER_CONSUMABLES = 1
local STORE_INBOX_FILTER_FLOOR_COVERING = 3
local STORE_INBOX_FILTER_WIDGET_IDS = {
	"filterAll",
	"filterConsumables",
	"filterFloorCovering"
}
local STORE_INBOX_CONSUMABLE_CATEGORIES = {
	[6] = true,
	[10] = true,
	[12] = true,
	[22] = true
}

if MarketCategory then
	STORE_INBOX_CONSUMABLE_CATEGORIES[MarketCategory.Food] = true
	STORE_INBOX_CONSUMABLE_CATEGORIES[MarketCategory.Potions] = true
	STORE_INBOX_CONSUMABLE_CATEGORIES[MarketCategory.Runes] = true
	STORE_INBOX_CONSUMABLE_CATEGORIES[MarketCategory.PremiumScrolls] = true
end

local STORE_INBOX_FLOOR_COVERING_CATEGORIES = {
	[5] = true
}

if MarketCategory then
	STORE_INBOX_FLOOR_COVERING_CATEGORIES[MarketCategory.Decoration] = true
end

local var_0_33 = 23721
local var_0_34 = 11698
local var_0_35 = 65535
local var_0_36 = {
	[19202] = true,
	[470] = true,
	[12902] = true,
	[3502] = true,
	[23396] = true
}

local function isStoreInboxContainer(container)
	if not container then
		return false
	end

	if container.hasFilters and container:hasFilters() then
		return true
	end

	return container:getName():lower():find("store inbox", 1, true) ~= nil
end

local function var_0_38(arg_28_0)
	if not arg_28_0 then
		return false
	end

	local containerItem = arg_28_0.getContainerItem and arg_28_0:getContainerItem()

	if containerItem and containerItem:getId() == var_0_34 then
		return true
	end

	local name = arg_28_0:getName()

	if not name then
		return false
	end

	return name:lower():find("battle pass", 1, true) ~= nil
end

local function var_0_39(arg_29_0)
	if not arg_29_0 or not arg_29_0.getContainerItem then
		return false
	end

	local containerItem = arg_29_0:getContainerItem()

	return containerItem and containerItem:getId() == var_0_33
end

local function var_0_40(arg_30_0, arg_30_1)
	if not arg_30_0 or not arg_30_0.getName then
		return false
	end

	local name = arg_30_0:getName()

	if not name or name == "" then
		return false
	end

	return name:lower():find(arg_30_1, 1, true) ~= nil
end

local function var_0_41(arg_31_0)
	local containerItem = arg_31_0 and arg_31_0.getContainerItem and arg_31_0:getContainerItem()

	if not containerItem then
		return false
	end

	if containerItem.isLyingCorpse and containerItem:isLyingCorpse() then
		return true
	end

	if containerItem.isPlayerCorpse and containerItem:isPlayerCorpse() then
		return true
	end

	return false
end

local function var_0_42(arg_32_0)
	if not arg_32_0 then
		return false
	end

	if arg_32_0.isInDepot and arg_32_0:isInDepot() then
		return false
	end

	if var_0_41(arg_32_0) then
		return false
	end

	if var_0_40(arg_32_0, "depot") or var_0_40(arg_32_0, "browse field") or var_0_40(arg_32_0, "market") then
		return false
	end

	local containerItem = arg_32_0.getContainerItem and arg_32_0:getContainerItem()

	if not containerItem then
		return false
	end

	if var_0_36[containerItem:getId()] then
		return false
	end

	local position = containerItem.getPosition and containerItem:getPosition()

	if not position or position.x ~= var_0_35 then
		return false
	end

	return true
end

local function isConsumableStoreInboxItem(item)
	if not item or not g_things or not g_things.getThingType then
		return false
	end

	local thingType = g_things.getThingType(item:getId(), ThingCategoryItem)

	if not thingType or not thingType.getMarketData then
		return false
	end

	local marketData = thingType:getMarketData()

	return marketData and marketData.category and STORE_INBOX_CONSUMABLE_CATEGORIES[marketData.category] == true
end

local function isFloorCoveringStoreInboxItem(item)
	if not item or not g_things or not g_things.getThingType then
		return false
	end

	local thingType = g_things.getThingType(item:getId(), ThingCategoryItem)

	if not thingType or not thingType.getMarketData then
		return false
	end

	local marketData = thingType:getMarketData()

	return marketData and marketData.category and STORE_INBOX_FLOOR_COVERING_CATEGORIES[marketData.category] == true
end

local function containerHasItemsMatching(container, itemMatcher)
	if not container or not itemMatcher then
		return false
	end

	if container.getItems then
		for _, item in pairs(container:getItems()) do
			if itemMatcher(item) then
				return true
			end
		end
	end

	for slot = 0, container:getCapacity() - 1 do
		if itemMatcher(container:getItem(slot)) then
			return true
		end
	end

	return false
end

local function containerHasConsumableItems(container)
	return containerHasItemsMatching(container, isConsumableStoreInboxItem)
end

local function containerHasFloorCoveringItems(container)
	return containerHasItemsMatching(container, isFloorCoveringStoreInboxItem)
end

local function hasStoreInboxFilterById(container, filterId, namePattern)
	if not container or not container.getFiltersCount then
		return false
	end

	for i = 0, container:getFiltersCount() - 1 do
		if container:getFilterId(i) == filterId then
			return true
		end

		if namePattern and container:getFilterName(i):lower():find(namePattern, 1, true) then
			return true
		end
	end

	return false
end

local function hasStoreInboxConsumablesFilter(container)
	return hasStoreInboxFilterById(container, STORE_INBOX_FILTER_CONSUMABLES, "consumable")
end

local function hasStoreInboxFloorCoveringFilter(container)
	return hasStoreInboxFilterById(container, STORE_INBOX_FILTER_FLOOR_COVERING, "floor")
end

local function getStoreInboxFilterState(container)
	local hasConsumables = containerHasConsumableItems(container)
	local hasFloorCovering = containerHasFloorCoveringItems(container)

	if container and container:hasPages() then
		hasConsumables = hasConsumables or hasStoreInboxConsumablesFilter(container)
		hasFloorCovering = hasFloorCovering or hasStoreInboxFloorCoveringFilter(container)
	end

	return {
		hasConsumables = hasConsumables,
		hasFloorCovering = hasFloorCovering
	}
end

local function isStoreInboxFilterOptionVisible(filterKey, filterState)
	if filterKey == "filterAll" then
		return true
	end

	if filterKey == "filterConsumables" then
		return filterState.hasConsumables
	end

	if filterKey == "filterFloorCovering" then
		return filterState.hasFloorCovering
	end

	return false
end

local function resolveStoreInboxFilterId(container, filterKey)
	if not container then
		return STORE_INBOX_FILTER_ALL
	end

	local targetId = STORE_INBOX_FILTER_ALL

	if filterKey == "filterConsumables" then
		targetId = STORE_INBOX_FILTER_CONSUMABLES
	elseif filterKey == "filterFloorCovering" then
		targetId = STORE_INBOX_FILTER_FLOOR_COVERING
	end

	for i = 0, container:getFiltersCount() - 1 do
		if container:getFilterId(i) == targetId then
			return targetId
		end
	end

	if filterKey == "filterAll" then
		for i = 0, container:getFiltersCount() - 1 do
			if container:getFilterName(i):lower() == "all" then
				return container:getFilterId(i)
			end
		end

		return STORE_INBOX_FILTER_ALL
	end

	if filterKey == "filterConsumables" then
		for i = 0, container:getFiltersCount() - 1 do
			if container:getFilterName(i):lower():find("consumable", 1, true) then
				return container:getFilterId(i)
			end
		end

		return STORE_INBOX_FILTER_CONSUMABLES
	end

	if filterKey == "filterFloorCovering" then
		for i = 0, container:getFiltersCount() - 1 do
			if container:getFilterName(i):lower():find("floor", 1, true) then
				return container:getFilterId(i)
			end
		end

		return STORE_INBOX_FILTER_FLOOR_COVERING
	end

	return STORE_INBOX_FILTER_ALL
end

local function getStoreInboxActiveFilterKey(container, selectedFilter)
	if selectedFilter == resolveStoreInboxFilterId(container, "filterConsumables") then
		return "filterConsumables"
	end

	if selectedFilter == resolveStoreInboxFilterId(container, "filterFloorCovering") then
		return "filterFloorCovering"
	end

	return "filterAll"
end

local function normalizeStoreInboxActiveFilterKey(container, selectedFilter, filterState)
	local activeKey = getStoreInboxActiveFilterKey(container, selectedFilter)

	if activeKey == "filterConsumables" and not filterState.hasConsumables then
		return "filterAll"
	end

	if activeKey == "filterFloorCovering" and not filterState.hasFloorCovering then
		return "filterAll"
	end

	return activeKey
end

local function shouldShowStoreInboxFilterButton(container)
	if not isStoreInboxContainer(container) then
		return false
	end

	local filterState = getStoreInboxFilterState(container)

	return filterState.hasConsumables or filterState.hasFloorCovering
end

function shouldApplyContainerSort(container)
	if not container then
		return false
	end

	if container.isInDepot and container:isInDepot() then
		return false
	end

	if isStoreInboxContainer(container) then
		return false
	end

	if var_0_39(container) then
		return false
	end

	if var_0_38(container) then
		return false
	end

	return true
end

local function setStoreInboxFilter(container, filterKey)
	if not container then
		return
	end

	local filterId = resolveStoreInboxFilterId(container, filterKey)

	g_game.seekInContainer(container:getId(), container:getFirstIndex(), filterId)
end

local function showStoreInboxContextMenu(widget, mousePos, mouseButton, container)
	local menu = g_ui.createWidget("StoreInboxSubMenu")

	if not menu then
		return false
	end

	menu:setGameMenu(true)

	local filterState = getStoreInboxFilterState(container)
	local selectedFilter = container:getSelectedFilter()
	local updatingChecks = false
	local filterWidgets = {}

	for _, widgetId in ipairs(STORE_INBOX_FILTER_WIDGET_IDS) do
		filterWidgets[widgetId] = menu:getChildById(widgetId)
	end

	for _, widgetId in ipairs(STORE_INBOX_FILTER_WIDGET_IDS) do
		local widget = filterWidgets[widgetId]

		if widget then
			local visible = isStoreInboxFilterOptionVisible(widgetId, filterState)

			widget:setVisible(visible)

			if not visible then
				widget:setChecked(false)
			end
		end
	end

	local function setFilterChecks(activeKey)
		updatingChecks = true

		for _, widgetId in ipairs(STORE_INBOX_FILTER_WIDGET_IDS) do
			local widget = filterWidgets[widgetId]

			if widget and widget:isVisible() then
				widget:setChecked(widgetId == activeKey)
			end
		end

		updatingChecks = false
	end

	local activeKey = normalizeStoreInboxActiveFilterKey(container, selectedFilter, filterState)

	setFilterChecks(activeKey)

	for _, widgetId in ipairs(STORE_INBOX_FILTER_WIDGET_IDS) do
		local widget = filterWidgets[widgetId]

		if widget and widget:isVisible() then
			function widget.onCheckChange()
				if updatingChecks then
					return
				end

				if widget:isChecked() then
					setFilterChecks(widgetId)
					setStoreInboxFilter(container, widgetId)
				elseif widgetId ~= "filterAll" then
					setFilterChecks("filterAll")
					setStoreInboxFilter(container, "filterAll")
				else
					setFilterChecks("filterAll")
				end

				menu:destroy()
			end
		end
	end

	local buttonPos = widget:getPosition()
	local buttonSize = widget:getSize()
	local width = menu:getWidth()
	local buttonCenterX = buttonPos.x + buttonSize.width / 2
	local var_49_14, menuX = buttonPos.y + buttonSize.height / 2, buttonCenterX - width

	menu:display({
		x = menuX,
		y = var_49_14
	})

	return true
end

local DROP_TRANSPARENT_WIDGET_IDS = {
	mapDragPreviewItem = true,
	globalDragPreviewItem = true,
	modalBlocker = true
}

local function isDropTransparentWidget(widget)
	if not widget then
		return true
	end

	if widget:isPhantom() then
		return true
	end

	local id = widget.getId and widget:getId() or ""

	return DROP_TRANSPARENT_WIDGET_IDS[id] == true
end

local function isWidgetDescendantOf(widget, ancestor)
	while widget do
		if widget == ancestor then
			return true
		end

		widget = widget:getParent()
	end

	return false
end

local function getPrimaryDropBlockingWidget(mousePos)
	local children = rootWidget:recursiveGetChildrenByPos(mousePos)

	for i = 1, #children do
		local child = children[i]

		if not isDropTransparentWidget(child) then
			return child
		end
	end

	return nil
end

local function shouldContainerPanelAcceptDrop(containerWindow, mousePos)
	if not containerWindow or containerWindow:isDestroyed() then
		return false
	end

	local blocker = getPrimaryDropBlockingWidget(mousePos)

	if not blocker then
		return false
	end

	if blocker:getClassName() == "UIGameMap" then
		return false
	end

	if blocker ~= containerWindow and not isWidgetDescendantOf(blocker, containerWindow) then
		return false
	end

	return true
end

local function findContainerSlotWidgetAtPos(itemsPanel, mousePos)
	if not itemsPanel or not itemsPanel:containsPaddingPoint(mousePos) then
		return nil
	end

	local layout = itemsPanel:getLayout()

	if not layout or not layout:isUIGridLayout() then
		return nil
	end

	local paddingRect = itemsPanel:getPaddingRect()
	local virtualOffset = itemsPanel:getVirtualOffset()
	local localX = mousePos.x - paddingRect.x + virtualOffset.x
	local localY = mousePos.y - paddingRect.y + virtualOffset.y

	if localX < 0 or localY < 0 then
		return nil
	end

	local cellSize = layout:getCellSize()
	local spacingX, spacingY = getGridSpacing(layout)
	local stepX = cellSize.width + spacingX
	local stepY = cellSize.height + spacingY

	if stepX <= 0 or stepY <= 0 then
		return nil
	end

	local numColumns = layout:getNumColumns()

	if numColumns <= 0 then
		return nil
	end

	local col = math.floor((localX + spacingX / 2) / stepX)
	local row = math.floor((localY + spacingY / 2) / stepY)

	if col < 0 or row < 0 or numColumns <= col then
		return nil
	end

	local numLines = layout:getNumLines()

	if numLines > 0 and numLines <= row then
		return nil
	end

	local slotIndex = row * numColumns + col

	return itemsPanel:getChildById("item" .. slotIndex)
end

local function clearContainerDragHoveredSlot()
	if containerDragHoveredSlot then
		containerDragHoveredSlot:setBorderWidth(0)

		containerDragHoveredSlot = nil
	end
end

function clearContainerDragHover()
	clearContainerDragHoveredSlot()

	local draggingWidget = g_ui.getDraggingWidget()

	if draggingWidget and draggingWidget.hoveredWho then
		draggingWidget.hoveredWho:setBorderWidth(0)

		draggingWidget.hoveredWho = nil
	end
end

local function setContainerDragHoveredSlot(slotWidget, draggingWidget)
	local itemWidget = getContainerSlotItemWidget(slotWidget)

	if itemWidget == containerDragHoveredSlot then
		return
	end

	clearContainerDragHoveredSlot()

	if itemWidget and draggingWidget and itemWidget ~= draggingWidget then
		itemWidget:setBorderWidth(1)

		draggingWidget.hoveredWho = itemWidget
		containerDragHoveredSlot = itemWidget
	end
end

local function updateContainerDragHover(mousePos)
	local draggingWidget = g_ui.getDraggingWidget()

	if not draggingWidget or not draggingWidget.currentDragThing then
		clearContainerDragHoveredSlot()

		return
	end

	for _, container in pairs(g_game.getContainers()) do
		local itemsPanel = container.itemsPanel

		if itemsPanel and itemsPanel.containerDropTarget and itemsPanel:containsPaddingPoint(mousePos) then
			local slotWidget = findContainerSlotWidgetAtPos(itemsPanel, mousePos)
			local itemWidget = getContainerSlotItemWidget(slotWidget)

			if itemWidget then
				if rootWidget:recursiveGetChildByPos(mousePos, false) == itemWidget then
					if containerDragHoveredSlot and containerDragHoveredSlot ~= itemWidget then
						clearContainerDragHoveredSlot()
					end

					return
				end

				setContainerDragHoveredSlot(slotWidget, draggingWidget)
			else
				clearContainerDragHoveredSlot()
			end

			return
		end
	end

	clearContainerDragHoveredSlot()
end

local function setupContainerDropTarget(containerPanel, containerWindow)
	containerPanel.containerDropTarget = true
	containerPanel.containerWindow = containerWindow

	function containerPanel.onDrop(self, draggedWidget, mousePos)
		if self:isDestroyed() then
			return false
		end

		local containerWin = self.containerWindow

		if not containerWin or containerWin:isDestroyed() then
			return false
		end

		if not shouldContainerPanelAcceptDrop(containerWin, mousePos) then
			return false
		end

		if not self:containsPaddingPoint(mousePos) then
			return false
		end

		local slotWidget = findContainerSlotWidgetAtPos(self, mousePos)
		local itemWidget = getContainerSlotItemWidget(slotWidget)

		if itemWidget then
			return itemWidget:onDrop(draggedWidget, mousePos, true)
		end

		return false
	end

	function containerPanel.onHoverChange(self, hovered)
		UIWidget.onHoverChange(self, hovered)

		if hovered then
			updateContainerDragHover(g_window.getMousePosition())
		else
			clearContainerDragHoveredSlot()
		end
	end

	function containerPanel.onMouseMove(self, mousePos, mouseMoved)
		if g_ui.getDraggingWidget() then
			updateContainerDragHover(mousePos)
		end
	end
end

local layoutRestoreScheduled = false
local savingContainerLayoutsOnLogout = false
local LAYOUT_RESTORE_MAX_ATTEMPTS = 30
local nextContainerOpenInvocation = 0
local containersLayoutRestoredThisLogin = false

local function getSidebarWidgetOptionsPersistence()
	return modules.game_interface and modules.game_interface.SidebarWidgetOptionsPersistence
end

local function clearContainerLayoutForId()
	if SidebarPersistence and type(SidebarPersistence.document) == "table" then
		SidebarPersistence.document.battlePassInboxWidgetOptions = nil
	end

	local var_66_0 = getSidebarWidgetOptionsPersistence()

	if var_66_0 and var_66_0.clearWidgetOptionsById then
		var_66_0.clearWidgetOptionsById("BattlePassInboxWindow")
	end

	local var_66_1 = modules.game_interface and modules.game_interface.SidebarWidgetsPersistence

	if var_66_1 then
		if var_66_1.clearWidgetPlacementByType then
			var_66_1.clearWidgetPlacementByType("battlePassInbox")
		elseif var_66_1.clearWidgetPlacement then
			var_66_1.clearWidgetPlacement("BattlePassInboxWindow")
		end
	end

	if SidebarLayoutState and SidebarLayoutState.widgets then
		for key, widget in pairs(SidebarLayoutState.widgets) do
			if widget and widget.type == "battlePassInbox" then
				SidebarLayoutState.widgets[key] = nil
			end
		end
	end
end

local function var_0_76(arg_67_0, arg_67_1)
	if not arg_67_0 then
		return
	end

	local var_67_0 = arg_67_1 and var_0_38(arg_67_1)
	local textValue = tostring(arg_67_0):match("^container(%d+)$")

	if textValue then
		local var_67_2 = getSidebarWidgetOptionsPersistence()

		if var_67_2 and var_67_2.clearContainerOptions then
			var_67_2.clearContainerOptions(tonumber(textValue))
		end

		local var_67_3 = modules.game_interface and modules.game_interface.SidebarWidgetsPersistence

		if var_67_3 and var_67_3.clearWidgetPlacement then
			var_67_3.clearWidgetPlacement(tostring(arg_67_0))
		end
	end

	if var_67_0 then
		clearContainerLayoutForId()
	end
end

local function var_0_77()
	return modules.game_interface and modules.game_interface.SidebarWidgetsPersistence
end

local function getSavedLayoutForWindow(arg_69_0, window)
	if not arg_69_0 or not arg_69_0.getId then
		return nil, nil
	end

	local settings = arg_69_0:getSettings("parentId")
	local var_69_1 = arg_69_0:getSettings("index")
	local var_69_2 = window and var_0_38(window)
	local var_69_3 = var_0_77()

	if not settings and var_69_3 then
		local widgetPlacement = var_69_3.getWidgetPlacement and var_69_3.getWidgetPlacement(arg_69_0:getId())

		if not widgetPlacement and var_69_2 then
			widgetPlacement = var_69_3.getWidgetPlacementByType and var_69_3.getWidgetPlacementByType("battlePassInbox") or var_69_3.getWidgetPlacement and var_69_3.getWidgetPlacement("BattlePassInboxWindow")
		end

		if widgetPlacement then
			settings = widgetPlacement.parentId
			var_69_1 = widgetPlacement.index
		end
	end

	if not settings and SidebarLayoutState and SidebarLayoutState.getWidgets then
		local widgets = SidebarLayoutState.getWidgets()[arg_69_0:getId()]

		if not widgets and var_69_2 then
			for unusedValue, getWidget in pairs(SidebarLayoutState.getWidgets()) do
				if getWidget.type == "battlePassInbox" then
					widgets = getWidget

					break
				end
			end
		end

		if widgets then
			settings = widgets.parentId
			var_69_1 = widgets.index
		end
	end

	return settings, var_69_1
end

local function clearContainerWindowLayout(arg_70_0, arg_70_1)
	if not arg_70_0 or not arg_70_0.getId then
		return
	end

	var_0_76(arg_70_0:getId(), arg_70_1)
end

local function ensureSidebarForSavedLayout(parentId)
	if not parentId or not modules.client_options then
		return
	end

	local optionKey

	if parentId == "gameLeftPanel" then
		optionKey = "showLeftPanel"
	elseif parentId:find("^gameLeftExtraPanel") then
		optionKey = "showLeftExtraPanel"
	elseif parentId:find("^gameRightExtraPanel") then
		optionKey = "showRightExtraPanel"
	end

	if optionKey and not modules.client_options.getOption(optionKey) then
		modules.client_options.setOption(optionKey, true, true)

		if modules.game_interface.updateSidebarControlStates then
			modules.game_interface.updateSidebarControlStates()
		end
	end
end

local function computeExpectedNumLines(layout, container)
	local numColumns = layout:getNumColumns()

	if numColumns <= 0 then
		return math.max(layout:getNumLines(), 1)
	end

	local capacity = container:getCapacity()

	return math.max(math.ceil(capacity / numColumns), 1)
end

local var_0_82 = 4
local var_0_83 = 9
local var_0_84 = 3
local var_0_85 = 4
local var_0_86 = var_0_85 + 24
local var_0_87 = 17

local function var_0_88(arg_73_0, arg_73_1, arg_73_2)
	if not arg_73_0 or arg_73_1 <= 0 then
		return 0
	end

	local cellSize = arg_73_0:getCellSize()
	local unusedValue, var_73_2 = getGridSpacing(arg_73_0)

	return arg_73_1 * cellSize.height + math.max(arg_73_1 - 1, 0) * var_73_2 + var_0_87 + (arg_73_2 or var_0_83) - var_0_83
end

local function applyDefaultContentHeightForWindow(containerWindow, layout, unusedArgument, container)
	local itemsCount

	if modules.client_options.getOption("openMaximized") then
		itemsCount = math.max(computeExpectedNumLines(layout, container), 1)
	else
		itemsCount = math.max(math.ceil(container:getItemsCount() / layout:getNumColumns()), 1)
	end

	containerWindow:setContentHeight(var_0_88(layout, itemsCount))
end

local function var_0_90(arg_75_0, arg_75_1, arg_75_2)
	if arg_75_0 and not arg_75_0:isDestroyed() and arg_75_0.getMinimumHeight then
		local minimumHeight = arg_75_0:getMinimumHeight()

		if minimumHeight and minimumHeight > 0 then
			return minimumHeight
		end
	end

	if not arg_75_1 or not arg_75_2 then
		return 0
	end

	local var_75_1 = arg_75_1:hasPages() and var_0_86 or var_0_85

	return var_0_88(arg_75_2, 1) + var_0_82 + var_0_84 + var_75_1
end

local function var_0_91(arg_76_0, arg_76_1, arg_76_2)
	if not arg_76_0 or arg_76_0:isDestroyed() then
		return
	end

	local height = var_0_90(arg_76_0, arg_76_1, arg_76_2)

	if height > 0 and height > arg_76_0:getHeight() then
		arg_76_0:setHeight(height)
	end
end

local function var_0_92(arg_77_0, arg_77_1, arg_77_2, unusedArgument)
	if not arg_77_0 or arg_77_0:isDestroyed() or not arg_77_2 then
		return
	end

	arg_77_0:setContentMinimumHeight(var_0_88(arg_77_2, 1, var_0_84))
	arg_77_0:setContentMaximumHeight(var_0_88(arg_77_2, computeExpectedNumLines(arg_77_2, arg_77_1)))
end

local function var_0_93(arg_78_0, arg_78_1, arg_78_2)
	var_0_91(arg_78_0, arg_78_1, arg_78_2)

	if not arg_78_0 or arg_78_0:isDestroyed() or not arg_78_0.getMaximumHeight then
		return
	end

	local maximumHeight = arg_78_0:getMaximumHeight()

	if maximumHeight and maximumHeight > 0 and maximumHeight < arg_78_0:getHeight() then
		arg_78_0:setHeight(maximumHeight)
	end
end

local function applyContainerHeight(containerWindow, container, layout, cellSize)
	if not containerWindow or containerWindow:isDestroyed() then
		return
	end

	if containerWindow.preservedHeight and containerWindow.preservedHeight > 0 then
		local var_79_0 = var_0_90(containerWindow, container, layout)
		local preservedHeight = containerWindow.preservedHeight

		if var_79_0 > 0 and preservedHeight < var_79_0 then
			preservedHeight = var_79_0
		end

		containerWindow:setHeight(preservedHeight)

		containerWindow.preservedHeight = nil

		var_0_93(containerWindow, container, layout)

		return
	end

	local swop = getSidebarWidgetOptionsPersistence()
	local containerOpts = swop and swop.getContainerOptions and swop.getContainerOptions(container:getId())

	if containerOpts and type(containerOpts.contentHeight) == "number" and containerOpts.contentHeight > 0 then
		containerWindow:setContentHeight(containerOpts.contentHeight)
		var_0_93(containerWindow, container, layout)

		return
	end

	local legacyHeight = containerWindow:getSettings("height")

	if legacyHeight and legacyHeight > 0 then
		containerWindow:setHeight(legacyHeight)
		var_0_93(containerWindow, container, layout)

		return
	end

	applyDefaultContentHeightForWindow(containerWindow, layout, cellSize, container)
	var_0_93(containerWindow, container, layout)
end

local function applyContainerLayout(container, cellSize, arg_80_2, layout)
	local containerWindow = container.window

	if not containerWindow or containerWindow:isDestroyed() then
		return false
	end

	local savedParentId, savedIndex = getSavedLayoutForWindow(containerWindow, container)
	local swop = getSidebarWidgetOptionsPersistence()
	local containerOpts = swop and swop.getContainerOptions and swop.getContainerOptions(container:getId())
	local savedHeight = containerWindow:getSettings("height")
	local savedContentHeight
	local savedMinimized = containerWindow:getSettings("minimized")
	local savedClosed = false

	if containerOpts then
		if containerOpts.contentHeight == 0 and containerOpts.contentMaximized == true then
			savedClosed = true
			savedMinimized = false
		elseif containerOpts.contentMaximized == false then
			savedMinimized = true
		elseif containerOpts.contentMaximized == true then
			savedMinimized = false
		end

		if type(containerOpts.contentHeight) == "number" and containerOpts.contentHeight > 0 then
			savedContentHeight = containerOpts.contentHeight
		end
	end

	if not savedParentId then
		local currentParent = containerWindow:getParent()

		if currentParent and type(currentParent) == "userdata" and not currentParent:isDestroyed() then
			container._needsLayoutRestore = nil

			return true
		end

		local panel = modules.game_interface.findContentPanelAvailable(containerWindow, cellSize.height)

		if not panel or type(panel) ~= "userdata" then
			panel = modules.game_interface.getRightPanel()
		end

		if panel and type(panel) == "userdata" and containerWindow:getParent() ~= panel then
			panel:addChild(containerWindow)
		end

		if not layout then
			applyDefaultContentHeightForWindow(containerWindow, arg_80_2, cellSize, container)
		end

		container._needsLayoutRestore = nil

		return true
	end

	ensureSidebarForSavedLayout(savedParentId)

	local currentParent = containerWindow:getParent()

	if currentParent then
		currentParent:removeChild(containerWindow)
	end

	containerWindow.miniLoaded = false
	containerWindow.miniIndex = nil

	local parent = rootWidget:recursiveGetChildById(savedParentId)

	if not parent or type(parent) ~= "userdata" then
		container._needsLayoutRestore = true

		return false
	end

	local isSidePanel = modules.game_interface and modules.game_interface.isGameSidePanelId and modules.game_interface.isGameSidePanelId(parent:getId())

	if not (parent:isVisible() or isSidePanel and parent:isOn()) then
		container._needsLayoutRestore = true

		return false
	end

	if parent:getClassName() == "UIMiniWindowContainer" and savedIndex and type(parent.scheduleInsert) == "function" then
		local requestedIdx = tonumber(savedIndex)

		if requestedIdx then
			local actualIndex
			local children = parent:getChildren()
			local saveCount = 0

			for i = 1, #children do
				local child = children[i]

				if child and child.save then
					saveCount = saveCount + 1
				end

				if requestedIdx <= saveCount then
					actualIndex = i

					break
				end
			end

			actualIndex = actualIndex or parent:getChildCount() + 1
			containerWindow.miniIndex = requestedIdx

			parent:scheduleInsert(containerWindow, actualIndex)
		else
			containerWindow.miniIndex = nil

			parent:addChild(containerWindow)
		end
	else
		local savedPosition = containerWindow:getSettings("position")

		if savedPosition then
			containerWindow:setParent(parent, true)
			containerWindow:setPosition(topoint(savedPosition))
		else
			local idx = tonumber(savedIndex)

			if idx and type(parent.insertChild) == "function" then
				local children = parent:getChildren()
				local saveCount = 0
				local actualIndex

				for i = 1, #children do
					local child = children[i]

					if child and child.save then
						saveCount = saveCount + 1
					end

					if idx <= saveCount then
						actualIndex = i

						break
					end
				end

				actualIndex = actualIndex or parent:getChildCount() + 1

				parent:insertChild(actualIndex, containerWindow)
			else
				parent:addChild(containerWindow)
			end
		end
	end

	containerWindow.miniLoaded = true

	containerWindow:eraseSettings({
		closed = true
	})

	if savedClosed then
		containerWindow:close(true)
	else
		if not layout then
			if containerWindow.preservedHeight and containerWindow.preservedHeight > 0 then
				local var_80_25 = var_0_90(containerWindow, container, arg_80_2)
				local preservedHeight = containerWindow.preservedHeight

				if var_80_25 > 0 and preservedHeight < var_80_25 then
					preservedHeight = var_80_25
				end

				containerWindow:setHeight(preservedHeight)

				containerWindow.preservedHeight = nil
			elseif savedContentHeight and containerWindow:isResizeable() then
				containerWindow:setContentHeight(savedContentHeight)
				var_0_91(containerWindow, container, arg_80_2)
			elseif savedHeight and containerWindow:isResizeable() then
				containerWindow:setHeight(savedHeight)
				var_0_91(containerWindow, container, arg_80_2)
			end
		end

		containerWindow:open(true)

		if savedMinimized then
			containerWindow:minimize(true)
		end
	end

	if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
		SidebarLayoutState.noteWidgetPlacement(containerWindow)
	end

	if parent:getClassName() == "UIMiniWindowContainer" then
		addEvent(function()
			if parent and not parent:isDestroyed() then
				local var_81_0 = var_0_77()

				if var_81_0 and var_81_0.isRestoringLoginOrder and var_81_0.isRestoringLoginOrder() then
					parent:order()
				end
			end
		end)
	end

	container._needsLayoutRestore = nil
	container._layoutRestoreAttempts = nil

	return true
end

local function applyDefaultPanelFallback(container, cellSize, layout)
	local containerWindow = container.window

	if not containerWindow or containerWindow:isDestroyed() then
		return
	end

	local currentParent = containerWindow:getParent()

	if currentParent then
		currentParent:removeChild(containerWindow)
	end

	local panel = modules.game_interface.findContentPanelAvailable(containerWindow, cellSize.height)

	if not panel or type(panel) ~= "userdata" then
		panel = modules.game_interface.getRightPanel()
	end

	if panel and type(panel) == "userdata" then
		panel:addChild(containerWindow)
	end

	applyDefaultContentHeightForWindow(containerWindow, layout, cellSize, container)
	containerWindow:open(true)

	container._needsLayoutRestore = nil
	container._layoutRestoreAttempts = nil
end

local function restoreAllContainerLayouts()
	local stillPending = false

	for _, container in pairs(g_game.getContainers()) do
		local window = container.window

		if not window or window:isDestroyed() then
			-- block empty
		else
			local savedParentId = getSavedLayoutForWindow(window, container)
			local currentParent = window:getParent()
			local currentParentId = currentParent and currentParent:getId()

			if savedParentId and (container._needsLayoutRestore or savedParentId ~= currentParentId) then
				local containerPanel = window:getChildById("contentsPanel")
				local layout = containerPanel and containerPanel:getLayout()

				if layout then
					local cellSize = layout:getCellSize()

					applyContainerLayout(container, cellSize, layout, true)
					toggleContainerPages(window, container)
					applyContainerContextLayout(window)
					var_0_92(window, container, layout, cellSize)
					applyContainerHeight(window, container, layout, cellSize)
					var_0_93(window, container, layout)

					if container._needsLayoutRestore then
						container._layoutRestoreAttempts = (container._layoutRestoreAttempts or 0) + 1

						if container._layoutRestoreAttempts > LAYOUT_RESTORE_MAX_ATTEMPTS then
							applyDefaultPanelFallback(container, cellSize, layout)
							toggleContainerPages(window, container)
							applyContainerContextLayout(window)
							var_0_92(window, container, layout, cellSize)
							var_0_93(window, container, layout)
						else
							stillPending = true
						end
					end
				end
			elseif container._needsLayoutRestore and not savedParentId then
				container._needsLayoutRestore = nil
			end
		end
	end

	if stillPending then
		scheduleContainersLayoutRestore()
	end
end

function restoreAllContainerLayoutsNow()
	if containersLayoutRestoredThisLogin then
		return
	end

	containersLayoutRestoredThisLogin = true

	restoreAllContainerLayouts()
end

function scheduleContainersLayoutRestore()
	if layoutRestoreScheduled then
		return
	end

	layoutRestoreScheduled = true

	addEvent(function()
		layoutRestoreScheduled = false

		restoreAllContainerLayouts()
	end)
end

function toggleManualSortMode()
	if not containerSettings then
		return
	end

	local newState = containerSettings.useManualSortMode ~= 1

	containerSettings.useManualSortMode = newState and 1 or 0

	g_settings.setNode("containers", containerSettings)
	g_game.setManualContainerSort(newState)
	refreshAllContainerTitleStyles()
end

function init()
	g_ui.importStyle("container")
	g_ui.importStyle("sortNestedContainersConfirm")

	containerSettings = g_settings.getNode("containers")

	if not containerSettings then
		containerSettings = {}
		containerSettings.useManualSortMode = 0
		containerSettings.currentSortMode = "none"
		containerSettings.sortContainersFirst = 0
		containerSettings.sortNestedContainers = 0

		g_settings.setNode("containers", containerSettings)
	end

	if not containerSettings.manualSortMigrated then
		containerSettings.useManualSortMode = 0
		containerSettings.manualSortMigrated = 1

		g_settings.setNode("containers", containerSettings)
	end

	if containerSettings.sortNestedContainers == nil then
		containerSettings.sortNestedContainers = 0
	end

	if containerSettings.sortContainersFirst == nil then
		containerSettings.sortContainersFirst = 0
	end

	if containerSettings.useManualSortMode == nil then
		containerSettings.useManualSortMode = 0
	end

	g_game.setManualContainerSort(containerSettings.useManualSortMode == 1)
	connect(Container, {
		onOpen = onContainerOpen,
		onClose = onContainerClose,
		onSizeChange = onContainerChangeSize,
		onUpdateItem = onContainerUpdateItem
	})
	connect(g_game, {
		onGameEnd = onGameEnd,
		onGameStart = onContainersGameStart
	})
	Keybind.new("Containers", "Toggle Manual Sort Mode", {
		[CHAT_MODE.ON] = "",
		[CHAT_MODE.OFF] = "Shift+S"
	}, "")
	Keybind.bind("Containers", "Toggle Manual Sort Mode", {
		{
			type = KEY_DOWN,
			callback = function()
				if not g_game.isOnline() then
					return
				end

				toggleManualSortMode()
			end
		}
	})

	if not UIItem._containerDragMoveWrapped then
		UIItem._containerDragMoveWrapped = true

		local originalOnDragMove = UIItem.onDragMove

		function UIItem.onDragMove(self, mousePos, mouseMoved)
			if originalOnDragMove then
				originalOnDragMove(self, mousePos, mouseMoved)
			end

			updateContainerDragHover(mousePos)
		end

		local originalOnDragLeave = UIItem.onDragLeave

		function UIItem.onDragLeave(self, droppedWidget, mousePos)
			clearContainerDragHoveredSlot()

			if originalOnDragLeave then
				return originalOnDragLeave(self, droppedWidget, mousePos)
			end

			return true
		end
	end

	reloadContainers()
end

function terminate()
	Keybind.delete("Containers", "Toggle Manual Sort Mode")
	disconnect(Container, {
		onOpen = onContainerOpen,
		onClose = onContainerClose,
		onSizeChange = onContainerChangeSize,
		onUpdateItem = onContainerUpdateItem
	})

	if g_game then
		disconnect(g_game, {
			onGameEnd = onGameEnd,
			onGameStart = onContainersGameStart
		})
	end
end

function onContainersGameStart()
	scheduleContainersLayoutRestore()
end

function onGameEnd()
	savingContainerLayoutsOnLogout = true

	clean()

	savingContainerLayoutsOnLogout = false
	containersLayoutRestoredThisLogin = false
end

function reloadContainers()
	clean()

	for _, container in pairs(g_game.getContainers()) do
		onContainerOpen(container)
	end
end

function clean()
	clearContainerDragHoveredSlot()

	for containerid, container in pairs(g_game.getContainers()) do
		destroy(container)
	end
end

function destroy(container)
	container._needsLayoutRestore = nil

	if container.window then
		local parent = container.window

		container.window = nil
		container.itemsPanel = nil

		if parent:isDestroyed() then
			return
		end

		local var_97_1 = parent:getParent()

		parent:destroy()

		if var_97_1 and not var_97_1:isDestroyed() and var_97_1:getClassName() == "UIMiniWindowContainer" and type(var_97_1.refreshSidebarFreeSpace) == "function" then
			var_97_1:refreshSidebarFreeSpace()
		end
	end
end

function closeContainerForSidebar(container)
	if not container then
		return
	end

	local window = container.window

	if window and not window:isDestroyed() then
		clearContainerWindowLayout(window, container)
	end

	g_game.close(container)
end

function showContainersContextMenu(widget, mousePos, mouseButton)
	local sourceContainer = getContainerFromWidget(widget)

	if isStoreInboxContainer(sourceContainer) then
		if not shouldShowStoreInboxFilterButton(sourceContainer) then
			return false
		end

		return showStoreInboxContextMenu(widget, mousePos, mouseButton, sourceContainer)
	end

	local menu = g_ui.createWidget("ContainersSubMenu")

	if not menu then
		return false
	end

	menu:setGameMenu(true)

	local var_99_2 = var_0_39(sourceContainer)
	local visible = var_0_42(sourceContainer)
	local autoLoot = menu:getChildById("autoLoot")
	local autoLootSeparator = menu:getChildById("autoLootSeparator")

	if autoLootSeparator then
		autoLootSeparator:setVisible(visible)
	end

	if autoLoot then
		autoLoot:setVisible(visible)

		if visible then
			local var_99_6 = OtcOpCode and OtcOpCode.TOGGLE_AUTOLOOT or 1
			local checked = g_game.isOtcToggleEnabled and g_game.isOtcToggleEnabled(var_99_6) and true or false
			local unusedValue = true

			autoLoot:setChecked(checked)

			local var_99_9 = false

			function autoLoot.onCheckChange(arg_100_0)
				if var_99_9 then
					return
				end

				if not g_game.sendOtcToggle then
					return
				end

				g_game.sendOtcToggle(var_99_6, arg_100_0:isChecked() and 1 or 0)
				menu:destroy()
			end
		end
	end

	for _, choice in ipairs(menu:getChildren()) do
		local choiceId = choice:getId()

		if var_99_2 and choiceId ~= "autoLoot" and choiceId ~= "autoLootSeparator" then
			choice:setVisible(false)
		end

		if choiceId and choiceId ~= "HorizontalSeparator" and choiceId ~= "autoLoot" and choiceId ~= "autoLootSeparator" then
			local widgetClass = choice:getClassName()
			local isSortingAction = choiceId:find("sortAsc") or choiceId:find("sortDesc")

			if isSortingAction or choiceId == "moveToObtainContainers" then
				function choice.onClick()
					onContainersMenuAction(choiceId, sourceContainer)
					menu:destroy()
				end

				function choice.onMouseRelease(widget, mousePos, mouseButton)
					if mouseButton == MouseLeftButton then
						onContainersMenuAction(choiceId, sourceContainer)
						menu:destroy()

						return true
					end

					return false
				end

				if isSortingAction then
					choice:setEnabled(true)
					choice:setColor("#ffffff")
				else
					choice:setEnabled(true)
					choice:setColor("#ffffff")
				end
			else
				local currentState = getContainerOptionState(choiceId)

				choice:setChecked(currentState)
				choice:setEnabled(true)
				choice:setColor("#ffffff")

				function choice.onCheckChange()
					onContainersMenuAction(choiceId, sourceContainer)
					menu:destroy()
				end
			end
		end
	end

	local buttonPos = widget:getPosition()
	local buttonSize = widget:getSize()
	local width = menu:getWidth()
	local buttonCenterX = buttonPos.x + buttonSize.width / 2
	local var_99_18, menuX = buttonPos.y + buttonSize.height / 2, buttonCenterX - width

	menu:display({
		x = menuX,
		y = var_99_18
	})

	return true
end

function getContainerOptionState(optionId)
	if not containerSettings then
		return false
	end

	if optionId == "sortContainersFirst" then
		return containerSettings.sortContainersFirst == 1
	elseif optionId == "sortNestedContainers" then
		return containerSettings.sortNestedContainers == 1
	elseif optionId == "useManualSortMode" then
		return containerSettings.useManualSortMode == 1
	elseif optionId == "moveNestedContainers" then
		return containerSettings.moveNestedContainers == 1
	end

	return false
end

function sortContainerItems(container, sortMode)
	if not container then
		return
	end

	requestContainerSort(container, sortMode)
end

function onContainersMenuAction(actionId, container)
	local isToggleOption = actionId == "sortContainersFirst" or actionId == "sortNestedContainers" or actionId == "useManualSortMode" or actionId == "moveNestedContainers"

	if actionId == "moveToObtainContainers" or actionId:find("sortAsc") or actionId:find("sortDesc") then
		if actionId == "moveToObtainContainers" then
			if container then
				requestMoveToObtainContainers(container)
			else
				applyMoveToObtainToOpenContainers()
			end

			return
		elseif actionId:find("sortAsc") or actionId:find("sortDesc") then
			handleContainerSortAction(container, actionId)

			return
		end
	end

	if isToggleOption then
		local var_106_1 = not getContainerOptionState(actionId)

		containerSettings[actionId] = var_106_1 and 1 or 0

		g_settings.setNode("containers", containerSettings)

		if actionId == "useManualSortMode" then
			g_game.setManualContainerSort(var_106_1)
			refreshAllContainerTitleStyles()
		end
	end
end

local applyContainerHeaderButtonLayout

function refreshContainerItems(container)
	for slot = 0, container:getCapacity() - 1 do
		local slotWidget = container.itemsPanel:getChildById("item" .. slot)

		applyContainerSlotVisuals(slotWidget, container:getItem(slot))
		bindContainerSlotPosition(slotWidget, container:getSlotPosition(slot))
	end

	if container:hasPages() then
		refreshContainerPages(container)
	end

	if container.window and (isStoreInboxContainer(container) or var_0_38(container)) then
		applyContainerHeaderButtonLayout(container.window, container)
	end
end

local function isContainerInHorizontalContext(widget)
	local current = widget

	for _ = 1, 12 do
		if not current then
			break
		end

		if current.isHorizontalPanel then
			return true
		end

		local id = current.getId and current:getId() or nil

		if id == "gameLeftTopPanel" or id == "gameRightTopPanel" then
			return true
		end

		current = current.getParent and current:getParent() or nil
	end

	return false
end

function isContainerMiniWindow(widget)
	if not widget or widget.isDestroyed and widget:isDestroyed() then
		return false
	end

	return widget:getChildById("containerItemWidget") ~= nil
end

function applyContainerContextLayout(containerWindow)
	if not containerWindow or containerWindow.isDestroyed and containerWindow:isDestroyed() then
		return
	end

	if not isContainerMiniWindow(containerWindow) then
		return
	end

	local contents = containerWindow.getChildById and containerWindow:getChildById("contentsPanel")

	if not contents then
		return
	end

	contents:setMarginLeft(isContainerInHorizontalContext(containerWindow) and 1 or 5)
	contents:setMarginRight(1)
end

local marginRight = 1
local CONTAINER_HEADER_BUTTON_MARGIN = 5
local CONTAINER_SLOT_BATCH_SIZE = 50

local function createContainerSlotWidget(containerPanel, container, slot)
	local slotWidget = g_ui.createWidget("ContainerItemSlot", containerPanel)

	slotWidget:setId("item" .. slot)
	slotWidget:setMargin(0)
	applyContainerSlotVisuals(slotWidget, container:getItem(slot))
	bindContainerSlotPosition(slotWidget, container:getSlotPosition(slot))

	if not container:isUnlocked() then
		slotWidget:setBorderColor("red")
	end

	return slotWidget
end

function applyContainerHeaderButtonLayout(containerWindow, container)
	if not containerWindow or containerWindow.isDestroyed and containerWindow:isDestroyed() then
		return
	end

	local upButton = containerWindow:getChildById("upButton")
	local searchButton = containerWindow:getChildById("searchButton")
	local contextMenuButton = containerWindow:recursiveGetChildById("contextMenuButton")
	local lockButton = containerWindow:recursiveGetChildById("lockButton")
	local minimizeButton = containerWindow:recursiveGetChildById("minimizeButton")

	if not upButton or not contextMenuButton or not minimizeButton then
		var_0_10(containerWindow, minimizeButton)

		return
	end

	local showDepotSearch = container and container.isInDepot and container:isInDepot()
	local showStoreInboxFilter = shouldShowStoreInboxFilterButton(container)

	if searchButton then
		searchButton:setVisible(showDepotSearch)
	end

	local var_112_7 = var_0_42(container)
	local visible = not showDepotSearch and not var_0_38(container) and (showStoreInboxFilter or not isStoreInboxContainer(container)) and (not var_0_39(container) or var_112_7)

	contextMenuButton:setVisible(visible)

	local var_112_9 = container and modules.game_interface.canContainerShowUpButton and modules.game_interface.canContainerShowUpButton(container)

	upButton:setVisible(var_112_9)
	upButton:breakAnchors()
	upButton:addAnchor(AnchorTop, minimizeButton:getId(), AnchorTop)
	upButton:addAnchor(AnchorRight, minimizeButton:getId(), AnchorLeft)
	upButton:setMarginRight(marginRight)
	upButton:setMarginTop(0)

	local var_112_10

	if showDepotSearch and searchButton then
		var_112_10 = searchButton
	elseif visible then
		var_112_10 = contextMenuButton
	end

	if var_112_10 then
		var_112_10:breakAnchors()

		if var_112_9 then
			var_112_10:addAnchor(AnchorTop, upButton:getId(), AnchorTop)
			var_112_10:addAnchor(AnchorRight, upButton:getId(), AnchorLeft)
		else
			var_112_10:addAnchor(AnchorTop, minimizeButton:getId(), AnchorTop)
			var_112_10:addAnchor(AnchorRight, minimizeButton:getId(), AnchorLeft)
		end

		var_112_10:setMarginRight(CONTAINER_HEADER_BUTTON_MARGIN)
		var_112_10:setMarginTop(0)
	end

	local var_112_11 = var_112_10 or var_112_9 and upButton or minimizeButton

	if lockButton and var_112_11 then
		lockButton:breakAnchors()
		lockButton:addAnchor(AnchorTop, var_112_11:getId(), AnchorTop)
		lockButton:addAnchor(AnchorRight, var_112_11:getId(), AnchorLeft)
		lockButton:setMarginRight(CONTAINER_HEADER_BUTTON_MARGIN)
		lockButton:setMarginTop(0)
	end

	local var_112_12 = lockButton and lockButton:isVisible() and lockButton or var_112_10 or var_112_9 and upButton or minimizeButton

	var_0_10(containerWindow, var_112_12)
end

function toggleContainerPages(containerWindow, container)
	local pages = container:hasPages()
	local scrollbar = containerWindow:getChildById("miniwindowScrollBar")
	local pagePanel = containerWindow:getChildById("pagePanel")
	local separator = containerWindow:getChildById("separator")
	local contentsPanel = containerWindow:getChildById("contentsPanel")
	local marginBottom = pages and var_0_86 or var_0_85

	if pages then
		scrollbar:breakAnchors()
		scrollbar:addAnchor(AnchorTop, "closeButton", AnchorBottom)
		scrollbar:addAnchor(AnchorRight, "parent", AnchorRight)
		scrollbar:addAnchor(AnchorBottom, "parent", AnchorBottom)
		scrollbar:setMarginTop(2)
		scrollbar:setMarginRight(4)
		scrollbar:setMarginBottom(marginBottom)
		contentsPanel:breakAnchors()
		contentsPanel:addAnchor(AnchorTop, "miniwindowTopBar", AnchorBottom)
		contentsPanel:addAnchor(AnchorLeft, "parent", AnchorLeft)
		contentsPanel:addAnchor(AnchorRight, "miniwindowScrollBar", AnchorLeft)
		contentsPanel:addAnchor(AnchorBottom, "parent", AnchorBottom)
		contentsPanel:setMarginLeft(isContainerInHorizontalContext(containerWindow) and 1 or 5)
		contentsPanel:setMarginBottom(marginBottom)
		contentsPanel:setMarginTop(-2)
		contentsPanel:setMarginRight(1)
		contentsPanel:setPaddingTop(var_0_82)
		contentsPanel:setPaddingBottom(var_0_83)

		if contentsPanel.setClipToPadding then
			contentsPanel:setClipToPadding(false)
		end
	else
		scrollbar:breakAnchors()
		scrollbar:addAnchor(AnchorTop, "parent", AnchorTop)
		scrollbar:addAnchor(AnchorRight, "parent", AnchorRight)
		scrollbar:addAnchor(AnchorBottom, "parent", AnchorBottom)
		scrollbar:setMarginTop(15)
		scrollbar:setMarginRight(4)
		scrollbar:setMarginBottom(marginBottom)
		contentsPanel:breakAnchors()
		contentsPanel:addAnchor(AnchorTop, "miniwindowTopBar", AnchorBottom)
		contentsPanel:addAnchor(AnchorLeft, "parent", AnchorLeft)
		contentsPanel:addAnchor(AnchorRight, "miniwindowScrollBar", AnchorLeft)
		contentsPanel:addAnchor(AnchorBottom, "parent", AnchorBottom)
		contentsPanel:setMarginLeft(isContainerInHorizontalContext(containerWindow) and 1 or 5)
		contentsPanel:setMarginBottom(marginBottom)
		contentsPanel:setMarginTop(-2)
		contentsPanel:setMarginRight(1)
		contentsPanel:setPaddingTop(var_0_82)
		contentsPanel:setPaddingBottom(var_0_83)

		if contentsPanel.setClipToPadding then
			contentsPanel:setClipToPadding(false)
		end
	end

	applyContainerHeaderButtonLayout(containerWindow, container)
	pagePanel:setVisible(pages)
	separator:setVisible(pages)
end

function refreshContainerPages(container)
	local currentPage = 1 + math.floor(container:getFirstIndex() / container:getCapacity())
	local pages = 1 + math.floor(math.max(0, container:getSize() - 1) / container:getCapacity())

	container.window:recursiveGetChildById("pageLabel"):setText(string.format("Page %i of %i", currentPage, pages))

	local prevPageButton = container.window:recursiveGetChildById("prevPageButton")
	local nextPageButton = container.window:recursiveGetChildById("nextPageButton")

	if pages == 1 then
		prevPageButton:setVisible(false)
		nextPageButton:setVisible(false)
	else
		if currentPage == 1 then
			prevPageButton:setVisible(false)
		else
			prevPageButton:setVisible(true)
			prevPageButton:setEnabled(true)

			function prevPageButton.onClick()
				local currentHeight = container.window:getHeight()

				container.window.preservedHeight = currentHeight

				g_game.seekInContainer(container:getId(), container:getFirstIndex() - container:getCapacity(), getContainerSeekFilter(container))
			end
		end

		if pages <= currentPage then
			nextPageButton:setVisible(false)
		else
			nextPageButton:setVisible(true)
			nextPageButton:setEnabled(true)

			function nextPageButton.onClick()
				local currentHeight = container.window:getHeight()

				container.window.preservedHeight = currentHeight

				g_game.seekInContainer(container:getId(), container:getFirstIndex() + container:getCapacity(), getContainerSeekFilter(container))
			end
		end
	end
end

function onContainerOpen(container, previousContainer)
	if not previousContainer and container.window and not container.window:isDestroyed() and container.window:isVisible() then
		clearContainerWindowLayout(container.window, container)
		g_game.close(container)

		return
	end

	local containerWindow
	local reusedWindow = false

	if previousContainer then
		previousContainer._openToken = (previousContainer._openToken or 0) + 1
		containerWindow = previousContainer.window
		previousContainer.window = nil
		previousContainer.itemsPanel = nil

		if containerWindow and not containerWindow:isDestroyed() then
			reusedWindow = true
		end
	end

	if not containerWindow or containerWindow:isDestroyed() then
		containerWindow = g_ui.createWidget("ContainerWindow")
		reusedWindow = false
	end

	if not containerWindow then
		g_logger.error("onContainerOpen: failed to create ContainerWindow for id " .. container:getId())

		return
	end

	local openToken = (container._openToken or 0) + 1

	container._openToken = openToken
	nextContainerOpenInvocation = nextContainerOpenInvocation + 1

	local invocationId = nextContainerOpenInvocation

	containerWindow._openInvocationId = invocationId

	local function isOpenStale()
		return container._openToken ~= openToken
	end

	local function abortStaleOpen()
		if not containerWindow or containerWindow:isDestroyed() then
			return
		end

		if containerWindow._openInvocationId ~= invocationId then
			return
		end

		containerWindow:destroy()
	end

	containerWindow:setId("container" .. container:getId())

	local containerPanel = containerWindow:getChildById("contentsPanel")
	local containerItemWidget = containerWindow:getChildById("containerItemWidget")

	containerWindow:getChildById("miniwindowScrollBar"):mergeStyle({
		["$!on"] = {}
	})

	containerWindow:getChildById("upButton").onClick = function()
		g_game.openParent(container)
	end

	function containerWindow.onMinimize()
		local pagePanel = containerWindow:getChildById("pagePanel")

		if pagePanel and pagePanel:isVisible() then
			pagePanel.wasVisibleBeforeMinimize = true

			pagePanel:setVisible(false)
		end
	end

	function containerWindow.onMaximize()
		local pagePanel = containerWindow:getChildById("pagePanel")

		if pagePanel and pagePanel.wasVisibleBeforeMinimize then
			pagePanel:setVisible(true)

			pagePanel.wasVisibleBeforeMinimize = nil
		end
	end

	local toggleFilterButton = containerWindow:recursiveGetChildById("toggleFilterButton")

	if toggleFilterButton then
		toggleFilterButton:setVisible(false)
		toggleFilterButton:setOn(false)
	end

	local newWindowButton = containerWindow:recursiveGetChildById("newWindowButton")

	if newWindowButton then
		newWindowButton:setVisible(false)
	end

	local contextMenuButton = containerWindow:recursiveGetChildById("contextMenuButton")

	if contextMenuButton then
		function contextMenuButton.onClick(widget, mousePos, mouseButton)
			return showContainersContextMenu(widget, mousePos, mouseButton)
		end
	end

	local searchButton = containerWindow:getChildById("searchButton")

	if searchButton then
		function searchButton.onClick()
			if modules.game_search_locker and modules.game_search_locker.onRequestSearch then
				modules.game_search_locker.onRequestSearch()
			end
		end
	end

	applyContainerHeaderButtonLayout(containerWindow, container)

	local name = container:getName()
	local name = name:sub(1, 1):upper() .. name:sub(2)
	local titleWidget = containerWindow:getChildById("miniwindowTitle")

	if titleWidget then
		titleWidget:setText(name)
		applyContainerTitleStyle(containerWindow)
	else
		containerWindow:setText(name)
	end

	containerItemWidget:setItem(container:getContainerItem())
	containerItemWidget:setPhantom(true)
	containerPanel:destroyChildren()

	local layout = containerPanel:getLayout()

	layout:disableUpdates()

	local function finishContainerOpen()
		if isOpenStale() then
			layout:enableUpdates()
			abortStaleOpen()

			return
		end

		layout:enableUpdates()
		layout:update()

		container.window = containerWindow
		container.itemsPanel = containerPanel

		setupContainerDropTarget(containerPanel, containerWindow)
		refreshContainerPages(container)

		local cellSize = layout:getCellSize()

		local function restrictResize()
			function containerWindow.onResize()
				var_0_91(containerWindow, container, layout)
			end
		end

		restrictResize()

		function containerWindow.onMinimize()
			local pagePanel = containerWindow:getChildById("pagePanel")

			if pagePanel and pagePanel:isVisible() then
				pagePanel.wasVisibleBeforeMinimize = true

				pagePanel:setVisible(false)
			end

			containerWindow.onResize = nil
		end

		function containerWindow.onMaximize()
			local pagePanel = containerWindow:getChildById("pagePanel")

			if pagePanel and pagePanel.wasVisibleBeforeMinimize then
				pagePanel:setVisible(true)

				pagePanel.wasVisibleBeforeMinimize = nil
			end

			restrictResize()
		end

		containerWindow:setup()

		local closeButton = containerWindow:getChildById("closeButton")

		if closeButton then
			function closeButton.onClick()
				closeContainerForSidebar(container)
			end
		end

		if not reusedWindow then
			if getSavedLayoutForWindow(containerWindow, container) then
				container._needsLayoutRestore = true

				containerWindow:hide()

				if not applyContainerLayout(container, cellSize, layout, true) then
					scheduleContainersLayoutRestore()
				else
					container._layoutRestoreAttempts = nil
				end
			else
				container._needsLayoutRestore = nil

				local var_125_3 = modules.game_interface.findContentPanelAvailable(containerWindow, cellSize.height)

				containerWindow.miniIndex = nil
				containerWindow.miniLoaded = true

				var_125_3:addChild(containerWindow)

				if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
					SidebarLayoutState.noteWidgetPlacement(containerWindow)
				end
			end
		else
			if not containerWindow.preservedHeight or containerWindow.preservedHeight <= 0 then
				containerWindow.preservedHeight = containerWindow:getHeight()
			end

			local currentParent = containerWindow:getParent()

			if not currentParent or currentParent:isDestroyed() or not containerWindow:isVisible() then
				local panel = modules.game_interface.findContentPanelAvailable(containerWindow, cellSize.height)

				if currentParent then
					currentParent:removeChild(containerWindow)
				end

				panel:addChild(containerWindow)
				containerWindow:show()

				if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
					SidebarLayoutState.noteWidgetPlacement(containerWindow)
				end
			end
		end

		toggleContainerPages(containerWindow, container)
		applyContainerContextLayout(containerWindow)
		var_0_92(containerWindow, container, layout, cellSize)
		applyContainerHeight(containerWindow, container, layout, cellSize)
		var_0_93(containerWindow, container, layout)
	end

	local capacity = container:getCapacity()
	local firstBatchSize = math.min(capacity, CONTAINER_SLOT_BATCH_SIZE)

	for slot = 0, firstBatchSize - 1 do
		createContainerSlotWidget(containerPanel, container, slot)
	end

	finishContainerOpen()

	if firstBatchSize < capacity then
		local slot = firstBatchSize

		local function createNextBatch()
			if isOpenStale() then
				abortStaleOpen()

				return
			end

			if not container.itemsPanel or container.itemsPanel:isDestroyed() then
				return
			end

			local batchLayout = container.itemsPanel:getLayout()

			if batchLayout then
				batchLayout:disableUpdates()
			end

			local endSlot = math.min(slot + CONTAINER_SLOT_BATCH_SIZE - 1, capacity - 1)

			for s = slot, endSlot do
				createContainerSlotWidget(containerPanel, container, s)
			end

			slot = endSlot + 1

			if batchLayout then
				batchLayout:enableUpdates()
				batchLayout:update()
			end

			if slot < capacity then
				addEvent(createNextBatch)
			end
		end

		addEvent(createNextBatch)
	end
end

function onContainerClose(container)
	local windowId = container.window and container.window:getId()

	destroy(container)

	if windowId and not savingContainerLayoutsOnLogout then
		var_0_76(windowId, container)
	end
end

function onContainerChangeSize(container, size)
	if not container.window then
		return
	end

	local preservedHeight = container.window.preservedHeight

	refreshContainerItems(container)

	if preservedHeight then
		local contentsPanel = container.itemsPanel or container.window and container.window:getChildById("contentsPanel")
		local layout = contentsPanel and contentsPanel:getLayout()
		local var_133_3 = var_0_90(container.window, container, layout)

		if var_133_3 > 0 and preservedHeight < var_133_3 then
			preservedHeight = var_133_3
		end

		container.window:setHeight(preservedHeight)

		container.window.preservedHeight = nil

		if layout then
			var_0_93(container.window, container, layout)
		end
	end
end

function onContainerUpdateItem(container, slot, arg_134_2, unusedArgument)
	if not container.window then
		return
	end

	local item = container.itemsPanel:getChildById("item" .. slot)

	applyContainerSlotVisuals(item, arg_134_2)
	bindContainerSlotPosition(item, container:getSlotPosition(slot))

	if isStoreInboxContainer(container) or var_0_38(container) then
		applyContainerHeaderButtonLayout(container.window, container)
	end
end
