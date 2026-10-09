local rootWidget
local contentTextList
local goldenOutfitButton
local royalCostumeButton
local var_0_4
local var_0_5

local function var_0_6(text, marginTop, width)
	if width and width > 0 then
		local mEIndentedLabelRowWidget = g_ui.createWidget("MEIndentedLabelRow", contentTextList)

		if marginTop then
			mEIndentedLabelRowWidget:setMarginTop(marginTop)
		end

		mEIndentedLabelRowWidget:recursiveGetChildById("indentSpacer"):setWidth(width)

		local label = mEIndentedLabelRowWidget:recursiveGetChildById("label")

		label:setText(text)
		mEIndentedLabelRowWidget:setHeight(label:getHeight())

		return
	end

	local mEListLabelWidget = g_ui.createWidget("MEListLabel", contentTextList)

	if marginTop then
		mEListLabelWidget:setMarginTop(marginTop)
	end

	mEListLabelWidget:setText(text)
end

local function var_0_7(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	contentTextList:destroyChildren()

	local var_2_0 = #arg_2_0.base > 0 or #arg_2_0.addon1 > 0 or #arg_2_0.addon2 > 0

	var_0_6(var_2_0 and arg_2_1 or arg_2_2, 0)

	local function var_2_1(arg_3_0, arg_3_1)
		if arg_2_3 then
			return tr("%s for %s Silver Tokens and %s Gold Tokens:", arg_3_0, formatMoney(arg_3_1.silver), formatMoney(arg_3_1.gold))
		end

		return tr("%s for %s gold:", arg_3_0, formatMoney(arg_3_1))
	end

	if #arg_2_0.addon2 > 0 then
		var_0_6(var_2_1("Full Outfit", arg_2_0.price2), 12, 41)

		for unusedValue, entry in ipairs(arg_2_0.addon2) do
			var_0_6("- " .. entry, -1, 57)
		end
	end

	if #arg_2_0.addon1 > 0 then
		var_0_6(var_2_1("With One Addon", arg_2_0.price1), 12, 41)

		for unusedValue, entry in ipairs(arg_2_0.addon1) do
			var_0_6("- " .. entry, -1, 57)
		end
	end

	if #arg_2_0.base > 0 then
		var_0_6(var_2_1("Basic Outfit", arg_2_0.price0), 12, 41)

		for unusedValue, entry in ipairs(arg_2_0.base) do
			var_0_6("- " .. entry, -1, 57)
		end
	end
end

local function var_0_8()
	if rootWidget then
		return true
	end

	rootWidget = g_ui.loadUI("memorial", g_ui.getRootWidget())

	if not rootWidget then
		return false
	end

	contentTextList = rootWidget:recursiveGetChildById("contentTextList")
	goldenOutfitButton = rootWidget:recursiveGetChildById("goldenOutfitButton")
	royalCostumeButton = rootWidget:recursiveGetChildById("royalCostumeButton")

	rootWidget:hide()

	return true
end

local function var_0_9()
	if not rootWidget then
		return
	end

	rootWidget:show()
	rootWidget:raise()
	rootWidget:focus()

	if g_modalManager then
		g_modalManager.show(rootWidget)
	end
end

function closeMemorial()
	if not rootWidget then
		return
	end

	if g_modalManager then
		g_modalManager.hide(rootWidget)
	end

	rootWidget:hide()
end

local function handleOutfitMemorial(arg_7_0, arg_7_1)
	var_0_4 = arg_7_0
	var_0_5 = arg_7_1

	if not var_0_8() then
		return
	end

	var_0_9()
	selectGoldenPanel()
end

function selectGoldenPanel()
	var_0_7(var_0_4, "The following characters have spent a fortune on a Golden Outfit:", "The Golden Outfit has not been acquired by anyone yet.", false)
	goldenOutfitButton:setChecked(true)
	royalCostumeButton:setChecked(false)
end

function selectRoyalPanel()
	var_0_7(var_0_5, "The following characters have spent a fortune on a Royal Costume:", "The Royal Costume has not been acquired by anyone yet.", true)
	royalCostumeButton:setChecked(true)
	goldenOutfitButton:setChecked(false)
end

function init()
	connect(g_game, {
		onOutfitMemorial = handleOutfitMemorial,
		onGameStart = closeMemorial,
		onGameEnd = closeMemorial
	})
end

function terminate()
	disconnect(g_game, {
		onOutfitMemorial = handleOutfitMemorial,
		onGameStart = closeMemorial,
		onGameEnd = closeMemorial
	})

	if rootWidget then
		if g_modalManager then
			g_modalManager.hide(rootWidget)
		end

		rootWidget:destroy()

		rootWidget = nil
	end
end
