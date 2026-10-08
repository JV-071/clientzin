local smartWalkDirs = {}
local smartWalkDir
local walkEvent
local lastTurn = 0
local nextWalkDir
local lastWalkDir
local lastCancelWalkTime = 0
local pendingWalkEventDir
local DEFAULT_KEYBOARD_DELAY_MS = 250
local walkRepeatEvent
local walkRepeatRetryEvent
local walkRepeatActive = false
local continueWalk
local activeWalkKeys = {}
local walkKeyDirs = {}
local var_0_15 = {}
local var_0_16 = "Movement"
local var_0_17 = {
	{
		action = "Go East",
		defaultKey = "D",
		direction = East
	},
	{
		action = "Go North",
		defaultKey = "W",
		direction = North
	},
	{
		action = "Go North-East",
		defaultKey = "E",
		direction = NorthEast
	},
	{
		action = "Go North-West",
		defaultKey = "Q",
		direction = NorthWest
	},
	{
		action = "Go South",
		defaultKey = "S",
		direction = South
	},
	{
		action = "Go South-East",
		defaultKey = "C",
		direction = SouthEast
	},
	{
		action = "Go South-West",
		defaultKey = "Z",
		direction = SouthWest
	},
	{
		action = "Go West",
		defaultKey = "A",
		direction = West
	}
}

local function var_0_18()
	for unusedValue, entry in ipairs(var_0_17) do
		Keybind.new(var_0_16, entry.action, {
			[CHAT_MODE.ON] = "",
			[CHAT_MODE.OFF] = entry.defaultKey
		}, "", true)
	end
end

local function var_0_19()
	for unusedValue, entry in ipairs(var_0_17) do
		Keybind.delete(var_0_16, entry.action)
	end
end

local function getWalkOptionNumber(name)
	local var_3_0

	if modules.client_options and iscallable(modules.client_options.getOption) then
		var_3_0 = modules.client_options.getOption(name)
	else
		var_3_0 = g_settings.getNumber(name)
	end

	return tonumber(var_3_0) or 0
end

local function getKeyboardDelay()
	if modules.client_options and type(modules.client_options.getOption) == "function" then
		local delay = tonumber(modules.client_options.getOption("hotkeyDelay"))

		return math.max(delay or DEFAULT_KEYBOARD_DELAY_MS, 0)
	end

	if not g_settings:exists("useDefaultHotkeyDelay") or g_settings.getBoolean("useDefaultHotkeyDelay") then
		return DEFAULT_KEYBOARD_DELAY_MS
	end

	return math.max(tonumber(g_settings.getNumber("hotkeyDelay")) or DEFAULT_KEYBOARD_DELAY_MS, 0)
end

local function hasPhysicallyPressedWalkKey()
	local hasPressedKey = false

	for key in pairs(activeWalkKeys) do
		if g_keyboard.isKeyPressed(key) then
			hasPressedKey = true
		else
			activeWalkKeys[key] = nil
		end
	end

	return hasPressedKey
end

local function isWalkDirHeld(dir)
	for key in pairs(activeWalkKeys) do
		if walkKeyDirs[key] == dir and g_keyboard.isKeyPressed(key) then
			return true
		end
	end

	return false
end

local function canContinueHeldWalk()
	return smartWalkDir ~= nil and hasPhysicallyPressedWalkKey()
end

local function registerHeldWalkKeysForDir(dir)
	local found = false

	for key, keyDir in pairs(walkKeyDirs) do
		if keyDir == dir and g_keyboard.isKeyPressed(key) then
			activeWalkKeys[key] = true
			found = true
		end
	end

	return found
end

local function stopWalkRepeat()
	if walkRepeatEvent then
		removeEvent(walkRepeatEvent)

		walkRepeatEvent = nil
	end

	if walkRepeatRetryEvent then
		removeEvent(walkRepeatRetryEvent)

		walkRepeatRetryEvent = nil
	end

	walkRepeatActive = false
end

