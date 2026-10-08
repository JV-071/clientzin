PlayerStates = {
	Rewards = 30,
	Mentor = 536870912,
	Powerless = 268435456,
	Agony = 134217728,
	NewManaShield = 67108864,
	GoshnarTaint5 = 33554432,
	GoshnarTaint4 = 16777216,
	GoshnarTaint3 = 8388608,
	GoshnarTaint2 = 4194304,
	GoshnarTaint1 = 2097152,
	Feared = 1048576,
	Rooted = 524288,
	GreaterHex = 262144,
	IntenseHex = 131072,
	LesserHex = 65536,
	Bleeding = 32768,
	Pigeon = 16384,
	Pz = 16384,
	PzBlock = 8192,
	RedSwords = 8192,
	PartyBuff = 4096,
	Cursed = 2048,
	Dazzled = 1024,
	Freezing = 512,
	Drowning = 256,
	Swords = 128,
	Haste = 64,
	Paralyze = 32,
	ManaShield = 16,
	Drunk = 8,
	Energy = 4,
	Burn = 2,
	Poison = 1,
	None = 0
}
Icons = {}
Icons[PlayerStates.Poison] = {
	clip = 1,
	id = "condition_poisoned",
	tooltip = tr("You are poisoned")
}
Icons[PlayerStates.Burn] = {
	clip = 2,
	id = "condition_burning",
	tooltip = tr("You are burning")
}
Icons[PlayerStates.Energy] = {
	clip = 3,
	id = "condition_electrified",
	tooltip = tr("You are electrified")
}
Icons[PlayerStates.Drunk] = {
	clip = 4,
	id = "condition_drunk",
	tooltip = tr("You are drunk")
}
Icons[PlayerStates.ManaShield] = {
	clip = 5,
	id = "condition_magic_shield",
	tooltip = tr("You are protected by a magic shield")
}
Icons[PlayerStates.Paralyze] = {
	clip = 6,
	id = "condition_slowed",
	tooltip = tr("You are paralysed")
}
Icons[PlayerStates.Haste] = {
	clip = 7,
	id = "condition_haste",
	tooltip = tr("You are hasted")
}
Icons[PlayerStates.Swords] = {
	clip = 8,
	id = "condition_logout_block",
	tooltip = tr("You may not logout during a fight")
}
Icons[PlayerStates.Drowning] = {
	clip = 9,
	id = "condition_drowning",
	tooltip = tr("You are drowning")
}
Icons[PlayerStates.Freezing] = {
	clip = 10,
	id = "condition_freezing",
	tooltip = tr("You are freezing")
}
Icons[PlayerStates.Dazzled] = {
	clip = 11,
	id = "condition_dazzled",
	tooltip = tr("You are dazzled")
}
Icons[PlayerStates.Cursed] = {
	clip = 12,
	id = "condition_cursed",
	tooltip = tr("You are cursed")
}
Icons[PlayerStates.PartyBuff] = {
	clip = 13,
	id = "condition_strengthened",
	tooltip = tr("You are strengthened")
}
Icons[PlayerStates.RedSwords] = {
	clip = 14,
	id = "condition_RedSwords",
	tooltip = tr("You may not logout or enter a protection zone")
}
Icons[PlayerStates.Pigeon] = {
	clip = 15,
	id = "condition_Pigeon",
	tooltip = tr("You are within a protection zone")
}
Icons[PlayerStates.Bleeding] = {
	clip = 16,
	id = "condition_Bleeding",
	tooltip = tr("You are Bleeding")
}
Icons[PlayerStates.LesserHex] = {
	clip = 17,
	id = "condition_LesserHex",
	tooltip = tr("You are LesserHex")
}
Icons[PlayerStates.IntenseHex] = {
	clip = 18,
	id = "condition_IntenseHex",
	tooltip = tr("You are IntenseHex")
}
Icons[PlayerStates.GreaterHex] = {
	clip = 19,
	id = "condition_GreaterHex",
	tooltip = tr("You are GreaterHex")
}
Icons[PlayerStates.Rooted] = {
	clip = 20,
	id = "condition_Rooted",
	tooltip = tr("You are Rooted")
}
Icons[PlayerStates.Feared] = {
	clip = 21,
	id = "condition_Feared",
	tooltip = tr("You are Feared")
}
Icons[PlayerStates.GoshnarTaint1] = {
	clip = 22,
	id = "condition_GoshnarTaint1",
	tooltip = tr("You are GoshnarTaint")
}
Icons[PlayerStates.GoshnarTaint2] = {
	clip = 23,
	id = "condition_GoshnarTaint2",
	tooltip = tr("You are GoshnarTaint")
}
Icons[PlayerStates.GoshnarTaint3] = {
	clip = 24,
	id = "condition_GoshnarTaint3",
	tooltip = tr("You are GoshnarTaint")
}
Icons[PlayerStates.GoshnarTaint4] = {
	clip = 25,
	id = "condition_GoshnarTaint4",
	tooltip = tr("You are GoshnarTaint")
}
Icons[PlayerStates.GoshnarTaint5] = {
	clip = 26,
	id = "condition_GoshnarTaint5",
	tooltip = tr("You are GoshnarTaint")
}
Icons[PlayerStates.NewManaShield] = {
	clip = 27,
	id = "condition_NewManaShield",
	tooltip = tr("You are NewManaShield")
}
Icons[PlayerStates.Agony] = {
	clip = 28,
	id = "condition_Agony",
	tooltip = tr("You are Agony")
}
Icons[PlayerStates.Powerless] = {
	clip = 29,
	id = "condition_Powerless",
	tooltip = tr("You are Powerless")
}
Icons[PlayerStates.Mentor] = {
	clip = 30,
	id = "condition_Mentor",
	tooltip = tr("You are Mentor")
}
Icons[PlayerStates.Rewards] = {
	image = "/images/game/creatures/player-state-flags-client",
	id = "condition_Rewards",
	clipRect = "0 0 9 9",
	tooltip = tr("Rewards")
}
Icons.hungry = {
	image = "/images/game/creatures/player-state-flags-client",
	id = "condition_hungry",
	clipRect = "18 0 9 9",
	tooltip = tr("You are hungry")
}
PlayerStateFlagsImage = "/images/game/creatures/player-state-flags"
PlayerStateFlagsClientImage = "/images/game/creatures/player-state-flags-client"
PlayerStateFlagsRottenBloodImage = "/images/game/creatures/player-state-flags-rotten-blood"
PlayerStatePlayerKillerFlagsImage = "/images/game/creatures/player-state-playerkiller-flags"
PlayerStateFlagGuildImage = "/images/game/creatures/hud/flags/guild"
SpecialConditionExtraIcons = {
	condition_restingarea = {
		id = "condition_restingarea",
		clipRect = "0 0 9 9",
		image = PlayerStateFlagsClientImage,
		tooltip = tr("You are within a resting area")
	},
	condition_hungry = {
		id = "condition_hungry",
		clipRect = "18 0 9 9",
		image = PlayerStateFlagsClientImage,
		tooltip = tr("You are hungry")
	},
	condition_goshnar_taint = {
		clip = 26,
		id = "condition_goshnar_taint",
		tooltip = tr("You are Goshnar's Taint")
	},
	condition_bakragore_taint = {
		id = "condition_bakragore_taint",
		clipRect = "72 0 9 9",
		image = PlayerStateFlagsRottenBloodImage,
		tooltip = tr("You are Bakragore's Taint")
	},
	skullyellow = {
		id = "skullyellow",
		clipRect = "0 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You have a yellow skull")
	},
	skullgreen = {
		id = "skullgreen",
		clipRect = "9 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You are in party mode")
	},
	skullwhite = {
		id = "skullwhite",
		clipRect = "18 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You have a white skull")
	},
	skullred = {
		id = "skullred",
		clipRect = "27 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You have a red skull")
	},
	skullblack = {
		id = "skullblack",
		clipRect = "36 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You have a black skull")
	},
	skullorange = {
		id = "skullorange",
		clipRect = "45 0 9 9",
		image = PlayerStatePlayerKillerFlagsImage,
		tooltip = tr("You have an orange skull")
	},
	guildWar = {
		id = "guildWar",
		clipRect = "0 0 11 11",
		image = PlayerStateFlagGuildImage,
		tooltip = tr("You are in a guild war")
	}
}
SpecialConditions = {
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Poison,
		label = tr("Poisoned")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Burn,
		label = tr("Burning")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Energy,
		label = tr("Electrified")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Bleeding,
		label = tr("Bleeding")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Agony,
		label = tr("Agony")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Powerless,
		label = tr("Powerless")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Rooted,
		label = tr("Rooted")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Feared,
		label = tr("Feared")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Drunk,
		label = tr("Drunk")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.NewManaShield,
		label = tr("Magic Shield")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Paralyze,
		label = tr("Slowed")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Haste,
		label = tr("Haste")
	},
	{
		defaultBar = true,
		defaultHud = false,
		state = PlayerStates.Swords,
		label = tr("Logout Block")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Drowning,
		label = tr("Drowning")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Freezing,
		label = tr("Freezing")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Dazzled,
		label = tr("Dazzled")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.Cursed,
		label = tr("Cursed")
	},
	{
		defaultBar = true,
		defaultHud = false,
		state = PlayerStates.Mentor,
		label = tr("Mentor Other")
	},
	{
		defaultBar = true,
		defaultHud = false,
		state = PlayerStates.PartyBuff,
		label = tr("Strengthened")
	},
	{
		defaultBar = true,
		defaultHud = false,
		state = PlayerStates.RedSwords,
		label = tr("Protection Zone Block")
	},
	{
		defaultBar = true,
		defaultHud = false,
		state = PlayerStates.Pigeon,
		label = tr("In Protection Zone")
	},
	{
		id = "condition_restingarea",
		defaultBar = true,
		defaultHud = false,
		label = tr("Resting Area")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.LesserHex,
		label = tr("Lesser Hex")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.IntenseHex,
		label = tr("Intense Hex")
	},
	{
		defaultBar = true,
		defaultHud = true,
		state = PlayerStates.GreaterHex,
		label = tr("Greater Hex")
	},
	{
		id = "condition_goshnar_taint",
		defaultBar = true,
		defaultHud = false,
		label = tr("Goshnar's Taint")
	},
	{
		id = "condition_bakragore_taint",
		defaultBar = true,
		defaultHud = false,
		label = tr("Bakragore's Taint")
	},
	{
		id = "skullyellow",
		defaultBar = true,
		defaultHud = true,
		label = tr("Yellow Skull")
	},
	{
		id = "skullgreen",
		defaultBar = true,
		defaultHud = true,
		label = tr("Party Mode")
	},
	{
		id = "skullwhite",
		defaultBar = true,
		defaultHud = true,
		label = tr("White Skull")
	},
	{
		id = "skullred",
		defaultBar = true,
		defaultHud = true,
		label = tr("Red Skull")
	},
	{
		id = "skullblack",
		defaultBar = true,
		defaultHud = true,
		label = tr("Black Skull")
	},
	{
		id = "skullorange",
		defaultBar = true,
		defaultHud = true,
		label = tr("Orange Skull")
	},
	{
		id = "guildWar",
		defaultBar = true,
		defaultHud = false,
		label = tr("In Guild War")
	},
	{
		id = "condition_hungry",
		defaultBar = true,
		defaultHud = false,
		label = tr("Hungry")
	}
}

