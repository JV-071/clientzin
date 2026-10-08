local unusedValue
local chaseModeBox
local optionsAmount = 0
local specialsAmount = 0
local storeAmount = 0
local chaseModeRadioGroup
local buttonConfigs = {}
local buttonOrder = {}

local function stripHotkey(text)
	if type(text) ~= "string" then
		return text
	end

	return text:gsub("%s*%b()$", "")
end

local function onShortcutsSidebarMousePress(_, mousePos, mouseButton)
	if mouseButton == MouseRightButton then
		if modules.client_options and modules.client_options.openManageShortcutsMenu then
			modules.client_options.openManageShortcutsMenu(mousePos)
		end

		return true
	end
end

local function bindShortcutsSidebarContextMenuRecursive(widget)
	if not widget or widget:isDestroyed() then
		return
	end

	widget.onMousePress = onShortcutsSidebarMousePress

	for _, child in pairs(widget:getChildren()) do
		bindShortcutsSidebarContextMenuRecursive(child)
	end
end

function refreshShortcutsSidebarContextMenu()
	if not optionsController or not optionsController.ui or not optionsController.ui.onPanel then
		return
	end

	local optionsPanel = optionsController.ui.onPanel.options

	if not optionsPanel or optionsPanel:isDestroyed() then
		return
	end

	optionsPanel:setPhantom(false)
	bindShortcutsSidebarContextMenuRecursive(optionsPanel)
end

ControlButtonNames = {
	imbuementTrackerButton = "Imbuement Tracker",
	bosstiarytrackerButton = "Bosstiary Tracker",
	preyButton = "Prey Dialog",
	bosstiary = "Bosstiary",
	reportButton = "Report",
	bossSlot = "Boss Slots",
	questLogButton = "Quest Log",
	trackerButton = "Bestiary Tracker",
	rewardWall = "Reward Wall",
	battleButton = "Battle List",
	eventScheduleButton = "Event Schedule",
	analyticsSelectorWidget = "Analytics Selector",
	skillsButton = "Skills",
	questTrackerButton = "Quest Tracker",
	friendsDialog = "Social",
	partyWidget = "Party List",
	spellListWidget = "Spell List",
	manageShortcuts = "Manage Shortcuts",
	taskBoard = "Task Board",
	preyTrackerButton = "Kill Tracker",
	unjustifiedPointsButton = "Unjustified Points",
	playerGuide = "Player Guide",
	vipListButton = "VIP List",
	highscoresButton = "Highscores",
	ProciencyButton = "Weapon Proficiency",
	helperDialog = "Helper",
	wheelButton = "Wheel of Destiny",
	forgeButton = "Exaltation Forge",
	CyclopediaButton = "Cyclopedia",
	compendiumDialog = "Compendium"
}

local PANEL_CONSTANTS = {
	MULTI_STORE_HEIGHT = 20,
	HEIGHT_EXTRA_ONPANEL = -19,
	HEIGHT_EXTRA_SHRINK = -14,
	ICON_HEIGHT = 18,
	ICON_WIDTH = 18,
	MAIN_RIGHT_PANEL_EXTRA_HEIGHT = 3,
	MAX_ICONS_PER_ROW = {
		STORE = 1,
		SPECIALS = 2,
		OPTIONS = 5
	}
}
local DEFAULT_SHORTCUT_ORDER = {
	"skillsButton",
	"battleButton",
	"spellListWidget",
	"vipListButton",
	"lenshelpFunction",
	"questLogButton",
	"compendiumDialog",
	"CyclopediaButton",
	"highscoresButton",
	"playerGuide",
	"manageShortcuts",
	"partyWidget",
	"wheelButton",
	"questTrackerButton",
	"unjustifiedPointsButton",
	"preyButton",
	"preyTrackerButton",
	"rewardWall",
	"analyticsSelectorWidget",
	"bosstiary",
	"bossSlot",
	"bosstiarytrackerButton",
	"trackerButton",
	"imbuementTrackerButton",
	"ProciencyButton",
	"forgeButton",
	"friendsDialog",
	"taskBoard",
	"eventScheduleButton",
	"reportButton"
}
local optionsShrink = false
local var_0_14 = "control_buttons"
local var_0_15 = {
	helperButton = true
}