local function restartWalkRepeatDelay()
	stopWalkRepeat()

	walkRepeatEvent = scheduleEvent(function()
		walkRepeatEvent = nil

		if #smartWalkDirs == 0 or not canContinueHeldWalk() then
			return
		end

		walkRepeatActive = true

		continueWalk(0)
	end, getKeyboardDelay())
end

local DIAGONAL_MAP = {
	[North] = {
		[West] = NorthWest,
		[East] = NorthEast
	},
	[South] = {
		[West] = SouthWest,
		[East] = SouthEast
	},
	[West] = {
		[North] = NorthWest,
		[South] = SouthWest
	},
	[East] = {
		[North] = NorthEast,
		[South] = SouthEast
	}
}

local function updateSmartWalkDir()
	smartWalkDir = smartWalkDirs[1]

	if not smartWalkDir then
		return
	end

	if modules.client_options.getOption("smartWalk") and #smartWalkDirs > 1 then
		for _, d in ipairs(smartWalkDirs) do
			if DIAGONAL_MAP[smartWalkDir] and DIAGONAL_MAP[smartWalkDir][d] then
				smartWalkDir = DIAGONAL_MAP[smartWalkDir][d]

				break
			end
		end
	end
end

local function pruneStaleWalkDirs()
	local changed = false

	for i = #smartWalkDirs, 1, -1 do
		if not isWalkDirHeld(smartWalkDirs[i]) then
			table.remove(smartWalkDirs, i)

			changed = true
		end
	end

	if changed then
		updateSmartWalkDir()

		if #smartWalkDirs == 0 then
			stopWalkRepeat()
		end
	end

	return changed
end

local keys = {
	{
		"Up",
		North
	},
	{
		"Right",
		East
	},
	{
		"Down",
		South
	},
	{
		"Left",
		West
	},
	{
		"Num+Up",
		North
	},
	{
		"Num+PgUp",
		NorthEast
	},
	{
		"Num+Right",
		East
	},
	{
		"Num+PgDown",
		SouthEast
	},
	{
		"Num+Down",
		South
	},
	{
		"Num+End",
		SouthWest
	},
	{
		"Num+Left",
		West
	},
	{
		"Num+Home",
		NorthWest
	}
}
local currentTurnKeys = {}
local turnKeyHandlers = {}
local walkKeyHandlers = {}
local includeWasdTurnKeys = true
local TURN_ARROW_KEYS = {
	"Up",
	"Right",
	"Down",
	"Left"
}
local TURN_WASD_KEYS = {
	"W",
	"D",
	"S",
	"A"
}
local TURN_NUMPAD_KEYS = {
	"Num+Up",
	"Num+Right",
	"Num+Down",
	"Num+Left"
}
local TURN_BASE_DIRS = {
	North,
	East,
	South,
	West
}
local TURN_MOD_VARIANTS = {
	"Ctrl",
	"Shift",
	"Alt",
	"Ctrl+Shift",
	"Ctrl+Alt",
	"Alt+Shift",
	"Ctrl+Alt+Shift"
}
local TURN_CLEANUP_KEY_NAMES = {
	"Up",
	"Right",
	"Down",
	"Left",
	"W",
	"D",
	"S",
	"A",
	"Num+Up",
	"Num+Right",
	"Num+Down",
	"Num+Left"
}

local function optBool(v)
	if v == true then
		return true
	end

	if v == false or v == nil then
		return false
	end

	if type(v) == "number" then
		return v ~= 0
	end

	if type(v) == "string" then
		local l = v:lower():match("^%s*(.-)%s*$")

		return l == "true" or l == "1" or l == "yes"
	end

	return not not v
end

local function maskToRotateModPrefix(mask)
	local hasC = bit.band(mask, 1) ~= 0
	local hasS = bit.band(mask, 2) ~= 0
	local hasA = bit.band(mask, 4) ~= 0
	local parts = {}

	if hasC then
		table.insert(parts, "Ctrl")
	end

	if hasA and hasS then
		table.insert(parts, "Alt")
		table.insert(parts, "Shift")
	elseif hasA then
		table.insert(parts, "Alt")
	elseif hasS then
		table.insert(parts, "Shift")
	end

	return table.concat(parts, "+")
