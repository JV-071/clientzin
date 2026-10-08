imageSizeBroad = 0
imageSizeThin = 0
mapPanel = modules.game_interface.getMapPanel()

function currentViewMode()
	return modules.game_interface.currentViewMode
end

healthCircle = nil
manaCircle = nil
manaShieldCircle = nil
harmonyCircle = nil
sereneCircle = nil
arcConditionsBar = nil
manaShieldImageSizeBroad = 0
manaShieldImageSizeThin = 0

local HARMONY_ARC_SLOTS = 5
local ARC_BASE_WIDTH_AT_100 = 33
local ARC_BASE_HEIGHT_AT_100 = 120
local ARC_THICKNESS_AT_100 = 10
local SERENE_INSET_FROM_HEALTH_WIDGET_RIGHT_AT_BASE = 10
local SERENE_DIAMETER_AT_100 = 11.5
local SERENE_MIN_DIAMETER = 5
local SERENE_DIAMETER_PRESET_MUL = {
	small = 0.8,
	large = 1,
	default = 1
}
local CONDITION_BAR_WIDTH_AT_100 = 13
local CONDITION_BAR_MIN_HEIGHT_AT_100 = 21
local CONDITION_BAR_ICON_AT_100 = 9
local CONDITION_BAR_ICON_SPACING_AT_100 = 4
local CONDITION_BAR_CAP_PAD_AT_100 = 6
local CONDITION_BAR_GAP_FROM_HEALTH_AT_100 = 7
local MAP_BASE_WIDTH_AT_100 = 480
local MAP_BASE_HEIGHT_AT_100 = 352
local ARC_VERTICAL_OFFSET = -14
local ARC_DISTANCE_SCROLL_RANGE = {
	small = {
		min = 0,
		max = 695
	},
	default = {
		min = 0,
		max = 392
	},
	large = {
		min = 0,
		max = 217
	}
}

hudArcsSizePreset = "default"

local HUD_ARC_SCALE_PRESET_SMALL = 0.6
local HUD_ARC_SCALE_PRESET_LARGE = 1.61

hudArcScaleMul = 1
isHealthCircle = not g_settings.getBoolean("healthcircle_hpcircle")
isManaCircle = not g_settings.getBoolean("healthcircle_mpcircle")
distanceFromCenter = tonumber(g_settings.getNumber("healthcircle_distfromcenter")) or 0

local function arcDistanceScrollLoHi()
	local row = ARC_DISTANCE_SCROLL_RANGE[hudArcsSizePreset] or ARC_DISTANCE_SCROLL_RANGE.default

	return tonumber(row.min) or 0, tonumber(row.max) or 0
end

function arcScrollPercentToDistancePixels(percent)
	if type(percent) ~= "number" then
		return 0
	end

	percent = math.max(0, math.min(100, percent))

	local lo, hi = arcDistanceScrollLoHi()
	local numericValue

	numericValue = tonumber(lo) or 0

	local var_3_3

	var_3_3 = tonumber(hi) or numericValue

	return math.floor(numericValue + (var_3_3 - numericValue) * percent / 100 + 0.5)
end

function arcDistancePixelsToScrollPercent(px)
	if type(px) ~= "number" then
		return 0
	end

	local lo, hi = arcDistanceScrollLoHi()
	local numericValue

	numericValue = tonumber(lo) or 0

	local var_4_3

	var_4_3 = tonumber(hi) or numericValue

	if var_4_3 <= numericValue then
		return 0
	end

	px = math.max(numericValue, math.min(var_4_3, px))

	return math.floor((px - numericValue) / (var_4_3 - numericValue) * 100 + 0.5)
end

statsBarMenuLoaded = false

local hudArcsAllowed = false
local vitalsRefreshEvent
local lastManaShieldSplitKey
local lastHarmonySplitKey

local function hudOptionBool(key)
	local co = modules.client_options

	if not co or not co.getOption then
		return false
	end

	return co.getOption(key) == true
end

local function hudArcsShown()
	return hudArcsAllowed
end

local function computeHarmonySplit()
	if not hudOptionBool("showOwnHarmony") then
		return false, nil
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player then
		return false, nil
	end

	local voc = player:getVocation()

	if voc ~= VocationsClient.Monk and voc ~= VocationsClient.ExaltedMonk then
		return false, nil
	end

	if hudOptionBool("harmonyNextToHealth") then
		return true, "health"
	end

	if hudOptionBool("harmonyNextToMana") then
		return true, "mana"
	end

	return false, nil
end

function updateSereneDisplay()
	if not sereneCircle then
		return
	end

	if not hudArcsShown() then
		sereneCircle:setVisible(false)

		return
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player then
		sereneCircle:setVisible(false)

		return
	end

	if not computeHarmonySplit() then
		sereneCircle:setVisible(false)

		return
	end

	sereneCircle:setVisible(true)

	if player:isSerene() then
		sereneCircle:setPercent(100)
		sereneCircle:setFillColor("#D437FFBF")
	else
		sereneCircle:setPercent(0)
		sereneCircle:setTrackColor("#0000003C")
	end
end

local function computeManaShieldSplit()
	if not hudOptionBool("showManaShield") then
		return false, nil
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player then
		return false, nil
	end

	if (tonumber(player:getManaShield()) or 0) <= 0 then
		return false, nil
	end

	if hudOptionBool("manaShieldNextToMana") then
		return true, "mana"
	end

	if hudOptionBool("manaShieldNextToHealth") then
		return true, "health"
	end

	return false, nil
end

local function getMapArcLayoutScale()
	if not mapPanel then
		return 1
	end

	local mapWidth = tonumber(mapPanel:getWidth()) or 0
	local mapHeight = tonumber(mapPanel:getHeight()) or 0

	if mapWidth <= 0 or mapHeight <= 0 then
		return 1
	end

	local scaleByWidth = mapWidth / MAP_BASE_WIDTH_AT_100
	local scaleByHeight = mapHeight / MAP_BASE_HEIGHT_AT_100
	local scale = math.min(scaleByWidth, scaleByHeight) * (tonumber(hudArcScaleMul) or 1)
	local numericValue

	numericValue = tonumber(scale) or 1

	if numericValue <= 0 then
		return 1
	end

	return numericValue
end

local function getArcLayoutHalfGap()
	local arcGap = math.max(0, math.floor((distanceFromCenter or 0) * getMapArcLayoutScale() + 0.5))

	return math.floor(arcGap / 2 + 0.5)
end