local function calculatePanelHeight(panel, max_icons_per_row)
	local icon_count = 0

	for _, icon in ipairs(panel:getChildren()) do
		if icon:isVisible() then
			icon_count = icon_count + 1
		end
	end

	local rows = math.ceil(icon_count / max_icons_per_row)
	local height = rows * PANEL_CONSTANTS.ICON_HEIGHT + rows * 3

	if rows > 2 then
		height = height + rows - 2
	end

	return height, icon_count
end

function reloadMainPanelSizes()
	local main_panel = modules.game_interface.getMainRightPanel()
	local right_panel = modules.game_interface.getRightPanel()

	if not main_panel or not right_panel then
		return
	end

	local total_height = 1

	for _, panel in ipairs(main_panel:getChildren()) do
		if panel.panelHeight ~= nil then
			if panel:isVisible() then
				panel:setHeight(panel.panelHeight)

				total_height = total_height + panel.panelHeight

				if panel:getId() == "mainoptionspanel" then
					local store_panel = panel.onPanel.store
					local _, store_count = calculatePanelHeight(store_panel, PANEL_CONSTANTS.MAX_ICONS_PER_ROW.STORE)
					local store_height = 0

					if store_count > 0 then
						store_height = store_count * PANEL_CONSTANTS.MULTI_STORE_HEIGHT

						if store_count > 1 then
							store_height = store_height + (store_count - 1) * 4
						end
					end

					store_panel:setHeight(store_height)

					if panel:isOn() then
						local options = optionsController.ui.onPanel.options

						if options then
							options:setMarginTop(5)
						end

						local var_6_8, unusedValue = calculatePanelHeight(options, PANEL_CONSTANTS.MAX_ICONS_PER_ROW.OPTIONS)
						local specials = optionsController.ui.onPanel.specials
						local var_6_11, unusedValue = calculatePanelHeight(specials, PANEL_CONSTANTS.MAX_ICONS_PER_ROW.SPECIALS)
						local optionsSeparator = optionsController.ui.onPanel.optionsSeparator
						local controls_height = math.max(var_6_8, var_6_11)

						options:setHeight(controls_height)
						specials:setHeight(controls_height)

						if optionsSeparator then
							optionsSeparator:setHeight(controls_height)
						end

						local right_column_height = store_height + options:getMarginTop() + controls_height
						local combined_height = math.max(store_height, right_column_height) + PANEL_CONSTANTS.HEIGHT_EXTRA_ONPANEL

						panel:setHeight(combined_height + panel.panelHeight)

						total_height = total_height + combined_height
					else
						local combined_height = store_height + PANEL_CONSTANTS.HEIGHT_EXTRA_SHRINK - 4

						panel:setHeight(combined_height + panel.panelHeight)

						total_height = total_height + combined_height
					end
				end
			else
				panel:setHeight(0)
			end
		end
	end

	main_panel:setHeight(total_height + PANEL_CONSTANTS.MAIN_RIGHT_PANEL_EXTRA_HEIGHT)

	if modules.game_interface.syncMainRightPanelClearance then
		modules.game_interface.syncMainRightPanelClearance()
	end

	right_panel:fitAll()
end

local function var_0_17(arg_7_0)
	if not arg_7_0 or arg_7_0:isDestroyed() then
		return false
	end

	if arg_7_0.isExplicitlyVisible and not arg_7_0:isExplicitlyVisible() then
		return false
	end

	local id = arg_7_0:getId() or ""

	if id:find("Highlight") or id:find("highlight") then
		return true
	end

	local var_7_1, var_7_2 = pcall(function()
		return arg_7_0:getImageSource()
	end)

	return var_7_1 and type(var_7_2) == "string" and var_7_2:find("button%-highlight") ~= nil