for _, cond in ipairs(SpecialConditions) do
	if cond.state then
		local info = Icons[cond.state]

		if info then
			cond.id = cond.id or info.id
			cond.info = info
		end
	elseif cond.id and SpecialConditionExtraIcons[cond.id] then
		cond.info = SpecialConditionExtraIcons[cond.id]
	end
end

function getSpecialConditionDefaults(id)
	for _, cond in ipairs(SpecialConditions) do
		if cond.id == id then
			return cond.defaultHud ~= false, cond.defaultBar ~= false
		end
	end

	return true, true
end

function isPlayerHungry(player)
	player = player or g_game.getLocalPlayer()

	if not player then
		return false
	end

	return getFoodRegenerationRemaining() <= 0
end

function isPlayerHungryConditionActive(player)
	player = player or g_game.getLocalPlayer()

	if not player then
		return false
	end

	return isPlayerHungry(player)
end

function buildFoodRegenerationTooltip(regenerationTime)
	if not regenerationTime or regenerationTime <= 0 then
		return tr("You are hungry.\nEat something to regenerate hit points and mana faster over time.")
	end

	local minutes = math.floor(regenerationTime / 60)
	local seconds = regenerationTime % 60

	return tr("You are regenerating hit points and mana faster for %d minutes and %d seconds", minutes, seconds)