end

local function canonicalTurnCombo(mod, keyName)
	local raw = mod .. "+" .. keyName

	if type(retranslateKeyComboDesc) == "function" then
		local ok, out = pcall(retranslateKeyComboDesc, raw)

		if ok and out and out ~= "" then
			return out
		end
	end

	return raw
end

local function buildTurnKeys()
	if not modules.client_options or not modules.client_options.getOption then
		return {}
	end

	local c = optBool(modules.client_options.getOption("rotateHoldCtrl"))
	local s = optBool(modules.client_options.getOption("rotateHoldShift"))
	local a = optBool(modules.client_options.getOption("rotateHoldAlt"))

	if not c and not s and not a then
		return {}
	end

	local enabledMask = bit.bor(c and 1 or 0, s and 2 or 0, a and 4 or 0)
	local list = {}

	for mask = 1, 7 do
		if bit.band(mask, enabledMask) == mask then
			local modStr = maskToRotateModPrefix(mask)

			if modStr ~= "" then
				for i = 1, 4 do
					table.insert(list, {
						canonicalTurnCombo(modStr, TURN_ARROW_KEYS[i]),
						TURN_BASE_DIRS[i]
					})
				end

				for i = 1, 4 do
					table.insert(list, {
						canonicalTurnCombo(modStr, TURN_NUMPAD_KEYS[i]),
						TURN_BASE_DIRS[i]
					})
				end

				if includeWasdTurnKeys then
					for i = 1, 4 do
						table.insert(list, {
							canonicalTurnCombo(modStr, TURN_WASD_KEYS[i]),
							TURN_BASE_DIRS[i]
						})
					end
				end
			end
		end
	end

	return list
end

WalkController = Controller:new()

local function stopSmartWalk()
	smartWalkDirs = {}
	smartWalkDir = nil
	activeWalkKeys = {}

	stopWalkRepeat()
end

local function cancelWalkEvent()
	if walkEvent then
		removeEvent(walkEvent)

		walkEvent = nil
	end

	nextWalkDir = nil
end

local function abortSmartWalk()
	stopSmartWalk()
	cancelWalkEvent()
end

local function canChangeFloor(pos, deltaZ)
	if deltaZ == 0 then
		return false
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return false
	end

	local toPos = {
		x = pos.x,
		y = pos.y,
		z = pos.z + deltaZ
	}
	local toTile = g_map.getTile(toPos)

	if not toTile then
		return false
	end

	if deltaZ > 0 then
		return toTile:isWalkable() and (toTile:hasElevation(3) or toTile:hasFloorChange())
	end

	local fromTile = g_map.getTile(player:getPosition())

	return fromTile and fromTile:hasElevation(3) and toTile:isWalkable()
end

local function walk(dir)
	local player = g_game.getLocalPlayer()

	if not player or g_game.isDead() or player:isDead() then
		return
	end

	if player:isWalkLocked() then
		nextWalkDir = nil

		return
	end

	if g_game.isFollowing() then
		g_game.cancelFollow()
	end

	local isAutoWalking = player:isAutoWalking()

	if isAutoWalking or player:isServerWalking() then
		g_game.stop()

		if isAutoWalking then
			player:stopAutoWalk()
		end

		player:lockWalk(player:getStepDuration() + 50)

		return
	end

	if not player:canWalk() then
		if lastWalkDir ~= dir then
			nextWalkDir = dir
		end

		return
	end

	nextWalkDir = nil
	lastWalkDir = dir

	if modules.client_options and modules.client_options.getOption("alwaysTurnTowardsMovement") and player:getDirection() ~= dir then
		g_game.turn(dir)
	end

	if g_game.getFeature(GameAllowPreWalk) then
		local toPos = Position.translatedToDirection(player:getPosition(), dir)
		local toTile = g_map.getTile(toPos)

		if not toTile or not toTile:isWalkable() then
			if not canChangeFloor(toPos, 1) and not canChangeFloor(toPos, -1) then
				return false
			end
		else
			player:preWalk(dir)
		end
	end

	g_game.walk(dir)

	return true
