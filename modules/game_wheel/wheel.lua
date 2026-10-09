wheelWindow = nil
wheelOfDestinyWindow = nil
gemAtelierWindow = nil
fragmentWindow = nil
newPresetWindow = nil
renamePresetWindow = nil
exportCodeWindow = nil
deletePresetWindow = nil
checkSavePresetWindow = nil
selectedNewPresetRadio = nil

local summaryVisible = false
local presetTabSelection = "informationButton"
local var_0_2

wheelPanel = nil
centerReferencePoint = nil

local function onGameStart()
	if var_0_2 then
		removeEvent(var_0_2)

		var_0_2 = nil
	end

	WheelOfDestiny.cancelActiveStateRequest()
	WheelOfDestiny.clearActiveState()

	if not WheelOfDestiny.loadWheelPresets() then
		print("[wheel] Error loading wheel presets")
	end

	var_0_2 = scheduleEvent(function()
		var_0_2 = nil

		WheelOfDestiny.requestActiveState()
	end, 250)
end

function init()
	wheelWindow = g_ui.displayUI("wheel")
	mainPanel = wheelWindow:getChildById("mainPanel")

	g_ui.importStyle("styles/wheelSlice")
	g_ui.importStyle("styles/wheelMenu_widgets")
	g_ui.importStyle("styles/wheelMenu_selection")
	g_ui.importStyle("styles/wheelMenu_info")
	g_ui.importStyle("styles/wheelMenu_summary")
	g_ui.importStyle("styles/wheelMenu_dedicationPerks")
	g_ui.importStyle("styles/wheelMenu_convictionPerks")
	g_ui.importStyle("styles/wheelMenu_vessels")
	g_ui.importStyle("styles/wheelMenu_revelationPerks")
	g_ui.importStyle("styles/wheelMenu_wheelPanel")
	g_ui.importStyle("styles/gemMenu_widgets")

	wheelOfDestinyWindow = g_ui.loadUI("styles/wheelMenu", mainPanel)

	if not wheelOfDestinyWindow then
		error("failed to load styles/wheelMenu")
	end

	wheelOfDestinyWindow:hide()

	wheelPanel = wheelOfDestinyWindow:getChildById("wheelPanel")

	WheelOfDestiny.initSliceFills()

	gemAtelierWindow = g_ui.loadUI("styles/gemMenu", mainPanel)

	if not gemAtelierWindow then
		error("failed to load styles/gemMenu")
	end

	gemAtelierWindow:hide()

	local affinitiesBox = gemAtelierWindow:recursiveGetChildById("affinitiesBox")
	local qualitiesBox = gemAtelierWindow:recursiveGetChildById("qualitiesBox")

	if affinitiesBox then
		function affinitiesBox.onOptionChange(widget, text, data)
			if GemAtelier and GemAtelier.onSortAffinity then
				GemAtelier.onSortAffinity(widget, widget.currentIndex)
			end
		end
	end

	if qualitiesBox then
		function qualitiesBox.onOptionChange(widget, text, data)
			if GemAtelier and GemAtelier.onSortQuality then
				GemAtelier.onSortQuality(widget, widget.currentIndex)
			end
		end
	end

	fragmentWindow = g_ui.loadUI("styles/fragmentMenu", mainPanel)

	fragmentWindow:hide()

	newPresetWindow = g_ui.displayUI("styles/newPreset")

	newPresetWindow:hide()

	renamePresetWindow = g_ui.displayUI("styles/renamePreset")

	renamePresetWindow:hide()

	selectedNewPresetRadio = UIRadioGroup.create()

	selectedNewPresetRadio:addWidget(newPresetWindow.contentPanel.useEmpty)
	selectedNewPresetRadio:addWidget(newPresetWindow.contentPanel.copyPreset)
	selectedNewPresetRadio:addWidget(newPresetWindow.contentPanel.import)
	selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.import)

	selectedNewPresetRadio.onSelectionChange = WheelOfDestiny.onNewPresetSelectionChange

	local addOneButton = wheelOfDestinyWindow:recursiveGetChildById("addOne")
	local rmvOneButton = wheelOfDestinyWindow:recursiveGetChildById("rmvOne")

	g_mouse.bindAutoPress(addOneButton, function()
		onAddOne()
	end, 500, nil)
	g_mouse.bindAutoPress(rmvOneButton, function()
		onRmvOne()
	end, 500, nil)
	loadMenu("wheelMenu")
	toggleTabBarButtons("informationButton")
	hide()
	connect(g_game, {
		onGameEnd = onGameEnd,
		onGameStart = onGameStart,
		onDestinyWheel = WheelOfDestiny.onDestinyWheel,
		onResourcesBalanceChange = onResourceBalance
	})

	if modules.game_mainpanel then
		wheelButton = modules.game_mainpanel.addToggleButton("wheelButton", tr("Wheel of Destiny"), "/images/options/button_skillwheeldialog", toggle, false, 10)

		wheelButton:setOn(false)
	end

	Keybind.new("Dialogs", "Open Wheel of Destiny", "", "")
	Keybind.bind("Dialogs", "Open Wheel of Destiny", {
		{
			type = KEY_DOWN,
			callback = toggle
		}
	}, modules.game_interface.getRootPanel())

	if g_game.isOnline() then
		onGameStart()
	end
