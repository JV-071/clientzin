WheelOfDestiny = {}
WheelOfDestiny.__index = WheelOfDestiny
WheelOfDestiny.pointInvested = {}
WheelOfDestiny.clickIndex = 0
WheelOfDestiny.equipedGems = {}
WheelOfDestiny.atelierGems = {}
WheelOfDestiny.basicModsUpgrade = {}
WheelOfDestiny.supremeModsUpgrade = {}
WheelOfDestiny.vocationId = 0
WheelOfDestiny.changeState = 0
WheelOfDestiny.isPreview = false
WheelOfDestiny.lastSelectedGemVessel = nil
WheelOfDestiny.extraGemPoints = 0
WheelOfDestiny.fromAchievementType = 0
WheelOfDestiny.activeState = {
	ready = false
}
WheelOfDestiny.backgroundRequestPending = false
WheelOfDestiny.passivePoints = {}
WheelOfDestiny.extraPassivePoints = {}
WheelOfDestiny.basicModCount = {}
WheelOfDestiny.supremeModCount = {}
WheelOfDestiny.vesselEnabled = {}
WheelOfDestiny.equipedGemBonuses = {}
WheelOfDestiny.externalPreset = {}
WheelOfDestiny.internalPreset = {}
WheelOfDestiny.currentPreset = {}
WheelOfDestiny.mouseIndex = 0
WheelOfDestiny.mousePassiveDomain = 0
WheelOfDestiny.revealedGems = {}

local sliceFillsInitialized = false
local slicePairsByIndex = {}
local focusSelectedWheel
local t = {}
local opacity = 1
local AVAILABLE_SLICE_OPACITY = 0.29
local SELECTED_SLICE_OPACITY = 0.20392156862745098
local DEFAULT_FILL_COLOR = {
	r = 255,
	a = 255,
	b = 255,
	g = 255
}

local function parseWheelFillColor(color)
	if type(color) == "table" then
		return color
	end

	if type(color) == "string" and color:sub(1, 1) == "#" then
		local hexColor = color:sub(2)
		local hexLength = #hexColor

		if hexLength == 6 or hexLength == 8 then
			local numericValue = tonumber(hexColor:sub(1, 2), 16)
			local green = tonumber(hexColor:sub(3, 4), 16)
			local blue = tonumber(hexColor:sub(5, 6), 16)
			local alpha = 255

			if hexLength == 8 then
				alpha = tonumber(hexColor:sub(7, 8), 16)
			end

			if numericValue ~= nil and green ~= nil and blue ~= nil and alpha ~= nil then
				return {
					r = numericValue,
					g = green,
					b = blue,
					a = alpha
				}
			end
		end
	end

	return DEFAULT_FILL_COLOR
end

local function replaceLegacySliceFillWidget(legacyWidget, widgetId)
	if not legacyWidget or not wheelPanel then
		return nil
	end

	local parent = legacyWidget:getParent() or wheelPanel
	local childIndex = parent:getChildIndex(legacyWidget)
	local numericValue = tonumber(widgetId:match("%d+")) or 0

	legacyWidget:destroy()

	local widgetStyle = "WheelSliceFill"

	if widgetId:find("fullColorWheel", 1, true) then
		widgetStyle = "WheelSliceFillAvailable"
	end

	local sliceFillWidget = g_ui.createWidget(widgetStyle)

	sliceFillWidget:setId(widgetId)
	sliceFillWidget:setSize(tosize("522 522"))

	local sliceArcParams = WheelButtons.getSliceArcParams(numericValue, 1)

	if sliceArcParams then
		sliceFillWidget:setStartAngle(sliceArcParams.startAngle)
		sliceFillWidget:setFullSpan(sliceArcParams.fullSpan)
		sliceFillWidget:setThickness(sliceArcParams.thickness)
		sliceFillWidget:setRadialInset(sliceArcParams.radialInset)
	end

	sliceFillWidget:setFillColor(parseWheelFillColor(WheelButtons.getSliceFillColor(numericValue)))

	if sliceFillWidget.setCompositionModeName then
		sliceFillWidget:setCompositionModeName("additive")
	end

	sliceFillWidget:setPercent(100)
	sliceFillWidget:setVisible(false)
	parent:insertChild(childIndex, sliceFillWidget)
	sliceFillWidget:addAnchor(AnchorTop, "parent", AnchorTop)
	sliceFillWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)

	return sliceFillWidget
end

