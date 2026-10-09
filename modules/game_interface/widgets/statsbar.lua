local statsBarTop
local statsBarBottom
local gameLeftStatsBar
local gameRightStatsBar
local statsBars = {}
local statsBarDeepInfo = {}
local statsBarQuickInfoEvent
local statsBarDeepInfoEvent
local statsBarQuickHealthPending = false
local statsBarQuickManaPending = false
local statsBarsPlacements = {
	"Top",
	"Bottom",
	"Left",
	"Right"
}
local statsBarsDimensions = {
	Large = {
		height = 35
	},
	Default = {
		height = 35
	},
	Parallel = {
		height = 35
	},
	Compact = {
		height = 20
	}
}
local lastProficiencyCache = {}
local proficiencyPerkHighlightActive = false
local firstCall = true
local currentStats = {
	placement = "hide",
	dimension = "hide"
}
local skillsLineHeight = 20

local function playerLevelPercentForStatsBar(player)
	local p = player:getLevelPercent()

	if g_game.getFeature(GameLevelPercentU16) then
		return math.floor(p / 100)
	end

	return p
end

local function playerSkillPercentForStatsBar(rawPercent)
	return math.floor((rawPercent or 0) / 100)
end

local SKILL_ICONS_SHEET = "/images/game/creatures/icons-skills"
local skillsTuples = {
	{
		key = "experience",
		name = "Level",
		order = 0,
		clip = "9 0 9 9",
		placement = "center"
	},
	{
		key = "magic",
		name = "Magic Level",
		order = 1,
		clip = "27 0 9 9",
		placement = "left"
	},
	{
		key = "axe",
		name = "Axe Fighting Skill",
		order = 1,
		clip = "54 0 9 9",
		placement = "right",
		skill = Skill.Axe
	},
	{
		key = "club",
		name = "Club Fighting Skill",
		order = 2,
		clip = "45 0 9 9",
		placement = "left",
		skill = Skill.Club
	},
	{
		key = "distance",
		name = "Distance Fighting Skill",
		order = 2,
		clip = "18 0 9 9",
		placement = "right",
		skill = Skill.Distance
	},
	{
		key = "fist",
		name = "Fist Fighting Skill",
		order = 3,
		clip = "0 0 9 9",
		placement = "left",
		skill = Skill.Fist
	},
	{
		key = "shielding",
		name = "Shielding Fighting Skill",
		order = 3,
		clip = "63 0 9 9",
		placement = "right",
		skill = Skill.Shielding
	},
	{
		key = "sword",
		name = "Sword Fighting Skill",
		order = 4,
		clip = "36 0 9 9",
		placement = "left",
		skill = Skill.Sword
	},
	{
		key = "fishing",
		name = "Fishing Fighting Skill",
		order = 4,
		clip = "72 0 9 9",
		placement = "right",
		skill = Skill.Fishing
	}
}
local SKILL_MENU_CHECKBOX_LABEL = {
	fishing = "Show Fishing Skill",
	shielding = "Show Shielding Skill",
	axe = "Show Axe Fighting Skill",
	sword = "Show Sword Fighting Skill",
	fist = "Show Fist Fighting Skill",
	magic = "Show Magic Level",
	distance = "Show Distance Fighting Skill",
	club = "Show Club Fighting Skill",
	experience = "Show Level"
}

StatsBar = {}

function getConfigurations()
	local configs = {}

	for _, statsBar in pairs(statsBars) do
		for _, placement in ipairs(statsBarsPlacements) do
			for dimension, _ in pairs(statsBarsDimensions) do
				local dimensionOnPlacement = tostring(dimension):lower() .. "On" .. placement
				local key = "statsBar" .. placement:gsub("^%l", string.upper)

				if statsBar[key] then
					table.insert(configs, statsBar[key][dimensionOnPlacement])
				end
			end
		end
	end

	return configs
end

local DEFAULT_SKILL_CENTER_GAP_LEFT = -4
local DEFAULT_SKILL_CENTER_GAP_RIGHT = -1
local COMPACT_SKILL_CENTER_GAP_LEFT = 3
local COMPACT_SKILL_CENTER_GAP_RIGHT = 2
local COMPACT_STATS_BAR_HEIGHT = 23
local PARALLEL_STATS_BAR_HEIGHT = 8
local LARGE_STATS_BAR_HEIGHT_TRIM = 10

local function statsBarTopSkillsParentBaseHeight(parent)
	if not parent then
		return 40
	end

	local id = parent:getId()

	if id == "defaultOnTop" then
		return 32
	elseif id == "defaultOnBottom" then
		return 35
	elseif id == "compactOnBottom" or id == "parallelOnBottom" or id == "largeOnBottom" then
		return 43
	end

	return 40
end

local function statsBarSkillsParentIsCompact(parent)
	if not parent then
		return false
	end

	local id = parent:getId()

	return id == "compactOnTop" or id == "compactOnBottom" or id == "compactOnLeft" or id == "compactOnRight"
end

local function statsBarSkillsParentIsParallel(parent)
	if not parent then
		return false
	end

	local id = parent:getId()

	return id == "parallelOnTop" or id == "parallelOnBottom" or id == "parallelOnLeft" or id == "parallelOnRight"
end

local function statsBarSkillsParentIsLarge(parent)
	if not parent then
		return false
	end

	local id = parent:getId()

	return id == "largeOnTop" or id == "largeOnBottom" or id == "largeOnLeft" or id == "largeOnRight"
end

local function var_0_33(arg_8_0)
	if not arg_8_0 then
		return false
	end

	local id = arg_8_0:getId() or ""

	return id:find("OnLeft") ~= nil or id:find("OnRight") ~= nil
end

local function var_0_34(arg_9_0)
	local id = arg_9_0:getId()

	if id ~= "defaultOnLeft" and id ~= "defaultOnRight" then
		return
	end

	local level = arg_9_0:getChildById("barsColumn")
	local widget = arg_9_0.health or level and level:getChildById("health")
	local bar = arg_9_0.mana or level and level:getChildById("mana")

	if not level or not widget or not bar then
		return
	end

	local barMarginRight = tonumber(level:getHeight()) or 0

	if barMarginRight < 4 then
		return
	end

	local var_9_5 = 5
	local var_9_6 = math.floor((barMarginRight - var_9_5) / 2)

	if var_9_6 < 1 then
		return
	end

	widget:breakAnchors()
	widget:addAnchor(AnchorTop, "parent", AnchorTop)
	widget:addAnchor(AnchorLeft, "parent", AnchorLeft)
	widget:addAnchor(AnchorRight, "parent", AnchorRight)
	widget:setMarginTop(0)
	widget:setMarginBottom(0)
	widget:setHeight(var_9_6)
	bar:breakAnchors()
	bar:addAnchor(AnchorBottom, "parent", AnchorBottom)
	bar:addAnchor(AnchorLeft, "parent", AnchorLeft)
	bar:addAnchor(AnchorRight, "parent", AnchorRight)
	bar:setMarginTop(0)
	bar:setMarginBottom(0)
	bar:setHeight(var_9_6)
end

local function var_0_35(arg_10_0)
	if not arg_10_0 then
		return false
	end

	local id = arg_10_0:getId()

	return id == "gameLeftStatsBarPanel" or id == "gameRightStatsBarPanel"
end

local function var_0_36(arg_11_0)
	local var_11_0 = statsBarsDimensions[arg_11_0]

	if not var_11_0 then
		return 35
	end

	return var_11_0.width or var_11_0.height or 35
end

local var_0_37 = 19
local var_0_38 = {
	compactOnLeft = 10,
	parallelOnRight = 11,
	parallelOnLeft = 11,
	largeOnRight = 8,
	largeOnLeft = 8,
	defaultOnRight = 11,
	defaultOnLeft = 11,
	compactOnRight = 10
}
local var_0_39 = {
	parallelOnLeft = 15,
	defaultOnRight = -1,
	defaultOnLeft = -1,
	parallelOnRight = 15
}

local function var_0_40()
	local var_12_0 = {}

	for iter_12_0 = 1, #skillsTuples do
		local var_12_1 = skillsTuples[iter_12_0]

		if var_12_1 and g_settings.getBoolean("top_statsbar_" .. var_12_1.key) then
			table.insert(var_12_0, var_12_1)
		end
	end

	return var_12_0
end

local function var_0_41(arg_13_0)
	local id = arg_13_0 and arg_13_0:getId() or ""

	if id:find("compact") then
		return "Compact"
	elseif id:find("parallel") then
		return "Parallel"
	elseif id:find("large") then
		return "Large"
	end

	return "Default"
end

local function var_0_42(arg_14_0, arg_14_1, arg_14_2)
	if arg_14_1.key == "experience" then
		arg_14_0.level:setText(comma_value(arg_14_2:getLevel()))
		arg_14_0.bar:setValue(playerLevelPercentForStatsBar(arg_14_2), 100)
	elseif arg_14_1.key == "magic" then
		arg_14_0.level:setText(arg_14_2:getMagicLevel())
		arg_14_0.bar:setValue(playerSkillPercentForStatsBar(arg_14_2:getMagicLevelPercent()), 100)
	else
		arg_14_0.level:setText(arg_14_2:getSkillLevel(arg_14_1.skill))
		arg_14_0.bar:setValue(playerSkillPercentForStatsBar(arg_14_2:getSkillLevelPercent(arg_14_1.skill)), 100)
	end
end