end

function terminate()
	Keybind.delete("Dialogs", "Open Wheel of Destiny")

	if var_0_2 then
		removeEvent(var_0_2)

		var_0_2 = nil
	end

	WheelOfDestiny.cancelActiveStateRequest()
	WheelOfDestiny.clearActiveState()
	disconnect(g_game, {
		onGameEnd = onGameEnd,
		onGameStart = onGameStart,
		onDestinyWheel = WheelOfDestiny.onDestinyWheel,
		onResourcesBalanceChange = onResourceBalance
	})

	if wheelWindow then
		if g_modalManager then
			g_modalManager.hide(wheelWindow)
		end

		wheelWindow:destroy()

		wheelWindow = nil
	end

	if wheelButton then
		wheelButton:destroy()

		wheelButton = nil
	end
end

function showWheelWindow()
	wheelWindow:show(true)

	if g_modalManager then
		g_modalManager.show(wheelWindow)
	end

	wheelWindow:raise()
	wheelWindow:focus()
end

function hideWheelWindow()
	if g_modalManager then
		g_modalManager.hide(wheelWindow)
	end

	wheelWindow:ungrabMouse()
	wheelWindow:ungrabKeyboard()
	wheelWindow:hide()
end

local function var_0_4(playerId)
	WheelOfDestiny.cancelActiveStateRequest()
	setWheelButtonOn(true)
	g_game.openWheel(playerId)
end

function toggle()
	if wheelWindow:isVisible() then
		hide()
	else
		wheelWindow:focus()
		loadMenu("wheelMenu")

		if gemAtelierWindow:isVisible() then
			gemAtelierWindow:hide()
		end

		if fragmentWindow:isVisible() then
			fragmentWindow:hide()
		end

		var_0_4(g_game.getLocalPlayer():getId())
		wheelWindow:recursiveGetChildById("tabContent"):setVisible(false)
		WheelOfDestiny.onRemoveClick()
	end
end

function setWheelButtonOn(on)
	if wheelButton then
		wheelButton:setOn(on)
	end
end

function getActiveWheelState()
	return WheelOfDestiny.getActiveState()
end

function hide()
	WheelOfDestiny.setPreviewMode(false)
	hideWheelWindow()

	if wheelButton then
		wheelButton:setOn(false)
	end
end

function onGameEnd()
	if var_0_2 then
		removeEvent(var_0_2)

		var_0_2 = nil
	end

	WheelOfDestiny.cancelActiveStateRequest()
	WheelOfDestiny.clearActiveState()
	hide()
	WheelOfDestiny.saveWheelPresets()
	newPresetWindow:hide()
	renamePresetWindow:hide()

	if exportCodeWindow then
		exportCodeWindow:destroy()

		exportCodeWindow = nil
	end

	if exportCodeWindow then
		exportCodeWindow:destroy()

		exportCodeWindow = nil
	end

	if checkSavePresetWindow then
		checkSavePresetWindow:destroy()

		checkSavePresetWindow = nil
	end

	WheelOfDestiny.currentPreset = {}
