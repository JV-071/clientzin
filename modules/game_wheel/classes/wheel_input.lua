function WheelOfDestiny.getPassiveDomain(arg_1_0)
	for iter_1_0 = 1, 4 do
		local selectPassive = wheelPanel:recursiveGetChildById("selectPassive" .. iter_1_0) or wheelPanel:recursiveGetChildById("focusPassive" .. iter_1_0)

		if selectPassive then
			local rect = selectPassive:getRect()
			local var_1_2 = rect.x + rect.width * 0.5
			local var_1_3 = rect.y + rect.height * 0.5
			local var_1_4 = math.min(rect.width, rect.height) * 0.5
			local var_1_5 = arg_1_0.x - var_1_2
			local var_1_6 = arg_1_0.y - var_1_3

			if var_1_5 * var_1_5 + var_1_6 * var_1_6 <= var_1_4 * var_1_4 then
				return iter_1_0
			end
		end
	end

	return 0
end

function WheelOfDestiny.getSliceIndex(arg_2_0)
	local center = centerReferencePoint:getCenter()
	local x = center.x
	local y = center.y
	local topLeft = WheelSettings.topLeft

	if x >= arg_2_0.x then
		if y < arg_2_0.y then
			topLeft = WheelSettings.bottomLeft
		else
			topLeft = WheelSettings.topLeft
		end
	elseif y < arg_2_0.y then
		topLeft = WheelSettings.bottomRight
	else
		topLeft = WheelSettings.topRight
	end

	local var_2_4 = arg_2_0.x - x
	local var_2_5 = arg_2_0.y - y
	local var_2_6 = var_2_4 * var_2_4 + var_2_5 * var_2_5
	local var_2_7 = {}

	for unusedValue, entry in pairs(topLeft) do
		if WheelButtons[entry] then
			table.insert(var_2_7, entry)
		end
	end

	table.sort(var_2_7, function(arg_3_0, arg_3_1)
		local visualRing = WheelButtons.getVisualRing(WheelButtons[arg_3_0].radius)
		local var_3_1 = WheelButtons.getVisualRing(WheelButtons[arg_3_1].radius)

		return visualRing.outer < var_3_1.outer
	end)

	for unusedValue, entry in ipairs(var_2_7) do
		local var_2_8 = WheelButtons[entry]
		local visualRing = WheelButtons.getVisualRing(var_2_8.radius)
		local var_2_10 = math.max(0, visualRing.inner - 1)
		local var_2_11 = visualRing.outer + 1

		if var_2_6 >= var_2_10 * var_2_10 and var_2_6 <= var_2_11 * var_2_11 and Circle.new(x, y, var_2_11):isPointInSlice(arg_2_0, var_2_8.slice, var_2_8.totalSlice) then
			return entry
		end
	end

	return 0
end

local function var_0_0(clickIndex)
	if type(clickIndex) ~= "number" or clickIndex < 1 then
		clickIndex = WheelOfDestiny.clickIndex
	end

	if type(clickIndex) ~= "number" or clickIndex < 1 then
		return 0
	end

	return clickIndex
end

local function var_0_1(arg_5_0)
	return WheelOfDestiny.pointInvested[arg_5_0] or 0
end

function WheelOfDestiny.canAddPoints(arg_6_0, arg_6_1)
	if WheelOfDestiny.isPreview then
		return false
	end

	if WheelOfDestiny.vocationId == 0 then
		return false
	end

	if arg_6_1 == nil then
		arg_6_1 = false
	end

	local var_6_0 = WheelBonus[arg_6_0 - 1]

	if not var_6_0 then
		return false
	end

	if not arg_6_1 and var_0_1(arg_6_0) >= var_6_0.maxPoints then
		return false
	end

	if not WheelOfDestiny.points then
		WheelOfDestiny.points = 0
	end

	local var_6_1 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	if not arg_6_1 and var_6_1 - WheelOfDestiny.usedPoints <= 0 then
		return false
	end

	if var_6_0.maxPoints == 50 then
		return true
	end

	local var_6_2 = WheelNodes[arg_6_0]

	if not var_6_2 or not var_6_2.connecteds or #var_6_2.connecteds == 0 then
		return true
	end

	for unusedValue, connected in pairs(var_6_2.connecteds) do
		local var_6_3 = WheelBonus[connected - 1]

		if var_6_3 and var_0_1(connected) >= var_6_3.maxPoints then
			return true
		end
	end

	return false
