if not MiscAnalyser then
	MiscAnalyser = {
		transcendence = 0,
		momentum = 0,
		ruse = 0,
		amplifiedOnslaught = 0,
		onslaughtDamage = 0,
		onslaught = 0,
		damageReceived = 0,
		manaGain = 0,
		lifeGain = 0,
		critDamage = 0,
		crits = 0,
		charmDamage = 0,
		damage = 0,
		hits = 0,
		charms = {},
		charmOrder = {},
		charmRows = {}
	}
	MiscAnalyser.__index = MiscAnalyser
end

local var_0_0 = "/modules/game_cyclopedia/images/charms/monster-bonus-effects"
local var_0_1 = "/modules/game_analysers/images/misc-analyser-icons"
local var_0_2 = {
	numb = 10,
	["adrenaline burst"] = 9,
	dodge = 8,
	parry = 7,
	cripple = 6,
	curse = 5,
	zap = 4,
	freeze = 3,
	poison = 2,
	enflame = 1,
	wound = 0,
	overflux = 24,
	overpower = 23,
	carnage = 22,
	["void inversion"] = 21,
	["fatal hold"] = 20,
	["savage blow"] = 19,
	["void's call"] = 18,
	["vampiric embrace"] = 17,
	["divine wrath"] = 16,
	["low blow"] = 15,
	gut = 14,
	scavenge = 13,
	bless = 12,
	cleanse = 11
}
local var_0_3 = {
	["savage blow"] = true,
	["low blow"] = true
}
local var_0_4 = {
	["adrenaline burst"] = "Adrenaline"
}
local var_0_5 = 15
local var_0_6 = 28
local var_0_7 = {
	{
		id = "critical",
		list = "imbuementList",
		clip = "0 0 12 12",
		name = "Critical Hit",
		icon = var_0_1
	},
	{
		id = "manaGain",
		list = "imbuementList",
		clip = "12 0 12 12",
		name = "Mana Gain",
		icon = var_0_1
	},
	{
		id = "lifeGain",
		list = "imbuementList",
		clip = "24 0 12 12",
		name = "Life Gain",
		icon = var_0_1
	},
	{
		id = "onslaught",
		list = "upgradeList",
		clip = "36 0 12 12",
		name = "Onslaught",
		icon = var_0_1
	},
	{
		id = "ruse",
		list = "upgradeList",
		clip = "48 0 12 12",
		name = "Ruse",
		icon = var_0_1
	},
	{
		id = "momentum",
		list = "upgradeList",
		clip = "60 0 12 12",
		name = "Momentum",
		icon = var_0_1
	},
	{
		id = "transcendence",
		list = "upgradeList",
		clip = "72 0 12 12",
		name = "Transcendence",
		icon = var_0_1
	},
	{
		name = "Critical Rate",
		id = "critRate",
		list = "efficiencyList"
	},
	{
		name = "Charm Dmg",
		id = "charmShare",
		list = "efficiencyList"
	},
	{
		name = "Life Gain/h",
		id = "lifeGainHour",
		list = "efficiencyList"
	},
	{
		name = "Mana Gain/h",
		id = "manaGainHour",
		list = "efficiencyList"
	},
	{
		name = "Sustain",
		id = "sustain",
		list = "efficiencyList"
	}
}

local function var_0_8(arg_1_0)
	arg_1_0 = math.floor(tonumber(arg_1_0) or 0)

	if arg_1_0 < 10000 then
		return formatMoney(arg_1_0, ",")
	end

	local var_1_0 = arg_1_0 / 1000
	local var_1_1 = "k"

	if arg_1_0 >= 1000000 then
		var_1_0, var_1_1 = arg_1_0 / 1000000, "M"
	end

	if var_1_0 >= 100 then
		return math.floor(var_1_0) .. var_1_1
	end

	return string.format(var_1_0 >= 10 and "%.1f" or "%.2f", var_1_0):gsub("0+$", ""):gsub("%.$", "") .. var_1_1
