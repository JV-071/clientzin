HelperCavebotAutoRoute = HelperCavebotAutoRoute or {}

local var_0_0 = HelperCavebotAutoRoute
local var_0_1 = {
	generating = false,
	active = false
}
local var_0_2

local function var_0_3(arg_1_0)
	if not arg_1_0 or tonumber(arg_1_0.x) == nil or tonumber(arg_1_0.y) == nil or tonumber(arg_1_0.z) == nil then
		return nil
	end

	return {
		x = math.floor(tonumber(arg_1_0.x)),
		y = math.floor(tonumber(arg_1_0.y)),
		z = math.floor(tonumber(arg_1_0.z))
	}
end

local function var_0_4(arg_2_0, arg_2_1)
	if var_0_1.ctx and var_0_1.ctx.text then
		return var_0_1.ctx.text(arg_2_0, arg_2_1)
	end

	return arg_2_0
end

local function var_0_5(arg_3_0)
	if var_0_1.ctx and var_0_1.ctx.getWidget then
		return var_0_1.ctx.getWidget(arg_3_0)
	end

	return nil
end

local function var_0_6(arg_4_0)
	if var_0_1.ctx and var_0_1.ctx.setStatus then
		var_0_1.ctx.setStatus(arg_4_0)
	end
end

local function var_0_7(arg_5_0)
	if arg_5_0 and not arg_5_0:isDestroyed() then
		arg_5_0:destroy()
	end
end

local function var_0_8()
	local confirmBox = var_0_1.confirmBox

	var_0_1.confirmBox = nil

	var_0_7(confirmBox)
end

local function var_0_9()
	if var_0_1.generationEvent then
		removeEvent(var_0_1.generationEvent)

		var_0_1.generationEvent = nil
	end
end

local function var_0_10()
	var_0_1.animationCallback = nil

	if g_cavebotAutoRoute and g_cavebotAutoRoute.clearAnimation then
		pcall(function()
			g_cavebotAutoRoute.clearAnimation()
		end)
	end
end

local function var_0_11()
	for unusedValue, iter_10_1 in ipairs({
		"cavebotAutoRouteButton",
		"cavebotRosePanel"
	}) do
		local var_10_0 = var_0_5(iter_10_1)

		if var_10_0 and not var_10_0:isDestroyed() then
			var_10_0:raise()
		end
	end
end

local function var_0_12(arg_11_0)
	local var_11_0 = var_0_5("cavebotRosePanel")

	if var_11_0 and not var_11_0:isDestroyed() then
		var_11_0:setEnabled(arg_11_0)
	end
end

function var_0_0.refreshButton()
	local var_12_0 = var_0_5("cavebotAutoRouteButton")

	if not var_12_0 or var_12_0:isDestroyed() then
		return
	end

	var_12_0:setOn(var_0_1.active)
	var_12_0:setText(var_0_1.active and var_0_4("Cancel", "Cancelar") or var_0_4("Auto Route", "Rota Auto"))
	var_12_0:setTooltip(var_0_1.active and var_0_4("Cancel the automatic hunt scan.", "Cancelar o escaneamento automatico da hunt.") or var_0_4("Scan the connected hunt and generate a geometric Position-only route.", "Escaneie a hunt conectada e gere uma rota geometrica somente com Pos."))
end

local function var_0_13()
	local map = var_0_1.map

	if map and not map:isDestroyed() then
		local var_13_1 = var_0_1.savedHandlers or {}

		map.onMousePress = var_13_1.onMousePress
		map.onMouseMove = var_13_1.onMouseMove
		map.onMouseRelease = var_13_1.onMouseRelease
		map.onMouseWheel = var_13_1.onMouseWheel

		if var_13_1.draggable ~= nil then
			map:setDraggable(var_13_1.draggable)
		end
	end

	var_0_1.savedHandlers = nil

	var_0_12(true)
end

