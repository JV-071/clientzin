local wheelAccessInfoBox
local activeStateRequestTimeoutEvent

local function createEmptyWheelPoints()
	local emptyPoints = {}

	for sliceIndex = 1, 36 do
		emptyPoints[sliceIndex] = 0
	end

	return emptyPoints
end

local function copyNumericWheelState(state)
	local copiedState = {}

	if type(state) ~= "table" then
		return copiedState
	end

	for key, entry in pairs(state) do
		copiedState[key] = tonumber(entry) or 0
	end

	return copiedState
end

function WheelOfDestiny.clearActiveState()
	WheelOfDestiny.activeState = {
		ready = false
	}
end

function WheelOfDestiny.getActiveState()
	return WheelOfDestiny.activeState
end

function WheelOfDestiny.cancelActiveStateRequest()
	WheelOfDestiny.backgroundRequestPending = false

	if activeStateRequestTimeoutEvent then
		removeEvent(activeStateRequestTimeoutEvent)

		activeStateRequestTimeoutEvent = nil
	end
end

function WheelOfDestiny.requestActiveState()
	if WheelOfDestiny.backgroundRequestPending or not g_game.isOnline() or not g_game.openWheel then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return false
	end

	WheelOfDestiny.backgroundRequestPending = true
	activeStateRequestTimeoutEvent = scheduleEvent(function()
		activeStateRequestTimeoutEvent = nil
		WheelOfDestiny.backgroundRequestPending = false

		if g_logger and g_logger.warning then
			g_logger.warning("[wheel] Timed out while requesting the active Wheel state.")
		end
	end, 3000)

	g_game.openWheel(localPlayer:getId())

	return true
end

function WheelOfDestiny.captureActiveState(playerId)
	WheelOfDestiny.activeState = {
		ready = true,
		playerId = playerId,
		vocationId = WheelOfDestiny.vocationId,
		pointInvested = copyNumericWheelState(WheelOfDestiny.pointInvested),
		passivePoints = copyNumericWheelState(WheelOfDestiny.passivePoints),
		extraPassivePoints = copyNumericWheelState(WheelOfDestiny.extraPassivePoints)
	}
end

function WheelOfDestiny.setPreviewMode(isPreview)
	WheelOfDestiny.isPreview = isPreview

	if not wheelWindow then
		return
	end

	if isPreview then
		wheelWindow:setText(tr("Wheel of Destiny - Preview"))
	else
		wheelWindow:setText(tr("Wheel Of Destiny"))
	end

	if wheelWindow.reset then
		wheelWindow.reset:setVisible(not isPreview)
	end

	if wheelWindow.apply then
		wheelWindow.apply:setVisible(not isPreview)
	end

	if wheelWindow.ok then
		wheelWindow.ok:setVisible(not isPreview)
	end

	if wheelWindow.close then
		wheelWindow.close:setText(tr("Close"))
	end
end

local function normalizeEquippedGemIds(equippedGems)
	if type(equippedGems) ~= "table" then
		return {
			-1,
			-1,
			-1,
			-1
		}
	end

	local gemIds = {}
	local hasGemRecords = false

	for unusedValue, entry in pairs(equippedGems) do
		if type(entry) == "table" and entry.gemID ~= nil then
			hasGemRecords = true

			break
		end
	end

	if hasGemRecords then
		local orderedGemDomains = {
			GemDomains.GREEN,
			GemDomains.RED,
			GemDomains.ACQUA,
			GemDomains.PURPLE
		}

		for unusedValue, entry in ipairs(orderedGemDomains) do
			local gemEntry = equippedGems[entry]
			local gemId = type(gemEntry) == "table" and tonumber(gemEntry.gemID) or tonumber(gemEntry)

			table.insert(gemIds, gemId or -1)
		end
	else
		for unusedValue, entry in ipairs(equippedGems) do
			local numericValue = tonumber(entry)

			table.insert(gemIds, numericValue or -1)
		end

		if #gemIds == 0 then
			for unusedValue, entry in pairs(equippedGems) do
				local numericValue = tonumber(entry)

				table.insert(gemIds, numericValue or -1)
			end
		end
	end

	while #gemIds < 4 do
		table.insert(gemIds, -1)
	end

	return gemIds
end

