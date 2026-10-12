HelperActionCoordinator = HelperActionCoordinator or {}

local MIN_ACTION_TIMEOUT_MS = 200
local MAX_ACTION_TIMEOUT_MS = 400
local DEFAULT_ACTION_TIMEOUT_MS = 250
local connectedPlayer
local pendingEquipmentAction
local manualHotkeyBlockedUntilMs = 0

local function getNowMs()
	return g_clock.millis()
end

local function getActionTimeoutMs()
	local ping = g_game.getPing and tonumber(g_game.getPing()) or 0

	if not ping or ping <= 0 then
		return DEFAULT_ACTION_TIMEOUT_MS
	end

	return math.max(MIN_ACTION_TIMEOUT_MS, math.min(MAX_ACTION_TIMEOUT_MS, ping + 100))
end

local function resolveEquipmentSlot(numericValue)
	numericValue = tonumber(numericValue)

	if not numericValue or numericValue <= 0 or not Item or not Item.create then
		return nil
	end

	local item = Item.create(numericValue)

	if not item or not item.getClothSlot then
		return nil
	end

	local clothSlot = tonumber(item:getClothSlot())

	return clothSlot and clothSlot > 0 and clothSlot or nil
end

local function resolveItemName(thingId)
	if not thingId or not g_things or not g_things.getThingType then
		return nil
	end

	local thingType = g_things.getThingType(thingId, ThingCategoryItem)

	if not thingType then
		return nil
	end

	local marketData = thingType.getMarketData and thingType:getMarketData() or nil

	if marketData and marketData.name and marketData.name ~= "" then
		return marketData.name
	end

	local name = thingType.getName and thingType:getName() or nil

	return name and name ~= "" and name or nil
end

local function matchesEquipmentItem(inventoryItem, expectedItemId)
	if not inventoryItem or not expectedItemId or not inventoryItem.getId then
		return false
	end

	local id = inventoryItem:getId()

	if id == expectedItemId then
		return true
	end

	local expectedItemName = resolveItemName(expectedItemId)

	return expectedItemName ~= nil and expectedItemName == resolveItemName(id)
end

local function expirePendingEquipmentAction()
	if pendingEquipmentAction and getNowMs() >= pendingEquipmentAction.expiresAt then
		pendingEquipmentAction = nil
	end
end

local function handleInventoryChange(unusedArgument, changedSlot, changedItem)
	if not pendingEquipmentAction then
		return
	end

	local inventorySlot = pendingEquipmentAction.inventorySlot

	if not inventorySlot then
		pendingEquipmentAction = nil

		return
	end

	if inventorySlot ~= changedSlot then
		return
	end

	if matchesEquipmentItem(changedItem, pendingEquipmentAction.itemId) == pendingEquipmentAction.shouldBeEquipped then
		pendingEquipmentAction = nil
	end
end

local function connectInventoryObserver(player)
	if connectedPlayer == player then
		return
	end

	if connectedPlayer then
		disconnect(connectedPlayer, {
			onInventoryChange = handleInventoryChange
		})
	end

	connectedPlayer = player

	if connectedPlayer then
		connect(connectedPlayer, {
			onInventoryChange = handleInventoryChange
		})
	end
end

function HelperActionCoordinator.beginManualEquipmentAction(itemId)
	if not g_game.isOnline() then
		return false
	end

	connectInventoryObserver(g_game.getLocalPlayer())

	local startedAtMs = getNowMs()
	local numericValue = tonumber(itemId)
	local equipmentSlot = resolveEquipmentSlot(numericValue)
	local localPlayer = g_game.getLocalPlayer()
	local inventoryItem = equipmentSlot and localPlayer and localPlayer.getInventoryItem and localPlayer:getInventoryItem(equipmentSlot) or nil
	local shouldBeEquipped

	if numericValue then
		shouldBeEquipped = not matchesEquipmentItem(inventoryItem, numericValue)
	end

	pendingEquipmentAction = {
		itemId = numericValue,
		inventorySlot = equipmentSlot,
		shouldBeEquipped = shouldBeEquipped,
		startedAt = startedAtMs,
		expiresAt = startedAtMs + getActionTimeoutMs()
	}

	return true
end

function HelperActionCoordinator.beginManualHotkeyAction()
	if not g_game.isOnline() then
		return false
	end

	manualHotkeyBlockedUntilMs = math.max(manualHotkeyBlockedUntilMs, getNowMs() + getActionTimeoutMs())

	return true
end

function HelperActionCoordinator.clearManualHotkeyAction()
	manualHotkeyBlockedUntilMs = 0
end

function HelperActionCoordinator.isAutomaticActionBlocked()
	expirePendingEquipmentAction()

	return pendingEquipmentAction ~= nil or getNowMs() < manualHotkeyBlockedUntilMs
end

function HelperActionCoordinator.reset()
	pendingEquipmentAction = nil
	manualHotkeyBlockedUntilMs = 0
end

function HelperActionCoordinator.init()
	HelperActionCoordinator.reset()
	connectInventoryObserver(g_game.getLocalPlayer())
end

function HelperActionCoordinator.onGameStart()
	HelperActionCoordinator.reset()
	connectInventoryObserver(g_game.getLocalPlayer())
end

function HelperActionCoordinator.onGameEnd()
	HelperActionCoordinator.reset()
end

function HelperActionCoordinator.terminate()
	HelperActionCoordinator.reset()
	connectInventoryObserver(nil)
end
