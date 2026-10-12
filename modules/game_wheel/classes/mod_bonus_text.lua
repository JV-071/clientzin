ModBonusText = {}

function ModBonusText.getUpgradeBonus(baseValue, bonusId, isSupreme, upgradeLevelOverride)
	local upgradeLevel = upgradeLevelOverride and upgradeLevelOverride or isSupreme and WheelOfDestiny.supremeModsUpgrade[bonusId] or WheelOfDestiny.basicModsUpgrade[bonusId]

	if not upgradeLevel then
		return baseValue
	end

	if upgradeLevel == 3 then
		baseValue = baseValue + baseValue * 50 / 100
	else
		baseValue = baseValue + baseValue * (10 * upgradeLevel) / 100
	end

	baseValue = roundToTwoDecimalPlaces(baseValue)

	return baseValue
end

function ModBonusText.getBonusDescription(modData, upgradeLevelOverride)
	local descriptionPrefix = ""

	if modData.desc and modData.showDesc then
		descriptionPrefix = tr("%s\n", modData.desc)
	end

	local upgradeLevel = modData.supreme and WheelOfDestiny.supremeModsUpgrade[modData.modID] or WheelOfDestiny.basicModsUpgrade[modData.modID]

	if upgradeLevelOverride then
		upgradeLevel = upgradeLevelOverride
	end

	local vocationBonusRates = bonusStep[WheelOfDestiny.vocationId]

	local function calculateBonusValue(baseValue, stepType)
		if modData.type and modData.type == "cooldown" then
			if not upgradeLevel or upgradeLevel == 0 then
				return 0
			end

			local cooldownBonus = modData.baseII + modData.baseII * (upgradeLevel - 1)

			return upgradeLevel == 3 and math.round(cooldownBonus) or cooldownBonus
		elseif not stepType then
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevelOverride)
		elseif stepType == "mana" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.mana, modData.modID, modData.supreme, upgradeLevelOverride)
		elseif stepType == "health" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.life, modData.modID, modData.supreme, upgradeLevelOverride)
		elseif stepType == "capacity" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.capacity, modData.modID, modData.supreme, upgradeLevelOverride)
		else
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevelOverride)
		end
	end

	local firstBonusValue = calculateBonusValue(modData.baseI, modData.stepTypeI)
	local secondBonusValue = modData.baseII and calculateBonusValue(modData.baseII, modData.stepTypeII)

	local function formatBonusTooltip(firstBonusValue, secondBonusValue)
		if modData.type == "cooldown" then
			if upgradeLevel == 0 then
				return (modData.tooltip:gsub("\n.*", ""))
			end

			return tr(modData.tooltip, secondBonusValue)
		end

		if secondBonusValue then
			return tr(modData.tooltip, firstBonusValue, secondBonusValue)
		end

		return tr(modData.tooltip, firstBonusValue)
	end

	return descriptionPrefix .. formatBonusTooltip(firstBonusValue, secondBonusValue)
end

function ModBonusText.getSideBonusDescription(modData, upgradeLevel)
	local descriptionPrefix = ""
	local vocationBonusRates = bonusStep[WheelOfDestiny.vocationId]

	local function calculateBonusValue(baseValue, stepType)
		if modData.type and modData.type == "cooldown" then
			if upgradeLevel == 0 then
				return 0
			end

			local cooldownBonus = modData.baseII + modData.baseII * (upgradeLevel - 1)

			if upgradeLevel == 3 then
				cooldownBonus = math.round(cooldownBonus)
			end

			return cooldownBonus
		elseif not stepType then
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "mana" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.mana, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "health" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.life, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "capacity" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.capacity, modData.modID, modData.supreme, upgradeLevel)
		else
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevel)
		end
	end

	local firstBonusValue = calculateBonusValue(modData.baseI, modData.stepTypeI)
	local secondBonusValue = modData.baseII and calculateBonusValue(modData.baseII, modData.stepTypeII)

	local function formatBonusTooltip(firstBonusValue, secondBonusValue)
		if modData.type == "cooldown" then
			if upgradeLevel == 0 then
				return (modData.tooltip:gsub("\n.*", ""))
			end

			return tr(modData.tooltip, secondBonusValue)
		end

		if secondBonusValue then
			return tr(modData.tooltip, firstBonusValue, secondBonusValue)
		end

		return tr(modData.tooltip, firstBonusValue)
	end

	return descriptionPrefix .. formatBonusTooltip(firstBonusValue, secondBonusValue)
end

function ModBonusText.getBonusValue(modData, upgradeLevel, useFirstBonus)
	if not modData then
		return 0
	end

	local vocationBonusRates = bonusStep[WheelOfDestiny.vocationId]

	local function calculateBonusValue(baseValue, stepType)
		if modData.type and modData.type == "cooldown" then
			if not upgradeLevel or upgradeLevel == 0 then
				return 0
			end

			local cooldownBonus = modData.baseII + modData.baseII * (upgradeLevel - 1)

			return upgradeLevel == 3 and math.round(cooldownBonus) or cooldownBonus
		elseif not stepType then
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "mana" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.mana, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "health" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.life, modData.modID, modData.supreme, upgradeLevel)
		elseif stepType == "capacity" then
			return ModBonusText.getUpgradeBonus(modData.baseStepI * vocationBonusRates.capacity, modData.modID, modData.supreme, upgradeLevel)
		else
			return ModBonusText.getUpgradeBonus(baseValue, modData.modID, modData.supreme, upgradeLevel)
		end
	end

	local firstBonusValue = calculateBonusValue(modData.baseI, modData.stepTypeI)
	local secondBonusValue = modData.baseII and calculateBonusValue(modData.baseII, modData.stepTypeII)

	return useFirstBonus and firstBonusValue or secondBonusValue
end

function ModBonusText.getGemInformationByBonus(bonusId, isSupreme, gemId, modIndex)
	local gemDataById = WheelGemState.getGemDataById(gemId)

	if not gemDataById then
		return 0
	end

	local effectiveLevel = WheelGemState.getEffectiveLevel(gemDataById, bonusId, isSupreme, modIndex)
	local dataByBonus = ModCatalog.getDataByBonus(bonusId, isSupreme)

	if not dataByBonus then
		return "(Unkown)", 0
	end

	local bonusDescription = ModBonusText.getBonusDescription(dataByBonus, effectiveLevel)

	if bonusDescription:find("Aug.") then
		bonusDescription = bonusDescription:gsub("Aug.", "Augmented")
	end

	local gradeLabels = {
		[0] = "(I)",
		"(II)",
		"(III)",
		"(IV)"
	}

	return bonusDescription .. " " .. gradeLabels[effectiveLevel], effectiveLevel
end