local function updateSliceFillGeometry(sliceFillWidget, sliceIndex, startFraction, endFraction, fillColorOverride)
	local sliceArcParams = WheelButtons.getSliceArcParams(sliceIndex, startFraction, endFraction)

	if not sliceArcParams or not sliceFillWidget then
		return
	end

	local sliceFillColor = fillColorOverride

	if sliceFillColor == nil then
		sliceFillColor = WheelButtons.getSliceFillColor(sliceIndex)
	end

	local fillColor = parseWheelFillColor(sliceFillColor)
	local cachedFillState = t[sliceFillWidget]

	if not cachedFillState then
		cachedFillState = {}
		t[sliceFillWidget] = cachedFillState
	end

	if cachedFillState.startAngle ~= sliceArcParams.startAngle then
		sliceFillWidget:setStartAngle(sliceArcParams.startAngle)

		cachedFillState.startAngle = sliceArcParams.startAngle
	end

	if cachedFillState.fullSpan ~= sliceArcParams.fullSpan then
		sliceFillWidget:setFullSpan(sliceArcParams.fullSpan)

		cachedFillState.fullSpan = sliceArcParams.fullSpan
	end

	if cachedFillState.thickness ~= sliceArcParams.thickness then
		sliceFillWidget:setThickness(sliceArcParams.thickness)

		cachedFillState.thickness = sliceArcParams.thickness
	end

	if cachedFillState.radialInset ~= sliceArcParams.radialInset then
		sliceFillWidget:setRadialInset(sliceArcParams.radialInset)

		cachedFillState.radialInset = sliceArcParams.radialInset
	end

	if cachedFillState.fillColor ~= fillColor then
		sliceFillWidget:setFillColor(fillColor)

		cachedFillState.fillColor = fillColor
	end

	if cachedFillState.percent ~= 100 then
		sliceFillWidget:setPercent(100)

		cachedFillState.percent = 100
	end
end

function WheelOfDestiny.initSliceFills()
	if sliceFillsInitialized or not wheelPanel then
		return
	end

	slicePairsByIndex = {}
	t = {}

	for i = 1, 36 do
		local fullColorWheel = wheelPanel:getChildById("fullColorWheel_" .. i)
		local colorWheel = wheelPanel:getChildById("colorWheel_" .. i)

		if fullColorWheel and fullColorWheel.getPercent == nil then
			fullColorWheel = replaceLegacySliceFillWidget(fullColorWheel, "fullColorWheel_" .. i)
		end

		if colorWheel and colorWheel.getPercent == nil then
			colorWheel = replaceLegacySliceFillWidget(colorWheel, "colorWheel_" .. i)
		end

		slicePairsByIndex[i] = {
			color = colorWheel,
			full = fullColorWheel
		}

		if colorWheel then
			updateSliceFillGeometry(colorWheel, i, 0, 1)
			colorWheel:setVisible(false)
			colorWheel:setOpacity(opacity)
		end

		if fullColorWheel then
			updateSliceFillGeometry(fullColorWheel, i, 0, 1, WheelButtons.getSliceAvailableColor(i))
			fullColorWheel:setVisible(false)
			fullColorWheel:setOpacity(AVAILABLE_SLICE_OPACITY)
		end
	end

	focusSelectedWheel = wheelPanel:getChildById("focusSelectedWheel") or wheelPanel.focusSelectedWheel

	if not focusSelectedWheel then
		focusSelectedWheel = g_ui.createWidget("WheelSliceFill", wheelPanel)

		focusSelectedWheel:setId("focusSelectedWheel")
		focusSelectedWheel:setSize(tosize("522 522"))
		focusSelectedWheel:addAnchor(AnchorTop, "parent", AnchorTop)
		focusSelectedWheel:addAnchor(AnchorLeft, "parent", AnchorLeft)
		focusSelectedWheel:setVisible(false)

		if focusSelectedWheel.setCompositionModeName then
			focusSelectedWheel:setCompositionModeName("additive")
		end
	end

	local wheelBackground = wheelPanel:getChildById("wheelBackground")

	if wheelBackground and focusSelectedWheel then
		local childIndex = wheelPanel:getChildIndex(wheelBackground) + 1

		if wheelPanel:getChildIndex(focusSelectedWheel) ~= childIndex then
			wheelPanel:removeChild(focusSelectedWheel)
			wheelPanel:insertChild(childIndex, focusSelectedWheel)
		end

		wheelPanel.focusSelectedWheel = focusSelectedWheel
	end

	local overlayWidgetIds = {
		"socketBackground0",
		"revelationBgTL",
		"revelationPerkTL",
		"backdropLight1",
		"focusPassive1",
		"wheelPassive1",
		"selectPassive1",
		"socketBackground1",
		"revelationBgTR",
		"revelationPerkTR",
		"backdropLight2",
		"focusPassive2",
		"wheelPassive2",
		"selectPassive2",
		"socketBackground2",
		"revelationBgBL",
		"revelationPerkBL",
		"backdropLight3",
		"focusPassive3",
		"wheelPassive3",
		"selectPassive3",
		"socketBackground3",
		"revelationBgBR",
		"revelationPerkBR",
		"backdropLight4",
		"focusPassive4",
		"wheelPassive4",
		"selectPassive4",
		"vocationWheel",
		"borderSelectedWheel",
		"selectVessel0",
		"selectVessel1",
		"selectVessel2",
		"selectVessel3"
	}

	for unusedValue, entry in ipairs(overlayWidgetIds) do
		local childById = wheelPanel:getChildById(entry)

		if childById then
			childById:raise()
		end
	end

	sliceFillsInitialized = true
