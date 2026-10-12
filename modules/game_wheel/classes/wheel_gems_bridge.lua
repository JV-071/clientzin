local inactiveSocketBackground = "/images/game/wheel/backdrop_skillwheel_socket_inactive"
local activeSocketBackground = "/images/game/wheel/backdrop_skillwheel_socket_active"
local imageSourcePath = "/images/game/wheel/icons-skillwheel-sockets"

function WheelOfDestiny.configureEquippedGems()
	if not wheelPanel then
		return
	end

	for vesselIndex = 0, 3 do
		local equipedGem = GemAtelier.getEquipedGem(vesselIndex)
		local socketBackground = wheelPanel:recursiveGetChildById("socketBackground" .. vesselIndex)
		local gemSocketBg = wheelPanel:recursiveGetChildById("gemSocketBg" .. vesselIndex)
		local gemSocket = wheelPanel:recursiveGetChildById("gemSocket" .. vesselIndex)

		if gemSocket then
			local gemIcon = gemSocket:recursiveGetChildById("gemIcon" .. vesselIndex)
			local vesselSocketLevel = WheelGemState.getVesselSocketLevel(vesselIndex)
			local visible = equipedGem ~= nil
			local isGemFullyActivated = visible and vesselSocketLevel == equipedGem.gemType + 1

			if socketBackground then
				local socketBackgroundName = vesselSocketLevel == 0 and "backdrop_skillwheel_largebonus_socketdisabled_" .. vesselIndex or "backdrop_skillwheel_largebonus_socketenabled_" .. vesselIndex

				socketBackground:setImageSource("/images/game/wheel/" .. socketBackgroundName)
			end

			if gemSocketBg then
				gemSocketBg:setImageSource(vesselSocketLevel == 0 and inactiveSocketBackground or activeSocketBackground)
				gemSocketBg:setVisible(true)
			end

			gemSocket:setImageSource(imageSourcePath)
			gemSocket:setImageClip(WheelGemState.getSocketImageClip(vesselIndex, vesselSocketLevel, isGemFullyActivated))
			gemSocket:setVisible(vesselSocketLevel > 0 or visible)

			if gemIcon then
				gemIcon:setVisible(visible)

				if visible then
					local gemTypeClipOffset = equipedGem.gemType * 32
					local gemDomainClipOffset = equipedGem.gemDomain * 96
					local vocationClipOffset = (WheelOfDestiny.vocationId - 1) * 384

					gemIcon:setImageClip(vocationClipOffset + gemDomainClipOffset + gemTypeClipOffset .. " 0 32 32")
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

function WheelOfDestiny.onGemVesselClick(vesselIndex)
	if WheelOfDestiny.lastSelectedGemVessel then
		WheelOfDestiny.lastSelectedGemVessel:setVisible(false)
	end

	WheelOfDestiny.resetPassiveFocus()
	wheelPanel.borderSelectedWheel:setVisible(false)

	local selectVessel = wheelPanel:recursiveGetChildById("selectVessel" .. vesselIndex)

	WheelOfDestiny.lastSelectedGemVessel = selectVessel

	WheelOfDestiny.lastSelectedGemVessel:setVisible(true)
	wheelOfDestinyWindow.selection.tabContent:setVisible(false)
	wheelOfDestinyWindow.selection.gemContent:setVisible(true)

	local filledVesselCount = GemAtelier.getFilledVesselCount(vesselIndex)
	local equipedGem = GemAtelier.getEquipedGem(vesselIndex)

	if not equipedGem then
		wheelOfDestinyWindow.selection.gemContent.gemName:setText("Vessel contains no gem")
	end

	local vesselRankLabels = {
		"I",
		"II",
		"III"
	}
	local vesselStateName = "Sealed"

	if filledVesselCount == 1 then
		vesselStateName = "Dormant"
	elseif filledVesselCount == 2 then
		vesselStateName = "Awakened"
	elseif filledVesselCount == 3 then
		vesselStateName = "Radiant"
	end

	wheelOfDestinyWindow.selection.gemContent.sealedInfo:setText(tr("%s Vessel (VR %s)", vesselStateName, filledVesselCount == 0 and "0" or vesselRankLabels[filledVesselCount]))
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
			local lesserBonusText = {}
			local lesserBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(lesserBonusText, lesserBonusDescription, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(lesserBonusText)
		elseif equipedGem.gemType == 1 then
			local lesserBonusText = {}
			local lesserBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(lesserBonusText, lesserBonusDescription, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(lesserBonusText)

			local regularBonusText = {}
			local regularBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.regularBonus, false, equipedGem.gemID, 1)

			setStringColor(regularBonusText, regularBonusDescription, filledVesselCount >= 2 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification1:setColoredText(regularBonusText)
		elseif equipedGem.gemType == 2 then
			local lesserBonusText = {}
			local lesserBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.lesserBonus, false, equipedGem.gemID, 0)

			setStringColor(lesserBonusText, lesserBonusDescription, filledVesselCount >= 1 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification0:setColoredText(lesserBonusText)

			local regularBonusText = {}
			local regularBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.regularBonus, false, equipedGem.gemID, 1)

			setStringColor(regularBonusText, regularBonusDescription, filledVesselCount >= 2 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification1:setColoredText(regularBonusText)

			local supremeBonusText = {}
			local supremeBonusDescription, unusedValue = Workshop.getGemInformationByBonus(equipedGem.supremeBonus, true, equipedGem.gemID, 2)

			setStringColor(supremeBonusText, supremeBonusDescription, filledVesselCount == 3 and "#c0c0c0" or "#707070")
			wheelOfDestinyWindow.selection.gemContent.modification2:setColoredText(supremeBonusText)
		end

		local vesselRankBonusText = {}
		local isGemFullyActivated = filledVesselCount == equipedGem.gemType + 1

		setStringColor(vesselRankBonusText, tr("+%s Damage and Healing", equipedGem.gemType == 2 and 2 or 1), isGemFullyActivated and "#c0c0c0" or "#707070")
		wheelOfDestinyWindow.selection.gemContent.VRBonus:setColoredText(vesselRankBonusText)
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