end

local function var_0_18()
	if not optionsController or not optionsController.ui or not optionsController.ui.onPanel then
		return false
	end

	local options = optionsController.ui.onPanel.options

	if not options or options:isDestroyed() then
		return false
	end

	for unusedValue, child in ipairs(options:getChildren()) do
		if child and not child:isDestroyed() then
			for unusedValue, child in ipairs(child:getChildren()) do
				if var_0_17(child) then
					return true
				end
			end
		end
	end

	return false
end

function refreshOffPanelResizerHighlight()
	if not optionsController or not optionsController.ui or not optionsController.ui.offPanel then
		return
	end

	local offPanelResizerHighlight = optionsController.ui.offPanel.offPanelResizerHighlight or optionsController.ui.offPanel:recursiveGetChildById("offPanelResizerHighlight")

	if not offPanelResizerHighlight or offPanelResizerHighlight:isDestroyed() then
		return
	end

	offPanelResizerHighlight:setVisible(optionsShrink and var_0_18())
end

local function refreshOptionsSizes()
	local ui = optionsController.ui
	local offBtn = ui.offPanel:recursiveGetChildById("offOptionsSizeButton")
	local resizer = ui.onPanel:recursiveGetChildById("resizer")
	local options = ui.onPanel:recursiveGetChildById("options")
	local specials = ui.onPanel:recursiveGetChildById("specials")
	local optionsSeparator = ui.onPanel:recursiveGetChildById("optionsSeparator")

	ui.onPanel:show()

	if optionsShrink then
		ui:setOn(false)
		ui.offPanel:show()

		if options then
			options:hide()
		end

		if specials then
			specials:hide()
		end

		if optionsSeparator then
			optionsSeparator:hide()
		end

		if resizer then
			resizer:hide()
			resizer:setImageClip("0 40 42 20")
		end

		if offBtn then
			offBtn:setImageClip("0 0 42 20")
		end
	else
		ui:setOn(true)
		ui.offPanel:hide()

		if options then
			options:show()
		end

		if specials then
			specials:show()
		end

		if optionsSeparator then
			optionsSeparator:show()
		end

		if resizer then
			resizer:show()
			resizer:setImageClip("0 40 42 20")
		end

		if offBtn then
			offBtn:setImageClip("0 0 42 20")
		end
	end

	refreshOffPanelResizerHighlight()
	reloadMainPanelSizes()
end

local function createButton_large(id, description, image, callback, panelId, front)
	local panel = optionsController.ui.onPanel[panelId or "store"]

	storeAmount = storeAmount + 1

	local button = panel:getChildById(id)

	if not button then
		button = g_ui.createWidget("largeToggleButton")

		if front then
			panel:insertChild(1, button)
		else
			panel:addChild(button)
		end
	end

	button:setId(id)
	button:setTooltip(description)
	button:setImageSource(image)
	button:setImageClip("0 0 108 20")

	function button.onMouseRelease(widget, mousePos, mouseButton)
		if widget:containsPoint(mousePos) and mouseButton == MouseLeftButton then
			callback()

			return true
		end
	end

	reloadMainPanelSizes()

	return button
end

local function doFullSync()
	if not g_game.isOnline() then
		return
	end

	local optionsPanel = optionsController.ui.onPanel.options

	if not optionsPanel then
		return
	end

	for _, button in ipairs(optionsPanel:getChildren()) do
		local id = button:getId()

		if id then
			if not buttonConfigs[id] then
				local visible = table.find(buttonOrder, id) ~= nil

				buttonConfigs[id] = {
					visible = visible,
					tooltip = ControlButtonNames[id] or stripHotkey(button:getTooltip()) or id
				}
			end

			button:setVisible(buttonConfigs[id].visible)

			if buttonConfigs[id].visible and not table.find(buttonOrder, id) then
				table.insert(buttonOrder, id)
			end
		end
	end

	reorderButtons()
	reorderMainPanelSpecialButtons()

	if modules.client_topmenu and modules.client_topmenu.reorderTopRightToggleButtons then
		modules.client_topmenu.reorderTopRightToggleButtons()
	end

	reloadMainPanelSizes()

	if modules.client_options and modules.client_options.refreshShortcuts then
		modules.client_options.refreshShortcuts()
	end

	refreshShortcutsSidebarContextMenu()
