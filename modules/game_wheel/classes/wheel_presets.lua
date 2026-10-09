local var_0_0 = {
	[0] = "",
	"K0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"P0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"S0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"D0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"M0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
}

local function var_0_1(arg_1_0)
	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		if entry.presetName == arg_1_0 then
			return false
		end
	end

	return #arg_1_0 > 1
end

function WheelOfDestiny.showNewPreset(arg_2_0)
	hideWheelWindow()
	newPresetWindow:show()

	if not arg_2_0 then
		selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.import)
	else
		selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.useEmpty)
	end

	newPresetWindow.contentPanel.presetName:clearText()
	newPresetWindow.contentPanel.presetCode:clearText()
	newPresetWindow.contentPanel.copyPreset:setText(string.format("Copy preset '%s'", WheelOfDestiny.currentPreset.presetName))
end

function WheelOfDestiny.onImportConfig(arg_3_0)
	if not arg_3_0 or arg_3_0 == "" then
		return {}
	end

	arg_3_0 = arg_3_0:gsub("-", "+"):gsub("_", "/")

	local var_3_0 = #arg_3_0 % 4

	if var_3_0 > 0 then
		arg_3_0 = arg_3_0 .. string.rep("=", 4 - var_3_0)
	end

	if not base64.isValidBase64(arg_3_0) then
		return {}
	end

	local var_3_1 = base64.decode(arg_3_0)
	local var_3_2 = string.unpack_custom("I2", var_3_1)
	local var_3_3 = {}
	local var_3_4 = {}
	local var_3_5 = 3
	local var_3_6 = 0
	local points = WheelOfDestiny.points
	local var_3_8 = {
		15,
		14,
		9,
		13,
		8,
		3,
		7,
		2,
		1,
		16,
		17,
		10,
		18,
		11,
		4,
		12,
		5,
		6,
		22,
		23,
		28,
		24,
		29,
		34,
		30,
		35,
		36,
		21,
		20,
		27,
		19,
		26,
		33,
		32,
		25,
		31
	}
	local var_3_9 = {}

	while var_3_5 <= #var_3_1 do
		local var_3_10 = string.unpack_custom("I1", var_3_1:sub(var_3_5, var_3_5))

		if points and points < var_3_6 + var_3_10 then
			var_3_10 = points - var_3_6

			if var_3_10 < 0 then
				var_3_10 = 0
			end
		end

		table.insert(var_3_9, var_3_10)

		var_3_6 = var_3_6 + var_3_10
		var_3_5 = var_3_5 + 1

		if var_3_5 >= 39 then
			break
		end
	end

	for iter_3_0 = 1, 36 do
		var_3_3[iter_3_0] = 0
	end

	for index, entry in ipairs(var_3_9) do
		if var_3_8[index] then
			var_3_3[var_3_8[index]] = entry
		end
	end

	while var_3_5 <= #var_3_1 do
		local var_3_11 = string.unpack_custom("I1", var_3_1:sub(var_3_5, var_3_5))

		if var_3_11 == 255 then
			var_3_11 = -1
		end

		table.insert(var_3_4, var_3_11)

		var_3_5 = var_3_5 + 1
	end

	while #var_3_4 < 4 do
		table.insert(var_3_4, -1)
	end

	if var_3_2 < var_3_6 then
		return {}
	end

	return {
		maxPoints = var_3_2,
		usedPoints = var_3_6,
		pointInvested = var_3_3,
		equipedGems = var_3_4
	}
end

function WheelOfDestiny.onImportPreset()
	WheelOfDestiny.showNewPreset(false)
	newPresetWindow.contentPanel.presetCode:focus()
end

