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

local var_0_0 = false
local var_0_1 = {}
local focusSelectedWheel
local t = {}
local var_0_4 = 1
local var_0_5 = 0.29
local var_0_6 = 0.20392156862745098
local var_0_7 = {
	r = 255,
	a = 255,
	b = 255,
	g = 255
}

local function var_0_8(arg_1_0)
	if type(arg_1_0) == "table" then
		return arg_1_0
	end

	if type(arg_1_0) == "string" and arg_1_0:sub(1, 1) == "#" then
		local var_1_0 = arg_1_0:sub(2)
		local var_1_1 = #var_1_0

		if var_1_1 == 6 or var_1_1 == 8 then
			local numericValue = tonumber(var_1_0:sub(1, 2), 16)
			local var_1_3 = tonumber(var_1_0:sub(3, 4), 16)
			local var_1_4 = tonumber(var_1_0:sub(5, 6), 16)
			local var_1_5 = 255

			if var_1_1 == 8 then
				var_1_5 = tonumber(var_1_0:sub(7, 8), 16)
			end

			if numericValue ~= nil and var_1_3 ~= nil and var_1_4 ~= nil and var_1_5 ~= nil then
				return {
					r = numericValue,
					g = var_1_3,
					b = var_1_4,
					a = var_1_5
				}
			end
		end
	end

	return var_0_7
end

local function var_0_9(arg_2_0, arg_2_1)
	if not arg_2_0 or not wheelPanel then
		return nil
	end

	local parent = arg_2_0:getParent() or wheelPanel
	local childIndex = parent:getChildIndex(arg_2_0)
	local numericValue = tonumber(arg_2_1:match("%d+")) or 0

	arg_2_0:destroy()

	local var_2_3 = "WheelSliceFill"

	if arg_2_1:find("fullColorWheel", 1, true) then
		var_2_3 = "WheelSliceFillAvailable"
	end

	local var_2_4 = g_ui.createWidget(var_2_3)

	var_2_4:setId(arg_2_1)
	var_2_4:setSize(tosize("522 522"))

	local sliceArcParams = WheelButtons.getSliceArcParams(numericValue, 1)

	if sliceArcParams then
		var_2_4:setStartAngle(sliceArcParams.startAngle)
		var_2_4:setFullSpan(sliceArcParams.fullSpan)
		var_2_4:setThickness(sliceArcParams.thickness)
		var_2_4:setRadialInset(sliceArcParams.radialInset)
	end

	var_2_4:setFillColor(var_0_8(WheelButtons.getSliceFillColor(numericValue)))

	if var_2_4.setCompositionModeName then
		var_2_4:setCompositionModeName("additive")
	end

	var_2_4:setPercent(100)
	var_2_4:setVisible(false)
	parent:insertChild(childIndex, var_2_4)
	var_2_4:addAnchor(AnchorTop, "parent", AnchorTop)
	var_2_4:addAnchor(AnchorLeft, "parent", AnchorLeft)

	return var_2_4
end