end

function continueWalk(delay)
	if not walkRepeatActive or not smartWalkDir or walkRepeatRetryEvent then
		return
	end

	walkRepeatRetryEvent = scheduleEvent(function()
		walkRepeatRetryEvent = nil

		if not walkRepeatActive or not smartWalkDir then
			return
		end

		if not canContinueHeldWalk() then
			abortSmartWalk()

			return
		end

		pruneStaleWalkDirs()

		if not smartWalkDir then
			return
		end

		local player = g_game.getLocalPlayer()

		if not player or g_game.isDead() or player:isDead() then
			return
		end

		if player:isWalking() then
			return
		end

		if not walk(smartWalkDir) then
			continueWalk(10)
		end
	end, delay or 0)
end

local function addWalkEvent(dir, delay)
	if walkEvent and pendingWalkEventDir == dir and (delay == nil or delay <= 0) then
		return
	end

	cancelWalkEvent()

	lastCancelWalkTime = g_clock.millis()
	pendingWalkEventDir = dir

	local function action()
		walkEvent = nil
		pendingWalkEventDir = nil

		if canContinueHeldWalk() then
			walk(smartWalkDir or dir)
		end
	end

	walkEvent = delay ~= nil and delay > 0 and scheduleEvent(action, delay) or addEvent(action)
end

function smartWalk(dir)
	addWalkEvent(dir)
end

local function changeWalkDir(dir, pop)
	while table.removevalue(smartWalkDirs, dir) do
		-- block empty
	end

	if pop then
		if #smartWalkDirs == 0 then
			stopSmartWalk()

			return
		end
	else
		table.insert(smartWalkDirs, 1, dir)
	end

	updateSmartWalkDir()
end

local function turn(dir, repeated)
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	if player:isWalking() and player:getDirection() == dir then
		return
	end

	cancelWalkEvent()

	local TURN_DELAY_REPEATED = 150
	local TURN_DELAY_DEFAULT = 50
	local delay = repeated and TURN_DELAY_REPEATED or TURN_DELAY_DEFAULT

	if lastTurn + delay < g_clock.millis() then
		g_game.turn(dir)

		if registerHeldWalkKeysForDir(dir) then
			changeWalkDir(dir)
		end

		lastTurn = g_clock.millis()

		player:lockWalk(getWalkOptionNumber("walkTurnDelay"))
	end
end

local function bindKeys()
	for _, keyDir in ipairs(keys) do
		bindWalkKey(keyDir[1], keyDir[2])
	end

	currentTurnKeys = buildTurnKeys()

	for _, keyDir in ipairs(currentTurnKeys) do
		bindTurnKey(keyDir[1], keyDir[2])
	end
end

local function unbindKeys()
	for _, keyDir in ipairs(keys) do
		unbindWalkKey(keyDir[1])
	end

	for _, keyDir in ipairs(currentTurnKeys) do
		unbindTurnKey(keyDir[1])
	end

	currentTurnKeys = {}
end

local function onTeleport(player, newPos, oldPos)
	if not player or not newPos or not oldPos then
		return
	end

	local var_32_0 = Position.offsetX(newPos, oldPos)
	local offsetY = Position.offsetY(newPos, oldPos)
	local offsetZ = Position.offsetZ(newPos, oldPos)
	local TELEPORT_DELAY = getWalkOptionNumber("walkTeleportDelay")
	local STAIRS_DELAY = getWalkOptionNumber("walkStairsDelay")
	local delay = (var_32_0 >= 3 or offsetY >= 3 or offsetZ >= 2) and TELEPORT_DELAY or STAIRS_DELAY
	local numericValue

	numericValue = tonumber(delay) or 100

	player:lockWalk(numericValue)
end

