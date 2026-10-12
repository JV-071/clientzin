HelperCavebotAutoRoute = HelperCavebotAutoRoute or {}

local autoRoute = HelperCavebotAutoRoute
local autoRouteState = {
	generating = false,
	active = false
}
local startRouteGeneration

local function normalizePosition(position)
	if not position or tonumber(position.x) == nil or tonumber(position.y) == nil or tonumber(position.z) == nil then
		return nil
	end

	return {
		x = math.floor(tonumber(position.x)),
		y = math.floor(tonumber(position.y)),
		z = math.floor(tonumber(position.z))
	}
end

local function localizedText(englishText, portugueseText)
	if autoRouteState.ctx and autoRouteState.ctx.text then
		return autoRouteState.ctx.text(englishText, portugueseText)
	end

	return englishText
end

local function getWidget(widgetId)
	if autoRouteState.ctx and autoRouteState.ctx.getWidget then
		return autoRouteState.ctx.getWidget(widgetId)
	end

	return nil
end

local function setRouteStatus(statusText)
	if autoRouteState.ctx and autoRouteState.ctx.setStatus then
		autoRouteState.ctx.setStatus(statusText)
	end
end

local function destroyWidgetIfAlive(widget)
	if widget and not widget:isDestroyed() then
		widget:destroy()
	end
end

local function closeRouteConfirmation()
	local confirmBox = autoRouteState.confirmBox

	autoRouteState.confirmBox = nil

	destroyWidgetIfAlive(confirmBox)
end

local function cancelRouteGenerationEvent()
	if autoRouteState.generationEvent then
		removeEvent(autoRouteState.generationEvent)

		autoRouteState.generationEvent = nil
	end
end

local function clearRouteAnimation()
	autoRouteState.animationCallback = nil

	if g_cavebotAutoRoute and g_cavebotAutoRoute.clearAnimation then
		pcall(function()
			g_cavebotAutoRoute.clearAnimation()
		end)
	end
end

local function raiseRouteControls()
	for unusedValue, widgetId in ipairs({
		"cavebotAutoRouteButton",
		"cavebotRosePanel"
	}) do
		local controlWidget = getWidget(widgetId)

		if controlWidget and not controlWidget:isDestroyed() then
			controlWidget:raise()
		end
	end
end

local function setRosePanelEnabled(enabled)
	local rosePanel = getWidget("cavebotRosePanel")

	if rosePanel and not rosePanel:isDestroyed() then
		rosePanel:setEnabled(enabled)
	end
end

function autoRoute.refreshButton()
	local autoRouteButton = getWidget("cavebotAutoRouteButton")

	if not autoRouteButton or autoRouteButton:isDestroyed() then
		return
	end

	autoRouteButton:setOn(autoRouteState.active)
	autoRouteButton:setText(autoRouteState.active and localizedText("Cancel", "Cancelar") or localizedText("Auto Route", "Rota Auto"))
	autoRouteButton:setTooltip(autoRouteState.active and localizedText("Cancel the automatic hunt scan.", "Cancelar o escaneamento automatico da hunt.") or localizedText("Scan the connected hunt and generate a geometric Position-only route.", "Escaneie a hunt conectada e gere uma rota geometrica somente com Pos."))
end

local function restoreMapInputHandlers()
	local map = autoRouteState.map

	if map and not map:isDestroyed() then
		local savedHandlers = autoRouteState.savedHandlers or {}

		map.onMousePress = savedHandlers.onMousePress
		map.onMouseMove = savedHandlers.onMouseMove
		map.onMouseRelease = savedHandlers.onMouseRelease
		map.onMouseWheel = savedHandlers.onMouseWheel

		if savedHandlers.draggable ~= nil then
			map:setDraggable(savedHandlers.draggable)
		end
	end

	autoRouteState.savedHandlers = nil

	setRosePanelEnabled(true)
end