local function getArcOutfitPlacementOffset()
	if g_game.getFeature and g_game.getFeature(GameNegativeOffset) then
		return 0, 0
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player or not g_things or not g_things.getThingType then
		return 0, 0
	end

	local outfit = player:getOutfit()

	if not outfit then
		return 0, 0
	end

	local numericValue = tonumber(outfit.type) or 0

	if numericValue <= 0 then
		return 0, 0
	end

	local lookType = numericValue
	local numericValue = tonumber(outfit.mount) or 0

	if numericValue > 0 then
		lookType = numericValue
	end

	local thingType = g_things.getThingType(lookType, ThingCategoryCreature)

	if not thingType then
		return 0, 0
	end

	local dispX = thingType:getDisplacementX() or 0
	local dispY = thingType:getDisplacementY() or 0
	local scale = getMapArcLayoutScale()

	return -math.floor(dispX * scale + 0.5), -math.floor(dispY * scale + 0.5)
end

local function getHealthArcBaseLayoutXY()
	if not mapPanel then
		return 0, 0
	end

	local halfGap = getArcLayoutHalfGap()
	local width = tonumber(mapPanel:getWidth()) or 0
	local height = tonumber(mapPanel:getHeight()) or 0
	local x = tonumber(mapPanel:getX()) or 0
	local y = tonumber(mapPanel:getY()) or 0
	local numericValue = tonumber(imageSizeThin) or 0
	local var_13_6 = tonumber(imageSizeBroad) or 0

	if currentViewMode() == 2 then
		return math.floor(width / 2 - numericValue - halfGap), math.floor(height / 2 - var_13_6 / 2 + ARC_VERTICAL_OFFSET)
	end

	return math.floor(x + width / 2 - numericValue - halfGap), math.floor(y + height / 2 - var_13_6 / 2 + ARC_VERTICAL_OFFSET)
end

local function getManaArcLeftNudge()
	return math.max(0, math.floor(1 * getMapArcLayoutScale() + 0.5))
end

local function getManaArcLayoutX()
	if not mapPanel then
		return 0
	end

	local ox = getArcOutfitPlacementOffset()
	local numericValue

	numericValue = tonumber(ox) or 0

	local halfGap = getArcLayoutHalfGap()
	local nudge = getManaArcLeftNudge()
	local width = tonumber(mapPanel:getWidth()) or 0
	local x = tonumber(mapPanel:getX()) or 0

	if currentViewMode() == 2 then
		return math.floor(width / 2 + halfGap) + numericValue - nudge
	end

	return math.floor(x + width / 2 + halfGap) + numericValue - nudge
end

local arcHudLayoutGuard = false
local arcHudLayoutPending = false
local arcConditionsRefreshScheduled = false
local var_0_38

local function getConditionsBarScale()
	if healthCircle then
		local height = tonumber(healthCircle:getHeight()) or 0

		if height > 0 then
			return height / ARC_BASE_HEIGHT_AT_100
		end
	end

	return getMapArcLayoutScale()
end

local function arcConditionsBarMetrics(iconCount, scale)
	scale = scale or getConditionsBarScale()

	local iconSize = math.max(1, math.floor(CONDITION_BAR_ICON_AT_100 * scale + 0.5))
	local iconSpacing = math.max(0, math.floor(CONDITION_BAR_ICON_SPACING_AT_100 * scale + 0.5))
	local capPad = math.max(1, math.floor(CONDITION_BAR_CAP_PAD_AT_100 * scale + 0.5))
	local gapCount = math.max(0, iconCount - 1)
	local contentH = iconCount * iconSize + gapCount * iconSpacing
	local barHeight = math.max(math.floor(CONDITION_BAR_MIN_HEIGHT_AT_100 * scale + 0.5), capPad * 2 + contentH)

	return {
		iconSize = iconSize,
		iconSpacing = iconSpacing,
		contentH = contentH,
		barHeight = barHeight,
		iconsY = math.max(0, math.floor((barHeight - contentH) / 2 + 0.5))
	}
end

local function arcConditionsBarHeight(iconCount, scale)
	if iconCount <= 0 then
		return 0
	end

	return arcConditionsBarMetrics(iconCount, scale).barHeight
end

local function resetArcConditionsBarLayout()
	if not arcConditionsBar then
		return
	end

	if arcConditionsBar.breakAnchors then
		arcConditionsBar:breakAnchors()
	end

	arcConditionsBar:setMarginTop(0)
	arcConditionsBar:setMarginBottom(0)
	arcConditionsBar:setMarginLeft(0)
	arcConditionsBar:setMarginRight(0)
end

local function resetArcConditionsIconsPanel(iconsPanel)
	if not iconsPanel then
		return
	end

	if iconsPanel.breakAnchors then
		iconsPanel:breakAnchors()
	end

	iconsPanel:setPosition({
		y = 0,
		x = 0
	})
	iconsPanel:setPaddingTop(0)
	iconsPanel:setPaddingBottom(0)
	iconsPanel:setPaddingLeft(0)
	iconsPanel:setPaddingRight(0)
	iconsPanel:setMarginTop(0)
	iconsPanel:setMarginBottom(0)
	iconsPanel:setMarginLeft(0)
	iconsPanel:setMarginRight(0)
end

local function sortArcConditionEntries(list)
	table.sort(list, function(a, b)
		if modules.client_options and modules.client_options.getConditionDisplayOrderIndex then
			local orderA = modules.client_options.getConditionDisplayOrderIndex(a.info.id)
			local orderB = modules.client_options.getConditionDisplayOrderIndex(b.info.id)

			if orderA ~= orderB then
				return orderA < orderB
			end
		end

		return a.state < b.state
	end)
end

local function collectActiveConditionStates(states)
	local list = {}
	local redSwordsActive = bit.band(states, PlayerStates.RedSwords) ~= 0

	for state, info in pairs(Icons) do
		if not (state == PlayerStates.Swords and redSwordsActive) and type(state) == "number" and state > 0 and info and info.id and bit.band(states, state) ~= 0 and (not modules.client_options or not modules.client_options.isSpecialConditionId(info.id) or modules.client_options.isConditionVisibleInHud(info.id)) then
			list[#list + 1] = {
				state = state,
				info = info
			}
		end
	end

	sortArcConditionEntries(list)

	return list
end

local function appendVirtualArcCondition(list, info, sortState, conditionId, displayInfo)
	if not info or not info.id then
		return
	end

	displayInfo = displayInfo or info

	local visible = true

	if modules.client_options and modules.client_options.isSpecialConditionId(conditionId or info.id) and modules.client_options.isConditionVisibleInHud then
		visible = modules.client_options.isConditionVisibleInHud(conditionId or info.id)
	end

	if not visible then
		return
	end

	for _, entry in ipairs(list) do
		if entry.info.id == info.id then
			return
		end
	end

	list[#list + 1] = {
		state = sortState,
		info = displayInfo
	}

	sortArcConditionEntries(list)
end

