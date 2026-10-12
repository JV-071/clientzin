SidebarWidgetsPersistence = {}

local SECTION_WIDGETS_MANAGER = "sidebarWidgetsMangerOptions"
local HORIZONTAL_PARENT_IDS = {
	"gameRightTopPanel",
	"gameLeftTopPanel"
}
local SECTION_FIELD_ORDER = {
	"leftHorizontalSidebar",
	"rightHorizontalSidebar",
	"leftSidebarCount",
	"openWidgetsOrderPerHorizontalSidebar",
	"openWidgetsOrderPerSidebar"
}
local applyScheduled = false
local placementByWidgetId = {}
local fullOrderRestoreEvent
local isRestoringLoginOrder = false
local battlePassInboxRequested = false
local widgetIdByType = {
	prey = "preyTracker",
	battlePassTracker = "BattlePassTrackerWindow",
	battleList = "battleWindow",
	bosstiaryTracker = "BosstiaryTrackerWindow",
	partyList = "partyWindow",
	bestiaryTracker = "BestiaryTrackerWindow",
	xpAnalyser = "xpAnalyserMiniWindow",
	vip = "vipWindow",
	partyHuntAnalyser = "phAnalyserMiniWindow",
	skills = "skillWindow",
	dropTracker = "dropTrackerMiniWindow",
	huntingSessionAnalyser = "huntingAnalyserMiniWindow",
	bossCooldown = "bossCdAnalyserMiniWindow",
	damageInputAnalyser = "inputAnalyserMiniWindow",
	minimap = "mainmappanel",
	impactAnalyser = "impactAnalyserMiniWindow",
	supplyAnalyser = "supplyAnalyserMiniWindow",
	lootAnalyser = "lootAnalyserMiniWindow",
	analyticsSelector = "analyserMiniWindow",
	helperStats = "helperStatsWindow",
	spellList = "spellListMiniWindow",
	unjustifiedPoints = "unjustifiedPointsWindow",
	questTracker = "QuestLogTracker",
	imbuementTracker = "imbuementTracker",
	battlePassInbox = "BattlePassInboxWindow"
}
local moduleNameByWidgetType = {
	prey = "game_prey",
	battlePassTracker = "game_battlepass",
	battleList = "game_battle",
	bosstiaryTracker = "game_cyclopedia",
	partyList = "game_party",
	bestiaryTracker = "game_cyclopedia",
	xpAnalyser = "game_analysers",
	vip = "game_viplist",
	partyHuntAnalyser = "game_analysers",
	skills = "game_skills",
	dropTracker = "game_analysers",
	huntingSessionAnalyser = "game_analysers",
	bossCooldown = "game_analysers",
	damageInputAnalyser = "game_analysers",
	minimap = "game_minimap",
	impactAnalyser = "game_analysers",
	supplyAnalyser = "game_analysers",
	lootAnalyser = "game_analysers",
	analyticsSelector = "game_analysers",
	helperStats = "game_helper",
	spellList = "game_spelllist",
	unjustifiedPoints = "game_unjustifiedpoints",
	questTracker = "game_questlog",
	imbuementTracker = "game_imbuementtracker",
	battlePassInbox = "game_battlepass"
}

local function resolveWidgetId(widgetType, instance)
	if widgetType == "container" then
		return "container" .. tostring(instance or 0)
	end

	if widgetType == "battlePassInbox" then
		local inboxWindow = SidebarWidgetOptions and SidebarWidgetOptions.findBattlePassInboxWindow and SidebarWidgetOptions.findBattlePassInboxWindow()

		if inboxWindow and inboxWindow.getId then
			return inboxWindow:getId()
		end

		return "BattlePassInboxWindow"
	end

	if widgetType == "battleList" then
		instance = tonumber(instance) or 0

		if instance == 0 then
			return "battleWindow"
		end

		return "battleWindow_" .. instance
	end

	local localId = widgetIdByType[widgetType]

	if localId then
		return localId
	end

	if CipImportMappings and CipImportMappings.resolveSidebarWidgetId then
		return CipImportMappings.resolveSidebarWidgetId(widgetType, instance)
	end

	return nil
