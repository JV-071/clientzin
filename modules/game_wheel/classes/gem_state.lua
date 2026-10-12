WheelGemState = {}

function WheelGemState.getAtelierGems()
	return WheelOfDestiny.atelierGems or {}
end

function WheelGemState.getEquipedGems()
	return WheelOfDestiny.equipedGems or {}
end

function WheelGemState.getAtelierGemCount()
	return #WheelGemState.getAtelierGems()
end

function WheelGemState.setEquipedGems(equipedGems)
	WheelOfDestiny.equipedGems = equipedGems

	if WheelOfDestiny.currentPreset then
		WheelOfDestiny.currentPreset.equipedGems = equipedGems
	end
end

function WheelGemState.getGemDataById(gemId)
	if type(gemId) ~= "number" or gemId < 0 then
		return nil
	end

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemID == gemId then
			return getAtelierGem
		end
	end

	return nil
end

function WheelGemState.isGemEquipped(gemId)
	if not gemId or gemId < 0 then
		return false
	end

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		if type(getEquipedGem) == "number" and getEquipedGem == gemId then
			return true
		end
	end

	return false
end

function WheelGemState.getGemDomainById(gemId)
	if type(gemId) ~= "number" or gemId < 0 then
		return -1
	end

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemID == gemId then
			return getAtelierGem.gemDomain
		end
	end

	return -1
end

function WheelGemState.getGemCountByDomain(gemDomain)
	local gemCount = 0

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemDomain == gemDomain then
			gemCount = gemCount + 1
		end
	end

	return gemCount
end

function WheelGemState.getEquipedGem(gemDomain)
	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemDomain == gemDomain and WheelGemState.isGemEquipped(getAtelierGem.gemID) then
			return getAtelierGem
		end
	end

	return nil
end

function WheelGemState.getFilledVesselCount(vesselIndex)
	local filledVesselCount = 0
	local vesselBonusIndices = VesselIndex[vesselIndex]

	if not vesselBonusIndices then
		return 0
	end

	for unusedValue, entry in pairs(vesselBonusIndices) do
		local bonusDefinition = WheelBonus[entry]
		local investedPoints = WheelOfDestiny.pointInvested[entry + 1]

		if bonusDefinition and investedPoints and investedPoints >= bonusDefinition.maxPoints then
			filledVesselCount = filledVesselCount + 1
		end
	end

	return filledVesselCount
end

function WheelGemState.getVesselSocketLevel(vesselIndex)
	return math.min(WheelGemState.getFilledVesselCount(vesselIndex), 3)
end

function WheelGemState.getGemModCount(gem)
	if not gem or type(gem.gemType) ~= "number" then
		return 0
	end

	return math.max(0, math.min(gem.gemType + 1, 3))
end

function WheelGemState.getGemModBonus(gem, modSlot)
	if modSlot > WheelGemState.getGemModCount(gem) then
		return nil
	end

	if modSlot == 1 then
		return gem.lesserBonus, false
	elseif modSlot == 2 then
		return gem.regularBonus, false
	elseif modSlot == 3 then
		return gem.supremeBonus, true
	end

	return nil
end

function WheelGemState.getSocketImageClip(vesselIndex, socketLevel, isGemFullyActivated)
	if not socketLevel or socketLevel < 1 then
		return "0 0 34 34"
	end

	socketLevel = math.min(3, socketLevel)
	vesselIndex = vesselIndex or 0

	return ((isGemFullyActivated and 2 or 14) + vesselIndex * 3 + (socketLevel - 1) - 1) * 34 .. " 0 34 34"
end

function WheelGemState.isVesselAvailable(vesselIndex, requiredFilledVessels)
	local filledVesselCount = 0
	local vesselBonusIndices = VesselIndex[vesselIndex]

	if not vesselBonusIndices then
		return false
	end

	for unusedValue, entry in pairs(vesselBonusIndices) do
		local bonusDefinition = WheelBonus[entry]
		local investedPoints = WheelOfDestiny.pointInvested[entry + 1] or 0

		if bonusDefinition and investedPoints >= bonusDefinition.maxPoints then
			filledVesselCount = filledVesselCount + 1
		end
	end

	return requiredFilledVessels <= filledVesselCount
end

function WheelGemState.getEffectiveLevel(gem, bonusId, isSupremeBonus, modIndex)
	local basicModsUpgrade = WheelOfDestiny.basicModsUpgrade
	local supremeModsUpgrade = WheelOfDestiny.supremeModsUpgrade
	local bonusUpgradeLevel = isSupremeBonus and (supremeModsUpgrade[bonusId] or 0) or basicModsUpgrade[bonusId] or 0

	if modIndex == 0 then
		return bonusUpgradeLevel
	elseif modIndex == 1 then
		local lesserBonusUpgradeLevel = basicModsUpgrade[gem.lesserBonus] or 0

		return math.min(bonusUpgradeLevel, lesserBonusUpgradeLevel)
	elseif modIndex == 2 then
		local lesserBonusUpgradeLevel = basicModsUpgrade[gem.lesserBonus] or 0
		local regularBonusUpgradeLevel = basicModsUpgrade[gem.regularBonus] or 0
		local precedingBonusLevel = math.min(lesserBonusUpgradeLevel, regularBonusUpgradeLevel)

		return math.min(bonusUpgradeLevel, precedingBonusLevel)
	end
end

function WheelGemState.toggleGemLock(gemId)
	local gemDataById = WheelGemState.getGemDataById(gemId)

	if not gemDataById then
		return nil
	end

	gemDataById.locked = gemDataById.locked == 1 and 0 or 1

	return gemDataById.locked
end

function WheelGemState.equipGemInVessel(gem, unequip)
	local equippedGemIds = {
		-1,
		-1,
		-1,
		-1
	}

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		if type(getEquipedGem) == "number" and getEquipedGem >= 0 then
			local gemDomainById = WheelGemState.getGemDomainById(getEquipedGem)

			if gemDomainById ~= -1 and gemDomainById ~= gem.gemDomain then
				equippedGemIds[gemDomainById + 1] = getEquipedGem
			end
		end
	end

	if not unequip then
		equippedGemIds[gem.gemDomain + 1] = gem.gemID
	else
		equippedGemIds[gem.gemDomain + 1] = -1
	end

	WheelGemState.setEquipedGems(equippedGemIds)

	return equippedGemIds
end
