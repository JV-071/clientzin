local statesOutft = {
	store = 1,
	available = 0
}
local pendingCyclopediaFocus
local activeCyclopediaPending
local cyclopediaViewMode = false
local restoreCyclopediaOnClose = false
local CYClOPEDIA_VIEW_TITLES = {
	mounts = "View Mounts",
	familiars = "View Familiars",
	outfits = "View Outfits"
}
local outfitwindowWidget
local podiumContext
local hirelingContext
local var_0_9
local colorModeGroup
local colorBoxGroup
local floor
local movementCheck
local showFloorCheck
local showOutfitCheck
local showFamiliarCheck
local podiumPlatformCheck
local podiumOutfitCheck
local showPlatformBeforeOutfitOff = true
local PODIUM_OPTION_ENABLED_COLOR = "#c0c0c0"
local PODIUM_OPTION_DISABLED_COLOR = "#707070"
local previewCreature
local previewFamiliar
local previewRow
local previewPodiumWidget
local previewPodiumItem
local podiumPreviewInitialized = false
local previewMovementWarmup = {
	retryMs = 16,
	token = 0
}
local pendingRenamePresetId
local ignoreNextOutfitWindow = 0
local floorTileWidth = 318
local floorTileHeight = 128
local floorTileColumns = 3
local floorTileRows = 3
local floorOffsetX = 0
local floorOffsetY = 0
local floorEventRunning = false
local floorRowWidgets = {}

local function getSelectionListGrid()
	if not outfitwindowWidget or not outfitwindowWidget.selectionList then
		return nil
	end

	local grid = outfitwindowWidget.selectionList.selectionListGrid

	if not grid or grid:isDestroyed() then
		return outfitwindowWidget.selectionList
	end

	return grid
end

local handleCheckChange = {
	ignoreCheck = false,
	index = 1,
	ranges = {
		{
			id = "filterDefault",
			max = 9999,
			min = 0
		},
		{
			id = "filterCustom",
			max = 19999,
			min = 10000
		},
		{
			id = "filterBattlePass",
			min = 20000
		}
	},
	rangeIndexForLookType = function(numericValue)
		numericValue = tonumber(numericValue) or 0

		if numericValue >= 20000 then
			return 3
		end

		if numericValue >= 10000 then
			return 2
		end

		return 1
	end
}

function handleCheckChange.lookTypeInRange(numericValue)
	numericValue = tonumber(numericValue) or 0

	local var_3_0 = handleCheckChange.ranges[handleCheckChange.index] or handleCheckChange.ranges[1]

	if numericValue < (var_3_0.min or 0) then
		return false
	end

	if var_3_0.max and numericValue > var_3_0.max then
		return false
	end

	return true
end

function handleCheckChange.setIndex(arg_4_0, arg_4_1)
	if arg_4_0 < 1 or arg_4_0 > #handleCheckChange.ranges then
		return
	end

	handleCheckChange.index = arg_4_0

	if not outfitwindowWidget or not outfitwindowWidget.listSearch then
		return
	end

	handleCheckChange.ignoreCheck = true

	for index, range in ipairs(handleCheckChange.ranges) do
		local var_4_0 = outfitwindowWidget.listSearch[range.id]

		if var_4_0 then
			var_4_0:setChecked(index == arg_4_0)
		end
	end

	handleCheckChange.ignoreCheck = false

	if arg_4_1 then
		handleCheckChange.apply()
	end
end

function handleCheckChange.onRangeCheckChange(arg_5_0, arg_5_1)
	if handleCheckChange.ignoreCheck or not arg_5_0 then
		return
	end

	local index = handleCheckChange.index

	for iter_5_0, range in ipairs(handleCheckChange.ranges) do
		if outfitwindowWidget.listSearch[range.id] == arg_5_0 then
			index = iter_5_0

			break
		end
	end

	if not arg_5_1 then
		handleCheckChange.setIndex(index, false)

		return
	end

	handleCheckChange.setIndex(index, true)
end

function handleCheckChange.bindRangeChecks()
	if not outfitwindowWidget or not outfitwindowWidget.listSearch then
		return
	end

	for unusedValue, range in ipairs(handleCheckChange.ranges) do
		local var_6_0 = outfitwindowWidget.listSearch[range.id]

		if var_6_0 then
			var_6_0.onCheckChange = handleCheckChange.onRangeCheckChange
		end
	end

	local var_6_1 = tempOutfit and tempOutfit.type

	if not var_6_1 or var_6_1 == 0 then
		local localPlayer = g_game.getLocalPlayer()
		local outfit = localPlayer and localPlayer:getOutfit()

		var_6_1 = outfit and outfit.type or 0
	end

	handleCheckChange.setIndex(handleCheckChange.rangeIndexForLookType(var_6_1), false)
end

local function getSelectionListFocusedChild()
	local var_7_0 = getSelectionListGrid()

	return var_7_0 and var_7_0:getFocusedChild() or nil
end

local function setSelectionListFocusHandler(handler)
	if outfitwindowWidget and outfitwindowWidget.selectionList then
		outfitwindowWidget.selectionList.onChildFocusChange = nil
	end

	local var_8_0 = getSelectionListGrid()

	if var_8_0 then
		var_8_0.onChildFocusChange = handler
	end
end

local function clearSelectionListFocus()
	local var_9_0 = getSelectionListGrid()

	if var_9_0 and var_9_0.focusChild then
		var_9_0:focusChild(nil)
	end
end

local function resetSelectionListScrollPosition()
	if not outfitwindowWidget or not outfitwindowWidget.selectionList then
		return
	end

	local selectionList = outfitwindowWidget.selectionList

	if selectionList.getVirtualOffset and selectionList.setVirtualOffset then
		local virtualOffset = selectionList:getVirtualOffset() or {
			x = 0,
			y = 0
		}

		virtualOffset.x = 0
		virtualOffset.y = 0

		selectionList:setVirtualOffset(virtualOffset)
	end

	if outfitwindowWidget.selectionScroll then
		outfitwindowWidget.selectionScroll:setValue(outfitwindowWidget.selectionScroll:getMinimum())
	end
end

function getCurrentGraphicsMode()
	local client_options = modules.client_options

	if not client_options or not client_options.getOption then
		return 0
	end

	return math.max(0, math.min(3, tonumber(client_options.getOption("antialiasingMode")) or 0))
end

function applyCreatureGraphicsMode(arg_12_0, arg_12_1)
	if not arg_12_0 or arg_12_0:isDestroyed() then
		return
	end

	arg_12_0:setAntiAliasingMode(arg_12_1 == nil and getCurrentGraphicsMode() or arg_12_1)
end

local var_0_45 = 20
local var_0_46 = 20
local selectionListBuildToken = 0
local selectionHydrationEvent
local SELECTION_CARD_HEIGHT = 102
local SELECTION_CARD_WIDTH = 108
local SELECTION_CARD_SPACING = 2
local SELECTION_HYDRATION_BUFFER_ROWS = 2
local SELECTION_HYDRATION_BATCH_SIZE = 8
local SELECTION_HYDRATION_MAX_ITEMS = 24
local OUTFIT_CLOSE_DESTROY_BATCH_SIZE = 12
local OUTFIT_CLOSE_CLEANUP_INTERVAL_MS = 16
local OUTFIT_CLOSE_LUA_GC_STEP_SIZE = 256

local function var_0_58(arg_13_0, arg_13_1)
	table.sort(arg_13_0, function(arg_14_0, arg_14_1)
		local available = arg_14_0[arg_13_1]

		if available == nil then
			available = statesOutft.available
		end

		local var_14_1 = arg_14_1[arg_13_1]

		if var_14_1 == nil then
			var_14_1 = statesOutft.available
		end

		local var_14_2 = available == statesOutft.available

		if var_14_2 ~= (var_14_1 == statesOutft.available) then
			return var_14_2
		end

		if arg_14_0[1] ~= arg_14_1[1] then
			return arg_14_0[1] < arg_14_1[1]
		end

		return tostring(arg_14_0[2] or "") < tostring(arg_14_1[2] or "")
	end)
end

local isSelectionListBuildStale
local selectionTextureCache = {
	hydrationToken = 0,
	hydratedButtons = {}
}
local outfitLuaGcEvent
local outfitLuaGcPassesRemaining = 0

local function clearSelectionHydrationEvent()
	selectionTextureCache.hydrationToken = selectionTextureCache.hydrationToken + 1

	if selectionHydrationEvent then
		removeEvent(selectionHydrationEvent)

		selectionHydrationEvent = nil
	end
end

function clearPreviewAnimationReadyEvent()
	previewMovementWarmup.token = previewMovementWarmup.token + 1

	if previewMovementWarmup.event then
		removeEvent(previewMovementWarmup.event)

		previewMovementWarmup.event = nil
	end
end

function selectionTextureCache.getButtonKey(button)
	return button and tostring(button:getId()) or ""
end

local function requestIncrementalOutfitGarbageCollection()
	outfitLuaGcPassesRemaining = math.max(outfitLuaGcPassesRemaining, 2)

	if outfitLuaGcEvent then
		return
	end

	local function collectNextStep()
		outfitLuaGcEvent = nil

		if collectgarbage("step", OUTFIT_CLOSE_LUA_GC_STEP_SIZE) then
			outfitLuaGcPassesRemaining = outfitLuaGcPassesRemaining - 1
		end

		if outfitLuaGcPassesRemaining > 0 then
			outfitLuaGcEvent = scheduleEvent(collectNextStep, OUTFIT_CLOSE_CLEANUP_INTERVAL_MS)
		end
	end

	outfitLuaGcEvent = scheduleEvent(collectNextStep, OUTFIT_CLOSE_CLEANUP_INTERVAL_MS)
end

local function appendDeferredDestroyChildren(children, container)
	if not container or container:isDestroyed() then
		return
	end

	local layout = container:getLayout()

	if layout then
		layout:disableUpdates()
	end

	for _, child in ipairs(container:getChildren()) do
		table.insert(children, child)
	end
end

local function destroyOutfitWindowIncrementally(win)
	if not win or win:isDestroyed() then
		requestIncrementalOutfitGarbageCollection()

		return
	end

	local children = {}
	local selectionList = win.selectionList
	local selectionGrid = selectionList and selectionList.selectionListGrid or selectionList
	local colorSection = win.appearance and win.appearance.colorSection
	local colorBackground = colorSection and colorSection.colorBoxBackground

	appendDeferredDestroyChildren(children, selectionGrid)
	appendDeferredDestroyChildren(children, colorBackground and colorBackground.colorBoxPanel)
	appendDeferredDestroyChildren(children, win.presetsList)

	local childIndex = 1
	local childCount = #children

	local function destroyNextBatch()
		if win:isDestroyed() then
			requestIncrementalOutfitGarbageCollection()

			return
		end

		local batchEnd = math.min(childIndex + OUTFIT_CLOSE_DESTROY_BATCH_SIZE - 1, childCount)

		for index = childIndex, batchEnd do
			local child = children[index]

			children[index] = nil

			if child and not child:isDestroyed() then
				child:destroy()
			end
		end

		childIndex = batchEnd + 1

		if childIndex <= childCount then
			scheduleEvent(destroyNextBatch, OUTFIT_CLOSE_CLEANUP_INTERVAL_MS)

			return
		end

		win:destroy()
		requestIncrementalOutfitGarbageCollection()
	end

	scheduleEvent(destroyNextBatch, OUTFIT_CLOSE_CLEANUP_INTERVAL_MS)
end

local function markSelectionButtonDeferred(button, outfitPayload)
	if not button then
		return
	end

	button.__selectionOutfitPayload = outfitPayload
	button.__selectionOutfitHydrated = false
	button.__selectionSheetsRequested = false
	button.__selectionTextureRequested = false
	selectionTextureCache.hydratedButtons[selectionTextureCache.getButtonKey(button)] = nil

	if button.outfit then
		button.outfit:setCreature(nil)
		button.outfit:setVisible(false)
	end
end

local function requestSelectionSpriteSheets(button, payload)
	if not button or button:isDestroyed() then
		return nil
	end

	local lookType = payload and payload.type or 0

	if lookType <= 0 then
		return nil
	end

	local thingType = g_things.getThingType(lookType, ThingCategoryCreature)

	if not thingType then
		return nil
	end

	if not button.__selectionSheetsRequested then
		thingType:prefetchSpriteSheetsForPreview(0)

		button.__selectionSheetsRequested = true
	end

	return thingType
end

local function requestVisibleSelectionTexture(button, payload)
	if not button or button:isDestroyed() or button.__selectionTextureRequested then
		return
	end

	local thingType = requestSelectionSpriteSheets(button, payload)

	if not thingType then
		return
	end

	thingType:prefetchTexturePhase(0)

	button.__selectionTextureRequested = true
end

local function hydrateSelectionButton(button)
	if not button or button:isDestroyed() then
		return false
	end

	local payload = button.__selectionOutfitPayload

	if not payload or not button.outfit then
		return false
	end

	if button.__selectionOutfitHydrated then
		button.outfit:setVisible(true)
		requestVisibleSelectionTexture(button, payload)

		return false
	end

	button.outfit:setOutfit(payload)

	local creature = button.outfit:getCreature()

	if creature then
		creature:setAnimate(true)

		if button.auraClientId and button.auraClientId > 0 then
			creature:setFixedAnimationTicks(100)
		end
	end

	requestSelectionSpriteSheets(button, payload)
	requestVisibleSelectionTexture(button, payload)

	button.__selectionOutfitHydrated = true
	selectionTextureCache.hydratedButtons[selectionTextureCache.getButtonKey(button)] = button

	button.outfit:setVisible(true)

	return true
end

function selectionTextureCache.dehydrateButton(button)
	if not button or not button.__selectionOutfitHydrated then
		return false
	end

	if not button:isDestroyed() and button.outfit then
		button.outfit:setVisible(false)
		button.outfit:setCreature(nil)
	end

	button.__selectionOutfitHydrated = false
	button.__selectionSheetsRequested = false
	button.__selectionTextureRequested = false
	selectionTextureCache.hydratedButtons[selectionTextureCache.getButtonKey(button)] = nil

	return true
end

function selectionTextureCache.releaseHydration()
	local hydrated = {}

	for _, button in pairs(selectionTextureCache.hydratedButtons) do
		table.insert(hydrated, button)
	end

	for _, button in ipairs(hydrated) do
		selectionTextureCache.dehydrateButton(button)
	end

	selectionTextureCache.hydratedButtons = {}
end

local function getSelectionHydrationWindow(totalCount, bufferRows)
	local panel = outfitwindowWidget and outfitwindowWidget.selectionList
	local grid = getSelectionListGrid()

	if not panel or not grid or totalCount <= 0 then
		return 1, 0
	end

	local viewportHeight = panel:getHeight() - panel:getPaddingTop() - panel:getPaddingBottom()

	if viewportHeight <= 0 then
		viewportHeight = panel:getHeight()
	end

	local gridWidth = grid:getWidth() - grid:getPaddingLeft() - grid:getPaddingRight()

	if gridWidth <= 0 then
		gridWidth = grid:getWidth()
	end

	local columns = math.max(1, math.floor((gridWidth + SELECTION_CARD_SPACING) / (SELECTION_CARD_WIDTH + SELECTION_CARD_SPACING)))
	local scrollY = 0

	if outfitwindowWidget and outfitwindowWidget.selectionScroll then
		scrollY = outfitwindowWidget.selectionScroll:getValue()
	end

	bufferRows = bufferRows == nil and SELECTION_HYDRATION_BUFFER_ROWS or bufferRows

	local firstVisibleRow = math.max(0, math.floor(scrollY / SELECTION_CARD_HEIGHT))
	local startRow = math.max(0, firstVisibleRow - bufferRows)
	local var_29_8 = firstVisibleRow + math.max(1, math.ceil(viewportHeight / SELECTION_CARD_HEIGHT)) + bufferRows
	local startIndex = startRow * columns + 1
	local endIndex = math.min(totalCount, (var_29_8 + 1) * columns)

	if startIndex <= endIndex then
		endIndex = math.min(endIndex, startIndex + SELECTION_HYDRATION_MAX_ITEMS - 1)
	end

	return startIndex, endIndex
end

