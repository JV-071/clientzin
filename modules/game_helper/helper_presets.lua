HelperPresets = HelperPresets or {}

local var_0_0
local var_0_1 = {
	"sorcerer",
	"druid",
	"paladin",
	"knight",
	"sorcerer",
	"druid",
	"paladin",
	"knight",
	"monk",
	"monk"
}
local var_0_2 = {
	sorcerer = {
		{
			id = "ENERGY",
			stance = "Master of Thunder",
			label = "Energy"
		},
		{
			id = "FIRE",
			stance = "Master of Flames",
			label = "Fire"
		},
		{
			id = "DEATH",
			stance = "Master of Decay",
			label = "Death"
		}
	},
	druid = {
		{
			id = "ICE",
			label = "Ice"
		},
		{
			id = "EARTH",
			label = "Earth"
		}
	}
}
local var_0_3 = {
	"K",
	"P",
	"S",
	"D",
	"M",
	nil,
	nil,
	nil,
	nil,
	nil,
	"EK",
	"RP",
	"MS",
	"ED",
	"EM"
}
local var_0_4 = {
	paladin = "Paladin",
	druid = "Druid",
	sorcerer = "Sorcerer",
	monk = "Monk",
	knight = "Knight"
}

local function var_0_5(arg_1_0)
	if not HelperShooter or type(HelperShooter.isWheelSpellUnlocked) ~= "function" then
		return true
	end

	return HelperShooter.isWheelSpellUnlocked(arg_1_0) == true
end

