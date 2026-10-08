local function var_0_0(attribute)
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

local var_0_2 = "#c0c0c0"
local var_0_3 = "#707070"

function formatWheelPercent(numericValue, arg_3_1)
	numericValue = tonumber(numericValue) or 0

	local formattedText

	if math.abs(numericValue - math.floor(numericValue + 1e-09)) < 1e-09 then
		formattedText = string.format("%d", math.floor(numericValue + 1e-09))
	else
		formattedText = string.format("%.2f", numericValue):gsub("(%..-)0+$", "%1"):gsub("%.$", "")
	end

	if arg_3_1 then
		return string.format("+%s%%", formattedText)
	end

	return formattedText .. "%"
end

function formatWheelPlusInteger(arg_4_0)
	arg_4_0 = math.floor((tonumber(arg_4_0) or 0) + 0.5)

	return (arg_4_0 < 0 and "-" or "+") .. comma_value(math.abs(arg_4_0))
end

function formatWheelSignedPercent(numericValue)
	numericValue = tonumber(numericValue) or 0

	return (numericValue < 0 and "-" or "+") .. formatWheelPercent(math.abs(numericValue))
end

function formatWheelFixedPercent(numericValue, arg_6_1)
	numericValue = tonumber(numericValue) or 0

	local formattedText = string.format("%.2f%%", math.abs(numericValue))

	if numericValue < 0 then
		return "-" .. formattedText
	end

	return (arg_6_1 and "+" or "") .. formattedText
end

