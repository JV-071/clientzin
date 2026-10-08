-- chunkname: @/client_background/background.lua

local background
local toggleState = true
local timeLoopBackgroundEffect = 5000
local mapReadyEvent
local mapTransitionStartedAt = 0
local mapTransitionActive = false
local MAP_READY_POLL_MS = 16
local MAP_READY_TIMEOUT_MS = 3000

local function cancelMapReadyEvent()
	if mapReadyEvent then
		removeEvent(mapReadyEvent)

		mapReadyEvent = nil
	end
end

local function finishMapTransition(timedOut)
	cancelMapReadyEvent()

	mapTransitionActive = false

	if timedOut then
		g_logger.warning(string.format("[login] map loading art timed out after %d ms", MAP_READY_TIMEOUT_MS))
	else
		g_logger.info(string.format("[login] map ready after %d ms", g_clock.realMillis() - mapTransitionStartedAt))
	end

	background:hide()

	if CharacterList and CharacterList.destroyLoadBox then
		CharacterList.destroyLoadBox()
	end

	if modules.client_topmenu and modules.client_topmenu.online then
		modules.client_topmenu.online()
	end

	if EnterGame and EnterGame.hidePanels then
		EnterGame.hidePanels(true)
	end
end

local function pollMapReady()
	mapReadyEvent = nil

	if not g_game.isOnline() then
		return
	end

	local gameInterface = modules.game_interface
	local mapPanel = gameInterface and gameInterface.getMapPanel and gameInterface.getMapPanel()

	if mapPanel and not mapPanel:isDestroyed() and mapPanel.isReadyToDisplay and mapPanel:isReadyToDisplay() then
		finishMapTransition(false)

		return
	end

	if g_clock.realMillis() - mapTransitionStartedAt >= MAP_READY_TIMEOUT_MS then
		finishMapTransition(true)

		return
	end

	mapReadyEvent = scheduleEvent(pollMapReady, MAP_READY_POLL_MS)
end

local function beginMapTransition()
	cancelMapReadyEvent()

	mapTransitionStartedAt = g_clock.realMillis()
	mapTransitionActive = true

	background:show()

	if modules.client_topmenu then
		modules.client_topmenu.offline()
		modules.client_topmenu.show()
	end

	if g_modules.getModule("client_bottommenu") and g_modules.getModule("client_bottommenu"):isLoaded() then
		modules.client_bottommenu.show()
	end

	mapReadyEvent = scheduleEvent(pollMapReady, 0)
end

function init()
	background = g_ui.displayUI("background")

	background:lower()

	if background.serverLogo then
		background.serverLogo:hide()
	end

	connect(g_game, {
		onGameStart = beginMapTransition
	})
	connect(g_game, {
		onGameEnd = show
	})

	if g_game.isOnline() then
		beginMapTransition()
	end
end

function terminate()
	cancelMapReadyEvent()

	mapTransitionActive = false

	disconnect(g_game, {
		onGameStart = beginMapTransition
	})
	disconnect(g_game, {
		onGameEnd = show
	})
	background:destroy()

	background = nil
end

function hide()
	cancelMapReadyEvent()

	mapTransitionActive = false

	background:hide()
end

function show()
	cancelMapReadyEvent()

	mapTransitionActive = false

	background:show()
end

function getBackground()
	return background
end

function isMapTransitionActive()
	return mapTransitionActive
end


-- Read-only diagnostics for the main world view; sends no game actions.
local worldDiagnosticEvents = {}