end

function WheelOfDestiny.canRemovePoints(arg_7_0)
	if WheelOfDestiny.isPreview then
		return false
	end

	if not WheelOfDestiny.isLit(arg_7_0) then
		return false
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	local var_7_0 = WheelButtons[arg_7_0]

	if var_7_0 and var_7_0.radius == BIG_LARGE_CIRCLE then
		return true
	end

	local var_7_1 = WheelNodes[arg_7_0]

	if not var_7_1 or not var_7_1.connections or #var_7_1.connections == 0 then
		return true
	end

	for unusedValue, connection in pairs(var_7_1.connections) do
		if WheelOfDestiny.isLit(connection) and not canReachRootNodeFromNode(connection, arg_7_0) then
			return false
		end
	end

	return true
end

function WheelOfDestiny.isLit(arg_8_0)
	return var_0_1(arg_8_0) > 0
end

function WheelOfDestiny.isLitFull(arg_9_0)
	local var_9_0 = WheelBonus[arg_9_0 - 1]

	if not var_9_0 then
		return false
	end

	return var_0_1(arg_9_0) == var_9_0.maxPoints
end

function WheelOfDestiny.insertUnlockedThe(arg_10_0)
	local var_10_0 = WheelNodes[arg_10_0]

	if not var_10_0 or not var_10_0.connections or #var_10_0.connections == 0 then
		return false
	end

	local var_10_1 = WheelBonus[arg_10_0 - 1]

	if not var_10_1 then
		return false
	end

	if var_0_1(arg_10_0) < var_10_1.maxPoints then
		return false
	end

	for unusedValue, connection in pairs(var_10_0.connections) do
		WheelOfDestiny.showUnlockedPreview(connection)
	end
end

