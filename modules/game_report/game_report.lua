local gameReportWidget
local var_0_1
local uIButtonWidget
local var_0_3
local newPlayerExerciseSelectorWidget
local var_0_5
local var_0_6
local var_0_7 = 0
local reportId
local var_0_9 = {}
local var_0_10
local var_0_11 = false
local var_0_12 = false
local visible = false
local var_0_14 = false
local var_0_15
local var_0_16
local var_0_17 = false
local var_0_18 = false
local var_0_19 = 0
local var_0_20 = 1
local var_0_21 = "#484848"
local var_0_22 = "#414141"
local var_0_23 = "#585858"
local var_0_24 = "#a0a0ff"
local var_0_25 = "#60f8f8"
local var_0_26 = "#ffffff"
local var_0_27 = "#909090"
local var_0_28 = "#C0C0C0"
local REPORT_STATUS_COLORS = {
	closed = "#d33c3c",
	open = "#44ad25"
}
local DEFAULT_SUPPORT_SENDER = "Support"
local REPORT_SHORTCUT_HIGHLIGHT_ID = "reportShortcutHighlight"
local REPORT_MAP_HIGHLIGHT_ID = "reportMapHighlight"
local REWARD_MAP_HIGHLIGHT_ID = "rewardMapHighlight"
local REPORT_MAP_BUTTON_ID = "reportMapButton"
local NEW_PLAYER_REWARD_MAP_BUTTON_ID = "newPlayerRewardMapButton"
local var_0_36 = {
	3,
	1,
	2,
	4,
	5,
	6,
	7,
	8
}
local EXERCISE_WEAPON_CHOICES = {
	{
		name = "Sword",
		id = 63298
	},
	{
		name = "Axe",
		id = 63299
	},
	{
		name = "Club",
		id = 63300
	},
	{
		name = "Bow",
		id = 63301
	},
	{
		name = "Rod",
		id = 63302
	},
	{
		name = "Wand",
		id = 63303
	},
	{
		name = "Shield",
		id = 63304
	},
	{
		name = "Wraps",
		id = 63305
	}
}
local var_0_38 = 36
local var_0_39 = 6
local var_0_40 = 7
local var_0_41 = 6
local var_0_42 = {
	x = 2,
	y = 2
}
local var_0_43 = {
	x = 3,
	y = 3
}
local var_0_44 = 1.3636363636363635
local var_0_45 = {
	image = "/images/animations/button-highlight-22x22",
	size = 22
}
local var_0_46 = {
	image = "/images/animations/button-highlight-38x38",
	size = 38
}
local var_0_47 = {
	"sideCreatedCaption",
	"sideCreatedDate",
	"sideCreatedTime",
	"sideClosedCaption",
	"sideClosedDate",
	"sideClosedTime",
	"sideStatusCaption",
	"sideStatusValue"
}
local var_0_48 = {
	"sideGotoPlayerButton",
	"sideGotoPositionButton",
	"sideCloseTicketButton"
}
local var_0_49 = {
	"reportListTop",
	"reportListHeaderSeparator",
	"reportListBackground",
	"reportList",
	"reportListScrollBar"
}
local var_0_50
local var_0_51

local function var_0_52(arg_1_0)
	return arg_1_0 and not arg_1_0:isDestroyed()
end

local function var_0_53(arg_2_0)
	return gameReportWidget and gameReportWidget:recursiveGetChildById(arg_2_0) or nil
end

local function var_0_54()
	return var_0_53("reportList")
end

local function var_0_55()
	return var_0_52(gameReportWidget) and gameReportWidget:isVisible()
end

local function var_0_56(arg_5_0, visible)
	for unusedValue, entry in ipairs(arg_5_0) do
		local var_5_0 = var_0_53(entry)

		if var_5_0 then
			var_5_0:setVisible(visible)
		end
	end
end

local function var_0_57(arg_6_0)
	if var_0_52(arg_6_0) then
		arg_6_0:destroy()
	end

	return nil
end