local function worldDescribe(value)
  if type(value) ~= 'table' then return tostring(value) end
  local values = {}
  for _, key in ipairs({'x', 'y', 'z', 'width', 'height', 'type', 'head', 'body', 'legs', 'feet'}) do
    if value[key] ~= nil then values[#values + 1] = key .. '=' .. tostring(value[key]) end
  end
  return '{' .. table.concat(values, ',') .. '}'
end

local function worldRead(object, method, ...)
  if not object then return 'missing', nil end
  local lookupOk, callback = pcall(function() return object[method] end)
  if not lookupOk or type(callback) ~= 'function' then return 'unavailable', nil end
  local ok, value = pcall(callback, object, ...)
  if not ok then return 'failed', nil end
  return worldDescribe(value), value
end

local function worldSingleton(object, method, ...)
  if not object or type(object[method]) ~= 'function' then return nil end
  local ok, value = pcall(object[method], ...)
  if ok then return value end
end

function dumpWorldViewDiagnostics(phase)
  local interface = modules and modules.game_interface
  local panel = worldSingleton(interface, 'getMapPanel')
  local player = worldSingleton(g_game, 'getLocalPlayer')
  local fields = {'phase=' .. tostring(phase or 'manual'), 'online=' .. tostring(worldSingleton(g_game, 'isOnline'))}
  for _, method in ipairs({'isVisible', 'isExplicitlyVisible', 'isEnabled', 'getOpacity', 'getRect', 'getMapRect', 'getVisibleDimension', 'getCameraPosition', 'getZoom', 'getShader', 'isReadyToDisplay'}) do
    local value = worldRead(panel, method)
    fields[#fields + 1] = 'map.' .. method .. '=' .. value
  end
  local positionText, position = worldRead(player, 'getPosition')
  fields[#fields + 1] = 'player.position=' .. positionText
  for _, method in ipairs({'getOutfit', 'isRemoved', 'isDead', 'isInvisible'}) do
    local value = worldRead(player, method)
    fields[#fields + 1] = 'player.' .. method .. '=' .. value
  end
  fields[#fields + 1] = 'map.center=' .. worldDescribe(worldSingleton(g_map, 'getCentralPosition'))
  local tile = position and worldSingleton(g_map, 'getTile', position)
  local count = worldRead(tile, 'getThingCount')
  fields[#fields + 1] = 'tile.things=' .. count
  local groundText, ground = worldRead(tile, 'getGround')
  fields[#fields + 1] = 'tile.ground=' .. (ground and worldRead(ground, 'getId') or groundText)
  local parent = panel
  for level = 0, 7 do
    if not parent then break end
    local id = worldRead(parent, 'getId')
    local visible = worldRead(parent, 'isVisible')
    local rect = worldRead(parent, 'getRect')
    local opacity = worldRead(parent, 'getOpacity')
    fields[#fields + 1] = 'ancestor' .. level .. '={id=' .. id .. ',visible=' .. visible .. ',rect=' .. rect .. ',opacity=' .. opacity .. '}'
    local _, nextParent = worldRead(parent, 'getParent')
    parent = nextParent
  end
  g_logger.info('[world-view] ' .. table.concat(fields, ' '))
end

local function cancelWorldDiagnostics()
  for _, event in ipairs(worldDiagnosticEvents) do removeEvent(event) end
  worldDiagnosticEvents = {}
end

local function queueWorldDiagnostics()
  cancelWorldDiagnostics()
  for _, elapsed in ipairs({0, 5000, 25000, 60000}) do
    local sampleTime = elapsed
    worldDiagnosticEvents[#worldDiagnosticEvents + 1] = scheduleEvent(function()
      if g_game.isOnline() then dumpWorldViewDiagnostics('login+' .. sampleTime .. 'ms') end
    end, elapsed)
  end
end

local backgroundInitBeforeDiagnostics = init
function init()
  backgroundInitBeforeDiagnostics()
  connect(g_game, {onGameStart = queueWorldDiagnostics, onGameEnd = cancelWorldDiagnostics})
  scheduleEvent(function() dumpWorldViewDiagnostics('initialization') end, 0)
end

local backgroundTerminateBeforeDiagnostics = terminate
function terminate()
  cancelWorldDiagnostics()
  disconnect(g_game, {onGameStart = queueWorldDiagnostics, onGameEnd = cancelWorldDiagnostics})
  backgroundTerminateBeforeDiagnostics()
end