local function resetAutoRouteState(restoreMarkers)
	cancelRouteGenerationEvent()
	closeRouteConfirmation()
	clearRouteAnimation()
	restoreMapInputHandlers()

	autoRouteState.active = false
	autoRouteState.generating = false
	autoRouteState.scanOrigin = nil
	autoRouteState.plan = nil
	autoRouteState.map = nil
	autoRouteState.destination = nil

	autoRoute.refreshButton()

	if restoreMarkers and autoRouteState.ctx and autoRouteState.ctx.showMarkers then
		autoRouteState.ctx.showMarkers()
	end
end

function autoRoute.cancel(showCancelStatus)
	if not autoRouteState.active and not autoRouteState.map then
		return false
	end

	resetAutoRouteState(true)

	if showCancelStatus then
		setRouteStatus(localizedText("Automatic route cancelled", "Rota automatica cancelada"))
	end

	return true
end

local function formatRouteGenerationError(errorCode, errorDetails)
	errorDetails = type(errorDetails) == "table" and errorDetails or {}

	if errorCode == "invalidPlayerPosition" then
		return localizedText("The player position is unavailable for scanning.", "A posicao do personagem nao esta disponivel para o escaneamento.")
	elseif errorCode == "singleFloorOnly" then
		return localizedText("The selection must stay on one floor.", "A selecao precisa ficar em um unico andar.")
	elseif errorCode == "selectionTooLarge" then
		return string.format(localizedText("Selection is too large (%d tiles; maximum %d).", "A selecao e grande demais (%d SQMs; maximo %d)."), tonumber(errorDetails.selectedTiles) or 0, tonumber(errorDetails.maximum) or 0)
	elseif errorCode == "regionTooLarge" then
		return string.format(localizedText("The connected hunt is too large (%d tiles; maximum %d).", "A hunt conectada e grande demais (%d SQMs; maximo %d)."), tonumber(errorDetails.regionTiles) or 0, tonumber(errorDetails.maximum) or 0)
	elseif errorCode == "regionTooSmall" then
		return string.format(localizedText("The connected hunt is too small (%d tiles; minimum %d).", "A hunt conectada e pequena demais (%d SQMs; minimo %d)."), tonumber(errorDetails.regionTiles) or 0, tonumber(errorDetails.minimum) or 0)
	elseif errorCode == "noNavigableTiles" then
		return localizedText("No known walkable hunt area was found.", "Nenhuma area conhecida e caminhavel da hunt foi encontrada.")
	elseif errorCode == "notEnoughRoutePoints" then
		return localizedText("The hunt does not contain enough space for a route.", "A hunt nao tem espaco suficiente para uma rota.")
	elseif errorCode == "tooManyWaypoints" then
		return string.format(localizedText("The route needs too many waypoints (%d; maximum %d).", "A rota precisa de waypoints demais (%d; maximo %d)."), tonumber(errorDetails.waypoints) or 0, tonumber(errorDetails.maximum) or 0)
	elseif errorCode == "routeLeavesHunt" then
		return localizedText("A safe route that stays inside the hunt could not be built.", "Nao foi possivel montar uma rota segura que fique dentro da hunt.")
	elseif errorCode == "routeConnectionFailed" then
		return localizedText("Some hunt sections could not be connected safely.", "Algumas partes da hunt nao puderam ser conectadas com seguranca.")
	elseif errorCode == "pathfinderUnavailable" or errorCode == "pathfinderFailed" then
		return localizedText("The map pathfinder is unavailable for this area.", "O pathfinder do mapa nao esta disponivel para esta area.")
	end

	return localizedText("The automatic route could not be generated.", "Nao foi possivel gerar a rota automatica.")
end

local function runRouteAnimation(animationMethod, plan, onComplete)
	local routeGenerator = g_cavebotAutoRoute
	local animate = routeGenerator and routeGenerator[animationMethod]

	if not animate or not autoRouteState.map or autoRouteState.map:isDestroyed() then
		onComplete()

		return
	end

	local unusedValue

	local function animationCallback()
		if autoRouteState.animationCallback ~= animationCallback then
			return
		end

		autoRouteState.animationCallback = nil

		if autoRouteState.active and autoRouteState.plan == plan then
			raiseRouteControls()
			onComplete()
		end
	end

	autoRouteState.animationCallback = animationCallback

	local animationCallSucceeded, animationStarted = pcall(function()
		return animate(autoRouteState.map, animationCallback)
	end)

	if animationCallSucceeded and animationStarted then
		return
	end

	if autoRouteState.animationCallback == animationCallback then
		autoRouteState.animationCallback = nil
	end

	onComplete()
