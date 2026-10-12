local emptyPresetCodesByVocation = {
	[0] = "",
	"K0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"P0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"S0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"D0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"M0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
}

local function isNewPresetNameAvailable(presetName)
	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		if entry.presetName == presetName then
			return false
		end
	end

	return #presetName > 1
end

function WheelOfDestiny.showNewPreset(useEmptyPreset)
	hideWheelWindow()
	newPresetWindow:show()

	if not useEmptyPreset then
		selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.import)
	else
		selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.useEmpty)
	end

	newPresetWindow.contentPanel.presetName:clearText()
	newPresetWindow.contentPanel.presetCode:clearText()
	newPresetWindow.contentPanel.copyPreset:setText(string.format("Copy preset '%s'", WheelOfDestiny.currentPreset.presetName))
end

function WheelOfDestiny.onImportConfig(encodedPreset)
	if not encodedPreset or encodedPreset == "" then
		return {}
	end

	encodedPreset = encodedPreset:gsub("-", "+"):gsub("_", "/")

	local base64Remainder = #encodedPreset % 4

	if base64Remainder > 0 then
		encodedPreset = encodedPreset .. string.rep("=", 4 - base64Remainder)
	end

	if not base64.isValidBase64(encodedPreset) then
		return {}
	end

	local decodedPreset = base64.decode(encodedPreset)
	local maxPoints = string.unpack_custom("I2", decodedPreset)
	local pointInvested = {}
	local equippedGems = {}
	local readOffset = 3
	local usedPoints = 0
	local points = WheelOfDestiny.points
	local encodedSliceOrder = {
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
	local encodedSlicePoints = {}

	while readOffset <= #decodedPreset do
		local slicePoints = string.unpack_custom("I1", decodedPreset:sub(readOffset, readOffset))

		if points and points < usedPoints + slicePoints then
			slicePoints = points - usedPoints

			if slicePoints < 0 then
				slicePoints = 0
			end
		end

		table.insert(encodedSlicePoints, slicePoints)

		usedPoints = usedPoints + slicePoints
		readOffset = readOffset + 1

		if readOffset >= 39 then
			break
		end
	end

	for sliceIndex = 1, 36 do
		pointInvested[sliceIndex] = 0
	end

	for index, entry in ipairs(encodedSlicePoints) do
		if encodedSliceOrder[index] then
			pointInvested[encodedSliceOrder[index]] = entry
		end
	end

	while readOffset <= #decodedPreset do
		local gemId = string.unpack_custom("I1", decodedPreset:sub(readOffset, readOffset))

		if gemId == 255 then
			gemId = -1
		end

		table.insert(equippedGems, gemId)

		readOffset = readOffset + 1
	end

	while #equippedGems < 4 do
		table.insert(equippedGems, -1)
	end

	if maxPoints < usedPoints then
		return {}
	end

	return {
		maxPoints = maxPoints,
		usedPoints = usedPoints,
		pointInvested = pointInvested,
		equipedGems = equippedGems
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

	local function copyPresetCodeToClipboard()
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

	local function acceptPlannerUrlSelection()
		return true
	end

	local function cancelPresetExport()
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
			callback = copyPresetCodeToClipboard
		},
		{
			text = tr("URL"),
			callback = acceptPlannerUrlSelection
		},
		{
			text = tr("Cancel"),
			callback = cancelPresetExport
		}
	})
end