end

local function getInitializedSlicePair(sliceIndex)
	if not sliceFillsInitialized then
		WheelOfDestiny.initSliceFills()
	end

	return slicePairsByIndex[sliceIndex]
end

function WheelOfDestiny.getSlicePair(sliceIndex)
	return getInitializedSlicePair(sliceIndex)
end

local function isSliceUnlocked(sliceIndex)
	if sliceIndex == 15 or sliceIndex == 16 or sliceIndex == 21 or sliceIndex == 22 then
		return true
	end

	local wheelNode = WheelNodes[sliceIndex]

	if not wheelNode then
		return false
	end

	for unusedValue, entry in ipairs(wheelNode.connecteds or {}) do
		local connectedBonus = WheelBonus[entry - 1]

		if connectedBonus and (WheelOfDestiny.pointInvested[entry] or 0) >= connectedBonus.maxPoints then
			return true
		end
	end

	return false
end

function WheelOfDestiny.updateSliceFill(index, investedPoints)
	local slicePair = getInitializedSlicePair(index)
	local bonus = WheelBonus[index - 1]

	if not slicePair or not slicePair.color or not slicePair.full or not bonus then
		return
	end

	local color = slicePair.color
	local full = slicePair.full

	if investedPoints <= 0 then
		color:setVisible(false)

		if isSliceUnlocked(index) then
			updateSliceFillGeometry(full, index, 0, 1, WheelButtons.getSliceAvailableColor(index))
			full:setVisible(true)
			full:setOpacity(AVAILABLE_SLICE_OPACITY)
		else
			full:setVisible(false)
		end

		return
	end

	local investedFraction = math.min(1, investedPoints / math.max(bonus.maxPoints, 1))

	updateSliceFillGeometry(color, index, 0, math.max(investedFraction, 0.001))
	color:setVisible(true)
	color:setOpacity(opacity)

	if investedFraction < 0.999 then
		updateSliceFillGeometry(full, index, investedFraction, 1, WheelButtons.getSliceAvailableColor(index))
		full:setVisible(true)
		full:setOpacity(AVAILABLE_SLICE_OPACITY)
	else
		full:setVisible(false)
	end
end

function WheelOfDestiny.showUnlockedPreview(sliceIndex)
	local slicePair = getInitializedSlicePair(sliceIndex)
	local availableSliceFill = slicePair and slicePair.full

	if not availableSliceFill then
		return
	end

	if (WheelOfDestiny.pointInvested[sliceIndex] or 0) > 0 then
		return
	end

	updateSliceFillGeometry(availableSliceFill, sliceIndex, 0, 1, WheelButtons.getSliceAvailableColor(sliceIndex))
	availableSliceFill:setVisible(true)
	availableSliceFill:setOpacity(AVAILABLE_SLICE_OPACITY)
end

function WheelOfDestiny.applySliceFocus(sliceIndex)
	local focusSelectedWheel = focusSelectedWheel or wheelPanel.focusSelectedWheel or wheelPanel:getChildById("focusSelectedWheel")

	if not focusSelectedWheel then
		return
	end

	updateSliceFillGeometry(focusSelectedWheel, sliceIndex, 0, 1, "#FFFFFFFF")
	focusSelectedWheel:setOpacity(SELECTED_SLICE_OPACITY)
	focusSelectedWheel:setVisible(true)