local function collectArcConditionEntries(player)
	local list = collectActiveConditionStates(player:getStates())

	if isPlayerHungry(player) then
		local hungryInfo = Icons.hungry

		if hungryInfo then
			appendVirtualArcCondition(list, hungryInfo, 0, hungryInfo.id)
		end
	end

	if isPlayerInRestingArea() then
		local restingInfo = getPlayerRestingAreaIconInfo()

		if restingInfo then
			appendVirtualArcCondition(list, SpecialConditionExtraIcons.condition_restingarea, 1, "condition_restingarea", restingInfo)
		end
	end

	local bakragoreIcon = getBakragoreTaintIconInfo(player:getBakragoreIcon())

	if bakragoreIcon then
		appendVirtualArcCondition(list, SpecialConditionExtraIcons.condition_bakragore_taint, 2, "condition_bakragore_taint", bakragoreIcon)
	end

	return list
end

local function getArcConditionsClusterWidth()
	if not hudArcsShown() or not isHealthCircle or not healthCircle or not healthCircle:isVisible() then
		return 0
	end

	if not g_game.isOnline() or not g_game.getLocalPlayer() then
		return 0
	end

	local scale = getConditionsBarScale()

	return math.max(1, math.floor(CONDITION_BAR_WIDTH_AT_100 * scale + 0.5)) + math.max(1, math.floor(CONDITION_BAR_GAP_FROM_HEALTH_AT_100 * scale + 0.5))
end

local function getHealthOutfitPlacementInwardCompensation()
	local ox, oy = getArcOutfitPlacementOffset()

	return math.max(0, -ox), math.max(0, -oy)
end

local function getHealthConditionsInwardOffset()
	local lo, hi = arcDistanceScrollLoHi()
	local numericValue

	numericValue = tonumber(lo) or 0

	local var_28_3

	var_28_3 = tonumber(hi) or numericValue

	local dist = tonumber(distanceFromCenter) or 0

	if dist <= numericValue then
		return 0
	end

	local t = 1

	if numericValue < var_28_3 then
		t = math.min(1, (dist - numericValue) / (var_28_3 - numericValue))
	end

	local inward = 0
	local cluster = getArcConditionsClusterWidth()

	if cluster > 0 then
		inward = math.floor(cluster * t + 0.5)
	end

	local outfitInX, _ = getHealthOutfitPlacementInwardCompensation()
	local numericValue

	numericValue = tonumber(outfitInX) or 0

	return inward + math.floor(numericValue * t + 0.5)
end

local function getMapPanelLayoutLeftTop()
	if not mapPanel then
		return 0, 0
	end

	if currentViewMode() == 2 then
		return 0, 0
	end

	return tonumber(mapPanel:getX()) or 0, tonumber(mapPanel:getY()) or 0
end

local function clampHealthArcLayoutXY(healthX, healthY)
	if not mapPanel then
		return healthX, healthY
	end

	healthX = tonumber(healthX) or 0
	healthY = tonumber(healthY) or 0

	local var_30_0, var_30_1 = getMapPanelLayoutLeftTop()
	local mapLeft

	mapLeft = tonumber(var_30_0) or 0

	local mapTop

	mapTop = tonumber(var_30_1) or 0

	local cluster = tonumber(getArcConditionsClusterWidth()) or 0

	if cluster > 0 then
		local leftEdge = healthX - cluster

		if leftEdge < mapLeft then
			healthX = healthX + (mapLeft - leftEdge)
		end
	elseif healthX < mapLeft then
		healthX = mapLeft
	end

	if healthY < mapTop then
		healthY = mapTop
	end

	return healthX, healthY
end

local function getHealthArcLayoutXY()
	local x, y = getHealthArcBaseLayoutXY()
	local ox

	ox = tonumber(x) or 0

	local numericValue

	numericValue = tonumber(y) or 0

	local var_31_4, var_31_5 = getArcOutfitPlacementOffset()
	local var_31_6

	var_31_6 = tonumber(var_31_4) or 0

	local oy

	oy = tonumber(var_31_5) or 0

	local unusedValue, var_31_9 = getHealthOutfitPlacementInwardCompensation()
	local outfitInY

	outfitInY = tonumber(var_31_9) or 0

	local x = ox + (tonumber(getHealthConditionsInwardOffset()) or 0) + var_31_6
	local y = numericValue + oy + outfitInY

	return clampHealthArcLayoutXY(x, y)
end

local function createArcConditionIcon(icon, info, iconSize)
	applyPlayerStateIcon(icon, info)

	local tooltip = info.tooltip

	if tooltip == "You are GoshnarTaint" then
		tooltip = "Goshnar's Lairs Penalties:\n" .. "- 10% chance of creature teleportation to you\n" .. "- 0.5% chance of new creature spawn when hitting another\n" .. "- 15% increased damage received\n" .. "- 10% chance of creature full heal instead of dying\n" .. "- Lose 10% of current HP and mana every 10 seconds"
	end

	icon:setTooltip(tooltip)
	icon:setSize({
		width = iconSize,
		height = iconSize
	})
	icon:setImageSize(tosize(iconSize .. " " .. iconSize))
end

local function var_0_55(arg_33_0)
	for unusedValue, child in ipairs(arg_33_0:getChildren()) do
		child:hide()
	end
end

local function var_0_56(arg_34_0)
	local icon = 0

	for unusedValue, child in ipairs(arg_34_0:getChildren()) do
		if child:isExplicitlyVisible() then
			icon = icon + 1
		end
	end

	return icon
end

local function ensureArcConditionsIconsLayout(iconsPanel)
	local layout = iconsPanel:getLayout()

	if layout and layout.setSpacing then
		return layout
	end

	local layout = UIVerticalLayout.create(iconsPanel)

	iconsPanel:setLayout(layout)

	return layout
end

local function layoutArcConditionIcons(iconsPanel, active, metrics, barWidth)
	local sidePad = math.max(0, math.floor((barWidth - metrics.iconSize) / 2 + 0.5))
	local padBottom = math.max(0, metrics.barHeight - metrics.iconsY - metrics.contentH)

	iconsPanel:setPaddingTop(metrics.iconsY)
	iconsPanel:setPaddingBottom(padBottom)
	iconsPanel:setPaddingLeft(sidePad)
	iconsPanel:setPaddingRight(sidePad)
	ensureArcConditionsIconsLayout(iconsPanel):setSpacing(metrics.iconSpacing)

	local var_36_2 = {}

	for _, entry in ipairs(active) do
		local childById = iconsPanel:getChildById(entry.info.id)

		if not childById then
			childById = g_ui.createWidget("ArcConditionIcon", iconsPanel)

			childById:setId(entry.info.id)
		end

		createArcConditionIcon(childById, entry.info, metrics.iconSize)
		childById:show()
		iconsPanel:moveChildToIndex(childById, _)

		var_36_2[entry.info.id] = true
	end

	for unusedValue, child in ipairs(iconsPanel:getChildren()) do
		if not var_36_2[child:getId()] then
			child:hide()
		end
	end

	iconsPanel:updateLayout()