end

local function var_0_9(arg_2_0, arg_2_1)
	if not arg_2_1 or arg_2_1 <= 0 then
		return "0%"
	end

	local var_2_0 = arg_2_0 * 100 / arg_2_1

	if var_2_0 >= 10 then
		return string.format("%d%%", math.floor(var_2_0 + 0.5))
	end

	return string.format("%.1f%%", var_2_0)
end

local function var_0_10(arg_3_0)
	return arg_3_0 == 1 and "1 proc" or string.format("%d procs", arg_3_0)
end

local function var_0_11(arg_4_0)
	return (arg_4_0:gsub("(%a)([%w']*)", function(arg_5_0, arg_5_1)
		return arg_5_0:upper() .. arg_5_1
	end))
end

local function var_0_12()
	if not AnalyserSession:isActive() then
		return "00:00h"
	end

	local var_6_0 = math.max(1, AnalyserSession:durationSeconds())

	return string.format("%02d:%02dh", math.floor(var_6_0 / 3600), math.floor(var_6_0 % 3600 / 60))
end

local var_0_13 = {
	critical = function(arg_7_0)
		return tostring(arg_7_0.crits), tr("%d critical hits (attacks, spells and runes)\nDamage: %s\nAverage: %s", arg_7_0.crits, formatMoney(arg_7_0.critDamage, ","), formatMoney(math.floor(arg_7_0.critDamage / math.max(1, arg_7_0.crits)), ",")), var_0_8(arg_7_0.critDamage)
	end,
	manaGain = function(arg_8_0)
		return var_0_8(arg_8_0.manaGain), tr("Mana gained from leech: %s", formatMoney(arg_8_0.manaGain, ","))
	end,
	lifeGain = function(arg_9_0)
		return var_0_8(arg_9_0.lifeGain), tr("Hit points gained from leech: %s", formatMoney(arg_9_0.lifeGain, ","))
	end,
	onslaught = function(arg_10_0)
		local var_10_0 = tr("%d Onslaught hits\nDamage: %s", arg_10_0.onslaught, formatMoney(arg_10_0.onslaughtDamage, ","))

		if arg_10_0.amplifiedOnslaught > 0 then
			var_10_0 = var_10_0 .. "\n" .. tr("Amplified: %d", arg_10_0.amplifiedOnslaught)
		end

		return tostring(arg_10_0.onslaught), var_10_0, var_0_8(arg_10_0.onslaughtDamage)
	end,
	ruse = function(arg_11_0)
		return tostring(arg_11_0.ruse), tr("Attacks dodged: %d (Ruse and Wheel of Destiny dodge)", arg_11_0.ruse)
	end,
	momentum = function(arg_12_0)
		return tostring(arg_12_0.momentum), tr("Momentum triggers: %d (-2s on spell cooldowns each)", arg_12_0.momentum)
	end,
	transcendence = function(arg_13_0)
		return tostring(arg_13_0.transcendence), tr("Transcendence triggers: %d", arg_13_0.transcendence)
	end,
	critRate = function(arg_14_0)
		return var_0_9(arg_14_0.crits, arg_14_0.hits), tr("%d of %d hits were critical", arg_14_0.crits, arg_14_0.hits)
	end,
	charmShare = function(arg_15_0)
		return var_0_9(arg_15_0.charmDamage, arg_15_0.damage), tr("%s of %s damage came from charms", formatMoney(arg_15_0.charmDamage, ","), formatMoney(arg_15_0.damage, ","))
	end,
	lifeGainHour = function(unusedArgument, arg_16_1)
		return var_0_8(arg_16_1), tr("Hit points gained from leech per hour: %s", formatMoney(arg_16_1, ","))
	end,
	manaGainHour = function(unusedArgument, arg_17_1)
		return var_0_8(arg_17_1), tr("Mana gained from leech per hour: %s", formatMoney(arg_17_1, ","))
	end,
	sustain = function(arg_18_0)
		return var_0_9(arg_18_0.lifeGain, arg_18_0.damageReceived), tr("Life Gain covered this share of the damage you took\nLife Gain: %s\nDamage taken: %s", formatMoney(arg_18_0.lifeGain, ","), formatMoney(arg_18_0.damageReceived, ","))
	end
}