end

function WheelOfDestiny.hideSliceFocus()
	local focusSelectedWheel = focusSelectedWheel or wheelPanel.focusSelectedWheel or wheelPanel:getChildById("focusSelectedWheel")

	if focusSelectedWheel then
		focusSelectedWheel:setVisible(false)
	end
end

function WheelOfDestiny.onCreate(vocationId)
	for key, entry in pairs(WheelIcons[vocationId]) do
		local icon = wheelPanel:recursiveGetChildById("icon" .. key)

		if icon and not WheelOfDestiny.isVesselSlice(key) then
			icon:setImageClip(entry.iconRect)
		end

		local smallicon = wheelPanel:recursiveGetChildById("smallicon" .. key)

		if smallicon then
			smallicon:setImageClip(entry.miniIconRect)
		end
	end

	WheelOfDestiny.refreshAllVesselDomains()

	local totalPoints = WheelOfDestiny.points + (WheelOfDestiny.extraGemPoints + WheelOfDestiny.scrollPoints)

	wheelOfDestinyWindow.selection.points:setText(comma_value(totalPoints - WheelOfDestiny.usedPoints) .. " / " .. comma_value(totalPoints))
	WheelOfDestiny.showUnlockedPreview(15)
	WheelOfDestiny.showUnlockedPreview(16)
	WheelOfDestiny.showUnlockedPreview(21)
	WheelOfDestiny.showUnlockedPreview(22)
	WheelOfDestiny.configureDedicationPerk()
	WheelOfDestiny.configureConvictionPerk()
	WheelOfDestiny.configureVessels()
	WheelOfDestiny.configureSummary()
	WheelOfDestiny.configurePassives()
	WheelOfDestiny.configureEquippedGems()

	if gemAtelierWindow:isVisible() then
		GemAtelier.showGems()
	end

	if fragmentWindow:isVisible() then
		local searchWidget = fragmentWindow:recursiveGetChildById("searchText")
		local currentSearch = searchWidget and searchWidget:getText() or ""

		Workshop.showFragmentList(false, false, true, currentSearch)
	end

	WheelOfDestiny.showInformationDefault()
end

function WheelOfDestiny.configureVessels()
	local tabContent = wheelOfDestinyWindow.vessels.tabContent
	local scrollBar = wheelOfDestinyWindow.vessels.tabContentScroll

	tabContent:destroyChildren()
	scrollBar:setVisible(false)

	local width = tabContent:getWidth()

	for index, connection in ipairs(getVesselBonus()) do
		local perksPanelWidget = g_ui.createWidget("PerksPanel", tabContent)

		if connection.icon then
			perksPanelWidget.icon:setImageSource(connection.icon)
			perksPanelWidget.icon:setVisible(true)
			perksPanelWidget.perk:setMarginLeft(16)
		elseif connection.indent then
			perksPanelWidget.perk:setMarginLeft(10)
		end

		if connection.value == -1 then
			perksPanelWidget.value:setVisible(false)
		else
			perksPanelWidget.value:setText(tostring(connection.value))
		end

		if connection.tooltip and connection.tooltip ~= "" then
			perksPanelWidget.info:setVisible(true)
			perksPanelWidget.info:setTooltip(connection.tooltip)
		end

		local connectionDescription = connection.text and connection.text ~= "" and connection.text or "(Unknown)"

		WheelOfDestiny.fitPerkName(perksPanelWidget.perk, {
			connectionDescription
		}, width, perksPanelWidget.value)
	end

	if scrollBar:getMaximum() > 0 then
		scrollBar:setVisible(true)
	end
end

function WheelOfDestiny.resetPassiveFocus()
	WheelOfDestiny.mousePassiveDomain = 0

	for i = 1, 4 do
		local widget = wheelPanel:recursiveGetChildById("selectPassive" .. i)

		if widget then
			widget:setVisible(false)
		end

		local focusPassive = wheelPanel:recursiveGetChildById("focusPassive" .. i)

		if focusPassive then
			focusPassive:setVisible(false)
		end
	end
end

function WheelOfDestiny.applyPassiveFocus(selectedDomain)
	for domain = 1, 4 do
		local focusPassive = wheelPanel:recursiveGetChildById("focusPassive" .. domain)

		if focusPassive then
			focusPassive:setVisible(domain == selectedDomain)
		end
	end
