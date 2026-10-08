SpelllistSettings = {
	Default = {
		iconFile = "/images/game/spells/spell-icons-32x32",
		iconSize = {
			height = 32,
			width = 32
		}
	}
}
PassiveAbilities = {
	{
		exhaustion = 108000000,
		type = "Passive",
		name = "Gift of Life",
		icon = "/images/game/spells/passiveability-icons-32x32"
	}
}

function PassiveAbilityUnlockedInWheel(passiveId)
	if passiveId ~= 1 then
		return true
	end

	local WD = rawget(_G, "WheelOfDestiny")

	if type(WD) ~= "table" or not WD.passivePoints then
		return true
	end

	return (WD.passivePoints[1] or 0) >= 250
end

SpellAreas = {
	AREA_BEAM5 = {
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			3
		}
	},
	AREA_BEAM6 = {
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			3
		}
	},
	AREA_BEAM7 = {
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			3
		}
	},
	AREA_BEAM8 = {
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			1
		},
		{
			3
		}
	},
	AREA_WIDE_BEAM5 = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0,
			3,
			0
		}
	},
	AREA_WIDE_BEAM8 = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0,
			3,
			0
		}
	},
	AREA_SQUAREWAVE1 = {
		{
			1,
			1,
			1
		},
		{
			0,
			3,
			0
		}
	},
	AREA_SQUAREWAVE3 = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0,
			1,
			0
		},
		{
			0,
			3,
			0
		}
	},
	AREA_SQUAREWAVE4 = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0,
			1,
			0
		},
		{
			0,
			1,
			0
		},
		{
			0,
			3,
			0
		}
	},
	AREA_SQUAREWAVE5 = {
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			0,
			0
		},
		{
			0,
			0,
			3,
			0,
			0
		}
	},
	AREA_SQUAREWAVE6 = {
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			0,
			0
		},
		{
			0,
			0,
			3,
			0,
			0
		}
	},
	AREA_STRONG_ICE_WAVE = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0,
			1,
			0
		},
		{
			0,
			3,
			0
		}
	},
	AREA_AUGMENTED_FRONT_SWEEP = {
		{
			1,
			1,
			1
		},
		{
			1,
			3,
			1
		}
	},
	AREA_SQUARE2X2 = {
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			3,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		}
	},
	AREA_CIRCLE1X1 = {
		{
			1,
			1,
			1
		},
		{
			1,
			3,
			1
		},
		{
			1,
			1,
			1
		}
	},
	AREA_CIRCLE2X2 = {
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			3,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			0
		}
	},
	AREA_CIRCLE3X3 = {
		{
			0,
			0,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			3,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			0,
			0
		}
	},
	AREA_CIRCLE5X5 = {
		{
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1,
			3,
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0
		}
	},
	AREA_CIRCLE6X6 = {
		{
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			3,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0,
			0
		}
	},
	AREA_RING_BURST3 = {
		{
			0,
			0,
			0,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			0,
			0,
			0,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			0,
			3,
			0,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			0,
			0,
			0,
			1,
			1,
			1
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			0,
			0,
			0
		}
	},
	AREA_BURSTWAVE1 = {
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			3,
			1,
			1
		},
		{
			0,
			1,
			0,
			1,
			0
		}
	},
	AREA_FLURRYWAVE = {
		{
			0,
			0,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			3,
			1,
			0
		}
	},
	AREA_GREATER_FLURRYWAVE = {
		{
			0,
			0,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			0,
			1,
			3,
			1,
			0
		}
	},
	AREA_SHORTWAVE4 = {
		{
			0,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			3,
			1,
			1
		}
	},
	AREA_BALANCED_BRAWL = {
		{
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0
		},
		{
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0
		},
		{
			0,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			0
		},
		{
			1,
			1,
			1,
			1,
			1,
			0,
			3,
			0,
			1,
			1,
			1,
			1,
			1
		}
	},
	AREA_FORKS = {
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			3,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		{
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		}
	}
}
SpellInfo = {
	Default = {
		["Light Healing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Light Healing",
			soul = 0,
			mana = 20,
			level = 8,
			exhaustion = 1000,
			id = 1,
			words = "exura",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7,
				9,
				10
			}
		},
		["Intense Healing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Intense Healing",
			soul = 0,
			mana = 70,
			level = 20,
			exhaustion = 1000,
			id = 2,
			words = "exura gran",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7,
				9,
				10
			}
		},
		["Ultimate Healing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Ultimate Healing",
			soul = 0,
			mana = 160,
			level = 30,
			exhaustion = 1000,
			id = 3,
			words = "exura vita",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Intense Healing Rune"] = {
			id = 4,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Intense Healing Rune",
			soul = 2,
			mana = 120,
			maglevel = 1,
			exhaustion = 2000,
			words = "adura gran",
			type = "Conjure",
			source = 3147,
			level = 15,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Ultimate Healing Rune"] = {
			id = 5,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Ultimate Healing Rune",
			soul = 3,
			mana = 400,
			maglevel = 4,
			exhaustion = 2000,
			words = "adura vita",
			type = "Conjure",
			source = 3147,
			level = 24,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Haste = {
			id = 6,
			premium = true,
			duration = 33000,
			parameter = false,
			needTarget = false,
			name = "Haste",
			soul = 0,
			mana = 60,
			level = 14,
			exhaustion = 2000,
			range = 0,
			words = "utani hur",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Light Magic Missile"] = {
			id = 7,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Light Magic Missile",
			soul = 1,
			mana = 120,
			maglevel = 0,
			exhaustion = 2000,
			words = "adori min vis",
			type = "Conjure",
			source = 3147,
			level = 15,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Heavy Magic Missile"] = {
			id = 8,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Heavy Magic Missile",
			soul = 2,
			mana = 350,
			maglevel = 3,
			exhaustion = 2000,
			words = "adori vis",
			type = "Conjure",
			source = 3147,
			level = 25,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5,
				2,
				6
			}
		},
		["Summon Creature"] = {
			premium = false,
			range = 0,
			parameter = true,
			needTarget = false,
			name = "Summon Creature",
			soul = 0,
			mana = 0,
			level = 25,
			exhaustion = 2000,
			parameterPlaceholder = "creature",
			words = "utevo res",
			type = "Instant",
			id = 9,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		Light = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Light",
			soul = 0,
			mana = 20,
			level = 8,
			exhaustion = 2000,
			id = 10,
			words = "utevo lux",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Great Light"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Great Light",
			soul = 0,
			mana = 60,
			level = 13,
			exhaustion = 2000,
			id = 11,
			words = "utevo gran lux",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Convince Creature"] = {
			id = 12,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Convince Creature",
			soul = 3,
			mana = 200,
			maglevel = 5,
			exhaustion = 2000,
			words = "adeta sio",
			type = "Conjure",
			source = 3147,
			level = 16,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6,
				9,
				10
			}
		},
		["Energy Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Energy Wave",
			soul = 0,
			mana = 170,
			level = 38,
			exhaustion = 8000,
			premium = false,
			words = "exevo vis hur",
			type = "Instant",
			id = 13,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_SQUAREWAVE4
		},
		Chameleon = {
			id = 14,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Chameleon",
			soul = 2,
			mana = 600,
			maglevel = 4,
			exhaustion = 2000,
			words = "adevo ina",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Fireball = {
			id = 15,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fireball",
			soul = 3,
			mana = 460,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori flam",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Great Fireball"] = {
			id = 16,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Great Fireball",
			soul = 3,
			mana = 530,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori mas flam",
			type = "Conjure",
			source = 3147,
			level = 30,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		Firebomb = {
			id = 17,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fire Bomb Rune",
			soul = 4,
			mana = 600,
			maglevel = 5,
			exhaustion = 2000,
			words = "adevo mas flam",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		Explosion = {
			id = 18,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Explosion",
			soul = 4,
			mana = 570,
			maglevel = 6,
			exhaustion = 2000,
			words = "adevo mas hur",
			type = "Conjure",
			source = 3147,
			level = 31,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Fire Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fire Wave",
			soul = 0,
			mana = 25,
			level = 18,
			exhaustion = 3000,
			premium = false,
			words = "exevo flam hur",
			type = "Instant",
			id = 19,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_SQUAREWAVE5
		},
		["Find Person"] = {
			premium = false,
			range = 0,
			parameter = true,
			needTarget = false,
			name = "Find Person",
			soul = 0,
			mana = 20,
			level = 8,
			exhaustion = 2000,
			parameterPlaceholder = "name",
			words = "exiva",
			type = "Instant",
			id = 20,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Sudden Death"] = {
			id = 21,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Sudden Death",
			soul = 5,
			mana = 985,
			maglevel = 15,
			exhaustion = 2000,
			words = "adori gran mort",
			type = "Conjure",
			source = 3147,
			level = 45,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Energy Beam"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Energy Beam",
			soul = 0,
			mana = 40,
			level = 23,
			exhaustion = 4000,
			premium = false,
			words = "exevo vis lux",
			type = "Instant",
			id = 22,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_BEAM5
		},
		["Great Energy Beam"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Great Energy Beam",
			soul = 0,
			mana = 110,
			level = 29,
			exhaustion = 6000,
			premium = false,
			words = "exevo gran vis lux",
			type = "Instant",
			id = 23,
			group = {
				[1] = 2000,
				[9] = 6000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_BEAM8
		},
		["Hell's Core"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Hell's Core",
			soul = 0,
			mana = 1100,
			level = 60,
			exhaustion = 40000,
			id = 24,
			words = "exevo gran mas flam",
			type = "Instant",
			group = {
				[1] = 4000,
				[7] = 40000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_CIRCLE5X5
		},
		["Fire Field"] = {
			id = 25,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fire Field Rune",
			soul = 1,
			mana = 240,
			maglevel = 1,
			exhaustion = 2000,
			words = "adevo grav flam",
			type = "Conjure",
			source = 3147,
			level = 15,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Poison Field"] = {
			id = 26,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Poison Field Rune",
			soul = 1,
			mana = 200,
			maglevel = 0,
			exhaustion = 2000,
			words = "adevo grav pox",
			type = "Conjure",
			source = 3147,
			level = 14,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Energy Field"] = {
			id = 27,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Energy Field Rune",
			soul = 2,
			mana = 320,
			maglevel = 3,
			exhaustion = 2000,
			words = "adevo grav vis",
			type = "Conjure",
			source = 3147,
			level = 18,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Fire Wall"] = {
			id = 28,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fire Wall Rune",
			soul = 4,
			mana = 780,
			maglevel = 6,
			exhaustion = 2000,
			words = "adevo mas grav flam",
			type = "Conjure",
			source = 3147,
			level = 33,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Cure Poison"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Poison",
			soul = 0,
			mana = 30,
			level = 10,
			exhaustion = 6000,
			id = 29,
			words = "exana pox",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Destroy Field"] = {
			id = 30,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Destroy Field Rune",
			soul = 2,
			mana = 120,
			maglevel = 3,
			exhaustion = 2000,
			words = "adito grav",
			type = "Conjure",
			source = 3147,
			level = 17,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7,
				9,
				10
			}
		},
		["Cure Poison Rune"] = {
			id = 31,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Poison Rune",
			soul = 1,
			mana = 200,
			maglevel = 0,
			exhaustion = 2000,
			words = "adana pox",
			type = "Conjure",
			source = 3147,
			level = 15,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Poison Wall"] = {
			id = 32,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Poison Wall Rune",
			soul = 3,
			mana = 640,
			maglevel = 5,
			exhaustion = 2000,
			words = "adevo mas grav pox",
			type = "Conjure",
			source = 3147,
			level = 29,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Energy Wall"] = {
			id = 33,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Energy Wall Rune",
			soul = 5,
			mana = 1000,
			maglevel = 9,
			exhaustion = 2000,
			words = "adevo mas grav vis",
			type = "Conjure",
			source = 3147,
			level = 41,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		Salvation = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Salvation",
			soul = 0,
			mana = 210,
			level = 60,
			exhaustion = 1000,
			id = 36,
			words = "exura gran san",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				3,
				7
			}
		},
		["Creature Illusion"] = {
			premium = false,
			range = 0,
			parameter = true,
			needTarget = false,
			name = "Creature Illusion",
			soul = 0,
			mana = 100,
			level = 23,
			exhaustion = 2000,
			parameterPlaceholder = "creature",
			words = "utevo res ina",
			type = "Instant",
			id = 38,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Strong Haste"] = {
			id = 39,
			premium = true,
			duration = 22000,
			parameter = false,
			needTarget = false,
			name = "Strong Haste",
			soul = 0,
			mana = 100,
			level = 20,
			exhaustion = 2000,
			range = 0,
			words = "utani gran hur",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6,
				9,
				10
			}
		},
		Food = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Food",
			soul = 1,
			mana = 120,
			level = 0,
			exhaustion = 2000,
			id = 42,
			words = "exevo pan",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Strong Ice Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Strong Ice Wave",
			soul = 0,
			mana = 170,
			level = 40,
			exhaustion = 8000,
			premium = false,
			words = "exevo gran frigo hur",
			type = "Instant",
			id = 43,
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_STRONG_ICE_WAVE
		},
		["Magic Shield"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Magic Shield",
			soul = 0,
			mana = 50,
			level = 14,
			exhaustion = 14000,
			id = 44,
			words = "utamo vita",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		Invisibility = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Invisibility",
			soul = 0,
			mana = 440,
			level = 35,
			exhaustion = 2000,
			id = 45,
			words = "utana vid",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Conjure Explosive Arrow"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Conjure Explosive Arrow",
			soul = 3,
			mana = 290,
			level = 25,
			exhaustion = 2000,
			id = 49,
			words = "exevo con flam",
			type = "Conjure",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Soulfire = {
			id = 50,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Soulfire",
			soul = 3,
			mana = 420,
			maglevel = 7,
			exhaustion = 2000,
			words = "adevo res flam",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Blank Rune"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Blank Rune",
			soul = 1,
			mana = 50,
			level = 20,
			exhaustion = 2000,
			id = 320,
			words = "adori blank",
			type = "Conjure",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7
			}
		},
		["Conjure Arrow"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Conjure Arrow",
			soul = 1,
			mana = 100,
			level = 13,
			exhaustion = 2000,
			id = 51,
			words = "exevo con",
			type = "Conjure",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Paralyze = {
			id = 54,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Paralyze",
			soul = 3,
			mana = 1400,
			maglevel = 18,
			exhaustion = 2000,
			words = "adana ani",
			type = "Conjure",
			source = 3147,
			level = 54,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Energybomb = {
			id = 55,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Energy Bomb Rune",
			soul = 5,
			mana = 880,
			maglevel = 10,
			exhaustion = 2000,
			words = "adevo mas vis",
			type = "Conjure",
			source = 3147,
			level = 37,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Wrath of Nature"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Wrath of Nature",
			soul = 0,
			mana = 700,
			level = 55,
			exhaustion = 40000,
			id = 56,
			words = "exevo gran mas tera",
			type = "Instant",
			group = {
				[1] = 4000,
				[7] = 40000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_CIRCLE6X6
		},
		["Strong Ethereal Spear"] = {
			premium = true,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Strong Ethereal Spear",
			soul = 0,
			mana = 55,
			level = 90,
			exhaustion = 8000,
			id = 57,
			words = "exori gran con",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Front Sweep"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Front Sweep",
			soul = 0,
			mana = 200,
			level = 70,
			exhaustion = 6000,
			premium = true,
			words = "exori min",
			type = "Instant",
			id = 59,
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_SQUAREWAVE1
		},
		["Brutal Strike"] = {
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Brutal Strike",
			soul = 0,
			mana = 30,
			level = 16,
			exhaustion = 6000,
			id = 61,
			words = "exori ico",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		Annihilation = {
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Annihilation",
			soul = 0,
			mana = 300,
			level = 110,
			exhaustion = 30000,
			id = 62,
			words = "exori gran ico",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Ultimate Light"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Ultimate Light",
			soul = 0,
			mana = 140,
			level = 26,
			exhaustion = 2000,
			id = 75,
			words = "utevo vis lux",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Magic Rope"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Magic Rope",
			soul = 0,
			mana = 20,
			level = 9,
			exhaustion = 2000,
			id = 76,
			words = "exani tera",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		Stalagmite = {
			id = 77,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Stalagmite Rune",
			soul = 2,
			mana = 350,
			maglevel = 3,
			exhaustion = 2000,
			words = "adori tera",
			type = "Conjure",
			source = 3147,
			level = 24,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5,
				2,
				6
			}
		},
		Disintegrate = {
			id = 78,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Disintegrate Rune",
			soul = 3,
			mana = 200,
			maglevel = 4,
			exhaustion = 2000,
			words = "adito tera",
			type = "Conjure",
			source = 3147,
			level = 21,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7,
				9,
				10
			}
		},
		Berserk = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Berserk",
			soul = 0,
			mana = 115,
			level = 35,
			exhaustion = 4000,
			id = 80,
			words = "exori",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_CIRCLE1X1
		},
		Levitate = {
			premium = true,
			range = 0,
			parameter = true,
			needTarget = false,
			name = "Levitate",
			soul = 0,
			mana = 50,
			level = 12,
			exhaustion = 2000,
			parameterPlaceholder = "up|down",
			words = "exani hur",
			type = "Instant",
			id = 81,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Mass Healing"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Mass Healing",
			soul = 0,
			mana = 150,
			level = 36,
			exhaustion = 2000,
			id = 82,
			words = "exura gran mas res",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				6
			}
		},
		["Animate Dead"] = {
			id = 83,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Animate Dead",
			soul = 5,
			mana = 600,
			maglevel = 4,
			exhaustion = 2000,
			words = "adana mort",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Heal Friend"] = {
			premium = true,
			range = 7,
			parameter = true,
			needTarget = true,
			name = "Heal Friend",
			soul = 0,
			mana = 120,
			level = 18,
			exhaustion = 1000,
			parameterPlaceholder = "name",
			words = "exura sio",
			type = "Instant",
			id = 84,
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				6
			}
		},
		["Magic Wall"] = {
			id = 86,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Magic Wall Rune",
			soul = 5,
			mana = 750,
			maglevel = 9,
			exhaustion = 2000,
			words = "adevo grav tera",
			type = "Conjure",
			source = 3147,
			level = 32,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Death Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Death Strike",
			soul = 0,
			mana = 20,
			level = 16,
			exhaustion = 2000,
			id = 87,
			words = "exori mort",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Energy Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Energy Strike",
			soul = 0,
			mana = 20,
			level = 12,
			exhaustion = 2000,
			id = 88,
			words = "exori vis",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Flame Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Flame Strike",
			soul = 0,
			mana = 20,
			level = 14,
			exhaustion = 2000,
			id = 89,
			words = "exori flam",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Cancel Invisibility"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cancel Invisibility",
			soul = 0,
			mana = 200,
			level = 26,
			exhaustion = 2000,
			id = 90,
			words = "exana ina",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Poisonbomb = {
			id = 91,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Poison Bomb Rune",
			soul = 2,
			mana = 520,
			maglevel = 4,
			exhaustion = 2000,
			words = "adevo mas pox",
			type = "Conjure",
			source = 3147,
			level = 25,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Conjure Wand of Darkness"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Conjure Wand of Darkness",
			soul = 0,
			mana = 250,
			level = 41,
			exhaustion = 1200000,
			id = 92,
			words = "exevo gran mort",
			type = "Conjure",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		Challenge = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Challenge",
			soul = 0,
			mana = 30,
			level = 20,
			exhaustion = 2000,
			id = 93,
			words = "exeta res",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				8
			}
		},
		["Wild Growth"] = {
			id = 94,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Wild Growth",
			soul = 5,
			mana = 600,
			maglevel = 8,
			exhaustion = 0,
			words = "adevo grav vita",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Fierce Berserk"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fierce Berserk",
			soul = 0,
			mana = 340,
			level = 90,
			exhaustion = 6000,
			id = 105,
			words = "exori gran",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_CIRCLE1X1
		},
		Groundshaker = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Groundshaker",
			soul = 0,
			mana = 160,
			level = 33,
			exhaustion = 8000,
			id = 106,
			words = "exori mas",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_CIRCLE3X3
		},
		["Whirlwind Throw"] = {
			premium = true,
			range = 5,
			parameter = false,
			needTarget = true,
			name = "Whirlwind Throw",
			soul = 0,
			mana = 40,
			level = 28,
			exhaustion = 6000,
			id = 107,
			words = "exori hur",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Enchant Spear"] = {
			id = 110,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Enchant Spear",
			soul = 3,
			source = 3277,
			level = 45,
			exhaustion = 2000,
			words = "exeta con",
			type = "Conjure",
			mana = 350,
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Ethereal Spear"] = {
			premium = true,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Ethereal Spear",
			soul = 0,
			mana = 25,
			level = 23,
			exhaustion = 2000,
			id = 111,
			words = "exori con",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Ice Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Ice Strike",
			soul = 0,
			mana = 20,
			level = 15,
			exhaustion = 2000,
			id = 112,
			words = "exori frigo",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5,
				2,
				6
			}
		},
		["Terra Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Terra Strike",
			soul = 0,
			mana = 20,
			level = 13,
			exhaustion = 2000,
			id = 113,
			words = "exori tera",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5,
				2,
				6
			}
		},
		Icicle = {
			id = 114,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Icicle",
			soul = 3,
			mana = 460,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori frigo",
			type = "Conjure",
			source = 3147,
			level = 28,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Avalanche = {
			id = 115,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avalanche",
			soul = 3,
			mana = 530,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori mas frigo",
			type = "Conjure",
			source = 3147,
			level = 30,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Stone Shower"] = {
			id = 116,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Stone Shower",
			soul = 3,
			mana = 430,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori mas tera",
			type = "Conjure",
			source = 3147,
			level = 28,
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Thunderstorm = {
			id = 117,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Thunderstorm",
			soul = 3,
			mana = 430,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori mas vis",
			type = "Conjure",
			source = 3147,
			level = 28,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Eternal Winter"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Eternal Winter",
			soul = 0,
			mana = 1050,
			level = 60,
			exhaustion = 40000,
			id = 118,
			words = "exevo gran mas frigo",
			type = "Instant",
			group = {
				[1] = 4000,
				[7] = 40000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_CIRCLE5X5
		},
		["Rage of the Skies"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Rage of the Skies",
			soul = 0,
			mana = 600,
			level = 55,
			exhaustion = 40000,
			id = 119,
			words = "exevo gran mas vis",
			type = "Instant",
			group = {
				[1] = 4000,
				[7] = 40000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_CIRCLE5X5
		},
		["Terra Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Terra Wave",
			soul = 0,
			mana = 170,
			level = 38,
			exhaustion = 4000,
			premium = false,
			words = "exevo tera hur",
			type = "Instant",
			id = 120,
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_SQUAREWAVE4
		},
		["Ice Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Ice Wave",
			soul = 0,
			mana = 25,
			level = 18,
			exhaustion = 3000,
			premium = false,
			words = "exevo frigo hur",
			type = "Instant",
			id = 121,
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_SQUAREWAVE5
		},
		["Divine Missile"] = {
			premium = true,
			range = 4,
			parameter = false,
			needTarget = false,
			name = "Divine Missile",
			soul = 0,
			mana = 20,
			level = 40,
			exhaustion = 2000,
			id = 122,
			words = "exori san",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Wound Cleansing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Wound Cleansing",
			soul = 0,
			mana = 40,
			level = 8,
			exhaustion = 2000,
			id = 123,
			words = "exura ico",
			type = "Instant",
			group = {
				[2] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Divine Caldera"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Divine Caldera",
			soul = 0,
			mana = 160,
			level = 50,
			exhaustion = 4000,
			id = 124,
			words = "exevo mas san",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			},
			area = SpellAreas.AREA_CIRCLE3X3
		},
		["Divine Healing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Divine Healing",
			soul = 0,
			mana = 160,
			level = 35,
			exhaustion = 1000,
			id = 125,
			words = "exura san",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				3,
				7
			}
		},
		["Train Party"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Train Party",
			soul = 0,
			mana = 60,
			level = 32,
			exhaustion = 2000,
			id = 126,
			words = "utito mas sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Protect Party"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Protect Party",
			soul = 0,
			mana = 90,
			level = 32,
			exhaustion = 2000,
			id = 127,
			words = "utamo mas sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Heal Party"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Heal Party",
			soul = 0,
			mana = 120,
			level = 32,
			exhaustion = 2000,
			id = 128,
			words = "utura mas sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Enchant Party"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Enchant Party",
			soul = 0,
			mana = 120,
			level = 32,
			exhaustion = 2000,
			id = 129,
			words = "utori mas sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Holy Missile"] = {
			id = 130,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Holy Missile",
			soul = 3,
			mana = 300,
			maglevel = 4,
			exhaustion = 2000,
			words = "adori san",
			type = "Conjure",
			source = 3147,
			level = 27,
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Charge = {
			id = 131,
			premium = true,
			duration = 5000,
			parameter = false,
			needTarget = false,
			name = "Charge",
			soul = 0,
			mana = 100,
			level = 25,
			exhaustion = 2000,
			range = 0,
			words = "utani tempo hur",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		Protector = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Protector",
			soul = 0,
			mana = 200,
			level = 55,
			exhaustion = 2000,
			id = 132,
			words = "utamo tempo",
			type = "Instant",
			group = {
				[3] = 2000,
				[7] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Blood Rage"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Blood Rage",
			soul = 0,
			mana = 290,
			level = 60,
			exhaustion = 2000,
			id = 133,
			words = "utito tempo",
			type = "Instant",
			group = {
				[3] = 2000,
				[7] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Swift Foot"] = {
			id = 134,
			premium = false,
			duration = 10000,
			parameter = false,
			needTarget = false,
			name = "Swift Foot",
			soul = 0,
			mana = 400,
			level = 55,
			exhaustion = 10000,
			range = 0,
			words = "utamo tempo san",
			type = "Instant",
			group = {
				[3] = 2000,
				[7] = 10000
			},
			vocations = {
				3,
				7
			}
		},
		Sharpshooter = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Sharpshooter",
			soul = 0,
			mana = 250,
			level = 20,
			exhaustion = 10000,
			id = 313,
			words = "utori con",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Ignite = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = true,
			name = "Ignite",
			soul = 0,
			mana = 30,
			level = 26,
			exhaustion = 30000,
			id = 138,
			words = "utori flam",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		Curse = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = true,
			name = "Curse",
			soul = 0,
			mana = 30,
			level = 75,
			exhaustion = 40000,
			id = 139,
			words = "utori mort",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		Electrify = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = true,
			name = "Electrify",
			soul = 0,
			mana = 30,
			level = 34,
			exhaustion = 30000,
			id = 140,
			words = "utori vis",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Inflict Wound"] = {
			premium = false,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Inflict Wound",
			soul = 0,
			mana = 30,
			level = 40,
			exhaustion = 30000,
			id = 141,
			words = "utori kor",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8,
				9
			}
		},
		Envenom = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = true,
			name = "Envenom",
			soul = 0,
			mana = 30,
			level = 50,
			exhaustion = 40000,
			id = 142,
			words = "utori pox",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Holy Flash"] = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = true,
			name = "Holy Flash",
			soul = 0,
			mana = 30,
			level = 70,
			exhaustion = 10000,
			id = 143,
			words = "utori san",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Cure Bleeding"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Bleeding",
			soul = 0,
			mana = 30,
			level = 45,
			exhaustion = 6000,
			id = 144,
			words = "exana kor",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				4,
				6,
				8
			}
		},
		["Cure Burning"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Burning",
			soul = 0,
			mana = 30,
			level = 30,
			exhaustion = 6000,
			id = 145,
			words = "exana flam",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				6
			}
		},
		["Cure Electrification"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Electrification",
			soul = 0,
			mana = 30,
			level = 22,
			exhaustion = 6000,
			id = 146,
			words = "exana vis",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				6
			}
		},
		["Cure Curse"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cure Curse",
			soul = 0,
			mana = 40,
			level = 80,
			exhaustion = 6000,
			id = 147,
			words = "exana mort",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				3,
				7
			}
		},
		["Physical Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Physical Strike",
			soul = 0,
			mana = 20,
			level = 16,
			exhaustion = 2000,
			id = 148,
			words = "exori moe ico",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		Lightning = {
			premium = true,
			range = 4,
			parameter = false,
			needTarget = false,
			name = "Lightning",
			soul = 0,
			mana = 60,
			level = 55,
			exhaustion = 6000,
			id = 149,
			words = "exori amp vis",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 8000
			},
			vocations = {
				1,
				5
			}
		},
		["Strong Flame Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Strong Flame Strike",
			soul = 0,
			mana = 60,
			level = 70,
			exhaustion = 8000,
			id = 150,
			words = "exori gran flam",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 8000
			},
			vocations = {
				1,
				5
			}
		},
		["Strong Energy Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Strong Energy Strike",
			soul = 0,
			mana = 60,
			level = 80,
			exhaustion = 8000,
			id = 151,
			words = "exori gran vis",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 8000
			},
			vocations = {
				1,
				5
			}
		},
		["Strong Ice Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Strong Ice Strike",
			soul = 0,
			mana = 60,
			level = 80,
			exhaustion = 8000,
			id = 152,
			words = "exori gran frigo",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 8000
			},
			vocations = {
				2,
				6
			}
		},
		["Strong Terra Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Strong Terra Strike",
			soul = 0,
			mana = 60,
			level = 70,
			exhaustion = 8000,
			id = 153,
			words = "exori gran tera",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 8000
			},
			vocations = {
				2,
				6
			}
		},
		["Ultimate Flame Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Ultimate Flame Strike",
			soul = 0,
			mana = 100,
			level = 90,
			exhaustion = 30000,
			id = 154,
			words = "exori max flam",
			type = "Instant",
			group = {
				[1] = 2000,
				[8] = 30000
			},
			vocations = {
				1,
				5
			}
		},
		["Ultimate Energy Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Ultimate Energy Strike",
			soul = 0,
			mana = 100,
			level = 100,
			exhaustion = 30000,
			id = 155,
			words = "exori max vis",
			type = "Instant",
			group = {
				[1] = 2000,
				[8] = 30000
			},
			vocations = {
				1,
				5
			}
		},
		["Ultimate Ice Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Ultimate Ice Strike",
			soul = 0,
			mana = 100,
			level = 100,
			exhaustion = 30000,
			id = 156,
			words = "exori max frigo",
			type = "Instant",
			group = {
				[1] = 2000,
				[8] = 30000
			},
			vocations = {
				2,
				6
			}
		},
		["Ultimate Terra Strike"] = {
			premium = true,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Ultimate Terra Strike",
			soul = 0,
			mana = 100,
			level = 90,
			exhaustion = 30000,
			id = 157,
			words = "exori max tera",
			type = "Instant",
			group = {
				[1] = 2000,
				[8] = 30000
			},
			vocations = {
				2,
				6
			}
		},
		["Intense Wound Cleansing"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Intense Wound Cleansing",
			soul = 0,
			mana = 200,
			level = 80,
			exhaustion = 120000,
			id = 158,
			words = "exura gran ico",
			type = "Instant",
			group = {
				[2] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		Recovery = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Recovery",
			soul = 0,
			mana = 75,
			level = 50,
			exhaustion = 60000,
			id = 159,
			words = "utura",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				3,
				4,
				7,
				8
			}
		},
		["Intense Recovery"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Intense Recovery",
			soul = 0,
			mana = 165,
			level = 100,
			exhaustion = 60000,
			id = 160,
			words = "utura gran",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				3,
				4,
				7,
				8
			}
		},
		["Practise Healing"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Practise Healing",
			soul = 0,
			mana = 5,
			level = 1,
			exhaustion = 1000,
			id = 166,
			words = "exura dis",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				0
			}
		},
		["Practise Fire Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Practise Fire Wave",
			soul = 0,
			mana = 5,
			level = 1,
			exhaustion = 3000,
			premium = false,
			words = "exevo dis flam hur",
			type = "Instant",
			id = 167,
			group = {
				[1] = 2000
			},
			vocations = {
				0
			},
			area = SpellAreas.AREA_SQUAREWAVE5
		},
		["Practise Magic Missile"] = {
			id = 168,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Practice Magic Missile Rune",
			soul = 0,
			mana = 5,
			maglevel = 0,
			exhaustion = 2000,
			words = "adori dis min vis",
			type = "Conjure",
			source = 3147,
			level = 1,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Lightest Missile"] = {
			id = 179,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Lightest Missile Rune",
			soul = 0,
			mana = 6,
			maglevel = 0,
			exhaustion = 2000,
			words = "adori infir vis",
			type = "Conjure",
			source = 3147,
			level = 1,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7
			}
		},
		["Light Stone Shower"] = {
			id = 180,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Light Stone Shower Rune",
			soul = 3,
			mana = 6,
			maglevel = 0,
			exhaustion = 2000,
			words = "adori infir mas tera",
			type = "Conjure",
			source = 3147,
			level = 1,
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7
			}
		},
		["Apprentice's Strike"] = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Apprentice's Strike",
			soul = 0,
			mana = 6,
			level = 8,
			exhaustion = 2000,
			id = 169,
			words = "exori min flam",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Bruise Bane"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Bruise Bane",
			soul = 0,
			mana = 10,
			level = 1,
			exhaustion = 2000,
			id = 175,
			words = "exura infir ico",
			type = "Instant",
			group = {
				[2] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Mud Attack"] = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Mud Attack",
			soul = 0,
			mana = 6,
			level = 1,
			exhaustion = 2000,
			id = 172,
			words = "exori infir tera",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			}
		},
		["Chill Out"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Chill Out",
			soul = 0,
			mana = 8,
			level = 1,
			exhaustion = 4000,
			premium = false,
			words = "exevo infir frigo hur",
			type = "Instant",
			id = 173,
			group = {
				[1] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_SQUAREWAVE5
		},
		["Magic Patch"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Magic Patch",
			soul = 0,
			mana = 6,
			level = 1,
			exhaustion = 1000,
			id = 174,
			words = "exura infir",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				3,
				5,
				6,
				7,
				9,
				10
			}
		},
		["Arrow Call"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Arrow Call",
			soul = 1,
			mana = 30,
			level = 1,
			exhaustion = 2000,
			id = 176,
			words = "exevo infir con",
			type = "Conjure",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		Buzz = {
			premium = false,
			range = 3,
			parameter = false,
			needTarget = false,
			name = "Buzz",
			soul = 0,
			mana = 6,
			level = 1,
			exhaustion = 2000,
			id = 177,
			words = "exori infir vis",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		Scorch = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Scorch",
			soul = 0,
			mana = 8,
			level = 1,
			exhaustion = 3000,
			premium = false,
			words = "exevo infir flam hur",
			type = "Instant",
			id = 178,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_SQUAREWAVE5
		},
		["Summon Knight Familiar"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Summon Knight Familiar",
			soul = 0,
			mana = 1000,
			level = 200,
			exhaustion = 1800000,
			id = 194,
			words = "utevo gran res eq",
			type = "Instant",
			group = {
				[3] = 4000
			},
			vocations = {
				8
			}
		},
		["Summon Paladin Familiar"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Summon Paladin Familiar",
			soul = 0,
			mana = 2000,
			level = 200,
			exhaustion = 1800000,
			id = 195,
			words = "utevo gran res sac",
			type = "Instant",
			group = {
				[3] = 4000
			},
			vocations = {
				7
			}
		},
		["Summon Sorcerer Familiar"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Summon Sorcerer Familiar",
			soul = 0,
			mana = 3000,
			level = 200,
			exhaustion = 1800000,
			id = 196,
			words = "utevo gran res ven",
			type = "Instant",
			group = {
				[3] = 4000
			},
			vocations = {
				5
			}
		},
		["Summon Druid Familiar"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Summon Druid Familiar",
			soul = 0,
			mana = 3000,
			level = 200,
			exhaustion = 1800000,
			id = 197,
			words = "utevo gran res dru",
			type = "Instant",
			group = {
				[3] = 4000
			},
			vocations = {
				6
			}
		},
		["Chivalrous Challenge"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Chivalrous Challenge",
			soul = 0,
			mana = 80,
			level = 150,
			exhaustion = 2000,
			id = 237,
			words = "exeta amp res",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Divine Dazzle"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Divine Dazzle",
			soul = 0,
			mana = 80,
			level = 250,
			exhaustion = 16000,
			id = 238,
			words = "exana amp res",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Fair Wound Cleansing"] = {
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Fair Wound Cleansing",
			soul = 0,
			mana = 90,
			level = 300,
			exhaustion = 2000,
			id = 239,
			words = "exura med ico",
			type = "Instant",
			group = {
				[2] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Great Fire Wave"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Great Fire Wave",
			soul = 0,
			mana = 120,
			level = 38,
			exhaustion = 4000,
			premium = false,
			words = "exevo gran flam hur",
			type = "Instant",
			id = 240,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_SQUAREWAVE6
		},
		Restoration = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Restoration",
			soul = 0,
			mana = 260,
			level = 300,
			exhaustion = 6000,
			id = 241,
			words = "exura max vita",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				1,
				2,
				5,
				6
			}
		},
		["Nature's Embrace"] = {
			premium = true,
			range = 0,
			parameter = true,
			needTarget = true,
			name = "Nature's Embrace",
			soul = 0,
			mana = 400,
			level = 275,
			exhaustion = 60000,
			parameterPlaceholder = "name",
			words = "exura gran sio",
			type = "Instant",
			id = 242,
			group = {
				[2] = 1000
			},
			vocations = {
				2,
				6
			}
		},
		["Aura of Sapped Strength"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Aura of Sapped Strength",
			soul = 0,
			mana = 1500,
			level = 175,
			exhaustion = 30000,
			id = 311,
			words = "exori kor tempo",
			type = "Instant",
			group = {
				[3] = 2000,
				[6] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Aura of Exposed Weakness"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Aura of Exposed Weakness",
			soul = 0,
			mana = 1500,
			level = 175,
			exhaustion = 30000,
			id = 312,
			words = "exori moe tempo",
			type = "Instant",
			group = {
				[3] = 2000,
				[6] = 2000
			},
			vocations = {
				1,
				5
			}
		},
		["Cancel Magic Shield"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Cancel Magic Shield",
			soul = 0,
			mana = 50,
			level = 14,
			exhaustion = 2000,
			id = 245,
			words = "exana vita",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				5,
				2,
				6
			}
		},
		["Find Fiend"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Find Fiend",
			soul = 0,
			mana = 20,
			level = 25,
			exhaustion = 2000,
			id = 248,
			words = "exiva moe res",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10
			}
		},
		["Divine Grenade"] = {
			parameter = false,
			premium = false,
			range = 5,
			special = true,
			needTarget = false,
			soul = 0,
			mana = 160,
			level = 0,
			crossHairTarget = true,
			words = "exevo tempo mas san",
			id = 258,
			exhaustion = 26000,
			name = "Divine Grenade",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				7
			},
			area = SpellAreas.AREA_CIRCLE2X2
		},
		["Great Death Beam"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Great Death Beam",
			soul = 0,
			mana = 140,
			level = 66,
			exhaustion = 10000,
			premium = false,
			words = "exevo max mort",
			type = "Instant",
			id = 260,
			group = {
				[1] = 2000,
				[9] = 6000
			},
			vocations = {
				5
			},
			area = SpellAreas.AREA_BEAM8
		},
		["Executioner's Throw"] = {
			premium = false,
			range = 5,
			parameter = false,
			needTarget = true,
			name = "Executioner's Throw",
			soul = 0,
			mana = 225,
			level = 300,
			exhaustion = 2000,
			id = 261,
			words = "exori amp kor",
			type = "Instant",
			special = true,
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Terra Burst"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Terra Burst",
			soul = 0,
			mana = 230,
			level = 300,
			exhaustion = 2000,
			id = 262,
			words = "exevo ulus tera",
			type = "Instant",
			special = true,
			group = {
				[1] = 2000,
				[10] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_RING_BURST3
		},
		["Ice Burst"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Ice Burst",
			soul = 0,
			mana = 230,
			level = 300,
			exhaustion = 2000,
			id = 263,
			words = "exevo ulus frigo",
			type = "Instant",
			special = true,
			group = {
				[1] = 2000,
				[10] = 2000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_RING_BURST3
		},
		["Avatar of Steel"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avatar of Steel",
			soul = 0,
			mana = 800,
			level = 0,
			exhaustion = 7200000,
			id = 264,
			words = "uteta res eq",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				8
			}
		},
		["Avatar of Light"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avatar of Light",
			soul = 0,
			mana = 1500,
			level = 0,
			exhaustion = 7200000,
			id = 265,
			words = "uteta res sac",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				7
			}
		},
		["Avatar of Storm"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avatar of Storm",
			soul = 0,
			mana = 2200,
			level = 0,
			exhaustion = 7200000,
			id = 266,
			words = "uteta res ven",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				5
			}
		},
		["Avatar of Nature"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avatar of Nature",
			soul = 0,
			mana = 2200,
			level = 0,
			exhaustion = 7200000,
			id = 267,
			words = "uteta res dru",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				6
			}
		},
		["Divine Empowerment"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Divine Empowerment",
			soul = 0,
			mana = 500,
			level = 0,
			exhaustion = 32000,
			id = 268,
			words = "utevo grav san",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				7
			},
			area = SpellAreas.AREA_CIRCLE2X2
		},
		["Lesser Ethereal Spear"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Lesser Ethereal Spear",
			soul = 0,
			mana = 6,
			level = 1,
			exhaustion = 8000,
			id = 270,
			words = "exori infir con",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Lesser Front Sweep"] = {
			premium = false,
			range = 1,
			parameter = false,
			needTarget = false,
			name = "Lesser Front Sweep",
			soul = 0,
			mana = 6,
			level = 1,
			exhaustion = 6000,
			id = 271,
			words = "exori infir min",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_SQUAREWAVE1
		},
		["Spirit Mend"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Spirit Mend",
			soul = 0,
			mana = 210,
			level = 80,
			exhaustion = 1000,
			id = 273,
			words = "exura gran tio",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				9,
				10
			}
		},
		["Virtue of Harmony"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Virtue of Harmony",
			soul = 0,
			mana = 210,
			level = 20,
			exhaustion = 10000,
			id = 274,
			words = "utori virtu",
			type = "Instant",
			group = {
				[3] = 2000,
				[11] = 10000
			},
			vocations = {
				9,
				10
			}
		},
		["Virtue of Justice"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Virtue of Justice",
			soul = 0,
			mana = 210,
			level = 20,
			exhaustion = 10000,
			id = 275,
			words = "utito virtu",
			type = "Instant",
			group = {
				[3] = 2000,
				[11] = 10000
			},
			vocations = {
				9,
				10
			}
		},
		["Virtue of Sustain"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Virtue of Sustain",
			soul = 0,
			mana = 210,
			level = 20,
			exhaustion = 10000,
			id = 276,
			words = "utura tio",
			type = "Instant",
			group = {
				[3] = 2000,
				[11] = 10000
			},
			vocations = {
				9,
				10
			}
		},
		["Enlighten Party"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Enlighten Party",
			soul = 0,
			mana = 75,
			level = 32,
			exhaustion = 300000,
			id = 278,
			words = "utevo mas sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Focus Harmony"] = {
			needLearn = true,
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Focus Harmony",
			soul = 0,
			mana = 500,
			level = 275,
			exhaustion = 120000,
			words = "utevo nia",
			type = "Instant",
			id = 279,
			group = {
				[3] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Balanced Brawl"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Balanced Brawl",
			soul = 0,
			mana = 80,
			level = 175,
			exhaustion = 10000,
			premium = true,
			words = "exori mas res",
			type = "Instant",
			id = 280,
			group = {
				[3] = 2000
			},
			vocations = {
				9,
				10
			},
			area = SpellAreas.AREA_BALANCED_BRAWL
		},
		["Focus Serenity"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Focus Serenity",
			soul = 0,
			mana = 500,
			level = 150,
			exhaustion = 600000,
			id = 281,
			words = "utamo tio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Summon Monk Familiar"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Summon Monk Familiar",
			soul = 0,
			mana = 1500,
			level = 200,
			exhaustion = 1800000,
			id = 282,
			words = "utevo gran res tio",
			type = "Instant",
			group = {
				[3] = 4000
			},
			vocations = {
				9,
				10
			}
		},
		["Avatar of Balance"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Avatar of Balance",
			soul = 0,
			mana = 1200,
			level = 0,
			exhaustion = 7200000,
			id = 283,
			words = "uteta res tio",
			type = "Instant",
			special = true,
			group = {
				[3] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Swift Jab"] = {
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Swift Jab",
			soul = 0,
			mana = 3,
			level = 0,
			exhaustion = 2000,
			id = 284,
			words = "exori infir pug",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Double Jab"] = {
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Double Jab",
			soul = 0,
			mana = 35,
			level = 14,
			exhaustion = 4000,
			id = 285,
			words = "exori pug",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Forceful Uppercut"] = {
			needLearn = true,
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Forceful Uppercut",
			soul = 0,
			mana = 325,
			level = 110,
			exhaustion = 60000,
			words = "exori gran pug",
			type = "Instant",
			id = 286,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Flurry of Blows"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Flurry of Blows",
			soul = 0,
			mana = 125,
			level = 35,
			exhaustion = 4000,
			premium = true,
			words = "exori mas pug",
			type = "Instant",
			id = 287,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			},
			area = SpellAreas.AREA_FLURRYWAVE
		},
		["Chained Penance"] = {
			premium = true,
			range = 2,
			parameter = false,
			needTarget = true,
			name = "Chained Penance",
			soul = 0,
			mana = 180,
			level = 70,
			exhaustion = 4000,
			id = 288,
			words = "exori med pug",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Greater Flurry of Blows"] = {
			directional = true,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Greater Flurry of Blows",
			soul = 0,
			mana = 315,
			level = 90,
			exhaustion = 16000,
			premium = true,
			words = "exori gran mas pug",
			type = "Instant",
			id = 289,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			},
			area = SpellAreas.AREA_GREATER_FLURRYWAVE
		},
		["Mystic Repulse"] = {
			needLearn = true,
			premium = true,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Mystic Repulse",
			soul = 0,
			mana = 175,
			level = 30,
			exhaustion = 8000,
			words = "exori amp pug",
			type = "Instant",
			id = 290,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Tiger Clash"] = {
			id = 291,
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Tiger Clash",
			spender = true,
			mana = 18,
			level = 0,
			exhaustion = 8000,
			words = "exori infir nia",
			type = "Instant",
			soul = 0,
			useHarmony = true,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Greater Tiger Clash"] = {
			id = 292,
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Greater Tiger Clash",
			spender = true,
			mana = 50,
			level = 18,
			exhaustion = 8000,
			words = "exori nia",
			type = "Instant",
			soul = 0,
			useHarmony = true,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Devastating Knockout"] = {
			id = 293,
			premium = true,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Devastating Knockout",
			spender = true,
			mana = 210,
			level = 125,
			exhaustion = 24000,
			words = "exori gran nia",
			type = "Instant",
			soul = 0,
			useHarmony = true,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Sweeping Takedown"] = {
			spender = true,
			premium = true,
			range = 0,
			parameter = false,
			needTarget = false,
			soul = 0,
			mana = 195,
			level = 60,
			useHarmony = true,
			directional = true,
			words = "exori mas nia",
			id = 294,
			exhaustion = 8000,
			name = "Sweeping Takedown",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			},
			area = SpellAreas.AREA_SHORTWAVE4
		},
		["Spiritual Outburst"] = {
			premium = true,
			range = 2,
			parameter = false,
			needTarget = true,
			useHarmony = true,
			soul = 0,
			mana = 425,
			level = 0,
			spender = true,
			special = true,
			words = "exori gran mas nia",
			id = 295,
			exhaustion = 24000,
			name = "Spiritual Outburst",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Mass Spirit Mend"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Mass Spirit Mend",
			soul = 0,
			mana = 250,
			level = 150,
			exhaustion = 12000,
			id = 296,
			words = "exura mas nia",
			type = "Instant",
			group = {
				[2] = 1000
			},
			vocations = {
				9,
				10
			}
		},
		["Restore Balance"] = {
			premium = true,
			range = 7,
			parameter = true,
			needTarget = true,
			name = "Restore Balance",
			soul = 0,
			mana = 120,
			level = 18,
			exhaustion = 2000,
			parameterPlaceholder = "name",
			words = "exura tio sio",
			type = "Instant",
			id = 297,
			group = {
				[2] = 1000
			},
			vocations = {
				9,
				10
			}
		},
		["Lesser Mystic Repulse"] = {
			needLearn = true,
			premium = false,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Lesser Mystic Repulse",
			soul = 0,
			mana = 30,
			level = 6,
			exhaustion = 20000,
			words = "exori infir amp pug",
			type = "Instant",
			id = 300,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			}
		},
		["Thousand Fist Blows"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = true,
			name = "Thousand Fist Blows",
			soul = 0,
			mana = 145,
			level = 120,
			exhaustion = 8000,
			id = 301,
			words = "exori mas amp pug",
			type = "Instant",
			crossHairTarget = true,
			group = {
				[1] = 2000
			},
			vocations = {
				9,
				10
			},
			area = SpellAreas.AREA_CIRCLE2X2
		},
		["Divine Barrage"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = false,
			name = "Divine Barrage",
			soul = 0,
			mana = 175,
			level = 70,
			exhaustion = 4000,
			id = 302,
			words = "exori dir san",
			type = "Instant",
			crossHairTarget = true,
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			},
			area = SpellAreas.AREA_CIRCLE2X2
		},
		["Ethereal Barrage"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = false,
			name = "Ethereal Barrage",
			soul = 0,
			mana = 135,
			level = 60,
			exhaustion = 4000,
			id = 303,
			words = "exori dir moe",
			type = "Instant",
			crossHairTarget = true,
			group = {
				[1] = 2000
			},
			vocations = {
				3,
				7
			},
			area = SpellAreas.AREA_CIRCLE2X2
		},
		["Master of Flames"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Master of Flames",
			soul = 0,
			mana = 400,
			level = 20,
			exhaustion = 30000,
			id = 304,
			words = "uteta flam",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				5
			}
		},
		["Master of Thunder"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Master of Thunder",
			soul = 0,
			mana = 400,
			level = 20,
			exhaustion = 30000,
			id = 305,
			words = "uteta vis",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				5
			}
		},
		["Master of Decay"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Master of Decay",
			soul = 0,
			mana = 400,
			level = 20,
			exhaustion = 30000,
			id = 306,
			words = "uteta mort",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				5
			}
		},
		["Elemental Synthesis"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Elemental Synthesis",
			soul = 0,
			mana = 400,
			level = 20,
			exhaustion = 10000,
			id = 319,
			words = "utito dru",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				6
			}
		},
		["Shared Conservation"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Shared Conservation",
			soul = 0,
			mana = 400,
			level = 20,
			exhaustion = 10000,
			id = 309,
			words = "utura sio",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				6
			}
		},
		["Death Echo"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = false,
			name = "Death Echo",
			soul = 0,
			mana = 155,
			level = 120,
			exhaustion = 6000,
			id = 310,
			words = "exevo mort ora",
			type = "Instant",
			crossHairTarget = true,
			group = {
				[1] = 2000
			},
			vocations = {
				1,
				5
			},
			area = SpellAreas.AREA_SQUARE2X2
		},
		["Divine Defiance"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Divine Defiance",
			soul = 0,
			mana = 250,
			level = 20,
			exhaustion = 10000,
			id = 314,
			words = "utori hur",
			type = "Instant",
			group = {
				[3] = 2000
			},
			vocations = {
				3,
				7
			}
		},
		["Shield Bash"] = {
			premium = false,
			range = 1,
			parameter = false,
			needTarget = true,
			name = "Shield Bash",
			soul = 0,
			mana = 30,
			level = 18,
			exhaustion = 4000,
			id = 315,
			words = "exori ico scu",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			}
		},
		["Shield Slam"] = {
			premium = false,
			range = 0,
			parameter = false,
			needTarget = false,
			name = "Shield Slam",
			soul = 0,
			mana = 110,
			level = 30,
			exhaustion = 6000,
			id = 316,
			words = "exori scu",
			type = "Instant",
			group = {
				[1] = 2000
			},
			vocations = {
				4,
				8
			},
			area = SpellAreas.AREA_CIRCLE1X1
		},
		["Forked Glacier"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = false,
			name = "Forked Glacier",
			soul = 0,
			mana = 180,
			level = 90,
			exhaustion = 6000,
			id = 317,
			words = "exevo fur frigo",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 6000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_FORKS
		},
		["Forked Thorns"] = {
			premium = false,
			range = 7,
			parameter = false,
			needTarget = false,
			name = "Forked Thorns",
			soul = 0,
			mana = 180,
			level = 80,
			exhaustion = 6000,
			id = 318,
			words = "exevo fur tera",
			type = "Instant",
			group = {
				[1] = 2000,
				[4] = 6000
			},
			vocations = {
				2,
				6
			},
			area = SpellAreas.AREA_FORKS
		}
	}
}
SpellIconsFirstIsZero = {
	5,
	6,
	0,
	73,
	61,
	100,
	72,
	76,
	115,
	114,
	113,
	89,
	42,
	90,
	78,
	77,
	81,
	82,
	43,
	111,
	63,
	40,
	41,
	48,
	80,
	68,
	84,
	79,
	9,
	86,
	88,
	67,
	83,
	nil,
	nil,
	59,
	nil,
	99,
	101,
	nil,
	nil,
	98,
	45,
	120,
	93,
	nil,
	nil,
	nil,
	108,
	66,
	105,
	nil,
	nil,
	70,
	85,
	47,
	58,
	nil,
	19,
	nil,
	22,
	23,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	112,
	104,
	65,
	87,
	nil,
	20,
	121,
	8,
	92,
	7,
	nil,
	71,
	37,
	28,
	25,
	94,
	69,
	138,
	96,
	60,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	21,
	24,
	18,
	nil,
	nil,
	103,
	17,
	31,
	34,
	74,
	91,
	64,
	62,
	49,
	51,
	46,
	44,
	38,
	2,
	39,
	1,
	117,
	119,
	122,
	110,
	75,
	97,
	118,
	95,
	116,
	nil,
	nil,
	nil,
	54,
	53,
	55,
	56,
	57,
	52,
	11,
	12,
	13,
	10,
	16,
	50,
	26,
	29,
	32,
	35,
	27,
	30,
	33,
	36,
	3,
	14,
	15,
	nil,
	nil,
	nil,
	nil,
	nil,
	124,
	125,
	126,
	123,
	nil,
	nil,
	133,
	132,
	130,
	131,
	134,
	129,
	128,
	72,
	64,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	139,
	141,
	142,
	140,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	109,
	135,
	4,
	102,
	107,
	106,
	nil,
	nil,
	143,
	nil,
	nil,
	144,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	152,
	nil,
	154,
	149,
	151,
	150,
	145,
	147,
	148,
	146,
	155,
	nil,
	156,
	157,
	nil,
	158,
	159,
	160,
	161,
	nil,
	163,
	164,
	165,
	166,
	167,
	168,
	169,
	170,
	171,
	172,
	173,
	174,
	175,
	176,
	177,
	178,
	179,
	180,
	181,
	182,
	nil,
	nil,
	183,
	184,
	185,
	186,
	187,
	188,
	189,
	nil,
	190,
	191,
	192,
	199,
	200,
	193,
	194,
	195,
	196,
	197,
	198,
	190,
	73
}
SpellIcons = {}

