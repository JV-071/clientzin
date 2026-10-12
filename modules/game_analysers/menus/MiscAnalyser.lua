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

local imageSourcePath = "/modules/game_cyclopedia/images/charms/monster-bonus-effects"
local MISC_ANALYSER_ICON_SHEET = "/modules/game_analysers/images/misc-analyser-icons"
local CHARM_ICON_INDICES = {
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
local CRITICAL_HIT_CHARMS = {
	["savage blow"] = true,
	["low blow"] = true
}
local CHARM_DISPLAY_NAMES = {
	["adrenaline burst"] = "Adrenaline"
}
local ROW_HEIGHT = 15
local ROW_WITH_DETAIL_HEIGHT = 28
local METRIC_ROW_DEFINITIONS = {
	{
		id = "critical",
		list = "imbuementList",
		clip = "0 0 12 12",
		name = "Critical Hit",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "manaGain",
		list = "imbuementList",
		clip = "12 0 12 12",
		name = "Mana Gain",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "lifeGain",
		list = "imbuementList",
		clip = "24 0 12 12",
		name = "Life Gain",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "onslaught",
		list = "upgradeList",
		clip = "36 0 12 12",
		name = "Onslaught",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "ruse",
		list = "upgradeList",
		clip = "48 0 12 12",
		name = "Ruse",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "momentum",
		list = "upgradeList",
		clip = "60 0 12 12",
		name = "Momentum",
		icon = MISC_ANALYSER_ICON_SHEET
	},
	{
		id = "transcendence",
		list = "upgradeList",
		clip = "72 0 12 12",
		name = "Transcendence",
		icon = MISC_ANALYSER_ICON_SHEET
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

local function formatCompactAmount(amount)
	amount = math.floor(tonumber(amount) or 0)

	if amount < 10000 then
		return formatMoney(amount, ",")
	end

	local scaledAmount = amount / 1000
	local suffix = "k"

	if amount >= 1000000 then
		scaledAmount, suffix = amount / 1000000, "M"
	end

	if scaledAmount >= 100 then
		return math.floor(scaledAmount) .. suffix
	end

	return string.format(scaledAmount >= 10 and "%.1f" or "%.2f", scaledAmount):gsub("0+$", ""):gsub("%.$", "") .. suffix
end

local function formatPercentage(part, total)
	if not total or total <= 0 then
		return "0%"
	end

	local percentage = part * 100 / total

	if percentage >= 10 then
		return string.format("%d%%", math.floor(percentage + 0.5))
	end

	return string.format("%.1f%%", percentage)
end

local function formatProcCount(count)
	return count == 1 and "1 proc" or string.format("%d procs", count)
end

local function titleCaseCharmName(name)
	return (name:gsub("(%a)([%w']*)", function(firstLetter, wordRemainder)
		return firstLetter:upper() .. wordRemainder
	end))
end

local function formatSessionDuration()
	if not AnalyserSession:isActive() then
		return "00:00h"
	end

	local durationSeconds = math.max(1, AnalyserSession:durationSeconds())

	return string.format("%02d:%02dh", math.floor(durationSeconds / 3600), math.floor(durationSeconds % 3600 / 60))
end

local METRIC_FORMATTERS = {
	critical = function(stats)
		return tostring(stats.crits), tr("%d critical hits (attacks, spells and runes)\nDamage: %s\nAverage: %s", stats.crits, formatMoney(stats.critDamage, ","), formatMoney(math.floor(stats.critDamage / math.max(1, stats.crits)), ",")), formatCompactAmount(stats.critDamage)
	end,
	manaGain = function(stats)
		return formatCompactAmount(stats.manaGain), tr("Mana gained from leech: %s", formatMoney(stats.manaGain, ","))
	end,
	lifeGain = function(stats)
		return formatCompactAmount(stats.lifeGain), tr("Hit points gained from leech: %s", formatMoney(stats.lifeGain, ","))
	end,
	onslaught = function(stats)
		local tooltip = tr("%d Onslaught hits\nDamage: %s", stats.onslaught, formatMoney(stats.onslaughtDamage, ","))

		if stats.amplifiedOnslaught > 0 then
			tooltip = tooltip .. "\n" .. tr("Amplified: %d", stats.amplifiedOnslaught)
		end

		return tostring(stats.onslaught), tooltip, formatCompactAmount(stats.onslaughtDamage)
	end,
	ruse = function(stats)
		return tostring(stats.ruse), tr("Attacks dodged: %d (Ruse and Wheel of Destiny dodge)", stats.ruse)
	end,
	momentum = function(stats)
		return tostring(stats.momentum), tr("Momentum triggers: %d (-2s on spell cooldowns each)", stats.momentum)
	end,
	transcendence = function(stats)
		return tostring(stats.transcendence), tr("Transcendence triggers: %d", stats.transcendence)
	end,
	critRate = function(stats)
		return formatPercentage(stats.crits, stats.hits), tr("%d of %d hits were critical", stats.crits, stats.hits)
	end,
	charmShare = function(stats)
		return formatPercentage(stats.charmDamage, stats.damage), tr("%s of %s damage came from charms", formatMoney(stats.charmDamage, ","), formatMoney(stats.damage, ","))
	end,
	lifeGainHour = function(unusedArgument, lifeGainPerHour)
		return formatCompactAmount(lifeGainPerHour), tr("Hit points gained from leech per hour: %s", formatMoney(lifeGainPerHour, ","))
	end,
	manaGainHour = function(unusedArgument, manaGainPerHour)
		return formatCompactAmount(manaGainPerHour), tr("Mana gained from leech per hour: %s", formatMoney(manaGainPerHour, ","))
	end,
	sustain = function(stats)
		return formatPercentage(stats.lifeGain, stats.damageReceived), tr("Life Gain covered this share of the damage you took\nLife Gain: %s\nDamage taken: %s", formatMoney(stats.lifeGain, ","), formatMoney(stats.damageReceived, ","))
	end
}

local function build(charmStats)
	local tooltip = tr("%s charm: %s", charmStats.name, formatProcCount(charmStats.count))

	if charmStats.damage > 0 then
		tooltip = tooltip .. "\n" .. tr("Damage: %s\nAverage: %s", formatMoney(charmStats.damage, ","), formatMoney(math.floor(charmStats.damage / math.max(1, charmStats.count)), ","))

		return tostring(charmStats.count), tooltip, formatCompactAmount(charmStats.damage)
	end

	if CRITICAL_HIT_CHARMS[charmStats.key] then
		tooltip = tooltip .. "\n" .. tr("Critical hits against the charmed creature.")
	end

	return tostring(charmStats.count), tooltip
end

local function updateRowDetail(rowWidget, text)
	local hasDetail = text ~= nil

	if rowWidget.hasDetail ~= hasDetail then
		rowWidget.hasDetail = hasDetail

		rowWidget.detailName:setVisible(hasDetail)
		rowWidget.detailValue:setVisible(hasDetail)
		rowWidget:setHeight(hasDetail and ROW_WITH_DETAIL_HEIGHT or ROW_HEIGHT)
	end

	if hasDetail then
		rowWidget.detailValue:setText(text)
	end
end

local function updateMetricRow(rowWidget, visible, primaryValue, secondaryValue, stats)
	rowWidget:setVisible(visible)

	if not visible then
		return false
	end

	if rowWidget.shownA ~= primaryValue or rowWidget.shownB ~= secondaryValue then
		rowWidget.shownA, rowWidget.shownB = primaryValue, secondaryValue

		local text, tooltip, detailText = rowWidget.build(stats or MiscAnalyser, primaryValue, secondaryValue)

		rowWidget.value:setText(text)
		rowWidget:setTooltip(tooltip)
		updateRowDetail(rowWidget, detailText)
	end

	return true
end

local function invalidateRowValues(rowWidget)
	rowWidget.shownA, rowWidget.shownB = nil
end

function MiscAnalyser.create(unusedArgument)
	MiscAnalyser.window = openedWindows.miscButton
	MiscAnalyser.charmRows = {}

	MiscAnalyser:clearData()

	local contentsPanel = MiscAnalyser.window.contentsPanel

	for unusedValue, entry in ipairs(METRIC_ROW_DEFINITIONS) do
		local rowWidget = contentsPanel[entry.list][entry.id]

		rowWidget.name:setText(tr(entry.name))

		rowWidget.build = METRIC_FORMATTERS[entry.id]

		if entry.icon then
			rowWidget.icon:setImageSource(entry.icon)

			if entry.clip then
				rowWidget.icon:setImageClip(entry.clip)
			end
		end

		rowWidget:setVisible(false)
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
		invalidateRowValues(charmRow)
	end

	local contentsPanel = MiscAnalyser.window.contentsPanel

	for unusedValue, entry in ipairs(METRIC_ROW_DEFINITIONS) do
		invalidateRowValues(contentsPanel[entry.list][entry.id])
	end

	MiscAnalyser:updateWindow(true)
end

local UNKNOWN_CHARM_SORT_INDEX = 1000

local function compareCharmOrder(leftCharm, rightCharm)
	local leftSortIndex = CHARM_ICON_INDICES[leftCharm.key] or UNKNOWN_CHARM_SORT_INDEX
	local rightSortIndex = CHARM_ICON_INDICES[rightCharm.key] or UNKNOWN_CHARM_SORT_INDEX

	if leftSortIndex ~= rightSortIndex then
		return leftSortIndex < rightSortIndex
	end

	return leftCharm.name < rightCharm.name
end

local function getOrCreateCharmStats(charmKey)
	local charmStats = MiscAnalyser.charms[charmKey]

	if not charmStats then
		charmStats = {
			count = 0,
			damage = 0,
			key = charmKey,
			name = titleCaseCharmName(charmKey)
		}
		MiscAnalyser.charms[charmKey] = charmStats

		local charmOrder = MiscAnalyser.charmOrder

		charmOrder[#charmOrder + 1] = charmStats

		table.sort(charmOrder, compareCharmOrder)
	end

	return charmStats
end

local parsedCharmKeys = {}

local function extractCharmKeys(message)
	local charmCount = 0

	if not message:find(" charm", 1, true) then
		return charmCount
	end

	for parenthesizedText in message:gmatch("%(([^()]*)%)") do
		for charmName in parenthesizedText:gmatch("([%a][%a' ]-) charm") do
			charmCount = charmCount + 1
			parsedCharmKeys[charmCount] = charmName:lower()
		end
	end

	return charmCount
end

local function processDamageMessage(message)
	if not message:find("due to your", 1, true) then
		return
	end

	local numericValue = tonumber(message:match("loses (%d+) hitpoints?") or message:match("loses (%d+) mana")) or 0

	MiscAnalyser.damage = MiscAnalyser.damage + numericValue

	local countedCharmDamage = false

	for charmIndex = 1, extractCharmKeys(message) do
		local charmKey = parsedCharmKeys[charmIndex]
		local charmStats = getOrCreateCharmStats(charmKey)

		charmStats.count = charmStats.count + 1

		if not CRITICAL_HIT_CHARMS[charmKey] and not countedCharmDamage then
			countedCharmDamage = true
			charmStats.damage = charmStats.damage + numericValue
			MiscAnalyser.charmDamage = MiscAnalyser.charmDamage + numericValue
		end
	end

	if countedCharmDamage then
		return
	end

	MiscAnalyser.hits = MiscAnalyser.hits + 1

	if message:find("critical attack", 1, true) then
		MiscAnalyser.crits = MiscAnalyser.crits + 1
		MiscAnalyser.critDamage = MiscAnalyser.critDamage + numericValue
	end

	if message:find("fatal attack", 1, true) or message:find("Onslaught)", 1, true) then
		MiscAnalyser.onslaught = MiscAnalyser.onslaught + 1
		MiscAnalyser.onslaughtDamage = MiscAnalyser.onslaughtDamage + numericValue

		if message:find("mplified", 1, true) then
			MiscAnalyser.amplifiedOnslaught = MiscAnalyser.amplifiedOnslaught + 1
		end
	end
end

local function processLeechMessage(message)
	local healedAmountText = message:match("^You were healed for (%d+) hitpoints?")

	if healedAmountText then
		MiscAnalyser.lifeGain = MiscAnalyser.lifeGain + tonumber(healedAmountText)

		return
	end

	local restoredManaText = message:match("^You gained (%d+) mana") or message:match("^You were restored for (%d+) mana")

	if restoredManaText then
		MiscAnalyser.manaGain = MiscAnalyser.manaGain + tonumber(restoredManaText)
	end
end

local function processStatusMessage(message)
	local charmCount = extractCharmKeys(message)

	if charmCount > 0 then
		for charmIndex = 1, charmCount do
			local charmStats = getOrCreateCharmStats(parsedCharmKeys[charmIndex])

			charmStats.count = charmStats.count + 1
		end

		return
	end

	if message:find("^Momentum was triggered") then
		MiscAnalyser.momentum = MiscAnalyser.momentum + 1
	elseif message:find("^Transcendence was triggered") then
		MiscAnalyser.transcendence = MiscAnalyser.transcendence + 1
	elseif message:find("^You dodged an attack%.?$") then
		MiscAnalyser.ruse = MiscAnalyser.ruse + 1
	end
end

local messageHandlersByMode

local function dispatchAnalyserMessage(messageMode, message)
	local handler = messageHandlersByMode and messageHandlersByMode[messageMode]

	if handler and type(message) == "string" then
		handler(message)
	end
end

function MiscAnalyser.registerMessageModes(unusedArgument)
	MiscAnalyser:unregisterMessageModes()

	messageHandlersByMode = {
		[MessageModes.DamageDealed] = processDamageMessage,
		[MessageModes.Heal] = processLeechMessage,
		[MessageModes.Mana] = processLeechMessage,
		[MessageModes.Failure] = processStatusMessage,
		[MessageModes.Login] = processStatusMessage,
		[MessageModes.Loot] = processStatusMessage,
		[MessageModes.Status] = processStatusMessage,
		[MessageModes.Attention] = processStatusMessage
	}

	local registered = {
		modes = {},
		callback = dispatchAnalyserMessage
	}

	for key, unusedValue in pairs(messageHandlersByMode) do
		registerMessageMode(key, dispatchAnalyserMessage)

		registered.modes[#registered.modes + 1] = key
	end

	MiscAnalyser.registered = registered
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
	messageHandlersByMode = nil
end

function MiscAnalyser.addDamageReceived(unusedArgument, damageAmount)
	MiscAnalyser.damageReceived = MiscAnalyser.damageReceived + (tonumber(damageAmount) or 0)
end

local function createCharmRow(parentWidget, charmStats)
	local miscAnalyserRowWidget = g_ui.createWidget("MiscAnalyserRow", parentWidget)

	miscAnalyserRowWidget.name:setText(CHARM_DISPLAY_NAMES[charmStats.key] or charmStats.name)

	miscAnalyserRowWidget.build = build

	local iconIndex = CHARM_ICON_INDICES[charmStats.key]

	if iconIndex then
		miscAnalyserRowWidget.icon:setImageSource(imageSourcePath)
		miscAnalyserRowWidget.icon:setImageClip(string.format("%d 0 32 32", iconIndex * 32))
	end

	MiscAnalyser.charmRows[charmStats.key] = miscAnalyserRowWidget

	return miscAnalyserRowWidget
end

function MiscAnalyser.updateWindow(unusedArgument, forceRefresh)
	local window = MiscAnalyser.window

	if not window or window:isDestroyed() or not window:isVisible() and not forceRefresh then
		return
	end

	local stats = MiscAnalyser
	local contentsPanel = window.contentsPanel
	local shownMinutes = AnalyserSession:isActive() and math.floor(math.max(1, AnalyserSession:durationSeconds()) / 60) or -1

	if contentsPanel.session.shownMinutes ~= shownMinutes then
		contentsPanel.session.shownMinutes = shownMinutes

		contentsPanel.session:setText(formatSessionDuration())
	end

	local charmList = contentsPanel.charmList

	for index, entry in ipairs(stats.charmOrder) do
		local charmRow = stats.charmRows[entry.key] or createCharmRow(charmList, entry)

		updateMetricRow(charmRow, true, entry.count, entry.damage, entry)

		if charmList:getChildIndex(charmRow) ~= index + 1 then
			charmList:moveChildToIndex(charmRow, index + 1)
		end
	end

	charmList.empty:setVisible(#stats.charmOrder == 0)

	local imbuementList = contentsPanel.imbuementList
	local hasImbuementRows = updateMetricRow(imbuementList.critical, stats.crits > 0, stats.crits, stats.critDamage)

	hasImbuementRows = updateMetricRow(imbuementList.manaGain, stats.manaGain > 0, stats.manaGain) or hasImbuementRows
	hasImbuementRows = updateMetricRow(imbuementList.lifeGain, stats.lifeGain > 0, stats.lifeGain) or hasImbuementRows

	imbuementList.empty:setVisible(not hasImbuementRows)

	local upgradeList = contentsPanel.upgradeList
	local hasUpgradeRows = updateMetricRow(upgradeList.onslaught, stats.onslaught > 0, stats.onslaught, stats.onslaughtDamage)

	hasUpgradeRows = updateMetricRow(upgradeList.ruse, stats.ruse > 0, stats.ruse) or hasUpgradeRows
	hasUpgradeRows = updateMetricRow(upgradeList.momentum, stats.momentum > 0, stats.momentum) or hasUpgradeRows
	hasUpgradeRows = updateMetricRow(upgradeList.transcendence, stats.transcendence > 0, stats.transcendence) or hasUpgradeRows

	upgradeList.empty:setVisible(not hasUpgradeRows)

	local efficiencyList = contentsPanel.efficiencyList
	local hasEfficiencyRows = updateMetricRow(efficiencyList.critRate, stats.crits > 0, stats.crits, stats.hits)

	hasEfficiencyRows = updateMetricRow(efficiencyList.charmShare, stats.charmDamage > 0, stats.charmDamage, stats.damage) or hasEfficiencyRows
	hasEfficiencyRows = updateMetricRow(efficiencyList.lifeGainHour, stats.lifeGain > 0, AnalyserSession:perHourFromTotal(stats.lifeGain)) or hasEfficiencyRows
	hasEfficiencyRows = updateMetricRow(efficiencyList.manaGainHour, stats.manaGain > 0, AnalyserSession:perHourFromTotal(stats.manaGain)) or hasEfficiencyRows
	hasEfficiencyRows = updateMetricRow(efficiencyList.sustain, stats.lifeGain > 0 and stats.damageReceived > 0, stats.lifeGain, stats.damageReceived) or hasEfficiencyRows

	efficiencyList.empty:setVisible(not hasEfficiencyRows)
end

function onMiscExtra(mousePosition)
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
	popupMenuWidget:display(mousePosition)

	return true
end

local function buildSessionReport()
	local stats = MiscAnalyser
	local reportLines = {}

	reportLines[#reportLines + 1] = "Session data: From " .. os.date("%Y-%m-%d, %H:%M:%S", AnalyserSession.startUnix) .. " to " .. os.date("%Y-%m-%d, %H:%M:%S")
	reportLines[#reportLines + 1] = "Session: " .. formatSessionDuration()
	reportLines[#reportLines + 1] = "Charm:"

	local charmOrder = stats.charmOrder

	if #charmOrder == 0 then
		reportLines[#reportLines + 1] = "\tNo data yet"
	end

	for unusedValue, entry in ipairs(charmOrder) do
		local formattedText = string.format("\t%s: %s", entry.name, formatProcCount(entry.count))

		if entry.damage > 0 then
			formattedText = formattedText .. string.format(", %s damage (%s)", formatMoney(entry.damage, ","), formatPercentage(entry.damage, stats.damage))
		end

		reportLines[#reportLines + 1] = formattedText
	end

	reportLines[#reportLines + 1] = "Imbuement:"
	reportLines[#reportLines + 1] = string.format("\tCritical Hit: %d (%s damage)", stats.crits, formatMoney(stats.critDamage, ","))
	reportLines[#reportLines + 1] = "\tMana Gain: " .. formatMoney(stats.manaGain, ",")
	reportLines[#reportLines + 1] = "\tLife Gain: " .. formatMoney(stats.lifeGain, ",")
	reportLines[#reportLines + 1] = "Item Upgrade:"
	reportLines[#reportLines + 1] = string.format("\tOnslaught: %d (%s damage, %d amplified)", stats.onslaught, formatMoney(stats.onslaughtDamage, ","), stats.amplifiedOnslaught)
	reportLines[#reportLines + 1] = "\tRuse: " .. stats.ruse
	reportLines[#reportLines + 1] = "\tMomentum: " .. stats.momentum
	reportLines[#reportLines + 1] = "\tTranscendence: " .. stats.transcendence
	reportLines[#reportLines + 1] = "Efficiency:"
	reportLines[#reportLines + 1] = string.format("\tCritical Rate: %s (%d of %d hits)", formatPercentage(stats.crits, stats.hits), stats.crits, stats.hits)
	reportLines[#reportLines + 1] = string.format("\tCharm Damage: %s of %s damage", formatPercentage(stats.charmDamage, stats.damage), formatMoney(stats.damage, ","))
	reportLines[#reportLines + 1] = "\tLife Gain/h: " .. formatMoney(AnalyserSession:perHourFromTotal(stats.lifeGain), ",")
	reportLines[#reportLines + 1] = "\tMana Gain/h: " .. formatMoney(AnalyserSession:perHourFromTotal(stats.manaGain), ",")
	reportLines[#reportLines + 1] = string.format("\tLeech Sustain: %s of %s damage taken", formatPercentage(stats.lifeGain, stats.damageReceived), formatMoney(stats.damageReceived, ","))

	return table.concat(reportLines, "\n")
end

function MiscAnalyser.clipboardData(unusedArgument)
	g_window.setClipboardText(buildSessionReport())
end

function MiscAnalyser.saveToFile(unusedArgument)
	local fileName = "Misc_Analyser_" .. os.date("%Y-%m-%d", AnalyserSession.startUnix) .. "_" .. AnalyserSession.startUnix .. ".txt"

	g_resources.writeFileContents(fileName, buildSessionReport())
	modules.game_textmessage.displayStatusMessage(tr("Misc Analyser data has been saved to location '%s'", fileName))
end
