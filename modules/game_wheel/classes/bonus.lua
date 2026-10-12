local function firstSpellIsUnlocked(attribute)
	if type(attribute) ~= "table" then
		return false
	end

	return WheelOfDestiny.isLitFull(attribute[1]) or WheelOfDestiny.isLitFull(attribute[2])
end

local function secondSpellIsUnlocked(attribute)
	if type(attribute) ~= "table" then
		return false
	end

	return WheelOfDestiny.isLitFull(attribute[1]) and WheelOfDestiny.isLitFull(attribute[2])
end

local ACTIVE_BONUS_TEXT_COLOR = "#c0c0c0"
local INACTIVE_BONUS_TEXT_COLOR = "#707070"

function formatWheelPercent(numericValue, includePlusSign)
	numericValue = tonumber(numericValue) or 0

	local formattedText

	if math.abs(numericValue - math.floor(numericValue + 1e-09)) < 1e-09 then
		formattedText = string.format("%d", math.floor(numericValue + 1e-09))
	else
		formattedText = string.format("%.2f", numericValue):gsub("(%..-)0+$", "%1"):gsub("%.$", "")
	end

	if includePlusSign then
		return string.format("+%s%%", formattedText)
	end

	return formattedText .. "%"
end

function formatWheelPlusInteger(amount)
	amount = math.floor((tonumber(amount) or 0) + 0.5)

	return (amount < 0 and "-" or "+") .. comma_value(math.abs(amount))
end

function formatWheelSignedPercent(numericValue)
	numericValue = tonumber(numericValue) or 0

	return (numericValue < 0 and "-" or "+") .. formatWheelPercent(math.abs(numericValue))
end

function formatWheelFixedPercent(numericValue, includePlusSign)
	numericValue = tonumber(numericValue) or 0

	local formattedText = string.format("%.2f%%", math.abs(numericValue))

	if numericValue < 0 then
		return "-" .. formattedText
	end

	return (includePlusSign and "+" or "") .. formattedText
end