function WheelOfDestiny.removeUnlockedThe(arg_11_0)
	local var_11_0 = WheelNodes[arg_11_0]

	if not var_11_0 or not var_11_0.connections or #var_11_0.connections == 0 then
		return false
	end

	for unusedValue, connection in pairs(var_11_0.connections) do
		local var_11_1 = {}

		for unusedValue, connected in ipairs(WheelNodes[connection].connecteds) do
			if connected ~= arg_11_0 and WheelOfDestiny.isLit(connected) then
				var_11_1[#var_11_1 + 1] = connection
			end
		end

		if not table.isIn(var_11_1, connection) then
			local slicePair = WheelOfDestiny.getSlicePair(connection)
			local var_11_3 = slicePair and slicePair.full

			if var_11_3 and (WheelOfDestiny.pointInvested[connection] or 0) <= 0 then
				var_11_3:setVisible(false)
				var_11_3:setOpacity(FULL_COLOR_WHEEL_OPACITY)
			end
		end
	end
end

function WheelOfDestiny.onWheelClick(arg_12_0)
	local sliceIndex = WheelOfDestiny.getSliceIndex(arg_12_0)

	if sliceIndex == 0 then
		return
	end

	WheelOfDestiny.resetPassiveFocus()

	local var_12_1 = WheelOfDestiny.pointInvested[sliceIndex]

	if not var_12_1 then
		return
	end

	if WheelOfDestiny.lastSelectedGemVessel then
		WheelOfDestiny.lastSelectedGemVessel:setVisible(false)
	end

	if wheelOfDestinyWindow.selection.gemContent:isVisible() then
		wheelOfDestinyWindow.selection.gemContent:setVisible(false)
		wheelOfDestinyWindow.selection.tabContent:setVisible(true)
	end

	if not wheelWindow:recursiveGetChildById("tabContent"):isVisible() then
		wheelWindow:recursiveGetChildById("tabContent"):setVisible(true)
	end

	WheelOfDestiny.clickIndex = sliceIndex

	wheelPanel.borderSelectedWheel:setVisible(true)
	wheelPanel.borderSelectedWheel:setImageSource(WheelButtons[sliceIndex].borderImageBase)

	local var_12_2 = WheelBonus[sliceIndex - 1]

	wheelOfDestinyWindow.selection.tabContent.information1:setTooltip(ConvictionTooltip)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(var_12_1, 0, var_12_2.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(var_12_1 .. " / " .. var_12_2.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationTitle:setText("Dedication Perk")
	wheelOfDestinyWindow.selection.tabContent.convictionTitle:setText("Conviction Perk")
	wheelOfDestinyWindow.selection.tabContent.convictionTitle:setTextAlign(AlignCenter)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
end

function WheelOfDestiny.onRemoveClick()
	if WheelOfDestiny.lastSelectedGemVessel then
		WheelOfDestiny.lastSelectedGemVessel:setVisible(false)
	end

	if wheelOfDestinyWindow.selection.gemContent:isVisible() then
		wheelOfDestinyWindow.selection.gemContent:setVisible(false)
		wheelOfDestinyWindow.selection.tabContent:setVisible(true)
	end

	WheelOfDestiny.clickIndex = 0

	wheelPanel.borderSelectedWheel:setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("addMax"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("addOne"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setVisible(false)
end

function WheelOfDestiny.checkManagerPointsButtons(arg_14_0)
	if WheelOfDestiny.isPreview then
		wheelOfDestinyWindow:recursiveGetChildById("addMax"):setVisible(false)
		wheelOfDestinyWindow:recursiveGetChildById("addOne"):setVisible(false)
		wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setVisible(false)
		wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setVisible(false)

		return
	end

	wheelOfDestinyWindow:recursiveGetChildById("addMax"):setVisible(true)
	wheelOfDestinyWindow:recursiveGetChildById("addOne"):setVisible(true)
	wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setVisible(true)
	wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setVisible(true)

	if WheelOfDestiny.canAddPoints(arg_14_0) then
		wheelOfDestinyWindow:recursiveGetChildById("addMax"):setEnabled(true)
		wheelOfDestinyWindow:recursiveGetChildById("addOne"):setEnabled(true)
	else
		wheelOfDestinyWindow:recursiveGetChildById("addMax"):setEnabled(false)
		wheelOfDestinyWindow:recursiveGetChildById("addOne"):setEnabled(false)
	end

	if WheelOfDestiny.canRemovePoints(arg_14_0) then
		wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setEnabled(true)
		wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setEnabled(true)
	else
		wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setEnabled(false)
		wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setEnabled(false)
	end
end

function WheelOfDestiny.onMouseRelease(unusedArgument, arg_15_1, arg_15_2)
	if arg_15_2 ~= MouseRightButton then
		return
	end

	local sliceIndex = WheelOfDestiny.getSliceIndex(arg_15_1)

	if sliceIndex == 0 then
		return
	end

	local var_15_1 = 0

	if g_keyboard.getModifiers() == KeyboardAltModifier then
		var_15_1 = 1
	elseif g_keyboard.getModifiers() == KeyboardShiftModifier then
		var_15_1 = 50
	elseif g_keyboard.getModifiers() == KeyboardCtrlModifier then
		var_15_1 = 100
	end

	local var_15_2 = WheelBonus[sliceIndex - 1]
	local var_15_3 = var_0_1(sliceIndex)

	if var_15_2 and var_15_3 > var_15_2.maxPoints then
		if not WheelOfDestiny.canRemovePoints(sliceIndex) then
			return
		end

		onRmvMax(sliceIndex)
		WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
		WheelOfDestiny.onWheelClick(arg_15_1)
	else
		if not WheelOfDestiny.canAddPoints(sliceIndex) then
			if WheelOfDestiny.canRemovePoints(sliceIndex) then
				onRmvMax(sliceIndex)
				WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
				WheelOfDestiny.onWheelClick(arg_15_1)
			end

			return
		end

		if var_15_1 ~= 0 then
			onAddCustom(sliceIndex, var_15_1)
		else
			WheelOfDestiny.onAddMax(sliceIndex)
		end

		WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
	end

	WheelOfDestiny.onWheelClick(arg_15_1)

	return true
end

function WheelOfDestiny.onMouseMove(unusedArgument, arg_16_1, unusedArgument)
	local passiveDomain = WheelOfDestiny.getPassiveDomain(arg_16_1)

	if passiveDomain ~= 0 then
		WheelOfDestiny.hideSliceFocus()

		if WheelOfDestiny.mouseIndex ~= 0 then
			WheelOfDestiny.showInformationDefault()
		end

		if WheelOfDestiny.mousePassiveDomain == passiveDomain then
			return
		end

		WheelOfDestiny.mousePassiveDomain = passiveDomain

		WheelOfDestiny.applyPassiveFocus(passiveDomain)

		return
	end

	if WheelOfDestiny.mousePassiveDomain ~= 0 then
		WheelOfDestiny.mousePassiveDomain = 0

		WheelOfDestiny.hidePassiveFocus()
	end

	local sliceIndex = WheelOfDestiny.getSliceIndex(arg_16_1)

	if sliceIndex == 0 then
		WheelOfDestiny.hideSliceFocus()

		if WheelOfDestiny.mouseIndex ~= 0 then
			WheelOfDestiny.showInformationDefault()
		end

		return
	end

	if WheelOfDestiny.mouseIndex == sliceIndex then
		return
	end

	WheelOfDestiny.mouseIndex = sliceIndex

	if not WheelOfDestiny.pointInvested[sliceIndex] then
		WheelOfDestiny.hideSliceFocus()
		WheelOfDestiny.showInformationDefault()

		return
	end

	WheelOfDestiny.updateInformationPerk(sliceIndex)
	WheelOfDestiny.applySliceFocus(sliceIndex)
end

function WheelOfDestiny.insertPoint(arg_17_0, arg_17_1)
	local var_17_0 = WheelBonus[arg_17_0 - 1]

	WheelOfDestiny.updateSliceFill(arg_17_0, arg_17_1)

	if arg_17_1 > 0 and arg_17_1 >= var_17_0.maxPoints then
		WheelOfDestiny.insertUnlockedThe(arg_17_0)

		if WheelOfDestiny.isVesselSlice(arg_17_0) then
			WheelOfDestiny.refreshVesselDomain(var_17_0.domain - 1)
		else
			local icon = wheelPanel:recursiveGetChildById("icon" .. arg_17_0)
			local var_17_2 = WheelIcons[WheelOfDestiny.vocationId][arg_17_0]

			icon:setImageClip(var_17_2.iconRect)
		end
	end
end

function WheelOfDestiny.isVesselSlice(arg_18_0)
	local var_18_0 = WheelBonus[arg_18_0 - 1]

	return var_18_0 ~= nil and var_18_0.conviction == "vessel"
end

local function var_0_2(arg_19_0)
	local icon = wheelPanel:recursiveGetChildById("icon" .. arg_19_0)
	local var_19_1 = WheelIcons[WheelOfDestiny.vocationId] and WheelIcons[WheelOfDestiny.vocationId][arg_19_0]

	if not icon or not var_19_1 then
		return nil
	end

	icon:setImageSource("/images/game/wheel/icons-skillwheel-mediumperks")
	icon:setImageClip(var_19_1.iconRect)
	icon:setSize(tosize("30 30"))

	local modIcon = icon:recursiveGetChildById("modIcon" .. arg_19_0)

	if modIcon then
		modIcon:setVisible(false)
	end

	return icon, modIcon
end

function WheelOfDestiny.refreshVesselDomain(arg_20_0)
	local var_20_0 = WheelDomainOrder[arg_20_0]

	if not var_20_0 or not wheelPanel then
		return
	end

	local equipedGem = GemAtelier.getEquipedGem(arg_20_0)
	local var_20_2 = {}

	for unusedValue, entry in ipairs(var_20_0) do
		local var_20_3 = WheelBonus[entry - 1]

		if var_20_3 and var_20_3.conviction == "vessel" then
			local var_20_4, var_20_5 = var_0_2(entry)

			WheelOfDestiny.equipedGemBonuses[entry] = nil

			if (WheelOfDestiny.pointInvested[entry] or 0) >= var_20_3.maxPoints then
				table.insert(var_20_2, entry)

				local var_20_6, var_20_7 = WheelGemState.getGemModBonus(equipedGem, #var_20_2)

				if var_20_4 and var_20_6 then
					if var_20_7 then
						var_20_4:setImageSource("/images/game/wheel/icons-skillwheel-suprememods")
						var_20_4:setImageClip(getSupremeModIconClip(var_20_6))
						var_20_4:setSize(tosize("35 35"))
					else
						var_20_4:setImageSource("/images/game/wheel/icons-skillwheel-basicmods")
						var_20_4:setImageClip(30 * var_20_6 .. " 0 30 30")
					end

					if var_20_5 then
						var_20_5:setVisible(true)
					end

					WheelOfDestiny.equipedGemBonuses[entry] = {
						bonusID = var_20_6,
						supreme = var_20_7,
						gemID = equipedGem.gemID
					}
				end
			end
		end
	end

	WheelOfDestiny.vesselEnabled[arg_20_0] = var_20_2
end

function WheelOfDestiny.refreshAllVesselDomains()
	for iter_21_0 = 0, 3 do
		WheelOfDestiny.refreshVesselDomain(iter_21_0)
	end
end

function WheelOfDestiny.removePoint(arg_22_0, arg_22_1)
	local var_22_0 = WheelBonus[arg_22_0 - 1]

	WheelOfDestiny.updateSliceFill(arg_22_0, arg_22_1)

	if arg_22_1 > 0 and arg_22_1 >= var_22_0.maxPoints then
		WheelOfDestiny.insertUnlockedThe(arg_22_0)
	elseif WheelOfDestiny.isVesselSlice(arg_22_0) then
		WheelOfDestiny.refreshVesselDomain(var_22_0.domain - 1)
	end
end

function WheelOfDestiny.onAddMax(arg_23_0)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_23_0 = var_0_0(arg_23_0)

	if arg_23_0 == 0 then
		return
	end

	local var_23_0 = WheelBonus[arg_23_0 - 1]

	if not var_23_0 then
		return
	end

	local var_23_1 = var_0_1(arg_23_0)

	if var_23_1 >= var_23_0.maxPoints then
		return
	end

	local var_23_2 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)
	local var_23_3 = math.max(var_23_2 - WheelOfDestiny.usedPoints, 0)

	if var_23_3 == 1 then
		return onAddOne(arg_23_0)
	end

	local var_23_4 = math.max(var_23_0.maxPoints, 0)

	if not WheelOfDestiny.canAddPoints(arg_23_0, true) then
		return
	end

	WheelOfDestiny.pointInvested[arg_23_0] = math.min(var_23_1 + var_23_3, var_23_4)

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[arg_23_0], 0, var_23_0.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[arg_23_0] .. " / " .. var_23_0.maxPoints)
	WheelOfDestiny.configureDedication(arg_23_0)
	WheelOfDestiny.configureConviction(arg_23_0)
	WheelOfDestiny.insertPoint(arg_23_0, WheelOfDestiny.pointInvested[arg_23_0])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local var_23_6 = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[var_23_6.domain] = WheelOfDestiny.passivePoints[var_23_6.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_23_2 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_23_2))
	WheelOfDestiny.checkManagerPointsButtons(arg_23_0)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	if WheelOfDestiny.changeState == 0 or WheelOfDestiny.changeState == 2 then
		WheelOfDestiny.onWheelOfDestinyApply(false, false)
	end

	WheelOfDestiny.checkApplyButton()
end

function onAddOne(arg_24_0)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_24_0 = var_0_0(arg_24_0)

	if arg_24_0 == 0 then
		return
	end

	local var_24_0 = WheelBonus[arg_24_0 - 1]

	if not var_24_0 then
		return
	end

	local var_24_1 = var_0_1(arg_24_0)

	if var_24_1 >= var_24_0.maxPoints then
		return
	end

	if not WheelOfDestiny.canAddPoints(arg_24_0, true) then
		return
	end

	WheelOfDestiny.pointInvested[arg_24_0] = var_24_1 + 1

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[arg_24_0], 0, var_24_0.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[arg_24_0] .. " / " .. var_24_0.maxPoints)
	WheelOfDestiny.configureDedication(arg_24_0)
	WheelOfDestiny.configureConviction(arg_24_0)
	WheelOfDestiny.insertPoint(arg_24_0, WheelOfDestiny.pointInvested[arg_24_0])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local var_24_3 = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[var_24_3.domain] = WheelOfDestiny.passivePoints[var_24_3.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local var_24_4 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_24_4 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_24_4))
	WheelOfDestiny.checkManagerPointsButtons(arg_24_0)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	if WheelOfDestiny.changeState == 0 or WheelOfDestiny.changeState == 2 then
		WheelOfDestiny.onWheelOfDestinyApply(false, false)
	end

	WheelOfDestiny.checkApplyButton()
end

function onAddCustom(arg_25_0, arg_25_1)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_25_0 = var_0_0(arg_25_0)

	if arg_25_0 == 0 then
		return
	end

	local var_25_0 = WheelBonus[arg_25_0 - 1]

	if not var_25_0 then
		return
	end

	local var_25_1 = var_0_1(arg_25_0)

	if var_25_1 >= var_25_0.maxPoints then
		return
	end

	if not WheelOfDestiny.canAddPoints(arg_25_0, true) then
		return
	end

	local var_25_2 = math.min(var_25_0.maxPoints, var_25_1 + arg_25_1)

	WheelOfDestiny.pointInvested[arg_25_0] = var_25_2

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[arg_25_0], 0, var_25_0.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[arg_25_0] .. " / " .. var_25_0.maxPoints)
	WheelOfDestiny.configureDedication(arg_25_0)
	WheelOfDestiny.configureConviction(arg_25_0)
	WheelOfDestiny.insertPoint(arg_25_0, WheelOfDestiny.pointInvested[arg_25_0])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local var_25_4 = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[var_25_4.domain] = WheelOfDestiny.passivePoints[var_25_4.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local var_25_5 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_25_5 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_25_5))
	WheelOfDestiny.checkManagerPointsButtons(arg_25_0)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	if WheelOfDestiny.changeState == 0 or WheelOfDestiny.changeState == 2 then
		WheelOfDestiny.onWheelOfDestinyApply(false, false)
	end

	WheelOfDestiny.checkApplyButton()