function WheelOfDestiny.onExportPreset()
	if exportCodeWindow then
		exportCodeWindow:destroy()

		exportCodeWindow = nil
	end

	hideWheelWindow()

	local function var_5_0()
		if exportCodeWindow then
			exportCodeWindow:destroy()

			exportCodeWindow = nil
		end

		showWheelWindow()

		local exportCode = WheelOfDestiny.getExportCode(WheelOfDestiny.currentPreset)

		if exportCode and exportCode ~= "" then
			g_window.setClipboardText(exportCode)
		end

		return true
	end

	local function var_5_1()
		return true
	end

	local function var_5_2()
		if exportCodeWindow then
			exportCodeWindow:destroy()

			exportCodeWindow = nil
		end

		showWheelWindow()

		return false
	end

	exportCodeWindow = displayGeneralBox("Copy to Clipboard", tr("Copy export code or URL of the planner to clipboard."), {
		{
			text = tr("Code"),
			callback = var_5_0
		},
		{
			text = tr("URL"),
			callback = var_5_1
		},
		{
			text = tr("Cancel"),
			callback = var_5_2
		}
	})
end

function WheelOfDestiny.onExportConfig()
	local var_9_0 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)
	local var_9_1 = WheelOfDestiny.pointInvested or {}

	if not WheelOfDestiny.equipedGems then
		local unusedValue = {}
	end

	local var_9_3 = {}
	local var_9_4 = string.pack_custom("I2", var_9_0)

	if not var_9_4 or var_9_4 == "" then
		return ""
	end

	table.insert(var_9_3, var_9_4)

	for unusedValue, entry in ipairs(var_9_1) do
		local var_9_5 = string.pack_custom("I1", entry)

		if var_9_5 and var_9_5 ~= "" then
			table.insert(var_9_3, var_9_5)
		end
	end

	local gemStruct = WheelOfDestiny.getGemStruct()
	local var_9_7 = {
		GemDomains.GREEN,
		GemDomains.RED,
		GemDomains.ACQUA,
		GemDomains.PURPLE
	}

	for unusedValue, entry in ipairs(var_9_7) do
		local var_9_8 = gemStruct[entry]
		local var_9_9 = var_9_8 and var_9_8.gemID or -1
		local var_9_10 = string.pack_custom("I1", var_9_9 < 0 and 255 or var_9_9)

		if var_9_10 and var_9_10 ~= "" then
			table.insert(var_9_3, var_9_10)
		end
	end

	local var_9_11 = table.concat(var_9_3)

	if not var_9_11 or var_9_11 == "" then
		return ""
	end

	local var_9_12 = base64.encode(var_9_11)
	local formattedText = string.format("%s%s", getVocationSt(WheelOfDestiny.vocationId), var_9_12)

	g_window.setClipboardText(formattedText)
end

function WheelOfDestiny.getExportCode(arg_10_0)
	if not arg_10_0 or table.empty(arg_10_0) then
		return ""
	end

	local availablePoints = arg_10_0.availablePoints
	local var_10_1 = arg_10_0.pointInvested or {}

	if not arg_10_0.equipedGems then
		local unusedValue = {}
	end

	local var_10_3 = {}
	local var_10_4 = string.pack_custom("I2", availablePoints)

	if not var_10_4 or var_10_4 == "" then
		return ""
	end

	table.insert(var_10_3, var_10_4)

	local var_10_5 = {
		15,
		14,
		9,
		13,
		8,
		3,
		7,
		2,
		1,
		16,
		17,
		10,
		18,
		11,
		4,
		12,
		5,
		6,
		22,
		23,
		28,
		24,
		29,
		34,
		30,
		35,
		36,
		21,
		20,
		27,
		19,
		26,
		33,
		32,
		25,
		31
	}
	local var_10_6 = {}

	for iter_10_0 = 1, 36 do
		var_10_6[iter_10_0] = 0
	end

	for index, entry in ipairs(var_10_5) do
		var_10_6[index] = var_10_1[entry] or 0
	end

	for unusedValue, entry in ipairs(var_10_6) do
		local var_10_7 = string.pack_custom("I1", entry)

		if var_10_7 and var_10_7 ~= "" then
			table.insert(var_10_3, var_10_7)
		end
	end

	local gemStruct = WheelOfDestiny.getGemStruct(arg_10_0)
	local var_10_9 = {
		GemDomains.GREEN,
		GemDomains.RED,
		GemDomains.ACQUA,
		GemDomains.PURPLE
	}

	for unusedValue, entry in ipairs(var_10_9) do
		local var_10_10 = gemStruct[entry]
		local var_10_11 = var_10_10 and var_10_10.gemID or -1
		local var_10_12 = string.pack_custom("I1", var_10_11 < 0 and 255 or var_10_11)

		if var_10_12 and var_10_12 ~= "" then
			table.insert(var_10_3, var_10_12)
		end
	end

	local var_10_13 = table.concat(var_10_3)

	if not var_10_13 or var_10_13 == "" then
		return ""
	end

	local var_10_14 = base64.encode(var_10_13)
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return ""
	end

	local vocation = translateWheelVocation(localPlayer:getVocation())

	return string.format("%s%s", getVocationSt(vocation), var_10_14)