function WheelOfDestiny.getGemStruct(preset)
	local gemStruct = {
		[GemDomains.GREEN] = {
			gemID = -1
		},
		[GemDomains.RED] = {
			gemID = -1
		},
		[GemDomains.ACQUA] = {
			gemID = -1
		},
		[GemDomains.PURPLE] = {
			gemID = -1
		}
	}
	local equippedGems = preset ~= nil and preset.equipedGems or WheelOfDestiny.equipedGems

	for unusedValue, entry in pairs(equippedGems) do
		local gemDomainById = GemAtelier.getGemDomainById(entry)

		if gemDomainById ~= -1 then
			gemStruct[gemDomainById].hasGem = true
			gemStruct[gemDomainById].gemID = entry
		end
	end

	return gemStruct
end

function WheelOfDestiny.getLocalGemStruct()
	local gemIdsByDomain = {
		-1,
		-1,
		-1,
		-1
	}

	for unusedValue, equipedGem in pairs(WheelOfDestiny.equipedGems) do
		local gemDomainById = GemAtelier.getGemDomainById(equipedGem)

		if gemDomainById == -1 then
			-- block empty
		else
			gemIdsByDomain[gemDomainById + 1] = equipedGem
		end
	end

	return gemIdsByDomain
end

function WheelOfDestiny.onWheelOfDestinyApply(closeAfterApply, skipServerUpdate)
	if WheelOfDestiny.changeState == 0 then
		if closeAfterApply then
			hide()
		end

		return
	end

	local gemStruct = WheelOfDestiny.getGemStruct()

	if not skipServerUpdate then
		local function encodeGemId(gemId)
			if gemId == nil or gemId < 0 then
				return 65535
			end

			return gemId
		end

		local greenGem = encodeGemId(gemStruct[GemDomains.GREEN].gemID)
		local redGem = encodeGemId(gemStruct[GemDomains.RED].gemID)
		local acquaGem = encodeGemId(gemStruct[GemDomains.ACQUA].gemID)
		local purpleGem = encodeGemId(gemStruct[GemDomains.PURPLE].gemID)

		if WheelOfDestiny.currentPreset then
			WheelOfDestiny.currentPreset.equipedGems = normalizeEquippedGemIds(gemStruct)
		end

		g_game.sendApplyWheelPoints(WheelOfDestiny.pointInvested, greenGem, redGem, acquaGem, purpleGem)
		scheduleEvent(function()
			WheelOfDestiny.requestActiveState()
		end, 100)
	end

	if g_game.getLocalPlayer() then
		WheelOfDestiny.updateCurrentPreset()
		WheelOfDestiny.saveWheelPresets()
	end

	if closeAfterApply then
		hide()
	end
end

