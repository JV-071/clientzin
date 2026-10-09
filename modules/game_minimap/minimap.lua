local unusedValue
local oldPos
local fullscreenWidget
local virtualFloor = 7
local dragStartMouseY = 0
local dragStartMargin = 0
local persistentMinimapDataLoaded = false
local visible = false
local currentDayTime = {
	m = 0,
	h = 12
}
local LAYER_FLOOR_MIN = 0
local LAYER_FLOOR_MAX = 15
local MINIMAP_OTMM_PATH = "Minimap"
local var_0_12 = 12
local MINIMAP_OTMM_FALLBACK_PATHS = {
	{
		action = "Center",
		defaultKey = "",
		callback = function()
			resetMap()
		end
	},
	{
		action = "One Floor Down",
		defaultKey = "Alt+PageDown",
		callback = function()
			downLayer()
		end
	},
	{
		action = "One Floor Up",
		defaultKey = "Alt+PageUp",
		callback = function()
			upLayer()
		end
	},
	{
		action = "Scroll East",
		defaultKey = "Alt+Right",
		callback = function()
			onClickRoseButton("east", var_0_12)
		end
	},
	{
		action = "Scroll North",
		defaultKey = "Alt+Up",
		callback = function()
			onClickRoseButton("north", var_0_12)
		end
	},
	{
		action = "Scroll South",
		defaultKey = "Alt+Down",
		callback = function()
			onClickRoseButton("south", var_0_12)
		end
	},
	{
		action = "Scroll West",
		defaultKey = "Alt+Left",
		callback = function()
			onClickRoseButton("west", var_0_12)
		end
	},
	{
		action = "Zoom In",
		defaultKey = "Alt+End",
		callback = function()
			zoomIn()
		end
	},
	{
		action = "Zoom Out",
		defaultKey = "Alt+Home",
		callback = function()
			zoomOut()
		end
	}
}

local function var_0_14()
	local rootPanel = modules.game_interface.getRootPanel()

	for _, path in ipairs(MINIMAP_OTMM_FALLBACK_PATHS) do
		Keybind.new(MINIMAP_OTMM_PATH, path.action, path.defaultKey, "")
		Keybind.bind(MINIMAP_OTMM_PATH, path.action, {
			{
				type = KEY_DOWN,
				callback = path.callback
			}
		}, rootPanel)
	end
end

local function var_0_15()
	for unusedValue, entry in ipairs(MINIMAP_OTMM_FALLBACK_PATHS) do
		Keybind.delete(MINIMAP_OTMM_PATH, entry.action)
	end
end

local unusedValue = "/assets/minimap/minimap.otmm"
local MINIMAP_OTMM_FALLBACK_PATHS = {
	"/assets/minimap/minimap.otmm",
	"/minimap/minimap.otmm"
}
local BUNDLED_MARKERS_PATH = "/minimap/markers.json"

local function normalizeFsPath(path)
	if not path or path == "" then
		return ""
	end

	path = path:gsub("\\", "/"):gsub("/+$", "")

	return path:lower()
end

local function isWriteDirPath(realDir, writeDir)
	local normalizedReal = normalizeFsPath(realDir)
	local normalizedWrite = normalizeFsPath(writeDir)

	return normalizedReal ~= "" and normalizedReal == normalizedWrite
end

local function loadMinimapOtmm()
	if not g_minimap.loadOtmm then
		g_logger.warning("[game_minimap] g_minimap.loadOtmm is not available")

		return nil
	end

	local writeDir = g_resources.getWriteDir()
	local foundAny = false
	local foundBundled = false

	for _, path in ipairs(MINIMAP_OTMM_FALLBACK_PATHS) do
		if not g_resources.fileExists(path) then
			-- block empty
		else
			foundAny = true

			local realDir = g_resources.getRealDir(path)

			if isWriteDirPath(realDir, writeDir) then
				-- block empty
			else
				foundBundled = true

				if g_minimap.loadOtmm(path) then
					g_logger.info(string.format("[game_minimap] OTMM loaded from %s", path))

					return path
				end

				g_logger.warning(string.format("[game_minimap] loadOtmm failed for %s", path))
			end
		end
	end

	if not foundAny then
		g_logger.warning("[game_minimap] minimap.otmm not found in bundled paths")
	elseif not foundBundled then
		g_logger.warning("[game_minimap] minimap.otmm only found in user write dir; bundled load skipped")
	else
		g_logger.warning("[game_minimap] minimap.otmm found but failed to load (corrupt or unsupported version)")
	end

	return nil
end