end

local pendingFullSync = false

local function scheduleFullSync()
	if pendingFullSync or not g_game.isOnline() then
		return
	end

	pendingFullSync = true

	scheduleEvent(function()
		pendingFullSync = false

		doFullSync()
	end, 0)
end

local pendingRefreshOptionsSizes = false

local function scheduleRefreshOptionsSizes()
	if pendingRefreshOptionsSizes then
		return
	end

	pendingRefreshOptionsSizes = true

	addEvent(function()
		pendingRefreshOptionsSizes = false

		refreshOptionsSizes()
	end)
end

local function createButton(id, description, image, callback, special, front, index, styleName)
	local panel

	if special then
		panel = optionsController.ui.onPanel.specials
		specialsAmount = specialsAmount + 1
	else
		panel = optionsController.ui.onPanel.options
		optionsAmount = optionsAmount + 1
	end

	local button = panel:getChildById(id)

	if not button then
		button = g_ui.createWidget(styleName or "MainToggleButton")

		if front then
			panel:insertChild(1, button)
		else
			panel:addChild(button)
		end
	end

	button:setId(id)
	button:setTooltip(description)
	button:setSize("20 20")
	button:setImageSource(image)
	button:setImageClip("0 0 20 20")

	button.mainPanelCallback = callback

	function button.onMouseRelease(widget, mousePos, mouseButton)
		if widget:containsPoint(mousePos) and mouseButton == MouseLeftButton then
			callback()

			return true
		end
	end

	if not button.index and type(index) == "number" then
		button.index = index or 1000
	end

	if not special then
		button:setVisible(false)

		if buttonConfigs[id] then
			button:setVisible(buttonConfigs[id].visible)
		end

		refreshShortcutsSidebarContextMenu()
	end

	if g_game.isOnline() then
		scheduleFullSync()
	else
		scheduleRefreshOptionsSizes()
	end

	return button
end

optionsController = Controller:new()

optionsController:setUI("mainoptionspanel", modules.game_interface.getMainRightPanel())

function optionsController.onInit(unusedArgument)
	createButton_large("Store shop", tr("Open the Store"), "/images/options/store_large", toggleStore, "store", false)
	refreshShortcutsSidebarContextMenu()
end

function toggleStore()
	if modules.game_store and modules.game_store.toggle then
		modules.game_store.toggle()
	end
end

function optionsController.onTerminate(self)
	return
end

function optionsController.onGameStart(unusedArgument)
	local config = loadButtonConfig()

	buttonConfigs = {}

	applyShortcutOrder(config.shortcutOrder)

	if SidebarPersistence and SidebarPersistence.getSection then
		local panelOptions = SidebarPersistence.getSection("sidebarPanelsOptions")

		if type(panelOptions) == "table" and panelOptions.controlButtonsVisible ~= nil then
			optionsShrink = panelOptions.controlButtonsVisible ~= true
		end
	end

	refreshOptionsSizes()
	modules.game_interface.setupOptionsMainButton()
	modules.client_options.setupOptionsMainButton()

	local getOptionsPanel = optionsController.ui.onPanel.options
	local children = getOptionsPanel:getChildren()

	table.sort(children, function(a, b)
		return (a.index or 1000) < (b.index or 1000)
	end)
	getOptionsPanel:reorderChildren(children)
	reorderButtons()
	reorderMainPanelSpecialButtons()
	reloadMainPanelSizes()
	scheduleFullSync()
	optionsController:scheduleEvent(function()
		doFullSync()
	end, 50, "onGameStart")
end