for id, icon in pairs(SpellIconsFirstIsZero) do
	SpellIcons[id] = icon + 1
end

VocationNames = {
	[0] = "None",
	"Sorcerer",
	"Druid",
	"Paladin",
	"Knight",
	"Master Sorcerer",
	"Elder Druid",
	"Royal Paladin",
	"Elite Knight",
	"Monk",
	"Exalted Monk"
}
SpellGroups = {
	"Attack",
	"Healing",
	"Support",
	"Special",
	"Conjure",
	"Crippling",
	"Focus",
	"Ultimate Strikes",
	"Great Beams",
	"Bursts of Nature",
	"Virtue"
}
SpellGroupIconFile = "/images/game/spells/spellgroup-icons-20x20"
SpellGroupIconSize = {
	height = 20,
	width = 20
}
SpellRunesData = {
	[3148] = {
		group = 3,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 30,
		name = "destroy field rune"
	},
	[3149] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 55,
		name = "energybomb rune"
	},
	[3152] = {
		group = 2,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 4,
		name = "intense healing rune"
	},
	[3153] = {
		group = 2,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 31,
		name = "antidote rune"
	},
	[3155] = {
		group = 1,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 21,
		name = "sudden death rune"
	},
	[3156] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 94,
		name = "Wild Growth Rune"
	},
	[3158] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 114,
		name = "icicle rune"
	},
	[3160] = {
		group = 2,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 5,
		name = "ultimate healing rune"
	},
	[3161] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 115,
		name = "avalanche rune"
	},
	[3164] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 27,
		name = "energy field rune"
	},
	[3165] = {
		group = 3,
		groupExhaustion = 2000,
		exhaustion = 4000,
		id = 54,
		name = "paralyze rune"
	},
	[3166] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 33,
		name = "energy wall rune"
	},
	[3172] = {
		group = 1,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 26,
		name = "poison field rune"
	},
	[3173] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 91,
		name = "poison bomb rune"
	},
	[3174] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 7,
		name = "light magic missile rune"
	},
	[3175] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 116,
		name = "stone shower rune"
	},
	[3176] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 32,
		name = "poison wall rune"
	},
	[3177] = {
		group = 3,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 12,
		name = "convince creature rune"
	},
	[3178] = {
		group = 3,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 14,
		name = "chameleon rune"
	},
	[3179] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 77,
		name = "stalagmite rune"
	},
	[3180] = {
		group = 1,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 86,
		name = "Magic Wall Rune"
	},
	[3182] = {
		group = 1,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 130,
		name = "holy missile rune"
	},
	[3188] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 25,
		name = "fire field rune"
	},
	[3189] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 15,
		name = "fireball rune"
	},
	[3190] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 28,
		name = "fire wall rune"
	},
	[3191] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 16,
		name = "great fireball rune"
	},
	[3192] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 17,
		name = "firebomb rune"
	},
	[3195] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 50,
		name = "soulfire rune"
	},
	[3197] = {
		group = 3,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 78,
		name = "desintegrate rune"
	},
	[3198] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 8,
		name = "heavy magic missile rune"
	},
	[3200] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 18,
		name = "explosion rune"
	},
	[3202] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 117,
		name = "thunderstorm rune"
	},
	[3203] = {
		group = 3,
		groupExhaustion = 2000,
		exhaustion = 2000,
		id = 83,
		name = "animate dead rune"
	},
	[17512] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 7,
		name = "lightest magic missile rune"
	},
	[21351] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 116,
		name = "light stone shower rune"
	},
	[21352] = {
		group = 1,
		groupExhaustion = 1500,
		exhaustion = 2000,
		id = 7,
		name = "lightest missile rune"
	}
}
Spells = {}

