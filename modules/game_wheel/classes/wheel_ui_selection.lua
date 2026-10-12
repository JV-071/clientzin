function WheelOfDestiny.setConvictionText(labelWidget, text, isActive)
	if not labelWidget then
		return
	end

	if type(text) == "table" or type(text) == "string" and text:find("{", 1, true) then
		labelWidget:setColoredText(text)
	else
		labelWidget:setText(text or "")

		if isActive ~= nil then
			labelWidget:setColor(isActive and "#c0c0c0" or "#707070")
		end
	end
end

local function createConvictionTierRow(parentWidget, fontName)
	local panelWidget = g_ui.createWidget("Panel", parentWidget)

	panelWidget:setHeight(13)

	local labelWidget = g_ui.createWidget("Label", panelWidget)

	labelWidget:setId("prefix")
	labelWidget:setSize(tosize("24 13"))
	labelWidget:addAnchor(AnchorTop, "parent", AnchorTop)
	labelWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
	labelWidget:setTextAlign(AlignTopLeft)
	labelWidget:setColor("#c0c0c0")

	if fontName then
		labelWidget:setFont(fontName)
	end

	local contentLabel = g_ui.createWidget("Label", panelWidget)

	contentLabel:setId("content")
	contentLabel:addAnchor(AnchorTop, "parent", AnchorTop)
	contentLabel:addAnchor(AnchorLeft, "prefix", AnchorRight)
	contentLabel:addAnchor(AnchorRight, "parent", AnchorRight)
	contentLabel:setMarginLeft(-4)
	contentLabel:setTextAlign(AlignTopLeft)
	contentLabel:setColor("#c0c0c0")
	contentLabel:setTextWrap(true)
	contentLabel:setTextAutoResize(true)

	if fontName then
		contentLabel:setFont(fontName)
	end

	return panelWidget, labelWidget, contentLabel
end

function WheelOfDestiny.configureConvictionAugmentBody(bodyPanel, fallbackLabel, bonusParts, tooltip)
	if not fallbackLabel or not bonusParts then
		return
	end

	local tooltipText = type(tooltip) == "string" and tooltip or ""

	fallbackLabel:setTooltip(tooltipText)

	if bodyPanel then
		bodyPanel:destroyChildren()
		bodyPanel:setTooltip(tooltipText)
	end

	if bonusParts.tiers and #bonusParts.tiers > 0 then
		local fallbackTierText = ""

		for index, tier in ipairs(bonusParts.tiers) do
			if index > 1 then
				fallbackTierText = fallbackTierText .. "\n"
			end

			fallbackTierText = fallbackTierText .. tier.prefix .. tier.text
		end

		if not bodyPanel then
			fallbackLabel:setVisible(true)
			WheelOfDestiny.setConvictionText(fallbackLabel, fallbackTierText)

			return
		end

		local tierRowsCreated, creationError = pcall(function()
			local font = fallbackLabel.getFont and fallbackLabel:getFont() or nil
			local totalTierHeight = 0

			bodyPanel:setVisible(true)

			for index, tier in ipairs(bonusParts.tiers) do
				local tierPanel, prefixLabel, contentLabel = createConvictionTierRow(bodyPanel, font)

				tierPanel:setId("convictionTier" .. index)

				if index > 1 then
					tierPanel:setMarginTop(2)
				end

				prefixLabel:setColoredText(tier.prefix)
				contentLabel:setColoredText(tier.text)

				local textSize = contentLabel:getTextSize()
				local height = math.max(13, textSize and textSize.height or 13)

				tierPanel:setHeight(height)

				totalTierHeight = totalTierHeight + height + (index > 1 and 2 or 0)
			end

			if totalTierHeight > 0 then
				bodyPanel:setHeight(totalTierHeight)
			end

			fallbackLabel:setVisible(false)
			fallbackLabel:setText("")
		end)

		if tierRowsCreated then
			return
		end

		g_logger.error("configureConvictionAugmentBody: " .. tostring(creationError))
		bodyPanel:destroyChildren()
		bodyPanel:setVisible(false)
		fallbackLabel:setVisible(true)
		WheelOfDestiny.setConvictionText(fallbackLabel, fallbackTierText)

		return
	end

	if bodyPanel then
		bodyPanel:setVisible(false)
	end

	if bonusParts.body and bonusParts.body ~= "" then
		fallbackLabel:setVisible(true)
	else
		fallbackLabel:setVisible(false)
		fallbackLabel:setText("")
	end