local function scheduleSelectionListHydration(reason)
	clearSelectionHydrationEvent()

	local buildToken = selectionListBuildToken
	local hydrationToken = selectionTextureCache.hydrationToken

	local function updateHydration()
		selectionHydrationEvent = nil

		if isSelectionListBuildStale(buildToken) or hydrationToken ~= selectionTextureCache.hydrationToken then
			return
		end

		local grid = getSelectionListGrid()

		if not grid then
			return
		end

		local children = grid:getChildren()
		local visibleChildren = {}

		for _, child in ipairs(children) do
			if child:isVisible() then
				table.insert(visibleChildren, child)
			end
		end

		local totalCount = #visibleChildren

		if totalCount == 0 then
			selectionTextureCache.releaseHydration()

			return
		end

		local startIndex, endIndex = getSelectionHydrationWindow(totalCount)
		local visibleStartIndex, visibleEndIndex = getSelectionHydrationWindow(totalCount, 0)
		local desired = {}
		local focusedChild = getSelectionListFocusedChild()

		if focusedChild and focusedChild:isVisible() then
			desired[selectionTextureCache.getButtonKey(focusedChild)] = true
		end

		for index = visibleStartIndex, visibleEndIndex do
			local child = visibleChildren[index]

			if child then
				desired[selectionTextureCache.getButtonKey(child)] = true
			end
		end

		for index = visibleStartIndex, visibleEndIndex do
			hydrateSelectionButton(visibleChildren[index])
		end

		local staleButtons = {}

		for key, button in pairs(selectionTextureCache.hydratedButtons) do
			if not desired[key] then
				table.insert(staleButtons, button)
			end
		end

		for _, button in ipairs(staleButtons) do
			selectionTextureCache.dehydrateButton(button)
		end

		local pending = {}
		local focusedChild = getSelectionListFocusedChild()
		local focusedKey = selectionTextureCache.getButtonKey(focusedChild)

		if focusedChild and desired[focusedKey] and not focusedChild.__selectionOutfitHydrated then
			table.insert(pending, focusedChild)
		end

		for index = startIndex, endIndex do
			local child = visibleChildren[index]

			if child and selectionTextureCache.getButtonKey(child) ~= focusedKey and not child.__selectionOutfitHydrated then
				table.insert(pending, child)
			end
		end

		if #pending == 0 then
			return
		end

		local pendingIndex = 1

		local function hydrateBatch()
			if isSelectionListBuildStale(buildToken) or hydrationToken ~= selectionTextureCache.hydrationToken then
				return
			end

			local batchEnd = math.min(pendingIndex + SELECTION_HYDRATION_BATCH_SIZE - 1, #pending)

			for i = pendingIndex, batchEnd do
				local button = pending[i]

				requestSelectionSpriteSheets(button, button and button.__selectionOutfitPayload)
			end

			pendingIndex = batchEnd + 1

			if pendingIndex <= #pending then
				addEvent(hydrateBatch)

				return
			end
		end

		hydrateBatch()
	end

	if reason == "scroll" then
		updateHydration()
	else
		selectionHydrationEvent = scheduleEvent(updateHydration, 16)
	end
end

function handleCheckChange.apply()
	if not outfitwindowWidget or not outfitwindowWidget.selectionList then
		return
	end

	local items = getSelectionListGrid()

	if not items then
		return
	end

	local onChildFocusChange = items.onChildFocusChange

	items.onChildFocusChange = nil

	local text = ""

	if outfitwindowWidget.listSearch and outfitwindowWidget.listSearch.search then
		text = outfitwindowWidget.listSearch.search:getText():lower():trim()
	end

	local var_33_3 = outfitwindowWidget.listSearch and outfitwindowWidget.listSearch.onlyMine and outfitwindowWidget.listSearch.onlyMine:isChecked()

	for index, item in ipairs(items:getChildren()) do
		local id = item.auraClientId ~= nil or handleCheckChange.lookTypeInRange(item:getId())

		if id and var_33_3 and (not item.state or item.state ~= statesOutft.available) then
			id = false
		end

		if id and text:len() >= 1 and not (item.name and item.name:getText():lower() or ""):find(text) then
			id = false
		end

		item:setVisible(id)
	end

	local var_33_5 = getSelectionListFocusedChild()

	if var_33_5 then
		local id = tonumber(var_33_5:getId())
		local var_33_7 = tempOutfit and (id == tempOutfit.type or id == tempOutfit.mount or id == tempOutfit.familiar or id == ServerData.selectedAuraId)

		if not var_33_5:isVisible() or not var_33_7 then
			clearSelectionListFocus()
		end
	end

	items.onChildFocusChange = onChildFocusChange

	scheduleSelectionListHydration("filterSelectionList")
end

local function makeThumbnailStatic(uiCreature)
	applyCreatureGraphicsMode(uiCreature)

	local creature = uiCreature and uiCreature:getCreature()

	if creature then
		creature:setAnimate(true)
	end
end

local function var_0_74()
	selectionListBuildToken = selectionListBuildToken + 1

	return selectionListBuildToken
end

function isSelectionListBuildStale(buildToken)
	return not outfitwindowWidget or not outfitwindowWidget.selectionList or buildToken ~= selectionListBuildToken
end

local function buildSelectionListBatched(floorRowWidgets, buildItem, onComplete)
	local layout = getSelectionListGrid():getLayout()

	if layout then
		layout:disableUpdates()
	end

	local var_37_1 = selectionListBuildToken

	local function var_37_2()
		if isSelectionListBuildStale(var_37_1) then
			if layout then
				layout:enableUpdates()
			end

			return
		end

		if layout then
			layout:enableUpdates()

			if layout.update then
				layout:update()
			end
		end

		if onComplete then
			onComplete()
		end
	end

	local var_37_3 = #floorRowWidgets

	if var_37_3 <= var_0_46 then
		for index, tile in ipairs(floorRowWidgets) do
			buildItem(tile, index)
		end

		var_37_2()

		return
	end

	local var_37_4 = 1

	local function var_37_5()
		if isSelectionListBuildStale(var_37_1) then
			if layout then
				layout:enableUpdates()
			end

			return
		end

		local var_39_0 = math.min(var_37_4 + var_0_45 - 1, var_37_3)

		for iter_39_0 = var_37_4, var_39_0 do
			buildItem(floorRowWidgets[iter_39_0], iter_39_0)
		end

		var_37_4 = var_39_0 + 1

		if var_37_4 <= var_37_3 then
			addEvent(var_37_5)
		else
			var_37_2()
		end
	end

	var_37_5()
end

local function applyFloorRowScrollMargins()
	if not floorRowWidgets or #floorRowWidgets == 0 then
		return
	end

	for index, floorRowWidget in ipairs(floorRowWidgets) do
		local col = math.floor((index - 1) / floorTileColumns) + 1
		local var_40_1 = (index - 1) % floorTileColumns + 1

		floorRowWidget:setMarginTop((col - 1) * floorTileHeight - floorOffsetY)
		floorRowWidget:setMarginLeft((var_40_1 - 1) * floorTileWidth - floorOffsetX)
	end
end

local function resetFloorScrollOffsets()
	floorOffsetX = 0
	floorOffsetY = 0

	applyFloorRowScrollMargins()
end

local settingsFile = "/settings/outfit.json"
local settings = {}
local movementEnabledForSession = false
local outfitWindowDefaultWidth = 756
local outfitWindowDefaultHeight = 559
local outfitWindowDefaultMarginTop = 43
local outfitWindowCompactMarginTop = 32
local configurePanelDefaultHeight = 256
local var_0_86 = 256
local var_0_87 = 108
local missingFamiliarCompactionHeight = 22
local missingPresetCompactionHeight = 22
local hirelingWindowHeight = 471
local hirelingAppearanceCompactionHeight = 44
local defaultButtonImage = "/images/ui/1pixel-down-frame"
local storeButtonClipPressed = {
	iconGap = 4,
	storeRowTextExtraY = 3,
	textOffsetY = 1,
	icon = "/images/icons/icon-store-16x10",
	clipPressed = "0 20 230 20",
	clipNormal = "0 0 230 20",
	image = "/images/ui/outfits/button_store_mount",
	pressNudge = 1,
	iconFallbackW = 12
}
local storeNameRowLayoutBase = {}
local storeNameRowPressed = {}

local function appearanceNameRowUsesStoreChrome(widget)
	if not widget or widget:isDestroyed() then
		return false
	end

	local src = widget:getImageSource() or ""

	if src == storeButtonClipPressed.image then
		return true
	end

	return string.find(src, "button_store_mount", 1, true) ~= nil
end

local function storeNameRowLayoutBaseKey(widget)
	if not widget or widget:isDestroyed() then
		return ""
	end

	local parent = widget:getParent()

	if not parent or parent:isDestroyed() then
		return "noparent/" .. (widget:getId() or "name")
	end

	return parent:getId() .. "/" .. (widget:getId() or "name")
end

local function resetAppearanceNameRowStoreLayout(widget)
	if not widget or widget:isDestroyed() then
		return
	end

	local key = storeNameRowLayoutBaseKey(widget)

	storeNameRowLayoutBase[key] = nil
	storeNameRowPressed[key] = nil

	widget:setIconAlign(AlignNone)
	widget:setIconOffset(topoint("0 0"))
	widget:setTextAlign(AlignCenter)
	widget:setTextOffset(topoint("0 " .. storeButtonClipPressed.textOffsetY))
end

local function layoutStoreAppearanceNameRowCentered(widget)
	if not widget or widget:isDestroyed() then
		return
	end

	if not appearanceNameRowUsesStoreChrome(widget) then
		return
	end

	local clip = widget:getIconClip()
	local iconW = clip and clip.width or 0

	if iconW <= 0 then
		iconW = storeButtonClipPressed.iconFallbackW
	end

	local textW = widget:getTextSize().width
	local total = iconW + storeButtonClipPressed.iconGap + textW
	local w = widget:getWidth()
	local groupX = math.max(0, math.floor((w - total) / 2))

	widget:setIconAlign(AlignLeftCenter)
	widget:setIconOffset(topoint(groupX .. " 0"))
	widget:setTextAlign(AlignLeft)

	local textY = storeButtonClipPressed.textOffsetY + storeButtonClipPressed.storeRowTextExtraY
	local textX = groupX + iconW + storeButtonClipPressed.iconGap

	widget:setTextOffset(topoint(textX .. " " .. textY))

	local key = storeNameRowLayoutBaseKey(widget)

	storeNameRowLayoutBase[key] = {
		iconY = 0,
		iconX = groupX,
		textX = textX,
		textY = textY
	}

	if storeNameRowPressed[key] then
		setStoreAppearanceNameRowPressNudge(widget, true)
	end
end

local function setStoreAppearanceNameRowPressNudge(widget, pressed)
	if not widget or widget:isDestroyed() then
		return
	end

	local key = storeNameRowLayoutBaseKey(widget)

	if key == "" then
		return
	end

	if not pressed then
		storeNameRowPressed[key] = false
	end

	local b = storeNameRowLayoutBase[key]

	if not b then
		layoutStoreAppearanceNameRowCentered(widget)

		b = storeNameRowLayoutBase[key]
	end

	if not b then
		return
	end

	if pressed then
		storeNameRowPressed[key] = true
	end

	local d = pressed and storeButtonClipPressed.pressNudge or 0

	widget:setIconOffset(topoint(b.iconX + d .. " " .. b.iconY + d))
	widget:setTextOffset(topoint(b.textX + d .. " " .. b.textY + d))
end

local function scheduleStoreAppearanceNameRowReleaseSnap(widget)
	addEvent(function()
		if not widget or widget:isDestroyed() then
			return
		end

		if not appearanceNameRowUsesStoreChrome(widget) then
			return
		end

		local key = storeNameRowLayoutBaseKey(widget)

		if key == "" or storeNameRowPressed[key] then
			return
		end

		local b = storeNameRowLayoutBase[key]

		if not b then
			return
		end

		widget:setIconOffset(topoint(b.iconX .. " " .. b.iconY))
		widget:setTextOffset(topoint(b.textX .. " " .. b.textY))
	end)
end

local function scheduleLayoutStoreAppearanceNameRow(widget)
	addEvent(function()
		if not widget or widget:isDestroyed() or not appearanceNameRowUsesStoreChrome(widget) then
			return
		end

		layoutStoreAppearanceNameRowCentered(widget)
	end)
end

local outfitColorCache = {
	head = 0,
	feet = 0,
	legs = 0,
	body = 0
}
local mountColorCache = {
	head = 0,
	feet = 0,
	legs = 0,
	body = 0
}
local familiarColorCache = {
	head = 0,
	feet = 0,
	legs = 0,
	body = 0
}
local colorPickerProgrammatic = false

local function applyOutfitPreviewSpriteScale(spriteWidget)
	if not spriteWidget then
		return
	end

	applyCreatureGraphicsMode(spriteWidget)

	if not spriteWidget:getCreature() then
		return
	end

	spriteWidget:setCenter(false)
	spriteWidget:setFixedCreatureSize(false)
	spriteWidget:setCreatureSize(100)
	spriteWidget:setBaseScale(true)
end

local function setupPodiumPreviewWidget()
	if not previewRow then
		return false
	end

	previewPodiumWidget = previewRow:recursiveGetChildById("podiumPreview")

	if not previewPodiumWidget then
		return false
	end

	previewPodiumWidget:setVirtual(true)
	previewPodiumWidget:setPodiumPreview(true)
	previewPodiumWidget:setFixedItemSize(false)
	previewPodiumWidget:setSize("70 70")
	previewPodiumWidget:setItemVisible(false)

	podiumPreviewInitialized = true

	return true
end

local function getPodiumSourceThing(position, itemClientId)
	if modules.game_customisepodium and modules.game_customisepodium.currentThing then
		local thing = modules.game_customisepodium.currentThing

		if thing and thing.isPodium and thing:isPodium() then
			return thing
		end
	end

	if position then
		local tile = g_map.getTile(position)

		if tile then
			local thing = tile:getTopUseThing()

			if thing and thing.isPodium and thing:isPodium() then
				return thing
			end
		end
	end

	if itemClientId and itemClientId > 0 then
		return Item.create(itemClientId)
	end

	return nil
end

local function buildPodiumPreviewItem(thing, itemClientId)
	if thing and thing.isItem and thing:isItem() and thing.clone then
		return thing:clone()
	end

	if itemClientId and itemClientId > 0 then
		return Item.create(itemClientId)
	end

	return nil
end

local function restoreNormalPreviewCreatureLayout()
	if not previewCreature then
		return
	end

	previewCreature:breakAnchors()
	previewCreature:addAnchor(AnchorLeft, "parent", AnchorLeft)
	previewCreature:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
	previewCreature:setMarginLeft(0)
	previewCreature:setMarginTop(0)

	if previewRow and previewRow.updateLayout then
		previewRow:updateLayout()
	end
end

local function getPodiumPlatformElevation(item)
	if not item or not item.getId then
		return 0
	end

	local thingType = g_things.getThingType(item:getId(), ThingCategoryItem)

	if thingType and thingType.hasElevation and thingType:hasElevation() then
		return thingType:getElevation()
	end

	return 0
end

local function getPodiumShowOutfit()
	if podiumOutfitCheck then
		return podiumOutfitCheck:isChecked()
	end

	return settings.showOutfit ~= false
end

local function getPodiumShowMount()
	if not g_game.getFeature(GamePlayerMounts) then
		return false
	end

	if not outfitwindowWidget or not outfitwindowWidget.configure or not outfitwindowWidget.configure.mount or not outfitwindowWidget.configure.mount.check then
		return false
	end

	return outfitwindowWidget.configure.mount.check:isChecked()
end

local function getPodiumShowPlatform()
	if podiumPlatformCheck then
		return podiumPlatformCheck:isChecked()
	end

	if podiumContext then
		return podiumContext.showPlatform ~= false
	end

	return true
end

local function layoutPreviewCreatureForPodium(showPlatform, item)
	if not previewCreature then
		return
	end

	previewCreature:breakAnchors()
	previewCreature:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	previewCreature:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)

	if showPlatform then
		local elevation = getPodiumPlatformElevation(item or previewPodiumItem)
		local previewOffset = elevation > 0 and elevation * 2 or 12

		previewCreature:setMarginLeft(-previewOffset)
		previewCreature:setMarginTop(-previewOffset)
	else
		previewCreature:setMarginLeft(0)
		previewCreature:setMarginTop(0)
	end

	if previewRow and previewRow.updateLayout then
		previewRow:updateLayout()
	end
end

local function updatePodiumPreview()
	if not podiumContext or not podiumPreviewInitialized or not previewPodiumWidget then
		return
	end

	if not previewPodiumItem then
		previewPodiumItem = buildPodiumPreviewItem(podiumContext.sourceThing, podiumContext.itemClientId)
	end

	if not previewPodiumItem then
		previewPodiumWidget:setItemVisible(false)
		layoutPreviewCreatureForPodium(false, previewPodiumItem)

		return
	end

	local showPodium = podiumPlatformCheck and podiumPlatformCheck:isChecked()

	if showPodium == nil then
		showPodium = podiumContext.showPlatform ~= false
	end

	local direction = Directions.South

	if previewCreature and previewCreature:getCreature() then
		direction = previewCreature:getDirection()
	elseif podiumContext.direction then
		direction = podiumContext.direction
	end

	previewPodiumItem:setPodium({}, direction, showPodium, false)
	previewPodiumWidget:setItem(previewPodiumItem)
	previewPodiumWidget:setItemVisible(showPodium)
	layoutPreviewCreatureForPodium(showPodium, previewPodiumItem)
end

local function syncPreviewWalkingState()
	local walkingSpeed = not podiumContext and not hirelingContext and settings.movement and 1000 or 0
	local mainCreature = previewCreature and previewCreature:getCreature()

	if mainCreature then
		mainCreature:setStaticWalking(walkingSpeed)
	end

	if g_game.getFeature(GamePlayerFamiliars) then
		local familiarCreature = previewFamiliar and previewFamiliar:getCreature()

		if familiarCreature then
			familiarCreature:setStaticWalking(walkingSpeed)
		end
	end
end

local tempOutfit = {}
local didAcceptCustomize = false
local clipboardChangeWatchEvent
local lastClipboardChangeCount = 0
local ServerData = {
	selectedAuraClientId = 0,
	currentAuraClientId = 0,
	selectedAuraId = 0,
	currentOutfit = {},
	outfits = {},
	mounts = {},
	familiars = {},
	auras = {}
}

local function getPreferredInitialMountId(mounts)
	if table.empty(mounts) then
		return 0
	end

	for _, mountData in ipairs(mounts) do
		local state = mountData[3]

		if state == nil or state == statesOutft.available then
			return mountData[1]
		end
	end

	return mounts[1][1]
end

local function isPodiumMountShown()
	if not podiumContext or not tempOutfit then
		return false
	end

	return getPodiumShowMount() and (tempOutfit.mount or 0) > 0
end

local function podiumCreatureWouldDisplay()
	if not podiumContext then
		return false
	end

	return getPodiumShowOutfit() or isPodiumMountShown()
end

local function getEffectivePodiumShowPlatform()
	if not podiumCreatureWouldDisplay() then
		return true
	end

	return getPodiumShowPlatform()
end

local function syncShowPodiumOptionState()
	if not podiumContext or not podiumPlatformCheck then
		return
	end

	if podiumCreatureWouldDisplay() then
		podiumPlatformCheck:setEnabled(true)
		podiumPlatformCheck:setColor(PODIUM_OPTION_ENABLED_COLOR)

		local checked = podiumContext.showPlatform ~= false

		podiumPlatformCheck:setChecked(checked)

		podiumContext.showPlatform = checked

		return
	end

	podiumContext.showPlatform = true

	podiumPlatformCheck:setChecked(true)
	podiumPlatformCheck:setEnabled(false)
	podiumPlatformCheck:setColor(PODIUM_OPTION_DISABLED_COLOR)
end

local function ensurePodiumMountSelection()
	if not podiumContext or not tempOutfit or not getPodiumShowMount() then
		return
	end

	if (tempOutfit.mount or 0) > 0 or table.empty(ServerData.mounts) then
		return
	end

	tempOutfit.mount = getPreferredInitialMountId(ServerData.mounts)
end

local function getMountStateById(mountId)
	if not mountId or mountId < 1 or table.empty(ServerData.mounts) then
		return nil
	end

	for _, mountData in ipairs(ServerData.mounts) do
		if mountData[1] == mountId then
			return mountData[3]
		end
	end

	return nil
end

local function getMountOfferIdById(mountId)
	if not mountId or mountId < 1 or table.empty(ServerData.mounts) then
		return 0
	end

	for _, mountData in ipairs(ServerData.mounts) do
		if mountData[1] == mountId then
			return mountData[4] or 0
		end
	end

	return 0
end

local function getOutfitStateById(outfitId)
	return getMountStateById(outfitId) == statesOutft.available
end

local function var_0_133()
	if table.empty(ServerData.mounts) then
		return nil
	end

	for _, outfitData in ipairs(ServerData.mounts) do
		local var_72_0 = outfitData[3]

		if var_72_0 and var_72_0 ~= statesOutft.available then
			return outfitData
		end
	end

	return nil
end

local function initColorCachesFromOutfit()
	if podiumContext or hirelingContext then
		return
	end

	if not g_game.getFeature(GamePlayerMounts) then
		return
	end

	if getOutfitStateById(tempOutfit and tempOutfit.mount) then
		return
	end

	local var_73_0 = var_0_133()

	if not var_73_0 then
		return
	end

	tempOutfit.mount = var_73_0[1]
end

local function getOutfitOfferIdById(outfitId)
	if not outfitId or outfitId < 1 or table.empty(ServerData.outfits) then
		return nil
	end

	for _, outfitData in ipairs(ServerData.outfits) do
		if outfitData[1] == outfitId then
			return outfitData[4]
		end
	end

	return nil
end

local function var_0_136(lookType)
	if not lookType or lookType < 1 or table.empty(ServerData.outfits) then
		return 0
	end

	for _, outfitData in ipairs(ServerData.outfits) do
		if outfitData[1] == lookType then
			return outfitData[5] or 0
		end
	end

	return 0