local function var_0_14(arg_14_0)
	var_0_9()
	var_0_8()
	var_0_10()
	var_0_13()

	var_0_1.active = false
	var_0_1.generating = false
	var_0_1.scanOrigin = nil
	var_0_1.plan = nil
	var_0_1.map = nil
	var_0_1.destination = nil

	var_0_0.refreshButton()

	if arg_14_0 and var_0_1.ctx and var_0_1.ctx.showMarkers then
		var_0_1.ctx.showMarkers()
	end
end

function var_0_0.cancel(arg_15_0)
	if not var_0_1.active and not var_0_1.map then
		return false
	end

	var_0_14(true)

	if arg_15_0 then
		var_0_6(var_0_4("Automatic route cancelled", "Rota automatica cancelada"))
	end

	return true
end

local function var_0_15(arg_16_0, arg_16_1)
	arg_16_1 = type(arg_16_1) == "table" and arg_16_1 or {}

	if arg_16_0 == "invalidPlayerPosition" then
		return var_0_4("The player position is unavailable for scanning.", "A posicao do personagem nao esta disponivel para o escaneamento.")
	elseif arg_16_0 == "singleFloorOnly" then
		return var_0_4("The selection must stay on one floor.", "A selecao precisa ficar em um unico andar.")
	elseif arg_16_0 == "selectionTooLarge" then
		return string.format(var_0_4("Selection is too large (%d tiles; maximum %d).", "A selecao e grande demais (%d SQMs; maximo %d)."), tonumber(arg_16_1.selectedTiles) or 0, tonumber(arg_16_1.maximum) or 0)
	elseif arg_16_0 == "regionTooLarge" then
		return string.format(var_0_4("The connected hunt is too large (%d tiles; maximum %d).", "A hunt conectada e grande demais (%d SQMs; maximo %d)."), tonumber(arg_16_1.regionTiles) or 0, tonumber(arg_16_1.maximum) or 0)
	elseif arg_16_0 == "regionTooSmall" then
		return string.format(var_0_4("The connected hunt is too small (%d tiles; minimum %d).", "A hunt conectada e pequena demais (%d SQMs; minimo %d)."), tonumber(arg_16_1.regionTiles) or 0, tonumber(arg_16_1.minimum) or 0)
	elseif arg_16_0 == "noNavigableTiles" then
		return var_0_4("No known walkable hunt area was found.", "Nenhuma area conhecida e caminhavel da hunt foi encontrada.")
	elseif arg_16_0 == "notEnoughRoutePoints" then
		return var_0_4("The hunt does not contain enough space for a route.", "A hunt nao tem espaco suficiente para uma rota.")
	elseif arg_16_0 == "tooManyWaypoints" then
		return string.format(var_0_4("The route needs too many waypoints (%d; maximum %d).", "A rota precisa de waypoints demais (%d; maximo %d)."), tonumber(arg_16_1.waypoints) or 0, tonumber(arg_16_1.maximum) or 0)
	elseif arg_16_0 == "routeLeavesHunt" then
		return var_0_4("A safe route that stays inside the hunt could not be built.", "Nao foi possivel montar uma rota segura que fique dentro da hunt.")
	elseif arg_16_0 == "routeConnectionFailed" then
		return var_0_4("Some hunt sections could not be connected safely.", "Algumas partes da hunt nao puderam ser conectadas com seguranca.")
	elseif arg_16_0 == "pathfinderUnavailable" or arg_16_0 == "pathfinderFailed" then
		return var_0_4("The map pathfinder is unavailable for this area.", "O pathfinder do mapa nao esta disponivel para esta area.")
	end

	return var_0_4("The automatic route could not be generated.", "Nao foi possivel gerar a rota automatica.")
end

local function var_0_16(arg_17_0, arg_17_1, arg_17_2)
	local var_17_0 = g_cavebotAutoRoute
	local var_17_1 = var_17_0 and var_17_0[arg_17_0]

	if not var_17_1 or not var_0_1.map or var_0_1.map:isDestroyed() then
		arg_17_2()

		return
	end

	local unusedValue

	local function var_17_3()
		if var_0_1.animationCallback ~= var_17_3 then
			return
		end

		var_0_1.animationCallback = nil

		if var_0_1.active and var_0_1.plan == arg_17_1 then
			var_0_11()
			arg_17_2()
		end
	end

	var_0_1.animationCallback = var_17_3

	local var_17_4, var_17_5 = pcall(function()
		return var_17_1(var_0_1.map, var_17_3)
	end)

	if var_17_4 and var_17_5 then
		return
	end

	if var_0_1.animationCallback == var_17_3 then
		var_0_1.animationCallback = nil
	end

	arg_17_2()
