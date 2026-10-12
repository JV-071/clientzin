g_modalManager = g_modalManager or {}

local DEFAULT_OVERLAY_COLOR = "#00000080"
local TRANSPARENT_COLOR = "#00000000"
local BLOCKER_ID = "modalBlocker"
local modalStack = {}
local keyboardKeeperWidgets = {}
local MODAL_HOTKEY_BLOCK_SOURCE = "g_modal_manager"
local modalHotkeyBlockId

local function acquireModalHotkeyBlock()
	if modalHotkeyBlockId then
		return
	end

	if HotkeyUtils and HotkeyUtils.disableHotkeys then
		modalHotkeyBlockId = HotkeyUtils.disableHotkeys(MODAL_HOTKEY_BLOCK_SOURCE)
	end

	if modules.game_actionbar and modules.game_actionbar.pauseHotkeys then
		modules.game_actionbar.pauseHotkeys()
	end
end

local function releaseModalHotkeyBlock()
	if not modalHotkeyBlockId then
		return
	end

	if HotkeyUtils and HotkeyUtils.enableHotkeys then
		HotkeyUtils.enableHotkeys(modalHotkeyBlockId)
	end

	modalHotkeyBlockId = nil

	if modules.game_actionbar and modules.game_actionbar.resumeHotkeys then
		modules.game_actionbar.resumeHotkeys()
	end
end

local function destroyEntryBlocker(entry)
	if not entry then
		return
	end

	local blocker = entry.blocker

	entry.blocker = nil

	if blocker and isWidgetAlive(blocker) then
		pcall(function()
			blocker:destroy()
		end)
	end
end

local function pruneStack()
	for i = #modalStack, 1, -1 do
		local entry = modalStack[i]

		if not isWidgetAlive(entry.widget) then
			destroyEntryBlocker(entry)

			entry.widget = nil
			entry.opts = nil

			table.remove(modalStack, i)
		end
	end
end

local function findIndex(widget)
	for i = #modalStack, 1, -1 do
		if modalStack[i].widget == widget then
			return i
		end
	end

	return nil
end

local function createBlocker(widget, opts)
	local parent = widget:getParent() or rootWidget
	local blocker = g_ui.createWidget("UIWidget", parent)

	blocker:setId(BLOCKER_ID)
	blocker:fill("parent")
	blocker:setPhantom(false)
	blocker:setFocusable(false)

	if opts.darken then
		blocker:setBackgroundColor(opts.color or DEFAULT_OVERLAY_COLOR)
	else
		blocker:setBackgroundColor(TRANSPARENT_COLOR)
	end

	return blocker
end

local function pruneDeadKeyboardKeepers()
	for keeperWidget in pairs(keyboardKeeperWidgets) do
		if not isWidgetAlive(keeperWidget) then
			keyboardKeeperWidgets[keeperWidget] = nil
		end
	end
end

local function hasVisibleKeyboardKeeper()
	pruneDeadKeyboardKeepers()

	for keeperWidget in pairs(keyboardKeeperWidgets) do
		if keeperWidget:isVisible() then
			return true
		end
	end

	return false
end