function Spells.getParameterPlaceholder(spell)
	if not spell then
		return nil
	end

	return spell.parameterPlaceholder
end

local function resolveSpellByName(spellName)
	if not spellName or spellName == "" then
		return nil, nil
	end

	local trimmed = spellName:trim()

	for profile, data in pairs(SpellInfo) do
		local spell = data[trimmed]

		if spell then
			return spell, profile
		end

		for _, entry in pairs(data) do
			if entry.name and entry.name:trim():lower() == trimmed:lower() then
				return entry, profile
			end
		end
	end

	return nil, nil
end

local function resolveSpellIconId(spell)
	if not spell then
		return nil
	end

	if SpellIcons[spell.id] then
		return SpellIcons[spell.id]
	end

	return nil
end

function Spells.getClientId(spellName)
	return resolveSpellIconId(resolveSpellByName(spellName))
end

function Spells.getSpellByClientId(id)
	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.id == id then
				return spell, profile, k
			end
		end
	end

	return nil
end

function Spells.getSpellNameByWords(words)
	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.words == words then
				return k
			end
		end
	end

	return nil
end

function Spells.getSpellByName(name)
	return (resolveSpellByName(name))
end

local spellByIdCache = {}
local spellByWordsCache = {}

function Spells.getSpellByWords(words)
	if not words or words == "" then
		return nil
	end

	local normalized = words:lower():trim()
	local cached = spellByWordsCache[normalized]

	if cached ~= nil then
		if cached == false then
			return nil
		end

		return cached[1], cached[2], cached[3]
	end

	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.words == normalized then
				spellByWordsCache[normalized] = {
					spell,
					profile,
					k
				}

				return spell, profile, k
			end
		end
	end

	spellByWordsCache[normalized] = false

	return nil
