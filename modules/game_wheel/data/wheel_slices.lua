WheelPointTooltip = "From level 51 onwards, you receive one promotion point with each level, of which you currently have %s.\n\nFor each fully enhanced mod, you will receive another promotion point. This currently gives you %s out of a maximum of 69 points.\n\nCertain rare items and special game accomplishments can earn you bonus promotion points, of wich you currently have %s:"
ConvictionTooltip = "The Conviction Perk is unlocked when the maximum number of\npromotion points for this slice has been assigned.\n\nMost Conviction Perks can be found more than once within the\nWheel of Destiny. When they are unlocked, thier effect adds up."
WheelDedicationHeight = {
	{
		45,
		60,
		60,
		74
	},
	{
		45,
		45,
		60,
		74
	},
	{
		45,
		60,
		60,
		74
	},
	{
		45,
		60,
		74,
		74
	},
	{
		45,
		60,
		60,
		74
	}
}
WheelConsts = {
	manaleech = 0.25,
	skill = 1,
	lifeleech = 0.75,
	mitigation = 0.075,
	lifemana = {
		life = {
			3,
			2,
			1,
			1,
			2
		},
		mana = {
			1,
			3,
			6,
			6,
			2
		}
	},
	special_1 = {
		{
			"Battle Instinct",
			"Gain +6 shielding and +1 sword/axe/club fighting when 5\ncreatures are on adjacent squares.\nFor each additional creature, up to a maximum of 8, you get +6\nshielding and +1 sword/axe/club fighting more."
		},
		{
			"Positional Tactics",
			"Gain +3 distance fighting while no monster is within 1 squares.\nOtherwise gain +3 holy magic level and +3 healing magic level."
		},
		{
			"Runic Mastery",
			"If you use a rune, you have a 25% chance of increasing your magic\nlevel by 10%, or by 20% if you use a rune that can be created by\nyour vocation."
		},
		{
			"Healing Link",
			"If you heal someone with Nature's Embrace or Heal Friend, you\nalso heal yourself for 25% of the applied healing."
		},
		{
			"Guiding Presence",
			"Gain an aura that shares 100% of your mantra with members of your group."
		}
	},
	special_2 = {
		{
			"Battle Healing",
			"Healing Spells have 10% increased healing. This bonus is tripled when wearing a shield."
		},
		{
			"Ballistic Mastery",
			"The critical extra damage for attacks with a crossbow is increased\nby 10%. While wielding a bow your attacks and spells treat the\ntargets physical and holy sensitivity as being 4% higher."
		},
		{
			"Focus Mastery",
			"Increases the damage of your next damage spell by 35% within 12\nseconds after casting a focus spell. Reduces the group cooldown\nof focus spells by 2 seconds."
		},
		{
			"Runic Mastery",
			"If you use a rune, you have a 25% chance of increasing your magic\nlevel by 10%, or by 20% if you use a rune that can be created by\nyour vocation."
		},
		{
			"Sanctuary",
			"Consuming Harmony creates a field lasting 5 seconds, increasing your damage and healing done by 2% for each Harmony consumed. It also increases the damage you deal to adjacent enemies and the healing you do to adjacent allies by 10%."
		}
	},
	health = {
		3,
		2,
		1,
		1,
		2
	},
	mana = {
		1,
		3,
		6,
		6,
		2
	},
	spell_1 = {
		6,
		21
	},
	spell_2 = {
		8,
		24
	},
	capacity = {
		5,
		4,
		2,
		2,
		5
	},
	spell_3 = {
		11,
		26
	},
	spell_4 = {
		13,
		29
	},
	spell_5 = {
		16,
		31
	}
}
WheelBonus = {
	[0] = {
		conviction = "special_1",
		dedication = "lifemana",
		domain = 1,
		maxPoints = 200
	},
	{
		conviction = "manaleech",
		dedication = "mitigation",
		domain = 1,
		maxPoints = 150
	},
	{
		modType = 1,
		conviction = "vessel",
		dedication = "health",
		domain = 1,
		maxPoints = 100
	},
	{
		conviction = "skill",
		dedication = "mana",
		domain = 2,
		maxPoints = 100
	},
	{
		modType = 2,
		conviction = "vessel",
		dedication = "health",
		domain = 2,
		maxPoints = 150
	},
	{
		conviction = "spell_1",
		dedication = "lifemana",
		domain = 2,
		maxPoints = 200
	},
	{
		modType = 2,
		conviction = "vessel",
		dedication = "mitigation",
		domain = 1,
		maxPoints = 150
	},
	{
		conviction = "spell_2",
		dedication = "health",
		domain = 1,
		maxPoints = 100
	},
	{
		conviction = "lifeleech",
		dedication = "mana",
		domain = 1,
		maxPoints = 75
	},
	{
		modType = 0,
		conviction = "vessel",
		dedication = "capacity",
		domain = 2,
		maxPoints = 75
	},
	{
		conviction = "spell_3",
		dedication = "mana",
		domain = 2,
		maxPoints = 100
	},
	{
		conviction = "manaleech",
		dedication = "health",
		domain = 2,
		maxPoints = 150
	},
	{
		conviction = "spell_4",
		dedication = "health",
		domain = 1,
		maxPoints = 100
	},
	{
		conviction = "skill",
		dedication = "mana",
		domain = 1,
		maxPoints = 75
	},
	{
		modType = 0,
		conviction = "vessel",
		dedication = "capacity",
		domain = 1,
		maxPoints = 50
	},
	{
		conviction = "spell_5",
		dedication = "mitigation",
		domain = 2,
		maxPoints = 50
	},
	{
		conviction = "lifeleech",
		dedication = "capacity",
		domain = 2,
		maxPoints = 75
	},
	{
		modType = 1,
		conviction = "vessel",
		dedication = "mana",
		domain = 2,
		maxPoints = 100
	},
	{
		modType = 1,
		conviction = "vessel",
		dedication = "mitigation",
		domain = 3,
		maxPoints = 100
	},
	{
		conviction = "manaleech",
		dedication = "health",
		domain = 3,
		maxPoints = 75
	},
	{
		conviction = "spell_1",
		dedication = "mana",
		domain = 3,
		maxPoints = 50
	},
	{
		modType = 0,
		conviction = "vessel",
		dedication = "health",
		domain = 4,
		maxPoints = 50
	},
	{
		conviction = "skill",
		dedication = "mitigation",
		domain = 4,
		maxPoints = 75
	},
	{
		conviction = "spell_2",
		dedication = "capacity",
		domain = 4,
		maxPoints = 100
	},
	{
		conviction = "lifeleech",
		dedication = "capacity",
		domain = 3,
		maxPoints = 150
	},
	{
		conviction = "spell_3",
		dedication = "mitigation",
		domain = 3,
		maxPoints = 100
	},
	{
		modType = 0,
		conviction = "vessel",
		dedication = "health",
		domain = 3,
		maxPoints = 75
	},
	{
		conviction = "manaleech",
		dedication = "mitigation",
		domain = 4,
		maxPoints = 75
	},
	{
		conviction = "spell_4",
		dedication = "capacity",
		domain = 4,
		maxPoints = 100
	},
	{
		modType = 2,
		conviction = "vessel",
		dedication = "mana",
		domain = 4,
		maxPoints = 150
	},
	{
		conviction = "spell_5",
		dedication = "lifemana",
		domain = 3,
		maxPoints = 200
	},
	{
		modType = 2,
		conviction = "vessel",
		dedication = "capacity",
		domain = 3,
		maxPoints = 150
	},
	{
		conviction = "skill",
		dedication = "mitigation",
		domain = 3,
		maxPoints = 100
	},
	{
		modType = 1,
		conviction = "vessel",
		dedication = "capacity",
		domain = 4,
		maxPoints = 100
	},
	{
		conviction = "lifeleech",
		dedication = "mana",
		domain = 4,
		maxPoints = 150
	},
	{
		conviction = "special_2",
		dedication = "lifemana",
		domain = 4,
		maxPoints = 200
	}
}
WheelDomainOrder = {
	[0] = {
		15,
		14,
		9,
		13,
		8,
		3,
		7,
		2,
		1
	},
	{
		16,
		10,
		17,
		4,
		11,
		18,
		5,
		12,
		6
	},
	{
		21,
		20,
		27,
		19,
		26,
		33,
		25,
		32,
		31
	},
	{
		22,
		23,
		28,
		24,
		29,
		34,
		30,
		35,
		36
	}
}
