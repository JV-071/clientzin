GemAtelier = {}
GemAtelier.__index = GemAtelier

local lockedOnly = false
local sortQuality = 1
local sortAffinity = 1
local currentPage = 1
local destroyGemWindow
local lastSelectedGem
local var_0_6
local currentGemList = {}
local totalGemList = {}
local currentSearchText = ""
local cachedBasicMods = {}
local cachedSupremeMods = {}

function GemAtelier.resetFields()
	lockedOnly = false
	sortQuality = 1
	sortAffinity = 1
	destroyGemWindow = nil
	lastSelectedGem = nil
	currentGemList = {}
	currentSearchText = ""
	totalGemList = {}
	currentPage = 1

	gemAtelierWindow:recursiveGetChildById("filterPanel").searchText:clearText()
	gemAtelierWindow:recursiveGetChildById("affinitiesBox"):setCurrentIndex(1, true)
	gemAtelierWindow:recursiveGetChildById("qualitiesBox"):setCurrentIndex(1, true)
	gemAtelierWindow:recursiveGetChildById("lockedOnly"):setChecked(false, true)

	if var_0_6 then
		var_0_6:setVisible(false)

		var_0_6 = nil
	end

	cachedBasicMods, cachedSupremeMods = ModCatalog.buildModCache()
end

