function WheelOfDestiny.getPassiveDomain(mousePosition)
	for domainIndex = 1, 4 do
		local selectPassive = wheelPanel:recursiveGetChildById("selectPassive" .. domainIndex) or wheelPanel:recursiveGetChildById("focusPassive" .. domainIndex)

		if selectPassive then
			local rect = selectPassive:getRect()
			local centerX = rect.x + rect.width * 0.5
			local centerY = rect.y + rect.height * 0.5
			local radius = math.min(rect.width, rect.height) * 0.5
			local offsetX = mousePosition.x - centerX
			local offsetY = mousePosition.y - centerY

			if offsetX * offsetX + offsetY * offsetY <= radius * radius then
				return domainIndex
			end
		end
	end

	return 0
end

function WheelOfDestiny.getSliceIndex(mousePosition)
	local center = centerReferencePoint:getCenter()
	local x = center.x
	local y = center.y
	local topLeft = WheelSettings.topLeft

	if x >= mousePosition.x then
		if y < mousePosition.y then
			topLeft = WheelSettings.bottomLeft
		else
			topLeft = WheelSettings.topLeft
		end
	elseif y < mousePosition.y then
		topLeft = WheelSettings.bottomRight
	else
		topLeft = WheelSettings.topRight
	end

	local offsetX = mousePosition.x - x
	local offsetY = mousePosition.y - y
	local distanceSquared = offsetX * offsetX + offsetY * offsetY
	local candidateSlices = {}

	for unusedValue, entry in pairs(topLeft) do
		if WheelButtons[entry] then
			table.insert(candidateSlices, entry)
		end
	end

	table.sort(candidateSlices, function(leftSliceIndex, rightSliceIndex)
		local visualRing = WheelButtons.getVisualRing(WheelButtons[leftSliceIndex].radius)
		local rightVisualRing = WheelButtons.getVisualRing(WheelButtons[rightSliceIndex].radius)

		return visualRing.outer < rightVisualRing.outer
	end)

	for unusedValue, entry in ipairs(candidateSlices) do
		local sliceButton = WheelButtons[entry]
		local visualRing = WheelButtons.getVisualRing(sliceButton.radius)
		local innerRadius = math.max(0, visualRing.inner - 1)
		local outerRadius = visualRing.outer + 1

		if distanceSquared >= innerRadius * innerRadius and distanceSquared <= outerRadius * outerRadius and Circle.new(x, y, outerRadius):isPointInSlice(mousePosition, sliceButton.slice, sliceButton.totalSlice) then
			return entry
		end
	end

	return 0
end

local function resolveSelectedSliceIndex(clickIndex)
	if type(clickIndex) ~= "number" or clickIndex < 1 then
		clickIndex = WheelOfDestiny.clickIndex
	end

	if type(clickIndex) ~= "number" or clickIndex < 1 then
		return 0
	end

	return clickIndex
end

local function getInvestedSlicePoints(sliceIndex)
	return WheelOfDestiny.pointInvested[sliceIndex] or 0
end

function WheelOfDestiny.canAddPoints(sliceIndex, ignorePointLimits)
	if WheelOfDestiny.isPreview then
		return false
	end

	if WheelOfDestiny.vocationId == 0 then
		return false
	end

	if ignorePointLimits == nil then
		ignorePointLimits = false
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return false
	end

	if not ignorePointLimits and getInvestedSlicePoints(sliceIndex) >= bonusDefinition.maxPoints then
		return false
	end

	if not WheelOfDestiny.points then
		WheelOfDestiny.points = 0
	end

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	if not ignorePointLimits and totalAvailablePoints - WheelOfDestiny.usedPoints <= 0 then
		return false
	end

	if bonusDefinition.maxPoints == 50 then
		return true
	end

	local sliceNode = WheelNodes[sliceIndex]

	if not sliceNode or not sliceNode.connecteds or #sliceNode.connecteds == 0 then
		return true
	end

	for unusedValue, connected in pairs(sliceNode.connecteds) do
		local connectedBonusDefinition = WheelBonus[connected - 1]

		if connectedBonusDefinition and getInvestedSlicePoints(connected) >= connectedBonusDefinition.maxPoints then
			return true
		end
	end

	return false