local function activateTop()
	local top = modalStack[#modalStack]

	if not top or not isWidgetAlive(top.widget) then
		return
	end

	top.widget:raise()
	top.widget:focus()

	if hasVisibleKeyboardKeeper() then
		pruneDeadKeyboardKeepers()

		for keeperWidget in pairs(keyboardKeeperWidgets) do
			if keeperWidget:isVisible() then
				keeperWidget:raise()
			end
		end

		return
	end

	top.widget:grabKeyboard()
end

function g_modalManager.addKeyboardKeeper(widget)
	if isWidgetAlive(widget) then
		keyboardKeeperWidgets[widget] = true
	end
end

function g_modalManager.removeKeyboardKeeper(widget)
	if widget then
		keyboardKeeperWidgets[widget] = nil
	end
end

function g_modalManager.restoreKeyboard()
	pruneStack()

	local top = modalStack[#modalStack]

	if top and isWidgetAlive(top.widget) and not hasVisibleKeyboardKeeper() then
		top.widget:grabKeyboard()
	end
end

function g_modalManager.reactivate()
	pruneStack()
	activateTop()
end

local function collectActiveBlockers()
	local active = {}

	for _, entry in ipairs(modalStack) do
		if entry.blocker and isWidgetAlive(entry.blocker) then
			active[entry.blocker] = true
		end
	end

	return active
end

local function pruneOrphanBlockersInWidget(widget, activeBlockers)
	if not isWidgetAlive(widget) then
		return
	end

	if widget:getId() == BLOCKER_ID and not activeBlockers[widget] then
		widget:destroy()

		return
	end

	local children = widget:getChildren()

	for i = 1, #children do
		local childWidget = children[i]

		children[i] = nil

		pruneOrphanBlockersInWidget(childWidget, activeBlockers)
	end
end

function g_modalManager.pruneOrphanBlockers()
	if not rootWidget then
		return
	end

	pruneStack()
	pruneOrphanBlockersInWidget(rootWidget, collectActiveBlockers())
end

local function ensureModalDestroyCleanup(widget)
	if widget._modalManagerCleanupConnected then
		return
	end

	widget._modalManagerCleanupConnected = true

	connect(widget, {
		onDestroy = function(destroyedWidget)
			g_modalManager.hide(destroyedWidget)
			g_modalManager.pruneOrphanBlockers()
		end
	})
end

local function invokeCloseCallback(entry)
	if not entry or not entry.opts then
		return
	end

	local onClose = entry.opts.onClose

	if type(onClose) ~= "function" then
		return
	end

	pcall(onClose, entry.widget)
end

local function releaseModalEntry(entry, hideWidget, runCloseCallback)
	if not entry then
		return
	end

	if runCloseCallback then
		invokeCloseCallback(entry)
	end

	destroyEntryBlocker(entry)

	local widget = entry.widget

	entry.widget = nil
	entry.opts = nil

	if isWidgetAlive(widget) then
		pcall(function()
			widget:ungrabKeyboard()
		end)

		if hideWidget then
			pcall(function()
				widget:hide()
			end)
		end
	end
end

local function isTextEditWidget(widget)
	if not isWidgetAlive(widget) or not widget.getClassName then
		return false
	end

	return widget:getClassName() == "UITextEditBox"
end

local function hasFocusedTextEdit(modalWidget)
	local focusedWidget = g_ui.getFocusedWidget and g_ui.getFocusedWidget()

	if not isTextEditWidget(focusedWidget) then
		return false
	end

	local parent = focusedWidget

	while parent do
		if parent == modalWidget then
			return true
		end

		parent = parent.getParent and parent:getParent()
	end

	return false
end

local function resolveClickableTab(widget)
	if not isWidgetAlive(widget) then
		return nil
	end

	if widget.onClick then
		return widget
	end

	local button = widget.getChildById and widget:getChildById("button")

	if isWidgetAlive(button) and button.onClick then
		return button
	end

	return nil
end

local function collectModalTabs(modalWidget)
	if not isWidgetAlive(modalWidget) or not modalWidget.recursiveGetChildById then
		return nil
	end

	local menus = modalWidget:recursiveGetChildById("menus")

	if not isWidgetAlive(menus) or not menus.getChildren then
		return nil
	end

	local tabButtons = {}
	local children = menus:getChildren()

	for childIndex = 1, #children do
		local tabButton = resolveClickableTab(children[childIndex])

		if tabButton then
			tabButtons[#tabButtons + 1] = tabButton
		end
	end

	if #tabButtons < 2 then
		return nil
	end

	return tabButtons
end

local function getEnabledModalTabs(modalWidget, options)
	options = options or {}

	if options.tabs == false then
		return nil
	end

	return collectModalTabs(modalWidget)
end

local function isTabSelected(tabButton)
	if not isWidgetAlive(tabButton) then
		return false
	end

	if tabButton.isOn and tabButton:isOn() then
		return true
	end

	if tabButton.isChecked and tabButton:isChecked() then
		return true
	end

	return false
end

local function findSelectedTabIndex(tabButtons)
	for tabIndex = 1, #tabButtons do
		if isTabSelected(tabButtons[tabIndex]) then
			return tabIndex
		end
	end

	return 1
end

local function activateTab(tabAction)
	if type(tabAction) == "function" then
		tabAction()

		return
	end

	if isWidgetAlive(tabAction) and tabAction.onClick then
		signalcall(tabAction.onClick, tabAction)
	end
end

function g_modalManager.handleTabKey(keyCode, keyboardModifiers)
	if keyCode ~= KeyTab then
		return false
	end

	if keyboardModifiers ~= KeyboardNoModifier and keyboardModifiers ~= KeyboardShiftModifier then
		return false
	end

	local topEntry = modalStack[#modalStack]

	if not topEntry or not isWidgetAlive(topEntry.widget) then
		return false
	end

	if hasFocusedTextEdit(topEntry.widget) then
		return false
	end

	local tabButtons = getEnabledModalTabs(topEntry.widget, topEntry.opts)

	if not tabButtons or #tabButtons < 2 then
		return false
	end

	local nextTabIndex = findSelectedTabIndex(tabButtons) + (keyboardModifiers == KeyboardShiftModifier and -1 or 1)

	if nextTabIndex < 1 then
		nextTabIndex = #tabButtons
	elseif nextTabIndex > #tabButtons then
		nextTabIndex = 1
	end

	activateTab(tabButtons[nextTabIndex])
	activateTop()

	return true
end

function g_modalManager.hookSearchEdit(searchEdit)
	if not isWidgetAlive(searchEdit) or searchEdit._modalSearchTabHooked then
		return
	end

	searchEdit._modalSearchTabHooked = true

	connect(searchEdit, {
		onKeyDown = function(unusedArgument, keyCode, keyboardModifiers)
			return g_modalManager.handleTabKey(keyCode, keyboardModifiers)
		end
	})
end

local function handleKeyDown(unusedArgument, keyCode, keyboardModifiers)
	return g_modalManager.handleTabKey(keyCode, keyboardModifiers)
end

local function connectModalTabKeys(modalWidget)
	if modalWidget._modalTabKeysConnected then
		return
	end

	modalWidget._modalTabKeysConnected = true

	connect(modalWidget, {
		onKeyDown = handleKeyDown
	})
end

local function suppressModalAutoRaise(widget)
	if widget._modalAutoRaiseSuppressed then
		return
	end

	widget._modalAutoRaiseSuppressed = true

	function widget.onMousePress()
		widget:grabKeyboard()

		return false
	end

	function widget.onFocusChange()
		return
	end
end

function g_modalManager.show(widget, opts)
	if not isWidgetAlive(widget) then
		return
	end

	pruneStack()

	if findIndex(widget) then
		activateTop()

		return
	end

	opts = opts or {}

	local ok, blocker = pcall(createBlocker, widget, opts)

	if not ok or not blocker then
		return
	end

	table.insert(modalStack, {
		widget = widget,
		blocker = blocker,
		opts = opts
	})

	if opts.tabs ~= false then
		connectModalTabKeys(widget)
	end

	if #modalStack == 1 then
		acquireModalHotkeyBlock()
	end

	ensureModalDestroyCleanup(widget)
	suppressModalAutoRaise(widget)
	activateTop()
end

function g_modalManager.hide(widget)
	if not widget then
		return
	end

	local idx = findIndex(widget)

	if not idx then
		pruneStack()

		return
	end

	local entry = table.remove(modalStack, idx)

	releaseModalEntry(entry, false, false)
	pruneStack()

	if #modalStack == 0 then
		releaseModalHotkeyBlock()
	else
		activateTop()
	end

	g_modalManager.pruneOrphanBlockers()
end

function g_modalManager.hideAll()
	pruneStack()

	local entries = {}

	for i = 1, #modalStack do
		entries[i] = modalStack[i]
	end

	modalStack = {}

	releaseModalHotkeyBlock()

	for i = #entries, 1, -1 do
		releaseModalEntry(entries[i], true, true)
	end

	if g_client and g_client.setInputLockWidget then
		pcall(function()
			g_client.setInputLockWidget(nil)
		end)
	end

	g_modalManager.pruneOrphanBlockers()
end

function g_modalManager.isModal(widget)
	return findIndex(widget) ~= nil
end

local ORPHAN_OVERLAY_IDS = {
	storeWindow = true,
	changeNameWindow = true,
	[BLOCKER_ID] = true
}

local function destroyModalWidget(widget)
	if not isWidgetAlive(widget) then
		return
	end

	pcall(function()
		g_modalManager.hide(widget)
	end)
	pcall(function()
		widget:ungrabKeyboard()
	end)
	pcall(function()
		widget:destroy()
	end)
end

local function dismissOrphanOverlays()
	if not rootWidget then
		return
	end

	local children = rootWidget:getChildren()

	for i = #children, 1, -1 do
		local child = children[i]

		if isWidgetAlive(child) and ORPHAN_OVERLAY_IDS[child:getId()] then
			destroyModalWidget(child)
		end
	end
end

function g_modalManager.dismissAll()
	pruneStack()

	local widgetsToClose = {}

	for _, entry in ipairs(modalStack) do
		if isWidgetAlive(entry.widget) then
			table.insert(widgetsToClose, entry.widget)
		end
	end

	while #modalStack > 0 do
		local entry = table.remove(modalStack)

		invokeCloseCallback(entry)
		destroyEntryBlocker(entry)

		local widget = entry.widget

		entry.widget = nil
		entry.opts = nil

		if isWidgetAlive(widget) then
			pcall(function()
				widget:ungrabKeyboard()
			end)
		end
	end

	releaseModalHotkeyBlock()

	for _, widget in ipairs(widgetsToClose) do
		destroyModalWidget(widget)
	end

	if g_client and g_client.setInputLockWidget then
		pcall(function()
			g_client.setInputLockWidget(nil)
		end)
	end

	dismissOrphanOverlays()
	g_modalManager.pruneOrphanBlockers()
end

function g_modalManager.clear()
	g_modalManager.dismissAll()
end

local function onGameEndHideModals()
	g_modalManager.hideAll()
end

connect(g_game, {
	onGameEnd = onGameEndHideModals
})