local function var_0_43(parentWidget, parent)
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local tuples = var_0_40()
	local currentStatsBar = StatsBar.getCurrentStatsBar()

	if not currentStatsBar then
		return
	end

	parentWidget:setWidth(0)
	parentWidget:destroyChildren()

	local lines = 0
	local lastPlacement = "top"
	local id = parent:getId()
	local var_15_6 = id:find("OnRight") ~= nil
	local styleName = var_15_6 and "RightStatsSkillElement" or "LeftStatsSkillElement"

	for i = 1, #tuples do
		local skillTuple = tuples[i]
		local widget = g_ui.createWidget(styleName, parentWidget)

		widget:setId("statsbar_skill_" .. skillTuple.key)

		if var_15_6 then
			widget:addAnchor(AnchorRight, "parent", AnchorRight)
		else
			widget:addAnchor(AnchorLeft, "parent", AnchorLeft)
		end

		widget:setWidth(var_0_37)

		local var_15_10

		if lastPlacement == "top" then
			var_15_10 = lines * var_0_37
		else
			var_15_10 = (lines - 1) * var_0_37
		end

		if var_15_6 then
			widget:setMarginRight(var_15_10)
		else
			widget:setMarginLeft(var_15_10)
		end

		widget.level = widget:getChildById("level") or widget:recursiveGetChildById("level")
		widget.icon = widget:getChildById("icon")
		widget.bar = widget:getChildById("bar")

		local xpSlot = widget:recursiveGetChildById("statsbarXpBoostSlot")
		local xpBtn = widget:recursiveGetChildById("statsbarXpBoostButton")

		if xpSlot and xpBtn then
			if skillTuple.key == "experience" and g_game.getFeature(GameExperienceBonus) then
				xpBtn:show()
				xpSlot:setHeight(76)
				xpSlot:setWidth(14)
			else
				xpSlot:setWidth(0)
				xpSlot:setHeight(0)
				xpBtn:hide()
			end
		end

		widget.icon:setImageSource(SKILL_ICONS_SHEET)
		widget.icon:setImageClip(skillTuple.clip)
		widget.icon:setTooltip(skillTuple.name)

		widget.bar.statsGrade = 4
		widget.bar.statsGradeColor = "#070707ff"
		widget.bar.statsOrientation = "vertical"

		widget.bar:reloadBorder()

		widget.bar.showText = false

		if skillTuple.key == "experience" then
			widget.bar.statsType = "experience"
		else
			widget.bar.statsType = "skill"
		end

		local function var_15_13()
			widget:addAnchor(AnchorBottom, "parent", AnchorBottom)
			widget:addAnchor(AnchorTop, "parent", AnchorVerticalCenter)

			if statsBarSkillsParentIsCompact(parent) then
				widget:setMarginTop(COMPACT_SKILL_CENTER_GAP_LEFT - 1)
			else
				widget:setMarginTop(DEFAULT_SKILL_CENTER_GAP_LEFT - 1)
			end
		end

		local function var_15_14()
			widget:addAnchor(AnchorTop, "parent", AnchorTop)
			widget:addAnchor(AnchorBottom, "parent", AnchorVerticalCenter)
			widget:setMarginTop(-5)

			if statsBarSkillsParentIsCompact(parent) then
				widget:setMarginBottom(COMPACT_SKILL_CENTER_GAP_RIGHT + 1)
			else
				widget:setMarginBottom(DEFAULT_SKILL_CENTER_GAP_RIGHT + 1)
			end
		end

		if skillTuple.placement == "center" or i == #tuples and lastPlacement == "top" then
			widget:addAnchor(AnchorTop, "parent", AnchorTop)
			widget:addAnchor(AnchorBottom, "parent", AnchorBottom)

			if skillTuple.placement ~= "center" then
				widget:setMarginTop(-5)
			end

			lines = lines + 1
		elseif lastPlacement == "top" then
			if var_15_6 then
				var_15_14()
			else
				var_15_13()
			end

			lines = lines + 1
			lastPlacement = "bottom"
		elseif lastPlacement == "bottom" then
			if var_15_6 then
				var_15_13()
			else
				var_15_14()
			end

			lastPlacement = "top"
		end

		var_0_42(widget, skillTuple, localPlayer)
	end

	local var_15_15 = lines * var_0_37

	parentWidget:updateLayout()
	parentWidget:setWidth(var_15_15)

	local var_15_16 = var_0_36(var_0_41(parent))
	local var_15_17 = var_0_38[id] or 0
	local totalH = var_15_16 + var_15_15 + var_15_17 - 1 + (var_0_39[id] or 0)

	if totalH < 1 then
		totalH = 1
	end

	parent:setWidth(totalH)
	currentStatsBar:setWidth(totalH)
end

local function reloadSkillsTab(skills, parent)
	if var_0_33(parent) then
		return var_0_43(skills, parent)
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local var_18_1 = var_0_40()
	local statsBar = StatsBar.getCurrentStatsBar()

	if not statsBar then
		return
	end

	skills:setHeight(0)
	skills:destroyChildren()

	local var_18_3 = 0
	local var_18_4 = "left"

	for iter_18_0 = 1, #var_18_1 do
		local var_18_5 = var_18_1[iter_18_0]
		local topStatsSkillElementWidget = g_ui.createWidget("TopStatsSkillElement", skills)

		topStatsSkillElementWidget:setId("statsbar_skill_" .. var_18_5.key)
		topStatsSkillElementWidget:addAnchor(AnchorTop, "parent", AnchorTop)

		if var_18_4 == "left" then
			topStatsSkillElementWidget:setMarginTop(var_18_3 * skillsLineHeight)
		else
			topStatsSkillElementWidget:setMarginTop((var_18_3 - 1) * skillsLineHeight)
		end

		topStatsSkillElementWidget.level = topStatsSkillElementWidget:getChildById("level")
		topStatsSkillElementWidget.icon = topStatsSkillElementWidget:getChildById("icon")
		topStatsSkillElementWidget.bar = topStatsSkillElementWidget:getChildById("bar")

		local statsbarXpBoostSlot = topStatsSkillElementWidget:recursiveGetChildById("statsbarXpBoostSlot")
		local statsbarXpBoostButton = topStatsSkillElementWidget:recursiveGetChildById("statsbarXpBoostButton")

		if statsbarXpBoostSlot and statsbarXpBoostButton then
			if var_18_5.key == "experience" and g_game.getFeature(GameExperienceBonus) then
				statsbarXpBoostButton:show()

				local width = statsbarXpBoostButton:getWidth()

				statsbarXpBoostSlot:setWidth(width > 0 and width or 76)
			else
				statsbarXpBoostSlot:setWidth(0)
				statsbarXpBoostButton:hide()
			end
		end

		if var_18_5.key == "experience" then
			local marginRight = topStatsSkillElementWidget.bar:getMarginRight()

			topStatsSkillElementWidget.bar:setMarginRight((marginRight and marginRight > 0 and marginRight or 2) + 4)
		else
			local marginRight = topStatsSkillElementWidget.bar:getMarginRight()

			topStatsSkillElementWidget.bar:setMarginRight((marginRight and marginRight > 0 and marginRight or 2) - 1)
		end

		topStatsSkillElementWidget.icon:setImageSource(SKILL_ICONS_SHEET)
		topStatsSkillElementWidget.icon:setImageClip(var_18_5.clip)
		topStatsSkillElementWidget.icon:setTooltip(var_18_5.name)

		topStatsSkillElementWidget.bar.statsGrade = 4
		topStatsSkillElementWidget.bar.statsGradeColor = "#070707ff"

		topStatsSkillElementWidget.bar:reloadBorder()

		topStatsSkillElementWidget.bar.showText = false

		if var_18_5.key == "experience" then
			topStatsSkillElementWidget.bar.statsType = "experience"
		else
			topStatsSkillElementWidget.bar.statsType = "skill"
		end

		if var_18_5.placement == "center" or iter_18_0 == #var_18_1 and var_18_4 == "left" then
			topStatsSkillElementWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
			topStatsSkillElementWidget:addAnchor(AnchorRight, "parent", AnchorRight)

			var_18_3 = var_18_3 + 1
		elseif var_18_4 == "left" then
			topStatsSkillElementWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
			topStatsSkillElementWidget:addAnchor(AnchorRight, "parent", AnchorHorizontalCenter)

			if statsBarSkillsParentIsCompact(parent) then
				topStatsSkillElementWidget:setMarginRight(COMPACT_SKILL_CENTER_GAP_LEFT)
			else
				topStatsSkillElementWidget:setMarginRight(DEFAULT_SKILL_CENTER_GAP_LEFT)
			end

			var_18_3 = var_18_3 + 1
			var_18_4 = "right"
		elseif var_18_4 == "right" then
			topStatsSkillElementWidget:addAnchor(AnchorRight, "parent", AnchorRight)
			topStatsSkillElementWidget:addAnchor(AnchorLeft, "parent", AnchorHorizontalCenter)

			if statsBarSkillsParentIsCompact(parent) then
				topStatsSkillElementWidget:setMarginLeft(COMPACT_SKILL_CENTER_GAP_RIGHT)
			else
				topStatsSkillElementWidget:setMarginLeft(DEFAULT_SKILL_CENTER_GAP_RIGHT)
			end

			var_18_4 = "left"
		end

		var_0_42(topStatsSkillElementWidget, var_18_5, localPlayer)
	end

	skills:updateLayout()
	skills:setHeight(var_18_3 * skillsLineHeight + 5)

	local totalH = statsBarTopSkillsParentBaseHeight(parent) + skills:getHeight() - 1

	if statsBarSkillsParentIsCompact(parent) then
		totalH = totalH - COMPACT_STATS_BAR_HEIGHT
	elseif statsBarSkillsParentIsParallel(parent) then
		totalH = totalH + PARALLEL_STATS_BAR_HEIGHT
	elseif statsBarSkillsParentIsLarge(parent) then
		totalH = totalH - LARGE_STATS_BAR_HEIGHT_TRIM
	end

	if totalH < 1 then
		totalH = 1
	end

	parent:setHeight(totalH)
	statsBar:setHeight(totalH)
end

