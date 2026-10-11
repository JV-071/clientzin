local rootWidget
local contentTextList
local goldenOutfitButton
local royalCostumeButton
local goldenOutfitMemorial
local royalCostumeMemorial

local function addMemorialTextRow(text, marginTop, width)
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

local function populateMemorial(memorialData, populatedHeader, emptyHeader, useTokenPrices)
	contentTextList:destroyChildren()

	local hasEntries = #memorialData.base > 0 or #memorialData.addon1 > 0 or #memorialData.addon2 > 0

	addMemorialTextRow(hasEntries and populatedHeader or emptyHeader, 0)

	local function formatMemorialPrice(outfitDescription, price)
		if useTokenPrices then
			return tr("%s for %s Silver Tokens and %s Gold Tokens:", outfitDescription, formatMoney(price.silver), formatMoney(price.gold))
		end

		return tr("%s for %s gold:", outfitDescription, formatMoney(price))
	end

	if #memorialData.addon2 > 0 then
		addMemorialTextRow(formatMemorialPrice("Full Outfit", memorialData.price2), 12, 41)

		for unusedValue, entry in ipairs(memorialData.addon2) do
			addMemorialTextRow("- " .. entry, -1, 57)
		end
	end

	if #memorialData.addon1 > 0 then
		addMemorialTextRow(formatMemorialPrice("With One Addon", memorialData.price1), 12, 41)

		for unusedValue, entry in ipairs(memorialData.addon1) do
			addMemorialTextRow("- " .. entry, -1, 57)
		end
	end

	if #memorialData.base > 0 then
		addMemorialTextRow(formatMemorialPrice("Basic Outfit", memorialData.price0), 12, 41)

		for unusedValue, entry in ipairs(memorialData.base) do
			addMemorialTextRow("- " .. entry, -1, 57)
		end
	end
end

local function ensureMemorialWindow()
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

local function showMemorialWindow()
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

local function handleOutfitMemorial(goldenOutfitData, royalCostumeData)
	goldenOutfitMemorial = goldenOutfitData
	royalCostumeMemorial = royalCostumeData

	if not ensureMemorialWindow() then
		return
	end

	showMemorialWindow()
	selectGoldenPanel()
end

function selectGoldenPanel()
	populateMemorial(goldenOutfitMemorial, "The following characters have spent a fortune on a Golden Outfit:", "The Golden Outfit has not been acquired by anyone yet.", false)
	goldenOutfitButton:setChecked(true)
	royalCostumeButton:setChecked(false)
end

function selectRoyalPanel()
	populateMemorial(royalCostumeMemorial, "The following characters have spent a fortune on a Royal Costume:", "The Royal Costume has not been acquired by anyone yet.", true)
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
