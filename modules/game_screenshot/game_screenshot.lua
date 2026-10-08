local AUTO_SCREENSHOTS_ENABLED = false
local CLIENT_EVENT_TYPE_SIMPLE = 1
local CLIENT_EVENT_TYPE_ACHIEVEMENT = 2
local CLIENT_EVENT_TYPE_LEVEL = 4
local CLIENT_EVENT_TYPE_SKILL = 5
local CLIENT_EVENT_TYPE_BESTIARY = 6
local CLIENT_EVENT_BOSSDEFEATED = 1
local CLIENT_EVENT_DEATHPVE = 2
local CLIENT_EVENT_DEATHPVP = 3
local CLIENT_EVENT_PLAYERKILLASSIST = 4
local CLIENT_EVENT_PLAYERKILL = 5
local CLIENT_EVENT_PLAYERATTACKING = 6
local CLIENT_EVENT_TREASUREFOUND = 7
local CLIENT_EVENT_GIFTOFLIFE = 8
local AutoScreenshotEvents = {
	{
		label = "Level Up",
		enableDefault = true,
		optionKey = "levelUp"
	},
	{
		label = "Skill Up",
		enableDefault = true,
		optionKey = "skillUp"
	},
	{
		label = "Achievement",
		enableDefault = true,
		optionKey = "achievement"
	},
	{
		label = "Bestiary Entry Unlocked",
		enableDefault = false,
		optionKey = "bestiaryUnlocked"
	},
	{
		label = "Bestiary Entry Completed",
		enableDefault = false,
		optionKey = "bestiaryCompleted"
	},
	{
		label = "Treasure Found",
		enableDefault = false,
		optionKey = "treasureFound"
	},
	{
		label = "Valuable Loot",
		enableDefault = false,
		optionKey = "valuableLoot"
	},
	{
		label = "Boss Defeated",
		enableDefault = false,
		optionKey = "bossDefeated"
	},
	{
		label = "Death PvE",
		enableDefault = true,
		optionKey = "deathPvE"
	},
	{
		label = "Death PvP",
		enableDefault = false,
		optionKey = "deathPvP"
	},
	{
		label = "Player Kill",
		enableDefault = false,
		optionKey = "playerKill"
	},
	{
		label = "Player Kill Assist",
		enableDefault = false,
		optionKey = "playerKillAssist"
	},
	{
		label = "Player Attacking",
		enableDefault = false,
		optionKey = "playerAttacking"
	},
	{
		label = "Highest Damage Dealt",
		enableDefault = false,
		optionKey = "highestDamage"
	},
	{
		label = "Highest Healing Done",
		enableDefault = false,
		optionKey = "highestHealing"
	},
	{
		label = "Low Health",
		enableDefault = false,
		optionKey = "lowHealth"
	},
	{
		label = "Gift of Life Triggered",
		enableDefault = true,
		optionKey = "giftOfLife"
	}
}
local SIMPLE_EVENT_SCREENSHOTS = {
	[CLIENT_EVENT_BOSSDEFEATED] = {
		"bossDefeated",
		"BossDefeated"
	},
	[CLIENT_EVENT_DEATHPVE] = {
		"deathPvE",
		"DeathPvE"
	},
	[CLIENT_EVENT_DEATHPVP] = {
		"deathPvP",
		"DeathPvP"
	},
	[CLIENT_EVENT_PLAYERKILLASSIST] = {
		"playerKillAssist",
		"PlayerKillAssist"
	},
	[CLIENT_EVENT_PLAYERKILL] = {
		"playerKill",
		"PlayerKill"
	},
	[CLIENT_EVENT_PLAYERATTACKING] = {
		"playerAttacking",
		"PlayerAttacking"
	},
	[CLIENT_EVENT_TREASUREFOUND] = {
		"treasureFound",
		"TreasureFound"
	},
	[CLIENT_EVENT_GIFTOFLIFE] = {
		"giftOfLife",
		"GiftOfLifeTriggered"
	}
}
local autoScreenshotDir = "/auto_screenshots"
local var_0_17 = "/screenshots"

screenshotController = Controller:new()

local function ensureScreenshotDir()
	if not g_resources.directoryExists(autoScreenshotDir) then
		g_resources.makeDir(autoScreenshotDir)
	end
end

local function getScreenshotDirPath()
	ensureScreenshotDir()

	return g_resources.getWriteDir():gsub("[/\\]+$", ""):gsub("/", "\\") .. "\\auto_screenshots"
end

local function var_0_20()
	if not g_resources.directoryExists(var_0_17) then
		g_resources.makeDir(var_0_17)
	end
end

local function var_0_21()
	var_0_20()

	return g_resources.getWriteDir():gsub("[/\\]+$", ""):gsub("/", "\\") .. "\\screenshots"
end

