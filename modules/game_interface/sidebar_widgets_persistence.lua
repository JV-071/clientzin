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
local WIDGET_TYPE_TO_ID = false
local var_0_7 = false
local var_0_8 = {
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
local var_0_9 = {
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
		local var_1_0 = SidebarWidgetOptions and SidebarWidgetOptions.findBattlePassInboxWindow and SidebarWidgetOptions.findBattlePassInboxWindow()

		if var_1_0 and var_1_0.getId then
			return var_1_0:getId()
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

	local localId = var_0_8[widgetType]

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

function SidebarWidgetsPersistence.getWidgetPlacementByType(arg_8_0)
	if type(arg_8_0) ~= "string" then
		return nil
	end

	for widgetId, placement in pairs(placementByWidgetId) do
		if placement and placement.type == arg_8_0 then
			return placement
		end
	end

	return nil
end

function SidebarWidgetsPersistence.hasWidgetType(arg_9_0)
	return SidebarWidgetsPersistence.getWidgetPlacementByType(arg_9_0) ~= nil
end

local function var_0_13(arg_10_0, arg_10_1, arg_10_2)
	if type(arg_10_0) ~= "table" or not arg_10_1 then
		return
	end

	local numericValue = tonumber(arg_10_2) or 0

	for iter_10_0 = #arg_10_0, 1, -1 do
		local var_10_1 = arg_10_0[iter_10_0]

		if type(var_10_1) == "table" and var_10_1.type == arg_10_1 and (tonumber(var_10_1.instance) or 0) == numericValue then
			table.remove(arg_10_0, iter_10_0)
		end
	end
end

function SidebarWidgetsPersistence.clearWidgetPlacementByType(parent)
	if type(parent) ~= "string" or parent == "" then
		return
	end

	local var_11_0 = {}

	for key, entry in pairs(placementByWidgetId) do
		if entry and entry.type == parent then
			var_11_0[#var_11_0 + 1] = key
		end
	end

	if parent == "battlePassInbox" then
		var_11_0[#var_11_0 + 1] = "BattlePassInboxWindow"
	end

	for unusedValue, entry in ipairs(var_11_0) do
		SidebarWidgetsPersistence.clearWidgetPlacement(entry)
	end
end

function SidebarWidgetsPersistence.clearWidgetPlacement(arg_12_0)
	if type(arg_12_0) ~= "string" or arg_12_0 == "" then
		return
	end

	placementByWidgetId[arg_12_0] = nil

	if SidebarLayoutState and SidebarLayoutState.widgets then
		SidebarLayoutState.widgets[arg_12_0] = nil
	end

	if not SidebarPersistence or not SidebarPersistence.active then
		return
	end

	if not SidebarLayoutState or not SidebarLayoutState.resolveTypeFromWidgetId then
		return
	end

	local var_12_0, var_12_1 = SidebarLayoutState.resolveTypeFromWidgetId(arg_12_0)

	if not var_12_0 then
		return
	end

	local section = SidebarPersistence.getSection(SECTION_WIDGETS_MANAGER)

	if type(section) ~= "table" then
		return
	end

	if type(section.openWidgetsOrderPerSidebar) == "table" then
		for unusedValue, entry in ipairs(section.openWidgetsOrderPerSidebar) do
			var_0_13(entry, var_12_0, var_12_1)
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		for unusedValue, entry in ipairs(section.openWidgetsOrderPerHorizontalSidebar) do
			var_0_13(entry, var_12_0, var_12_1)
		end
	end

	SidebarWidgetsPersistence.buildPlacementMap(section)
end

local function var_0_14(arg_13_0)
	local var_13_0 = var_0_9[arg_13_0]

	if not var_13_0 or not g_modules or not g_modules.ensureModuleLoaded then
		return
	end

	g_modules.ensureModuleLoaded(var_13_0)
end

local function var_0_15(arg_14_0, arg_14_1)
	if arg_14_1 == "battlePassInbox" or arg_14_0 == "BattlePassInboxWindow" then
		local var_14_0 = SidebarWidgetOptions and SidebarWidgetOptions.findBattlePassInboxWindow and SidebarWidgetOptions.findBattlePassInboxWindow()

		if var_14_0 and not var_14_0:isDestroyed() then
			return var_14_0
		end
	end

	local rootWidget = g_ui.getRootWidget()
	local var_14_2 = rootWidget and rootWidget:recursiveGetChildById(arg_14_0)

	if var_14_2 and not var_14_2:isDestroyed() then
		return var_14_2
	end

	local var_14_3 = g_ui.loadedWidgetsById and g_ui.loadedWidgetsById[arg_14_0]

	if var_14_3 and not var_14_3:isDestroyed() then
		return var_14_3
	end

	local var_14_4 = var_0_9[arg_14_1]

	if var_14_4 then
		local var_14_5 = modules[var_14_4]

		if var_14_5 and var_14_5[arg_14_0] and not var_14_5[arg_14_0]:isDestroyed() then
			return var_14_5[arg_14_0]
		end
	end

	return nil
end

local function var_0_16(arg_15_0, arg_15_1)
	if type(arg_15_0) ~= "table" or not arg_15_1 then
		return
	end

	for index, entry in ipairs(arg_15_0) do
		if type(entry) == "table" and type(entry.type) == "string" then
			var_0_14(entry.type)

			local var_15_0 = resolveWidgetId(entry.type, entry.instance)

			if var_15_0 and not placementByWidgetId[var_15_0] then
				placementByWidgetId[var_15_0] = {
					parentId = arg_15_1,
					index = index,
					type = entry.type
				}
			end

			if entry.type == "battlePassInbox" and not placementByWidgetId.BattlePassInboxWindow then
				placementByWidgetId.BattlePassInboxWindow = {
					parentId = arg_15_1,
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
			var_0_16(entry, getParentIdForVerticalSlot(index, section))
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		local var_16_0 = 0

		if section.rightHorizontalSidebar == true then
			var_16_0 = var_16_0 + 1

			var_0_16(section.openWidgetsOrderPerHorizontalSidebar[var_16_0], HORIZONTAL_PARENT_IDS[1])
		end

		if section.leftHorizontalSidebar == true then
			local var_16_1 = var_16_0 + 1

			var_0_16(section.openWidgetsOrderPerHorizontalSidebar[var_16_1], HORIZONTAL_PARENT_IDS[2])
		end
	end

	SidebarWidgetsPersistence.seedRegistryFromPlacement()
end

function SidebarWidgetsPersistence.seedRegistryFromPlacement()
	if not SidebarLayoutState then
		return
	end

	for key, entry in pairs(placementByWidgetId) do
		local var_17_0, var_17_1 = SidebarLayoutState.resolveTypeFromWidgetId(key)

		if var_17_0 then
			SidebarLayoutState.widgets[key] = {
				type = var_17_0,
				instance = var_17_1 or 0,
				parentId = SidebarLayoutState.canonicalParentId(entry.parentId),
				index = tonumber(entry.index) or 1
			}
		end
	end
end

local function var_0_17(parentId)
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

local function var_0_18(parentId)
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

local function var_0_19(arg_20_0, arg_20_1, arg_20_2)
	if not arg_20_0 or arg_20_0:isDestroyed() then
		return false
	end

	var_0_17(arg_20_1)

	local parent = var_0_18(arg_20_1)

	if not parent or parent:isDestroyed() then
		return false
	end

	local id = modules.game_interface and modules.game_interface.isGameSidePanelId and modules.game_interface.isGameSidePanelId(parent:getId())
	local var_20_2 = arg_20_1 == "gameLeftTopPanel" or arg_20_1 == "gameRightTopPanel"

	if not (parent:isVisible() or id and parent:isOn() or var_20_2 and parent:isOn()) then
		return false
	end

	local var_20_3 = arg_20_0:getParent()

	if var_20_3 and not var_20_3:isDestroyed() and var_20_3 ~= parent then
		var_20_3:removeChild(arg_20_0)
	end

	arg_20_0.miniLoaded = false
	arg_20_0.miniIndex = nil

	if parent:getClassName() == "UIMiniWindowContainer" and arg_20_2 and type(parent.scheduleInsert) == "function" then
		local numericValue = tonumber(arg_20_2)

		arg_20_0.miniIndex = numericValue or arg_20_2

		parent:scheduleInsert(arg_20_0, numericValue or arg_20_2)
	elseif arg_20_0:getParent() ~= parent then
		parent:addChild(arg_20_0)
	end

	if parent:getClassName() == "UIMiniWindowContainer" then
		addEvent(function()
			if parent and not parent:isDestroyed() then
				parent:order()
			end
		end)
	end

	SidebarWidgetsPersistence.noteWidgetPlacement(arg_20_0)

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
	local var_23_1 = math.max(0, numericValue - 1)
	local var_23_2 = getRightExtraCountFromSection(section)

	if modules.client_options then
		modules.client_options.setOption("showLeftPanel", numericValue > 0, true)
	end

	if modules.game_interface and modules.game_interface.restoreSidebarColumnCounts then
		modules.game_interface.restoreSidebarColumnCounts(var_23_1, var_23_2)
	end
end

function SidebarWidgetsPersistence.applyWidgetPlacements()
	if table.empty(placementByWidgetId) then
		return true
	end

	if not g_ui.getRootWidget() then
		return false
	end

	local var_24_0 = false

	for key, entry in pairs(placementByWidgetId) do
		local var_24_1 = var_0_15(key, entry.type)

		if var_24_1 and not var_24_1:isDestroyed() then
			local parent = var_24_1:getParent()
			local id = parent and parent:getId()

			if SidebarLayoutState and SidebarLayoutState.canonicalParentId(id) == SidebarLayoutState.canonicalParentId(entry.parentId) and parent and not parent:isDestroyed() then
				if parent:getClassName() == "UIMiniWindowContainer" and entry.index and type(parent.scheduleInsert) == "function" then
					local numericValue = tonumber(entry.index)

					if numericValue and var_24_1.miniIndex ~= numericValue then
						var_24_1.miniIndex = numericValue

						parent:scheduleInsert(var_24_1, numericValue)
					end
				end

				if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
					SidebarLayoutState.noteWidgetPlacement(var_24_1)
				end
			elseif not var_0_19(var_24_1, entry.parentId, entry.index) then
				var_24_0 = true
			end
		else
			local var_24_5 = entry.type or SidebarLayoutState and SidebarLayoutState.resolveTypeFromWidgetId(key)

			if var_24_5 == "battlePassInbox" and not var_0_7 then
				var_0_7 = true

				if g_game.sendBattlePassOpenInbox then
					g_game.sendBattlePassOpenInbox()
				end
			end

			if var_24_5 ~= "container" and var_24_5 ~= "battlePassInbox" then
				var_24_0 = true
			end
		end
	end

	if not var_24_0 and modules.game_interface and modules.game_interface.getMiniWindowSidebarPanelsInOrder then
		for unusedValue, entry in ipairs(modules.game_interface.getMiniWindowSidebarPanelsInOrder()) do
			if entry and not entry:isDestroyed() and entry.order then
				entry:order()
			end
		end
	end

	if not var_24_0 and modules.game_containers and modules.game_containers.scheduleContainersLayoutRestore then
		modules.game_containers.scheduleContainersLayoutRestore()
	end

	return not var_24_0
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

local function var_0_20(arg_26_0, arg_26_1)
	if not arg_26_0 or type(arg_26_1) ~= "table" or #arg_26_1 == 0 then
		return
	end

	local rootWidget = g_ui.getRootWidget()

	if not rootWidget then
		return
	end

	local parent = var_0_18(arg_26_0)

	if not parent or parent:isDestroyed() then
		return
	end

	if parent:getClassName() ~= "UIMiniWindowContainer" then
		return
	end

	local var_26_2 = {}

	for unusedValue, entry in ipairs(arg_26_1) do
		local var_26_3 = resolveWidgetId(entry.type, entry.instance)

		if var_26_3 then
			local var_26_4 = rootWidget:recursiveGetChildById(var_26_3)

			if var_26_4 and not var_26_4:isDestroyed() and var_26_4:getParent() == parent then
				var_26_2[#var_26_2 + 1] = var_26_4
			end
		end
	end

	if #var_26_2 == 0 then
		return
	end

	for iter_26_2, targetWidget in ipairs(var_26_2) do
		local children = parent:getChildren()
		local var_26_6 = 0
		local var_26_7

		for iter_26_4 = 1, #children do
			if children[iter_26_4] and children[iter_26_4].save then
				var_26_6 = var_26_6 + 1

				if var_26_6 == iter_26_2 then
					var_26_7 = iter_26_4

					break
				end
			end
		end

		local targetRawIdx = var_26_7 or parent:getChildCount()

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
				local var_28_0 = getParentIdForVerticalSlot(index, section)

				if var_28_0 then
					var_0_20(var_28_0, entry)
				end
			end
		end
	end

	if type(section.openWidgetsOrderPerHorizontalSidebar) == "table" then
		local var_28_1 = 0

		if section.rightHorizontalSidebar == true then
			var_28_1 = var_28_1 + 1

			local var_28_2 = section.openWidgetsOrderPerHorizontalSidebar[var_28_1]

			if type(var_28_2) == "table" and #var_28_2 > 0 then
				var_0_20(HORIZONTAL_PARENT_IDS[1], var_28_2)
			end
		end

		if section.leftHorizontalSidebar == true then
			local var_28_3 = var_28_1 + 1
			local var_28_4 = section.openWidgetsOrderPerHorizontalSidebar[var_28_3]

			if type(var_28_4) == "table" and #var_28_4 > 0 then
				var_0_20(HORIZONTAL_PARENT_IDS[2], var_28_4)
			end
		end
	end
end

local function applySavedOrderToPanel(section)
	applyAllPanelsOrder(section)
end

function SidebarWidgetsPersistence.scheduleFullOrderRestore()
	if not WIDGET_TYPE_TO_ID or not SidebarPersistence or not SidebarPersistence.active then
		return
	end

	if fullOrderRestoreEvent then
		removeEvent(fullOrderRestoreEvent)

		fullOrderRestoreEvent = nil
	end

	fullOrderRestoreEvent = scheduleEvent(function()
		fullOrderRestoreEvent = nil

		if not WIDGET_TYPE_TO_ID then
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

	WIDGET_TYPE_TO_ID = false
end

function SidebarWidgetsPersistence.isRestoringLoginOrder()
	return WIDGET_TYPE_TO_ID == true
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

		WIDGET_TYPE_TO_ID = false
	end,
	onGameStart = function()
		layoutRestoreAttempts = 0
		var_0_7 = false

		SidebarWidgetsPersistence.clearRuntimeState()

		WIDGET_TYPE_TO_ID = true

		local var_42_0 = {}

		if modules.game_interface then
			if modules.game_interface.getRightPanel then
				var_42_0[#var_42_0 + 1] = modules.game_interface.getRightPanel()
			end

			if modules.game_interface.getMiniWindowSidebarPanelsInOrder then
				for unusedValue, entry in ipairs(modules.game_interface.getMiniWindowSidebarPanelsInOrder()) do
					var_42_0[#var_42_0 + 1] = entry
				end
			end
		end

		local var_42_1 = {}

		for unusedValue, entry in ipairs(var_42_0) do
			if entry and not entry:isDestroyed() and not var_42_1[entry] then
				var_42_1[entry] = true

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
						if SidebarPersistence and SidebarPersistence.active and WIDGET_TYPE_TO_ID then
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