function StatsBar.getAllStatsBarWithPosition()
	local statsBarsWithPosition = {}

	for _, statsBar in pairs(statsBars) do
		for _, placement in ipairs(statsBarsPlacements) do
			for dimension, _ in pairs(statsBarsDimensions) do
				local dimensionOnPlacement = tostring(dimension):lower() .. "On" .. placement

				if statsBar[dimensionOnPlacement] then
					statsBarsWithPosition[#statsBarsWithPosition + 1] = statsBar[dimensionOnPlacement]
				end
			end
		end
	end

	return statsBarsWithPosition
end

function StatsBar.getCurrentStatsBarWithPosition()
	if currentStats.dimension == "hide" or currentStats.placement == "hide" then
		return nil
	end

	local placement = currentStats.placement:gsub("^%l", string.upper)
	local fullPosition = currentStats.dimension .. "On" .. placement
	local statsBar = StatsBar.getCurrentStatsBar()

	if not statsBar then
		return nil
	end

	if statsBar[fullPosition] then
		return statsBar[fullPosition]
	else
		print("No stats bar with position found for:", statsBar)
	end

	return nil
end

function StatsBar.getCurrentStatsBar()
	if currentStats.dimension == "hide" or currentStats.placement == "hide" then
		return nil
	end

	local placement = currentStats.placement:gsub("^%l", string.upper)
	local statsBar = "statsBar" .. placement

	if statsBars[statsBar] then
		return statsBars[statsBar]
	else
		print("No stats bar found for:", statsBar)
	end

	return nil
end

local function statsBarApplyManaLineWidget(widget, lineMain)
	if not widget or not widget.recursiveGetChildById then
		return
	end

	local row = widget:recursiveGetChildById("textRow")
	local lbl = widget:recursiveGetChildById("statsbarManaValue")
	local icon = widget:recursiveGetChildById("statsbarManaShieldIcon")
	local fin = widget:recursiveGetChildById("statsbarManaEnd")

	if row then
		row:show()
		row:raise()
	end

	if lbl then
		lbl:setText(lineMain)
		lbl:show()
	end

	if icon then
		icon:show()
	end

	if fin then
		fin:setText(")")
		fin:show()
	end
end

local function statsBarHideManaLineWidget(widget)
	if not widget or not widget.recursiveGetChildById then
		return
	end

	local row = widget:recursiveGetChildById("textRow")

	if row then
		row:hide()
	end
end

local function statsBarApplyShieldRowNoParen(widget, lineNumeric)
	if not widget or not widget.recursiveGetChildById then
		return
	end

	local row = widget:recursiveGetChildById("textRow")
	local lbl = widget:recursiveGetChildById("statsbarManaValue")
	local icon = widget:recursiveGetChildById("statsbarManaShieldIcon")
	local fin = widget:recursiveGetChildById("statsbarManaEnd")

	if row then
		row:show()
		row:raise()
	end

	if lbl then
		lbl:setText(lineNumeric)
		lbl:show()
	end

	if icon then
		icon:show()
	end

	if fin then
		fin:hide()
	end
end

local function statsBarPlayerUsesManaShieldBar(player)
	return player and (player:isSorcerer() or player:isDruid())
end

local function statsBarPlayerHasMagicShieldState(player)
	if not player or not player.hasCondition then
		return false
	end

	return player:hasCondition(PlayerStates.ManaShield) or player:hasCondition(PlayerStates.NewManaShield)
end

local function statsBarResetManaBarFillMargins(manaBarWidget)
	local b = manaBarWidget and manaBarWidget:getChildById("bar")

	if b then
		b:setMargin(1)
	end
end

local function statsBarSetManaBarReserveShieldStrip(manaBarWidget, stripPx)
	local b = manaBarWidget and manaBarWidget:getChildById("bar")

	if not b then
		return
	end

	b:setMarginTop(1)
	b:setMarginLeft(1)
	b:setMarginRight(1)
	b:setMarginBottom(stripPx + 1)
end

local function statsBarLayoutIsLargeDual(bar)
	local id = bar and bar.getId and bar:getId() or ""

	return id == "largeOnTop" or id == "largeOnBottom"
end

local LARGE_DUAL_MANA_STRIP_H = 13
local LARGE_DUAL_MANA_SHIELD_GAP_TOP = 2
local LARGE_DUAL_MANASHIELD_STRIP_H = 13

local function statsBarApplyLargeDualLayoutMode(bar, mode)
	local stack = bar:getChildById("manaStack")

	if not stack then
		return
	end

	local manaW = stack:getChildById("mana")
	local msW = stack:getChildById("manashield")

	if not manaW then
		return
	end

	if mode == "mage" and msW then
		msW:show()
		manaW:breakAnchors()
		manaW:addAnchor(AnchorTop, "parent", AnchorTop)
		manaW:addAnchor(AnchorLeft, "parent", AnchorLeft)
		manaW:addAnchor(AnchorRight, "parent", AnchorRight)
		manaW:setHeight(LARGE_DUAL_MANA_STRIP_H)
		msW:breakAnchors()
		msW:addAnchor(AnchorTop, "mana", AnchorBottom)
		msW:setMarginTop(LARGE_DUAL_MANA_SHIELD_GAP_TOP)
		msW:setMarginBottom(0)
		msW:addAnchor(AnchorLeft, "parent", AnchorLeft)
		msW:addAnchor(AnchorRight, "parent", AnchorRight)
		msW:setHeight(LARGE_DUAL_MANASHIELD_STRIP_H)
	else
		if msW then
			msW:hide()
			msW:breakAnchors()
			msW:setMarginTop(0)
			msW:setMarginBottom(0)
		end

		manaW:breakAnchors()
		manaW:addAnchor(AnchorTop, "parent", AnchorTop)
		manaW:addAnchor(AnchorLeft, "parent", AnchorLeft)
		manaW:addAnchor(AnchorRight, "parent", AnchorRight)
		manaW:addAnchor(AnchorBottom, "parent", AnchorBottom)
	end
end

local function statsBarApplyManaQuickInfoToBar(bar, player, updateHealth, updateMana)
	if not bar or not player then
		return
	end

	local healthW = bar.health or bar:getChildById("health")

	if updateHealth and healthW then
		healthW:setValue(player:getHealth(), player:getMaxHealth())
	end

	if not updateMana then
		return
	end

	local manaW = bar.mana or bar:getChildById("mana")
	local msW = bar.manashield

	if not manaW then
		local stack = bar:getChildById("manaStack")

		if stack then
			manaW = stack:getChildById("mana")
		end
	end

	if manaW then
		local nestedMs = manaW:getChildById("manashield")

		if nestedMs then
			msW = nestedMs
		end
	end

	msW = msW or bar:getChildById("manashield")

	if not msW then
		local stack = bar:getChildById("manaStack")

		if stack then
			msW = stack:getChildById("manashield")
		end
	end

	if not manaW then
		return
	end

	if msW and manaW then
		if manaW.statsOrientation then
			msW.statsOrientation = manaW.statsOrientation
		end

		msW.statsType = "manashield"

		if not statsBarLayoutIsLargeDual(bar) and manaW.statsSize then
			msW.statsSize = manaW.statsSize
		end
	end

	local mana = player:getMana()
	local maxMana = player:getMaxMana()
	local manashield = player:getManaShield()
	local maxManaShield = player:getMaxManaShield()
	local isMage = statsBarPlayerUsesManaShieldBar(player)
	local utamoShieldBarActive = statsBarPlayerHasMagicShieldState(player)
	local useSplitManaShieldBars = isMage and msW and utamoShieldBarActive and not statsBarLayoutIsLargeDual(bar)

	if statsBarLayoutIsLargeDual(bar) then
		manaW.manaShieldText = nil

		if msW then
			msW.manaShieldText = nil
		end

		local desiredMode = isMage and msW and "mage" or "knight"

		if bar._largeDualLayoutMode ~= desiredMode then
			bar._largeDualLayoutMode = desiredMode

			statsBarApplyLargeDualLayoutMode(bar, desiredMode)
		end

		statsBarResetManaBarFillMargins(manaW)

		if desiredMode == "mage" and msW then
			manaW.manaDisplayLineMain = nil
			manaW.manaShieldText = nil
			manaW.showText = true

			manaW:setValue(mana, maxMana)

			msW.manaDisplayLineMain = nil
			msW.manaShieldText = nil
			msW.showText = true

			local shieldBarTotal = math.max(1, maxManaShield)
			local shieldBarValue = math.max(0, math.min(manashield, shieldBarTotal))

			msW:setValue(shieldBarValue, shieldBarTotal)

			local shieldLine = string.format("%d/%d", manashield, maxManaShield)

			statsBarApplyShieldRowNoParen(msW, shieldLine)

			local textRowMana = manaW:recursiveGetChildById("textRow")

			if textRowMana then
				textRowMana:raise()
			end

			local textRowMs = msW:recursiveGetChildById("textRow")

			if textRowMs then
				textRowMs:raise()
			end
		else
			if msW then
				msW.manaDisplayLineMain = nil
				msW.manaShieldText = nil
				msW.showText = false

				statsBarHideManaLineWidget(msW)
			end

			manaW.manaDisplayLineMain = nil
			manaW.showText = true

			manaW:setValue(mana, maxMana)
		end

		return
	end

	if not manaW.defaultHeight then
		manaW.defaultHeight = manaW:getHeight()
	end

	manaW.manaShieldText = nil

	if msW then
		msW.manaShieldText = nil
	end

	if useSplitManaShieldBars then
		local manaLineMain = string.format("%d/%d (%d/%d", mana, maxMana, manashield, maxManaShield)
		local stripH = 6

		if manaW.defaultHeight then
			manaW:setHeight(manaW.defaultHeight)
		end

		statsBarSetManaBarReserveShieldStrip(manaW, stripH)

		manaW.manaDisplayLineMain = manaLineMain
		manaW.showText = true

		manaW:setValue(mana, maxMana)

		if msW then
			msW:show()
			msW:setMarginTop(0)
			msW:setMarginBottom(1)
			msW:setMarginLeft(0)
			msW:setMarginRight(0)
			msW:setHeight(stripH)

			msW.manaDisplayLineMain = nil
			msW.showText = false

			local shieldBarTotal = math.max(1, maxManaShield)
			local shieldBarValue = math.max(0, math.min(manashield, shieldBarTotal))

			msW:setValue(shieldBarValue, shieldBarTotal)
		end

		statsBarApplyManaLineWidget(manaW, manaLineMain)

		local textRow = manaW:recursiveGetChildById("textRow")

		if textRow then
			textRow:raise()
		end
	elseif isMage then
		if msW then
			msW.manaDisplayLineMain = nil
			msW.showText = true

			msW:setMarginTop(0)
			msW:hide()

			local msRow = msW:recursiveGetChildById("textRow")

			if msRow then
				msRow:setMarginTop(0)
				msRow:setMarginBottom(0)
			end
		end

		statsBarResetManaBarFillMargins(manaW)

		local manaLineMain = string.format("%d/%d (%d/%d", mana, maxMana, manashield, maxManaShield)

		manaW.manaDisplayLineMain = manaLineMain
		manaW.showText = true

		if manaW.defaultHeight then
			manaW:setHeight(manaW.defaultHeight)
		end

		manaW:setValue(mana, maxMana)
		statsBarHideManaLineWidget(msW)
		statsBarApplyManaLineWidget(manaW, manaLineMain)
	else
		if msW then
			msW.manaDisplayLineMain = nil
			msW.showText = true

			msW:setMarginTop(0)
			msW:hide()

			local msRow = msW:recursiveGetChildById("textRow")

			if msRow then
				msRow:setMarginTop(0)
				msRow:setMarginBottom(0)
			end
		end

		statsBarResetManaBarFillMargins(manaW)

		manaW.manaDisplayLineMain = nil
		manaW.showText = true

		if manaW.defaultHeight then
			manaW:setHeight(manaW.defaultHeight)
		end

		manaW:setValue(mana, maxMana)
		statsBarHideManaLineWidget(msW)
	end
end

function StatsBar.reloadCurrentStatsBarQuickInfo(updateHealth, updateMana)
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	if updateHealth == nil and updateMana == nil then
		updateHealth = true
		updateMana = true
	end

	local bar = StatsBar.getCurrentStatsBarWithPosition()

	if bar then
		statsBarApplyManaQuickInfoToBar(bar, player, updateHealth == true, updateMana == true)
	end
end

local function loadIcon(bitChanged, content, topmenu)
	if not bitChanged then
		return nil
	end

	if modules.client_options and modules.client_options.isSpecialConditionId(bitChanged.id) and not modules.client_options.isConditionVisibleInBar(bitChanged.id) then
		return nil
	end

	local icon = g_ui.createWidget("ConditionWidget", content)

	icon:setId(bitChanged.id)
	applyPlayerStateIcon(icon, bitChanged)

	local tooltip = bitChanged.tooltip

	if tooltip == "You are GoshnarTaint" then
		tooltip = "Goshnar's Lairs Penalties:\n" .. "- 10% chance of creature teleportation to you\n" .. "- 0.5% chance of new creature spawn when hitting another\n" .. "- 15% increased damage received\n" .. "- 10% chance of creature full heal instead of dying\n" .. "- Lose 10% of current HP and mana every 10 seconds"
	end

	icon:setTooltip(tooltip)
	icon:setImageSize(tosize("9 9"))

	if content and content.verticalIcons then
		icon:setMarginLeft(4)
		icon:setMarginRight(0)
		icon:setMarginTop(0)
		icon:setMarginBottom(2)
	else
		icon:setMarginRight(-1)

		if topmenu then
			icon:setMarginTop(5)
			icon:setMarginLeft(2)
			icon:setMarginRight(-2)
		end
	end

	return icon
end

local function var_0_59()
	local iconContents = {}
	local statsBars = StatsBar.getAllStatsBarWithPosition()

	for _, statsBar in ipairs(statsBars) do
		local iconsPanel = statsBar:recursiveGetChildById("icons")

		if iconsPanel then
			iconContents[#iconContents + 1] = {
				loadIconTransparent = true,
				content = iconsPanel
			}
		end
	end

	iconContents[#iconContents + 1] = {
		loadIconTransparent = false,
		content = modules.game_inventory.getIconsPanelOn()
	}
	iconContents[#iconContents + 1] = {
		loadIconTransparent = false,
		content = modules.game_inventory.getIconsPanelOff()
	}

	return iconContents
end

local BATTLE_CONDITION_STATES = bit.bor(PlayerStates.Swords, PlayerStates.RedSwords)
local var_0_61 = "condition_bakragore_taint"
local refreshHungryConditionIcon

local function var_0_63(arg_35_0)
	local client_options = modules.client_options

	return client_options ~= nil and client_options.isSpecialConditionId(arg_35_0) and not client_options.isConditionVisibleInBar(arg_35_0)
end

local function var_0_64(arg_36_0, arg_36_1, arg_36_2)
	local content = arg_36_0.content
	local childById = content:getChildById(arg_36_1.id)

	if arg_36_2 and var_0_63(arg_36_1.id) then
		arg_36_2 = false
	end

	if not arg_36_2 then
		if childById then
			childById:hide()
		end

		return nil
	end

	if not childById then
		return loadIcon(arg_36_1, content, arg_36_0.loadIconTransparent)
	end

	if not childById:isExplicitlyVisible() then
		content:moveChildToIndex(childById, content:getChildCount())
		childById:show()
	end

	return childById
end

local function refreshBattleConditionIcon(states)
	local desiredState

	if bit.band(states, PlayerStates.RedSwords) ~= 0 then
		desiredState = PlayerStates.RedSwords
	elseif bit.band(states, PlayerStates.Swords) ~= 0 then
		desiredState = PlayerStates.Swords
	end

	local swordsInfo = Icons[PlayerStates.Swords]
	local redSwordsInfo = Icons[PlayerStates.RedSwords]

	for _, contentData in ipairs(var_0_59()) do
		var_0_64(contentData, swordsInfo, desiredState == PlayerStates.Swords)
		var_0_64(contentData, redSwordsInfo, desiredState == PlayerStates.RedSwords)
	end
end

local function var_0_66(bitChanged, arg_38_1)
	local iconId = Icons[bitChanged]

	if not iconId then
		g_logger.warning(string.format("No icon ID %s (%s)  found. Check Icons array in modules/gamelib/player.lua.", tostring(bitChanged), tostring(math.log(bitChanged) / math.log(2))))

		return
	end

	for _, contentData in ipairs(var_0_59()) do
		var_0_64(contentData, iconId, arg_38_1)
	end
end

function StatsBar.refreshConditionIconsFromSettings()
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local states = player:getStates()

	for _, contentData in ipairs(var_0_59()) do
		for _, cond in ipairs(SpecialConditions or {}) do
			local var_39_2 = cond.state and Icons[cond.state]

			if cond.id and var_39_2 then
				var_0_64(contentData, var_39_2, bit.band(states, cond.state) ~= 0)
			end
		end
	end

	refreshBattleConditionIcon(states)
	refreshHungryConditionIcon()
	refreshBakragoreTaintIcon()
end

function refreshHungryConditionIcon()
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local info = Icons.hungry

	if not info or not info.id then
		return
	end

	local active = isPlayerHungryConditionActive(player)

	for _, contentData in ipairs(var_0_59()) do
		var_0_64(contentData, info, active)
	end
end

function refreshBakragoreTaintIcon()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local bakragoreIcon = getBakragoreTaintIconInfo(localPlayer:getBakragoreIcon())

	for _, contentData in ipairs(var_0_59()) do
		local icon = var_0_64(contentData, bakragoreIcon or {
			id = var_0_61
		}, bakragoreIcon ~= nil)

		if icon then
			applyPlayerStateIcon(icon, bakragoreIcon)
			icon:setTooltip(bakragoreIcon.tooltip)
		end
	end
end

function processIcon(id, action, createIfMissing)
	local var_42_0 = Icons[id]
	local var_42_1 = var_42_0 and var_42_0.id or id

	for _, skillTuple in ipairs(var_0_59()) do
		local childById

		if createIfMissing and var_42_0 then
			childById = var_0_64(skillTuple, var_42_0, true)
		else
			childById = skillTuple.content:getChildById(var_42_1)
		end

		if childById then
			action(childById)
		end
	end
end

function StatsBar.reloadCurrentStatsBarQuickInfo_state(unusedArgument, now, old)
	if not g_game.getLocalPlayer() then
		return
	end

	if now == old then
		return
	end

	local var_43_0 = bit.bxor(now, old)
	local var_43_1 = bit.band(var_43_0, BATTLE_CONDITION_STATES) ~= 0

	for iter_43_0 = 1, 32 do
		local var_43_2 = math.pow(2, iter_43_0 - 1)

		if var_43_0 < var_43_2 then
			break
		end

		local var_43_3 = bit.band(var_43_0, var_43_2)

		if var_43_3 ~= 0 and bit.band(var_43_3, BATTLE_CONDITION_STATES) == 0 then
			var_0_66(var_43_3, bit.band(now, var_43_3) ~= 0)
		end
	end

	if var_43_1 then
		refreshBattleConditionIcon(now)
	end

	local var_43_4 = bit.bor(PlayerStates.ManaShield, PlayerStates.NewManaShield)

	if bit.band(var_43_0, var_43_4) ~= 0 then
		StatsBar.scheduleCurrentStatsBarManaInfo()
	end
end

function StatsBar.reloadCurrentStatsBarDeepInfo()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local currentStatsBarWithPosition = StatsBar.getCurrentStatsBarWithPosition()

	if not currentStatsBarWithPosition then
		return
	end

	for unusedValue, skillsTuple in ipairs(skillsTuples) do
		local statsbarSkill = currentStatsBarWithPosition:recursiveGetChildById("statsbar_skill_" .. skillsTuple.key)

		if statsbarSkill then
			if skillsTuple.key == "experience" then
				statsbarSkill.level:setText(comma_value(localPlayer:getLevel()))
				statsbarSkill.bar:setValue(playerLevelPercentForStatsBar(localPlayer), 100)
			elseif skillsTuple.key == "magic" then
				statsbarSkill.level:setText(localPlayer:getMagicLevel())
				statsbarSkill.bar:setValue(playerSkillPercentForStatsBar(localPlayer:getMagicLevelPercent()), 100)
			else
				statsbarSkill.level:setText(localPlayer:getSkillLevel(skillsTuple.skill))
				statsbarSkill.bar:setValue(playerSkillPercentForStatsBar(localPlayer:getSkillLevelPercent(skillsTuple.skill)), 100)
			end
		end
	end
end

function StatsBar.cancelPendingRefreshes()
	if statsBarQuickInfoEvent then
		removeEvent(statsBarQuickInfoEvent)

		statsBarQuickInfoEvent = nil
	end

	if statsBarDeepInfoEvent then
		removeEvent(statsBarDeepInfoEvent)

		statsBarDeepInfoEvent = nil
	end

	statsBarQuickHealthPending = false
	statsBarQuickManaPending = false
end

local function var_0_67(arg_46_0, arg_46_1)
	statsBarQuickHealthPending = statsBarQuickHealthPending or arg_46_0 == true
	statsBarQuickManaPending = statsBarQuickManaPending or arg_46_1 == true

	if statsBarQuickInfoEvent then
		return
	end

	statsBarQuickInfoEvent = addEvent(function()
		statsBarQuickInfoEvent = nil

		local refreshHealth = statsBarQuickHealthPending
		local refreshMana = statsBarQuickManaPending

		statsBarQuickHealthPending = false
		statsBarQuickManaPending = false

		StatsBar.reloadCurrentStatsBarQuickInfo(refreshHealth, refreshMana)
	end)
end

function StatsBar.scheduleCurrentStatsBarHealthInfo()
	var_0_67(true, false)
end

function StatsBar.scheduleCurrentStatsBarManaInfo()
	var_0_67(false, true)
end

function StatsBar.scheduleCurrentStatsBarDeepInfo()
	if statsBarDeepInfoEvent then
		return
	end

	statsBarDeepInfoEvent = addEvent(function()
		statsBarDeepInfoEvent = nil

		StatsBar.reloadCurrentStatsBarDeepInfo()
	end)
end

local function normalizePlacement(placement)
	placement = string.lower(tostring(placement or "top"))

	if placement == "bottom" or placement == "left" or placement == "right" then
		return placement
	end

	return "top"
end

local function saveStatsBarConfigNow(dimensionString, placement)
	placement = normalizePlacement(placement)
	currentStats = {
		dimension = dimensionString,
		placement = placement
	}

	g_settings.set("statsbar_dimension", dimensionString)
	g_settings.set("statsbar_placement", placement)
	g_settings.save()
end

function constructStatsBar(dimension, placement)
	local dimensionString = dimension:gsub("^%u", string.lower)

	placement = normalizePlacement(placement)

	saveStatsBarConfigNow(dimensionString, placement)

	local dimensionOnPlacement = dimensionString .. "On" .. placement:gsub("^%l", string.upper)
	local statsBar = statsBars["statsBar" .. placement:gsub("^%l", string.upper)]

	if not statsBar then
		return
	end

	local variant = statsBar[dimensionOnPlacement]

	if not variant then
		variant = statsBar:getChildById(dimensionOnPlacement)

		if variant then
			statsBar[dimensionOnPlacement] = variant
		end
	end

	if variant then
		local var_54_4 = var_0_36(dimension)

		if var_0_35(statsBar) then
			statsBar:setWidth(var_54_4)
			variant:setWidth(var_54_4)
		else
			statsBar:setHeight(var_54_4)
			variant:setHeight(var_54_4)
		end

		variant:show()
		variant:setPhantom(false)

		variant.health = variant:getChildById("health") or variant:recursiveGetChildById("health")

		local root = variant
		local manaRef = root:getChildById("mana") or root:recursiveGetChildById("mana")
		local msRef = root:getChildById("manashield") or root:recursiveGetChildById("manashield")

		if not manaRef or not msRef then
			local stack = root:getChildById("manaStack")

			if stack then
				manaRef = manaRef or stack:getChildById("mana")
				msRef = msRef or stack:getChildById("manashield")
			end
		end

		if not msRef and manaRef then
			msRef = manaRef:getChildById("manashield")
		end

		root.mana = manaRef
		root.manashield = msRef
		root._largeDualLayoutMode = nil
		variant.skills = variant:getChildById("skills")
		statsBar[dimensionOnPlacement] = variant

		if var_0_35(statsBar) then
			local id = statsBar:getId() == "gameRightStatsBarPanel" and 90 or -90

			local function var_54_10(arg_55_0)
				if arg_55_0 and arg_55_0.setRotation then
					arg_55_0:setRotation(id)
				end
			end

			local health = variant.health or variant:recursiveGetChildById("health")

			if health then
				var_54_10(health:getChildById("text"))
				var_54_10(health:getChildById("textRow"))
			end

			if variant.mana then
				var_54_10(variant.mana:getChildById("text"))
				var_54_10(variant.mana:getChildById("textRow"))
			end

			var_54_10(variant:recursiveGetChildById("proficiencyLabel"))
			var_54_10(variant:recursiveGetChildById("proficiencyIcon"))
			var_0_34(variant)

			local barsColumn = variant:getChildById("barsColumn")

			if barsColumn and not barsColumn._statsBarEqualizeBound then
				barsColumn._statsBarEqualizeBound = true

				function barsColumn.onGeometryChange()
					var_0_34(variant)
				end
			end
		end

		reloadSkillsTab(variant.skills, variant)
		StatsBar.reloadCurrentStatsBarQuickInfo()

		if modules.game_interface and modules.game_interface.refreshStatsBarDockLayout then
			modules.game_interface.refreshStatsBarDockLayout()
		end

		modules.game_healthcircle.setStatsBarOption(dimensionString, placement)

		if string.lower(dimension) == "default" or string.lower(dimension) == "parallel" then
			StatsBar.applyDefaultTopProficiencyLayout()
		elseif string.lower(dimension) == "compact" then
			StatsBar.applyCompactTopProficiencyWeaponButton()
		end

		if string.lower(dimension) == "default" or string.lower(dimension) == "compact" or string.lower(dimension) == "parallel" or string.lower(dimension) == "large" then
			StatsBar.applyDefaultTopMonkComboSereneLayout()
		end

		StatsBar.switchCurrentLayout()
	else
		print("No stats bar found for:", dimensionOnPlacement .. " on constructStatsBar()")
	end
end

function StatsBar.updateCurrentStats(dimension, placement)
	currentStats = {
		dimension = dimension,
		placement = placement
	}
end

local function openDropMenu(mousePos)
	local menu = g_ui.createWidget("PopupMenu")

	menu:setGameMenu(true)

	local function currentStyleForConstruct()
		local d = currentStats.dimension

		if not d or d == "" or d == "hide" then
			d = g_settings.getString("statsbar_dimension")
		end

		if not d or d == "" or d == "hide" then
			return "Compact"
		end

		return d:sub(1, 1):upper() .. d:sub(2)
	end

	local function currentPlacementDefault()
		local p = currentStats.placement

		if not p or p == "" or p == "hide" then
			p = g_settings.getString("statsbar_placement")
		end

		return normalizePlacement(p)
	end

	local function placementMenuToPlacementDock(menuId)
		if menuId == "top" then
			g_settings.set("statsbar_dock", "full")

			return "top"
		elseif menuId == "left" then
			g_settings.set("statsbar_dock", "full")

			return "left"
		elseif menuId == "right" then
			g_settings.set("statsbar_dock", "full")

			return "right"
		elseif menuId == "bottom" then
			g_settings.set("statsbar_dock", "full")

			return "bottom"
		end

		return "top"
	end

	local placementRows = {
		{
			menuId = "top",
			label = tr("Switch to Top Position")
		},
		{
			menuId = "left",
			label = tr("Switch to Left Position")
		},
		{
			menuId = "right",
			label = tr("Switch to Right Position")
		},
		{
			menuId = "bottom",
			label = tr("Switch to Bottom Position")
		}
	}
	local barPlacement = currentStats.placement

	if not barPlacement or barPlacement == "" then
		barPlacement = g_settings.getString("statsbar_placement")
	end

	if barPlacement == "" or barPlacement == "hide" then
		barPlacement = "top"
	end

	for _, row in ipairs(placementRows) do
		if not (barPlacement == "top" and row.menuId == "top" or barPlacement == "bottom" and row.menuId == "bottom" or barPlacement == "left" and row.menuId == "left" or barPlacement == "right" and row.menuId == "right") then
			menu:addOption(row.label, function()
				local plac = placementMenuToPlacementDock(row.menuId)

				StatsBar.hideAll()
				constructStatsBar(currentStyleForConstruct(), plac)
			end)
		end
	end

	menu:addSeparator()

	local barStyle = currentStats.dimension

	if not barStyle or barStyle == "" then
		barStyle = g_settings.getString("statsbar_dimension")
	end

	if barStyle == "" or barStyle == "hide" then
		barStyle = "compact"
	end

	local barStyle = barStyle:lower()
	local styleRows = {
		{
			styleId = "default",
			dim = "Default",
			label = tr("Switch to Default Style")
		},
		{
			styleId = "compact",
			dim = "Compact",
			label = tr("Switch to Compact Style")
		},
		{
			styleId = "large",
			dim = "Large",
			label = tr("Switch to Large Style")
		},
		{
			styleId = "parallel",
			dim = "Parallel",
			label = tr("Switch to Parallel Style")
		}
	}

	for _, row in ipairs(styleRows) do
		if barStyle ~= row.styleId then
			menu:addOption(row.label, function()
				StatsBar.hideAll()
				constructStatsBar(row.dim, currentPlacementDefault())
			end)
		end
	end

	menu:addSeparator()

	for _, skillTuple in ipairs(skillsTuples) do
		local key = skillTuple.key
		local checked = g_settings.getBoolean("top_statsbar_" .. key)
		local label = tr(SKILL_MENU_CHECKBOX_LABEL[key] or "Show " .. skillTuple.name)

		menu:addCheckBox(label, checked, function(_, newChecked)
			g_settings.set("top_statsbar_" .. key, newChecked)

			local cur = StatsBar.getCurrentStatsBarWithPosition()

			if cur and cur.skills then
				reloadSkillsTab(cur.skills, cur)

				if modules.game_interface and modules.game_interface.refreshStatsBarDockLayout then
					modules.game_interface.refreshStatsBarDockLayout()
				end
			end
		end)
	end

	menu:addSeparator()

	if modules.client_options and modules.client_options.getOption and modules.client_options.setOption then
		local customOn = modules.client_options.getOption("showCustomisableStatusBars")

		menu:addCheckBox(tr("Show Customisable Status Bars"), customOn, function(_, checked)
			modules.client_options.setOption("showCustomisableStatusBars", checked, true)
		end)

		local statusOn = modules.client_options.getOption("showStatusBars")

		menu:addCheckBox(tr("Show Status Bars"), statusOn, function(_, checked)
			modules.client_options.setOption("showStatusBars", checked, true)
		end)
	end

	menu:setWidth(271)
	menu:display(mousePos)
end

local function onStatsMousePress(tab, mousePos, mouseButton)
	if mouseButton == MouseRightButton then
		openDropMenu(mousePos)

		return true
	end
end

function StatsBar.reloadCurrentTab()
	if currentStats.dimension == "hide" then
		return
	end

	local dimension = currentStats.dimension:gsub("^%l", string.upper)

	if statsBarsDimensions[dimension] then
		return constructStatsBar(dimension, currentStats.placement)
	else
		print("No stats bars dimensions found: ", dimension, " on reloadCurrentTab()")

		return
	end
end

function StatsBar.updateStatsBarOption(dimension)
	StatsBar.hideAll()
	StatsBar.firstLoadSettings()

	if currentStats.dimension ~= "hide" and dimension ~= "hide" then
		StatsBar.reloadCurrentTab()
	end
end

local function getSettingOrDefault(setting, default)
	local value = g_settings.getString(setting)

	return value ~= "" and value or default
end

local function setSetting(setting, value)
	g_settings.set(setting, value)
end

function StatsBar.loadSettings()
	currentStats = {
		dimension = getSettingOrDefault("statsbar_dimension", "compact"),
		placement = normalizePlacement(getSettingOrDefault("statsbar_placement", "top"))
	}
end

function StatsBar.firstLoadSettings()
	if firstCall then
		StatsBar.loadSettings()

		firstCall = false
	end
end

local statsBarInventoryPlayerRef
local lastProficiencyPanelVisible
local leftHandHasWeaponProficiency

local function onStatsBarInventoryChange()
	local showPanel = leftHandHasWeaponProficiency()

	StatsBar.applyDefaultTopProficiencyLayout()
	StatsBar.syncProficiencyHighlightWithHandWeapon()

	if lastProficiencyPanelVisible ~= showPanel then
		lastProficiencyPanelVisible = showPanel

		if g_settings.getString("statsbar_placement") == "bottom" and modules.game_interface and modules.game_interface.applyBottomSplitterLayoutHeight then
			modules.game_interface.applyBottomSplitterLayoutHeight()
		end
	end
end

local statsBarInventoryHandlers = {
	onInventoryChange = function()
		addEvent(onStatsBarInventoryChange)
	end
}

local function statsBarDisconnectInventoryPlayer()
	if statsBarInventoryPlayerRef then
		pcall(function()
			disconnect(statsBarInventoryPlayerRef, statsBarInventoryHandlers)
		end)

		statsBarInventoryPlayerRef = nil
	end
end

local function statsBarConnectInventoryPlayer()
	statsBarDisconnectInventoryPlayer()

	local p = g_game.getLocalPlayer()

	if p and type(p) == "userdata" then
		statsBarInventoryPlayerRef = p

		connect(statsBarInventoryPlayerRef, statsBarInventoryHandlers)
	end
end

function StatsBar.OnGameEnd()
	StatsBar.cancelPendingRefreshes()
	statsBarDisconnectInventoryPlayer()

	lastProficiencyCache = {}
	lastProficiencyPanelVisible = nil

	StatsBar.clearProficiencyHighlightUi()
	StatsBar.hideAll()
	modules.game_inventory.getIconsPanelOn():destroyChildren()
	modules.game_inventory.getIconsPanelOff():destroyChildren()
	StatsBar.destroyAllIcons()
end

function StatsBar.OnGameStart()
	lastProficiencyCache = {}

	StatsBar.clearProficiencyHighlightUi()
	statsBarConnectInventoryPlayer()
	StatsBar.loadSettings()
	StatsBar.reloadCurrentTab()
	StatsBar.applyDefaultTopProficiencyLayout()
	StatsBar.applyDefaultTopMonkComboSereneLayout()
	modules.game_healthcircle.setStatsBarOption()
	refreshHungryConditionIcon()
	refreshBakragoreTaintIcon()

	if modules.game_interface and modules.game_interface.refreshStatsBarDockLayout then
		modules.game_interface.refreshStatsBarDockLayout()
	end
end

function createStatsBarWidgets(statsBar)
	local widget = statsBar

	for _, placement in ipairs(statsBarsPlacements) do
		for dimension, _ in pairs(statsBarsDimensions) do
			local elementName = tostring(dimension):gsub("^%u", string.lower) .. "On" .. placement

			widget[elementName] = statsBar:getChildById(elementName)
		end
	end

	widget.onMousePress = onStatsMousePress

	return widget
end

local statsBarThingsHandlers = {
	onLoadDat = function()
		StatsBar.applyDefaultTopProficiencyLayout()
	end
}

local function proficiencyTableHasEntries(PD)
	return PD and PD.content and next(PD.content) ~= nil
end

function leftHandHasWeaponProficiency()
	local player = g_game.getLocalPlayer()

	if not player or not g_game.isOnline() then
		return false
	end

	local item

	if modules.game_inventory and modules.game_inventory.getWeaponProficiencyHandItem then
		item = modules.game_inventory.getWeaponProficiencyHandItem()
	end

	item = item or player:getInventoryItem(InventorySlotLeft)

	if not item then
		return false
	end

	local ok, pid = pcall(function()
		return item:getProficiencyId()
	end)

	if not ok or not pid or pid == 0 then
		return false
	end

	local PD = ProficiencyData

	if not PD and modules.game_proficiency then
		PD = modules.game_proficiency.ProficiencyData
	end

	if PD and PD.isValidProfiencyId and proficiencyTableHasEntries(PD) then
		return PD:isValidProfiencyId(pid)
	end

	return true
end

local PROFICIENCY_BUTTON_COMPACT_UNEQUIPPED = "/images/game/topbar/proficiency-button-compact-unequipped"
local PROFICIENCY_BUTTON_COMPACT_EQUIPPED = "/images/game/topbar/proficiency-button-compact-equipped"
local PROFICIENCY_BUTTON_LARGE_UNEQUIPPED = "/images/game/topbar/proficiency-button-large-unequipped"
local PROFICIENCY_BUTTON_LARGE_EQUIPPED = "/images/game/topbar/proficiency-button-large-equipped"

local function buildRectPerimeterBorderPoints(W, H)
	local pts = {}

	for x = 1, W - 1 do
		pts[#pts + 1] = {
			x,
			0
		}
	end

	for y = 1, H - 1 do
		pts[#pts + 1] = {
			W - 1,
			y
		}
	end

	for x = W - 2, 0, -1 do
		pts[#pts + 1] = {
			x,
			H - 1
		}
	end

	for y = H - 2, 0, -1 do
		pts[#pts + 1] = {
			0,
			y
		}
	end

	return pts
end

local function proficiencyLargePerimeterCompanion(x, y, W, H)
	if y == 0 then
		return x, 1
	end

	if x == W - 1 then
		return W - 2, y
	end

	if y == H - 1 then
		return x, H - 2
	end

	if x == 0 then
		return 1, y
	end

	return x, y
end

local LARGE_PROF_RING_OFF_X = 1
local LARGE_PROF_RING_OFF_Y = 1
local LARGE_PROF_RING_INNER_W = 25
local LARGE_PROF_RING_INNER_H = 25
local LARGE_BORDER_POINTS_FLAT = (function()
	local baseLocal = buildRectPerimeterBorderPoints(LARGE_PROF_RING_INNER_W, LARGE_PROF_RING_INNER_H)
	local ox = LARGE_PROF_RING_OFF_X
	local oy = LARGE_PROF_RING_OFF_Y
	local flat = {}

	for _, pt in ipairs(baseLocal) do
		local cx, cy = proficiencyLargePerimeterCompanion(pt[1], pt[2], LARGE_PROF_RING_INNER_W, LARGE_PROF_RING_INNER_H)

		flat[#flat + 1] = {
			pt[1] + ox,
			pt[2] + oy
		}
		flat[#flat + 1] = {
			cx + ox,
			cy + oy
		}
	end

	return flat
end)()
local LARGE_BORDER_PIXEL_COUNT = #LARGE_BORDER_POINTS_FLAT
local LARGE_BORDER_STEP_COUNT = LARGE_BORDER_PIXEL_COUNT / 2

assert(LARGE_BORDER_PIXEL_COUNT == 192, "large proficiency border must be 96 steps x 2 pixels")
assert(LARGE_BORDER_STEP_COUNT == 96, "large proficiency perimeter must be 96 steps")

local BORDER_POINTS = {
	{
		1,
		0
	},
	{
		2,
		0
	},
	{
		3,
		0
	},
	{
		4,
		0
	},
	{
		5,
		0
	},
	{
		6,
		0
	},
	{
		7,
		0
	},
	{
		8,
		0
	},
	{
		9,
		0
	},
	{
		10,
		0
	},
	{
		11,
		0
	},
	{
		12,
		0
	},
	{
		13,
		0
	},
	{
		13,
		1
	},
	{
		13,
		2
	},
	{
		13,
		3
	},
	{
		13,
		4
	},
	{
		13,
		5
	},
	{
		13,
		6
	},
	{
		13,
		7
	},
	{
		13,
		8
	},
	{
		13,
		9
	},
	{
		13,
		10
	},
	{
		13,
		11
	},
	{
		13,
		12
	},
	{
		13,
		13
	},
	{
		12,
		13
	},
	{
		11,
		13
	},
	{
		10,
		13
	},
	{
		9,
		13
	},
	{
		8,
		13
	},
	{
		7,
		13
	},
	{
		6,
		13
	},
	{
		5,
		13
	},
	{
		4,
		13
	},
	{
		3,
		13
	},
	{
		2,
		13
	},
	{
		1,
		13
	},
	{
		0,
		13
	},
	{
		0,
		12
	},
	{
		0,
		11
	},
	{
		0,
		10
	},
	{
		0,
		9
	},
	{
		0,
		8
	},
	{
		0,
		7
	},
	{
		0,
		6
	},
	{
		0,
		5
	},
	{
		0,
		4
	},
	{
		0,
		3
	},
	{
		0,
		2
	},
	{
		0,
		1
	},
	{
		0,
		0
	}
}
local BORDER_SIZE = #BORDER_POINTS

assert(BORDER_SIZE == 52, "compact proficiency border must trace exactly 52 pixels")

local COMPACT_BORDER_PROGRESS_COLOR = "#00b9b1"

local function getProficiencyProgressRingSpec(panel)
	if not panel or panel:isDestroyed() then
		return nil, nil
	end

	local pid = panel:getId()

	if pid == "proficiencyButtonCompactProgress" then
		return BORDER_POINTS, BORDER_SIZE
	elseif pid == "proficiencyButtonLargeProgress" then
		return LARGE_BORDER_POINTS_FLAT, LARGE_BORDER_PIXEL_COUNT
	end

	return nil, nil
end

local function ensureBorderPixels(panel)
	if not panel or panel:isDestroyed() then
		return
	end

	local borderPoints, expectedSize = getProficiencyProgressRingSpec(panel)

	if not borderPoints or not expectedSize then
		return
	end

	local existing = panel.borderPixels

	if existing and #existing == expectedSize then
		local intact = true

		for i = 1, expectedSize do
			local w = existing[i]

			if not w or w:isDestroyed() then
				intact = false

				break
			end
		end

		if intact then
			return
		end
	end

	if existing then
		for _, w in ipairs(existing) do
			if w and not w:isDestroyed() then
				w:destroy()
			end
		end
	end

	panel.borderPixels = {}

	for i, pos in ipairs(borderPoints) do
		local pixel = g_ui.createWidget("UIWidget", panel)

		pixel:setPhantom(true)
		pixel:setFocusable(false)
		pixel:setSize({
			height = 1,
			width = 1
		})
		pixel:breakAnchors()
		pixel:addAnchor(AnchorLeft, "parent", AnchorLeft)
		pixel:addAnchor(AnchorTop, "parent", AnchorTop)
		pixel:setMarginLeft(pos[1])
		pixel:setMarginTop(pos[2])
		pixel:setBackgroundColor(COMPACT_BORDER_PROGRESS_COLOR)
		pixel:setVisible(false)

		panel.borderPixels[i] = pixel
	end

	panel:updateLayout()
end

local function updateCompactBorderProgress(panel, percent)
	if not panel or panel:isDestroyed() then
		return
	end

	local _, borderSize = getProficiencyProgressRingSpec(panel)

	if not borderSize then
		return
	end

	ensureBorderPixels(panel)

	local pixels = panel.borderPixels

	if not pixels then
		return
	end

	local p = math.max(0, math.min(100, tonumber(percent) or 0))

	if panel:getId() == "proficiencyButtonLargeProgress" then
		local steps = LARGE_BORDER_STEP_COUNT
		local visibleSteps = math.floor(steps * p / 100)

		if visibleSteps < 0 then
			visibleSteps = 0
		elseif steps < visibleSteps then
			visibleSteps = steps
		end

		for i = 1, borderSize do
			local step = math.ceil(i / 2)

			pixels[i]:setVisible(step <= visibleSteps)
		end
	else
		local visiblePixels = math.floor(borderSize * p / 100)

		if visiblePixels < 0 then
			visiblePixels = 0
		elseif borderSize < visiblePixels then
			visiblePixels = borderSize
		end

		for i = 1, borderSize do
			pixels[i]:setVisible(i <= visiblePixels)
		end
	end
end

local PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS = {
	"defaultOnTop",
	"parallelOnTop",
	"defaultOnBottom",
	"parallelOnBottom",
	"defaultOnLeft",
	"parallelOnLeft",
	"defaultOnRight",
	"parallelOnRight"
}
local PROFICIENCY_COMPACT_LAYOUT_IDS = {
	"compactOnTop",
	"compactOnBottom",
	"compactOnLeft",
	"compactOnRight"
}
local PROFICIENCY_LARGE_LAYOUT_IDS = {
	"largeOnTop",
	"largeOnBottom",
	"largeOnLeft",
	"largeOnRight"
}
local PROFICIENCY_STATS_LAYOUT_IDS = PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS

local function applyCompactProficiencyWeaponButtonToRoot(root, equipped, srcCompact, srcLarge, pct)
	if not root then
		return
	end

	local btn = root:recursiveGetChildById("proficiencyButtonCompact")

	if btn and btn.setImageSource then
		btn:setImageSource(srcCompact)
	end

	local ring = root:recursiveGetChildById("proficiencyButtonCompactProgress")

	if ring then
		ring:setVisible(equipped)
		updateCompactBorderProgress(ring, equipped and pct or 0)
	end

	local btnL = root:recursiveGetChildById("proficiencyButtonLarge")

	if btnL and btnL.setImageSource then
		btnL:setImageSource(srcLarge)
	end

	local ringL = root:recursiveGetChildById("proficiencyButtonLargeProgress")

	if ringL then
		ringL:setVisible(equipped)
		updateCompactBorderProgress(ringL, equipped and pct or 0)
	end
end

local function applyProficiencyTopBarWidgetsAllLayouts(percent, progressTooltip, showHighlight)
	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_STATS_LAYOUT_IDS) do
				local root = bar:getChildById(layoutId)

				if root then
					local pb = root:recursiveGetChildById("starProgress")

					if pb then
						pb:setPercent(percent)
						pb:setTooltip(progressTooltip)
					end

					local lbl = root:recursiveGetChildById("proficiencyLabel")

					if lbl then
						lbl:setText(percent .. "%")
					end

					local icon = root:recursiveGetChildById("proficiencyIcon")

					if icon then
						icon:setOn(showHighlight)
					end
				end
			end
		end
	end
