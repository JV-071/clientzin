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

local function var_0_9(arg_3_0)
	if not arg_3_0 then
		return
	end

	local blocker = arg_3_0.blocker

	arg_3_0.blocker = nil

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
			var_0_9(entry)

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
		local var_16_1 = children[i]

		children[i] = nil

		pruneOrphanBlockersInWidget(var_16_1, activeBlockers)
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

	var_0_9(entry)

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

local function var_0_21(arg_24_0)
	if not isWidgetAlive(arg_24_0) or not arg_24_0.getClassName then
		return false
	end

	return arg_24_0:getClassName() == "UITextEditBox"
end

local function var_0_22(arg_25_0)
	local focusedWidget = g_ui.getFocusedWidget and g_ui.getFocusedWidget()

	if not var_0_21(focusedWidget) then
		return false
	end

	local parent = focusedWidget

	while parent do
		if parent == arg_25_0 then
			return true
		end

		parent = parent.getParent and parent:getParent()
	end

	return false
end

local function var_0_23(arg_26_0)
	if not isWidgetAlive(arg_26_0) then
		return nil
	end

	if arg_26_0.onClick then
		return arg_26_0
	end

	local button = arg_26_0.getChildById and arg_26_0:getChildById("button")

	if isWidgetAlive(button) and button.onClick then
		return button
	end

	return nil
end

local function var_0_24(arg_27_0)
	if not isWidgetAlive(arg_27_0) or not arg_27_0.recursiveGetChildById then
		return nil
	end

	local menus = arg_27_0:recursiveGetChildById("menus")

	if not isWidgetAlive(menus) or not menus.getChildren then
		return nil
	end

	local var_27_1 = {}
	local children = menus:getChildren()

	for iter_27_0 = 1, #children do
		local var_27_3 = var_0_23(children[iter_27_0])

		if var_27_3 then
			var_27_1[#var_27_1 + 1] = var_27_3
		end
	end

	if #var_27_1 < 2 then
		return nil
	end

	return var_27_1
end

local function var_0_25(arg_28_0, arg_28_1)
	arg_28_1 = arg_28_1 or {}

	if arg_28_1.tabs == false then
		return nil
	end

	return var_0_24(arg_28_0)
end

local function var_0_26(arg_29_0)
	if not isWidgetAlive(arg_29_0) then
		return false
	end

	if arg_29_0.isOn and arg_29_0:isOn() then
		return true
	end

	if arg_29_0.isChecked and arg_29_0:isChecked() then
		return true
	end

	return false
end

local function var_0_27(arg_30_0)
	for iter_30_0 = 1, #arg_30_0 do
		if var_0_26(arg_30_0[iter_30_0]) then
			return iter_30_0
		end
	end

	return 1
end

local function var_0_28(arg_31_0)
	if type(arg_31_0) == "function" then
		arg_31_0()

		return
	end

	if isWidgetAlive(arg_31_0) and arg_31_0.onClick then
		signalcall(arg_31_0.onClick, arg_31_0)
	end
end

function g_modalManager.handleTabKey(arg_32_0, arg_32_1)
	if arg_32_0 ~= KeyTab then
		return false
	end

	if arg_32_1 ~= KeyboardNoModifier and arg_32_1 ~= KeyboardShiftModifier then
		return false
	end

	local var_32_0 = modalStack[#modalStack]

	if not var_32_0 or not isWidgetAlive(var_32_0.widget) then
		return false
	end

	if var_0_22(var_32_0.widget) then
		return false
	end

	local var_32_1 = var_0_25(var_32_0.widget, var_32_0.opts)

	if not var_32_1 or #var_32_1 < 2 then
		return false
	end

	local var_32_2 = var_0_27(var_32_1) + (arg_32_1 == KeyboardShiftModifier and -1 or 1)

	if var_32_2 < 1 then
		var_32_2 = #var_32_1
	elseif var_32_2 > #var_32_1 then
		var_32_2 = 1
	end

	var_0_28(var_32_1[var_32_2])
	activateTop()

	return true
end

function g_modalManager.hookSearchEdit(arg_33_0)
	if not isWidgetAlive(arg_33_0) or arg_33_0._modalSearchTabHooked then
		return
	end

	arg_33_0._modalSearchTabHooked = true

	connect(arg_33_0, {
		onKeyDown = function(unusedArgument, arg_34_1, arg_34_2)
			return g_modalManager.handleTabKey(arg_34_1, arg_34_2)
		end
	})
end

local function handleKeyDown(unusedArgument, arg_35_1, arg_35_2)
	return g_modalManager.handleTabKey(arg_35_1, arg_35_2)
end

local function var_0_30(arg_36_0)
	if arg_36_0._modalTabKeysConnected then
		return
	end

	arg_36_0._modalTabKeysConnected = true

	connect(arg_36_0, {
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

	local var_40_0, var_40_1 = pcall(createBlocker, widget, opts)

	if not var_40_0 or not var_40_1 then
		return
	end

	table.insert(modalStack, {
		widget = widget,
		blocker = var_40_1,
		opts = opts
	})

	if opts.tabs ~= false then
		var_0_30(widget)
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
		var_0_9(entry)

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