local function onWalkFinish(player)
	if walkRepeatActive and smartWalkDir then
		continueWalk(0)

		return
	end

	if nextWalkDir and canContinueHeldWalk() then
		if not hasPhysicallyPressedWalkKey() then
			nextWalkDir = nil

			return
		end

		if not g_game.getFeature(GameAllowPreWalk) then
			walk(nextWalkDir)
		else
			addWalkEvent(nextWalkDir, 0)
		end
	end
end

local function onAutoWalk(player)
	return
end

local function onCancelWalk(player)
	player:lockWalk(50)
end

function WalkController.onInit(unusedArgument)
	var_0_18()
	bindKeys()
	rebindMovementKeys(Keybind.chatMode)
	scheduleEvent(function()
		rebindTurnKeys()
	end, 0)
end

function WalkController.onTerminate(unusedArgument)
	abortSmartWalk()
	unbindMovementKeys()
	unbindKeys()
	var_0_19()
end

function WalkController.onGameStart(self)
	self:registerEvents(g_game, {
		onGameStart = onGameStart,
		onTeleport = onTeleport,
		onAutoWalk = onAutoWalk
	})
	self:registerEvents(LocalPlayer, {
		onCancelWalk = onCancelWalk,
		onWalkFinish = onWalkFinish,
		onAutoWalk = onAutoWalk
	})

	modules.game_interface.getRootPanel().onFocusChange = function(unusedArgument, arg_40_1)
		if arg_40_1 then
			return
		end

		if hasPhysicallyPressedWalkKey() then
			return
		end

		abortSmartWalk()
	end

	modules.game_joystick.addOnJoystickMoveListener(function(dir)
		g_game.walk(dir)
	end)

	if not g_game.isOfficialTibia() then
		g_game.enableFeature(GameForceFirstAutoWalkStep)
	else
		g_game.disableFeature(GameForceFirstAutoWalkStep)
	end

	scheduleEvent(function()
		rebindTurnKeys()
	end, 0)
end

function WalkController.onGameEnd(unusedArgument)
	abortSmartWalk()
end

function bindWalkKey(key, dir)
	local gameRootPanel = modules.game_interface.getRootPanel()

	unbindWalkKey(key, activeWalkKeys[key] ~= nil)

	walkKeyDirs[key] = dir

	local handlers = {
		down = function()
			if g_keyboard.getModifiers() ~= KeyboardNoModifier then
				return false
			end

			pruneStaleWalkDirs()

			activeWalkKeys[key] = true

			changeWalkDir(dir)
			restartWalkRepeatDelay()
			walk(smartWalkDir or dir)
		end,
		up = function()
			if not activeWalkKeys[key] then
				if table.removevalue(smartWalkDirs, dir) then
					while table.removevalue(smartWalkDirs, dir) do
						-- block empty
					end

					updateSmartWalkDir()
				end

				return false
			end

			activeWalkKeys[key] = nil

			local previousDir = smartWalkDir

			changeWalkDir(dir, true)
			pruneStaleWalkDirs()

			if #smartWalkDirs == 0 then
				cancelWalkEvent()
				stopWalkRepeat()
			elseif smartWalkDir ~= previousDir then
				cancelWalkEvent()
				restartWalkRepeatDelay()
				walk(smartWalkDir)
			end
		end
	}

	walkKeyHandlers[key] = handlers

	g_keyboard.bindKeyDown(key, handlers.down, gameRootPanel, true)
	g_keyboard.bindKeyUp(key, handlers.up, gameRootPanel, true)
end

function bindTurnKey(key, dir)
	local gameRootPanel = modules.game_interface.getRootPanel()
	local handlers = {
		down = function()
			turn(dir, false)

			if modules.game_textmessage and modules.game_textmessage.isClearOldestHotkeyCombo(key) then
				modules.game_textmessage.clearOldestMessage()
			end

			return false
		end,
		press = function()
			turn(dir, true)

			return false
		end,
		up = function()
			local player = g_game.getLocalPlayer()

			if player then
				player:lockWalk(200)
			end

			return false
		end
	}

	turnKeyHandlers[key] = handlers

	g_keyboard.bindKeyDown(key, handlers.down, gameRootPanel)
	g_keyboard.bindKeyPress(key, handlers.press, gameRootPanel)
	g_keyboard.bindKeyUp(key, handlers.up, gameRootPanel)
