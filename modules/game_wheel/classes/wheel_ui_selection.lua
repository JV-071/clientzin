function WheelOfDestiny.setConvictionText(arg_1_0, arg_1_1, arg_1_2)
	if not arg_1_0 then
		return
	end

	if type(arg_1_1) == "table" or type(arg_1_1) == "string" and arg_1_1:find("{", 1, true) then
		arg_1_0:setColoredText(arg_1_1)
	else
		arg_1_0:setText(arg_1_1 or "")

		if arg_1_2 ~= nil then
			arg_1_0:setColor(arg_1_2 and "#c0c0c0" or "#707070")
		end
	end
end

local function var_0_0(parentWidget, arg_2_1)
	local panelWidget = g_ui.createWidget("Panel", parentWidget)

	panelWidget:setHeight(13)

	local labelWidget = g_ui.createWidget("Label", panelWidget)

	labelWidget:setId("prefix")
	labelWidget:setSize(tosize("24 13"))
	labelWidget:addAnchor(AnchorTop, "parent", AnchorTop)
	labelWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
	labelWidget:setTextAlign(AlignTopLeft)
	labelWidget:setColor("#c0c0c0")

	if arg_2_1 then
		labelWidget:setFont(arg_2_1)
	end

	local var_2_2 = g_ui.createWidget("Label", panelWidget)

	var_2_2:setId("content")
	var_2_2:addAnchor(AnchorTop, "parent", AnchorTop)
	var_2_2:addAnchor(AnchorLeft, "prefix", AnchorRight)
	var_2_2:addAnchor(AnchorRight, "parent", AnchorRight)
	var_2_2:setMarginLeft(-4)
	var_2_2:setTextAlign(AlignTopLeft)
	var_2_2:setColor("#c0c0c0")
	var_2_2:setTextWrap(true)
	var_2_2:setTextAutoResize(true)

	if arg_2_1 then
		var_2_2:setFont(arg_2_1)
	end

	return panelWidget, labelWidget, var_2_2
end