end

local function animateRouteScan(plan, onComplete)
	runRouteAnimation("animateScan", plan, onComplete)
end

local function animateGeneratedRoute(plan, onComplete)
	runRouteAnimation("animateRoute", plan, onComplete)
end

local function buildRouteSummary(plan)
	local stats = plan.stats or {}
	local summaryLines = {
		string.format(localizedText("%d Position waypoints", "%d waypoints Pos"), tonumber(stats.waypoints) or #(plan.waypoints or {})),
		string.format(localizedText("Hunt coverage: %.1f%% of %d navigable tiles", "Cobertura da hunt: %.1f%% de %d SQMs caminhaveis"), tonumber(stats.coveragePercent) or 0, tonumber(stats.huntTiles) or 0),
		string.format(localizedText("Estimated cycle: %d steps", "Ciclo estimado: %d passos"), tonumber(stats.totalSteps) or 0)
	}
	local numericValue = tonumber(stats.outsideTiles) or 0

	if numericValue > 0 then
		if stats.automaticScan then
			summaryLines[#summaryLines + 1] = string.format(localizedText("%d non-walkable or unsafe tile(s) were ignored by the scan.", "%d SQM(s) nao caminhaveis ou inseguros foram ignorados pelo scanner."), numericValue)
		else
			summaryLines[#summaryLines + 1] = string.format(localizedText("%d selected tile(s) outside the walkable hunt were detected and ignored.", "%d SQM(s) fora da area caminhavel da hunt foram detectados e ignorados."), numericValue)
		end
	else
		summaryLines[#summaryLines + 1] = stats.automaticScan and localizedText("The wave stayed inside the connected walkable hunt.", "A onda permaneceu dentro da hunt caminhavel conectada.") or localizedText("The entire selection belongs to the walkable hunt area.", "Toda a selecao pertence a area caminhavel da hunt.")
	end

	local numericValue = tonumber(stats.floorChangeTiles) or 0

	if numericValue > 0 then
		summaryLines[#summaryLines + 1] = string.format(localizedText("%d floor-change tile(s) were excluded for safety.", "%d SQM(s) de troca de andar foram excluidos por seguranca."), numericValue)
	end

	if stats.automaticScan then
		if stats.scanLimited then
			summaryLines[#summaryLines + 1] = string.format(localizedText("Open-area safety limit reached after %d path layers.", "Limite de seguranca para area aberta atingido apos %d camadas de caminho."), tonumber(stats.scanSafetyDistance) or 0)
		else
			summaryLines[#summaryLines + 1] = localizedText("The circular wave reached the complete boundary of this connected hunt.", "A onda circular encontrou todo o limite desta hunt conectada.")
		end
	end

	local textValue = tostring(stats.routePattern or "")

	if textValue == "horizontal" or textValue == "vertical" then
		summaryLines[#summaryLines + 1] = textValue == "horizontal" and localizedText("Geometric pattern: horizontal sweep.", "Padrao geometrico: varredura horizontal.") or localizedText("Geometric pattern: vertical sweep.", "Padrao geometrico: varredura vertical.")
	end

	local numericValue = tonumber(stats.continuityCorrections) or 0

	if numericValue > 0 then
		summaryLines[#summaryLines + 1] = string.format(localizedText("%d local return(s) were replaced by smoother continuations.", "%d retorno(s) local(is) foram trocados por continuacoes mais fluidas."), numericValue)
	end

	summaryLines[#summaryLines + 1] = localizedText("The route uses only Pos and never changes floor.", "A rota usa apenas Pos e nunca troca de andar.")
	summaryLines[#summaryLines + 1] = localizedText("Closed cycle: the last waypoint returns to the first.", "Ciclo fechado: o ultimo waypoint retorna ao primeiro.")

	return table.concat(summaryLines, "\n")
end

local function rescanRoute()
	closeRouteConfirmation()
	clearRouteAnimation()

	autoRouteState.plan = nil

	local localPlayer = g_game and g_game.getLocalPlayer and g_game.getLocalPlayer()
	local position = normalizePosition(localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if position then
		autoRouteState.scanOrigin = position
	end

	if startRouteGeneration then
		startRouteGeneration()
	end
end

local function showGeneratedRouteConfirmation(plan)
	autoRouteState.generating = false
	autoRouteState.plan = plan

	setRouteStatus(localizedText("Automatic route ready for review", "Rota automatica pronta para revisao"))

	local function applyGeneratedRoute()
		if not autoRouteState.active or autoRouteState.plan ~= plan then
			return
		end

		local plan = autoRouteState.plan
		local destination = autoRouteState.destination

		resetAutoRouteState(false)

		if plan and autoRouteState.ctx and autoRouteState.ctx.applyWaypoints then
			autoRouteState.ctx.applyWaypoints(plan.waypoints, plan.stats, destination)
		end
	end

	local function cancelGeneratedRoute()
		autoRoute.cancel(true)
	end

	if not displayGeneralBox then
		applyGeneratedRoute()

		return
	end

	autoRouteState.confirmBox = displayGeneralBox(localizedText("Automatic Cavebot Route", "Rota Automatica do Cavebot"), buildRouteSummary(plan), {
		{
			text = localizedText("Cancel", "Cancelar"),
			callback = cancelGeneratedRoute
		},
		{
			text = localizedText("Rescan", "Escanear"),
			callback = rescanRoute
		},
		{
			text = localizedText("Apply", "Aplicar"),
			callback = applyGeneratedRoute
		}
	}, applyGeneratedRoute, cancelGeneratedRoute)
end

local function reportRouteGenerationFailure(statusText, errorDetails)
	resetAutoRouteState(true)
	setRouteStatus(statusText)

	if errorDetails and g_logger and g_logger.error then
		g_logger.error("[helper_cavebot_auto_route] " .. tostring(errorDetails))
	end

	if displayErrorBox then
		displayErrorBox(localizedText("Automatic Cavebot Route", "Rota Automatica do Cavebot"), statusText)
	end
end

local function showGeneratedRouteAnimations(plan)
	autoRouteState.plan = plan

	setRouteStatus(localizedText("Propagating circular scan waves through the hunt...", "Propagando ondas circulares de escaneamento pela hunt..."))
	animateRouteScan(plan, function()
		if not autoRouteState.active or autoRouteState.plan ~= plan then
			return
		end

		setRouteStatus(localizedText("Drawing the optimized route...", "Desenhando a rota otimizada..."))
		animateGeneratedRoute(plan, function()
			if autoRouteState.active and autoRouteState.plan == plan then
				showGeneratedRouteConfirmation(plan)
			end
		end)
	end)
end

local function pollRouteGeneration()
	autoRouteState.generationEvent = nil

	if not autoRouteState.active or not autoRouteState.scanOrigin then
		return
	end

	if not g_cavebotAutoRoute or not g_cavebotAutoRoute.generateAutomatic then
		reportRouteGenerationFailure(localizedText("The automatic route generator is unavailable.", "O gerador automatico de rota esta indisponivel."))

		return
	end

	local scanOrigin = normalizePosition(autoRouteState.scanOrigin)
	local generationCallSucceeded, generatedPlan, generationStatus, generationDetails = pcall(function()
		return g_cavebotAutoRoute.generateAutomatic(scanOrigin)
	end)

	if not generationCallSucceeded then
		reportRouteGenerationFailure(localizedText("The automatic route generator failed safely.", "O gerador automatico de rota falhou com seguranca."), tostring(generatedPlan))

		return
	end

	if not generatedPlan and generationStatus == "pending" then
		generationDetails = type(generationDetails) == "table" and generationDetails or {}

		local numericValue = tonumber(generationDetails.phase) or 1

		if numericValue == 1 then
			setRouteStatus(string.format(localizedText("Scanning the connected hunt... %d tiles", "Escaneando a hunt conectada... %d SQMs"), tonumber(generationDetails.processed) or 0))
		elseif numericValue == 2 then
			setRouteStatus(localizedText("Optimizing the route in the background...", "Otimizando a rota em segundo plano..."))
		elseif numericValue == 3 then
			setRouteStatus(string.format(localizedText("Validating route connections... %d/%d", "Validando conexoes da rota... %d/%d"), tonumber(generationDetails.processed) or 0, tonumber(generationDetails.total) or 0))
		end

		if autoRouteState.active and autoRouteState.scanOrigin then
			autoRouteState.generationEvent = scheduleEvent(pollRouteGeneration, 1)
		end

		return
	end

	if not generatedPlan then
		reportRouteGenerationFailure(formatRouteGenerationError(generationStatus, generationDetails), generationStatus)

		return
	end

	showGeneratedRouteAnimations(generatedPlan)
end

function startRouteGeneration()
	if not autoRouteState.active or not autoRouteState.scanOrigin then
		return
	end

	cancelRouteGenerationEvent()
	closeRouteConfirmation()
	clearRouteAnimation()

	autoRouteState.plan = nil
	autoRouteState.generating = true

	setRouteStatus(localizedText("Scanning the connected hunt...", "Escaneando a hunt conectada..."))

	autoRouteState.generationEvent = scheduleEvent(pollRouteGeneration, 1)
end

local function captureMapInputHandlers(mapWidget)
	autoRouteState.savedHandlers = {
		onMousePress = mapWidget.onMousePress,
		onMouseMove = mapWidget.onMouseMove,
		onMouseRelease = mapWidget.onMouseRelease,
		onMouseWheel = mapWidget.onMouseWheel,
		draggable = mapWidget:isDraggable()
	}

	mapWidget:setDraggable(false)

	function mapWidget.onMousePress(unusedArgument, unusedArgument, mouseButton)
		if mouseButton == MouseRightButton then
			autoRoute.cancel(true)
		end

		return true
	end

	function mapWidget.onMouseMove()
		return true
	end

	function mapWidget.onMouseRelease(unusedArgument, unusedArgument, mouseButton)
		if mouseButton == MouseRightButton then
			autoRoute.cancel(true)
		end

		return true
	end

	function mapWidget.onMouseWheel()
		return true
	end
end

function autoRoute.start(destination)
	local map = getWidget("cavebotMapPreview")
	local localPlayer = g_game and g_game.getLocalPlayer and g_game.getLocalPlayer()
	local position = normalizePosition(localPlayer and localPlayer.getPosition and localPlayer:getPosition())

	if not map or map:isDestroyed() or not position then
		setRouteStatus(localizedText("Open the game before generating a route.", "Entre no jogo antes de gerar uma rota."))

		return false
	end

	if autoRouteState.active or autoRouteState.map then
		resetAutoRouteState(true)
	end

	if autoRouteState.ctx and autoRouteState.ctx.prepare then
		autoRouteState.ctx.prepare()
	end

	autoRouteState.map = map
	autoRouteState.active = true
	autoRouteState.generating = true
	autoRouteState.scanOrigin = normalizePosition(position)
	autoRouteState.plan = nil
	autoRouteState.destination = destination

	if autoRouteState.ctx and autoRouteState.ctx.hideMarkers then
		autoRouteState.ctx.hideMarkers()
	end

	captureMapInputHandlers(map)
	setRosePanelEnabled(false)
	autoRoute.refreshButton()
	raiseRouteControls()
	startRouteGeneration()

	return true
end

function autoRoute.toggle()
	if autoRouteState.active then
		return autoRoute.cancel(true)
	end

	return autoRoute.start()
end

function autoRoute.isActive()
	return autoRouteState.active == true
end

function autoRoute.init(ctx)
	if autoRouteState.active or autoRouteState.map then
		resetAutoRouteState(false)
	end

	autoRouteState.ctx = ctx

	autoRoute.refreshButton()
end

function autoRoute.terminate()
	if autoRouteState.active or autoRouteState.map then
		resetAutoRouteState(false)
	end

	autoRouteState.ctx = nil
end