local function var_0_4(arg_7_0)
	if type(arg_7_0) ~= "string" then
		return ""
	end

	return arg_7_0:gsub("\n+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function var_0_5(arg_8_0, arg_8_1)
	if type(arg_8_0) == "string" then
		return arg_8_0
	end

	if type(arg_8_1) == "string" then
		return arg_8_1
	end

	return ""
end

local function var_0_6(arg_9_0, arg_9_1, arg_9_2)
	local var_9_0 = var_0_4(arg_9_2)
	local var_9_1 = arg_9_1 and var_0_2 or var_0_3

	return {
		prefix = string.format("{icon:icon-augmentation-%d-%s}{: , %s}", arg_9_0, arg_9_1 and "active" or "inactive", var_0_2),
		text = string.format("{%s, %s}", var_9_0, var_9_1)
	}
end

local function var_0_7(arg_10_0, arg_10_1)
	local var_10_0 = arg_10_1 and var_0_2 or var_0_3

	return string.format("{%s, %s}", var_0_4(arg_10_0), var_10_0)
end

local function var_0_8(arg_11_0, arg_11_1, arg_11_2, arg_11_3)
	local var_11_0 = {
		var_0_6(1, arg_11_1, arg_11_0)
	}

	if arg_11_2 and arg_11_2 ~= "" then
		var_11_0[#var_11_0 + 1] = var_0_6(2, arg_11_3, arg_11_2)
	end

	return var_11_0
end

local function var_0_9(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	return {
		name = var_0_7(arg_12_0, arg_12_5 <= arg_12_4),
		tiers = var_0_8(arg_12_1, var_0_0(arg_12_3), arg_12_2, secondSpellIsUnlocked(arg_12_3))
	}
end

local function var_0_10(arg_13_0)
	if type(arg_13_0) ~= "string" or arg_13_0 == "" then
		return "", ""
	end

	local var_13_0 = arg_13_0:find("\n", 1, true)

	if not var_13_0 then
		return arg_13_0, ""
	end

	return arg_13_0:sub(1, var_13_0 - 1), arg_13_0:sub(var_13_0 + 1)
end

local function var_0_11(arg_14_0)
	local var_14_0, var_14_1 = var_0_10(arg_14_0)

	return {
		name = var_14_0,
		body = var_14_1
	}
end

function getDedicationBonus(index)
	local bonus = WheelBonus[index - 1]
	local vocation = WheelOfDestiny.vocationId
	local points = WheelOfDestiny.pointInvested[index] or 0

	if not vocation or vocation == 0 then
		return
	end

	local var_15_3 = WheelConsts[bonus.dedication]
	local var_15_4 = 0

	if type(var_15_3) == "table" and var_15_3[vocation] then
		var_15_4 = var_15_3[vocation] or 0
	end

	local var_15_5 = DedicationBonusTexts[bonus.dedication]

	if not var_15_5 then
		return ""
	end

	if bonus.dedication == "mitigation" then
		return formatWheelPercent(points * var_15_3) .. var_15_5.percentSuffix
	elseif bonus.dedication == "lifemana" then
		return string.format(var_15_5, points * var_15_3.life[vocation], points * var_15_3.mana[vocation])
	end

	return string.format(var_15_5, points * var_15_4)
end

function getDedicationTooltip(index)
	local var_16_0 = WheelBonus[index - 1]
	local vocationId = WheelOfDestiny.vocationId

	if not vocationId or vocationId == 0 then
		return ""
	end

	local var_16_2 = WheelConsts[var_16_0.dedication]
	local var_16_3 = 0

	if type(var_16_2) == "table" and var_16_2[vocationId] then
		var_16_3 = var_16_2[vocationId] or 0
	end

	local var_16_4 = DedicationTooltipTexts[var_16_0.dedication]

	if not var_16_4 then
		return ""
	end

	if var_16_0.dedication == "mitigation" then
		return var_16_4.prefix .. formatWheelPercent(var_16_2) .. var_16_4.percentSuffix
	elseif var_16_0.dedication == "lifemana" then
		return string.format(var_16_4, var_16_2.life[vocationId], var_16_2.mana[vocationId])
	end

	return string.format(var_16_4, var_16_3)
end

function getConvictionBonusTooltip(index)
	local var_17_0 = WheelBonus[index - 1]
	local vocation = WheelOfDestiny.vocationId
	local order = WheelConsts[var_17_0.conviction]
	local conviction = var_17_0.conviction

	if conviction == "vessel" then
		local var_17_4 = ConvictionStaticTexts.vessel[var_17_0.domain]

		return var_17_4 and var_17_4.tooltip or ""
	elseif conviction == "special_1" or conviction == "special_2" then
		local var_17_5 = ConvictionSpecialTexts[conviction] and ConvictionSpecialTexts[conviction][vocation]

		return var_17_5 and (var_17_5.tooltip or var_17_5.body) or ""
	elseif ConvictionSpellTexts[conviction] then
		return buildSpellConvictionTooltip(conviction, vocation, order) or ""
	end

	return ""
end

function getConvictionBonus(index, fullMessage)
	local var_18_0 = getConvictionBonusParts(index, fullMessage)

	if not var_18_0.name or var_18_0.name == "" then
		return var_18_0.body or ""
	end

	if var_18_0.tiers and #var_18_0.tiers > 0 then
		local var_18_1 = ""

		for index, tier in ipairs(var_18_0.tiers) do
			if index > 1 then
				var_18_1 = var_18_1 .. "\n"
			end

			var_18_1 = var_18_1 .. tier.prefix .. tier.text
		end

		return var_18_0.name .. var_18_1
	end

	if var_18_0.body and var_18_0.body ~= "" then
		if var_18_0.name:find("{", 1, true) or var_18_0.body:find("{", 1, true) then
			return var_18_0.name .. var_18_0.body
		end

		return var_18_0.name .. "\n" .. var_18_0.body
	end

	return var_18_0.name
end

function getConvictionBonusParts(arg_19_0, arg_19_1)
	local var_19_0 = getConvictionBonusRaw(arg_19_0, arg_19_1)

	if type(var_19_0) == "table" and type(var_19_0.name) == "string" then
		if var_19_0.tiers then
			return {
				body = "",
				name = var_19_0.name,
				tiers = var_19_0.tiers
			}
		end

		return var_19_0
	end

	if type(var_19_0) ~= "string" then
		var_19_0 = ""
	end

	return var_0_11(var_19_0)
end

local function var_0_12(arg_20_0, arg_20_1, arg_20_2)
	local var_20_0 = ConvictionSpecialTexts[arg_20_0] and ConvictionSpecialTexts[arg_20_0][arg_20_1]

	if not var_20_0 then
		return ""
	end

	local var_20_1 = arg_20_2 and var_20_0.body or var_20_0.bodyShort or var_20_0.body

	return var_0_5(var_20_0.name) .. "\n" .. var_0_5(var_20_1)
end

function getSpellConvictionTextEntry(arg_21_0, arg_21_1)
	return ConvictionSpellTexts[arg_21_0] and ConvictionSpellTexts[arg_21_0][arg_21_1] or nil
end

local var_0_13 = "•"

function buildSpellConvictionTooltip(arg_22_0, arg_22_1, unusedArgument)
	local var_22_0 = getSpellConvictionTextEntry(arg_22_0, arg_22_1)

	if not var_22_0 then
		return nil
	end

	local var_22_1 = {}
	local var_22_2 = var_22_0.tiers or {}

	for index, entry in ipairs(var_22_2) do
		if type(entry) ~= "string" then
			-- block empty
		else
			setStringColor(var_22_1, var_0_13, "white")

			local var_22_3 = index < #var_22_2 and "\n" or ""

			setStringColor(var_22_1, entry .. var_22_3, "#3F3F3F")
		end
	end

	return var_22_1
end

function getConvictionBonusRaw(arg_23_0, arg_23_1)
	local var_23_0 = WheelBonus[arg_23_0 - 1]

	if not var_23_0 then
		return ""
	end

	local vocationId = WheelOfDestiny.vocationId
	local var_23_2 = WheelOfDestiny.pointInvested[arg_23_0] or 0
	local var_23_3 = WheelConsts[var_23_0.conviction]
	local conviction = var_23_0.conviction

	if conviction == "vessel" then
		local var_23_5 = ConvictionStaticTexts.vessel[var_23_0.domain]

		if not var_23_5 then
			return ""
		end

		local var_23_6 = arg_23_1 and var_23_5.body or var_23_5.bodyShort

		return var_0_5(var_23_5.name) .. "\n" .. var_0_5(var_23_6)
	elseif conviction == "skill" then
		local var_23_7 = ConvictionStaticTexts.skill[vocationId]

		if not var_23_7 then
			return ""
		end

		return string.format(var_0_5(var_23_7.template), var_23_3)
	elseif conviction == "lifeleech" then
		return formatWheelPercent(var_23_3, true) .. " Life Leech"
	elseif conviction == "manaleech" then
		return formatWheelPercent(var_23_3, true) .. " Mana Leech"
	elseif ConvictionSpellTexts[conviction] then
		local var_23_8 = getSpellConvictionTextEntry(conviction, vocationId)

		if not var_23_8 then
			return ""
		end

		local tiers = var_23_8.tiers

		if type(tiers) ~= "table" then
			tiers = {}
		end

		return var_0_9(var_0_5(var_23_8.title, var_23_8.perk), var_0_5(tiers[1]), var_0_5(tiers[2]), var_23_3, var_23_2, var_23_0.maxPoints or 0)
	elseif conviction == "special_1" or conviction == "special_2" then
		return var_0_12(conviction, vocationId, arg_23_1)
	end

	return ""
end

local var_0_14 = {
	"I",
	"II",
	"III"
}

local function var_0_15(arg_24_0)
	return (arg_24_0 or ""):gsub("^Augmented%s+", ""):gsub("^Aug%.%s*", "")
end

function getConvictionPerks()
	local vocationId = WheelOfDestiny.vocationId
	local convictions = {}

	local function var_25_2(arg_26_0, arg_26_1)
		if not convictions[arg_26_0] then
			arg_26_1.points = 0
			convictions[arg_26_0] = arg_26_1
		end

		return convictions[arg_26_0]
	end

	for id, bonus in pairs(WheelBonus) do
		local index = id + 1

		if (WheelOfDestiny.pointInvested[index] or 0) < bonus.maxPoints then
			-- block empty
		else
			local conviction = bonus.conviction
			local var_25_5 = WheelConsts[conviction]

			if conviction == "special_1" or conviction == "special_2" then
				local var_25_6 = ConvictionSpecialTexts[conviction] and ConvictionSpecialTexts[conviction][vocationId]

				if var_25_6 then
					var_25_2(conviction, {
						priority = 0,
						names = {
							var_25_6.name
						},
						tooltip = var_25_6.tooltip or var_25_6.body
					})
				elseif var_25_5 and var_25_5[vocationId] then
					var_25_2(conviction, {
						priority = 0,
						names = {
							var_25_5[vocationId][1]
						},
						tooltip = var_25_5[vocationId][2]
					})
				end
			elseif conviction == "skill" then
				local var_25_7 = ConvictionStaticTexts.skill[vocationId]

				if var_25_7 then
					local var_25_8 = var_25_2(conviction, {
						priority = 0,
						names = {
							var_25_7.perk
						},
						tooltip = var_25_7.tooltip
					})

					var_25_8.points = var_25_8.points + var_25_5
					var_25_8.stringPoint = formatWheelPlusInteger(var_25_8.points)
				end
			elseif conviction == "lifeleech" or conviction == "manaleech" then
				local var_25_9 = conviction == "lifeleech" and "Life Leech" or "Mana Leech"
				local var_25_10 = var_25_2(conviction, {
					priority = 4,
					names = {
						var_25_9
					},
					order = conviction == "lifeleech" and 1 or 2
				})

				var_25_10.points = var_25_10.points + var_25_5
				var_25_10.stringPoint = formatWheelFixedPercent(var_25_10.points, true)
			elseif conviction == "vessel" then
				local var_25_11 = ConvictionStaticTexts.vessel[bonus.domain]

				if var_25_11 then
					local var_25_12 = var_25_2("vessel." .. bonus.domain, {
						priority = 4,
						names = {
							var_25_11.name,
							var_25_11.perk
						},
						order = 10 + bonus.domain,
						tooltip = var_25_11.tooltip
					})

					var_25_12.points = var_25_12.points + 1
					var_25_12.stringPoint = var_0_14[math.min(var_25_12.points, 3)]
				end
			elseif ConvictionSpellTexts[conviction] then
				local var_25_13 = getSpellConvictionTextEntry(conviction, vocationId)

				if var_25_13 then
					local var_25_14 = var_0_15(var_25_13.title or var_25_13.perk)
					local var_25_15 = var_25_2(conviction, {
						priority = 1,
						names = {
							"Augmented " .. var_25_14,
							"Aug. " .. var_25_14
						},
						tooltip = buildSpellConvictionTooltip(conviction, vocationId, var_25_5)
					})

					var_25_15.points = var_25_15.points + 1
					var_25_15.stringPoint = var_0_14[math.min(var_25_15.points, 2)]
				end
			end
		end
	end

	local var_25_16 = {}

	for unusedValue, conviction in pairs(convictions) do
		conviction.perk = conviction.names[#conviction.names]

		table.insert(var_25_16, conviction)
	end

	table.sort(var_25_16, function(arg_27_0, arg_27_1)
		if arg_27_0.priority ~= arg_27_1.priority then
			return arg_27_0.priority < arg_27_1.priority
		end

		if (arg_27_0.order or 0) ~= (arg_27_1.order or 0) then
			return (arg_27_0.order or 0) < (arg_27_1.order or 0)
		end

		return arg_27_0.names[1] < arg_27_1.names[1]
	end)

	return var_25_16, convictions
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

local var_0_16 = "/images/game/wheel/icon-crit"
local var_0_17 = "/images/game/wheel/icon-spelldamage"
local var_0_18 = "If the Vessel Resonance matches the gem quality in this domain, a\nbonus of +1 to all damage and healing is granted. This bonus is\nincreased by 1 for greater gems.\n\nRegardless of the match, gems will always grant mod bonuses\nbased on the Vessel Resonance.\n- Lesser gems match Dormant Vessels (VR I)\n- Regular gems match Awakened Vessels (VR II)\n- Greater gems match Radiant Vessels (VR III)"
local var_0_19 = "Increasing the mod grade of cooldown augmentations does not\nfurther reduce the cooldown of spells, but adds a chance to gain\nMomentum that is additive to other chances of gaining Momentum."
local var_0_20 = {
	["Hit Points"] = 40,
	Capacity = 42,
	Mana = 41
}

local function var_0_21(arg_33_0, arg_33_1)
	if arg_33_0 == "integer" then
		return formatWheelPlusInteger(arg_33_1)
	elseif arg_33_0 == "fixedPercent" then
		return formatWheelFixedPercent(arg_33_1)
	elseif arg_33_0 == "seconds" then
		return string.format("%ds", arg_33_1)
	end

	return formatWheelSignedPercent(arg_33_1)
end

function getVesselBonus()
	local defenses = {}

	local function var_34_1(arg_35_0, arg_35_1, arg_35_2)
		local var_35_0 = defenses[arg_35_0]

		if not var_35_0 then
			var_35_0 = arg_35_1
			var_35_0.amount = 0
			defenses[arg_35_0] = var_35_0
		end

		var_35_0.amount = var_35_0.amount + (tonumber(arg_35_2) or 0)
	end

	for _, k in pairs(WheelOfDestiny.equipedGemBonuses) do
		local bonus = k.supreme and SupremeGemDescription[k.bonusID] or RegularGemDescription[k.bonusID]

		if k.bonusID == -1 or not bonus then
			-- block empty
		else
			local text = bonus.text
			local skipIndex = text:find("\n")
			local var_34_5 = skipIndex and text:sub(1, skipIndex - 1) or text
			local var_34_6 = skipIndex and text:sub(skipIndex + 1) or nil

			if not k.supreme then
				for iter_34_2 = 1, 2 do
					local var_34_7 = iter_34_2 == 1 and var_34_5 or var_34_6
					local var_34_8 = iter_34_2 == 1 and bonus.type1 or bonus.type2

					if var_34_7 and var_34_8 then
						local number = getBonusValueUpgrade(k.bonusID, k.gemID, false, iter_34_2 == 1)

						if var_34_8 == "mitigation" then
							var_34_1("mitigation", {
								format = "fixedPercent",
								bonusType = "mitigation",
								priority = 43,
								text = "Mitigation Mult.",
								tooltip = bonus.tooltip
							}, number)
						elseif var_34_8 == "defense" then
							local var_34_10 = var_34_7

							if iter_34_2 == 2 and bonus.bonus2 == -1 then
								local unusedValue
								local var_34_12

								var_34_12, var_34_10 = var_34_7:match("([-]?%d+%.?%d*)%% (.+)")
								number = tonumber(var_34_12) or 0
							end

							local var_34_13 = (var_34_10 or var_34_7):gsub(" Resistance$", "")

							var_34_1("defense." .. var_34_13, {
								bonusType = "defense",
								indent = true,
								priority = 50,
								text = var_34_13
							}, number)
						else
							local var_34_14 = var_34_7:match("[@#]%s*(.+)") or var_34_7

							var_34_1("stat." .. var_34_14, {
								format = "integer",
								bonusType = var_34_8,
								text = var_34_14,
								priority = var_0_20[var_34_14] or 44
							}, number)
						end
					end
				end
			elseif text:find("^RM ") then
				var_34_1("rm." .. text, {
					format = "integer",
					bonusType = "revelation",
					priority = 10,
					text = text,
					tooltip = bonus.tooltip
				}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
			elseif not var_34_6 then
				local var_34_15 = var_34_5:match("%%%s+(.+)$") or var_34_5

				var_34_1("flat." .. var_34_15, {
					bonusType = "special",
					priority = 30,
					text = var_34_15
				}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
			else
				local var_34_16 = var_34_5:gsub("^Aug%.%s*", "")

				if var_34_6:find("Cooldown") then
					local numericValue = tonumber(var_34_6:match("(%-?%d+)s")) or 0

					var_34_1("cooldown." .. var_34_16, {
						format = "seconds",
						bonusType = "augment",
						priority = 20,
						text = var_34_16,
						tooltip = var_34_6
					}, numericValue)

					local var_34_18 = getBonusValueUpgrade(k.bonusID, k.gemID, true, true)

					if var_34_18 > 0 then
						var_34_1("momentum", {
							bonusType = "momentum",
							text = "Momentum",
							priority = 5,
							tooltip = var_0_19
						}, var_34_18)
					end
				else
					local var_34_19 = var_34_6:find("Critical") and var_0_16 or var_0_17

					var_34_1("augment." .. var_34_19 .. var_34_16, {
						bonusType = "augment",
						priority = 20,
						text = var_34_16,
						icon = var_34_19,
						tooltipFormat = bonus.tooltip
					}, getBonusValueUpgrade(k.bonusID, k.gemID, true, true))
				end
			end
		end
	end

	local bonuses = {}

	for _, v in pairs(defenses) do
		if v.amount ~= 0 or v.bonusType ~= "defense" then
			v.value = var_0_21(v.format, v.amount)

			if v.tooltipFormat and v.tooltipFormat:find("%%") then
				v.tooltip = tr(v.tooltipFormat, v.amount)
			end

			table.insert(bonuses, v)
		end
	end

	table.sort(bonuses, function(arg_36_0, arg_36_1)
		if arg_36_0.priority ~= arg_36_1.priority then
			return arg_36_0.priority < arg_36_1.priority
		end

		if arg_36_0.text ~= arg_36_1.text then
			return arg_36_0.text < arg_36_1.text
		end

		return (arg_36_0.icon or "") > (arg_36_1.icon or "")
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
			tooltip = var_0_18
		})
	end

	return bonuses
end