local var_0_6 = {
	[59] = true,
	[121] = true,
	[23] = true,
	[173] = true,
	[19] = true,
	[120] = true,
	[240] = true,
	[22] = true,
	[260] = true,
	[287] = true,
	[43] = true,
	[289] = true,
	[294] = true,
	[13] = true,
	[178] = true
}
local var_0_7 = {
	knight = {
		{
			id = 261,
			hpMax = 30
		},
		{
			id = 59,
			creatures = 3
		},
		{
			id = 105,
			creatures = 2
		},
		{
			id = 106,
			creatures = 4
		},
		{
			id = 62,
			hpMin = 15
		},
		{
			creatures = 2,
			id = 80,
			retireAt = 90
		},
		{
			id = 61
		},
		{
			id = 107
		},
		{
			id = 271,
			retireAt = 35
		}
	},
	paladin = {
		{
			id = 124,
			creatures = 3
		},
		{
			creatures = 2,
			useTo = "bestTile",
			id = 258
		},
		{
			creatures = 2,
			useTo = "bestTile",
			id = 302
		},
		{
			creatures = 2,
			useTo = "bestTile",
			id = 303
		},
		{
			id = 57,
			hpMin = 15
		},
		{
			id = 122
		},
		{
			id = 111,
			retireAt = 90
		},
		{
			id = 270,
			retireAt = 23
		}
	},
	sorcerer = {
		{
			creatures = 5,
			id = 119,
			element = "ENERGY"
		},
		{
			creatures = 3,
			id = 23,
			element = "ENERGY"
		},
		{
			creatures = 3,
			id = 13,
			element = "ENERGY"
		},
		{
			id = 155,
			element = "ENERGY",
			hpMin = 15
		},
		{
			creatures = 2,
			id = 22,
			retireAt = 29,
			element = "ENERGY"
		},
		{
			id = 151,
			element = "ENERGY"
		},
		{
			id = 149,
			retireAt = 80,
			element = "ENERGY"
		},
		{
			id = 88,
			retireAt = 80,
			element = "ENERGY"
		},
		{
			creatures = 5,
			id = 24,
			element = "FIRE"
		},
		{
			creatures = 3,
			id = 240,
			element = "FIRE"
		},
		{
			id = 154,
			element = "FIRE",
			hpMin = 15
		},
		{
			creatures = 3,
			id = 19,
			retireAt = 38,
			element = "FIRE"
		},
		{
			id = 150,
			element = "FIRE"
		},
		{
			id = 89,
			retireAt = 70,
			element = "FIRE"
		},
		{
			creatures = 3,
			id = 178,
			retireAt = 18,
			element = "FIRE"
		},
		{
			id = 169,
			retireAt = 14,
			element = "FIRE"
		},
		{
			creatures = 3,
			id = 260,
			element = "DEATH"
		},
		{
			creatures = 2,
			useTo = "bestTile",
			id = 310,
			element = "DEATH"
		},
		{
			id = 87,
			element = "DEATH"
		},
		{
			id = 177,
			retireAt = 12
		}
	},
	druid = {
		{
			creatures = 5,
			id = 118,
			element = "ICE"
		},
		{
			creatures = 3,
			id = 43,
			element = "ICE"
		},
		{
			creatures = 3,
			id = 263,
			element = "ICE"
		},
		{
			creatures = 2,
			id = 317,
			element = "ICE"
		},
		{
			id = 156,
			element = "ICE",
			hpMin = 15
		},
		{
			creatures = 3,
			id = 121,
			retireAt = 40,
			element = "ICE"
		},
		{
			id = 152,
			element = "ICE"
		},
		{
			id = 112,
			retireAt = 80,
			element = "ICE"
		},
		{
			creatures = 3,
			id = 173,
			retireAt = 18,
			element = "ICE"
		},
		{
			creatures = 5,
			id = 56,
			element = "EARTH"
		},
		{
			creatures = 3,
			id = 120,
			element = "EARTH"
		},
		{
			creatures = 3,
			id = 262,
			element = "EARTH"
		},
		{
			creatures = 2,
			id = 318,
			element = "EARTH"
		},
		{
			id = 157,
			element = "EARTH",
			hpMin = 15
		},
		{
			id = 153,
			element = "EARTH"
		},
		{
			id = 113,
			retireAt = 70,
			element = "EARTH"
		},
		{
			id = 88,
			retireAt = 15
		},
		{
			id = 172,
			retireAt = 13
		},
		{
			id = 169,
			retireAt = 12
		}
	},
	monk = {
		{
			id = 294,
			creatures = 3,
			harmony = 5
		},
		{
			id = 293,
			harmony = 5,
			hpMin = 15
		},
		{
			id = 292,
			retireAt = 125,
			harmony = 5
		},
		{
			id = 295,
			harmony = 5,
			hpMin = 15
		},
		{
			id = 291,
			retireAt = 18,
			harmony = 5
		},
		{
			id = 289,
			creatures = 3
		},
		{
			creatures = 3,
			id = 287,
			retireAt = 90
		},
		{
			id = 286,
			hpMin = 15
		},
		{
			creatures = 2,
			useTo = "bestTile",
			id = 301
		},
		{
			id = 288
		},
		{
			id = 290,
			retireAt = 70
		},
		{
			id = 285
		},
		{
			id = 284,
			retireAt = 14
		}
	}
}
local var_0_8 = {
	sorcerer = {
		{
			id = 3155,
			hpMin = 20
		},
		{
			creatures = 3,
			useTo = "bestTile",
			id = 3191,
			element = "FIRE"
		},
		{
			creatures = 3,
			useTo = "bestTile",
			id = 3202,
			element = "ENERGY"
		}
	},
	druid = {
		{
			id = 3158,
			element = "ICE",
			hpMin = 20
		},
		{
			creatures = 3,
			useTo = "bestTile",
			id = 3161,
			element = "ICE"
		},
		{
			creatures = 3,
			useTo = "bestTile",
			id = 3175,
			element = "EARTH"
		}
	},
	paladin = {
		{
			id = 3182,
			hpMin = 20
		},
		{
			creatures = 3,
			useTo = "bestTile",
			id = 3161
		}
	},
	knight = {},
	monk = {}
}
local var_0_9 = {
	sorcerer = {
		174,
		1,
		2,
		3,
		241
	},
	druid = {
		174,
		1,
		2,
		3,
		241
	},
	paladin = {
		174,
		1,
		2,
		125,
		36
	},
	knight = {
		175,
		123,
		158,
		239
	},
	monk = {
		174,
		1,
		2,
		273
	}
}
local var_0_10 = {
	sorcerer = {
		hp = 40,
		topUp = 90,
		main = 70,
		mp = 60
	},
	druid = {
		hp = 40,
		topUp = 90,
		main = 70,
		mp = 60
	},
	paladin = {
		hp = 45,
		topUp = 90,
		main = 70,
		spiritMp = 40,
		mp = 55
	},
	knight = {
		hp = 70,
		topUp = 85,
		main = 60,
		mp = 40
	},
	monk = {
		hp = 45,
		topUp = 90,
		main = 70,
		spiritMp = 40,
		mp = 55
	}
}
local var_0_11
local var_0_12 = {
	{
		id = 7876,
		level = 1,
		vocations = var_0_11
	},
	{
		id = 266,
		level = 1,
		vocations = var_0_11
	},
	{
		id = 236,
		level = 50,
		vocations = {
			paladin = true,
			monk = true,
			knight = true
		}
	},
	{
		id = 239,
		level = 80,
		vocations = {
			knight = true
		}
	},
	{
		id = 7643,
		level = 130,
		vocations = {
			knight = true
		}
	},
	{
		id = 23375,
		level = 200,
		vocations = {
			knight = true
		}
	}
}
local var_0_13 = {
	{
		id = 7642,
		level = 80,
		vocations = {
			paladin = true,
			monk = true
		}
	},
	{
		id = 23374,
		level = 130,
		vocations = {
			paladin = true,
			monk = true
		}
	}
}
local var_0_14 = {
	{
		id = 268,
		level = 1,
		vocations = var_0_11
	},
	{
		id = 237,
		level = 50,
		vocations = var_0_11
	},
	{
		id = 238,
		level = 80,
		vocations = var_0_11
	},
	{
		id = 53163,
		level = 130,
		vocations = var_0_11
	},
	{
		id = 53162,
		level = 100,
		vocations = {
			paladin = true,
			druid = true,
			monk = true,
			sorcerer = true
		}
	},
	{
		id = 53164,
		level = 200,
		vocations = var_0_11
	},
	{
		id = 23373,
		level = 130,
		vocations = {
			sorcerer = true,
			druid = true
		}
	}
}
local var_0_15 = {
	knight = {
		distance = 7,
		mode = "chase",
		autoTargetMode = "A"
	},
	monk = {
		distance = 7,
		mode = "chase",
		autoTargetMode = "A"
	},
	paladin = {
		distance = 7,
		mode = "stand",
		autoTargetMode = "A"
	},
	sorcerer = {
		distance = 7,
		mode = "stand",
		autoTargetMode = "A"
	},
	druid = {
		distance = 7,
		mode = "stand",
		autoTargetMode = "A"
	}
}
local var_0_16 = {
	knight = {
		stance = "Blood Rage"
	},
	paladin = {
		stance = "Sharpshooter"
	},
	sorcerer = {
		crippling = "Aura of Sapped Strength",
		elemental = "Master of Flames"
	},
	druid = {
		stance = "Elemental Synthesis"
	},
	monk = {
		virtue = "Virtue of Harmony"
	}
}
local var_0_17 = {
	en = {
		generated = "Generated a %s preset for level %d into \"%s\": %d shooter entries, %d healing entries.",
		noPlayer = "Log in with a character before generating a preset.",
		empty = "Your level is too low to unlock any attack spell for this vocation yet.",
		noVocation = "This character has no vocation, so there is nothing to generate."
	},
	pt = {
		generated = "Preset de %s gerado para o level %d em \"%s\": %d entradas no Shooter, %d de cura.",
		noPlayer = "Entre com um personagem antes de gerar um preset.",
		empty = "Seu level ainda e baixo demais para liberar alguma magia de ataque desta vocacao.",
		noVocation = "Este personagem nao tem vocacao, entao nao ha o que gerar."
	}
}