function optionsController.onGameEnd(self)
	return
end

function getControlButtonsVisible()
	return not optionsShrink
end

function setControlButtonsVisible(visible)
	local expanded = visible == true

	if not optionsShrink == expanded then
		return
	end

	optionsShrink = not expanded

	refreshOptionsSizes()
end

function changeOptionsSize()
	optionsShrink = not optionsShrink

	refreshOptionsSizes()
end

function addToggleButton(id, description, image, callback, front, index, styleName)
	return createButton(id, description, image, callback, false, front, index, styleName)
end

function addSpecialToggleButton(id, description, image, callback, front, index, styleName)
	return createButton(id, description, image, callback, true, front, index, styleName)
end

function addStoreButton(id, description, image, callback, front)
	return createButton_large(id, description, image, callback, "store", front)
end

function getButton(id)
	local optionsPanel = optionsController and optionsController.ui and optionsController.ui.onPanel

	if not optionsPanel then
		return nil
	end

	return optionsPanel.options:recursiveGetChildById(id) or optionsPanel.specials:recursiveGetChildById(id)
end

function toggleExtendedViewButtons(extended)
	local optionsPanel = optionsController.ui.onPanel.options
	local specialsPanel = optionsController.ui.onPanel.store
	local rightGamePanel = modules.client_topmenu.getRightGameButtonsPanel()

	if extended then
		local optionChildren = optionsPanel:getChildren()

		for _, id in ipairs(optionChildren) do
			if not id:isDestroyed() then
				id.originalPanel = "options"

				rightGamePanel:addChild(id)
			end
		end

		local specialChildren = specialsPanel:getChildren()

		for _, button in ipairs(specialChildren) do
			if not button:isDestroyed() then
				button.originalPanel = "specials"

				rightGamePanel:addChild(button)
			end
		end

		optionsController.ui:hide()
		optionsController.ui:setHeight(0)
	else
		local children = rightGamePanel:getChildren()

		for _, id in ipairs(children) do
			if not id:isDestroyed() then
				if id.originalPanel == "options" then
					optionsPanel:addChild(id)
				elseif id.originalPanel == "specials" then
					specialsPanel:addChild(id)
				end
			end
		end

		optionsController.ui:show()
		optionsController.ui:setHeight(28)

		local mainRightPanel = modules.game_interface.getMainRightPanel()

		if mainRightPanel:hasChild(optionsController.ui) then
			mainRightPanel:moveChildToIndex(optionsController.ui, 4)
		end
	end

	refreshOptionsSizes()
end

local function var_0_27(arg_36_0)
	local var_36_0 = {}
	local seen = {}

	if type(arg_36_0) ~= "table" then
		return var_36_0
	end

	local visibleSet = {}

	for _, id in pairs(arg_36_0) do
		local numericValue = tonumber(_)

		if numericValue and numericValue >= 1 and numericValue == math.floor(numericValue) and type(id) == "string" and id ~= "" and not var_0_15[id] then
			table.insert(visibleSet, {
				index = numericValue,
				id = id
			})
		end
	end

	table.sort(visibleSet, function(arg_37_0, arg_37_1)
		return arg_37_0.index < arg_37_1.index
	end)

	for unusedValue, entry in ipairs(visibleSet) do
		if not seen[entry.id] then
			table.insert(var_36_0, entry.id)

			seen[entry.id] = true
		end
	end

	return var_36_0
end

local function var_0_28()
	if not SidebarPersistence or not SidebarPersistence.getSection then
		return {}, false
	end

	local section = SidebarPersistence.getSection("sidebarPanelsOptions")

	if type(section) ~= "table" then
		return {}, false
	end

	return var_0_27(section.shortcutOrder), type(section.shortcutOrder) == "table"
end