end

function getOutfitNameByLookType(lookId)
	if not lookId or lookId < 1 or table.empty(ServerData.outfits) then
		return nil
	end

	for unusedValue, outfitData in ipairs(ServerData.outfits) do
		if outfitData[1] == lookId then
			return outfitData[2]
		end
	end

	return nil
end

local function redirectToStoreOffer(offerId)
	if offerId <= 0 then
		return
	end

	if outfitwindowWidget then
		destroy()
	end

	if modules and modules.game_store and modules.game_store.openOfferById then
		modules.game_store.openOfferById(offerId)

		return
	end

	g_game.openStore()
	addEvent(function()
		g_game.sendRequestStoreOfferById(offerId)
	end, 250)
end

function onOutfitNameClick()
	local outfitId = tempOutfit and tempOutfit.type or 0
	local var_79_1 = getOutfitOfferIdById(outfitId)
	local offerId = var_0_136(outfitId)

	if var_79_1 and var_79_1 ~= statesOutft.available and offerId > 0 then
		redirectToStoreOffer(offerId)
	end
end

function onMountNameClick()
	local mountId = tempOutfit and tempOutfit.mount or 0
	local var_80_1 = getMountStateById(mountId)
	local offerId = getMountOfferIdById(mountId)

	if var_80_1 and var_80_1 ~= statesOutft.available and offerId > 0 then
		redirectToStoreOffer(offerId)
	end
end

local function onMountNameMousePress(widget, mousePos, mouseButton)
	if mouseButton ~= MouseLeftButton then
		return false
	end

	widget:setImageClip(storeButtonClipPressed.clipPressed)
	setStoreAppearanceNameRowPressNudge(widget, true)

	return true
end

local function onMountNameMouseRelease(widget)
	return function(arg_83_0, mousePos, arg_83_2)
		if arg_83_2 ~= MouseLeftButton then
			return false
		end

		arg_83_0:setImageClip(storeButtonClipPressed.clipNormal)
		setStoreAppearanceNameRowPressNudge(arg_83_0, false)
		scheduleStoreAppearanceNameRowReleaseSnap(arg_83_0)

		if arg_83_0:containsPoint(mousePos) then
			widget()
		end

		return true
	end
end

local handleMouseRelease = onMountNameMouseRelease(onMountNameClick)
local onMouseRelease = onMountNameMouseRelease(onOutfitNameClick)

local function updateMountAppearanceNameVisual(mountId)
	if not outfitwindowWidget or not outfitwindowWidget.appearance or not outfitwindowWidget.appearance.settings or not outfitwindowWidget.appearance.settings.mount or not outfitwindowWidget.appearance.settings.mount.name then
		return
	end

	local name = outfitwindowWidget.appearance.settings.mount.name
	local var_84_1 = getMountStateById(mountId)
	local var_84_2 = getMountOfferIdById(mountId)

	if var_84_1 ~= nil and var_84_1 ~= statesOutft.available and var_84_2 > 0 then
		name:setImageSource(storeButtonClipPressed.image)
		name:setImageClip(storeButtonClipPressed.clipNormal)
		name:setIcon(storeButtonClipPressed.icon)
		name:setTooltip("Open store offer")
		name:setPhantom(false)
		name:setFocusable(true)

		name.onMousePress = onMountNameMousePress
		name.onMouseRelease = handleMouseRelease

		layoutStoreAppearanceNameRowCentered(name)
		scheduleLayoutStoreAppearanceNameRow(name)
	else
		name:setImageSource(defaultButtonImage)
		name:setImageClip(nil)
		name:setIcon("")
		resetAppearanceNameRowStoreLayout(name)
		name:setTooltip("")
		name:setPhantom(true)
		name:setFocusable(false)

		name.onMousePress = nil
		name.onMouseRelease = nil
	end
end

local function var_0_143(arg_85_0)
	if not outfitwindowWidget or not outfitwindowWidget.appearance or not outfitwindowWidget.appearance.settings or not outfitwindowWidget.appearance.settings.outfit or not outfitwindowWidget.appearance.settings.outfit.name then
		return
	end

	local name = outfitwindowWidget.appearance.settings.outfit.name
	local var_85_1 = getOutfitOfferIdById(arg_85_0)
	local var_85_2 = var_0_136(arg_85_0)

	if var_85_1 ~= nil and var_85_1 ~= statesOutft.available and var_85_2 > 0 then
		name:setImageSource(storeButtonClipPressed.image)
		name:setImageClip(storeButtonClipPressed.clipNormal)
		name:setIcon(storeButtonClipPressed.icon)
		name:setTooltip("Open store offer")
		name:setPhantom(false)
		name:setFocusable(true)

		name.onMousePress = onMountNameMousePress
		name.onMouseRelease = onMouseRelease

		layoutStoreAppearanceNameRowCentered(name)
		scheduleLayoutStoreAppearanceNameRow(name)
	else
		name:setImageSource(defaultButtonImage)
		name:setImageClip(nil)
		name:setIcon("")
		resetAppearanceNameRowStoreLayout(name)
		name:setTooltip("")
		name:setPhantom(true)
		name:setFocusable(false)

		name.onMousePress = nil
		name.onMouseRelease = nil
	end
end

local function var_0_144(arg_86_0)
	if not arg_86_0 then
		return
	end

	local h = arg_86_0.head or 0
	local b = arg_86_0.body or 0
	local l = arg_86_0.legs or 0
	local f = arg_86_0.feet or 0

	outfitColorCache = {
		head = h,
		body = b,
		legs = l,
		feet = f
	}

	local mh = arg_86_0.mountHead

	if mh == nil then
		mh = 0
	end

	local mb = arg_86_0.mountBody

	if mb == nil then
		mb = 0
	end

	local ml = arg_86_0.mountLegs

	if ml == nil then
		ml = 0
	end

	local mf = arg_86_0.mountFeet

	if mf == nil then
		mf = 0
	end

	mountColorCache = {
		head = mh,
		body = mb,
		legs = ml,
		feet = mf
	}
	familiarColorCache = {
		head = h,
		body = b,
		legs = l,
		feet = f
	}
end

local function applyGlobalColorCachesFromSettings()
	if settings and (settings.currentPreset or 0) > 0 then
		return
	end

	if settings and settings.outfitColorCache and type(settings.outfitColorCache) == "table" then
		local c = settings.outfitColorCache

		outfitColorCache = {
			head = c.head or 0,
			body = c.body or 0,
			legs = c.legs or 0,
			feet = c.feet or 0
		}
	end

	if g_game.getFeature(GamePlayerMounts) and settings and settings.mountColorCache and type(settings.mountColorCache) == "table" then
		local c = settings.mountColorCache

		mountColorCache = {
			head = c.head or 0,
			body = c.body or 0,
			legs = c.legs or 0,
			feet = c.feet or 0
		}
	end
end

local function getAppearanceCategoryName()
	if not var_0_9 or not outfitwindowWidget or not outfitwindowWidget.appearance or not outfitwindowWidget.appearance.settings then
		return "outfit"
	end

	local w = var_0_9:getSelectedWidget()

	if not w then
		return "outfit"
	end

	local parent = w:getParent()

	if not parent or not parent.getId then
		return "outfit"
	end

	return parent:getId() or "outfit"
end

local function getCreatureThingType(lookId)
	if not lookId or lookId < 1 then
		return nil
	end

	return g_things.getThingType(lookId, ThingCategoryCreature)
end

local function thingTypeHasVariableColors(thingType)
	if not thingType then
		return false
	end

	local ok, layers = pcall(function()
		return thingType:getLayers()
	end)

	return ok and layers and layers >= 2
end

local function headBodyForListThumbnail(lookId, cache)
	if not cache or not lookId or lookId < 1 then
		return 0, 0, 0, 0
	end

	if thingTypeHasVariableColors(getCreatureThingType(lookId)) then
		return cache.head or 0, cache.body or 0, cache.legs or 0, cache.feet or 0
	end

	return 0, 0, 0, 0
end

local function isColorContextActive()
	local app = getAppearanceCategoryName()

	if app == "preset" then
		return false
	end

	if app == "outfit" then
		return thingTypeHasVariableColors(getCreatureThingType(tempOutfit and tempOutfit.type))
	end

	if app == "mount" then
		if not g_game.getFeature(GamePlayerMounts) or not tempOutfit or (tempOutfit.mount or 0) < 1 then
			return false
		end

		return thingTypeHasVariableColors(getCreatureThingType(tempOutfit.mount))
	end

	if app == "familiar" then
		if not g_game.getFeature(GamePlayerFamiliars) or not tempOutfit or (tempOutfit.familiar or 0) < 1 then
			return false
		end

		return thingTypeHasVariableColors(getCreatureThingType(tempOutfit.familiar))
	end

	return false
end

local function getColorCacheForAppearance(app)
	if app == "mount" then
		return mountColorCache
	end

	if app == "familiar" then
		return familiarColorCache
	end

	return outfitColorCache
end

local function var_0_152()
	local var_95_0 = getSelectionListGrid()

	if not var_95_0 then
		return
	end

	local var_95_1 = getColorCacheForAppearance(getAppearanceCategoryName())

	if not var_95_1 then
		return
	end

	for unusedValue, child in ipairs(var_95_0:getChildren()) do
		local id = tonumber(child:getId())

		if id and id > 0 then
			local __selectionOutfitPayload = child.__selectionOutfitPayload

			if __selectionOutfitPayload then
				local head, body, legs, feet = headBodyForListThumbnail(id, var_95_1)

				__selectionOutfitPayload.head = head
				__selectionOutfitPayload.body = body
				__selectionOutfitPayload.legs = legs
				__selectionOutfitPayload.feet = feet

				if child.__selectionOutfitHydrated and child.outfit then
					child.outfit:setOutfit(__selectionOutfitPayload)
					makeThumbnailStatic(child.outfit)
				end
			end
		end
	end
end

local function getColorIdFromMode(cache, colorMode)
	if not cache or not colorMode then
		return 0
	end

	if colorMode == "head" then
		return cache.head or 0
	elseif colorMode == "primary" then
		return cache.body or 0
	elseif colorMode == "secondary" then
		return cache.legs or 0
	elseif colorMode == "detail" then
		return cache.feet or 0
	end

	return 0
end

local function applyColorIdToMode(cache, colorMode, colorId)
	if not cache or not colorMode then
		return
	end

	if colorMode == "head" then
		cache.head = colorId
	elseif colorMode == "primary" then
		cache.body = colorId
	elseif colorMode == "secondary" then
		cache.legs = colorId
	elseif colorMode == "detail" then
		cache.feet = colorId
	end
end

local function applyOutfitColorsToTemp()
	if not tempOutfit or not outfitColorCache then
		return
	end

	tempOutfit.head = outfitColorCache.head
	tempOutfit.body = outfitColorCache.body
	tempOutfit.legs = outfitColorCache.legs
	tempOutfit.feet = outfitColorCache.feet
end

local function applyMountColorsToOutfitTable(outfitTable)
	if not outfitTable then
		return
	end

	if not g_game.getFeature(GamePlayerMounts) or (outfitTable.mount or 0) < 1 then
		outfitTable.mountHead = 0
		outfitTable.mountBody = 0
		outfitTable.mountLegs = 0
		outfitTable.mountFeet = 0

		return
	end

	if thingTypeHasVariableColors(getCreatureThingType(outfitTable.mount)) then
		outfitTable.mountHead = mountColorCache.head
		outfitTable.mountBody = mountColorCache.body
		outfitTable.mountLegs = mountColorCache.legs
		outfitTable.mountFeet = mountColorCache.feet
	else
		outfitTable.mountHead = 0
		outfitTable.mountBody = 0
		outfitTable.mountLegs = 0
		outfitTable.mountFeet = 0
	end
end

local function syncTempOutfitFromSelection()
	if not outfitwindowWidget or not outfitwindowWidget.selectionList or not var_0_9 then
		return
	end

	local tabId = getAppearanceCategoryName()
	local focusedChild = getSelectionListFocusedChild()

	if not focusedChild or focusedChild:isDestroyed() then
		return
	end

	if tabId == "outfit" then
		local outfitType = tonumber(focusedChild:getId())

		if outfitType then
			tempOutfit.type = outfitType
		end
	elseif tabId == "mount" then
		tempOutfit.mount = tonumber(focusedChild:getId()) or 0
	elseif tabId == "familiar" then
		tempOutfit.familiar = tonumber(focusedChild:getId()) or 0
	elseif tabId == "aura" then
		ServerData.selectedAuraId = tonumber(focusedChild:getId()) or 0
		ServerData.selectedAuraClientId = focusedChild.auraClientId or 0
	end
end

local function buildOutfitPayloadForSend()
	syncTempOutfitFromSelection()
	applyOutfitColorsToTemp()

	local outfitToSend = tonumber(tempOutfit and tempOutfit.type) or 0

	if outfitToSend < 1 then
		local var_101_1 = getSelectionListFocusedChild()

		if var_101_1 then
			if var_101_1.selectionOutfitData then
				outfitToSend = tonumber(var_101_1.selectionOutfitData.type) or 0
			end

			if outfitToSend < 1 then
				outfitToSend = tonumber(var_101_1:getId()) or 0
			end
		end
	end

	local outfitToSend = {
		type = outfitToSend,
		auxType = tempOutfit.auxType or 0,
		head = tempOutfit.head or 0,
		body = tempOutfit.body or 0,
		legs = tempOutfit.legs or 0,
		feet = tempOutfit.feet or 0,
		addons = tempOutfit.addons or 0,
		mount = tonumber(tempOutfit.mount) or 0,
		familiar = tonumber(tempOutfit.familiar) or 0
	}

	if not getOutfitStateById(outfitToSend.mount) then
		outfitToSend.mount = 0
	end

	applyMountColorsToOutfitTable(outfitToSend)

	return outfitToSend
end

local function selectFirstColorBoxForDisabledState()
	if not outfitwindowWidget or not colorBoxGroup then
		return
	end

	local csec = outfitwindowWidget.appearance and outfitwindowWidget.appearance.colorSection
	local panel = csec and csec.colorBoxBackground and csec.colorBoxBackground.colorBoxPanel

	if not panel then
		return
	end

	local box0 = panel.colorBox0

	if not box0 then
		return
	end

	colorPickerProgrammatic = true

	colorBoxGroup:selectWidget(box0)

	colorPickerProgrammatic = false
end

local decodeCopyColoursCode
local unusedValue
local refreshColorBoxForCurrentContext
local setPasteButtonMode
local classifyPasteClipboardCode
local currentPasteMode = "colours"

local function updateColorControlsState()
	if not outfitwindowWidget or not outfitwindowWidget.appearance then
		return
	end

	local canColor = isColorContextActive()

	if outfitwindowWidget.appearance.colorSection and outfitwindowWidget.appearance.colorSection.colorBoxBackground and outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel and outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel.setEnabled then
		outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel:setEnabled(canColor)
	end

	if outfitwindowWidget.appearance.colorSection.colorMode then
		for _, c in pairs(outfitwindowWidget.appearance.colorSection.colorMode:getChildren()) do
			if c.setEnabled then
				c:setEnabled(canColor)
			end
		end
	end

	if outfitwindowWidget.appearance.colorSection then
		local overlay = outfitwindowWidget.appearance.colorSection.colorsDisabledOverlay

		if overlay and overlay.setVisible then
			overlay:setVisible(not canColor)
		end
	end

	if outfitwindowWidget.appearance.colorCopyButtons then
		local copyAllButton = outfitwindowWidget.appearance.colorCopyButtons.copyAll

		if copyAllButton and copyAllButton.setEnabled then
			copyAllButton:setEnabled(true)
		end

		local copyColoursButton = outfitwindowWidget.appearance.colorCopyButtons.copyColours

		if copyColoursButton and copyColoursButton.setEnabled then
			copyColoursButton:setEnabled(canColor)
		end

		local pasteColoursButton = outfitwindowWidget.appearance.colorCopyButtons.pasteColours

		if pasteColoursButton and pasteColoursButton.setEnabled then
			local hasValidClipboard = false
			local pasteMode = currentPasteMode

			if g_window and g_window.getClipboardText then
				local clipboardText = g_window.getClipboardText()
				local detectedMode = classifyPasteClipboardCode(clipboardText, canColor)

				if detectedMode == "all" then
					hasValidClipboard = true
					pasteMode = "all"
				elseif detectedMode == "colours" then
					hasValidClipboard = true
					pasteMode = "colours"
				end
			end

			if hasValidClipboard then
				setPasteButtonMode(pasteMode)
			end

			pasteColoursButton:setEnabled(hasValidClipboard)
		end
	end

	if not canColor then
		selectFirstColorBoxForDisabledState()
	end
end

local function stopClipboardChangeWatcher()
	if clipboardChangeWatchEvent then
		removeEvent(clipboardChangeWatchEvent)

		clipboardChangeWatchEvent = nil
	end
end

local function startClipboardChangeWatcher()
	stopClipboardChangeWatcher()

	if not g_window or not g_window.getClipboardChangeCount or not g_window.getPlatformType or not string.find(g_window.getPlatformType(), "WIN32", 1, true) then
		return
	end

	lastClipboardChangeCount = g_window.getClipboardChangeCount()

	local function watch()
		if not outfitwindowWidget then
			clipboardChangeWatchEvent = nil

			return
		end

		local currentCount = g_window.getClipboardChangeCount()

		if currentCount ~= lastClipboardChangeCount then
			lastClipboardChangeCount = currentCount

			updateColorControlsState()
		end

		clipboardChangeWatchEvent = scheduleEvent(watch, 80)
	end

	clipboardChangeWatchEvent = scheduleEvent(watch, 80)
end

local function encodeCborUnsigned(value)
	value = math.max(0, math.floor(tonumber(value) or 0))

	if value < 24 then
		return string.char(value)
	end

	if value < 256 then
		return string.char(24, value)
	end

	if value < 65536 then
		local hi = math.floor(value / 256)
		local lo = value % 256

		return string.char(25, hi, lo)
	end

	return string.char(26, math.floor(value / 16777216) % 256, math.floor(value / 65536) % 256, math.floor(value / 256) % 256, value % 256)
end

local function encodeCborText(value)
	value = tostring(value or "")

	local len = #value

	if len < 24 then
		return string.char(96 + len) .. value
	end

	if len < 256 then
		return string.char(120, len) .. value
	end

	return string.char(121, math.floor(len / 256) % 256, len % 256) .. value
end

local function encodeCborBool(value)
	return value and string.char(245) or string.char(244)
end