local function var_0_18(arg_2_0)
	local var_2_0 = {}

	for key, entry in pairs(arg_2_0) do
		var_2_0[key] = entry
	end

	return var_2_0
end

local function var_0_19(arg_3_0)
	local language = var_0_0 and var_0_0.getLanguage and var_0_0.getLanguage() or "en"

	return (var_0_17[language] or var_0_17.en)[arg_3_0] or var_0_17.en[arg_3_0] or arg_3_0
end

local function var_0_20()
	return g_game and g_game.getLocalPlayer and g_game.getLocalPlayer() or nil
end

local var_0_21 = {
	4,
	3,
	1,
	2,
	9,
	nil,
	nil,
	nil,
	nil,
	nil,
	8,
	7,
	5,
	6,
	10
}

local function var_0_22(arg_5_0)
	arg_5_0 = arg_5_0 or var_0_20()

	if not arg_5_0 then
		return 0
	end

	local vocation = tonumber(arg_5_0:getVocation()) or 0

	if vocation <= 0 then
		return 0
	end

	local var_5_1 = var_0_21[vocation]

	if var_5_1 then
		return var_5_1
	end

	if type(translateVocation) == "function" then
		local var_5_2, var_5_3 = pcall(translateVocation, vocation)
		local numericValue

		numericValue = tonumber(var_5_3) or 0

		if var_5_2 and numericValue > 0 then
			return numericValue
		end
	end

	if var_0_0 and type(var_0_0.getPlayerVoc) == "function" then
		return tonumber(var_0_0.getPlayerVoc()) or 0
	end

	return 0