function applyBundledMarkers(minimapWidget)
	if not minimapWidget or minimapWidget:isDestroyed() then
		return 0
	end

	minimapWidget:clearBundledFlags()

	local total = minimapWidget:loadBundledMarkerData(BUNDLED_MARKERS_PATH)

	if total == 0 and g_resources.fileExists(BUNDLED_MARKERS_PATH) then
		g_logger.warning(string.format("[game_minimap] Failed to parse bundled markers from %s", BUNDLED_MARKERS_PATH))

		return 0
	end

	g_logger.info(string.format("[game_minimap] Bundled markers: %d loaded from %s (visible set updates with camera)", total, BUNDLED_MARKERS_PATH))
	minimapWidget:scheduleBundledFlagsRefresh()

	return total
end

local function loadBundledMinimapMarkers()
	local minimap = mapController.ui and mapController.ui.minimapBorder and mapController.ui.minimapBorder.minimap

	applyBundledMarkers(minimap)
end

function loadPersistentMinimapData()
	if persistentMinimapDataLoaded then
		return true
	end

	local ui = mapController.ui
	local minimap = ui and not ui:isDestroyed() and ui.minimapBorder and ui.minimapBorder.minimap

	if not minimap or minimap:isDestroyed() then
		return false
	end

	local startedAt = g_clock.realMillis()

	g_minimap.clean()
	loadMinimapOtmm()
	minimap:load()
	loadBundledMinimapMarkers()

	persistentMinimapDataLoaded = true

	g_logger.info(string.format("[login] persistent minimap data ready in %d ms", g_clock.realMillis() - startedAt))

	return true
end

local function layerMarginTopForFloor(z)
	z = math.max(LAYER_FLOOR_MIN, math.min(LAYER_FLOOR_MAX, z))

	return (z + 1) * 4 - 4
end

local function refreshVirtualFloors()
	local layersPanel = mapController.ui and mapController.ui.layersPanel

	if not layersPanel or layersPanel:isDestroyed() then
		return
	end

	local mark = layersPanel:getChildById("layersMark")

	if not mark or mark:isDestroyed() then
		return
	end

	mark:setMarginTop(layerMarginTopForFloor(virtualFloor))
end

local function setupLayersMarkDrag(mark)
	if not mark or mark:isDestroyed() then
		return
	end

	function mark.onMousePress(widget, pos, button)
		if button == MouseLeftButton then
			dragStartMouseY = pos.y
			dragStartMargin = layerMarginTopForFloor(virtualFloor)
		end
	end

	function mark.onMouseMove(widget, mousePos, mouseMoved)
		if not widget:isPressed() then
			return
		end

		local dyTotal = mousePos.y - dragStartMouseY
		local rawMargin = dragStartMargin + dyTotal
		local minM = layerMarginTopForFloor(LAYER_FLOOR_MIN)
		local maxM = layerMarginTopForFloor(LAYER_FLOOR_MAX)
		local rawMargin = math.max(minM, math.min(maxM, rawMargin))
		local newFloor = math.floor(rawMargin / 4)

		if newFloor ~= virtualFloor then
			local mini = mapController.ui.minimapBorder.minimap

			while newFloor > virtualFloor do
				if not mini:floorDown() then
					break
				end

				virtualFloor = virtualFloor + 1
			end

			while newFloor < virtualFloor do
				if not mini:floorUp() then
					break
				end

				virtualFloor = virtualFloor - 1
			end
		end

		widget:setMarginTop(rawMargin)
	end

	function mark.onMouseRelease(widget, pos, button)
		if button == MouseLeftButton then
			refreshVirtualFloors()
		end
	end
end

local function setupLayersPanelWheel(layersPanel)
	if not layersPanel or layersPanel:isDestroyed() then
		return
	end

	local automapLayers = layersPanel:getChildById("automapLayers")

	if not automapLayers or automapLayers:isDestroyed() then
		return
	end

	local function onLayersWheel(widget, mousePos, direction)
		if not automapLayers:containsPoint(mousePos) then
			return false
		end

		if direction == MouseWheelUp then
			upLayer()
		elseif direction == MouseWheelDown then
			downLayer()
		end

		return true
	end

	layersPanel.onMouseWheel = onLayersWheel

	for _, child in ipairs(layersPanel:getChildren()) do
		child.onMouseWheel = onLayersWheel
	end
end

local function onPositionChange()
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local pos = player:getPosition()

	if not pos then
		return
	end

	local minimapWidget = mapController.ui.minimapBorder.minimap

	if not minimapWidget or minimapWidget:isDragging() then
		return
	end

	if not minimapWidget.fullMapView then
		minimapWidget:setCameraPosition(pos)
		minimapWidget:scheduleBundledFlagsRefresh()
	end

	minimapWidget:setCrossPosition(pos)

	virtualFloor = pos.z

	refreshVirtualFloors()
end

local function onUpdatePlayerPartyPosition(playerName, vocationId, position, isLeader)
	local mini = mapController and mapController.ui and mapController.ui.minimapBorder and mapController.ui.minimapBorder.minimap

	if not mini or mini:isDestroyed() then
		return
	end

	if not playerName or not position then
		return
	end

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and localPlayer:getName() == playerName then
		return
	end

	mini:setPartyMemberPosition(playerName, vocationId, {
		x = position.x,
		y = position.y,
		z = position.z
	}, isLeader)