end

function WheelOfDestiny.onCancelConfig()
	showWheelWindow()
	newPresetWindow:hide()
end

function WheelOfDestiny.validateImportCode(arg_12_0)
	if not arg_12_0 or arg_12_0 == "" or #arg_12_0 < 3 then
		return "Export code does not match a valid Wheel of Destiny."
	end

	local var_12_0 = arg_12_0:sub(1, 2)
	local var_12_1 = arg_12_0:sub(3)

	if var_12_0 ~= getVocationSt(WheelOfDestiny.vocationId) then
		return "Export code does not match the character's vocation."
	end

	if not var_12_1 or var_12_1 == "" then
		return "Export code does not match a valid Wheel of Destiny."
	end

	local var_12_2 = WheelOfDestiny.onImportConfig(var_12_1)

	if not var_12_2 or table.empty(var_12_2) then
		return "Export code does not match a valid Wheel of Destiny."
	end

	return ""
end

function WheelOfDestiny.onEditCode(arg_13_0)
	selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.import)

	local var_13_0 = WheelOfDestiny.validateImportCode(arg_13_0)

	if not string.empty(var_13_0) then
		newPresetWindow.contentPanel.importTooltip:setVisible(true)
		newPresetWindow.contentPanel.importTooltip:setTooltip(var_13_0)
		newPresetWindow.contentPanel.ok:setEnabled(false)

		return
	end

	newPresetWindow.contentPanel.importTooltip:setVisible(false)

	local text = newPresetWindow.contentPanel.presetName:getText()
	local var_13_2 = var_0_1(text)

	newPresetWindow.contentPanel.ok:setEnabled(var_13_2)
end

function WheelOfDestiny.onEditName(arg_14_0)
	newPresetWindow.contentPanel.presetNameTooltip:setVisible(not var_0_1(arg_14_0))

	local var_14_0 = var_0_1(arg_14_0)
	local text = string.empty(WheelOfDestiny.validateImportCode(newPresetWindow.contentPanel.presetCode:getText()))

	if selectedNewPresetRadio:getSelectedWidget() == newPresetWindow.contentPanel.import then
		newPresetWindow.contentPanel.ok:setEnabled(var_14_0 and text)

		return
	end

	newPresetWindow.contentPanel.ok:setEnabled(var_14_0)
end

function WheelOfDestiny.onNewPresetSelectionChange()
	local selectedWidget = selectedNewPresetRadio:getSelectedWidget()

	if not selectedWidget then
		return true
	end

	local text = newPresetWindow.contentPanel.presetName:getText()
	local var_15_2 = var_0_1(text)

	if selectedWidget == newPresetWindow.contentPanel.import then
		local text = newPresetWindow.contentPanel.presetCode:getText()
		local var_15_4 = string.empty(WheelOfDestiny.validateImportCode(text))

		newPresetWindow.contentPanel.ok:setEnabled(var_15_2 and var_15_4)

		return
	end

	newPresetWindow.contentPanel.ok:setEnabled(var_15_2)
end