end

function formatFoodRegenerationTime(regenerationTime)
	if not regenerationTime or regenerationTime <= 0 then
		return "00:00"
	end

	local hours = math.floor(regenerationTime / 3600)
	local minutes = math.floor(regenerationTime % 3600 / 60)

	return string.format("%02d:%02d", hours, minutes)
end

local foodRegenerationRemaining = 0
local foodRegenerationSyncedAt = 0
local foodRegenerationTickEvent
local FOOD_REGENERATION_TICK_MS = 5000

local function refreshFoodRegenerationUi(regenerationTime)
	if modules.game_skills and modules.game_skills.updateFoodRegenerationDisplay then
		modules.game_skills.updateFoodRegenerationDisplay(regenerationTime)
	end

	if Cyclopedia and Cyclopedia.updateFoodRegenerationDisplay then
		Cyclopedia.updateFoodRegenerationDisplay(regenerationTime)
	end
end

local function tickFoodRegeneration()
	refreshFoodRegenerationUi(getFoodRegenerationRemaining())
end

function getFoodRegenerationRemaining()
	if foodRegenerationRemaining <= 0 then
		return 0
	end

	local elapsed = g_clock.seconds() - foodRegenerationSyncedAt

	return math.max(0, foodRegenerationRemaining - elapsed)