end

function WheelOfDestiny.configureDedication(sliceIndex)
	wheelOfDestinyWindow.selection.tabContent.dedication:setWidth("185")
	wheelOfDestinyWindow.selection.tabContent.dedication:setHeight("29")
	wheelOfDestinyWindow.selection.tabContent.dedication:setText(getDedicationBonus(sliceIndex))
	wheelOfDestinyWindow.selection.tabContent.information:setTooltip(getDedicationTooltip(sliceIndex))

	if (WheelOfDestiny.pointInvested[sliceIndex] or 0) > 0 then
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#c0c0c0")
	else
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#707070")
	end
end

function WheelOfDestiny.configureConviction(sliceIndex)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return
	end

	local tabContent = wheelOfDestinyWindow.selection.tabContent
	local bonusParts = getConvictionBonusParts(sliceIndex) or {
		name = "",
		body = ""
	}
	local isConvictionActive = (WheelOfDestiny.pointInvested[sliceIndex] or 0) >= bonusDefinition.maxPoints
	local convictionTooltip = getConvictionBonusTooltip(sliceIndex)

	if type(convictionTooltip) ~= "string" then
		convictionTooltip = ""
	end

	local convictionName = tabContent.convictionName or tabContent:getChildById("convictionName")
	local conviction = tabContent.conviction or tabContent:getChildById("conviction")
	local convictionBody = tabContent.convictionBody or tabContent:getChildById("convictionBody")

	if convictionName then
		convictionName:setTooltip(convictionTooltip)
		WheelOfDestiny.setConvictionText(convictionName, bonusParts.name, isConvictionActive)
	end

	WheelOfDestiny.configureConvictionAugmentBody(convictionBody, conviction, bonusParts, convictionTooltip)

	if not bonusParts.tiers and bonusParts.body and bonusParts.body ~= "" then
		WheelOfDestiny.setConvictionText(conviction, bonusParts.body, isConvictionActive)
	end
end

function WheelOfDestiny.configureDedicationPerk()
	local healthBonus = 0
	local manaBonus = 0
	local capacityBonus = 0
	local mitigationBonus = 0
	local vocationId = WheelOfDestiny.vocationId

	for key, WheelBonu in pairs(WheelBonus) do
		local sliceIndex = key + 1

		if not WheelOfDestiny.isLit(sliceIndex) then
			-- block empty
		else
			local investedPoints = WheelOfDestiny.pointInvested[sliceIndex]
			local dedicationBonusRates = WheelConsts[WheelBonu.dedication]

			if WheelBonu.dedication == "capacity" then
				capacityBonus = capacityBonus + investedPoints * dedicationBonusRates[vocationId]
			elseif WheelBonu.dedication == "mana" then
				manaBonus = manaBonus + investedPoints * dedicationBonusRates[vocationId]
			elseif WheelBonu.dedication == "health" then
				healthBonus = healthBonus + investedPoints * dedicationBonusRates[vocationId]
			elseif WheelBonu.dedication == "mitigation" then
				mitigationBonus = mitigationBonus + investedPoints * dedicationBonusRates
			elseif WheelBonu.dedication == "lifemana" then
				healthBonus = healthBonus + investedPoints * dedicationBonusRates.life[vocationId]
				manaBonus = manaBonus + investedPoints * dedicationBonusRates.mana[vocationId]
			end
		end
	end

	local tabContent = wheelOfDestinyWindow.dedicationPerks.tabContent

	tabContent.hitPoints.value:setText(healthBonus > 0 and formatWheelPlusInteger(healthBonus) or "0")
	tabContent.manaPoints.value:setText(manaBonus > 0 and formatWheelPlusInteger(manaBonus) or "0")
	tabContent.capPoints.value:setText(capacityBonus > 0 and formatWheelPlusInteger(capacityBonus) or "0")
	tabContent.mitigationPoints.value:setText(formatWheelFixedPercent(mitigationBonus))
end

