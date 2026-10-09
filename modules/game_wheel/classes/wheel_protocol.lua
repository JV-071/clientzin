local var_0_0
local var_0_1

local function var_0_2()
	local var_1_0 = {}

	for iter_1_0 = 1, 36 do
		var_1_0[iter_1_0] = 0
	end

	return var_1_0
end

local function var_0_3(arg_2_0)
	local var_2_0 = {}

	if type(arg_2_0) ~= "table" then
		return var_2_0
	end

	for key, entry in pairs(arg_2_0) do
		var_2_0[key] = tonumber(entry) or 0
	end

	return var_2_0
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

	if var_0_1 then
		removeEvent(var_0_1)

		var_0_1 = nil
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
	var_0_1 = scheduleEvent(function()
		var_0_1 = nil
		WheelOfDestiny.backgroundRequestPending = false

		if g_logger and g_logger.warning then
			g_logger.warning("[wheel] Timed out while requesting the active Wheel state.")
		end
	end, 3000)

	g_game.openWheel(localPlayer:getId())

	return true
end

function WheelOfDestiny.captureActiveState(arg_8_0)
	WheelOfDestiny.activeState = {
		ready = true,
		playerId = arg_8_0,
		vocationId = WheelOfDestiny.vocationId,
		pointInvested = var_0_3(WheelOfDestiny.pointInvested),
		passivePoints = var_0_3(WheelOfDestiny.passivePoints),
		extraPassivePoints = var_0_3(WheelOfDestiny.extraPassivePoints)
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

local function var_0_4(arg_10_0)
	if type(arg_10_0) ~= "table" then
		return {
			-1,
			-1,
			-1,
			-1
		}
	end

	local var_10_0 = {}
	local var_10_1 = false

	for unusedValue, entry in pairs(arg_10_0) do
		if type(entry) == "table" and entry.gemID ~= nil then
			var_10_1 = true

			break
		end
	end

	if var_10_1 then
		local var_10_2 = {
			GemDomains.GREEN,
			GemDomains.RED,
			GemDomains.ACQUA,
			GemDomains.PURPLE
		}

		for unusedValue, entry in ipairs(var_10_2) do
			local var_10_3 = arg_10_0[entry]
			local var_10_4 = type(var_10_3) == "table" and tonumber(var_10_3.gemID) or tonumber(var_10_3)

			table.insert(var_10_0, var_10_4 or -1)
		end
	else
		for unusedValue, entry in ipairs(arg_10_0) do
			local numericValue = tonumber(entry)

			table.insert(var_10_0, numericValue or -1)
		end

		if #var_10_0 == 0 then
			for unusedValue, entry in pairs(arg_10_0) do
				local numericValue = tonumber(entry)

				table.insert(var_10_0, numericValue or -1)
			end
		end
	end

	while #var_10_0 < 4 do
		table.insert(var_10_0, -1)
	end

	return var_10_0
end

function WheelOfDestiny.getGemStruct(arg_11_0)
	local var_11_0 = {
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
	local var_11_1 = arg_11_0 ~= nil and arg_11_0.equipedGems or WheelOfDestiny.equipedGems

	for unusedValue, entry in pairs(var_11_1) do
		local gemDomainById = GemAtelier.getGemDomainById(entry)

		if gemDomainById ~= -1 then
			var_11_0[gemDomainById].hasGem = true
			var_11_0[gemDomainById].gemID = entry
		end
	end

	return var_11_0
end

function WheelOfDestiny.getLocalGemStruct()
	local var_12_0 = {
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
			var_12_0[gemDomainById + 1] = equipedGem
		end
	end

	return var_12_0
end

function WheelOfDestiny.onWheelOfDestinyApply(arg_13_0, arg_13_1)
	if WheelOfDestiny.changeState == 0 then
		if arg_13_0 then
			hide()
		end

		return
	end

	local gemStruct = WheelOfDestiny.getGemStruct()

	if not arg_13_1 then
		local function var_13_1(arg_14_0)
			if arg_14_0 == nil or arg_14_0 < 0 then
				return 65535
			end

			return arg_14_0
		end

		local greenGem = var_13_1(gemStruct[GemDomains.GREEN].gemID)
		local redGem = var_13_1(gemStruct[GemDomains.RED].gemID)
		local acquaGem = var_13_1(gemStruct[GemDomains.ACQUA].gemID)
		local purpleGem = var_13_1(gemStruct[GemDomains.PURPLE].gemID)

		if WheelOfDestiny.currentPreset then
			WheelOfDestiny.currentPreset.equipedGems = var_0_4(gemStruct)
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

	if arg_13_0 then
		hide()
	end
end

function WheelOfDestiny.openPreviewWheel(arg_16_0, arg_16_1)
	WheelOfDestiny.setPreviewMode(true)

	local var_16_0 = 0
	local var_16_1 = 0
	local var_16_2 = 0
	local var_16_3 = 0
	local var_16_4 = var_0_2()
	local var_16_5 = {}
	local var_16_6 = {
		-1,
		-1,
		-1,
		-1
	}
	local var_16_7 = {}
	local var_16_8 = {}
	local var_16_9 = {}
	local var_16_10 = 0

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
	local var_16_13 = localPlayer:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local var_16_14 = localPlayer:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local var_16_15 = localPlayer:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS)
	local var_16_16 = resourceBalance + var_16_13

	wheelWindow.moneyPanel.gold:setText(formatMoney(var_16_16, ","))
	wheelWindow.lesserFragmentPanel.gold:setText(var_16_14)
	wheelWindow.greaterFragmentPanel.gold:setText(var_16_15)
	WheelOfDestiny.create(arg_16_0, var_16_1, var_16_0, arg_16_1, var_16_2, var_16_3, var_16_4, var_16_5, var_16_6, var_16_7, var_16_8, var_16_9, var_16_10)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	wheelPanel.onMouseRelease = WheelOfDestiny.onMouseRelease

	local var_16_17 = var_16_0 == 1
	local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

	if not var_16_17 then
		toggleTabBarButtons("informationButton")
	end

	managePresetsButton:setEnabled(var_16_17)
	refreshPresetTabBarButtons()

	if arg_16_1 == 1 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_knight")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("34 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("68 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("102 0 34 34")
	elseif arg_16_1 == 2 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_paladin")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("136 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("170 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("204 0 34 34")
	elseif arg_16_1 == 3 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_sorcerer")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("238 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("272 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("306 0 34 34")
	elseif arg_16_1 == 4 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_druid")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("374 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("340 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("408 0 34 34")
	elseif arg_16_1 == 5 then
		wheelPanel.vocationWheel:setImageSource("/images/game/wheel/wheel-vocations/backdrop_skillwheel_monk")
		wheelPanel:recursiveGetChildById("perkIconTopLeft"):setImageClip("0 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconTopRight"):setImageClip("442 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomLeft"):setImageClip("476 0 34 34")
		wheelPanel:recursiveGetChildById("perkIconBottomRight"):setImageClip("510 0 34 34")
	end

	WheelOfDestiny.onCreate(arg_16_1)
	WheelOfDestiny.checkApplyButton()
	WheelOfDestiny.determinateCurrentPreset()
	WheelOfDestiny.updateCurrentPreset()
	WheelOfDestiny.configureVessels()

	if wheelButton then
		wheelButton:setOn(true)
	end
end

function WheelOfDestiny.onDestinyWheel(arg_17_0, arg_17_1, arg_17_2, vocation, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9, arg_17_10, arg_17_11, arg_17_12)
	local var_17_0 = WheelOfDestiny.backgroundRequestPending == true

	WheelOfDestiny.cancelActiveStateRequest()

	if arg_17_1 == 0 or not table.isIn({
		1,
		2,
		3,
		4,
		5
	}, vocation) then
		if var_17_0 then
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
			local function var_17_2()
				if var_0_0 then
					var_0_0:destroy()

					var_0_0 = nil
				end

				hide()
			end

			if not var_0_0 then
				var_0_0 = displayGeneralBox(tr("Info"), tr("To be able to use the Wheel of Destiny, a character must be at least level 51, be promoted and have active\nPremium Time."), {
					{
						text = tr("Ok"),
						callback = var_17_2
					}
				}, var_17_2)
			end

			return
		end

		if not var_0_0 then
			local var_17_3 = tr("To be able to use the Wheel of Destiny, a character must be at least level 51, be promoted and have active\nPremium Time.\n\nClick on \"Ok\" to see a preview of the Wheel of Destiny for your vocation.")

			local function var_17_4()
				if var_0_0 then
					var_0_0:destroy()

					var_0_0 = nil
				end

				hide()
			end

			local function var_17_5()
				if var_0_0 then
					var_0_0:destroy()

					var_0_0 = nil
				end

				WheelOfDestiny.openPreviewWheel(arg_17_0, vocation)
			end

			var_0_0 = displayGeneralBox(tr("Info"), var_17_3, {
				{
					text = tr("Cancel"),
					callback = var_17_4
				},
				{
					text = tr("Ok"),
					callback = var_17_5
				}
			}, var_17_5, var_17_4)
		end

		return
	end

	WheelOfDestiny.setPreviewMode(false)

	if table.empty(WheelOfDestiny.internalPreset) then
		WheelOfDestiny.loadWheelPresets()
	end

	if not var_17_0 and not wheelWindow:isVisible() then
		showWheelWindow()
		WheelOfDestiny.resetPassiveFocus()
	end

	WheelOfDestiny.resetWheel(true)

	local localPlayer = g_game.getLocalPlayer()
	local resourceBalance = localPlayer:getResourceBalance(ResourceTypes.BANK_BALANCE)
	local var_17_8 = localPlayer:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local var_17_9 = localPlayer:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local var_17_10 = localPlayer:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS)
	local var_17_11 = resourceBalance + var_17_8

	wheelWindow.moneyPanel.gold:setText(formatMoney(var_17_11, ","))
	wheelWindow.lesserFragmentPanel.gold:setText(var_17_9)
	wheelWindow.greaterFragmentPanel.gold:setText(var_17_10)
	WheelOfDestiny.create(arg_17_0, arg_17_1, arg_17_2, vocation, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9, arg_17_10, arg_17_11, arg_17_12)

	if GemAtelier and gemAtelierWindow and gemAtelierWindow:isVisible() and GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	wheelPanel.onMouseRelease = WheelOfDestiny.onMouseRelease

	local var_17_12 = arg_17_2 == 1
	local managePresetsButton = wheelWindow.mainPanel.wheelMenu.info.presetTabBar:getChildById("managePresetsButton")

	if not var_17_12 then
		toggleTabBarButtons("informationButton")
	end

	managePresetsButton:setEnabled(var_17_12)
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

	if localPlayer and arg_17_0 == localPlayer:getId() then
		WheelOfDestiny.captureActiveState(arg_17_0)
	end

	WheelOfDestiny.checkApplyButton()
	WheelOfDestiny.determinateCurrentPreset()
	WheelOfDestiny.updateCurrentPreset()
	WheelOfDestiny.configureVessels()

	if wheelButton then
		wheelButton:setOn(not var_17_0 or wheelWindow:isVisible())
	end
end

function WheelOfDestiny.create(playerId, canView, changeState, vocationId, arg_21_4, scrollPoints, arg_21_6, usedPromotionScrolls, arg_21_8, atelierGems, basicModsUpgrade, supremeModsUpgrade, fromAchievementType)
	WheelOfDestiny.playerId = playerId
	WheelOfDestiny.canView = canView
	WheelOfDestiny.changeState = changeState
	WheelOfDestiny.vocationId = vocationId
	WheelOfDestiny.points = arg_21_4
	WheelOfDestiny.levelPoints = arg_21_4
	WheelOfDestiny.scrollPoints = scrollPoints
	WheelOfDestiny.usedPromotionScrolls = usedPromotionScrolls
	WheelOfDestiny.equipedGems = var_0_4(arg_21_8)
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

	local var_21_1 = {
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

	local var_21_2 = 0

	for unusedValue, entry in pairs(arg_21_6) do
		var_21_2 = var_21_2 + entry
	end

	WheelOfDestiny.usedPoints = 0

	for unusedValue, entry in pairs(var_21_1) do
		_points = arg_21_6[entry] or 0

		local var_21_3 = WheelBonus[entry - 1]

		WheelOfDestiny.pointInvested[entry] = 0

		if var_21_3 then
			for unusedValue = 1, _points do
				WheelOfDestiny.usedPoints = WheelOfDestiny.usedPoints + 1
				WheelOfDestiny.passivePoints[var_21_3.domain] = WheelOfDestiny.passivePoints[var_21_3.domain] + 1
				WheelOfDestiny.pointInvested[entry] = WheelOfDestiny.pointInvested[entry] + 1
			end
		end
	end

	local var_21_4 = 0

	for unusedValue, entry in pairs(WheelOfDestiny.pointInvested) do
		var_21_4 = var_21_4 + entry
	end

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		if not WheelOfDestiny.canAddPoints(key, true) and entry > 0 then
			local var_21_5 = WheelBonus[key - 1]

			WheelOfDestiny.usedPoints = WheelOfDestiny.usedPoints - entry
			WheelOfDestiny.passivePoints[var_21_5.domain] = WheelOfDestiny.passivePoints[var_21_5.domain] - entry
			entry = 0
		end
	end

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		WheelOfDestiny.insertPoint(key, entry)
	end

	local function var_21_6(arg_22_0, arg_22_1)
		if type(arg_22_0) ~= "number" or arg_22_0 <= 0 then
			return
		end

		local textValue = tostring(arg_22_0)

		arg_22_1[textValue] = (arg_22_1[textValue] or 0) + 1
	end

	WheelOfDestiny.basicModCount = {}
	WheelOfDestiny.supremeModCount = {}

	for unusedValue, atelierGem in pairs(WheelOfDestiny.atelierGems) do
		local function var_21_7(unusedArgument, unusedArgument)
			return
		end

		var_21_7("basicModCount", WheelOfDestiny.basicModCount)
		var_21_7("supremeModCount", WheelOfDestiny.supremeModCount)
		var_21_6(atelierGem.lesserBonus, WheelOfDestiny.basicModCount)
		var_21_6(atelierGem.regularBonus, WheelOfDestiny.basicModCount)
		var_21_6(atelierGem.supremeBonus, WheelOfDestiny.supremeModCount)
	end

	local var_21_8 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_21_8 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_21_8))

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

function WheelOfDestiny.resetWheel(arg_28_0)
	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	for index, unusedValue in ipairs(WheelNodes) do
		if WheelOfDestiny.vocationId ~= 0 then
			local icon = wheelPanel:recursiveGetChildById("icon" .. index)
			local modIcon = icon:recursiveGetChildById("modIcon" .. index)
			local var_28_2 = WheelIcons[WheelOfDestiny.vocationId][index]

			icon:setImageSource("/images/game/wheel/icons-skillwheel-mediumperks")
			icon:setImageClip(var_28_2.iconRect)
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

	for iter_28_2 = 0, 3 do
		WheelOfDestiny.vesselEnabled[iter_28_2] = {}
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
	WheelOfDestiny.onWheelOfDestinyApply(false, arg_28_0)
end

function WheelOfDestiny.setupPointsTooltip()
	local var_29_0 = tr(WheelPointTooltip, WheelOfDestiny.levelPoints, WheelOfDestiny.extraGemPoints, WheelOfDestiny.scrollPoints)

	if WheelOfDestiny.scrollPoints > 0 then
		var_29_0 = var_29_0 .. "\nYou have received bonus promotion points by using the following items: "

		for key, usedPromotionScroll in pairs(WheelOfDestiny.usedPromotionScrolls) do
			local marketData = Item.create(key):getMarketData()

			if marketData then
				var_29_0 = var_29_0 .. "\n" .. string.format("%s (%s points)", marketData.name, usedPromotionScroll)
			end
		end
	end

	if WheelOfDestiny.fromAchievementType and WheelOfDestiny.fromAchievementType > 0 then
		var_29_0 = var_29_0 .. "\nYou were rewarded 10 bonus promotion points for earning the achievement \"Path of Insight\"."
	end

	wheelOfDestinyWindow.selection.pointsDesc:setTooltip(var_29_0)
	wheelOfDestinyWindow.selection.points:setTooltip(var_29_0)
end
