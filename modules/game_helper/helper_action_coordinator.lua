HelperActionCoordinator = HelperActionCoordinator or {}

local var_0_0 = 200
local var_0_1 = 400
local var_0_2 = 250
local var_0_3
local var_0_4
local var_0_5 = 0

local function var_0_6()
	return g_clock.millis()
end

local function var_0_7()
	local ping = g_game.getPing and tonumber(g_game.getPing()) or 0

	if not ping or ping <= 0 then
		return var_0_2
	end

	return math.max(var_0_0, math.min(var_0_1, ping + 100))
end

local function var_0_8(numericValue)
	numericValue = tonumber(numericValue)

	if not numericValue or numericValue <= 0 or not Item or not Item.create then
		return nil
	end

	local var_3_0 = Item.create(numericValue)

	if not var_3_0 or not var_3_0.getClothSlot then
		return nil
	end

	local clothSlot = tonumber(var_3_0:getClothSlot())

	return clothSlot and clothSlot > 0 and clothSlot or nil
end

local function var_0_9(thingId)
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

local function var_0_10(arg_5_0, arg_5_1)
	if not arg_5_0 or not arg_5_1 or not arg_5_0.getId then
		return false
	end

	local id = arg_5_0:getId()

	if id == arg_5_1 then
		return true
	end

	local var_5_1 = var_0_9(arg_5_1)

	return var_5_1 ~= nil and var_5_1 == var_0_9(id)
end

local function var_0_11()
	if var_0_4 and var_0_6() >= var_0_4.expiresAt then
		var_0_4 = nil
	end
end

local function handleInventoryChange(unusedArgument, arg_7_1, arg_7_2)
	if not var_0_4 then
		return
	end

	local inventorySlot = var_0_4.inventorySlot

	if not inventorySlot then
		var_0_4 = nil

		return
	end

	if inventorySlot ~= arg_7_1 then
		return
	end

	if var_0_10(arg_7_2, var_0_4.itemId) == var_0_4.shouldBeEquipped then
		var_0_4 = nil
	end
end

local function var_0_13(arg_8_0)
	if var_0_3 == arg_8_0 then
		return
	end

	if var_0_3 then
		disconnect(var_0_3, {
			onInventoryChange = handleInventoryChange
		})
	end

	var_0_3 = arg_8_0

	if var_0_3 then
		connect(var_0_3, {
			onInventoryChange = handleInventoryChange
		})
	end
end

function HelperActionCoordinator.beginManualEquipmentAction(arg_9_0)
	if not g_game.isOnline() then
		return false
	end

	var_0_13(g_game.getLocalPlayer())

	local var_9_0 = var_0_6()
	local numericValue = tonumber(arg_9_0)
	local var_9_2 = var_0_8(numericValue)
	local localPlayer = g_game.getLocalPlayer()
	local inventoryItem = var_9_2 and localPlayer and localPlayer.getInventoryItem and localPlayer:getInventoryItem(var_9_2) or nil
	local var_9_5

	if numericValue then
		var_9_5 = not var_0_10(inventoryItem, numericValue)
	end

	var_0_4 = {
		itemId = numericValue,
		inventorySlot = var_9_2,
		shouldBeEquipped = var_9_5,
		startedAt = var_9_0,
		expiresAt = var_9_0 + var_0_7()
	}

	return true
end

function HelperActionCoordinator.beginManualHotkeyAction()
	if not g_game.isOnline() then
		return false
	end

	var_0_5 = math.max(var_0_5, var_0_6() + var_0_7())

	return true
end

function HelperActionCoordinator.clearManualHotkeyAction()
	var_0_5 = 0
end

function HelperActionCoordinator.isAutomaticActionBlocked()
	var_0_11()

	return var_0_4 ~= nil or var_0_6() < var_0_5
end

function HelperActionCoordinator.reset()
	var_0_4 = nil
	var_0_5 = 0
end

function HelperActionCoordinator.init()
	HelperActionCoordinator.reset()
	var_0_13(g_game.getLocalPlayer())
end

function HelperActionCoordinator.onGameStart()
	HelperActionCoordinator.reset()
	var_0_13(g_game.getLocalPlayer())
end

function HelperActionCoordinator.onGameEnd()
	HelperActionCoordinator.reset()
end

function HelperActionCoordinator.terminate()
	HelperActionCoordinator.reset()
	var_0_13(nil)
end