end

function unbindWalkKey(key, arg_51_1)
	local gameRootPanel = modules.game_interface.getRootPanel()
	local handlers = walkKeyHandlers[key]

	if handlers then
		if activeWalkKeys[key] and not arg_51_1 then
			abortSmartWalk()
		end

		walkKeyDirs[key] = nil

		g_keyboard.unbindKeyDown(key, handlers.down, gameRootPanel)
		g_keyboard.unbindKeyUp(key, handlers.up, gameRootPanel)

		if handlers.press then
			g_keyboard.unbindKeyPress(key, handlers.press, gameRootPanel)
		end

		walkKeyHandlers[key] = nil
	end
end

function unbindTurnKey(key)
	local gameRootPanel = modules.game_interface.getRootPanel()
	local handlers = turnKeyHandlers[key]

	if handlers then
		g_keyboard.unbindKeyDown(key, handlers.down, gameRootPanel)
		g_keyboard.unbindKeyPress(key, handlers.press, gameRootPanel)
		g_keyboard.unbindKeyUp(key, handlers.up, gameRootPanel)

		turnKeyHandlers[key] = nil
	end
end

local function unbindTurnKeyDual(rawCombo)
	unbindTurnKey(rawCombo)

	if type(retranslateKeyComboDesc) == "function" then
		local ok, can = pcall(retranslateKeyComboDesc, rawCombo)

		if ok and can and can ~= "" and can ~= rawCombo then
			unbindTurnKey(can)
		end
	end
end

function rebindTurnKeys()
	local gameRootPanel = modules.game_interface.getRootPanel()

	if not gameRootPanel then
		return
	end

	for _, m in ipairs(TURN_MOD_VARIANTS) do
		for _, a in ipairs(TURN_CLEANUP_KEY_NAMES) do
			local raw = m .. "+" .. a

			unbindTurnKeyDual(raw)
			unbindTurnKeyDual(canonicalTurnCombo(m, a))
		end
	end

	currentTurnKeys = buildTurnKeys()

	for _, keyDir in ipairs(currentTurnKeys) do
		bindTurnKey(keyDir[1], keyDir[2])
	end

	if modules.game_textmessage and modules.game_textmessage.bindClearOldestHotkey then
		modules.game_textmessage.bindClearOldestHotkey(gameRootPanel)
	end
end

function syncWasdTurnKeyLayout(enabled)
	includeWasdTurnKeys = not not enabled

	rebindTurnKeys()
end

function getMovementKeyDirs(arg_56_0)
	arg_56_0 = arg_56_0 or Keybind.chatMode

	local var_56_0 = {}
	local var_56_1 = {}

	for unusedValue, entry in ipairs(var_0_17) do
		local keybindKeys = Keybind.getKeybindKeys(var_0_16, entry.action, arg_56_0)

		for unusedValue, iter_56_3 in ipairs({
			"primary",
			"secondary"
		}) do
			local var_56_3 = keybindKeys[iter_56_3]

			if var_56_3 and var_56_3 ~= "" and not var_56_1[var_56_3] then
				var_56_1[var_56_3] = true

				table.insert(var_56_0, {
					var_56_3,
					entry.direction,
					entry.action
				})
			end
		end
	end

	return var_56_0
end

function isMovementKeyBlockedByHotkey(arg_57_0, arg_57_1, arg_57_2)
	if not arg_57_0 or arg_57_0 == "" then
		return false
	end

	arg_57_2 = arg_57_2 or Keybind.chatMode

	if modules.game_actionbar and modules.game_actionbar.isKeyComboUsedOnActionBar and modules.game_actionbar.isKeyComboUsedOnActionBar(arg_57_0, arg_57_2 == CHAT_MODE.ON) then
		return true
	end

	if Keybind and Keybind.isKeyComboUsed and Keybind.isKeyComboUsed(arg_57_0, var_0_16, arg_57_1, arg_57_2) then
		return true
	end

	return false
