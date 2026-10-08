KNIGHT = 1
PALADIN = 2
SORCERER = 3
DRUID = 4
MONK = 5
MediumPerkIconNames = {
	[0] = "Fire Resistance",
	"Energy Resistance",
	"Ice Resistance",
	"Earth Resistance",
	"Holy and Death Resistance",
	"Mana Leech",
	"Life Leech",
	"Weapon Skill Boost",
	"Battle Instinct",
	"Battle Healing",
	"Augmented Fierce Berserk|Aug. Fierce Berserk",
	"Augmented Intense Wound Cleansing|Aug. Intense Wound Cleansing",
	"Augmented Front Sweep|Aug. Front Sweep",
	"Augmented Groundshaker|Aug. Groundshaker",
	"Augmented Shield Slam|Aug. Shield Slam",
	"Distance Skill Boost",
	"Ballistic Mastery",
	"Ballistic Mastery",
	"Augmented Divine Caldera|Aug. Divine Caldera",
	"Augmented Divine Barrage|Aug. Divine Barrage",
	"Augmented Divine Dazzle|Aug. Divine Dazzle",
	"Augmented Strong Ethereal Spear|Aug. Strong Ethereal Spear",
	"Augmented Ethereal Barrage|Aug. Ethereal Barrage",
	"Focus Mastery",
	"Augmented Great Fire Wave|Aug. Great Fire Wave",
	"Augmented Energy Wave|Aug. Energy Wave",
	"Augmented Special Spells|Aug. Special Spells",
	"Augmented Focus Spells|Aug. Focus Spells",
	"Healing Link",
	"Augmented Forked Spells|Aug. Forked Spells",
	"Augmented Terra Wave|Aug. Terra Wave",
	"Augmented Strong Ice Wave|Aug. Strong Ice Wave",
	"Augmented Mass Healing|Aug. Mass Healing",
	"Augmented Heal Friend|Aug. Heal Friend",
	"Magic Skill Boost",
	"Runic Mastery",
	"Augmented Death Echo|Aug. Death Echo",
	"Vessel Resonance Top Left|VR Top Left",
	"Vessel Resonance Top Right|VR Top Right",
	"Vessel Resonance Bottom Left|VR Bottom Left",
	"Vessel Resonance Bottom Right|VR Bottom Right",
	"Sanctuary",
	"Guiding Presence",
	"Fist Fighting Skill Boost",
	"Augmented Thousand Fist Blows|Aug. Thousand Fist Blows",
	"Augmented Mass Spirit Mend|Aug. Mass Spirit Mend",
	"Augmented Mystic Repulse|Aug. Mystic Repulse",
	"Augmented Chained Penance|Aug. Chained Penance",
	"Augmented Flurry of Blows|Aug. Flurry of Blows"
}

function mediumPerkIconRect(iconIndex)
	return iconIndex * 30 .. " 0 30 30"
end

function getSupremeModIconClip(modID)
	return modID * 35 .. " 0 35 35"
end

