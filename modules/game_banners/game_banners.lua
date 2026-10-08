bannersController = Controller:new()

local var_0_0 = "ui_drop_shadow"
local bannerQueue = {}
local var_0_2 = false
local gameBannerPanelWidget
local var_0_4
local animationEvents = {}
local var_0_6 = false
local var_0_7 = 355
local var_0_8 = 128
local BANNER_BODY_WIDTH = 289
local BANNER_BODY_HEIGHT = 88
local ANIM_FRAME_MS = 400
local var_0_12 = 100
local var_0_13 = 15
local var_0_14 = 3500
local var_0_15 = 7
local BACKDROP_MARGIN_LEFT = -74
local BACKDROP_MARGIN_TOP = 21
local var_0_18 = 73
local TEXT_MARGIN_RIGHT = 16
local IMAGE_BASE = "/images/game/banners/"
local SPELL_ICON_FILE = "/images/game/spells/spell-icons-32x32"
local SPELL_BORDER_ICON = "border-vocationinfo-spells"
local ANIM_FRAMES = {
	{
		frame = "backdrop-infobanner-anim1",
		width = 76
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 86
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 99
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 104
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 117
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 121
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 130
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 134
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 142
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 147
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 155
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 160
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 168
	},
	{
		frame = "backdrop-infobanner-anim2",
		width = 173
	},
	{
		frame = "backdrop-infobanner-anim3",
		width = 181
	},
	{
		frame = "backdrop-infobanner-anim3",
		width = 186
	},
	{
		frame = "backdrop-infobanner-anim3",
		width = 195
	},
	{
		frame = "backdrop-infobanner-anim3",
		width = 203
	},
	{
		frame = "backdrop-infobanner-anim3",
		width = 208
	},
	{
		frame = "backdrop-infobanner-anim4",
		width = 216
	},
	{
		frame = "backdrop-infobanner-anim4",
		width = 225
	},
	{
		frame = "backdrop-infobanner-anim5",
		width = 234
	},
	{
		frame = "backdrop-infobanner-anim5",
		width = 239
	},
	{
		frame = "backdrop-infobanner-anim5",
		width = 243
	},
	{
		frame = "backdrop-infobanner-anim5",
		width = 247
	},
	{
		frame = "backdrop-infobanner-anim6",
		width = 256
	},
	{
		frame = "backdrop-infobanner-anim6",
		width = 260
	},
	{
		frame = "backdrop-infobanner-anim6",
		width = 265
	},
	{
		frame = "backdrop-infobanner-anim6",
		width = 268
	},
	{
		frame = "backdrop-infobanner-anim6",
		width = 273
	},
	{
		frame = "backdrop-infobanner-anim7",
		width = 275
	}
}
local var_0_24 = #ANIM_FRAMES

for _, eventId in ipairs(ANIM_FRAMES) do
	eventId.path = IMAGE_BASE .. eventId.frame
end

local var_0_25 = {
	width = 0,
	y = 0,
	x = 0,
	height = BANNER_BODY_HEIGHT
}
local path
local var_0_27
local var_0_28
local var_0_29 = 1
local var_0_30 = 2
local var_0_31 = 3
local var_0_32 = 4
local var_0_33 = 5
local var_0_34 = 6
local var_0_35 = 7
local var_0_36 = 8
local var_0_37 = 9
local var_0_38 = 10
local var_0_39 = 11
local var_0_40 = 12
local eventType = 13
local var_0_42 = 14
local var_0_43 = 15
local var_0_44 = 100
local var_0_45 = 1
local var_0_46 = 4
local var_0_47 = 5
local var_0_48 = 6
local var_0_49 = 7
local var_0_50 = 8
local var_0_51 = 9
local var_0_52 = 10
local var_0_53 = 11
local var_0_54 = 12
local var_0_55 = 13
local var_0_56 = 14
local var_0_57 = 15
local var_0_58 = 16
local var_0_59 = 0
local COSMETIC_TYPE_OUTFIT = 1
local var_0_61 = 2
local COSMETIC_TYPE_MOUNT = 3
local var_0_63 = {
	legs = 39,
	body = 113,
	head = 95,
	feet = 15
}
local var_0_64 = {
	{
		icon = "icon-infobanner-skill-magic",
		name = "Magic Level"
	},
	{
		icon = "icon-infobanner-skill-sword",
		name = "Sword Fighting"
	},
	{
		icon = "icon-infobanner-skill-club",
		name = "Club Fighting"
	},
	{
		icon = "icon-infobanner-skill-axe",
		name = "Axe Fighting"
	},
	{
		icon = "icon-infobanner-skill-fist",
		name = "Fist Fighting"
	},
	{
		icon = "icon-infobanner-skill-distance",
		name = "Distance Fighting"
	},
	{
		icon = "icon-infobanner-skill-shielding",
		name = "Shielding"
	},
	{
		icon = "icon-infobanner-skill-fishing",
		name = "Fishing"
	}
}
local var_0_65 = {
	[var_0_45] = {
		description = "You defeated a boss creature.",
		title = "Boss Defeated",
		icon = "icon-infobanner-hint"
	},
	[var_0_46] = {
		description = "You assisted in defeating another player.",
		title = "Player Kill Assist",
		icon = "icon-infobanner-hint"
	},
	[var_0_47] = {
		description = "You defeated another player.",
		title = "Player Kill",
		icon = "icon-infobanner-hint"
	},
	[var_0_48] = {
		description = "You are attacking another player.",
		title = "Player Attacking",
		icon = "icon-infobanner-hint"
	},
	[var_0_49] = {
		description = "You discovered a hidden treasure.",
		title = "Treasure Found",
		icon = "icon-infobanner-unlock"
	},
	[var_0_50] = {
		description = "Your Gift of Life was triggered.",
		title = "Gift of Life",
		icon = "icon-infobanner-hint"
	},
	[var_0_51] = {
		description = "Only click once to attack your target.",
		title = "Stop Attack",
		icon = "icon-infobanner-hint"
	},
	[var_0_52] = {
		description = "Remove items before adding new ones.",
		title = "Capacity Limit",
		icon = "icon-infobanner-hint"
	},
	[var_0_53] = {
		description = "You have no arrow or bolt equipped.",
		title = "Out of Ammunition",
		icon = "icon-infobanner-hint"
	},
	[var_0_55] = {
		description = "You don't have enough soul points to cast this spell.",
		title = "Out of Soul Points",
		icon = "icon-infobanner-hint"
	},
	[var_0_54] = {
		description = "You are using a ranged auto- attack at melee distance.",
		title = "Target Too Close",
		icon = "icon-infobanner-hint"
	},
	[var_0_56] = {
		description = "Leave the village and set sail to start your real adventure.",
		title = "Off to New Shores",
		icon = "icon-infobanner-offtonewshores"
	},
	[var_0_57] = {
		description = "Completed task: Any creature.",
		title = "Weekly Task",
		icon = "icon-infobanner-weeklytask"
	},
	[var_0_58] = {
		description = "You now benefit from various new bonuses.",
		title = "Promotion Granted",
		icon = "icon-infobanner-promotion"
	}
}
local BannerTexts = {
	[var_0_30] = {
		description = "You have earned %s.",
		title = "New Achievement",
		icon = "icon-infobanner-achievements"
	},
	[var_0_31] = {
		description = "You have earned %s.",
		title = "Title Gained",
		icon = "icon-infobanner-title"
	},
	[var_0_32] = {
		description = "You gained hit points, mana, and capacity.",
		title = "Level %d",
		icon = "icon-infobanner-levelup"
	},
	[var_0_34] = {
		icon = "icon-infobanner-unlock",
		descriptionProgress = "You have progressed %s.",
		descriptionNew = "You have discovered %s.",
		titleProgress = "Bestiary Progress",
		titleNew = "New Bestiary"
	},
	[var_0_35] = {
		icon = "icon-infobanner-unlock",
		descriptionProgress = "You have progressed %s.",
		descriptionNew = "You have discovered %s.",
		titleProgress = "Bosstiary Progress",
		titleNew = "New Bosstiary"
	},
	[var_0_36] = {
		descriptionProgress = "You have begun %s",
		descriptionComplete = "You have finished %s",
		titleComplete = "Quest Complete",
		titleProgress = "Quest Started",
		icon = "icon-infobanner-quests"
	},
	[var_0_37] = {
		titleOutfit = "Outfit Unlocked",
		iconMount = "icon-infobanner-unlock",
		titleMount = "Mount Unlocked",
		description = "You have unlocked %s",
		titleAddon = "Addon Unlocked",
		iconAddon = "icon-infobanner-unlock"
	},
	[var_0_38] = {
		description = "You have improved %s",
		title = "Weapon Proficiency",
		icon = "icon-infobanner-unlock"
	},
	[var_0_39] = {
		description = "Completed task: %s",
		title = "Bounty Task",
		icon = "icon-infobanner-unlock"
	},
	[var_0_40] = {
		description = "Completed task: %s",
		title = "Weekly Task",
		icon = "icon-infobanner-weeklytask"
	},
	[eventType] = {
		description = "You have unlocked a new spell: %s.",
		title = "New Spell Unlocked",
		icon = "icon-infobanner-unlock"
	},
	[var_0_42] = {
		description = "You have received %d Charm Points.",
		title = "Echo Warden Killed",
		icon = "icon-infobanner-unlock"
	},
	[var_0_43] = {
		description = "%s",
		title = "Subarea Unlocked",
		icon = "icon-infobanner-pointofinterest"
	},
	[var_0_44] = {
		icon = "icon-infobanner-battlepass",
		descriptionDaily = "You completed a daily Battle Pass mission.",
		title = "Battle Pass",
		descriptionWeekly = "You completed a weekly Battle Pass mission."
	}
}