end

function Spells.getSpellByIcon(iconId)
	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.id == iconId then
				return spell, profile, k
			end
		end
	end

	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if SpellIcons[spell.id] and SpellIcons[spell.id] == iconId then
				return spell, profile, k
			end
		end
	end

	return nil
end

function Spells.resolveSpellId(iconId)
	local spell = Spells.getSpellByIcon(iconId)

	return spell and spell.id or iconId
end

function Spells.getSpellIconIds()
	local ids = {}

	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			table.insert(ids, spell.id)
		end
	end

	return ids
end

function Spells.getSpellProfileById(id)
	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.id == id then
				return profile
			end
		end
	end

	return nil
end

function Spells.getSpellProfileByWords(words)
	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if spell.words == words then
				return profile
			end
		end
	end

	return nil
end

function Spells.getSpellProfileByName(spellName)
	local _, profile = resolveSpellByName(spellName)

	return profile
end

function Spells.getSpellsByVocationId(vocId)
	local spells = {}

	for profile, data in pairs(SpellInfo) do
		for k, spell in pairs(data) do
			if table.contains(spell.vocations, vocId) then
				table.insert(spells, spell)
			end
		end
	end

	return spells
end

function Spells.getSpellNamesSortedForVocation(vocId, spellProfile)
	local names = {}
	local data = SpellInfo[spellProfile]

	if not data or not vocId or vocId <= 0 then
		return names
	end

	for spellName, spell in pairs(data) do
		if table.contains(spell.vocations, vocId) then
			table.insert(names, spellName)
		end
	end

	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)

	return names