end

function WheelOfDestiny.canRemovePoints(sliceIndex)
	if WheelOfDestiny.isPreview then
		return false
	end

	if not WheelOfDestiny.isLit(sliceIndex) then
		return false
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	local sliceButton = WheelButtons[sliceIndex]

	if sliceButton and sliceButton.radius == BIG_LARGE_CIRCLE then
		return true
	end

	local sliceNode = WheelNodes[sliceIndex]

	if not sliceNode or not sliceNode.connections or #sliceNode.connections == 0 then
		return true
	end

	for unusedValue, connection in pairs(sliceNode.connections) do
		if WheelOfDestiny.isLit(connection) and not canReachRootNodeFromNode(connection, sliceIndex) then
			return false
		end
	end

	return true
end

function WheelOfDestiny.isLit(sliceIndex)
	return getInvestedSlicePoints(sliceIndex) > 0
end

function WheelOfDestiny.isLitFull(sliceIndex)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return false
	end

	return getInvestedSlicePoints(sliceIndex) == bonusDefinition.maxPoints
end

function WheelOfDestiny.insertUnlockedThe(sliceIndex)
	local sliceNode = WheelNodes[sliceIndex]

	if not sliceNode or not sliceNode.connections or #sliceNode.connections == 0 then
		return false
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return false
	end

	if getInvestedSlicePoints(sliceIndex) < bonusDefinition.maxPoints then
		return false
	end

	for unusedValue, connection in pairs(sliceNode.connections) do
		WheelOfDestiny.showUnlockedPreview(connection)
	end
end

