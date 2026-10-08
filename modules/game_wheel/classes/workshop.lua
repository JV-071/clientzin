Workshop = {}
Workshop.__index = Workshop
currentWorkshopPage = 1

function Workshop.getFragmentList()
	return ModCatalog.getFragmentList()
end

function Workshop.setCurrentPage(index)
	currentWorkshopPage = index
end

function Workshop.getDataByBonus(bonusID, supreme)
	return ModCatalog.getDataByBonus(bonusID, supreme)
end

function Workshop.createFragments()
	return ModCatalog.createFragments()
end

function Workshop.getBonusDescription(modInfo, relativeTier)
	return ModBonusText.getBonusDescription(modInfo, relativeTier)
end

function Workshop.getSideBonusDescription(data, targetTier)
	return ModBonusText.getSideBonusDescription(data, targetTier)
end

function Workshop.getBonusValue(modInfo, targetTier, firstBonus)
	return ModBonusText.getBonusValue(modInfo, targetTier, firstBonus)
end

function Workshop.getUpgradeBonus(baseBonus, modID, supreme, targetTier)
	return ModBonusText.getUpgradeBonus(baseBonus, modID, supreme, targetTier)
end

function Workshop.getGemInformationByBonus(gemBonusID, supremeMod, gemID, gemSlot)
	return ModBonusText.getGemInformationByBonus(gemBonusID, supremeMod, gemID, gemSlot)
end

function Workshop.getEquippedGemBonus()
	return ModCatalog.getEquippedGemBonus()
end

function Workshop.getSortList(sortOption, equippedBasic, equippedSupreme, text)
	return ModCatalog.getSortList(sortOption, equippedBasic, equippedSupreme, text)
end

function Workshop.searchModifications(text)
	return ModCatalog.searchModifications(text)
end