end

function show()
	var_0_4(g_game.getLocalPlayer():getId())
end

function openForPlayer(playerId)
	if not wheelWindow then
		return
	end

	local id = playerId

	if not id or id == 0 then
		local player = g_game.getLocalPlayer()

		if not player then
			return
		end

		id = player:getId()
	end

	wheelWindow:focus()
	loadMenu("wheelMenu")

	if gemAtelierWindow:isVisible() then
		gemAtelierWindow:hide()
	end

	if fragmentWindow:isVisible() then
		fragmentWindow:hide()
	end

	var_0_4(id)
	wheelWindow:recursiveGetChildById("tabContent"):setVisible(false)
	WheelOfDestiny.onRemoveClick()
end

function onWheelClick(position)
	WheelOfDestiny.onWheelClick(position)
end

function loadMenu(menuId)
	if wheelOfDestinyWindow:isVisible() then
		wheelOfDestinyWindow:hide()
	end

	if gemAtelierWindow:isVisible() then
		gemAtelierWindow:hide()
	end

	if newPresetWindow:isVisible() then
		newPresetWindow:hide()
	end

	if fragmentWindow:isVisible() then
		fragmentWindow:hide()
	end

	wheelMenuButton = wheelWindow.menus:getChildById("wheelMenu")
	gemMenuButton = wheelWindow.menus:getChildById("gemMenu")
	fragmentMenuButton = wheelWindow.menus:getChildById("fragmentMenu")

	if menuId == "wheelMenu" then
		gemAtelierWindow:hide()
		fragmentWindow:hide()

		wheelPanel = wheelOfDestinyWindow:getChildById("wheelPanel")
		wheelPanel.onMouseMove = WheelOfDestiny.onMouseMove
		centerReferencePoint = wheelOfDestinyWindow:recursiveGetChildById("centerReferencePoint")

		wheelMenuButton:setChecked(true)
		gemMenuButton:setChecked(false)
		fragmentMenuButton:setChecked(false)

		local informationButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("informationButton")
		local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")
		local summaryButton = wheelWindow.mainPanel.wheelMenu.dedicationPerks:getChildById("summaryButton")
		local summaryOpenedButton = wheelWindow.mainPanel.wheelMenu.summary:getChildById("summaryButton")

		function informationButton.onClick()
			toggleTabBarButtons("informationButton")
		end

		function managePresetsButton.onClick()
			toggleTabBarButtons("managePresetsButton")
			scheduleEvent(function()
				WheelOfDestiny.configurePresets()
			end, 50)
		end

		function summaryButton.onClick()
			toggleSummary()
		end

		function summaryOpenedButton.onClick()
			toggleSummary()
		end

		toggleTabBarButtons("informationButton")

		if WheelOfDestiny.lastSelectedGemVessel and WheelOfDestiny.lastSelectedGemVessel:isVisible() then
			local currentDomain = WheelOfDestiny.lastSelectedGemVessel:getId():gsub("selectVessel", "")

			WheelOfDestiny.onGemVesselClick(tonumber(currentDomain))
		end

		Workshop.createFragments()
		wheelOfDestinyWindow:show(true)
	elseif menuId == "gemMenu" then
		Workshop.createFragments()
		GemAtelier.resetFields()
		GemAtelier.showGems(true)
		gemAtelierWindow:show(true)
		wheelMenuButton:setChecked(false)
		fragmentMenuButton:setChecked(false)
		gemMenuButton:setChecked(true)
	elseif menuId == "fragmentMenu" then
		Workshop.createFragments()
		Workshop.showFragmentList(true)
		fragmentWindow:show(true)
		wheelMenuButton:setChecked(false)
		gemMenuButton:setChecked(false)
		fragmentMenuButton:setChecked(true)
	end