local function showScreenshotSavedMessage(eventName)
	if not eventName or not modules.game_textmessage or not modules.game_textmessage.displayStatusMessage then
		return
	end

	modules.game_textmessage.displayStatusMessage(tr("Screenshot for event %s has been saved to location '%s'.", eventName, getScreenshotDirPath()))
end

local function getScreenshotOption(key)
	if modules.client_options and modules.client_options.getOption then
		local value = modules.client_options.getOption(key)

		if value ~= nil then
			return value
		end
	end

	return false
end

local function triggerAutoScreenshot(optionKey, labelSuffix)
	if not getScreenshotOption("enableAutoScreenshots") then
		return
	end

	if not getScreenshotOption(optionKey) then
		return
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local name = player:getName() or "player"
	local level = player:getLevel() or 1
	local screenshotName = name .. level .. "_" .. labelSuffix:gsub("%s+", "") .. "_" .. os.date("%Y%m%d%H%M%S") .. ".png"

	takeScreenshot(autoScreenshotDir .. "/" .. screenshotName, labelSuffix)
end

local function onClientEvent(eventType, ...)
	if eventType == CLIENT_EVENT_TYPE_SIMPLE then
		local simpleType = select(1, ...)
		local entry = SIMPLE_EVENT_SCREENSHOTS[simpleType]

		if entry then
			triggerAutoScreenshot(entry[1], entry[2])
		end

		return
	end

	if eventType == CLIENT_EVENT_TYPE_ACHIEVEMENT then
		triggerAutoScreenshot("achievement", "Achievement")

		return
	end

	if eventType == CLIENT_EVENT_TYPE_LEVEL then
		triggerAutoScreenshot("levelUp", "LevelUp")

		return
	end

	if eventType == CLIENT_EVENT_TYPE_SKILL then
		triggerAutoScreenshot("skillUp", "SkillUp")

		return
	end

	if eventType == CLIENT_EVENT_TYPE_BESTIARY then
		local progressLevel = select(2, ...) or 0

		if progressLevel == 0 then
			triggerAutoScreenshot("bestiaryUnlocked", "BestiaryEntryUnlocked")
		elseif progressLevel >= 3 then
			triggerAutoScreenshot("bestiaryCompleted", "BestiaryEntryCompleted")
		end
	end
end

function screenshotController.onInit(unusedArgument)
	Keybind.new("Misc.", "Take Screenshot", "", "")
	Keybind.bind("Misc.", "Take Screenshot", {
		{
			type = KEY_DOWN,
			callback = takeManualScreenshot
		}
	})
end

function screenshotController.onTerminate(unusedArgument)
	Keybind.delete("Misc.", "Take Screenshot")

	AutoScreenshotEvents = {}
end

function screenshotController.onGameStart(unusedArgument)
	ensureScreenshotDir()
	screenshotController:registerEvents(g_game, {
		onClientEvent = onClientEvent
	})
end

function screenshotController.onGameEnd(self)
	return
end

function resetValues()
	if not modules.client_options or not modules.client_options.setOption then
		return
	end

	modules.client_options.setOption("enableAutoScreenshots", true, true)
	modules.client_options.setOption("onlyCaptureGameWindow", false, true)
	modules.client_options.setOption("keepBacklog", false, true)

	for _, screenshotEvent in ipairs(AutoScreenshotEvents) do
		modules.client_options.setOption(screenshotEvent.optionKey, screenshotEvent.enableDefault, true)
	end
end

function takeScreenshot(name, eventName)
	if not AUTO_SCREENSHOTS_ENABLED then
		return
	end

	if not g_game.isOnline() then
		return
	end

	ensureScreenshotDir()
	screenshotController:scheduleEvent(function()
		if getScreenshotOption("onlyCaptureGameWindow") then
			g_app.doMapScreenshot(name)
		else
			g_app.doScreenshot(name)
		end

		showScreenshotSavedMessage(eventName)
	end, 50, "screenshotScheduleEvent")
end

function takeManualScreenshot()
	if not g_game.isOnline() then
		return
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	var_0_20()

	local name = (localPlayer:getName() or "player"):gsub("[^%w%-_]", "_")
	local formattedText = string.format("%s_%s_%03d.png", name, os.date("%Y%m%d_%H%M%S"), g_clock.millis() % 1000)
	local var_16_3 = var_0_17 .. "/" .. formattedText

	screenshotController:scheduleEvent(function()
		if getScreenshotOption("onlyCaptureGameWindow") then
			g_app.doMapScreenshot(var_16_3)
		else
			g_app.doScreenshot(var_16_3)
		end

		if modules.game_textmessage and modules.game_textmessage.displayStatusMessage then
			modules.game_textmessage.displayStatusMessage(tr("Screenshot has been saved to location '%s'.", var_0_21()))
		end
	end, 50, "manualScreenshotScheduleEvent")
end

function OpenFolder()
	g_platform.openDir(getScreenshotDirPath())
end