end

mapController = Controller:new()

mapController:setUI("minimap", modules.game_interface.getMainRightPanel())

local function getLayoutRoot(ui, horizontal)
	if not ui or ui:isDestroyed() then
		return nil
	end

	return ui:getChildById(horizontal and "layoutHorizontal" or "layoutDefault")
end

local function getLayoutWidget(layoutRoot, widgetId)
	if not layoutRoot or layoutRoot:isDestroyed() then
		return nil
	end

	return layoutRoot:getChildById(widgetId)
end

local function findPhantomStyleBackground(ui)
	if not ui or ui:isDestroyed() then
		return nil
	end

	if ui._phantomStyleBackground and not ui._phantomStyleBackground:isDestroyed() then
		return ui._phantomStyleBackground
	end

	local children = ui:getChildren()

	for i = 1, #children do
		local child = children[i]

		if child and not child:isDestroyed() then
			local id = child:getId()

			if id ~= "layoutDefault" and id ~= "layoutHorizontal" and (child.getImageSource and child:getImageSource() or ""):find("/images/ui/background", 1, true) then
				ui._phantomStyleBackground = child

				return child
			end
		end
	end

	return nil
end

local function setPhantomStyleBackgroundVisible(ui, visible)
	local background = findPhantomStyleBackground(ui)

	if background then
		background:setVisible(visible)
	end
end

local function findMinimapWidget(ui)
	if not ui or ui:isDestroyed() then
		return nil
	end

	local defaultBorder = getLayoutWidget(getLayoutRoot(ui, false), "minimapBorder")
	local mini = defaultBorder and defaultBorder:getChildById("minimap")

	if mini and not mini:isDestroyed() then
		return mini
	end

	local horizontalBorder = getLayoutWidget(getLayoutRoot(ui, true), "minimapBorder")

	return horizontalBorder and horizontalBorder:getChildById("minimap")
end

local function syncMinimapLayoutAliases(layoutRoot)
	if not layoutRoot or layoutRoot:isDestroyed() then
		return nil
	end

	local var_33_0 = getLayoutWidget(getLayoutRoot(layoutRoot, false), "minimapBorder")
	local cavebotMinimap = var_33_0 and var_33_0:getChildById("cavebotMinimap")

	if cavebotMinimap and not cavebotMinimap:isDestroyed() then
		return cavebotMinimap
	end

	local var_33_2 = getLayoutWidget(getLayoutRoot(layoutRoot, true), "minimapBorder")

	return var_33_2 and var_33_2:getChildById("cavebotMinimap")
end

local function var_0_35(arg_34_0)
	if not arg_34_0 or arg_34_0:isDestroyed() then
		return
	end

	arg_34_0:load()

	if not arg_34_0.cavebotStandardFlagsLoaded then
		applyBundledMarkers(arg_34_0)

		arg_34_0.cavebotStandardFlagsLoaded = true
	else
		arg_34_0:scheduleBundledFlagsRefresh()
	end
end

local function var_0_36()
	if visible then
		local var_35_0 = syncMinimapLayoutAliases(mapController.ui)

		if var_35_0 and not var_35_0:isDestroyed() then
			return var_35_0
		end
	end

	return findMinimapWidget(mapController.ui)
end

local function var_0_37()
	local ui = mapController.ui

	if not ui or ui:isDestroyed() then
		return
	end

	for unusedValue, iter_36_1 in ipairs({
		false,
		true
	}) do
		local var_36_1 = getLayoutWidget(getLayoutRoot(ui, iter_36_1), "cavebotMap")

		if var_36_1 and not var_36_1:isDestroyed() then
			var_36_1:setOn(visible)
			var_36_1:setTooltip(tr(visible and "Show the regular minimap." or "Show the Cavebot route map."))
		end
	end
end

local function var_0_38()
	local var_37_0 = findMinimapWidget(mapController.ui)
	local var_37_1 = syncMinimapLayoutAliases(mapController.ui)

	if var_37_0 and not var_37_0:isDestroyed() then
		var_37_0:setVisible(not visible)

		if not visible then
			var_37_0:raise()
		end
	end

	if var_37_1 and not var_37_1:isDestroyed() then
		var_37_1:setVisible(visible)

		if visible then
			var_37_1:raise()
		end
	end

	var_0_37()
end