local function var_0_14(arg_19_0)
	local var_19_0 = tr("%s charm: %s", arg_19_0.name, var_0_10(arg_19_0.count))

	if arg_19_0.damage > 0 then
		var_19_0 = var_19_0 .. "\n" .. tr("Damage: %s\nAverage: %s", formatMoney(arg_19_0.damage, ","), formatMoney(math.floor(arg_19_0.damage / math.max(1, arg_19_0.count)), ","))

		return tostring(arg_19_0.count), var_19_0, var_0_8(arg_19_0.damage)
	end

	if var_0_3[arg_19_0.key] then
		var_19_0 = var_19_0 .. "\n" .. tr("Critical hits against the charmed creature.")
	end

	return tostring(arg_19_0.count), var_19_0
end

local function var_0_15(arg_20_0, arg_20_1)
	local var_20_0 = arg_20_1 ~= nil

	if arg_20_0.hasDetail ~= var_20_0 then
		arg_20_0.hasDetail = var_20_0

		arg_20_0.detailName:setVisible(var_20_0)
		arg_20_0.detailValue:setVisible(var_20_0)
		arg_20_0:setHeight(var_20_0 and var_0_6 or var_0_5)
	end

	if var_20_0 then
		arg_20_0.detailValue:setText(arg_20_1)
	end
end

local function var_0_16(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4)
	arg_21_0:setVisible(arg_21_1)

	if not arg_21_1 then
		return false
	end

	if arg_21_0.shownA ~= arg_21_2 or arg_21_0.shownB ~= arg_21_3 then
		arg_21_0.shownA, arg_21_0.shownB = arg_21_2, arg_21_3

		local var_21_0, var_21_1, var_21_2 = arg_21_0.build(arg_21_4 or MiscAnalyser, arg_21_2, arg_21_3)

		arg_21_0.value:setText(var_21_0)
		arg_21_0:setTooltip(var_21_1)
		var_0_15(arg_21_0, var_21_2)
	end

	return true
end

local function var_0_17(arg_22_0)
	arg_22_0.shownA, arg_22_0.shownB = nil
end

function MiscAnalyser.create(unusedArgument)
	MiscAnalyser.window = openedWindows.miscButton
	MiscAnalyser.charmRows = {}

	MiscAnalyser:clearData()

	local contentsPanel = MiscAnalyser.window.contentsPanel

	for unusedValue, entry in ipairs(var_0_7) do
		local var_23_1 = contentsPanel[entry.list][entry.id]

		var_23_1.name:setText(tr(entry.name))

		var_23_1.build = var_0_13[entry.id]

		if entry.icon then
			var_23_1.icon:setImageSource(entry.icon)

			if entry.clip then
				var_23_1.icon:setImageClip(entry.clip)
			end
		end

		var_23_1:setVisible(false)
	end
end

function MiscAnalyser.clearData(unusedArgument)
	MiscAnalyser.charms = {}
	MiscAnalyser.charmOrder = {}
	MiscAnalyser.hits = 0
	MiscAnalyser.damage = 0
	MiscAnalyser.charmDamage = 0
	MiscAnalyser.crits = 0
	MiscAnalyser.critDamage = 0
	MiscAnalyser.lifeGain = 0
	MiscAnalyser.manaGain = 0
	MiscAnalyser.damageReceived = 0
	MiscAnalyser.onslaught = 0
	MiscAnalyser.onslaughtDamage = 0
	MiscAnalyser.amplifiedOnslaught = 0
	MiscAnalyser.ruse = 0
	MiscAnalyser.momentum = 0
	MiscAnalyser.transcendence = 0