function WheelOfDestiny.fitPerkName(nameLabel, candidateNames, panelWidth, valueLabel)
	if type(candidateNames) ~= "table" then
		candidateNames = {
			candidateNames
		}
	end

	if not panelWidth or panelWidth <= 0 then
		panelWidth = 190
	end

	local textSize = 0

	if valueLabel and valueLabel:isVisible() and valueLabel:getText() ~= "" then
		textSize = valueLabel:getTextSize().width
	end

	local marginLeft = panelWidth - nameLabel:getMarginLeft() - 15 - textSize - 6

	for unusedValue, entry in ipairs(candidateNames) do
		nameLabel:setText(entry)

		if marginLeft >= nameLabel:getTextSize().width then
			return
		end
	end

	local shortenedName = candidateNames[#candidateNames] or ""

	while #shortenedName > 1 do
		shortenedName = shortenedName:sub(1, -2):gsub("%s+$", "")

		nameLabel:setText(shortenedName .. "...")

		if marginLeft >= nameLabel:getTextSize().width then
			return
		end
	end
end

function WheelOfDestiny.configureConvictionPerk()
	local tabContent = wheelOfDestinyWindow.convictionPerks.tabContent

	tabContent:destroyChildren()
	wheelOfDestinyWindow.convictionPerks.tabContentScroll:setVisible(false)

	local convictionPerks = getConvictionPerks()

	if #convictionPerks > 8 then
		wheelOfDestinyWindow.convictionPerks.tabContentScroll:setVisible(true)
	end

	local width = tabContent:getWidth()

	for unusedValue, entry in ipairs(convictionPerks) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", tabContent)

		if entry.stringPoint then
			perksPanelWidget.value:setText(entry.stringPoint)
		else
			perksPanelWidget.value:setVisible(false)
		end

		if entry.tooltip and entry.tooltip ~= "" then
			perksPanelWidget.info:setTooltip(entry.tooltip)
			perksPanelWidget.info:setVisible(true)
		end

		WheelOfDestiny.fitPerkName(perksPanelWidget.perk, entry.names, width, perksPanelWidget.value)
	end
end

function WheelOfDestiny.showInformationDefault()
	local information = wheelOfDestinyWindow.info.tabContent.information

	if not information then
		return
	end

	information.defaultDescription:setVisible(true)
	information.tabContent:setVisible(false)

	WheelOfDestiny.mouseIndex = 0
end

function WheelOfDestiny.updateInformationPerk(sliceIndex)
	local bonusDefinition = WheelBonus[sliceIndex - 1]
	local investedPoints = WheelOfDestiny.pointInvested[sliceIndex]

	if not investedPoints or not bonusDefinition then
		WheelOfDestiny.showInformationDefault()

		return
	end

	local information = wheelOfDestinyWindow.info.tabContent.information

	information.defaultDescription:setVisible(false)
	information.tabContent:setVisible(true)

	local tabContent = information.tabContent
	local dedicationPB2 = tabContent.dedicationPB2

	dedicationPB2:setValue(investedPoints, 0, bonusDefinition.maxPoints)
	dedicationPB2:setText(investedPoints .. " / " .. bonusDefinition.maxPoints)
	dedicationPB2:setImageSource("/images/game/wheel/progressBar")
	dedicationPB2:setPercent(investedPoints * 100 / bonusDefinition.maxPoints)
	tabContent.dedication2:setText(getDedicationBonus(sliceIndex))

	if (WheelOfDestiny.pointInvested[sliceIndex] or 0) > 0 then
		tabContent.dedication2:setColor("#c0c0c0")
	else
		tabContent.dedication2:setColor("#707070")
	end

	local bonusParts = getConvictionBonusParts(sliceIndex, true)
	local isConvictionActive = (WheelOfDestiny.pointInvested[sliceIndex] or 0) >= bonusDefinition.maxPoints

	WheelOfDestiny.setConvictionText(tabContent.convictionName2, bonusParts.name, isConvictionActive)

	local convictionBody2 = tabContent.convictionBody2 or tabContent:getChildById("convictionBody2")
	local conviction2 = tabContent.conviction2 or tabContent:getChildById("conviction2")

	WheelOfDestiny.configureConvictionAugmentBody(convictionBody2, conviction2, bonusParts)

	if not bonusParts.tiers and bonusParts.body and bonusParts.body ~= "" then
		WheelOfDestiny.setConvictionText(conviction2, bonusParts.body, isConvictionActive)
	end
end
