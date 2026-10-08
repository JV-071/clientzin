local musicFilename = "sounds/startup"
local musicChannel
local startupLoadBox
local var_0_3 = 100
local var_0_4 = 1500

if g_sounds then
	musicChannel = g_sounds.getChannel(SoundChannels.Music)
end

local function hideLoginStartupUI()
	if modules.client_topmenu and modules.client_topmenu.hide then
		modules.client_topmenu.hide()
	end

	if g_modules.getModule("client_bottommenu") and g_modules.getModule("client_bottommenu"):isLoaded() and modules.client_bottommenu.hide then
		modules.client_bottommenu.hide()
	end

	if modules.client_background and modules.client_background.getBackground then
		local background = modules.client_background.getBackground()

		if background and background.serverLogo then
			background.serverLogo:hide()
		end
	end

	if EnterGame and EnterGame.hide then
		EnterGame.hide()
	end
end

local function showStartupLoadingBox()
	local box = g_ui.createWidget("MessageBoxWindow", rootWidget)

	box:setSize("250 60")
	box:setMarginTop(252)

	local holder = box:getChildById("holder")

	if holder then
		holder:destroy()
	end

	for _, child in pairs(box:recursiveGetChildrenByStyleName("HorizontalSeparator")) do
		child:destroy()
	end

	box:getChildById("title"):setText(tr("Please Wait"))

	local content = box:getChildById("content")

	content:setText(tr("Loading game files"))
	content:setMarginTop(27)

	if content.setFont then
		content:setFont("Verdana Bold-11px-new")
	end

	box:raise()
	box:focus()

	return box
end

local function destroyStartupLoadingBox()
	if startupLoadBox then
		startupLoadBox:destroy()

		startupLoadBox = nil
	end
end

local function var_0_8(arg_4_0)
	if not startupLoadBox or startupLoadBox:isDestroyed() then
		return
	end

	local content = startupLoadBox:getChildById("content")

	if content then
		content:setText(arg_4_0)
	end
end

local function var_0_9()
	return Cyclopedia and Cyclopedia.ItemsIndexPreloading and not Cyclopedia.ItemsIndexBuilt
end

function setMusic(filename)
	musicFilename = filename

	if not g_game.isOnline() then
		musicChannel:stop()
		musicChannel:enqueue(musicFilename, 3)
	end
end

function startup()
	if musicChannel then
		musicChannel:enqueue(musicFilename, 3)
		connect(g_game, {
			onGameStart = function()
				musicChannel:stop(3)
			end
		})
		connect(g_game, {
			onGameEnd = function()
				g_sounds.stopAll()
				musicChannel:enqueue(musicFilename, 3)
			end
		})
	end

	local errtitle
	local errmsg

	if g_graphics.getRenderer():lower():match("gdi generic") then
		errtitle = tr("Graphics card driver not detected")
		errmsg = tr("No graphics card detected, everything will be drawn using the CPU,\nthus the performance will be really bad.\nPlease update your graphics driver to have a better performance.")
	end

	local function proceedToEnterGame()
		if EnterGame.showPanels then
			EnterGame.showPanels()
		end

		EnterGame.firstShow()
	end

	local announcementsLoaded = modules.game_announcements ~= nil

	local function finishStartup()
		destroyStartupLoadingBox()

		if errmsg or errtitle then
			displayErrorBox(errtitle, errmsg).onOk = proceedToEnterGame
		elseif not announcementsLoaded then
			proceedToEnterGame()
		else
			EnterGame.loadStartupData()
			proceedToEnterGame()

			if modules.game_announcements.onClientStartup then
				modules.game_announcements.onClientStartup()
			end
		end
	end

	hideLoginStartupUI()

	startupLoadBox = showStartupLoadingBox()

	var_0_8(tr("Loading interface"))

	local var_7_5 = g_clock.realMillis()

	local function var_7_6()
		local var_12_0 = g_clock.realMillis() - var_7_5

		if var_12_0 < var_0_3 then
			scheduleEvent(var_7_6, var_0_3 - var_12_0)

			return
		end

		if not var_0_9() or var_12_0 >= var_0_4 then
			finishStartup()

			return
		end

		scheduleEvent(var_7_6, 50)
	end

	scheduleEvent(function()
		if Cyclopedia and Cyclopedia.ensureStylesLoaded then
			Cyclopedia.ensureStylesLoaded()
		end

		local var_13_0 = {
			function()
				var_0_8(tr("Loading items"))

				if Cyclopedia and Cyclopedia.startItemsIndexPreload then
					Cyclopedia.startItemsIndexPreload(true)
				end
			end,
			function()
				var_0_8(tr("Loading spells"))

				if Cyclopedia and Cyclopedia.preloadMagicalArchivesSpells then
					Cyclopedia.preloadMagicalArchivesSpells()
				end
			end,
			function()
				var_0_8(tr("Loading map"))

				if modules.game_minimap and modules.game_minimap.loadPersistentMinimapData then
					modules.game_minimap.loadPersistentMinimapData()
				end
			end
		}
		local var_13_1 = 1

		local function var_13_2()
			if var_13_1 > #var_13_0 or g_clock.realMillis() - var_7_5 >= var_0_4 then
				if var_13_1 <= #var_13_0 then
					local var_17_0 = {}

					for iter_17_0 = var_13_1, #var_13_0 do
						var_17_0[#var_17_0 + 1] = var_13_0[iter_17_0]
					end

					addEvent(function()
						for iter_18_0 = 1, #var_17_0 do
							var_17_0[iter_18_0]()
						end
					end)
				end

				var_7_6()

				return
			end

			var_13_0[var_13_1]()

			var_13_1 = var_13_1 + 1

			scheduleEvent(var_13_2, 0)
		end

		var_13_2()
	end, 0)

	if g_sounds then
		g_sounds.setAudioEnabled(true)
		g_settings.set("enableAudio", true)
		g_sounds.getChannel(SoundChannels.Music):setEnabled(g_settings.getBoolean("enableMusicSound"))
	end
end

function init()
	connect(g_app, {
		onRun = startup
	})

	if musicChannel then
		g_sounds.preload(musicFilename)
	end
end

function terminate()
	disconnect(g_app, {
		onRun = startup
	})
end