local function var_0_39(arg_38_0)
	local var_38_0 = findMinimapWidget(mapController.ui)
	local var_38_1 = syncMinimapLayoutAliases(mapController.ui)
	local game_helper = modules.game_helper
	local var_38_3 = visible

	arg_38_0 = arg_38_0 == true

	if arg_38_0 then
		var_0_35(var_38_1)

		local zoom = var_38_0 and not var_38_0:isDestroyed() and var_38_0:getZoom()

		visible = (var_38_1 and not var_38_1:isDestroyed() and game_helper and game_helper.setCavebotMinimapView and game_helper.setCavebotMinimapView(var_38_1, true)) == true

		if visible then
			if zoom then
				var_38_1:setZoom(zoom)
			end

			local localPlayer = g_game.getLocalPlayer()

			if localPlayer then
				virtualFloor = localPlayer:getPosition().z
			end
		end
	else
		if var_38_3 and var_38_0 and not var_38_0:isDestroyed() and var_38_1 and not var_38_1:isDestroyed() then
			local zoom = var_38_1:getZoom()

			if zoom then
				var_38_0:setZoom(zoom)
			end
		end

		if game_helper and game_helper.setCavebotMinimapView then
			game_helper.setCavebotMinimapView(var_38_1, false)
		end

		visible = false
	end

	var_0_38()
	refreshVirtualFloors()

	return visible == arg_38_0
end

local function var_0_40(layoutRoot)
	local ui = mapController.ui

	if not ui or ui:isDestroyed() or not layoutRoot or layoutRoot:isDestroyed() then
		return
	end

	ui.minimapBorder = getLayoutWidget(layoutRoot, "minimapBorder")
	ui.layersPanel = getLayoutWidget(layoutRoot, "layersPanel")
	ui.minimapControls = getLayoutWidget(layoutRoot, "minimapControls")
	ui.rosePanel = getLayoutWidget(layoutRoot, "rosePanel")
end

local function recalcMainRightPanelHeight()
	if modules.game_mainpanel and modules.game_mainpanel.reloadMainPanelSizes then
		modules.game_mainpanel.reloadMainPanelSizes()

		return
	end

	local mainRightPanel = modules.game_interface.getMainRightPanel()

	if not mainRightPanel or mainRightPanel:isDestroyed() then
		return
	end

	local usedHeight = mainRightPanel:getPaddingTop() + mainRightPanel:getPaddingBottom()
	local children = mainRightPanel:getChildren()

	for i = 1, #children do
		local child = children[i]

		if child and child:isExplicitlyVisible() then
			usedHeight = usedHeight + child:getHeight() + child:getMarginTop() + child:getMarginBottom()
		end
	end

	if usedHeight > 0 then
		mainRightPanel:setHeight(usedHeight)
	end
end

local function findMinimapDropTarget(window, mousePos)
	local root = g_ui.getRootWidget()

	if not root or not window then
		return nil
	end

	local children = root:recursiveGetChildrenByPos(mousePos)

	for i = 1, #children do
		local child = children[i]

		if child ~= window and child:getClassName() == "UIMiniWindowContainer" and type(child.onDrop) == "function" and child:onDrop(window, mousePos) then
			return child
		end
	end

	return nil
end

local minimapDragDockRefreshEvent

local function refreshMinimapDragDockLayout()
	minimapDragDockRefreshEvent = nil

	if modules.game_interface and modules.game_interface.refreshStatsBarDockLayout then
		modules.game_interface.refreshStatsBarDockLayout()
	end

	local ui = mapController.ui

	if ui and not ui:isDestroyed() and ui._horizontalDragActive then
		ui:raise()
	end

	addEvent(recalcMainRightPanelHeight)
end

local function queueMinimapDragDockLayoutRefresh()
	if minimapDragDockRefreshEvent then
		return
	end

	minimapDragDockRefreshEvent = addEvent(refreshMinimapDragDockLayout)
end

local function setupHorizontalDragHandle(handle)
	if not handle or handle:isDestroyed() then
		return
	end

	local window = mapController.ui

	if not window or window:isDestroyed() then
		return
	end

	function handle.onMousePress(_, mousePos, button)
		if button ~= MouseLeftButton then
			return false
		end

		window:raise()

		if window.onDragEnter then
			window:onDragEnter(mousePos)
		end

		window._horizontalDragActive = true

		queueMinimapDragDockLayoutRefresh()

		return true
	end

	function handle.onMouseMove(_, mousePos, mouseMoved)
		if not window._horizontalDragActive or not window.onDragMove then
			return false
		end

		local moved = window:onDragMove(mousePos, mouseMoved)

		queueMinimapDragDockLayoutRefresh()

		return moved
	end

	function handle.onMouseRelease(_, mousePos, button)
		if button ~= MouseLeftButton or not window._horizontalDragActive then
			return false
		end

		window._horizontalDragActive = false

		if window.onDragLeave then
			local dropped = findMinimapDropTarget(window, mousePos)

			window:onDragLeave(dropped, mousePos)
		end

		queueMinimapDragDockLayoutRefresh()

		return true
	end
end

local lastHorizontalSide