end

function syncFoodRegenerationTime(regenerationTime)
	if regenerationTime == nil or regenerationTime < 0 then
		foodRegenerationRemaining = 0
	else
		foodRegenerationRemaining = regenerationTime
	end

	foodRegenerationSyncedAt = g_clock.seconds()
end

function startFoodRegenerationTicker()
	if foodRegenerationTickEvent then
		return
	end

	if not g_game.isOnline() then
		return
	end

	foodRegenerationTickEvent = cycleEvent(tickFoodRegeneration, FOOD_REGENERATION_TICK_MS)
end

function stopFoodRegenerationTicker()
	if foodRegenerationTickEvent then
		foodRegenerationTickEvent:cancel()

		foodRegenerationTickEvent = nil
	end

	foodRegenerationRemaining = 0
	foodRegenerationSyncedAt = 0
end

local RESTING_AREA_ZONE = 1
local lastRestingAreaZone
local restingAreaActive = false
local restingAreaTooltip

function updatePlayerRestingAreaState(zone, state, message)
	local changed = lastRestingAreaZone ~= zone

	lastRestingAreaZone = zone
	restingAreaActive = zone == RESTING_AREA_ZONE

	local tooltipChanged = false

	if message and message ~= "" and message ~= restingAreaTooltip then
		restingAreaTooltip = message
		tooltipChanged = true
	end

	return changed or tooltipChanged
end

function resetPlayerRestingAreaState()
	lastRestingAreaZone = nil
	restingAreaActive = false
	restingAreaTooltip = nil
end

function isPlayerInRestingArea()
	return restingAreaActive
end

function getPlayerRestingAreaTooltip()
	local info = SpecialConditionExtraIcons.condition_restingarea

	if restingAreaTooltip and restingAreaTooltip ~= "" then
		return restingAreaTooltip
	end

	return info and info.tooltip or tr("You are within a resting area")
end

function getPlayerRestingAreaIconInfo()
	local info = SpecialConditionExtraIcons.condition_restingarea

	if not info then
		return nil
	end

	local tooltip = getPlayerRestingAreaTooltip()

	if tooltip == info.tooltip then
		return info
	end

	return {
		id = info.id,
		image = info.image,
		clipRect = info.clipRect,
		clip = info.clip,
		tooltip = tooltip
	}
end

function getPlayerStateIconImage(info)
	return info.image or PlayerStateFlagsImage
end

function getPlayerStateIconClip(info, variant)
	if info.clipRect then
		return info.clipRect
	end

	if info.clip then
		return (info.clip - 1) * 9 .. " 0 9 9"
	end
end

function applyPlayerStateIcon(widget, info, variant)
	widget:setImageSource(getPlayerStateIconImage(info))
	widget:setImageClip(getPlayerStateIconClip(info, variant))
end

local var_0_11 = 9