local function var_0_10(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local sliceArcParams = WheelButtons.getSliceArcParams(arg_3_1, arg_3_2, arg_3_3)

	if not sliceArcParams or not arg_3_0 then
		return
	end

	local sliceFillColor = arg_3_4

	if sliceFillColor == nil then
		sliceFillColor = WheelButtons.getSliceFillColor(arg_3_1)
	end

	local fillColor = var_0_8(sliceFillColor)
	local var_3_3 = t[arg_3_0]

	if not var_3_3 then
		var_3_3 = {}
		t[arg_3_0] = var_3_3
	end

	if var_3_3.startAngle ~= sliceArcParams.startAngle then
		arg_3_0:setStartAngle(sliceArcParams.startAngle)

		var_3_3.startAngle = sliceArcParams.startAngle
	end

	if var_3_3.fullSpan ~= sliceArcParams.fullSpan then
		arg_3_0:setFullSpan(sliceArcParams.fullSpan)

		var_3_3.fullSpan = sliceArcParams.fullSpan
	end

	if var_3_3.thickness ~= sliceArcParams.thickness then
		arg_3_0:setThickness(sliceArcParams.thickness)

		var_3_3.thickness = sliceArcParams.thickness
	end

	if var_3_3.radialInset ~= sliceArcParams.radialInset then
		arg_3_0:setRadialInset(sliceArcParams.radialInset)

		var_3_3.radialInset = sliceArcParams.radialInset
	end

	if var_3_3.fillColor ~= fillColor then
		arg_3_0:setFillColor(fillColor)

		var_3_3.fillColor = fillColor
	end

	if var_3_3.percent ~= 100 then
		arg_3_0:setPercent(100)

		var_3_3.percent = 100
	end
end

function WheelOfDestiny.initSliceFills()
	if var_0_0 or not wheelPanel then
		return
	end

	var_0_1 = {}
	t = {}

	for i = 1, 36 do
		local fullColorWheel = wheelPanel:getChildById("fullColorWheel_" .. i)
		local colorWheel = wheelPanel:getChildById("colorWheel_" .. i)

		if fullColorWheel and fullColorWheel.getPercent == nil then
			fullColorWheel = var_0_9(fullColorWheel, "fullColorWheel_" .. i)
		end

		if colorWheel and colorWheel.getPercent == nil then
			colorWheel = var_0_9(colorWheel, "colorWheel_" .. i)
		end

		var_0_1[i] = {
			color = colorWheel,
			full = fullColorWheel
		}

		if colorWheel then
			var_0_10(colorWheel, i, 0, 1)
			colorWheel:setVisible(false)
			colorWheel:setOpacity(var_0_4)
		end

		if fullColorWheel then
			var_0_10(fullColorWheel, i, 0, 1, WheelButtons.getSliceAvailableColor(i))
			fullColorWheel:setVisible(false)
			fullColorWheel:setOpacity(var_0_5)
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

	local var_4_4 = {
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

	for unusedValue, entry in ipairs(var_4_4) do
		local childById = wheelPanel:getChildById(entry)

		if childById then
			childById:raise()
		end
	end

	var_0_0 = true
end

local function var_0_11(arg_5_0)
	if not var_0_0 then
		WheelOfDestiny.initSliceFills()
	end

	return var_0_1[arg_5_0]
end

function WheelOfDestiny.getSlicePair(arg_6_0)
	return var_0_11(arg_6_0)
end

local function var_0_12(arg_7_0)
	if arg_7_0 == 15 or arg_7_0 == 16 or arg_7_0 == 21 or arg_7_0 == 22 then
		return true
	end

	local var_7_0 = WheelNodes[arg_7_0]

	if not var_7_0 then
		return false
	end

	for unusedValue, entry in ipairs(var_7_0.connecteds or {}) do
		local var_7_1 = WheelBonus[entry - 1]

		if var_7_1 and (WheelOfDestiny.pointInvested[entry] or 0) >= var_7_1.maxPoints then
			return true
		end
	end

	return false
end

function WheelOfDestiny.updateSliceFill(index, arg_8_1)
	local var_8_0 = var_0_11(index)
	local bonus = WheelBonus[index - 1]

	if not var_8_0 or not var_8_0.color or not var_8_0.full or not bonus then
		return
	end

	local color = var_8_0.color
	local full = var_8_0.full

	if arg_8_1 <= 0 then
		color:setVisible(false)

		if var_0_12(index) then
			var_0_10(full, index, 0, 1, WheelButtons.getSliceAvailableColor(index))
			full:setVisible(true)
			full:setOpacity(var_0_5)
		else
			full:setVisible(false)
		end

		return
	end

	local var_8_4 = math.min(1, arg_8_1 / math.max(bonus.maxPoints, 1))

	var_0_10(color, index, 0, math.max(var_8_4, 0.001))
	color:setVisible(true)
	color:setOpacity(var_0_4)

	if var_8_4 < 0.999 then
		var_0_10(full, index, var_8_4, 1, WheelButtons.getSliceAvailableColor(index))
		full:setVisible(true)
		full:setOpacity(var_0_5)
	else
		full:setVisible(false)
	end
end

function WheelOfDestiny.showUnlockedPreview(arg_9_0)
	local var_9_0 = var_0_11(arg_9_0)
	local var_9_1 = var_9_0 and var_9_0.full

	if not var_9_1 then
		return
	end

	if (WheelOfDestiny.pointInvested[arg_9_0] or 0) > 0 then
		return
	end

	var_0_10(var_9_1, arg_9_0, 0, 1, WheelButtons.getSliceAvailableColor(arg_9_0))
	var_9_1:setVisible(true)
	var_9_1:setOpacity(var_0_5)
end

function WheelOfDestiny.applySliceFocus(arg_10_0)
	local focusSelectedWheel = focusSelectedWheel or wheelPanel.focusSelectedWheel or wheelPanel:getChildById("focusSelectedWheel")

	if not focusSelectedWheel then
		return
	end

	var_0_10(focusSelectedWheel, arg_10_0, 0, 1, "#FFFFFFFF")
	focusSelectedWheel:setOpacity(var_0_6)
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

		local var_13_4 = connection.text and connection.text ~= "" and connection.text or "(Unknown)"

		WheelOfDestiny.fitPerkName(perksPanelWidget.perk, {
			var_13_4
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

function WheelOfDestiny.applyPassiveFocus(arg_15_0)
	for iter_15_0 = 1, 4 do
		local focusPassive = wheelPanel:recursiveGetChildById("focusPassive" .. iter_15_0)

		if focusPassive then
			focusPassive:setVisible(iter_15_0 == arg_15_0)
		end
	end
end

function WheelOfDestiny.hidePassiveFocus()
	for iter_16_0 = 1, 4 do
		local focusPassive = wheelPanel:recursiveGetChildById("focusPassive" .. iter_16_0)

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
	local var_18_2 = passive + (WheelOfDestiny.extraPassivePoints[domain] or 0)

	if var_18_2 >= 1000 then
		maximum = 1000
	elseif var_18_2 >= 500 then
		maximum = 1000
	elseif var_18_2 >= 250 then
		maximum = 500
	end

	if var_18_2 < 0 then
		var_18_2 = 0
	end

	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setValue(var_18_2, 0, maximum)
	wheelOfDestinyWindow.selection.tabContent.dedicationPb:setText(var_18_2 .. " / " .. maximum)
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

	if var_18_2 == 1000 then
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

	if var_18_2 >= 1000 then
		wheelOfDestinyWindow.selection.tabContent.convictionName:setText("Stage 3")
	elseif var_18_2 >= 500 then
		wheelOfDestinyWindow.selection.tabContent.convictionName:setText("Stage 2")
	elseif var_18_2 >= 250 then
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
		local var_19_4 = "Locked"

		if packedValue >= 1000 then
			var_19_4 = "Stage 3"
		elseif packedValue >= 500 then
			var_19_4 = "Stage 2"
		elseif packedValue >= 250 then
			var_19_4 = "Stage 1"
		end

		value.panel.value:setText(var_19_4)

		local var_19_5 = getRevelationDisplayName(value.domain)
		local var_19_6 = value.panel[value.label]

		var_19_6:setTooltip(var_19_5)
		WheelOfDestiny.fitPerkName(var_19_6, {
			var_19_5
		}, value.panel:getWidth(), value.panel.value)
		value.info:setTooltip((getPassiveInfo(value.domain)))
	end
end