local function var_0_58(arg_7_0)
	return tostring(arg_7_0 or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function var_0_59(arg_8_0)
	return tonumber(arg_8_0) or 0
end

local function var_0_60(arg_9_0)
	return var_0_59(arg_9_0 and (arg_9_0.hasUnread or arg_9_0.unread)) == 1
end

local function var_0_61(arg_10_0)
	for unusedValue, entry in ipairs(arg_10_0 or {}) do
		if var_0_60(entry) then
			return true
		end
	end

	return false
end

local function var_0_62(arg_11_0)
	local var_11_0 = {}

	for key, entry in pairs(arg_11_0 or {}) do
		if type(entry) == "table" then
			var_11_0[#var_11_0 + 1] = {
				index = var_0_59(key),
				entry = entry
			}
		end
	end

	table.sort(var_11_0, function(arg_12_0, arg_12_1)
		return arg_12_0.index < arg_12_1.index
	end)

	return var_11_0
end

local function unusedValue(textValue)
	textValue = tostring(textValue or ""):lower()

	return REPORT_STATUS_COLORS[textValue] or var_0_28
end

local function formatReportStatus(textValue)
	textValue = tostring(textValue or ""):lower()

	if textValue == "closed" then
		return tr("Closed"), REPORT_STATUS_COLORS.closed
	end

	if textValue == "open" then
		return tr("Open"), REPORT_STATUS_COLORS.open
	end

	if textValue == "" then
		return "", var_0_28
	end

	return textValue:sub(1, 1):upper() .. textValue:sub(2), var_0_28
end

local function var_0_65(arg_15_0)
	local var_15_0 = var_0_59(arg_15_0)

	return var_15_0 > 0 and os.date("%H:%M:%S", var_15_0) or os.date("%H:%M:%S")
end

local function var_0_66(arg_16_0)
	local var_16_0 = var_0_59(arg_16_0)

	if var_16_0 <= 0 then
		return ""
	end

	return string.format("%s %d %s", os.date("%b", var_16_0), tonumber(os.date("%d", var_16_0)), os.date("%Y", var_16_0))
end

local function var_0_67(arg_17_0)
	local var_17_0 = var_0_59(arg_17_0)

	return var_17_0 > 0 and os.date("%H:%M:%S", var_17_0) or ""
end

local function var_0_68(textValue)
	textValue = tostring(textValue or ""):gsub("%s+", "")

	if textValue == "" or textValue == "nil" then
		return ""
	end

	local var_18_0, var_18_1, var_18_2 = textValue:match("^(%-?%d+),(%-?%d+),(%-?%d+)$")

	return var_18_0 and string.format("%s,%s,%s", var_18_0, var_18_1, var_18_2) or ""
end

local function var_0_69(textValue, arg_19_1)
	textValue = tostring(textValue or ""):gsub("%s+", " ")
	textValue = var_0_58(textValue)
	arg_19_1 = arg_19_1 or 48

	if arg_19_1 < #textValue then
		return textValue:sub(1, arg_19_1 - 3) .. "..."
	end

	return textValue
end

local function var_0_70(arg_20_0)
	if var_0_7 == var_0_20 then
		local var_20_0 = arg_20_0.playerName or ""

		if var_20_0 == "" then
			var_20_0 = arg_20_0.targetName or ""
		end

		return var_20_0
	end

	local var_20_1 = arg_20_0.comment or ""

	if var_20_1 == "" then
		var_20_1 = arg_20_0.reason or ""
	end

	return var_0_69(var_20_1, 48)
end

local function var_0_71(parentWidget, arg_21_1, arg_21_2)
	if not var_0_52(parentWidget) then
		return nil
	end

	local var_21_0 = parentWidget:recursiveGetChildById(arg_21_1)

	if var_21_0 then
		return var_21_0
	end

	local uIWidgetWidget = g_ui.createWidget("UIWidget", parentWidget)

	if not uIWidgetWidget then
		return nil
	end

	local var_21_2 = arg_21_2 and arg_21_2.size or 22

	uIWidgetWidget:setId(arg_21_1)
	uIWidgetWidget:setSize({
		width = var_21_2,
		height = var_21_2
	})
	uIWidgetWidget:setPhantom(true)
	uIWidgetWidget:setClipping(false)
	uIWidgetWidget:setImageSource(arg_21_2 and arg_21_2.image or var_0_45.image)
	uIWidgetWidget:breakAnchors()
	uIWidgetWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	uIWidgetWidget:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)

	return uIWidgetWidget
end

local function var_0_72(arg_22_0)
	if arg_22_0 and not var_0_18 then
		var_0_18 = g_mouse.pushCursor("default")
	elseif not arg_22_0 and var_0_18 then
		g_mouse.popCursor("default")

		var_0_18 = false
	end
end

local function var_0_73()
	local var_23_0 = var_0_71(var_0_1, REPORT_SHORTCUT_HIGHLIGHT_ID, var_0_45)

	if var_23_0 then
		var_23_0:setVisible(visible)
	end

	if var_0_52(uIButtonWidget) then
		if not visible then
			var_0_72(false)
		end

		uIButtonWidget:setVisible(visible)

		local var_23_1 = var_0_71(uIButtonWidget, REPORT_MAP_HIGHLIGHT_ID, var_0_46)

		if var_23_1 then
			var_23_1:setVisible(visible)
		end

		if visible then
			uIButtonWidget:raise()
		end
	end

	if modules.game_mainpanel and modules.game_mainpanel.refreshOffPanelResizerHighlight then
		modules.game_mainpanel.refreshOffPanelResizerHighlight()
	end
end

local function var_0_74(arg_24_0, arg_24_1)
	visible = arg_24_0 == true or arg_24_0 == 1

	if visible then
		local var_24_0 = var_0_59(arg_24_1)

		if var_24_0 > 0 then
			var_0_15 = var_24_0
		end
	else
		var_0_15 = nil
	end

	var_0_73()
end

local function var_0_75()
	var_0_74(false)
end

local function var_0_76()
	local game_interface = modules.game_interface

	return game_interface and game_interface.getMapPanel and game_interface.getMapPanel() or nil
end

local function var_0_77(arg_27_0)
	local paddingRect = arg_27_0:getPaddingRect()
	local var_27_1 = paddingRect and paddingRect.width or 0
	local var_27_2 = paddingRect and paddingRect.height or 0

	if var_27_1 <= 0 or var_27_2 <= 0 or not arg_27_0:isKeepAspectRatioEnabled() then
		return 0, 0
	end

	local var_27_3 = var_0_44
	local visibleDimension = arg_27_0:getVisibleDimension()

	if visibleDimension and visibleDimension.width and visibleDimension.height and visibleDimension.height > 0 then
		var_27_3 = visibleDimension.width / visibleDimension.height
	end

	local var_27_5 = var_27_1
	local var_27_6 = math.floor(var_27_5 / var_27_3 + 0.5)

	if var_27_2 < var_27_6 then
		var_27_6 = var_27_2
		var_27_5 = math.floor(var_27_6 * var_27_3 + 0.5)
	end

	return math.max(0, math.floor((var_27_1 - var_27_5) / 2)), math.max(0, math.floor((var_27_2 - var_27_6) / 2))
end

local function var_0_78(arg_28_0, arg_28_1)
	if not var_0_52(arg_28_0) then
		return
	end

	local var_28_0 = var_0_76()

	if not var_0_52(var_28_0) then
		return
	end

	local var_28_1, var_28_2 = var_0_77(var_28_0)

	arg_28_0:breakAnchors()
	arg_28_0:addAnchor(AnchorRight, "parent", AnchorRight)
	arg_28_0:addAnchor(AnchorBottom, "parent", AnchorBottom)
	arg_28_0:setMarginRight(var_28_1 + var_0_40 + (arg_28_1 or 0))
	arg_28_0:setMarginBottom(var_28_2 + var_0_41)
end

local function var_0_79()
	return var_0_14 and var_0_52(var_0_3)
end

