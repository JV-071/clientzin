local var_0_0 = "/images/game/wheel/backdrop_skillwheel_socket_inactive"
local var_0_1 = "/images/game/wheel/backdrop_skillwheel_socket_active"
local imageSourcePath = "/images/game/wheel/icons-skillwheel-sockets"

function WheelOfDestiny.configureEquippedGems()
	if not wheelPanel then
		return
	end

	for iter_1_0 = 0, 3 do
		local equipedGem = GemAtelier.getEquipedGem(iter_1_0)
		local socketBackground = wheelPanel:recursiveGetChildById("socketBackground" .. iter_1_0)
		local gemSocketBg = wheelPanel:recursiveGetChildById("gemSocketBg" .. iter_1_0)
		local gemSocket = wheelPanel:recursiveGetChildById("gemSocket" .. iter_1_0)

		if gemSocket then
			local gemIcon = gemSocket:recursiveGetChildById("gemIcon" .. iter_1_0)
			local vesselSocketLevel = WheelGemState.getVesselSocketLevel(iter_1_0)
			local visible = equipedGem ~= nil
			local var_1_7 = visible and vesselSocketLevel == equipedGem.gemType + 1

			if socketBackground then
				local var_1_8 = vesselSocketLevel == 0 and "backdrop_skillwheel_largebonus_socketdisabled_" .. iter_1_0 or "backdrop_skillwheel_largebonus_socketenabled_" .. iter_1_0

				socketBackground:setImageSource("/images/game/wheel/" .. var_1_8)
			end

			if gemSocketBg then
				gemSocketBg:setImageSource(vesselSocketLevel == 0 and var_0_0 or var_0_1)
				gemSocketBg:setVisible(true)
			end

			gemSocket:setImageSource(imageSourcePath)
			gemSocket:setImageClip(WheelGemState.getSocketImageClip(iter_1_0, vesselSocketLevel, var_1_7))
			gemSocket:setVisible(vesselSocketLevel > 0 or visible)

			if gemIcon then
				gemIcon:setVisible(visible)

				if visible then
					local var_1_9 = equipedGem.gemType * 32
					local var_1_10 = equipedGem.gemDomain * 96
					local var_1_11 = (WheelOfDestiny.vocationId - 1) * 384

					gemIcon:setImageClip(var_1_11 + var_1_10 + var_1_9 .. " 0 32 32")
				end
			end
		end
	end
end

function WheelOfDestiny.refreshGemState()
	WheelOfDestiny.refreshAllVesselDomains()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()
end

function WheelOfDestiny.onGemVesselClick(arg_3_0)
	if WheelOfDestiny.lastSelectedGemVessel then
		WheelOfDestiny.lastSelectedGemVessel:setVisible(false)
	end

	WheelOfDestiny.resetPassiveFocus()
	wheelPanel.borderSelectedWheel:setVisible(false)

	local selectVessel = wheelPanel:recursiveGetChildById("selectVessel" .. arg_3_0)

	WheelOfDestiny.lastSelectedGemVessel = selectVessel

	WheelOfDestiny.lastSelectedGemVessel:setVisible(true)
	wheelOfDestinyWindow.selection.tabContent:setVisible(false)
	wheelOfDestinyWindow.selection.gemContent:setVisible(true)

	local filledVesselCount = GemAtelier.getFilledVesselCount(arg_3_0)
	local equipedGem = GemAtelier.getEquipedGem(arg_3_0)

	if not equipedGem then
		wheelOfDestinyWindow.selection.gemContent.gemName:setText("Vessel contains no gem")
	end

	local var_3_3 = {
		"I",
		"II",
		"III"
	}
	local var_3_4 = "Sealed"

	if filledVesselCount == 1 then
		var_3_4 = "Dormant"
	elseif filledVesselCount == 2 then
		var_3_4 = "Awakened"
	elseif filledVesselCount == 3 then
		var_3_4 = "Radiant"
	end

	wheelOfDestinyWindow.selection.gemContent.sealedInfo:setText(tr("%s Vessel (VR %s)", var_3_4, filledVesselCount == 0 and "0" or var_3_3[filledVesselCount]))
	wheelOfDestinyWindow.selection.gemContent.VRBonus:setText("")
	wheelOfDestinyWindow.selection.gemContent.modification0:setText("")
	wheelOfDestinyWindow.selection.gemContent.modification1:setText("")
	wheelOfDestinyWindow.selection.gemContent.modification2:setText("")

	if equipedGem then
		local text = GemVocations[WheelOfDestiny.vocationId][equipedGem.gemType].name:gsub(" %(x 0%)", "")
		local unusedValue = 0
		local unusedValue
		local unusedValue
		local unusedValue = "(Unkown)"

		if equipedGem.gemType == 0 then
			local var_3_10 = {}
			local var_3_11, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(var_3_10, var_3_11, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(var_3_10)
		elseif equipedGem.gemType == 1 then
			local var_3_13 = {}
			local var_3_14, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(var_3_13, var_3_14, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(var_3_13)

			local var_3_16 = {}
			local var_3_17, unusedValue = Workshop.getGemInformationByBonus(equipedGem.regularBonus, false, equipedGem.gemID, 1)

			setStringColor(var_3_16, var_3_17, filledVesselCount >= 2 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification1:setColoredText(var_3_16)
		elseif equipedGem.gemType == 2 then
			local var_3_19 = {}
			local var_3_20, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(var_3_19, var_3_20, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(var_3_19)

			local var_3_22 = {}
			local var_3_23, unusedValue = Workshop.getGemInformationByBonus(equipedGem.regularBonus, false, equipedGem.gemID, 1)

			setStringColor(var_3_22, var_3_23, filledVesselCount >= 2 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification1:setColoredText(var_3_22)

			local var_3_25 = {}
			local var_3_26, unusedValue = Workshop.getGemInformationByBonus(equipedGem.supremeBonus, true, equipedGem.gemID, 2)

			setStringColor(var_3_25, var_3_26, filledVesselCount == 3 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification2:setColoredText(var_3_25)
		end

		local var_3_28 = {}
		local var_3_29 = filledVesselCount == equipedGem.gemType + 1

		setStringColor(var_3_28, tr("+%s Damage and Healing", equipedGem.gemType == 2 and 2 or 1), var_3_29 and "#c0c0c0" or "#707070")
		wheelOfDestinyWindow.selection.gemContent.VRBonus:setColoredText(var_3_28)
		wheelOfDestinyWindow.selection.gemContent.gemName:setText(text)
	end
end

function WheelOfDestiny.onChangeGemButton(unusedArgument)
	if wheelOfDestinyWindow:isVisible() then
		wheelOfDestinyWindow:hide()
	end

	local wheelMenu = wheelWindow.menus:getChildById("wheelMenu")
	local gemMenu = wheelWindow.menus:getChildById("gemMenu")

	wheelMenu:setChecked(false)
	gemMenu:setChecked(true)
	gemAtelierWindow:show(true)
	wheelMenu:setChecked(false)
	gemMenu:setChecked(true)

	local id = WheelOfDestiny.lastSelectedGemVessel and WheelOfDestiny.lastSelectedGemVessel:getId():gsub("selectVessel", "") or 0
	local equipedGem = GemAtelier.getEquipedGem(tonumber(id))

	if equipedGem then
		GemAtelier.redirectToGem(equipedGem)
	else
		GemAtelier.resetFields()
		GemAtelier.showGems(true)
	end
end