end

function WheelOfDestiny.hidePassiveFocus()
	for domain = 1, 4 do
		local focusPassive = wheelPanel:recursiveGetChildById("focusPassive" .. domain)

		if focusPassive then
			focusPassive:setVisible(false)
		end
	end
end

function WheelOfDestiny.configurePassives()
	WheelOfDestiny.extraPassivePoints = table.reserve(4, 0)

	for i = 0, 3 do
		local data = GemAtelier.getEquipedGem(i)
		local filledCount = GemAtelier.getFilledVesselCount(i)

		if data and data.supremeBonus > 0 and filledCount == 3 then
			local vocationId = translateVocation(WheelOfDestiny.vocationId)
			local supremeList = data.supremeBonus > 5 and VocationSupremeMods[vocationId] or FlatSupremeMods

			if supremeList then
				local bonus = supremeList[data.supremeBonus]

				if bonus and bonus.domain then
					local gemValue = getBonusValueUpgrade(data.supremeBonus, data.gemID, true, true)
					local currentValue = WheelOfDestiny.extraPassivePoints[bonus.domain + 1] or 0

					WheelOfDestiny.extraPassivePoints[bonus.domain + 1] = gemValue + currentValue
				end
			end
		end
	end

	local passivel = "TL"

	for domain, points in ipairs(WheelOfDestiny.passivePoints) do
		if domain == 1 then
			passivel = "TL"
		elseif domain == 2 then
			passivel = "TR"
		elseif domain == 3 then
			passivel = "BL"
		elseif domain == 4 then
			passivel = "BR"
		end

		points = points + (WheelOfDestiny.extraPassivePoints[domain] or 0)

		local widget = wheelPanel:recursiveGetChildById("wheelPassive" .. domain)
		local widgetPercent = wheelPanel:recursiveGetChildById("revelationPerk" .. passivel)

		if points < 250 then
			widget:setImageSource("/images/game/wheel/backdrop_skillwheel_largebonus_front0_" .. passivel)
			widgetPercent:setPercent(math.floor((points - 0) / 250 * 100))
		elseif points < 500 then
			widget:setImageSource("/images/game/wheel/backdrop_skillwheel_largebonus_front1_" .. passivel)
			widgetPercent:setPercent(math.floor((points - 250) / 250 * 100))
		elseif points < 1000 then
			widget:setImageSource("/images/game/wheel/backdrop_skillwheel_largebonus_front2_" .. passivel)
			widgetPercent:setPercent(math.floor((points - 500) / 500 * 100))
		else
			widget:setImageSource("/images/game/wheel/backdrop_skillwheel_largebonus_front3_" .. passivel)
			widgetPercent:setPercent(100)
		end
	end

	WheelOfDestiny.configureRevelationPerks()
end