local function resolveHorizontalSide(container)
	local current = container

	for _ = 1, 12 do
		if not current then
			break
		end

		local id = current.getId and current:getId() or nil

		if id == "gameLeftTopPanel" then
			return "left"
		end

		if id == "gameRightTopPanel" then
			return "right"
		end

		current = current.getParent and current:getParent() or nil
	end

	return "right"
end

local function applyHorizontalControlsLayout(controls, mirror)
	if not controls or controls:isDestroyed() then
		return
	end

	local layerDown = controls:getChildById("layerDown")
	local zoomIn = controls:getChildById("zoomIn")
	local layerUp = controls:getChildById("layerUp")
	local zoomOut = controls:getChildById("zoomOut")

	if not layerDown or not zoomIn or not layerUp or not zoomOut then
		return
	end

	local layerDownId = layerDown:getId()
	local layerUpId = layerUp:getId()

	if mirror then
		layerDown:breakAnchors()
		layerDown:addAnchor(AnchorLeft, "parent", AnchorLeft)
		layerDown:addAnchor(AnchorBottom, "parent", AnchorBottom)
		zoomIn:breakAnchors()
		zoomIn:addAnchor(AnchorLeft, layerDownId, AnchorRight)
		zoomIn:addAnchor(AnchorBottom, "parent", AnchorBottom)
		zoomIn:setMarginLeft(2)
		zoomIn:setMarginRight(0)
		layerUp:breakAnchors()
		layerUp:addAnchor(AnchorLeft, "parent", AnchorLeft)
		layerUp:addAnchor(AnchorBottom, layerDownId, AnchorTop)
		layerUp:setMarginBottom(2)
		zoomOut:breakAnchors()
		zoomOut:addAnchor(AnchorLeft, layerUpId, AnchorRight)
		zoomOut:addAnchor(AnchorBottom, layerUpId, AnchorBottom)
		zoomOut:setMarginLeft(2)
		zoomOut:setMarginRight(0)
	else
		layerDown:breakAnchors()
		layerDown:addAnchor(AnchorRight, "parent", AnchorRight)
		layerDown:addAnchor(AnchorBottom, "parent", AnchorBottom)
		zoomIn:breakAnchors()
		zoomIn:addAnchor(AnchorRight, layerDownId, AnchorLeft)
		zoomIn:addAnchor(AnchorBottom, "parent", AnchorBottom)
		zoomIn:setMarginRight(2)
		zoomIn:setMarginLeft(0)
		layerUp:breakAnchors()
		layerUp:addAnchor(AnchorRight, "parent", AnchorRight)
		layerUp:addAnchor(AnchorBottom, layerDownId, AnchorTop)
		layerUp:setMarginBottom(2)
		zoomOut:breakAnchors()
		zoomOut:addAnchor(AnchorRight, layerUpId, AnchorLeft)
		zoomOut:addAnchor(AnchorBottom, layerUpId, AnchorBottom)
		zoomOut:setMarginRight(2)
		zoomOut:setMarginLeft(0)
	end
end