local function var_0_80()
	local var_30_0 = var_0_79() and var_0_38 + var_0_39 or 0

	var_0_78(var_0_3, 0)
	var_0_78(uIButtonWidget, var_30_0)

	if var_0_52(var_0_3) then
		var_0_3:setVisible(var_0_14)

		local var_30_1 = var_0_71(var_0_3, REWARD_MAP_HIGHLIGHT_ID, var_0_46)

		if var_30_1 then
			var_30_1:setVisible(var_0_14)
		end

		if var_0_14 then
			var_0_3:raise()
		end
	end

	var_0_73()
end

local function var_0_81()
	var_0_80()
end

local function var_0_82()
	local var_32_0 = var_0_76()

	if var_0_17 and var_0_52(var_32_0) then
		disconnect(var_32_0, {
			onGeometryChange = var_0_81,
			onZoomChange = var_0_81
		})

		var_0_17 = false
	end

	var_0_72(false)

	uIButtonWidget = var_0_57(uIButtonWidget)
	var_0_3 = var_0_57(var_0_3)
end

local function var_0_83()
	local parentWidget = var_0_76()

	if not var_0_52(parentWidget) then
		return
	end

	if var_0_52(uIButtonWidget) and uIButtonWidget:getParent() == parentWidget then
		var_0_80()

		return
	end

	var_0_82()

	uIButtonWidget = g_ui.createWidget("UIButton", parentWidget)

	if not uIButtonWidget then
		return
	end

	uIButtonWidget:setId(REPORT_MAP_BUTTON_ID)
	uIButtonWidget:setSize({
		width = var_0_38,
		height = var_0_38
	})
	uIButtonWidget:setImageSource("/images/ui/button-gold-up")
	uIButtonWidget:setImageBorder(5)
	uIButtonWidget:setTooltip(tr("Open Report"))
	uIButtonWidget:setFocusable(false)
	uIButtonWidget:setClipping(false)
	uIButtonWidget:setVisible(false)
	uIButtonWidget:setIcon("/images/icons_big/icon-friends-friendlist")
	uIButtonWidget:setIconSize({
		height = 32,
		width = 32
	})
	uIButtonWidget:setIconOffset(var_0_42)

	function uIButtonWidget.onHoverChange(arg_34_0, arg_34_1)
		var_0_72(arg_34_1 and arg_34_0:isEnabled() and arg_34_0:isVisible())
	end

	function uIButtonWidget.onMousePress(arg_35_0)
		arg_35_0:setImageSource("/images/ui/button-gold-down")
		arg_35_0:setIconOffset(var_0_43)

		return true
	end

	function uIButtonWidget.onMouseRelease(arg_36_0, arg_36_1, arg_36_2)
		arg_36_0:setImageSource("/images/ui/button-gold-up")
		arg_36_0:setIconOffset(var_0_42)

		if arg_36_2 == MouseLeftButton and arg_36_0:containsPoint(arg_36_1) then
			show()
		end

		return true
	end

	if not var_0_17 then
		connect(parentWidget, {
			onGeometryChange = var_0_81,
			onZoomChange = var_0_81
		})

		var_0_17 = true
	end

	var_0_80()
end

local function var_0_84(arg_37_0)
	local var_37_0 = var_0_36[tonumber(arg_37_0) or 0] or 0

	if var_37_0 < 1 or not g_game.sendRewardExercise then
		return
	end

	g_game.sendRewardExercise(var_37_0)

	var_0_14 = false

	var_0_80()
end

local function var_0_85(numericValue)
	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 or not g_things or not g_things.getThingType then
		return
	end

	if g_things.isValidDatId and not g_things.isValidDatId(numericValue, ThingCategoryItem) then
		return
	end

	local thingType = g_things.getThingType(numericValue, ThingCategoryItem)

	if thingType then
		thingType:prefetchSpriteSheetsForPreview(0)
		thingType:prefetchTexturePhase(0)
	end
end

local function var_0_86(arg_39_0)
	local thingId = arg_39_0 and arg_39_0.id or 0

	if thingId > 0 and g_things and g_things.getThingType then
		local thingType = g_things.getThingType(thingId, ThingCategoryItem)

		if thingType and thingType.getName then
			local name = thingType:getName()

			if name and name ~= "" then
				return name
			end
		end
	end

	return tr(arg_39_0 and arg_39_0.name or "")
end

local function var_0_87()
	var_0_5 = nil

	if var_0_52(newPlayerExerciseSelectorWidget) then
		if g_modalManager then
			g_modalManager.hide(newPlayerExerciseSelectorWidget)
		end

		newPlayerExerciseSelectorWidget:destroy()
	end

	newPlayerExerciseSelectorWidget = nil
end

local function var_0_88(numericValue)
	numericValue = tonumber(numericValue) or 0
	var_0_5 = numericValue

	if not var_0_52(newPlayerExerciseSelectorWidget) then
		return
	end

	local elements = newPlayerExerciseSelectorWidget:getChildById("elements")

	if var_0_52(elements) then
		for unusedValue, child in ipairs(elements:getChildren()) do
			if child.setChecked then
				child:setChecked((tonumber(child.choiceId) or 0) == numericValue)
			end
		end
	end

	local selectButton = newPlayerExerciseSelectorWidget:getChildById("selectButton")

	if var_0_52(selectButton) then
		selectButton:setEnabled(numericValue > 0)

		if numericValue > 0 then
			selectButton:focus()
		end
	end
end

function cancelNewPlayerExercise()
	var_0_87()
end

function confirmNewPlayerExercise()
	local numericValue = tonumber(var_0_5) or 0

	var_0_87()

	if numericValue >= 1 and numericValue <= #EXERCISE_WEAPON_CHOICES then
		var_0_84(numericValue)
	end
end