function WheelOfDestiny.onWheelPassiveClick(domain)
	if not wheelWindow:recursiveGetChildById("tabContent"):isVisible() then
		wheelWindow:recursiveGetChildById("tabContent"):setVisible(true)
	end

	WheelOfDestiny.resetPassiveFocus()
	wheelPanel:recursiveGetChildById("selectPassive" .. domain):setVisible(true)

	if WheelOfDestiny.lastSelectedGemVessel then
		WheelOfDestiny.lastSelectedGemVessel:setVisible(false)
	end

	if wheelOfDestinyWindow.selection.gemContent:isVisible() then
		wheelOfDestinyWindow.selection.gemContent:setVisible(false)
		wheelOfDestinyWindow.selection.tabContent:setVisible(true)
	end

	wheelOfDestinyWindow.selection.tabContent.dedicationTitle:setText("Revelation Perk")
	wheelOfDestinyWindow.selection.tabContent.convictionTitle:setText("More details: ")
	wheelOfDestinyWindow.selection.tabContent.convictionTitle:setTextAlign(AlignLeft)
	wheelOfDestinyWindow.selection.tabContent.information:setTooltip("To unlock a Revelation Perk, you need to distribute promotion \npoints in the corresponding domain.\nTo unlock stage 1 of a Revelation Perk, you need 250 promotion \npoints. Stage 2 requires 500 promotion points. As soon as you have \ndistributed 1000 promotion points, stage 3 is unlocked.\nRevelation Mastery, which can be found on some gems, provides \nadditional points to unlock Revelation Perks.\n\nUnlocked Revelation Perks grant a bonus to all damage and \nhealing:\n* Stage 1 grants a bonus of +4 damage and healing\n* Stage 2 increases this bonus to +9\n* Stage 3 increases this bonus to +20")

	local passive = WheelOfDestiny.passivePoints[domain]
	local maximum = 250
	local totalPassivePoints = passive + (WheelOfDestiny.extraPassivePoints[domain] or 0)

	if totalPassivePoints >= 1000 then
		maximum = 1000
	elseif totalPassivePoints >= 500 then
		maximum = 1000
	elseif totalPassivePoints >= 250 then
		maximum = 500
	end

	if totalPassivePoints < 0 then
		totalPassivePoints = 0
	end

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(totalPassivePoints, 0, maximum)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(totalPassivePoints .. " / " .. maximum)
	wheelPanel.borderSelectedWheel:setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("addMax"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("addOne"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("rmvMax"):setVisible(false)
	wheelOfDestinyWindow:recursiveGetChildById("rmvOne"):setVisible(false)

	local m1, m2 = getPassiveInfo(domain)
	local height = (WheelDedicationHeight[WheelOfDestiny.vocationId] or {})[domain] or 0

	wheelOfDestinyWindow.selection.tabContent.dedication:setHeight(height)
	wheelOfDestinyWindow.selection.tabContent.dedication:setText(m1)
	wheelOfDestinyWindow.selection.tabContent.information1:setTooltip(m2)

	if totalPassivePoints == 1000 then
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#c0c0c0")
	else
		wheelOfDestinyWindow.selection.tabContent.dedication:setColor("#707070")
	end

	local tabContent = wheelOfDestinyWindow.selection.tabContent

	tabContent.convictionName:setText("Locked")
	tabContent.convictionName:setColor("#c0c0c0")
	tabContent.conviction:setVisible(false)
	tabContent.conviction:setText("")

	local convictionBody = tabContent.convictionBody or tabContent:getChildById("convictionBody")

	if convictionBody then
		convictionBody:destroyChildren()
		convictionBody:setVisible(false)
	end

	if totalPassivePoints >= 1000 then
		wheelOfDestinyWindow.selection.tabContent.convictionName:setText("Stage 3")
	elseif totalPassivePoints >= 500 then
		wheelOfDestinyWindow.selection.tabContent.convictionName:setText("Stage 2")
	elseif totalPassivePoints >= 250 then
		wheelOfDestinyWindow.selection.tabContent.convictionName:setText("Stage 1")
	end
end

function WheelOfDestiny.configureRevelationPerks()
	local tabContent = wheelOfDestinyWindow.revelationPerks.tabContent
	local damage = 0

	for domain, points in ipairs(WheelOfDestiny.passivePoints) do
		points = points + (WheelOfDestiny.extraPassivePoints[domain] or 0)

		if points >= 1000 then
			damage = damage + 20
		elseif points >= 500 then
			damage = damage + 9
		elseif points >= 250 then
			damage = damage + 4
		end
	end

	tabContent.damage.value:setText("+" .. damage)

	local pointInvested = {
		{
			domain = 4,
			label = "perk1",
			panel = tabContent.avatar,
			info = tabContent.infoAvatar
		},
		{
			domain = 2,
			label = "perk2",
			panel = tabContent.spell1,
			info = tabContent.infoSpell1
		},
		{
			domain = 1,
			label = "perk3",
			panel = tabContent.spell2,
			info = tabContent.infoSpell2
		},
		{
			domain = 3,
			label = "perk4",
			panel = tabContent.spell3,
			info = tabContent.infoSpell3
		}
	}

	for _, value in ipairs(pointInvested) do
		local packedValue = (WheelOfDestiny.passivePoints[value.domain] or 0) + (WheelOfDestiny.extraPassivePoints[value.domain] or 0)
		local text = "Locked"

		if packedValue >= 1000 then
			text = "Stage 3"
		elseif packedValue >= 500 then
			text = "Stage 2"
		elseif packedValue >= 250 then
			text = "Stage 1"
		end

		value.panel.value:setText(text)

		local revelationName = getRevelationDisplayName(value.domain)
		local perkNameLabel = value.panel[value.label]

		perkNameLabel:setTooltip(revelationName)
		WheelOfDestiny.fitPerkName(perkNameLabel, {
			revelationName
		}, value.panel:getWidth(), value.panel.value)
		value.info:setTooltip((getPassiveInfo(value.domain)))
	end
end