function WheelOfDestiny.onExportConfig()
	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)
	local pointInvested = WheelOfDestiny.pointInvested or {}

	if not WheelOfDestiny.equipedGems then
		local unusedValue = {}
	end

	local encodedChunks = {}
	local packedAvailablePoints = string.pack_custom("I2", totalAvailablePoints)

	if not packedAvailablePoints or packedAvailablePoints == "" then
		return ""
	end

	table.insert(encodedChunks, packedAvailablePoints)

	for unusedValue, entry in ipairs(pointInvested) do
		local packedSlicePoints = string.pack_custom("I1", entry)

		if packedSlicePoints and packedSlicePoints ~= "" then
			table.insert(encodedChunks, packedSlicePoints)
		end
	end

	local gemStruct = WheelOfDestiny.getGemStruct()
	local orderedGemDomains = {
		GemDomains.GREEN,
		GemDomains.RED,
		GemDomains.ACQUA,
		GemDomains.PURPLE
	}

	for unusedValue, entry in ipairs(orderedGemDomains) do
		local gemEntry = gemStruct[entry]
		local gemId = gemEntry and gemEntry.gemID or -1
		local packedGemId = string.pack_custom("I1", gemId < 0 and 255 or gemId)

		if packedGemId and packedGemId ~= "" then
			table.insert(encodedChunks, packedGemId)
		end
	end

	local binaryPreset = table.concat(encodedChunks)

	if not binaryPreset or binaryPreset == "" then
		return ""
	end

	local encodedPreset = base64.encode(binaryPreset)
	local formattedText = string.format("%s%s", getVocationSt(WheelOfDestiny.vocationId), encodedPreset)

	g_window.setClipboardText(formattedText)
end