local function var_0_89()
	var_0_87()

	if modules.game_banners and modules.game_banners.hidePreviewBanner then
		modules.game_banners.hidePreviewBanner(true)
	end

	newPlayerExerciseSelectorWidget = g_ui.createWidget("NewPlayerExerciseSelector", rootWidget)

	if not var_0_52(newPlayerExerciseSelectorWidget) then
		return
	end

	newPlayerExerciseSelectorWidget:setText("")

	local elements = newPlayerExerciseSelectorWidget:getChildById("elements")
	local var_44_1 = 64
	local var_44_2 = 64
	local var_44_3 = 5
	local var_44_4 = 4

	for index, entry in ipairs(EXERCISE_WEAPON_CHOICES) do
		local newPlayerExerciseButtonWidget = g_ui.createWidget("NewPlayerExerciseButton", elements)

		if var_0_52(newPlayerExerciseButtonWidget) then
			newPlayerExerciseButtonWidget:setId("choice" .. index)

			newPlayerExerciseButtonWidget.choiceId = index

			local var_44_6 = (index - 1) % var_44_4
			local var_44_7 = math.floor((index - 1) / var_44_4)
			local var_44_8 = math.min(var_44_4, #EXERCISE_WEAPON_CHOICES - var_44_7 * var_44_4)
			local var_44_9 = var_44_8 * var_44_1 + (var_44_8 - 1) * var_44_3
			local width = math.floor(((elements:getWidth() > 0 and elements:getWidth() or 280) - var_44_9) / 2)

			newPlayerExerciseButtonWidget:addAnchor(AnchorTop, "parent", AnchorTop)
			newPlayerExerciseButtonWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
			newPlayerExerciseButtonWidget:setMarginTop(var_44_7 * (var_44_2 + var_44_3))
			newPlayerExerciseButtonWidget:setMarginLeft(width + var_44_6 * (var_44_1 + var_44_3))
			newPlayerExerciseButtonWidget:setTooltip(var_0_86(entry))

			local item = newPlayerExerciseButtonWidget:getChildById("item")

			if var_0_52(item) and entry.id > 0 then
				item:setItemId(entry.id)
				item:setVisible(true)
				var_0_85(entry.id)
			end

			function newPlayerExerciseButtonWidget.onClick()
				var_0_88(index)
			end
		end
	end

	local cancelButton = newPlayerExerciseSelectorWidget:getChildById("cancelButton")

	if var_0_52(cancelButton) then
		function cancelButton.onClick()
			cancelNewPlayerExercise()
		end
	end

	local selectButton = newPlayerExerciseSelectorWidget:getChildById("selectButton")

	if var_0_52(selectButton) then
		selectButton:setEnabled(false)

		function selectButton.onClick()
			confirmNewPlayerExercise()
		end
	end

	function newPlayerExerciseSelectorWidget.onEscape()
		cancelNewPlayerExercise()

		return true
	end

	function newPlayerExerciseSelectorWidget.onEnter()
		confirmNewPlayerExercise()

		return true
	end

	newPlayerExerciseSelectorWidget:show()
	newPlayerExerciseSelectorWidget:raise()
	newPlayerExerciseSelectorWidget:focus()

	if g_modalManager then
		g_modalManager.show(newPlayerExerciseSelectorWidget)
	end
end

local function var_0_90()
	local parentWidget = var_0_76()

	if not var_0_52(parentWidget) then
		return
	end

	if var_0_52(var_0_3) and var_0_3:getParent() == parentWidget then
		var_0_80()

		return
	end

	var_0_3 = var_0_57(var_0_3)
	var_0_3 = g_ui.createWidget("UIButton", parentWidget)

	if not var_0_3 then
		return
	end

	var_0_3:setId(NEW_PLAYER_REWARD_MAP_BUTTON_ID)
	var_0_3:setSize({
		width = var_0_38,
		height = var_0_38
	})
	var_0_3:setImageSource("/images/ui/button-gold-up")
	var_0_3:setImageBorder(5)
	var_0_3:setTooltip(tr("Claim New Player Reward"))
	var_0_3:setFocusable(false)
	var_0_3:setClipping(false)
	var_0_3:setVisible(false)
	var_0_3:setIcon("/images/icons_big/icon-reward-new-player")
	var_0_3:setIconSize({
		height = 32,
		width = 32
	})
	var_0_3:setIconOffset(var_0_42)

	function var_0_3.onHoverChange(arg_51_0, arg_51_1)
		var_0_72(arg_51_1 and arg_51_0:isEnabled() and arg_51_0:isVisible())
	end

	function var_0_3.onMousePress(arg_52_0)
		arg_52_0:setImageSource("/images/ui/button-gold-down")
		arg_52_0:setIconOffset(var_0_43)

		return true
	end

	function var_0_3.onMouseRelease(arg_53_0, arg_53_1, arg_53_2)
		arg_53_0:setImageSource("/images/ui/button-gold-up")
		arg_53_0:setIconOffset(var_0_42)

		if arg_53_2 == MouseLeftButton and arg_53_0:containsPoint(arg_53_1) then
			var_0_89()
		end

		return true
	end

	var_0_80()
end

local function var_0_91()
	var_0_6 = var_0_57(var_0_6)
end

local function var_0_92()
	var_0_56(var_0_48, false)
end

local function var_0_93(arg_56_0, arg_56_1)
	if not arg_56_0 then
		return
	end

	arg_56_0:breakAnchors()
	arg_56_0:addAnchor(AnchorBottom, arg_56_1, arg_56_1 == "parent" and AnchorBottom or AnchorTop)
	arg_56_0:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	arg_56_0:setMarginBottom(arg_56_1 == "parent" and 8 or 4)
end

local function var_0_94(arg_57_0, arg_57_1, arg_57_2)
	local var_57_0 = {}

	if arg_57_0 then
		var_57_0[#var_57_0 + 1] = "sideCloseTicketButton"
	end

	if arg_57_1 then
		var_57_0[#var_57_0 + 1] = "sideGotoPositionButton"
	end

	if arg_57_2 then
		var_57_0[#var_57_0 + 1] = "sideGotoPlayerButton"
	end

	for index, entry in ipairs(var_57_0) do
		var_0_93(var_0_53(entry), index == 1 and "parent" or var_57_0[index - 1])
	end
end

local function var_0_95(arg_58_0)
	local var_58_0 = var_0_53("sideGotoPlayerButton")
	local var_58_1 = var_0_53("sideGotoPositionButton")
	local var_58_2 = var_0_53("sideCloseTicketButton")

	if not var_58_0 or not var_58_1 or not var_58_2 then
		return
	end

	if var_0_7 ~= var_0_20 or not arg_58_0 then
		var_0_92()

		return
	end

	local textValue = tostring(arg_58_0.status or ""):lower() == "open"

	var_58_2:setVisible(textValue)

	local var_58_4 = var_0_58(arg_58_0.targetName)
	local visible = var_58_4 ~= ""

	var_58_0:setVisible(visible)

	var_58_0.gotoCommand = visible and "/goto " .. var_58_4 or nil

	local var_58_6 = var_0_68(arg_58_0.mapPosition)
	local var_58_7 = var_58_6 ~= ""

	var_58_1:setVisible(var_58_7)

	var_58_1.gotoCommand = var_58_7 and "/gotopos " .. var_58_6 or nil

	var_0_94(textValue, var_58_7, visible)
end

local function var_0_96()
	local var_59_0 = var_0_53("sideTitle")

	if var_59_0 then
		var_59_0:setText(tr("Select a ticket"))
		var_59_0:setColor(var_0_27)
	end

	for unusedValue, entry in ipairs(var_0_47) do
		local var_59_1 = var_0_53(entry)

		if var_59_1 then
			var_59_1:setVisible(false)

			if var_59_1.setText and not entry:find("Caption$") then
				var_59_1:setText("")
			end
		end
	end

	var_0_92()
end

local function var_0_97(arg_60_0, arg_60_1, arg_60_2, visible)
	local var_60_0 = var_0_53(arg_60_0)
	local var_60_1 = var_0_53(arg_60_1)

	if var_60_0 then
		var_60_0:setVisible(visible)
		var_60_0:setText(visible and var_0_66(arg_60_2) or "")
	end

	if var_60_1 then
		var_60_1:setVisible(visible)
		var_60_1:setText(visible and var_0_67(arg_60_2) or "")
	end
end

local function var_0_98(arg_61_0)
	local var_61_0 = var_0_53("sideTitle")

	if not var_61_0 then
		return
	end

	if not arg_61_0 then
		var_0_96()

		return
	end

	local var_61_1 = var_0_59(arg_61_0.id)

	var_61_0:setText(string.format("#%d", var_61_1))
	var_61_0:setColor(var_0_27)

	local var_61_2 = var_0_59(arg_61_0.createdAt)
	local var_61_3 = var_0_59(arg_61_0.closedAt)
	local textValue = tostring(arg_61_0.status or ""):lower() == "closed" and var_61_3 > 0
	local var_61_5 = var_0_53("sideCreatedCaption")

	if var_61_5 then
		var_61_5:setVisible(true)
	end

	var_0_97("sideCreatedDate", "sideCreatedTime", var_61_2, true)

	local var_61_6 = var_0_53("sideClosedCaption")

	if var_61_6 then
		var_61_6:setVisible(textValue)
	end

	var_0_97("sideClosedDate", "sideClosedTime", var_61_3, textValue)

	local var_61_7 = var_0_53("sideStatusCaption")

	if var_61_7 then
		var_61_7:setVisible(true)
		var_61_7:breakAnchors()
		var_61_7:addAnchor(AnchorTop, textValue and "sideClosedTime" or "sideCreatedTime", AnchorBottom)
		var_61_7:addAnchor(AnchorLeft, "parent", AnchorLeft)
		var_61_7:addAnchor(AnchorRight, "parent", AnchorRight)
		var_61_7:setMarginTop(10)
		var_61_7:setMarginLeft(8)
		var_61_7:setMarginRight(8)
	end

	local var_61_8 = var_0_53("sideStatusValue")

	if var_61_8 then
		local text, var_61_10 = formatReportStatus(arg_61_0.status)

		var_61_8:setVisible(true)
		var_61_8:setText(text)
		var_61_8:setColor(var_61_10)
	end

	var_0_95(arg_61_0)
end

local function var_0_99()
	local var_62_0 = var_0_53("closeButton")

	if var_62_0 then
		var_62_0:setText(var_0_11 and tr("Back") or tr("Close"))
	end
end

local function var_0_100()
	local var_63_0 = var_0_53("reportSecondColumnHeader")

	if var_63_0 then
		var_63_0:setText(var_0_7 == var_0_20 and tr("Player") or tr("Message"))
	end
end

local function var_0_101(arg_64_0, arg_64_1)
	if arg_64_0 and arg_64_0.canReply ~= nil and arg_64_0.canReply ~= "" then
		return var_0_59(arg_64_0.canReply) == 1
	end

	if not arg_64_0 or (arg_64_0.status or "") ~= "open" then
		return false
	end

	if var_0_7 == var_0_20 then
		return true
	end

	local var_64_0 = arg_64_0.ownerName or arg_64_0.playerName or ""
	local var_64_1 = var_0_62(arg_64_1)

	if #var_64_1 == 0 then
		return false
	end

	local var_64_2 = var_64_1[#var_64_1].entry.replier or ""

	return var_64_2 ~= "" and var_64_2 ~= var_64_0
end

local function var_0_102()
	local var_65_0 = var_0_53("reportSendButton")

	if not var_65_0 then
		return
	end

	local var_65_1 = var_0_11 and var_0_10 and var_0_10.canReply

	var_65_0:setEnabled(var_65_1 and true or false)

	if var_65_1 then
		var_65_0:setTooltip("")
	else
		var_65_0:setTooltip("Waiting for a response from Support.")
	end
end

local function var_0_103(arg_66_0)
	return tostring(arg_66_0 and arg_66_0.status or ""):lower() == "closed"
end

local function var_0_104(arg_67_0)
	local visible = arg_67_0 and var_0_10 and var_0_10.report and not var_0_103(var_0_10.report)
	local var_67_1 = var_0_53("reportListBase")

	if var_67_1 then
		var_67_1:setMarginBottom(visible and 19 or -2)
	end

	local var_67_2 = var_0_53("reportReplyEdit")

	if var_67_2 then
		var_67_2:setVisible(visible)

		if not visible then
			var_67_2:setText("")
		end
	end

	local var_67_3 = var_0_53("reportSendButton")

	if var_67_3 then
		var_67_3:setVisible(visible)
	end
end

local function var_0_105(arg_68_0)
	var_0_56(var_0_49, arg_68_0)

	local var_68_0 = var_0_53("reportThreadPanel")

	if var_68_0 then
		var_68_0:setVisible(not arg_68_0)
	end

	var_0_104(not arg_68_0)
end

local function var_0_106(parentWidget, arg_69_1, arg_69_2, arg_69_3, arg_69_4)
	if not parentWidget or not arg_69_3 or arg_69_3 == "" then
		return
	end

	local reportThreadLabelWidget = g_ui.createWidget("ReportThreadLabel", parentWidget)

	reportThreadLabelWidget:setText(string.format("%s %s: %s", var_0_65(arg_69_1), arg_69_2, arg_69_3))
	reportThreadLabelWidget:setColor(arg_69_4)
end

local function var_0_107(parentWidget, arg_70_1, arg_70_2, arg_70_3)
	if not parentWidget or not arg_70_2 or arg_70_2 == "" then
		return
	end

	local reportThreadLabelWidget = g_ui.createWidget("ReportThreadLabel", parentWidget)

	reportThreadLabelWidget:setText(string.format("%s %s", var_0_65(arg_70_1), arg_70_2))
	reportThreadLabelWidget:setColor(arg_70_3 or var_0_26)
end

local function var_0_108(arg_71_0, arg_71_1)
	local textValue = tostring(arg_71_0.type or tr("Report"))
	local var_71_1 = var_0_66(var_0_59(arg_71_0.createdAt))

	if var_71_1 == "" then
		var_71_1 = os.date("%b %d %Y")
	end

	local var_71_2 = arg_71_0.targetName or ""
	local var_71_3 = tostring(arg_71_0.statement or "")
	local var_71_4 = tostring(arg_71_0.comment or "")
	local var_71_5 = var_71_3 ~= "" and var_71_3 or var_71_4
	local var_71_6 = tostring(arg_71_0.type or ""):upper() == "STATEMENT"
	local var_71_7 = var_0_7 == var_0_20

	if var_71_6 and var_71_5 ~= "" then
		if var_71_2 ~= "" then
			if var_71_7 then
				return tr("The player %s opened a report %s to player %s with the message \"%s\".", arg_71_1, textValue, var_71_2, var_71_5)
			end

			return tr("You opened a report %s to player %s with the message \"%s\".", textValue, var_71_2, var_71_5)
		end

		if var_71_7 then
			return tr("The player %s opened a report %s with the message \"%s\".", arg_71_1, textValue, var_71_5)
		end

		return tr("You opened a report %s with the message \"%s\".", textValue, var_71_5)
	end

	if var_71_7 then
		return tr("The player %s opened a report %s as %s.", arg_71_1, textValue, var_71_1)
	end

	return tr("You opened a report %s as %s.", textValue, var_71_1)
end

local function var_0_109()
	local var_72_0 = var_0_53("reportThreadList")

	if not var_72_0 or not var_0_10 or not var_0_10.report then
		return
	end

	var_72_0:destroyChildren()

	local report = var_0_10.report
	local var_72_2 = report.ownerName or report.playerName or ""

	if var_72_2 == "" then
		var_72_2 = tr("Player")
	end

	var_0_107(var_72_0, report.createdAt, var_0_108(report, var_72_2), var_0_26)

	local textValue = tostring(report.type or ""):upper()
	local var_72_4 = report.comment or ""

	if var_72_4 == "" and textValue ~= "STATEMENT" then
		var_72_4 = report.statement or ""
	end

	if var_72_4 ~= "" then
		var_0_106(var_72_0, report.createdAt, var_72_2, var_72_4, var_0_24)
	end

	for unusedValue, message in ipairs(var_0_62(var_0_10.messages)) do
		local entry = message.entry
		local var_72_6 = entry.replier or ""
		local var_72_7 = var_72_6 ~= "" and var_72_6 == var_72_2

		var_0_106(var_72_0, entry.createdAt, var_72_7 and var_72_2 or DEFAULT_SUPPORT_SENDER, entry.message or "", var_72_7 and var_0_24 or var_0_25)
	end

	local var_72_8 = var_0_53("reportThreadScrollBar")

	if var_72_8 then
		scheduleEvent(function()
			if var_0_52(var_72_8) then
				var_72_8:setValue(var_72_8:getMaximum())
			end
		end, 30)
	end

	var_0_102()
end

local function var_0_110()
	var_0_11 = false
	var_0_12 = false

	var_0_105(true)
	var_0_96()
	var_0_99()
	var_0_102()
end

local function var_0_111()
	if not reportId then
		return
	end

	if not var_0_10 or var_0_59(var_0_10.report and var_0_10.report.id) ~= reportId then
		var_0_12 = true

		g_game.sendReportGet(reportId)

		return
	end

	var_0_11 = true
	var_0_12 = false

	var_0_105(false)
	var_0_109()
	var_0_98(var_0_10.report)
	var_0_99()

	local var_75_0 = var_0_53("reportReplyEdit")

	if var_75_0 then
		var_75_0:setText("")

		if var_0_10.canReply then
			var_75_0:focus()
		end
	end

	var_0_102()
end

local function var_0_112(arg_76_0)
	local outfit = arg_76_0:getOutfit()

	if outfit and (outfit.type or 0) ~= 0 then
		return outfit
	end

	local var_76_1 = modules.game_cyclopedia and modules.game_cyclopedia.Cyclopedia
	local var_76_2 = var_76_1 and var_76_1.Character and var_76_1.Character.InspectionOutfit

	if var_76_2 and (var_76_2.type or 0) ~= 0 then
		return var_76_2
	end
end

local function var_0_113()
	if not var_0_55() or not g_game.isOnline() then
		return
	end

	local localPlayer = g_game.getLocalPlayer()
	local var_77_1 = var_0_53("reportCharacterBase")

	if not localPlayer or not var_77_1 then
		return
	end

	var_77_1:setText(localPlayer:getName())
	var_77_1.reportWorldInfoLabel:setText(g_game.getWorldName() or "")
	var_77_1.reportInfoLabel:setText(string.format("Level %d\n%s", localPlayer:getLevel(), localPlayer:getVocationNameByClientId()))

	local reportOutfit = var_77_1.reportOutfit
	local outfit = reportOutfit and var_0_112(localPlayer)

	if reportOutfit and outfit then
		reportOutfit:setOutfit(outfit)
	end
end

local function var_0_114(arg_78_0, arg_78_1)
	if not var_0_52(arg_78_0) then
		return
	end

	arg_78_0:setBackgroundColor(arg_78_1 and var_0_23 or arg_78_0.rowColor or var_0_21)
end

local function var_0_115(arg_79_0)
	if not arg_79_0 or not arg_79_0.reportId or var_0_11 then
		return false
	end

	local var_79_0 = var_0_54()

	if var_79_0 then
		for unusedValue, child in ipairs(var_79_0:getChildren()) do
			var_0_114(child, child == arg_79_0)
		end
	end

	if reportId ~= arg_79_0.reportId then
		reportId = arg_79_0.reportId
		var_0_10 = nil
	end

	return true
end

local function onClick(arg_80_0)
	var_0_115(arg_80_0)
end

local function handleClick(arg_81_0)
	local parent = arg_81_0 and arg_81_0:getParent() or nil

	if var_0_115(parent) then
		var_0_111()
	end
end

local function var_0_118(arg_82_0)
	local parentWidget = var_0_54()

	if not parentWidget then
		return
	end

	parentWidget:destroyChildren()

	var_0_9 = {}
	reportId = nil
	var_0_10 = nil

	var_0_110()
	var_0_100()

	local rowColor = var_0_21

	for unusedValue, entry in ipairs(var_0_62(arg_82_0)) do
		local entry = entry.entry
		local reportId = var_0_59(entry.id)

		var_0_9[reportId] = entry

		local reportListRowWidget = g_ui.createWidget("ReportListRow", parentWidget)

		if not reportListRowWidget then
			break
		end

		reportListRowWidget.reportId = reportId
		reportListRowWidget.rowColor = rowColor

		reportListRowWidget:setId("reportRow" .. reportId)
		reportListRowWidget:setBackgroundColor(rowColor)

		local ticketLabel = reportListRowWidget:getChildById("ticketLabel")
		local playerLabel = reportListRowWidget:getChildById("playerLabel")
		local typeLabel = reportListRowWidget:getChildById("typeLabel")
		local statusLabel = reportListRowWidget:getChildById("statusLabel")
		local text = "#" .. tostring(reportId)

		if var_0_60(entry) then
			text = "* " .. text
		end

		if ticketLabel then
			ticketLabel:setText(text)
		end

		if playerLabel then
			playerLabel:setText(var_0_70(entry))
		end

		if typeLabel then
			typeLabel:setText(entry.type or "")
		end

		if statusLabel then
			local text, var_82_11 = formatReportStatus(entry.status)

			statusLabel:setText(text)
			statusLabel:setColor(var_82_11)
		end

		local detailsButton = reportListRowWidget:getChildById("detailsButton")

		if detailsButton then
			detailsButton.onClick = handleClick
		end

		reportListRowWidget.onClick = onClick
		rowColor = rowColor == var_0_21 and var_0_22 or var_0_21
	end

	var_0_99()
end

local function var_0_119()
	if not var_0_52(gameReportWidget) then
		return
	end

	gameReportWidget:show()
	gameReportWidget:raise()
	gameReportWidget:focus()
	g_modalManager.show(gameReportWidget)
end

local function var_0_120(arg_84_0)
	local var_84_0 = var_0_53(arg_84_0)
	local message = var_84_0 and var_84_0.gotoCommand or nil

	if not message or message == "" then
		return
	end

	g_game.talk(message)
	hide()
end

local function var_0_121()
	local var_85_0 = var_0_59(var_0_15)

	var_0_15 = nil

	if var_85_0 <= 0 then
		return false
	end

	reportId = var_85_0
	var_0_12 = true

	g_game.sendReportGet(var_85_0)

	return true
end

local function handleParseCyclopediaCharacterInspection()
	if var_0_55() then
		scheduleEvent(var_0_113, 0)
	end
end

local function handleGameStart()
	if not var_0_1 then
		var_0_1 = modules.game_mainpanel.addToggleButton("reportButton", tr("Open Report"), "/images/options/button_report", toggle, false, 1002)
	end

	var_0_83()
	var_0_90()
	scheduleEvent(function()
		var_0_83()
		var_0_90()
		var_0_73()
		var_0_113()
	end, 100)
end

local function handleRewardExerciseAllowed()
	var_0_14 = true

	var_0_90()
	var_0_80()
end

local function handleGameEnd()
	hide()
	var_0_91()

	var_0_9 = {}
	reportId = nil
	var_0_10 = nil
	var_0_11 = false
	var_0_12 = false
	var_0_15 = nil
	var_0_16 = nil
	var_0_7 = var_0_19

	var_0_96()
	var_0_75()

	var_0_14 = false

	var_0_87()
	var_0_82()
end

local function handleOutfitChange(arg_91_0, outfit)
	if not var_0_55() or arg_91_0 ~= g_game.getLocalPlayer() then
		return
	end

	local var_91_0 = var_0_53("reportCharacterBase")

	if var_91_0 and var_91_0.reportOutfit and outfit then
		var_91_0.reportOutfit:setOutfit(outfit)
	end
end

function onReplyTextChange()
	var_0_102()
end

function onReplyKeyDown(unusedArgument, arg_93_1, unusedArgument)
	if g_keyboard.isEnterKey(arg_93_1) then
		onSendReply()

		return true
	end
end

function onCloseButtonClick()
	if var_0_11 then
		var_0_110()
		g_game.sendReportOpen()

		return
	end

	hide()
end

function onGotoPlayerClick()
	var_0_120("sideGotoPlayerButton")
end

function onGotoPositionClick()
	var_0_120("sideGotoPositionButton")
end

function onCloseTicketClick()
	if var_0_7 ~= var_0_20 or not reportId or var_0_52(var_0_6) then
		return
	end

	local var_97_0 = reportId

	if var_0_52(gameReportWidget) then
		g_modalManager.hide(gameReportWidget)
		gameReportWidget:hide()
	end

	local function var_97_1()
		var_0_91()

		if var_0_7 ~= var_0_20 or not var_97_0 then
			var_0_119()

			return
		end

		var_0_110()

		reportId = nil
		var_0_10 = nil

		var_0_119()
		g_game.sendReportClose(var_97_0)
	end

	local function var_97_2()
		var_0_91()
		var_0_119()

		if var_0_10 and var_0_59(var_0_10.report and var_0_10.report.id) == var_97_0 then
			reportId = var_97_0

			var_0_111()
		end
	end

	var_0_6 = displayGeneralBox(tr("Close Ticket"), tr("Do you really want to close ticket #%s?", tostring(var_97_0)), {
		{
			text = tr("No"),
			callback = var_97_2
		},
		{
			text = tr("Yes"),
			callback = var_97_1
		},
		anchor = AnchorHorizontalCenter
	}, var_97_1, var_97_2)
end

function onSendReply()
	if not var_0_11 or not reportId or not var_0_10 or not var_0_10.canReply then
		return
	end

	local var_100_0 = var_0_53("reportReplyEdit")

	if not var_100_0 then
		return
	end

	local text = var_0_58(var_100_0:getText())

	if text == "" then
		return
	end

	g_game.sendReportReply(reportId, text)
	var_100_0:setText("")
	var_0_102()
end

function onReportList(arg_101_0, arg_101_1)
	var_0_7 = var_0_59(arg_101_0)
	var_0_16 = arg_101_1 or {}

	if not var_0_55() then
		return
	end

	if not var_0_11 and not var_0_12 then
		var_0_118(var_0_16)
	end

	var_0_74(var_0_61(var_0_16))
end

function onReportThread(arg_102_0, arg_102_1)
	local var_102_0 = var_0_59(arg_102_0 and arg_102_0.id)

	var_0_10 = {
		report = arg_102_0 or {},
		messages = arg_102_1 or {},
		canReply = var_0_101(arg_102_0, arg_102_1)
	}

	if var_102_0 > 0 then
		reportId = var_102_0

		if var_0_15 == var_102_0 then
			var_0_15 = nil
		end
	end

	var_0_99()

	if var_0_11 or var_0_12 then
		var_0_111()
	end

	if var_102_0 > 0 then
		g_game.sendReportOpen()
	end
end

function onReportNotify(unusedArgument, arg_103_1, unusedArgument, unusedArgument, unusedArgument)
	arg_103_1 = var_0_59(arg_103_1)

	local var_103_0 = var_0_55()

	if var_103_0 and var_0_11 and reportId == arg_103_1 and arg_103_1 > 0 then
		g_game.sendReportGet(arg_103_1)
		g_game.sendReportOpen()

		return
	end

	var_0_74(true, arg_103_1)

	if var_103_0 then
		g_game.sendReportOpen()
	end
end

function onReportResult(arg_104_0, arg_104_1)
	if arg_104_0 ~= 0 and arg_104_1 and arg_104_1 ~= "" and modules.game_textmessage then
		modules.game_textmessage.displayFailureMessage(arg_104_1)
	end
end

function init()
	gameReportWidget = g_ui.displayUI("game_report")

	gameReportWidget:hide()
	var_0_99()
	var_0_102()

	local var_105_0 = var_0_53("reportReplyEdit")

	if var_105_0 then
		var_105_0.onKeyDown = onReplyKeyDown
	end

	var_0_50 = {
		onGameStart = handleGameStart,
		onGameEnd = handleGameEnd,
		onParseCyclopediaCharacterInspection = handleParseCyclopediaCharacterInspection,
		onReportList = onReportList,
		onReportThread = onReportThread,
		onReportNotify = onReportNotify,
		onReportResult = onReportResult,
		onRewardExerciseAllowed = handleRewardExerciseAllowed
	}
	var_0_51 = {
		onOutfitChange = handleOutfitChange
	}

	connect(g_game, var_0_50)
	connect(LocalPlayer, var_0_51)

	if g_game.isOnline() then
		handleGameStart()
	end
end

function terminate()
	if var_0_50 then
		disconnect(g_game, var_0_50)

		var_0_50 = nil
	end

	if var_0_51 then
		disconnect(LocalPlayer, var_0_51)

		var_0_51 = nil
	end

	var_0_1 = var_0_57(var_0_1)

	var_0_87()
	var_0_82()
	var_0_91()

	gameReportWidget = var_0_57(gameReportWidget)
end

function show()
	if not var_0_52(gameReportWidget) or not g_game.isOnline() then
		return
	end

	var_0_113()

	if CyclopediaCharacterInfoTypes and CyclopediaCharacterInfoTypes.Ispection then
		g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.Ispection)
	end

	var_0_119()

	if var_0_1 then
		var_0_1:setOn(true)
	end

	if var_0_121() then
		return
	end

	var_0_110()

	if var_0_16 then
		var_0_118(var_0_16)
		var_0_74(var_0_61(var_0_16))
	end

	g_game.sendReportOpen()
end

function hide()
	if not var_0_52(gameReportWidget) then
		return
	end

	var_0_110()
	g_modalManager.hide(gameReportWidget)
	gameReportWidget:hide()

	if var_0_1 then
		var_0_1:setOn(false)
	end
end

function toggle()
	if var_0_55() then
		hide()
	else
		show()
	end
end