GemEnums = {
	GUARDIAN = 1,
	LESSER = 0,
	GREATER = 2
}
GemDomains = {
	RED = 1,
	GREEN = 0,
	PURPLE = 3,
	ACQUA = 2
}
GemVocations = {
	[KNIGHT] = {
		[GemEnums.LESSER] = {
			id = 44602,
			name = "Lesser Guardian Gem (x 0)"
		},
		[GemEnums.GUARDIAN] = {
			id = 44603,
			name = "Guardian Gem (x 0)"
		},
		[GemEnums.GREATER] = {
			id = 44604,
			name = "Greater Guardian Gem (x 0)"
		}
	},
	[PALADIN] = {
		[GemEnums.LESSER] = {
			id = 44605,
			name = "Lesser Marksman Gem (x 0)"
		},
		[GemEnums.GUARDIAN] = {
			id = 44606,
			name = "Marksman Gem (x 0)"
		},
		[GemEnums.GREATER] = {
			id = 44607,
			name = "Greater Marksman Gem (x 0)"
		}
	},
	[SORCERER] = {
		[GemEnums.LESSER] = {
			id = 44608,
			name = "Lesser Sage Gem (x 0)"
		},
		[GemEnums.GUARDIAN] = {
			id = 44609,
			name = "Sage Gem (x 0)"
		},
		[GemEnums.GREATER] = {
			id = 44610,
			name = "Greater Sage Gem (x 0)"
		}
	},
	[DRUID] = {
		[GemEnums.LESSER] = {
			id = 44611,
			name = "Lesser Mystic Gem (x 0)"
		},
		[GemEnums.GUARDIAN] = {
			id = 44612,
			name = "Mystic Gem (x 0)"
		},
		[GemEnums.GREATER] = {
			id = 44613,
			name = "Greater Mystic Gem (x 0)"
		}
	},
	[MONK] = {
		[GemEnums.LESSER] = {
			id = 49371,
			name = "Lesser Spiritualist Gem (x 0)"
		},
		[GemEnums.GUARDIAN] = {
			id = 49372,
			name = "Spiritualist Gem (x 0)"
		},
		[GemEnums.GREATER] = {
			id = 49373,
			name = "Greater Spiritualist Gem (x 0)"
		}
	}
}
RegularGemDescription = {
	[0] = {
		type1 = "defense",
		bonus1 = 1,
		text = "Physical Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 1,
		text = "Holy Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 1,
		text = "Death Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 2,
		text = "Fire Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 2,
		text = "Earth Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 2,
		text = "Ice Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 2,
		text = "Energy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1.5,
		type1 = "defense",
		bonus2 = -1,
		text = "Holy Resistance\n-1% Death Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1.5,
		type1 = "defense",
		bonus2 = -1,
		text = "Death Resistance\n-1% Holy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Fire Resistance\nEarth Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Fire Resistance\nIce Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Fire Resistance\nEnergy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Earth Resistance\nIce Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Earth Resistance\nEnergy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 1,
		type1 = "defense",
		bonus2 = 1,
		text = "Ice Resistance\nEnergy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Fire Resistance\n-2% Earth Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Fire Resistance\n-2% Ice Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Fire Resistance\n-2% Energy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Earth Resistance\n-2% Fire Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Earth Resistance\n-2% Ice Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Earth Resistance\n-2% Energy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Ice Resistance\n-2% Earth Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Ice Resistance\n-2% Fire Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Ice Resistance\n-2% Energy Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Energy Resistance\n-2% Earth Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Energy Resistance\n-2% Ice Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = -1,
		text = "Energy Resistance\n-2% Fire Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 3,
		text = "Mana Drain Resistance"
	},
	{
		type1 = "defense",
		bonus1 = 3,
		text = "Life Drain Resistance"
	},
	{
		type2 = "defense",
		bonus1 = 3,
		type1 = "defense",
		bonus2 = 3,
		text = "Mana Drain Resistance\nLife Drain Resistance"
	},
	{
		type1 = "mitigation",
		bonus1 = 20,
		text = "Mitigation Multiplier",
		tooltip = "Increases your mitigation multiplicatively."
	},
	{
		type1 = "mana",
		step = 100,
		text = "+@ Hit Points"
	},
	{
		type1 = "mana",
		type2 = "capacity",
		text = "+@ Mana\n+# Capacity",
		step = 50
	},
	{
		type1 = "mana",
		type2 = "defense",
		text = "+@ Mana\nFire Resistance",
		step = 50
	},
	{
		type1 = "mana",
		type2 = "defense",
		text = "+@ Mana\nEnergy Resistance",
		step = 50
	},
	{
		type1 = "mana",
		type2 = "defense",
		text = "+@ Mana\nEarth Resistance",
		step = 50
	},
	{
		type1 = "mana",
		type2 = "defense",
		text = "+@ Mana\nIce Resistance",
		step = 50
	},
	{
		type1 = "mana",
		step = 100,
		text = "+@ Mana"
	},
	{
		type1 = "life",
		type2 = "defense",
		text = "+@ Hit Points\nFire Resistance",
		step = 50
	},
	{
		type1 = "life",
		type2 = "defense",
		text = "+@ Hit Points\nEnergy Resistance",
		step = 50
	},
	{
		type1 = "life",
		type2 = "defense",
		text = "+@ Hit Points\nEarth Resistance",
		step = 50
	},
	{
		type1 = "life",
		type2 = "defense",
		text = "+@ Hit Points\nIce Resistance",
		step = 50
	},
	{
		type1 = "life",
		type2 = "mana",
		text = "+@ Hit Points\n+# Mana",
		step = 50
	},
	{
		type1 = "life",
		type2 = "capacity",
		text = "+@ Hit Points\n+# Capacity",
		step = 50
	},
	{
		type1 = "capacity",
		type2 = "defense",
		text = "+@ Capacity\nFire Resistance",
		step = 50
	},
	{
		type1 = "capacity",
		type2 = "defense",
		text = "+@ Capacity\nEnergy Resistance",
		step = 50
	},
	{
		type1 = "capacity",
		type2 = "defense",
		text = "+@ Capacity\nEarth Resistance",
		step = 50
	},
	{
		type1 = "capacity",
		type2 = "defense",
		text = "+@ Capacity\nIce Resistance",
		step = 50
	},
	{
		type1 = "capacity",
		step = 100,
		text = "+@ Capacity"
	}
}
SupremeGemDescription = {
	[0] = {
		text = "+0.28% Dodge"
	},
	{
		text = "+2% Critical Extra Damage"
	},
	{
		text = "+2% Life Leech"
	},
	{
		text = "+0.8% Mana Leech"
	},
	{
		text = "Aug. Ultimate Healing\n+5% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 1,
		text = "RM Gift of Life"
	},
	{
		text = "Aug. Avatar of Steel\n-900s Cooldown",
		tooltip = "-900s Cooldown"
	},
	{
		text = "Aug. Executioner's Throw\n-2s Cooldown",
		tooltip = "-2s Cooldown"
	},
	{
		text = "Aug. Executioner's Throw\n+6% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Executioner's Throw\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Fierce Berserk\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Fierce Berserk\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Berserk\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Berserk\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Front Sweep\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Front Sweep\n12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Groundshaker\n+6.5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Groundshaker\n12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Annihilation\n+12% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Annihilation\n15% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Fair Wound Cleasing\n+10% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 4,
		text = "RM Avatar of Steel"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 2,
		text = "RM Executioner's Throw"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 3,
		text = "RM Combat Mastery"
	},
	{
		text = "Aug. Avatar of Light\n-900s Cooldown",
		tooltip = "-900s Cooldown"
	},
	{
		text = "Aug. Divine Dazzle\n-4s Cooldown",
		tooltip = "-4s Cooldown"
	},
	{
		text = "Aug. Divine Grenade\n+6% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Divine Grenade\n12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Divine Caldera\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Divine Caldera\n8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Divine Barrage\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Divine Barrage\n12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Ethereal Barrage\n+10% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Ethereal Barrage\n15% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Strong Ethereal Spear\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Strong Ethereal Spear\n12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Divine Empowerment\n-3s Cooldown",
		tooltip = "-6s Cooldown"
	},
	{
		text = "Aug. Divine Grenade\n-1s Cooldown",
		tooltip = "-2s Cooldown"
	},
	{
		text = "Aug. Salvation\n+6 Base Healing",
		tooltip = "+6 Base Healing"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 4,
		text = "RM Avatar of Light"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 2,
		text = "RM Divine Grenade"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 3,
		text = "RM Divine Empowerment"
	},
	{
		text = "Aug. Avatar of Storm\n-900s Cooldown",
		tooltip = "-900s Cooldown"
	},
	{
		text = "Aug. Energy Wave\n-1s Cooldown",
		tooltip = "-1s Cooldown"
	},
	{
		text = "Aug. Great Death Beam\n+10% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Great Death Beam\n+15% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Hell's Core\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Hell's Core\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Energy Wave\n5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Energy Wave\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Great Fire Wave\n5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Great Fire Wave\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Rage of the Skies\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Rage of the Skies\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Great Energy Beam\n+10% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Great Energy Beam\n+15% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 4,
		text = "RM Avatar of Storm"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 2,
		text = "RM Beaam Mastery"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 3,
		text = "RM Lord of Destruction"
	},
	{
		text = "Aug. Avatar of Nature\n-900s Cooldown",
		tooltip = "-900s Cooldown"
	},
	{
		text = "Aug. Nature's Embrace\n-10s Cooldown",
		tooltip = "-10s Cooldown"
	},
	{
		text = "Aug. Terra Burst\n+7% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Terra Burst\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Ice Burst\n+7% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Ice Burst\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Eternal Winter\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Eternal Winter\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Terra Wave\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Terra Wave\n+12% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Strong Ice Wave\n+8% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Strong Ice Wave\n+15% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Heal Friend\n+5% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		text = "Aug. Mass Healing\n+5% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 4,
		text = "RM Avatar of Nature"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 2,
		text = "RM Blessing of the Groove"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 3,
		text = "RM Twin Burst"
	},
	{
		text = "Aug. Avatar of Balance\n-900s Cooldown",
		tooltip = "-900s Cooldown"
	},
	{
		text = "Aug. Spirit Mend\n+9% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		text = "Aug. Spiritual Outburst\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Spiritual Outburst\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Forceful Uppercut\n+10% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Forceful Uppercut\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Flurry of Blows\n+6.5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Flurry of Blows\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Greater Flurry of Blows\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Greater Flurry of Blows\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Sweeping Takedown\n+5% Base Damage",
		tooltip = "+%s%% Base Damage"
	},
	{
		text = "Aug. Sweeping Takedown\n+8% Critical Extra Damage",
		tooltip = "Adds %s%% critical extra damage for this spell and grant a 10%%\nchance (non-cumulative) for a critical hit."
	},
	{
		text = "Aug. Focus Serenity\n-150s Cooldown",
		tooltip = "-150s Cooldown"
	},
	{
		text = "Aug. Focus Harmony\n-30s Cooldown",
		tooltip = "-30s Cooldown"
	},
	{
		text = "Aug. Mass Spirit Mend\n+5% Base Healing",
		tooltip = "+%s%% Base Healing"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 4,
		text = "RM Avatar of Balance"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 2,
		text = "RM Spiritual Outburst"
	},
	{
		tooltip = "The Revelation Mastery bonus counts towards the promotion points\ndistributed in the domain of the corresponding Revelation Perk.",
		extraPoints = 150,
		domain = 3,
		text = "RM Ascetic"
	}
}
lesserResources = {
	[0] = {
		price = 2000000,
		fragment = 5
	},
	{
		price = 5000000,
		fragment = 15
	},
	{
		price = 30000000,
		fragment = 30
	}
}
greaterResources = {
	[0] = {
		price = 5000000,
		fragment = 5
	},
	{
		price = 12500000,
		fragment = 15
	},
	{
		price = 75000000,
		fragment = 30
	}
}
bonusStep = {
	[KNIGHT] = {
		mana = 1,
		life = 3,
		capacity = 5
	},
	[PALADIN] = {
		mana = 3,
		life = 2,
		capacity = 4
	},
	[SORCERER] = {
		mana = 6,
		life = 1,
		capacity = 2
	},
	[DRUID] = {
		mana = 6,
		life = 1,
		capacity = 2
	},
	[MONK] = {
		mana = 2,
		life = 2,
		capacity = 4
	}
}
FlatSupremeMods = {
	[0] = {
		tooltip = "+%s%% Dodge",
		desc = "Dodge",
		baseI = 0.28
	},
	{
		tooltip = "+%s%% Critical Extra Damage",
		desc = "Critical Extra Damage",
		baseI = 2
	},
	{
		tooltip = "+%s%% Life Leech",
		desc = "Life Leech",
		baseI = 2
	},
	{
		tooltip = "+%s%% Mana Leech",
		desc = "Mana Leech",
		baseI = 0.8
	},
	{
		tooltip = "+%s%% Base Healing",
		showDesc = true,
		desc = "Aug. Ultimate Healing",
		baseI = 5
	},
	{
		showDesc = true,
		domain = 0,
		baseI = 150,
		tooltip = "+%s Gift of Life",
		desc = "Revelation Mastery"
	}
}
BasicMods = {
	[0] = {
		tooltip = "+%s%% Physical Resistance",
		baseI = 1
	},
	{
		tooltip = "+%s%% Holy Resistance",
		baseI = 1
	},
	{
		tooltip = "+%s%% Death Resistance",
		baseI = 1
	},
	{
		tooltip = "+%s%% Fire Resistance",
		baseI = 2
	},
	{
		tooltip = "+%s%% Earth Resistance",
		baseI = 2
	},
	{
		tooltip = "+%s%% Ice Resistance",
		baseI = 2
	},
	{
		tooltip = "+%s%% Energy Resistance",
		baseI = 2
	},
	{
		tooltip = "+%s%% Holy Resistance\n-1%% Death Resistance",
		baseI = 1.5
	},
	{
		tooltip = "+%s%% Death Resistance\n-1%% Holy Resistance",
		baseI = 1.5
	},
	{
		tooltip = "+%s%% Fire Resistance\n+%s%% Earth Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Fire Resistance\n+%s%% Ice Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Fire Resistance\n+%s%% Energy Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Earth Resistance\n+%s%% Ice Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Earth Resistance\n+%s%% Energy Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Ice Resistance\n+%s%% Energy Resistance",
		baseII = 1,
		baseI = 1
	},
	{
		tooltip = "+%s%% Fire Resistance\n-2%% Earth Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Fire Resistance\n-2%% Ice Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Fire Resistance\n-2%% Energy Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Earth Resistance\n-2%% Fire Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Earth Resistance\n-2%% Ice Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Earth Resistance\n-2%% Energy Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Ice Resistance\n-2%% Earth Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Ice Resistance\n-2%% Fire Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Ice Resistance\n-2%% Energy Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Energy Resistance\n-2%% Earth Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Energy Resistance\n-2%% Ice Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Energy Resistance\n-2%% Fire Resistance",
		baseII = -2,
		baseI = 3
	},
	{
		tooltip = "+%s%% Mana Drain Resistance",
		baseI = 3
	},
	{
		tooltip = "+%s%% Life Drain Resistance",
		baseI = 3
	},
	{
		tooltip = "+%s%% Mana Drain Resistance\n+%s%% Life Drain Resistance",
		baseII = 1.5,
		baseI = 1.5
	},
	{
		tooltip = "+%s%% Mitigation Multiplier",
		baseI = 20
	},
	{
		baseStepI = 100,
		tooltip = "+%s Hit Points",
		stepTypeI = "health"
	},
	[33] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Mana\n+%s%% Fire Resistance",
		stepTypeI = "mana"
	},
	[34] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Mana\n+%s%% Energy Resistance",
		stepTypeI = "mana"
	},
	[35] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Mana\n+%s%% Earth Resistance",
		stepTypeI = "mana"
	},
	[36] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Mana\n+%s%% Ice Resistance",
		stepTypeI = "mana"
	},
	[37] = {
		baseStepI = 100,
		tooltip = "+%s Mana",
		stepTypeI = "mana"
	},
	[38] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Health\n+%s%% Fire Resistance",
		stepTypeI = "health"
	},
	[39] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Health\n+%s%% Energy Resistance",
		stepTypeI = "health"
	},
	[40] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Health\n+%s%% Earth Resistance",
		stepTypeI = "health"
	},
	[41] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Health\n+%s%% Ice Resistance",
		stepTypeI = "health"
	},
	[44] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Capacity\n+%s%% Fire Resistance",
		stepTypeI = "capacity"
	},
	[45] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Capacity\n+%s%% Energy Resistance",
		stepTypeI = "capacity"
	},
	[46] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Capacity\n+%s%% Earth Resistance",
		stepTypeI = "capacity"
	},
	[47] = {
		baseStepI = 50,
		baseII = 1,
		tooltip = "+%s Capacity\n+%s%% Ice Resistance",
		stepTypeI = "capacity"
	},
	[48] = {
		baseStepI = 100,
		tooltip = "+%s Capacity",
		stepTypeI = "capacity"
	}
}
VocationSupremeMods = {
	[8] = {
		[6] = {
			type = "cooldown",
			desc = "Aug. Avatar of Steel",
			tooltip = "-900s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[7] = {
			type = "cooldown",
			desc = "Aug. Executioner's Throw",
			tooltip = "-2s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[8] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Executioner's Throw",
			baseI = 6
		},
		[9] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Executioner's Throw",
			baseI = 12
		},
		[10] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Fierce Berserk",
			baseI = 5
		},
		[11] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Fierce Berserk",
			baseI = 8
		},
		[12] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Berserk",
			baseI = 5
		},
		[13] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Berserk",
			baseI = 12
		},
		[14] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Front Sweep",
			baseI = 8
		},
		[15] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Front Sweep",
			baseI = 12
		},
		[16] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Groundshaker",
			baseI = 6.5
		},
		[17] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Groundshaker",
			baseI = 12
		},
		[18] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Annihilation",
			baseI = 12
		},
		[19] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Annihilation",
			baseI = 15
		},
		[20] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Fair Wound Cleansing",
			baseI = 10
		},
		[21] = {
			showDesc = true,
			domain = 3,
			baseI = 150,
			tooltip = "+%s Avatar of Steel",
			desc = "Revelation Mastery"
		},
		[22] = {
			showDesc = true,
			domain = 1,
			baseI = 150,
			tooltip = "+%s Executioner's Throw",
			desc = "Revelation Mastery"
		},
		[23] = {
			showDesc = true,
			domain = 2,
			baseI = 150,
			tooltip = "+%s Combat Mastery",
			desc = "Revelation Mastery"
		}
	},
	[7] = {
		[24] = {
			type = "cooldown",
			desc = "Aug. Avatar of Light",
			tooltip = "-900s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[25] = {
			type = "cooldown",
			desc = "Aug. Divine Dazzle",
			tooltip = "-4s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[26] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Divine Grenade",
			baseI = 6
		},
		[27] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Divine Grenade",
			baseI = 12
		},
		[28] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Divine Caldera",
			baseI = 5
		},
		[29] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Divine Caldera",
			baseI = 8
		},
		[30] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Divine Barrage",
			baseI = 8
		},
		[31] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Divine Barrage",
			baseI = 12
		},
		[32] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Ethereal Barrage",
			baseI = 10
		},
		[33] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Ethereal Barrage",
			baseI = 15
		},
		[34] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Strong Ethereal Spear",
			baseI = 8
		},
		[35] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Strong Ethereal Spear",
			baseI = 12
		},
		[36] = {
			type = "cooldown",
			desc = "Aug. Divine Empowerment",
			tooltip = "-6s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[37] = {
			type = "cooldown",
			desc = "Aug. Divine Grenade",
			tooltip = "-2s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[38] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Salvation",
			baseI = 6
		},
		[39] = {
			showDesc = true,
			domain = 3,
			baseI = 150,
			tooltip = "+%s Avatar of Light",
			desc = "Revelation Mastery"
		},
		[40] = {
			showDesc = true,
			domain = 1,
			baseI = 150,
			tooltip = "+%s Divine Grenade",
			desc = "Revelation Mastery"
		},
		[41] = {
			showDesc = true,
			domain = 2,
			baseI = 150,
			tooltip = "+%s Divine Empowerment",
			desc = "Revelation Mastery"
		}
	},
	[5] = {
		[42] = {
			type = "cooldown",
			desc = "Aug. Avatar of Storm",
			tooltip = "-900s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[43] = {
			type = "cooldown",
			desc = "Aug. Energy Wave",
			tooltip = "-1s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[44] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Great Death Beam",
			baseI = 10
		},
		[45] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Great Death Beam",
			baseI = 15
		},
		[46] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Hell's Core",
			baseI = 8
		},
		[47] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Hell's Core",
			baseI = 12
		},
		[48] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Energy Wave",
			baseI = 5
		},
		[49] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Energy Wave",
			baseI = 12
		},
		[50] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Great Fire Wave",
			baseI = 5
		},
		[51] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Great Fire Wave",
			baseI = 8
		},
		[52] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Rage of the Skies",
			baseI = 8
		},
		[53] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Rage of the Skies",
			baseI = 12
		},
		[54] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Great Energy Beam",
			baseI = 10
		},
		[55] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Great Energy Beam",
			baseI = 15
		},
		[56] = {
			showDesc = true,
			domain = 3,
			baseI = 150,
			tooltip = "+%s Avatar of Storm",
			desc = "Revelation Mastery"
		},
		[57] = {
			showDesc = true,
			domain = 1,
			baseI = 150,
			tooltip = "+%s Beam Mastery",
			desc = "Revelation Mastery"
		},
		[58] = {
			showDesc = true,
			domain = 2,
			baseI = 150,
			tooltip = "+%s Lord of Destruction",
			desc = "Revelation Mastery"
		}
	},
	[6] = {
		[59] = {
			type = "cooldown",
			desc = "Aug. Avatar of Nature",
			tooltip = "-900s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[60] = {
			type = "cooldown",
			desc = "Aug. Nature's Embrace",
			tooltip = "-10s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[61] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Terra Burst",
			baseI = 7
		},
		[62] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Terra Burst",
			baseI = 12
		},
		[63] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Ice Burst",
			baseI = 7
		},
		[64] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Ice Burst",
			baseI = 12
		},
		[65] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Eternal Winter",
			baseI = 8
		},
		[66] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Eternal Winter",
			baseI = 12
		},
		[67] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Terra Wave",
			baseI = 5
		},
		[68] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Terra Wave",
			baseI = 12
		},
		[69] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Strong Ice Wave",
			baseI = 8
		},
		[70] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Strong Ice Wave",
			baseI = 15
		},
		[71] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Heal Friend",
			baseI = 5
		},
		[72] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Mass Healing",
			baseI = 5
		},
		[73] = {
			showDesc = true,
			domain = 3,
			baseI = 150,
			tooltip = "+%s Avatar of Nature",
			desc = "Revelation Mastery"
		},
		[74] = {
			showDesc = true,
			domain = 1,
			baseI = 150,
			tooltip = "+%s Blessing of the Grove",
			desc = "Revelation Mastery"
		},
		[75] = {
			showDesc = true,
			domain = 2,
			baseI = 150,
			tooltip = "+%s Twin Bursts",
			desc = "Revelation Mastery"
		}
	},
	[9] = {
		[76] = {
			type = "cooldown",
			desc = "Aug. Avatar of Balance",
			tooltip = "-900s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[77] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Spirit Mend",
			baseI = 6
		},
		[78] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Spiritual Outburst",
			baseI = 5
		},
		[79] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Spiritual Outburst",
			baseI = 8
		},
		[80] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Forceful Uppercut",
			baseI = 10
		},
		[81] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Forceful Uppercut",
			baseI = 8
		},
		[82] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Flurry of Blows",
			baseI = 6.5
		},
		[83] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Flurry of Blows",
			baseI = 8
		},
		[84] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Greater Flurry of Blows",
			baseI = 5
		},
		[85] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Greater Flurry of Blows",
			baseI = 8
		},
		[86] = {
			tooltip = "+%s%% Base Damage",
			showDesc = true,
			desc = "Aug. Sweeping Takedown",
			baseI = 5
		},
		[87] = {
			tooltip = "+%s%% Critical Extra Damage",
			showDesc = true,
			desc = "Aug. Sweeping Takedown",
			baseI = 8
		},
		[88] = {
			type = "cooldown",
			desc = "Aug. Focus Serenity",
			tooltip = "-150s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[89] = {
			type = "cooldown",
			desc = "Aug. Focus Harmony",
			tooltip = "-30s Cooldown\n+%s%% Momentum",
			showDesc = true,
			baseII = 0.33
		},
		[90] = {
			tooltip = "+%s%% Base Healing",
			showDesc = true,
			desc = "Aug. Mass Spirit Mend",
			baseI = 5
		},
		[91] = {
			showDesc = true,
			domain = 3,
			baseI = 150,
			tooltip = "+%s Avatar of Balance",
			desc = "Revelation Mastery"
		},
		[92] = {
			showDesc = true,
			domain = 1,
			baseI = 150,
			tooltip = "+%s Spiritual Outburst",
			desc = "Revelation Mastery"
		},
		[93] = {
			showDesc = true,
			domain = 2,
			baseI = 150,
			tooltip = "+%s Ascetic",
			desc = "Revelation Mastery"
		}
	}
}
GemStaticTooltips = {
	[0] = "You need at least %s gold to reveal gems of this quality.",
	"You have no unrevealed gems of this quality.",
	"You have no unrevealed gems of this quality.\nYou must be inside a temple to reveal gems.",
	"You can carry a maximum of 225 revealed gems. Destroy some to reveal more."
}
GemRevealPrice = {
	[GemEnums.LESSER] = 125000,
	[GemEnums.GUARDIAN] = 1000000,
	[GemEnums.GREATER] = 6000000
}
GemSwitchPrice = {
	[GemEnums.LESSER] = 125000,
	[GemEnums.GUARDIAN] = 250000,
	[GemEnums.GREATER] = 500000
}
VesselIndex = {
	[GemDomains.GREEN] = {
		2,
		6,
		14
	},
	[GemDomains.RED] = {
		4,
		9,
		17
	},
	[GemDomains.ACQUA] = {
		18,
		26,
		31
	},
	[GemDomains.PURPLE] = {
		21,
		29,
		33
	}
}
WheelIcons = {
	[KNIGHT] = {
		{
			miniIconRect = "32 0 16 16",
			iconRect = "240 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "210 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "360 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "420 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "390 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "330 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "210 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "300 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "360 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "210 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "420 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "390 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "330 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "300 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "210 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "270 0 30 30"
		}
	},
	[PALADIN] = {
		{
			miniIconRect = "32 0 16 16",
			iconRect = "510 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "450 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "660 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "630 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "600 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "570 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "450 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "540 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "660 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "450 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "630 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "600 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "570 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "540 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "450 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "480 0 30 30"
		}
	},
	[SORCERER] = {
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1050 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "810 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "780 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1080 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "750 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "720 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "810 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "780 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1080 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "750 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "720 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "690 0 30 30"
		}
	},
	[DRUID] = {
		{
			miniIconRect = "32 0 16 16",
			iconRect = "840 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "870 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "960 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "990 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "900 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "930 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "870 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "960 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "990 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "900 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "930 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1020 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1050 0 30 30"
		}
	},
	[MONK] = {
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1260 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1290 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1410 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1350 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1380 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1440 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1290 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1110 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1320 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1140 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1410 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1290 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1350 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1380 0 30 30"
		},
		{
			miniIconRect = "0 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "150 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1440 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1320 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1170 0 30 30"
		},
		{
			miniIconRect = "64 0 16 16",
			iconRect = "1290 0 30 30"
		},
		{
			miniIconRect = "48 0 16 16",
			iconRect = "1200 0 30 30"
		},
		{
			miniIconRect = "16 0 16 16",
			iconRect = "180 0 30 30"
		},
		{
			miniIconRect = "32 0 16 16",
			iconRect = "1230 0 30 30"
		}
	}
}