function WheelOfDestiny.getExportCode(preset)
	if not preset or table.empty(preset) then
		return ""
	end

	local availablePoints = preset.availablePoints
	local pointInvested = preset.pointInvested or {}

	if not preset.equipedGems then
		local unusedValue = {}
	end

	local encodedChunks = {}
	local packedAvailablePoints = string.pack_custom("I2", availablePoints)

	if not packedAvailablePoints or packedAvailablePoints == "" then
		return ""
	end

	table.insert(encodedChunks, packedAvailablePoints)

	local encodedSliceOrder = {
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
	local encodedSlicePoints = {}

	for sliceIndex = 1, 36 do
		encodedSlicePoints[sliceIndex] = 0
	end

	for index, entry in ipairs(encodedSliceOrder) do
		encodedSlicePoints[index] = pointInvested[entry] or 0
	end

	for unusedValue, entry in ipairs(encodedSlicePoints) do
		local packedSlicePoints = string.pack_custom("I1", entry)

		if packedSlicePoints and packedSlicePoints ~= "" then
			table.insert(encodedChunks, packedSlicePoints)
		end
	end

	local gemStruct = WheelOfDestiny.getGemStruct(preset)
	local orderedGemDomains = {
		GemDomains.GREEN,
		GemDomains.RED,
		GemDomains.ACQUA,
		GemDomains.PURPLE
	}

	for unusedValue, entry in ipairs(orderedGemDomains) do
		local gemEntry = gemStruct[entry]
		local gemId = gemEntry and gemEntry.gemID or -1
		local packedGemId = string.pack_custom("I1", gemId < 0 and 255 or gemId)

		if packedGemId and packedGemId ~= "" then
			table.insert(encodedChunks, packedGemId)
		end
	end

	local binaryPreset = table.concat(encodedChunks)

	if not binaryPreset or binaryPreset == "" then
		return ""
	end

	local encodedPreset = base64.encode(binaryPreset)
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return ""
	end

	local vocation = translateWheelVocation(localPlayer:getVocation())

	return string.format("%s%s", getVocationSt(vocation), encodedPreset)
end

function WheelOfDestiny.onCancelConfig()
	showWheelWindow()
	newPresetWindow:hide()
end

function WheelOfDestiny.validateImportCode(exportCode)
	if not exportCode or exportCode == "" or #exportCode < 3 then
		return "Export code does not match a valid Wheel of Destiny."
	end

	local vocationPrefix = exportCode:sub(1, 2)
	local encodedPreset = exportCode:sub(3)

	if vocationPrefix ~= getVocationSt(WheelOfDestiny.vocationId) then
		return "Export code does not match the character's vocation."
	end

	if not encodedPreset or encodedPreset == "" then
		return "Export code does not match a valid Wheel of Destiny."
	end

	local importedPreset = WheelOfDestiny.onImportConfig(encodedPreset)

	if not importedPreset or table.empty(importedPreset) then
		return "Export code does not match a valid Wheel of Destiny."
	end

	return ""
end

function WheelOfDestiny.onEditCode(exportCode)
	selectedNewPresetRadio:selectWidget(newPresetWindow.contentPanel.import)

	local validationError = WheelOfDestiny.validateImportCode(exportCode)

	if not string.empty(validationError) then
		newPresetWindow.contentPanel.importTooltip:setVisible(true)
		newPresetWindow.contentPanel.importTooltip:setTooltip(validationError)
		newPresetWindow.contentPanel.ok:setEnabled(false)

		return
	end

	newPresetWindow.contentPanel.importTooltip:setVisible(false)

	local text = newPresetWindow.contentPanel.presetName:getText()
	local enabled = isNewPresetNameAvailable(text)

	newPresetWindow.contentPanel.ok:setEnabled(enabled)
end

function WheelOfDestiny.onEditName(presetName)
	newPresetWindow.contentPanel.presetNameTooltip:setVisible(not isNewPresetNameAvailable(presetName))

	local enabled = isNewPresetNameAvailable(presetName)
	local text = string.empty(WheelOfDestiny.validateImportCode(newPresetWindow.contentPanel.presetCode:getText()))

	if selectedNewPresetRadio:getSelectedWidget() == newPresetWindow.contentPanel.import then
		newPresetWindow.contentPanel.ok:setEnabled(enabled and text)

		return
	end

	newPresetWindow.contentPanel.ok:setEnabled(enabled)
end

function WheelOfDestiny.onNewPresetSelectionChange()
	local selectedWidget = selectedNewPresetRadio:getSelectedWidget()

	if not selectedWidget then
		return true
	end

	local text = newPresetWindow.contentPanel.presetName:getText()
	local enabled = isNewPresetNameAvailable(text)

	if selectedWidget == newPresetWindow.contentPanel.import then
		local text = newPresetWindow.contentPanel.presetCode:getText()
		local isImportCodeValid = string.empty(WheelOfDestiny.validateImportCode(text))

		newPresetWindow.contentPanel.ok:setEnabled(enabled and isImportCodeValid)

		return
	end

	newPresetWindow.contentPanel.ok:setEnabled(enabled)
end

function WheelOfDestiny.onConfirmCreatePreset()
	local selectedWidget = selectedNewPresetRadio:getSelectedWidget()

	if not selectedWidget then
		return true
	end

	local text = newPresetWindow.contentPanel.presetName:getText()

	if not isNewPresetNameAvailable(text) then
		return
	end

	local newPreset

	if selectedWidget == newPresetWindow.contentPanel.import then
		local exportCode = newPresetWindow.contentPanel.presetCode:getText()

		if exportCode:sub(1, 2) ~= getVocationSt(WheelOfDestiny.vocationId) then
			return
		end

		local encodedPreset = exportCode:sub(3)
		local importedPreset = WheelOfDestiny.onImportConfig(encodedPreset)

		if table.empty(importedPreset) then
			return
		end

		newPreset = {
			presetName = text,
			availablePoints = importedPreset.maxPoints,
			usedPoints = importedPreset.usedPoints,
			pointInvested = importedPreset.pointInvested,
			equipedGems = importedPreset.equipedGems
		}
	elseif selectedWidget == newPresetWindow.contentPanel.copyPreset then
		newPreset = table.copy(WheelOfDestiny.currentPreset)
		newPreset.presetName = text
	elseif selectedWidget == newPresetWindow.contentPanel.useEmpty then
		local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

		newPreset = {
			usedPoints = 0,
			presetName = text,
			availablePoints = totalAvailablePoints,
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
		newPreset.equipedGems = equipedGems
	end

	WheelOfDestiny.createPreset(text, newPreset)
	WheelOfDestiny.saveWheelPresets()

	local pointInvested = table.copy(newPreset.pointInvested)
	local equipedGems = table.copy(newPreset.equipedGems)

	WheelOfDestiny.resetWheel(true)

	WheelOfDestiny.currentPreset.pointInvested = pointInvested
	WheelOfDestiny.currentPreset.equipedGems = equipedGems

	local levelPoints = WheelOfDestiny.levelPoints or WheelOfDestiny.points or 0
	local unusedValue = newPreset.availablePoints - (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	WheelOfDestiny.create(WheelOfDestiny.playerId, WheelOfDestiny.canView, WheelOfDestiny.changeState, WheelOfDestiny.vocationId, levelPoints, WheelOfDestiny.scrollPoints, newPreset.pointInvested, WheelOfDestiny.usedPromotionScrolls, newPreset.equipedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade)

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

function WheelOfDestiny.onPresetNameChange(presetName)
	local enabled = isNewPresetNameAvailable(presetName)
	local selectedNewPresetWidget = selectedNewPresetRadio:getSelectedWidget()

	renamePresetWindow.contentPanel.presetNameTooltip:setVisible(not enabled)
	renamePresetWindow.contentPanel.ok:setEnabled(enabled)
end

function WheelOfDestiny.onConfirmRenamePreset(cancelRename)
	if cancelRename then
		renamePresetWindow:hide()
		showWheelWindow()

		return
	end

	local text = renamePresetWindow.contentPanel.presetName:getText()

	if not isNewPresetNameAvailable(text) then
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

	local function cancelPresetDeletion()
		deletePresetWindow:destroy()

		deletePresetWindow = nil

		showWheelWindow()
	end

	local function confirmPresetDeletion()
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
			callback = confirmPresetDeletion
		},
		{
			text = "No",
			callback = cancelPresetDeletion
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

local isConfiguringPresets = false

function WheelOfDestiny.configurePresets()
	if isConfiguringPresets then
		return
	end

	isConfiguringPresets = true

	local configuredSuccessfully, unusedValue = pcall(function()
		local presetList = wheelWindow:recursiveGetChildById("presetList")

		if not presetList then
			isConfiguringPresets = false

			return
		end

		if not presetList:isVisible() then
			isConfiguringPresets = false

			return
		end

		if table.empty(WheelOfDestiny.internalPreset) then
			WheelOfDestiny.loadWheelPresets()
		end

		presetList:destroyChildren()

		function presetList.onChildFocusChange(presetListWidget, focusedPresetWidget, previousPresetWidget)
			WheelOfDestiny.onPreparePresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)
		end

		if table.empty(WheelOfDestiny.internalPreset) then
			isConfiguringPresets = false

			return
		end

		table.sort(WheelOfDestiny.internalPreset, function(leftPreset, rightPreset)
			if not leftPreset or not leftPreset.presetName then
				return false
			end

			if not rightPreset or not rightPreset.presetName then
				return true
			end

			return leftPreset.presetName:lower() < rightPreset.presetName:lower()
		end)

		for key, entry in pairs(WheelOfDestiny.internalPreset) do
			local rowCreatedSuccessfully, unusedValue = pcall(function()
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

			if not rowCreatedSuccessfully then
				-- block empty
			end
		end

		local deletePreset = wheelWindow:recursiveGetChildById("deletePreset")

		if deletePreset then
			deletePreset:setEnabled(#WheelOfDestiny.internalPreset > 1)
		end
	end)

	isConfiguringPresets = false

	if not configuredSuccessfully then
		-- block empty
	end
end

function WheelOfDestiny.onPreparePresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)
	if not focusedPresetWidget or not focusedPresetWidget.presetData then
		return
	end

	if not previousPresetWidget or not previousPresetWidget.presetData then
		WheelOfDestiny.onPresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)

		return
	end

	local previousPresetPoints = previousPresetWidget.presetData.pointInvested or {}

	if table.compare(previousPresetPoints, WheelOfDestiny.pointInvested) then
		WheelOfDestiny.onPresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)

		return
	end

	if checkSavePresetWindow then
		checkSavePresetWindow:destroy()
	end

	hideWheelWindow()

	local function saveCurrentPresetChanges()
		if checkSavePresetWindow then
			checkSavePresetWindow:destroy()

			checkSavePresetWindow = nil
		end

		showWheelWindow()
		WheelOfDestiny.onWheelOfDestinyApply(false, false)
		WheelOfDestiny.updateCurrentPreset()

		return true
	end

	local function activatePresetWithoutSaving()
		if checkSavePresetWindow then
			checkSavePresetWindow:destroy()

			checkSavePresetWindow = nil
		end

		showWheelWindow()
		WheelOfDestiny.onPresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)

		return false
	end

	local formattedText = string.format("You have not saved the changes you made to preset '%s'.\nDo you want to save your current changes and active the preset?", WheelOfDestiny.currentPreset.presetName)

	checkSavePresetWindow = displayGeneralBox("Save?", formattedText, {
		{
			text = "Yes",
			callback = saveCurrentPresetChanges
		},
		{
			text = "No",
			callback = activatePresetWithoutSaving
		}
	})