function WheelOfDestiny.removeUnlockedThe(sliceIndex)
	local sliceNode = WheelNodes[sliceIndex]

	if not sliceNode or not sliceNode.connections or #sliceNode.connections == 0 then
		return false
	end

	for unusedValue, connection in pairs(sliceNode.connections) do
		local litParentConnections = {}

		for unusedValue, connected in ipairs(WheelNodes[connection].connecteds) do
			if connected ~= sliceIndex and WheelOfDestiny.isLit(connected) then
				litParentConnections[#litParentConnections + 1] = connection
			end
		end

		if not table.isIn(litParentConnections, connection) then
			local slicePair = WheelOfDestiny.getSlicePair(connection)
			local sliceFillWidget = slicePair and slicePair.full

			if sliceFillWidget and (WheelOfDestiny.pointInvested[connection] or 0) <= 0 then
				sliceFillWidget:setVisible(false)
				sliceFillWidget:setOpacity(FULL_COLOR_WHEEL_OPACITY)
			end
		end
	end
end

function WheelOfDestiny.onWheelClick(mousePosition)
	local sliceIndex = WheelOfDestiny.getSliceIndex(mousePosition)

	if sliceIndex == 0 then
		return
	end

	WheelOfDestiny.resetPassiveFocus()

	local investedPoints = WheelOfDestiny.pointInvested[sliceIndex]

	if not investedPoints then
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

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	wheelOfDestinyWindow.selection.tabContent.information1:setTooltip(ConvictionTooltip)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(investedPoints, 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(investedPoints .. " / " .. bonusDefinition.maxPoints)
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

function WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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

	if WheelOfDestiny.canAddPoints(sliceIndex) then
		wheelOfDestinyWindow:recursiveGetChildById("addMax"):setEnabled(true)
		wheelOfDestinyWindow:recursiveGetChildById("addOne"):setEnabled(true)
	else
		wheelOfDestinyWindow:recursiveGetChildById("addMax"):setEnabled(false)
		wheelOfDestinyWindow:recursiveGetChildById("addOne"):setEnabled(false)
	end

	if WheelOfDestiny.canRemovePoints(sliceIndex) then
		wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setEnabled(true)
		wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setEnabled(true)
	else
		wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setEnabled(false)
		wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setEnabled(false)
	end
end

function WheelOfDestiny.onMouseRelease(unusedArgument, mousePosition, mouseButton)
	if mouseButton ~= MouseRightButton then
		return
	end

	local sliceIndex = WheelOfDestiny.getSliceIndex(mousePosition)

	if sliceIndex == 0 then
		return
	end

	local requestedPointCount = 0

	if g_keyboard.getModifiers() == KeyboardAltModifier then
		requestedPointCount = 1
	elseif g_keyboard.getModifiers() == KeyboardShiftModifier then
		requestedPointCount = 50
	elseif g_keyboard.getModifiers() == KeyboardCtrlModifier then
		requestedPointCount = 100
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]
	local investedPoints = getInvestedSlicePoints(sliceIndex)

	if bonusDefinition and investedPoints > bonusDefinition.maxPoints then
		if not WheelOfDestiny.canRemovePoints(sliceIndex) then
			return
		end

		onRmvMax(sliceIndex)
		WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
		WheelOfDestiny.onWheelClick(mousePosition)
	else
		if not WheelOfDestiny.canAddPoints(sliceIndex) then
			if WheelOfDestiny.canRemovePoints(sliceIndex) then
				onRmvMax(sliceIndex)
				WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
				WheelOfDestiny.onWheelClick(mousePosition)
			end

			return
		end

		if requestedPointCount ~= 0 then
			onAddCustom(sliceIndex, requestedPointCount)
		else
			WheelOfDestiny.onAddMax(sliceIndex)
		end

		WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
	end

	WheelOfDestiny.onWheelClick(mousePosition)

	return true
end

function WheelOfDestiny.onMouseMove(unusedArgument, mousePosition, unusedArgument)
	local passiveDomain = WheelOfDestiny.getPassiveDomain(mousePosition)

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

	local sliceIndex = WheelOfDestiny.getSliceIndex(mousePosition)

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

function WheelOfDestiny.insertPoint(sliceIndex, investedPoints)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	WheelOfDestiny.updateSliceFill(sliceIndex, investedPoints)

	if investedPoints > 0 and investedPoints >= bonusDefinition.maxPoints then
		WheelOfDestiny.insertUnlockedThe(sliceIndex)

		if WheelOfDestiny.isVesselSlice(sliceIndex) then
			WheelOfDestiny.refreshVesselDomain(bonusDefinition.domain - 1)
		else
			local icon = wheelPanel:recursiveGetChildById("icon" .. sliceIndex)
			local iconDefinition = WheelIcons[WheelOfDestiny.vocationId][sliceIndex]

			icon:setImageClip(iconDefinition.iconRect)
		end
	end
end

function WheelOfDestiny.isVesselSlice(sliceIndex)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	return bonusDefinition ~= nil and bonusDefinition.conviction == "vessel"
end

local function resetVesselSliceIcon(sliceIndex)
	local icon = wheelPanel:recursiveGetChildById("icon" .. sliceIndex)
	local iconDefinition = WheelIcons[WheelOfDestiny.vocationId] and WheelIcons[WheelOfDestiny.vocationId][sliceIndex]

	if not icon or not iconDefinition then
		return nil
	end

	icon:setImageSource("/images/game/wheel/icons-skillwheel-mediumperks")
	icon:setImageClip(iconDefinition.iconRect)
	icon:setSize(tosize("30 30"))

	local modIcon = icon:recursiveGetChildById("modIcon" .. sliceIndex)

	if modIcon then
		modIcon:setVisible(false)
	end

	return icon, modIcon
end

function WheelOfDestiny.refreshVesselDomain(domainIndex)
	local domainSliceOrder = WheelDomainOrder[domainIndex]

	if not domainSliceOrder or not wheelPanel then
		return
	end

	local equipedGem = GemAtelier.getEquipedGem(domainIndex)
	local enabledVesselSlices = {}

	for unusedValue, entry in ipairs(domainSliceOrder) do
		local bonusDefinition = WheelBonus[entry - 1]

		if bonusDefinition and bonusDefinition.conviction == "vessel" then
			local vesselIconWidget, modIconWidget = resetVesselSliceIcon(entry)

			WheelOfDestiny.equipedGemBonuses[entry] = nil

			if (WheelOfDestiny.pointInvested[entry] or 0) >= bonusDefinition.maxPoints then
				table.insert(enabledVesselSlices, entry)

				local bonusId, isSupremeBonus = WheelGemState.getGemModBonus(equipedGem, #enabledVesselSlices)

				if vesselIconWidget and bonusId then
					if isSupremeBonus then
						vesselIconWidget:setImageSource("/images/game/wheel/icons-skillwheel-suprememods")
						vesselIconWidget:setImageClip(getSupremeModIconClip(bonusId))
						vesselIconWidget:setSize(tosize("35 35"))
					else
						vesselIconWidget:setImageSource("/images/game/wheel/icons-skillwheel-basicmods")
						vesselIconWidget:setImageClip(30 * bonusId .. " 0 30 30")
					end

					if modIconWidget then
						modIconWidget:setVisible(true)
					end

					WheelOfDestiny.equipedGemBonuses[entry] = {
						bonusID = bonusId,
						supreme = isSupremeBonus,
						gemID = equipedGem.gemID
					}
				end
			end
		end
	end

	WheelOfDestiny.vesselEnabled[domainIndex] = enabledVesselSlices
end

function WheelOfDestiny.refreshAllVesselDomains()
	for domainIndex = 0, 3 do
		WheelOfDestiny.refreshVesselDomain(domainIndex)
	end
end

function WheelOfDestiny.removePoint(sliceIndex, investedPoints)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	WheelOfDestiny.updateSliceFill(sliceIndex, investedPoints)

	if investedPoints > 0 and investedPoints >= bonusDefinition.maxPoints then
		WheelOfDestiny.insertUnlockedThe(sliceIndex)
	elseif WheelOfDestiny.isVesselSlice(sliceIndex) then
		WheelOfDestiny.refreshVesselDomain(bonusDefinition.domain - 1)
	end
end

function WheelOfDestiny.onAddMax(sliceIndex)
	if WheelOfDestiny.isPreview then
		return
	end

	sliceIndex = resolveSelectedSliceIndex(sliceIndex)

	if sliceIndex == 0 then
		return
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	local investedPoints = getInvestedSlicePoints(sliceIndex)

	if investedPoints >= bonusDefinition.maxPoints then
		return
	end

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)
	local remainingPoints = math.max(totalAvailablePoints - WheelOfDestiny.usedPoints, 0)

	if remainingPoints == 1 then
		return onAddOne(sliceIndex)
	end

	local maxSlicePoints = math.max(bonusDefinition.maxPoints, 0)

	if not WheelOfDestiny.canAddPoints(sliceIndex, true) then
		return
	end

	WheelOfDestiny.pointInvested[sliceIndex] = math.min(investedPoints + remainingPoints, maxSlicePoints)

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[sliceIndex], 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[sliceIndex] .. " / " .. bonusDefinition.maxPoints)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.insertPoint(sliceIndex, WheelOfDestiny.pointInvested[sliceIndex])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local sliceBonusDefinition = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] = WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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