local function applyHorizontalPanelLayout(horizontalRoot, side)
	if not horizontalRoot or horizontalRoot:isDestroyed() then
		return
	end

	local borderId = "minimapBorder"
	local fullMap = getLayoutWidget(horizontalRoot, "fullMap")
	local var_50_2 = getLayoutWidget(horizontalRoot, "cavebotMap")
	local rose = getLayoutWidget(horizontalRoot, "minimapControls")
	local drag = getLayoutWidget(horizontalRoot, "rosePanel")
	local dragHandle = getLayoutWidget(horizontalRoot, "horizontalDragHandle")

	if not fullMap or not var_50_2 or not rose or not drag or not dragHandle then
		return
	end

	local mirror = side == "left"

	if mirror then
		var_50_2:breakAnchors()
		var_50_2:addAnchor(AnchorRight, borderId, AnchorRight)
		var_50_2:addAnchor(AnchorBottom, borderId, AnchorBottom)
		var_50_2:setMarginRight(3)
		var_50_2:setMarginLeft(0)
		var_50_2:setMarginBottom(3)
		fullMap:breakAnchors()
		fullMap:addAnchor(AnchorRight, var_50_2:getId(), AnchorLeft)
		fullMap:addAnchor(AnchorBottom, borderId, AnchorBottom)
		fullMap:setMarginRight(3)
		fullMap:setMarginLeft(0)
		fullMap:setMarginBottom(3)
		rose:breakAnchors()
		rose:addAnchor(AnchorLeft, borderId, AnchorLeft)
		rose:addAnchor(AnchorBottom, borderId, AnchorBottom)
		rose:setMarginLeft(3)
		rose:setMarginRight(0)
		rose:setMarginBottom(3)
		drag:breakAnchors()
		drag:addAnchor(AnchorTop, borderId, AnchorTop)
		drag:addAnchor(AnchorLeft, borderId, AnchorLeft)
		drag:setMarginTop(3)
		drag:setMarginLeft(3)
		drag:setMarginRight(0)
		dragHandle:breakAnchors()
		dragHandle:addAnchor(AnchorTop, borderId, AnchorTop)
		dragHandle:addAnchor(AnchorRight, borderId, AnchorRight)
		dragHandle:setMarginTop(1)
		dragHandle:setMarginRight(1)
		dragHandle:setMarginLeft(0)
		dragHandle:setImageSource("/images/ui/miniborder-top-right")
	else
		fullMap:breakAnchors()
		fullMap:addAnchor(AnchorLeft, borderId, AnchorLeft)
		fullMap:addAnchor(AnchorBottom, borderId, AnchorBottom)
		fullMap:setMarginLeft(3)
		fullMap:setMarginRight(0)
		fullMap:setMarginBottom(3)
		var_50_2:breakAnchors()
		var_50_2:addAnchor(AnchorLeft, fullMap:getId(), AnchorRight)
		var_50_2:addAnchor(AnchorBottom, borderId, AnchorBottom)
		var_50_2:setMarginLeft(3)
		var_50_2:setMarginRight(0)
		var_50_2:setMarginBottom(3)
		rose:breakAnchors()
		rose:addAnchor(AnchorRight, borderId, AnchorRight)
		rose:addAnchor(AnchorBottom, borderId, AnchorBottom)
		rose:setMarginRight(3)
		rose:setMarginLeft(0)
		rose:setMarginBottom(3)
		drag:breakAnchors()
		drag:addAnchor(AnchorTop, borderId, AnchorTop)
		drag:addAnchor(AnchorRight, borderId, AnchorRight)
		drag:setMarginTop(3)
		drag:setMarginRight(3)
		drag:setMarginLeft(0)
		dragHandle:breakAnchors()
		dragHandle:addAnchor(AnchorTop, borderId, AnchorTop)
		dragHandle:addAnchor(AnchorLeft, borderId, AnchorLeft)
		dragHandle:setMarginTop(1)
		dragHandle:setMarginLeft(1)
		dragHandle:setMarginRight(0)
		dragHandle:setImageSource("/images/ui/miniborder-top-left")
	end

	applyHorizontalControlsLayout(rose, mirror)

	lastHorizontalSide = side
end

local function applyLayoutMode(isHorizontal, container)
	local var_51_0 = mapController.ui

	if not var_51_0 or var_51_0:isDestroyed() then
		return
	end

	local ui = getLayoutRoot(var_51_0, false)
	local var_51_2 = getLayoutRoot(var_51_0, true)

	if not ui or ui:isDestroyed() or not var_51_2 or var_51_2:isDestroyed() then
		return
	end

	local showHorizontal = isHorizontal == true
	local var_51_4 = showHorizontal and resolveHorizontalSide(container) or nil
	local dragHandle = getLayoutWidget(var_51_2, "horizontalDragHandle")

	setPhantomStyleBackgroundVisible(var_51_0, not showHorizontal)

	if not showHorizontal and visible then
		var_0_39(false)
	end

	if ui:isVisible() == not showHorizontal and var_51_2:isVisible() == showHorizontal then
		if showHorizontal then
			if lastHorizontalSide ~= var_51_4 then
				applyHorizontalPanelLayout(var_51_2, var_51_4)
				addEvent(function()
					if var_51_0 and not var_51_0:isDestroyed() then
						var_51_0:updateLayout()
					end
				end)
			end

			if dragHandle and not dragHandle:isDestroyed() then
				dragHandle:raise()
			end
		else
			lastHorizontalSide = nil
		end

		return
	end

	local var_51_6 = findMinimapWidget(var_51_0)
	local var_51_7 = syncMinimapLayoutAliases(var_51_0)

	ui:setVisible(not showHorizontal)
	var_51_2:setVisible(showHorizontal)

	local var_51_8 = showHorizontal and var_51_2 or ui
	local var_51_9 = getLayoutWidget(var_51_8, "minimapBorder")

	if var_51_6 and not var_51_6:isDestroyed() and var_51_9 and not var_51_9:isDestroyed() and var_51_6:getParent() ~= var_51_9 then
		var_51_6:setParent(var_51_9)
		var_51_6:fill("parent")
		var_51_6:setMargin(1)
	end

	if var_51_7 and not var_51_7:isDestroyed() and var_51_9 and not var_51_9:isDestroyed() and var_51_7:getParent() ~= var_51_9 then
		var_51_7:setParent(var_51_9)
		var_51_7:fill("parent")
		var_51_7:setMargin(1)
	end

	var_0_40(var_51_8)
	var_0_38()

	if showHorizontal then
		applyHorizontalPanelLayout(var_51_2, var_51_4)
	else
		lastHorizontalSide = nil
	end

	if showHorizontal and dragHandle and not dragHandle:isDestroyed() then
		dragHandle:raise()
	end

	addEvent(function()
		if not var_51_0 or var_51_0:isDestroyed() then
			return
		end

		var_51_0:updateLayout()

		if not showHorizontal and var_51_0.minimapBorder and not var_51_0.minimapBorder:isDestroyed() then
			var_51_0.minimapBorder:setSize({
				height = 111,
				width = 108
			})
		end

		if showHorizontal and dragHandle and not dragHandle:isDestroyed() then
			dragHandle:raise()
		end
	end)