function WheelOfDestiny.configureConvictionAugmentBody(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	if not arg_3_1 or not arg_3_2 then
		return
	end

	local var_3_0 = type(arg_3_3) == "string" and arg_3_3 or ""

	arg_3_1:setTooltip(var_3_0)

	if arg_3_0 then
		arg_3_0:destroyChildren()
		arg_3_0:setTooltip(var_3_0)
	end

	if arg_3_2.tiers and #arg_3_2.tiers > 0 then
		local var_3_1 = ""

		for index, tier in ipairs(arg_3_2.tiers) do
			if index > 1 then
				var_3_1 = var_3_1 .. "\n"
			end

			var_3_1 = var_3_1 .. tier.prefix .. tier.text
		end

		if not arg_3_0 then
			arg_3_1:setVisible(true)
			WheelOfDestiny.setConvictionText(arg_3_1, var_3_1)

			return
		end

		local var_3_2, var_3_3 = pcall(function()
			local font = arg_3_1.getFont and arg_3_1:getFont() or nil
			local var_4_1 = 0

			arg_3_0:setVisible(true)

			for index, tier in ipairs(arg_3_2.tiers) do
				local var_4_2, var_4_3, var_4_4 = var_0_0(arg_3_0, font)

				var_4_2:setId("convictionTier" .. index)

				if index > 1 then
					var_4_2:setMarginTop(2)
				end

				var_4_3:setColoredText(tier.prefix)
				var_4_4:setColoredText(tier.text)

				local textSize = var_4_4:getTextSize()
				local var_4_6 = math.max(13, textSize and textSize.height or 13)

				var_4_2:setHeight(var_4_6)

				var_4_1 = var_4_1 + var_4_6 + (index > 1 and 2 or 0)
			end

			if var_4_1 > 0 then
				arg_3_0:setHeight(var_4_1)
			end

			arg_3_1:setVisible(false)
			arg_3_1:setText("")
		end)

		if var_3_2 then
			return
		end

		g_logger.error("configureConvictionAugmentBody: " .. tostring(var_3_3))
		arg_3_0:destroyChildren()
		arg_3_0:setVisible(false)
		arg_3_1:setVisible(true)
		WheelOfDestiny.setConvictionText(arg_3_1, var_3_1)

		return
	end

	if arg_3_0 then
		arg_3_0:setVisible(false)
	end

	if arg_3_2.body and arg_3_2.body ~= "" then
		arg_3_1:setVisible(true)
	else
		arg_3_1:setVisible(false)
		arg_3_1:setText("")
	end
end

function WheelOfDestiny.configureDedication(arg_5_0)
	wheelOfDestinyWindow.selection.tabContent.dedication:setWidth("185")
	wheelOfDestinyWindow.selection.tabContent.dedication:setHeight("29")
	wheelOfDestinyWindow.selection.tabContent.dedication:setText(getDedicationBonus(arg_5_0))
	wheelOfDestinyWindow.selection.tabContent.information:setTooltip(getDedicationTooltip(arg_5_0))

	if (WheelOfDestiny.pointInvested[arg_5_0] or 0) > 0 then
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#c0c0c0")
	else
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#707070")
	end
end

function WheelOfDestiny.configureConviction(arg_6_0)
	local var_6_0 = WheelBonus[arg_6_0 - 1]

	if not var_6_0 then
		return
	end

	local tabContent = wheelOfDestinyWindow.selection.tabContent
	local var_6_2 = getConvictionBonusParts(arg_6_0) or {
		name = "",
		body = ""
	}
	local var_6_3 = (WheelOfDestiny.pointInvested[arg_6_0] or 0) >= var_6_0.maxPoints
	local var_6_4 = getConvictionBonusTooltip(arg_6_0)

	if type(var_6_4) ~= "string" then
		var_6_4 = ""
	end

	local convictionName = tabContent.convictionName or tabContent:getChildById("convictionName")
	local conviction = tabContent.conviction or tabContent:getChildById("conviction")
	local convictionBody = tabContent.convictionBody or tabContent:getChildById("convictionBody")

	if convictionName then
		convictionName:setTooltip(var_6_4)
		WheelOfDestiny.setConvictionText(convictionName, var_6_2.name, var_6_3)
	end

	WheelOfDestiny.configureConvictionAugmentBody(convictionBody, conviction, var_6_2, var_6_4)

	if not var_6_2.tiers and var_6_2.body and var_6_2.body ~= "" then
		WheelOfDestiny.setConvictionText(conviction, var_6_2.body, var_6_3)
	end
end

function WheelOfDestiny.configureDedicationPerk()
	local var_7_0 = 0
	local var_7_1 = 0
	local var_7_2 = 0
	local var_7_3 = 0
	local vocationId = WheelOfDestiny.vocationId

	for key, WheelBonu in pairs(WheelBonus) do
		local var_7_5 = key + 1

		if not WheelOfDestiny.isLit(var_7_5) then
			-- block empty
		else
			local var_7_6 = WheelOfDestiny.pointInvested[var_7_5]
			local var_7_7 = WheelConsts[WheelBonu.dedication]

			if WheelBonu.dedication == "capacity" then
				var_7_2 = var_7_2 + var_7_6 * var_7_7[vocationId]
			elseif WheelBonu.dedication == "mana" then
				var_7_1 = var_7_1 + var_7_6 * var_7_7[vocationId]
			elseif WheelBonu.dedication == "health" then
				var_7_0 = var_7_0 + var_7_6 * var_7_7[vocationId]
			elseif WheelBonu.dedication == "mitigation" then
				var_7_3 = var_7_3 + var_7_6 * var_7_7
			elseif WheelBonu.dedication == "lifemana" then
				var_7_0 = var_7_0 + var_7_6 * var_7_7.life[vocationId]
				var_7_1 = var_7_1 + var_7_6 * var_7_7.mana[vocationId]
			end
		end
	end

	local tabContent = wheelOfDestinyWindow.dedicationPerks.tabContent

	tabContent.hitPoints.value:setText(var_7_0 > 0 and formatWheelPlusInteger(var_7_0) or "0")
	tabContent.manaPoints.value:setText(var_7_1 > 0 and formatWheelPlusInteger(var_7_1) or "0")
	tabContent.capPoints.value:setText(var_7_2 > 0 and formatWheelPlusInteger(var_7_2) or "0")
	tabContent.mitigationPoints.value:setText(formatWheelFixedPercent(var_7_3))
end

function WheelOfDestiny.fitPerkName(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	if type(arg_8_1) ~= "table" then
		arg_8_1 = {
			arg_8_1
		}
	end

	if not arg_8_2 or arg_8_2 <= 0 then
		arg_8_2 = 190
	end

	local textSize = 0

	if arg_8_3 and arg_8_3:isVisible() and arg_8_3:getText() ~= "" then
		textSize = arg_8_3:getTextSize().width
	end

	local marginLeft = arg_8_2 - arg_8_0:getMarginLeft() - 15 - textSize - 6

	for unusedValue, entry in ipairs(arg_8_1) do
		arg_8_0:setText(entry)

		if marginLeft >= arg_8_0:getTextSize().width then
			return
		end
	end

	local var_8_2 = arg_8_1[#arg_8_1] or ""

	while #var_8_2 > 1 do
		var_8_2 = var_8_2:sub(1, -2):gsub("%s+$", "")

		arg_8_0:setText(var_8_2 .. "...")

		if marginLeft >= arg_8_0:getTextSize().width then
			return
		end
	end
end

function WheelOfDestiny.configureConvictionPerk()
	local tabContent = wheelOfDestinyWindow.convictionPerks.tabContent

	tabContent:destroyChildren()
	wheelOfDestinyWindow.convictionPerks.tabContentScroll:setVisible(false)

	local var_9_1 = getConvictionPerks()

	if #var_9_1 > 8 then
		wheelOfDestinyWindow.convictionPerks.tabContentScroll:setVisible(true)
	end

	local width = tabContent:getWidth()

	for unusedValue, entry in ipairs(var_9_1) do
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

function WheelOfDestiny.updateInformationPerk(arg_11_0)
	local var_11_0 = WheelBonus[arg_11_0 - 1]
	local var_11_1 = WheelOfDestiny.pointInvested[arg_11_0]

	if not var_11_1 or not var_11_0 then
		WheelOfDestiny.showInformationDefault()

		return
	end

	local information = wheelOfDestinyWindow.info.tabContent.information

	information.defaultDescription:setVisible(false)
	information.tabContent:setVisible(true)

	local tabContent = information.tabContent
	local dedicationPB2 = tabContent.dedicationPB2

	dedicationPB2:setValue(var_11_1, 0, var_11_0.maxPoints)
	dedicationPB2:setText(var_11_1 .. " / " .. var_11_0.maxPoints)
	dedicationPB2:setImageSource("/images/game/wheel/progressBar")
	dedicationPB2:setPercent(var_11_1 * 100 / var_11_0.maxPoints)
	tabContent.dedication2:setText(getDedicationBonus(arg_11_0))

	if (WheelOfDestiny.pointInvested[arg_11_0] or 0) > 0 then
		tabContent.dedication2:setColor("#c0c0c0")
	else
		tabContent.dedication2:setColor("#707070")
	end

	local var_11_5 = getConvictionBonusParts(arg_11_0, true)
	local var_11_6 = (WheelOfDestiny.pointInvested[arg_11_0] or 0) >= var_11_0.maxPoints

	WheelOfDestiny.setConvictionText(tabContent.convictionName2, var_11_5.name, var_11_6)

	local convictionBody2 = tabContent.convictionBody2 or tabContent:getChildById("convictionBody2")
	local conviction2 = tabContent.conviction2 or tabContent:getChildById("conviction2")

	WheelOfDestiny.configureConvictionAugmentBody(convictionBody2, conviction2, var_11_5)

	if not var_11_5.tiers and var_11_5.body and var_11_5.body ~= "" then
		WheelOfDestiny.setConvictionText(conviction2, var_11_5.body, var_11_6)
	end
end
