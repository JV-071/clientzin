function WheelOfDestiny.configureSummary()
	if not wheelOfDestinyWindow.summary.tabContent:isVisible() then
		return
	end

	wheelOfDestinyWindow.summary.tabContent:destroyChildren()

	local var_1_0 = 0
	local var_1_1 = 0
	local var_1_2 = 0
	local var_1_3 = 0
	local vocationId = WheelOfDestiny.vocationId

	for key, WheelBonu in pairs(WheelBonus) do
		local var_1_5 = key + 1

		if not WheelOfDestiny.isLit(var_1_5) then
			-- block empty
		else
			local var_1_6 = WheelOfDestiny.pointInvested[var_1_5]
			local var_1_7 = WheelConsts[WheelBonu.dedication]

			if WheelBonu.dedication == "capacity" then
				var_1_2 = var_1_2 + var_1_6 * var_1_7[vocationId]
			elseif WheelBonu.dedication == "mana" then
				var_1_1 = var_1_1 + var_1_6 * var_1_7[vocationId]
			elseif WheelBonu.dedication == "health" then
				var_1_0 = var_1_0 + var_1_6 * var_1_7[vocationId]
			elseif WheelBonu.dedication == "mitigation" then
				var_1_3 = var_1_3 + var_1_6 * var_1_7
			elseif WheelBonu.dedication == "lifemana" then
				var_1_0 = var_1_0 + var_1_6 * var_1_7.life[vocationId]
				var_1_1 = var_1_1 + var_1_6 * var_1_7.mana[vocationId]
			end
		end
	end

	for unusedValue, equipedGemBonuse in pairs(WheelOfDestiny.equipedGemBonuses) do
		if equipedGemBonuse.bonusID == -1 then
			-- block empty
		else
			local var_1_8 = equipedGemBonuse.supreme and SupremeGemDescription[equipedGemBonuse.bonusID] or RegularGemDescription[equipedGemBonuse.bonusID]

			if not equipedGemBonuse.supreme then
				if var_1_8.type1 == "life" or var_1_8.type2 == "life" then
					var_1_0 = var_1_0 + (getValueByVocation(var_1_8.type1, var_1_8.step) + getValueByVocation(var_1_8.type2, var_1_8.step))
				end

				if var_1_8.type1 == "capacity" or var_1_8.type2 == "capacity" then
					var_1_2 = var_1_2 + (getValueByVocation(var_1_8.type1, var_1_8.step) + getValueByVocation(var_1_8.type2, var_1_8.step))
				end

				if var_1_8.type1 == "mana" or var_1_8.type2 == "mana" then
					var_1_1 = var_1_1 + (getValueByVocation(var_1_8.type1, var_1_8.step) + getValueByVocation(var_1_8.type2, var_1_8.step))
				end

				if var_1_8.type1 == "mitigation" or var_1_8.type2 == "mitigation" then
					var_1_3 = var_1_3 + (getValueByVocation(var_1_8.type1, var_1_8.step) + getValueByVocation(var_1_8.type2, var_1_8.step))
				end
			end
		end
	end

	local var_1_9 = 0

	for unusedValue, passivePoint in ipairs(WheelOfDestiny.passivePoints) do
		if passivePoint >= 1000 then
			var_1_9 = var_1_9 + 20
		elseif passivePoint >= 500 then
			var_1_9 = var_1_9 + 9
		elseif passivePoint >= 250 then
			var_1_9 = var_1_9 + 4
		end
	end

	local damageAndHealing = var_1_9 + GemAtelier:getDamageAndHealing()

	if damageAndHealing > 0 then
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		perksPanelWidget.perk:setText("Damage and Healing")
		perksPanelWidget.value:setText("+" .. damageAndHealing)
		perksPanelWidget.info:setVisible(false)
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local var_1_12 = {
		"Hit Points",
		"Mana",
		"Capacity",
		"Mitigation Mult.",
		"Life Leech",
		"Mana Leech"
	}
	local unusedValue, var_1_14 = getConvictionPerks()

	for unusedValue, entry in ipairs(var_1_12) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		perksPanelWidget.perk:setText(entry)
		perksPanelWidget.info:setVisible(false)

		if entry == "Hit Points" then
			perksPanelWidget.value:setText(var_1_0 > 0 and formatWheelPlusInteger(var_1_0) or "0")
		elseif entry == "Mana" then
			perksPanelWidget.value:setText(var_1_1 > 0 and formatWheelPlusInteger(var_1_1) or "0")
		elseif entry == "Capacity" then
			perksPanelWidget.value:setText(var_1_2 > 0 and formatWheelPlusInteger(var_1_2) or "0")
		elseif entry == "Mitigation Mult." then
			perksPanelWidget.value:setText(formatWheelFixedPercent(var_1_3))
			perksPanelWidget.info:setTooltip("Increase your mitigation multiplicatively.")
			perksPanelWidget.info:setVisible(true)
		elseif entry == "Life Leech" then
			local lifeleech = var_1_14.lifeleech

			if not lifeleech or lifeleech.points == 0 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.value:setText(lifeleech.stringPoint)
				perksPanelWidget.info:setVisible(false)
			end
		elseif entry == "Mana Leech" then
			local manaleech = var_1_14.manaleech

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

	local var_1_18 = {
		"special_1",
		"special_2",
		"skill"
	}
	local var_1_19 = false

	for unusedValue, entry in pairs(var_1_18) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

		if entry == "special_1" then
			local special_1 = var_1_14.special_1

			if not special_1 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(special_1.perk)
				perksPanelWidget.value:setVisible(false)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(special_1.tooltip)

				var_1_19 = true
			end
		elseif entry == "special_2" then
			local special_2 = var_1_14.special_2

			if not special_2 then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(special_2.perk)
				perksPanelWidget.value:setVisible(false)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(special_2.tooltip)

				var_1_19 = true
			end
		elseif entry == "skill" then
			local skill = var_1_14.skill

			if not skill then
				perksPanelWidget:destroy()
			else
				perksPanelWidget.perk:setText(skill.perk)
				perksPanelWidget.value:setText(skill.stringPoint)
				perksPanelWidget.info:setVisible(true)
				perksPanelWidget.info:setTooltip(skill.tooltip)

				var_1_19 = true
			end
		end
	end

	if var_1_19 then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local var_1_24 = {
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
	local var_1_25 = false

	for unusedValue, entry in pairs(var_1_24) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)
		local var_1_27 = var_1_14[entry]

		if not var_1_27 then
			perksPanelWidget:destroy()
		else
			perksPanelWidget.perk:setText(var_1_27.perk)
			perksPanelWidget.value:setText(var_1_27.stringPoint)
			perksPanelWidget.info:setTooltip(var_1_27.tooltip)
			perksPanelWidget.info:setVisible(true)

			var_1_25 = true
		end
	end

	local var_1_28 = getVesselBonus()

	for unusedValue, entry in pairs(var_1_28) do
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

			var_1_25 = true
		end
	end

	if var_1_25 then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local text = getRevelationDisplayName(4)
	local var_1_32 = getRevelationDisplayName(2)
	local var_1_33 = getRevelationDisplayName(3)
	local unusedValue, var_1_35 = getPassiveInfo(4)
	local var_1_36 = WheelOfDestiny.passivePoints[4]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(text)

	if var_1_36 >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif var_1_36 >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif var_1_36 >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(var_1_35)

	local unusedValue, var_1_39 = getPassiveInfo(2)
	local var_1_40 = WheelOfDestiny.passivePoints[2]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(var_1_32)
	perksPanelWidget.perk:setTooltip(var_1_32)

	if var_1_40 >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif var_1_40 >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif var_1_40 >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(var_1_39)

	local unusedValue, var_1_43 = getPassiveInfo(1)
	local var_1_44 = WheelOfDestiny.passivePoints[1]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText("Gift of Life")

	if var_1_44 >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif var_1_44 >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif var_1_44 >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(var_1_43)

	local unusedValue, var_1_47 = getPassiveInfo(3)
	local var_1_48 = WheelOfDestiny.passivePoints[3]
	local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)

	perksPanelWidget.perk:setText(var_1_33)
	perksPanelWidget.perk:setTooltip(var_1_33)

	if var_1_48 >= 1000 then
		perksPanelWidget.value:setText("Stage 3")
	elseif var_1_48 >= 500 then
		perksPanelWidget.value:setText("Stage 2")
	elseif var_1_48 >= 250 then
		perksPanelWidget.value:setText("Stage 1")
	else
		perksPanelWidget.value:setText("Locked")
	end

	perksPanelWidget.info:setTooltip(var_1_47)

	local var_1_50 = getVesselBonus()

	for unusedValue, entry in pairs(var_1_50) do
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

	local var_1_53 = false
	local var_1_54 = getVesselBonus()

	for unusedValue, entry in pairs(var_1_54) do
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

			var_1_53 = true
		end
	end

	if var_1_53 then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end

	local var_1_57 = {
		[12] = "vessel.2",
		[14] = "vessel.4",
		[13] = "vessel.3",
		[11] = "vessel.1"
	}
	local var_1_58 = false

	for unusedValue, entry in pairs(var_1_57) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", wheelOfDestinyWindow.summary.tabContent)
		local var_1_60 = var_1_14[entry]

		if not var_1_60 then
			perksPanelWidget:destroy()
		else
			perksPanelWidget.perk:setText(var_1_60.perk)
			perksPanelWidget.value:setText(var_1_60.stringPoint)
			perksPanelWidget.info:setTooltip(var_1_60.tooltip)
			perksPanelWidget.info:setVisible(true)

			var_1_58 = true
		end
	end

	if var_1_58 then
		g_ui.createWidget("HorizontalSeparator", wheelOfDestinyWindow.summary.tabContent)
	end
end