end

function Spells.filterSpellsByGroups(spells, groups)
	local filtered = {}

	for v, spell in pairs(spells) do
		local spellGroups = Spells.getGroupIds(spell)

		if table.equals(spellGroups, groups) then
			table.insert(filtered, spell)
		end
	end

	return filtered
end

function Spells.getGroupIds(spell)
	local groups = {}

	for k, _ in pairs(spell.group) do
		table.insert(groups, k)
	end

	return groups
end

function Spells.getPrimaryGroupId(spell)
	if not spell or not spell.group then
		return nil
	end

	local minId

	for gid, _ in pairs(spell.group) do
		if not minId or gid < minId then
			minId = gid
		end
	end

	return minId
end

function Spells.getSpellGroupIconClip(groupId)
	if not groupId or groupId < 1 or not SpellGroups[groupId] then
		return nil
	end

	local w = SpellGroupIconSize.width
	local h = SpellGroupIconSize.height

	return (groupId - 1) * w .. " 0 " .. w .. " " .. h
end

function Spells.getImageClip(id, profile)
	if not id or not profile or not SpelllistSettings[profile] then
		return nil
	end

	local w = SpelllistSettings[profile].iconSize.width
	local h = SpelllistSettings[profile].iconSize.height

	return (id - 1) * w .. " 0 " .. w .. " " .. h