end

function WheelOfDestiny.onPresetClick(presetListWidget, focusedPresetWidget, previousPresetWidget)
	if not focusedPresetWidget then
		return
	end

	if not focusedPresetWidget.presetData then
		return
	end

	local presetData = focusedPresetWidget.presetData

	if previousPresetWidget then
		local childIndex = presetListWidget:getChildIndex(previousPresetWidget)

		previousPresetWidget:setBackgroundColor(childIndex % 2 == 0 and "#484848" or "#414141")
		previousPresetWidget.name:setColor("#c0c0c0")
		previousPresetWidget.points:setColor("#c0c0c0")
	end

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and not localPlayer:hasState(PlayerStates.Pz) then
		local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

		toggleTabBarButtons("informationButton")
		managePresetsButton:setEnabled(false)
		refreshPresetTabBarButtons()

		return
	end

	focusedPresetWidget.name:setColor("#f4f4f4")
	focusedPresetWidget.points:setColor("#f4f4f4")

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

	local presetLevelPoints = presetData.availablePoints - (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	WheelOfDestiny.create(WheelOfDestiny.playerId, WheelOfDestiny.canView, WheelOfDestiny.changeState, WheelOfDestiny.vocationId, presetLevelPoints, WheelOfDestiny.scrollPoints, presetData.pointInvested, WheelOfDestiny.usedPromotionScrolls, presetData.equipedGems, WheelOfDestiny.atelierGems, WheelOfDestiny.basicModsUpgrade, WheelOfDestiny.supremeModsUpgrade)

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

	local levelPoints = WheelOfDestiny.points or 0
	local extraGemPoints = WheelOfDestiny.extraGemPoints or 0
	local availablePoints = levelPoints + (extraGemPoints + (WheelOfDestiny.scrollPoints or 0))

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

	local savedPresetPoints = WheelOfDestiny.currentPreset.pointInvested or {}
	local enabled = table.compare(savedPresetPoints, WheelOfDestiny.pointInvested)
	local manage = wheelWindow:recursiveGetChildById("manage")

	manage.applyPresetChanges:setEnabled(not enabled)
	manage.renamePreset:setEnabled(enabled)

	local close = wheelWindow:recursiveGetChildById("close")
	local ok = wheelWindow:recursiveGetChildById("ok")

	close:setText(enabled and "Close" or "Cancel")
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
				exportString = emptyPresetCodesByVocation[vocation]
			}
		}
	}
	local id = "/characterdata/" .. localPlayer:getId() .. "/wheelOfDestiny.json"

	if g_resources.fileExists(id) then
		local decodedSuccessfully, savedExternalPreset = pcall(function()
			return json.decode(g_resources.readFileContents(id))
		end)

		if not decodedSuccessfully then
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
		local vocationPrefix = exportString:sub(1, 2)
		local encodedPreset = exportString:sub(3)
		local importedPreset = WheelOfDestiny.onImportConfig(encodedPreset)

		if table.empty(importedPreset) or vocationPrefix ~= getVocationSt(vocation) then
			table.remove(WheelOfDestiny.externalPreset.presets, key)
		else
			table.insert(WheelOfDestiny.internalPreset, {
				presetName = preset.name,
				availablePoints = importedPreset.maxPoints,
				usedPoints = importedPreset.usedPoints,
				pointInvested = importedPreset.pointInvested,
				equipedGems = importedPreset.equipedGems
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

	local externalPreset = {
		presets = {}
	}

	for unusedValue, entry in pairs(WheelOfDestiny.internalPreset) do
		local exportCode = WheelOfDestiny.getExportCode(entry)

		if not string.empty(exportCode) and #exportCode < 10 then
			exportCode = emptyPresetCodesByVocation[translateWheelVocation(localPlayer:getVocation())]
		end

		if not string.empty(exportCode) then
			table.insert(externalPreset.presets, {
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

	local encodedSuccessfully, serializedPresets = pcall(function()
		return json.encode(externalPreset, 2)
	end)

	if not encodedSuccessfully then
		return false
	end

	if serializedPresets:len() > 104857600 then
		return false
	end

	g_resources.writeFileContents(fileName, serializedPresets)

	return true
end