function onAddOne(sliceIndex)
	if WheelOfDestiny.isPreview then
		return
	end

	sliceIndex = resolveSelectedSliceIndex(sliceIndex)

	if sliceIndex == 0 then
		return
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	local investedPoints = getInvestedSlicePoints(sliceIndex)

	if investedPoints >= bonusDefinition.maxPoints then
		return
	end

	if not WheelOfDestiny.canAddPoints(sliceIndex) then
		return
	end

	WheelOfDestiny.pointInvested[sliceIndex] = investedPoints + 1

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[sliceIndex], 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[sliceIndex] .. " / " .. bonusDefinition.maxPoints)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.insertPoint(sliceIndex, WheelOfDestiny.pointInvested[sliceIndex])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local sliceBonusDefinition = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] = WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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

function onAddCustom(sliceIndex, requestedPointCount)
	if WheelOfDestiny.isPreview then
		return
	end

	sliceIndex = resolveSelectedSliceIndex(sliceIndex)

	if sliceIndex == 0 then
		return
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	local investedPoints = getInvestedSlicePoints(sliceIndex)

	if investedPoints >= bonusDefinition.maxPoints then
		return
	end

	if not WheelOfDestiny.canAddPoints(sliceIndex) then
		return
	end

	if type(requestedPointCount) ~= "number" or requestedPointCount <= 0 then
		return
	end

	local remainingPoints = math.max(WheelOfDestiny.points + WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints - WheelOfDestiny.usedPoints, 0)
	local newInvestedPoints = math.min(bonusDefinition.maxPoints, investedPoints + math.min(requestedPointCount, remainingPoints))

	WheelOfDestiny.pointInvested[sliceIndex] = newInvestedPoints

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[sliceIndex], 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[sliceIndex] .. " / " .. bonusDefinition.maxPoints)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.insertPoint(sliceIndex, WheelOfDestiny.pointInvested[sliceIndex])

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local sliceBonusDefinition = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] = WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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