end

local function applyContainerLayout(container)
	if not container or container:isDestroyed() then
		return
	end

	local ui = mapController.ui

	if not ui or ui:isDestroyed() then
		return
	end

	local isHorizontal = container.isHorizontalPanel == true
	local defaultHeight = ui.panelHeight or 115

	if isHorizontal then
		local available = container:getHeight() - container:getPaddingTop() - container:getPaddingBottom()

		if available > 0 then
			ui:setHeight(available)
		end
	else
		ui:setHeight(defaultHeight)
	end

	applyLayoutMode(isHorizontal, container)
	addEvent(recalcMainRightPanelHeight)
end

local function adjustMinimapToContainer(_, container)
	applyContainerLayout(container)
end

function onChangeWorldTime(hour, minute)
	currentDayTime = {
		h = hour % 24,
		m = minute
	}

	mapController:scheduleEvent(function()
		local nextH = currentDayTime.h
		local nextM = currentDayTime.m + 12

		if nextM >= 60 then
			nextH = nextH + 1
			nextM = nextM - 60
		end

		onChangeWorldTime(nextH, nextM)
	end, 30000, "dayTime")

	local position = math.floor(0.08611111111111111 * (hour * 60 + minute))
	local mainWidth = 31
	local secondaryWidth = 0

	if position + 31 >= 124 then
		secondaryWidth = position + 31 - 124 + 1
		mainWidth = 31 - secondaryWidth
	end

	local function applyWorldTimeToRose(rosePanel)
		if not rosePanel or rosePanel:isDestroyed() then
			return
		end

		local ambients = rosePanel.ambients

		if not ambients or ambients:isDestroyed() then
			return
		end

		ambients.main:setWidth(mainWidth)
		ambients.secondary:setWidth(secondaryWidth)

		if secondaryWidth == 0 then
			ambients.secondary:hide()
		else
			ambients.secondary:setImageClip("0 0 " .. secondaryWidth .. " 31")
			ambients.secondary:show()
		end

		if mainWidth == 0 then
			ambients.main:hide()
		else
			ambients.main:setImageClip(position .. " 0 " .. mainWidth .. " 31")
			ambients.main:show()
		end
	end

	local ui = mapController.ui

	if ui and not ui:isDestroyed() then
		applyWorldTimeToRose(getLayoutWidget(getLayoutRoot(ui, false), "rosePanel"))
		applyWorldTimeToRose(getLayoutWidget(getLayoutRoot(ui, true), "rosePanel"))
	end
end

function mapController.onInit(self)
	var_0_14()
	var_0_40(getLayoutRoot(self.ui, false))

	local mini = findMinimapWidget(self.ui)

	if mini and not mini:isDestroyed() then
		mini:getChildById("floorUpButton"):hide()
		mini:getChildById("floorDownButton"):hide()
		mini:getChildById("zoomInButton"):hide()
		mini:getChildById("zoomOutButton"):hide()
		mini:getChildById("resetButton"):hide()
	end

	local defaultLayers = getLayoutWidget(getLayoutRoot(self.ui, false), "layersPanel")
	local horizontalLayers = getLayoutWidget(getLayoutRoot(self.ui, true), "layersPanel")

	if defaultLayers then
		setupLayersMarkDrag(defaultLayers:getChildById("layersMark"))
		setupLayersPanelWheel(defaultLayers)
	end

	if horizontalLayers then
		setupLayersMarkDrag(horizontalLayers:getChildById("layersMark"))
		setupLayersPanelWheel(horizontalLayers)
	end

	setupHorizontalDragHandle(getLayoutWidget(getLayoutRoot(self.ui, true), "horizontalDragHandle"))

	self.ui.moveOnlyToMain = true
	self.ui.allowHorizontalDrop = true
	self.ui.onContainerChanged = adjustMinimapToContainer

	local topBar = self.ui:recursiveGetChildById("miniwindowTopBar")

	if topBar and not topBar:isDestroyed() then
		topBar:setPhantom(false)
		topBar:raise()
	end

	applyContainerLayout(self.ui:getParent())
	var_0_39(false)
end