end

local function var_0_17(arg_20_0, arg_20_1)
	var_0_16("animateScan", arg_20_0, arg_20_1)
end

local function var_0_18(arg_21_0, arg_21_1)
	var_0_16("animateRoute", arg_21_0, arg_21_1)
end

local function var_0_19(arg_22_0)
	local var_22_0 = arg_22_0.stats or {}
	local var_22_1 = {
		string.format(var_0_4("%d Position waypoints", "%d waypoints Pos"), tonumber(var_22_0.waypoints) or #(arg_22_0.waypoints or {})),
		string.format(var_0_4("Hunt coverage: %.1f%% of %d navigable tiles", "Cobertura da hunt: %.1f%% de %d SQMs caminhaveis"), tonumber(var_22_0.coveragePercent) or 0, tonumber(var_22_0.huntTiles) or 0),
		string.format(var_0_4("Estimated cycle: %d steps", "Ciclo estimado: %d passos"), tonumber(var_22_0.totalSteps) or 0)
	}
	local numericValue = tonumber(var_22_0.outsideTiles) or 0

	if numericValue > 0 then
		if var_22_0.automaticScan then
			var_22_1[#var_22_1 + 1] = string.format(var_0_4("%d non-walkable or unsafe tile(s) were ignored by the scan.", "%d SQM(s) nao caminhaveis ou inseguros foram ignorados pelo scanner."), numericValue)
		else
			var_22_1[#var_22_1 + 1] = string.format(var_0_4("%d selected tile(s) outside the walkable hunt were detected and ignored.", "%d SQM(s) fora da area caminhavel da hunt foram detectados e ignorados."), numericValue)
		end
	else
		var_22_1[#var_22_1 + 1] = var_22_0.automaticScan and var_0_4("The wave stayed inside the connected walkable hunt.", "A onda permaneceu dentro da hunt caminhavel conectada.") or var_0_4("The entire selection belongs to the walkable hunt area.", "Toda a selecao pertence a area caminhavel da hunt.")
	end

	local numericValue = tonumber(var_22_0.floorChangeTiles) or 0

	if numericValue > 0 then
		var_22_1[#var_22_1 + 1] = string.format(var_0_4("%d floor-change tile(s) were excluded for safety.", "%d SQM(s) de troca de andar foram excluidos por seguranca."), numericValue)
	end

	if var_22_0.automaticScan then
		if var_22_0.scanLimited then
			var_22_1[#var_22_1 + 1] = string.format(var_0_4("Open-area safety limit reached after %d path layers.", "Limite de seguranca para area aberta atingido apos %d camadas de caminho."), tonumber(var_22_0.scanSafetyDistance) or 0)
		else
			var_22_1[#var_22_1 + 1] = var_0_4("The circular wave reached the complete boundary of this connected hunt.", "A onda circular encontrou todo o limite desta hunt conectada.")
		end
	end

	local textValue = tostring(var_22_0.routePattern or "")

	if textValue == "horizontal" or textValue == "vertical" then
		var_22_1[#var_22_1 + 1] = textValue == "horizontal" and var_0_4("Geometric pattern: horizontal sweep.", "Padrao geometrico: varredura horizontal.") or var_0_4("Geometric pattern: vertical sweep.", "Padrao geometrico: varredura vertical.")
	end

	local numericValue = tonumber(var_22_0.continuityCorrections) or 0

	if numericValue > 0 then
		var_22_1[#var_22_1 + 1] = string.format(var_0_4("%d local return(s) were replaced by smoother continuations.", "%d retorno(s) local(is) foram trocados por continuacoes mais fluidas."), numericValue)
	end

	var_22_1[#var_22_1 + 1] = var_0_4("The route uses only Pos and never changes floor.", "A rota usa apenas Pos e nunca troca de andar.")
	var_22_1[#var_22_1 + 1] = var_0_4("Closed cycle: the last waypoint returns to the first.", "Ciclo fechado: o ultimo waypoint retorna ao primeiro.")

	return table.concat(var_22_1, "\n")
end

local function var_0_20()
	var_0_8()
	var_0_10()

	var_0_1.plan = nil

	local localPlayer = g_game and g_game.getLocalPlayer and g_game.getLocalPlayer()
	local position = var_0_3(localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if position then
		var_0_1.scanOrigin = position
	end

	if var_0_2 then
		var_0_2()
	end
end

local function var_0_21(arg_24_0)
	var_0_1.generating = false
	var_0_1.plan = arg_24_0

	var_0_6(var_0_4("Automatic route ready for review", "Rota automatica pronta para revisao"))

	local function var_24_0()
		if not var_0_1.active or var_0_1.plan ~= arg_24_0 then
			return
		end

		local plan = var_0_1.plan
		local destination = var_0_1.destination

		var_0_14(false)

		if plan and var_0_1.ctx and var_0_1.ctx.applyWaypoints then
			var_0_1.ctx.applyWaypoints(plan.waypoints, plan.stats, destination)
		end
	end

	local function var_24_1()
		var_0_0.cancel(true)
	end

	if not displayGeneralBox then
		var_24_0()

		return
	end

	var_0_1.confirmBox = displayGeneralBox(var_0_4("Automatic Cavebot Route", "Rota Automatica do Cavebot"), var_0_19(arg_24_0), {
		{
			text = var_0_4("Cancel", "Cancelar"),
			callback = var_24_1
		},
		{
			text = var_0_4("Rescan", "Escanear"),
			callback = var_0_20
		},
		{
			text = var_0_4("Apply", "Aplicar"),
			callback = var_24_0
		}
	}, var_24_0, var_24_1)
end

local function var_0_22(arg_27_0, arg_27_1)
	var_0_14(true)
	var_0_6(arg_27_0)

	if arg_27_1 and g_logger and g_logger.error then
		g_logger.error("[helper_cavebot_auto_route] " .. tostring(arg_27_1))
	end

	if displayErrorBox then
		displayErrorBox(var_0_4("Automatic Cavebot Route", "Rota Automatica do Cavebot"), arg_27_0)
	end
end

local function var_0_23(arg_28_0)
	var_0_1.plan = arg_28_0

	var_0_6(var_0_4("Propagating circular scan waves through the hunt...", "Propagando ondas circulares de escaneamento pela hunt..."))
	var_0_17(arg_28_0, function()
		if not var_0_1.active or var_0_1.plan ~= arg_28_0 then
			return
		end

		var_0_6(var_0_4("Drawing the optimized route...", "Desenhando a rota otimizada..."))
		var_0_18(arg_28_0, function()
			if var_0_1.active and var_0_1.plan == arg_28_0 then
				var_0_21(arg_28_0)
			end
		end)
	end)
end

local function var_0_24()
	var_0_1.generationEvent = nil

	if not var_0_1.active or not var_0_1.scanOrigin then
		return
	end

	if not g_cavebotAutoRoute or not g_cavebotAutoRoute.generateAutomatic then
		var_0_22(var_0_4("The automatic route generator is unavailable.", "O gerador automatico de rota esta indisponivel."))

		return
	end

	local var_31_0 = var_0_3(var_0_1.scanOrigin)
	local var_31_1, var_31_2, var_31_3, var_31_4 = pcall(function()
		return g_cavebotAutoRoute.generateAutomatic(var_31_0)
	end)

	if not var_31_1 then
		var_0_22(var_0_4("The automatic route generator failed safely.", "O gerador automatico de rota falhou com seguranca."), tostring(var_31_2))

		return
	end

	if not var_31_2 and var_31_3 == "pending" then
		var_31_4 = type(var_31_4) == "table" and var_31_4 or {}

		local numericValue = tonumber(var_31_4.phase) or 1

		if numericValue == 1 then
			var_0_6(string.format(var_0_4("Scanning the connected hunt... %d tiles", "Escaneando a hunt conectada... %d SQMs"), tonumber(var_31_4.processed) or 0))
		elseif numericValue == 2 then
			var_0_6(var_0_4("Optimizing the route in the background...", "Otimizando a rota em segundo plano..."))
		elseif numericValue == 3 then
			var_0_6(string.format(var_0_4("Validating route connections... %d/%d", "Validando conexoes da rota... %d/%d"), tonumber(var_31_4.processed) or 0, tonumber(var_31_4.total) or 0))
		end

		if var_0_1.active and var_0_1.scanOrigin then
			var_0_1.generationEvent = scheduleEvent(var_0_24, 1)
		end

		return
	end

	if not var_31_2 then
		var_0_22(var_0_15(var_31_3, var_31_4), var_31_3)

		return
	end

	var_0_23(var_31_2)
end

function var_0_2()
	if not var_0_1.active or not var_0_1.scanOrigin then
		return
	end

	var_0_9()
	var_0_8()
	var_0_10()

	var_0_1.plan = nil
	var_0_1.generating = true

	var_0_6(var_0_4("Scanning the connected hunt...", "Escaneando a hunt conectada..."))

	var_0_1.generationEvent = scheduleEvent(var_0_24, 1)
end

local function var_0_25(arg_34_0)
	var_0_1.savedHandlers = {
		onMousePress = arg_34_0.onMousePress,
		onMouseMove = arg_34_0.onMouseMove,
		onMouseRelease = arg_34_0.onMouseRelease,
		onMouseWheel = arg_34_0.onMouseWheel,
		draggable = arg_34_0:isDraggable()
	}

	arg_34_0:setDraggable(false)

	function arg_34_0.onMousePress(unusedArgument, unusedArgument, arg_35_2)
		if arg_35_2 == MouseRightButton then
			var_0_0.cancel(true)
		end

		return true
	end

	function arg_34_0.onMouseMove()
		return true
	end

	function arg_34_0.onMouseRelease(unusedArgument, unusedArgument, arg_37_2)
		if arg_37_2 == MouseRightButton then
			var_0_0.cancel(true)
		end

		return true
	end

	function arg_34_0.onMouseWheel()
		return true
	end
end

function var_0_0.start(arg_39_0)
	local var_39_0 = var_0_5("cavebotMapPreview")
	local localPlayer = g_game and g_game.getLocalPlayer and g_game.getLocalPlayer()
	local position = var_0_3(localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if not var_39_0 or var_39_0:isDestroyed() or not position then
		var_0_6(var_0_4("Open the game before generating a route.", "Entre no jogo antes de gerar uma rota."))

		return false
	end

	if var_0_1.active or var_0_1.map then
		var_0_14(true)
	end

	if var_0_1.ctx and var_0_1.ctx.prepare then
		var_0_1.ctx.prepare()
	end

	var_0_1.map = var_39_0
	var_0_1.active = true
	var_0_1.generating = true
	var_0_1.scanOrigin = var_0_3(position)
	var_0_1.plan = nil
	var_0_1.destination = arg_39_0

	if var_0_1.ctx and var_0_1.ctx.hideMarkers then
		var_0_1.ctx.hideMarkers()
	end

	var_0_25(var_39_0)
	var_0_12(false)
	var_0_0.refreshButton()
	var_0_11()
	var_0_2()

	return true
end

function var_0_0.toggle()
	if var_0_1.active then
		return var_0_0.cancel(true)
	end

	return var_0_0.start()
end

function var_0_0.isActive()
	return var_0_1.active == true
end

function var_0_0.init(arg_42_0)
	if var_0_1.active or var_0_1.map then
		var_0_14(false)
	end

	var_0_1.ctx = arg_42_0

	var_0_0.refreshButton()
end

function var_0_0.terminate()
	if var_0_1.active or var_0_1.map then
		var_0_14(false)
	end

	var_0_1.ctx = nil
end