function Workshop.showFragmentList(startUp, nextPage, selectCurrent, searchText, focusIndex)
	if not fragmentWindow then
		return true
	end

	local fragmentPanel = fragmentWindow:recursiveGetChildById("fragmentContent")

	if not fragmentPanel then
		return true
	end

	local lastSelectedWidget

	if selectCurrent then
		lastSelectedWidget = fragmentPanel:getFocusedChild()
	end

	local currentModList = ModCatalog.getFragmentList()
	local equippedBasic, equippedSupreme = ModCatalog.getEquippedGemBonus()
	local sortBox = fragmentWindow:recursiveGetChildById("affinitiesBox")
	local maxPages = math.ceil(#currentModList / 30)
	local modCount = #currentModList

	if startUp then
		fragmentWindow:recursiveGetChildById("searchText"):clearText(true)
		sortBox:setCurrentOption("All", false)
	end

	if sortBox:getCurrentOption().text ~= "All" then
		currentModList = ModCatalog.getSortList(sortBox:getCurrentOption(), equippedBasic, equippedSupreme, searchText)
		maxPages = math.ceil(#currentModList / 30)
		modCount = #currentModList

		if maxPages < currentWorkshopPage then
			currentWorkshopPage = maxPages
		end
	elseif searchText and not string.empty(searchText) then
		currentModList = ModCatalog.searchModifications(searchText)
		maxPages = math.ceil(#currentModList / 30)
		modCount = #currentModList

		if maxPages < currentWorkshopPage then
			currentWorkshopPage = maxPages
		end
	end

	if not startUp and not focusIndex then
		currentWorkshopPage = nextPage and math.min(maxPages, currentWorkshopPage + 1) or math.max(1, currentWorkshopPage - 1)
	end

	local beginList = (currentWorkshopPage - 1) * 30 + 1
	local endList = math.min(beginList + 29, #currentModList)

	local function updateWidget(widget, info, equipped, count)
		local basicMod = widget:recursiveGetChildById("basicMod")
		local supremeMod = widget:recursiveGetChildById("supremeMod")
		local amount = widget:recursiveGetChildById("amountLabel")
		local modTierWidget = widget:recursiveGetChildById("fragmentType")
		local socketed = widget:recursiveGetChildById("socketed")

		widget.cache = info

		socketed:setVisible(false)
		widget:setVisible(true)
		amount:setVisible(false)
		amount:setText("x 0")
		modTierWidget:setImageClip("0 0 50 50")

		if info.supreme then
			basicMod:setVisible(false)
			supremeMod:setVisible(true)
			supremeMod:setImageClip(getSupremeModIconClip(info.modID))
			supremeMod:setTooltip(ModBonusText.getBonusDescription(info))

			local supremeTier = WheelOfDestiny.supremeModsUpgrade[info.modID]

			if supremeTier then
				modTierWidget:setImageClip(supremeTier * 50 .. " 0 50 50")
			end

			if equipped[tostring(info.modID)] then
				socketed:setVisible(true)
			end
		else
			basicMod:setVisible(true)
			supremeMod:setVisible(false)
			basicMod:setImageClip(info.modID * 30 .. " 0 30 30")
			basicMod:setTooltip(ModBonusText.getBonusDescription(info))

			local basicTier = WheelOfDestiny.basicModsUpgrade[info.modID]

			if basicTier then
				modTierWidget:setImageClip(basicTier * 50 .. " 0 50 50")
			end

			if equipped[tostring(info.modID)] then
				socketed:setVisible(true)
			end
		end

		if count > 0 then
			amount:setText(tr("x %s", count))
			amount:setVisible(true)
			amount:setTooltip(tr(amount:getTooltip(), count))
		end
	end

	for i, widget in ipairs(fragmentPanel:getChildren()) do
		widget:setVisible(false)

		local k = beginList + (i - 1)

		if k <= endList then
			local info = currentModList[k]

			if info then
				local isSupreme = info.supreme
				local count = isSupreme and (WheelOfDestiny.supremeModCount[tostring(info.modID)] or 0) or WheelOfDestiny.basicModCount[tostring(info.modID)] or 0

				updateWidget(widget, info, isSupreme and equippedSupreme or equippedBasic, count)
			end
		end
	end

	local infoLabel = fragmentWindow:recursiveGetChildById("pagesLabel")

	if infoLabel then
		infoLabel:setText(tr("Page %s / %s (%s Mods)", currentWorkshopPage, math.max(1, maxPages), modCount))
	end

	local previousPage = fragmentWindow:recursiveGetChildById("rightArrow")
	local nextPage = fragmentWindow:recursiveGetChildById("leftArrow")
	local modGradePanel = fragmentWindow:recursiveGetChildById("modGrade")
	local noModGradePanel = fragmentWindow:recursiveGetChildById("noModGrade")

	modGradePanel:setVisible(#currentModList > 0)
	noModGradePanel:setVisible(#currentModList == 0)

	if previousPage and nextPage then
		if currentWorkshopPage == maxPages and maxPages == 1 or #currentModList == 0 then
			previousPage:setEnabled(false)
			nextPage:setEnabled(false)
		elseif currentWorkshopPage <= 1 then
			previousPage:setEnabled(false)
			nextPage:setEnabled(true)
		elseif currentWorkshopPage > 1 and maxPages > currentWorkshopPage then
			previousPage:setEnabled(true)
			nextPage:setEnabled(true)
		elseif currentWorkshopPage == maxPages then
			previousPage:setEnabled(true)
			nextPage:setEnabled(false)
		end
	end

	fragmentPanel.onChildFocusChange = Workshop.onSelectChild

	if focusIndex then
		fragmentPanel:focusChild(fragmentPanel:getChildByIndex(focusIndex))
	elseif selectCurrent then
		Workshop.onSelectChild(nil, lastSelectedWidget)
		fragmentPanel:focusChild(lastSelectedWidget)
	else
		fragmentPanel:focusChild(nil)
		fragmentPanel:focusChild(fragmentPanel:getFirstChild())
	end
end

function Workshop.onSelectChild(list, selected)
	if not selected then
		return true
	end

	local isSupreme = selected.cache.supreme
	local supremeTier = WheelOfDestiny.supremeModsUpgrade[selected.cache.modID] or 0
	local basicTier = WheelOfDestiny.basicModsUpgrade[selected.cache.modID] or 0
	local maxTier = isSupreme and supremeTier or basicTier
	local modID = selected.cache.modID
	local imageClipSize = isSupreme and 35 or 30
	local activeColor = "#c0c0c0"
	local inactiveColor = "#707070"
	local modDesc = fragmentWindow:recursiveGetChildById("modDesc")

	for i = 0, 3 do
		local basicWidget = fragmentWindow:recursiveGetChildById("basicMod" .. i)
		local supremeWidget = fragmentWindow:recursiveGetChildById("supremeMod" .. i)
		local gradeWidget = fragmentWindow:recursiveGetChildById("grade" .. i)
		local bonusWidget = fragmentWindow:recursiveGetChildById("bonus" .. i)
		local backDrop = fragmentWindow:recursiveGetChildById("fragmentType" .. i)
		local backMidle = fragmentWindow:recursiveGetChildById("modBgAnim" .. i)
		local backLine = fragmentWindow:recursiveGetChildById("lineAnim" .. i)
		local isActive = i <= maxTier

		if isSupreme then
			basicWidget:setVisible(false)
			supremeWidget:setVisible(true)
			supremeWidget:setImageClip(getSupremeModIconClip(modID))
			supremeWidget:setShader(isActive and "" or "image_black_white")
		else
			supremeWidget:setVisible(false)
			basicWidget:setVisible(true)
			basicWidget:setImageClip(modID * imageClipSize .. " 0 " .. imageClipSize .. " " .. imageClipSize)
			basicWidget:setShader(isActive and "" or "image_black_white")
		end

		backDrop:setShader(isActive and "" or "image_black_white")
		gradeWidget:setColor(isActive and activeColor or inactiveColor)
		bonusWidget:setColor(isActive and activeColor or inactiveColor)
		backMidle:setVisible(isActive)

		if backLine then
			backLine:setVisible(isActive)
		end

		bonusWidget:setText(ModBonusText.getSideBonusDescription(selected.cache, i))
	end

	local fragmentWidget = fragmentWindow:recursiveGetChildById("fragmentCost")
	local fragmentIcon = fragmentWindow:recursiveGetChildById("fragmentIcon")
	local goldWidget = fragmentWindow:recursiveGetChildById("gold")
	local enhanceButton = fragmentWindow:recursiveGetChildById("enhanceButton")

	if maxTier >= 3 then
		fragmentIcon:getParent():setVisible(false)
		goldWidget:getParent():setVisible(false)
		enhanceButton:setVisible(false)

		return true
	end

	local player = g_game.getLocalPlayer()
	local goldCost = isSupreme and greaterResources[supremeTier].price or lesserResources[basicTier].price
	local fragmentCost = isSupreme and greaterResources[supremeTier].fragment or lesserResources[basicTier].fragment
	local resourceCheck = isSupreme and player:getResourceBalance(ResourceTypes.GREATER_FRAGMENTS) or player:getResourceBalance(ResourceTypes.LESSER_FRAGMENTS)
	local iconOffset = isSupreme and "0 12 12 12" or "0 0 12 12"
	local iconTooltip = isSupreme and "Greater Fragments" or "Lesser Fragments"

	goldWidget:setText(convertLongGold(goldCost, true))
	goldWidget:setTooltip(comma_value(goldCost))
	fragmentWidget:setText(fragmentCost)
	fragmentIcon:setImageClip(iconOffset)
	fragmentIcon:setTooltip(iconTooltip)
	fragmentIcon:getParent():setVisible(true)
	goldWidget:getParent():setVisible(true)
	goldWidget:setOn(true)
	enhanceButton:setVisible(true)
	fragmentWidget:setOn(true)

	local blockedTooltip = ""
	local totalBalance = player:getResourceBalance(ResourceTypes.BANK_BALANCE) + player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)

	if WheelOfDestiny.isPreview then
		blockedTooltip = tr("This action is not available in preview mode.")

		goldWidget:setOn(false)
		fragmentWidget:setOn(false)
	elseif totalBalance < goldCost then
		blockedTooltip = tr("You need at least %s gold to enhance mods of this quality.", comma_value(goldCost))

		goldWidget:setOn(false)
	end

	if resourceCheck < fragmentCost then
		if not string.empty(blockedTooltip) then
			blockedTooltip = tr("%s\nYou need at least %s greater fragments to enhance mods of this quality.", blockedTooltip, fragmentCost)
		else
			blockedTooltip = tr("You need at least %s greater fragments to enhance mods of this quality.", fragmentCost)
		end

		fragmentWidget:setOn(false)
	end

	enhanceButton:setTooltip(blockedTooltip)
	enhanceButton:setOn(string.empty(blockedTooltip))
	modDesc:setText(selected.cache.desc or "")
end

function Workshop.onUpgradeModification(button)
	if WheelOfDestiny.isPreview then
		return true
	end

	local selected = fragmentWindow:recursiveGetChildById("fragmentContent")

	if not selected or not button:isOn() then
		return true
	end

	local selectedWidget = selected:getFocusedChild()

	if not selectedWidget then
		return true
	end

	local fragmentType

	pos, fragmentType = selectedWidget.cache.modID or -1, (selectedWidget.cache.supreme or false) and 0 or 1

	WheelGemActions.send(4, fragmentType, pos)
end

function Workshop.onSearchChange(self)
	local text = self:getText()

	if string.empty(text) then
		Workshop.showFragmentList(true, false, false)

		return true
	end

	if #text > 50 then
		return true
	end

	Workshop.showFragmentList(false, false, false, text)
end