end

local function var_0_23(arg_6_0, arg_6_1)
	if type(arg_6_0.vocations) ~= "table" or not next(arg_6_0.vocations) then
		return true
	end

	for unusedValue, vocation in ipairs(arg_6_0.vocations) do
		if vocation == arg_6_1 then
			return true
		end
	end

	return false
end

local function var_0_24(arg_7_0, arg_7_1)
	return tonumber(arg_7_0.minLevel) or tonumber(arg_7_1.level) or 1
end

local function var_0_25(arg_8_0, arg_8_1)
	return arg_8_0.element == nil or arg_8_1 == nil or arg_8_0.element == arg_8_1
end

local var_0_26 = 4

local function var_0_27(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
	local var_9_0 = {}

	for unusedValue, entry in ipairs(var_0_7[arg_9_0] or {}) do
		local spellDataById = Spells.getSpellDataById(entry.id)

		if spellDataById and var_0_25(entry, arg_9_3) and var_0_23(spellDataById, arg_9_1) and arg_9_2 >= var_0_24(entry, spellDataById) and var_0_5(entry.id) and (not entry.retireAt or arg_9_2 < entry.retireAt) then
			table.insert(var_9_0, {
				rangeMax = 7,
				rangeMin = 1,
				enabled = true,
				type = "spell",
				forceCast = false,
				id = entry.id,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				creatures = tonumber(entry.creatures) or 1,
				useTo = entry.useTo or "target",
				harmony = spellDataById.useHarmony == true and (tonumber(entry.harmony) or 5) or nil,
				turnToCast = var_0_6[entry.id] == true
			})
		end
	end

	local var_9_2 = {}
	local var_9_3 = {}
	local var_9_4 = {}

	local function var_9_5(arg_10_0)
		local var_10_0 = {}

		for unusedValue, entry in ipairs(Spells.getGroupIds(Spells.getSpellDataById(arg_10_0.id)) or {}) do
			if entry ~= 1 then
				var_10_0[#var_10_0 + 1] = entry
			end
		end

		return var_10_0
	end

	local function var_9_6(arg_11_0)
		local var_11_0 = var_9_5(arg_11_0)

		if #var_11_0 == 0 then
			return not var_9_4[arg_11_0.creatures]
		end

		for unusedValue, entry in ipairs(var_11_0) do
			if var_9_3[entry] then
				return false
			end
		end

		return true
	end

	local function var_9_7(arg_12_0)
		local var_12_0 = var_9_5(arg_12_0)

		if #var_12_0 == 0 then
			var_9_4[arg_12_0.creatures] = true
		else
			for unusedValue, entry in ipairs(var_12_0) do
				var_9_3[entry] = true
			end
		end

		table.insert(var_9_2, arg_12_0)
	end

	local function var_9_8(arg_13_0)
		return arg_13_0.creatures == 1 and arg_13_0.hpMin == 0 and arg_13_0.hpMax == 100
	end

	for unusedValue, entry in ipairs(var_9_0) do
		if #var_9_2 >= var_0_26 - 1 then
			break
		end

		if var_9_6(entry) then
			var_9_7(entry)
		end
	end

	local var_9_9 = false

	for unusedValue, entry in ipairs(var_9_2) do
		if var_9_8(entry) then
			var_9_9 = true

			break
		end
	end

	if not var_9_9 then
		for unusedValue, entry in ipairs(var_9_0) do
			if entry.creatures == 1 and var_9_6(entry) then
				entry.hpMin, entry.hpMax = 0, 100

				var_9_7(entry)

				local unusedValue = true

				break
			end
		end
	end

	if #var_9_2 < var_0_26 then
		for unusedValue, entry in ipairs(var_9_0) do
			if #var_9_2 >= var_0_26 then
				break
			end

			local var_9_11 = false

			for iter_9_10, iter_9_11 in ipairs(var_9_2) do
				if iter_9_11 == entry then
					var_9_11 = true

					break
				end
			end

			if not var_9_11 and var_9_6(entry) then
				var_9_7(entry)
			end
		end
	end

	for unusedValue, entry in ipairs(var_0_8[arg_9_0] or {}) do
		local var_9_12 = SpellRunesData and SpellRunesData[entry.id]
		local spellDataById = var_9_12 and Spells.getSpellDataById(var_9_12.id)

		if spellDataById and var_0_25(entry, arg_9_3) and arg_9_2 >= (tonumber(spellDataById.level) or 1) then
			table.insert(var_9_2, {
				rangeMax = 7,
				rangeMin = 1,
				enabled = false,
				type = "rune",
				forceCast = false,
				id = entry.id,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				creatures = tonumber(entry.creatures) or 1,
				useTo = entry.useTo or "target"
			})
		end
	end

	local var_9_14
	local var_9_15
	local var_9_16 = false

	for unusedValue, entry in ipairs(var_9_2) do
		if entry.enabled and entry.type == "spell" then
			if entry.creatures == 1 and entry.hpMin == 0 and entry.hpMax == 100 then
				var_9_16 = true

				break
			end

			if entry.creatures == 1 then
				var_9_14 = entry
			end

			var_9_15 = entry
		end
	end

	local var_9_17 = not var_9_16 and (var_9_14 or var_9_15) or nil

	if var_9_17 then
		var_9_17.creatures = 1
		var_9_17.hpMin = 0
		var_9_17.hpMax = 100
	end

	return var_9_2
end

local function var_0_28(arg_14_0, arg_14_1)
	if HelperHealer and HelperHealer.potionAllowedForVocation then
		local var_14_0 = HelperHealer.potionAllowedForVocation(arg_14_0.id)

		if var_14_0 ~= nil then
			return var_14_0
		end
	end

	return arg_14_0.vocations == nil or arg_14_0.vocations[arg_14_1] == true
end

local function var_0_29(arg_15_0, arg_15_1, arg_15_2)
	local var_15_0

	for unusedValue, entry in ipairs(arg_15_0) do
		if arg_15_1 >= entry.level and var_0_28(entry, arg_15_2) then
			var_15_0 = entry
		end
	end

	return var_15_0 and var_15_0.id or nil
end

local function var_0_30(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	local var_16_0 = {
		conditionMax = "<=",
		enabled = true,
		thresholdMin = 1,
		conditionMin = ">=",
		conditionLogic = "and",
		id = arg_16_0,
		kind = arg_16_1,
		percent = arg_16_3,
		whenMetric1 = arg_16_2,
		whenMetric2 = arg_16_2,
		thresholdMax = arg_16_3
	}

	for key, entry in pairs(arg_16_4) do
		var_16_0[key] = entry
	end

	return var_16_0
end

local function var_0_31(arg_17_0, arg_17_1, arg_17_2)
	local var_17_0 = var_0_10[arg_17_0] or var_0_10.knight
	local var_17_1 = {}
	local var_17_2
	local var_17_3

	for unusedValue, entry in ipairs(var_0_9[arg_17_0] or {}) do
		local spellDataById = Spells.getSpellDataById(entry)

		if spellDataById and var_0_23(spellDataById, arg_17_1) and arg_17_2 >= (tonumber(spellDataById.level) or 1) and tostring(spellDataById.words or "") ~= "" then
			var_17_3 = var_17_2
			var_17_2 = spellDataById
		end
	end

	local var_17_5 = 1

	local function var_17_6(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
		table.insert(var_17_1, var_0_30(var_17_5, arg_18_0, arg_18_1, arg_18_2, arg_18_3))

		var_17_5 = var_17_5 + 1
	end

	if var_17_2 then
		var_17_6("spell", "HP", var_17_0.main, {
			words = var_17_2.words
		})
	end

	local var_17_7 = var_0_29(var_0_13, arg_17_2, arg_17_0)
	local var_17_8 = var_17_7 or var_0_29(var_0_12, arg_17_2, arg_17_0)

	if var_17_8 then
		var_17_6("potion", "HP", var_17_0.hp, {
			useType = "useOnSelf",
			itemId = var_17_8,
			spiritMetric = var_17_7 and "HP" or nil
		})
	end

	if var_17_3 then
		var_17_6("spell", "HP", var_17_0.topUp, {
			words = var_17_3.words
		})
	end

	if var_17_7 then
		var_17_6("potion", "MP", var_17_0.spiritMp or 40, {
			useType = "useOnSelf",
			spiritMetric = "MP",
			itemId = var_17_7
		})
	end

	local var_17_9 = var_0_29(var_0_14, arg_17_2, arg_17_0)

	if var_17_9 then
		var_17_6("potion", "MP", var_17_0.mp, {
			useType = "useOnSelf",
			itemId = var_17_9
		})
	end

	return var_17_1
end

local function var_0_32(arg_19_0, arg_19_1)
	local var_19_0 = var_0_15[arg_19_1] or var_0_15.knight

	arg_19_0.target = arg_19_0.target or {}
	arg_19_0.target.mode = var_19_0.mode
	arg_19_0.target.distance = var_19_0.distance
	arg_19_0.target.autoTargetMode = var_19_0.autoTargetMode
	arg_19_0.target.priorityList = arg_19_0.target.priorityList or {}
	arg_19_0.target.allCreatures = true
	arg_19_0.target.allCreaturesIndex = #arg_19_0.target.priorityList + 1
end

local function var_0_33(arg_20_0, arg_20_1, arg_20_2)
	arg_20_0.tools = arg_20_0.tools or {}

	local var_20_0

	for unusedValue, iter_20_1 in ipairs({
		6,
		39
	}) do
		local spellDataById = Spells.getSpellDataById(iter_20_1)

		if spellDataById and var_0_23(spellDataById, arg_20_1) and arg_20_2 >= (tonumber(spellDataById.level) or 1) then
			var_20_0 = spellDataById
		end
	end

	if not var_20_0 then
		return
	end

	arg_20_0.tools.autoHaste = true
	arg_20_0.tools.autoHasteSlot = {
		words = var_20_0.words
	}
end

local function var_0_34(arg_21_0, arg_21_1)
	if not HelperPosture or type(HelperPosture.setSelection) ~= "function" then
		return
	end

	local var_21_0 = var_0_16[arg_21_0]

	if type(var_21_0) ~= "table" then
		return
	end

	for unusedValue, entry in ipairs(var_0_2[arg_21_0] or {}) do
		if entry.id == arg_21_1 and entry.stance then
			var_21_0 = var_0_18(var_21_0)
			var_21_0.elemental = entry.stance
		end
	end

	for unusedValue, getGroup in ipairs(HelperPosture.getGroups()) do
		local var_21_1 = var_21_0[getGroup.key]

		if var_21_1 then
			for unusedValue, spell in ipairs(getGroup.spells) do
				if spell.name == var_21_1 then
					HelperPosture.setSelection(getGroup.key, spell.words, false)

					break
				end
			end
		end
	end
end

function HelperPresets.getProfileName(arg_22_0)
	local var_22_0 = var_0_20()

	if not var_22_0 then
		return nil
	end

	local vocation = tonumber(var_22_0:getVocation()) or 0
	local var_22_2 = var_0_22(var_22_0)

	if not var_0_1[var_22_2] then
		return nil
	end

	local var_22_3 = "Auto"
	local var_22_4 = var_0_3[vocation]

	if var_22_4 then
		var_22_3 = var_22_3 .. " " .. var_22_4
	end

	for unusedValue, entry in ipairs(var_0_2[var_0_1[var_22_2]] or {}) do
		if entry.id == arg_22_0 then
			var_22_3 = var_22_3 .. " " .. entry.label
		end
	end

	return var_22_3
end

function HelperPresets.getElementOptions()
	local var_23_0 = var_0_22()
	local var_23_1 = var_0_1[var_23_0]

	return var_23_1 and var_0_2[var_23_1] or nil
end

function HelperPresets.generate(arg_24_0)
	if not var_0_0 or type(var_0_0.collectConfig) ~= "function" or type(var_0_0.applyConfig) ~= "function" then
		return false, "Preset generator is not initialised."
	end

	local var_24_0 = var_0_20()

	if not var_24_0 then
		return false, var_0_19("noPlayer")
	end

	local var_24_1 = var_0_22(var_24_0)
	local var_24_2 = var_0_1[var_24_1]

	if not var_24_2 then
		return false, var_0_19("noVocation")
	end

	local level = tonumber(var_24_0:getLevel()) or 1
	local priorityList = var_0_27(var_24_2, var_24_1, level, arg_24_0)

	if #priorityList == 0 then
		return false, var_0_19("empty")
	end

	local var_24_5 = var_0_0.collectConfig()

	var_24_5.shooter = var_24_5.shooter or {}
	var_24_5.shooter.shooterProfiles = var_24_5.shooter.shooterProfiles or {}

	local selectedShooterProfile = var_24_5.shooter.selectedShooterProfile or "Default"

	var_24_5.shooter.selectedShooterProfile = selectedShooterProfile

	local var_24_7 = var_24_5.shooter.shooterProfiles[selectedShooterProfile]

	if type(var_24_7) ~= "table" then
		var_24_7 = {}
		var_24_5.shooter.shooterProfiles[selectedShooterProfile] = var_24_7
	end

	var_24_7.priorityList = priorityList
	var_24_7.spells = nil
	var_24_7.runes = nil

	local healingEntries = var_0_31(var_24_2, var_24_1, level)

	var_24_5.healingEntries = healingEntries
	var_24_5.healingSlots = nil

	var_0_32(var_24_5, var_24_2)
	var_0_33(var_24_5, var_24_1, level)
	var_0_0.applyConfig(var_24_5)
	var_0_34(var_24_2, arg_24_0)

	return true, string.format(var_0_19("generated"), var_0_4[var_24_2] or var_24_2, level, HelperPresets.getProfileName(arg_24_0) or "Auto", #priorityList, #healingEntries)
end

function HelperPresets.init(arg_25_0)
	var_0_0 = arg_25_0
end

function HelperPresets.terminate()
	var_0_0 = nil
end