local function var_0_29()
	local node = g_settings and g_settings.getNode and g_settings.getNode(var_0_14)

	if type(node) ~= "table" then
		node = {}
	end

	if type(node.buttons) ~= "table" then
		node.buttons = {}
	end

	local var_39_1 = false

	for iter_39_0 in pairs(var_0_15) do
		if node.buttons[iter_39_0] ~= nil then
			node.buttons[iter_39_0] = nil
			var_39_1 = true
		end
	end

	if type(node.order) == "table" then
		for unusedValue, entry in pairs(node.order) do
			if var_0_15[entry] then
				var_39_1 = true

				break
			end
		end
	end

	local order = var_0_27(node.order)

	if var_39_1 then
		node.order = order
	end

	if not (#order > 0 or node.shortcutOrderInitialized == true) then
		local var_39_3, var_39_4 = var_0_28()

		order = var_39_3

		if not var_39_4 then
			order = var_0_27(DEFAULT_SHORTCUT_ORDER)

			for iter_39_3 = #order, 1, -1 do
				local var_39_5 = node.buttons[order[iter_39_3]]

				if type(var_39_5) == "table" and var_39_5.visible == false then
					table.remove(order, iter_39_3)
				end
			end
		end

		node.order = order
		node.shortcutOrderInitialized = true
		var_39_1 = true
	end

	if var_39_1 and g_settings and g_settings.setNode then
		g_settings.setNode(var_0_14, node)
		g_settings.save()
	end

	return node, order
end

function saveButtonConfig()
	if not g_settings or not g_settings.setNode then
		return
	end

	local node = g_settings.getNode(var_0_14)

	if type(node) ~= "table" then
		node = {}
	end

	if type(node.buttons) ~= "table" then
		node.buttons = {}
	end

	for iter_40_0 in pairs(var_0_15) do
		node.buttons[iter_40_0] = nil
	end

	local var_40_1 = optionsController and optionsController.ui and optionsController.ui.onPanel and optionsController.ui.onPanel.options

	if var_40_1 then
		for unusedValue, child in ipairs(var_40_1:getChildren()) do
			local id = child:getId()

			if id and id ~= "" then
				local var_40_3 = buttonConfigs[id]

				node.buttons[id] = {
					visible = var_40_3 and var_40_3.visible ~= nil and var_40_3.visible or child:isVisible()
				}
			end
		end
	end

	node.order = var_0_27(buttonOrder)
	node.shortcutOrderInitialized = true

	g_settings.setNode(var_0_14, node)
	g_settings.save()
end

local function isShortcutButtonConfiguredVisible(id, button)
	local cfg = buttonConfigs[id]

	if cfg and cfg.visible ~= nil then
		return cfg.visible
	end

	return button and button:isVisible() or false
end

function getShortcutOrder()
	local order = {}
	local seen = {}
	local optionsPanel = optionsController and optionsController.ui and optionsController.ui.onPanel and optionsController.ui.onPanel.options

	if not optionsPanel then
		return order
	end

	local function isShortcutVisible(id)
		return isShortcutButtonConfiguredVisible(id, optionsPanel:getChildById(id))
	end

	for unusedValue, entry in ipairs(buttonOrder) do
		if type(entry) == "string" and entry ~= "" and not seen[entry] and isShortcutVisible(entry) then
			table.insert(order, entry)

			seen[entry] = true
		end
	end

	for unusedValue, child in ipairs(optionsPanel:getChildren()) do
		local id = child:getId()

		if id and id ~= "" and not seen[id] and isShortcutVisible(id) then
			table.insert(order, id)

			seen[id] = true
		end
	end

	return order
end

function applyShortcutOrder(order)
	local optionsPanel = optionsController and optionsController.ui and optionsController.ui.onPanel and optionsController.ui.onPanel.options

	if not optionsPanel then
		return
	end

	buttonOrder = var_0_27(order)

	local byId = {}

	for _, ch in ipairs(buttonOrder) do
		byId[ch] = true
	end

	for unusedValue, child in ipairs(optionsPanel:getChildren()) do
		local id = child:getId()

		if id and id ~= "" then
			local visible = byId[id] == true

			child:setVisible(visible)

			local displayName = ControlButtonNames[id] or stripHotkey(child:getTooltip()) or id

			if not buttonConfigs[id] then
				buttonConfigs[id] = {
					visible = visible,
					tooltip = displayName
				}
			else
				buttonConfigs[id].visible = visible
			end
		end
	end

	reorderButtons()
	reloadMainPanelSizes()
	refreshShortcutsSidebarContextMenu()
end

function loadButtonConfig()
	local unusedValue, DEFAULT_SHORTCUT_ORDER = var_0_29()

	return {
		shortcutOrder = DEFAULT_SHORTCUT_ORDER
	}
end

function reorderMainPanelSpecialButtons()
	if not optionsController or not optionsController.ui or not optionsController.ui.onPanel then
		return
	end

	local specials = optionsController.ui.onPanel.specials

	if not specials or specials:isDestroyed() then
		return
	end

	local orderIds = {
		"optionsMainButton",
		"logoutButton",
		"helperButton",
		"battlePassInboxButton"
	}
	local byId = {}

	for _, ch in ipairs(specials:getChildren()) do
		local id = ch:getId()

		if id and id ~= "" then
			byId[id] = ch
		end
	end

	local rest = {}
	local var_46_5 = {}

	for id, w in ipairs(orderIds) do
		local w = byId[w]

		if w then
			rest[#rest + 1] = w
			var_46_5[w] = true
		end
	end

	local var_46_7 = {}

	for _, id in pairs(byId) do
		if not var_46_5[id] then
			var_46_7[#var_46_7 + 1] = _
		end
	end

	table.sort(var_46_7)

	for _, button in ipairs(var_46_7) do
		rest[#rest + 1] = byId[button]
	end

	if #rest > 0 then
		specials:reorderChildren(rest)
	end
end

function reorderButtons()
	if not g_game.isOnline() then
		return
	end

	local optionsPanel = optionsController.ui.onPanel.options
	local children = {}

	for _, button in ipairs(buttonOrder) do
		local button = optionsPanel:getChildById(button)

		if button then
			table.insert(children, button)
		end
	end

	for _, button in ipairs(optionsPanel:getChildren()) do
		local id = button:getId()

		if not table.find(buttonOrder, id) then
			table.insert(children, button)
		end
	end

	optionsPanel:reorderChildren(children)
	refreshShortcutsSidebarContextMenu()
end

function getMainPanelButtonsInfo()
	local var_48_0 = {}
	local options = optionsController.ui.onPanel.options

	if options then
		for unusedValue, button in ipairs(options:getChildren()) do
			local id = button:getId()

			if id then
				table.insert(var_48_0, {
					id = id,
					tooltip = ControlButtonNames[id] or stripHotkey(button:getTooltip()) or id,
					visible = isShortcutButtonConfiguredVisible(id, button)
				})
			end
		end
	end

	return var_48_0, buttonOrder
end

function setMainPanelButtonVisible(id, visible)
	local optionsPanel = optionsController.ui.onPanel.options

	if not optionsPanel then
		return
	end

	local button = optionsPanel:getChildById(id)

	if button then
		button:setVisible(visible)

		local displayName = ControlButtonNames[id] or stripHotkey(button:getTooltip()) or id

		if not buttonConfigs[id] then
			buttonConfigs[id] = {
				visible = visible,
				tooltip = displayName
			}
		else
			buttonConfigs[id].visible = visible
		end

		if visible then
			if not table.find(buttonOrder, id) then
				table.insert(buttonOrder, id)
			end
		else
			table.removevalue(buttonOrder, id)
		end

		saveButtonConfig()
		reorderButtons()
		reloadMainPanelSizes()
	end
end

function setMainPanelButtonOrder(order)
	buttonOrder = var_0_27(order)

	reorderButtons()
	saveButtonConfig()
end

function resetMainPanelButtons()
	buttonConfigs = {}

	applyShortcutOrder(DEFAULT_SHORTCUT_ORDER)
	saveButtonConfig()
end