function WheelOfDestiny.openPreviewWheel(playerId, vocationId)
	WheelOfDestiny.setPreviewMode(true)

	local changeState = 0
	local canView = 0
	local levelPoints = 0
	local scrollPoints = 0
	local pointInvested = createEmptyWheelPoints()
	local usedPromotionScrolls = {}
	local equippedGems = {
		-1,
		-1,
		-1,
		-1
	}
	local atelierGems = {}
	local basicModsUpgrade = {}
	local supremeModsUpgrade = {}
	local fromAchievementType = 0

	if table.empty(WheelOfDestiny.internalPreset) then
		WheelOfDestiny.loadWheelPresets()
	end

	if not wheelWindow:isVisible() then
		showWheelWindow()
		WheelOfDestiny.resetPassiveFocus()
	end

	WheelOfDestiny.resetWheel(true)

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		hide()

		return
	end

	local resourceBalance = localPlayer:getResourceBalance(ResourceTypes.BANK_BALANCE)
	local equippedGold = localPlayer:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local text = localPlayer:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local greaterFragments = localPlayer:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS)
	local totalMoney = resourceBalance + equippedGold

	wheelWindow.moneyPanel.gold:setText(formatMoney(totalMoney, ","))
	wheelWindow.lesserFragmentPanel.gold:setText(text)
	wheelWindow.greaterFragmentPanel.gold:setText(greaterFragments)
	WheelOfDestiny.create(playerId, canView, changeState, vocationId, levelPoints, scrollPoints, pointInvested, usedPromotionScrolls, equippedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade, fromAchievementType)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	wheelPanel.onMouseRelease = WheelOfDestiny.onMouseRelease

	local enabled = changeState == 1
	local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

	if not enabled then
		toggleTabBarButtons("informationButton")
	end

	managePresetsButton:setEnabled(enabled)
	refreshPresetTabBarButtons()

	if vocationId == 1 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_knight")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("34 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("68 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("102 0 34 34")
	elseif vocationId == 2 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_paladin")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("136 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("170 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("204 0 34 34")
	elseif vocationId == 3 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_sorcerer")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("238 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("272 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("306 0 34 34")
	elseif vocationId == 4 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_druid")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("374 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("340 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("408 0 34 34")
	elseif vocationId == 5 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_monk")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("442 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("476 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("510 0 34 34")
	end

	WheelOfDestiny.onCreate(vocationId)
	WheelOfDestiny.checkApplyButton()
	WheelOfDestiny.determinateCurrentPreset()
	WheelOfDestiny.updateCurrentPreset()
	WheelOfDestiny.configureVessels()

	if wheelButton then
		wheelButton:setOn(true)
	end
end

function WheelOfDestiny.onDestinyWheel(playerId, canView, changeState, vocation, levelPoints, scrollPoints, pointInvested, usedPromotionScrolls, equippedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade, fromAchievementType)
	local wasBackgroundRequest = WheelOfDestiny.backgroundRequestPending == true

	WheelOfDestiny.cancelActiveStateRequest()

	if canView == 0 or not table.isIn({
		1,
		2,
		3,
		4,
		5
	}, vocation) then
		if wasBackgroundRequest then
			WheelOfDestiny.clearActiveState()

			return
		end

		local localPlayer = g_game.getLocalPlayer()

		if not localPlayer then
			hide()

			return
		end

		vocation = translateWheelVocation(localPlayer:getVocation())

		if vocation == 0 then
			local function closeWheelAccessInfoBox()
				if wheelAccessInfoBox then
					wheelAccessInfoBox:destroy()

					wheelAccessInfoBox = nil
				end

				hide()
			end

			if not wheelAccessInfoBox then
				wheelAccessInfoBox = displayGeneralBox(tr("Info"), tr("To be able to use the Wheel of Destiny, a character must be at least level 51, be promoted and have active\nPremium Time."), {
					{
						text = tr("Ok"),
						callback = closeWheelAccessInfoBox
					}
				}, closeWheelAccessInfoBox)
			end

			return
		end

		if not wheelAccessInfoBox then
			local previewOfferText = tr("To be able to use the Wheel of Destiny, a character must be at least level 51, be promoted and have active\nPremium Time.\n\nClick on \"Ok\" to see a preview of the Wheel of Destiny for your vocation.")

			local function cancelWheelPreview()
				if wheelAccessInfoBox then
					wheelAccessInfoBox:destroy()

					wheelAccessInfoBox = nil
				end

				hide()
			end

			local function showWheelPreview()
				if wheelAccessInfoBox then
					wheelAccessInfoBox:destroy()

					wheelAccessInfoBox = nil
				end

				WheelOfDestiny.openPreviewWheel(playerId, vocation)
			end

			wheelAccessInfoBox = displayGeneralBox(tr("Info"), previewOfferText, {
				{
					text = tr("Cancel"),
					callback = cancelWheelPreview
				},
				{
					text = tr("Ok"),
					callback = showWheelPreview
				}
			}, showWheelPreview, cancelWheelPreview)
		end

		return
	end

	WheelOfDestiny.setPreviewMode(false)

	if table.empty(WheelOfDestiny.internalPreset) then
		WheelOfDestiny.loadWheelPresets()
	end

	if not wasBackgroundRequest and not wheelWindow:isVisible() then
		showWheelWindow()
		WheelOfDestiny.resetPassiveFocus()
	end

	WheelOfDestiny.resetWheel(true)

	local localPlayer = g_game.getLocalPlayer()
	local resourceBalance = localPlayer:getResourceBalance(ResourceTypes.BANK_BALANCE)
	local equippedGold = localPlayer:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local text = localPlayer:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local greaterFragments = localPlayer:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS)
	local totalMoney = resourceBalance + equippedGold

	wheelWindow.moneyPanel.gold:setText(formatMoney(totalMoney, ","))
	wheelWindow.lesserFragmentPanel.gold:setText(text)
	wheelWindow.greaterFragmentPanel.gold:setText(greaterFragments)
	WheelOfDestiny.create(playerId, canView, changeState, vocation, levelPoints, scrollPoints, pointInvested, usedPromotionScrolls, equippedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade, fromAchievementType)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	wheelPanel.onMouseRelease = WheelOfDestiny.onMouseRelease

	local enabled = changeState == 1
	local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

	if not enabled then
		toggleTabBarButtons("informationButton")
	end

	managePresetsButton:setEnabled(enabled)
	refreshPresetTabBarButtons()

	if vocation == 1 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_knight")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("34 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("68 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("102 0 34 34")
	elseif vocation == 2 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_paladin")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("136 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("170 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("204 0 34 34")
	elseif vocation == 3 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_sorcerer")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("238 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("272 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("306 0 34 34")
	elseif vocation == 4 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_druid")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("374 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("340 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("408 0 34 34")
	elseif vocation == 5 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_monk")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("442 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("476 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("510 0 34 34")
	end

	if not WheelOfDestiny.isPreview then
		if WheelOfDestiny.changeState == 1 then
			wheelWindow.reset:setEnabled(true)
			wheelWindow.apply:setEnabled(true)
			wheelWindow.ok:setEnabled(true)
		elseif WheelOfDestiny.changeState == 2 then
			wheelWindow.reset:setEnabled(false)
			wheelWindow.apply:setEnabled(true)
			wheelWindow.ok:setEnabled(true)
		else
			wheelWindow.reset:setEnabled(false)
			wheelWindow.apply:setEnabled(false)
			wheelWindow.ok:setEnabled(true)
		end
	end

	WheelOfDestiny.onCreate(vocation)

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and playerId == localPlayer:getId() then
		WheelOfDestiny.captureActiveState(playerId)
	end

	WheelOfDestiny.checkApplyButton()
	WheelOfDestiny.determinateCurrentPreset()
	WheelOfDestiny.updateCurrentPreset()
	WheelOfDestiny.configureVessels()

	if wheelButton then
		wheelButton:setOn(not wasBackgroundRequest or wheelWindow:isVisible())
	end
end

function WheelOfDestiny.create(playerId, canView, changeState, vocationId, levelPoints, scrollPoints, pointInvested, usedPromotionScrolls, equippedGems, atelierGems, basicModsUpgrade, supremeModsUpgrade, fromAchievementType)
	WheelOfDestiny.playerId = playerId
	WheelOfDestiny.canView = canView
	WheelOfDestiny.changeState = changeState
	WheelOfDestiny.vocationId = vocationId
	WheelOfDestiny.points = levelPoints
	WheelOfDestiny.levelPoints = levelPoints
	WheelOfDestiny.scrollPoints = scrollPoints
	WheelOfDestiny.usedPromotionScrolls = usedPromotionScrolls
	WheelOfDestiny.equipedGems = normalizeEquippedGemIds(equippedGems)
	WheelOfDestiny.atelierGems = atelierGems
	WheelOfDestiny.basicModsUpgrade = basicModsUpgrade
	WheelOfDestiny.supremeModsUpgrade = supremeModsUpgrade
	WheelOfDestiny.extraGemPoints = 0
	WheelOfDestiny.fromAchievementType = fromAchievementType
	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	if WheelOfDestiny.vocationId == 0 then
		local localPlayer = g_game.getLocalPlayer()

		if localPlayer then
			WheelOfDestiny.vocationId = translateWheelVocation(localPlayer:getVocation())
		end
	end

	local sliceTraversalOrder = {
		15,
		9,
		14,
		3,
		8,
		13,
		2,
		7,
		1,
		16,
		10,
		17,
		4,
		11,
		18,
		5,
		12,
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
		25,
		32,
		31
	}

	for unusedValue, entry in pairs(WheelOfDestiny.basicModsUpgrade) do
		if entry == 3 then
			WheelOfDestiny.extraGemPoints = WheelOfDestiny.extraGemPoints + 1
		end
	end

	for unusedValue, entry in pairs(WheelOfDestiny.supremeModsUpgrade) do
		if entry == 3 then
			WheelOfDestiny.extraGemPoints = WheelOfDestiny.extraGemPoints + 1
		end
	end

	WheelOfDestiny.setupPointsTooltip()

	local requestedPointTotal = 0

	for unusedValue, entry in pairs(pointInvested) do
		requestedPointTotal = requestedPointTotal + entry
	end

	WheelOfDestiny.usedPoints = 0

	for unusedValue, entry in pairs(sliceTraversalOrder) do
		_points = pointInvested[entry] or 0

		local bonusDefinition = WheelBonus[entry - 1]

		WheelOfDestiny.pointInvested[entry] = 0

		if bonusDefinition then
			for unusedValue = 1, _points do
				WheelOfDestiny.usedPoints = WheelOfDestiny.usedPoints + 1
				WheelOfDestiny.passivePoints[bonusDefinition.domain] = WheelOfDestiny.passivePoints[bonusDefinition.domain] + 1
				WheelOfDestiny.pointInvested[entry] = WheelOfDestiny.pointInvested[entry] + 1
			end
		end
	end

	local totalInvestedPoints = 0

	for unusedValue, entry in pairs(WheelOfDestiny.pointInvested) do
		totalInvestedPoints = totalInvestedPoints + entry
	end

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		if not WheelOfDestiny.canAddPoints(key, true) and entry > 0 then
			local bonusDefinition = WheelBonus[key - 1]

			WheelOfDestiny.usedPoints = WheelOfDestiny.usedPoints - entry
			WheelOfDestiny.passivePoints[bonusDefinition.domain] = WheelOfDestiny.passivePoints[bonusDefinition.domain] - entry
			entry = 0
		end
	end

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		WheelOfDestiny.insertPoint(key, entry)
	end

	local function incrementModCount(bonusId, modCountById)
		if type(bonusId) ~= "number" or bonusId <= 0 then
			return
		end

		local textValue = tostring(bonusId)

		modCountById[textValue] = (modCountById[textValue] or 0) + 1
	end

	WheelOfDestiny.basicModCount = {}
	WheelOfDestiny.supremeModCount = {}

	for unusedValue, atelierGem in pairs(WheelOfDestiny.atelierGems) do
		local function emptyModCountHook(unusedArgument, unusedArgument)
			return
		end

		emptyModCountHook("basicModCount", WheelOfDestiny.basicModCount)
		emptyModCountHook("supremeModCount", WheelOfDestiny.supremeModCount)
		incrementModCount(atelierGem.lesserBonus, WheelOfDestiny.basicModCount)
		incrementModCount(atelierGem.regularBonus, WheelOfDestiny.basicModCount)
		incrementModCount(atelierGem.supremeBonus, WheelOfDestiny.supremeModCount)
	end

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))

	wheelPanel:recursiveGetChildById("perkIconTopLeft").onClick = function()
		WheelOfDestiny.onWheelPassiveClick(1)
	end
	wheelPanel:recursiveGetChildById("perkIconTopRight").onClick = function()
		WheelOfDestiny.onWheelPassiveClick(2)
	end
	wheelPanel:recursiveGetChildById("perkIconBottomLeft").onClick = function()
		WheelOfDestiny.onWheelPassiveClick(3)
	end
	wheelPanel:recursiveGetChildById("perkIconBottomRight").onClick = function()
		WheelOfDestiny.onWheelPassiveClick(4)
	end

	WheelOfDestiny.onCreate(vocationId)
end

function WheelOfDestiny.resetWheel(skipServerUpdate)
	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	for index, unusedValue in ipairs(WheelNodes) do
		if WheelOfDestiny.vocationId ~= 0 then
			local icon = wheelPanel:recursiveGetChildById("icon" .. index)
			local modIcon = icon:recursiveGetChildById("modIcon" .. index)
			local wheelIcon = WheelIcons[WheelOfDestiny.vocationId][index]

			icon:setImageSource("/images/game/wheel/icons-skillwheel-mediumperks")
			icon:setImageClip(wheelIcon.iconRect)
			icon:setSize(tosize("30 30"))

			if modIcon then
				modIcon:setVisible(false)
			end
		end

		WheelOfDestiny.pointInvested[index] = 0

		WheelOfDestiny.updateSliceFill(index, 0)
	end

	WheelOfDestiny.showUnlockedPreview(15)
	WheelOfDestiny.showUnlockedPreview(16)
	WheelOfDestiny.showUnlockedPreview(21)
	WheelOfDestiny.showUnlockedPreview(22)

	for vesselIndex = 0, 3 do
		WheelOfDestiny.vesselEnabled[vesselIndex] = {}
	end

	WheelOfDestiny.equipedGemBonuses = {}
	WheelOfDestiny.equipedGems = {
		-1,
		-1,
		-1,
		-1
	}

	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.onWheelOfDestinyApply(false, skipServerUpdate)
end

function WheelOfDestiny.setupPointsTooltip()
	local pointsTooltip = tr(WheelPointTooltip, WheelOfDestiny.levelPoints, WheelOfDestiny.extraGemPoints, WheelOfDestiny.scrollPoints)

	if WheelOfDestiny.scrollPoints > 0 then
		pointsTooltip = pointsTooltip .. "\nYou have received bonus promotion points by using the following items: "

		for key, usedPromotionScroll in pairs(WheelOfDestiny.usedPromotionScrolls) do
			local marketData = Item.create(key):getMarketData()

			if marketData then
				pointsTooltip = pointsTooltip .. "\n" .. string.format("%s (%s points)", marketData.name, usedPromotionScroll)
			end
		end
	end

	if WheelOfDestiny.fromAchievementType and WheelOfDestiny.fromAchievementType > 0 then
		pointsTooltip = pointsTooltip .. "\nYou were rewarded 10 bonus promotion points for earning the achievement \"Path of Insight\"."
	end

	wheelOfDestinyWindow.selection.pointsDesc:setTooltip(pointsTooltip)
	wheelOfDestinyWindow.selection.points:setTooltip(pointsTooltip)
end