end

function MiscAnalyser.reset(unusedArgument)
	MiscAnalyser:clearData()

	for unusedValue, charmRow in pairs(MiscAnalyser.charmRows) do
		charmRow:setVisible(false)
		var_0_17(charmRow)
	end

	local contentsPanel = MiscAnalyser.window.contentsPanel

	for unusedValue, entry in ipairs(var_0_7) do
		var_0_17(contentsPanel[entry.list][entry.id])
	end

	MiscAnalyser:updateWindow(true)
end

local var_0_18 = 1000

local function var_0_19(arg_26_0, arg_26_1)
	local var_26_0 = var_0_2[arg_26_0.key] or var_0_18
	local var_26_1 = var_0_2[arg_26_1.key] or var_0_18

	if var_26_0 ~= var_26_1 then
		return var_26_0 < var_26_1
	end

	return arg_26_0.name < arg_26_1.name
end

local function var_0_20(arg_27_0)
	local var_27_0 = MiscAnalyser.charms[arg_27_0]

	if not var_27_0 then
		var_27_0 = {
			count = 0,
			damage = 0,
			key = arg_27_0,
			name = var_0_11(arg_27_0)
		}
		MiscAnalyser.charms[arg_27_0] = var_27_0

		local charmOrder = MiscAnalyser.charmOrder

		charmOrder[#charmOrder + 1] = var_27_0

		table.sort(charmOrder, var_0_19)
	end

	return var_27_0
end

local var_0_21 = {}

local function var_0_22(arg_28_0)
	local var_28_0 = 0

	if not arg_28_0:find(" charm", 1, true) then
		return var_28_0
	end

	for iter_28_0 in arg_28_0:gmatch("%(([^()]*)%)") do
		for iter_28_1 in iter_28_0:gmatch("[^+]+") do
			local var_28_1 = iter_28_1:match("^%s*(.-)%s+charm%s*$")

			if var_28_1 and var_28_1 ~= "" then
				var_28_0 = var_28_0 + 1
				var_0_21[var_28_0] = var_28_1:lower()
			end
		end
	end

	return var_28_0
end

local function var_0_23(arg_29_0)
	if not arg_29_0:find("due to your", 1, true) then
		return
	end

	local numericValue = tonumber(arg_29_0:match("loses (%d+) hitpoints?") or arg_29_0:match("loses (%d+) mana")) or 0

	MiscAnalyser.damage = MiscAnalyser.damage + numericValue

	local var_29_1 = false

	for iter_29_0 = 1, var_0_22(arg_29_0) do
		local var_29_2 = var_0_21[iter_29_0]
		local var_29_3 = var_0_20(var_29_2)

		var_29_3.count = var_29_3.count + 1

		if not var_0_3[var_29_2] and not var_29_1 then
			var_29_1 = true
			var_29_3.damage = var_29_3.damage + numericValue
			MiscAnalyser.charmDamage = MiscAnalyser.charmDamage + numericValue
		end
	end

	if var_29_1 then
		return
	end

	MiscAnalyser.hits = MiscAnalyser.hits + 1

	if arg_29_0:find("critical attack", 1, true) then
		MiscAnalyser.crits = MiscAnalyser.crits + 1
		MiscAnalyser.critDamage = MiscAnalyser.critDamage + numericValue
	end

	if arg_29_0:find("fatal attack", 1, true) or arg_29_0:find("Onslaught)", 1, true) then
		MiscAnalyser.onslaught = MiscAnalyser.onslaught + 1
		MiscAnalyser.onslaughtDamage = MiscAnalyser.onslaughtDamage + numericValue

		if arg_29_0:find("mplified", 1, true) then
			MiscAnalyser.amplifiedOnslaught = MiscAnalyser.amplifiedOnslaught + 1
		end
	end
end

local function var_0_24(arg_30_0)
	local var_30_0 = arg_30_0:match("^You were healed for (%d+) hitpoints?")

	if var_30_0 then
		MiscAnalyser.lifeGain = MiscAnalyser.lifeGain + tonumber(var_30_0)

		return
	end

	local var_30_1 = arg_30_0:match("^You gained (%d+) mana") or arg_30_0:match("^You were restored for (%d+) mana")

	if var_30_1 then
		MiscAnalyser.manaGain = MiscAnalyser.manaGain + tonumber(var_30_1)
	end
end

local function var_0_25(arg_31_0)
	local var_31_0 = var_0_22(arg_31_0)

	if var_31_0 > 0 then
		for iter_31_0 = 1, var_31_0 do
			local var_31_1 = var_0_20(var_0_21[iter_31_0])

			var_31_1.count = var_31_1.count + 1
		end

		return
	end

	if arg_31_0:find("^Momentum was triggered") then
		MiscAnalyser.momentum = MiscAnalyser.momentum + 1
	elseif arg_31_0:find("^Transcendence was triggered") then
		MiscAnalyser.transcendence = MiscAnalyser.transcendence + 1
	elseif arg_31_0:find("^You dodged an attack%.?$") then
		MiscAnalyser.ruse = MiscAnalyser.ruse + 1
	end
end

local var_0_26

local function var_0_27(arg_32_0, arg_32_1)
	local var_32_0 = var_0_26 and var_0_26[arg_32_0]

	if var_32_0 and type(arg_32_1) == "string" then
		var_32_0(arg_32_1)
	end
end

function MiscAnalyser.registerMessageModes(unusedArgument)
	MiscAnalyser:unregisterMessageModes()

	var_0_26 = {
		[MessageModes.DamageDealed] = var_0_23,
		[MessageModes.Heal] = var_0_24,
		[MessageModes.Mana] = var_0_24,
		[MessageModes.Failure] = var_0_25,
		[MessageModes.Login] = var_0_25,
		[MessageModes.Status] = var_0_25,
		[MessageModes.Attention] = var_0_25
	}

	local var_33_0 = {
		modes = {},
		callback = var_0_27
	}

	for key, unusedValue in pairs(var_0_26) do
		registerMessageMode(key, var_0_27)

		var_33_0.modes[#var_33_0.modes + 1] = key
	end

	MiscAnalyser.registered = var_33_0
end

function MiscAnalyser.unregisterMessageModes(unusedArgument)
	local registered = MiscAnalyser.registered

	if not registered then
		return
	end

	for unusedValue, mode in ipairs(registered.modes) do
		unregisterMessageMode(mode, registered.callback)
	end

	MiscAnalyser.registered = nil
	var_0_26 = nil
end

function MiscAnalyser.addDamageReceived(unusedArgument, arg_35_1)
	MiscAnalyser.damageReceived = MiscAnalyser.damageReceived + (tonumber(arg_35_1) or 0)
end

local function var_0_28(arg_36_0, arg_36_1)
	local miscAnalyserRowWidget = g_ui.createWidget("MiscAnalyserRow", arg_36_0)

	miscAnalyserRowWidget.name:setText(var_0_4[arg_36_1.key] or arg_36_1.name)

	miscAnalyserRowWidget.build = var_0_14

	local var_36_1 = var_0_2[arg_36_1.key]

	if var_36_1 then
		miscAnalyserRowWidget.icon:setImageSource(var_0_0)
		miscAnalyserRowWidget.icon:setImageClip(string.format("%d 0 32 32", var_36_1 * 32))
	end

	MiscAnalyser.charmRows[arg_36_1.key] = miscAnalyserRowWidget

	return miscAnalyserRowWidget
end

function MiscAnalyser.updateWindow(unusedArgument, arg_37_1)
	local window = MiscAnalyser.window

	if not window or window:isDestroyed() or not window:isVisible() and not arg_37_1 then
		return
	end

	local var_37_1 = MiscAnalyser
	local contentsPanel = window.contentsPanel
	local var_37_3 = AnalyserSession:isActive() and math.floor(math.max(1, AnalyserSession:durationSeconds()) / 60) or -1

	if contentsPanel.session.shownMinutes ~= var_37_3 then
		contentsPanel.session.shownMinutes = var_37_3

		contentsPanel.session:setText(var_0_12())
	end

	local charmList = contentsPanel.charmList

	for index, entry in ipairs(var_37_1.charmOrder) do
		local var_37_5 = var_37_1.charmRows[entry.key] or var_0_28(charmList, entry)

		var_0_16(var_37_5, true, entry.count, entry.damage, entry)

		if charmList:getChildIndex(var_37_5) ~= index + 1 then
			charmList:moveChildToIndex(var_37_5, index + 1)
		end
	end

	charmList.empty:setVisible(#var_37_1.charmOrder == 0)

	local imbuementList = contentsPanel.imbuementList
	local var_37_7 = var_0_16(imbuementList.critical, var_37_1.crits > 0, var_37_1.crits, var_37_1.critDamage)

	var_37_7 = var_0_16(imbuementList.manaGain, var_37_1.manaGain > 0, var_37_1.manaGain) or var_37_7
	var_37_7 = var_0_16(imbuementList.lifeGain, var_37_1.lifeGain > 0, var_37_1.lifeGain) or var_37_7

	imbuementList.empty:setVisible(not var_37_7)

	local upgradeList = contentsPanel.upgradeList
	local var_37_9 = var_0_16(upgradeList.onslaught, var_37_1.onslaught > 0, var_37_1.onslaught, var_37_1.onslaughtDamage)

	var_37_9 = var_0_16(upgradeList.ruse, var_37_1.ruse > 0, var_37_1.ruse) or var_37_9
	var_37_9 = var_0_16(upgradeList.momentum, var_37_1.momentum > 0, var_37_1.momentum) or var_37_9
	var_37_9 = var_0_16(upgradeList.transcendence, var_37_1.transcendence > 0, var_37_1.transcendence) or var_37_9

	upgradeList.empty:setVisible(not var_37_9)

	local efficiencyList = contentsPanel.efficiencyList
	local var_37_11 = var_0_16(efficiencyList.critRate, var_37_1.crits > 0, var_37_1.crits, var_37_1.hits)

	var_37_11 = var_0_16(efficiencyList.charmShare, var_37_1.charmDamage > 0, var_37_1.charmDamage, var_37_1.damage) or var_37_11
	var_37_11 = var_0_16(efficiencyList.lifeGainHour, var_37_1.lifeGain > 0, AnalyserSession:perHourFromTotal(var_37_1.lifeGain)) or var_37_11
	var_37_11 = var_0_16(efficiencyList.manaGainHour, var_37_1.manaGain > 0, AnalyserSession:perHourFromTotal(var_37_1.manaGain)) or var_37_11
	var_37_11 = var_0_16(efficiencyList.sustain, var_37_1.lifeGain > 0 and var_37_1.damageReceived > 0, var_37_1.lifeGain, var_37_1.damageReceived) or var_37_11

	efficiencyList.empty:setVisible(not var_37_11)
end

function onMiscExtra(arg_38_0)
	if cancelNextRelease then
		cancelNextRelease = false

		return false
	end

	local popupMenuWidget = g_ui.createWidget("PopupMenu")

	popupMenuWidget:setGameMenu(true)
	popupMenuWidget:addOption(tr("Start New Session"), function()
		modules.game_analysers.startNewSession()
	end)
	popupMenuWidget:addSeparator()
	popupMenuWidget:addOption(tr("Copy to Clipboard"), function()
		MiscAnalyser:clipboardData()
	end)
	popupMenuWidget:addOption(tr("Save to File"), function()
		MiscAnalyser:saveToFile()
	end)
	popupMenuWidget:display(arg_38_0)

	return true
end

local function var_0_29()
	local var_42_0 = MiscAnalyser
	local var_42_1 = {}

	var_42_1[#var_42_1 + 1] = "Session data: From " .. os.date("%Y-%m-%d, %H:%M:%S", AnalyserSession.startUnix) .. " to " .. os.date("%Y-%m-%d, %H:%M:%S")
	var_42_1[#var_42_1 + 1] = "Session: " .. var_0_12()
	var_42_1[#var_42_1 + 1] = "Charm:"

	local charmOrder = var_42_0.charmOrder

	if #charmOrder == 0 then
		var_42_1[#var_42_1 + 1] = "\tNo data yet"
	end

	for unusedValue, entry in ipairs(charmOrder) do
		local formattedText = string.format("\t%s: %s", entry.name, var_0_10(entry.count))

		if entry.damage > 0 then
			formattedText = formattedText .. string.format(", %s damage (%s)", formatMoney(entry.damage, ","), var_0_9(entry.damage, var_42_0.damage))
		end

		var_42_1[#var_42_1 + 1] = formattedText
	end

	var_42_1[#var_42_1 + 1] = "Imbuement:"
	var_42_1[#var_42_1 + 1] = string.format("\tCritical Hit: %d (%s damage)", var_42_0.crits, formatMoney(var_42_0.critDamage, ","))
	var_42_1[#var_42_1 + 1] = "\tMana Gain: " .. formatMoney(var_42_0.manaGain, ",")
	var_42_1[#var_42_1 + 1] = "\tLife Gain: " .. formatMoney(var_42_0.lifeGain, ",")
	var_42_1[#var_42_1 + 1] = "Item Upgrade:"
	var_42_1[#var_42_1 + 1] = string.format("\tOnslaught: %d (%s damage, %d amplified)", var_42_0.onslaught, formatMoney(var_42_0.onslaughtDamage, ","), var_42_0.amplifiedOnslaught)
	var_42_1[#var_42_1 + 1] = "\tRuse: " .. var_42_0.ruse
	var_42_1[#var_42_1 + 1] = "\tMomentum: " .. var_42_0.momentum
	var_42_1[#var_42_1 + 1] = "\tTranscendence: " .. var_42_0.transcendence
	var_42_1[#var_42_1 + 1] = "Efficiency:"
	var_42_1[#var_42_1 + 1] = string.format("\tCritical Rate: %s (%d of %d hits)", var_0_9(var_42_0.crits, var_42_0.hits), var_42_0.crits, var_42_0.hits)
	var_42_1[#var_42_1 + 1] = string.format("\tCharm Damage: %s of %s damage", var_0_9(var_42_0.charmDamage, var_42_0.damage), formatMoney(var_42_0.damage, ","))
	var_42_1[#var_42_1 + 1] = "\tLife Gain/h: " .. formatMoney(AnalyserSession:perHourFromTotal(var_42_0.lifeGain), ",")
	var_42_1[#var_42_1 + 1] = "\tMana Gain/h: " .. formatMoney(AnalyserSession:perHourFromTotal(var_42_0.manaGain), ",")
	var_42_1[#var_42_1 + 1] = string.format("\tLeech Sustain: %s of %s damage taken", var_0_9(var_42_0.lifeGain, var_42_0.damageReceived), formatMoney(var_42_0.damageReceived, ","))

	return table.concat(var_42_1, "\n")
end

function MiscAnalyser.clipboardData(unusedArgument)
	g_window.setClipboardText(var_0_29())
end

function MiscAnalyser.saveToFile(unusedArgument)
	local var_44_0 = "Misc_Analyser_" .. os.date("%Y-%m-%d", AnalyserSession.startUnix) .. "_" .. AnalyserSession.startUnix .. ".txt"

	g_resources.writeFileContents(var_44_0, var_0_29())
	modules.game_textmessage.displayStatusMessage(tr("Misc Analyser data has been saved to location '%s'", var_44_0))
end
