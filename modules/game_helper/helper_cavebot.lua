-- Root locals stored in a lexical table to fit the LuaJIT 200-local limit.
local cavebotState = {}
HelperCavebot = HelperCavebot or {}
HelperCavebot.startAtNearestWaypoint = false
HelperCavebot.pendingStartAtNearestWaypoint = false
HelperCavebot.diagonalWalk = false
HelperCavebot.pendingDiagonalWalk = false

 cavebotState[0] = nil
 cavebotState[1] = {}
 cavebotState[2] = nil
 cavebotState[3] = 1
 cavebotState[4] = nil
 cavebotState[5] = nil
 cavebotState[6] = nil
 cavebotState[7] = {}

HelperCavebot.externalMapPreview = nil
HelperCavebot.externalMapMarkers = {}

 cavebotState[8] = {}
 cavebotState[9] = false
 cavebotState[10] = false
 cavebotState[11] = 0
 cavebotState[12] = 0
 cavebotState[13] = 0
 cavebotState[14] = 0
 cavebotState[15] = false
 cavebotState[16] = false
 cavebotState[17] = 0
 cavebotState[18] = false
 cavebotState[19] = 10800
 cavebotState[20] = 4294967295
 cavebotState[21] = 0
 cavebotState[22] = 1
 cavebotState[23] = 2
 cavebotState[24] = 3
 cavebotState[25] = nil
 cavebotState[26] = nil
 cavebotState[27] = false
 cavebotState[28] = false
 cavebotState[29] = nil
 cavebotState[30] = 0
 cavebotState[31] = {
	handoff = false,
	walkChangedAt = 0,
	selectStart = true,
	crossHazards = false
}
 cavebotState[32] = {
	retryInterval = 750,
	usedAt = 0,
	lastAttemptAt = 0,
	connected = false,
	farUseWindow = 10000,
	recordedAt = 0,
	reachedAt = 0,
	recordWindow = 3000,
	giveUpDelay = 5000,
	toolIds = {
		[9596] = true,
		[9598] = true,
		[3003] = true,
		[9594] = true
	}
}

 cavebotState[32].resetRuntime = function()
	cavebotState[32].waypoint = nil
	cavebotState[32].lastAttemptAt = 0
	cavebotState[32].usedAt = 0
	cavebotState[32].usedFrom = nil
	cavebotState[32].reachedAt = 0
	cavebotState[32].blockedOnArrival = nil
end

 cavebotState[32].resetRecording = function()
	cavebotState[32].recordedWaypoint = nil
	cavebotState[32].recordedAt = 0
	cavebotState[32].pendingUse = nil
end

 cavebotState[33] = false
 cavebotState[34] = nil
 cavebotState[35] = false
 cavebotState[36] = nil
 cavebotState[37] = nil
 cavebotState[38] = {}
 cavebotState[39] = "Default"
 cavebotState[40] = false
 cavebotState[41] = nil
 cavebotState[42] = nil
 cavebotState[43] = nil
 cavebotState[44] = nil
 cavebotState[45] = nil
 cavebotState[46] = false
 cavebotState[47] = {
	stopAt = 5,
	walkSpeed = 20,
	mode = "disabled",
	resumeAt = 2
}
 cavebotState[48] = false
 cavebotState[49] = false
 cavebotState[50] = false
 cavebotState[51] = 0
 cavebotState[52] = 0
 cavebotState[53] = nil
 cavebotState[54] = nil
 cavebotState[55] = {
	timestamp = 0
}
 cavebotState[56] = {}
 cavebotState[57] = {
	pendingEnabled = true,
	enabled = true,
	scanInterval = 200,
	searchRadius = 8,
	lastScanAt = 0,
	clientAppearanceIds = {
		[54133] = true
	},
	disabledSeenKeys = {}
}
 cavebotState[58] = 200
 cavebotState[59] = 750
 cavebotState[60] = 1500
 cavebotState[61] = 1
 cavebotState[62] = 5
 cavebotState[63] = "Default"
 cavebotState[64] = 7
 cavebotState[65] = 7
 cavebotState[66] = 10
 cavebotState[67] = 250
 cavebotState[68] = 5
 cavebotState[69] = 2
 cavebotState[70] = 8
 cavebotState[71] = 3
 cavebotState[72] = 1
 cavebotState[73] = 20
 cavebotState[74] = 100 / cavebotState[73]
 cavebotState[75] = 250
 cavebotState[76] = 3000
 cavebotState[77] = cavebotState[73]
 cavebotState[78] = 4
 cavebotState[79] = 4
 cavebotState[80] = 16
 cavebotState[81] = cavebotState[79] + 32
 cavebotState[82] = cavebotState[81] + cavebotState[80]
 cavebotState[83] = {
	{
		y = -1,
		x = 0
	},
	{
		y = 0,
		x = 1
	},
	{
		y = 1,
		x = 0
	},
	{
		y = 0,
		x = -1
	},
	{
		y = -1,
		x = 1
	},
	{
		y = 1,
		x = 1
	},
	{
		y = 1,
		x = -1
	},
	{
		y = -1,
		x = -1
	}
}
 cavebotState[84] = "#ffda34"

  cavebotState[85] = function(widgetId)
	return cavebotState[0] and cavebotState[0].getWidget and cavebotState[0].getWidget(widgetId) or nil
end

  cavebotState[86] = function(englishText, portugueseText)
	if cavebotState[0] and cavebotState[0].getLanguage and cavebotState[0].getLanguage() == "pt" then
		return portugueseText
	end

	return englishText
end

  cavebotState[87] = function()
	if g_clock and g_clock.realMillis then
		return g_clock.realMillis()
	end

	if g_clock and g_clock.millis then
		return g_clock.millis()
	end

	return 0
end

  cavebotState[88] = function(positionValue)
	if positionValue == nil then
		return nil
	end

	local positionValueType = type(positionValue)

	if positionValueType ~= "table" and positionValueType ~= "userdata" then
		return nil
	end

	local numericValue = tonumber(positionValue.x)
	local positionY = tonumber(positionValue.y)
	local positionZ = tonumber(positionValue.z)

	if not numericValue or not positionY or not positionZ then
		return nil
	end

	return {
		x = math.floor(numericValue),
		y = math.floor(positionY),
		z = math.floor(positionZ)
	}
end

  cavebotState[89] = function(position)
	if not position then
		return ""
	end

	return tostring(position.x) .. "," .. tostring(position.y) .. "," .. tostring(position.z)
end

 cavebotState[90] = 7
 cavebotState[91] = 5
 cavebotState[92] = cavebotState[90] * 2 + 1
 cavebotState[93] = 1.001
 cavebotState[94] = {
	[0] = {
		y = -1,
		x = 0
	},
	{
		y = 0,
		x = 1
	},
	{
		y = 1,
		x = 0
	},
	{
		y = 0,
		x = -1
	},
	{
		y = -1,
		x = 1
	},
	{
		y = 1,
		x = 1
	},
	{
		y = 1,
		x = -1
	},
	{
		y = -1,
		x = -1
	}
}

  cavebotState[95] = function(offsetX, offsetY)
	return (offsetY + cavebotState[91]) * cavebotState[92] + (offsetX + cavebotState[90])
end

  cavebotState[96] = function(tilePosition, allowNonPathable)
	local tile = g_map.getTile(tilePosition)

	return tile ~= nil and tile:isWalkable(false) and not tile:hasCreatures() and not tile:hasFloorChange() and (allowNonPathable or tile:isPathable()) and not cavebotState[31].isBlockedPathPosition(tilePosition)