end

function Spells.getIconFileByProfile(profile)
	return SpelllistSettings[profile].iconFile
end

function Spells.getImageClipNormal(id, profile)
	if not id or not profile or not SpelllistSettings[profile] then
		return nil
	end

	local w = SpelllistSettings[profile].iconSize.width
	local h = SpelllistSettings[profile].iconSize.height

	return (id - 1) * w .. " 0 " .. w .. " " .. h
end

function Spells.getSpellDataById(spellId)
	local cached = spellByIdCache[spellId]

	if cached ~= nil then
		return cached or nil
	end

	for _, data in pairs(SpellInfo) do
		for _, spell in pairs(data) do
			if spell.id == spellId then
				spellByIdCache[spellId] = spell

				return spell
			end
		end
	end

	spellByIdCache[spellId] = false

	return nil
end

function Spells.clearSpellCache()
	spellByIdCache = {}
	spellByWordsCache = {}
end

function Spells.getRuneUsageSpell(itemId)
	local runeData = SpellRunesData[itemId]

	if not runeData then
		return nil
	end

	local groupCd = runeData.groupExhaustion or runeData.exhaustion
	local conjureSpell = Spells.getSpellDataById(runeData.id)

	return {
		type = "Rune",
		id = runeData.id,
		name = conjureSpell and conjureSpell.name or runeData.name,
		icon = conjureSpell and conjureSpell.icon or nil,
		clientId = conjureSpell and conjureSpell.clientId or nil,
		group = {
			[runeData.group] = groupCd
		},
		exhaustion = runeData.exhaustion,
		_conjureVocations = conjureSpell and conjureSpell.vocations or nil
	}
end

function Spells.getRuneSpellByItem(itemId)
	return Spells.getRuneUsageSpell(itemId)
end

function Spells.isRuneSpell(spellId)
	for _, data in pairs(SpellRunesData) do
		if data.id == spellId then
			return true
		end
	end

	return false
end

function Spells.hasCrossHairTarget(spell)
	if type(spell) ~= "table" then
		return false
	end

	return spell.crossHairTarget == true
end