local function base64Encode(data)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local out = {}
	local len = #data
	local i = 1

	while i <= len do
		local b1 = data:byte(i) or 0
		local b2 = data:byte(i + 1) or 0
		local b3 = data:byte(i + 2) or 0
		local n = b1 * 65536 + b2 * 256 + b3
		local c1 = math.floor(n / 262144) % 64 + 1
		local c2 = math.floor(n / 4096) % 64 + 1
		local c3 = math.floor(n / 64) % 64 + 1
		local c4 = n % 64 + 1

		out[#out + 1] = chars:sub(c1, c1)
		out[#out + 1] = chars:sub(c2, c2)
		out[#out + 1] = len >= i + 1 and chars:sub(c3, c3) or "="
		out[#out + 1] = len >= i + 2 and chars:sub(c4, c4) or "="
		i = i + 3
	end

	return table.concat(out)
end

local function base64Decode(data)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local lookup = {}

	for i = 1, #chars do
		lookup[chars:sub(i, i)] = i - 1
	end

	local clean = (data or ""):gsub("%s+", "")

	if clean == "" or clean:find("[^A-Za-z0-9+/=]") then
		return nil
	end

	local rem = #clean % 4

	if rem == 1 then
		return nil
	elseif rem > 1 then
		clean = clean .. string.rep("=", 4 - rem)
	end

	local out = {}
	local i = 1

	while i <= #clean do
		local c1 = clean:sub(i, i)
		local c2 = clean:sub(i + 1, i + 1)
		local c3 = clean:sub(i + 2, i + 2)
		local c4 = clean:sub(i + 3, i + 3)

		if not c1 or not c2 or not c3 or not c4 then
			return nil
		end

		if c1 == "=" or c2 == "=" or c3 == "=" and c4 ~= "=" then
			return nil
		end

		local v1 = lookup[c1]
		local v2 = lookup[c2]
		local v3 = c3 == "=" and 0 or lookup[c3]
		local v4 = c4 == "=" and 0 or lookup[c4]

		if v1 == nil or v2 == nil or v3 == nil or v4 == nil then
			return nil
		end

		local n = v1 * 262144 + v2 * 4096 + v3 * 64 + v4

		out[#out + 1] = string.char(math.floor(n / 65536) % 256)

		if c3 ~= "=" then
			out[#out + 1] = string.char(math.floor(n / 256) % 256)
		end

		if c4 ~= "=" then
			out[#out + 1] = string.char(n % 256)
		end

		i = i + 4
	end

	return table.concat(out)
end

local function readCborUnsigned(data, pos, addl)
	if addl < 24 then
		return addl, pos
	end

	if addl == 24 then
		local b = data:byte(pos)

		if not b then
			return nil, pos
		end

		return b, pos + 1
	end

	if addl == 25 then
		local b1 = data:byte(pos)
		local b2 = data:byte(pos + 1)

		if not b1 or not b2 then
			return nil, pos
		end

		return b1 * 256 + b2, pos + 2
	end

	if addl == 26 then
		local b1 = data:byte(pos)
		local b2 = data:byte(pos + 1)
		local b3 = data:byte(pos + 2)
		local b4 = data:byte(pos + 3)

		if not b1 or not b2 or not b3 or not b4 then
			return nil, pos
		end

		return b1 * 16777216 + b2 * 65536 + b3 * 256 + b4, pos + 4
	end

	return nil, pos
end

local function looksLikeOutfitClipboardCode(code)
	if type(code) ~= "string" then
		return false
	end

	local trimmed = code:match("^%s*(.-)%s*$") or ""

	if #trimmed < 8 then
		return false
	end

	if trimmed:find("[^A-Za-z0-9+/=]") then
		return false
	end

	return #trimmed % 4 ~= 1
end

local function readCborValue(data, pos, depth)
	depth = depth or 0

	if depth > 16 then
		return nil, pos
	end

	local ib = data:byte(pos)

	if not ib then
		return nil, pos
	end

	pos = pos + 1

	local major = math.floor(ib / 32)
	local addl = ib % 32

	if major == 0 then
		return readCborUnsigned(data, pos, addl)
	end

	if major == 3 then
		local len
		local len

		len, pos = readCborUnsigned(data, pos, addl)

		if not len then
			return nil, pos
		end

		local value = data:sub(pos, pos + len - 1)

		if #value ~= len then
			return nil, pos
		end

		return value, pos + len
	end

	if major == 5 then
		local unusedValue
		local mapLen

		mapLen, pos = readCborUnsigned(data, pos, addl)

		if not mapLen then
			return nil, pos
		end

		local map = {}

		for _ = 1, mapLen do
			local key
			local key

			key, pos = readCborValue(data, pos, depth + 1)

			if type(key) ~= "string" then
				return nil, pos
			end

			local value
			local value

			value, pos = readCborValue(data, pos, depth + 1)

			if value == nil then
				return nil, pos
			end

			map[key] = value
		end

		return map, pos
	end

	if major == 7 then
		if addl == 20 then
			return false, pos
		end

		if addl == 21 then
			return true, pos
		end
	end

	return nil, pos
end

local function decodeCopyColoursCode(code)
	if not looksLikeOutfitClipboardCode(code) then
		return nil
	end

	local raw = base64Decode(code)

	if not raw or #raw < 2 then
		return nil
	end

	local pos = 1
	local first = raw:byte(pos)

	if not first then
		return nil
	end

	local pos = pos + 1
	local major = math.floor(first / 32)
	local addl = first % 32

	if major ~= 5 then
		return nil
	end

	local mapSize
	local mapSize, pos = readCborUnsigned(raw, pos, addl)

	if not mapSize or mapSize < 1 then
		return nil
	end

	local result = {}

	for _ = 1, mapSize do
		local keyHdr = raw:byte(pos)

		if not keyHdr then
			return nil
		end

		pos = pos + 1

		local keyMajor = math.floor(keyHdr / 32)
		local keyAddl = keyHdr % 32

		if keyMajor ~= 3 then
			return nil
		end

		local keyLen
		local keyLen

		keyLen, pos = readCborUnsigned(raw, pos, keyAddl)

		if not keyLen or keyLen < 1 then
			return nil
		end

		local key = raw:sub(pos, pos + keyLen - 1)

		if #key ~= keyLen then
			return nil
		end

		pos = pos + keyLen

		local valueHdr = raw:byte(pos)

		if not valueHdr then
			return nil
		end

		pos = pos + 1

		local valueMajor = math.floor(valueHdr / 32)
		local valueAddl = valueHdr % 32

		if valueMajor ~= 0 then
			return nil
		end

		local value
		local value

		value, pos = readCborUnsigned(raw, pos, valueAddl)

		if value == nil then
			return nil
		end

		result[key] = value
	end

	if result.head == nil or result.torso == nil or result.legs == nil or result.detail == nil then
		return nil
	end

	return {
		head = result.head,
		body = result.torso,
		legs = result.legs,
		feet = result.detail
	}
end

local function decodeCopyAllCode(code)
	if not looksLikeOutfitClipboardCode(code) then
		return nil
	end

	local raw = base64Decode(code)

	if not raw or #raw < 8 then
		return nil
	end

	local root = readCborValue(raw, 1, 0)

	if type(root) ~= "table" then
		return nil
	end

	if type(root.outfit) ~= "table" or type(root.mount) ~= "table" or type(root.summon) ~= "table" then
		return nil
	end

	if type(root.outfit.color) ~= "table" or type(root.mount.color) ~= "table" then
		return nil
	end

	if root.outfit.id == nil or root.mount.id == nil or root.summon.id == nil then
		return nil
	end

	return root
end

function setPasteButtonMode(mode)
	currentPasteMode = mode == "all" and "all" or "colours"

	if not outfitwindowWidget or not outfitwindowWidget.appearance or not outfitwindowWidget.appearance.colorCopyButtons then
		return
	end

	local button = outfitwindowWidget.appearance.colorCopyButtons.pasteColours

	if not button or not button.setStyle then
		return
	end

	if currentPasteMode == "all" then
		button:setStyle("OutfitPasteAllButton")
	else
		button:setStyle("OutfitPasteColoursButton")
	end
end

function classifyPasteClipboardCode(clipboardText, canColor)
	if not looksLikeOutfitClipboardCode(clipboardText) then
		return nil
	end

	local raw = base64Decode(clipboardText)

	if not raw or #raw < 2 then
		return nil
	end

	if raw:find("mount", 1, true) and raw:find("outfit", 1, true) and raw:find("summon", 1, true) then
		return "all"
	end

	if not canColor then
		return nil
	end

	if raw:find("detail", 1, true) and raw:find("head", 1, true) and raw:find("legs", 1, true) and raw:find("torso", 1, true) then
		return "colours"
	end

	return nil
end

local function buildCopyColoursCode(cache)
	if not cache then
		return nil
	end

	local cbor = table.concat({
		string.char(164),
		string.char(102),
		"detail",
		encodeCborUnsigned(cache.feet or 0),
		string.char(100),
		"head",
		encodeCborUnsigned(cache.head or 0),
		string.char(100),
		"legs",
		encodeCborUnsigned(cache.legs or 0),
		string.char(101),
		"torso",
		encodeCborUnsigned(cache.body or 0)
	})
	local encoded = base64Encode(cbor)

	return encoded and encoded:gsub("=+$", "") or nil
end

local function buildCopyAllCode()
	if not tempOutfit then
		return nil
	end

	local mountColors = mountColorCache or {}
	local outfitColors = outfitColorCache or {}
	local addons = tempOutfit.addons or 0
	local firstAddOn = addons == 1 or addons == 3
	local secondAddOn = addons == 2 or addons == 3
	local cbor = table.concat({
		string.char(164),
		encodeCborText("mount"),
		string.char(162),
		encodeCborText("color"),
		string.char(164),
		encodeCborText("detail"),
		encodeCborUnsigned(mountColors.feet or 0),
		encodeCborText("head"),
		encodeCborUnsigned(mountColors.head or 0),
		encodeCborText("legs"),
		encodeCborUnsigned(mountColors.legs or 0),
		encodeCborText("torso"),
		encodeCborUnsigned(mountColors.body or 0),
		encodeCborText("id"),
		encodeCborUnsigned(tempOutfit.mount or 0),
		encodeCborText("name"),
		encodeCborText(""),
		encodeCborText("outfit"),
		string.char(164),
		encodeCborText("color"),
		string.char(164),
		encodeCborText("detail"),
		encodeCborUnsigned(outfitColors.feet or 0),
		encodeCborText("head"),
		encodeCborUnsigned(outfitColors.head or 0),
		encodeCborText("legs"),
		encodeCborUnsigned(outfitColors.legs or 0),
		encodeCborText("torso"),
		encodeCborUnsigned(outfitColors.body or 0),
		encodeCborText("firstAddOn"),
		encodeCborBool(firstAddOn),
		encodeCborText("id"),
		encodeCborUnsigned(tempOutfit.type or 0),
		encodeCborText("secondAddOn"),
		encodeCborBool(secondAddOn),
		encodeCborText("summon"),
		string.char(161),
		encodeCborText("id"),
		encodeCborUnsigned(tempOutfit.familiar or 0)
	})
	local encoded = base64Encode(cbor)

	return encoded and encoded:gsub("=+$", "") or nil
end

local function onCopyAllClick()
	local code = buildCopyAllCode()

	if code and g_window and g_window.setClipboardText then
		g_window.setClipboardText(code)
		updateColorControlsState()
	end
end

local function onCopyColoursClick()
	if not isColorContextActive() then
		return
	end

	local app = getAppearanceCategoryName()
	local cache = getColorCacheForAppearance(app)
	local code = buildCopyColoursCode(cache)

	if code and g_window and g_window.setClipboardText then
		g_window.setClipboardText(code)
		updateColorControlsState()
	end
end

local function onPasteColoursClick()
	if not g_window or not g_window.getClipboardText then
		return
	end

	local clipboardText = g_window.getClipboardText()
	local detectedMode = classifyPasteClipboardCode(clipboardText, isColorContextActive())

	if detectedMode == "all" then
		local decodedAll = decodeCopyAllCode(clipboardText)

		if not decodedAll then
			updateColorControlsState()

			return
		end

		local outfitData = decodedAll.outfit or {}
		local outfitColors = outfitData.color or {}
		local mountData = decodedAll.mount or {}
		local mountColors = mountData.color or {}
		local summonData = decodedAll.summon or {}

		tempOutfit.type = tonumber(outfitData.id) or tempOutfit.type
		tempOutfit.mount = tonumber(mountData.id) or 0
		tempOutfit.familiar = tonumber(summonData.id) or 0
		tempOutfit.addons = (outfitData.firstAddOn and 1 or 0) + (outfitData.secondAddOn and 2 or 0)
		outfitColorCache.head = tonumber(outfitColors.head) or 0
		outfitColorCache.body = tonumber(outfitColors.torso) or 0
		outfitColorCache.legs = tonumber(outfitColors.legs) or 0
		outfitColorCache.feet = tonumber(outfitColors.detail) or 0
		mountColorCache.head = tonumber(mountColors.head) or 0
		mountColorCache.body = tonumber(mountColors.torso) or 0
		mountColorCache.legs = tonumber(mountColors.legs) or 0
		mountColorCache.feet = tonumber(mountColors.detail) or 0

		applyOutfitColorsToTemp()
		updateAppearanceTexts(tempOutfit)
		refreshColorBoxForCurrentContext()
		updatePreview()
		refreshFilterListForCurrentColorChange()
		updateColorControlsState()

		return
	end

	if detectedMode ~= "colours" then
		updateColorControlsState()

		return
	end

	if not isColorContextActive() then
		return
	end

	local decoded = decodeCopyColoursCode(clipboardText)

	if not decoded then
		updateColorControlsState()

		return
	end

	local app = getAppearanceCategoryName()
	local cache = getColorCacheForAppearance(app)

	if not cache then
		return
	end

	cache.head = decoded.head
	cache.body = decoded.body
	cache.legs = decoded.legs
	cache.feet = decoded.feet

	if app == "outfit" then
		applyOutfitColorsToTemp()
	end

	refreshColorBoxForCurrentContext()
	updatePreview()
	refreshFilterListForCurrentColorChange()
	updateColorControlsState()
end

function refreshColorBoxForCurrentContext()
	if not outfitwindowWidget or not colorBoxGroup or not colorModeGroup then
		return
	end

	if not isColorContextActive() then
		return
	end

	local app = getAppearanceCategoryName()
	local cache = getColorCacheForAppearance(app)

	if not cache then
		return
	end

	local sm = colorModeGroup:getSelectedWidget()

	if not sm then
		return
	end

	local colorMode = sm:getId()
	local id = getColorIdFromMode(cache, colorMode)
	local box = outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel["colorBox" .. id]

	if box and colorBoxGroup then
		colorPickerProgrammatic = true

		colorBoxGroup:selectWidget(box)

		colorPickerProgrammatic = false
	end
end

local AppearanceData = {
	"preset",
	"outfit",
	"mount",
	"aura",
	"familiar"
}

function init()
	connect(g_game, {
		onOpenOutfitWindow = onOpenPlayerOutfitWindow,
		onOpenHirelingOutfitWindow = onOpenHirelingOutfitWindow,
		onOpenPlayerPodiumWindow = onOpenPlayerPodiumWindow,
		onAuraList = onAuraList,
		onGameEnd = destroy
	})
end

function terminate()
	disconnect(g_game, {
		onOpenOutfitWindow = onOpenPlayerOutfitWindow,
		onOpenHirelingOutfitWindow = onOpenHirelingOutfitWindow,
		onOpenPlayerPodiumWindow = onOpenPlayerPodiumWindow,
		onAuraList = onAuraList,
		onGameEnd = destroy
	})
	destroy()
end

function onOpenPlayerOutfitWindow(player, outfitList, creatureMount, mountList, familiarList)
	hirelingContext = nil

	create(player, outfitList, creatureMount, mountList, familiarList)
end

function getSelectedAuraName()
	if ServerData.auras then
		for unusedValue, aura in ipairs(ServerData.auras) do
			if aura[1] == ServerData.selectedAuraId then
				return aura[2] or ""
			end
		end

		if #ServerData.auras > 0 then
			return ServerData.auras[1][2] or ""
		end
	end

	return "None"
end

function applyAuraToPreview()
	if podiumContext or hirelingContext then
		return
	end

	if not previewCreature or not previewCreature.getCreature then
		return
	end

	local creature = previewCreature:getCreature()

	if not creature or not creature.setAuraLookType then
		return
	end

	local var_129_1 = outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.aura and outfitwindowWidget.configure.aura.check and outfitwindowWidget.configure.aura.check:isChecked()

	creature:setAuraLookType(var_129_1 and (ServerData.selectedAuraClientId or 0) or 0)
end

function applyCustomizePanelHeights()
	if not outfitwindowWidget or podiumContext or hirelingContext or cyclopediaViewMode then
		return
	end

	local var_130_0 = ServerData and ServerData.familiars and not table.empty(ServerData.familiars)
	local var_130_1 = ServerData and ServerData.auras and not table.empty(ServerData.auras)
	local var_130_2 = 0

	if not var_130_0 then
		var_130_2 = var_130_2 + missingFamiliarCompactionHeight
	end

	if not var_130_1 then
		var_130_2 = var_130_2 + missingFamiliarCompactionHeight
	end

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings then
		outfitwindowWidget.appearance.settings:setHeight(var_0_87 - var_130_2)
	end

	if outfitwindowWidget.configure then
		outfitwindowWidget.configure:setHeight(configurePanelDefaultHeight - var_130_2)
	end

	if outfitwindowWidget.appearance then
		outfitwindowWidget.appearance:setHeight(var_0_86 - var_130_2)
	end

	outfitwindowWidget:setSize(string.format("%d %d", outfitWindowDefaultWidth, outfitWindowDefaultHeight - var_130_2))
	outfitwindowWidget:setMarginTop(var_130_2 > 0 and outfitWindowCompactMarginTop or outfitWindowDefaultMarginTop)
end

function refreshAuraTabVisibility()
	if not outfitwindowWidget then
		return
	end

	local var_131_0 = not podiumContext and not hirelingContext and ServerData.auras and not table.empty(ServerData.auras)

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings and outfitwindowWidget.appearance.settings.aura then
		local aura = outfitwindowWidget.appearance.settings.aura

		if var_131_0 then
			aura:show()
			aura:setHeight(20)
		else
			aura:hide()
			aura:setHeight(0)
		end
	end

	if outfitwindowWidget.configure and outfitwindowWidget.configure.aura then
		local aura = outfitwindowWidget.configure.aura

		if var_131_0 then
			aura:setVisible(true)
			aura:setHeight(22)
			aura:setPadding(5)

			if aura.check and not aura.check.onCheckChange then
				aura.check:setChecked((ServerData.currentAuraClientId or 0) > 0)

				aura.check.onCheckChange = onConfigureAuraChange
			end
		else
			aura:setVisible(false)
			aura:setHeight(0)
			aura:setPadding(0)
		end
	end

	applyCustomizePanelHeights()
end

function onAuraList(arg_132_0, arg_132_1)
	ServerData.auras = {}
	ServerData.currentAuraClientId = tonumber(arg_132_0) or 0
	ServerData.selectedAuraId = 0
	ServerData.selectedAuraClientId = 0

	if type(arg_132_1) == "table" then
		for unusedValue, entry in pairs(arg_132_1) do
			local numericValue = tonumber(entry.id) or 0
			local selectedAuraClientId = tonumber(entry.clientId) or 0
			local var_132_2 = entry.name or ""

			table.insert(ServerData.auras, {
				numericValue,
				var_132_2,
				selectedAuraClientId
			})

			if selectedAuraClientId > 0 and selectedAuraClientId == ServerData.currentAuraClientId then
				ServerData.selectedAuraId = numericValue
				ServerData.selectedAuraClientId = selectedAuraClientId
			end
		end

		table.sort(ServerData.auras, function(arg_133_0, arg_133_1)
			return (arg_133_0[1] or 0) < (arg_133_1[1] or 0)
		end)

		if (ServerData.selectedAuraId or 0) == 0 and #ServerData.auras > 0 then
			ServerData.selectedAuraId = ServerData.auras[1][1]
			ServerData.selectedAuraClientId = ServerData.auras[1][3] or 0
		end
	end

	if outfitwindowWidget and not podiumContext and not hirelingContext then
		refreshAuraTabVisibility()
		updatePreview()
		updateAppearanceText("aura", getSelectedAuraName())

		if getAppearanceCategoryName() == "aura" then
			showAuras()
		end
	end
end

function onOpenHirelingOutfitWindow(player, outfitList, creatureId)
	hirelingContext = {
		creatureId = creatureId
	}

	create(player, outfitList, nil, {}, {})
	applyHirelingWindowMode()
end

local function var_0_185(arg_135_0)
	if not arg_135_0 then
		return
	end

	arg_135_0:setVisible(false)
	arg_135_0:setHeight(0)
	arg_135_0:setPadding(0)
end

function applyHirelingWindowMode()
	if not outfitwindowWidget or not hirelingContext then
		return
	end

	outfitwindowWidget:setText(tr("Customise Hireling"))
	var_0_185(outfitwindowWidget.preview.options.movement)
	var_0_185(outfitwindowWidget.preview.options.showOutfit)
	var_0_185(outfitwindowWidget.preview.options.showFamiliar)

	settings.movement = false

	if movementCheck then
		local onCheckChange = movementCheck.onCheckChange

		movementCheck.onCheckChange = nil

		movementCheck:setChecked(false)

		movementCheck.onCheckChange = onCheckChange
	end

	syncPreviewWalkingState()

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings then
		local settings = outfitwindowWidget.appearance.settings

		for unusedValue, iter_136_1 in ipairs({
			"mount",
			"aura",
			"familiar",
			"preset"
		}) do
			local var_136_2 = settings[iter_136_1]

			if var_136_2 then
				var_136_2:hide()
				var_136_2:setHeight(0)
			end
		end

		settings:setHeight(settings:getHeight() - hirelingAppearanceCompactionHeight)
	end

	if outfitwindowWidget.configure then
		var_0_185(outfitwindowWidget.configure.addon1)
		var_0_185(outfitwindowWidget.configure.addon2)
		var_0_185(outfitwindowWidget.configure.mount)
		var_0_185(outfitwindowWidget.configure.aura)
	end

	if outfitwindowWidget.presetButtons then
		outfitwindowWidget.presetButtons:hide()
		outfitwindowWidget.presetButtons:setHeight(0)
		outfitwindowWidget.presetButtons:setPadding(0)
	end

	if outfitwindowWidget.selectionList and outfitwindowWidget.listSearch then
		outfitwindowWidget.selectionList:breakAnchors()
		outfitwindowWidget.selectionList:addAnchor(AnchorTop, "listSearch", AnchorBottom)
		outfitwindowWidget.selectionList:addAnchor(AnchorLeft, "listSearch", AnchorLeft)
		outfitwindowWidget.selectionList:addAnchor(AnchorRight, "parent", AnchorRight)
		outfitwindowWidget.selectionList:addAnchor(AnchorBottom, "separator", AnchorTop)
		outfitwindowWidget.selectionList:setMarginTop(6)
		outfitwindowWidget.selectionList:setMarginBottom(6)
		outfitwindowWidget.selectionList:setMarginLeft(0)
	end

	if outfitwindowWidget.configure then
		outfitwindowWidget.configure:setHeight(outfitwindowWidget.configure:getHeight() - hirelingAppearanceCompactionHeight)
	end

	if outfitwindowWidget.appearance then
		outfitwindowWidget.appearance:setHeight(outfitwindowWidget.appearance:getHeight() - hirelingAppearanceCompactionHeight)
	end

	outfitwindowWidget:setSize(string.format("%d %d", outfitWindowDefaultWidth, hirelingWindowHeight))
	outfitwindowWidget:setMarginTop(outfitWindowCompactMarginTop)
	updatePreview()
end

function onOpenPlayerPodiumWindow(player, outfitList, creatureMount, mountList, data)
	hirelingContext = nil
	podiumContext = data
	podiumContext.sourceThing = getPodiumSourceThing(data.position, data.itemClientId)
	showPlatformBeforeOutfitOff = data.showPlatform ~= false
	previewPodiumItem = nil
	podiumPreviewInitialized = false

	create(player, outfitList, creatureMount, mountList, {})
	applyPodiumWindowMode()
end

local function var_0_186(arg_138_0)
	if not arg_138_0 then
		return
	end

	arg_138_0:setVisible(true)
	arg_138_0:setHeight(22)
	arg_138_0:setPadding(5)
end

function applyPodiumWindowMode()
	if not outfitwindowWidget or not podiumContext then
		return
	end

	outfitwindowWidget:setText(tr("Customise Podium"))
	var_0_185(outfitwindowWidget.preview.options.movement)
	var_0_185(outfitwindowWidget.preview.options.showOutfit)
	var_0_185(outfitwindowWidget.preview.options.showFamiliar)

	if outfitwindowWidget.configure and outfitwindowWidget.configure.outfit and outfitwindowWidget.configure.outfit.check then
		var_0_186(outfitwindowWidget.configure.outfit)
		outfitwindowWidget.configure.addon1:setMarginTop(0)

		podiumOutfitCheck = outfitwindowWidget.configure.outfit.check
		podiumOutfitCheck.onCheckChange = onPodiumOutfitChange
		settings.showOutfit = podiumContext.showCreature ~= false

		podiumOutfitCheck:setChecked(settings.showOutfit)
		onPodiumOutfitChange(podiumOutfitCheck, settings.showOutfit)
		syncShowOutfitOptionState()
	end

	if outfitwindowWidget.configure and outfitwindowWidget.configure.podium and outfitwindowWidget.configure.podium.check then
		var_0_186(outfitwindowWidget.configure.podium)

		podiumPlatformCheck = outfitwindowWidget.configure.podium.check
		podiumPlatformCheck.onCheckChange = onPodiumPlatformChange

		podiumPlatformCheck:setChecked(podiumContext.showPlatform ~= false)

		podiumContext.showPlatform = podiumPlatformCheck:isChecked()

		syncShowPodiumOptionState()
	end

	if g_game.getFeature(GamePlayerMounts) and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check then
		outfitwindowWidget.configure.mount.check:setEnabled((tempOutfit.mount or 0) > 0 or not table.empty(ServerData.mounts))
		outfitwindowWidget.configure.mount.check:setChecked(podiumContext.showMount == true)

		if podiumContext.showMount and (tempOutfit.mount or 0) == 0 and not table.empty(ServerData.mounts) then
			tempOutfit.mount = getPreferredInitialMountId(ServerData.mounts)
		end

		syncShowOutfitOptionState()
	end

	updatePreview()
end

function onPodiumPlatformChange(unusedArgument, checked)
	if not podiumContext or not podiumCreatureWouldDisplay() then
		syncShowPodiumOptionState()

		return
	end

	podiumContext.showPlatform = checked

	updatePreview()
end

function onPodiumOutfitChange(checkBox, checked)
	local showOutfit = checked

	if showOutfit == nil and checkBox then
		showOutfit = checkBox:isChecked()
	end

	settings.showOutfit = showOutfit

	if podiumContext then
		if showOutfit then
			podiumContext.showPlatform = showPlatformBeforeOutfitOff
		else
			showPlatformBeforeOutfitOff = podiumContext.showPlatform ~= false
		end

		podiumContext.showCreature = showOutfit
	end

	syncPodiumAddonCheckState()
	updatePreview()
end

function onMovementChange(checkBox, checked)
	local enabled = checked == true

	movementEnabledForSession = enabled
	settings.movement = enabled

	if previewCreature and previewCreature:getCreature() then
		updatePreview()
	else
		syncPreviewWalkingState()
	end
end

function onShowFloorChange(checkBox, checked)
	if checked then
		floor:show()

		if floorEventRunning then
			settings.showFloor = checked

			return
		end

		floorEventRunning = true

		local delay = 50

		periodicalEvent(function()
			if not podiumContext and not hirelingContext and settings.movement and previewCreature and previewCreature:getCreature() then
				local dir = previewCreature:getDirection()
				local step = 8

				if dir == Directions.North then
					floorOffsetY = (floorOffsetY - step + floorTileHeight) % floorTileHeight
				elseif dir == Directions.South then
					floorOffsetY = (floorOffsetY + step) % floorTileHeight
				elseif dir == Directions.East then
					floorOffsetX = (floorOffsetX + step) % floorTileWidth
				elseif dir == Directions.West then
					floorOffsetX = (floorOffsetX - step + floorTileWidth) % floorTileWidth
				end

				applyFloorRowScrollMargins()
			else
				floor:setMargin(0)
				resetFloorScrollOffsets()
			end
		end, function()
			local keepRunning = outfitwindowWidget and floor and showFloorCheck and showFloorCheck:isChecked()

			if not keepRunning then
				floorEventRunning = false
			end

			return keepRunning
		end, delay, delay)
	else
		floor:hide()
		floor:setMargin(0)

		floorEventRunning = false

		resetFloorScrollOffsets()
	end

	settings.showFloor = checked
end

function onShowFamiliarChange(checkBox, checked)
	if not (ServerData and ServerData.familiars and not table.empty(ServerData.familiars)) then
		settings.showFamiliar = false

		if checkBox and checkBox:isChecked() then
			checkBox:setChecked(false)
		end

		updatePreview()

		return
	end

	settings.showFamiliar = checked

	updatePreview()
end

local function var_0_187(arg_147_0)
	if not showFamiliarCheck or podiumContext then
		return
	end

	if arg_147_0 then
		showFamiliarCheck:setEnabled(settings.showOutfit)
		showFamiliarCheck:setColor(settings.showOutfit and "#c0c0c0" or "#707070")
	else
		settings.showFamiliar = false

		showFamiliarCheck:setChecked(false)
		showFamiliarCheck:setEnabled(true)
		showFamiliarCheck:setColor("#707070")
	end
end

function syncShowOutfitOptionState()
	local outfitCheck = podiumContext and podiumOutfitCheck or showOutfitCheck

	if not outfitwindowWidget or not outfitCheck then
		return
	end

	local hasFamiliars = ServerData and ServerData.familiars and not table.empty(ServerData.familiars)

	if podiumContext then
		outfitCheck:setEnabled(true)
		outfitCheck:setColor("#c0c0c0")
		syncPodiumAddonCheckState()
		syncShowPodiumOptionState()

		return
	end

	if not g_game.getFeature(GamePlayerMounts) or not outfitwindowWidget.configure.mount or not outfitwindowWidget.configure.mount.check then
		outfitCheck:setEnabled(true)
		outfitCheck:setColor("#c0c0c0")
		var_0_187(hasFamiliars)

		return
	end

	local mountOn = outfitwindowWidget.configure.mount.check:isChecked()

	if not mountOn then
		settings.showOutfit = true

		local h = outfitCheck.onCheckChange

		outfitCheck.onCheckChange = nil

		outfitCheck:setChecked(true)

		outfitCheck.onCheckChange = h

		if podiumContext then
			podiumContext.showCreature = true
		end
	end

	outfitCheck:setEnabled(mountOn)
	outfitCheck:setColor(mountOn and "#c0c0c0" or "#707070")
	var_0_187(hasFamiliars)
end

function onShowOutfitChange(checkBox, checked)
	settings.showOutfit = checked

	local hasFamiliars = ServerData and ServerData.familiars and not table.empty(ServerData.familiars)

	var_0_187(hasFamiliars)
	updatePreview()
end

function onConfigureMountChange(checkBox, checked)
	if podiumContext then
		podiumContext.showMount = checked

		if checked then
			ensurePodiumMountSelection()
		end

		syncShowPodiumOptionState()
	else
		syncShowOutfitOptionState()
	end

	updatePreview()
end

function onConfigureAuraChange(unusedArgument, unusedArgument)
	updatePreview()
end

function mergeCyclopediaPendingIntoTempOutfit(pending, outfitTable)
	if pending.tabType == "outfits" then
		outfitTable.type = pending.lookType
		outfitTable.addons = pending.addons or 0
	elseif pending.tabType == "mounts" then
		outfitTable.mount = pending.lookType
	elseif pending.tabType == "familiars" then
		outfitTable.familiar = pending.lookType
	end

	if pending.colors then
		outfitTable.head = pending.colors.head or outfitTable.head
		outfitTable.body = pending.colors.body or outfitTable.body
		outfitTable.legs = pending.colors.legs or outfitTable.legs
		outfitTable.feet = pending.colors.feet or outfitTable.feet
	end
end

function applyCyclopediaViewMode(pending)
	cyclopediaViewMode = true

	outfitwindowWidget:setText(tr(CYClOPEDIA_VIEW_TITLES[pending.tabType] or "View Outfits"))

	local acceptButton = outfitwindowWidget:recursiveGetChildById("acceptButton")

	if acceptButton then
		acceptButton:hide()
	end

	local presetSetting = outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings and outfitwindowWidget.appearance.settings.preset

	if presetSetting then
		presetSetting:hide()
		presetSetting:setHeight(0)
	end

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings then
		outfitwindowWidget.appearance.settings:setHeight(outfitwindowWidget.appearance.settings:getHeight() - missingPresetCompactionHeight)
	end

	if outfitwindowWidget.appearance then
		outfitwindowWidget.appearance:setHeight(outfitwindowWidget.appearance:getHeight() - missingPresetCompactionHeight)
	end

	if outfitwindowWidget.configure then
		outfitwindowWidget.configure:setHeight(outfitwindowWidget.configure:getHeight() - missingPresetCompactionHeight)
	end

	outfitwindowWidget:setSize(string.format("%d %d", outfitwindowWidget:getWidth(), outfitwindowWidget:getHeight() - missingPresetCompactionHeight))

	function outfitwindowWidget.onEnter()
		destroy()
	end
end

function focusCyclopediaAppearanceSelection(pending)
	local var_155_0 = ({
		outfits = outfitwindowWidget.appearance.settings.outfit.check,
		mounts = outfitwindowWidget.appearance.settings.mount.check,
		familiars = outfitwindowWidget.appearance.settings.familiar.check
	})[pending.tabType]

	if var_0_9 and var_155_0 then
		var_0_9:selectWidget(var_155_0)
	end

	local list = outfitwindowWidget.selectionList
	local grid = getSelectionListGrid()

	if not list or not list:isVisible() then
		updatePreview()

		return
	end

	local lookId = pending.lookType
	local focusedWidget = grid and (grid:getChildById(tostring(lookId)) or grid[lookId])
	local appearanceKey = pending.tabType == "mounts" and "mount" or pending.tabType == "familiars" and "familiar" or "outfit"

	if pending.tabType == "outfits" then
		tempOutfit.type = lookId
		tempOutfit.addons = pending.addons or 0

		configureAddons(tempOutfit.addons)
	elseif pending.tabType == "mounts" then
		tempOutfit.mount = lookId

		local mountConfigureCheck = outfitwindowWidget.configure and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check

		if mountConfigureCheck then
			mountConfigureCheck:setEnabled(true)
			mountConfigureCheck:setChecked(true)
		end
	elseif pending.tabType == "familiars" then
		tempOutfit.familiar = lookId
	end

	if focusedWidget then
		setSelectionListFocusHandler(nil)
		focusedWidget:focus()
		list:ensureChildVisible(focusedWidget, {
			x = 0,
			y = 196
		})

		if pending.tabType == "mounts" then
			onMountSelect(grid, focusedWidget, nil, nil)
		elseif pending.tabType == "familiars" then
			onFamiliarSelect(grid, focusedWidget, nil, nil)
		end
	end

	updatePreview()

	if pending.name then
		updateAppearanceText(appearanceKey, pending.name)
	end

	if pending.tabType == "outfits" then
		setSelectionListFocusHandler(onOutfitSelect)
	elseif pending.tabType == "mounts" then
		setSelectionListFocusHandler(onMountSelect)
	elseif pending.tabType == "familiars" then
		setSelectionListFocusHandler(onFamiliarSelect)
	end
end

function applyPendingCyclopediaFocus()
	if not pendingCyclopediaFocus or not outfitwindowWidget then
		return
	end

	local pending = pendingCyclopediaFocus

	pendingCyclopediaFocus = nil
	activeCyclopediaPending = pending

	local tabWidgets = {
		outfits = outfitwindowWidget.appearance.settings.outfit.check,
		mounts = outfitwindowWidget.appearance.settings.mount.check,
		familiars = outfitwindowWidget.appearance.settings.familiar.check
	}
	local tabWidget = tabWidgets[pending.tabType] or tabWidgets.outfits

	var_0_9:selectWidget(tabWidget)
	addEvent(function()
		if not outfitwindowWidget then
			activeCyclopediaPending = nil

			return
		end

		focusCyclopediaAppearanceSelection(pending)
		applyCyclopediaViewMode(pending)
		updateColorControlsState()
		refreshColorBoxForCurrentContext()

		activeCyclopediaPending = nil
	end)
end

function openFromCyclopedia(appearanceData)
	if not appearanceData or not appearanceData.outfit then
		g_game.requestOutfit()

		return
	end

	pendingCyclopediaFocus = {
		viewMode = true,
		tabType = appearanceData.type,
		lookType = appearanceData.outfit.type,
		addons = appearanceData.outfit.addons or 0,
		name = appearanceData.name,
		colors = {
			head = appearanceData.outfit.head,
			body = appearanceData.outfit.body,
			legs = appearanceData.outfit.legs,
			feet = appearanceData.outfit.feet
		}
	}
	restoreCyclopediaOnClose = true

	g_game.requestOutfit()
end

local PreviewOptions = {
	showFloor = onShowFloorChange,
	showOutfit = onShowOutfitChange,
	showFamiliar = onShowFamiliarChange
}

function create(player, outfitList, creatureMount, mountList, familiarList)
	if ignoreNextOutfitWindow and g_clock.millis() < ignoreNextOutfitWindow + 1000 then
		return
	end

	local cyclopediaPending = pendingCyclopediaFocus
	local restoreCyclopedia = restoreCyclopediaOnClose
	local currentOutfit = player:getOutfit()

	if outfitwindowWidget then
		destroy({
			skipCyclopediaRestore = true
		})
	end

	pendingCyclopediaFocus = cyclopediaPending
	restoreCyclopediaOnClose = restoreCyclopedia

	loadSettings()

	ServerData = {
		currentOutfit = currentOutfit,
		outfits = outfitList,
		mounts = mountList,
		familiars = familiarList,
		auras = ServerData.auras or {},
		currentAuraClientId = ServerData.currentAuraClientId or 0,
		selectedAuraId = ServerData.selectedAuraId or 0,
		selectedAuraClientId = ServerData.selectedAuraClientId or 0
	}
	outfitwindowWidget = g_ui.displayUI("outfitwindow")

	g_modalManager.show(outfitwindowWidget)

	floor = outfitwindowWidget.preview.panel.floor
	floorRowWidgets = {}

	for r = 1, floorTileRows do
		for c = 1, floorTileColumns do
			local tile = floor["floorR" .. r .. "C" .. c]

			tile:setSize(string.format("%d %d", floorTileWidth, floorTileHeight))
			table.insert(floorRowWidgets, tile)
		end
	end

	floorOffsetX = 0
	floorOffsetY = 0

	applyFloorRowScrollMargins()
	floor:setSize(string.format("%d %d", floorTileColumns * floorTileWidth, floorTileRows * floorTileHeight))
	floor:setMargin(0)

	floorEventRunning = false

	floor:hide()

	for _, appKey in ipairs(AppearanceData) do
		updateAppearanceText(appKey, "None")
	end

	previewCreature = outfitwindowWidget.preview.panel:recursiveGetChildById("creature")
	previewFamiliar = outfitwindowWidget.preview.panel:recursiveGetChildById("UIfamiliar")
	previewRow = outfitwindowWidget.preview.panel:recursiveGetChildById("previewRow")

	setupPodiumPreviewWidget()

	previewPodiumItem = nil
	movementCheck = outfitwindowWidget.preview.options.movement.check
	showFloorCheck = outfitwindowWidget.preview.options.showFloor.check
	showOutfitCheck = outfitwindowWidget.preview.options.showOutfit.check
	showFamiliarCheck = outfitwindowWidget.preview.options.showFamiliar.check

	if settings.currentPreset == nil then
		loadDefaultSettings()
		g_logger.error("[game_outfit] loadSettings() failed, using default settings")
	end

	settings.currentPreset = 0
	didAcceptCustomize = false
	tempOutfit = table.copy(currentOutfit)

	if cyclopediaPending then
		mergeCyclopediaPendingIntoTempOutfit(cyclopediaPending, tempOutfit)
	end

	initColorCachesFromOutfit()
	var_0_144(tempOutfit)
	applyGlobalColorCachesFromSettings()
	applyOutfitColorsToTemp()

	if g_game.getFeature(GamePlayerMounts) then
		if cyclopediaPending and cyclopediaPending.tabType == "mounts" then
			outfitwindowWidget.configure.mount.check:setEnabled(true)
			outfitwindowWidget.configure.mount.check:setChecked(true)
		else
			local isMount = g_game.getLocalPlayer():isMounted()

			if isMount then
				outfitwindowWidget.configure.mount.check:setEnabled(true)
				outfitwindowWidget.configure.mount.check:setChecked(true)
			else
				outfitwindowWidget.configure.mount.check:setEnabled(currentOutfit.mount > 0)
				outfitwindowWidget.configure.mount.check:setChecked(isMount and currentOutfit.mount > 0)
			end
		end

		outfitwindowWidget.configure.mount.check.onCheckChange = onConfigureMountChange
	end

	configureAddons(tempOutfit.addons)

	for _, option in ipairs(outfitwindowWidget.preview.options:getChildren()) do
		local handler = PreviewOptions[option:getId()]

		if handler then
			option.check.onCheckChange = handler
		end
	end

	movementCheck.onCheckChange = nil

	movementCheck:setChecked(movementEnabledForSession)

	movementCheck.onCheckChange = onMovementChange

	onMovementChange(movementCheck, movementCheck:isChecked())
	showFloorCheck:setChecked(settings.showFloor)

	if showFloorCheck:isChecked() and not floor:isVisible() then
		onShowFloorChange(showFloorCheck, true)
	end

	showOutfitCheck:setChecked(settings.showOutfit)

	local hasFamiliars = not table.empty(ServerData.familiars)

	showFamiliarCheck:setChecked(hasFamiliars and settings.showFamiliar or false)
	updatePreview()
	updateAppearanceTexts(tempOutfit)

	colorBoxGroup = UIRadioGroup.create()

	for j = 0, 6 do
		for i = 0, 18 do
			local colorBox = g_ui.createWidget("OutfitColorBox", outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel)
			local outfitColor = getOutfitColor(j * 19 + i)

			colorBox.color:setImageColor(outfitColor)
			colorBox:setId("colorBox" .. j * 19 + i)

			colorBox.colorId = j * 19 + i

			if colorBox.colorId == outfitColorCache.head then
				colorBox:setChecked(true)
			end

			colorBoxGroup:addWidget(colorBox)
		end
	end

	colorBoxGroup.onSelectionChange = onColorCheckChange
	var_0_9 = UIRadioGroup.create()

	var_0_9:addWidget(outfitwindowWidget.appearance.settings.outfit.check)
	var_0_9:addWidget(outfitwindowWidget.appearance.settings.mount.check)

	if outfitwindowWidget.appearance.settings.aura then
		var_0_9:addWidget(outfitwindowWidget.appearance.settings.aura.check)
	end

	var_0_9:addWidget(outfitwindowWidget.appearance.settings.familiar.check)
	var_0_9:addWidget(outfitwindowWidget.appearance.settings.preset.check)

	var_0_9.onSelectionChange = onAppearanceChange

	refreshAuraTabVisibility()

	outfitwindowWidget.listSearch.search.onKeyPress = onFilterSearch
	outfitwindowWidget.listSearch.onlyMine.onCheckChange = onFilterOnlyMine

	handleCheckChange.bindRangeChecks()

	if not cyclopediaPending then
		var_0_9:selectWidget(outfitwindowWidget.appearance.settings.outfit.check)
	end

	colorModeGroup = UIRadioGroup.create()

	colorModeGroup:addWidget(outfitwindowWidget.appearance.colorSection.colorMode.head)
	colorModeGroup:addWidget(outfitwindowWidget.appearance.colorSection.colorMode.primary)
	colorModeGroup:addWidget(outfitwindowWidget.appearance.colorSection.colorMode.secondary)
	colorModeGroup:addWidget(outfitwindowWidget.appearance.colorSection.colorMode.detail)

	colorModeGroup.onSelectionChange = onColorModeChange

	colorModeGroup:selectWidget(outfitwindowWidget.appearance.colorSection.colorMode.head)

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.colorCopyButtons and outfitwindowWidget.appearance.colorCopyButtons.copyAll then
		outfitwindowWidget.appearance.colorCopyButtons.copyAll.onClick = onCopyAllClick
	end

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.colorCopyButtons and outfitwindowWidget.appearance.colorCopyButtons.copyColours then
		outfitwindowWidget.appearance.colorCopyButtons.copyColours.onClick = onCopyColoursClick
	end

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.colorCopyButtons and outfitwindowWidget.appearance.colorCopyButtons.pasteColours then
		outfitwindowWidget.appearance.colorCopyButtons.pasteColours.onClick = onPasteColoursClick
	end

	outfitwindowWidget.configure.mount:setVisible(g_game.getFeature(GamePlayerMounts))
	outfitwindowWidget.appearance.settings.mount:setVisible(g_game.getFeature(GamePlayerMounts))
	outfitwindowWidget.preview.options.showFamiliar:setVisible(g_game.getFeature(GamePlayerFamiliars))
	outfitwindowWidget.appearance.settings.familiar:setVisible(g_game.getFeature(GamePlayerFamiliars))
	var_0_187(hasFamiliars)

	if outfitwindowWidget.appearance and outfitwindowWidget.appearance.settings and outfitwindowWidget.appearance.settings.familiar then
		outfitwindowWidget.appearance.settings.familiar:setVisible(hasFamiliars)
	end

	applyCustomizePanelHeights()

	if previewCreature and previewCreature:getCreature() then
		previewCreature:getCreature():setDirection(2)
	end

	if outfitwindowWidget.selectionScroll then
		function outfitwindowWidget.selectionScroll.onValueChange(scrollbar, value)
			scheduleSelectionListHydration("scroll")
		end
	end

	updateColorControlsState()
	startClipboardChangeWatcher()

	if outfitwindowWidget.configure and outfitwindowWidget.configure.outfit then
		outfitwindowWidget.configure.outfit:setVisible(false)
		outfitwindowWidget.configure.outfit:setHeight(0)
		outfitwindowWidget.configure.outfit:setPadding(0)
	end

	if outfitwindowWidget.configure and outfitwindowWidget.configure.addon1 then
		outfitwindowWidget.configure.addon1:setMarginTop(-3)
	end

	if outfitwindowWidget.configure and outfitwindowWidget.configure.podium then
		outfitwindowWidget.configure.podium:setVisible(false)
		outfitwindowWidget.configure.podium:setHeight(0)
		outfitwindowWidget.configure.podium:setPadding(0)
	end

	podiumOutfitCheck = nil
	podiumPlatformCheck = nil

	if cyclopediaPending then
		applyPendingCyclopediaFocus()
	end
end

function destroy(options)
	options = options or {}

	clearSelectionHydrationEvent()
	clearPreviewAnimationReadyEvent()
	selectionTextureCache.releaseHydration()

	if not outfitwindowWidget then
		podiumContext = nil
		hirelingContext = nil

		return
	end

	local shouldRestoreCyclopedia = restoreCyclopediaOnClose and not options.skipCyclopediaRestore

	if not options.skipCyclopediaRestore then
		restoreCyclopediaOnClose = false
	end

	local var_161_1 = outfitwindowWidget

	outfitwindowWidget = nil

	var_161_1:hide()

	if g_modalManager then
		g_modalManager.hide(var_161_1)

		if g_modalManager.pruneOrphanBlockers then
			g_modalManager.pruneOrphanBlockers()
		end
	end

	if modules.game_containers and modules.game_containers.clearContainerDragHover then
		modules.game_containers.clearContainerDragHover()
	end

	stopClipboardChangeWatcher()

	pendingCyclopediaFocus = nil
	activeCyclopediaPending = nil
	cyclopediaViewMode = false
	pendingRenamePresetId = nil
	handleCheckChange.index = 1
	floor = nil
	floorRowWidgets = {}
	movementCheck = nil
	showFloorCheck = nil
	showOutfitCheck = nil
	showFamiliarCheck = nil
	podiumOutfitCheck = nil
	podiumPlatformCheck = nil

	if previewCreature then
		previewCreature:destroy()

		previewCreature = nil
	end

	if previewFamiliar then
		previewFamiliar:destroy()

		previewFamiliar = nil
	end

	previewRow = nil
	previewPodiumWidget = nil
	previewPodiumItem = nil
	podiumPreviewInitialized = false

	if var_0_9 then
		var_0_9:destroy()

		var_0_9 = nil
	end

	if colorModeGroup then
		colorModeGroup:destroy()

		colorModeGroup = nil
	end

	if colorBoxGroup then
		colorBoxGroup:destroy()

		colorBoxGroup = nil
	end

	ServerData = {
		selectedAuraClientId = 0,
		currentAuraClientId = 0,
		selectedAuraId = 0,
		currentOutfit = {},
		outfits = {},
		mounts = {},
		familiars = {},
		auras = {}
	}

	if didAcceptCustomize and settings and type(settings) == "table" then
		settings.outfitColorCache = {
			head = outfitColorCache.head or 0,
			body = outfitColorCache.body or 0,
			legs = outfitColorCache.legs or 0,
			feet = outfitColorCache.feet or 0
		}

		if g_game.getFeature(GamePlayerMounts) then
			settings.mountColorCache = {
				head = mountColorCache.head or 0,
				body = mountColorCache.body or 0,
				legs = mountColorCache.legs or 0,
				feet = mountColorCache.feet or 0
			}
		end
	end

	saveSettings()

	settings = {}

	destroyOutfitWindowIncrementally(var_161_1)

	podiumContext = nil
	hirelingContext = nil

	if shouldRestoreCyclopedia and modules.game_cyclopedia and modules.game_cyclopedia.restoreFromOverlay then
		addEvent(function()
			modules.game_cyclopedia.restoreFromOverlay()
		end)
	end
end

local function getCurrentOutfitAvailableAddons()
	if not tempOutfit or not ServerData or not ServerData.outfits then
		return 0
	end

	for _, outfitData in ipairs(ServerData.outfits) do
		if outfitData[1] == tempOutfit.type then
			return outfitData[3] or 0
		end
	end

	return tempOutfit.addons or 0
end

function syncPodiumAddonCheckState()
	if not podiumContext or not outfitwindowWidget or not outfitwindowWidget.configure then
		return
	end

	if not settings.showOutfit then
		tempOutfit.addons = 0
		outfitwindowWidget.configure.addon1.check.onCheckChange = nil
		outfitwindowWidget.configure.addon2.check.onCheckChange = nil

		outfitwindowWidget.configure.addon1.check:setChecked(false)
		outfitwindowWidget.configure.addon2.check:setChecked(false)
		outfitwindowWidget.configure.addon1.check:setEnabled(false)
		outfitwindowWidget.configure.addon2.check:setEnabled(false)
		outfitwindowWidget.configure.addon1.check:setColor("#707070")
		outfitwindowWidget.configure.addon2.check:setColor("#707070")

		outfitwindowWidget.configure.addon1.check.onCheckChange = onAddonChange
		outfitwindowWidget.configure.addon2.check.onCheckChange = onAddonChange

		return
	end

	configureAddons(getCurrentOutfitAvailableAddons())
end

function configureAddons(addons)
	local hasAddon1 = addons == 1 or addons == 3
	local hasAddon2 = addons == 2 or addons == 3

	outfitwindowWidget.configure.addon1.check:setEnabled(hasAddon1)
	outfitwindowWidget.configure.addon2.check:setEnabled(hasAddon2)

	outfitwindowWidget.configure.addon1.check.onCheckChange = nil
	outfitwindowWidget.configure.addon2.check.onCheckChange = nil

	outfitwindowWidget.configure.addon1.check:setChecked(false)
	outfitwindowWidget.configure.addon2.check:setChecked(false)

	if tempOutfit.addons == 3 then
		outfitwindowWidget.configure.addon1.check:setChecked(true)
		outfitwindowWidget.configure.addon2.check:setChecked(true)
	elseif tempOutfit.addons == 2 then
		outfitwindowWidget.configure.addon1.check:setChecked(false)
		outfitwindowWidget.configure.addon2.check:setChecked(true)
	elseif tempOutfit.addons == 1 then
		outfitwindowWidget.configure.addon1.check:setChecked(true)
		outfitwindowWidget.configure.addon2.check:setChecked(false)
	end

	outfitwindowWidget.configure.addon1.check.onCheckChange = onAddonChange
	outfitwindowWidget.configure.addon2.check.onCheckChange = onAddonChange

	outfitwindowWidget.configure.addon1.check:setColor(hasAddon1 and PODIUM_OPTION_ENABLED_COLOR or PODIUM_OPTION_DISABLED_COLOR)
	outfitwindowWidget.configure.addon2.check:setColor(hasAddon2 and PODIUM_OPTION_ENABLED_COLOR or PODIUM_OPTION_DISABLED_COLOR)
end

local function getPresetButtonCreature(widget)
	local row = widget.presetIconRow

	return row and row.creature or widget.creature
end

local function getPresetButtonFamiliar(widget)
	local row = widget.presetIconRow

	return row and row.presetFamiliar
end

function onGraphicsModeChange(arg_168_0)
	arg_168_0 = math.max(0, math.min(3, tonumber(arg_168_0) or 0))

	applyCreatureGraphicsMode(previewCreature, arg_168_0)
	applyCreatureGraphicsMode(previewFamiliar, arg_168_0)

	local var_168_0 = getSelectionListGrid()

	if var_168_0 then
		for unusedValue, child in ipairs(var_168_0:getChildren()) do
			applyCreatureGraphicsMode(child.outfit, arg_168_0)
		end
	end

	if outfitwindowWidget and outfitwindowWidget.presetsList then
		for unusedValue, child in ipairs(outfitwindowWidget.presetsList:getChildren()) do
			applyCreatureGraphicsMode(getPresetButtonCreature(child), arg_168_0)
			applyCreatureGraphicsMode(getPresetButtonFamiliar(child), arg_168_0)
		end
	end
end

local function layoutPresetIconRowOutfitSingleOrDual(presetWidget, dualMode)
	local row = presetWidget.presetIconRow
	local creature = getPresetButtonCreature(presetWidget)
	local fam = getPresetButtonFamiliar(presetWidget)

	if not row or not creature or not creature.breakAnchors then
		return
	end

	creature:breakAnchors()

	if dualMode and fam then
		creature:addAnchor(AnchorLeft, "parent", AnchorLeft)
		creature:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		creature:setMarginLeft(0)
		creature:setMarginRight(0)
		fam:breakAnchors()
		fam:addAnchor(AnchorLeft, "creature", AnchorRight)
		fam:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		fam:setMarginLeft(1)
		fam:show()
	else
		if fam then
			fam:breakAnchors()
			fam:hide()
		end

		creature:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		creature:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		creature:setMarginLeft(0)
	end

	if row.updateLayout then
		row:updateLayout()
	end
end

local function applyPresetListFamiliarThumb(widget, preset)
	local famWidget = getPresetButtonFamiliar(widget)

	if not famWidget then
		return
	end

	if not g_game.getFeature(GamePlayerFamiliars) then
		famWidget:hide()
		layoutPresetIconRowOutfitSingleOrDual(widget, false)

		return
	end

	local outfitTbl = preset and preset.outfit
	local fid = outfitTbl and outfitTbl.familiar or preset.familiar or 0

	if type(fid) == "string" then
		fid = tonumber(fid) or 0
	end

	if fid < 1 then
		layoutPresetIconRowOutfitSingleOrDual(widget, false)

		return
	end

	local fc = preset.familiarColorCache
	local h = 0
	local b = 0
	local l = 0
	local f = 0

	if fc and type(fc) == "table" then
		h = fc.head or 0
		b = fc.body or 0
		l = fc.legs or 0
		f = fc.feet or 0
	end

	famWidget:setOutfit({
		type = fid,
		head = h,
		body = b,
		legs = l,
		feet = f
	})
	makeThumbnailStatic(famWidget)

	local mainCreature = getPresetButtonCreature(widget)

	if mainCreature and mainCreature:getCreature() and famWidget:getCreature() then
		famWidget:getCreature():setDirection(mainCreature:getCreature():getDirection())
	end

	layoutPresetIconRowOutfitSingleOrDual(widget, true)
end

local function updatePresetManageActionButtonsEnabled()
	if not outfitwindowWidget or not outfitwindowWidget.presetButtons then
		return
	end

	local pb = outfitwindowWidget.presetButtons
	local renameBtn = pb.presetRename
	local saveBtn = pb.presetSave
	local deleteBtn = pb.presetDelete

	if not renameBtn or not saveBtn or not deleteBtn then
		return
	end

	local list = outfitwindowWidget.presetsList
	local hasSelection = list and list:isVisible() and list:getFocusedChild() ~= nil

	renameBtn:setEnabled(hasSelection)
	saveBtn:setEnabled(hasSelection)
	deleteBtn:setEnabled(hasSelection)
end

function newPreset()
	if not settings.presets then
		settings.presets = {}
	end

	local presetWidget = g_ui.createWidget("PresetButton", outfitwindowWidget.presetsList)
	local presetId = #settings.presets + 1

	presetWidget:setId(presetId)
	presetWidget.title:setText("Preset")
	applyOutfitColorsToTemp()
	applyMountColorsToOutfitTable(tempOutfit)

	local outfitCopy = table.copy(tempOutfit)

	getPresetButtonCreature(presetWidget):setOutfit(outfitCopy)
	makeThumbnailStatic(getPresetButtonCreature(presetWidget))

	settings.presets[presetId] = {
		familiar = 0,
		title = "Preset",
		outfit = outfitCopy,
		mounted = outfitwindowWidget.configure.mount.check:isChecked()
	}

	applyPresetListFamiliarThumb(presetWidget, settings.presets[presetId])
	outfitwindowWidget.presetsList:ensureChildVisible(presetWidget, {
		x = 0,
		y = 0
	})
	updatePresetManageActionButtonsEnabled()
end

function deletePreset()
	local presetId = settings.currentPreset

	if presetId == 0 then
		local focused = outfitwindowWidget.presetsList:getFocusedChild()

		if focused then
			presetId = tonumber(focused:getId())
		end
	end

	if not presetId or presetId == 0 then
		return
	end

	table.remove(settings.presets, presetId)
	outfitwindowWidget.presetsList[presetId]:destroy()

	settings.currentPreset = 0

	local newId = 1

	for _, child in ipairs(outfitwindowWidget.presetsList:getChildren()) do
		child:setId(newId)

		newId = newId + 1
	end

	updateAppearanceText("preset", "No Preset")
	updatePresetManageActionButtonsEnabled()
end

function savePreset()
	local presetId = settings.currentPreset

	if presetId == 0 then
		local focused = outfitwindowWidget.presetsList:getFocusedChild()

		if focused then
			presetId = tonumber(focused:getId())
		end
	end

	if not presetId or presetId == 0 then
		return
	end

	local listCreature = getPresetButtonCreature(outfitwindowWidget.presetsList[presetId])

	applyOutfitColorsToTemp()
	applyMountColorsToOutfitTable(tempOutfit)

	local outfitCopy = table.copy(tempOutfit)

	listCreature:setOutfit(outfitCopy)
	makeThumbnailStatic(listCreature)

	settings.presets[presetId].outfit = outfitCopy
	settings.presets[presetId].mounted = outfitwindowWidget.configure.mount.check:isChecked()

	if g_game.getFeature(GamePlayerFamiliars) then
		local fid = tempOutfit.familiar or 0

		settings.presets[presetId].familiar = fid

		if fid > 0 then
			settings.presets[presetId].familiarColorCache = {
				head = familiarColorCache.head or 0,
				body = familiarColorCache.body or 0,
				legs = familiarColorCache.legs or 0,
				feet = familiarColorCache.feet or 0
			}
		else
			settings.presets[presetId].familiarColorCache = nil
		end
	else
		settings.presets[presetId].familiar = tempOutfit.familiar or 0
	end

	settings.currentPreset = presetId

	applyPresetListFamiliarThumb(outfitwindowWidget.presetsList[presetId], settings.presets[presetId])
end

function cancelRenamePresetModal()
	pendingRenamePresetId = nil

	if not outfitwindowWidget or not outfitwindowWidget.renamePresetModal then
		return
	end

	local modal = outfitwindowWidget.renamePresetModal

	if modal.renamePresetInput then
		modal.renamePresetInput:setText("")
	end

	modal:hide()
end

function confirmRenamePresetModal()
	if not outfitwindowWidget or not outfitwindowWidget.renamePresetModal or not pendingRenamePresetId then
		cancelRenamePresetModal()

		return
	end

	local presetId = pendingRenamePresetId
	local modal = outfitwindowWidget.renamePresetModal
	local newTitle = modal.renamePresetInput:getText():trim()

	modal.renamePresetInput:setText("")
	modal:hide()

	pendingRenamePresetId = nil

	local presetWidget = outfitwindowWidget.presetsList[presetId]

	if not presetWidget then
		return
	end

	presetWidget.title:setText(newTitle)

	settings.presets[presetId].title = newTitle

	if presetId == settings.currentPreset then
		updateAppearanceText("preset", newTitle)
	end
end

function renamePreset()
	if not outfitwindowWidget then
		return
	end

	local presetId = settings.currentPreset

	if presetId == 0 then
		local focused = outfitwindowWidget.presetsList:getFocusedChild()

		if focused then
			presetId = tonumber(focused:getId())
		end
	end

	if not presetId or presetId == 0 then
		return
	end

	if not outfitwindowWidget.renamePresetModal then
		return
	end

	local preset = settings.presets and settings.presets[presetId]
	local initial = preset and preset.title or ""

	pendingRenamePresetId = presetId

	local modal = outfitwindowWidget.renamePresetModal

	modal.renamePresetInput:setText(initial)
	modal:show()
	modal:raise()
	modal.renamePresetInput:focus()
end

function onAppearanceChange(widget, selectedWidget)
	local id = selectedWidget:getParent():getId()

	if id == "preset" then
		showPresets()
	elseif id == "outfit" then
		showOutfits()
	elseif id == "mount" then
		showMounts()
	elseif id == "familiar" then
		showFamiliars()
	elseif id == "aura" then
		showAuras()
	end

	updateColorControlsState()
	refreshColorBoxForCurrentContext()
end

local function var_0_195()
	outfitwindowWidget.presetsList:hide()
	outfitwindowWidget.presetsScroll:hide()
	outfitwindowWidget.presetButtons:hide()

	local var_179_0 = getSelectionListGrid()

	if not var_179_0 then
		return nil
	end

	setSelectionListFocusHandler(nil)
	clearSelectionHydrationEvent()
	selectionTextureCache.releaseHydration()
	var_179_0:destroyChildren()
	var_0_74()

	return var_179_0
end

function showPresets()
	clearSelectionHydrationEvent()
	selectionTextureCache.releaseHydration()
	outfitwindowWidget.listSearch:hide()
	outfitwindowWidget.selectionList:hide()
	outfitwindowWidget.selectionScroll:hide()

	if outfitwindowWidget.presetsList:getChildCount() == 0 and settings.presets then
		for presetId, preset in ipairs(settings.presets) do
			local presetWidget = g_ui.createWidget("PresetButton", outfitwindowWidget.presetsList)

			presetWidget:setId(presetId)
			presetWidget.title:setText(preset.title)

			local rowCreature = getPresetButtonCreature(presetWidget)

			rowCreature:setOutfit(preset.outfit)
			makeThumbnailStatic(rowCreature)
			applyPresetListFamiliarThumb(presetWidget, preset)
		end
	end

	outfitwindowWidget.presetsList.onChildFocusChange = nil

	local pid = settings.currentPreset
	local toFocus

	if pid and pid > 0 then
		toFocus = outfitwindowWidget.presetsList[pid]
	end

	if toFocus and not toFocus:isDestroyed() then
		toFocus:focus()
	else
		outfitwindowWidget.presetsList:focusChild(nil)
	end

	outfitwindowWidget.presetsList.onChildFocusChange = onPresetSelect

	outfitwindowWidget.presetsList:show()
	outfitwindowWidget.presetsScroll:show()
	outfitwindowWidget.presetButtons:show()
	updatePresetManageActionButtonsEnabled()
	addEvent(function()
		if not outfitwindowWidget or not outfitwindowWidget.presetsList or not outfitwindowWidget.presetsScroll then
			return
		end

		if outfitwindowWidget.presetsList:isVisible() and outfitwindowWidget.presetsScroll:isVisible() then
			local min = outfitwindowWidget.presetsScroll:getMinimum()

			if outfitwindowWidget.presetsScroll:getValue() == min then
				local vo = outfitwindowWidget.presetsList:getVirtualOffset()

				if vo and vo.y ~= 0 then
					vo.y = 0

					outfitwindowWidget.presetsList:setVirtualOffset(vo)
				end
			end
		end
	end)
end

function showOutfits()
	local parentWidget = var_0_195()

	if not parentWidget then
		return
	end

	local focused
	local sortedOutfits = {}

	for _, outfitData in ipairs(ServerData.outfits) do
		table.insert(sortedOutfits, outfitData)
	end

	var_0_58(sortedOutfits, 4)
	buildSelectionListBatched(sortedOutfits, function(outfitData)
		local button = g_ui.createWidget("SelectionButton", parentWidget)

		button:setId(outfitData[1])

		local outfit = table.copy(tempOutfit)
		local availableAddons = outfitData[3] or 0

		outfit.type = outfitData[1]
		outfit.addons = availableAddons

		local h, b, l, f = headBodyForListThumbnail(outfitData[1], outfitColorCache)

		outfit.head, outfit.body, outfit.legs, outfit.feet = h, b, l, f
		outfit.mount = 0
		outfit.familiar = 0
		button.selectionAvailableAddons = availableAddons
		button.selectionOutfitData = outfit

		markSelectionButtonDeferred(button, outfit)
		makeThumbnailStatic(button.outfit)

		local state = outfitData[4]

		if state then
			button.state = state

			if state ~= statesOutft.available then
				button:setImageSource("/images/ui/button-blue-up")
			end
		end

		button.name:setText(outfitData[2])

		if tempOutfit.type == outfitData[1] then
			focused = outfitData[1]

			configureAddons(outfitData[3])
		end
	end, function()
		local function enableOutfitSelectionHandler()
			setSelectionListFocusHandler(onOutfitSelect)
		end

		setSelectionListFocusHandler(nil)
		handleCheckChange.apply()

		if focused then
			local grid = getSelectionListGrid()
			local var_184_2 = grid and grid[focused]

			if var_184_2 and var_184_2:isVisible() then
				hydrateSelectionButton(var_184_2)
				var_184_2:focus()
				outfitwindowWidget.selectionList:ensureChildVisible(var_184_2, {
					x = 0,
					y = 196
				})
			end

			local var_184_3 = focused

			addEvent(function()
				if not outfitwindowWidget or not outfitwindowWidget.selectionList or not outfitwindowWidget.selectionList:isVisible() then
					enableOutfitSelectionHandler()

					return
				end

				local var_186_0 = getSelectionListGrid()
				local var_186_1 = var_186_0 and var_186_0[var_184_3]

				if var_186_1 and var_186_1:isVisible() then
					var_186_1:focus()
					outfitwindowWidget.selectionList:ensureChildVisible(var_186_1, {
						x = 0,
						y = 196
					})
				end

				enableOutfitSelectionHandler()
			end)
		else
			enableOutfitSelectionHandler()
		end

		outfitwindowWidget.selectionList:show()
		outfitwindowWidget.selectionScroll:show()
		resetSelectionListScrollPosition()
		scheduleSelectionListHydration("showOutfits")
		outfitwindowWidget.listSearch:setText("Filter Outfits")
		outfitwindowWidget.listSearch:show()
	end)
end

function showMounts()
	local listGrid = var_0_195()

	if not listGrid then
		return
	end

	local mountCheck = outfitwindowWidget.configure and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check
	local previousMountChecked = mountCheck and mountCheck:isChecked() or false
	local cyclopediaMountFocus

	if activeCyclopediaPending and activeCyclopediaPending.tabType == "mounts" then
		cyclopediaMountFocus = {
			lookType = activeCyclopediaPending.lookType,
			name = activeCyclopediaPending.name
		}
		previousMountChecked = true
	end

	local focused
	local sortedMounts = {}

	for _, mountData in ipairs(ServerData.mounts) do
		table.insert(sortedMounts, mountData)
	end

	var_0_58(sortedMounts, 3)
	buildSelectionListBatched(sortedMounts, function(mountData)
		local button = g_ui.createWidget("SelectionButton", listGrid)

		button:setId(mountData[1])

		local h, b, l, f = headBodyForListThumbnail(mountData[1], mountColorCache)
		local mountOutfit = {
			type = mountData[1],
			head = h,
			body = b,
			legs = l,
			feet = f
		}

		button.selectionOutfitData = mountOutfit

		markSelectionButtonDeferred(button, mountOutfit)
		makeThumbnailStatic(button.outfit)
		button.name:setText(mountData[2])

		if tempOutfit.mount == mountData[1] then
			focused = mountData[1]
		end

		local state = mountData[3]

		if state then
			button.state = state

			if state ~= statesOutft.available then
				button:setImageSource("/images/ui/button-blue-up")
			end
		end
	end, function()
		if cyclopediaMountFocus then
			tempOutfit.mount = cyclopediaMountFocus.lookType
			focused = cyclopediaMountFocus.lookType
		end

		if focused == nil and #sortedMounts > 0 then
			local firstMount = sortedMounts[1]

			tempOutfit.mount = firstMount[1]
			focused = firstMount[1]

			updateAppearanceText("mount", firstMount[2] or "None")
		end

		if #ServerData.mounts == 1 then
			clearSelectionListFocus()
		end

		if mountCheck then
			local focused = getOutfitStateById(focused)

			mountCheck:setEnabled(focused)

			local showMounted = previousMountChecked

			if cyclopediaMountFocus then
				showMounted = true
			end

			mountCheck:setChecked(showMounted and focused)
		end

		updatePreview()

		if cyclopediaMountFocus and cyclopediaMountFocus.name then
			updateAppearanceText("mount", cyclopediaMountFocus.name)
			updateMountAppearanceNameVisual(tempOutfit.mount)
		end

		handleCheckChange.apply()

		if focused ~= nil then
			local grid = getSelectionListGrid()
			local w = grid and grid[focused]

			if w and w:isVisible() then
				hydrateSelectionButton(w)
				w:focus()
				outfitwindowWidget.selectionList:ensureChildVisible(w, {
					x = 0,
					y = 196
				})
			end
		end

		setSelectionListFocusHandler(onMountSelect)
		outfitwindowWidget.selectionList:show()
		outfitwindowWidget.selectionScroll:show()
		resetSelectionListScrollPosition()
		scheduleSelectionListHydration("showMounts")
		outfitwindowWidget.listSearch:setText("Filter Mounts")
		outfitwindowWidget.listSearch:show()
	end)
end

function showFamiliars()
	local listGrid = var_0_195()

	if not listGrid then
		return
	end

	if table.empty(ServerData.familiars) then
		outfitwindowWidget.selectionList:hide()
		outfitwindowWidget.selectionScroll:hide()
		outfitwindowWidget.listSearch:hide()

		return
	end

	local focused

	buildSelectionListBatched(ServerData.familiars, function(familiarData)
		local button = g_ui.createWidget("SelectionButton", listGrid)

		button:setId(familiarData[1])

		local h, b, l, f = headBodyForListThumbnail(familiarData[1], familiarColorCache)
		local familiarOutfit = {
			type = familiarData[1],
			head = h,
			body = b,
			legs = l,
			feet = f
		}

		button.selectionOutfitData = familiarOutfit

		markSelectionButtonDeferred(button, familiarOutfit)
		makeThumbnailStatic(button.outfit)
		button.name:setText(familiarData[2])

		if tempOutfit.familiar == familiarData[1] then
			focused = familiarData[1]
		end
	end, function()
		if #ServerData.familiars == 1 and (tempOutfit.familiar or 0) == 0 then
			clearSelectionListFocus()
		end

		handleCheckChange.apply()

		if focused then
			local grid = getSelectionListGrid()
			local w = grid and grid[focused]

			if w and w:isVisible() then
				hydrateSelectionButton(w)
				w:focus()
				outfitwindowWidget.selectionList:ensureChildVisible(w, {
					x = 0,
					y = 196
				})
			end
		end

		setSelectionListFocusHandler(onFamiliarSelect)
		outfitwindowWidget.selectionList:show()
		outfitwindowWidget.selectionScroll:show()
		resetSelectionListScrollPosition()
		scheduleSelectionListHydration("showFamiliars")
		outfitwindowWidget.listSearch:setText("Filter Familiars")
		outfitwindowWidget.listSearch:show()
	end)
end

function showAuras()
	local parentWidget = var_0_195()

	if not parentWidget then
		return
	end

	if podiumContext or hirelingContext or table.empty(ServerData.auras) then
		outfitwindowWidget.selectionList:hide()
		outfitwindowWidget.selectionScroll:hide()
		outfitwindowWidget.listSearch:hide()

		return
	end

	local var_193_1 = {}

	for _, outfitData in ipairs(ServerData.auras) do
		table.insert(var_193_1, outfitData)
	end

	local var_193_2

	buildSelectionListBatched(var_193_1, function(arg_194_0)
		local selectionButtonWidget = g_ui.createWidget("SelectionButton", parentWidget)

		selectionButtonWidget:setId(arg_194_0[1])

		selectionButtonWidget.auraClientId = arg_194_0[3] or 0

		if selectionButtonWidget.auraClientId > 0 then
			local selectionOutfitData = {
				type = selectionButtonWidget.auraClientId
			}

			selectionButtonWidget.selectionOutfitData = selectionOutfitData

			markSelectionButtonDeferred(selectionButtonWidget, selectionOutfitData)
			makeThumbnailStatic(selectionButtonWidget.outfit)
		end

		selectionButtonWidget.name:setText(arg_194_0[2])

		if ServerData.selectedAuraId == arg_194_0[1] then
			var_193_2 = arg_194_0[1]
		end
	end, function()
		if var_193_2 == nil and #var_193_1 > 0 then
			ServerData.selectedAuraId = var_193_1[1][1]
			ServerData.selectedAuraClientId = var_193_1[1][3] or 0
			var_193_2 = var_193_1[1][1]

			updateAppearanceText("aura", var_193_1[1][2] or "")
		end

		handleCheckChange.apply()

		if var_193_2 ~= nil then
			local var_195_0 = getSelectionListGrid()
			local var_195_1 = var_195_0 and var_195_0[var_193_2]

			if var_195_1 and var_195_1:isVisible() then
				hydrateSelectionButton(var_195_1)
				var_195_1:focus()
				outfitwindowWidget.selectionList:ensureChildVisible(var_195_1, {
					x = 0,
					y = 196
				})
			end
		end

		setSelectionListFocusHandler(onAuraSelect)
		outfitwindowWidget.selectionList:show()
		outfitwindowWidget.selectionScroll:show()
		resetSelectionListScrollPosition()
		scheduleSelectionListHydration("showAuras")
		outfitwindowWidget.listSearch:setText("Filter Auras")
		outfitwindowWidget.listSearch:show()
	end)
end

function refreshFilterListForCurrentColorChange()
	if not var_0_9 or not outfitwindowWidget then
		return
	end

	local selectedWidget = var_0_9:getSelectedWidget()

	if not selectedWidget or not selectedWidget.getParent then
		return
	end

	local parent = selectedWidget:getParent():getId()

	if parent == "outfit" or parent == "mount" or parent == "familiar" then
		var_0_152()
	end
end

function onPresetSelect(unusedArgument, focusedChild, unusedArgument, unusedArgument)
	if focusedChild then
		local id = tonumber(focusedChild:getId())
		local var_197_1 = settings.presets[id]

		tempOutfit = table.copy(var_197_1.outfit)

		var_0_144(tempOutfit)
		applyOutfitColorsToTemp()

		if var_197_1.familiarColorCache and type(var_197_1.familiarColorCache) == "table" then
			familiarColorCache.head = var_197_1.familiarColorCache.head or 0
			familiarColorCache.body = var_197_1.familiarColorCache.body or 0
			familiarColorCache.legs = var_197_1.familiarColorCache.legs or 0
			familiarColorCache.feet = var_197_1.familiarColorCache.feet or 0
		elseif (tempOutfit.familiar or 0) > 0 then
			familiarColorCache.head = 0
			familiarColorCache.body = 0
			familiarColorCache.legs = 0
			familiarColorCache.feet = 0
		end

		for unusedValue, outfit in ipairs(ServerData.outfits) do
			if tempOutfit.type == outfit[1] then
				configureAddons(outfit[3])

				break
			end
		end

		if g_game.getFeature(GamePlayerMounts) then
			outfitwindowWidget.configure.mount.check:setChecked(var_197_1.mounted and tempOutfit.mount > 0)
		end

		settings.currentPreset = id

		updatePreview()
		updateAppearanceTexts(tempOutfit)
		updateColorControlsState()
		refreshColorBoxForCurrentContext()
	end

	updatePresetManageActionButtonsEnabled()
end

function onOutfitSelect(unusedArgument, focusedChild, unusedArgument, unusedArgument)
	if focusedChild and focusedChild:isVisible() then
		hydrateSelectionButton(focusedChild)

		local selectionOutfitData = focusedChild.selectionOutfitData
		local selectionAvailableAddons = focusedChild.selectionAvailableAddons

		if not selectionOutfitData then
			local creature = focusedChild.outfit and focusedChild.outfit:getCreature()

			selectionOutfitData = creature and creature:getOutfit()
		end

		if not selectionOutfitData then
			return
		end

		if selectionAvailableAddons == nil then
			selectionAvailableAddons = selectionOutfitData.addons or 0
		end

		tempOutfit.type = selectionOutfitData.type
		tempOutfit.addons = math.min(tempOutfit.addons or 0, selectionAvailableAddons)

		configureAddons(selectionAvailableAddons)
		preparePreviewThingType(selectionOutfitData.type, settings.movement == true)
		updatePreview()
		updateAppearanceText("outfit", focusedChild.name:getText())
		updateColorControlsState()
		refreshColorBoxForCurrentContext()
	end
end

function onMountSelect(unusedArgument, focusedChild, unusedArgument, unusedArgument)
	if focusedChild and focusedChild:isVisible() then
		local id = tonumber(focusedChild:getId())

		if not id or id <= 0 then
			return
		end

		tempOutfit.mount = id

		local var_199_1 = outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check

		if var_199_1 then
			local var_199_2 = var_199_1:isChecked()
			local var_199_3 = getOutfitStateById(id)

			var_199_1:setEnabled(var_199_3)
			var_199_1:setChecked(var_199_2 and var_199_3)
		end

		preparePreviewThingType(id, settings.movement == true)
		updatePreview()
		updateAppearanceText("mount", focusedChild.name:getText())
		updateMountAppearanceNameVisual(id)
		updateColorControlsState()
		refreshColorBoxForCurrentContext()
	end
end

function onFamiliarSelect(unusedArgument, focusedChild, unusedArgument, unusedArgument)
	if focusedChild and focusedChild:isVisible() then
		local id = tonumber(focusedChild:getId())

		if not id or id <= 0 then
			return
		end

		tempOutfit.familiar = id

		previewFamiliar:setOutfit({
			type = id
		})

		if previewFamiliar:getCreature() then
			local creature = previewFamiliar:getCreature():getOutfit()

			if creature then
				familiarColorCache.head = creature.head or 0
				familiarColorCache.body = creature.body or 0
				familiarColorCache.legs = creature.legs or 0
				familiarColorCache.feet = creature.feet or 0
			end
		end

		updateColorControlsState()
		refreshColorBoxForCurrentContext()
		preparePreviewThingType(id, settings.movement == true)
		updatePreview()
		updateAppearanceText("familiar", focusedChild.name:getText())
	end
end

function onAuraSelect(unusedArgument, arg_201_1, unusedArgument, unusedArgument)
	if arg_201_1 and arg_201_1:isVisible() then
		ServerData.selectedAuraId = tonumber(arg_201_1:getId()) or 0
		ServerData.selectedAuraClientId = arg_201_1.auraClientId or 0

		preparePreviewThingType(ServerData.selectedAuraClientId, false, true)
		updatePreview()
		updateAppearanceText("aura", arg_201_1.name:getText())
	end
end

function updateAppearanceText(widget, text)
	if outfitwindowWidget.appearance.settings[widget] then
		outfitwindowWidget.appearance.settings[widget].name:setText(text)

		if widget == "mount" then
			updateMountAppearanceNameVisual(tempOutfit and tempOutfit.mount or 0)
		elseif widget == "outfit" then
			var_0_143(tempOutfit and tempOutfit.type or 0)
		end
	end
end

function updateAppearanceTexts(outfit)
	for unusedValue, entry in ipairs(AppearanceData) do
		if entry ~= "preset" then
			updateAppearanceText(entry, "None")
		end
	end

	local var_203_0 = {
		familiar = "familiars",
		mount = "mounts"
	}

	for key, unusedValue in pairs(outfit) do
		local var_203_1 = var_203_0[key] or key
		local var_203_2 = key

		if key == "type" then
			var_203_1 = "outfits"
			var_203_2 = "outfit"
		end

		local var_203_3 = ServerData[var_203_1]

		if var_203_3 then
			for unusedValue, entry in ipairs(var_203_3) do
				if (outfit[key] == entry[1] or outfit[key] == entry[2]) and var_203_2 and entry[2] then
					updateAppearanceText(var_203_2, entry[2])
				end
			end
		end
	end

	local presetId = settings.currentPreset

	if presetId and presetId > 0 and settings.presets and settings.presets[presetId] then
		updateAppearanceText("preset", settings.presets[presetId].title)
	else
		updateAppearanceText("preset", "No Preset")
	end

	updateAppearanceText("aura", getSelectedAuraName())
end

function onAddonChange(widget, checked)
	local addonId = widget:getParent():getId()
	local addons = tempOutfit.addons

	if addonId == "addon1" then
		addons = checked and addons + 1 or addons - 1
	elseif addonId == "addon2" then
		addons = checked and addons + 2 or addons - 2
	end

	tempOutfit.addons = addons

	updatePreview()
end

function onColorModeChange(widget, selectedWidget)
	if colorPickerProgrammatic or not selectedWidget then
		return
	end

	if not isColorContextActive() then
		return
	end

	local app = getAppearanceCategoryName()
	local cache = getColorCacheForAppearance(app)

	if not cache then
		return
	end

	local colorMode = selectedWidget:getId()
	local id = getColorIdFromMode(cache, colorMode)
	local box = outfitwindowWidget.appearance.colorSection.colorBoxBackground.colorBoxPanel["colorBox" .. id]

	if box and colorBoxGroup then
		colorPickerProgrammatic = true

		colorBoxGroup:selectWidget(box)

		colorPickerProgrammatic = false
	end
end

function onColorCheckChange(widget, selectedWidget)
	if colorPickerProgrammatic or not selectedWidget then
		return
	end

	if not isColorContextActive() then
		return
	end

	local colorId = selectedWidget.colorId
	local colorMode = colorModeGroup:getSelectedWidget():getId()
	local app = getAppearanceCategoryName()
	local cache = getColorCacheForAppearance(app)

	if not cache then
		return
	end

	applyColorIdToMode(cache, colorMode, colorId)

	if app == "outfit" then
		applyOutfitColorsToTemp()
	end

	updatePreview()
	refreshFilterListForCurrentColorChange()
end

function preparePreviewThingType(numericValue, arg_207_1, lookType)
	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 then
		return true
	end

	local thingType = g_things.getThingType(numericValue, ThingCategoryCreature)

	if not thingType then
		return true
	end

	if lookType then
		return thingType:preparePreviewAuraTexture()
	end

	local var_207_1 = thingType:preparePreviewIdleTexture()

	if arg_207_1 and not thingType:preparePreviewMovementTexture() then
		return false
	end

	return var_207_1
end

function prefetchPreviewTextures(arg_208_0, arg_208_1)
	if podiumContext or hirelingContext then
		return
	end

	local var_208_0 = settings.movement == true

	if arg_208_1 then
		preparePreviewThingType(arg_208_0.type, var_208_0)

		if (arg_208_0.mount or 0) > 0 then
			preparePreviewThingType(arg_208_0.mount, var_208_0)
		end
	end

	if previewFamiliar and settings.showFamiliar and (arg_208_0.familiar or 0) > 0 then
		preparePreviewThingType(arg_208_0.familiar, var_208_0)
	end

	local var_208_1 = outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.aura and outfitwindowWidget.configure.aura.check

	if arg_208_1 and var_208_1 and var_208_1:isChecked() then
		preparePreviewThingType(ServerData.selectedAuraClientId, false, true)
	end
end

function schedulePreviewAnimationRetry(token)
	if token ~= previewMovementWarmup.token or previewMovementWarmup.event then
		return
	end

	previewMovementWarmup.event = scheduleEvent(function()
		previewMovementWarmup.event = nil

		if token ~= previewMovementWarmup.token or not outfitwindowWidget then
			return
		end

		applyPreviewUpdate(token)
	end, previewMovementWarmup.retryMs)
end

function applyPreviewUpdate(token)
	if token ~= previewMovementWarmup.token or not outfitwindowWidget or not previewCreature then
		return
	end

	if podiumContext and podiumOutfitCheck then
		settings.showOutfit = getPodiumShowOutfit()
	end

	syncShowOutfitOptionState()

	local direction = previewCreature:getDirection()

	applyOutfitColorsToTemp()

	local previewOutfit = table.copy(tempOutfit)

	previewOutfit.head = outfitColorCache.head
	previewOutfit.body = outfitColorCache.body
	previewOutfit.legs = outfitColorCache.legs
	previewOutfit.feet = outfitColorCache.feet

	local showOutfitLayers = settings.showOutfit
	local showPreviewCreature = settings.showOutfit

	if podiumContext then
		ensurePodiumMountSelection()

		showOutfitLayers = getPodiumShowOutfit()
		showPreviewCreature = showOutfitLayers or isPodiumMountShown()

		if not getPodiumShowMount() then
			previewOutfit.mount = 0
		end

		if not showOutfitLayers then
			previewOutfit.addons = 0
		end
	end

	if not podiumContext and g_game.getFeature(GamePlayerMounts) and outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check and not outfitwindowWidget.configure.mount.check:isChecked() then
		previewOutfit.mount = 0
	end

	applyMountColorsToOutfitTable(previewOutfit)
	prefetchPreviewTextures(previewOutfit, showPreviewCreature)

	if showPreviewCreature then
		previewCreature:show()
	else
		previewCreature:hide()
	end

	if previewFamiliar then
		if not settings.showFamiliar then
			previewOutfit.familiar = 0

			previewFamiliar:setVisible(settings.showFamiliar)
		elseif previewOutfit.familiar and previewOutfit.familiar > 0 then
			previewFamiliar:setOutfit({
				type = previewOutfit.familiar,
				head = familiarColorCache.head,
				body = familiarColorCache.body,
				legs = familiarColorCache.legs,
				feet = familiarColorCache.feet
			})
			previewFamiliar:setVisible(true)
		end
	end

	if previewRow then
		if podiumContext then
			previewRow:setWidth(262)
			previewRow:setMarginLeft(1)
		else
			local gapBetweenCreatures = 1
			local showDual = settings.showFamiliar and (previewOutfit.familiar or 0) > 0

			previewRow:setWidth(showDual and 128 + gapBetweenCreatures + 128 or 128)
			previewRow:setMarginLeft(showDual and 2 or 1)
		end
	end

	previewCreature:setOutfit(previewOutfit)

	local previewCreaturePtr = previewCreature:getCreature()

	previewCreaturePtr:setDirection(direction)
	applyAuraToPreview()

	local mountShown = (previewOutfit.mount or 0) > 0

	if podiumContext then
		previewCreaturePtr:setDrawOutfitLayers(showOutfitLayers)
	else
		previewCreaturePtr:setDrawOutfitLayers(not mountShown or settings.showOutfit)
	end

	applyOutfitPreviewSpriteScale(previewCreature)

	if previewFamiliar and previewFamiliar:isVisible() and previewFamiliar:getCreature() then
		applyOutfitPreviewSpriteScale(previewFamiliar)
	end

	syncPreviewWalkingState()

	if podiumContext then
		previewCreaturePtr:setDrawOutfitLayers(showOutfitLayers)
		updatePodiumPreview()
	elseif previewPodiumWidget then
		previewPodiumWidget:setItemVisible(false)
		restoreNormalPreviewCreatureLayout()
	end
end

function updatePreview()
	clearPreviewAnimationReadyEvent()
	applyPreviewUpdate(previewMovementWarmup.token)
end

function rotate(value)
	if not previewCreature or not previewCreature:getCreature() then
		return
	end

	local direction = previewCreature:getDirection() + value

	if direction > Directions.West then
		direction = Directions.North
	elseif direction < Directions.North then
		direction = Directions.West
	end

	previewCreature:getCreature():setDirection(direction)

	if g_game.getFeature(GamePlayerFamiliars) and previewFamiliar and previewFamiliar:getCreature() then
		previewFamiliar:getCreature():setDirection(direction)
	end

	if podiumContext then
		updatePodiumPreview()
	end

	if floor then
		floor:setMargin(0)
		resetFloorScrollOffsets()
	end
end

function onFilterOnlyMine(self, checked)
	addEvent(handleCheckChange.apply)
end

function onFilterSearch()
	addEvent(handleCheckChange.apply)
end

function clearFilterSearch()
	if not outfitwindowWidget or not outfitwindowWidget.listSearch then
		return
	end

	outfitwindowWidget.listSearch.search:setText("")
	onFilterSearch()
	outfitwindowWidget.listSearch.search:focus()
end

function saveSettings()
	if not g_resources.fileExists(settingsFile) then
		g_resources.makeDir("/settings")
		g_resources.writeFileContents(settingsFile, "[]")
	end

	local fullSettings = {}
	local json_status, json_data = pcall(function()
		return json.decode(g_resources.readFileContents(settingsFile))
	end)

	if not json_status then
		g_logger.error("[saveSettings] Couldn't load JSON: " .. json_data)

		return
	end

	local fullSettings = json_data
	local persistedSettings = table.copy(settings)

	persistedSettings.movement = nil
	fullSettings[g_game.getCharacterName()] = persistedSettings

	local json_status, json_data = pcall(function()
		return json.encode(fullSettings)
	end)

	if not json_status then
		g_logger.error("[saveSettings] Couldn't save JSON: " .. json_data)

		return
	end

	g_resources.writeFileContents(settingsFile, json.encode(fullSettings))
end

function loadSettings()
	if not g_resources.fileExists(settingsFile) then
		g_resources.makeDir("/settings")
	end

	if g_resources.fileExists(settingsFile) then
		local json_status, json_data = pcall(function()
			return json.decode(g_resources.readFileContents(settingsFile))
		end)

		if not json_status then
			g_logger.error("[loadSettings] Couldn't load JSON: " .. json_data)

			return
		end

		settings = json_data[g_game.getCharacterName()]

		if not settings then
			loadDefaultSettings()
		else
			settings.movement = movementEnabledForSession
		end
	else
		loadDefaultSettings()
	end
end

function loadDefaultSettings()
	settings = {
		showFamiliar = true,
		currentPreset = 0,
		showOutfit = true,
		showFloor = true,
		movement = movementEnabledForSession,
		presets = {}
	}
end

function accept()
	if cyclopediaViewMode then
		destroy()

		return
	end

	didAcceptCustomize = true

	local shouldToggleMount = false
	local isMountedChecked = false
	local var_223_2 = 0

	if not podiumContext and not hirelingContext and outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.aura and outfitwindowWidget.configure.aura.check and outfitwindowWidget.configure.aura.check:isChecked() then
		var_223_2 = ServerData.selectedAuraId or 0
	end

	if not podiumContext and not hirelingContext and g_game.getFeature(GamePlayerMounts) and outfitwindowWidget and outfitwindowWidget.configure and outfitwindowWidget.configure.mount and outfitwindowWidget.configure.mount.check then
		isMountedChecked = outfitwindowWidget.configure.mount.check:isChecked()
		shouldToggleMount = true

		if settings.currentPreset > 0 then
			settings.presets[settings.currentPreset].mounted = isMountedChecked
		end
	end

	if g_game.getFeature(GamePlayerFamiliars) and settings.currentPreset > 0 then
		local p = settings.presets[settings.currentPreset]

		if p then
			local fid = tempOutfit.familiar or 0

			p.familiar = fid

			if fid > 0 then
				p.familiarColorCache = {
					head = familiarColorCache.head or 0,
					body = familiarColorCache.body or 0,
					legs = familiarColorCache.legs or 0,
					feet = familiarColorCache.feet or 0
				}
			else
				p.familiarColorCache = nil
			end
		end
	end

	local outfitToSend = buildOutfitPayloadForSend()
	local podiumRequest
	local isHirelingOutfit = hirelingContext ~= nil

	if podiumContext then
		local showPlatform = getEffectivePodiumShowPlatform()
		local showOutfit = getPodiumShowOutfit()
		local showMount = getPodiumShowMount()
		local direction = podiumContext.direction

		if previewCreature and previewCreature:getCreature() then
			direction = previewCreature:getDirection()
		end

		local podiumOutfit = table.copy(outfitToSend)

		if not showOutfit then
			podiumOutfit.type = 0
			podiumOutfit.addons = 0
		end

		if not showMount then
			podiumOutfit.mount = 0
		end

		applyMountColorsToOutfitTable(podiumOutfit)

		podiumRequest = {
			outfit = podiumOutfit,
			position = podiumContext.position,
			itemClientId = podiumContext.itemClientId,
			stackpos = podiumContext.stackpos,
			direction = direction,
			showPlatform = showPlatform,
			showOutfit = showOutfit
		}
	end

	ignoreNextOutfitWindow = g_clock.millis()

	if podiumRequest then
		g_game.changeOutfitPodium(podiumRequest.outfit, podiumRequest.position, podiumRequest.itemClientId, podiumRequest.stackpos, podiumRequest.direction, podiumRequest.showPlatform, podiumRequest.showOutfit)
	elseif isHirelingOutfit then
		g_game.changeHirelingOutfit(outfitToSend)
	else
		g_game.changeOutfit(outfitToSend)
		pcall(function()
			g_game.sendAuraSet(var_223_2)
		end)

		if shouldToggleMount then
			local player = g_game.getLocalPlayer()

			if player then
				if not player:isMounted() and isMountedChecked then
					player:mount()
				elseif player:isMounted() and not isMountedChecked then
					player:dismount()
				end
			end
		end
	end

	destroy()
	addEvent(function()
		if g_modalManager and g_modalManager.pruneOrphanBlockers then
			g_modalManager.pruneOrphanBlockers()
		end

		if modules.game_containers and modules.game_containers.clearContainerDragHover then
			modules.game_containers.clearContainerDragHover()
		end

		if g_client and g_client.setInputLockWidget then
			pcall(function()
				g_client.setInputLockWidget(nil)
			end)
		end

		local draggingWidget = g_ui.getDraggingWidget()

		if draggingWidget and draggingWidget.hoveredWho then
			draggingWidget.hoveredWho:setBorderWidth(0)

			draggingWidget.hoveredWho = nil
		end
	end)
end