local function isInfoBannerEnabled()
	if not modules.client_options or not modules.client_options.getOption then
		return true
	end

	return modules.client_options.getOption("showInfoBanner") ~= false
end

local function var_0_68(name)
	if not name or name == "" then
		return tr("Unknown Creature")
	end

	return name:gsub("(%a)([%w']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)
end

local function formatBannerQuotedName(name)
	return "\"" .. var_0_68(name) .. "\""
end

local function var_0_70(arg_5_0)
	if not arg_5_0 or arg_5_0 == "" then
		return "\"\""
	end

	local var_5_0 = arg_5_0:lower()

	return "\"" .. var_5_0:sub(1, 1):upper() .. var_5_0:sub(2) .. "\""
end

local function creatureName(arg_6_0)
	if not arg_6_0 or arg_6_0 == "" then
		return "\"\""
	end

	return "\"" .. arg_6_0:lower() .. "\""
end

local function var_0_72(arg_7_0)
	if not arg_7_0 or arg_7_0 == "" then
		return tr("Unknown Creature")
	end

	local var_7_0 = arg_7_0:lower()

	return var_7_0:sub(1, 1):upper() .. var_7_0:sub(2)
end

local function var_0_73(numericValue)
	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 then
		return nil, nil
	end

	local raceData = g_things.getRaceData(numericValue)

	if not raceData or raceData.raceId == 0 then
		return nil, nil
	end

	local var_8_1 = raceData.name and raceData.name ~= "" and raceData.name or nil
	local var_8_2 = raceData.outfit and raceData.outfit.type and raceData.outfit or nil

	return var_8_1, var_8_2
end

local function var_0_74(numericValue, arg_9_1)
	numericValue = tonumber(numericValue) or 0
	arg_9_1 = tonumber(arg_9_1) or var_0_59

	if numericValue <= 0 then
		return nil
	end

	if arg_9_1 == COSMETIC_TYPE_MOUNT then
		return {
			type = numericValue
		}
	end

	return {
		type = numericValue,
		addons = arg_9_1,
		head = var_0_63.head,
		body = var_0_63.body,
		legs = var_0_63.legs,
		feet = var_0_63.feet
	}
end

local function getSpellBannerIconClip(spellId)
	if not SpellIcons or not Spells or not Spells.getImageClipNormal then
		return nil
	end

	local iconId = SpellIcons[spellId]

	if not iconId then
		return nil
	end

	return Spells.getImageClipNormal(iconId, "Default")
end

local function var_0_76(arg_11_0, ...)
	local var_11_0 = select(1, ...)
	local numericValue = tonumber(select(2, ...)) or 0
	local var_11_2 = BannerTexts[arg_11_0]
	local var_11_3, var_11_4 = var_0_73(var_11_0)

	var_11_3 = var_11_3 or tr("Unknown Creature")

	local var_11_5 = numericValue ~= 0

	return {
		title = var_11_5 and var_11_2.titleNew or var_11_2.titleProgress,
		description = string.format(var_11_5 and var_11_2.descriptionNew or var_11_2.descriptionProgress, formatBannerQuotedName(var_11_3)),
		icon = var_11_2.icon,
		iconOutfit = var_11_4
	}
end

local function var_0_77(arg_12_0, ...)
	local var_12_0 = select(1, ...)
	local var_12_1 = BannerTexts[arg_12_0]
	local var_12_2, var_12_3 = var_0_73(var_12_0)

	var_12_2 = var_12_2 or tr("Unknown Creature")

	return {
		title = var_12_1.title,
		description = string.format(var_12_1.description, formatBannerQuotedName(var_12_2)),
		icon = var_12_1.icon,
		iconOutfit = var_12_3
	}
end

local function var_0_78(arg_13_0, ...)
	local level = select(1, ...)
	local var_13_1 = BannerTexts[arg_13_0]
	local var_13_2 = var_0_73(level) or tr("Unknown Creature")

	return {
		title = var_13_1.title,
		description = string.format(var_13_1.description, var_0_72(var_13_2)),
		icon = var_13_1.icon
	}
end

local var_0_79 = {
	[var_0_29] = function(...)
		local var_14_0 = var_0_65[select(1, ...)]

		if not var_14_0 then
			return nil
		end

		return {
			title = var_14_0.title,
			description = var_14_0.description,
			icon = var_14_0.icon
		}
	end,
	[var_0_30] = function(...)
		local descriptionTemplate = BannerTexts[var_0_30]

		return {
			title = descriptionTemplate.title,
			description = string.format(descriptionTemplate.description, formatBannerQuotedName(select(1, ...) or "")),
			icon = descriptionTemplate.icon
		}
	end,
	[var_0_31] = function(...)
		local var_16_0 = BannerTexts[var_0_31]

		return {
			title = var_16_0.title,
			description = string.format(var_16_0.description, formatBannerQuotedName(select(1, ...) or "")),
			icon = var_16_0.icon
		}
	end,
	[var_0_32] = function(...)
		local var_17_0 = BannerTexts[var_0_32]

		return {
			title = string.format(var_17_0.title, select(1, ...) or 0),
			description = var_17_0.description,
			icon = var_17_0.icon
		}
	end,
	[var_0_33] = function(...)
		local var_18_0 = var_0_64[select(1, ...)]

		if not var_18_0 then
			return nil
		end

		local var_18_1 = select(2, ...) or 0

		return {
			title = var_18_0.name,
			description = string.format("Your skill has advanced to level %d", var_18_1),
			icon = var_18_0.icon
		}
	end,
	[var_0_34] = function(...)
		return var_0_76(var_0_34, ...)
	end,
	[var_0_35] = function(...)
		return var_0_76(var_0_35, ...)
	end,
	[var_0_36] = function(...)
		local var_21_0 = BannerTexts[var_0_36]
		local var_21_1 = (select(2, ...) or 0) ~= 0

		return {
			title = var_21_1 and var_21_0.titleComplete or var_21_0.titleProgress,
			description = string.format(var_21_1 and var_21_0.descriptionComplete or var_21_0.descriptionProgress, var_0_70(select(1, ...) or "")),
			icon = var_21_0.icon
		}
	end,
	[var_0_37] = function(...)
		local var_22_0, itemName, var_22_2 = ...
		local skinType

		skinType = tonumber(var_22_2) or var_0_59
		itemName = type(itemName) == "string" and itemName or ""

		local data = BannerTexts[var_0_37]
		local title = data.titleOutfit
		local icon = data.iconAddon

		if skinType == COSMETIC_TYPE_MOUNT then
			title = data.titleMount
			icon = data.iconMount
		elseif skinType == COSMETIC_TYPE_OUTFIT or skinType == var_0_61 then
			title = data.titleAddon
			itemName = string.format("%s (Addon %d)", itemName, skinType)
		end

		return {
			title = title,
			description = string.format(data.description, formatBannerQuotedName(itemName)),
			icon = icon,
			iconOutfit = var_0_74(var_22_0, skinType),
			iconOutfitIdle = skinType ~= COSMETIC_TYPE_MOUNT
		}
	end,
	[var_0_38] = function(...)
		local var_23_0 = select(1, ...) or 0
		local data = BannerTexts[var_0_38]

		return {
			title = data.title,
			description = string.format(data.description, creatureName(select(2, ...) or "")),
			icon = data.icon,
			iconItemId = var_23_0
		}
	end,
	[var_0_39] = function(...)
		return var_0_77(var_0_39, ...)
	end,
	[var_0_40] = function(...)
		return var_0_78(var_0_40, ...)
	end,
	[eventType] = function(...)
		local spellId = select(1, ...) or 0
		local data = BannerTexts[eventType]
		local spellName = tr("Unknown Spell")

		if Spells and Spells.getSpellDataById then
			local spellData = Spells.getSpellDataById(spellId)

			if spellData and spellData.name then
				spellName = spellData.name
			end
		end

		return {
			title = data.title,
			description = string.format(data.description, formatBannerQuotedName(spellName)),
			icon = data.icon,
			iconSpellClip = getSpellBannerIconClip(spellId)
		}
	end,
	[var_0_43] = function(...)
		local areaId = select(1, ...) or 0
		local data = BannerTexts[var_0_43]
		local areaName = tr("Unknown Area")

		if g_minimap and g_minimap.getCyclopediaAreaName then
			local name = g_minimap.getCyclopediaAreaName(areaId)

			if name and name ~= "" then
				areaName = name
			end
		end

		return {
			title = data.title,
			description = string.format(data.description, formatBannerQuotedName(areaName)),
			icon = data.icon
		}
	end,
	[var_0_42] = function(...)
		local var_28_0 = select(1, ...)
		local charmPoints = select(2, ...) or 0
		local data = BannerTexts[var_0_42]
		local unusedValue, getRaceOutfit = var_0_73(var_28_0)

		return {
			title = data.title,
			description = string.format(data.description, charmPoints),
			icon = data.icon,
			iconOutfit = getRaceOutfit
		}
	end,
	[var_0_44] = function(...)
		local numericValue = tonumber(select(1, ...)) or 0
		local var_29_1 = BannerTexts[var_0_44]

		return {
			title = var_29_1.title,
			description = numericValue ~= 0 and var_29_1.descriptionWeekly or var_29_1.descriptionDaily,
			icon = var_29_1.icon
		}
	end
}

local function var_0_80(arg_30_0, ...)
	local var_30_0 = var_0_79[arg_30_0]

	if not var_30_0 then
		return nil
	end

	return var_30_0(...)
end

local function bannerWidget()
	return gameBannerPanelWidget and not gameBannerPanelWidget:isDestroyed()
end

local function var_0_82(arg_32_0)
	if bannerWidget() and arg_32_0 then
		arg_32_0()
	end
end

local function var_0_83()
	for unusedValue, animationEvent in ipairs(animationEvents) do
		removeEvent(animationEvent)
	end

	animationEvents = {}
end

local function scheduleBannerEvent(callback, delay)
	local var_34_0 = scheduleEvent(function()
		for index, storedId in ipairs(animationEvents) do
			if storedId == eventId then
				table.remove(animationEvents, index)

				break
			end
		end

		callback()
	end, delay)

	table.insert(animationEvents, var_34_0)

	return var_34_0
end

local function var_0_85()
	if not bannerWidget() then
		var_0_4 = nil

		return nil
	end

	var_0_4 = {
		icon = gameBannerPanelWidget:recursiveGetChildById("bannerIcon"),
		creature = gameBannerPanelWidget:recursiveGetChildById("bannerIconCreature"),
		spell = gameBannerPanelWidget:recursiveGetChildById("bannerIconSpell"),
		spellBorder = gameBannerPanelWidget:recursiveGetChildById("bannerIconSpellBorder"),
		item = gameBannerPanelWidget:recursiveGetChildById("bannerIconItem"),
		clip = gameBannerPanelWidget:recursiveGetChildById("bannerClipPanel"),
		textClip = gameBannerPanelWidget:recursiveGetChildById("bannerTextClip"),
		content = gameBannerPanelWidget:recursiveGetChildById("bannerContentLayer"),
		backdropAnim = gameBannerPanelWidget:recursiveGetChildById("backdropBottomAnim"),
		mid = gameBannerPanelWidget:recursiveGetChildById("backdropMid"),
		top = gameBannerPanelWidget:recursiveGetChildById("backdropTop"),
		roll = gameBannerPanelWidget:recursiveGetChildById("rollAnim"),
		title = gameBannerPanelWidget:recursiveGetChildById("bannerTitle"),
		description = gameBannerPanelWidget:recursiveGetChildById("bannerDescription"),
		textPanel = gameBannerPanelWidget:recursiveGetChildById("textPanel")
	}

	return var_0_4
end

local function var_0_86()
	if var_0_4 then
		return var_0_4
	end

	return var_0_85()
end

local function destroyBannerWidget()
	var_0_83()

	if bannerWidget() then
		g_effects.cancelFade(gameBannerPanelWidget)
		gameBannerPanelWidget:destroy()
	end

	gameBannerPanelWidget = nil
	var_0_4 = nil
	var_0_6 = false
	path = nil
	var_0_27 = nil
	var_0_28 = nil
end

local function getBannerParent()
	if modules.game_interface and modules.game_interface.getMapPanel then
		return modules.game_interface.getMapPanel()
	end

	return rootWidget
end

local function setTextContentOpacity(opacity)
	local bannerTitle = var_0_86()

	if not bannerTitle then
		return
	end

	if bannerTitle.clip and bannerTitle.clip:isVisible() then
		bannerTitle.clip:raise()
	end

	if bannerTitle.textClip then
		bannerTitle.textClip:raise()
	end

	if bannerTitle.content then
		bannerTitle.content:raise()
	end

	if bannerTitle.icon then
		bannerTitle.icon:raise()
	end

	if bannerTitle.spellBorder and bannerTitle.spellBorder:isVisible() then
		bannerTitle.spellBorder:raise()
	end

	if bannerTitle.spell and bannerTitle.spell:isVisible() then
		bannerTitle.spell:raise()
	end

	if bannerTitle.item and bannerTitle.item:isVisible() then
		bannerTitle.item:raise()
	end

	if bannerTitle.creature and bannerTitle.creature:isVisible() then
		bannerTitle.creature:raise()
	end

	if bannerTitle.top and bannerTitle.top:isVisible() then
		bannerTitle.top:raise()
	end

	if bannerTitle.mid and bannerTitle.mid:isVisible() then
		bannerTitle.mid:raise()
	end

	if opacity and bannerTitle.roll and bannerTitle.roll:isVisible() then
		bannerTitle.roll:raise()
	end
end

local function refreshBannerTextLayout(width)
	local var_41_0 = var_0_86()

	if not var_41_0 then
		return
	end

	width = math.max(1, math.min(width, BANNER_BODY_WIDTH))

	if width == var_0_27 then
		return
	end

	var_0_27 = width

	if var_41_0.backdropAnim then
		var_41_0.backdropAnim:setWidth(width)

		var_0_25.width = width

		var_41_0.backdropAnim:setImageClip(var_0_25)
	end

	if var_41_0.textClip then
		var_41_0.textClip:setWidth(width)
	end
end

local function var_0_91()
	if var_0_6 then
		return
	end

	local var_42_0 = var_0_86()

	if not var_42_0 then
		return
	end

	local var_42_1 = {
		width = BANNER_BODY_WIDTH,
		height = BANNER_BODY_HEIGHT
	}

	if var_42_0.clip then
		var_42_0.clip:setSize(var_42_1)
		var_42_0.clip:setClipping(false)
		var_42_0.clip:setVisible(true)
	end

	if var_42_0.backdropAnim then
		var_42_0.backdropAnim:setImageFixedRatio(false)
		var_42_0.backdropAnim:breakAnchors()
		var_42_0.backdropAnim:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_42_0.backdropAnim:addAnchor(AnchorTop, "parent", AnchorTop)
		var_42_0.backdropAnim:setHeight(BANNER_BODY_HEIGHT)
		var_42_0.backdropAnim:setVisible(true)
	end

	if var_42_0.textClip then
		var_42_0.textClip:breakAnchors()
		var_42_0.textClip:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_42_0.textClip:addAnchor(AnchorTop, "parent", AnchorTop)
		var_42_0.textClip:setClipping(true)
		var_42_0.textClip:setHeight(BANNER_BODY_HEIGHT)
		var_42_0.textClip:setVisible(true)
	end

	if var_42_0.content then
		var_42_0.content:setSize(var_42_1)
		var_42_0.content:breakAnchors()
		var_42_0.content:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_42_0.content:addAnchor(AnchorTop, "parent", AnchorTop)
		var_42_0.content:setClipping(false)
		var_42_0.content:setVisible(true)
	end

	if var_42_0.roll then
		var_42_0.roll:setMarginTop(BACKDROP_MARGIN_TOP)
		var_42_0.roll:setVisible(true)
	end

	if var_42_0.mid then
		var_42_0.mid:setVisible(true)
	end

	if var_42_0.top then
		var_42_0.top:setVisible(true)
	end

	var_0_6 = true
end

local function var_0_92()
	local var_43_0 = var_0_86()

	if not var_43_0 or not var_43_0.textPanel or not var_43_0.description then
		return
	end

	local var_43_1 = BANNER_BODY_WIDTH - var_0_18 - TEXT_MARGIN_RIGHT

	var_43_0.description:setTextAutoResize(false)
	var_43_0.description:setTextWrap(true)
	var_43_0.description:setWidth(var_43_1)
	var_43_0.textPanel:setHeight(math.max(20, var_43_0.description:getTextSize().height + 5))
end

local function var_0_93(arg_44_0)
	local var_44_0 = var_0_86()

	if not var_44_0 or not arg_44_0 then
		return
	end

	if var_44_0.icon and arg_44_0.icon then
		var_44_0.icon:setImageSource(IMAGE_BASE .. arg_44_0.icon)
	end

	if var_44_0.spell then
		if arg_44_0.iconSpellClip then
			var_44_0.spell:setImageSource(SPELL_ICON_FILE)
			var_44_0.spell:setImageClip(arg_44_0.iconSpellClip)
			var_44_0.spell:setVisible(true)

			if var_44_0.spellBorder then
				var_44_0.spellBorder:setImageSource(IMAGE_BASE .. SPELL_BORDER_ICON)
				var_44_0.spellBorder:setVisible(true)
			end
		else
			var_44_0.spell:setVisible(false)

			if var_44_0.spellBorder then
				var_44_0.spellBorder:setVisible(false)
			end
		end
	end

	if var_44_0.creature then
		if arg_44_0.iconOutfit then
			var_44_0.creature:setVisible(true)
			var_44_0.creature:setOutfit(arg_44_0.iconOutfit)

			local creature = var_44_0.creature:getCreature()

			if creature then
				if arg_44_0.iconOutfitIdle then
					creature:setAnimate(false)
					creature:setStaticWalking(0)
				else
					creature:setAnimate(true)
					creature:setStaticWalking(1000)
				end
			end
		else
			var_44_0.creature:setVisible(false)
		end
	end

	if var_44_0.item then
		local numericValue = tonumber(arg_44_0.iconItemId) or 0

		if numericValue > 0 then
			var_44_0.item:setItemId(numericValue)
			var_44_0.item:setVisible(true)
		else
			var_44_0.item:setItemId(0)
			var_44_0.item:setVisible(false)
		end
	end

	setTextContentOpacity(var_44_0.roll and var_44_0.roll:isVisible())
end

local function applyAnimationFrame(frameIndex)
	local var_45_0 = var_0_86()
	local var_45_1 = ANIM_FRAMES[frameIndex]

	if not var_45_0 or not var_45_1 or not var_45_0.clip or not var_45_0.roll then
		return
	end

	var_0_91()

	local var_45_2 = math.max(1, var_45_1.width)

	if var_45_1.path ~= path then
		path = var_45_1.path

		var_45_0.roll:setImageSource(var_45_1.path)
	end

	refreshBannerTextLayout(var_45_2)

	local var_45_3 = BACKDROP_MARGIN_LEFT + var_45_2 - var_0_15

	if var_45_3 ~= var_0_28 then
		var_0_28 = var_45_3

		var_45_0.roll:setMarginLeft(var_45_3)
	end
end

local function var_0_95(arg_46_0, arg_46_1)
	if not bannerWidget() then
		if arg_46_1 then
			arg_46_1()
		end

		return
	end

	g_effects.cancelFade(gameBannerPanelWidget)

	if arg_46_0 >= 1 then
		gameBannerPanelWidget:setOpacity(0)
		g_effects.fadeIn(gameBannerPanelWidget, ANIM_FRAME_MS)
	else
		gameBannerPanelWidget:setOpacity(1)
		g_effects.fadeOut(gameBannerPanelWidget, ANIM_FRAME_MS)
	end

	scheduleBannerEvent(function()
		if bannerWidget() then
			gameBannerPanelWidget:setOpacity(arg_46_0)
		end

		if arg_46_1 then
			arg_46_1()
		end
	end, ANIM_FRAME_MS)
end

local function var_0_96()
	local bannerClipPanel = var_0_86()

	if not bannerClipPanel then
		return
	end

	var_0_91()
	refreshBannerTextLayout(BANNER_BODY_WIDTH)

	if bannerClipPanel.roll then
		bannerClipPanel.roll:setVisible(false)
	end

	if bannerClipPanel.mid then
		bannerClipPanel.mid:setVisible(true)
	end

	if bannerClipPanel.top then
		bannerClipPanel.top:setVisible(true)
	end

	var_0_92()
	setTextContentOpacity(false)
end

local function var_0_97(fromIndex, toIndex, onComplete, arg_49_3)
	local step = fromIndex <= toIndex and 1 or -1
	local frameIndex = fromIndex

	arg_49_3 = arg_49_3 or var_0_13

	local function advance()
		if not bannerWidget() then
			return
		end

		applyAnimationFrame(frameIndex)

		if frameIndex == toIndex then
			scheduleBannerEvent(function()
				if onComplete then
					onComplete()
				end
			end, arg_49_3)

			return
		end

		frameIndex = frameIndex + step

		scheduleBannerEvent(advance, arg_49_3)
	end

	advance()
end

local function playOpenAnimation(onComplete)
	if not bannerWidget() then
		if onComplete then
			onComplete()
		end

		return
	end

	var_0_83()
	applyAnimationFrame(1)
	setTextContentOpacity(true)
	var_0_95(1, function()
		var_0_82(function()
			scheduleBannerEvent(function()
				var_0_82(function()
					var_0_97(1, var_0_24, function()
						var_0_82(function()
							var_0_96()

							if onComplete then
								onComplete()
							end
						end)
					end)
				end)
			end, var_0_12)
		end)
	end)
end

local function var_0_99(arg_59_0)
	if not bannerWidget() then
		if arg_59_0 then
			arg_59_0()
		end

		return
	end

	var_0_83()
	applyAnimationFrame(var_0_24)

	local var_59_0 = var_0_86()

	if var_59_0 and var_59_0.roll then
		var_59_0.roll:setVisible(true)
	end

	setTextContentOpacity(true)
	var_0_97(var_0_24, 1, function()
		if not bannerWidget() then
			if arg_59_0 then
				arg_59_0()
			end

			return
		end

		scheduleBannerEvent(function()
			if not bannerWidget() then
				if arg_59_0 then
					arg_59_0()
				end

				return
			end

			var_0_95(0, arg_59_0)
		end, var_0_12)
	end, var_0_13 / 2)
end

local processNextBanner

local function finishCurrentBanner()
	var_0_2 = false

	destroyBannerWidget()
	processNextBanner()
end

local function var_0_102(arg_63_0)
	local var_63_0 = getBannerParent()

	if not var_63_0 or var_63_0:isDestroyed() then
		return false
	end

	destroyBannerWidget()

	gameBannerPanelWidget = g_ui.createWidget("GameBannerPanel", var_63_0)

	if not gameBannerPanelWidget then
		return false
	end

	gameBannerPanelWidget:setSize({
		width = var_0_7,
		height = var_0_8
	})
	gameBannerPanelWidget:addAnchor(AnchorTop, "parent", AnchorTop)
	gameBannerPanelWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	gameBannerPanelWidget:setMarginTop(-18)
	gameBannerPanelWidget:setMarginLeft(35)
	gameBannerPanelWidget:raise()
	gameBannerPanelWidget:show()
	var_0_85()

	var_0_6 = false

	var_0_91()

	local var_63_1 = var_0_86()

	var_0_93(arg_63_0)

	if var_63_1 then
		if var_63_1.title then
			var_63_1.title:setText(arg_63_0.title)
			var_63_1.title:setVisible(true)
		end

		if var_63_1.description then
			var_63_1.description:setText(arg_63_0.description)
		end

		if var_63_1.textPanel then
			var_63_1.textPanel:setVisible(true)
		end
	end

	var_0_92()
	gameBannerPanelWidget:setOpacity(0)

	return true
end

function processNextBanner()
	if var_0_2 or #bannerQueue == 0 then
		return
	end

	if not g_game.isOnline() then
		bannerQueue = {}

		return
	end

	local entry = table.remove(bannerQueue, 1)

	var_0_2 = true

	if not var_0_102(entry) then
		var_0_2 = false

		return
	end

	playOpenAnimation(function()
		scheduleBannerEvent(function()
			if not bannerWidget() then
				finishCurrentBanner()

				return
			end

			var_0_99(finishCurrentBanner)
		end, var_0_14)
	end)
end

local function var_0_103(arg_67_0)
	if not arg_67_0 or arg_67_0 == "" then
		return arg_67_0
	end

	if arg_67_0:sub(-1) == "." then
		return arg_67_0
	end

	return arg_67_0 .. "."
end

local function enqueueBanner(entry)
	entry.description = var_0_103(entry.description)

	table.insert(bannerQueue, entry)
	processNextBanner()
end

local function resolveBannerContent(eventType, ...)
	if not isInfoBannerEnabled() then
		return
	end

	local content = var_0_80(eventType, ...)

	if not content then
		return
	end

	enqueueBanner(content)
end

function hideActiveBanner(clearQueue)
	if clearQueue then
		bannerQueue = {}
	end

	var_0_2 = false

	destroyBannerWidget()

	if not clearQueue then
		processNextBanner()
	end
end

function clearBannerQueue()
	bannerQueue = {}
end

local gameBannerPanelWidget
local var_0_107
local var_0_108 = {}
local var_0_109
local var_0_110 = false
local path
local var_0_112
local var_0_113
local var_0_114 = false
local var_0_115
local var_0_116 = {
	width = 0,
	y = 0,
	x = 0,
	height = BANNER_BODY_HEIGHT
}
local var_0_117 = 180
local var_0_118 = 30
local var_0_119 = 8
local var_0_120 = 250

local function var_0_121()
	return gameBannerPanelWidget and not gameBannerPanelWidget:isDestroyed()
end

local function var_0_122()
	if var_0_115 then
		removeEvent(var_0_115)

		var_0_115 = nil
	end

	var_0_114 = false
end

local function var_0_123()
	for unusedValue, entry in ipairs(var_0_108) do
		removeEvent(entry)
	end

	var_0_108 = {}
end

local function var_0_124(arg_75_0, arg_75_1)
	local var_75_0

	var_75_0 = scheduleEvent(function()
		for index, entry in ipairs(var_0_108) do
			if entry == var_75_0 then
				table.remove(var_0_108, index)

				break
			end
		end

		arg_75_0()
	end, arg_75_1)

	table.insert(var_0_108, var_75_0)

	return var_75_0
end

local function var_0_125()
	var_0_109 = nil

	var_0_122()

	var_0_110 = false
	path = nil
	var_0_112 = nil
	var_0_113 = nil
	var_0_107 = nil

	var_0_123()

	if var_0_121() then
		g_effects.cancelFade(gameBannerPanelWidget)
		gameBannerPanelWidget:destroy()
	end

	gameBannerPanelWidget = nil
end

local function var_0_126()
	if not var_0_121() then
		var_0_107 = nil

		return nil
	end

	var_0_107 = {
		icon = gameBannerPanelWidget:recursiveGetChildById("bannerIcon"),
		creature = gameBannerPanelWidget:recursiveGetChildById("bannerIconCreature"),
		spell = gameBannerPanelWidget:recursiveGetChildById("bannerIconSpell"),
		spellBorder = gameBannerPanelWidget:recursiveGetChildById("bannerIconSpellBorder"),
		item = gameBannerPanelWidget:recursiveGetChildById("bannerIconItem"),
		picture = gameBannerPanelWidget:recursiveGetChildById("bannerIconPicture"),
		overlay = gameBannerPanelWidget:recursiveGetChildById("bannerIconOverlay"),
		clip = gameBannerPanelWidget:recursiveGetChildById("bannerClipPanel"),
		textClip = gameBannerPanelWidget:recursiveGetChildById("bannerTextClip"),
		content = gameBannerPanelWidget:recursiveGetChildById("bannerContentLayer"),
		backdropAnim = gameBannerPanelWidget:recursiveGetChildById("backdropBottomAnim"),
		mid = gameBannerPanelWidget:recursiveGetChildById("backdropMid"),
		top = gameBannerPanelWidget:recursiveGetChildById("backdropTop"),
		roll = gameBannerPanelWidget:recursiveGetChildById("rollAnim"),
		title = gameBannerPanelWidget:recursiveGetChildById("bannerTitle"),
		description = gameBannerPanelWidget:recursiveGetChildById("bannerDescription"),
		textPanel = gameBannerPanelWidget:recursiveGetChildById("textPanel")
	}

	return var_0_107
end

local function var_0_127(arg_79_0)
	local var_79_0 = var_0_107

	if not var_79_0 then
		return
	end

	if var_79_0.clip and var_79_0.clip:isVisible() then
		var_79_0.clip:raise()
	end

	if var_79_0.textClip then
		var_79_0.textClip:raise()
	end

	if var_79_0.content then
		var_79_0.content:raise()
	end

	if var_79_0.icon then
		var_79_0.icon:raise()
	end

	if var_79_0.item and var_79_0.item:isVisible() then
		var_79_0.item:raise()
	end

	if var_79_0.creature and var_79_0.creature:isVisible() then
		var_79_0.creature:raise()
	end

	if var_79_0.top and var_79_0.top:isVisible() then
		var_79_0.top:raise()
	end

	if var_79_0.mid and var_79_0.mid:isVisible() then
		var_79_0.mid:raise()
	end

	if var_79_0.overlay and var_79_0.overlay:isVisible() then
		var_79_0.overlay:raise()
	end

	if arg_79_0 and var_79_0.roll and var_79_0.roll:isVisible() then
		var_79_0.roll:raise()
	end
end

local function var_0_128(width)
	local var_80_0 = var_0_107

	if not var_80_0 then
		return
	end

	width = math.max(1, math.min(width, BANNER_BODY_WIDTH))

	if width == var_0_112 then
		return
	end

	var_0_112 = width

	if var_80_0.backdropAnim then
		var_80_0.backdropAnim:setWidth(width)

		var_0_116.width = width

		var_80_0.backdropAnim:setImageClip(var_0_116)
	end

	if var_80_0.textClip then
		var_80_0.textClip:setWidth(width)
	end
end

local function var_0_129()
	if var_0_110 then
		return
	end

	local var_81_0 = var_0_107

	if not var_81_0 then
		return
	end

	local var_81_1 = {
		width = BANNER_BODY_WIDTH,
		height = BANNER_BODY_HEIGHT
	}

	if var_81_0.clip then
		var_81_0.clip:setSize(var_81_1)
		var_81_0.clip:setClipping(false)
		var_81_0.clip:setVisible(true)
	end

	if var_81_0.backdropAnim then
		var_81_0.backdropAnim:setImageFixedRatio(false)
		var_81_0.backdropAnim:breakAnchors()
		var_81_0.backdropAnim:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_81_0.backdropAnim:addAnchor(AnchorTop, "parent", AnchorTop)
		var_81_0.backdropAnim:setHeight(BANNER_BODY_HEIGHT)
		var_81_0.backdropAnim:setVisible(true)
	end

	if var_81_0.textClip then
		var_81_0.textClip:breakAnchors()
		var_81_0.textClip:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_81_0.textClip:addAnchor(AnchorTop, "parent", AnchorTop)
		var_81_0.textClip:setClipping(true)
		var_81_0.textClip:setHeight(BANNER_BODY_HEIGHT)
		var_81_0.textClip:setVisible(true)
	end

	if var_81_0.content then
		var_81_0.content:setSize(var_81_1)
		var_81_0.content:breakAnchors()
		var_81_0.content:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_81_0.content:addAnchor(AnchorTop, "parent", AnchorTop)
		var_81_0.content:setClipping(false)
		var_81_0.content:setVisible(true)
	end

	if var_81_0.roll then
		var_81_0.roll:setMarginTop(BACKDROP_MARGIN_TOP)
		var_81_0.roll:setVisible(true)
	end

	if var_81_0.mid then
		var_81_0.mid:setVisible(true)
	end

	if var_81_0.top then
		var_81_0.top:setVisible(true)
	end

	var_0_110 = true
end

local function var_0_130(arg_82_0)
	local var_82_0 = var_0_107
	local var_82_1 = ANIM_FRAMES[arg_82_0]

	if not var_82_0 or not var_82_1 or not var_82_0.clip or not var_82_0.roll then
		return
	end

	var_0_129()

	local var_82_2 = math.max(1, var_82_1.width)

	if var_82_1.path ~= path then
		path = var_82_1.path

		var_82_0.roll:setImageSource(var_82_1.path)
	end

	var_0_128(var_82_2)

	local var_82_3 = BACKDROP_MARGIN_LEFT + var_82_2 - var_0_15

	if var_82_3 ~= var_0_113 then
		var_0_113 = var_82_3

		var_82_0.roll:setMarginLeft(var_82_3)
	end
end

local function var_0_131(arg_83_0, arg_83_1)
	if not var_0_121() then
		if arg_83_1 then
			arg_83_1()
		end

		return
	end

	g_effects.cancelFade(gameBannerPanelWidget)

	if arg_83_0 >= 1 then
		gameBannerPanelWidget:setOpacity(0)
		g_effects.fadeIn(gameBannerPanelWidget, var_0_117)
	else
		gameBannerPanelWidget:setOpacity(1)
		g_effects.fadeOut(gameBannerPanelWidget, var_0_117)
	end

	var_0_124(function()
		if var_0_121() then
			gameBannerPanelWidget:setOpacity(arg_83_0)
		end

		if arg_83_1 then
			arg_83_1()
		end
	end, var_0_117)
end

local function var_0_132()
	local var_85_0 = var_0_107

	if not var_85_0 then
		return
	end

	var_0_129()
	var_0_128(BANNER_BODY_WIDTH)

	if var_85_0.roll then
		var_85_0.roll:setVisible(false)
	end

	if var_85_0.mid then
		var_85_0.mid:setVisible(true)
	end

	if var_85_0.top then
		var_85_0.top:setVisible(true)
	end

	var_0_127(false)
end

local function var_0_133(arg_86_0, arg_86_1, onComplete, arg_86_3)
	local var_86_0 = arg_86_0 <= arg_86_1 and 1 or -1
	local var_86_1 = arg_86_0

	arg_86_3 = arg_86_3 or var_0_119

	local function var_86_2()
		if not var_0_121() then
			return
		end

		var_0_130(var_86_1)

		if var_86_1 == arg_86_1 then
			var_0_124(function()
				if onComplete then
					onComplete()
				end
			end, arg_86_3)

			return
		end

		var_86_1 = var_86_1 + var_86_0

		var_0_124(var_86_2, arg_86_3)
	end

	var_86_2()
end

local function var_0_134()
	if not var_0_121() then
		return
	end

	var_0_123()
	var_0_130(1)
	var_0_127(true)
	var_0_131(1, function()
		if not var_0_121() then
			return
		end

		var_0_124(function()
			if not var_0_121() then
				return
			end

			var_0_133(1, var_0_24, function()
				if var_0_121() then
					var_0_132()
				end
			end, var_0_119)
		end, var_0_118)
	end)
end

local function var_0_135(arg_93_0)
	local var_93_0 = var_0_107

	if not var_93_0 or not arg_93_0 then
		return
	end

	if var_93_0.icon then
		var_93_0.icon:setImageSource(IMAGE_BASE .. (arg_93_0.icon or "icon-infobanner-unlock"))
	end

	if var_93_0.creature then
		if arg_93_0.iconOutfit then
			var_93_0.creature:setVisible(true)
			var_93_0.creature:setOutfit(arg_93_0.iconOutfit)

			local creature = var_93_0.creature:getCreature()

			if creature then
				if arg_93_0.iconOutfitIdle then
					creature:setAnimate(false)
					creature:setStaticWalking(0)
				else
					creature:setAnimate(true)
					creature:setStaticWalking(1000)
				end

				if creature.setAuraLookType then
					creature:setAuraLookType(tonumber(arg_93_0.iconAura) or 0)
				end
			end
		else
			local creature = var_93_0.creature:getCreature()

			if creature and creature.setAuraLookType then
				creature:setAuraLookType(0)
			end

			var_93_0.creature:setVisible(false)
		end
	end

	if var_93_0.spell then
		var_93_0.spell:setVisible(false)
	end

	if var_93_0.spellBorder then
		var_93_0.spellBorder:setVisible(false)
	end

	if var_93_0.item then
		local numericValue = tonumber(arg_93_0.iconItemId) or 0
		local var_93_4 = tonumber(arg_93_0.iconItemCount) or 0
		local iconImage = arg_93_0.iconImage

		if iconImage and iconImage ~= "" then
			var_93_0.item:setItemId(0)
			var_93_0.item:setVisible(false)
		else
			var_93_0.item:setItemId(numericValue)

			if numericValue > 0 and var_93_4 > 1 then
				var_93_0.item:setItemCount(var_93_4)
			end

			var_93_0.item:setShowCount(false)
			var_93_0.item:setVisible(numericValue > 0)
		end
	end

	if var_93_0.picture then
		local iconImage = arg_93_0.iconImage

		if iconImage and iconImage ~= "" then
			var_93_0.picture:setImageSource(iconImage)
			var_93_0.picture:setVisible(true)
		else
			var_93_0.picture:setVisible(false)
		end
	end

	if var_93_0.overlay then
		local iconOverlay = arg_93_0.iconOverlay

		if iconOverlay and iconOverlay ~= "" then
			var_93_0.overlay:setImageSource(iconOverlay)
			var_93_0.overlay:setVisible(true)
		else
			var_93_0.overlay:setVisible(false)
		end
	end

	if var_93_0.title then
		var_93_0.title:setText(arg_93_0.title or "")
		var_93_0.title:setVisible(true)
	end

	if var_93_0.description then
		var_93_0.description:setText(arg_93_0.description or "")
		var_93_0.description:setTextAutoResize(false)
		var_93_0.description:setTextWrap(true)
		var_93_0.description:setWidth(BANNER_BODY_WIDTH - var_0_18 - TEXT_MARGIN_RIGHT)
	end

	if var_93_0.textPanel then
		if var_93_0.description then
			var_93_0.textPanel:setHeight(math.max(20, var_93_0.description:getTextSize().height + 5))
		end

		var_93_0.textPanel:setVisible(true)
	end
end

local function var_0_136(arg_94_0)
	if not arg_94_0 or arg_94_0:isDestroyed() then
		return
	end

	arg_94_0:setPhantom(true)

	for unusedValue, child in ipairs(arg_94_0:getChildren()) do
		var_0_136(child)
	end
end

local function var_0_137(arg_95_0, arg_95_1)
	if not gameBannerPanelWidget or gameBannerPanelWidget:isDestroyed() or gameBannerPanelWidget:getParent() ~= arg_95_1 then
		if var_0_121() then
			g_effects.cancelFade(gameBannerPanelWidget)
			gameBannerPanelWidget:destroy()
		end

		gameBannerPanelWidget = g_ui.createWidget("GameBannerPanel", arg_95_1)

		if not gameBannerPanelWidget then
			return false
		end

		gameBannerPanelWidget:setId("infoBannerPreview")
		gameBannerPanelWidget:setSize({
			width = var_0_7,
			height = var_0_8
		})
		gameBannerPanelWidget:addAnchor(AnchorTop, "parent", AnchorTop)
		gameBannerPanelWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		gameBannerPanelWidget:setMarginTop(-18)
		gameBannerPanelWidget:setMarginLeft(35)
		var_0_136(gameBannerPanelWidget)
	end

	var_0_110 = false
	path = nil
	var_0_112 = nil
	var_0_113 = nil

	var_0_126()
	var_0_129()
	var_0_135(arg_95_0)
	gameBannerPanelWidget:setOpacity(0)
	gameBannerPanelWidget:raise()
	gameBannerPanelWidget:show()

	return true
end

function hidePreviewBanner(arg_96_0)
	if arg_96_0 then
		var_0_109 = nil

		var_0_122()
		var_0_123()

		if var_0_121() then
			g_effects.cancelFade(gameBannerPanelWidget)
			gameBannerPanelWidget:hide()
		end

		return
	end

	if not var_0_121() or not gameBannerPanelWidget:isVisible() or var_0_114 then
		return
	end

	var_0_114 = true
	var_0_115 = scheduleEvent(function()
		var_0_115 = nil

		if not var_0_114 or not var_0_121() then
			var_0_114 = false

			return
		end

		var_0_123()
		var_0_131(0, function()
			if not var_0_114 then
				return
			end

			var_0_114 = false
			var_0_109 = nil

			if var_0_121() then
				gameBannerPanelWidget:hide()
			end
		end)
	end, var_0_120)
end

function refreshPreviewItem(numericValue)
	if not var_0_121() or not var_0_107 or not var_0_107.item then
		return
	end

	local item = var_0_107.item

	if not item:isVisible() then
		return
	end

	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 then
		return
	end

	item:setItemId(0)
	item:setItemId(numericValue)
end

function showPreviewBanner(arg_100_0)
	if not arg_100_0 then
		hidePreviewBanner()

		return
	end

	local parent = arg_100_0.parent

	if not parent or parent:isDestroyed() then
		return
	end

	local var_100_1 = arg_100_0.iconOutfit and tonumber(arg_100_0.iconOutfit.type) or 0
	local formattedText = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s", arg_100_0.title or "", arg_100_0.description or "", arg_100_0.icon or "icon-infobanner-unlock", tonumber(arg_100_0.iconItemId) or 0, tonumber(arg_100_0.iconItemCount) or 0, arg_100_0.iconImage or "", var_100_1 or 0, tonumber(arg_100_0.iconAura) or 0, arg_100_0.iconOverlay or "")

	if var_0_121() and gameBannerPanelWidget:getParent() == parent and var_0_109 == formattedText and gameBannerPanelWidget:isVisible() then
		local var_100_3 = var_0_114

		var_0_122()

		if var_100_3 then
			var_0_123()
			g_effects.cancelFade(gameBannerPanelWidget)
			gameBannerPanelWidget:setOpacity(1)
			var_0_132()
		end

		gameBannerPanelWidget:raise()

		return
	end

	var_0_122()

	var_0_109 = formattedText

	var_0_123()

	if not var_0_137(arg_100_0, parent) then
		return
	end

	var_0_134()
end

function bannersController.onInit(unusedArgument)
	g_ui.importStyle("game_banners")
	g_shaders.createFragmentShader(var_0_0, "shaders/drop_shadow.frag", false)
end

function bannersController.onTerminate(unusedArgument)
	hideActiveBanner(true)
	var_0_125()
	g_shaders.removeShader(var_0_0)
end

function bannersController.onGameStart(unusedArgument)
	bannersController:registerEvents(g_game, {
		onClientEvent = resolveBannerContent
	})
end

function bannersController.onGameEnd(unusedArgument)
	hideActiveBanner(true)
	var_0_125()
end

function init()
	bannersController:init()
end

function terminate()
	bannersController:terminate()
end