function GemAtelier.redirectToGem(gemData)
	if not WheelOfDestiny or not gemAtelierWindow then
		return true
	end

	GemAtelier.resetFields()
	GemAtelier.setupVesselPanel()

	local gemList = gemAtelierWindow:recursiveGetChildById("gemContent")

	if not gemList then
		return true
	end

	if gemData then
		local affinityWidget = gemAtelierWindow:recursiveGetChildById("affinitiesBox")
		local qualityWidget = gemAtelierWindow:recursiveGetChildById("qualitiesBox")

		affinityWidget:setCurrentIndex(gemData.gemDomain + 2, true)
		qualityWidget:setCurrentIndex(1, true)

		sortQuality = 1
		sortAffinity = gemData.gemDomain + 2

		local highLight = gemAtelierWindow:recursiveGetChildById("selectVessel" .. gemData.gemDomain)

		highLight:setVisible(true)

		if var_0_6 then
			var_0_6:setVisible(false)
		end

		var_0_6 = highLight
	end

	gemList:destroyChildren()

	totalGemList = {}
	currentGemList = {}

	local index = 1
	local foundIndex = 1

	for i, data in pairs(WheelOfDestiny.atelierGems) do
		if sortQuality > 1 and data.gemType ~= sortQuality - 2 or sortAffinity > 1 and data.gemDomain ~= sortAffinity - 2 then
			-- block empty
		else
			if gemData.gemID == data.gemID then
				currentPage = math.ceil(index / 15)

				local foundIndex = math.max(1, index - 15)
			end

			index = index + 1

			table.insert(totalGemList, data)
		end
	end

	local gemCount = 0
	local beginList = (currentPage - 1) * 15 + 1
	local focusedGem

	for i, data in pairs(totalGemList) do
		if gemCount == 15 then
			break
		end

		if i < beginList then
			-- block empty
		else
			local widget = g_ui.createWidget("GemPanel", gemList)

			if GemAtelier.setupGemWidget(widget, data) then
				currentGemList[#currentGemList + 1] = data

				if widget then
					widget.gemIndex = #currentGemList
				end

				gemCount = gemCount + 1

				if data.gemID == gemData.gemID then
					focusedGem = widget
				end
			else
				widget:destroy()
			end
		end
	end

	GemAtelier.showGemRevelation()
	GemAtelier.configurePages()

	function gemList.onChildFocusChange(self, selected)
		GemAtelier.onSelectGem(selected, true)
	end

	focusedGem = focusedGem or gemList:getFirstChild()

	gemList:focusChild(focusedGem, ActiveFocusReason, true)
	GemAtelier.onSelectGem(focusedGem, true)
end

function GemAtelier.showGems(selectFirst, lastIndex)
	if not WheelOfDestiny or not gemAtelierWindow then
		return true
	end

	GemAtelier.setupVesselPanel()

	local gemList = gemAtelierWindow:recursiveGetChildById("gemContent")

	if not gemList then
		return true
	end

	totalGemList = {}
	currentGemList = {}

	for i, data in pairs(WheelOfDestiny.atelierGems) do
		if not data.gemID or data.gemID < 0 then
			-- block empty
		else
			local isLocked = data.locked == 1 or data.locked == true

			if lockedOnly and not isLocked then
				goto label_4_0
			elseif sortQuality > 1 and data.gemType ~= sortQuality - 2 then
				goto label_4_0
			elseif sortAffinity > 1 and data.gemDomain ~= sortAffinity - 2 then
				goto label_4_0
			elseif #currentSearchText > 0 and not GemAtelier.matchGemText(data) then
				goto label_4_0
			end

			table.insert(totalGemList, data)
		end

		::label_4_0::
	end

	gemList:destroyChildren()

	function gemList.onChildFocusChange(self, selected)
		GemAtelier.onSelectGem(selected, true)
	end

	local gemCount = 0
	local beginList = (currentPage - 1) * 15 + 1

	for i, data in pairs(totalGemList) do
		if gemCount == 15 then
			break
		end

		if i < beginList then
			-- block empty
		else
			local widget = g_ui.createWidget("GemPanel", gemList)

			if GemAtelier.setupGemWidget(widget, data) then
				currentGemList[#currentGemList + 1] = data

				if widget then
					widget.gemIndex = #currentGemList
				end

				gemCount = gemCount + 1
			else
				widget:destroy()
			end
		end
	end

	GemAtelier.showGemRevelation()
	GemAtelier.configurePages()

	local panel = gemAtelierWindow:recursiveGetChildById("clickedPanel")
	local children = gemList:getChildren()

	if #children == 0 then
		panel.clickedContent:setVisible(false)
		panel.cleanContent:setVisible(true)
	else
		gemList:focusChild(nil)
		panel.cleanContent:setVisible(false)

		if selectFirst then
			gemList:focusChild(gemList:getFirstChild())
		elseif lastIndex then
			gemList:focusChild(children[lastIndex])
		elseif lastSelectedGem and lastSelectedGem:isVisible() and lastSelectedGem.gemID then
			local targetIndex = 0

			for i, widget in ipairs(children) do
				if widget.gemID == lastSelectedGem.gemID then
					targetIndex = i

					break
				end
			end

			if targetIndex > 0 then
				gemList:focusChild(children[targetIndex])
			elseif #children > 0 then
				gemList:focusChild(children[1])
			end
		elseif #children > 0 then
			gemList:focusChild(children[1])
		end
	end
end

function GemAtelier.matchGemText(data)
	local descriptions = {
		RegularGemDescription[data.lesserBonus].text,
		cachedBasicMods[data.lesserBonus].tooltip
	}

	if data.gemType > 0 then
		table.insert(descriptions, RegularGemDescription[data.regularBonus].text)
		table.insert(descriptions, cachedBasicMods[data.regularBonus].tooltip)
	end

	if data.gemType > 1 then
		table.insert(descriptions, SupremeGemDescription[data.supremeBonus].text)
		table.insert(descriptions, cachedSupremeMods[data.supremeBonus].tooltip)
	end

	for _, text in pairs(descriptions) do
		if matchText(currentSearchText, text) then
			return true
		end
	end

	return false
end

function GemAtelier.setupGemWidget(widget, data)
	if not widget then
		return false
	end

	if data and data.gemID and data.gemID >= 0 then
		widget.gemID = data.gemID
	else
		widget.gemID = -1

		return false
	end

	if not data then
		return false
	end

	if not data.gemType or not data.gemDomain then
		return false
	end

	local typeOffset = data.gemType * 32
	local domainOffset = data.gemDomain * 96
	local var_7_2 = (WheelOfDestiny.vocationId - 1) * 384 + domainOffset + typeOffset
	local tmpData = GemVocations[WheelOfDestiny.vocationId][data.gemType]

	if not tmpData then
		return false
	end

	local lockedState = data.locked == 1

	widget.locker:setChecked(lockedState)

	widget.locker.onClick = GemAtelier.onLockGem
	widget.locker.gemID = data.gemID

	widget.gemRevelationItem:setImageClip(var_7_2 .. " 0 32 32")
	widget.gemRevelationItem:setTooltip(tmpData.name:gsub(" %(x 0%)", ""))

	if GemAtelier.isGemEquipped(data.gemID) then
		widget.gemDomainImage:setVisible(true)
		widget.gemDomainImage:setImageClip(data.gemDomain * 26 .. " 0 26 26")
	end

	local gemTypeWidget = widget:recursiveGetChildById("modType" .. data.gemType)

	if not gemTypeWidget then
		return false
	end

	gemTypeWidget:setVisible(true)
	GemAtelier.setupGemSlot(gemTypeWidget.fragmentType0.gemMod0, data.lesserBonus, WheelOfDestiny.basicModsUpgrade, false, data, 0)
	GemAtelier.setGemUpgradeImage(gemTypeWidget.fragmentType0, data.lesserBonus, WheelOfDestiny.basicModsUpgrade, nil)

	if data.gemType > 0 then
		GemAtelier.setupGemSlot(gemTypeWidget.fragmentType1.gemMod1, data.regularBonus, WheelOfDestiny.basicModsUpgrade, false, data, 1)
		GemAtelier.setGemUpgradeImage(gemTypeWidget.fragmentType1, data.regularBonus, WheelOfDestiny.basicModsUpgrade, WheelOfDestiny.basicModsUpgrade[data.lesserBonus] or 0, true)
	end

	if data.gemType > 1 then
		GemAtelier.setupGemSlot(gemTypeWidget.fragmentType2.gemMod2, data.supremeBonus, WheelOfDestiny.supremeModsUpgrade, true, data, 2)

		local effectiveBonus = math.min(WheelOfDestiny.basicModsUpgrade[data.lesserBonus] or 0, WheelOfDestiny.basicModsUpgrade[data.regularBonus] or 0)

		GemAtelier.setGemUpgradeImage(gemTypeWidget.fragmentType2, data.supremeBonus, WheelOfDestiny.supremeModsUpgrade, effectiveBonus)
	end

	return true
end

function GemAtelier.setupGemSlot(gemSlot, bonus, upgradeData, isSupreme, gemData, gemPosition)
	if not gemSlot then
		return
	end

	gemSlot:setImageSmooth(false)

	if isSupreme then
		gemSlot:setImageClip(getSupremeModIconClip(bonus))
	else
		gemSlot:setImageClip(bonus * 30 .. " 0 30 30")
	end

	GemAtelier.createGemInformation(gemSlot, bonus, isSupreme, true, gemData, gemPosition)
end

function GemAtelier.setGemUpgradeImage(gemFragment, bonus, upgradeData, prevBonus, debug)
	local upgradeLevel = upgradeData[bonus] or 0

	if prevBonus then
		if prevBonus < upgradeLevel then
			gemFragment.potential:setVisible(true)
			gemFragment.potential:setImageClip(upgradeLevel * 50 .. " 0 50 50")
			gemFragment:setImageClip(prevBonus * 50 .. " 0 50 50")
		else
			gemFragment:setImageClip(upgradeLevel * 50 .. " 0 50 50")
		end
	else
		gemFragment:setImageClip(upgradeLevel * 50 .. " 0 50 50")
	end
end

function GemAtelier.showGemRevelation()
	local data = GemVocations[WheelOfDestiny.vocationId]

	if not data then
		return true
	end

	local player = g_game:getLocalPlayer()
	local revelation = gemAtelierWindow.gemRevelation
	local totalBalance = player:getResourceBalance(ResourceTypes.BANK_BALANCE) + player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local resources = {
		[0] = player:getResourceBalance(ResourceTypes.LESSER_GEMS),
		player:getResourceBalance(ResourceTypes.REGULAR_GEMS),
		(player:getResourceBalance(ResourceTypes.GREATER_GEMS))
	}

	for i = 0, 2 do
		local itemWidget = revelation:recursiveGetChildById("gemRevelationItem" .. i)
		local gemInfo = revelation:recursiveGetChildById("gemInfo" .. i)
		local revealCost = revelation:recursiveGetChildById("gemRevealCost" .. i)
		local button = revelation:recursiveGetChildById("revealButton" .. i)

		itemWidget:setItemId(data[i].id)
		gemInfo:setText(data[i].name:gsub("%d", resources[i]))
		gemInfo:setMarginTop(60)

		if not gemInfo:isTextWrap() then
			gemInfo:setMarginTop(67)
		end

		revealCost.gold:setText(comma_value(GemRevealPrice[i] / 1000) .. "k")

		local toolTip = ""

		button:setOn(true)
		button:setTooltip("")

		if totalBalance < GemRevealPrice[i] then
			toolTip = tr(GemStaticTooltips[0], comma_value(GemRevealPrice[i]))
		end

		if resources[i] < 1 then
			toolTip = tr("%s" .. GemStaticTooltips[1], #toolTip > 0 and toolTip .. "\n" or "", comma_value(GemRevealPrice[i]))
		end

		if WheelOfDestiny.changeState ~= 1 or WheelOfDestiny.isPreview then
			toolTip = tr("%s%s", #toolTip > 0 and toolTip .. "\n" or "", GemStaticTooltips[2])
		end

		if #WheelOfDestiny.atelierGems >= 225 then
			toolTip = tr("%s%s", #toolTip > 0 and toolTip .. "\n" or "", GemStaticTooltips[3])
		end

		if #toolTip > 0 then
			button:setTooltip(toolTip)
			button:setOn(false)
		end
	end
end

function GemAtelier.configurePages()
	if not gemAtelierWindow then
		return true
	end

	local panel = gemAtelierWindow:recursiveGetChildById("filterPanel")
	local totalCount = #totalGemList
	local maxPage = math.max(1, math.ceil(totalCount / 15))

	panel.pagesPanel.pagesLabel:setText(tr("Page %s / %s (%s Gems)", currentPage, maxPage, totalCount))

	if currentPage == 1 and maxPage == 1 then
		panel.pagesPanel.leftArrow:setOn(false)
		panel.pagesPanel.rightArrow:setOn(false)
	end

	if currentPage == 1 and maxPage > 1 then
		panel.pagesPanel.leftArrow:setOn(false)
		panel.pagesPanel.rightArrow:setOn(true)
	end

	if currentPage > 1 and maxPage > currentPage then
		panel.pagesPanel.leftArrow:setOn(true)
		panel.pagesPanel.rightArrow:setOn(true)
	end

	if currentPage > 1 and currentPage == maxPage then
		panel.pagesPanel.leftArrow:setOn(true)
		panel.pagesPanel.rightArrow:setOn(false)
	end
end

function GemAtelier.managePage(button, foward)
	if not button:isOn() then
		return true
	end

	local totalCount = #WheelOfDestiny.atelierGems
	local maxPage = math.max(1, math.ceil(totalCount / 15))

	if foward then
		currentPage = math.min(currentPage + 1, math.ceil(maxPage))
	else
		currentPage = math.max(1, currentPage - 1)
	end

	GemAtelier.showGems(true)
end

function shortenAfterCooldown(text)
	local cooldownIndex = text:find("Cooldown")

	if cooldownIndex then
		local afterCooldownIndex = cooldownIndex + #"Cooldown" - 1

		if text:sub(afterCooldownIndex + 1):match("%S") then
			return text:sub(1, afterCooldownIndex) .. "…"
		else
			return text
		end
	else
		return text
	end
end

function GemAtelier.getEffectiveLevel(gemData, currentBonusID, supreme, gemSlot)
	return WheelGemState.getEffectiveLevel(gemData, currentBonusID, supreme, gemSlot)
end

function GemAtelier.createGemInformation(widget, gemTypeID, supremeMod, tooltip, gemData, gemSlot)
	local search

	if supremeMod then
		search = cachedSupremeMods[gemTypeID]
	else
		search = cachedBasicMods[gemTypeID]
	end

	if not search then
		return true
	end

	local function shortenAfterCooldown(text)
		local cooldownIndex = text:find("Cooldown")

		if cooldownIndex then
			local afterCooldownIndex = cooldownIndex + #"Cooldown" - 1

			if text:sub(afterCooldownIndex + 1):match("%S") then
				return text:sub(1, afterCooldownIndex) .. "...", true
			else
				return text, false
			end
		else
			return text, false
		end
	end

	local shorted = false
	local currentTier = GemAtelier.getEffectiveLevel(gemData, gemTypeID, supremeMod, gemSlot)
	local text = Workshop.getBonusDescription(search, currentTier)

	if tooltip then
		widget:setTooltip(text)
	else
		local originalText = text
		local text, shorted = shortenAfterCooldown(text)

		widget:setTooltip(shorted and originalText or "")
		widget:setText(text)
	end
end

function GemAtelier.onSelectGem(selected, clicked)
	if not selected or not selected.gemID then
		return true
	end

	if #currentGemList == 0 then
		return true
	end

	local gemData = GemAtelier.getGemDataById(selected.gemID)

	if not gemData then
		return true
	end

	if lastSelectedGem then
		lastSelectedGem:setBorderWidth(0)
		lastSelectedGem:setBorderColor("alpha")
	end

	lastSelectedGem = selected

	lastSelectedGem:setBorderWidth(2)
	lastSelectedGem:setBorderColor("white")

	local panel = gemAtelierWindow:recursiveGetChildById("clickedPanel")

	if panel.cleanContent:isVisible() then
		panel.cleanContent:setVisible(false)
	end

	panel.clickedContent:setVisible(true)

	function panel.clickedContent.placeVessel.onClick()
		GemAtelier.manageVessel(false)
	end

	function panel.clickedContent.removeVessel.onClick()
		GemAtelier.manageVessel(true)
	end

	panel.clickedContent.switch.onClick = GemAtelier.onSwitchDomain
	panel.clickedContent.destroy.onClick = GemAtelier.onDestroyGem

	local typeOffset = gemData.gemType * 64
	local domainOffset = gemData.gemDomain * 192
	local vocationOffset = (WheelOfDestiny.vocationId - 1) * 64
	local gemOffset = domainOffset + typeOffset
	local gemText = GemVocations[WheelOfDestiny.vocationId][gemData.gemType].name

	panel.clickedContent.gemDetails.gemName:setText(string.gsub(gemText, " %(x 0%)", ""))
	panel.clickedContent.gemDetails.gemDetailItem:setImageClip(gemOffset .. " " .. vocationOffset .. " 64 64")
	panel.clickedContent.gemDetails.domain:setImageClip(gemData.gemDomain * 26 .. " 0 26 26")

	local widgetMods = panel.clickedContent.gemMods

	for i = 0, 2 do
		widgetMods:recursiveGetChildById("fragmentType" .. i):setVisible(false)
		widgetMods:recursiveGetChildById("gemModItem" .. i):setVisible(false)
		widgetMods:recursiveGetChildById("modLabel" .. i):setVisible(false)
	end

	widgetMods.fragmentType0.gemModItem0:setImageClip(gemData.lesserBonus * 30 .. " 0 30 30")
	GemAtelier.setupModAvailable(widgetMods, 0, 1, gemData)
	GemAtelier.createGemInformation(widgetMods.modLabel0, gemData.lesserBonus, false, false, gemData, 0)

	if gemData.gemType > 0 then
		widgetMods.fragmentType1.gemModItem1:setImageClip(gemData.regularBonus * 30 .. " 0 30 30")
		GemAtelier.setupModAvailable(widgetMods, 1, 2, gemData)
		GemAtelier.createGemInformation(widgetMods.modLabel1, gemData.regularBonus, false, false, gemData, 1)
	end

	if gemData.gemType > 1 then
		widgetMods.fragmentType2.gemModItem2:setImageClip(getSupremeModIconClip(gemData.supremeBonus))
		GemAtelier.setupModAvailable(widgetMods, 2, 3, gemData)
		GemAtelier.createGemInformation(widgetMods.modLabel2, gemData.supremeBonus, true, false, gemData, 2)
	end

	local player = g_game:getLocalPlayer()
	local totalBalance = player:getResourceBalance(ResourceTypes.BANK_BALANCE) + player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
	local price = GemSwitchPrice[gemData.gemType] or 0
	local enough = price <= totalBalance
	local goldWidget = panel.clickedContent.switchCost.gold

	goldWidget:setText(price / 1000 .. "k")
	goldWidget:setColor(enough and "#c0c0c0" or "#d33c3c")
	panel.clickedContent.switchCost:setTooltip(comma_value(price))

	local alreadyEquipped = false
	local isTheSameGem = false

	for _, id in pairs(WheelOfDestiny.equipedGems or {}) do
		if type(id) == "number" and id >= 0 and GemAtelier.getGemDomainById(id) == gemData.gemDomain then
			alreadyEquipped = true

			if id == gemData.gemID then
				isTheSameGem = true
			end

			break
		end
	end

	if alreadyEquipped and isTheSameGem then
		panel.clickedContent.placeVessel:setVisible(false)
		panel.clickedContent.removeVessel:setVisible(true)
	else
		panel.clickedContent.placeVessel:setVisible(true)
		panel.clickedContent.removeVessel:setVisible(false)
	end

	local switchTip = ""
	local destroyTip = ""
	local canInteract = WheelOfDestiny.changeState == 1 and gemData.locked == 0 and not WheelOfDestiny.isPreview

	panel.clickedContent.switch:setOn(canInteract)
	panel.clickedContent.destroy:setOn(canInteract)

	if GemAtelier.getGemCountByDomain(gemData.gemDomain) < 2 then
		switchTip = tr("%s%sYou cannot switch the last gem of the domain.", switchTip, #switchTip > 0 and "\n" or "")
		destroyTip = tr("%s%sYou cannot destroy the last gem of the domain.", destroyTip, #destroyTip > 0 and "\n" or "")
	end

	if totalBalance < price then
		switchTip = tr("%s%sYou need at least %s gold to change the domain of this gem.", switchTip, #switchTip > 0 and "\n" or "", comma_value(price))
	end

	if gemData.locked == 1 then
		switchTip = tr("%s%sBefore you can change the domain of this gem, you must unlock it.", switchTip, #switchTip > 0 and "\n" or "")
		destroyTip = tr("%s%sBefore you can destroy the gem, you must unlock it.", destroyTip, #destroyTip > 0 and "\n" or "")
	end

	if GemAtelier.isGemEquipped(gemData.gemID) then
		switchTip = tr("%s%sYou must remove the gem from its vessel before you can switch its domain.", switchTip, #switchTip > 0 and "\n" or "")
		destroyTip = tr("%s%sThe gem must be removed from its vessel before it can be destroyed.", destroyTip, #destroyTip > 0 and "\n" or "")
	end

	panel.clickedContent.switch:setTooltip(switchTip)
	panel.clickedContent.destroy:setTooltip(destroyTip)

	if #switchTip > 0 then
		panel.clickedContent.switch:setOn(false)
	end

	if #destroyTip > 0 then
		panel.clickedContent.destroy:setOn(false)
	end

	if price <= totalBalance then
		panel.clickedContent.switch:setTooltip(tr("%s%sSwitch the gem's domain one step clockwise by paying the free of %s gold.", switchTip, #switchTip > 0 and "\n" or "", comma_value(price)))
	end
end

function GemAtelier.isVesselAvailable(domain, count)
	return WheelGemState.isVesselAvailable(domain, count)
end

function GemAtelier.getFilledVesselCount(domain)
	return WheelGemState.getFilledVesselCount(domain)
end

function GemAtelier.setupModAvailable(widget, gemType, vesselCount, gemData)
	if not widget then
		return true
	end

	local gemDomain = gemData.gemDomain
	local fragmentType = widget:recursiveGetChildById("fragmentType" .. gemType)
	local modItem = widget:recursiveGetChildById("gemModItem" .. gemType)
	local modLabel = widget:recursiveGetChildById("modLabel" .. gemType)
	local potentialLevel = fragmentType:recursiveGetChildById("potential")

	fragmentType:setVisible(true)
	modItem:setVisible(true)
	modLabel:setVisible(true)

	if GemAtelier.isVesselAvailable(gemDomain, vesselCount) then
		fragmentType:setShader("")
		modItem:setShader("")
		modLabel:setColor("#c0c0c0")
	else
		fragmentType:setShader("image_black_white")
		modItem:setShader("image_black_white")
		modLabel:setColor("#707070")
	end

	potentialLevel:setVisible(false)

	local gemBonusID = gemType == 0 and gemData.lesserBonus or gemType == 1 and gemData.regularBonus or gemType == 2 and gemData.supremeBonus
	local upgradeTier = WheelOfDestiny.basicModsUpgrade[gemBonusID] or 0

	if vesselCount == 3 then
		upgradeTier = WheelOfDestiny.supremeModsUpgrade[gemBonusID] or 0
	end

	if gemType == 0 then
		fragmentType:setImageClip(upgradeTier * 50 .. " 0 50 50")

		fragmentType.currentTier = upgradeTier
	elseif gemType == 1 then
		local lesserUpgradeTier = WheelOfDestiny.basicModsUpgrade[gemData.lesserBonus] or 0

		if lesserUpgradeTier < upgradeTier then
			fragmentType:setImageClip(lesserUpgradeTier * 50 .. " 0 50 50")
			potentialLevel:setVisible(true)
			potentialLevel:setImageClip(upgradeTier * 50 .. " 0 50 50")

			fragmentType.currentTier = lesserUpgradeTier
		else
			fragmentType:setImageClip(upgradeTier * 50 .. " 0 50 50")

			fragmentType.currentTier = upgradeTier
		end
	elseif gemType == 2 then
		local lesserUpgradeTier = WheelOfDestiny.basicModsUpgrade[gemData.lesserBonus] or 0
		local regularUpgradeTier = WheelOfDestiny.basicModsUpgrade[gemData.regularBonus] or 0
		local effectiveTier = math.min(lesserUpgradeTier, regularUpgradeTier)

		if effectiveTier < upgradeTier then
			fragmentType:setImageClip(effectiveTier * 50 .. " 0 50 50")
			potentialLevel:setVisible(true)
			potentialLevel:setImageClip(upgradeTier * 50 .. " 0 50 50")

			fragmentType.currentTier = effectiveTier
		else
			fragmentType:setImageClip(upgradeTier * 50 .. " 0 50 50")

			fragmentType.currentTier = upgradeTier
		end
	end

	fragmentType.modID = gemBonusID
	fragmentType.isSupreme = vesselCount == 3
end

function GemAtelier.manageVessel(remove)
	if WheelOfDestiny.isPreview then
		return true
	end

	if not lastSelectedGem then
		return true
	end

	local gemData

	for _, data in ipairs(currentGemList) do
		if data.gemID == lastSelectedGem.gemID then
			gemData = data

			break
		end
	end

	if not gemData then
		return true
	end

	WheelGemState.equipGemInVessel(gemData, remove)
	WheelOfDestiny.refreshGemState()

	if lastSelectedGem then
		GemAtelier.setupVesselPanel()
		GemAtelier.onSelectGem(lastSelectedGem, true)
	end

	GemAtelier.showGems(false, lastSelectedGem.gemIndex or 1)
end

function GemAtelier.isGemEquipped(gemID)
	return WheelGemState.isGemEquipped(gemID)
end

function GemAtelier.getGemDomainById(id)
	return WheelGemState.getGemDomainById(id)
end

function GemAtelier.getGemCountByDomain(domain)
	return WheelGemState.getGemCountByDomain(domain)
end

function GemAtelier.getGemDataById(id)
	return WheelGemState.getGemDataById(id)
end

function GemAtelier.getEquipedGem(domain)
	return WheelGemState.getEquipedGem(domain)
end

function GemAtelier.onLockActionSent(arg_29_0)
	local var_29_0 = WheelGemState.toggleGemLock(arg_29_0)

	if var_29_0 == nil then
		return
	end

	if lastSelectedGem and lastSelectedGem.locker then
		lastSelectedGem.locker:setChecked(var_29_0 == 1)
	end

	local var_29_1 = lastSelectedGem and lastSelectedGem.gemIndex or 1

	GemAtelier.showGems(false, var_29_1)
end

function GemAtelier.onRevealGem(button, gemType)
	if not button:isOn() then
		return true
	end

	WheelGemActions.send(1, gemType)
end

function GemAtelier.onSwitchDomain(button)
	if not button:isOn() or not lastSelectedGem then
		return true
	end

	local gemDataById = GemAtelier.getGemDataById(lastSelectedGem.gemID)

	if gemDataById then
		WheelGemActions.send(2, gemDataById.gemID)
	end
end

function GemAtelier.onDestroyGem(button)
	if not button or not button:isOn() or not lastSelectedGem or destroyGemWindow ~= nil then
		return true
	end

	local gemDataById = GemAtelier.getGemDataById(lastSelectedGem.gemID)

	if not gemDataById then
		return true
	end

	hideWheelWindow()

	local function yesFunction()
		WheelGemActions.send(0, gemDataById.gemID)
		showWheelWindow()
		destroyGemWindow:destroy()

		destroyGemWindow = nil
	end

	local function noFunction()
		showWheelWindow()
		destroyGemWindow:destroy()

		destroyGemWindow = nil
	end

	destroyGemWindow = displayGeneralBox(tr("Destroy Gem"), tr("Are you sure you want to destroy this gem?"), {
		{
			text = tr("Yes"),
			callback = yesFunction
		},
		{
			text = tr("No"),
			callback = noFunction
		}
	}, yesFunction, noFunction)
end

function GemAtelier.onLockGem(button)
	local gemID = button and button.gemID or lastSelectedGem and lastSelectedGem.gemID

	if not gemID then
		return true
	end

	WheelGemActions.send(3, gemID)
end

function GemAtelier.showLockedOnly(button)
	if not gemAtelierWindow then
		return true
	end

	lockedOnly = button:isChecked()
	currentPage = 1

	GemAtelier.showGems()
	GemAtelier.configurePages()

	local gemList = gemAtelierWindow:recursiveGetChildById("gemContent")

	if not gemList then
		return true
	end

	if #gemList:getChildren() > 0 then
		GemAtelier.onSelectGem(gemList:getChildren()[1])
	end
end

function GemAtelier.onSortQuality(widget, selectedIndex)
	if not gemAtelierWindow then
		return true
	end

	if type(selectedIndex) ~= "number" then
		if type(widget) == "number" then
			selectedIndex = widget
		elseif widget and widget.currentIndex then
			selectedIndex = widget.currentIndex
		else
			selectedIndex = 1
		end
	end

	sortQuality = selectedIndex
	currentPage = 1

	GemAtelier.showGems()
	GemAtelier.configurePages()

	local gemList = gemAtelierWindow:recursiveGetChildById("gemContent")

	if not gemList then
		return true
	end

	if #gemList:getChildren() > 0 then
		GemAtelier.onSelectGem(gemList:getChildren()[1])
	end
end

function GemAtelier.onSortAffinity(widget, selectedIndex)
	if not gemAtelierWindow then
		return true
	end

	if type(selectedIndex) ~= "number" then
		if type(widget) == "number" then
			selectedIndex = widget
		elseif widget and widget.currentIndex then
			selectedIndex = widget.currentIndex
		else
			selectedIndex = 1
		end
	end

	sortAffinity = selectedIndex
	currentPage = 1

	GemAtelier.showGems()
	GemAtelier.configurePages()

	local gemList = gemAtelierWindow:recursiveGetChildById("gemContent")

	if not gemList then
		return true
	end

	if #gemList:getChildren() > 0 then
		GemAtelier.onSelectGem(gemList:getChildren()[1])
	end
end

function GemAtelier.onSearchChange(self)
	local text = self:getText()

	if #text == 0 then
		currentSearchText = ""

		GemAtelier.showGems(true)

		return true
	end

	currentSearchText = text

	GemAtelier.showGems(true)
end

function GemAtelier.setupVesselPanel()
	if not gemAtelierWindow then
		return true
	end

	local selectWidget = gemAtelierWindow:recursiveGetChildById("vesselsContent")

	if not selectWidget then
		return
	end

	for i = 0, 3 do
		local background = selectWidget:recursiveGetChildById("vesselBg" .. i)
		local gemContainer = selectWidget:recursiveGetChildById("vessel" .. i)
		local gemItem = selectWidget:recursiveGetChildById("gemItem" .. i)

		if background and gemContainer and gemItem then
			local vesselSocketLevel = WheelGemState.getVesselSocketLevel(i)
			local data = GemAtelier.getEquipedGem(i)
			local var_40_6 = data ~= nil
			local var_40_7 = var_40_6 and vesselSocketLevel == data.gemType + 1

			background:setImageSource(vesselSocketLevel == 0 and "/images/game/wheel/backdrop_skillwheel_socket_inactive" or "/images/game/wheel/backdrop_skillwheel_socket_active")
			gemContainer:setImageSource("/images/game/wheel/icons-skillwheel-sockets")
			gemContainer:setImageClip(WheelGemState.getSocketImageClip(i, vesselSocketLevel, var_40_7))
			gemContainer:setVisible(vesselSocketLevel > 0)

			gemItem.gemID = -1

			gemItem:setVisible(false)
			gemItem:setImageClip("0 0 32 32")

			if var_40_6 then
				local typeOffset = data.gemType * 32
				local domainOffset = data.gemDomain * 96
				local vocationOffset = (WheelOfDestiny.vocationId - 1) * 384

				gemItem:setImageClip(vocationOffset + domainOffset + typeOffset .. " 0 32 32")

				gemItem.gemID = data.gemID

				gemItem:setVisible(true)
			end
		end
	end
end

function GemAtelier.onClickVessel(unusedArgument, domain)
	if var_0_6 then
		var_0_6:setVisible(false)
	end

	local gemItem = gemAtelierWindow:recursiveGetChildById("selectVessel" .. domain)

	if gemItem then
		gemItem:setVisible(true)

		var_0_6 = gemItem
	end

	local gemItem = gemAtelierWindow:recursiveGetChildById("gemItem" .. domain)
	local gemID = gemItem and gemItem.gemID
	local gemData

	if gemID ~= nil then
		gemData = GemAtelier.getGemDataById(gemID)
	end

	if gemData and gemData.gemDomain == domain then
		GemAtelier.redirectToGem(gemData)

		return
	end

	local fallbackGem

	for _, data in pairs(WheelOfDestiny.atelierGems or {}) do
		if data.gemDomain == domain and (not fallbackGem or data.gemID < fallbackGem.gemID) then
			fallbackGem = data
		end
	end

	if fallbackGem then
		GemAtelier.redirectToGem(fallbackGem)
	else
		GemAtelier.currentDomain = domain

		if GemAtelier.showGems then
			GemAtelier.showGems(false, domain)
		end
	end
end

function GemAtelier.onModRedirect(self)
	local modID = self.modID
	local isSupreme = self.isSupreme
	local itemsPerPage = 30
	local pageIndex
	local focusIndex = 0

	for i, k in pairs(Workshop.getFragmentList()) do
		if isSupreme and k.supreme and k.modID == modID or not isSupreme and not k.supreme and k.modID == modID then
			pageIndex = math.ceil(i / itemsPerPage)
			focusIndex = (i - 1) % itemsPerPage + 1

			break
		end
	end

	if not pageIndex then
		return true
	end

	Workshop.setCurrentPage(pageIndex)
	Workshop.showFragmentList(true, false, false, "", focusIndex)
	gemAtelierWindow:hide()
	fragmentWindow:show(true)
	gemMenuButton:setChecked(false)
	fragmentMenuButton:setChecked(true)
end

function GemAtelier.onHoverGem(self, hovered)
	local hoverWidget = self:recursiveGetChildById("hover")

	if not hoverWidget then
		return true
	end

	hoverWidget:setVisible(hovered)
	hoverWidget:setImageClip(self.currentTier and 200 + self.currentTier * 50 .. " 0 50 50" or "0 0 50 50")

	if hovered then
		g_mouse.pushCursor("pointer")
	else
		g_mouse.popCursor("pointer")
	end
end

function GemAtelier.getDamageAndHealing(self)
	local damage = 0

	for i = 0, 3 do
		local data = self.getEquipedGem(i)

		if data and self.getFilledVesselCount(i) == data.gemType + 1 then
			damage = damage + (data.gemType == 2 and 2 or 1)
		end
	end

	return damage
end