end

local function layoutArcConditionsPosition()
	if not arcConditionsBar or not healthCircle or not mapPanel or not arcConditionsBar:isVisible() then
		return
	end

	local scale = getMapArcLayoutScale()
	local gap = math.max(1, math.floor(CONDITION_BAR_GAP_FROM_HEALTH_AT_100 * scale + 0.5))
	local barW = tonumber(arcConditionsBar:getWidth()) or 0
	local barH = tonumber(arcConditionsBar:getHeight()) or 0
	local healthX, healthY = getHealthArcLayoutXY()
	local numericValue = tonumber(imageSizeBroad) or 0

	if arcConditionsBar.breakAnchors then
		arcConditionsBar:breakAnchors()
	end

	arcConditionsBar:setPosition({
		x = healthX - gap - barW,
		y = healthY + math.floor((numericValue - barH) / 2 + 0.5)
	})
end

local function updateArcConditionsDisplay()
	if not arcConditionsBar then
		return
	end

	local iconsPanel = arcConditionsBar:getChildById("icons")

	if not iconsPanel then
		return
	end

	var_0_38 = nil

	if not hudArcsShown() or not isHealthCircle or not healthCircle or not healthCircle:isVisible() then
		arcConditionsBar:setVisible(false)
		var_0_55(iconsPanel)

		return
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player then
		arcConditionsBar:setVisible(false)
		var_0_55(iconsPanel)

		return
	end

	var_0_38 = isPlayerHungry(player)

	local scale = getConditionsBarScale()
	local barWidth = math.max(1, math.floor(CONDITION_BAR_WIDTH_AT_100 * scale + 0.5))
	local active = {}
	local var_38_5 = {}

	for unusedValue, entry in ipairs(collectArcConditionEntries(player)) do
		if not var_38_5[entry.info.id] then
			var_38_5[entry.info.id] = true
			active[#active + 1] = entry
		end
	end

	local iconCount = #active

	if iconCount == 0 then
		arcConditionsBar:setVisible(false)
		var_0_55(iconsPanel)

		return
	end

	arcConditionsBar:setVisible(false)
	resetArcConditionsBarLayout()
	resetArcConditionsIconsPanel(iconsPanel)

	local ok, err = pcall(function()
		local metrics = arcConditionsBarMetrics(iconCount, scale)

		arcConditionsBar:setSize({
			width = barWidth,
			height = metrics.barHeight
		})
		iconsPanel:setSize({
			width = barWidth,
			height = metrics.barHeight
		})
		layoutArcConditionIcons(iconsPanel, active, metrics, barWidth)
	end)

	if ok and var_0_56(iconsPanel) > 0 then
		arcConditionsBar:setVisible(true)
		layoutArcConditionsPosition()
		arcConditionsBar:raise()
	else
		arcConditionsBar:setVisible(false)
		var_0_55(iconsPanel)

		if not ok then
			g_logger.error(string.format("[game_healthcircle] updateArcConditionsDisplay: %s", tostring(err)))
		end
	end
end

local function scheduleArcConditionsRefresh()
	if arcConditionsRefreshScheduled then
		return
	end

	arcConditionsRefreshScheduled = true

	addEvent(function()
		arcConditionsRefreshScheduled = false

		updateArcConditionsDisplay()
	end)
end

function refreshArcConditionsBarDeferred()
	scheduleArcConditionsRefresh()
end

local function repairArcConditionsIfMissing()
	if not arcConditionsBar or not arcConditionsBar:isVisible() then
		return
	end

	local iconsPanel = arcConditionsBar:getChildById("icons")

	if not iconsPanel or var_0_56(iconsPanel) > 0 then
		return
	end

	if not hudArcsShown() or not isHealthCircle or not healthCircle or not healthCircle:isVisible() then
		return
	end

	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not player or #collectArcConditionEntries(player) == 0 then
		return
	end

	updateArcConditionsDisplay()
end

local function layoutHealthManaArcPositions()
	if not mapPanel or not healthCircle or not manaCircle then
		return
	end

	local healthX, healthY = getHealthArcLayoutXY()
	local manaX = getManaArcLayoutX()

	healthCircle:setX(healthX)
	manaCircle:setX(manaX)
	healthCircle:setY(healthY)
	manaCircle:setY(healthY)

	local hSplit, hPair = computeHarmonySplit()

	if hudArcsShown() and harmonyCircle and hSplit and hPair == "mana" then
		harmonyCircle:setX(manaCircle:getX())
		harmonyCircle:setY(manaCircle:getY())
		manaCircle:raise()
		harmonyCircle:raise()
	elseif hudArcsShown() and harmonyCircle and hSplit and hPair == "health" then
		harmonyCircle:setX(healthCircle:getX())
		harmonyCircle:setY(healthCircle:getY())
		healthCircle:raise()
		harmonyCircle:raise()
	end

	local split, pair = computeManaShieldSplit()

	if hudArcsShown() and manaShieldCircle and split and pair == "mana" then
		manaShieldCircle:setX(manaCircle:getX())
		manaShieldCircle:setY(manaCircle:getY())
		manaCircle:raise()

		if harmonyCircle and hSplit and hPair == "mana" then
			harmonyCircle:raise()
		end
	elseif hudArcsShown() and manaShieldCircle and split and pair == "health" then
		manaShieldCircle:setX(healthCircle:getX())
		manaShieldCircle:setY(healthCircle:getY())
		healthCircle:raise()

		if harmonyCircle and hSplit and hPair == "health" then
			harmonyCircle:raise()
		end
	end

	if sereneCircle and healthCircle and manaCircle then
		local sw = tonumber(sereneCircle:getWidth()) or 0
		local sh = tonumber(sereneCircle:getHeight()) or 0

		if sw > 0 and sh > 0 then
			local serenePullLeft = tonumber(imageSizeThin) or 1
			local numericValue = tonumber(imageSizeBroad) or 1
			local var_44_11 = math.max(0, math.floor(SERENE_INSET_FROM_HEALTH_WIDGET_RIGHT_AT_BASE * (serenePullLeft / ARC_BASE_WIDTH_AT_100) + 0.5))
			local hSplit, hPair = computeHarmonySplit()
			local x = tonumber(manaCircle:getX()) or 0
			local y = tonumber(manaCircle:getY()) or 0
			local var_44_16 = tonumber(healthCircle:getX()) or 0
			local var_44_17 = tonumber(healthCircle:getY()) or 0

			if hSplit and hPair == "mana" then
				sereneCircle:setX(x + var_44_11)
				sereneCircle:setY(y + math.floor((numericValue - sh) / 2))
			else
				sereneCircle:setX(var_44_16 + serenePullLeft - sw - var_44_11)
				sereneCircle:setY(var_44_17 + math.floor((numericValue - sh) / 2))
			end

			if hudArcsShown() and sereneCircle:isVisible() then
				sereneCircle:raise()
			end
		end
	end

	layoutArcConditionsPosition()
	repairArcConditionsIfMissing()
end

local function whenLocalPlayerOutfitChange(localPlayer, outfit, oldOutfit)
	if not mapPanel or not healthCircle or not manaCircle then
		return
	end

	layoutHealthManaArcPositions()
	updateArcConditionsDisplay()
end

local function whenLocalPlayerStatesChange(localPlayer, now, old)
	if now == old then
		return
	end

	updateArcConditionsDisplay()
end

local function whenRegenerationChange(localPlayer, now, old)
	if now == old then
		return
	end

	if isPlayerHungry(localPlayer) == var_0_38 then
		return
	end

	updateArcConditionsDisplay()
end

local function cancelVitalsRefresh()
	if vitalsRefreshEvent then
		removeEvent(vitalsRefreshEvent)

		vitalsRefreshEvent = nil
	end
end

local function scheduleVitalsRefresh()
	if vitalsRefreshEvent then
		return
	end

	vitalsRefreshEvent = addEvent(function()
		vitalsRefreshEvent = nil

		whenHealthChange()
		whenManaChange()
	end)
end

local function onGameEndForHealthCircle()
	cancelVitalsRefresh()

	if not arcConditionsBar then
		return
	end

	resetPlayerRestingAreaState()
	arcConditionsBar:setVisible(false)
	resetArcConditionsBarLayout()

	local iconsPanel = arcConditionsBar:getChildById("icons")

	if iconsPanel then
		iconsPanel:destroyChildren()
		resetArcConditionsIconsPanel(iconsPanel)
	end
end

local function onGameStartForHealthCircle()
	whenMapResizeChange()

	if modules.client_options and modules.client_options.getOption then
		syncShowArcsFromClientOptions(modules.client_options.getOption("showArcs"), nil)
	end
end

function init()
	mapPanel = modules.game_interface.getMapPanel()

	g_ui.importStyle("game_healthcircle.otui")

	healthCircle = g_ui.createWidget("HealthProgressArc", mapPanel)
	manaCircle = g_ui.createWidget("ManaProgressArc", mapPanel)
	manaShieldCircle = g_ui.createWidget("ManaShieldProgressArc", mapPanel)
	harmonyCircle = g_ui.createWidget("HarmonyProgressArc", mapPanel)
	sereneCircle = g_ui.createWidget("SereneStatusCircle", mapPanel)
	arcConditionsBar = g_ui.createWidget("ArcConditionsBar", mapPanel)

	arcConditionsBar:setVisible(false)

	if modules.client_options and modules.client_options.getOption then
		local s = modules.client_options.getOption("showArcsSize") or "default"

		if s == "small" then
			hudArcsSizePreset = "small"
			hudArcScaleMul = HUD_ARC_SCALE_PRESET_SMALL
		elseif s == "large" then
			hudArcsSizePreset = "large"
			hudArcScaleMul = HUD_ARC_SCALE_PRESET_LARGE
		else
			hudArcsSizePreset = "default"
			hudArcScaleMul = 1
		end
	end

	imageSizeBroad = math.max(1, tonumber(healthCircle:getHeight()) or 1)
	imageSizeThin = math.max(1, tonumber(healthCircle:getWidth()) or 1)
	manaShieldImageSizeBroad = math.max(1, tonumber(manaShieldCircle:getHeight()) or 1)
	manaShieldImageSizeThin = math.max(1, tonumber(manaShieldCircle:getWidth()) or 1)

	manaShieldCircle:setVisible(false)
	harmonyCircle:setVisible(false)
	sereneCircle:setVisible(false)
	whenMapResizeChange()
	initOnHpAndMpChange()
	initOnGeometryChange()
	initOnLoginChange()

	hudArcsAllowed = g_settings.getBoolean("showArcs")

	if not isHealthCircle then
		healthCircle:setVisible(false)
	end

	if not isManaCircle then
		manaCircle:setVisible(false)
	end

	addToOptionsModule()
	addEvent(function()
		if modules.client_options and modules.client_options.getOption then
			syncShowArcsFromClientOptions(modules.client_options.getOption("showArcs"), nil)
		end
	end)
end

function terminate()
	cancelVitalsRefresh()
	healthCircle:destroy()

	healthCircle = nil

	manaCircle:destroy()

	manaCircle = nil

	manaShieldCircle:destroy()

	manaShieldCircle = nil

	harmonyCircle:destroy()

	harmonyCircle = nil

	sereneCircle:destroy()

	sereneCircle = nil

	arcConditionsBar:destroy()

	arcConditionsBar = nil

	terminateOnHpAndMpChange()
	terminateOnGeometryChange()
	terminateOnLoginChange()
	destroyOptionsModule()

	statsBarMenuLoaded = false
end

function initOnHpAndMpChange()
	connect(LocalPlayer, {
		onHealthChange = scheduleVitalsRefresh,
		onManaChange = scheduleVitalsRefresh,
		onManaShieldChange = scheduleVitalsRefresh,
		onHarmonyChange = whenHarmonyChange,
		onSereneChange = whenSereneChange,
		onVocationChange = whenLocalPlayerVocationChange,
		onOutfitChange = whenLocalPlayerOutfitChange,
		onStatesChange = whenLocalPlayerStatesChange,
		onBakragoreIconChange = updateArcConditionsDisplay,
		onRegenerationChange = whenRegenerationChange
	})
end

function terminateOnHpAndMpChange()
	disconnect(LocalPlayer, {
		onHealthChange = scheduleVitalsRefresh,
		onManaChange = scheduleVitalsRefresh,
		onManaShieldChange = scheduleVitalsRefresh,
		onHarmonyChange = whenHarmonyChange,
		onSereneChange = whenSereneChange,
		onVocationChange = whenLocalPlayerVocationChange,
		onOutfitChange = whenLocalPlayerOutfitChange,
		onStatesChange = whenLocalPlayerStatesChange,
		onBakragoreIconChange = updateArcConditionsDisplay,
		onRegenerationChange = whenRegenerationChange
	})
end

function initOnGeometryChange()
	connect(mapPanel, {
		onGeometryChange = whenMapResizeChange
	})
end

function terminateOnGeometryChange()
	disconnect(mapPanel, {
		onGeometryChange = whenMapResizeChange
	})
end

local function onRestingAreaStateForArc(zone, state, message)
	if updatePlayerRestingAreaState(zone, state, message) then
		updateArcConditionsDisplay()
	end
end

function initOnLoginChange()
	connect(g_game, {
		onGameStart = onGameStartForHealthCircle,
		onGameEnd = onGameEndForHealthCircle,
		onRestingAreaState = onRestingAreaStateForArc
	})
end

function terminateOnLoginChange()
	disconnect(g_game, {
		onGameStart = onGameStartForHealthCircle,
		onGameEnd = onGameEndForHealthCircle,
		onRestingAreaState = onRestingAreaStateForArc
	})
end

function whenHealthChange()
	if g_game.isOnline() then
		local healthPercent = math.floor(g_game.getLocalPlayer():getHealth() / g_game.getLocalPlayer():getMaxHealth() * 100)

		healthCircle:setPercent(healthPercent)
		healthCircle:setFillColor(getHealthColorByPercentWithAlpha(healthPercent))
	end
end

local function updateHarmonyDisplay()
	if not harmonyCircle or not manaCircle or not healthCircle then
		return
	end

	if not hudArcsShown() then
		harmonyCircle:setVisible(false)
		updateSereneDisplay()

		if lastHarmonySplitKey ~= nil then
			lastHarmonySplitKey = nil

			applyArcScaleByMapPanel()
			layoutHealthManaArcPositions()
		end

		return
	end

	local split, pair = computeHarmonySplit()
	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not split or not player then
		harmonyCircle:setVisible(false)
		updateSereneDisplay()

		if lastHarmonySplitKey ~= nil then
			lastHarmonySplitKey = nil

			applyArcScaleByMapPanel()
			layoutHealthManaArcPositions()
		end

		return
	end

	harmonyCircle:setVisible(true)

	local harmony = tonumber(player:getHarmony()) or 0

	harmonyCircle:setArcFilledSlots(math.min(HARMONY_ARC_SLOTS, harmony))

	if pair ~= lastHarmonySplitKey then
		lastHarmonySplitKey = pair

		applyArcScaleByMapPanel()
		layoutHealthManaArcPositions()
	end

	updateSereneDisplay()
end

local function updateManaShieldDisplay()
	if not manaShieldCircle or not manaCircle or not healthCircle then
		return
	end

	if not hudArcsShown() then
		manaShieldCircle:setVisible(false)

		if lastManaShieldSplitKey ~= nil then
			lastManaShieldSplitKey = nil

			applyArcScaleByMapPanel()
			layoutHealthManaArcPositions()
		end

		updateHarmonyDisplay()

		return
	end

	local split, pair = computeManaShieldSplit()
	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	if not split or not player then
		manaShieldCircle:setVisible(false)

		if lastManaShieldSplitKey ~= nil then
			lastManaShieldSplitKey = nil

			applyArcScaleByMapPanel()
			layoutHealthManaArcPositions()
		end
	else
		local maxShield = player:getMaxManaShield()
		local remainingShield = player:getManaShield()

		if maxShield <= 0 then
			maxShield = remainingShield
		end

		local var_65_5 = 100 * math.max(math.min(remainingShield, maxShield), 0) / maxShield

		manaShieldCircle:setVisible(true)
		manaShieldCircle:setPercent(var_65_5)

		if pair ~= lastManaShieldSplitKey then
			lastManaShieldSplitKey = pair

			applyArcScaleByMapPanel()
			layoutHealthManaArcPositions()
		end
	end

	updateHarmonyDisplay()
end

function whenHarmonyChange()
	updateHarmonyDisplay()
end

function whenSereneChange()
	updateSereneDisplay()
	layoutHealthManaArcPositions()
end

function whenLocalPlayerVocationChange()
	updateManaShieldDisplay()
end

function whenManaShieldChange()
	updateManaShieldDisplay()
end

function whenManaChange()
	if g_game.isOnline() then
		local player = g_game.getLocalPlayer()
		local maxMana = player:getMaxMana()

		if maxMana <= 0 then
			manaCircle:setVisible(false)

			if manaShieldCircle then
				manaShieldCircle:setVisible(false)
			end

			if harmonyCircle then
				harmonyCircle:setVisible(false)
			end

			if sereneCircle then
				sereneCircle:setVisible(false)
			end

			return
		elseif isManaCircle then
			manaCircle:setVisible(true)
		end

		updateManaShieldDisplay()

		local currentMana = player:getMana()
		local manaPercent = math.floor(currentMana / maxMana * 100)

		if manaPercent >= 99.5 then
			manaPercent = 100
		elseif manaPercent < 0 then
			manaPercent = 0
		end

		manaCircle:setPercent(manaPercent)
	end
end

function whenMapResizeChange()
	if arcHudLayoutGuard then
		arcHudLayoutPending = true

		return
	end

	arcHudLayoutGuard = true

	local ok, err = pcall(function()
		applyArcScaleByMapPanel()

		if g_game.isOnline() then
			whenHealthChange()
			whenManaChange()
		end

		updateManaShieldDisplay()
		updateSereneDisplay()
		layoutHealthManaArcPositions()
		updateArcConditionsDisplay()
	end)

	arcHudLayoutGuard = false

	if not ok then
		g_logger.error(string.format("[game_healthcircle] whenMapResizeChange: %s", tostring(err)))
	end

	if arcHudLayoutPending then
		arcHudLayoutPending = false

		whenMapResizeChange()

		return
	end

	scheduleArcConditionsRefresh()
end

function applyArcScaleByMapPanel()
	if not healthCircle or not manaCircle or not manaShieldCircle or not harmonyCircle or not mapPanel then
		return
	end

	local mapWidth = tonumber(mapPanel:getWidth()) or 0
	local mapHeight = tonumber(mapPanel:getHeight()) or 0

	if mapWidth <= 0 or mapHeight <= 0 then
		imageSizeBroad = math.max(1, tonumber(healthCircle:getHeight()) or 1)
		imageSizeThin = math.max(1, tonumber(healthCircle:getWidth()) or 1)

		return
	end

	local scaleByWidth = mapWidth / MAP_BASE_WIDTH_AT_100
	local scaleByHeight = mapHeight / MAP_BASE_HEIGHT_AT_100
	local scale = math.min(scaleByWidth, scaleByHeight) * (tonumber(hudArcScaleMul) or 1)
	local numericValue

	numericValue = tonumber(scale) or 1

	if numericValue <= 0 then
		numericValue = 1
	end

	local arcWidth = math.max(1, math.floor(ARC_BASE_WIDTH_AT_100 * numericValue + 0.5))
	local arcHeight = math.max(1, math.floor(ARC_BASE_HEIGHT_AT_100 * numericValue))
	local arcThickness = math.max(1, math.floor(ARC_THICKNESS_AT_100 * numericValue + 0.5))
	local sShield, pShield = computeManaShieldSplit()
	local sHarm, pHarm = computeHarmonySplit()

	if not hudArcsShown() then
		sShield, pShield = false
		sHarm, pHarm = false
	end

	local nHealthAux = 0

	if sShield and pShield == "health" then
		nHealthAux = 1
	end

	if sHarm and pHarm == "health" then
		nHealthAux = nHealthAux + 1
	end

	local nManaAux = 0

	if sShield and pShield == "mana" then
		nManaAux = 1
	end

	if sHarm and pHarm == "mana" then
		nManaAux = nManaAux + 1
	end

	local bandsHealth = 1 + nHealthAux
	local bandsMana = 1 + nManaAux
	local hpThickness = math.max(1, math.floor(arcThickness / bandsHealth + 0.5))
	local mpThickness = math.max(1, math.floor(arcThickness / bandsMana + 0.5))

	healthCircle:setWidth(arcWidth)
	healthCircle:setHeight(arcHeight)
	healthCircle:setThickness(hpThickness)
	manaCircle:setWidth(arcWidth)
	manaCircle:setHeight(arcHeight)
	manaCircle:setThickness(mpThickness)
	manaShieldCircle:setWidth(arcWidth)
	manaShieldCircle:setHeight(arcHeight)
	harmonyCircle:setWidth(arcWidth)
	harmonyCircle:setHeight(arcHeight)

	if sereneCircle then
		local presetMul = SERENE_DIAMETER_PRESET_MUL[hudArcsSizePreset] or SERENE_DIAMETER_PRESET_MUL.default
		local sereneSize = math.max(SERENE_MIN_DIAMETER, math.floor(arcWidth * (SERENE_DIAMETER_AT_100 / ARC_BASE_WIDTH_AT_100) * presetMul + 0.5))

		sereneCircle:setWidth(sereneSize)
		sereneCircle:setHeight(sereneSize)
		sereneCircle:setThickness(sereneSize)
	end

	local idxHealth = 0
	local idxMana = 0

	if sShield and pShield == "health" then
		idxHealth = idxHealth + 1

		manaShieldCircle:setThickness(hpThickness)
		manaShieldCircle:setRadialInset(hpThickness * idxHealth)
	elseif sShield and pShield == "mana" then
		idxMana = idxMana + 1

		manaShieldCircle:setThickness(mpThickness)
		manaShieldCircle:setRadialInset(mpThickness * idxMana)
	else
		manaShieldCircle:setThickness(arcThickness)
		manaShieldCircle:setRadialInset(0)
	end

	if sHarm and pHarm == "health" then
		local idxHealth = idxHealth + 1

		harmonyCircle:setThickness(hpThickness)
		harmonyCircle:setRadialInset(hpThickness * idxHealth)
	elseif sHarm and pHarm == "mana" then
		local idxMana = idxMana + 1

		harmonyCircle:setThickness(mpThickness)
		harmonyCircle:setRadialInset(mpThickness * idxMana)
	else
		harmonyCircle:setThickness(arcThickness)
		harmonyCircle:setRadialInset(0)
	end

	if sShield and pShield == "mana" then
		manaShieldCircle:setArcLayoutSide("right")
		manaShieldCircle:setStartAngle(45)
		manaShieldCircle:setFullSpan(90)
		manaShieldCircle:setFillFromEnd(true)
	elseif sShield and pShield == "health" then
		manaShieldCircle:setArcLayoutSide("left")
		manaShieldCircle:setStartAngle(225)
		manaShieldCircle:setFullSpan(90)
		manaShieldCircle:setFillFromEnd(false)
	else
		manaShieldCircle:setArcLayoutSide("left")
		manaShieldCircle:setStartAngle(225)
		manaShieldCircle:setFullSpan(90)
		manaShieldCircle:setFillFromEnd(false)
	end

	if sHarm and pHarm == "mana" then
		harmonyCircle:setArcLayoutSide("right")
		harmonyCircle:setStartAngle(45)
		harmonyCircle:setFullSpan(90)
		harmonyCircle:setFillFromEnd(true)
	elseif sHarm and pHarm == "health" then
		harmonyCircle:setArcLayoutSide("left")
		harmonyCircle:setStartAngle(225)
		harmonyCircle:setFullSpan(90)
		harmonyCircle:setFillFromEnd(false)
	else
		harmonyCircle:setArcLayoutSide("left")
		harmonyCircle:setStartAngle(225)
		harmonyCircle:setFullSpan(90)
		harmonyCircle:setFillFromEnd(false)
	end

	imageSizeBroad = math.max(1, tonumber(healthCircle:getHeight()) or 1)
	imageSizeThin = math.max(1, tonumber(healthCircle:getWidth()) or 1)
	manaShieldImageSizeBroad = math.max(1, tonumber(manaShieldCircle:getHeight()) or 1)
	manaShieldImageSizeThin = math.max(1, tonumber(manaShieldCircle:getWidth()) or 1)
end

function syncManaShieldHudOptions(options)
	lastManaShieldSplitKey = nil
	lastHarmonySplitKey = nil

	whenMapResizeChange()
end

local function hudOptionValue(options, key)
	if options and type(options) == "table" then
		local o = options[key]

		if type(o) == "table" then
			if o.pendingValue ~= nil then
				return o.pendingValue
			end

			return o.value
		end
	end

	if modules.client_options and modules.client_options.getOption then
		return modules.client_options.getOption(key)
	end

	return nil
end

function syncShowArcsFromClientOptions(show, options)
	show = toboolean(show)
	hudArcsAllowed = show

	if not healthCircle or not manaCircle then
		return
	end

	if not show then
		setHealthCircle(false)
		setManaCircle(false)

		if healthCheckBox then
			healthCheckBox:setChecked(false)
		end

		if manaCheckBox then
			manaCheckBox:setChecked(false)
		end

		if manaShieldCircle then
			manaShieldCircle:setVisible(false)
		end

		if harmonyCircle then
			harmonyCircle:setVisible(false)
		end

		if sereneCircle then
			sereneCircle:setVisible(false)
		end

		if arcConditionsBar then
			arcConditionsBar:setVisible(false)
		end

		lastManaShieldSplitKey = nil
		lastHarmonySplitKey = nil

		applyArcScaleByMapPanel()
		layoutHealthManaArcPositions()
		updateArcConditionsDisplay()

		return
	end

	setHealthCircle(true)
	setManaCircle(true)

	if healthCheckBox then
		healthCheckBox:setChecked(true)
	end

	if manaCheckBox then
		manaCheckBox:setChecked(true)
	end

	local size = hudOptionValue(options, "showArcsSize") or "default"

	if size == "small" then
		hudArcScaleMul = HUD_ARC_SCALE_PRESET_SMALL
		hudArcsSizePreset = "small"
	elseif size == "large" then
		hudArcScaleMul = HUD_ARC_SCALE_PRESET_LARGE
		hudArcsSizePreset = "large"
	else
		hudArcScaleMul = 1
		hudArcsSizePreset = "default"
	end

	local dist = hudOptionValue(options, "showArcsDistanceScroll")

	if type(dist) == "number" then
		setDistanceFromCenter(arcScrollPercentToDistancePixels(dist))
	end

	local op = hudOptionValue(options, "showArcsOpacityScroll")

	if type(op) == "number" then
		local var_76_3 = math.max(20, math.min(100, op)) / 100

		healthCircle:setOpacity(var_76_3)
		manaCircle:setOpacity(var_76_3)

		if manaShieldCircle then
			manaShieldCircle:setOpacity(var_76_3)
		end

		if harmonyCircle then
			harmonyCircle:setOpacity(var_76_3)
		end

		if sereneCircle then
			sereneCircle:setOpacity(var_76_3)
		end
	end

	lastManaShieldSplitKey = nil
	lastHarmonySplitKey = nil

	applyArcScaleByMapPanel()
	whenMapResizeChange()
	updateSereneDisplay()
	updateArcConditionsDisplay()
	scheduleArcConditionsRefresh()
end

function setHealthCircle(value)
	value = toboolean(value)
	isHealthCircle = value

	if value then
		healthCircle:setVisible(true)
		whenMapResizeChange()
		scheduleArcConditionsRefresh()
	else
		healthCircle:setVisible(false)
		updateManaShieldDisplay()
		updateArcConditionsDisplay()
	end

	g_settings.set("healthcircle_hpcircle", not value)
end

function setManaCircle(value)
	value = toboolean(value)
	isManaCircle = value

	if value then
		manaCircle:setVisible(true)
		whenMapResizeChange()
		scheduleArcConditionsRefresh()
	else
		manaCircle:setVisible(false)
		updateManaShieldDisplay()
	end

	g_settings.set("healthcircle_mpcircle", not value)
end

function setDistanceFromCenter(value)
	distanceFromCenter = value

	whenMapResizeChange()
	g_settings.set("healthcircle_distfromcenter", value)
end

function setCircleOpacity(value)
	return
end

optionPanel = nil
healthCheckBox = nil
manaCheckBox = nil
chooseStatsBarDimension = nil
chooseStatsBarPlacement = nil
distFromCenScrollbar = nil

local suppressStatsBarComboSignal = false

local function isStatsBarComboValid(combo)
	return combo and not combo:isDestroyed() and combo.setCurrentOptionByData ~= nil
end

local function clearStatsBarMenuRefs()
	statsBarMenuLoaded = false
	healthCheckBox = nil
	manaCheckBox = nil
	distFromCenScrollbar = nil
	chooseStatsBarDimension = nil
	chooseStatsBarPlacement = nil
end

function addToOptionsModule()
	if optionPanel then
		modules.client_options.removeButton("Interface", "HP/MP Circle")

		if not optionPanel:isDestroyed() then
			optionPanel:destroy()
		end

		optionPanel = nil
	end

	clearStatsBarMenuRefs()

	optionPanel = g_ui.loadUI("option_healthcircle", modules.client_options:getPanel())
	healthCheckBox = optionPanel:recursiveGetChildById("healthCheckBox")
	manaCheckBox = optionPanel:recursiveGetChildById("manaCheckBox")
	chooseStatsBarDimension = optionPanel:recursiveGetChildById("chooseStatsBarDimension")
	chooseStatsBarPlacement = optionPanel:recursiveGetChildById("chooseStatsBarPlacement")
	distFromCenScrollbar = optionPanel:recursiveGetChildById("distFromCenScrollbar")

	if not isStatsBarComboValid(chooseStatsBarPlacement) or not isStatsBarComboValid(chooseStatsBarDimension) then
		clearStatsBarMenuRefs()

		return
	end

	chooseStatsBarPlacement:addOption(tr("Top"), "top")
	chooseStatsBarPlacement:addOption(tr("Bottom"), "bottom")
	chooseStatsBarPlacement:addOption(tr("Left"), "left")
	chooseStatsBarPlacement:addOption(tr("Right"), "right")
	chooseStatsBarDimension:addOption(tr("Hide"), "hide")
	chooseStatsBarDimension:addOption(tr("Compact"), "compact")
	chooseStatsBarDimension:addOption(tr("Default"), "default")
	chooseStatsBarDimension:addOption(tr("Large"), "large")
	chooseStatsBarDimension:addOption(tr("Parallel"), "parallel")

	statsBarMenuLoaded = true
	suppressStatsBarComboSignal = true

	chooseStatsBarDimension:setCurrentOptionByData(g_settings.getString("statsbar_dimension"), true)
	chooseStatsBarPlacement:setCurrentOptionByData(g_settings.getString("statsbar_placement"), true)

	suppressStatsBarComboSignal = false

	function chooseStatsBarPlacement.onOptionChange()
		updateStatsBar()
	end

	function chooseStatsBarDimension.onOptionChange()
		updateStatsBar()
	end

	healthCheckBox:setChecked(isHealthCircle)
	manaCheckBox:setChecked(isManaCircle)

	local distPct = arcDistancePixelsToScrollPercent(distanceFromCenter)

	distFromCenScrollbar:setText(tr("Distance") .. ": " .. distPct .. "%")
	distFromCenScrollbar:setValue(distPct)
	modules.client_options.addButton("Interface", "HP/MP Circle", optionPanel)
end

function updateStatsBar()
	if suppressStatsBarComboSignal or not statsBarMenuLoaded then
		return
	end

	if not isStatsBarComboValid(chooseStatsBarDimension) or not isStatsBarComboValid(chooseStatsBarPlacement) then
		clearStatsBarMenuRefs()

		return
	end

	local dimOpt = chooseStatsBarDimension:getCurrentOption()
	local placOpt = chooseStatsBarPlacement:getCurrentOption()

	if dimOpt and placOpt then
		modules.game_interface.updateStatsBar(dimOpt.data, placOpt.data)
		scheduleArcConditionsRefresh()
	end
end

function setStatsBarOption(dimension, placement)
	if not statsBarMenuLoaded then
		return
	end

	if not isStatsBarComboValid(chooseStatsBarDimension) or not isStatsBarComboValid(chooseStatsBarPlacement) then
		clearStatsBarMenuRefs()

		return
	end

	if placement == nil or placement == "" then
		placement = g_settings.getString("statsbar_placement")

		if placement == "" then
			placement = "top"
		end
	end

	if dimension == nil or dimension == "" or dimension == "hide" then
		dimension = g_settings.getString("statsbar_dimension")

		if dimension == "" or dimension == "hide" then
			dimension = "compact"
		end
	end

	suppressStatsBarComboSignal = true

	chooseStatsBarPlacement:setCurrentOptionByData(placement, true)
	chooseStatsBarDimension:setCurrentOptionByData(dimension, true)

	suppressStatsBarComboSignal = false
end

function destroyOptionsModule()
	modules.client_options.removeButton("Interface", "HP/MP Circle")

	if optionPanel and not optionPanel:isDestroyed() then
		optionPanel:destroy()
	end

	optionPanel = nil

	clearStatsBarMenuRefs()
end