function getBakragoreTaintIconInfo(numericValue)
	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 then
		return nil
	end

	if numericValue > var_0_11 then
		numericValue = var_0_11
	end

	local var_20_0 = numericValue
	local var_20_1 = false

	if numericValue >= 5 then
		var_20_1 = true
		var_20_0 = numericValue - 5
	end

	local var_20_2

	if var_20_1 and var_20_0 == 0 then
		var_20_2 = tr("Bakragore's Final Taint\nEnhanced experience and loot, without the regular penalties.")
	elseif var_20_1 then
		var_20_2 = tr("Bakragore's Taint (%d) and Final Taint", var_20_0)
	else
		var_20_2 = tr("Bakragore's Taint (%d)", var_20_0)
	end

	return {
		id = "condition_bakragore_taint",
		image = PlayerStateFlagsRottenBloodImage,
		clipRect = (numericValue - 1) * 9 .. " 0 9 9",
		tooltip = var_20_2
	}
end

combatStates = {
	CLIENT_COMBAT_ICE = 4,
	CLIENT_COMBAT_ENERGY = 3,
	CLIENT_COMBAT_EARTH = 2,
	CLIENT_COMBAT_FIRE = 1,
	CLIENT_COMBAT_PHYSICAL = 0,
	CLIENT_COMBAT_MANADRAIN = 10,
	CLIENT_COMBAT_LIFEDRAIN = 9,
	CLIENT_COMBAT_DROWN = 8,
	CLIENT_COMBAT_HEALING = 7,
	CLIENT_COMBAT_DEATH = 6,
	CLIENT_COMBAT_HOLY = 5
}
clientCombat = {}
clientCombat[combatStates.CLIENT_COMBAT_PHYSICAL] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-physical-resist",
	id = "Physical"
}
clientCombat[combatStates.CLIENT_COMBAT_FIRE] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-fire-resist",
	id = "Fire"
}
clientCombat[combatStates.CLIENT_COMBAT_EARTH] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-earth-resist",
	id = "Earth"
}
clientCombat[combatStates.CLIENT_COMBAT_ENERGY] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-energy-resist",
	id = "Energy"
}
clientCombat[combatStates.CLIENT_COMBAT_ICE] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-ice-resist",
	id = "Ice"
}
clientCombat[combatStates.CLIENT_COMBAT_HOLY] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-holy-resist",
	id = "Holy"
}
clientCombat[combatStates.CLIENT_COMBAT_DEATH] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-death-resist",
	id = "Death"
}
clientCombat[combatStates.CLIENT_COMBAT_HEALING] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-healing-resist",
	id = "Healing"
}
clientCombat[combatStates.CLIENT_COMBAT_DROWN] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-drowning-resist",
	id = "Drown"
}
clientCombat[combatStates.CLIENT_COMBAT_LIFEDRAIN] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-lifedrain-resist",
	id = "Lifedrain "
}
clientCombat[combatStates.CLIENT_COMBAT_MANADRAIN] = {
	path = "/game_cyclopedia/images/bestiary/icons/monster-icon-manadrain-resist",
	id = "Manadrain"
}

function getClientCombatElementName(combatType)
	if combatType == nil then
		combatType = combatStates.CLIENT_COMBAT_PHYSICAL
	end

	local element = clientCombat[combatType] or clientCombat[combatStates.CLIENT_COMBAT_PHYSICAL]

	if not element or not element.id then
		return tr("Physical")
	end

	return tr(element.id:match("^%s*(.-)%s*$"))
end

InventorySlotOther = 0
InventorySlotHead = 1
InventorySlotNeck = 2
InventorySlotBack = 3
InventorySlotBody = 4
InventorySlotRight = 5
InventorySlotLeft = 6
InventorySlotLeg = 7
InventorySlotFeet = 8
InventorySlotFinger = 9
InventorySlotAmmo = 10
InventorySlotPurse = 11
InventorySlotFirst = 1
InventorySlotLast = 10
InventoryNameById = {
	[InventorySlotHead] = "helmet",
	[InventorySlotNeck] = "amulet",
	[InventorySlotBack] = "backpack",
	[InventorySlotBody] = "armor",
	[InventorySlotRight] = "shield",
	[InventorySlotLeft] = "sword",
	[InventorySlotLeg] = "legs",
	[InventorySlotFeet] = "boots",
	[InventorySlotFinger] = "ring",
	[InventorySlotAmmo] = "tools"
}
vocationNamesByClientId = {
	[0] = "No Vocation",
	"Knight",
	"Paladin",
	"Sorcerer",
	"Druid",
	"Monk",
	nil,
	nil,
	nil,
	nil,
	nil,
	"Elite Knight",
	"Royal Paladin",
	"Master Sorcerer",
	"Elder Druid",
	"Exalted Monk"
}

