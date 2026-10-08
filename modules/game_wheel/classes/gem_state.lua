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

function WheelGemState.getGemDataById(arg_5_0)
	if type(arg_5_0) ~= "number" or arg_5_0 < 0 then
		return nil
	end

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemID == arg_5_0 then
			return getAtelierGem
		end
	end

	return nil
end

function WheelGemState.isGemEquipped(arg_6_0)
	if not arg_6_0 or arg_6_0 < 0 then
		return false
	end

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		if type(getEquipedGem) == "number" and getEquipedGem == arg_6_0 then
			return true
		end
	end

	return false
end

function WheelGemState.getGemDomainById(arg_7_0)
	if type(arg_7_0) ~= "number" or arg_7_0 < 0 then
		return -1
	end

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemID == arg_7_0 then
			return getAtelierGem.gemDomain
		end
	end

	return -1
end

function WheelGemState.getGemCountByDomain(arg_8_0)
	local var_8_0 = 0

	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemDomain == arg_8_0 then
			var_8_0 = var_8_0 + 1
		end
	end

	return var_8_0
end

function WheelGemState.getEquipedGem(arg_9_0)
	for unusedValue, getAtelierGem in pairs(WheelGemState.getAtelierGems()) do
		if getAtelierGem.gemDomain == arg_9_0 and WheelGemState.isGemEquipped(getAtelierGem.gemID) then
			return getAtelierGem
		end
	end

	return nil
end

function WheelGemState.getFilledVesselCount(arg_10_0)
	local var_10_0 = 0
	local var_10_1 = VesselIndex[arg_10_0]

	if not var_10_1 then
		return 0
	end

	for unusedValue, entry in pairs(var_10_1) do
		local var_10_2 = WheelBonus[entry]
		local var_10_3 = WheelOfDestiny.pointInvested[entry + 1]

		if var_10_2 and var_10_3 and var_10_3 >= var_10_2.maxPoints then
			var_10_0 = var_10_0 + 1
		end
	end

	return var_10_0
end

function WheelGemState.getVesselSocketLevel(arg_11_0)
	return math.min(WheelGemState.getFilledVesselCount(arg_11_0), 3)
end

function WheelGemState.getGemModCount(arg_12_0)
	if not arg_12_0 or type(arg_12_0.gemType) ~= "number" then
		return 0
	end

	return math.max(0, math.min(arg_12_0.gemType + 1, 3))
end

function WheelGemState.getGemModBonus(arg_13_0, arg_13_1)
	if arg_13_1 > WheelGemState.getGemModCount(arg_13_0) then
		return nil
	end

	if arg_13_1 == 1 then
		return arg_13_0.lesserBonus, false
	elseif arg_13_1 == 2 then
		return arg_13_0.regularBonus, false
	elseif arg_13_1 == 3 then
		return arg_13_0.supremeBonus, true
	end

	return nil
end

function WheelGemState.getSocketImageClip(arg_14_0, arg_14_1, arg_14_2)
	if not arg_14_1 or arg_14_1 < 1 then
		return "0 0 34 34"
	end

	arg_14_1 = math.min(3, arg_14_1)
	arg_14_0 = arg_14_0 or 0

	return ((arg_14_2 and 2 or 14) + arg_14_0 * 3 + (arg_14_1 - 1) - 1) * 34 .. " 0 34 34"
end

function WheelGemState.isVesselAvailable(arg_15_0, arg_15_1)
	local var_15_0 = 0
	local var_15_1 = VesselIndex[arg_15_0]

	if not var_15_1 then
		return false
	end

	for unusedValue, entry in pairs(var_15_1) do
		local var_15_2 = WheelBonus[entry]
		local var_15_3 = WheelOfDestiny.pointInvested[entry + 1] or 0

		if var_15_2 and var_15_3 >= var_15_2.maxPoints then
			var_15_0 = var_15_0 + 1
		end
	end

	return arg_15_1 <= var_15_0
end

function WheelGemState.getEffectiveLevel(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
	local basicModsUpgrade = WheelOfDestiny.basicModsUpgrade
	local supremeModsUpgrade = WheelOfDestiny.supremeModsUpgrade
	local var_16_2 = arg_16_2 and (supremeModsUpgrade[arg_16_1] or 0) or basicModsUpgrade[arg_16_1] or 0

	if arg_16_3 == 0 then
		return var_16_2
	elseif arg_16_3 == 1 then
		local var_16_3 = basicModsUpgrade[arg_16_0.lesserBonus] or 0

		return math.min(var_16_2, var_16_3)
	elseif arg_16_3 == 2 then
		local var_16_4 = basicModsUpgrade[arg_16_0.lesserBonus] or 0
		local var_16_5 = basicModsUpgrade[arg_16_0.regularBonus] or 0
		local var_16_6 = math.min(var_16_4, var_16_5)

		return math.min(var_16_2, var_16_6)
	end
end

function WheelGemState.toggleGemLock(arg_17_0)
	local gemDataById = WheelGemState.getGemDataById(arg_17_0)

	if not gemDataById then
		return nil
	end

	gemDataById.locked = gemDataById.locked == 1 and 0 or 1

	return gemDataById.locked
end

function WheelGemState.equipGemInVessel(arg_18_0, arg_18_1)
	local var_18_0 = {
		-1,
		-1,
		-1,
		-1
	}

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		if type(getEquipedGem) == "number" and getEquipedGem >= 0 then
			local gemDomainById = WheelGemState.getGemDomainById(getEquipedGem)

			if gemDomainById ~= -1 and gemDomainById ~= arg_18_0.gemDomain then
				var_18_0[gemDomainById + 1] = getEquipedGem
			end
		end
	end

	if not arg_18_1 then
		var_18_0[arg_18_0.gemDomain + 1] = arg_18_0.gemID
	else
		var_18_0[arg_18_0.gemDomain + 1] = -1
	end

	WheelGemState.setEquipedGems(var_18_0)

	return var_18_0
end