end

local function var_0_61()
	local list = {}

	for key, dir in pairs(walkKeyDirs) do
		if g_keyboard.isKeyPressed(key) then
			list[key] = dir
		end
	end

	return list
end

local function var_0_62(arg_59_0)
	if not arg_59_0 then
		return
	end

	local var_59_0 = false

	for iter_59_0 in pairs(arg_59_0) do
		local var_59_1 = walkKeyDirs[iter_59_0]

		if var_59_1 and g_keyboard.isKeyPressed(iter_59_0) then
			activeWalkKeys[iter_59_0] = true

			local var_59_2 = false

			for unusedValue, smartWalkDir in ipairs(smartWalkDirs) do
				if smartWalkDir == var_59_1 then
					var_59_2 = true

					break
				end
			end

			if not var_59_2 then
				table.insert(smartWalkDirs, 1, var_59_1)
			end

			var_59_0 = true
		end
	end

	if not var_59_0 then
		return
	end

	updateSmartWalkDir()

	if smartWalkDir and not walkRepeatActive then
		walkRepeatActive = true

		continueWalk(0)
	end
end

function unbindMovementKeys(arg_60_0)
	for iter_60_0 in pairs(var_0_15) do
		unbindWalkKey(iter_60_0, arg_60_0)
	end

	var_0_15 = {}
end

function getDesiredMovementKeys(arg_61_0)
	arg_61_0 = arg_61_0 or Keybind.chatMode

	local var_61_0 = {}

	for unusedValue, entry in ipairs(getMovementKeyDirs(arg_61_0)) do
		local var_61_1 = entry[1]
		local var_61_2 = entry[3]

		if not isMovementKeyBlockedByHotkey(var_61_1, var_61_2, arg_61_0) then
			var_61_0[var_61_1] = true
		end
	end

	return var_61_0
end

function movementKeyBindsNeedSync(arg_62_0)
	arg_62_0 = arg_62_0 or Keybind.chatMode

	local var_62_0 = getDesiredMovementKeys(arg_62_0)

	for iter_62_0 in pairs(var_62_0) do
		if not var_0_15[iter_62_0] then
			return true
		end
	end

	for iter_62_1 in pairs(var_0_15) do
		if not var_62_0[iter_62_1] then
			return true
		end
	end

	return false
end

function rebindMovementKeys(arg_63_0)
	arg_63_0 = arg_63_0 or Keybind.chatMode

	local var_63_0 = var_0_61()

	unbindMovementKeys(true)

	for unusedValue, entry in ipairs(getMovementKeyDirs(arg_63_0)) do
		local var_63_1 = entry[1]
		local var_63_2 = entry[2]
		local var_63_3 = entry[3]

		if not isMovementKeyBlockedByHotkey(var_63_1, var_63_3, arg_63_0) then
			bindWalkKey(var_63_1, var_63_2)

			var_0_15[var_63_1] = true
		end
	end

	var_0_62(var_63_0)
end

if modules and modules.game_walk then
	modules.game_walk.cancelWalkInput = abortSmartWalk
	modules.game_walk.rebindTurnKeys = rebindTurnKeys
	modules.game_walk.bindTurnKey = bindTurnKey
	modules.game_walk.unbindTurnKey = unbindTurnKey
	modules.game_walk.syncWasdTurnKeyLayout = syncWasdTurnKeyLayout

	function modules.game_walk.getWasdMovementKeyDirs()
		return getMovementKeyDirs(CHAT_MODE.OFF)
	end

	modules.game_walk.getMovementKeyDirs = getMovementKeyDirs
	modules.game_walk.isMovementKeyBlockedByHotkey = isMovementKeyBlockedByHotkey
	modules.game_walk.rebindMovementKeys = rebindMovementKeys
	modules.game_walk.movementKeyBindsNeedSync = movementKeyBindsNeedSync
	modules.game_walk.getDesiredMovementKeys = getDesiredMovementKeys
	modules.game_walk.unbindMovementKeys = unbindMovementKeys
end