end

function toggleSummary()
	summaryVisible = not summaryVisible

	local summaryPanel = wheelWindow.mainPanel.wheelMenu:getChildById("summary")
	local dedicationPerksPanel = wheelWindow.mainPanel.wheelMenu:getChildById("dedicationPerks")
	local convictionPerksPanel = wheelWindow.mainPanel.wheelMenu:getChildById("convictionPerks")
	local vesselsPanel = wheelWindow.mainPanel.wheelMenu:getChildById("vessels")
	local revelationPerksPanel = wheelWindow.mainPanel.wheelMenu:getChildById("revelationPerks")

	summaryPanel:setVisible(summaryVisible)
	dedicationPerksPanel:setVisible(not summaryVisible)
	convictionPerksPanel:setVisible(not summaryVisible)
	vesselsPanel:setVisible(not summaryVisible)
	revelationPerksPanel:setVisible(not summaryVisible)
	WheelOfDestiny.configureSummary()
end

local function refreshPresetTabButtonClip(button)
	local buttonId = button:getId()
	local isSmall = buttonId == "informationButton" and presetTabSelection == "managePresetsButton" or buttonId == "managePresetsButton" and presetTabSelection == "informationButton"

	if buttonId == "managePresetsButton" and not button:isEnabled() then
		button:setImageClip(torect("0 68 34 34"))

		return
	end

	if isSmall then
		local clipY = button:isPressed() and 34 or 0

		button:setImageClip(torect(string.format("0 %d 34 34", clipY)))
	else
		button:setImageClip(torect("0 0 174 34"))
	end
end

function onPresetTabButtonPressChange(arg_28_0)
	refreshPresetTabButtonClip(arg_28_0)
end

function onPresetTabButtonHoverChange(button, hovered)
	if g_tooltip and g_tooltip.onWidgetHoverChange then
		g_tooltip.onWidgetHoverChange(button, hovered)
	end
end

function refreshPresetTabBarButtons()
	local presetTabBar = wheelWindow.mainPanel.wheelMenu.info.presetTabBar

	refreshPresetTabButtonClip(presetTabBar:getChildById("informationButton"))
	refreshPresetTabButtonClip(presetTabBar:getChildById("managePresetsButton"))
end

function toggleTabBarButtons(selectedButtonId)
	presetTabSelection = selectedButtonId

	local informationButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("informationButton")
	local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")
	local tabContent = wheelWindow.mainPanel.wheelMenu.info.tabContent

	if selectedButtonId == "informationButton" then
		informationButton:setSize(tosize("174 34"))
		informationButton:setImageSource("/images/game/wheel/buttons/button-information-selected")
		managePresetsButton:setSize(tosize("34 34"))
		managePresetsButton:setImageSource("/images/game/wheel/buttons/button-manage-unselected")
		tabContent.manage:setVisible(false)
		tabContent.information:setVisible(true)
	elseif selectedButtonId == "managePresetsButton" then
		informationButton:setSize(tosize("34 34"))
		informationButton:setImageSource("/images/game/wheel/buttons/button-information-unselected")
		managePresetsButton:setSize(tosize("174 34"))
		managePresetsButton:setImageSource("/images/game/wheel/buttons/button-manage-selected")
		tabContent.information:setVisible(false)
		tabContent.manage:setVisible(true)
	end

	refreshPresetTabButtonClip(informationButton)
	refreshPresetTabButtonClip(managePresetsButton)
end

function onResourceBalance()
	if not wheelWindow:isVisible() then
		return true
	end

	local player = g_game.getLocalPlayer()
	local bankMoney = player:getResourceBalance(ResourceTypes.BANK_BALANCE)
	local characterMoney = player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local lesserFragment = player:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local greaterFragment = player:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS)
	local value = bankMoney + characterMoney

	wheelWindow.moneyPanel.gold:setText(formatMoney(value, ","))
	wheelWindow.lesserFragmentPanel.gold:setText(lesserFragment)
	wheelWindow.greaterFragmentPanel.gold:setText(greaterFragment)
end