end

function onRmvMax(arg_26_0)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_26_0 = var_0_0(arg_26_0)

	if arg_26_0 == 0 then
		return
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	if var_0_1(arg_26_0) == 0 then
		return
	end

	if not WheelOfDestiny.canRemovePoints(arg_26_0) then
		return
	end

	local var_26_0 = WheelBonus[arg_26_0 - 1]

	if not var_26_0 then
		return
	end

	WheelOfDestiny.pointInvested[arg_26_0] = 0

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[arg_26_0], 0, var_26_0.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[arg_26_0] .. " / " .. var_26_0.maxPoints)
	WheelOfDestiny.configureDedication(arg_26_0)
	WheelOfDestiny.configureConviction(arg_26_0)
	WheelOfDestiny.removePoint(arg_26_0, WheelOfDestiny.pointInvested[arg_26_0])
	WheelOfDestiny.removeUnlockedThe(arg_26_0)

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local var_26_2 = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[var_26_2.domain] = WheelOfDestiny.passivePoints[var_26_2.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local var_26_3 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_26_3 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_26_3))
	WheelOfDestiny.checkManagerPointsButtons(arg_26_0)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	WheelOfDestiny.checkApplyButton()
end

function onRmvOne(arg_27_0)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_27_0 = var_0_0(arg_27_0)

	if arg_27_0 == 0 then
		return
	end

	if not WheelOfDestiny.canRemovePoints(arg_27_0) then
		return
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	local var_27_0 = var_0_1(arg_27_0)

	if var_27_0 == 0 then
		return
	end

	local var_27_1 = WheelBonus[arg_27_0 - 1]

	if not var_27_1 then
		return
	end

	WheelOfDestiny.pointInvested[arg_27_0] = var_27_0 - 1

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[arg_27_0], 0, var_27_1.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[arg_27_0] .. " / " .. var_27_1.maxPoints)
	WheelOfDestiny.configureDedication(arg_27_0)
	WheelOfDestiny.configureConviction(arg_27_0)
	WheelOfDestiny.removePoint(arg_27_0, WheelOfDestiny.pointInvested[arg_27_0])
	WheelOfDestiny.removeUnlockedThe(arg_27_0)

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local var_27_3 = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[var_27_3.domain] = WheelOfDestiny.passivePoints[var_27_3.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local var_27_4 = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(var_27_4 - WheelOfDestiny.usedPoints) .. " / " .. comma_value(var_27_4))
	WheelOfDestiny.checkManagerPointsButtons(arg_27_0)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if GemAtelier.setupVesselPanel then
		GemAtelier.setupVesselPanel()
	end

	WheelOfDestiny.checkApplyButton()
end
