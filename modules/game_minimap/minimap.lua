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
local MINIMAP_KEYBIND_CATEGORY = "Minimap"
local MINIMAP_HOTKEY_PAN_DISTANCE = 12
local MINIMAP_KEYBIND_ACTIONS = {
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
			onClickRoseButton("east", MINIMAP_HOTKEY_PAN_DISTANCE)
		end
	},
	{
		action = "Scroll North",
		defaultKey = "Alt+Up",
		callback = function()
			onClickRoseButton("north", MINIMAP_HOTKEY_PAN_DISTANCE)
		end
	},
	{
		action = "Scroll South",
		defaultKey = "Alt+Down",
		callback = function()
			onClickRoseButton("south", MINIMAP_HOTKEY_PAN_DISTANCE)
		end
	},
	{
		action = "Scroll West",
		defaultKey = "Alt+Left",
		callback = function()
			onClickRoseButton("west", MINIMAP_HOTKEY_PAN_DISTANCE)
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

local function bindMinimapKeybinds()
	local rootPanel = modules.game_interface.getRootPanel()

	for _, path in ipairs(MINIMAP_KEYBIND_ACTIONS) do
		Keybind.new(MINIMAP_KEYBIND_CATEGORY, path.action, path.defaultKey, "")
		Keybind.bind(MINIMAP_KEYBIND_CATEGORY, path.action, {
			{
				type = KEY_DOWN,
				callback = path.callback
			}
		}, rootPanel)
	end
end

local function unbindMinimapKeybinds()
	for unusedValue, entry in ipairs(MINIMAP_KEYBIND_ACTIONS) do
		Keybind.delete(MINIMAP_KEYBIND_CATEGORY, entry.action)
	end
end

local unusedValue = "/assets/minimap/minimap.otmm"
local MINIMAP_KEYBIND_ACTIONS = {
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

	for _, path in ipairs(MINIMAP_KEYBIND_ACTIONS) do
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

	local minimapBorder = getLayoutWidget(getLayoutRoot(layoutRoot, false), "minimapBorder")
	local cavebotMinimap = minimapBorder and minimapBorder:getChildById("cavebotMinimap")

	if cavebotMinimap and not cavebotMinimap:isDestroyed() then
		return cavebotMinimap
	end

	local horizontalMinimapBorder = getLayoutWidget(getLayoutRoot(layoutRoot, true), "minimapBorder")

	return horizontalMinimapBorder and horizontalMinimapBorder:getChildById("cavebotMinimap")
end

local function loadCavebotMinimapMarkers(cavebotMinimap)
	if not cavebotMinimap or cavebotMinimap:isDestroyed() then
		return
	end

	cavebotMinimap:load()

	if not cavebotMinimap.cavebotStandardFlagsLoaded then
		applyBundledMarkers(cavebotMinimap)

		cavebotMinimap.cavebotStandardFlagsLoaded = true
	else
		cavebotMinimap:scheduleBundledFlagsRefresh()
	end
end

local function getActiveMinimapWidget()
	if visible then
		local cavebotMinimap = syncMinimapLayoutAliases(mapController.ui)

		if cavebotMinimap and not cavebotMinimap:isDestroyed() then
			return cavebotMinimap
		end
	end

	return findMinimapWidget(mapController.ui)
end

local function updateCavebotMapToggleButtons()
	local ui = mapController.ui

	if not ui or ui:isDestroyed() then
		return
	end

	for unusedValue, isHorizontalLayout in ipairs({
		false,
		true
	}) do
		local cavebotMapButton = getLayoutWidget(getLayoutRoot(ui, isHorizontalLayout), "cavebotMap")

		if cavebotMapButton and not cavebotMapButton:isDestroyed() then
			cavebotMapButton:setOn(visible)
			cavebotMapButton:setTooltip(tr(visible and "Show the regular minimap." or "Show the Cavebot route map."))
		end
	end
end

local function updateMinimapViewVisibility()
	local regularMinimap = findMinimapWidget(mapController.ui)
	local cavebotMinimap = syncMinimapLayoutAliases(mapController.ui)

	if regularMinimap and not regularMinimap:isDestroyed() then
		regularMinimap:setVisible(not visible)

		if not visible then
			regularMinimap:raise()
		end
	end

	if cavebotMinimap and not cavebotMinimap:isDestroyed() then
		cavebotMinimap:setVisible(visible)

		if visible then
			cavebotMinimap:raise()
		end
	end

	updateCavebotMapToggleButtons()
end

local function setCavebotMapVisible(requestedVisible)
	local regularMinimap = findMinimapWidget(mapController.ui)
	local cavebotMinimap = syncMinimapLayoutAliases(mapController.ui)
	local game_helper = modules.game_helper
	local wasCavebotMapVisible = visible

	requestedVisible = requestedVisible == true

	if requestedVisible then
		loadCavebotMinimapMarkers(cavebotMinimap)

		local zoom = regularMinimap and not regularMinimap:isDestroyed() and regularMinimap:getZoom()

		visible = (cavebotMinimap and not cavebotMinimap:isDestroyed() and game_helper and game_helper.setCavebotMinimapView and game_helper.setCavebotMinimapView(cavebotMinimap, true)) == true

		if visible then
			if zoom then
				cavebotMinimap:setZoom(zoom)
			end

			local localPlayer = g_game.getLocalPlayer()

			if localPlayer then
				virtualFloor = localPlayer:getPosition().z
			end
		end
	else
		if wasCavebotMapVisible and regularMinimap and not regularMinimap:isDestroyed() and cavebotMinimap and not cavebotMinimap:isDestroyed() then
			local zoom = cavebotMinimap:getZoom()

			if zoom then
				regularMinimap:setZoom(zoom)
			end
		end

		if game_helper and game_helper.setCavebotMinimapView then
			game_helper.setCavebotMinimapView(cavebotMinimap, false)
		end

		visible = false
	end

	updateMinimapViewVisibility()
	refreshVirtualFloors()

	return visible == requestedVisible
end

local function updateMinimapLayoutAliases(layoutRoot)
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
	local cavebotMapButton = getLayoutWidget(horizontalRoot, "cavebotMap")
	local rose = getLayoutWidget(horizontalRoot, "minimapControls")
	local drag = getLayoutWidget(horizontalRoot, "rosePanel")
	local dragHandle = getLayoutWidget(horizontalRoot, "horizontalDragHandle")

	if not fullMap or not cavebotMapButton or not rose or not drag or not dragHandle then
		return
	end

	local mirror = side == "left"

	if mirror then
		cavebotMapButton:breakAnchors()
		cavebotMapButton:addAnchor(AnchorRight, borderId, AnchorRight)
		cavebotMapButton:addAnchor(AnchorBottom, borderId, AnchorBottom)
		cavebotMapButton:setMarginRight(3)
		cavebotMapButton:setMarginLeft(0)
		cavebotMapButton:setMarginBottom(3)
		fullMap:breakAnchors()
		fullMap:addAnchor(AnchorRight, cavebotMapButton:getId(), AnchorLeft)
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
		cavebotMapButton:breakAnchors()
		cavebotMapButton:addAnchor(AnchorLeft, fullMap:getId(), AnchorRight)
		cavebotMapButton:addAnchor(AnchorBottom, borderId, AnchorBottom)
		cavebotMapButton:setMarginLeft(3)
		cavebotMapButton:setMarginRight(0)
		cavebotMapButton:setMarginBottom(3)
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
	local minimapWindow = mapController.ui

	if not minimapWindow or minimapWindow:isDestroyed() then
		return
	end

	local ui = getLayoutRoot(minimapWindow, false)
	local horizontalLayout = getLayoutRoot(minimapWindow, true)

	if not ui or ui:isDestroyed() or not horizontalLayout or horizontalLayout:isDestroyed() then
		return
	end

	local showHorizontal = isHorizontal == true
	local horizontalSide = showHorizontal and resolveHorizontalSide(container) or nil
	local dragHandle = getLayoutWidget(horizontalLayout, "horizontalDragHandle")

	setPhantomStyleBackgroundVisible(minimapWindow, not showHorizontal)

	if not showHorizontal and visible then
		setCavebotMapVisible(false)
	end

	if ui:isVisible() == not showHorizontal and horizontalLayout:isVisible() == showHorizontal then
		if showHorizontal then
			if lastHorizontalSide ~= horizontalSide then
				applyHorizontalPanelLayout(horizontalLayout, horizontalSide)
				addEvent(function()
					if minimapWindow and not minimapWindow:isDestroyed() then
						minimapWindow:updateLayout()
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

	local regularMinimap = findMinimapWidget(minimapWindow)
	local cavebotMinimap = syncMinimapLayoutAliases(minimapWindow)

	ui:setVisible(not showHorizontal)
	horizontalLayout:setVisible(showHorizontal)

	local activeLayout = showHorizontal and horizontalLayout or ui
	local minimapBorder = getLayoutWidget(activeLayout, "minimapBorder")

	if regularMinimap and not regularMinimap:isDestroyed() and minimapBorder and not minimapBorder:isDestroyed() and regularMinimap:getParent() ~= minimapBorder then
		regularMinimap:setParent(minimapBorder)
		regularMinimap:fill("parent")
		regularMinimap:setMargin(1)
	end

	if cavebotMinimap and not cavebotMinimap:isDestroyed() and minimapBorder and not minimapBorder:isDestroyed() and cavebotMinimap:getParent() ~= minimapBorder then
		cavebotMinimap:setParent(minimapBorder)
		cavebotMinimap:fill("parent")
		cavebotMinimap:setMargin(1)
	end

	updateMinimapLayoutAliases(activeLayout)
	updateMinimapViewVisibility()

	if showHorizontal then
		applyHorizontalPanelLayout(horizontalLayout, horizontalSide)
	else
		lastHorizontalSide = nil
	end

	if showHorizontal and dragHandle and not dragHandle:isDestroyed() then
		dragHandle:raise()
	end

	addEvent(function()
		if not minimapWindow or minimapWindow:isDestroyed() then
			return
		end

		minimapWindow:updateLayout()

		if not showHorizontal and minimapWindow.minimapBorder and not minimapWindow.minimapBorder:isDestroyed() then
			minimapWindow.minimapBorder:setSize({
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
	bindMinimapKeybinds()
	updateMinimapLayoutAliases(getLayoutRoot(self.ui, false))

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
	setCavebotMapVisible(false)
end

function mapController.onGameStart(self)
	setCavebotMapVisible(false)
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
	setCavebotMapVisible(false)

	local minimap = self.ui.minimapBorder.minimap

	minimap:save()
	minimap:clearPartyMembers()
end

function mapController.onTerminate(unusedArgument)
	setCavebotMapVisible(false)
	unbindMinimapKeybinds()

	persistentMinimapDataLoaded = false
end

function zoomIn()
	local activeMinimap = getActiveMinimapWidget()

	if activeMinimap then
		activeMinimap:zoomIn()
	end
end

function zoomOut()
	local activeMinimap = getActiveMinimapWidget()

	if activeMinimap then
		activeMinimap:zoomOut()
	end
end

function toggleCavebotMap()
	return setCavebotMapVisible(not visible)
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

	local activeMinimap = getActiveMinimapWidget()

	if not activeMinimap then
		return
	end

	activeMinimap:floorUp()

	virtualFloor = virtualFloor - 1

	refreshVirtualFloors()
end

function downLayer()
	if virtualFloor == LAYER_FLOOR_MAX then
		return
	end

	local activeMinimap = getActiveMinimapWidget()

	if not activeMinimap then
		return
	end

	activeMinimap:floorDown()

	virtualFloor = virtualFloor + 1

	refreshVirtualFloors()
end

function onClickRoseButton(dir, panDistance)
	panDistance = panDistance or 1

	local activeMinimap = getActiveMinimapWidget()

	if not activeMinimap then
		return
	end

	if dir == "north" then
		activeMinimap:move(0, panDistance)
	elseif dir == "north-east" then
		activeMinimap:move(-panDistance, panDistance)
	elseif dir == "east" then
		activeMinimap:move(-panDistance, 0)
	elseif dir == "south-east" then
		activeMinimap:move(-panDistance, -panDistance)
	elseif dir == "south" then
		activeMinimap:move(0, -panDistance)
	elseif dir == "south-west" then
		activeMinimap:move(panDistance, -panDistance)
	elseif dir == "west" then
		activeMinimap:move(panDistance, 0)
	elseif dir == "north-west" then
		activeMinimap:move(panDistance, panDistance)
	end
end

function resetMap()
	local activeMinimap = getActiveMinimapWidget()

	if not activeMinimap then
		return
	end

	activeMinimap:reset()

	local player = g_game.getLocalPlayer()

	if player then
		virtualFloor = player:getPosition().z

		refreshVirtualFloors()
	end
end

function getMiniMapUi()
	return mapController.ui.minimapBorder.minimap
end