local function normalizeBonusWhitespace(text)
	if type(text) ~= "string" then
		return ""
	end

	return text:gsub("\n+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function selectStringOrFallback(text, fallback)
	if type(text) == "string" then
		return text
	end

	if type(fallback) == "string" then
		return fallback
	end

	return ""
end

local function buildAugmentationTier(tierIndex, unlocked, description)
	local normalizedDescription = normalizeBonusWhitespace(description)
	local textColor = unlocked and ACTIVE_BONUS_TEXT_COLOR or INACTIVE_BONUS_TEXT_COLOR

	return {
		prefix = string.format("{icon:icon-augmentation-%d-%s}{: , %s}", tierIndex, unlocked and "active" or "inactive", ACTIVE_BONUS_TEXT_COLOR),
		text = string.format("{%s, %s}", normalizedDescription, textColor)
	}
end

local function colorBonusText(text, active)
	local textColor = active and ACTIVE_BONUS_TEXT_COLOR or INACTIVE_BONUS_TEXT_COLOR

	return string.format("{%s, %s}", normalizeBonusWhitespace(text), textColor)
end

local function buildSpellAugmentationTiers(firstTierText, firstTierUnlocked, secondTierText, secondTierUnlocked)
	local tiers = {
		buildAugmentationTier(1, firstTierUnlocked, firstTierText)
	}

	if secondTierText and secondTierText ~= "" then
		tiers[#tiers + 1] = buildAugmentationTier(2, secondTierUnlocked, secondTierText)
	end

	return tiers
end

local function buildSpellConvictionParts(title, firstTierText, secondTierText, unlockSlices, investedPoints, requiredPoints)
	return {
		name = colorBonusText(title, requiredPoints <= investedPoints),
		tiers = buildSpellAugmentationTiers(firstTierText, firstSpellIsUnlocked(unlockSlices), secondTierText, secondSpellIsUnlocked(unlockSlices))
	}
end

local function splitBonusTitleAndBody(text)
	if type(text) ~= "string" or text == "" then
		return "", ""
	end

	local newlineIndex = text:find("\n", 1, true)

	if not newlineIndex then
		return text, ""
	end

	return text:sub(1, newlineIndex - 1), text:sub(newlineIndex + 1)
end

local function buildBonusTitleAndBody(text)
	local title, body = splitBonusTitleAndBody(text)

	return {
		name = title,
		body = body
	}
end

function getDedicationBonus(index)
	local bonus = WheelBonus[index - 1]
	local vocation = WheelOfDestiny.vocationId
	local points = WheelOfDestiny.pointInvested[index] or 0

	if not vocation or vocation == 0 then
		return
	end

	local dedicationConstants = WheelConsts[bonus.dedication]
	local bonusPerPoint = 0

	if type(dedicationConstants) == "table" and dedicationConstants[vocation] then
		bonusPerPoint = dedicationConstants[vocation] or 0
	end

	local dedicationText = DedicationBonusTexts[bonus.dedication]

	if not dedicationText then
		return ""
	end

	if bonus.dedication == "mitigation" then
		return formatWheelPercent(points * dedicationConstants) .. dedicationText.percentSuffix
	elseif bonus.dedication == "lifemana" then
		return string.format(dedicationText, points * dedicationConstants.life[vocation], points * dedicationConstants.mana[vocation])
	end

	return string.format(dedicationText, points * bonusPerPoint)
end

function getDedicationTooltip(index)
	local bonusDefinition = WheelBonus[index - 1]
	local vocationId = WheelOfDestiny.vocationId

	if not vocationId or vocationId == 0 then
		return ""
	end

	local dedicationConstants = WheelConsts[bonusDefinition.dedication]
	local bonusPerPoint = 0

	if type(dedicationConstants) == "table" and dedicationConstants[vocationId] then
		bonusPerPoint = dedicationConstants[vocationId] or 0
	end

	local dedicationTooltip = DedicationTooltipTexts[bonusDefinition.dedication]

	if not dedicationTooltip then
		return ""
	end

	if bonusDefinition.dedication == "mitigation" then
		return dedicationTooltip.prefix .. formatWheelPercent(dedicationConstants) .. dedicationTooltip.percentSuffix
	elseif bonusDefinition.dedication == "lifemana" then
		return string.format(dedicationTooltip, dedicationConstants.life[vocationId], dedicationConstants.mana[vocationId])
	end

	return string.format(dedicationTooltip, bonusPerPoint)
end

function getConvictionBonusTooltip(index)
	local bonusDefinition = WheelBonus[index - 1]
	local vocation = WheelOfDestiny.vocationId
	local order = WheelConsts[bonusDefinition.conviction]
	local conviction = bonusDefinition.conviction

	if conviction == "vessel" then
		local vesselText = ConvictionStaticTexts.vessel[bonusDefinition.domain]

		return vesselText and vesselText.tooltip or ""
	elseif conviction == "special_1" or conviction == "special_2" then
		local specialText = ConvictionSpecialTexts[conviction] and ConvictionSpecialTexts[conviction][vocation]

		return specialText and (specialText.tooltip or specialText.body) or ""
	elseif ConvictionSpellTexts[conviction] then
		return buildSpellConvictionTooltip(conviction, vocation, order) or ""
	end

	return ""
end

function getConvictionBonus(index, fullMessage)
	local bonusParts = getConvictionBonusParts(index, fullMessage)

	if not bonusParts.name or bonusParts.name == "" then
		return bonusParts.body or ""
	end

	if bonusParts.tiers and #bonusParts.tiers > 0 then
		local tierText = ""

		for index, tier in ipairs(bonusParts.tiers) do
			if index > 1 then
				tierText = tierText .. "\n"
			end

			tierText = tierText .. tier.prefix .. tier.text
		end

		return bonusParts.name .. tierText
	end

	if bonusParts.body and bonusParts.body ~= "" then
		if bonusParts.name:find("{", 1, true) or bonusParts.body:find("{", 1, true) then
			return bonusParts.name .. bonusParts.body
		end

		return bonusParts.name .. "\n" .. bonusParts.body
	end

	return bonusParts.name
end

function getConvictionBonusParts(sliceIndex, fullMessage)
	local rawBonus = getConvictionBonusRaw(sliceIndex, fullMessage)

	if type(rawBonus) == "table" and type(rawBonus.name) == "string" then
		if rawBonus.tiers then
			return {
				body = "",
				name = rawBonus.name,
				tiers = rawBonus.tiers
			}
		end

		return rawBonus
	end

	if type(rawBonus) ~= "string" then
		rawBonus = ""
	end

	return buildBonusTitleAndBody(rawBonus)
end

local function buildSpecialConvictionText(conviction, vocationId, fullMessage)
	local specialText = ConvictionSpecialTexts[conviction] and ConvictionSpecialTexts[conviction][vocationId]

	if not specialText then
		return ""
	end

	local body = fullMessage and specialText.body or specialText.bodyShort or specialText.body

	return selectStringOrFallback(specialText.name) .. "\n" .. selectStringOrFallback(body)
end

function getSpellConvictionTextEntry(conviction, vocationId)
	return ConvictionSpellTexts[conviction] and ConvictionSpellTexts[conviction][vocationId] or nil
end

local TOOLTIP_BULLET = "•"

function buildSpellConvictionTooltip(conviction, vocationId, unusedArgument)
	local spellText = getSpellConvictionTextEntry(conviction, vocationId)

	if not spellText then
		return nil
	end

	local tooltipParts = {}
	local tiers = spellText.tiers or {}

	for index, entry in ipairs(tiers) do
		if type(entry) ~= "string" then
			-- block empty
		else
			setStringColor(tooltipParts, TOOLTIP_BULLET, "white")

			local lineEnding = index < #tiers and "\n" or ""

			setStringColor(tooltipParts, entry .. lineEnding, "#3F3F3F")
		end
	end

	return tooltipParts
end

function getConvictionBonusRaw(sliceIndex, fullMessage)
	local bonusDefinition = WheelBonus[sliceIndex - 1]

	if not bonusDefinition then
		return ""
	end

	local vocationId = WheelOfDestiny.vocationId
	local investedPoints = WheelOfDestiny.pointInvested[sliceIndex] or 0
	local convictionConstants = WheelConsts[bonusDefinition.conviction]
	local conviction = bonusDefinition.conviction

	if conviction == "vessel" then
		local vesselText = ConvictionStaticTexts.vessel[bonusDefinition.domain]

		if not vesselText then
			return ""
		end

		local body = fullMessage and vesselText.body or vesselText.bodyShort

		return selectStringOrFallback(vesselText.name) .. "\n" .. selectStringOrFallback(body)
	elseif conviction == "skill" then
		local skillText = ConvictionStaticTexts.skill[vocationId]

		if not skillText then
			return ""
		end

		return string.format(selectStringOrFallback(skillText.template), convictionConstants)
	elseif conviction == "lifeleech" then
		return formatWheelPercent(convictionConstants, true) .. " Life Leech"
	elseif conviction == "manaleech" then
		return formatWheelPercent(convictionConstants, true) .. " Mana Leech"
	elseif ConvictionSpellTexts[conviction] then
		local spellText = getSpellConvictionTextEntry(conviction, vocationId)

		if not spellText then
			return ""
		end

		local tiers = spellText.tiers

		if type(tiers) ~= "table" then
			tiers = {}
		end

		return buildSpellConvictionParts(selectStringOrFallback(spellText.title, spellText.perk), selectStringOrFallback(tiers[1]), selectStringOrFallback(tiers[2]), convictionConstants, investedPoints, bonusDefinition.maxPoints or 0)
	elseif conviction == "special_1" or conviction == "special_2" then
		return buildSpecialConvictionText(conviction, vocationId, fullMessage)
	end

	return ""
end

local ROMAN_TIER_LABELS = {
	"I",
	"II",
	"III"
}

local function stripAugmentationPrefix(title)
	return (title or ""):gsub("^Augmented%s+", ""):gsub("^Aug%.%s*", "")
end

function getConvictionPerks()
	local vocationId = WheelOfDestiny.vocationId
	local convictions = {}

	local function getOrCreateConvictionPerk(convictionKey, perkDefinition)
		if not convictions[convictionKey] then
			perkDefinition.points = 0
			convictions[convictionKey] = perkDefinition
		end

		return convictions[convictionKey]
	end

	for id, bonus in pairs(WheelBonus) do
		local index = id + 1

		if (WheelOfDestiny.pointInvested[index] or 0) < bonus.maxPoints then
			-- block empty
		else
			local conviction = bonus.conviction
			local convictionConstants = WheelConsts[conviction]

			if conviction == "special_1" or conviction == "special_2" then
				local specialText = ConvictionSpecialTexts[conviction] and ConvictionSpecialTexts[conviction][vocationId]

				if specialText then
					getOrCreateConvictionPerk(conviction, {
						priority = 0,
						names = {
							specialText.name
						},
						tooltip = specialText.tooltip or specialText.body
					})
				elseif convictionConstants and convictionConstants[vocationId] then
					getOrCreateConvictionPerk(conviction, {
						priority = 0,
						names = {
							convictionConstants[vocationId][1]
						},
						tooltip = convictionConstants[vocationId][2]
					})
				end
			elseif conviction == "skill" then
				local skillText = ConvictionStaticTexts.skill[vocationId]

				if skillText then
					local skillPerk = getOrCreateConvictionPerk(conviction, {
						priority = 0,
						names = {
							skillText.perk
						},
						tooltip = skillText.tooltip
					})

					skillPerk.points = skillPerk.points + convictionConstants
					skillPerk.stringPoint = formatWheelPlusInteger(skillPerk.points)
				end
			elseif conviction == "lifeleech" or conviction == "manaleech" then
				local leechName = conviction == "lifeleech" and "Life Leech" or "Mana Leech"
				local leechPerk = getOrCreateConvictionPerk(conviction, {
					priority = 4,
					names = {
						leechName
					},
					order = conviction == "lifeleech" and 1 or 2
				})

				leechPerk.points = leechPerk.points + convictionConstants
				leechPerk.stringPoint = formatWheelFixedPercent(leechPerk.points, true)
			elseif conviction == "vessel" then
				local vesselText = ConvictionStaticTexts.vessel[bonus.domain]

				if vesselText then
					local vesselPerk = getOrCreateConvictionPerk("vessel." .. bonus.domain, {
						priority = 4,
						names = {
							vesselText.name,
							vesselText.perk
						},
						order = 10 + bonus.domain,
						tooltip = vesselText.tooltip
					})

					vesselPerk.points = vesselPerk.points + 1
					vesselPerk.stringPoint = ROMAN_TIER_LABELS[math.min(vesselPerk.points, 3)]
				end
			elseif ConvictionSpellTexts[conviction] then
				local spellText = getSpellConvictionTextEntry(conviction, vocationId)

				if spellText then
					local spellTitle = stripAugmentationPrefix(spellText.title or spellText.perk)
					local spellPerk = getOrCreateConvictionPerk(conviction, {
						priority = 1,
						names = {
							"Augmented " .. spellTitle,
							"Aug. " .. spellTitle
						},
						tooltip = buildSpellConvictionTooltip(conviction, vocationId, convictionConstants)
					})

					spellPerk.points = spellPerk.points + 1
					spellPerk.stringPoint = ROMAN_TIER_LABELS[math.min(spellPerk.points, 2)]
				end
			end
		end
	end

	local sortedPerks = {}

	for unusedValue, conviction in pairs(convictions) do
		conviction.perk = conviction.names[#conviction.names]

		table.insert(sortedPerks, conviction)
	end

	table.sort(sortedPerks, function(leftPerk, rightPerk)
		if leftPerk.priority ~= rightPerk.priority then
			return leftPerk.priority < rightPerk.priority
		end

		if (leftPerk.order or 0) ~= (rightPerk.order or 0) then
			return (leftPerk.order or 0) < (rightPerk.order or 0)
		end

		return leftPerk.names[1] < rightPerk.names[1]
	end)

	return sortedPerks, convictions
end

function getPassiveInfo(domain)
	local extraPoints = WheelOfDestiny.extraPassivePoints[domain] or 0
	local passive = WheelOfDestiny.passivePoints[domain] + extraPoints
	local message = {}

	local function currentUnlocked(i)
		if passive >= 1000 and i == 3 then
			return true
		elseif passive >= 500 and passive < 1000 and i == 2 then
			return true
		elseif passive >= 250 and passive < 500 and i == 1 then
			return true
		else
			return false
		end
	end

	local m1 = ""
	local m2 = ""
	local vocation = WheelOfDestiny.vocationId

	if domain == 1 then
		setStringColor(message, "If an attack (except with agony damage) were to kill you but the\noverkill damage amounts to less than ", "#3F3F3F")
		setStringColor(message, "20%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "25%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "30% ", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "of your\nmaximum hit points, you will heal yourself for ", "#3F3F3F")
		setStringColor(message, "20%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "25%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "30% ", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
		setStringColor(message, " of\nyour maximum hit points and mana. Only after that is the damage\napplied. In addition, all your spell cooldowns are reduced by 60\nseconds.\n\nCooldown: ", "#3F3F3F")
		setStringColor(message, "30h", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "20h", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "10h ", currentUnlocked(3) and "#ffffff" or "#3F3F3F")

		m1 = "Gift of Life\nAllows you to survive an\notherwise fatal blow."
		m2 = message
	elseif domain == 2 then
		if vocation == KNIGHT then
			m1 = "Executioner's Throw\nThrowing attack that deals\nmassive damage to enemies\nwith low hit points."

			setStringColor(message, "This spell throws your weapon on your target and jumps on ", "#3F3F3F")
			setStringColor(message, "2", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "3", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "4\n ", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "nearby enemies. Deals ", "#3F3F3F")
			setStringColor(message, "100%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "125%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "150%  ", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "additional damage to\ntargets with less than 30% of their hit points.\nCooldown: ", "#3F3F3F")
			setStringColor(message, "18", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "14", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "10", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " seconds", "#3F3F3F")

			m2 = message
		elseif vocation == PALADIN then
			setStringColor(message, "This spell plants a marker at the feet of your target that explodes\nafter 3 seconds, dealing holy damage. +16% Base Damage with\nhigher spell stages.\n\nCooldown: ", "#3F3F3F")
			setStringColor(message, "26", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "20", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "14", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " seconds", "#3F3F3F")

			m1 = "Divine Grenade\nDeploy a powerful delayed\neffect that deals holy damage."
			m2 = message
		elseif vocation == SORCERER then
			setStringColor(message, "This beam spell deals death damage. Damage and length increase\nwith higher spell stages.\nCooldown: ", "#3F3F3F")
			setStringColor(message, "10", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "8", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "6", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " seconds\n\nIn addition, for each target hit by a beam spell, the cooldown of all\nother spells is reduced by 1 sec (up to a maximum of 3 sec) and\nthe damage of beam spells is increased by ", "#3F3F3F")
			setStringColor(message, "10%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "12%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "14%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " (up to\na maximum of ", "#3F3F3F")
			setStringColor(message, "30%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "36%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "42%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, ").\nBeam spells also hit adjacent squares for ", "#3F3F3F")
			setStringColor(message, "40%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "60%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "80%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " of the\ninitial damage.", "#3F3F3F")

			m1 = "Beam Mastery\nBoosts all of your beam spells\nand unlocks a beam spell that\ndeals death damage."
			m2 = message
		elseif vocation == DRUID then
			setStringColor(message, "Your healing spells can critically heal, using your critical hit\nchance and critical extra damage.\nYour healing is increased by ", "#3F3F3F")
			setStringColor(message, "5%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "7.5%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "10%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " if the target has less\nthan 60% of their hit points. This bonus is doubled if the target\nhas less than 30% of their hit points.", "#3F3F3F")

			m1 = "Blessing of the Grove\nIncreases your healing if the target's\nmissing hit points is below certain \nthresholds."
			m2 = message
		elseif vocation == MONK then
			setStringColor(message, "This spell consumes your Harmony. Releases a massive attack\nchaining to ", "#3F3F3F")
			setStringColor(message, "7", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " additional enemies. When used with full Harmony,\n", "#3F3F3F")
			setStringColor(message, "repeats after 1 second for ", "#3F3F3F")
			setStringColor(message, "37.5%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "50%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "62.5%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " of its original\ndamage. Cooldown: ", "#3F3F3F")
			setStringColor(message, "24", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "20", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "16", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " seconds.", "#3F3F3F")

			m1 = "Spiritual Outburst\nA powerful spell that consumes\nHarmony to release a massive\nchain attack."
			m2 = message
		end
	elseif domain == 3 then
		if vocation == KNIGHT then
			setStringColor(message, "You take 1% less damage for every ", "#3F3F3F")
			setStringColor(message, "12%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "10%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "8%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " of your missing\nhit points. This bonus is doubled while wielding a shield.\n", "#3F3F3F")
			setStringColor(message, "You deal 1% more damage for every ", "#3F3F3F")
			setStringColor(message, "12%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "10%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "8%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " of your target's\nmissing hit points. This bonus is doubled while wielding a\ntwo-handed weapon.", "#3F3F3F")

			m1 = "Combat Mastery\nImprove your combat\nprowess based on the\nequipment you use."
			m2 = message
		elseif vocation == PALADIN then
			setStringColor(message, "This support spell creates a field of holy energy around your feet\nfor 5 seconds. As long as you stand in this field, your dealt damage\nincreases by ", "#3F3F3F")
			setStringColor(message, "8%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "10%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "12%.\n\n", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "Cooldown: ", "#3F3F3F")
			setStringColor(message, "32", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "28", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "24", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "seconds", "#3F3F3F")

			m1 = "Divine Empowerment\nThis support spell creates a\nfield that increases your dealt\ndamage."
			m2 = message
		elseif vocation == SORCERER then
			setStringColor(message, "Improves the buffs provided by your elemental stances.\nMaster of Flames: fire spells gain +", "#3F3F3F")
			setStringColor(message, "2%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "3%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "4%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " base power.\nMaster of Thunder: energy spells gain +", "#3F3F3F")
			setStringColor(message, "2%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "3%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "4%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " critical hit chance.\nMaster of Decay: death spells gain +", "#3F3F3F")
			setStringColor(message, "15%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "22.5%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "30%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " critical extra\ndamage.", "#3F3F3F")

			m1 = "Lord of Destruction\nImproves the buffs provided\nby your elemental stances."
			m2 = message
		elseif vocation == DRUID then
			setStringColor(message, "Decide wisely whether you want to cast ice or earth damage in a\nsmall area around you, as these two ring spells share the same\ncooldown. Both spells deal ", "#3F3F3F")
			setStringColor(message, "20%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "40%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "60%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " additional damage to\ntargets with more than 60% of their hit points.\nCooldown: ", "#3F3F3F")
			setStringColor(message, "22", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "18", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "14", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " seconds", "#3F3F3F")

			m1 = "Twin Bursts\nPowerful ring spell that deals\nice or earth damage that is\nenhanced against targets with\nhigh hit points."
			m2 = message
		elseif vocation == MONK then
			setStringColor(message, "Increases the Harmony base bonus by ", "#3F3F3F")
			setStringColor(message, "1%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "2%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "3%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " and your\nautoattacks deal additional damage equal to ", "#3F3F3F")
			setStringColor(message, "100%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "200%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
			setStringColor(message, "/", "#3F3F3F")
			setStringColor(message, "300%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
			setStringColor(message, " of\nyour mantra.", "#3F3F3F")

			m1 = "Ascetic\nImprove all spenders and allows\nmantra to improve the damage\nof your attacks."
			m2 = message
		end
	elseif domain == 4 then
		setStringColor(message, "This spell transforms yourself into a powerful avatar for 15 \nseconds.\nWhile in this form, you benefit from ", "#3F3F3F")
		setStringColor(message, "5%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "10%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "15%", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
		setStringColor(message, " damage \nreduction and all your attacks are critical hits with ", "#3F3F3F")
		setStringColor(message, "5%", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "10%", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "15%\n", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "critical extra damage.\nCooldown: ", "#3F3F3F")
		setStringColor(message, "120", currentUnlocked(1) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "90", currentUnlocked(2) and "#ffffff" or "#3F3F3F")
		setStringColor(message, "/", "#3F3F3F")
		setStringColor(message, "60", currentUnlocked(3) and "#ffffff" or "#3F3F3F")
		setStringColor(message, " minutes", "#3F3F3F")

		if vocation == KNIGHT then
			m1 = "Avatar of Steel\nTransforms you into a\npowerful form that reduces\ndamage taken and increases\ndamage dealt."
			m2 = message
		elseif vocation == PALADIN then
			m1 = "Avatar of Light\nTransforms you into a\npowerful form that reduces\ndamage taken and increases\ndamage dealt."
			m2 = message
		elseif vocation == SORCERER then
			m1 = "Avatar of Storm\nTransforms you into a\npowerful form that reduces\ndamage taken and increases\ndamage dealt."
			m2 = message
		elseif vocation == DRUID then
			m1 = "Avatar of Nature\nTransforms you into a\npowerful form that reduces\ndamage taken and increases\ndamage dealt."
			m2 = message
		elseif vocation == MONK then
			m1 = "Avatar of Balance\nTransforms you into a\npowerful form that reduces\ndamage taken and increases\ndamage dealt."
			m2 = message
		end
	end

	return m1, m2
end

function getRevelationDisplayName(domain)
	local title = select(1, getPassiveInfo(domain))

	return title:match("^([^\n]+)") or title
end

function getBonusValueUpgrade(currentBonusID, gemID, supreme, firstBonus)
	local gem = GemAtelier.getGemDataById(gemID)

	if not gem then
		return 0
	end

	local slot = 0

	if supreme then
		slot = 2
	elseif gem.lesserBonus == currentBonusID then
		slot = 0
	elseif gem.regularBonus == currentBonusID then
		slot = 1
	end

	local effectiveLevel = GemAtelier.getEffectiveLevel(gem, currentBonusID, supreme, slot)
	local modInfo = Workshop.getDataByBonus(currentBonusID, supreme)

	return (Workshop.getBonusValue(modInfo, effectiveLevel, firstBonus))
end

function getValueByVocation(bonusType, steps)
	local step = bonusStep[WheelOfDestiny.vocationId]
	local bonus = 0

	if bonusType == "mana" then
		bonus = steps * step.mana
	elseif bonusType == "life" then
		bonus = steps * step.life
	elseif bonusType == "capacity" then
		bonus = steps * step.capacity
	end

	return bonus
end

local CRITICAL_BONUS_ICON = "/images/game/wheel/icon-crit"
local SPELL_DAMAGE_BONUS_ICON = "/images/game/wheel/icon-spelldamage"
local VESSEL_RESONANCE_TOOLTIP = "If the Vessel Resonance matches the gem quality in this domain, a\nbonus of +1 to all damage and healing is granted. This bonus is\nincreased by 1 for greater gems.\n\nRegardless of the match, gems will always grant mod bonuses\nbased on the Vessel Resonance.\n- Lesser gems match Dormant Vessels (VR I)\n- Regular gems match Awakened Vessels (VR II)\n- Greater gems match Radiant Vessels (VR III)"
local COOLDOWN_MOMENTUM_TOOLTIP = "Increasing the mod grade of cooldown augmentations does not\nfurther reduce the cooldown of spells, but adds a chance to gain\nMomentum that is additive to other chances of gaining Momentum."
local STAT_BONUS_PRIORITIES = {
	["Hit Points"] = 40,
	Capacity = 42,
	Mana = 41
}

local function formatVesselBonusAmount(format, amount)
	if format == "integer" then
		return formatWheelPlusInteger(amount)
	elseif format == "fixedPercent" then
		return formatWheelFixedPercent(amount)
	elseif format == "seconds" then
		return string.format("%ds", amount)
	end

	return formatWheelSignedPercent(amount)
end

function getVesselBonus()
	local defenses = {}

	local function accumulateVesselBonus(bonusKey, bonusDefinition, amount)
		local accumulatedBonus = defenses[bonusKey]

		if not accumulatedBonus then
			accumulatedBonus = bonusDefinition
			accumulatedBonus.amount = 0
			defenses[bonusKey] = accumulatedBonus
		end

		accumulatedBonus.amount = accumulatedBonus.amount + (tonumber(amount) or 0)
	end

	for _, k in pairs(WheelOfDestiny.equipedGemBonuses) do
		local bonus = k.supreme and SupremeGemDescription[k.bonusID] or RegularGemDescription[k.bonusID]

		if k.bonusID == -1 or not bonus then
			-- block empty
		else
			local text = bonus.text
			local skipIndex = text:find("\n")
			local firstDescriptionLine = skipIndex and text:sub(1, skipIndex - 1) or text
			local secondDescriptionLine = skipIndex and text:sub(skipIndex + 1) or nil

			if not k.supreme then
				for lineIndex = 1, 2 do
					local descriptionLine = lineIndex == 1 and firstDescriptionLine or secondDescriptionLine
					local bonusType = lineIndex == 1 and bonus.type1 or bonus.type2

					if descriptionLine and bonusType then
						local number = getBonusValueUpgrade(k.bonusID, k.gemID, false, lineIndex == 1)

						if bonusType == "mitigation" then
							accumulateVesselBonus("mitigation", {
								format = "fixedPercent",
								bonusType = "mitigation",
								priority = 43,
								text = "Mitigation Mult.",
								tooltip = bonus.tooltip
							}, number)
						elseif bonusType == "defense" then
							local resistanceDescription = descriptionLine

							if lineIndex == 2 and bonus.bonus2 == -1 then
								local unusedValue
								local percentText

								percentText, resistanceDescription = descriptionLine:match("([-]?%d+%.?%d*)%% (.+)")
								number = tonumber(percentText) or 0
							end

							local resistanceName = (resistanceDescription or descriptionLine):gsub(" Resistance$", "")

							accumulateVesselBonus("defense." .. resistanceName, {
								bonusType = "defense",
								indent = true,
								priority = 50,
								text = resistanceName
							}, number)
						else
							local statName = descriptionLine:match("[@#]%s*(.+)") or descriptionLine

							accumulateVesselBonus("stat." .. statName, {
								format = "integer",
								bonusType = bonusType,
								text = statName,
								priority = STAT_BONUS_PRIORITIES[statName] or 44
							}, number)
						end
					end
				end
			elseif text:find("^RM ") then
				accumulateVesselBonus("rm." .. text, {
					format = "integer",
					bonusType = "revelation",
					priority = 10,
					text = text,
					tooltip = bonus.tooltip
				}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
			elseif not secondDescriptionLine then
				local specialBonusName = firstDescriptionLine:match("%%%s+(.+)$") or firstDescriptionLine

				accumulateVesselBonus("flat." .. specialBonusName, {
					bonusType = "special",
					priority = 30,
					text = specialBonusName
				}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
			else
				local spellName = firstDescriptionLine:gsub("^Aug%.%s*", "")

				if secondDescriptionLine:find("Cooldown") then
					local numericValue = tonumber(secondDescriptionLine:match("(%-?%d+)s")) or 0

					accumulateVesselBonus("cooldown." .. spellName, {
						format = "seconds",
						bonusType = "augment",
						priority = 20,
						text = spellName,
						tooltip = secondDescriptionLine
					}, numericValue)

					local momentumChance = getBonusValueUpgrade(k.bonusID, k.gemID, true, true)

					if momentumChance > 0 then
						accumulateVesselBonus("momentum", {
							bonusType = "momentum",
							text = "Momentum",
							priority = 5,
							tooltip = COOLDOWN_MOMENTUM_TOOLTIP
						}, momentumChance)
					end
				else
					local augmentationIcon = secondDescriptionLine:find("Critical") and CRITICAL_BONUS_ICON or SPELL_DAMAGE_BONUS_ICON

					accumulateVesselBonus("augment." .. augmentationIcon .. spellName, {
						bonusType = "augment",
						priority = 20,
						text = spellName,
						icon = augmentationIcon,
						tooltipFormat = bonus.tooltip
					}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
				end
			end
		end
	end

	local bonuses = {}

	for _, v in pairs(defenses) do
		if v.amount ~= 0 or v.bonusType ~= "defense" then
			v.value = formatVesselBonusAmount(v.format, v.amount)

			if v.tooltipFormat and v.tooltipFormat:find("%%") then
				v.tooltip = tr(v.tooltipFormat, v.amount)
			end

			table.insert(bonuses, v)
		end
	end

	table.sort(bonuses, function(leftBonus, rightBonus)
		if leftBonus.priority ~= rightBonus.priority then
			return leftBonus.priority < rightBonus.priority
		end

		if leftBonus.text ~= rightBonus.text then
			return leftBonus.text < rightBonus.text
		end

		return (leftBonus.icon or "") > (rightBonus.icon or "")
	end)

	for index, bonuse in ipairs(bonuses) do
		if bonuse.priority == 50 then
			table.insert(bonuses, index, {
				bonusType = "defense",
				value = -1,
				text = "Resistances:",
				priority = 50
			})

			break
		end
	end

	local DHcount = GemAtelier:getDamageAndHealing()

	if DHcount > 0 then
		table.insert(bonuses, 1, {
			bonusType = "damagehealing",
			priority = 0,
			text = "Damage and Healing",
			value = "+" .. DHcount,
			tooltip = VESSEL_RESONANCE_TOOLTIP
		})
	end

	return bonuses
end