function mapController.onGameStart(self)
	var_0_39(false)
	mapController:registerEvents(g_game, {
		onChangeWorldTime = onChangeWorldTime,
		onUpdatePlayerPartyPosition = onUpdatePlayerPartyPosition
	})
	mapController:registerEvents(LocalPlayer, {
		onPositionChange = onPositionChange
	}):execute()
	self.ui:setupOnStart()
	addEvent(function()
		if self.ui and not self.ui:isDestroyed() then
			applyContainerLayout(self.ui:getParent())
		end
	end)
	loadPersistentMinimapData()

	local minimap = self.ui.minimapBorder and self.ui.minimapBorder.minimap

	if minimap and not minimap:isDestroyed() then
		minimap:clearPartyMembers()
	end
end

function mapController.onGameEnd(self)
	var_0_39(false)

	local minimap = self.ui.minimapBorder.minimap

	minimap:save()
	minimap:clearPartyMembers()
end

function mapController.onTerminate(unusedArgument)
	var_0_39(false)
	var_0_15()

	persistentMinimapDataLoaded = false
end

function zoomIn()
	local var_64_0 = var_0_36()

	if var_64_0 then
		var_64_0:zoomIn()
	end
end

function zoomOut()
	local var_65_0 = var_0_36()

	if var_65_0 then
		var_65_0:zoomOut()
	end
end

function toggleCavebotMap()
	return var_0_39(not visible)
end

function getMinimapZoomLevel()
	local minimap = mapController.ui and mapController.ui.minimapBorder and mapController.ui.minimapBorder.minimap

	if minimap and not minimap:isDestroyed() then
		return minimap:getZoom()
	end

	return nil
end

function setMinimapZoomLevel(zoom)
	local minimap = mapController.ui and mapController.ui.minimapBorder and mapController.ui.minimapBorder.minimap

	if minimap and not minimap:isDestroyed() and type(zoom) == "number" then
		minimap.zoomMinimap = zoom

		minimap:setZoom(zoom)
	end
end

function fullscreen()
	local minimapWidget = mapController.ui.minimapBorder.minimap or fullscreenWidget
	local zoom

	if not minimapWidget then
		return
	end

	if minimapWidget.fullMapView then
		fullscreenWidget = nil

		minimapWidget:setParent(mapController.ui.minimapBorder)
		minimapWidget:fill("parent")
		mapController.ui:show()

		zoom = minimapWidget.zoomMinimap

		g_keyboard.unbindKeyDown("Escape")

		minimapWidget.fullMapView = false
	else
		fullscreenWidget = minimapWidget

		mapController.ui:hide(true)
		minimapWidget:setParent(modules.game_interface.getRootPanel())
		minimapWidget:fill("parent")

		zoom = minimapWidget.zoomFullmap

		g_keyboard.bindKeyDown("Escape", fullscreen)

		minimapWidget.fullMapView = true
	end

	local pos = oldPos or minimapWidget:getCameraPosition()

	oldPos = minimapWidget:getCameraPosition()

	minimapWidget:setZoom(zoom)
	minimapWidget:setCameraPosition(pos)
end

function upLayer()
	if virtualFloor == LAYER_FLOOR_MIN then
		return
	end

	local var_70_0 = var_0_36()

	if not var_70_0 then
		return
	end

	var_70_0:floorUp()

	virtualFloor = virtualFloor - 1

	refreshVirtualFloors()
end

function downLayer()
	if virtualFloor == LAYER_FLOOR_MAX then
		return
	end

	local var_71_0 = var_0_36()

	if not var_71_0 then
		return
	end

	var_71_0:floorDown()

	virtualFloor = virtualFloor + 1

	refreshVirtualFloors()
end

function onClickRoseButton(dir, arg_72_1)
	arg_72_1 = arg_72_1 or 1

	local var_72_0 = var_0_36()

	if not var_72_0 then
		return
	end

	if dir == "north" then
		var_72_0:move(0, arg_72_1)
	elseif dir == "north-east" then
		var_72_0:move(-arg_72_1, arg_72_1)
	elseif dir == "east" then
		var_72_0:move(-arg_72_1, 0)
	elseif dir == "south-east" then
		var_72_0:move(-arg_72_1, -arg_72_1)
	elseif dir == "south" then
		var_72_0:move(0, -arg_72_1)
	elseif dir == "south-west" then
		var_72_0:move(arg_72_1, -arg_72_1)
	elseif dir == "west" then
		var_72_0:move(arg_72_1, 0)
	elseif dir == "north-west" then
		var_72_0:move(arg_72_1, arg_72_1)
	end
end

function resetMap()
	local var_73_0 = var_0_36()

	if not var_73_0 then
		return
	end

	var_73_0:reset()

	local player = g_game.getLocalPlayer()

	if player then
		virtualFloor = player:getPosition().z

		refreshVirtualFloors()
	end
end

function getMiniMapUi()
	return mapController.ui.minimapBorder.minimap
end
