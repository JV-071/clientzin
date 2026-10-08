ModBonusText = {}

function ModBonusText.getUpgradeBonus(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	local var_1_0 = arg_1_3 and arg_1_3 or arg_1_2 and WheelOfDestiny.supremeModsUpgrade[arg_1_1] or WheelOfDestiny.basicModsUpgrade[arg_1_1]

	if not var_1_0 then
		return arg_1_0
	end

	if var_1_0 == 3 then
		arg_1_0 = arg_1_0 + arg_1_0 * 50 / 100
	else
		arg_1_0 = arg_1_0 + arg_1_0 * (10 * var_1_0) / 100
	end

	arg_1_0 = roundToTwoDecimalPlaces(arg_1_0)

	return arg_1_0
end

function ModBonusText.getBonusDescription(arg_2_0, arg_2_1)
	local var_2_0 = ""

	if arg_2_0.desc and arg_2_0.showDesc then
		var_2_0 = tr("%s\n", arg_2_0.desc)
	end

	local var_2_1 = arg_2_0.supreme and WheelOfDestiny.supremeModsUpgrade[arg_2_0.modID] or WheelOfDestiny.basicModsUpgrade[arg_2_0.modID]

	if arg_2_1 then
		var_2_1 = arg_2_1
	end

	local var_2_2 = bonusStep[WheelOfDestiny.vocationId]

	local function var_2_3(arg_3_0, arg_3_1)
		if arg_2_0.type and arg_2_0.type == "cooldown" then
			if not var_2_1 or var_2_1 == 0 then
				return 0
			end

			local var_3_0 = arg_2_0.baseII + arg_2_0.baseII * (var_2_1 - 1)

			return var_2_1 == 3 and math.round(var_3_0) or var_3_0
		elseif not arg_3_1 then
			return ModBonusText.getUpgradeBonus(arg_3_0, arg_2_0.modID, arg_2_0.supreme, arg_2_1)
		elseif arg_3_1 == "mana" then
			return ModBonusText.getUpgradeBonus(arg_2_0.baseStepI * var_2_2.mana, arg_2_0.modID, arg_2_0.supreme, arg_2_1)
		elseif arg_3_1 == "health" then
			return ModBonusText.getUpgradeBonus(arg_2_0.baseStepI * var_2_2.life, arg_2_0.modID, arg_2_0.supreme, arg_2_1)
		elseif arg_3_1 == "capacity" then
			return ModBonusText.getUpgradeBonus(arg_2_0.baseStepI * var_2_2.capacity, arg_2_0.modID, arg_2_0.supreme, arg_2_1)
		else
			return ModBonusText.getUpgradeBonus(arg_3_0, arg_2_0.modID, arg_2_0.supreme, arg_2_1)
		end
	end

	local var_2_4 = var_2_3(arg_2_0.baseI, arg_2_0.stepTypeI)
	local var_2_5 = arg_2_0.baseII and var_2_3(arg_2_0.baseII, arg_2_0.stepTypeII)

	local function var_2_6(arg_4_0, arg_4_1)
		if arg_2_0.type == "cooldown" then
			if var_2_1 == 0 then
				return (arg_2_0.tooltip:gsub("\n.*", ""))
			end

			return tr(arg_2_0.tooltip, arg_4_1)
		end

		if arg_4_1 then
			return tr(arg_2_0.tooltip, arg_4_0, arg_4_1)
		end

		return tr(arg_2_0.tooltip, arg_4_0)
	end

	return var_2_0 .. var_2_6(var_2_4, var_2_5)
end

function ModBonusText.getSideBonusDescription(arg_5_0, arg_5_1)
	local var_5_0 = ""
	local var_5_1 = bonusStep[WheelOfDestiny.vocationId]

	local function var_5_2(arg_6_0, arg_6_1)
		if arg_5_0.type and arg_5_0.type == "cooldown" then
			if arg_5_1 == 0 then
				return 0
			end

			local var_6_0 = arg_5_0.baseII + arg_5_0.baseII * (arg_5_1 - 1)

			if arg_5_1 == 3 then
				var_6_0 = math.round(var_6_0)
			end

			return var_6_0
		elseif not arg_6_1 then
			return ModBonusText.getUpgradeBonus(arg_6_0, arg_5_0.modID, arg_5_0.supreme, arg_5_1)
		elseif arg_6_1 == "mana" then
			return ModBonusText.getUpgradeBonus(arg_5_0.baseStepI * var_5_1.mana, arg_5_0.modID, arg_5_0.supreme, arg_5_1)
		elseif arg_6_1 == "health" then
			return ModBonusText.getUpgradeBonus(arg_5_0.baseStepI * var_5_1.life, arg_5_0.modID, arg_5_0.supreme, arg_5_1)
		elseif arg_6_1 == "capacity" then
			return ModBonusText.getUpgradeBonus(arg_5_0.baseStepI * var_5_1.capacity, arg_5_0.modID, arg_5_0.supreme, arg_5_1)
		else
			return ModBonusText.getUpgradeBonus(arg_6_0, arg_5_0.modID, arg_5_0.supreme, arg_5_1)
		end
	end

	local var_5_3 = var_5_2(arg_5_0.baseI, arg_5_0.stepTypeI)
	local var_5_4 = arg_5_0.baseII and var_5_2(arg_5_0.baseII, arg_5_0.stepTypeII)

	local function var_5_5(arg_7_0, arg_7_1)
		if arg_5_0.type == "cooldown" then
			if arg_5_1 == 0 then
				return (arg_5_0.tooltip:gsub("\n.*", ""))
			end

			return tr(arg_5_0.tooltip, arg_7_1)
		end

		if arg_7_1 then
			return tr(arg_5_0.tooltip, arg_7_0, arg_7_1)
		end

		return tr(arg_5_0.tooltip, arg_7_0)
	end

	return var_5_0 .. var_5_5(var_5_3, var_5_4)
end

function ModBonusText.getBonusValue(arg_8_0, arg_8_1, arg_8_2)
	if not arg_8_0 then
		return 0
	end

	local var_8_0 = bonusStep[WheelOfDestiny.vocationId]

	local function var_8_1(arg_9_0, arg_9_1)
		if arg_8_0.type and arg_8_0.type == "cooldown" then
			if not arg_8_1 or arg_8_1 == 0 then
				return 0
			end

			local var_9_0 = arg_8_0.baseII + arg_8_0.baseII * (arg_8_1 - 1)

			return arg_8_1 == 3 and math.round(var_9_0) or var_9_0
		elseif not arg_9_1 then
			return ModBonusText.getUpgradeBonus(arg_9_0, arg_8_0.modID, arg_8_0.supreme, arg_8_1)
		elseif arg_9_1 == "mana" then
			return ModBonusText.getUpgradeBonus(arg_8_0.baseStepI * var_8_0.mana, arg_8_0.modID, arg_8_0.supreme, arg_8_1)
		elseif arg_9_1 == "health" then
			return ModBonusText.getUpgradeBonus(arg_8_0.baseStepI * var_8_0.life, arg_8_0.modID, arg_8_0.supreme, arg_8_1)
		elseif arg_9_1 == "capacity" then
			return ModBonusText.getUpgradeBonus(arg_8_0.baseStepI * var_8_0.capacity, arg_8_0.modID, arg_8_0.supreme, arg_8_1)
		else
			return ModBonusText.getUpgradeBonus(arg_9_0, arg_8_0.modID, arg_8_0.supreme, arg_8_1)
		end
	end

	local var_8_2 = var_8_1(arg_8_0.baseI, arg_8_0.stepTypeI)
	local var_8_3 = arg_8_0.baseII and var_8_1(arg_8_0.baseII, arg_8_0.stepTypeII)

	return arg_8_2 and var_8_2 or var_8_3
end

function ModBonusText.getGemInformationByBonus(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
	local gemDataById = WheelGemState.getGemDataById(arg_10_2)

	if not gemDataById then
		return 0
	end

	local effectiveLevel = WheelGemState.getEffectiveLevel(gemDataById, arg_10_0, arg_10_1, arg_10_3)
	local dataByBonus = ModCatalog.getDataByBonus(arg_10_0, arg_10_1)

	if not dataByBonus then
		return "(Unkown)", 0
	end

	local bonusDescription = ModBonusText.getBonusDescription(dataByBonus, effectiveLevel)

	if bonusDescription:find("Aug.") then
		bonusDescription = bonusDescription:gsub("Aug.", "Augmented")
	end

	local var_10_4 = {
		[0] = "(I)",
		"(II)",
		"(III)",
		"(IV)"
	}

	return bonusDescription .. " " .. var_10_4[effectiveLevel], effectiveLevel
end