function Player.isPartyLeader(self)
	local shield = self:getShield()

	return shield == ShieldWhiteYellow or shield == ShieldYellow or shield == ShieldYellowSharedExp or shield == ShieldYellowNoSharedExpBlink or shield == ShieldYellowNoSharedExp
end

function Player.isPartyMember(self)
	local shield = self:getShield()

	return shield == ShieldWhiteYellow or shield == ShieldYellow or shield == ShieldYellowSharedExp or shield == ShieldYellowNoSharedExpBlink or shield == ShieldYellowNoSharedExp or shield == ShieldBlueSharedExp or shield == ShieldBlueNoSharedExpBlink or shield == ShieldBlueNoSharedExp or shield == ShieldBlue
end

function Player.isPartySharedExperienceActive(self)
	local shield = self:getShield()

	return shield == ShieldYellowSharedExp or shield == ShieldYellowNoSharedExpBlink or shield == ShieldYellowNoSharedExp or shield == ShieldBlueSharedExp or shield == ShieldBlueNoSharedExpBlink or shield == ShieldBlueNoSharedExp
end

function Player.hasCondition(self, condition)
	return bit.band(self:getStates(), condition) > 0
end

function Player.isInProtectionZone(self)
	return self:hasCondition(PlayerStates.Pz)
end

function Player.hasVip(self, creatureName)
	for id, vip in pairs(g_game.getVips()) do
		if vip[1] == creatureName then
			return true
		end
	end

	return false
end

function Player.isMounted(self)
	local outfit = self:getOutfit()

	return outfit.mount ~= nil and outfit.mount > 0
end

function Player.toggleMount(self)
	if g_game.getFeature(GamePlayerMounts) then
		g_game.mount(not self:isMounted())
	end
end

function Player.mount(self)
	if g_game.getFeature(GamePlayerMounts) then
		g_game.mount(true)
	end
end

function Player.dismount(self)
	if g_game.getFeature(GamePlayerMounts) then
		g_game.mount(false)
	end
end

function Player.getItem(self, itemId, subType)
	return g_game.findPlayerItem(itemId, subType or -1)
end

function Player.getItems(self, itemId, subType)
	local subType = subType or -1
	local items = {}

	for i = InventorySlotFirst, InventorySlotLast do
		local item = self:getInventoryItem(i)
		local var_33_3 = type(item)

		if (var_33_3 == "userdata" or var_33_3 == "table") and item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
			table.insert(items, item)
		end
	end

	for i, container in pairs(g_game.getContainers()) do
		local var_33_4 = type(container)

		if var_33_4 == "userdata" or var_33_4 == "table" then
			for j, item in pairs(container:getItems()) do
				local var_33_5 = type(item)

				if (var_33_5 == "userdata" or var_33_5 == "table") and item:getId() == itemId and (subType == -1 or item:getSubType() == subType) then
					item.container = container

					table.insert(items, item)
				end
			end
		end
	end

	return items
end

function Player.getItemsCount(self, itemId)
	local items = self:getItems(itemId)
	local count = 0

	for i = 1, #items do
		count = count + items[i]:getCount()
	end

	return count
end

function Player.hasState(self, state, states)
	states = states or self:getStates()

	for i = 1, 32 do
		local pow = math.pow(2, i - 1)

		if states < pow then
			break
		end

		if bit.band(states, pow) == state then
			return true
		end
	end

	return false
end

function Player.getVocationNameByClientId(self)
	return vocationNamesByClientId[self:getVocation()] or "Unknown Vocation"
end

function Player.isPromoted(self)
	local promoted = {
		11,
		12,
		13,
		14,
		15
	}

	if table.contains(promoted, self:getVocation()) then
		return true
	end

	return false
end

function Player.getBlessingStatus(self)
	local blessings = self:getBlessings()
	local status = 1

	if Bit.hasBit(blessings, bit.lshift(1, 8)) then
		status = 3
	elseif Bit.hasBit(blessings, bit.lshift(1, 1)) then
		status = 2
	end

	return status
end