function onRmvMax(sliceIndex)
	if WheelOfDestiny.isPreview then
		return
	end

	sliceIndex = resolveSelectedSliceIndex(sliceIndex)

	if sliceIndex == 0 then
		return
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	if getInvestedSlicePoints(sliceIndex) == 0 then
		return
	end

	if not WheelOfDestiny.canRemovePoints(sliceIndex) then
		return
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	WheelOfDestiny.pointInvested[sliceIndex] = 0

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[sliceIndex], 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[sliceIndex] .. " / " .. bonusDefinition.maxPoints)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.removePoint(sliceIndex, WheelOfDestiny.pointInvested[sliceIndex])
	WheelOfDestiny.removeUnlockedThe(sliceIndex)

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local sliceBonusDefinition = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] = WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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

function onRmvOne(sliceIndex)
	if WheelOfDestiny.isPreview then
		return
	end

	sliceIndex = resolveSelectedSliceIndex(sliceIndex)

	if sliceIndex == 0 then
		return
	end

	if not WheelOfDestiny.canRemovePoints(sliceIndex) then
		return
	end

	if WheelOfDestiny.changeState ~= 1 then
		return false
	end

	local investedPoints = getInvestedSlicePoints(sliceIndex)

	if investedPoints == 0 then
		return
	end

	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	WheelOfDestiny.pointInvested[sliceIndex] = investedPoints - 1

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(WheelOfDestiny.pointInvested[sliceIndex], 0, bonusDefinition.maxPoints)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(WheelOfDestiny.pointInvested[sliceIndex] .. " / " .. bonusDefinition.maxPoints)
	WheelOfDestiny.configureDedication(sliceIndex)
	WheelOfDestiny.configureConviction(sliceIndex)
	WheelOfDestiny.removePoint(sliceIndex, WheelOfDestiny.pointInvested[sliceIndex])
	WheelOfDestiny.removeUnlockedThe(sliceIndex)

	WheelOfDestiny.passivePoints = table.reserve(4, 0)

	local usedPoints = 0

	for key, entry in pairs(WheelOfDestiny.pointInvested) do
		usedPoints = usedPoints + entry

		local sliceBonusDefinition = WheelBonus[key - 1]

		WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] = WheelOfDestiny.passivePoints[sliceBonusDefinition.domain] + entry
	end

	WheelOfDestiny.usedPoints = usedPoints

	local totalAvailablePoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalAvailablePoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalAvailablePoints))
	WheelOfDestiny.checkManagerPointsButtons(sliceIndex)
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
