function WheelOfDestiny.configureSummary()
	if not wheelOfDestinyWindow.summary.tabContent:isVisible() then
		return
	end

	wheelOfDestinyWindow.summary.tabContent:destroyChildren()

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

	for unusedValue, equipedGemBonuse in pairs(WheelOfDestiny.equipedGemBonuses) do
		if equipedGemBonuse.bonusID == -1 then
			-- block empty
		else
			local gemBonusDescription = equipedGemBonuse.supreme and SupremeGemDescription[equipedGemBonuse.bonusID] or RegularGemDescription[equipedGemBonuse.bonusID]

			if not equipedGemBonuse.supreme then
				if gemBonusDescription.type1 == "life" or gemBonusDescription.type2 == "life" then
					healthBonus = healthBonus + (getValueByVocation(gemBonusDescription.type1, gemBonusDescription.step) + getValueByVocation(gemBonusDescription.type2, gemBonusDescription.step))
				end

				if gemBonusDescription.type1 == "capacity" or gemBonusDescription.type2 == "capacity" then
					capacityBonus = capacityBonus + (getValueByVocation(gemBonusDescription.type1, gemBonusDescription.step) + getValueByVocation(gemBonusDescription.type2, gemBonusDescription.step))
				end

				if gemBonusDescription.type1 == "mana" or gemBonusDescription.type2 == "mana" then
					manaBonus = manaBonus + (getValueByVocation(gemBonusDescription.type1, gemBonusDescription.step) + getValueByVocation(gemBonusDescription.type2, gemBonusDescription.step))
				end

				if gemBonusDescription.type1 == "mitigation" or gemBonusDescription.type2 == "mitigation" then
					mitigationBonus = mitigationBonus + (getValueByVocation(gemBonusDescription.type1, gemBonusDescription.step) + getValueByVocation(gemBonusDescription.type2, gemBonusDescription.step))
				end
			end
		end
	end

	local passiveDamageAndHealing = 0

	for unusedValue, passivePoint in ipairs(WheelOfDestiny.passivePoints) do
		if passivePoint >= 1000 then
			passiveDamageAndHealing = passiveDamageAndHealing + 20
		elseif passivePoint >= 500 then
			passiveDamageAndHealing = passiveDamageAndHealing + 9
		elseif passivePoint >= 250 then
			passiveDamageAndHealing = passiveDamageAndHealing + 4
		end
	end

	local damageAndHealing = passiveDamageAndHealing + GemAtelier:getDamageAndHealing()

	if damageAndHealing > 0 then
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		perksPanelWidget.perk:setText("Damage and Healing")
		perksPanelWidget.value:setText("+" .. damageAndHealing)
		perksPanelWidget.info:setVisible(false)
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local basePerkNames = {
		"Hit Points",
		"Mana",
		"Capacity",
		"Mitigation Mult.",
		"Life Leech",
		"Mana Leech"
	}
	local unusedValue, convictionPerksByName = getConvictionPerks()

	for unusedValue, entry in ipairs(basePerkNames) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		perksPanelWidget.perk:setText(entry)
		perksPanelWidget.info:setVisible(false)

		if entry == "Hit Points" then
			perksPanelWidget.value:setText(healthBonus > 0 and formatWheelPlusInteger(healthBonus) or "0")
		elseif entry == "Mana" then
			perksPanelWidget.value:setText(manaBonus > 0 and formatWheelPlusInteger(manaBonus) or "0")
		elseif entry == "Capacity" then
			perksPanelWidget.value:setText(capacityBonus > 0 and formatWheelPlusInteger(capacityBonus) or "0")
		elseif entry == "Mitigation Mult." then
			perksPanelWidget.value:setText(formatWheelFixedPercent(mitigationBonus))
			perksPanelWidget.info:setTooltip("Increase your mitigation multiplicatively.")
			perksPanelWidget.info:setVisible(true)
		elseif entry == "Life Leech" then
			local lifeleech = convictionPerksByName.lifeleech

			if not lifeleech or lifeleech.points == 0 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.value:setText(lifeleech.stringPoint)
				perksPanelWidget.info:setVisible(false)
			end
		elseif entry == "Mana Leech" then
			local manaleech = convictionPerksByName.manaleech

			if not manaleech or manaleech.points == 0 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.value:setText(manaleech.stringPoint)
				perksPanelWidget.info:setVisible(false)
			end
		else
			perksPanelWidget:destroy()
		end
	end

	g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)

	local specialPerkKeys = {
		"special_1",
		"special_2",
		"skill"
	}
	local hasSpecialPerks = false

	for unusedValue, entry in pairs(specialPerkKeys) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		if entry == "special_1" then
			local special_1 = convictionPerksByName.special_1

			if not special_1 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(special_1.perk)
				perksPanelWidget.value:setVisible(false)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(special_1.tooltip)

				hasSpecialPerks = true
			end
		elseif entry == "special_2" then
			local special_2 = convictionPerksByName.special_2

			if not special_2 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(special_2.perk)
				perksPanelWidget.value:setVisible(false)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(special_2.tooltip)

				hasSpecialPerks = true
			end
		elseif entry == "skill" then
			local skill = convictionPerksByName.skill

			if not skill then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(skill.perk)
				perksPanelWidget.value:setText(skill.stringPoint)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(skill.tooltip)

				hasSpecialPerks = true
			end
		end
	end

	if hasSpecialPerks then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local spellPerkKeys = {
		nil,
		nil,
		nil,
		nil,
		nil,
		"spell_1",
		"spell_2",
		"spell_3",
		[9] = "spell_4",
		[10] = "spell_5"
	}
	local hasSpellOrAugmentPerks = false

	for unusedValue, entry in pairs(spellPerkKeys) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)
		local spellPerk = convictionPerksByName[entry]

		if not spellPerk then
			perksPanelWidget:destroy()
		else
			perksPanelWidget.perk:setText(spellPerk.perk)
			perksPanelWidget.value:setText(spellPerk.stringPoint)
			perksPanelWidget.info:setTooltip(spellPerk.tooltip)
			perksPanelWidget.info:setVisible(true)

			hasSpellOrAugmentPerks = true
		end
	end

	local augmentVesselBonuses = getVesselBonus()

	for unusedValue, entry in pairs(augmentVesselBonuses) do
		if entry.bonusType ~= "augment" then
			-- block empty
		else
			local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

			perksPanelWidget.perk:setText(entry.text)

			if entry.value == -1 then
				perksPanelWidget.value:setVisible(false)
			end

			if entry.tooltip then
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(entry.tooltip)
			end

			local textValue = tostring(entry.value)

			if not textValue:match("[+-I]") then
				if tonumber(entry.value) < 15 then
					perksPanelWidget.value:setText("+" .. textValue .. "%")
				else
					perksPanelWidget.value:setText("+" .. textValue)
				end
			else
				perksPanelWidget.value:setText(entry.value)
			end

			hasSpellOrAugmentPerks = true
		end
	end

	if hasSpellOrAugmentPerks then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local text = getRevelationDisplayName(4)
	local secondRevelationName = getRevelationDisplayName(2)
	local thirdRevelationName = getRevelationDisplayName(3)
	local unusedValue, fourthPassiveTooltip = getPassiveInfo(4)
	local fourthPassivePoints = WheelOfDestiny.passivePoints[4]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(text)

	if fourthPassivePoints >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif fourthPassivePoints >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif fourthPassivePoints >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(fourthPassiveTooltip)

	local unusedValue, secondPassiveTooltip = getPassiveInfo(2)
	local secondPassivePoints = WheelOfDestiny.passivePoints[2]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(secondRevelationName)
	perksPanelWidget.perk:setTooltip(secondRevelationName)

	if secondPassivePoints >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif secondPassivePoints >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif secondPassivePoints >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(secondPassiveTooltip)

	local unusedValue, giftOfLifeTooltip = getPassiveInfo(1)
	local giftOfLifePoints = WheelOfDestiny.passivePoints[1]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText("Gift of Life")

	if giftOfLifePoints >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif giftOfLifePoints >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif giftOfLifePoints >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(giftOfLifeTooltip)

	local unusedValue, thirdPassiveTooltip = getPassiveInfo(3)
	local thirdPassivePoints = WheelOfDestiny.passivePoints[3]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(thirdRevelationName)
	perksPanelWidget.perk:setTooltip(thirdRevelationName)

	if thirdPassivePoints >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif thirdPassivePoints >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif thirdPassivePoints >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(thirdPassiveTooltip)

	local revelationVesselBonuses = getVesselBonus()

	for unusedValue, entry in pairs(revelationVesselBonuses) do
		if entry.bonusType ~= "revelation" then
			-- block empty
		else
			local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

			perksPanelWidget.perk:setText(entry.text)

			if entry.value == -1 then
				perksPanelWidget.value:setVisible(false)
			end

			if entry.tooltip then
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(entry.tooltip)
			end

			local textValue = tostring(entry.value)

			if not textValue:match("[+-I]") then
				if tonumber(entry.value) < 15 then
					perksPanelWidget.value:setText("+" .. textValue .. "%")
				else
					perksPanelWidget.value:setText("+" .. textValue)
				end
			else
				perksPanelWidget.value:setText(entry.value)
			end
		end
	end

	g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)

	local hasDefensePerks = false
	local defenseVesselBonuses = getVesselBonus()

	for unusedValue, entry in pairs(defenseVesselBonuses) do
		if entry.bonusType ~= "defense" then
			-- block empty
		else
			local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

			perksPanelWidget.perk:setText(entry.text)

			if entry.indent then
				perksPanelWidget.perk:setMarginLeft(10)
			end

			if entry.value == -1 then
				perksPanelWidget.value:setVisible(false)
			end

			if entry.tooltip then
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(entry.tooltip)
			end

			local textValue = tostring(entry.value)

			if not textValue:match("[+-I]") then
				if tonumber(entry.value) < 15 then
					perksPanelWidget.value:setText("+" .. textValue .. "%")
				else
					perksPanelWidget.value:setText("+" .. textValue)
				end
			else
				perksPanelWidget.value:setText(entry.value)
			end

			hasDefensePerks = true
		end
	end

	if hasDefensePerks then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local vesselPerkKeys = {
		[12] = "vessel.2",
		[14] = "vessel.4",
		[13] = "vessel.3",
		[11] = "vessel.1"
	}
	local hasVesselPerks = false

	for unusedValue, entry in pairs(vesselPerkKeys) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)
		local vesselPerk = convictionPerksByName[entry]

		if not vesselPerk then
			perksPanelWidget:destroy()
		else
			perksPanelWidget.perk:setText(vesselPerk.perk)
			perksPanelWidget.value:setText(vesselPerk.stringPoint)
			perksPanelWidget.info:setTooltip(vesselPerk.tooltip)
			perksPanelWidget.info:setVisible(true)

			hasVesselPerks = true
		end
	end

	if hasVesselPerks then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end
end