end

function StatsBar.applyCompactTopProficiencyWeaponButton()
	local equipped = leftHandHasWeaponProficiency()
	local srcCompact = equipped and PROFICIENCY_BUTTON_COMPACT_EQUIPPED or PROFICIENCY_BUTTON_COMPACT_UNEQUIPPED
	local srcLarge = equipped and PROFICIENCY_BUTTON_LARGE_EQUIPPED or PROFICIENCY_BUTTON_LARGE_UNEQUIPPED
	local pct = lastProficiencyCache and lastProficiencyCache.topBarPercent or 0

	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_COMPACT_LAYOUT_IDS) do
				applyCompactProficiencyWeaponButtonToRoot(bar:getChildById(layoutId), equipped, srcCompact, srcLarge, pct)
			end

			for _, layoutId in ipairs(PROFICIENCY_LARGE_LAYOUT_IDS) do
				applyCompactProficiencyWeaponButtonToRoot(bar:getChildById(layoutId), equipped, srcCompact, srcLarge, pct)
			end
		end
	end
end

local function proficiencyServerHighlightOn(flag)
	return flag == true or flag == 1
end

local function applyProficiencyPerkHighlightVisibleToWidgets()
	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					local highlightButton = layoutRoot:recursiveGetChildById("highlightProficiencyButton")

					if highlightButton then
						highlightButton:setVisible(proficiencyPerkHighlightActive)
					end
				end
			end

			for _, layoutId in ipairs(PROFICIENCY_COMPACT_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					local highlightCompact = layoutRoot:recursiveGetChildById("highlightProficiencyButtonCompact")

					if highlightCompact then
						highlightCompact:setVisible(proficiencyPerkHighlightActive)
					end
				end
			end

			for _, layoutId in ipairs(PROFICIENCY_LARGE_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					local highlightLarge = layoutRoot:recursiveGetChildById("highlightProficiencyButtonLarge")

					if highlightLarge then
						highlightLarge:setVisible(proficiencyPerkHighlightActive)
					end
				end
			end
		end
	end

	if modules.game_mainpanel and modules.game_mainpanel.getButton then
		local shortcutBtn = modules.game_mainpanel.getButton("ProciencyButton")

		if shortcutBtn and not shortcutBtn:isDestroyed() then
			local sh = shortcutBtn:recursiveGetChildById("proficiencyShortcutHighlight")

			if sh then
				sh:setVisible(proficiencyPerkHighlightActive)
			end
		end

		if modules.game_mainpanel.refreshOffPanelResizerHighlight then
			modules.game_mainpanel.refreshOffPanelResizerHighlight()
		end
	end
end

local function setProficiencyPerkHighlightVisible(show)
	proficiencyPerkHighlightActive = proficiencyServerHighlightOn(show)

	applyProficiencyPerkHighlightVisibleToWidgets()
end

function StatsBar.resyncProficiencyPerkHighlightWidgets()
	applyProficiencyPerkHighlightVisibleToWidgets()
end

function StatsBar.isProficiencyPerkHighlightVisible()
	return proficiencyPerkHighlightActive
end

function StatsBar.clearProficiencyHighlightUi()
	setProficiencyPerkHighlightVisible(false)

	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					local proficiencyIcon = layoutRoot:recursiveGetChildById("proficiencyIcon")

					if proficiencyIcon then
						proficiencyIcon:setOn(false)
					end
				end
			end
		end
	end
end

function StatsBar.syncProficiencyHighlightWithHandWeapon()
	if not modules.game_inventory or not modules.game_inventory.getWeaponProficiencyHandItem then
		return
	end

	local hand = modules.game_inventory.getWeaponProficiencyHandItem()

	if not hand then
		StatsBar.clearProficiencyHighlightUi()

		return
	end

	local hid = hand:getId()

	if lastProficiencyCache.itemClientId and lastProficiencyCache.itemClientId ~= hid then
		StatsBar.clearProficiencyHighlightUi()

		lastProficiencyCache = {}
	end
end

function StatsBar.applyDefaultTopProficiencyLayout()
	local showPanel = leftHandHasWeaponProficiency()

	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					local panel = layoutRoot:recursiveGetChildById("proficiencyPanel")

					if panel then
						panel:setVisible(showPanel)

						local rowInner = layoutRoot:recursiveGetChildById("topBarProficiencyRowInner")

						if rowInner then
							rowInner:updateLayout()
						end
					end
				end
			end
		end
	end

	if not showPanel then
		StatsBar.clearProficiencyHighlightUi()

		lastProficiencyCache = {}
	end

	StatsBar.applyCompactTopProficiencyWeaponButton()

	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_LARGE_LAYOUT_IDS) do
				local largeRoot = bar:getChildById(layoutId)

				if largeRoot then
					local centerRow = largeRoot:recursiveGetChildById("largeTopCenterRow")

					if centerRow then
						centerRow:updateLayout()
					end
				end
			end
		end
	end
end

local MONK_COMBO_IMAGE_EMPTY = "/images/game/topbar/icon-combopoint-empty"
local MONK_COMBO_IMAGE_FILLED = "/images/game/topbar/icon-combopoint-filled"
local MONK_SERENE_IMAGE_OFF = "/images/game/topbar/icon-serene-off"
local MONK_SERENE_IMAGE_ON = "/images/game/topbar/icon-serene-on"

local function var_0_115(root, monkPanelId)
	return root:recursiveGetChildById("topBarMonkCombo" .. monkPanelId) or root:recursiveGetChildById("topBarMonkLargeCombo" .. monkPanelId) or root:recursiveGetChildById("topBarMonkCompactCombo" .. monkPanelId)
end

local function monkPanel(arg_104_0)
	return arg_104_0:recursiveGetChildById("topBarMonkSereneIcon") or arg_104_0:recursiveGetChildById("topBarMonkLargeSereneIcon") or arg_104_0:recursiveGetChildById("topBarMonkCompactSereneIcon")
end

local function statsBarApplyMonkComboSereneToRoot(arg_105_0, arg_105_1, player)
	if not arg_105_0 then
		return
	end

	local var_105_0 = arg_105_0:recursiveGetChildById(arg_105_1)

	if not var_105_0 then
		return
	end

	if not player or not g_game.isOnline() or not player.isMonk or not player:isMonk() then
		var_105_0:hide()

		return
	end

	var_105_0:show()

	local harmony = 0

	if player.getHarmony then
		harmony = math.min(5, math.max(0, player:getHarmony()))
	end

	for i = 1, 5 do
		local w = var_0_115(var_105_0, i)

		if w then
			w:setImageSource(i <= harmony and MONK_COMBO_IMAGE_FILLED or MONK_COMBO_IMAGE_EMPTY)
		end
	end

	local sereneIcon = monkPanel(var_105_0)

	if sereneIcon and player.isSerene then
		sereneIcon:setImageSource(player:isSerene() and MONK_SERENE_IMAGE_ON or MONK_SERENE_IMAGE_OFF)
	end
end

function StatsBar.applyDefaultTopMonkComboSereneLayout()
	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil

	for _, bar in pairs(statsBars) do
		if bar then
			for _, layoutId in ipairs(PROFICIENCY_DEFAULT_PARALLEL_LAYOUT_IDS) do
				local layoutRoot = bar:getChildById(layoutId)

				if layoutRoot then
					statsBarApplyMonkComboSereneToRoot(layoutRoot, "topBarMonkComboSerene", player)

					local rowInner = layoutRoot:recursiveGetChildById("topBarProficiencyRowInner")

					if rowInner then
						rowInner:updateLayout()
					end
				end
			end

			for _, layoutId in ipairs(PROFICIENCY_LARGE_LAYOUT_IDS) do
				local largeRoot = bar:getChildById(layoutId)

				if largeRoot then
					statsBarApplyMonkComboSereneToRoot(largeRoot, "topBarMonkComboSereneLarge", player)

					local centerRow = largeRoot:recursiveGetChildById("largeTopCenterRow")

					if centerRow then
						centerRow:updateLayout()
					end
				end
			end

			for _, layoutId in ipairs(PROFICIENCY_COMPACT_LAYOUT_IDS) do
				local compactRoot = bar:getChildById(layoutId)

				if compactRoot then
					statsBarApplyMonkComboSereneToRoot(compactRoot, "topBarMonkComboSereneCompact", player)

					local centerRow = compactRoot:recursiveGetChildById("compactTopCenterRow")

					if centerRow then
						centerRow:updateLayout()
					end
				end
			end
		end
	end
end

function StatsBar.init()
	statsBarTop = modules.game_interface.getGameTopStatsBar()
	statsBarBottom = modules.game_interface.getGameBottomStatsBar()
	gameLeftStatsBar = modules.game_interface.getGameLeftStatsBar and modules.game_interface.getGameLeftStatsBar()
	gameRightStatsBar = modules.game_interface.getGameRightStatsBar and modules.game_interface.getGameRightStatsBar()
	statsBars = {
		statsBarTop = statsBarTop,
		statsBarBottom = statsBarBottom,
		statsBarLeft = gameLeftStatsBar,
		statsBarRight = gameRightStatsBar
	}

	if not statsBarTop then
		return
	end

	if not statsBarBottom then
		return
	end

	for _, statBar in pairs(statsBars) do
		statBar = createStatsBarWidgets(statBar)
	end

	statsBarDeepInfo = {
		onExperienceChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onLevelChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onHealthChange = StatsBar.scheduleCurrentStatsBarHealthInfo,
		onManaChange = StatsBar.scheduleCurrentStatsBarManaInfo,
		onManaShieldChange = StatsBar.scheduleCurrentStatsBarManaInfo,
		onMagicLevelChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onBaseMagicLevelChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onSkillChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onBaseSkillChange = StatsBar.scheduleCurrentStatsBarDeepInfo,
		onStatesChange = StatsBar.reloadCurrentStatsBarQuickInfo_state,
		onBakragoreIconChange = function()
			refreshBakragoreTaintIcon()
		end,
		onRegenerationChange = StatsBar.onRegenerationChange,
		onHarmonyChange = StatsBar.applyDefaultTopMonkComboSereneLayout,
		onSereneChange = StatsBar.applyDefaultTopMonkComboSereneLayout,
		onVocationChange = StatsBar.applyDefaultTopMonkComboSereneLayout
	}

	StatsBar.hideAll()
	connect(LocalPlayer, statsBarDeepInfo)
	connect(g_things, statsBarThingsHandlers)
	connect(g_game, {
		onGameStart = StatsBar.OnGameStart,
		onGameEnd = StatsBar.OnGameEnd
	})
	StatsBar.applyDefaultTopProficiencyLayout()
	StatsBar.applyDefaultTopMonkComboSereneLayout()

	if g_game.isOnline() then
		statsBarConnectInventoryPlayer()
	end
end

function StatsBar.hideAll()
	for _, bar in pairs(statsBars) do
		if bar then
			local var_109_0 = var_0_35(bar)

			for _, placement in pairs(statsBarsPlacements) do
				for dimension, _ in pairs(statsBarsDimensions) do
					local key = tostring(dimension):lower() .. "On" .. placement

					if bar[key] then
						if bar[key].skills then
							bar[key].skills:destroyChildren()

							if var_109_0 then
								bar[key].skills:setWidth(0)
							else
								bar[key].skills:setHeight(0)
							end
						end

						if var_109_0 then
							bar[key]:setWidth(0)
						else
							bar[key]:setHeight(0)
						end

						bar[key]:hide()
					end
				end
			end

			if var_109_0 then
				bar:setWidth(0)
			else
				bar:setHeight(0)
			end
		end
	end
end

function StatsBar.destroyAllIcons()
	for _, bar in pairs(statsBars) do
		if bar then
			for _, placement in pairs(statsBarsPlacements) do
				for dimension, _ in pairs(statsBarsDimensions) do
					local key = tostring(dimension):lower() .. "On" .. placement

					if bar[key] and bar[key].skills then
						local iconsPanel = bar[key]:recursiveGetChildById("icons")

						if iconsPanel then
							iconsPanel:destroyChildren()
						end
					end
				end
			end

			if var_0_35(bar) then
				bar:setWidth(0)
			else
				bar:setHeight(0)
			end
		end
	end
end

function StatsBar.destroyAllBars()
	for _, bar in pairs(statsBars) do
		if bar then
			bar:destroy()
		end
	end
end

function StatsBar.terminate()
	StatsBar.cancelPendingRefreshes()
	statsBarDisconnectInventoryPlayer()
	disconnect(LocalPlayer, statsBarDeepInfo)
	disconnect(g_things, statsBarThingsHandlers)
	disconnect(g_game, {
		onGameStart = StatsBar.OnGameStart,
		onGameEnd = StatsBar.OnGameEnd
	})
	StatsBar.destroyAllBars()
end

function StatsBar.onRegenerationChange(localPlayer, now, old)
	if now == old then
		return
	end

	refreshHungryConditionIcon()
end

function StatsBar.onHungryChange(regenerationTime, alert)
	refreshHungryConditionIcon()
end

function StatsBar.switchCurrentLayout()
	if table.empty(lastProficiencyCache) then
		return
	end

	StatsBar.onUpdateProficiencyData(lastProficiencyCache.itemCache, lastProficiencyCache.hasUnnusedPerk, lastProficiencyCache.thingType)
end

function StatsBar.onUpdateProficiencyData(itemCache, hasHighlight, thingType)
	if not thingType or not itemCache then
		StatsBar.clearProficiencyHighlightUi()
		StatsBar.applyDefaultTopProficiencyLayout()

		return
	end

	local PD = ProficiencyData

	if not PD and modules.game_proficiency then
		PD = modules.game_proficiency.ProficiencyData
	end

	if not modules.game_proficiency or not PD then
		StatsBar.clearProficiencyHighlightUi()
		StatsBar.applyDefaultTopProficiencyLayout()

		return
	end

	local perkLanes = PD:getPerkLaneCount(thingType:getProficiencyId())
	local maxAvailableLevel = perkLanes + 2
	local floorLastPerk = perkLanes > 0 and PD:getMaxExperienceByLevel(perkLanes, thingType) or nil
	local percent = PD:getTopBarProficiencyPercent(itemCache.exp, thingType)
	local maxLevelExperience
	local progressTooltip

	if floorLastPerk and floorLastPerk <= itemCache.exp then
		local maxLevelExperience = PD:getMaxExperience(perkLanes, thingType)

		progressTooltip = string.format("Proficiency Progress: %s / %s", comma_value(itemCache.exp), comma_value(maxLevelExperience))
	else
		local weaponLevel = PD:getCurrentLevelByExp(thingType, itemCache.exp, true)
		local maxLevelExperience = PD:getMaxExperienceByLevel(math.min(maxAvailableLevel, weaponLevel + 1), thingType)

		progressTooltip = string.format("Proficiency Progress: %s / %s", comma_value(itemCache.exp), comma_value(maxLevelExperience))
	end

	local showHighlight = proficiencyServerHighlightOn(hasHighlight)

	applyProficiencyTopBarWidgetsAllLayouts(percent, progressTooltip, showHighlight)

	for _, bar in pairs(statsBars) do
		if bar then
			local compactRing = bar:recursiveGetChildById("proficiencyButtonCompactProgress")

			if compactRing then
				updateCompactBorderProgress(compactRing, percent)
				compactRing:setTooltip(progressTooltip)
			end

			local largeRing = bar:recursiveGetChildById("proficiencyButtonLargeProgress")

			if largeRing then
				updateCompactBorderProgress(largeRing, percent)
				largeRing:setTooltip(progressTooltip)
			end
		end
	end

	setProficiencyPerkHighlightVisible(showHighlight)

	lastProficiencyCache = {
		itemCache = itemCache,
		hasUnnusedPerk = showHighlight,
		thingType = thingType,
		itemClientId = thingType:getId(),
		topBarPercent = percent
	}

	StatsBar.applyDefaultTopProficiencyLayout()
end