end

local function getRightExtraCountFromSection(section)
	local order = section.openWidgetsOrderPerSidebar

	if type(order) ~= "table" then
		return 0
	end

	local leftSidebarCount = tonumber(section.leftSidebarCount) or 0

	return math.max(0, #order - 1 - leftSidebarCount)
end

local function getParentIdForVerticalSlot(slotIndex, section)
	if not tonumber(section.leftSidebarCount) then
		local unusedValue = 0
	end

	local rightExtraCount = getRightExtraCountFromSection(section)

	if slotIndex == 1 then
		return "gameRightPanel"
	end

	if slotIndex <= 1 + rightExtraCount then
		local extraIndex = slotIndex - 1

		if extraIndex == 1 then
			return "gameRightExtraPanel"
		end

		return "gameRightExtraPanel_" .. extraIndex
	end

	local leftSlotIndex = slotIndex - 1 - rightExtraCount

	if leftSlotIndex == 1 then
		return "gameLeftPanel"
	end

	local leftExtraIndex = leftSlotIndex - 1

	if leftExtraIndex == 1 then
		return "gameLeftExtraPanel"
	end

	return "gameLeftExtraPanel_" .. leftExtraIndex
end

function SidebarWidgetsPersistence.noteWidgetPlacement(widget)
	if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
		SidebarLayoutState.noteWidgetPlacement(widget)
	end
end

function SidebarWidgetsPersistence.clearRuntimeState()
	placementByWidgetId = {}

	if SidebarLayoutState and SidebarLayoutState.clear then
		SidebarLayoutState.clear()
	end
end

function SidebarWidgetsPersistence.getRuntimeWidgets()
	if SidebarLayoutState and SidebarLayoutState.getWidgets then
		return SidebarLayoutState.getWidgets()
	end

	return {}
end

function SidebarWidgetsPersistence.getWidgetPlacement(widgetId)
	return placementByWidgetId[widgetId]
end

function SidebarWidgetsPersistence.getWidgetPlacementByType(widgetType)
	if type(widgetType) ~= "string" then
		return nil
	end

	for widgetId, placement in pairs(placementByWidgetId) do
		if placement and placement.type == widgetType then
			return placement
		end
	end

	return nil
end

function SidebarWidgetsPersistence.hasWidgetType(widgetType)
	return SidebarWidgetsPersistence.getWidgetPlacementByType(widgetType) ~= nil
end

local function removeWidgetFromSavedOrder(widgetList, widgetType, instance)
	if type(widgetList) ~= "table" or not widgetType then
		return
	end

	local numericValue = tonumber(instance) or 0

	for entryIndex = #widgetList, 1, -1 do
		local entry = widgetList[entryIndex]

		if type(entry) == "table" and entry.type == widgetType and (tonumber(entry.instance) or 0) == numericValue then
			table.remove(widgetList, entryIndex)
		end
	end
end

function SidebarWidgetsPersistence.clearWidgetPlacementByType(widgetType)
	if type(widgetType) ~= "string" or widgetType == "" then
		return
	end

	local widgetIdsToClear = {}

	for key, entry in pairs(placementByWidgetId) do
		if entry and entry.type == widgetType then
			widgetIdsToClear[#widgetIdsToClear + 1] = key
		end
	end

	if widgetType == "battlePassInbox" then
		widgetIdsToClear[#widgetIdsToClear + 1] = "BattlePassInboxWindow"
	end

	for unusedValue, entry in ipairs(widgetIdsToClear) do
		SidebarWidgetsPersistence.clearWidgetPlacement(entry)
	end
end

function SidebarWidgetsPersistence.clearWidgetPlacement(widgetId)
	if type(widgetId) ~= "string" or widgetId == "" then
		return
	end

	placementByWidgetId[widgetId] = nil

	if SidebarLayoutState and SidebarLayoutState.widgets then
		SidebarLayoutState.widgets[widgetId] = nil
	end

	if not SidebarPersistence or not SidebarPersistence.active then
		return
	end

	if not SidebarLayoutState or not SidebarLayoutState.resolveTypeFromWidgetId then
		return
	end

	local widgetType, instance = SidebarLayoutState.resolveTypeFromWidgetId(widgetId)

	if not widgetType then
		return
	end

	local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

	if type(section) ~= "table" then
		return
	end

	if type(section.openWidgetsOrderPerSidebar) == "table" then
		for unusedValue, entry in ipairs(section.openWidgetsOrderPerSidebar) do
			removeWidgetFromSavedOrder(entry, widgetType, instance)
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		for unusedValue, entry in ipairs(section.openWidgetsOrderPerHorizontalSidebar) do
			removeWidgetFromSavedOrder(entry, widgetType, instance)
		end
	end

	SidebarWidgetsPersistence.buildPlacementMap(section)
end

local function ensureWidgetModuleLoaded(widgetType)
	local moduleName = moduleNameByWidgetType[widgetType]

	if not moduleName or not g_modules or not g_modules.ensureModuleLoaded then
		return
	end

	g_modules.ensureModuleLoaded(moduleName)
end

local function findPlacementWidget(widgetId, widgetType)
	if widgetType == "battlePassInbox" or widgetId == "BattlePassInboxWindow" then
		local inboxWindow = SidebarWidgetOptions and SidebarWidgetOptions.findBattlePassInboxWindow and SidebarWidgetOptions.findBattlePassInboxWindow()

		if inboxWindow and not inboxWindow:isDestroyed() then
			return inboxWindow
		end
	end

	local rootWidget = g_ui.getRootWidget()
	local widget = rootWidget and rootWidget:recursiveGetChildById(widgetId)

	if widget and not widget:isDestroyed() then
		return widget
	end

	local registryWidget = g_ui.loadedWidgetsById and g_ui.loadedWidgetsById[widgetId]

	if registryWidget and not registryWidget:isDestroyed() then
		return registryWidget
	end

	local moduleName = moduleNameByWidgetType[widgetType]

	if moduleName then
		local module = modules[moduleName]

		if module and module[widgetId] and not module[widgetId]:isDestroyed() then
			return module[widgetId]
		end
	end

	return nil
end

local function addWidgetsToPlacementMap(widgetList, parentId)
	if type(widgetList) ~= "table" or not parentId then
		return
	end

	for index, entry in ipairs(widgetList) do
		if type(entry) == "table" and type(entry.type) == "string" then
			ensureWidgetModuleLoaded(entry.type)

			local widgetId = resolveWidgetId(entry.type, entry.instance)

			if widgetId and not placementByWidgetId[widgetId] then
				placementByWidgetId[widgetId] = {
					parentId = parentId,
					index = index,
					type = entry.type
				}
			end

			if entry.type == "battlePassInbox" and not placementByWidgetId.BattlePassInboxWindow then
				placementByWidgetId.BattlePassInboxWindow = {
					parentId = parentId,
					index = index,
					type = entry.type
				}
			end
		end
	end
end

function SidebarWidgetsPersistence.buildPlacementMap(section)
	placementByWidgetId = {}

	if type(section) ~= "table" then
		return
	end

	if type(section.openWidgetsOrderPerSidebar) == "table" then
		for index, entry in ipairs(section.openWidgetsOrderPerSidebar) do
			addWidgetsToPlacementMap(entry, getParentIdForVerticalSlot(index, section))
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		local slotIndex = 0

		if section.rightHorizontalSidebar == true then
			slotIndex = slotIndex + 1

			addWidgetsToPlacementMap(section.openWidgetsOrderPerHorizontalSidebar[slotIndex], HORIZONTAL_PARENT_IDS[1])
		end

		if section.leftHorizontalSidebar == true then
			local leftHorizontalSlotIndex = slotIndex + 1

			addWidgetsToPlacementMap(section.openWidgetsOrderPerHorizontalSidebar[leftHorizontalSlotIndex], HORIZONTAL_PARENT_IDS[2])
		end
	end

	SidebarWidgetsPersistence.seedRegistryFromPlacement()
end

function SidebarWidgetsPersistence.seedRegistryFromPlacement()
	if not SidebarLayoutState then
		return
	end

	for key, entry in pairs(placementByWidgetId) do
		local widgetType, instance = SidebarLayoutState.resolveTypeFromWidgetId(key)

		if widgetType then
			SidebarLayoutState.widgets[key] = {
				type = widgetType,
				instance = instance or 0,
				parentId = SidebarLayoutState.canonicalParentId(entry.parentId),
				index = tonumber(entry.index) or 1
			}
		end
	end
end

local function ensureSidebarForParentId(parentId)
	if not parentId or not modules.client_options then
		return
	end

	local optionKey

	if parentId == "gameLeftPanel" then
		optionKey = "showLeftPanel"
	elseif parentId == "gameLeftTopPanel" then
		optionKey = "showLeftHorizontalPanel"
	elseif parentId == "gameRightTopPanel" then
		optionKey = "showRightHorizontalPanel"
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

		if (parentId == "gameLeftTopPanel" or parentId == "gameRightTopPanel") and modules.game_interface.updateHorizontalPanelWidths then
			modules.game_interface.updateHorizontalPanelWidths()
		end
	end
end

local function resolveParentPanel(parentId)
	if not parentId or not modules.game_interface then
		return nil
	end

	if parentId == "gameRightPanel" and modules.game_interface.getRightPanel then
		return modules.game_interface.getRightPanel()
	end

	if parentId == "gameLeftPanel" and modules.game_interface.getLeftPanel then
		return modules.game_interface.getLeftPanel()
	end

	if parentId == "gameRightTopPanel" and modules.game_interface.getRightTopPanel then
		return modules.game_interface.getRightTopPanel()
	end

	if parentId == "gameLeftTopPanel" and modules.game_interface.getLeftTopPanel then
		return modules.game_interface.getLeftTopPanel()
	end

	if parentId == "gameRightExtraPanel" or parentId:find("^gameRightExtraPanel") then
		local extraIndex = 1
		local numbered = parentId:match("^gameRightExtraPanel_(%d+)$")

		if numbered then
			extraIndex = tonumber(numbered)
		end

		if modules.game_interface.getRightExtraPanelByIndex then
			return modules.game_interface.getRightExtraPanelByIndex(extraIndex)
		end

		return modules.game_interface.getRightExtraPanel and modules.game_interface.getRightExtraPanel()
	end

	if parentId == "gameLeftExtraPanel" or parentId:find("^gameLeftExtraPanel") then
		local extraIndex = 1
		local numbered = parentId:match("^gameLeftExtraPanel_(%d+)$")

		if numbered then
			extraIndex = tonumber(numbered)
		end

		if modules.game_interface.getLeftExtraPanelByIndex then
			return modules.game_interface.getLeftExtraPanelByIndex(extraIndex)
		end

		return modules.game_interface.getLeftExtraPanel and modules.game_interface.getLeftExtraPanel()
	end

	local rootWidget = g_ui.getRootWidget()

	if not rootWidget then
		return nil
	end

	return rootWidget:recursiveGetChildById(parentId)
end

local function moveWidgetToSavedPlacement(widget, parentId, index)
	if not widget or widget:isDestroyed() then
		return false
	end

	ensureSidebarForParentId(parentId)

	local parent = resolveParentPanel(parentId)

	if not parent or parent:isDestroyed() then
		return false
	end

	local id = modules.game_interface and modules.game_interface.isGameSidePanelId and modules.game_interface.isGameSidePanelId(parent:getId())
	local isHorizontalSidebar = parentId == "gameLeftTopPanel" or parentId == "gameRightTopPanel"

	if not (parent:isVisible() or id and parent:isOn() or isHorizontalSidebar and parent:isOn()) then
		return false
	end

	local currentParent = widget:getParent()

	if currentParent and not currentParent:isDestroyed() and currentParent ~= parent then
		currentParent:removeChild(widget)
	end

	widget.miniLoaded = false
	widget.miniIndex = nil

	if parent:getClassName() == "UIMiniWindowContainer" and index and type(parent.scheduleInsert) == "function" then
		local numericValue = tonumber(index)

		widget.miniIndex = numericValue or index

		parent:scheduleInsert(widget, numericValue or index)
	elseif widget:getParent() ~= parent then
		parent:addChild(widget)
	end

	if parent:getClassName() == "UIMiniWindowContainer" then
		addEvent(function()
			if parent and not parent:isDestroyed() then
				parent:order()
			end
		end)
	end

	SidebarWidgetsPersistence.noteWidgetPlacement(widget)

	return true
end

function SidebarWidgetsPersistence.collectWidgetsManagerOptions()
	local options = {}

	if SidebarLayoutState and SidebarLayoutState.syncFromPanels then
		SidebarLayoutState.syncFromPanels()
	end

	if SidebarLayoutState and SidebarLayoutState.pruneUntrackedWidgets then
		SidebarLayoutState.pruneUntrackedWidgets()
	end

	if modules.client_options and modules.client_options.getOption then
		options.leftHorizontalSidebar = modules.client_options.getOption("showLeftHorizontalPanel") == true
		options.rightHorizontalSidebar = modules.client_options.getOption("showRightHorizontalPanel") == true
	end

	if modules.game_interface and modules.game_interface.countVisibleLeftSidebarSlots then
		options.leftSidebarCount = modules.game_interface.countVisibleLeftSidebarSlots()
	else
		options.leftSidebarCount = 0
	end

	if SidebarLayoutState and SidebarLayoutState.collectVerticalWidgetOrder then
		options.openWidgetsOrderPerSidebar = SidebarLayoutState.collectVerticalWidgetOrder()
	else
		options.openWidgetsOrderPerSidebar = {}
	end

	if SidebarLayoutState and SidebarLayoutState.collectHorizontalWidgetOrder then
		options.openWidgetsOrderPerHorizontalSidebar = SidebarLayoutState.collectHorizontalWidgetOrder()
	else
		options.openWidgetsOrderPerHorizontalSidebar = {}
	end

	return options
end

function SidebarWidgetsPersistence.applySidebarLayout(section)
	if type(section) ~= "table" then
		return
	end

	if section.leftHorizontalSidebar ~= nil and modules.client_options then
		modules.client_options.setOption("showLeftHorizontalPanel", section.leftHorizontalSidebar == true, true)
	end

	if section.rightHorizontalSidebar ~= nil and modules.client_options then
		modules.client_options.setOption("showRightHorizontalPanel", section.rightHorizontalSidebar == true, true)
	end

	local numericValue = tonumber(section.leftSidebarCount) or 0
	local leftExtraCount = math.max(0, numericValue - 1)
	local rightExtraCount = getRightExtraCountFromSection(section)

	if modules.client_options then
		modules.client_options.setOption("showLeftPanel", numericValue > 0, true)
	end

	if modules.game_interface and modules.game_interface.restoreSidebarColumnCounts then
		modules.game_interface.restoreSidebarColumnCounts(leftExtraCount, rightExtraCount)
	end
end

function SidebarWidgetsPersistence.applyWidgetPlacements()
	if table.empty(placementByWidgetId) then
		return true
	end

	if not g_ui.getRootWidget() then
		return false
	end

	local stillPending = false

	for key, entry in pairs(placementByWidgetId) do
		local widget = findPlacementWidget(key, entry.type)

		if widget and not widget:isDestroyed() then
			local parent = widget:getParent()
			local id = parent and parent:getId()

			if SidebarLayoutState and SidebarLayoutState.canonicalParentId(id) == SidebarLayoutState.canonicalParentId(entry.parentId) and parent and not parent:isDestroyed() then
				if parent:getClassName() == "UIMiniWindowContainer" and entry.index and type(parent.scheduleInsert) == "function" then
					local numericValue = tonumber(entry.index)

					if numericValue and widget.miniIndex ~= numericValue then
						widget.miniIndex = numericValue

						parent:scheduleInsert(widget, numericValue)
					end
				end

				if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
					SidebarLayoutState.noteWidgetPlacement(widget)
				end
			elseif not moveWidgetToSavedPlacement(widget, entry.parentId, entry.index) then
				stillPending = true
			end
		else
			local widgetType = entry.type or SidebarLayoutState and SidebarLayoutState.resolveTypeFromWidgetId(key)

			if widgetType == "battlePassInbox" and not battlePassInboxRequested then
				battlePassInboxRequested = true

				if g_game.sendBattlePassOpenInbox then
					g_game.sendBattlePassOpenInbox()
				end
			end

			if widgetType ~= "container" and widgetType ~= "battlePassInbox" then
				stillPending = true
			end
		end
	end

	if not stillPending and modules.game_interface and modules.game_interface.getMiniWindowSidebarPanelsInOrder then
		for unusedValue, entry in ipairs(modules.game_interface.getMiniWindowSidebarPanelsInOrder()) do
			if entry and not entry:isDestroyed() and entry.order then
				entry:order()
			end
		end
	end

	if not stillPending and modules.game_containers and modules.game_containers.scheduleContainersLayoutRestore then
		modules.game_containers.scheduleContainersLayoutRestore()
	end

	return not stillPending
end

function SidebarWidgetsPersistence.enforceLayoutClosedState()
	if not SidebarPersistence or not SidebarPersistence.active then
		return
	end

	local seen = {}

	for _ in pairs(placementByWidgetId) do
		seen[_] = true
	end

	if not modules.game_interface or not modules.game_interface.getMiniWindowSidebarPanelsInOrder then
		return
	end

	for unusedValue, panel in ipairs(modules.game_interface.getMiniWindowSidebarPanelsInOrder()) do
		if panel and not panel:isDestroyed() then
			for _, child in ipairs(panel:getChildren()) do
				if child.save and child.getId and not child:isDestroyed() then
					local id = child:getId()

					if SidebarLayoutState.resolveTypeFromWidgetId(id) and not seen[id] and child.close then
						child:close(true)
					end
				end
			end
		end
	end
end

local function applyFullOrderToPanel(parentId, widgetList)
	if not parentId or type(widgetList) ~= "table" or #widgetList == 0 then
		return
	end

	local rootWidget = g_ui.getRootWidget()

	if not rootWidget then
		return
	end

	local parent = resolveParentPanel(parentId)

	if not parent or parent:isDestroyed() then
		return
	end

	if parent:getClassName() ~= "UIMiniWindowContainer" then
		return
	end

	local orderedWidgets = {}

	for unusedValue, entry in ipairs(widgetList) do
		local widgetId = resolveWidgetId(entry.type, entry.instance)

		if widgetId then
			local widget = rootWidget:recursiveGetChildById(widgetId)

			if widget and not widget:isDestroyed() and widget:getParent() == parent then
				orderedWidgets[#orderedWidgets + 1] = widget
			end
		end
	end

	if #orderedWidgets == 0 then
		return
	end

	for saveIdx, targetWidget in ipairs(orderedWidgets) do
		local children = parent:getChildren()
		local saveCount = 0
		local slotRawIdx

		for i = 1, #children do
			if children[i] and children[i].save then
				saveCount = saveCount + 1

				if saveCount == saveIdx then
					slotRawIdx = i

					break
				end
			end
		end

		local targetRawIdx = slotRawIdx or parent:getChildCount()

		if parent:getChildIndex(targetWidget) ~= targetRawIdx then
			pcall(function()
				parent:moveChildToIndex(targetWidget, targetRawIdx)
			end)
		end
	end
end

local function applyAllPanelsOrder(section)
	if type(section) ~= "table" then
		return
	end

	if type(section.openWidgetsOrderPerSidebar) == "table" then
		for index, entry in ipairs(section.openWidgetsOrderPerSidebar) do
			if type(entry) == "table" and #entry > 0 then
				local parentId = getParentIdForVerticalSlot(index, section)

				if parentId then
					applyFullOrderToPanel(parentId, entry)
				end
			end
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		local slotIndex = 0

		if section.rightHorizontalSidebar == true then
			slotIndex = slotIndex + 1

			local widgetList = section.openWidgetsOrderPerHorizontalSidebar[slotIndex]

			if type(widgetList) == "table" and #widgetList > 0 then
				applyFullOrderToPanel(HORIZONTAL_PARENT_IDS[1], widgetList)
			end
		end

		if section.leftHorizontalSidebar == true then
			local slotIndex = slotIndex + 1
			local widgetList = section.openWidgetsOrderPerHorizontalSidebar[slotIndex]

			if type(widgetList) == "table" and #widgetList > 0 then
				applyFullOrderToPanel(HORIZONTAL_PARENT_IDS[2], widgetList)
			end
		end
	end
end

local function applySavedOrderToPanel(section)
	applyAllPanelsOrder(section)
end

function SidebarWidgetsPersistence.scheduleFullOrderRestore()
	if not isRestoringLoginOrder or not SidebarPersistence or not SidebarPersistence.active then
		return
	end

	if fullOrderRestoreEvent then
		removeEvent(fullOrderRestoreEvent)

		fullOrderRestoreEvent = nil
	end

	fullOrderRestoreEvent = scheduleEvent(function()
		fullOrderRestoreEvent = nil

		if not isRestoringLoginOrder then
			return
		end

		local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

		applyAllPanelsOrder(section)
	end, 150)
end

function SidebarWidgetsPersistence.finishLoginOrderRestore()
	if fullOrderRestoreEvent then
		removeEvent(fullOrderRestoreEvent)

		fullOrderRestoreEvent = nil
	end

	isRestoringLoginOrder = false
end

function SidebarWidgetsPersistence.isRestoringLoginOrder()
	return isRestoringLoginOrder == true
end

function SidebarWidgetsPersistence.applyAll()
	if not SidebarPersistence or not SidebarPersistence.active then
		return true
	end

	local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

	if type(section) ~= "table" then
		placementByWidgetId = {}

		return true
	end

	SidebarWidgetsPersistence.applySidebarLayout(section)
	SidebarWidgetsPersistence.buildPlacementMap(section)

	return SidebarWidgetsPersistence.applyWidgetPlacements()
end

local layoutRestoreAttempts = 0
local LAYOUT_RESTORE_MAX_ATTEMPTS = 30

function SidebarWidgetsPersistence.scheduleApply()
	if applyScheduled then
		return
	end

	applyScheduled = true

	local function attempt()
		applyScheduled = false
		layoutRestoreAttempts = layoutRestoreAttempts + 1

		local complete

		if layoutRestoreAttempts == 1 then
			complete = SidebarWidgetsPersistence.applyAll()
		else
			complete = SidebarWidgetsPersistence.applyWidgetPlacements()
		end

		if not complete and layoutRestoreAttempts < LAYOUT_RESTORE_MAX_ATTEMPTS then
			applyScheduled = true

			scheduleEvent(function()
				attempt()
			end, 50)
		else
			if complete then
				layoutRestoreAttempts = 0
			end

			SidebarWidgetsPersistence.enforceLayoutClosedState()

			if SidebarWidgetOptionsPersistence and SidebarWidgetOptionsPersistence.scheduleApply then
				SidebarWidgetOptionsPersistence.scheduleApply()
			end
		end
	end

	addEvent(attempt)
end

local function assignOrderedSection(section, data)
	for i = 1, #SECTION_FIELD_ORDER do
		local key = SECTION_FIELD_ORDER[i]
		local value = data[key]

		if value ~= nil then
			section[key] = value
		end
	end

	section._jsonKeyOrder = SECTION_FIELD_ORDER
end

function SidebarWidgetsPersistence.register()
	if not SidebarPersistence or not SidebarPersistence.registerProvider then
		return
	end

	SidebarPersistence.registerProvider(SECTION_WIDGETS_MANAGER, {
		collect = function(section)
			local data = SidebarWidgetsPersistence.collectWidgetsManagerOptions()

			if type(data) ~= "table" then
				return
			end

			assignOrderedSection(section, data)
		end
	})
end

connect(g_game, {
	onGameEnd = function()
		if fullOrderRestoreEvent then
			removeEvent(fullOrderRestoreEvent)

			fullOrderRestoreEvent = nil
		end

		isRestoringLoginOrder = false
	end,
	onGameStart = function()
		layoutRestoreAttempts = 0
		battlePassInboxRequested = false

		SidebarWidgetsPersistence.clearRuntimeState()

		isRestoringLoginOrder = true

		local panels = {}

		if modules.game_interface then
			if modules.game_interface.getRightPanel then
				panels[#panels + 1] = modules.game_interface.getRightPanel()
			end

			if modules.game_interface.getMiniWindowSidebarPanelsInOrder then
				for unusedValue, entry in ipairs(modules.game_interface.getMiniWindowSidebarPanelsInOrder()) do
					panels[#panels + 1] = entry
				end
			end
		end

		local seen = {}

		for unusedValue, entry in ipairs(panels) do
			if entry and not entry:isDestroyed() and not seen[entry] then
				seen[entry] = true

				for unusedValue, child in ipairs(entry:getChildren()) do
					if child and child.save then
						child.miniIndex = nil
						child.miniLoaded = nil
					end
				end

				if type(entry.scheduledWidgets) == "table" then
					entry.scheduledWidgets = {}
				end
			end
		end

		local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

		if type(section) == "table" then
			SidebarWidgetsPersistence.applySidebarLayout(section)
			SidebarWidgetsPersistence.buildPlacementMap(section)
		end

		if SidebarWidgetsPersistence.applyWidgetPlacements() then
			layoutRestoreAttempts = 0

			SidebarWidgetsPersistence.enforceLayoutClosedState()

			local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

			applySavedOrderToPanel(section)
			addEvent(function()
				if SidebarWidgetOptionsPersistence then
					SidebarWidgetOptionsPersistence.applyAll()
					SidebarWidgetOptionsPersistence.syncAllButtons()

					if modules.game_containers and modules.game_containers.restoreAllContainerLayoutsNow then
						modules.game_containers.restoreAllContainerLayoutsNow()
					end

					local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

					applyAllPanelsOrder(section)
					scheduleEvent(function()
						if SidebarPersistence and SidebarPersistence.active and isRestoringLoginOrder then
							local s = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

							applyAllPanelsOrder(s)
						end

						SidebarWidgetsPersistence.finishLoginOrderRestore()
					end, 500)
				else
					SidebarWidgetsPersistence.finishLoginOrderRestore()
				end
			end)
		else
			SidebarWidgetsPersistence.scheduleApply()
			scheduleEvent(function()
				SidebarWidgetsPersistence.finishLoginOrderRestore()
			end, 2000)
		end
	end
})
connect(Container, {
	onOpen = function()
		SidebarWidgetsPersistence.scheduleFullOrderRestore()
	end
})
SidebarWidgetsPersistence.register()
