local musicFilename = "sounds/startup"
local musicChannel
local startupLoadBox
local MIN_STARTUP_VISIBLE_MILLIS = 100
local STARTUP_PRELOAD_TIMEOUT_MILLIS = 1500

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

local function setStartupLoadingText(loadingText)
	if not startupLoadBox or startupLoadBox:isDestroyed() then
		return
	end

	local content = startupLoadBox:getChildById("content")

	if content then
		content:setText(loadingText)
	end
end

local function isItemIndexPreloading()
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

	setStartupLoadingText(tr("Loading interface"))

	local startupStartedAtMillis = g_clock.realMillis()

	local function waitForStartupPreload()
		local startupElapsedMillis = g_clock.realMillis() - startupStartedAtMillis

		if startupElapsedMillis < MIN_STARTUP_VISIBLE_MILLIS then
			scheduleEvent(waitForStartupPreload, MIN_STARTUP_VISIBLE_MILLIS - startupElapsedMillis)

			return
		end

		if not isItemIndexPreloading() or startupElapsedMillis >= STARTUP_PRELOAD_TIMEOUT_MILLIS then
			finishStartup()

			return
		end

		scheduleEvent(waitForStartupPreload, 50)
	end

	scheduleEvent(function()
		if Cyclopedia and Cyclopedia.ensureStylesLoaded then
			Cyclopedia.ensureStylesLoaded()
		end

		local preloadTasks = {
			function()
				setStartupLoadingText(tr("Loading items"))

				if Cyclopedia and Cyclopedia.startItemsIndexPreload then
					Cyclopedia.startItemsIndexPreload(true)
				end
			end,
			function()
				setStartupLoadingText(tr("Loading spells"))

				if Cyclopedia and Cyclopedia.preloadMagicalArchivesSpells then
					Cyclopedia.preloadMagicalArchivesSpells()
				end
			end,
			function()
				setStartupLoadingText(tr("Loading map"))

				if modules.game_minimap and modules.game_minimap.loadPersistentMinimapData then
					modules.game_minimap.loadPersistentMinimapData()
				end
			end
		}
		local nextPreloadTaskIndex = 1

		local function runNextPreloadTask()
			if nextPreloadTaskIndex > #preloadTasks or g_clock.realMillis() - startupStartedAtMillis >= STARTUP_PRELOAD_TIMEOUT_MILLIS then
				if nextPreloadTaskIndex <= #preloadTasks then
					local deferredPreloadTasks = {}

					for remainingTaskIndex = nextPreloadTaskIndex, #preloadTasks do
						deferredPreloadTasks[#deferredPreloadTasks + 1] = preloadTasks[remainingTaskIndex]
					end

					addEvent(function()
						for deferredTaskIndex = 1, #deferredPreloadTasks do
							deferredPreloadTasks[deferredTaskIndex]()
						end
					end)
				end

				waitForStartupPreload()

				return
			end

			preloadTasks[nextPreloadTaskIndex]()

			nextPreloadTaskIndex = nextPreloadTaskIndex + 1

			scheduleEvent(runNextPreloadTask, 0)
		end

		runNextPreloadTask()
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