end

 cavebotState[31].diagonalDirections = function(startPosition, originalDirections)
	if not HelperCavebot.diagonalWalk or type(originalDirections) ~= "table" or originalDirections[2] == nil or not startPosition then
		return originalDirections
	end

	local allowNonPathable = cavebotState[31].allowsNonPathableWalk()
	local x = startPosition.x
	local y = startPosition.y
	local reachablePrefixLength = 0
	local destinationOffsetX = 0
	local destinationOffsetY = 0

	for index, entry in ipairs(originalDirections) do
		local directionOffset = cavebotState[94][entry]

		if not directionOffset then
			break
		end

		x, y = x + directionOffset.x, y + directionOffset.y

		if math.abs(x - startPosition.x) > cavebotState[90] or math.abs(y - startPosition.y) > cavebotState[91] or not cavebotState[96]({
			x = x,
			y = y,
			z = startPosition.z
		}, allowNonPathable) then
			break
		end

		reachablePrefixLength, destinationOffsetX, destinationOffsetY = index, x - startPosition.x, y - startPosition.y
	end

	if reachablePrefixLength < 2 then
		return originalDirections
	end

	local startNodeKey = cavebotState[95](0, 0)
	local destinationNodeKey = cavebotState[95](destinationOffsetX, destinationOffsetY)
	local distanceByNode = {
		[startNodeKey] = 0
	}
	local offsetByNode = {
		[startNodeKey] = {
			0,
			0
		}
	}
	local predecessorByNode = {}
	local incomingDirectionByNode = {}
	local closedNodes = {}
	local walkableByNode = {}
	local openNodes = {
		startNodeKey
	}

	while openNodes[1] ~= nil do
		local cheapestOpenIndex = 1

		for openNodeIndex = 2, #openNodes do
			if distanceByNode[openNodes[openNodeIndex]] < distanceByNode[openNodes[cheapestOpenIndex]] then
				cheapestOpenIndex = openNodeIndex
			end
		end

		local currentNodeKey = table.remove(openNodes, cheapestOpenIndex)

		if currentNodeKey == destinationNodeKey then
			break
		end

		closedNodes[currentNodeKey] = true

		local currentOffset = offsetByNode[currentNodeKey]

		for neighborDirection = 0, 7 do
			local neighborDirectionOffset = cavebotState[94][neighborDirection]
			local neighborOffsetX = currentOffset[1] + neighborDirectionOffset.x
			local neighborOffsetY = currentOffset[2] + neighborDirectionOffset.y
			local neighborNodeKey = cavebotState[95](neighborOffsetX, neighborOffsetY)

			if math.abs(neighborOffsetX) <= cavebotState[90] and math.abs(neighborOffsetY) <= cavebotState[91] and not closedNodes[neighborNodeKey] then
				if walkableByNode[neighborNodeKey] == nil then
					walkableByNode[neighborNodeKey] = cavebotState[96]({
						x = startPosition.x + neighborOffsetX,
						y = startPosition.y + neighborOffsetY,
						z = startPosition.z
					}, allowNonPathable)
				end

				local candidateDistance = distanceByNode[currentNodeKey] + (neighborDirection >= 4 and cavebotState[93] or 1)

				if walkableByNode[neighborNodeKey] and (distanceByNode[neighborNodeKey] == nil or candidateDistance < distanceByNode[neighborNodeKey]) then
					if distanceByNode[neighborNodeKey] == nil then
						openNodes[#openNodes + 1] = neighborNodeKey
						offsetByNode[neighborNodeKey] = {
							neighborOffsetX,
							neighborOffsetY
						}
					end

					distanceByNode[neighborNodeKey] = candidateDistance
					predecessorByNode[neighborNodeKey] = currentNodeKey
					incomingDirectionByNode[neighborNodeKey] = neighborDirection
				end
			end
		end
	end

	if predecessorByNode[destinationNodeKey] == nil then
		return originalDirections
	end

	local optimizedDirections = {}
	local backtrackNodeKey = destinationNodeKey

	while backtrackNodeKey ~= startNodeKey do
		table.insert(optimizedDirections, 1, incomingDirectionByNode[backtrackNodeKey])

		backtrackNodeKey = predecessorByNode[backtrackNodeKey]
	end

	if reachablePrefixLength <= #optimizedDirections then
		return originalDirections
	end

	for remainingDirectionIndex = reachablePrefixLength + 1, #originalDirections do
		optimizedDirections[#optimizedDirections + 1] = originalDirections[remainingDirectionIndex]
	end

	return optimizedDirections
end

 cavebotState[31].resetContinuousWalkProgress = function()
	cavebotState[31].walkDestinationKey = nil
	cavebotState[31].walkPositionKey = nil
	cavebotState[31].walkChangedAt = 0
end

 cavebotState[31].noteContinuousWalkProgress = function(currentPosition, destinationKey, observedAtMillis)
	cavebotState[31].walkDestinationKey = destinationKey
	cavebotState[31].walkPositionKey = cavebotState[89](currentPosition)
	cavebotState[31].walkChangedAt = observedAtMillis or cavebotState[87]()
end

 cavebotState[31].continuousWalkProgressGrace = function(player)
	local stepDuration = player and player.getStepDuration and tonumber(player:getStepDuration()) or 0
	local ping = g_game and g_game.getPing and tonumber(g_game.getPing()) or 0
	local stepAndNetworkGraceMillis = math.max(0, stepDuration, ping) + 100

	return math.max(1500, math.min(cavebotState[76], stepAndNetworkGraceMillis * 2))
end

 cavebotState[31].continuousWalkHasStalled = function(player, currentPosition, destinationKey, nowMillis)
	local currentPositionKey = cavebotState[89](currentPosition)

	if cavebotState[31].walkDestinationKey ~= destinationKey or cavebotState[31].walkPositionKey ~= currentPositionKey then
		cavebotState[31].noteContinuousWalkProgress(currentPosition, destinationKey, nowMillis)

		return false
	end

	if player.isWalking and player:isWalking() then
		return false
	end

	return cavebotState[31].walkChangedAt > 0 and nowMillis - cavebotState[31].walkChangedAt >= cavebotState[31].continuousWalkProgressGrace(player)
end

  cavebotState[97] = function()
	cavebotState[55].origin = nil
	cavebotState[55].timestamp = 0
	cavebotState[55].paths = nil
end

  cavebotState[98] = function()
	cavebotState[56].originKey = nil
	cavebotState[56].destinationKey = nil
	cavebotState[56].directions = nil
end

  cavebotState[99] = function(arg_17_0)
	if type(arg_17_0) ~= "table" then
		return nil
	end

	local var_17_0 = cavebotState[88](arg_17_0.position or arg_17_0.pos)

	if not var_17_0 then
		return nil
	end

	local textValue = tostring(arg_17_0.kind or arg_17_0.action or "position"):lower()

	if textValue == "walk" or textValue == "goto" then
		textValue = "position"
	end

	if arg_17_0.teleport == true or textValue == "teleport" then
		textValue = "teleport"
	elseif textValue == "stairs" or textValue == "stair" then
		textValue = "stairs"
	elseif textValue == "passage" then
		textValue = "transition"
	end

	if textValue ~= "transition" and textValue ~= "stairs" and textValue ~= "teleport" and textValue ~= "box" and textValue ~= "use" then
		textValue = "position"
	end

	local var_17_2 = {
		kind = textValue,
		position = var_17_0
	}

	if textValue == "use" then
		var_17_2.usePosition = cavebotState[88](arg_17_0.usePosition or arg_17_0.targetPosition or arg_17_0.targetPos)
		var_17_2.itemId = math.floor(tonumber(arg_17_0.itemId) or 0)

		local withItemId = math.floor(tonumber(arg_17_0.withItemId) or 0)

		if withItemId > 0 then
			var_17_2.withItemId = withItemId
		end

		if not var_17_2.usePosition or var_17_2.itemId <= 0 then
			var_17_2.kind = "position"
			var_17_2.usePosition = nil
			var_17_2.itemId = nil
			var_17_2.withItemId = nil
		elseif arg_17_0.transition == true then
			var_17_2.transition = true
		end
	end

	return var_17_2
end

  cavebotState[100] = function(arg_18_0)
	local var_18_0 = {}

	if type(arg_18_0) ~= "table" then
		return var_18_0
	end

	for unusedValue, entry in ipairs(arg_18_0) do
		local var_18_1 = cavebotState[99](entry)

		if var_18_1 then
			var_18_0[#var_18_0 + 1] = var_18_1
		end
	end

	return var_18_0
end

  cavebotState[101] = function(arg_19_0)
	return tostring(arg_19_0 or ""):match("^%s*(.-)%s*$") or ""
end

function HelperCavebot.getAutoRouteNameError(arg_20_0)
	if arg_20_0 == "" then
		return cavebotState[86]("Route name cannot be empty", "O nome da rota nao pode ficar vazio")
	end
end

  cavebotState[102] = function(arg_21_0)
	arg_21_0 = type(arg_21_0) == "table" and arg_21_0 or {}

	local textValue = tostring(arg_21_0.mode or "disabled"):lower()

	if textValue ~= "continuous" and textValue ~= "runstop" and textValue ~= "antilost" then
		textValue = "disabled"
	end

	local var_21_1 = math.max(1, math.min(20, math.floor(tonumber(arg_21_0.stopAt) or 5)))
	local var_21_2 = math.max(0, math.min(19, math.floor(tonumber(arg_21_0.resumeAt) or 2)))
	local var_21_3 = math.max(cavebotState[72], math.min(cavebotState[73], math.floor(tonumber(arg_21_0.walkSpeed) or cavebotState[77])))

	if var_21_1 <= var_21_2 then
		var_21_2 = math.max(0, var_21_1 - 1)
	end

	return {
		mode = textValue,
		stopAt = var_21_1,
		resumeAt = var_21_2,
		walkSpeed = var_21_3
	}
end

  cavebotState[103] = function(arg_22_0)
	arg_22_0 = type(arg_22_0) == "table" and arg_22_0 or {}

	if type(arg_22_0.waypoints) == "table" or type(arg_22_0.luring) == "table" then
		return {
			waypoints = cavebotState[100](arg_22_0.waypoints),
			luring = cavebotState[102](arg_22_0.luring)
		}
	end

	return {
		waypoints = cavebotState[100](arg_22_0),
		luring = cavebotState[102](nil)
	}
end

  cavebotState[104] = function(arg_23_0)
	local var_23_0 = {}

	if type(arg_23_0) ~= "table" then
		return var_23_0
	end

	for key, entry in pairs(arg_23_0) do
		key = cavebotState[101](key)

		if key ~= "" and type(entry) == "table" then
			var_23_0[key] = cavebotState[103](entry)
		end
	end

	return var_23_0
end

  cavebotState[105] = function()
	return {
		waypoints = cavebotState[100](cavebotState[1]),
		luring = cavebotState[102](cavebotState[47])
	}
end

function HelperCavebot.getAutoRouteDestination(arg_25_0)
	local var_25_0 = arg_25_0 == cavebotState[39] and cavebotState[105]() or cavebotState[38][arg_25_0]

	return {
		name = arg_25_0,
		waypoints = cavebotState[100](var_25_0 and var_25_0.waypoints),
		luring = cavebotState[102](var_25_0 and var_25_0.luring or cavebotState[47])
	}
end

  cavebotState[106] = function()
	local var_26_0 = {}

	for iter_26_0 in pairs(cavebotState[38]) do
		var_26_0[#var_26_0 + 1] = iter_26_0
	end

	table.sort(var_26_0, function(arg_27_0, arg_27_1)
		if arg_27_0 == arg_27_1 then
			return false
		end

		if arg_27_0 == cavebotState[63] then
			return true
		end

		if arg_27_1 == cavebotState[63] then
			return false
		end

		return arg_27_0:lower() < arg_27_1:lower()
	end)

	return var_26_0
end

  cavebotState[107] = function(arg_28_0)
	local var_28_0 = arg_28_0 and arg_28_0.position

	if not var_28_0 then
		return "-"
	end

	if arg_28_0.kind == "use" and arg_28_0.usePosition then
		local usePosition = arg_28_0.usePosition

		return string.format("%d, %d, %d > %d, %d, %d", var_28_0.x, var_28_0.y, var_28_0.z, usePosition.x, usePosition.y, usePosition.z)
	end

	return string.format("%d, %d, %d", var_28_0.x, var_28_0.y, var_28_0.z)
end

  cavebotState[108] = function(arg_29_0)
	return arg_29_0 == "position" or arg_29_0 == "box"
end

 cavebotState[31].isTransitionKind = function(arg_30_0)
	return arg_30_0 == "transition" or arg_30_0 == "stairs" or arg_30_0 == "teleport"
end

 cavebotState[31].allowsDestinationFloorChange = function(arg_31_0)
	return arg_31_0 ~= nil and (cavebotState[31].isTransitionKind(arg_31_0.kind) or arg_31_0.kind == "use")
end

 cavebotState[31].walkPathFlags = function(arg_32_0)
	local var_32_0 = arg_32_0 and cavebotState[82] or cavebotState[81]

	if cavebotState[31].crossHazards then
		return var_32_0
	end

	return var_32_0 - cavebotState[79]
end

 cavebotState[31].allowsNonPathableWalk = function()
	return cavebotState[31].crossHazards == true
end

 cavebotState[31].allowHazardCrossing = function()
	if cavebotState[31].crossHazards then
		return false
	end

	cavebotState[31].crossHazards = true

	cavebotState[98]()

	cavebotState[30] = 0
	cavebotState[52] = 0

	return true
end

function HelperCavebot.hasBoxWaypoint()
	for unusedValue, ptc_root_local in ipairs(cavebotState[1]) do
		if ptc_root_local and ptc_root_local.kind == "box" then
			return true
		end
	end

	return false
end

 cavebotState[31].blockedPathPositions = function()
	local var_36_0 = {}

	for unusedValue, ptc_root_local in ipairs(cavebotState[1]) do
		if cavebotState[31].isTransitionKind(ptc_root_local.kind) then
			var_36_0[#var_36_0 + 1] = cavebotState[88](ptc_root_local.position)
		end
	end

	if not cavebotState[57].enabled and cavebotState[57].visiblePositions and g_game and g_game.getLocalPlayer then
		local localPlayer = g_game.getLocalPlayer()
		local position = localPlayer and localPlayer:getPosition() or nil

		if position then
			for unusedValue, entry in ipairs(cavebotState[57].visiblePositions(position.z)) do
				var_36_0[#var_36_0 + 1] = entry
			end
		end
	end

	return var_36_0
end

 cavebotState[31].isBlockedPathPosition = function(arg_37_0)
	if not arg_37_0 then
		return false
	end

	for unusedValue, ptc_root_local in ipairs(cavebotState[1]) do
		if cavebotState[31].isTransitionKind(ptc_root_local.kind) and ptc_root_local.position and arg_37_0.x == ptc_root_local.position.x and arg_37_0.y == ptc_root_local.position.y and arg_37_0.z == ptc_root_local.position.z then
			return true
		end
	end

	return false
end

  cavebotState[109] = function(arg_38_0)
	if arg_38_0 == "box" then
		return cavebotState[86]("Box", "Box")
	end

	if arg_38_0 == "stairs" then
		return cavebotState[86]("Stairs", "Escada")
	end

	if arg_38_0 == "teleport" then
		return cavebotState[86]("Teleport", "Teleporte")
	end

	if arg_38_0 == "transition" then
		return cavebotState[86]("Passage", "Passagem")
	end

	if arg_38_0 == "use" then
		return "Use"
	end

	return "Pos"
end

  cavebotState[110] = function(arg_39_0)
	local var_39_0 = cavebotState[85]("cavebotStatusLabel")

	if var_39_0 and not var_39_0:isDestroyed() then
		arg_39_0 = arg_39_0 or ""

		if var_39_0:getText() ~= arg_39_0 then
			var_39_0:setText(arg_39_0)
			var_39_0:setTooltip(arg_39_0)
		end
	end
end

 cavebotState[57].refreshButton = function()
	local var_40_0 = cavebotState[85]("cavebotEchoRaidButton")

	if not var_40_0 or var_40_0:isDestroyed() then
		return
	end

	var_40_0.onClick = cavebotState[57].openWindow

	var_40_0:setOn(false)

	if cavebotState[57].enabled then
		var_40_0:setTooltip(cavebotState[86]("Echo Raid: step on nearby triggers. Click to configure.", "Echo Raid: pisar nos portais proximos. Clique para configurar."))
	else
		var_40_0:setTooltip(cavebotState[86]("Echo Raid: avoid triggers. Click to configure.", "Echo Raid: evitar os portais. Clique para configurar."))
	end
end

  cavebotState[111] = function()
	local var_41_0 = cavebotState[45]

	cavebotState[45] = nil

	if not var_41_0 or var_41_0:isDestroyed() then
		return
	end

	if g_modalManager and g_modalManager.isModal and g_modalManager.isModal(var_41_0) then
		g_modalManager.hide(var_41_0)
	end

	var_41_0:destroy()
end

  cavebotState[112] = function()
	return g_game and g_game.isCavebotAuthorized and g_game.isCavebotAuthorized()
end

  cavebotState[113] = function()
	return cavebotState[16] or cavebotState[11] == cavebotState[20]
end

  cavebotState[114] = function(arg_44_0)
	arg_44_0 = math.max(0, math.floor(tonumber(arg_44_0) or 0))

	if arg_44_0 > 0 and arg_44_0 < cavebotState[19] then
		cavebotState[13] = arg_44_0
		cavebotState[14] = cavebotState[87]()
	end
end

  cavebotState[115] = function(arg_45_0)
	if arg_45_0 < cavebotState[19] then
		return false
	end

	if cavebotState[13] <= 0 or cavebotState[13] >= cavebotState[19] then
		return false
	end

	if cavebotState[14] <= 0 then
		return false
	end

	local var_45_0 = cavebotState[19] - cavebotState[13]
	local var_45_1 = cavebotState[87]() - cavebotState[14]

	if var_45_1 < 0 then
		return true
	end

	return var_45_0 > math.floor(var_45_1 / 2000)
end

  cavebotState[116] = function(arg_46_0)
	if cavebotState[113]() then
		return cavebotState[20]
	end

	if cavebotState[11] <= 0 then
		return 0
	end

	if cavebotState[12] <= 0 then
		return math.min(cavebotState[19], cavebotState[11])
	end

	local var_46_0 = math.floor((cavebotState[87]() - cavebotState[12]) / 1000)

	if var_46_0 < 0 then
		var_46_0 = 0
	end

	if arg_46_0 then
		return math.max(0, cavebotState[11] - var_46_0)
	end

	return math.min(cavebotState[19], cavebotState[11])
end

  cavebotState[117] = function(arg_47_0)
	if cavebotState[113]() then
		cavebotState[12] = cavebotState[87]()

		return
	end

	cavebotState[11] = cavebotState[116](arg_47_0)
	cavebotState[12] = cavebotState[87]()

	cavebotState[114](cavebotState[11])
end

  cavebotState[118] = function()
	if cavebotState[113]() then
		return cavebotState[20]
	end

	local var_48_0 = cavebotState[116](cavebotState[18])

	cavebotState[114](var_48_0)

	return var_48_0
end

  cavebotState[119] = function()
	return cavebotState[113]() or cavebotState[118]() > 0
end

  cavebotState[120] = function()
	if not cavebotState[112]() or cavebotState[113]() then
		return false
	end

	local var_50_0 = cavebotState[118]()

	if var_50_0 >= cavebotState[19] then
		cavebotState[15] = false
	elseif var_50_0 <= cavebotState[19] - 60 then
		cavebotState[15] = true
	end

	return cavebotState[15]
end

  cavebotState[121] = function(arg_51_0, arg_51_1, arg_51_2, arg_51_3)
	local var_51_0 = math.max(0, tonumber(arg_51_0) or 0)

	if arg_51_1 ~= nil then
		cavebotState[16] = arg_51_1 == true or tonumber(arg_51_1) == 1
	end

	if arg_51_2 ~= nil then
		cavebotState[17] = math.max(0, math.floor(tonumber(arg_51_2) or 0))
	end

	if var_51_0 ~= cavebotState[20] and not arg_51_3 and cavebotState[115](var_51_0) then
		var_51_0 = cavebotState[13]
	elseif arg_51_3 then
		cavebotState[13] = 0
		cavebotState[14] = 0
	end

	cavebotState[11] = var_51_0
	cavebotState[12] = cavebotState[87]()

	cavebotState[114](cavebotState[11])
end

  cavebotState[122] = function(arg_52_0)
	if cavebotState[113]() then
		return cavebotState[86]("Unlimited", "Ilimitado")
	end

	arg_52_0 = math.max(0, math.floor(tonumber(arg_52_0) or 0))

	if arg_52_0 <= 0 then
		return cavebotState[86]("Expired", "Expirado")
	end

	local var_52_0 = math.floor(arg_52_0 / 3600)
	local var_52_1 = math.floor(arg_52_0 % 3600 / 60)

	if var_52_0 > 0 then
		return string.format("%dh %02dm", var_52_0, var_52_1)
	end

	return string.format("%dm", var_52_1)
end

  cavebotState[123] = function(arg_53_0, arg_53_1)
	if not arg_53_0 or arg_53_0.isDestroyed and arg_53_0:isDestroyed() then
		return
	end

	local goldValue = arg_53_0:getChildById("goldValue")

	if not goldValue then
		return
	end

	local var_53_1 = comma_value(math.floor(tonumber(arg_53_1) or 0))

	if not goldValue.getText or goldValue:getText() ~= var_53_1 then
		goldValue:setText(var_53_1)
	end
end

  cavebotState[124] = function()
	local var_54_0 = cavebotState[85]("cavebotTimeValueLabel")

	if not var_54_0 or var_54_0.isDestroyed and var_54_0:isDestroyed() then
		return
	end

	local var_54_1 = cavebotState[118]()
	local var_54_2 = cavebotState[122](var_54_1)

	if var_54_0.getText and var_54_0:getText() ~= var_54_2 then
		var_54_0:setText(var_54_2)
	elseif not var_54_0.getText then
		var_54_0:setText(var_54_2)
	end

	if var_54_0.setColor then
		var_54_0:setColor((cavebotState[113]() or var_54_1 > 0) and "#00ff00" or "#ff6464")
	end
end

  cavebotState[125] = function()
	local var_55_0 = cavebotState[113]()
	local var_55_1 = cavebotState[85]("cavebotTimeRow")
	local var_55_2 = cavebotState[85]("cavebotRenewRow")
	local var_55_3 = cavebotState[85]("cavebotAccessPanel")
	local var_55_4 = cavebotState[85]("cavebotAccessSeparator")

	if var_55_1 then
		var_55_1:setVisible(not var_55_0)
	end

	if var_55_2 then
		var_55_2:setVisible(not var_55_0)
	end

	if var_55_3 then
		var_55_3:setVisible(true)
	end

	if var_55_4 then
		var_55_4:setVisible(true)
	end

	cavebotState[57].refreshButton()

	if var_55_0 then
		return
	end

	cavebotState[124]()

	local var_55_5 = cavebotState[85]("cavebotRenewButton")

	if var_55_5 then
		var_55_5:setEnabled(cavebotState[120]())
	end

	cavebotState[123](cavebotState[85]("cavebotRenewPrice"), cavebotState[17])
end

  cavebotState[126] = function(arg_56_0)
	arg_56_0 = arg_56_0 == true

	if arg_56_0 and (not cavebotState[112]() or not cavebotState[119]()) then
		arg_56_0 = false
	end

	if cavebotState[18] == arg_56_0 then
		return arg_56_0
	end

	cavebotState[117](cavebotState[18])

	if g_game and g_game.sendCavebotSetActive then
		g_game.sendCavebotSetActive(arg_56_0)
	end

	cavebotState[18] = arg_56_0
	cavebotState[12] = cavebotState[87]()

	return arg_56_0
end

  cavebotState[127] = function()
	local var_57_0 = cavebotState[85]("enableCavebotCheckBox")
	local var_57_1 = cavebotState[18] or var_57_0 and var_57_0:isChecked()

	cavebotState[126](false)

	if var_57_0 and var_57_0:isChecked() then
		cavebotState[9] = true

		var_57_0:setChecked(false)

		cavebotState[9] = false
	end

	if not var_57_1 then
		return
	end

	cavebotState[25]()
	cavebotState[57].reset(false)
	cavebotState[26](true)
	cavebotState[110](cavebotState[86]("Cavebot time expired", "Tempo do cavebot expirado"))
end

  cavebotState[128] = function()
	if not cavebotState[112]() or not cavebotState[119]() then
		return false
	end

	local var_58_0 = cavebotState[85]("enableCavebotCheckBox")

	return var_58_0 and var_58_0:isChecked() or false
end

  cavebotState[129] = function()
	local var_59_0 = cavebotState[85]("checkbox")

	return var_59_0 and var_59_0:isChecked() or false
end

 cavebotState[25] = function()
	cavebotState[31].handoff = false

	cavebotState[98]()
	cavebotState[31].resetContinuousWalkProgress()

	if not cavebotState[28] then
		cavebotState[29] = nil

		return
	end

	cavebotState[28] = false
	cavebotState[29] = nil

	local localPlayer = g_game.getLocalPlayer()

	pcall(function()
		g_game.stop()

		if localPlayer and localPlayer.isAutoWalking and localPlayer:isAutoWalking() and localPlayer.stopAutoWalk then
			localPlayer:stopAutoWalk()
		end
	end)
end

 cavebotState[57].reset = function(arg_62_0)
	local var_62_0 = cavebotState[57].target ~= nil

	cavebotState[57].target = nil
	cavebotState[57].handledKey = nil
	cavebotState[57].lastScanAt = 0
	cavebotState[57].disabledSeenKeys = {}

	if arg_62_0 and var_62_0 then
		cavebotState[25]()

		cavebotState[30] = 0
		cavebotState[52] = 0
	end
end

  cavebotState[130] = function()
	if cavebotState[9] then
		return
	end

	if cavebotState[0] and cavebotState[0].isLoadingConfig and cavebotState[0].isLoadingConfig() then
		return
	end

	if cavebotState[38][cavebotState[39]] then
		cavebotState[38][cavebotState[39]] = cavebotState[105]()
	end

	if cavebotState[0] and cavebotState[0].requestAutoSave then
		cavebotState[0].requestAutoSave()
	elseif cavebotState[0] and cavebotState[0].saveConfig then
		cavebotState[0].saveConfig()
	end
end

  cavebotState[131] = function(arg_64_0)
	cavebotState[31].handoff = false
	cavebotState[31].crossHazards = false

	cavebotState[32].resetRuntime()

	if cavebotState[53] then
		removeEvent(cavebotState[53])

		cavebotState[53] = nil
	end

	cavebotState[48] = false
	cavebotState[49] = false
	cavebotState[50] = false
	cavebotState[51] = 0
	cavebotState[52] = 0
	cavebotState[54] = nil

	cavebotState[97]()
	cavebotState[98]()

	if arg_64_0 then
		cavebotState[25]()
	end
end

  cavebotState[132] = function(arg_65_0)
	local var_65_0 = math.max(cavebotState[72], math.min(cavebotState[73], math.floor(tonumber(arg_65_0) or cavebotState[77])))

	return math.floor(var_65_0 * cavebotState[74])
end

  cavebotState[133] = function(arg_66_0)
	return string.format("%d%%", cavebotState[132](arg_66_0))
end

  cavebotState[134] = function(arg_67_0, arg_67_1, arg_67_2, arg_67_3)
	if not arg_67_0 then
		return
	end

	local numberValue = arg_67_0:recursiveGetChildById("numberValue")
	local btnDec = arg_67_0:recursiveGetChildById("btnDec")
	local btnInc = arg_67_0:recursiveGetChildById("btnInc")

	if numberValue then
		numberValue:setText(tostring(arg_67_1))
	end

	if btnDec then
		btnDec:setEnabled(arg_67_2 < arg_67_1)
	end

	if btnInc then
		btnInc:setEnabled(arg_67_1 < arg_67_3)
	end
end

  cavebotState[135] = function()
	local var_68_0 = cavebotState[85]("cavebotLuringModeCombo")
	local var_68_1 = cavebotState[85]("cavebotLuringThresholdPanel")
	local var_68_2 = cavebotState[85]("cavebotLuringStopStepper")
	local var_68_3 = cavebotState[85]("cavebotLuringRunStepper")
	local var_68_4 = cavebotState[85]("cavebotLuringSpeedScrollBar")
	local var_68_5 = cavebotState[85]("cavebotLuringSpeedLabel")

	cavebotState[46] = true

	if var_68_0 then
		var_68_0:clearOptions()
		var_68_0:addOption(cavebotState[86]("Disabled", "Desativado"), "disabled")
		var_68_0:addOption(cavebotState[86]("Continuous", "Continuo"), "continuous")
		var_68_0:addOption(cavebotState[86]("Stop / Run", "Parar / Voltar"), "runstop")
		var_68_0:addOption("Anti-Lost", "antilost")

		if var_68_0.setCurrentOptionByData then
			var_68_0:setCurrentOptionByData(cavebotState[47].mode, true)
		else
			var_68_0:setCurrentOption(cavebotState[47].mode == "runstop" and cavebotState[86]("Stop / Run", "Parar / Voltar") or cavebotState[47].mode == "antilost" and "Anti-Lost" or cavebotState[47].mode == "continuous" and cavebotState[86]("Continuous", "Continuo") or cavebotState[86]("Disabled", "Desativado"), true)
		end
	end

	cavebotState[134](var_68_2, cavebotState[47].stopAt, 1, 20)
	cavebotState[134](var_68_3, cavebotState[47].resumeAt, 0, math.max(0, cavebotState[47].stopAt - 1))

	if var_68_1 then
		var_68_1:setEnabled(cavebotState[47].mode ~= "antilost" and cavebotState[47].mode ~= "continuous")
	end

	if var_68_5 then
		var_68_5:setText(string.format("%s: %s", cavebotState[86]("Speed", "Vel."), cavebotState[133](cavebotState[47].walkSpeed)))
	end

	if var_68_4 then
		var_68_4:setValue(cavebotState[47].walkSpeed)
	end

	cavebotState[46] = false
end

  cavebotState[136] = function(arg_69_0, arg_69_1)
	if cavebotState[46] or cavebotState[47].mode == "antilost" or cavebotState[47].mode == "continuous" then
		return
	end

	local var_69_0 = cavebotState[102](cavebotState[47])

	if arg_69_0 == "stop" then
		var_69_0.stopAt = math.max(1, math.min(20, math.floor(tonumber(arg_69_1) or var_69_0.stopAt)))

		if var_69_0.resumeAt >= var_69_0.stopAt then
			var_69_0.resumeAt = math.max(0, var_69_0.stopAt - 1)
		end
	else
		var_69_0.resumeAt = math.max(0, math.min(var_69_0.stopAt - 1, math.floor(tonumber(arg_69_1) or var_69_0.resumeAt)))
	end

	cavebotState[47] = cavebotState[102](var_69_0)

	cavebotState[131](true)
	cavebotState[135]()
	cavebotState[130]()
end

  cavebotState[137] = function(arg_70_0)
	if cavebotState[46] then
		return
	end

	local var_70_0 = cavebotState[102](cavebotState[47])

	var_70_0.walkSpeed = math.max(cavebotState[72], math.min(cavebotState[73], math.floor(tonumber(arg_70_0) or var_70_0.walkSpeed)))

	if var_70_0.walkSpeed == cavebotState[47].walkSpeed then
		return
	end

	cavebotState[47] = cavebotState[102](var_70_0)

	local var_70_1 = cavebotState[85]("cavebotLuringSpeedLabel")

	if var_70_1 then
		var_70_1:setText(string.format("%s: %s", cavebotState[86]("Speed", "Vel."), cavebotState[133](cavebotState[47].walkSpeed)))
	end

	if cavebotState[53] then
		removeEvent(cavebotState[53])
	end

	cavebotState[53] = scheduleEvent(function()
		cavebotState[53] = nil

		cavebotState[131](true)
		cavebotState[130]()
	end, cavebotState[75])
end

  cavebotState[138] = function()
	local var_72_0 = cavebotState[85]("cavebotLuringModeCombo")
	local var_72_1 = cavebotState[85]("cavebotLuringStopStepper")
	local var_72_2 = cavebotState[85]("cavebotLuringRunStepper")
	local var_72_3 = cavebotState[85]("cavebotLuringSpeedScrollBar")

	if var_72_0 then
		function var_72_0.onOptionChange(unusedArgument, arg_73_1, arg_73_2)
			if cavebotState[46] then
				return
			end

			cavebotState[47].mode = tostring(arg_73_2 or arg_73_1 or "disabled"):lower()
			cavebotState[47] = cavebotState[102](cavebotState[47])

			cavebotState[131](true)
			cavebotState[135]()
			cavebotState[130]()
		end
	end

	if var_72_1 then
		local btnDec = var_72_1:recursiveGetChildById("btnDec")
		local btnInc = var_72_1:recursiveGetChildById("btnInc")

		if btnDec then
			function btnDec.onClick()
				cavebotState[136]("stop", cavebotState[47].stopAt - 1)
			end
		end

		if btnInc then
			function btnInc.onClick()
				cavebotState[136]("stop", cavebotState[47].stopAt + 1)
			end
		end
	end

	if var_72_2 then
		local btnDec = var_72_2:recursiveGetChildById("btnDec")
		local btnInc = var_72_2:recursiveGetChildById("btnInc")

		if btnDec then
			function btnDec.onClick()
				cavebotState[136]("resume", cavebotState[47].resumeAt - 1)
			end
		end

		if btnInc then
			function btnInc.onClick()
				cavebotState[136]("resume", cavebotState[47].resumeAt + 1)
			end
		end
	end

	if var_72_3 then
		var_72_3:setRange(cavebotState[72], cavebotState[73])
		var_72_3:setStep(1)
		var_72_3:setMouseScroll(true)

		function var_72_3.onValueChange(unusedArgument, arg_78_1)
			cavebotState[137](arg_78_1)
		end
	end

	cavebotState[135]()
end

  cavebotState[139] = function(arg_79_0)
	arg_79_0 = cavebotState[101](arg_79_0)

	local var_79_0 = cavebotState[38][arg_79_0] ~= nil
	local var_79_1 = cavebotState[85]("cavebotPresetDeleteButton")

	if var_79_1 then
		var_79_1:setEnabled(var_79_0 and arg_79_0 ~= cavebotState[63])
	end
end

  cavebotState[140] = function()
	local var_80_0 = cavebotState[85]("cavebotPresetCombo")

	if var_80_0 and not var_80_0:isDestroyed() and var_80_0.getCurrentOption then
		local currentOption = var_80_0:getCurrentOption()

		if type(currentOption) == "table" then
			return cavebotState[101](currentOption.data or currentOption.text)
		end
	end

	return cavebotState[39]
end

  cavebotState[141] = function(arg_81_0)
	local var_81_0 = cavebotState[85]("cavebotPresetCombo")

	if not var_81_0 or var_81_0:isDestroyed() then
		return
	end

	if not cavebotState[38][cavebotState[63]] then
		cavebotState[38][cavebotState[63]] = cavebotState[105]()
	end

	if not cavebotState[38][cavebotState[39]] then
		cavebotState[39] = cavebotState[63]
	end

	local var_81_1 = cavebotState[101](arg_81_0)

	if var_81_1 == "" or not cavebotState[38][var_81_1] then
		var_81_1 = cavebotState[39]
	end

	local var_81_2 = cavebotState[106]()

	var_81_0.menuScroll = #var_81_2 > cavebotState[64]
	cavebotState[40] = true

	var_81_0:clearOptions()

	for unusedValue, entry in ipairs(var_81_2) do
		var_81_0:addOption(entry, entry)
	end

	if var_81_0.setCurrentOptionByData then
		var_81_0:setCurrentOptionByData(var_81_1, true)
	else
		var_81_0:setCurrentOption(var_81_1, true)
	end

	cavebotState[40] = false

	cavebotState[139](var_81_1)
end

  cavebotState[142] = function()
	local var_82_0 = cavebotState[85]("cavebotPresetCombo")

	if not var_82_0 or var_82_0:isDestroyed() then
		return
	end

	function var_82_0.onOptionChange(unusedArgument, arg_83_1, arg_83_2)
		if cavebotState[40] then
			return
		end

		local var_83_0 = cavebotState[101](arg_83_2 or arg_83_1)

		if var_83_0 ~= "" and cavebotState[38][var_83_0] then
			HelperCavebot.loadPreset(var_83_0)
		else
			cavebotState[141]()
		end
	end

	cavebotState[141]()
end

  cavebotState[143] = function()
	return cavebotState[1][cavebotState[3]]
end

  cavebotState[144] = function(arg_85_0, arg_85_1)
	if not arg_85_0 or not arg_85_1 or arg_85_0.z ~= arg_85_1.z then
		return math.huge
	end

	return math.max(math.abs(arg_85_0.x - arg_85_1.x), math.abs(arg_85_0.y - arg_85_1.y))
end

function HelperCavebot.hasReachedWaypoint(arg_86_0, arg_86_1)
	if not arg_86_1 or not cavebotState[108](arg_86_1.kind) then
		return false
	end

	return (arg_86_1.kind == "box" and 0 or cavebotState[61]) >= cavebotState[144](arg_86_0, arg_86_1.position)
end

  cavebotState[145] = function(arg_87_0, arg_87_1)
	if not arg_87_0 or not arg_87_1 then
		return math.huge
	end

	return math.max(math.abs(arg_87_0.x - arg_87_1.x), math.abs(arg_87_0.y - arg_87_1.y))
end

  cavebotState[146] = function(arg_88_0, arg_88_1)
	if not arg_88_0 or not arg_88_1 then
		return nil
	end

	if cavebotState[145](arg_88_0, arg_88_1) > cavebotState[61] then
		return "teleport"
	end

	if arg_88_1.z ~= arg_88_0.z then
		return "stairs"
	end

	return nil
end

  cavebotState[147] = function(arg_89_0, arg_89_1)
	return math.max(1024, math.min(20000, math.floor(cavebotState[145](arg_89_0, arg_89_1) * 256)))
end

  cavebotState[148] = function(tilePosition)
	if not tilePosition or not g_map or not g_map.getTile then
		return false
	end

	local tile = g_map.getTile(tilePosition)

	if not tile then
		return false
	end

	for unusedValue, entry in ipairs(tile:getCreatures() or {}) do
		if entry and entry.isMonster and entry:isMonster() and (not entry.isDead or not entry:isDead()) then
			return true
		end
	end

	return false
end

  cavebotState[149] = function(arg_91_0, arg_91_1)
	if not arg_91_0 or not arg_91_1 or not cavebotState[108](arg_91_1.kind) or not cavebotState[148](arg_91_1.position) then
		return arg_91_1 and arg_91_1.position or nil, false
	end

	local var_91_0
	local huge = math.huge
	local var_91_2 = cavebotState[147](arg_91_0, arg_91_1.position)

	for unusedValue, ptc_root_local in ipairs(cavebotState[83]) do
		local tilePosition = {
			x = arg_91_1.position.x + ptc_root_local.x,
			y = arg_91_1.position.y + ptc_root_local.y,
			z = arg_91_1.position.z
		}
		local tile = g_map.getTile(tilePosition)

		if tile and tile:isWalkable(false) and not tile:hasCreatures() then
			local var_91_5, var_91_6 = pcall(function()
				return g_map.findPathWithBlockedFloorChanges(arg_91_0, tilePosition, var_91_2, cavebotState[31].walkPathFlags(false), cavebotState[31].blockedPathPositions(), false)
			end)
			local var_91_7 = var_91_5 and type(var_91_6) == "table" and #var_91_6 or nil
			local var_91_8 = cavebotState[144](arg_91_0, tilePosition) == 0

			if var_91_7 and (var_91_7 > 0 or var_91_8) and var_91_7 < huge then
				var_91_0 = tilePosition
				huge = var_91_7
			end
		end
	end

	if var_91_0 then
		return var_91_0, true
	end

	return arg_91_1.position, false
end

  cavebotState[150] = function(arg_93_0)
	return arg_93_0 and "/modules/game_helper/images/cavebot-waypoint-active" or "/modules/game_helper/images/cavebot-waypoint"
end

  cavebotState[151] = function(arg_94_0, arg_94_1)
	return string.format("#%d %s - %s\n%s", arg_94_0, cavebotState[109](arg_94_1.kind), cavebotState[107](arg_94_1), cavebotState[86]("Drag to move. Right-click for options.", "Arraste para mover. Clique com o botao direito para ver opcoes."))
end

  cavebotState[152] = function(arg_95_0)
	local cross = arg_95_0.cross
	local cavebotMinimapControls = arg_95_0:getChildById("cavebotMinimapControls")
	local cavebotAutoRouteButton = arg_95_0:getChildById("cavebotAutoRouteButton")
	local cavebotRosePanel = arg_95_0:getChildById("cavebotRosePanel")

	if cross and not cross:isDestroyed() then
		cross:raise()
	end

	if cavebotMinimapControls then
		cavebotMinimapControls:raise()
	end

	if cavebotAutoRouteButton and not cavebotAutoRouteButton:isDestroyed() then
		cavebotAutoRouteButton:raise()
	end

	if cavebotRosePanel then
		cavebotRosePanel:raise()
	end
end

  cavebotState[153] = function(arg_96_0, arg_96_1)
	if not arg_96_0 or arg_96_0:isDestroyed() or not arg_96_1 or not arg_96_0:containsPaddingPoint(arg_96_1) then
		return nil
	end

	return cavebotState[88](arg_96_0:getTilePosition(arg_96_1))
end

function HelperCavebot.refreshMapMarkerPosition(arg_97_0, arg_97_1, arg_97_2)
	if not arg_97_0 or arg_97_0:isDestroyed() then
		return
	end

	arg_97_0:setTooltip(cavebotState[151](arg_97_1, arg_97_2))

	local parent = arg_97_0:getParent()

	if parent and not parent:isDestroyed() then
		parent:centerInPosition(arg_97_0, arg_97_2.position)
		arg_97_0:raise()
		cavebotState[152](parent)
	end
end

  cavebotState[154] = function(arg_98_0)
	local var_98_0 = cavebotState[1][arg_98_0]

	if not var_98_0 then
		return
	end

	local var_98_1 = cavebotState[8][arg_98_0]

	if var_98_1 and not var_98_1:isDestroyed() then
		local waypointPosition = var_98_1:getChildById("waypointPosition")

		if waypointPosition then
			waypointPosition:setText(cavebotState[107](var_98_0))
		end
	end

	HelperCavebot.refreshMapMarkerPosition(cavebotState[7][arg_98_0], arg_98_0, var_98_0)
	HelperCavebot.refreshMapMarkerPosition(HelperCavebot.externalMapMarkers[arg_98_0], arg_98_0, var_98_0)
end

  cavebotState[155] = function(arg_99_0, arg_99_1, arg_99_2)
	local var_99_0 = cavebotState[1][arg_99_0]
	local newWaypointPosition = cavebotState[88](arg_99_1)

	if not var_99_0 or not newWaypointPosition then
		return false
	end

	local position = var_99_0.position

	if position.x == newWaypointPosition.x and position.y == newWaypointPosition.y and position.z == newWaypointPosition.z then
		cavebotState[154](arg_99_0, arg_99_2)

		return false
	end

	if cavebotState[128]() and arg_99_0 == cavebotState[3] then
		cavebotState[131](true)

		cavebotState[30] = 0
		cavebotState[31].reachedAt = nil
	end

	if var_99_0.kind == "use" and var_99_0.usePosition then
		var_99_0.usePosition = {
			x = var_99_0.usePosition.x + newWaypointPosition.x - position.x,
			y = var_99_0.usePosition.y + newWaypointPosition.y - position.y,
			z = var_99_0.usePosition.z + newWaypointPosition.z - position.z
		}
	end

	var_99_0.position = newWaypointPosition

	cavebotState[154](arg_99_0, arg_99_2)
	HelperCavebot.selectWaypoint(arg_99_0, false)
	cavebotState[110](string.format("%s #%d - %s", cavebotState[86]("Waypoint moved", "Waypoint movido"), arg_99_0, cavebotState[107](var_99_0)))
	cavebotState[130]()

	return true
end

  cavebotState[156] = function(parentWidget, waypointIndex, arg_100_2, arg_100_3)
	local var_100_0 = cavebotState[128]() and waypointIndex == cavebotState[3]
	local cavebotMapWaypointMarkerWidget = g_ui.createWidget("CavebotMapWaypointMarker", parentWidget)

	cavebotMapWaypointMarkerWidget:setImageSource(cavebotState[150](var_100_0))

	if arg_100_2.kind == "box" then
		cavebotMapWaypointMarkerWidget:setImageColor(cavebotState[84])
	end

	cavebotMapWaypointMarkerWidget:setTooltip(cavebotState[151](waypointIndex, arg_100_2))

	cavebotMapWaypointMarkerWidget.waypointIndex = waypointIndex

	cavebotMapWaypointMarkerWidget:setDraggable(true)

	function cavebotMapWaypointMarkerWidget.onDragEnter(arg_101_0)
		local waypointIndex = arg_101_0.waypointIndex
		local var_101_1 = cavebotState[1][waypointIndex]

		if not var_101_1 then
			return false
		end

		arg_101_0.cavebotDragOriginalPosition = cavebotState[88](var_101_1.position)

		arg_101_0:setOpacity(0.65)
		HelperCavebot.selectWaypoint(waypointIndex, false)

		return true
	end

	function cavebotMapWaypointMarkerWidget.onDragMove(arg_102_0, arg_102_1)
		local parent = arg_102_0:getParent()
		local var_102_1 = cavebotState[153](parent, arg_102_1)

		if var_102_1 then
			parent:centerInPosition(arg_102_0, var_102_1)
			arg_102_0:raise()
			cavebotState[152](parent)
		end

		return true
	end

	function cavebotMapWaypointMarkerWidget.onDragLeave(arg_103_0, unusedArgument, arg_103_2)
		local parent = arg_103_0:getParent()
		local var_103_1 = cavebotState[153](parent, arg_103_2)

		arg_103_0:setOpacity(1)

		if var_103_1 then
			cavebotState[155](arg_103_0.waypointIndex, var_103_1, parent)
		elseif arg_103_0.cavebotDragOriginalPosition and parent and not parent:isDestroyed() then
			parent:centerInPosition(arg_103_0, arg_103_0.cavebotDragOriginalPosition)
			arg_103_0:raise()
			cavebotState[152](parent)
		end

		arg_103_0.cavebotDragOriginalPosition = nil

		return true
	end

	function cavebotMapWaypointMarkerWidget.onMouseRelease(arg_104_0, arg_104_1, arg_104_2)
		local waypointIndex = arg_104_0.waypointIndex

		if arg_104_2 == MouseLeftButton then
			HelperCavebot.selectWaypoint(waypointIndex, false)

			return true
		end

		if arg_104_2 == MouseRightButton then
			local popupMenuWidget = g_ui.createWidget("PopupMenu")

			popupMenuWidget:setGameMenu(true)
			popupMenuWidget:addOption(cavebotState[86]("Remove Waypoint", "Remover waypoint"), function()
				cavebotState[2] = waypointIndex

				HelperCavebot.removeSelectedWaypoint()
			end)
			popupMenuWidget:display(arg_104_1)

			return true
		end

		return false
	end

	arg_100_3 = arg_100_3 or cavebotState[7]
	arg_100_3[waypointIndex] = cavebotMapWaypointMarkerWidget

	parentWidget:centerInPosition(cavebotMapWaypointMarkerWidget, arg_100_2.position)
	cavebotMapWaypointMarkerWidget:raise()

	return cavebotMapWaypointMarkerWidget
end

function HelperCavebot.destroyMarkerCollection(arg_106_0)
	for unusedValue, entry in ipairs(arg_106_0) do
		if entry and not entry:isDestroyed() then
			entry:destroy()
		end
	end

	return {}
end

  cavebotState[157] = function()
	cavebotState[7] = HelperCavebot.destroyMarkerCollection(cavebotState[7])
	HelperCavebot.externalMapMarkers = HelperCavebot.destroyMarkerCollection(HelperCavebot.externalMapMarkers)
end

function HelperCavebot.refreshExternalMapMarkers()
	HelperCavebot.externalMapMarkers = HelperCavebot.destroyMarkerCollection(HelperCavebot.externalMapMarkers)

	local externalMapPreview = HelperCavebot.externalMapPreview

	if not externalMapPreview or externalMapPreview:isDestroyed() then
		HelperCavebot.externalMapPreview = nil

		return
	end

	for index, ptc_root_local in ipairs(cavebotState[1]) do
		cavebotState[156](externalMapPreview, index, ptc_root_local, HelperCavebot.externalMapMarkers)
	end

	cavebotState[152](externalMapPreview)
end

  cavebotState[158] = function()
	cavebotState[157]()

	local var_109_0 = cavebotState[85]("cavebotMapPreview")

	if var_109_0 and not var_109_0:isDestroyed() then
		for index, ptc_root_local in ipairs(cavebotState[1]) do
			cavebotState[156](var_109_0, index, ptc_root_local, cavebotState[7])
		end

		cavebotState[152](var_109_0)
	end

	HelperCavebot.refreshExternalMapMarkers()
end

  cavebotState[159] = function()
	local var_110_0 = cavebotState[2] ~= nil and cavebotState[1][cavebotState[2]] ~= nil
	local var_110_1 = cavebotState[85]("cavebotRemoveButton")
	local var_110_2 = cavebotState[85]("cavebotClearButton")

	if var_110_1 then
		var_110_1:setEnabled(var_110_0)
	end

	if var_110_2 then
		var_110_2:setEnabled(#cavebotState[1] > 0)
	end
end

  cavebotState[160] = function()
	if not cavebotState[1][cavebotState[3]] then
		return false
	end

	local var_111_0 = cavebotState[2] ~= cavebotState[3]

	cavebotState[2] = cavebotState[3]

	return var_111_0
end

  cavebotState[161] = function()
	local var_112_0 = cavebotState[85]("cavebotRecordButton")

	if not var_112_0 then
		return
	end

	var_112_0:setOn(cavebotState[33])
	var_112_0:setText(cavebotState[86](cavebotState[33] and "Stop" or "Record", cavebotState[33] and "Parar" or "Gravar"))
	var_112_0:setTooltip(cavebotState[86](cavebotState[33] and "Stop recording waypoints and object uses." or "Start recording waypoints while you walk and use doors, ladders and holes.", cavebotState[33] and "Para de gravar waypoints e uses de objetos." or "Inicia a gravacao enquanto voce caminha e usa portas, escadas e buracos."))
end

  cavebotState[162] = function(parentWidget, waypointIndex, arg_113_2)
	local cavebotWaypointRowWidget = g_ui.createWidget("CavebotWaypointRow", parentWidget)

	cavebotWaypointRowWidget.waypointIndex = waypointIndex
	cavebotState[8][waypointIndex] = cavebotWaypointRowWidget
	cavebotWaypointRowWidget.zebraColor = waypointIndex % 2 == 0 and "#414141" or "#484848"

	cavebotWaypointRowWidget:setBackgroundColor(waypointIndex == cavebotState[2] and "#585858" or cavebotWaypointRowWidget.zebraColor)

	local waypointTitle = cavebotWaypointRowWidget:getChildById("waypointTitle")
	local waypointPosition = cavebotWaypointRowWidget:getChildById("waypointPosition")
	local waypointTypeIcon = cavebotWaypointRowWidget:getChildById("waypointTypeIcon")
	local var_113_4 = cavebotState[128]() and waypointIndex == cavebotState[3]

	if waypointTitle then
		waypointTitle:setText(string.format("%d. %s", waypointIndex, cavebotState[109](arg_113_2.kind)))
	end

	if waypointPosition then
		waypointPosition:setText(cavebotState[107](arg_113_2))
	end

	if waypointTypeIcon then
		waypointTypeIcon:setImageSource(cavebotState[150](var_113_4))

		if arg_113_2.kind == "box" then
			waypointTypeIcon:setImageColor(cavebotState[84])
		end
	end

	function cavebotWaypointRowWidget.onMouseRelease(arg_114_0, unusedArgument, arg_114_2)
		if arg_114_2 == MouseLeftButton then
			HelperCavebot.selectWaypoint(arg_114_0.waypointIndex, true)

			return true
		end

		return false
	end

	return cavebotWaypointRowWidget
end

  cavebotState[163] = function()
	local var_115_0 = cavebotState[85]("cavebotWaypointsList")

	if not var_115_0 or var_115_0:isDestroyed() then
		cavebotState[8] = {}

		return
	end

	var_115_0:destroyChildren()

	cavebotState[8] = {}

	local var_115_1

	for index, ptc_root_local in ipairs(cavebotState[1]) do
		local var_115_2 = cavebotState[162](var_115_0, index, ptc_root_local)

		if index == cavebotState[2] then
			var_115_1 = var_115_2
		end
	end

	if var_115_1 and var_115_0.ensureChildVisible then
		addEvent(function()
			if var_115_0:isDestroyed() or var_115_1:isDestroyed() then
				return
			end

			var_115_0:ensureChildVisible(var_115_1)
		end)
	end
end

  cavebotState[164] = function(arg_117_0)
	local var_117_0 = cavebotState[1][arg_117_0]

	if not var_117_0 then
		return
	end

	local var_117_1 = cavebotState[85]("cavebotWaypointsList")

	if var_117_1 and not var_117_1:isDestroyed() then
		local var_117_2 = cavebotState[162](var_117_1, arg_117_0, var_117_0)

		if var_117_1.ensureChildVisible then
			addEvent(function()
				if not var_117_1:isDestroyed() and not var_117_2:isDestroyed() then
					var_117_1:ensureChildVisible(var_117_2)
				end
			end)
		end
	end

	local var_117_3 = cavebotState[85]("cavebotMapPreview")

	if var_117_3 and not var_117_3:isDestroyed() then
		cavebotState[156](var_117_3, arg_117_0, var_117_0, cavebotState[7])
		cavebotState[152](var_117_3)
	end

	local externalMapPreview = HelperCavebot.externalMapPreview

	if externalMapPreview and not externalMapPreview:isDestroyed() then
		cavebotState[156](externalMapPreview, arg_117_0, var_117_0, HelperCavebot.externalMapMarkers)
		cavebotState[152](externalMapPreview)
	end
end

  cavebotState[165] = function(arg_119_0, arg_119_1)
	local var_119_0 = cavebotState[128]()
	local var_119_1 = cavebotState[85]("cavebotWaypointsList")
	local var_119_2 = {}

	local function var_119_3(arg_120_0)
		if not arg_120_0 or var_119_2[arg_120_0] then
			return
		end

		var_119_2[arg_120_0] = true

		local var_120_0 = cavebotState[1][arg_120_0]

		if not var_120_0 then
			return
		end

		local var_120_1 = cavebotState[8][arg_120_0]

		if var_120_1 and not var_120_1:isDestroyed() then
			var_120_1:setBackgroundColor(arg_120_0 == cavebotState[2] and "#585858" or var_120_1.zebraColor or "#484848")

			local waypointTypeIcon = var_120_1:getChildById("waypointTypeIcon")

			if waypointTypeIcon then
				waypointTypeIcon:setImageSource(cavebotState[150](var_119_0 and arg_120_0 == cavebotState[3]))
				waypointTypeIcon:setImageColor(var_120_0.kind == "box" and cavebotState[84] or "#ffffff")
			end
		end

		local function var_120_3(arg_121_0)
			if not arg_121_0 or arg_121_0:isDestroyed() then
				return
			end

			arg_121_0:setImageSource(cavebotState[150](var_119_0 and arg_120_0 == cavebotState[3]))
			arg_121_0:setImageColor(var_120_0.kind == "box" and cavebotState[84] or "#ffffff")
		end

		var_120_3(cavebotState[7][arg_120_0])
		var_120_3(HelperCavebot.externalMapMarkers[arg_120_0])
	end

	var_119_3(arg_119_0)
	var_119_3(arg_119_1)
	var_119_3(cavebotState[2])
	var_119_3(cavebotState[3])

	local var_119_4 = cavebotState[8][cavebotState[2]]

	if var_119_1 and not var_119_1:isDestroyed() and var_119_4 and not var_119_4:isDestroyed() and var_119_1.ensureChildVisible then
		var_119_1:ensureChildVisible(var_119_4)
	end
end

  cavebotState[166] = function(arg_122_0)
	local var_122_0

	if arg_122_0 <= #cavebotState[8] then
		var_122_0 = table.remove(cavebotState[8], arg_122_0)
	else
		var_122_0 = cavebotState[8][arg_122_0]
		cavebotState[8][arg_122_0] = nil
	end

	if var_122_0 and not var_122_0:isDestroyed() then
		var_122_0:destroy()
	end

	local var_122_1

	if arg_122_0 <= #cavebotState[7] then
		var_122_1 = table.remove(cavebotState[7], arg_122_0)
	else
		var_122_1 = cavebotState[7][arg_122_0]
		cavebotState[7][arg_122_0] = nil
	end

	if var_122_1 and not var_122_1:isDestroyed() then
		var_122_1:destroy()
	end

	local var_122_2 = cavebotState[128]()

	for waypointIndex = arg_122_0, #cavebotState[1] do
		local var_122_3 = cavebotState[1][waypointIndex]
		local var_122_4 = cavebotState[8][waypointIndex]

		if var_122_4 and not var_122_4:isDestroyed() then
			var_122_4.waypointIndex = waypointIndex
			var_122_4.zebraColor = waypointIndex % 2 == 0 and "#414141" or "#484848"

			var_122_4:setBackgroundColor(waypointIndex == cavebotState[2] and "#585858" or var_122_4.zebraColor)

			local waypointTitle = var_122_4:getChildById("waypointTitle")
			local waypointPosition = var_122_4:getChildById("waypointPosition")
			local waypointTypeIcon = var_122_4:getChildById("waypointTypeIcon")

			if waypointTitle then
				waypointTitle:setText(string.format("%d. %s", waypointIndex, cavebotState[109](var_122_3.kind)))
			end

			if waypointPosition then
				waypointPosition:setText(cavebotState[107](var_122_3))
			end

			if waypointTypeIcon then
				waypointTypeIcon:setImageSource(cavebotState[150](var_122_2 and waypointIndex == cavebotState[3]))
				waypointTypeIcon:setImageColor(var_122_3.kind == "box" and cavebotState[84] or "#ffffff")
			end
		end

		local var_122_8 = cavebotState[7][waypointIndex]

		if var_122_8 and not var_122_8:isDestroyed() then
			var_122_8.waypointIndex = waypointIndex

			var_122_8:setTooltip(cavebotState[151](waypointIndex, var_122_3))
			var_122_8:setImageSource(cavebotState[150](var_122_2 and waypointIndex == cavebotState[3]))
			var_122_8:setImageColor(var_122_3.kind == "box" and cavebotState[84] or "#ffffff")
		end
	end

	HelperCavebot.refreshExternalMapMarkers()
end

  cavebotState[167] = function()
	local var_123_0 = cavebotState[85]("cavebotWaypointCountLabel")

	if var_123_0 then
		var_123_0:setText(string.format("%d WP", #cavebotState[1]))
	end
end

  cavebotState[168] = function()
	cavebotState[163]()
	cavebotState[167]()
	cavebotState[159]()
	cavebotState[161]()
	cavebotState[158]()
	cavebotState[125]()
end

  cavebotState[169] = function(arg_125_0)
	local var_125_0 = cavebotState[85]("cavebotMapPreview")

	arg_125_0 = cavebotState[88](arg_125_0)

	if not var_125_0 or var_125_0:isDestroyed() or not arg_125_0 then
		return false
	end

	var_125_0:setCameraPosition(arg_125_0)

	return true
end

  cavebotState[170] = function(arg_126_0)
	local var_126_0 = cavebotState[85]("cavebotMapPreview")

	arg_126_0 = cavebotState[88](arg_126_0)

	if not arg_126_0 then
		return
	end

	local function var_126_1(arg_127_0)
		if not arg_127_0 or arg_127_0:isDestroyed() then
			return
		end

		arg_127_0:setCrossPosition(arg_126_0)

		if not HelperCavebotAutoRoute or not HelperCavebotAutoRoute.isActive() then
			arg_127_0:setCameraPosition(arg_126_0)
		end
	end

	var_126_1(var_126_0)
	var_126_1(HelperCavebot.externalMapPreview)
end

  cavebotState[171] = function(numericValue, arg_128_1)
	numericValue = tonumber(numericValue)
	arg_128_1 = tonumber(arg_128_1)

	if not numericValue or not arg_128_1 then
		return false
	end

	numericValue = numericValue % 24
	cavebotState[37] = {
		h = numericValue,
		m = arg_128_1
	}

	local var_128_0 = cavebotState[85]("cavebotRoseMain")
	local var_128_1 = cavebotState[85]("cavebotRoseSecondary")

	if not var_128_0 or not var_128_1 or var_128_0:isDestroyed() or var_128_1:isDestroyed() then
		return false
	end

	local var_128_2 = math.floor(0.08611111111111111 * (numericValue * 60 + arg_128_1))
	local var_128_3 = 31
	local var_128_4 = 0

	if var_128_2 + 31 >= 124 then
		var_128_4 = var_128_2 + 31 - 124 + 1
		var_128_3 = 31 - var_128_4
	end

	var_128_0:setWidth(var_128_3)
	var_128_1:setWidth(var_128_4)

	if var_128_4 == 0 then
		var_128_1:hide()
	else
		var_128_1:setImageClip("0 0 " .. var_128_4 .. " 31")
		var_128_1:show()
	end

	if var_128_3 == 0 then
		var_128_0:hide()
	else
		var_128_0:setImageClip(var_128_2 .. " 0 " .. var_128_3 .. " 31")
		var_128_0:show()
	end

	return true
end

  cavebotState[172] = function()
	local var_129_0 = modules and modules.game_minimap
	local var_129_1 = var_129_0 and var_129_0.mapController
	local var_129_2 = var_129_1 and var_129_1.ui

	if not var_129_2 or var_129_2:isDestroyed() then
		return false
	end

	local rosePanel = var_129_2:recursiveGetChildById("rosePanel")
	local ambients = rosePanel and rosePanel:getChildById("ambients")
	local main = ambients and ambients:getChildById("main")
	local secondary = ambients and ambients:getChildById("secondary")
	local var_129_7 = cavebotState[85]("cavebotRoseMain")
	local var_129_8 = cavebotState[85]("cavebotRoseSecondary")

	if not main or not secondary or not var_129_7 or not var_129_8 then
		return false
	end

	var_129_7:setWidth(main:getWidth())
	var_129_7:setImageClip(main:getImageClip())
	var_129_7:setVisible(main:isExplicitlyVisible())
	var_129_8:setWidth(secondary:getWidth())
	var_129_8:setImageClip(secondary:getImageClip())
	var_129_8:setVisible(secondary:isExplicitlyVisible())

	return true
end

  cavebotState[173] = function(arg_130_0, arg_130_1)
	cavebotState[171](arg_130_0, arg_130_1)
end

  cavebotState[174] = function()
	cavebotState[125]()

	if not cavebotState[119]() then
		cavebotState[127]()
	end

	if cavebotState[172]() then
		return true
	end

	if cavebotState[37] then
		return cavebotState[171](cavebotState[37].h, cavebotState[37].m)
	end

	return false
end

  cavebotState[175] = function(arg_132_0, arg_132_1)
	local var_132_0 = cavebotState[1][#cavebotState[1]]

	return var_132_0 and var_132_0.kind == arg_132_0 and var_132_0.position.x == arg_132_1.x and var_132_0.position.y == arg_132_1.y and var_132_0.position.z == arg_132_1.z
end

  cavebotState[176] = function(arg_133_0, arg_133_1)
	arg_133_1 = cavebotState[88](arg_133_1)

	if not arg_133_1 or cavebotState[175](arg_133_0, arg_133_1) then
		return false
	end

	return HelperCavebot.addWaypointAt(arg_133_0, arg_133_1)
end

 cavebotState[32].findTileItem = function(arg_134_0, arg_134_1, arg_134_2)
	if not arg_134_0 or not arg_134_1 then
		return nil
	end

	if arg_134_2 ~= nil then
		local thing = arg_134_0:getThing(arg_134_2)

		if thing and thing:isItem() and thing:getId() == arg_134_1 then
			return thing
		end
	end

	for unusedValue, getThing in ipairs(arg_134_0:getThings()) do
		if getThing and getThing:isItem() and getThing:getId() == arg_134_1 then
			return getThing
		end
	end

	return nil
end

 cavebotState[32].holdFarUse = function(arg_135_0, arg_135_1, arg_135_2)
	cavebotState[32].pendingUse = {
		usePosition = arg_135_0,
		targetId = arg_135_1,
		withItemId = arg_135_2,
		at = cavebotState[87]()
	}
end

 cavebotState[32].absorbPendingUse = function(arg_136_0)
	local var_136_0 = cavebotState[32].pendingUse

	if not var_136_0 or not arg_136_0 then
		return false
	end

	if cavebotState[87]() - var_136_0.at > cavebotState[32].farUseWindow then
		cavebotState[32].pendingUse = nil

		return false
	end

	if cavebotState[145](arg_136_0, var_136_0.usePosition) > 1 or math.abs(arg_136_0.z - var_136_0.usePosition.z) > 1 then
		return false
	end

	local var_136_1 = cavebotState[88](arg_136_0)

	cavebotState[32].pendingUse = nil

	if not var_136_1 or not HelperCavebot.addWaypointAt("use", var_136_1, {
		usePosition = var_136_0.usePosition,
		itemId = var_136_0.targetId,
		withItemId = var_136_0.withItemId
	}) then
		return false
	end

	cavebotState[34] = cavebotState[88](var_136_1)
	cavebotState[32].recordedWaypoint = cavebotState[1][#cavebotState[1]]
	cavebotState[32].recordedAt = cavebotState[87]()

	cavebotState[110](cavebotState[86]("Item use recorded", "Use de item gravado"))

	return true
end

 cavebotState[32].findTool = function(arg_137_0)
	arg_137_0 = math.floor(tonumber(arg_137_0) or 0)

	if arg_137_0 <= 0 then
		return nil
	end

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and localPlayer.getInventoryItem and InventorySlotFirst then
		for iter_137_0 = InventorySlotFirst, InventorySlotLast do
			local inventoryItem = localPlayer:getInventoryItem(iter_137_0)

			if inventoryItem and inventoryItem.getId and inventoryItem:getId() == arg_137_0 then
				return inventoryItem
			end
		end
	end

	if not g_game.getContainers then
		return nil
	end

	for unusedValue, entry in pairs(g_game.getContainers() or {}) do
		if entry and entry.getItems then
			for unusedValue, entry in ipairs(entry:getItems() or {}) do
				if entry and entry.getId and entry:getId() == arg_137_0 then
					return entry
				end
			end
		end
	end

	return nil
end

 cavebotState[32].record = function(arg_138_0, arg_138_1, arg_138_2)
	if not cavebotState[33] then
		return
	end

	local tilePosition = cavebotState[88](arg_138_0)
	local localPlayer = g_game.getLocalPlayer()
	local position = cavebotState[88](localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	arg_138_1 = math.floor(tonumber(arg_138_1) or 0)

	if not tilePosition or tilePosition.x == 65535 or not position or arg_138_1 <= 0 then
		return
	end

	if cavebotState[145](position, tilePosition) > 1 or math.abs(position.z - tilePosition.z) > 1 then
		cavebotState[32].holdFarUse(tilePosition, arg_138_1, nil)

		return
	end

	local tile = g_map.getTile(tilePosition)
	local var_138_4 = cavebotState[32].findTileItem(tile, arg_138_1, arg_138_2)

	if var_138_4 and (var_138_4:isPickupable() or var_138_4:isContainer()) then
		cavebotState[110](cavebotState[86]("Only fixed map objects are recorded", "So objetos fixos do mapa sao gravados"))

		return
	end

	local var_138_5 = cavebotState[1][#cavebotState[1]]

	if var_138_5 and var_138_5.kind == "use" and var_138_5.itemId == arg_138_1 and cavebotState[89](var_138_5.position) == cavebotState[89](position) and cavebotState[89](var_138_5.usePosition) == cavebotState[89](tilePosition) then
		return
	end

	if HelperCavebot.addWaypointAt("use", position, {
		usePosition = tilePosition,
		itemId = arg_138_1
	}) then
		cavebotState[34] = cavebotState[88](position)
		cavebotState[32].recordedWaypoint = cavebotState[1][#cavebotState[1]]
		cavebotState[32].recordedAt = cavebotState[87]()

		cavebotState[110](cavebotState[86]("Item use recorded", "Use de item gravado"))
	end
end

 cavebotState[32].absorbRecordedTransition = function(arg_139_0)
	local var_139_0 = cavebotState[32].recordedWaypoint

	if not var_139_0 or var_139_0 ~= cavebotState[1][#cavebotState[1]] or cavebotState[87]() - cavebotState[32].recordedAt > cavebotState[32].recordWindow then
		return false
	end

	if cavebotState[89](var_139_0.position) ~= cavebotState[89](arg_139_0) and cavebotState[89](var_139_0.usePosition) ~= cavebotState[89](arg_139_0) then
		return false
	end

	var_139_0.transition = true

	cavebotState[32].resetRecording()

	return true
end

 cavebotState[32].recordWith = function(unusedArgument, arg_140_1, arg_140_2, unusedArgument)
	if not cavebotState[33] or not arg_140_2 then
		return
	end

	arg_140_1 = math.floor(tonumber(arg_140_1) or 0)

	if arg_140_1 <= 0 then
		return
	end

	if arg_140_2.isCreature and arg_140_2:isCreature() then
		local tile = arg_140_2.getPosition and g_map.getTile(arg_140_2:getPosition())
		local topUseThing = tile and tile.getTopUseThing and tile:getTopUseThing()

		if not topUseThing or topUseThing.isCreature and topUseThing:isCreature() then
			return
		end

		arg_140_2 = topUseThing
	end

	local position = cavebotState[88](arg_140_2.getPosition and arg_140_2:getPosition())
	local localPlayer = g_game.getLocalPlayer()
	local var_140_4 = cavebotState[88](localPlayer and localPlayer.getPosition and localPlayer:getPosition())
	local id = arg_140_2.getId and math.floor(tonumber(arg_140_2:getId()) or 0) or 0

	if not position or position.x == 65535 or not var_140_4 or id <= 0 then
		return
	end

	if not cavebotState[32].toolIds[arg_140_1] then
		cavebotState[110](string.format(cavebotState[86]("Item %d is not a recordable tool", "Item %d nao e uma ferramenta gravavel"), arg_140_1))

		return
	end

	if cavebotState[145](var_140_4, position) > 1 or math.abs(var_140_4.z - position.z) > 1 then
		cavebotState[32].holdFarUse(position, id, arg_140_1)

		return
	end

	local var_140_6 = cavebotState[1][#cavebotState[1]]

	if var_140_6 and var_140_6.kind == "use" and var_140_6.withItemId == arg_140_1 and cavebotState[89](var_140_6.position) == cavebotState[89](var_140_4) and cavebotState[89](var_140_6.usePosition) == cavebotState[89](position) then
		return
	end

	if HelperCavebot.addWaypointAt("use", var_140_4, {
		usePosition = position,
		itemId = id,
		withItemId = arg_140_1
	}) then
		cavebotState[34] = cavebotState[88](var_140_4)
		cavebotState[32].recordedWaypoint = cavebotState[1][#cavebotState[1]]
		cavebotState[32].recordedAt = cavebotState[87]()

		cavebotState[110](cavebotState[86]("Item use recorded", "Use de item gravado"))
	end
end

 cavebotState[26] = function(arg_141_0)
	if not cavebotState[33] then
		return false
	end

	cavebotState[33] = false
	cavebotState[34] = nil

	cavebotState[32].resetRecording()
	cavebotState[161]()

	if not arg_141_0 then
		cavebotState[110](string.format("%s - %d WP", cavebotState[86]("Recording stopped", "Gravacao encerrada"), #cavebotState[1]))
		cavebotState[130]()
	end

	return true
end

  cavebotState[177] = function(arg_142_0, arg_142_1)
	if not cavebotState[33] or not arg_142_0 or not arg_142_1 then
		return
	end

	arg_142_0 = cavebotState[88](arg_142_0)
	arg_142_1 = cavebotState[88](arg_142_1)

	if not arg_142_0 or not arg_142_1 then
		return
	end

	if not cavebotState[34] then
		cavebotState[176]("position", arg_142_1)

		cavebotState[34] = cavebotState[88](arg_142_1)
	end

	cavebotState[32].absorbPendingUse(arg_142_0)

	local var_142_0 = cavebotState[146](arg_142_1, arg_142_0)

	if var_142_0 then
		cavebotState[32].absorbPendingUse(arg_142_1)

		if cavebotState[32].absorbRecordedTransition(arg_142_1) then
			cavebotState[34] = cavebotState[88](arg_142_0)

			cavebotState[110](cavebotState[86]("Use moved the character", "Use moveu o personagem"))

			return
		end

		cavebotState[176](var_142_0, arg_142_1)

		cavebotState[34] = cavebotState[88](arg_142_0)

		cavebotState[110](var_142_0 == "stairs" and cavebotState[86]("Stairs recorded", "Escada gravada") or cavebotState[86]("Teleport recorded", "Teleporte gravado"))

		return
	end

	if cavebotState[34].z == arg_142_0.z and cavebotState[145](cavebotState[34], arg_142_0) >= cavebotState[62] and cavebotState[176]("position", arg_142_0) then
		cavebotState[34] = cavebotState[88](arg_142_0)

		cavebotState[110](string.format("%s #%d", cavebotState[86]("Recording waypoint", "Gravando waypoint"), #cavebotState[1]))
	end
end

  cavebotState[178] = function(arg_143_0, arg_143_1)
	local var_143_0 = cavebotState[88](arg_143_0)

	if not var_143_0 then
		return
	end

	local popupMenuWidget = g_ui.createWidget("PopupMenu")

	popupMenuWidget:setGameMenu(true)
	popupMenuWidget:addOption(cavebotState[86]("Add Position Waypoint", "Adicionar waypoint de posicao"), function()
		HelperCavebot.addWaypointAt("position", var_143_0)
	end)
	popupMenuWidget:addOption(cavebotState[86]("Add Box Waypoint", "Adicionar waypoint de box"), function()
		HelperCavebot.addWaypointAt("box", var_143_0)
	end)
	popupMenuWidget:addOption(cavebotState[86]("Add Passage Waypoint", "Adicionar waypoint de passagem"), function()
		HelperCavebot.addWaypointAt("transition", var_143_0)
	end)
	popupMenuWidget:display(arg_143_1)
end

function HelperCavebot.chooseAutoRoutePresetName()
	return cavebotState[43](cavebotState[86]("New Automatic Route", "Nova Rota Automatica"), HelperCavebot.startAutoRouteForPreset, HelperCavebot.getAutoRouteNameError)
end

function HelperCavebot.startAutoRouteForPreset(arg_148_0)
	local var_148_0 = HelperCavebotAutoRoute

	if not var_148_0 then
		return false
	end

	arg_148_0 = cavebotState[101](arg_148_0)

	local autoRouteNameError = HelperCavebot.getAutoRouteNameError(arg_148_0)

	if autoRouteNameError then
		cavebotState[110](autoRouteNameError)

		return false
	end

	if cavebotState[41] and not cavebotState[41]:isDestroyed() then
		cavebotState[41]:destroy()
	end

	cavebotState[41] = nil

	local autoRouteDestination = HelperCavebot.getAutoRouteDestination(arg_148_0)

	if #autoRouteDestination.waypoints == 0 then
		return var_148_0.start(autoRouteDestination)
	end

	if not displayGeneralBox then
		cavebotState[110](cavebotState[86]("Overwrite confirmation is unavailable", "A confirmacao de sobrescrita esta indisponivel"))

		return false
	end

	local var_148_3

	local function var_148_4()
		if cavebotState[41] ~= var_148_3 or not var_148_3 or var_148_3:isDestroyed() then
			return false
		end

		cavebotState[41] = nil

		var_148_3:destroy()

		return true
	end

	local function var_148_5()
		if not var_148_4() then
			return
		end

		var_148_0.start(HelperCavebot.getAutoRouteDestination(arg_148_0))
	end

	local function var_148_6()
		if var_148_4() then
			HelperCavebot.chooseAutoRoutePresetName()
		end
	end

	var_148_3 = displayGeneralBox(cavebotState[86]("Overwrite Route", "Sobrescrever Rota"), string.format(cavebotState[86]("The profile \"%s\" already has waypoints.\nDo you want to overwrite them?\nThe current route is only replaced when you click Apply.", "Ja existem waypoints no perfil \"%s\".\nDeseja sobrescrever?\nA rota atual so sera substituida ao clicar em Aplicar."), arg_148_0), {
		{
			text = cavebotState[86]("No", "Nao"),
			callback = var_148_6
		},
		{
			text = cavebotState[86]("Yes", "Sim"),
			callback = var_148_5
		}
	}, var_148_5, var_148_4)
	cavebotState[41] = var_148_3

	return true
end

function HelperCavebot.toggleAutoRouteSelection()
	local var_152_0 = HelperCavebotAutoRoute

	if not var_152_0 then
		return false
	end

	if var_152_0.isActive() then
		return var_152_0.cancel(true)
	end

	if cavebotState[42] and not cavebotState[42]:isDestroyed() then
		cavebotState[42]:destroy()
	end

	return HelperCavebot.startAutoRouteForPreset(cavebotState[39])
end

  cavebotState[179] = function(arg_153_0)
	local var_153_0 = cavebotState[85]("cavebotMapPreview")

	if not var_153_0 or var_153_0:isDestroyed() then
		return
	end

	var_153_0.autowalk = false

	if not var_153_0.cavebotSetupDone then
		var_153_0.cavebotSetupDone = true

		var_153_0:setZoom(2)

		function var_153_0.onMouseRelease(arg_154_0, arg_154_1, arg_154_2)
			if not arg_154_0.allowNextRelease then
				return true
			end

			arg_154_0.allowNextRelease = false

			local tilePosition = arg_154_0:getTilePosition(arg_154_1)

			if not tilePosition then
				return false
			end

			if arg_154_2 == MouseRightButton then
				cavebotState[178](tilePosition, arg_154_1)

				return true
			end

			return arg_154_2 == MouseLeftButton
		end
	end

	local localPlayer = g_game.getLocalPlayer()
	local position = cavebotState[88](localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if position then
		var_153_0:setCrossPosition(position)

		if arg_153_0 or not var_153_0:getCameraPosition() then
			var_153_0:setCameraPosition(position)
		end
	end

	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.refreshButton()
	end

	cavebotState[158]()
end

function HelperCavebot.setupExternalMapPreview(arg_155_0)
	local externalMapPreview = HelperCavebot.externalMapPreview

	if not externalMapPreview or externalMapPreview:isDestroyed() then
		HelperCavebot.externalMapPreview = nil
		HelperCavebot.externalMapMarkers = HelperCavebot.destroyMarkerCollection(HelperCavebot.externalMapMarkers)

		return false
	end

	externalMapPreview.autowalk = false

	if not externalMapPreview.cavebotSetupDone then
		externalMapPreview.cavebotSetupDone = true

		externalMapPreview:setZoom(2)

		function externalMapPreview.onMouseRelease(arg_156_0, arg_156_1, arg_156_2)
			if not arg_156_0.allowNextRelease then
				return true
			end

			arg_156_0.allowNextRelease = false

			local tilePosition = arg_156_0:getTilePosition(arg_156_1)

			if not tilePosition then
				return false
			end

			if arg_156_2 == MouseRightButton then
				cavebotState[178](tilePosition, arg_156_1)

				return true
			end

			return arg_156_2 == MouseLeftButton
		end
	end

	local localPlayer = g_game.getLocalPlayer()
	local position = cavebotState[88](localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if position then
		externalMapPreview:setCrossPosition(position)

		if arg_155_0 or not externalMapPreview:getCameraPosition() then
			externalMapPreview:setCameraPosition(position)
		end
	end

	HelperCavebot.refreshExternalMapMarkers()

	return true
end

function HelperCavebot.setExternalMapPreview(externalMapPreview, arg_157_1)
	HelperCavebot.externalMapMarkers = HelperCavebot.destroyMarkerCollection(HelperCavebot.externalMapMarkers)
	HelperCavebot.externalMapPreview = nil

	if arg_157_1 ~= true then
		return true
	end

	if not externalMapPreview or externalMapPreview:isDestroyed() then
		return false
	end

	HelperCavebot.externalMapPreview = externalMapPreview

	return HelperCavebot.setupExternalMapPreview(true)
end

  cavebotState[180] = function(arg_158_0)
	if #cavebotState[1] == 0 then
		cavebotState[3] = 1

		return
	end

	local var_158_0 = cavebotState[2]
	local var_158_1 = cavebotState[3]

	cavebotState[3] = cavebotState[3] + 1

	if cavebotState[3] > #cavebotState[1] then
		cavebotState[3] = 1
	end

	cavebotState[28] = false
	cavebotState[29] = nil

	cavebotState[31].resetContinuousWalkProgress()

	cavebotState[31].handoff = true

	cavebotState[98]()

	cavebotState[30] = 0
	cavebotState[31].reachedAt = nil
	cavebotState[31].crossHazards = false

	cavebotState[32].resetRuntime()

	cavebotState[54] = nil
	cavebotState[49] = false
	cavebotState[51] = 0
	cavebotState[52] = 0

	if arg_158_0 then
		cavebotState[110](arg_158_0)
	end

	cavebotState[160]()
	cavebotState[165](var_158_0, var_158_1)
end

  cavebotState[181] = function(arg_159_0)
	if #cavebotState[1] == 0 then
		return false
	end

	for iter_159_0 = 0, #cavebotState[1] - 1 do
		local var_159_0 = (cavebotState[3] - 1 + iter_159_0) % #cavebotState[1] + 1
		local var_159_1 = cavebotState[1][var_159_0]

		if var_159_1 and var_159_1.position.z == arg_159_0 then
			if cavebotState[3] ~= var_159_0 then
				local var_159_2 = cavebotState[2]
				local var_159_3 = cavebotState[3]

				cavebotState[3] = var_159_0

				cavebotState[98]()

				cavebotState[30] = 0
				cavebotState[31].reachedAt = nil

				cavebotState[160]()
				cavebotState[165](var_159_2, var_159_3)
			end

			return true
		end
	end

	return false
end

 cavebotState[31].nearestStartWaypointIndex = function(arg_160_0)
	if not arg_160_0 or #cavebotState[1] == 0 then
		return nil
	end

	local var_160_0
	local huge = math.huge
	local var_160_2
	local var_160_3 = math.huge
	local var_160_4 = math.huge
	local var_160_5 = cavebotState[31].blockedPathPositions()

	for index, ptc_root_local in ipairs(cavebotState[1]) do
		local var_160_6 = ptc_root_local and ptc_root_local.position

		if ptc_root_local and cavebotState[108](ptc_root_local.kind) and var_160_6 and var_160_6.z == arg_160_0.z then
			local var_160_7 = cavebotState[144](arg_160_0, var_160_6)

			if var_160_7 < huge then
				var_160_0 = index
				huge = var_160_7
			end

			local var_160_8

			if var_160_7 == 0 then
				var_160_8 = 0
			elseif g_map and g_map.findPathWithBlockedFloorChanges then
				local var_160_9, var_160_10 = pcall(function()
					return g_map.findPathWithBlockedFloorChanges(arg_160_0, var_160_6, cavebotState[147](arg_160_0, var_160_6), cavebotState[82], var_160_5, false)
				end)

				if var_160_9 and type(var_160_10) == "table" and var_160_10[1] ~= nil then
					var_160_8 = #var_160_10
				end
			end

			if var_160_8 and (var_160_8 < var_160_3 or var_160_8 == var_160_3 and var_160_7 < var_160_4) then
				var_160_2 = index
				var_160_3 = var_160_8
				var_160_4 = var_160_7
			end
		end
	end

	return var_160_2 or var_160_0
end

 cavebotState[31].alignCurrentWaypointToNearest = function(arg_162_0)
	local var_162_0 = cavebotState[31].nearestStartWaypointIndex(arg_162_0)

	if not var_162_0 then
		return false
	end

	if cavebotState[3] ~= var_162_0 then
		local var_162_1 = cavebotState[2]
		local var_162_2 = cavebotState[3]

		cavebotState[3] = var_162_0

		cavebotState[98]()

		cavebotState[30] = 0
		cavebotState[31].reachedAt = nil

		cavebotState[160]()
		cavebotState[165](var_162_1, var_162_2)
	end

	return true
end

  cavebotState[182] = function(startPosition)
	if not startPosition or not g_map or type(g_map.findEveryPath) ~= "function" then
		return nil
	end

	local timestamp = cavebotState[87]()

	if cavebotState[55].paths and cavebotState[55].origin and cavebotState[144](startPosition, cavebotState[55].origin) <= cavebotState[66] and timestamp - cavebotState[55].timestamp <= cavebotState[67] then
		return cavebotState[55].paths
	end

	local paths = g_map.findEveryPath(startPosition, cavebotState[65] + cavebotState[66], {
		ignoreCost = true,
		ignoreCreatures = true,
		allowOnlyVisibleTiles = true,
		ignoreNonPathable = true
	})

	if type(paths) ~= "table" then
		paths = nil
	end

	cavebotState[55].origin = cavebotState[88](startPosition)
	cavebotState[55].timestamp = timestamp
	cavebotState[55].paths = paths

	return paths
end

  cavebotState[183] = function(arg_164_0, arg_164_1)
	if type(arg_164_0) ~= "table" or not arg_164_1 then
		return false
	end

	for iter_164_0 = -1, 1 do
		for iter_164_1 = -1, 1 do
			local var_164_0 = {
				x = arg_164_1.x + iter_164_0,
				y = arg_164_1.y + iter_164_1,
				z = arg_164_1.z
			}

			if arg_164_0[cavebotState[89](var_164_0)] then
				return true
			end
		end
	end

	return false
end

function HelperCavebot.isCreatureReachable(arg_165_0, arg_165_1)
	if not arg_165_0 or not arg_165_1 or arg_165_0.z ~= arg_165_1.z then
		return false
	end

	return cavebotState[183](cavebotState[182](arg_165_0), arg_165_1)
end

  cavebotState[184] = function(arg_166_0)
	local var_166_0 = {}

	if not arg_166_0 or not g_map or not g_map.getSpectators then
		return var_166_0
	end

	for unusedValue, entry in ipairs(g_map.getSpectators(arg_166_0, false) or {}) do
		if entry and entry.isMonster and entry:isMonster() and (not entry.isDead or not entry:isDead()) and (not HelperTarget or not HelperTarget.isFamiliar or not HelperTarget.isFamiliar(entry)) then
			local position = entry:getPosition()
			local var_166_2 = position and cavebotState[144](arg_166_0, position) or math.huge

			if position and position.z == arg_166_0.z and var_166_2 <= cavebotState[65] then
				var_166_0[#var_166_0 + 1] = {
					id = entry.getId and entry:getId() or nil,
					position = cavebotState[88](position),
					distance = var_166_2
				}
			end
		end
	end

	if #var_166_0 == 0 then
		return var_166_0
	end

	local var_166_3 = cavebotState[182](arg_166_0)
	local var_166_4 = {}

	for unusedValue, entry in ipairs(var_166_0) do
		if cavebotState[183](var_166_3, entry.position) then
			var_166_4[#var_166_4 + 1] = entry
		end
	end

	return var_166_4
end

  cavebotState[185] = function()
	return math.max(cavebotState[72], math.min(cavebotState[73], math.floor(tonumber(cavebotState[47].walkSpeed) or cavebotState[77])))
end

  cavebotState[186] = function()
	return cavebotState[185]() < cavebotState[73]
end

  cavebotState[187] = function()
	local var_169_0 = cavebotState[185]()
	local var_169_1 = math.max(1, math.min(cavebotState[78], math.ceil(var_169_0 / 5)))
	local var_169_2 = math.max(cavebotState[58], math.floor(var_169_1 * 1000 / var_169_0))

	return var_169_0, var_169_1, var_169_2
end

  cavebotState[188] = function(arg_170_0)
	local var_170_0 = 0

	for unusedValue, entry in ipairs(arg_170_0) do
		var_170_0 = math.max(var_170_0, entry.distance)
	end

	local var_170_1 = math.max(0, cavebotState[68] - var_170_0)

	return math.min(cavebotState[70], cavebotState[69] + math.floor(var_170_1) * 2)
end

  cavebotState[189] = function(arg_171_0, arg_171_1, arg_171_2)
	local var_171_0 = 0

	for unusedValue, entry in ipairs(arg_171_0) do
		local var_171_1 = cavebotState[144](arg_171_1, entry.position)
		local var_171_2 = cavebotState[144](arg_171_2, entry.position)

		if var_171_2 > cavebotState[68] and var_171_1 < var_171_2 then
			var_171_0 = var_171_0 + 1
		end
	end

	return var_171_0
end

  cavebotState[190] = function(arg_172_0, arg_172_1, arg_172_2, arg_172_3)
	local var_172_0 = cavebotState[88](arg_172_0)
	local var_172_1 = 0
	local unusedValue = 0
	local var_172_3 = math.min(cavebotState[188](arg_172_2), tonumber(arg_172_3) or math.huge)

	for iter_172_0 = 1, math.min(#arg_172_1, var_172_3) do
		local tilePosition = Position.translatedToDirection(var_172_0, arg_172_1[iter_172_0])
		local tile = g_map.getTile(tilePosition)

		if not (tile and tile:isWalkable(false) and not tile:hasCreatures() and not tile:hasFloorChange() and not cavebotState[31].isBlockedPathPosition(tilePosition)) then
			return var_172_1 > 0 and var_172_0 or nil, var_172_1, 0, nil, true
		end

		local var_172_6 = cavebotState[189](arg_172_2, var_172_0, tilePosition)

		if var_172_6 > 0 then
			return var_172_1 > 0 and var_172_0 or nil, var_172_1, var_172_6, tilePosition, false
		end

		var_172_0 = tilePosition
		var_172_1 = iter_172_0
	end

	return var_172_0, var_172_1, 0, nil, false
end

  cavebotState[191] = function(arg_173_0, arg_173_1, arg_173_2, arg_173_3, arg_173_4)
	local var_173_0, var_173_1 = pcall(function()
		return g_map.findPathWithBlockedFloorChanges(arg_173_0, arg_173_1, arg_173_2, arg_173_3, cavebotState[31].blockedPathPositions(), arg_173_4 == true)
	end)

	if not var_173_0 or type(var_173_1) ~= "table" or var_173_1[1] == nil then
		return nil
	end

	return var_173_1
end

 cavebotState[31].ensureWalkPermission = function(arg_175_0, arg_175_1, arg_175_2)
	if cavebotState[31].crossHazards or not arg_175_0 or not arg_175_1 or arg_175_1.z ~= arg_175_0.z or cavebotState[145](arg_175_0, arg_175_1) == 0 then
		return
	end

	local var_175_0 = cavebotState[147](arg_175_0, arg_175_1)

	if cavebotState[191](arg_175_0, arg_175_1, var_175_0, cavebotState[31].walkPathFlags(false), arg_175_2) then
		return
	end

	cavebotState[31].crossHazards = true

	if not cavebotState[191](arg_175_0, arg_175_1, var_175_0, cavebotState[31].walkPathFlags(false), arg_175_2) then
		cavebotState[31].crossHazards = false
	end
end

 cavebotState[57].tileContains = function(arg_176_0)
	if not arg_176_0 or not arg_176_0.getItems then
		return false
	end

	for unusedValue, entry in ipairs(arg_176_0:getItems() or {}) do
		if entry and entry.getId and cavebotState[57].clientAppearanceIds[entry:getId()] then
			return true
		end
	end

	return false
end

 cavebotState[57].existsAt = function(tilePosition)
	return tilePosition and g_map and g_map.getTile and cavebotState[57].tileContains(g_map.getTile(tilePosition)) or false
end

 cavebotState[57].visiblePositions = function(arg_178_0)
	local var_178_0 = {}

	if arg_178_0 == nil or not g_map or not g_map.getTiles then
		return var_178_0
	end

	for unusedValue, entry in ipairs(g_map.getTiles(arg_178_0) or {}) do
		if cavebotState[57].tileContains(entry) then
			local position = entry:getPosition()

			if position then
				var_178_0[#var_178_0 + 1] = cavebotState[88](position)
			end
		end
	end

	return var_178_0
end

 cavebotState[57].handleDisabled = function(arg_179_0)
	local disabledSeenKeys = {}
	local var_179_1 = false

	for unusedValue, entry in ipairs(cavebotState[57].visiblePositions(arg_179_0.z)) do
		local var_179_2 = cavebotState[89](entry)

		disabledSeenKeys[var_179_2] = true

		if not cavebotState[57].disabledSeenKeys[var_179_2] then
			var_179_1 = true
		end
	end

	cavebotState[57].disabledSeenKeys = disabledSeenKeys

	if var_179_1 and cavebotState[28] then
		cavebotState[25]()

		cavebotState[30] = 0
		cavebotState[52] = 0
		cavebotState[31].handoff = true

		cavebotState[98]()
	end
end

 cavebotState[57].findTarget = function(arg_180_0)
	if not arg_180_0 or not g_map or not g_map.getTiles then
		return nil
	end

	local var_180_0
	local huge = math.huge
	local var_180_2 = false

	for unusedValue, entry in ipairs(g_map.getTiles(arg_180_0.z) or {}) do
		if cavebotState[57].tileContains(entry) then
			local position = cavebotState[88](entry:getPosition())
			local var_180_4 = cavebotState[89](position)

			if var_180_4 == cavebotState[57].handledKey then
				var_180_2 = true
			elseif position and cavebotState[144](arg_180_0, position) <= cavebotState[57].searchRadius then
				local unusedValue
				local var_180_6

				if cavebotState[144](arg_180_0, position) == 0 then
					var_180_6 = 0
				else
					local var_180_7 = cavebotState[191](arg_180_0, position, cavebotState[147](arg_180_0, position), cavebotState[82], false)

					var_180_6 = var_180_7 and #var_180_7 or nil
				end

				if var_180_6 and (var_180_6 < huge or var_180_6 == huge and var_180_4 < cavebotState[89](var_180_0)) then
					var_180_0 = position
					huge = var_180_6
				end
			end
		end
	end

	if cavebotState[57].handledKey and not var_180_2 then
		cavebotState[57].handledKey = nil
	end

	return var_180_0
end

 cavebotState[57].attemptWalk = function(arg_181_0, unusedArgument)
	local var_181_0 = cavebotState[57].target

	if not var_181_0 then
		return false
	end

	local var_181_1 = cavebotState[89](var_181_0)
	local var_181_2 = cavebotState[31].handoff == true

	if arg_181_0.isAutoWalking and arg_181_0:isAutoWalking() then
		if not var_181_2 and cavebotState[29] == var_181_1 then
			return true
		end

		cavebotState[25]()

		var_181_2 = true
	end

	if not var_181_2 and arg_181_0.isWalking and arg_181_0:isWalking() then
		return true
	end

	local var_181_3 = cavebotState[87]()

	if not var_181_2 and var_181_3 - cavebotState[30] < cavebotState[59] then
		return true
	end

	cavebotState[30] = var_181_3

	local var_181_4, var_181_5 = pcall(function()
		return arg_181_0:cavebotAutoWalk(var_181_0, true, true, true, false, cavebotState[31].blockedPathPositions(), true)
	end)

	cavebotState[31].handoff = false

	local var_181_6 = var_181_4 and var_181_5 ~= false

	cavebotState[28] = var_181_6
	cavebotState[29] = var_181_6 and var_181_1 or nil

	if var_181_6 then
		cavebotState[110](string.format("%s - %d, %d, %d", cavebotState[86]("Walking to Echo Raid", "Indo para Echo Raid"), var_181_0.x, var_181_0.y, var_181_0.z))
	else
		cavebotState[110](cavebotState[86]("No path to Echo Raid", "Sem caminho para Echo Raid"))
	end

	return true
end

 cavebotState[57].handleBeforeRoute = function(arg_183_0, arg_183_1)
	if not cavebotState[57].enabled then
		cavebotState[57].handleDisabled(arg_183_1)

		return false
	end

	if cavebotState[57].target then
		local handledKey = cavebotState[89](cavebotState[57].target)

		if cavebotState[144](arg_183_1, cavebotState[57].target) == 0 then
			cavebotState[57].handledKey = handledKey
			cavebotState[57].target = nil
			cavebotState[28] = false
			cavebotState[29] = nil
			cavebotState[30] = 0
			cavebotState[52] = 0
			cavebotState[31].handoff = true

			cavebotState[98]()
			cavebotState[110](cavebotState[86]("Echo Raid activated - resuming route", "Echo Raid ativada - retomando rota"))
		elseif arg_183_1.z ~= cavebotState[57].target.z or not cavebotState[57].existsAt(cavebotState[57].target) then
			cavebotState[57].target = nil

			cavebotState[25]()

			cavebotState[30] = 0
			cavebotState[52] = 0
			cavebotState[31].handoff = true
		end
	end

	if not cavebotState[57].target then
		local lastScanAt = cavebotState[87]()

		if cavebotState[57].lastScanAt == 0 or lastScanAt - cavebotState[57].lastScanAt >= cavebotState[57].scanInterval then
			cavebotState[57].lastScanAt = lastScanAt

			local target = cavebotState[57].findTarget(arg_183_1)

			if target then
				cavebotState[25]()
				cavebotState[131](false)

				cavebotState[57].target = target
				cavebotState[30] = 0
				cavebotState[52] = 0
				cavebotState[31].handoff = true
			end
		end
	end

	if not cavebotState[57].target then
		return false
	end

	return cavebotState[57].attemptWalk(arg_183_0, arg_183_1)
end

  cavebotState[192] = function(arg_184_0, startPosition, arg_184_2, arg_184_3)
	local var_184_0 = cavebotState[87]()
	local var_184_1 = cavebotState[31].handoff == true
	local unusedValue, var_184_3, var_184_4 = cavebotState[187]()
	local var_184_5 = cavebotState[149](startPosition, arg_184_2)
	local var_184_6 = cavebotState[147](startPosition, var_184_5)
	local var_184_7 = cavebotState[31].allowsDestinationFloorChange(arg_184_2)
	local var_184_8 = cavebotState[191](startPosition, var_184_5, var_184_6, cavebotState[31].walkPathFlags(true), var_184_7)

	if not var_184_8 and cavebotState[31].allowHazardCrossing() then
		var_184_8 = cavebotState[191](startPosition, var_184_5, var_184_6, cavebotState[31].walkPathFlags(true), var_184_7)
	end

	if not var_184_8 then
		cavebotState[31].handoff = false
		cavebotState[49] = false

		if arg_184_0.isAutoWalking and arg_184_0:isAutoWalking() then
			return true
		end

		return false
	end

	local var_184_9 = cavebotState[31].diagonalDirections(startPosition, var_184_8)
	local var_184_10 = 0

	for unusedValue, entry in ipairs(arg_184_3) do
		if entry.distance <= 1 then
			var_184_10 = var_184_10 + 1
		end
	end

	local var_184_11, var_184_12, var_184_13, var_184_14, var_184_15 = cavebotState[190](startPosition, var_184_9, arg_184_3, var_184_3)

	if var_184_15 and var_184_12 == 0 then
		cavebotState[25]()

		local var_184_16 = cavebotState[191](startPosition, var_184_5, var_184_6, cavebotState[31].walkPathFlags(false), var_184_7)

		if var_184_16 then
			var_184_9 = cavebotState[31].diagonalDirections(startPosition, var_184_16)
			var_184_11, var_184_12, var_184_13, var_184_14, var_184_15 = cavebotState[190](startPosition, var_184_9, arg_184_3, var_184_3)
		end
	end

	if var_184_15 and var_184_12 == 0 then
		cavebotState[31].handoff = false
		cavebotState[49] = true

		cavebotState[110](cavebotState[86]("Anti-Lost waiting for route", "Anti-Lost aguardando caminho"))

		return true
	end

	if var_184_13 > 0 and var_184_12 == 0 and var_184_10 < cavebotState[71] then
		cavebotState[25]()

		cavebotState[31].handoff = false
		cavebotState[49] = true

		cavebotState[110](string.format("%s: %d", cavebotState[86]("Anti-Lost regrouping", "Anti-Lost reagrupando"), var_184_13))

		return true
	end

	if var_184_13 > 0 and var_184_12 == 0 then
		var_184_11 = var_184_14
		var_184_12 = 1
	end

	local directions = {}

	for iter_184_2 = 1, var_184_12 do
		directions[#directions + 1] = var_184_9[iter_184_2]
	end

	cavebotState[49] = false

	local var_184_18 = cavebotState[89](var_184_11)

	if not var_184_1 and arg_184_0.isAutoWalking and arg_184_0:isAutoWalking() then
		return true
	end

	if not var_184_1 and arg_184_0.isWalking and arg_184_0:isWalking() then
		return true
	end

	if not var_184_1 and var_184_4 > var_184_0 - cavebotState[51] then
		return true
	end

	cavebotState[51] = var_184_0
	cavebotState[30] = var_184_0

	local var_184_19, var_184_20 = pcall(function()
		return g_game.autoWalk(directions, startPosition)
	end)

	cavebotState[31].handoff = false

	local var_184_21 = var_184_19 and var_184_20 ~= false

	cavebotState[28] = var_184_21
	cavebotState[29] = var_184_21 and var_184_18 or nil

	if var_184_21 then
		cavebotState[110](string.format("%s #%d - %s", cavebotState[86]("Anti-Lost walking to", "Anti-Lost indo para"), cavebotState[3], cavebotState[107](arg_184_2)))
	else
		cavebotState[110](string.format("%s #%d", cavebotState[86]("No path to waypoint", "Sem caminho para waypoint"), cavebotState[3]))
	end

	return true
end

  cavebotState[193] = function(arg_186_0, arg_186_1, arg_186_2)
	local originKey = cavebotState[89](arg_186_0)
	local destinationKey = cavebotState[89](arg_186_1)
	local var_186_2

	if cavebotState[56].originKey == originKey and cavebotState[56].destinationKey == destinationKey and type(cavebotState[56].directions) == "table" and cavebotState[56].directions[1] ~= nil then
		var_186_2 = cavebotState[56].directions
	else
		var_186_2 = cavebotState[191](arg_186_0, arg_186_1, cavebotState[147](arg_186_0, arg_186_1), cavebotState[31].walkPathFlags(false), arg_186_2)

		if not var_186_2 and cavebotState[31].allowHazardCrossing() then
			var_186_2 = cavebotState[191](arg_186_0, arg_186_1, cavebotState[147](arg_186_0, arg_186_1), cavebotState[31].walkPathFlags(false), arg_186_2)
		end

		if not var_186_2 then
			cavebotState[98]()

			return nil
		end

		cavebotState[56].originKey = originKey
		cavebotState[56].destinationKey = destinationKey
	end

	cavebotState[56].directions = cavebotState[31].diagonalDirections(arg_186_0, var_186_2)

	return cavebotState[56].directions
end

  cavebotState[194] = function(arg_187_0, arg_187_1, arg_187_2)
	local var_187_0 = cavebotState[88](arg_187_0)
	local var_187_1 = {}
	local var_187_2 = 0

	for iter_187_0 = 1, math.min(#arg_187_1, arg_187_2) do
		local tilePosition = Position.translatedToDirection(var_187_0, arg_187_1[iter_187_0])
		local tile = g_map.getTile(tilePosition)

		if not (tile and tile:isWalkable(false) and not tile:hasCreatures() and not tile:hasFloorChange() and not cavebotState[31].isBlockedPathPosition(tilePosition)) then
			break
		end

		var_187_1[#var_187_1 + 1] = arg_187_1[iter_187_0]
		var_187_0 = tilePosition
		var_187_2 = iter_187_0
	end

	return var_187_2 > 0 and var_187_0 or nil, var_187_1, var_187_2
end

  cavebotState[195] = function(arg_188_0, arg_188_1, arg_188_2)
	local directions = {}

	for iter_188_0 = arg_188_2 + 1, #arg_188_1 do
		directions[#directions + 1] = arg_188_1[iter_188_0]
	end

	cavebotState[56].originKey = cavebotState[89](arg_188_0)
	cavebotState[56].directions = directions
end

  cavebotState[196] = function(arg_189_0, startPosition, arg_189_2)
	local var_189_0 = cavebotState[87]()
	local var_189_1 = cavebotState[31].handoff == true
	local var_189_2 = not cavebotState[186]()

	if cavebotState[28] and cavebotState[29] then
		if cavebotState[89](startPosition) ~= cavebotState[29] then
			if not var_189_1 then
				if var_189_2 then
					if not cavebotState[31].continuousWalkHasStalled(arg_189_0, startPosition, cavebotState[29], var_189_0) then
						return true
					end
				elseif arg_189_0.isWalking and arg_189_0:isWalking() or var_189_0 - cavebotState[30] < cavebotState[76] then
					return true
				end
			end

			cavebotState[98]()
		end

		cavebotState[28] = false
		cavebotState[29] = nil
	end

	if not var_189_1 and arg_189_0.isAutoWalking and arg_189_0:isAutoWalking() then
		return true
	end

	if not var_189_1 and arg_189_0.isWalking and arg_189_0:isWalking() then
		return true
	end

	cavebotState[28] = false
	cavebotState[29] = nil

	local var_189_3, var_189_4, var_189_5 = cavebotState[187]()

	if var_189_2 then
		var_189_4, var_189_5 = 127, 0
	end

	if not var_189_1 and var_189_5 > var_189_0 - cavebotState[52] then
		return true
	end

	local var_189_6 = cavebotState[149](startPosition, arg_189_2)
	local var_189_7 = cavebotState[31].allowsDestinationFloorChange(arg_189_2)
	local var_189_8 = cavebotState[193](startPosition, var_189_6, var_189_7)
	local var_189_9
	local directions
	local var_189_11

	if var_189_8 then
		var_189_9, directions, var_189_11 = cavebotState[194](startPosition, var_189_8, var_189_4)
	end

	if not var_189_9 and var_189_8 then
		cavebotState[98]()

		var_189_8 = cavebotState[193](startPosition, var_189_6, var_189_7)

		if var_189_8 then
			var_189_9, directions, var_189_11 = cavebotState[194](startPosition, var_189_8, var_189_4)
		end
	end

	if not var_189_9 then
		cavebotState[31].handoff = false

		cavebotState[110](string.format("%s #%d", cavebotState[86]("No path to waypoint", "Sem caminho para waypoint"), cavebotState[3]))

		return true
	end

	cavebotState[52] = var_189_0
	cavebotState[30] = var_189_0

	local var_189_12, var_189_13 = pcall(function()
		return g_game.autoWalk(directions, startPosition)
	end)

	cavebotState[31].handoff = false

	local var_189_14 = var_189_12 and var_189_13 ~= false

	cavebotState[28] = var_189_14
	cavebotState[29] = var_189_14 and cavebotState[89](var_189_9) or nil

	if var_189_14 then
		cavebotState[195](var_189_9, var_189_8, var_189_11)
	else
		cavebotState[98]()
	end

	if var_189_14 and var_189_2 then
		cavebotState[31].noteContinuousWalkProgress(startPosition, cavebotState[29], var_189_0)
		cavebotState[110](string.format("%s #%d - %s", cavebotState[86]("Walking to", "Indo para"), cavebotState[3], cavebotState[107](arg_189_2)))
	elseif var_189_14 then
		cavebotState[110](string.format("%s %s - #%d", cavebotState[86]("Route speed", "Velocidade da rota"), cavebotState[133](var_189_3), cavebotState[3]))
	else
		cavebotState[110](string.format("%s #%d", cavebotState[86]("No path to waypoint", "Sem caminho para waypoint"), cavebotState[3]))
	end

	return true
end

  cavebotState[197] = function(arg_191_0, arg_191_1, arg_191_2)
	if cavebotState[47].mode == "disabled" or cavebotState[47].mode == "continuous" then
		if cavebotState[48] or cavebotState[49] or cavebotState[50] then
			cavebotState[131](false)
		end

		return false
	end

	local var_191_0 = cavebotState[184](arg_191_1)

	if cavebotState[47].mode == "antilost" then
		if #var_191_0 == 0 then
			cavebotState[49] = false

			if cavebotState[50] then
				cavebotState[50] = false
				cavebotState[30] = 0

				cavebotState[25]()

				cavebotState[31].handoff = true
			end

			return false
		end

		if not cavebotState[50] then
			cavebotState[50] = true
			cavebotState[51] = 0

			cavebotState[25]()

			cavebotState[31].handoff = true
		end

		return cavebotState[192](arg_191_0, arg_191_1, arg_191_2, var_191_0)
	end

	cavebotState[50] = false

	local var_191_1 = #var_191_0

	if cavebotState[48] then
		if var_191_1 <= cavebotState[47].resumeAt then
			cavebotState[48] = false
			cavebotState[49] = false
			cavebotState[52] = 0

			cavebotState[110](string.format("%s: %d", cavebotState[86]("Luring resumed", "Luring retomado"), var_191_1))
		else
			cavebotState[25]()
			cavebotState[110](string.format("%s: %d/%d", cavebotState[86]("Luring stopped", "Luring parado"), var_191_1, cavebotState[47].resumeAt))

			return true
		end
	elseif var_191_1 >= cavebotState[47].stopAt then
		cavebotState[48] = true
		cavebotState[52] = 0

		cavebotState[25]()
		cavebotState[110](string.format("%s: %d/%d", cavebotState[86]("Luring stopped", "Luring parado"), var_191_1, cavebotState[47].stopAt))

		return true
	end

	return false
end

  cavebotState[198] = function(arg_192_0, arg_192_1)
	if arg_192_1.kind ~= "box" then
		cavebotState[54] = nil

		return false
	end

	if cavebotState[47].mode == "continuous" then
		cavebotState[54] = nil

		return false
	end

	local var_192_0 = #cavebotState[184](arg_192_0)

	if cavebotState[54] == arg_192_1 then
		if var_192_0 <= cavebotState[47].resumeAt then
			cavebotState[54] = nil

			return false
		end
	elseif var_192_0 < cavebotState[47].stopAt then
		return false
	else
		cavebotState[54] = arg_192_1

		cavebotState[25]()
	end

	cavebotState[110](string.format("%s #%d: %d/%d", cavebotState[86]("Box", "Box"), cavebotState[3], var_192_0, cavebotState[47].resumeAt))

	return true
end

  cavebotState[199] = function(arg_193_0, arg_193_1, arg_193_2)
	local var_193_0 = cavebotState[149](arg_193_1, arg_193_2)
	local var_193_1 = cavebotState[89](var_193_0)
	local var_193_2 = cavebotState[31].handoff == true
	local var_193_3 = cavebotState[87]()

	if arg_193_0.isAutoWalking and arg_193_0:isAutoWalking() and not var_193_2 then
		if not cavebotState[28] then
			cavebotState[31].resetContinuousWalkProgress()

			return
		end

		if cavebotState[29] == var_193_1 then
			if not cavebotState[31].continuousWalkHasStalled(arg_193_0, arg_193_1, var_193_1, var_193_3) then
				return
			end

			cavebotState[25]()

			cavebotState[30] = 0
			cavebotState[31].handoff = true

			return
		end

		cavebotState[25]()

		cavebotState[30] = 0
	end

	if not var_193_2 and arg_193_0.isWalking and arg_193_0:isWalking() then
		return
	end

	if not var_193_2 and var_193_3 - cavebotState[30] < cavebotState[59] then
		return
	end

	cavebotState[30] = var_193_3

	local var_193_4 = cavebotState[31].allowsDestinationFloorChange(arg_193_2)

	cavebotState[31].ensureWalkPermission(arg_193_1, var_193_0, var_193_4)

	local var_193_5, var_193_6 = pcall(function()
		return arg_193_0:cavebotAutoWalk(var_193_0, true, cavebotState[31].allowsNonPathableWalk(), true, var_193_4, cavebotState[31].blockedPathPositions(), false)
	end)

	cavebotState[31].handoff = false

	if var_193_5 and var_193_6 ~= false then
		cavebotState[28] = true
		cavebotState[29] = var_193_1

		cavebotState[31].noteContinuousWalkProgress(arg_193_1, var_193_1, var_193_3)
		cavebotState[110](string.format("%s #%d - %s", cavebotState[86]("Walking to", "Indo para"), cavebotState[3], cavebotState[107](arg_193_2)))
	else
		cavebotState[28] = false
		cavebotState[29] = nil

		cavebotState[31].resetContinuousWalkProgress()
		cavebotState[110](string.format("%s #%d", cavebotState[86]("No path to waypoint", "Sem caminho para waypoint"), cavebotState[3]))
	end
end

  cavebotState[200] = function(arg_195_0, arg_195_1, arg_195_2)
	if HelperCavebot.diagonalWalk then
		return cavebotState[196](arg_195_0, arg_195_1, arg_195_2)
	end

	if cavebotState[47].mode == "antilost" and not cavebotState[50] then
		return cavebotState[199](arg_195_0, arg_195_1, arg_195_2)
	end

	if cavebotState[186]() then
		return cavebotState[196](arg_195_0, arg_195_1, arg_195_2)
	end

	return cavebotState[199](arg_195_0, arg_195_1, arg_195_2)
end

 cavebotState[32].movedAfterUse = function(arg_196_0, arg_196_1)
	return cavebotState[32].waypoint == arg_196_1 and cavebotState[32].usedAt > 0 and cavebotState[32].usedFrom ~= nil and cavebotState[32].usedFrom ~= cavebotState[89](arg_196_0)
end

 cavebotState[32].handle = function(arg_197_0, waypoint)
	local tilePosition = waypoint and waypoint.usePosition

	if not tilePosition then
		return false
	end

	local var_197_1 = cavebotState[89](waypoint.position) == cavebotState[89](tilePosition) and 0 or 1
	local var_197_2 = cavebotState[144](arg_197_0, waypoint.position) == 0
	local var_197_3 = arg_197_0.z == waypoint.position.z and var_197_1 >= cavebotState[144](arg_197_0, tilePosition)

	if not var_197_2 and not var_197_3 then
		return false
	end

	cavebotState[25]()

	local var_197_4 = cavebotState[87]()

	if cavebotState[32].waypoint ~= waypoint then
		cavebotState[32].resetRuntime()

		cavebotState[32].waypoint = waypoint
		cavebotState[32].reachedAt = var_197_4
	end

	local tile = g_map.getTile(tilePosition)

	if not tile then
		if var_197_4 - cavebotState[32].reachedAt >= cavebotState[32].giveUpDelay then
			cavebotState[180](cavebotState[86]("Recorded object is not here", "Objeto gravado nao esta aqui"))
		else
			cavebotState[110](cavebotState[86]("Waiting for the object tile", "Aguardando o tile do objeto"))
		end

		return true
	end

	local var_197_6 = tile:isWalkable(true)

	if cavebotState[32].blockedOnArrival == nil then
		cavebotState[32].blockedOnArrival = not var_197_6
	end

	local var_197_7 = cavebotState[32].findTileItem(tile, waypoint.itemId)

	if not var_197_7 then
		local var_197_8

		if cavebotState[32].usedAt > 0 then
			var_197_8 = cavebotState[86]("Use completed", "Use concluido")
		elseif var_197_6 then
			var_197_8 = cavebotState[86]("Passage is already open", "Passagem ja esta aberta")
		else
			var_197_8 = cavebotState[86]("Recorded object is not here", "Objeto gravado nao esta aqui")
		end

		cavebotState[180](var_197_8)

		return true
	end

	if var_197_6 and cavebotState[32].blockedOnArrival and not waypoint.transition then
		cavebotState[180](cavebotState[86]("Door is open", "Porta esta aberta"))

		return true
	end

	local item = waypoint.withItemId and cavebotState[32].findTool(waypoint.withItemId)

	if cavebotState[32].usedAt > 0 and var_197_4 - cavebotState[32].usedAt >= cavebotState[32].giveUpDelay and not waypoint.transition and not cavebotState[32].blockedOnArrival then
		cavebotState[180](cavebotState[86]("Object did not react to the use", "Objeto nao respondeu ao use"))

		return true
	end

	if cavebotState[32].lastAttemptAt == 0 or var_197_4 - cavebotState[32].lastAttemptAt >= cavebotState[32].retryInterval then
		cavebotState[32].lastAttemptAt = var_197_4

		if cavebotState[32].usedAt == 0 then
			cavebotState[32].usedAt = var_197_4
		end

		cavebotState[32].usedFrom = cavebotState[89](arg_197_0)

		if not waypoint.withItemId then
			g_game.use(var_197_7)
		elseif item then
			g_game.useWith(item, var_197_7)
		else
			g_game.useInventoryItemWith(waypoint.withItemId, var_197_7)
		end
	end

	if waypoint.withItemId and not item then
		cavebotState[110](cavebotState[86]("Item not in an open container - trying anyway", "Item fora dos containers abertos - tentando mesmo assim"))
	elseif cavebotState[32].usedAt > 0 and var_197_4 - cavebotState[32].usedAt >= cavebotState[60] then
		cavebotState[110](cavebotState[86]("Object used, but nothing changed yet", "Objeto usado, mas nada mudou ainda"))
	else
		cavebotState[110](waypoint.withItemId and cavebotState[86]("Using the item here", "Usando o item aqui") or cavebotState[32].blockedOnArrival and cavebotState[86]("Opening door", "Abrindo porta") or cavebotState[86]("Using object", "Usando objeto"))
	end

	return true
end

  cavebotState[201] = function()
	local var_198_0, var_198_1 = pcall(cavebotState[6])

	if not var_198_0 and g_logger then
		g_logger.error("[helper_cavebot] " .. tostring(var_198_1))
	end
end

  cavebotState[202] = function()
	if cavebotState[5] then
		return
	end

	cavebotState[5] = scheduleEvent(function()
		cavebotState[5] = nil

		cavebotState[201]()
	end, 0)
end

 cavebotState[57].closeWindow = function()
	local var_201_0 = cavebotState[57].window

	cavebotState[57].window = nil
	cavebotState[57].pendingEnabled = cavebotState[57].enabled
	HelperCavebot.pendingStartAtNearestWaypoint = HelperCavebot.startAtNearestWaypoint
	HelperCavebot.pendingDiagonalWalk = HelperCavebot.diagonalWalk

	if not var_201_0 or var_201_0:isDestroyed() then
		return
	end

	if g_modalManager and g_modalManager.isModal and g_modalManager.isModal(var_201_0) then
		g_modalManager.hide(var_201_0)
	end

	var_201_0:destroy()
end

 cavebotState[57].refreshModeCombo = function()
	local var_202_0 = cavebotState[57].window

	if not var_202_0 or var_202_0:isDestroyed() then
		return false
	end

	local cavebotEchoRaidModeCombo = var_202_0:recursiveGetChildById("cavebotEchoRaidModeCombo")

	if not cavebotEchoRaidModeCombo or not cavebotEchoRaidModeCombo.clearOptions or not cavebotEchoRaidModeCombo.addOption then
		return false
	end

	local pendingEnabled = cavebotState[57].pendingEnabled

	cavebotEchoRaidModeCombo:clearOptions()
	cavebotEchoRaidModeCombo:addOption(cavebotState[86]("Step on Echo Raid", "Pisar na Echo Raid"), "step")
	cavebotEchoRaidModeCombo:addOption(cavebotState[86]("Avoid Echo Raid", "Evitar a Echo Raid"), "avoid")

	local var_202_3 = pendingEnabled and "step" or "avoid"

	if cavebotEchoRaidModeCombo.setCurrentOptionByData then
		cavebotEchoRaidModeCombo:setCurrentOptionByData(var_202_3, true)
	else
		cavebotEchoRaidModeCombo:setCurrentOption(pendingEnabled and cavebotState[86]("Step on Echo Raid", "Pisar na Echo Raid") or cavebotState[86]("Avoid Echo Raid", "Evitar a Echo Raid"), true)
	end

	cavebotState[57].pendingEnabled = pendingEnabled

	return true
end

 cavebotState[57].openWindow = function()
	if cavebotState[57].window and not cavebotState[57].window:isDestroyed() then
		cavebotState[57].window:show()
		cavebotState[57].window:raise()
		cavebotState[57].window:focus()

		return true
	end

	local var_203_0, window = pcall(g_ui.createWidget, "CavebotEchoRaidWindow", g_ui.getRootWidget())

	if not var_203_0 or not window then
		if g_logger and g_logger.error then
			g_logger.error("[helper_cavebot] Could not create Echo Raid settings window: " .. tostring(window))
		end

		return false
	end

	cavebotState[57].window = window
	cavebotState[57].pendingEnabled = cavebotState[57].enabled
	HelperCavebot.pendingStartAtNearestWaypoint = HelperCavebot.startAtNearestWaypoint
	HelperCavebot.pendingDiagonalWalk = HelperCavebot.diagonalWalk

	if cavebotState[0] and cavebotState[0].applyWidgetLanguage then
		cavebotState[0].applyWidgetLanguage(window)
	end

	local cavebotStartNearestWaypointCheckBox = window:recursiveGetChildById("cavebotStartNearestWaypointCheckBox")
	local cavebotRecordDistanceScrollBar = window:recursiveGetChildById("cavebotRecordDistanceScrollBar")
	local cavebotRecordDistanceValueLabel = window:recursiveGetChildById("cavebotRecordDistanceValueLabel")

	if not cavebotStartNearestWaypointCheckBox or not cavebotRecordDistanceScrollBar or not cavebotRecordDistanceValueLabel then
		cavebotState[57].closeWindow()

		return false
	end

	local function var_203_5(arg_204_0)
		cavebotRecordDistanceValueLabel:setText(string.format("%d %s", math.floor(tonumber(arg_204_0) or cavebotState[62]), cavebotState[86]("tiles", "SQMs")))
	end

	cavebotRecordDistanceScrollBar:setRange(1, 50)
	cavebotRecordDistanceScrollBar:setStep(1)
	cavebotRecordDistanceScrollBar:setMouseScroll(true)

	function cavebotRecordDistanceScrollBar.onValueChange(unusedArgument, arg_205_1)
		var_203_5(arg_205_1)
	end

	cavebotStartNearestWaypointCheckBox:setChecked(HelperCavebot.pendingStartAtNearestWaypoint)

	local cavebotDiagonalWalkCheckBox = window:recursiveGetChildById("cavebotDiagonalWalkCheckBox")

	if cavebotDiagonalWalkCheckBox then
		cavebotDiagonalWalkCheckBox:setChecked(HelperCavebot.pendingDiagonalWalk)
	end

	cavebotRecordDistanceScrollBar:setValue(cavebotState[62])
	var_203_5(cavebotState[62])

	if not cavebotState[57].refreshModeCombo() then
		cavebotState[57].closeWindow()

		return false
	end

	local var_203_7 = window

	if g_modalManager and g_modalManager.show then
		g_modalManager.show(var_203_7, {
			tabs = false,
			onClose = function()
				if cavebotState[57].window == var_203_7 then
					cavebotState[57].window = nil
					cavebotState[57].pendingEnabled = cavebotState[57].enabled
					HelperCavebot.pendingStartAtNearestWaypoint = HelperCavebot.startAtNearestWaypoint
					HelperCavebot.pendingDiagonalWalk = HelperCavebot.diagonalWalk
				end

				if var_203_7 and not var_203_7:isDestroyed() then
					var_203_7:destroy()
				end
			end
		})
	else
		var_203_7:show()
		var_203_7:raise()
		var_203_7:focus()
	end

	return true
end

 cavebotState[57].confirmWindow = function()
	if not cavebotState[57].window or cavebotState[57].window:isDestroyed() then
		return false
	end

	local enabled = cavebotState[57].pendingEnabled == true
	local var_207_1 = HelperCavebot.pendingStartAtNearestWaypoint == true
	local var_207_2 = HelperCavebot.pendingDiagonalWalk == true
	local var_207_3 = HelperCavebot.diagonalWalk ~= var_207_2
	local cavebotRecordDistanceScrollBar = cavebotState[57].window:recursiveGetChildById("cavebotRecordDistanceScrollBar")
	local value = math.max(1, math.min(50, math.floor(tonumber(cavebotRecordDistanceScrollBar and cavebotRecordDistanceScrollBar:getValue()) or cavebotState[62])))
	local var_207_6 = cavebotState[57].enabled ~= enabled or HelperCavebot.startAtNearestWaypoint ~= var_207_1 or var_207_3 or cavebotState[62] ~= value

	cavebotState[57].closeWindow()

	cavebotState[57].enabled = enabled
	HelperCavebot.startAtNearestWaypoint = var_207_1
	HelperCavebot.pendingStartAtNearestWaypoint = var_207_1
	HelperCavebot.diagonalWalk = var_207_2
	HelperCavebot.pendingDiagonalWalk = var_207_2
	cavebotState[62] = value

	if var_207_3 then
		cavebotState[25]()

		cavebotState[30] = 0
		cavebotState[52] = 0
	end

	cavebotState[57].reset(not enabled)
	cavebotState[57].refreshButton()

	if enabled or var_207_3 then
		cavebotState[202]()
	end

	if var_207_6 then
		cavebotState[130]()
	end

	return true
end

 cavebotState[6] = function()
	if HelperActionCoordinator and HelperActionCoordinator.isAutomaticActionBlocked and HelperActionCoordinator.isAutomaticActionBlocked() then
		return
	end

	if not g_game.isOnline() then
		cavebotState[126](false)

		cavebotState[28] = false
		cavebotState[29] = nil
		cavebotState[31].handoff = false

		cavebotState[110](cavebotState[86]("Offline", "Offline"))

		return
	end

	if cavebotState[33] then
		cavebotState[126](false)
		cavebotState[25]()

		return
	end

	if not cavebotState[128]() then
		cavebotState[126](false)
		cavebotState[25]()
		cavebotState[110](cavebotState[86]("Cavebot disabled", "Cavebot desativado"))

		return
	end

	if not cavebotState[129]() then
		cavebotState[126](false)
		cavebotState[25]()
		cavebotState[110](cavebotState[86]("Paused - Helper disabled", "Pausado - Helper desativado"))

		return
	end

	if #cavebotState[1] == 0 then
		cavebotState[126](false)
		cavebotState[25]()
		cavebotState[110](cavebotState[86]("Add a waypoint to start", "Adicione um waypoint para iniciar"))

		return
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		cavebotState[126](false)

		return
	end

	local position = localPlayer:getPosition()

	if cavebotState[31].selectStart then
		local var_208_2

		if HelperCavebot.startAtNearestWaypoint then
			var_208_2 = cavebotState[31].alignCurrentWaypointToNearest(position)
		else
			var_208_2 = cavebotState[181](position.z)
		end

		if not var_208_2 then
			cavebotState[126](false)
			cavebotState[25]()
			cavebotState[110](string.format("%s %d", cavebotState[86]("No waypoint on floor", "Sem waypoint no andar"), position.z))

			return
		end

		cavebotState[31].selectStart = false
	end

	if not cavebotState[126](true) then
		cavebotState[127]()

		return
	end

	if cavebotState[57].handleBeforeRoute(localPlayer, position) then
		return
	end

	local var_208_3 = cavebotState[143]()

	if not var_208_3 then
		return
	end

	if cavebotState[47].mode == "disabled" and not HelperCavebot.hasBoxWaypoint() and HelperTarget and HelperTarget.shouldHoldCavebotMovement and HelperTarget.shouldHoldCavebotMovement() then
		cavebotState[25]()

		cavebotState[30] = 0
		cavebotState[52] = 0

		cavebotState[110](cavebotState[86]("Paused - Target active", "Pausado - Target ativo"))

		return
	end

	if cavebotState[54] and cavebotState[54] ~= var_208_3 then
		cavebotState[54] = nil
	end

	local var_208_4 = cavebotState[144](position, var_208_3.position)

	if var_208_3.kind == "use" then
		cavebotState[31].reachedAt = nil

		if cavebotState[32].movedAfterUse(position, var_208_3) then
			cavebotState[180](cavebotState[86]("Use completed", "Use concluido"))
			cavebotState[202]()

			return
		end

		if cavebotState[32].handle(position, var_208_3) then
			return
		end

		cavebotState[200](localPlayer, position, var_208_3)

		return
	end

	if cavebotState[108](var_208_3.kind) then
		cavebotState[31].reachedAt = nil

		if HelperCavebot.hasReachedWaypoint(position, var_208_3) then
			if cavebotState[198](position, var_208_3) then
				return
			end

			local var_208_5 = var_208_3.kind == "box"

			cavebotState[180](var_208_5 and cavebotState[86]("Box released", "Box liberado") or cavebotState[86]("Position reached", "Posicao alcancada"))

			local var_208_6 = cavebotState[143]()

			if not (var_208_6 and cavebotState[108](var_208_6.kind) and HelperCavebot.hasReachedWaypoint(position, var_208_6)) then
				cavebotState[202]()
			end

			return
		end

		if cavebotState[197](localPlayer, position, var_208_3) then
			return
		end

		cavebotState[200](localPlayer, position, var_208_3)

		return
	end

	cavebotState[54] = nil

	if var_208_4 == 0 then
		cavebotState[28] = false
		cavebotState[29] = nil
		cavebotState[31].reachedAt = cavebotState[31].reachedAt or cavebotState[87]()

		if cavebotState[87]() - cavebotState[31].reachedAt >= cavebotState[60] then
			cavebotState[110](cavebotState[86]("Transition reached, but no passage was detected", "Transicao alcancada, mas nenhuma passagem foi detectada"))
		else
			cavebotState[110](cavebotState[86]("Waiting for transition", "Aguardando transicao"))
		end

		return
	end

	cavebotState[31].reachedAt = nil

	cavebotState[199](localPlayer, position, var_208_3)
end

  cavebotState[203] = function(unusedArgument, arg_209_1, arg_209_2)
	if not arg_209_1 then
		return
	end

	cavebotState[170](arg_209_1)
	cavebotState[177](arg_209_1, arg_209_2)

	if not arg_209_2 or not cavebotState[128]() or not cavebotState[129]() then
		return
	end

	if cavebotState[28] and HelperCavebot.diagonalWalk and not cavebotState[186]() and cavebotState[29] == cavebotState[89](arg_209_1) then
		local localPlayer = g_game.getLocalPlayer()

		if not localPlayer or not localPlayer.isPreWalking or not localPlayer:isPreWalking() then
			cavebotState[31].handoff = true

			cavebotState[202]()
		end
	end

	if cavebotState[57].target and cavebotState[144](arg_209_1, cavebotState[57].target) == 0 then
		cavebotState[202]()
	end

	local var_209_1 = cavebotState[143]()

	if var_209_1 and cavebotState[108](var_209_1.kind) and HelperCavebot.hasReachedWaypoint(arg_209_1, var_209_1) then
		cavebotState[202]()
	end

	if var_209_1 and cavebotState[31].isTransitionKind(var_209_1.kind) and arg_209_1.z == var_209_1.position.z and cavebotState[144](arg_209_1, var_209_1.position) == 0 then
		cavebotState[31].reachedAt = cavebotState[87]()
	end

	local var_209_2 = var_209_1 and cavebotState[31].isTransitionKind(var_209_1.kind) and arg_209_2.z == var_209_1.position.z and cavebotState[145](arg_209_2, var_209_1.position) <= cavebotState[61]
	local kind = cavebotState[146](arg_209_2, arg_209_1)
	local var_209_4 = cavebotState[32].waypoint == var_209_1 and cavebotState[32].usedAt > 0

	if kind and var_209_1 and var_209_1.kind == "use" and (var_209_1.transition == true or var_209_4) and arg_209_2.z == var_209_1.position.z and cavebotState[145](arg_209_2, var_209_1.position) <= cavebotState[61] then
		local var_209_5 = var_209_4 and var_209_1.transition ~= true

		if var_209_5 then
			var_209_1.transition = true
		end

		cavebotState[180](cavebotState[86]("Use completed", "Use concluido"))

		if var_209_5 then
			cavebotState[130]()
		end

		cavebotState[202]()

		return
	end

	if kind and var_209_1 and cavebotState[31].isTransitionKind(var_209_1.kind) and (var_209_2 or cavebotState[31].reachedAt) then
		local var_209_6 = var_209_1.kind ~= kind

		var_209_1.kind = kind

		if var_209_6 then
			cavebotState[130]()
		end

		cavebotState[180](kind == "stairs" and cavebotState[86]("Stairs completed", "Escada concluida") or cavebotState[86]("Teleport completed", "Teleporte concluido"))

		if var_209_6 then
			cavebotState[163]()
			cavebotState[158]()
		end

		cavebotState[202]()

		return
	end

	if kind and var_209_1 and cavebotState[108](var_209_1.kind) and arg_209_1.z ~= var_209_1.position.z then
		local var_209_7

		if HelperCavebot.startAtNearestWaypoint then
			var_209_7 = cavebotState[31].alignCurrentWaypointToNearest(arg_209_1)
		else
			var_209_7 = cavebotState[181](arg_209_1.z)
		end

		if var_209_7 then
			cavebotState[25]()

			cavebotState[30] = 0
			cavebotState[52] = 0

			cavebotState[110](cavebotState[86]("Unexpected floor change - route realigned", "Mudanca de andar inesperada - rota realinhada"))
			cavebotState[202]()
		end
	end
end

  cavebotState[204] = function()
	if not cavebotState[28] then
		return
	end

	cavebotState[28] = false
	cavebotState[29] = nil

	cavebotState[31].resetContinuousWalkProgress()

	cavebotState[31].handoff = false

	if cavebotState[186]() then
		cavebotState[30] = 0
		cavebotState[52] = 0
	end

	if cavebotState[57].target then
		cavebotState[30] = 0
		cavebotState[31].handoff = true

		cavebotState[110](cavebotState[86]("No path to Echo Raid", "Sem caminho para Echo Raid"))

		return
	end

	if cavebotState[31].allowHazardCrossing() then
		cavebotState[202]()

		return
	end

	cavebotState[110](string.format("%s #%d", cavebotState[86]("No path to waypoint", "Sem caminho para waypoint"), cavebotState[3]))
end

  cavebotState[205] = function()
	if not cavebotState[28] then
		return
	end

	if cavebotState[57].target then
		cavebotState[28] = false
		cavebotState[29] = nil
		cavebotState[31].handoff = true
		cavebotState[30] = 0
		cavebotState[52] = 0

		return
	end

	if not cavebotState[186]() and not HelperCavebot.diagonalWalk then
		return
	end

	cavebotState[28] = false
	cavebotState[29] = nil
	cavebotState[31].handoff = false
	cavebotState[30] = 0
	cavebotState[52] = 0

	cavebotState[98]()
end

function HelperCavebot.init(arg_212_0)
	cavebotState[0] = arg_212_0

	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.init({
			getWidget = cavebotState[85],
			text = cavebotState[86],
			setStatus = cavebotState[110],
			prepare = function()
				cavebotState[26](false)

				local var_213_0 = cavebotState[85]("enableCavebotCheckBox")

				if var_213_0 and var_213_0:isChecked() then
					var_213_0:setChecked(false)
				else
					cavebotState[25]()
				end
			end,
			hideMarkers = cavebotState[157],
			showMarkers = cavebotState[158],
			applyWaypoints = function(arg_214_0, unusedArgument, arg_214_2)
				local var_214_0 = cavebotState[100](arg_214_0)

				if #var_214_0 < 2 then
					cavebotState[110](cavebotState[86]("The generated route is empty", "A rota gerada esta vazia"))
					cavebotState[158]()

					return false
				end

				local autoRouteDestination = type(arg_214_2) == "table" and arg_214_2.name and HelperCavebot.getAutoRouteDestination(arg_214_2.name)

				if not autoRouteDestination or not table.equal(autoRouteDestination.waypoints, arg_214_2.waypoints) then
					cavebotState[110](cavebotState[86]("The destination route changed. Start a new scan to confirm it again.", "A rota de destino mudou. Inicie outro scan para confirmar novamente."))
					cavebotState[158]()

					return false
				end

				cavebotState[25]()
				cavebotState[57].reset(false)
				cavebotState[26](true)

				cavebotState[38][cavebotState[39]] = cavebotState[105]()
				cavebotState[39] = autoRouteDestination.name
				cavebotState[47] = autoRouteDestination.luring
				cavebotState[1] = var_214_0
				cavebotState[2] = 1
				cavebotState[3] = 1
				cavebotState[30] = 0
				cavebotState[31].selectStart = true
				cavebotState[31].reachedAt = nil

				cavebotState[131](false)

				cavebotState[38][cavebotState[39]] = cavebotState[105]()

				cavebotState[141]()
				cavebotState[135]()
				cavebotState[168]()
				cavebotState[110](string.format(cavebotState[86]("Automatic route applied - %d Position waypoints", "Rota automatica aplicada - %d waypoints Pos"), #cavebotState[1]))
				cavebotState[130]()

				return true
			end
		})
	end

	cavebotState[142]()
	cavebotState[138]()
	cavebotState[179](true)
	cavebotState[174]()

	if not cavebotState[35] then
		connect(g_game, {
			onChangeWorldTime = cavebotState[173]
		})

		cavebotState[35] = true
	end

	if not cavebotState[32].connected then
		connect(g_game, {
			onUse = cavebotState[32].record,
			onUseWith = cavebotState[32].recordWith
		})

		cavebotState[32].connected = true
	end

	if not cavebotState[27] then
		connect(LocalPlayer, {
			onPositionChange = cavebotState[203],
			onAutoWalkFail = cavebotState[204],
			onCancelWalk = cavebotState[205]
		})

		cavebotState[27] = true
	end

	if not cavebotState[4] then
		tagHitchEventSource("game_helper.cavebot.runTickSafely")

		cavebotState[4] = cycleEvent(cavebotState[201], cavebotState[58])
	end

	if not cavebotState[36] then
		cavebotState[36] = cycleEvent(cavebotState[174], 1000)
	end
end

function HelperCavebot.onShow()
	cavebotState[142]()
	cavebotState[138]()
	cavebotState[179](true)
	cavebotState[174]()
	cavebotState[168]()
end

function HelperCavebot.refreshLanguage()
	cavebotState[135]()
	cavebotState[161]()
	cavebotState[163]()
	cavebotState[125]()

	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.refreshButton()
	end

	if cavebotState[45] and not cavebotState[45]:isDestroyed() and cavebotState[0] and cavebotState[0].applyWidgetLanguage then
		cavebotState[0].applyWidgetLanguage(cavebotState[45])
	end

	if cavebotState[57].window and not cavebotState[57].window:isDestroyed() and cavebotState[0] and cavebotState[0].applyWidgetLanguage then
		cavebotState[0].applyWidgetLanguage(cavebotState[57].window)
		cavebotState[57].refreshModeCombo()
	end

	cavebotState[57].refreshButton()
end

function HelperCavebot.onHide()
	if cavebotState[41] and not cavebotState[41]:isDestroyed() then
		cavebotState[41]:destroy()
	end

	cavebotState[41] = nil

	if cavebotState[42] and not cavebotState[42]:isDestroyed() then
		cavebotState[42]:destroy()
	end

	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.cancel(false)
	end
end

function HelperCavebot.terminate()
	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.terminate()
	end

	cavebotState[126](false)
	cavebotState[25]()
	cavebotState[57].reset(false)

	if cavebotState[53] then
		removeEvent(cavebotState[53])

		cavebotState[53] = nil
	end

	cavebotState[26](true)
	cavebotState[111]()
	cavebotState[57].closeWindow()

	if cavebotState[4] then
		removeEvent(cavebotState[4])

		cavebotState[4] = nil
	end

	if cavebotState[5] then
		removeEvent(cavebotState[5])

		cavebotState[5] = nil
	end

	if cavebotState[36] then
		removeEvent(cavebotState[36])

		cavebotState[36] = nil
	end

	if cavebotState[35] then
		disconnect(g_game, {
			onChangeWorldTime = cavebotState[173]
		})

		cavebotState[35] = false
	end

	if cavebotState[32].connected then
		disconnect(g_game, {
			onUse = cavebotState[32].record,
			onUseWith = cavebotState[32].recordWith
		})

		cavebotState[32].connected = false
	end

	if cavebotState[27] then
		disconnect(LocalPlayer, {
			onPositionChange = cavebotState[203],
			onAutoWalkFail = cavebotState[204],
			onCancelWalk = cavebotState[205]
		})

		cavebotState[27] = false
	end

	cavebotState[157]()

	HelperCavebot.externalMapPreview = nil

	if cavebotState[41] and not cavebotState[41]:isDestroyed() then
		cavebotState[41]:destroy()
	end

	if cavebotState[42] and not cavebotState[42]:isDestroyed() then
		cavebotState[42]:destroy()
	end

	if cavebotState[44] and not cavebotState[44]:isDestroyed() then
		cavebotState[44]:destroy()
	end

	cavebotState[41] = nil
	cavebotState[42] = nil
	cavebotState[44] = nil
	cavebotState[1] = {}
	cavebotState[8] = {}
	cavebotState[38] = {}
	cavebotState[39] = cavebotState[63]
	cavebotState[40] = false
	cavebotState[46] = false
	cavebotState[47] = cavebotState[102](nil)
	cavebotState[57].enabled = true
	cavebotState[57].pendingEnabled = true
	HelperCavebot.startAtNearestWaypoint = false
	HelperCavebot.pendingStartAtNearestWaypoint = false
	HelperCavebot.diagonalWalk = false
	HelperCavebot.pendingDiagonalWalk = false
	cavebotState[62] = 5

	cavebotState[131](false)

	cavebotState[2] = nil
	cavebotState[3] = 1
	cavebotState[37] = nil
	cavebotState[11] = 0
	cavebotState[12] = 0
	cavebotState[13] = 0
	cavebotState[14] = 0
	cavebotState[15] = false
	cavebotState[16] = false
	cavebotState[17] = 0
	cavebotState[18] = false
	cavebotState[0] = nil
end

function HelperCavebot.openRenewWindow()
	if not cavebotState[112]() or not cavebotState[120]() then
		return false
	end

	if cavebotState[45] and not cavebotState[45]:isDestroyed() then
		cavebotState[123](cavebotState[45]:getChildById("cavebotRenewModalPrice"), cavebotState[17])

		local cavebotRenewDescriptionLabel = cavebotState[45]:getChildById("cavebotRenewDescriptionLabel")

		if cavebotRenewDescriptionLabel then
			cavebotRenewDescriptionLabel:setText(cavebotState[86](string.format("Renew 1 hour for %s gold?", comma_value(cavebotState[17])), string.format("Renovar 1 hora por %s gold?", comma_value(cavebotState[17]))))
		end

		cavebotState[45]:show()
		cavebotState[45]:raise()
		cavebotState[45]:focus()

		return true
	end

	cavebotState[45] = g_ui.loadUI("cavebot_renew", g_ui.getRootWidget())

	if not cavebotState[45] then
		return false
	end

	if cavebotState[0] and cavebotState[0].applyWidgetLanguage then
		cavebotState[0].applyWidgetLanguage(cavebotState[45])
	end

	local cavebotRenewDescriptionLabel = cavebotState[45]:getChildById("cavebotRenewDescriptionLabel")

	if cavebotRenewDescriptionLabel then
		cavebotRenewDescriptionLabel:setText(cavebotState[86](string.format("Renew 1 hour for %s gold?", comma_value(cavebotState[17])), string.format("Renovar 1 hora por %s gold?", comma_value(cavebotState[17]))))
	end

	cavebotState[123](cavebotState[45]:getChildById("cavebotRenewModalPrice"), cavebotState[17])

	local var_219_2 = cavebotState[45]

	if g_modalManager and g_modalManager.show then
		g_modalManager.show(var_219_2, {
			tabs = false,
			onClose = function()
				if cavebotState[45] == var_219_2 then
					cavebotState[45] = nil
				end

				if var_219_2 and not var_219_2:isDestroyed() then
					var_219_2:destroy()
				end
			end
		})
	else
		var_219_2:show()
		var_219_2:raise()
		var_219_2:focus()
	end

	return true
end

function HelperCavebot.closeRenewWindow()
	cavebotState[111]()
end

function HelperCavebot.confirmRenewWindow()
	if not cavebotState[112]() or not cavebotState[120]() then
		cavebotState[111]()

		return
	end

	if g_game and g_game.sendCavebotRenew then
		g_game.sendCavebotRenew()
	end

	cavebotState[111]()
end

function HelperCavebot.openEchoRaidWindow()
	return cavebotState[57].openWindow()
end

function HelperCavebot.closeEchoRaidWindow()
	cavebotState[57].closeWindow()
end

function HelperCavebot.confirmEchoRaidWindow()
	return cavebotState[57].confirmWindow()
end

function HelperCavebot.onEchoRaidModeChange(arg_226_0)
	if not arg_226_0 or not cavebotState[57].window or cavebotState[57].window:isDestroyed() or not arg_226_0.getCurrentOption then
		return
	end

	local currentOption = arg_226_0:getCurrentOption()
	local var_226_1 = type(currentOption) == "table" and (currentOption.data or currentOption.text) or currentOption

	cavebotState[57].pendingEnabled = var_226_1 ~= "avoid"
end

function HelperCavebot.onStartNearestWaypointChange(unusedArgument, arg_227_1)
	if not cavebotState[57].window or cavebotState[57].window:isDestroyed() then
		return
	end

	HelperCavebot.pendingStartAtNearestWaypoint = arg_227_1 == true
end

function HelperCavebot.onDiagonalWalkChange(unusedArgument, arg_228_1)
	if not cavebotState[57].window or cavebotState[57].window:isDestroyed() then
		return
	end

	HelperCavebot.pendingDiagonalWalk = arg_228_1 == true
end

function HelperCavebot.onHelperEnableChange(arg_229_0)
	if not arg_229_0 then
		cavebotState[126](false)
		cavebotState[25]()
		cavebotState[57].reset(false)
	end

	if not HelperCavebot.startAtNearestWaypoint then
		return
	end

	cavebotState[31].selectStart = true
	cavebotState[31].reachedAt = nil
	cavebotState[30] = 0
	cavebotState[52] = 0

	cavebotState[131](false)

	if arg_229_0 and cavebotState[128]() then
		cavebotState[160]()
		cavebotState[202]()
	end
end

function HelperCavebot.collectConfig(arg_230_0)
	arg_230_0.cavebot = {
		enabled = cavebotState[10] or cavebotState[128](),
		echoRaid = cavebotState[57].enabled,
		startAtNearestWaypoint = HelperCavebot.startAtNearestWaypoint,
		diagonalWalk = HelperCavebot.diagonalWalk,
		recordStepDistance = cavebotState[62],
		waypoints = cavebotState[100](cavebotState[1]),
		luring = cavebotState[102](cavebotState[47]),
		activePreset = cavebotState[39],
		presets = cavebotState[104](cavebotState[38])
	}
end

function HelperCavebot.loadFromConfig(arg_231_0)
	local var_231_0 = type(arg_231_0.cavebot) == "table" and arg_231_0.cavebot or {}

	if HelperCavebotAutoRoute then
		HelperCavebotAutoRoute.cancel(false)
	end

	if cavebotState[41] and not cavebotState[41]:isDestroyed() then
		cavebotState[41]:destroy()
	end

	cavebotState[41] = nil

	if cavebotState[42] and not cavebotState[42]:isDestroyed() then
		cavebotState[42]:destroy()
	end

	cavebotState[57].closeWindow()
	cavebotState[25]()
	cavebotState[57].reset(false)
	cavebotState[26](true)

	cavebotState[9] = true
	cavebotState[38] = cavebotState[104](var_231_0.presets)
	cavebotState[39] = cavebotState[101](var_231_0.activePreset)

	if cavebotState[39] == "" or not cavebotState[38][cavebotState[39]] then
		cavebotState[39] = cavebotState[63]
	end

	local var_231_1 = cavebotState[38][cavebotState[39]]

	if type(var_231_0.waypoints) == "table" then
		cavebotState[1] = cavebotState[100](var_231_0.waypoints)
	else
		cavebotState[1] = cavebotState[100](var_231_1 and var_231_1.waypoints)
	end

	cavebotState[47] = cavebotState[102](type(var_231_0.luring) == "table" and var_231_0.luring or var_231_1 and var_231_1.luring)

	if not cavebotState[38][cavebotState[63]] then
		cavebotState[38][cavebotState[63]] = cavebotState[105]()
	end

	if not cavebotState[38][cavebotState[39]] then
		cavebotState[39] = cavebotState[63]
	end

	cavebotState[38][cavebotState[39]] = cavebotState[105]()
	cavebotState[2] = nil
	cavebotState[3] = 1
	cavebotState[30] = 0
	cavebotState[31].selectStart = true
	cavebotState[31].reachedAt = nil

	cavebotState[131](false)

	cavebotState[10] = var_231_0.enabled == true

	local var_231_2 = cavebotState[85]("enableCavebotCheckBox")

	if var_231_2 then
		var_231_2:setChecked(cavebotState[10] and cavebotState[112]() and cavebotState[119]())
	end

	cavebotState[57].enabled = var_231_0.echoRaid == nil or var_231_0.echoRaid == true
	HelperCavebot.startAtNearestWaypoint = var_231_0.startAtNearestWaypoint == true
	HelperCavebot.pendingStartAtNearestWaypoint = HelperCavebot.startAtNearestWaypoint
	HelperCavebot.diagonalWalk = var_231_0.diagonalWalk == true
	HelperCavebot.pendingDiagonalWalk = HelperCavebot.diagonalWalk
	cavebotState[62] = math.max(1, math.min(50, math.floor(tonumber(var_231_0.recordStepDistance) or 5)))

	if cavebotState[128]() then
		cavebotState[160]()
	end

	cavebotState[9] = false

	cavebotState[142]()
	cavebotState[138]()
	cavebotState[179](true)
	cavebotState[168]()
end

function HelperCavebot.onAuthorized(arg_232_0, arg_232_1, arg_232_2)
	cavebotState[121](arg_232_0, arg_232_1, arg_232_2, false)

	cavebotState[9] = true

	local var_232_0 = cavebotState[85]("enableCavebotCheckBox")

	if var_232_0 then
		var_232_0:setChecked(cavebotState[10] and cavebotState[119]())
	end

	if cavebotState[128]() then
		cavebotState[160]()
	end

	cavebotState[9] = false

	cavebotState[168]()
end

function HelperCavebot.onStatus(arg_233_0, numericValue, arg_233_2, arg_233_3)
	numericValue = tonumber(numericValue) or cavebotState[21]

	cavebotState[121](arg_233_0, arg_233_2, arg_233_3, numericValue == cavebotState[22])

	if numericValue == cavebotState[22] then
		cavebotState[110](cavebotState[86]("Cavebot time renewed", "Tempo do cavebot renovado"))
	elseif numericValue == cavebotState[23] then
		cavebotState[110](string.format(cavebotState[86]("Need %s gold (inventory or bank)", "Precisa de %s gold (inventario ou banco)"), comma_value(cavebotState[17])))
	elseif numericValue == cavebotState[24] then
		cavebotState[110](cavebotState[86]("Cavebot denied by the server", "Cavebot negado pelo servidor"))
		cavebotState[127]()
	end

	if not cavebotState[119]() then
		cavebotState[127]()
	end

	cavebotState[125]()
end

function HelperCavebot.disableForSessionBoundary()
	cavebotState[10] = false

	local var_234_0 = cavebotState[85]("enableCavebotCheckBox")

	if var_234_0 and var_234_0:isChecked() then
		local var_234_1 = cavebotState[9]

		cavebotState[9] = true

		var_234_0:setChecked(false)

		cavebotState[9] = var_234_1
	end

	cavebotState[126](false)
	cavebotState[25]()
	cavebotState[57].reset(false)

	cavebotState[31].selectStart = true
	cavebotState[31].reachedAt = nil
	cavebotState[31].handoff = false
end

function HelperCavebot.onGameStart()
	HelperCavebot.disableForSessionBoundary()
	cavebotState[168]()
end

function HelperCavebot.onLogout()
	HelperCavebot.onHide()
	HelperCavebot.disableForSessionBoundary()
	cavebotState[32].resetRuntime()
end

function HelperCavebot.onEnableChange(unusedArgument, arg_237_1)
	if cavebotState[9] or cavebotState[0] and cavebotState[0].isLoadingConfig and cavebotState[0].isLoadingConfig() then
		return
	end

	if arg_237_1 and (not cavebotState[112]() or not cavebotState[119]()) then
		local var_237_0 = cavebotState[85]("enableCavebotCheckBox")

		if var_237_0 then
			var_237_0:setChecked(false)
		end

		if arg_237_1 and cavebotState[112]() and not cavebotState[119]() then
			cavebotState[110](cavebotState[86]("Buy cavebot time to enable", "Compre tempo de cavebot para ativar"))
		end

		return
	end

	cavebotState[10] = arg_237_1 == true

	if arg_237_1 then
		cavebotState[26](false)
	end

	if not cavebotState[1][cavebotState[3]] then
		cavebotState[3] = 1
	end

	if arg_237_1 then
		cavebotState[160]()
	end

	cavebotState[30] = 0

	if arg_237_1 then
		cavebotState[31].selectStart = true
	end

	cavebotState[31].reachedAt = nil

	cavebotState[131](false)

	if not arg_237_1 then
		cavebotState[126](false)
		cavebotState[25]()
		cavebotState[57].reset(false)
	end

	cavebotState[168]()
	cavebotState[130]()
end

function HelperCavebot.toggleRecording()
	if cavebotState[33] then
		return cavebotState[26](false)
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		cavebotState[110](cavebotState[86]("Player is offline", "Jogador esta offline"))

		return false
	end

	local var_238_1 = cavebotState[85]("enableCavebotCheckBox")

	if var_238_1 and var_238_1:isChecked() then
		var_238_1:setChecked(false)
	end

	local position = cavebotState[88](localPlayer:getPosition())

	if not position then
		cavebotState[110](cavebotState[86]("Invalid player position", "Posicao do jogador invalida"))

		return false
	end

	cavebotState[33] = true
	cavebotState[34] = cavebotState[88](position)

	cavebotState[32].resetRecording()
	cavebotState[176]("position", position)
	cavebotState[161]()
	cavebotState[110](cavebotState[86](string.format("Recording every %d tiles and object uses", cavebotState[62]), string.format("Gravando a cada %d SQMs e uses de objetos", cavebotState[62])))

	return true
end

 cavebotState[43] = function(arg_239_0, arg_239_1, arg_239_2)
	if not UIInputBox or not UIInputBox.create then
		cavebotState[110](cavebotState[86]("Route name input is unavailable", "Campo de nome da rota indisponivel"))

		return false
	end

	if cavebotState[42] and not cavebotState[42]:isDestroyed() then
		cavebotState[42]:destroy()
	end

	local unusedValue
	local handleEnter = UIInputBox.create(arg_239_0, function(arg_240_0)
		arg_239_1(cavebotState[101](arg_240_0))
	end, function()
		cavebotState[42] = nil
	end)

	cavebotState[42] = handleEnter

	local var_239_2 = handleEnter:addLabel(cavebotState[86]("Route name:", "Nome da rota:"))
	local var_239_3 = handleEnter:addLineEdit(nil, nil, 48)

	if var_239_2 then
		var_239_2:setStyle("HelperProfileInputLabel")
		var_239_2:resizeToText()
	end

	if var_239_3 then
		var_239_3:setStyle("HelperProfileInputLineEdit")
	end

	if arg_239_2 and var_239_3 then
		local onEnter = handleEnter.onEnter

		function handleEnter.onEnter()
			if handleEnter:isDestroyed() then
				return
			end

			local text = arg_239_2(cavebotState[101](var_239_3:getText()))

			if text then
				cavebotState[110](text)
				var_239_3:setTooltip(text)
				var_239_3:focus()

				return
			end

			onEnter()
		end
	end

	handleEnter:display()
	handleEnter:setStyle("HelperProfileInputBox")

	function handleEnter.onDestroy()
		if cavebotState[42] == handleEnter then
			cavebotState[42] = nil
		end
	end

	if var_239_3 then
		var_239_3:focus()
	end

	return true
end

function HelperCavebot.newPreset()
	return cavebotState[43](cavebotState[86]("New Route Configuration", "Nova Configuracao de Rota"), function(arg_245_0)
		if arg_245_0 == "" then
			cavebotState[110](cavebotState[86]("Route name cannot be empty", "O nome da rota nao pode ficar vazio"))

			return
		end

		if cavebotState[38][arg_245_0] then
			cavebotState[110](cavebotState[86]("A route with this name already exists", "Ja existe uma rota com este nome"))

			return
		end

		cavebotState[38][arg_245_0] = cavebotState[103](nil)

		HelperCavebot.loadPreset(arg_245_0)
		cavebotState[110](string.format("%s: %s", cavebotState[86]("Route created", "Rota criada"), arg_245_0))
	end)
end

function HelperCavebot.loadPreset(arg_246_0)
	arg_246_0 = cavebotState[101](arg_246_0)

	local var_246_0 = cavebotState[38][arg_246_0]

	if arg_246_0 == "" or not var_246_0 then
		return false
	end

	cavebotState[25]()
	cavebotState[57].reset(false)
	cavebotState[26](false)

	cavebotState[1] = cavebotState[100](var_246_0.waypoints)
	cavebotState[47] = cavebotState[102](var_246_0.luring)
	cavebotState[39] = arg_246_0
	cavebotState[2] = nil
	cavebotState[3] = 1

	if cavebotState[128]() then
		cavebotState[160]()
	end

	cavebotState[30] = 0
	cavebotState[31].selectStart = true
	cavebotState[31].reachedAt = nil

	cavebotState[131](false)
	cavebotState[141]()
	cavebotState[135]()
	cavebotState[168]()
	cavebotState[110](string.format("%s: %s", cavebotState[86]("Route loaded", "Rota carregada"), arg_246_0))
	cavebotState[130]()

	return true
end

function HelperCavebot.deletePreset(arg_247_0)
	arg_247_0 = cavebotState[101](arg_247_0 or cavebotState[140]())

	if arg_247_0 == "" or arg_247_0 == cavebotState[63] or not cavebotState[38][arg_247_0] then
		return false
	end

	local function var_247_0()
		if cavebotState[41] and not cavebotState[41]:isDestroyed() then
			cavebotState[41]:destroy()
		end

		cavebotState[41] = nil
	end

	local function var_247_1()
		var_247_0()

		cavebotState[38][arg_247_0] = nil

		HelperCavebot.loadPreset(cavebotState[63])
		cavebotState[110](string.format("%s: %s", cavebotState[86]("Route removed", "Rota removida"), arg_247_0))
	end

	if not displayGeneralBox then
		var_247_1()

		return true
	end

	cavebotState[41] = displayGeneralBox(cavebotState[86]("Delete Route Configuration", "Excluir Configuracao de Rota"), string.format(cavebotState[86]("Delete the route configuration \"%s\"?", "Excluir a configuracao de rota \"%s\"?"), arg_247_0), {
		{
			text = cavebotState[86]("Yes", "Sim"),
			callback = var_247_1
		},
		{
			text = cavebotState[86]("No", "Nao"),
			callback = var_247_0
		}
	}, var_247_1, var_247_0)

	return true
end

function HelperCavebot.deleteNamedPreset()
	return HelperCavebot.deletePreset(cavebotState[140]())
end

function HelperCavebot.selectWaypoint(numericValue, arg_251_1)
	numericValue = tonumber(numericValue)

	if not numericValue or not cavebotState[1][numericValue] then
		return false
	end

	local var_251_0 = cavebotState[2]

	cavebotState[2] = numericValue

	cavebotState[165](var_251_0, nil)
	cavebotState[159]()

	if arg_251_1 then
		cavebotState[169](cavebotState[1][numericValue].position)
	end

	return true
end

function HelperCavebot.addWaypointAt(textValue, arg_252_1, arg_252_2)
	local var_252_0 = cavebotState[88](arg_252_1)

	if not var_252_0 then
		cavebotState[110](cavebotState[86]("Invalid waypoint position", "Posicao de waypoint invalida"))

		return false
	end

	textValue = tostring(textValue or "position"):lower()

	if textValue == "stair" then
		textValue = "stairs"
	end

	if textValue ~= "transition" and textValue ~= "stairs" and textValue ~= "teleport" and textValue ~= "box" and textValue ~= "use" then
		textValue = "position"
	end

	arg_252_2 = type(arg_252_2) == "table" and arg_252_2 or {}

	local usePosition = textValue == "use" and cavebotState[88](arg_252_2.usePosition) or nil
	local itemId = textValue == "use" and math.floor(tonumber(arg_252_2.itemId) or 0) or nil

	if textValue == "use" and (not usePosition or itemId <= 0) then
		return false
	end

	local var_252_3 = cavebotState[2]
	local var_252_4 = {
		kind = textValue,
		position = var_252_0
	}

	if textValue == "use" then
		var_252_4.usePosition = usePosition
		var_252_4.itemId = itemId

		local withItemId = math.floor(tonumber(arg_252_2.withItemId) or 0)

		if withItemId > 0 then
			var_252_4.withItemId = withItemId
		end

		if arg_252_2.transition == true then
			var_252_4.transition = true
		end
	end

	cavebotState[1][#cavebotState[1] + 1] = var_252_4
	cavebotState[2] = #cavebotState[1]

	if #cavebotState[1] == 1 then
		cavebotState[3] = 1
	end

	cavebotState[110](string.format("%s #%d", cavebotState[86]("Waypoint added", "Waypoint adicionado"), #cavebotState[1]))
	cavebotState[164](#cavebotState[1])
	cavebotState[165](var_252_3, nil)
	cavebotState[167]()
	cavebotState[159]()

	if not cavebotState[33] then
		cavebotState[130]()
	end

	return true
end

function HelperCavebot.addCurrentWaypoint(arg_253_0)
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		cavebotState[110](cavebotState[86]("Player is offline", "Jogador esta offline"))

		return false
	end

	return HelperCavebot.addWaypointAt(arg_253_0, localPlayer:getPosition())
end

function HelperCavebot.removeSelectedWaypoint()
	local var_254_0 = cavebotState[2]

	if not var_254_0 or not cavebotState[1][var_254_0] then
		return false
	end

	local var_254_1 = cavebotState[2]
	local var_254_2 = cavebotState[3]

	cavebotState[25]()
	table.remove(cavebotState[1], var_254_0)

	if var_254_0 < cavebotState[3] then
		cavebotState[3] = cavebotState[3] - 1
	elseif cavebotState[3] > #cavebotState[1] then
		cavebotState[3] = 1
	end

	if #cavebotState[1] == 0 then
		cavebotState[2] = nil
		cavebotState[3] = 1
	else
		cavebotState[2] = math.min(var_254_0, #cavebotState[1])
	end

	cavebotState[30] = 0
	cavebotState[31].reachedAt = nil

	cavebotState[166](var_254_0)
	cavebotState[165](var_254_1, var_254_2)
	cavebotState[167]()
	cavebotState[159]()
	cavebotState[130]()

	return true
end

function HelperCavebot.clearWaypoints()
	if #cavebotState[1] == 0 then
		return false
	end

	cavebotState[25]()
	cavebotState[57].reset(false)
	cavebotState[26](true)

	cavebotState[1] = {}
	cavebotState[2] = nil
	cavebotState[3] = 1
	cavebotState[30] = 0
	cavebotState[31].selectStart = true
	cavebotState[31].reachedAt = nil

	cavebotState[131](false)
	cavebotState[168]()
	cavebotState[110](cavebotState[86]("All waypoints cleared", "Todos os waypoints foram removidos"))
	cavebotState[130]()

	return true
end

function HelperCavebot.requestClearWaypoints()
	if #cavebotState[1] == 0 then
		return false
	end

	local function var_256_0()
		if cavebotState[44] and not cavebotState[44]:isDestroyed() then
			cavebotState[44]:destroy()
		end

		cavebotState[44] = nil
	end

	local function var_256_1()
		var_256_0()
		HelperCavebot.clearWaypoints()
	end

	if not displayGeneralBox then
		var_256_1()

		return true
	end

	cavebotState[44] = displayGeneralBox(cavebotState[86]("Clear All Waypoints", "Limpar Todos os Waypoints"), cavebotState[86]("Remove every waypoint from the current route?", "Remover todos os waypoints da rota atual?"), {
		{
			text = cavebotState[86]("No", "Nao"),
			callback = var_256_0
		},
		{
			text = cavebotState[86]("Yes", "Sim"),
			callback = var_256_1
		}
	}, var_256_1, var_256_0)

	return true
end

function HelperCavebot.moveSelectedWaypoint(numericValue)
	local var_259_0 = cavebotState[2]

	numericValue = tonumber(numericValue) or 0

	local var_259_1 = var_259_0 and var_259_0 + numericValue or nil

	if not var_259_0 or not var_259_1 or not cavebotState[1][var_259_0] or not cavebotState[1][var_259_1] then
		return false
	end

	cavebotState[1][var_259_0], cavebotState[1][var_259_1] = cavebotState[1][var_259_1], cavebotState[1][var_259_0]

	if cavebotState[3] == var_259_0 then
		cavebotState[3] = var_259_1
	elseif cavebotState[3] == var_259_1 then
		cavebotState[3] = var_259_0
	end

	cavebotState[2] = var_259_1

	cavebotState[168]()
	cavebotState[130]()

	return true
end

function HelperCavebot.centerMapOnPlayer()
	local localPlayer = g_game.getLocalPlayer()
	local position = cavebotState[88](localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if not position then
		return false
	end

	local var_260_2 = cavebotState[85]("cavebotMapPreview")

	if var_260_2 and not var_260_2:isDestroyed() then
		var_260_2:setCrossPosition(position)
	end

	return cavebotState[169](position)
end

function HelperCavebot.navigateMap(arg_261_0, arg_261_1)
	local var_261_0 = cavebotState[85]("cavebotMapPreview")

	if not var_261_0 or var_261_0:isDestroyed() then
		return false
	end

	arg_261_1 = arg_261_1 or 1

	if arg_261_0 == "north" then
		var_261_0:move(0, arg_261_1)
	elseif arg_261_0 == "north-east" then
		var_261_0:move(-arg_261_1, arg_261_1)
	elseif arg_261_0 == "east" then
		var_261_0:move(-arg_261_1, 0)
	elseif arg_261_0 == "south-east" then
		var_261_0:move(-arg_261_1, -arg_261_1)
	elseif arg_261_0 == "south" then
		var_261_0:move(0, -arg_261_1)
	elseif arg_261_0 == "south-west" then
		var_261_0:move(arg_261_1, -arg_261_1)
	elseif arg_261_0 == "west" then
		var_261_0:move(arg_261_1, 0)
	elseif arg_261_0 == "north-west" then
		var_261_0:move(arg_261_1, arg_261_1)
	else
		return false
	end

	return true
end

function HelperCavebot.zoomMap(arg_262_0)
	local var_262_0 = cavebotState[85]("cavebotMapPreview")

	if not var_262_0 then
		return false
	end

	if tonumber(arg_262_0) and tonumber(arg_262_0) > 0 then
		return var_262_0:zoomIn()
	end

	return var_262_0:zoomOut()
end

function HelperCavebot.changeMapFloor(arg_263_0)
	local var_263_0 = cavebotState[85]("cavebotMapPreview")

	if not var_263_0 then
		return false
	end

	if tonumber(arg_263_0) and tonumber(arg_263_0) < 0 then
		return var_263_0:floorUp()
	end

	return var_263_0:floorDown()
end