function WheelOfDestiny.onConfirmCreatePreset()
	local selectedWidget = selectedNewPresetRadio:getSelectedWidget()

	if not selectedWidget then
		return true
	end

	local text = newPresetWindow.contentPanel.presetName:getText()

	if not var_0_1(text) then
		return
	end

	local var_16_2

	if selectedWidget == newPresetWindow.contentPanel.import then
		local var_16_3 = newPresetWindow.contentPanel.presetCode:getText()

		if var_16_3:sub(1, 2) ~= getVocationSt(WheelOfDestiny.vocationId) then
			return
		end

		local var_16_4 = var_16_3:sub(3)
		local var_16_5 = WheelOfDestiny.onImportConfig(var_16_4)

		if table.empty(var_16_5) then
			return
		end

		var_16_2 = {
			presetName = text,
			availablePoints = var_16_5.maxPoints,
			usedPoints = var_16_5.usedPoints,
			pointInvested = var_16_5.pointInvested,
			equipedGems = var_16_5.equipedGems
		}
	elseif selectedWidget == newPresetWindow.contentPanel.copyPreset then
		var_16_2 = table.copy(WheelOfDestiny.currentPreset)
		var_16_2.presetName = text
	elseif selectedWidget == newPresetWindow.contentPanel.useEmpty then
		local var_16_6 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

		var_16_2 = {
			usedPoints = 0,
			presetName = text,
			availablePoints = var_16_6,
			pointInvested = table.reserve(36, 0),
			equipedGems = {
				-1,
				-1,
				-1,
				-1
			}
		}
	else
		return
	end

	showWheelWindow()
	newPresetWindow:hide()

	local equipedGems = table.copy(WheelOfDestiny.equipedGems)
	local atelierGems = WheelOfDestiny.atelierGems
	local basicModsUpgrade = WheelOfDestiny.basicModsUpgrade
	local supremeModsUpgrade = WheelOfDestiny.supremeModsUpgrade

	if selectedWidget == newPresetWindow.contentPanel.import then
		var_16_2.equipedGems = equipedGems
	end

	WheelOfDestiny.createPreset(text, var_16_2)
	WheelOfDestiny.saveWheelPresets()

	local pointInvested = table.copy(var_16_2.pointInvested)
	local equipedGems = table.copy(var_16_2.equipedGems)

	WheelOfDestiny.resetWheel(true)

	WheelOfDestiny.currentPreset.pointInvested = pointInvested
	WheelOfDestiny.currentPreset.equipedGems = equipedGems

	local var_16_13 = WheelOfDestiny.levelPoints or WheelOfDestiny.points or 0
	local unusedValue = var_16_2.availablePoints - (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	WheelOfDestiny.create(WheelOfDestiny.playerId, WheelOfDestiny.canView, WheelOfDestiny.changeState, WheelOfDestiny.vocationId, var_16_13, WheelOfDestiny.scrollPoints, var_16_2.pointInvested, WheelOfDestiny.usedPromotionScrolls, var_16_2.equipedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	local presetLabel = wheelWindow:recursiveGetChildById("presetLabel")

	if presetLabel then
		presetLabel:setText(string.format("Current Preset: %s", text))
	end

	local hotCopy = wheelWindow:recursiveGetChildById("hotCopy")

	if hotCopy then
		function hotCopy.onClick()
			WheelOfDestiny.onExportConfig()
		end
	end

	local manage = wheelWindow:recursiveGetChildById("manage")

	if manage then
		manage.applyPresetChanges:setEnabled(false)
		manage.renamePreset:setEnabled(true)
	end

	toggleTabBarButtons("managePresetsButton")
	scheduleEvent(function()
		WheelOfDestiny.configurePresets()

		local presetList = wheelWindow:recursiveGetChildById("presetList")

		if presetList then
			for unusedValue, child in ipairs(presetList:getChildren()) do
				if child.presetData and child.presetData.presetName == text then
					presetList:focusChild(child)

					break
				end
			end
		end
	end, 100)
end

function WheelOfDestiny.createPreset(unusedArgument, currentPreset)
	WheelOfDestiny.currentPreset = currentPreset

	table.insert(WheelOfDestiny.internalPreset, currentPreset)
end

function WheelOfDestiny.changePresetName(presetName)
	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		if entry.presetName == WheelOfDestiny.currentPreset.presetName then
			entry.presetName = presetName
		end
	end
end

function WheelOfDestiny.onRenamePreset()
	hideWheelWindow()
	renamePresetWindow:show()
	renamePresetWindow.contentPanel.presetName:setText(WheelOfDestiny.currentPreset.presetName)
	renamePresetWindow:grabMouse()
	renamePresetWindow:grabKeyboard()
end

function WheelOfDestiny.onPresetNameChange(arg_22_0)
	local var_22_0 = var_0_1(arg_22_0)
	local var_22_1 = selectedNewPresetRadio:getSelectedWidget()

	renamePresetWindow.contentPanel.presetNameTooltip:setVisible(not var_22_0)
	renamePresetWindow.contentPanel.ok:setEnabled(var_22_0)
end

function WheelOfDestiny.onConfirmRenamePreset(arg_23_0)
	if arg_23_0 then
		renamePresetWindow:hide()
		showWheelWindow()

		return
	end

	local text = renamePresetWindow.contentPanel.presetName:getText()

	if not var_0_1(text) then
		return
	end

	WheelOfDestiny.changePresetName(text)

	WheelOfDestiny.currentPreset.presetName = text

	renamePresetWindow:hide()
	showWheelWindow()
	WheelOfDestiny.configurePresets()
	WheelOfDestiny.saveWheelPresets()
end

function WheelOfDestiny.onDeletePreset()
	if deletePresetWindow then
		deletePresetWindow:destroy()
	end

	hideWheelWindow()

	local function var_24_0()
		deletePresetWindow:destroy()

		deletePresetWindow = nil

		showWheelWindow()
	end

	local function var_24_1()
		WheelOfDestiny.deletePreset()
		showWheelWindow()
		deletePresetWindow:destroy()

		deletePresetWindow = nil

		WheelOfDestiny.configurePresets()
		WheelOfDestiny.saveWheelPresets()
	end

	local formattedText = string.format("Do you really  want to delete the preset '%s'?", WheelOfDestiny.currentPreset.presetName)

	deletePresetWindow = displayGeneralBox("Delete Preset", formattedText, {
		{
			text = "Yes",
			callback = var_24_1
		},
		{
			text = "No",
			callback = var_24_0
		}
	})
end

function WheelOfDestiny.deletePreset()
	local currentPreset = WheelOfDestiny.currentPreset

	for key, entry in pairs(WheelOfDestiny.internalPreset) do
		if entry.presetName == currentPreset.presetName then
			table.remove(WheelOfDestiny.internalPreset, key)

			break
		end
	end

	WheelOfDestiny.currentPreset = WheelOfDestiny.internalPreset[1]
end

local var_0_2 = false

function WheelOfDestiny.configurePresets()
	if var_0_2 then
		return
	end

	var_0_2 = true

	local var_28_0, unusedValue = pcall(function()
		local presetList = wheelWindow:recursiveGetChildById("presetList")

		if not presetList then
			var_0_2 = false

			return
		end

		if not presetList:isVisible() then
			var_0_2 = false

			return
		end

		if table.empty(WheelOfDestiny.internalPreset) then
			WheelOfDestiny.loadWheelPresets()
		end

		presetList:destroyChildren()

		function presetList.onChildFocusChange(arg_30_0, arg_30_1, arg_30_2)
			WheelOfDestiny.onPreparePresetClick(arg_30_0, arg_30_1, arg_30_2)
		end

		if table.empty(WheelOfDestiny.internalPreset) then
			var_0_2 = false

			return
		end

		table.sort(WheelOfDestiny.internalPreset, function(arg_31_0, arg_31_1)
			if not arg_31_0 or not arg_31_0.presetName then
				return false
			end

			if not arg_31_1 or not arg_31_1.presetName then
				return true
			end

			return arg_31_0.presetName:lower() < arg_31_1.presetName:lower()
		end)

		for key, entry in pairs(WheelOfDestiny.internalPreset) do
			local var_29_1, unusedValue = pcall(function()
				local presetLabelWidget = g_ui.createWidget("PresetLabel", presetList)

				if not presetLabelWidget then
					return
				end

				local name = presetLabelWidget:getChildById("name")
				local points = presetLabelWidget:getChildById("points")

				if name then
					name:setText(entry.presetName or "Unknown")
				end

				if points then
					local textValue = tostring((entry.availablePoints or 0) - (entry.usedPoints or 0))

					points:setText(textValue)
				end

				presetLabelWidget:setBackgroundColor(key % 2 == 0 and "#484848" or "#414141")

				presetLabelWidget.presetData = entry

				if WheelOfDestiny.currentPreset and WheelOfDestiny.currentPreset.presetName == entry.presetName then
					presetList:focusChild(presetLabelWidget)
				end
			end)

			if not var_29_1 then
				-- block empty
			end
		end

		local deletePreset = wheelWindow:recursiveGetChildById("deletePreset")

		if deletePreset then
			deletePreset:setEnabled(#WheelOfDestiny.internalPreset > 1)
		end
	end)

	var_0_2 = false

	if not var_28_0 then
		-- block empty
	end
end

function WheelOfDestiny.onPreparePresetClick(arg_33_0, arg_33_1, arg_33_2)
	if not arg_33_1 or not arg_33_1.presetData then
		return
	end

	if not arg_33_2 or not arg_33_2.presetData then
		WheelOfDestiny.onPresetClick(arg_33_0, arg_33_1, arg_33_2)

		return
	end

	local var_33_0 = arg_33_2.presetData.pointInvested or {}

	if table.compare(var_33_0, WheelOfDestiny.pointInvested) then
		WheelOfDestiny.onPresetClick(arg_33_0, arg_33_1, arg_33_2)

		return
	end

	if checkSavePresetWindow then
		checkSavePresetWindow:destroy()
	end

	hideWheelWindow()

	local function var_33_1()
		if checkSavePresetWindow then
			checkSavePresetWindow:destroy()

			checkSavePresetWindow = nil
		end

		showWheelWindow()
		WheelOfDestiny.onWheelOfDestinyApply(false, false)
		WheelOfDestiny.updateCurrentPreset()

		return true
	end

	local function var_33_2()
		if checkSavePresetWindow then
			checkSavePresetWindow:destroy()

			checkSavePresetWindow = nil
		end

		showWheelWindow()
		WheelOfDestiny.onPresetClick(arg_33_0, arg_33_1, arg_33_2)

		return false
	end

	local formattedText = string.format("You have not saved the changes you made to preset '%s'.\nDo you want to save your current changes and active the preset?", WheelOfDestiny.currentPreset.presetName)

	checkSavePresetWindow = displayGeneralBox("Save?", formattedText, {
		{
			text = "Yes",
			callback = var_33_1
		},
		{
			text = "No",
			callback = var_33_2
		}
	})
end

function WheelOfDestiny.onPresetClick(arg_36_0, arg_36_1, arg_36_2)
	if not arg_36_1 then
		return
	end

	if not arg_36_1.presetData then
		return
	end

	local presetData = arg_36_1.presetData

	if arg_36_2 then
		local childIndex = arg_36_0:getChildIndex(arg_36_2)

		arg_36_2:setBackgroundColor(childIndex % 2 == 0 and "#484848" or "#414141")
		arg_36_2.name:setColor("#c0c0c0")
		arg_36_2.points:setColor("#c0c0c0")
	end

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and not localPlayer:hasState(PlayerStates.Pz) then
		local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

		toggleTabBarButtons("informationButton")
		managePresetsButton:setEnabled(false)
		refreshPresetTabBarButtons()

		return
	end

	arg_36_1.name:setColor("#f4f4f4")
	arg_36_1.points:setColor("#f4f4f4")

	WheelOfDestiny.currentPreset = presetData

	wheelWindow:recursiveGetChildById("presetLabel"):setText(string.format("Current Preset: %s", presetData.presetName))

	wheelWindow:recursiveGetChildById("hotCopy").onClick = function()
		WheelOfDestiny.onExportConfig()
	end

	local manage = wheelWindow:recursiveGetChildById("manage")

	manage.applyPresetChanges:setEnabled(false)
	manage.renamePreset:setEnabled(true)
	wheelWindow:recursiveGetChildById("deletePreset"):setEnabled(#WheelOfDestiny.internalPreset > 1)

	local pointInvested = table.copy(WheelOfDestiny.currentPreset.pointInvested)
	local equipedGems = table.copy(WheelOfDestiny.currentPreset.equipedGems)

	WheelOfDestiny.resetWheel(true)

	WheelOfDestiny.currentPreset.pointInvested = pointInvested
	WheelOfDestiny.currentPreset.equipedGems = equipedGems

	local var_36_7 = presetData.availablePoints - (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	WheelOfDestiny.create(WheelOfDestiny.playerId, WheelOfDestiny.canView, WheelOfDestiny.changeState, WheelOfDestiny.vocationId, var_36_7, WheelOfDestiny.scrollPoints, presetData.pointInvested, WheelOfDestiny.usedPromotionScrolls, presetData.equipedGems, WheelOfDestiny.atelierGems, WheelOfDestiny.basicModsUpgrade, WheelOfDestiny.supremeModsUpgrade)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end
end

function WheelOfDestiny.determinateCurrentPreset()
	local localGemStruct = WheelOfDestiny.getLocalGemStruct()

	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		local pointInvested = entry.pointInvested
		local equipedGems = entry.equipedGems

		if table.compare(pointInvested, WheelOfDestiny.pointInvested) and table.compare(equipedGems, localGemStruct) then
			WheelOfDestiny.currentPreset = entry

			wheelWindow:recursiveGetChildById("presetLabel"):setText(string.format("Current Preset: %s", entry.presetName))

			wheelWindow:recursiveGetChildById("hotCopy").onClick = function()
				WheelOfDestiny.onExportConfig()
			end

			return
		end
	end

	if (not WheelOfDestiny.currentPreset or table.empty(WheelOfDestiny.currentPreset)) and not table.empty(WheelOfDestiny.internalPreset) then
		WheelOfDestiny.currentPreset = WheelOfDestiny.internalPreset[1]

		local presetLabel = wheelWindow:recursiveGetChildById("presetLabel")

		if presetLabel then
			presetLabel:setText(string.format("Current Preset: %s", WheelOfDestiny.currentPreset.presetName))
		end
	end
end

function WheelOfDestiny.updateCurrentPreset()
	if not WheelOfDestiny.currentPreset then
		return
	end

	if not g_game.getLocalPlayer() then
		return
	end

	WheelOfDestiny.currentPreset.pointInvested = WheelOfDestiny.pointInvested or {}
	WheelOfDestiny.currentPreset.equipedGems = WheelOfDestiny.getLocalGemStruct()
	WheelOfDestiny.currentPreset.usedPoints = WheelOfDestiny.usedPoints or 0

	local var_40_0 = WheelOfDestiny.points or 0
	local extraGemPoints = WheelOfDestiny.extraGemPoints or 0
	local availablePoints = var_40_0 + (extraGemPoints + (WheelOfDestiny.scrollPoints or 0))

	WheelOfDestiny.currentPreset.availablePoints = availablePoints
	WheelOfDestiny.currentPreset.extraGemPoints = extraGemPoints
	WheelOfDestiny.currentPreset.presetName = WheelOfDestiny.currentPreset.presetName or "Default-Preset"

	for key, entry in pairs(WheelOfDestiny.internalPreset) do
		if entry.presetName == WheelOfDestiny.currentPreset.presetName then
			WheelOfDestiny.internalPreset[key] = WheelOfDestiny.currentPreset

			break
		end
	end

	WheelOfDestiny.configurePresets()
end

function WheelOfDestiny.checkApplyButton()
	if WheelOfDestiny.isPreview then
		return
	end

	local var_41_0 = WheelOfDestiny.currentPreset.pointInvested or {}
	local var_41_1 = table.compare(var_41_0, WheelOfDestiny.pointInvested)
	local manage = wheelWindow:recursiveGetChildById("manage")

	manage.applyPresetChanges:setEnabled(not var_41_1)
	manage.renamePreset:setEnabled(var_41_1)

	local close = wheelWindow:recursiveGetChildById("close")
	local ok = wheelWindow:recursiveGetChildById("ok")

	close:setText(var_41_1 and "Close" or "Cancel")
	ok:setEnabled(true)
end

function WheelOfDestiny.loadWheelPresets()
	WheelOfDestiny.externalPreset = {}
	WheelOfDestiny.internalPreset = {}

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return false
	end

	local vocation = translateWheelVocation(localPlayer:getVocation())
	local externalPreset = {
		presets = {
			{
				name = "Default-Preset",
				exportString = var_0_0[vocation]
			}
		}
	}
	local id = "/characterdata/" .. localPlayer:getId() .. "/wheelOfDestiny.json"

	if g_resources.fileExists(id) then
		local var_42_4, savedExternalPreset = pcall(function()
			return json.decode(g_resources.readFileContents(id))
		end)

		if not var_42_4 then
			WheelOfDestiny.externalPreset = externalPreset

			WheelOfDestiny.generateInternalPreset()

			return false
		end

		if savedExternalPreset.presets == nil or #savedExternalPreset.presets == 0 then
			WheelOfDestiny.externalPreset = externalPreset
		else
			WheelOfDestiny.externalPreset = savedExternalPreset
		end
	else
		WheelOfDestiny.externalPreset = externalPreset
	end

	WheelOfDestiny.generateInternalPreset()

	return true
end

function WheelOfDestiny.generateInternalPreset()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local vocation = translateWheelVocation(localPlayer:getVocation())

	for key, preset in pairs(WheelOfDestiny.externalPreset.presets) do
		local exportString = preset.exportString
		local var_44_3 = exportString:sub(1, 2)
		local var_44_4 = exportString:sub(3)
		local var_44_5 = WheelOfDestiny.onImportConfig(var_44_4)

		if table.empty(var_44_5) or var_44_3 ~= getVocationSt(vocation) then
			table.remove(WheelOfDestiny.externalPreset.presets, key)
		else
			table.insert(WheelOfDestiny.internalPreset, {
				presetName = preset.name,
				availablePoints = var_44_5.maxPoints,
				usedPoints = var_44_5.usedPoints,
				pointInvested = var_44_5.pointInvested,
				equipedGems = var_44_5.equipedGems
			})
		end
	end
end

function WheelOfDestiny.saveWheelPresets()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return false
	end

	if table.empty(WheelOfDestiny.internalPreset) then
		return false
	end

	local var_45_1 = {
		presets = {}
	}

	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		local exportCode = WheelOfDestiny.getExportCode(entry)

		if not string.empty(exportCode) and #exportCode < 10 then
			exportCode = var_0_0[translateWheelVocation(localPlayer:getVocation())]
		end

		if not string.empty(exportCode) then
			table.insert(var_45_1.presets, {
				exportString = exportCode,
				name = entry.presetName
			})
		end
	end

	local id = "/characterdata/" .. localPlayer:getId()
	local fileName = id .. "/wheelOfDestiny.json"

	if not g_resources.directoryExists(id) then
		local unusedValue = g_resources.makeDir(id)
	end

	local var_45_6, var_45_7 = pcall(function()
		return json.encode(var_45_1, 2)
	end)

	if not var_45_6 then
		return false
	end

	if var_45_7:len() > 104857600 then
		return false
	end

	g_resources.writeFileContents(fileName, var_45_7)

	return true
end
