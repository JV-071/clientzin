local acceptWindow
local changeNameWindow
local worldTransferWindow
local hirelingNameWindow
local transferPointsWindow
local processingWindow
local messageBox
local oldProtocol = false
local a0xF2 = true
local offerDescriptions = {}
local reasonCategory = {}
local bannersHome = {}
local currentIndex = 1
local HISTORY_ENTRIES_PER_PAGE = 26
local HISTORY_ROW_COLOR_A = "#484848"
local HISTORY_ROW_COLOR_B = "#414141"
local HISTORY_ROW_COLOR_SELECTED = "#585858"
local waitingInitialHome = false
local pendingStoreRedirect
local storeRedirectAwaitingOffers = false
local pendingStoreFocusOfferId
local var_0_21
local var_0_22 = 0
local var_0_23 = false
local var_0_24
local var_0_25
local subOffers = {}
local var_0_27
local var_0_28
local var_0_29 = 0
local row
local var_0_31 = {}
local var_0_32 = false
local var_0_33 = 6
local var_0_34 = 12
local var_0_35 = 120
local var_0_36 = 80
local var_0_37 = 4

local function var_0_38(arg_1_0, arg_1_1)
	if not var_0_32 then
		return
	end

	g_logger.info(string.format("[game_store perf] %s: %dms", arg_1_0, g_clock.millis() - arg_1_1))
end

local function var_0_39()
	if var_0_21 then
		removeEvent(var_0_21)

		var_0_21 = nil
	end
end

local function var_0_40()
	subOffers = {}

	if var_0_25 then
		removeEvent(var_0_25)

		var_0_25 = nil
	end
end

local function var_0_41()
	var_0_22 = var_0_22 + 1
	var_0_23 = false
	var_0_27 = nil

	var_0_40()

	if var_0_24 then
		removeEvent(var_0_24)

		var_0_24 = nil
	end
end

local function normalizeStoreOfferId(offerId)
	offerId = tonumber(offerId) or 0

	if offerId <= 0 then
		return 0
	end

	if offerId > 1000000 then
		return offerId % 1000000
	end

	return offerId
end

local function getPrimaryPurchasableOfferId(product)
	if not product then
		return 0
	end

	for _, subOffer in ipairs(product.subOffers or {}) do
		if subOffer.id and subOffer.id > 0 and subOffer.price ~= nil then
			return subOffer.id
		end
	end

	return product.id or 0
end

local function getCachedOfferDescription(offerId)
	if not offerId or offerId <= 0 then
		return ""
	end

	local cached = offerDescriptions[offerId] or offerDescriptions[normalizeStoreOfferId(offerId)]

	return cached and cached.description or ""
end

local function cacheOfferDescription(offerId, description)
	if not offerId or offerId <= 0 then
		return
	end

	offerDescriptions[offerId] = {
		id = offerId,
		description = description
	}

	local normalizedId = normalizeStoreOfferId(offerId)

	if normalizedId ~= offerId then
		offerDescriptions[normalizedId] = offerDescriptions[offerId]
	end
end

local function offerIdBelongsToProduct(product, offerId)
	if not product or not offerId or offerId <= 0 then
		return false
	end

	local normalizedIncoming = normalizeStoreOfferId(offerId)

	for _, subOffer in ipairs(product.subOffers or {}) do
		if subOffer.id and subOffer.id > 0 and (subOffer.id == offerId or normalizeStoreOfferId(subOffer.id) == normalizedIncoming) then
			return true
		end
	end

	if product.id and product.id > 0 and (product.id == offerId or normalizeStoreOfferId(product.id) == normalizedIncoming) then
		return true
	end

	return false
end

local function focusStoreOffer(listProduct, targetOfferId)
	if not listProduct or not targetOfferId or targetOfferId <= 0 then
		return false
	end

	local normalizedTarget = normalizeStoreOfferId(targetOfferId)

	for _, child in ipairs(listProduct:getChildren()) do
		local subOffers = child.product and (child.product.subOffers or {
			child.product
		}) or {}

		for _, subOffer in ipairs(subOffers) do
			if normalizeStoreOfferId(subOffer.id) == normalizedTarget then
				listProduct:focusChild(child)
				listProduct:ensureChildVisible(child)

				return true
			end
		end
	end

	return false
end

local storeHiddenForOverlay = false
local STORE_WATCHDOG_EVENT = "serverNoSendPackets0xF20xFA"

local function resetStoreLuaFlags()
	waitingInitialHome = false
	pendingStoreRedirect = nil
	storeRedirectAwaitingOffers = false
	pendingStoreFocusOfferId = nil
	storeHiddenForOverlay = false
end

local function resetStoreSessionFlags()
	resetStoreLuaFlags()

	a0xF2 = true
end

local function cancelStoreWatchdogEvent()
	controllerShop:scheduleEvent(function()
		return
	end, 1, STORE_WATCHDOG_EVENT)
end

local function recoverStoreOpenEnvironment()
	if g_modalManager and g_modalManager.pruneOrphanBlockers then
		g_modalManager.pruneOrphanBlockers()
	end

	if g_client and g_client.setInputLockWidget then
		pcall(function()
			g_client.setInputLockWidget(nil)
		end)
	end
end

local function showStoreWindow()
	if not controllerShop.ui then
		return
	end

	storeHiddenForOverlay = false

	controllerShop.ui:show()
	g_modalManager.show(controllerShop.ui)

	if controllerShop.ui.SearchEdit then
		controllerShop.ui.SearchEdit:focus()
	end
end

local function hideStoreForOverlay()
	if not controllerShop.ui then
		return
	end

	storeHiddenForOverlay = true

	g_modalManager.hide(controllerShop.ui)
	controllerShop.ui:hide()
end

local function restoreStoreAfterOverlay()
	if not storeHiddenForOverlay or not controllerShop.ui then
		return
	end

	showStoreWindow()
end

function hideStoreForCharacterBazaar()
	hideStoreForOverlay()
end

local STORE_ROW_AVAILABLE = "StoreOfferRowAvailable"
local STORE_ROW_UNAVAILABLE = "StoreOfferRowUnavailable"
local var_0_59 = {
	detailLargePreview = true
}
local var_0_60 = {
	packagePreview = true
}

GameStore = {}
GameStore.website = {
	IMAGES_URL = "",
	WEBSITE_GETCOINS = "http://127.0.0.1/?subtopic=donate"
}
GameStore.CoinType = {
	Transferable = 1,
	Coin = 0
}
GameStore.ClientOfferTypes = {
	CLIENT_STORE_OFFER_CHARACTER = 4,
	CLIENT_STORE_OFFER_HIRELING = 3,
	CLIENT_STORE_OFFER_WORLD_TRANSFER = 2,
	CLIENT_STORE_OFFER_NAMECHANGE = 1,
	CLIENT_STORE_OFFER_OTHER = 0,
	CLIENT_STORE_OFFER_CONFIRM = 6,
	CLIENT_STORE_OFFER_TOURNAMENT = 5
}
GameStore.States = {
	STATE_NONE = 0,
	STATE_TIMED = 3,
	STATE_SALE = 2,
	STATE_NEW = 1
}
GameStore.SendingPackets = {
	S_CompletePurchase = 254,
	S_OpenTransactionHistory = 253,
	S_StoreOffers = 252,
	S_OpenStore = 251,
	S_CoinBalanceUpdating = 242,
	S_RequestPurchaseData = 225,
	S_StoreError = 224,
	S_CoinBalance = 223
}
GameStore.RecivedPackets = {
	C_BuyStoreOffer = 252,
	C_RequestStoreOffers = 251,
	C_OpenStore = 250,
	C_ParseHirelingName = 236,
	C_RequestTransactionHistory = 254,
	C_TransferCoins = 239,
	C_RequestOfferDescription = 232,
	C_OpenTransactionHistory = 253
}

local function showPanel(panel)
	if panel == "HomePanel" then
		controllerShop.ui.HomePanel:setVisible(true)
		controllerShop.ui.panelItem:setVisible(false)
		controllerShop.ui.transferHistory:setVisible(false)
	elseif panel == "transferHistory" then
		controllerShop.ui.HomePanel:setVisible(false)
		controllerShop.ui.panelItem:setVisible(false)
		controllerShop.ui.transferHistory:setVisible(true)
	elseif panel == "panelItem" then
		controllerShop.ui.HomePanel:setVisible(false)
		controllerShop.ui.panelItem:setVisible(true)
		controllerShop.ui.transferHistory:setVisible(false)
	end
end

local function prepareStoreRedirectUi(focusOfferId)
	showStoreWindow()

	waitingInitialHome = false
	storeRedirectAwaitingOffers = true
	pendingStoreFocusOfferId = focusOfferId

	showPanel("panelItem")

	local listProduct = controllerShop.ui.panelItem and controllerShop.ui.panelItem.listProduct

	if listProduct then
		listProduct:destroyChildren()
	end
end

local function clearPurchaseCompleteModalEvents(box)
	if not box then
		return
	end

	if box._closeEvent then
		removeEvent(box._closeEvent)

		box._closeEvent = nil
	end
end

local function releasePurchaseCompleteModalRefs(box)
	clearPurchaseCompleteModalEvents(box)

	if not box then
		return
	end

	local buttonAnimation = box:recursiveGetChildById("buttonAnimation")

	if buttonAnimation and not buttonAnimation:isDestroyed() then
		buttonAnimation.onClick = nil
	end

	if box.onEscape then
		box.onEscape = nil
	end
end

local function releaseTransferPointsWindowRefs(window)
	if not window then
		return
	end

	if window.transferPointsText and not window.transferPointsText:isDestroyed() then
		window.transferPointsText.onTextChange = nil
	end

	if window.amountBar and not window.amountBar:isDestroyed() then
		window.amountBar.onValueChange = nil
	end

	if window.closeButton and not window.closeButton:isDestroyed() then
		window.closeButton.onClick = nil
	end

	if window.buttonOk and not window.buttonOk:isDestroyed() then
		window.buttonOk.onClick = nil
	end

	if window._giftButtonUpdateEvent then
		removeEvent(window._giftButtonUpdateEvent)

		window._giftButtonUpdateEvent = nil
	end

	window.onEscape = nil
	window.giftable = nil
	window.amount = nil
	window.amountBar = nil
	window.transferPointsText = nil
	window.closeButton = nil
	window.buttonOk = nil
end

local function releaseChangeNameWindowRefs(window)
	if not window then
		return
	end

	local nameField = window.transferPointsText

	if nameField and not nameField:isDestroyed() then
		nameField.onTextChange = nil
	end

	if window.closeButton and not window.closeButton:isDestroyed() then
		window.closeButton.onClick = nil
	end

	if window.buttonOk and not window.buttonOk:isDestroyed() then
		window.buttonOk.onClick = nil
	end

	if window._nameOkButtonUpdateEvent then
		removeEvent(window._nameOkButtonUpdateEvent)

		window._nameOkButtonUpdateEvent = nil
	end

	window.onEscape = nil
	window.transferPointsText = nil
	window.closeButton = nil
	window.buttonOk = nil
end

local function clearStoreOverlayWindowRef(window)
	if window == acceptWindow then
		acceptWindow = nil
	elseif window == processingWindow then
		processingWindow = nil
	elseif window == messageBox then
		messageBox = nil
	elseif window == transferPointsWindow then
		transferPointsWindow = nil
	elseif window == changeNameWindow then
		changeNameWindow = nil
	end
end

local function destroyWindow(windows)
	local list = type(windows) == "table" and windows or {
		windows
	}

	for _, window in ipairs(list) do
		if window == messageBox then
			clearPurchaseCompleteModalEvents(window)
		end

		if window and not window:isDestroyed() then
			releasePurchaseCompleteModalRefs(window)

			if releaseShopMessageBoxRefs then
				releaseShopMessageBoxRefs(window)
			end

			if window == transferPointsWindow then
				releaseTransferPointsWindowRefs(window)
			elseif window == changeNameWindow then
				releaseChangeNameWindowRefs(window)
			end

			g_modalManager.hide(window)
			window:destroy()
		end

		clearStoreOverlayWindowRef(window)
	end
end

local function isConfigurableOffer(product, offer)
	return offer and offer.configurable == true or product and product.configurable == true or false
end

local function showStoreProcessingModal()
	destroyWindow(processingWindow)
	hideStoreForOverlay()

	processingWindow = displayGeneralBox(tr("Processing purchase."), tr("Your purchase is being processed."), {}, nil, nil)

	if processingWindow then
		g_modalManager.show(processingWindow)
	end
end

local function getPageLabelHistory()
	local currentPage, pageCount = controllerShop.ui.transferHistory.lblPage:getText():match("Page (%d+)/(%d+)")

	return tonumber(currentPage), tonumber(pageCount)
end

local pendingHttpWidgets = {}
local pendingHttpId = 0
local STORE_DESC_FONT = {}
local var_0_75 = {}
local var_0_76 = 0
local var_0_77 = "Verdana Bold-11px-new"
local var_0_78 = "Verdana-11px-lowspace-italic"
local var_0_79 = "Verdana-11px-lowspace-underline"
local var_0_80 = "#f4f4f4"
local imageSourcePath = "/images/icons/store-icons-inline"
local var_0_82 = string.char(1)
local var_0_83 = string.char(2)
local var_0_84 = string.char(3)
local var_0_85 = string.char(4)
local var_0_86 = {
	["{houseicon}"] = "65 0 13 13",
	["{vocationlevelcheckicon}"] = "104 0 13 13",
	["{storeinboxicon}"] = "52 0 13 13",
	["{speedboosticon}"] = "117 0 13 13",
	["{boxicon}"] = "39 0 13 13",
	["{activatedicon}"] = "130 0 13 13",
	["{usablebyallicon}"] = "26 0 13 13",
	["{battlesignicon}"] = "143 0 13 13",
	["{charactericon}"] = "13 0 13 13",
	["{capacityicon}"] = "156 0 13 13",
	["{info}"] = "0 0 13 13",
	["{useicon}"] = "169 0 13 13",
	["{backtoinboxicon}"] = "91 0 13 13",
	["{transferablepriceicon}"] = "182 0 13 13",
	["{limiticon}"] = "78 0 13 13",
	["{accounticon}"] = "195 0 13 13"
}
local htmlToStoreDescriptionLines = {
	{
		text = "only usable by purchasing character",
		keyword = "character",
		icon = "{charactericon}"
	},
	{
		text = "can be used by all characters that have access to the house",
		keyword = "usablebyall",
		icon = "{usablebyallicon}"
	},
	{
		text = "comes in a box which can only be unwrapped by purchasing character",
		keyword = "box",
		icon = "{boxicon}"
	},
	{
		text = "will be sent to your Store inbox and can only be stored there and in depot box",
		keyword = "storeinbox",
		icon = "{storeinboxicon}"
	},
	{
		text = "can only be unwrapped in a house owned by the purchasing character",
		keyword = "house",
		icon = "{houseicon}"
	},
	{
		text = "maximum amount that can be owned by character: %s",
		keyword = "limit",
		dynamic = true,
		icon = "{limiticon}"
	},
	{
		text = "will be wrapped back and sent to inbox if the purchasing character is no longer the house owner",
		keyword = "backtoinbox",
		icon = "{backtoinboxicon}"
	},
	{
		text = "only buyable if fitting vocation and level of purchasing character",
		keyword = "vocationlevelcheck",
		icon = "{vocationlevelcheckicon}"
	},
	{
		text = "provides character with a speed boost",
		keyword = "speedboost",
		icon = "{speedboosticon}"
	},
	{
		text = "activated at purchase",
		keyword = "activated",
		icon = "{activatedicon}"
	},
	{
		text = "cannot be purchased by characters with protection zone block or battle sign",
		keyword = "battlesign",
		icon = "{battlesignicon}"
	},
	{
		text = "cannot be purchased if capacity is exceeded",
		keyword = "capacity",
		icon = "{capacityicon}"
	},
	{
		text = "can only be purchased with transferable Clientzin Coins",
		keyword = "transferableprice",
		icon = "{transferablepriceicon}"
	},
	{
		text = "usable by all characters of the account",
		keyword = "account",
		icon = "{accounticon}"
	}
}
local var_0_88 = {}
local parts = {}

for _, line in ipairs(htmlToStoreDescriptionLines) do
	var_0_88[line.keyword] = line

	if not line.dynamic then
		parts[line.text:lower()] = line
	end
end

local function var_0_90(arg_32_0)
	arg_32_0 = arg_32_0:gsub("&nbsp;", " ")
	arg_32_0 = arg_32_0:gsub("&lt;", "<")
	arg_32_0 = arg_32_0:gsub("&gt;", ">")
	arg_32_0 = arg_32_0:gsub("&quot;", "\"")
	arg_32_0 = arg_32_0:gsub("&amp;", "&")

	return arg_32_0
end

local function var_0_91(lineText, nextPos)
	if lineText:byte(nextPos) ~= 123 then
		return nil
	end

	local textAfterIcon = lineText:sub(nextPos):match("^(%{limit|%d+%})")

	if textAfterIcon then
		return "{limiticon}", var_0_86["{limiticon}"], nextPos + #textAfterIcon
	end

	local panel = lineText:find("}", nextPos + 1, true)

	if not panel then
		return nil
	end

	local var_33_2 = lineText:sub(nextPos, panel)
	local var_33_3 = var_0_86[var_33_2]

	if var_33_3 then
		return var_33_2, var_33_3, panel + 1
	end

	return nil
end

local function var_0_92(arg_34_0)
	local var_34_0 = arg_34_0:match("^%s*(.*)$") or arg_34_0

	if var_34_0 == "" then
		return false
	end

	return var_0_91(var_34_0, 1) ~= nil
end

local function var_0_93(arg_35_0)
	if not arg_35_0 or not arg_35_0:match("%S") then
		return arg_35_0
	end

	if var_0_92(arg_35_0) then
		return arg_35_0
	end

	local var_35_0 = (arg_35_0:match("^%s*(.-)%s*$") or arg_35_0):gsub("^%-%s*", "")
	local var_35_1 = var_35_0:match("^%{([^}]+)}%s*$") or var_35_0:match("^%{([^}]+)}%s+")

	if var_35_1 then
		local var_35_2, var_35_3 = var_35_1:match("^([^|]+)|(%d+)$")

		var_35_2 = var_35_2 or var_35_1

		local var_35_4 = var_35_2:lower()
		local var_35_5 = var_0_88[var_35_4]

		if var_35_5 then
			if var_35_5.dynamic and var_35_3 then
				local formattedText = string.format(var_35_5.text, var_35_3)

				return "{limit|" .. var_35_3 .. "} " .. formattedText
			elseif not var_35_5.dynamic then
				return var_35_5.icon .. " " .. var_35_5.text
			end
		end
	end

	local var_35_7 = var_35_0:lower()
	local var_35_8 = var_35_7:match("^maximum amount that can be owned by character: (%d+)$")

	if var_35_8 then
		return "{limit|" .. var_35_8 .. "} maximum amount that can be owned by character: " .. var_35_8
	end

	local var_35_9 = parts[var_35_7]

	if var_35_9 then
		return var_35_9.icon .. " " .. var_35_9.text
	end

	return arg_35_0
end

local function htmlToStoreDescriptionLines(html)
	if not html or html == "" then
		return {}
	end

	html = var_0_90(html:gsub("\r", ""))
	html = html:gsub("<[bB][rR]%s*/?>", "\n")
	html = html:gsub("<[lL][iI]>%s*", "- ")
	html = html:gsub("</[lL][iI]>%s*", "\n")
	html = html:gsub("<[uUoO][lL]>%s*", "")
	html = html:gsub("</[uUoO][lL]>%s*", "\n")
	html = html:gsub("<[pP]>%s*", "")
	html = html:gsub("</[pP]>%s*", "\n")
	html = html:gsub("</?[bB]>", "")

	local var_36_0 = {}
	local var_36_1 = 1

	for iter_36_0 = 1, #html do
		if html:byte(iter_36_0) == 10 then
			table.insert(var_36_0, html:sub(var_36_1, iter_36_0 - 1))

			var_36_1 = iter_36_0 + 1
		end
	end

	if var_36_1 <= #html then
		table.insert(var_36_0, html:sub(var_36_1))
	end

	for iter_36_1 = 1, #var_36_0 do
		var_36_0[iter_36_1] = var_0_93(var_36_0[iter_36_1])
	end

	return var_36_0
end

local function var_0_95(arg_37_0)
	return (arg_37_0:match("^%s*(.-)%s*$") or arg_37_0):gsub("<i>", ""):gsub("</i>", ""):gsub("<I>", ""):gsub("</I>", ""):gsub("<u>", ""):gsub("</u>", ""):gsub("<U>", ""):gsub("</U>", ""):gsub("<[^>]+>", "")
end

local marginLeft = 17
local labelWidget

local function var_0_98(arg_38_0)
	local var_38_0 = arg_38_0:match("^%s*(.-)%s*$") or arg_38_0

	if var_38_0:find("<i>") or var_38_0:find("<I>") then
		return var_0_78
	end

	if var_38_0:find("<u>") or var_38_0:find("<U>") then
		return var_0_79
	end

	return var_0_77
end

local function var_0_99(arg_39_0, arg_39_1)
	if not arg_39_0 or arg_39_0 == "" then
		return 0
	end

	if not labelWidget then
		labelWidget = g_ui.createWidget("Label", g_ui.getRootWidget())

		labelWidget:setVisible(false)
		labelWidget:setPhantom(true)
	end

	labelWidget:setFont(arg_39_1)
	labelWidget:setTextWrap(false)
	labelWidget:setText(arg_39_0, true)

	return labelWidget:getTextSize().width
end

local function var_0_100(arg_40_0)
	if not arg_40_0 then
		return 200
	end

	local width = arg_40_0:getWidth() - arg_40_0:getPaddingLeft() - arg_40_0:getPaddingRight()

	return math.max(1, width)
end

local function var_0_101(arg_41_0, arg_41_1, arg_41_2, arg_41_3)
	if not arg_41_0 or arg_41_0 == "" then
		return {
			""
		}
	end

	local var_41_0 = {}
	local var_41_1 = ""
	local var_41_2 = arg_41_3

	for iter_41_0 in arg_41_0:gmatch("%S+") do
		local var_41_3 = var_41_1 == "" and iter_41_0 or var_41_1 .. " " .. iter_41_0

		if var_41_2 >= var_0_99(var_41_3, arg_41_1) then
			var_41_1 = var_41_3
		elseif var_41_1 == "" then
			table.insert(var_41_0, iter_41_0)

			var_41_1 = ""
			var_41_2 = arg_41_2
		else
			table.insert(var_41_0, var_41_1)

			var_41_1 = iter_41_0
			var_41_2 = arg_41_2
		end
	end

	if var_41_1 ~= "" then
		table.insert(var_41_0, var_41_1)
	end

	if #var_41_0 == 0 then
		table.insert(var_41_0, arg_41_0)
	end

	return var_41_0
end

local function unusedValue(html)
	local textParts = {}

	for _, line in ipairs(htmlToStoreDescriptionLines(html)) do
		local plain = line:gsub("<i>", var_0_82):gsub("</i>", var_0_83):gsub("<u>", var_0_84):gsub("</u>", var_0_85):gsub("<[^>]+>", "")

		table.insert(textParts, plain)
	end

	return table.concat(textParts, "\n")
end

local function var_0_103(arg_43_0, arg_43_1, arg_43_2)
	local var_43_0 = arg_43_1:match("^%s*(.-)%s*$") or arg_43_1
	local var_43_1 = var_43_0:find("<i>") or var_43_0:find("<I>")
	local var_43_2 = var_43_0:find("<u>") or var_43_0:find("<U>")
	local text = var_0_95(var_43_0)

	if text == "" then
		arg_43_0:setText("")

		return
	end

	if var_43_1 then
		arg_43_0:setFont(var_0_78)
	elseif var_43_2 then
		arg_43_0:setFont(var_0_79)
	else
		arg_43_0:setFont(var_0_77)
	end

	arg_43_0:setText(text)
	arg_43_0:setColor(arg_43_2 or var_0_80)
end

local function var_0_104(parentWidget, arg_44_1, arg_44_2, imageClipRect)
	local storeDescriptionLineWidget = g_ui.createWidget("StoreDescriptionLine", parentWidget)

	if not storeDescriptionLineWidget then
		return false
	end

	local icon = storeDescriptionLineWidget.icon or storeDescriptionLineWidget:getChildById("icon")
	local text = storeDescriptionLineWidget.text or storeDescriptionLineWidget:getChildById("text")

	if not text then
		storeDescriptionLineWidget:destroy()

		return false
	end

	if imageClipRect and icon then
		icon:setVisible(true)
		icon:setImageSource(imageSourcePath)
		icon:setImageClip(imageClipRect)
		text:setMarginLeft(marginLeft)
		text:setTextWrap(false)
	else
		if icon then
			icon:setVisible(false)
		end

		text:setMarginLeft(0)
		text:setTextWrap(true)
	end

	var_0_103(text, arg_44_1, arg_44_2)
	storeDescriptionLineWidget:setHeight(math.max(14, text:getTextSize().height + 2))

	return text:getText() ~= "" or imageClipRect ~= nil
end

local function addStoreDescriptionLine(container, lineText, color)
	if lineText == nil then
		return false
	end

	if not lineText:match("%S") then
		local storeDescriptionLineWidget = g_ui.createWidget("StoreDescriptionLine", container)

		if not storeDescriptionLineWidget then
			return false
		end

		local icon = storeDescriptionLineWidget.icon or storeDescriptionLineWidget:getChildById("icon")
		local text = storeDescriptionLineWidget.text or storeDescriptionLineWidget:getChildById("text")

		if icon then
			icon:setVisible(false)
		end

		if text then
			text:setMarginLeft(0)
			text:setText("")
		end

		storeDescriptionLineWidget:setHeight(8)

		return true
	end

	local unusedValue, var_45_4, var_45_5 = var_0_91(lineText, 1)

	if var_45_4 then
		local var_45_6 = lineText:sub(var_45_5)
		local var_45_7 = var_0_98(var_45_6)
		local var_45_8 = var_0_95(var_45_6:match("^%s*(.-)%s*$") or var_45_6)
		local var_45_9 = var_0_100(container)
		local var_45_10 = math.max(1, var_45_9 - marginLeft)
		local var_45_11 = var_0_101(var_45_8, var_45_7, var_45_9, var_45_10)
		local var_45_12 = var_45_6:find("<i>") or var_45_6:find("<I>")
		local var_45_13 = var_45_6:find("<u>") or var_45_6:find("<U>")
		local var_45_14 = false

		for index, entry in ipairs(var_45_11) do
			local var_45_15 = entry

			if var_45_12 then
				var_45_15 = "<i>" .. entry .. "</i>"
			elseif var_45_13 then
				var_45_15 = "<u>" .. entry .. "</u>"
			end

			if var_0_104(container, var_45_15, color, index == 1 and var_45_4 or nil) then
				var_45_14 = true
			end
		end

		return var_45_14
	end

	return var_0_104(container, lineText, color, nil)
end

local var_0_106
local var_0_107

local function getPanelItemDetailsContent(panel)
	if not panel then
		return nil
	end

	return panel.detailsContentPanel or panel:getChildById("detailsContentPanel")
end

local function var_0_109()
	var_0_106 = nil
	var_0_107 = nil
end

local function var_0_110(arg_48_0)
	if not arg_48_0 or arg_48_0:isDestroyed() then
		var_0_109()

		return nil
	end

	if var_0_107 and var_0_106 == arg_48_0 then
		return var_0_107
	end

	var_0_106 = arg_48_0
	var_0_107 = {
		lblName = arg_48_0:getChildById("lblName"),
		image = arg_48_0:getChildById("image"),
		StackOffers = arg_48_0:getChildById("StackOffers")
	}

	return var_0_107
end

local function getPanelItemDescriptionScroll(panel)
	local var_49_0 = getPanelItemDetailsContent(panel)

	if not var_49_0 then
		return nil
	end

	return var_49_0.descriptionScroll or var_49_0:getChildById("descriptionScroll")
end

local function unusedValue(arg_50_0)
	local var_50_0 = getPanelItemDescriptionScroll(arg_50_0)

	if not var_50_0 then
		return nil
	end

	return var_50_0.lblDescription or var_50_0:getChildById("lblDescription")
end

local function clearStoreDescriptionLines(scroll)
	if not scroll then
		return
	end

	for iter_51_0 = scroll:getChildCount(), 1, -1 do
		local childByIndex = scroll:getChildByIndex(iter_51_0)

		if childByIndex and childByIndex:getId() ~= "lblDescription" then
			childByIndex:destroy()
		end
	end
end

local function showStoreDescriptionFallback(scroll, html, errorText)
	local lblDescription = scroll.lblDescription or scroll:getChildById("lblDescription")

	if not lblDescription then
		return
	end

	clearStoreDescriptionLines(scroll)
	lblDescription:setVisible(true)

	local var_52_1 = {}

	for unusedValue, entry in ipairs(htmlToStoreDescriptionLines(html or "")) do
		local var_52_2 = var_0_95(entry):gsub("%{%w+%}", "")

		table.insert(var_52_1, var_52_2)
	end

	local text = table.concat(var_52_1, "\n")

	if errorText and errorText ~= "" then
		text = errorText .. (text ~= "" and "\n\n" .. text or "")
	end

	lblDescription:setFont(var_0_77)
	lblDescription:setColor(var_0_80)
	lblDescription:setText(text)
end

local createProductImage

local function getPackageContents(product)
	local numericValue = tonumber(product and product.productsCapacity) or 0

	if numericValue <= 0 then
		return {}
	end

	local capacity = product.subOffers or {}
	local var_53_2 = #capacity - numericValue + 1

	if var_53_2 < 1 then
		return {}
	end

	local purchasable = {}

	for i = var_53_2, #capacity do
		table.insert(purchasable, capacity[i])
	end

	return purchasable
end

local function getProductOutfitColors(source)
	local var_54_0 = source and source.subOffers or {}
	local numericValue = tonumber(source and source.productsCapacity) or 0

	if numericValue <= 0 or numericValue >= #var_54_0 then
		return var_54_0
	end

	local var_54_2 = {}

	for iter_54_0 = 1, #var_54_0 - numericValue do
		table.insert(var_54_2, var_54_0[iter_54_0])
	end

	return var_54_2
end

local function var_0_118(arg_55_0)
	if not arg_55_0 then
		return 0, 0, 0, 0
	end

	local function var_55_0(arg_56_0)
		if arg_56_0.outfit then
			return arg_56_0.outfit.lookHead or arg_56_0.outfit.head or 0, arg_56_0.outfit.lookBody or arg_56_0.outfit.body or 0, arg_56_0.outfit.lookLegs or arg_56_0.outfit.legs or 0, arg_56_0.outfit.lookFeet or arg_56_0.outfit.feet or 0
		end

		return arg_56_0.outfitHead or 0, arg_56_0.outfitBody or 0, arg_56_0.outfitLegs or 0, arg_56_0.outfitFeet or 0
	end

	local var_55_1, var_55_2, var_55_3, var_55_4 = var_55_0(arg_55_0)

	if arg_55_0.outfitHead ~= nil or arg_55_0.outfitBody ~= nil or arg_55_0.outfitLegs ~= nil or arg_55_0.outfitFeet ~= nil then
		return var_55_1, var_55_2, var_55_3, var_55_4
	end

	for _, subOffer in ipairs(arg_55_0.subOffers or {}) do
		if subOffer.outfitHead ~= nil or subOffer.outfitBody ~= nil or subOffer.outfitLegs ~= nil or subOffer.outfitFeet ~= nil then
			return var_55_0(subOffer)
		end
	end

	return var_55_1, var_55_2, var_55_3, var_55_4
end

local function buildHirelingProductData(source, outfitId)
	if not outfitId or outfitId <= 0 then
		return nil
	end

	local var_57_0, var_57_1, var_57_2, var_57_3 = var_0_118(source)

	return {
		VALOR = "outfitId",
		isHireling = true,
		ID = outfitId,
		outfit = {
			addons = 3,
			type = outfitId,
			head = var_57_0,
			body = var_57_1,
			legs = var_57_2,
			feet = var_57_3
		}
	}
end

local function var_0_120(arg_58_0)
	local numericValue = tonumber(arg_58_0)

	if numericValue and numericValue > 0 then
		return numericValue
	end

	return nil
end

local function findHirelingOutfitIds(product)
	local var_59_0 = var_0_120(product.maleOutfitId)
	local var_59_1 = var_0_120(product.femaleOutfitId)

	if var_59_0 or var_59_1 then
		return var_59_0, var_59_1
	end

	for unusedValue, entry in ipairs(product.subOffers or {}) do
		var_59_0 = var_59_0 or var_0_120(entry.maleOutfitId)
		var_59_1 = var_59_1 or var_0_120(entry.femaleOutfitId)
	end

	return var_59_0, var_59_1
end

local function resolveHirelingOutfitId(sex, maleOutfitId, femaleOutfitId)
	if sex == nil then
		sex = 1
	end

	return sex == 0 and femaleOutfitId or maleOutfitId or maleOutfitId or femaleOutfitId
end

local function findHirelingSex(product)
	if product.sex ~= nil then
		return product.sex
	end

	for _, subOffer in ipairs(product.subOffers or {}) do
		if subOffer.sex ~= nil then
			return subOffer.sex
		end
	end

	return 1
end

local function getSubOfferProductData(subOffer)
	if not subOffer then
		return nil
	end

	if subOffer.itemId and subOffer.itemId > 0 then
		return {
			VALOR = "item",
			ID = subOffer.itemId
		}
	end

	if subOffer.mountId and subOffer.mountId > 0 then
		return {
			VALOR = "mountId",
			ID = subOffer.mountId
		}
	end

	if subOffer.icon and subOffer.icon ~= "" then
		return {
			VALOR = "icon",
			ID = subOffer.icon
		}
	end

	local maleOutfitId = subOffer.maleOutfitId
	local femaleOutfitId = subOffer.femaleOutfitId

	if maleOutfitId and maleOutfitId > 0 or femaleOutfitId and femaleOutfitId > 0 then
		local outfitId = resolveHirelingOutfitId(subOffer.sex, maleOutfitId, femaleOutfitId)

		return buildHirelingProductData(subOffer, outfitId)
	end

	return nil
end

local function renderStorePackageContents(scroll, product, opts)
	opts = opts or {}

	if not scroll or not product then
		return false
	end

	local contents = getPackageContents(product)

	if #contents == 0 then
		return false
	end

	if opts.addSpacer then
		addStoreDescriptionLine(scroll, "")
	end

	local header = g_ui.createWidget("StorePackageContentsHeader", scroll)

	if header then
		header:setText("This package contains:")
	end

	for _, content in ipairs(contents) do
		local row = g_ui.createWidget("StorePackageContentsRow", scroll)

		if not row then
			-- block empty
		else
			local nameLabel = row.name or row:getChildById("name")

			if nameLabel then
				nameLabel:setText(content.name or "")
			end

			local preview = row.preview or row:getChildById("preview")
			local data = getSubOfferProductData(content)

			if preview and data and createProductImage then
				preview:destroyChildren()
				createProductImage(preview, data, var_0_60)
			end
		end
	end

	return true
end

local function renderStoreDescription(panel, html, errorText, product)
	local var_64_0 = var_0_32 and g_clock.millis() or nil
	local scroll = getPanelItemDescriptionScroll(panel)

	if not scroll then
		return
	end

	local fallbackLabel = scroll.lblDescription or scroll:getChildById("lblDescription")

	if fallbackLabel then
		fallbackLabel:setVisible(false)
	end

	clearStoreDescriptionLines(scroll)

	local lineCount = 0

	if errorText and errorText ~= "" then
		if addStoreDescriptionLine(scroll, errorText, "#d33c3c") then
			lineCount = lineCount + 1
		end

		if addStoreDescriptionLine(scroll, "") then
			lineCount = lineCount + 1
		end
	end

	if html and html ~= "" then
		for _, line in ipairs(htmlToStoreDescriptionLines(html)) do
			if addStoreDescriptionLine(scroll, line) then
				lineCount = lineCount + 1
			end
		end
	end

	local hasPackage = renderStorePackageContents(scroll, product, {
		addSpacer = lineCount > 0
	})

	if lineCount == 0 and not hasPackage then
		showStoreDescriptionFallback(scroll, html, errorText)

		if var_64_0 then
			var_0_38("renderStoreDescription fallback", var_64_0)
		end

		return
	end

	scroll:updateLayout()

	if var_64_0 then
		var_0_38("renderStoreDescription", var_64_0)
	end
end

local function clearPendingHttpForChildren(parent)
	if not parent then
		return
	end

	local var_65_0

	for i = 1, parent:getChildCount() do
		local child = parent:getChildByIndex(i)

		if child and child._httpId then
			pendingHttpWidgets[child._httpId] = nil
			child._httpId = nil
			var_65_0 = var_65_0 or {}
			var_65_0[child] = true
		end
	end

	if not var_65_0 then
		return
	end

	for unusedValue, homeProductos in pairs(STORE_DESC_FONT) do
		for _, row in ipairs(homeProductos) do
			if row.widget and var_65_0[row.widget] then
				row.widget = nil
			end
		end
	end
end

local function var_0_128()
	for key, entry in pairs(STORE_DESC_FONT) do
		local var_66_0

		for unusedValue, entry in ipairs(entry) do
			local widget = entry.widget

			if entry.persistent and widget and not widget:isDestroyed() then
				var_66_0 = var_66_0 or {}
				var_66_0[#var_66_0 + 1] = entry
			else
				pendingHttpWidgets[entry.httpId] = nil

				if widget then
					widget._httpId = nil
					entry.widget = nil
				end
			end
		end

		STORE_DESC_FONT[key] = var_66_0
	end

	local var_66_2 = {}

	for unusedValue, entry in ipairs(var_0_75) do
		if STORE_DESC_FONT[entry.url] then
			var_66_2[#var_66_2 + 1] = entry
		end
	end

	var_0_75 = var_66_2
end

GameStore.luaGc = {
	intervalMs = 16,
	stepSize = 256,
	passes = 0
}

function GameStore.requestIncrementalGC()
	local luaGc = GameStore.luaGc

	luaGc.passes = math.max(luaGc.passes, 2)

	if luaGc.event then
		return
	end

	local function var_67_1()
		luaGc.event = nil

		if collectgarbage("step", luaGc.stepSize) then
			luaGc.passes = luaGc.passes - 1
		end

		if luaGc.passes > 0 then
			luaGc.event = scheduleEvent(var_67_1, luaGc.intervalMs)
		end
	end

	luaGc.event = scheduleEvent(var_67_1, luaGc.intervalMs)
end

local function clearHomeProducts()
	if not controllerShop.ui or not controllerShop.ui.HomePanel then
		return
	end

	local HomeProductos = controllerShop.ui.HomePanel.HomeRecentlyAdded.HomeProductos

	for iter_69_0 = 1, HomeProductos:getChildCount() do
		local childByIndex = HomeProductos:getChildByIndex(iter_69_0)

		if childByIndex then
			clearPendingHttpForChildren(childByIndex:getChildById("image"))
		end
	end

	HomeProductos:destroyChildren()

	row = nil
end

local function refreshRowHoverBorder(row)
	local _hoverBorder = row._hoverBorder

	if not _hoverBorder then
		return
	end

	_hoverBorder:setVisible(row._isHovered == true or row._isFocused == true)
end

local function var_0_131(arg_71_0, arg_71_1, arg_71_2)
	arg_71_0._isHovered = false
	arg_71_0._isFocused = false
	arg_71_0._hoverBorder = arg_71_0:getChildById("hoverBorder")

	if arg_71_2 ~= false then
		function arg_71_0.onFocusChange(arg_72_0, _isFocused)
			arg_72_0._isFocused = _isFocused

			refreshRowHoverBorder(arg_72_0)
		end
	end

	if arg_71_1 then
		function arg_71_0.onHoverChange(arg_73_0, _isHovered)
			arg_73_0._isHovered = _isHovered

			refreshRowHoverBorder(arg_73_0)
		end
	end
end

local function updateHomeHoveredRow(homeProductos, mousePos)
	local var_74_0

	for unusedValue, child in ipairs(homeProductos:getChildren()) do
		if child:containsPoint(mousePos) then
			var_74_0 = child

			break
		end
	end

	if var_74_0 == row then
		return var_74_0
	end

	if row and not row:isDestroyed() then
		row._isHovered = false

		refreshRowHoverBorder(row)
	end

	if var_74_0 then
		var_74_0._isHovered = true

		refreshRowHoverBorder(var_74_0)
	end

	row = var_74_0

	return var_74_0
end

local function getHomeBannerWidget()
	if not controllerShop.ui or not controllerShop.ui.HomePanel then
		return nil
	end

	local homeImagenFrame = controllerShop.ui.HomePanel:getChildById("HomeImagenFrame")

	if not homeImagenFrame then
		return nil
	end

	return homeImagenFrame:getChildById("HomeImagen")
end

local function var_0_134(arg_76_0, arg_76_1, imageSourcePath, arg_76_3, arg_76_4)
	if not arg_76_0 or arg_76_0:isDestroyed() then
		return
	end

	if arg_76_3 then
		g_logger.warning("HTTP error: " .. arg_76_3 .. " - " .. arg_76_4)

		if arg_76_1 then
			arg_76_0:setIcon("/game_store/images/dynamic-image-error")
		else
			arg_76_0:setImageSource("/game_store/images/dynamic-image-error")
			arg_76_0:setImageFixedRatio(false)
		end

		return
	end

	if arg_76_1 then
		arg_76_0:setIcon(imageSourcePath)
	else
		arg_76_0:setImageSource(imageSourcePath)
	end
end

local function var_0_135()
	while var_0_76 < var_0_37 and #var_0_75 > 0 do
		local var_77_0 = table.remove(var_0_75, 1)

		if not STORE_DESC_FONT[var_77_0.url] then
			-- block empty
		else
			var_0_76 = var_0_76 + 1

			if HTTP.downloadImage(var_77_0.url, function(arg_78_0, arg_78_1)
				var_0_76 = var_0_76 - 1

				local var_78_0 = STORE_DESC_FONT[var_77_0.url]

				STORE_DESC_FONT[var_77_0.url] = nil

				if var_78_0 then
					for unusedValue, entry in ipairs(var_78_0) do
						pendingHttpWidgets[entry.httpId] = nil

						if entry.widget then
							entry.widget._httpId = nil
						end

						var_0_134(entry.widget, entry.isIcon, arg_78_0, arg_78_1, var_77_0.url)
					end
				end

				var_0_135()
			end) == nil and STORE_DESC_FONT[var_77_0.url] then
				var_0_76 = var_0_76 - 1

				local var_77_1 = STORE_DESC_FONT[var_77_0.url]

				STORE_DESC_FONT[var_77_0.url] = nil

				if var_77_1 then
					for unusedValue, entry in ipairs(var_77_1) do
						pendingHttpWidgets[entry.httpId] = nil

						if entry.widget then
							entry.widget._httpId = nil
						end

						var_0_134(entry.widget, entry.isIcon, nil, "invalid url", var_77_0.url)
					end
				end
			end
		end
	end
end

local function setImagenHttp(widget, url, arg_79_2, arg_79_3)
	local IMAGES_URL = GameStore.website.IMAGES_URL

	if IMAGES_URL and IMAGES_URL ~= "" then
		pendingHttpId = pendingHttpId + 1

		local _httpId = pendingHttpId

		pendingHttpWidgets[_httpId] = widget
		widget._httpId = _httpId

		local var_79_2 = IMAGES_URL .. url
		local var_79_3 = {
			widget = widget,
			isIcon = arg_79_2,
			httpId = _httpId,
			persistent = arg_79_3 == true
		}

		if STORE_DESC_FONT[var_79_2] then
			table.insert(STORE_DESC_FONT[var_79_2], var_79_3)

			return
		end

		STORE_DESC_FONT[var_79_2] = {
			var_79_3
		}

		table.insert(var_0_75, {
			url = var_79_2
		})
		var_0_135()
	else
		local rel = url:gsub("^/+", "")
		local localPath = "/game_store/images/" .. rel

		if not g_resources.fileExists(localPath) then
			widget:setImageSource("/game_store/images/dynamic-image-error")
			widget:setImageFixedRatio(false)
		else
			widget:setImageSource(localPath)
		end
	end
end

local function formatNumberWithCommas(value)
	local sign = value < 0 and "-" or ""

	value = math.abs(value)

	local formattedValue = string.format("%d", value):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

	return sign .. formattedValue
end

local function getCoinsBalance()
	local function extractNumber(text)
		if type(text) ~= "string" then
			return 0
		end

		local numberStr = text:match("%d[%d,]*")

		if not numberStr then
			return 0
		end

		local cleanNumber = numberStr:gsub("[^%d]", "")

		return tonumber(cleanNumber) or 0
	end

	local lblCoins = controllerShop.ui.lblCoins.lblTibiaCoins
	local lblTransfer = controllerShop.ui.lblCoins.lblTibiaTransfer
	local coins1 = lblCoins and extractNumber(lblCoins:getText()) or 0
	local coins2 = lblTransfer and extractNumber(lblTransfer:getText()) or 0

	return coins1, coins2
end

local function fixServerNoSend0xF2()
	if not a0xF2 then
		return
	end

	local player = g_game.getLocalPlayer()

	if not player or not controllerShop.ui then
		local packet2 = GameStore.SendingPackets.S_CoinBalanceUpdating

		g_logger.warning(string.format("[game_store BUG] Check 0x%X (%d) on server onParseStoreGetCoin", packet2, packet2))

		return
	end

	local coin, transfer = getCoinsBalance()
	local coinBalance = player:getResourceBalance(ResourceTypes.COIN_NORMAL)
	local transferBalance = player:getResourceBalance(ResourceTypes.COIN_TRANSFERRABLE)

	if coin ~= coinBalance or transfer ~= transferBalance then
		controllerShop.ui.lblCoins.lblTibiaCoins:setText(formatNumberWithCommas(coinBalance))
		controllerShop.ui.lblCoins.lblTibiaTransfer:setText(string.format("(Including: %s", formatNumberWithCommas(transferBalance)))
	end

	a0xF2 = false
end

local function closePurchaseSuccessModal(box)
	box = box or messageBox

	if not box or box:isDestroyed() then
		return
	end

	destroyWindow(box)
	restoreStoreAfterOverlay()
	fixServerNoSend0xF2()
end

function updateAuctionCharacterTransferableBalance()
	local window = configAuctionCharacterWindow

	if not window or window:isDestroyed() or not window:isVisible() then
		window = checksAuctionCharacterWindow
	end

	if not window or window:isDestroyed() then
		return
	end

	local label = window.balanceCoins and window.balanceCoins.balanceCoinsLabel

	if not label then
		return
	end

	fixServerNoSend0xF2()

	local _, transferableBalance = getCoinsBalance()
	local player = g_game.getLocalPlayer()

	if not player then
		return
	end

	local balance = player:getResourceBalance(ResourceTypes.COIN_TRANSFERRABLE)

	if balance == 0 then
		balance = transferableBalance
	end

	label:setText(formatNumberWithCommas(balance))
end

local function convert_timestamp(timestamp)
	return (os.date("%Y-%m-%d, %H:%M:%S", timestamp))
end

local function getProductData(product)
	local SHOW_NONE = 0
	local SHOW_MOUNT = 1
	local SHOW_OUTFIT = 2
	local SHOW_ITEM = 3
	local SHOW_HIRELING = 4

	local function toPositiveNumber(value)
		local n = tonumber(value)

		if n and n > 0 then
			return n
		end

		return nil
	end

	local productType = tonumber(product.type) or 0
	local subOffers = getProductOutfitColors(product)

	local function findNumber(fieldName)
		local direct = toPositiveNumber(product[fieldName])

		if direct then
			return direct
		end

		for _, subOffer in ipairs(subOffers) do
			local value = toPositiveNumber(subOffer[fieldName])

			if value then
				return value
			end
		end

		return nil
	end

	local function findIcon()
		if product.icon and product.icon ~= "" then
			return product.icon
		end

		for _, subOffer in ipairs(subOffers) do
			if subOffer.icon and subOffer.icon ~= "" then
				return subOffer.icon
			end
		end

		return nil
	end

	local itemId = findNumber("itemId")
	local itemType = findNumber("itemType")
	local icon = findIcon()
	local mountClientId = findNumber("mountClientId")
	local mountId = findNumber("mountId")
	local outfitId = findNumber("outfitId")
	local maleOutfitId = findNumber("maleOutfitId")
	local femaleOutfitId = findNumber("femaleOutfitId")
	local sexId = findNumber("sexId")

	if productType == SHOW_MOUNT and (mountClientId or mountId) then
		return {
			VALOR = "mountId",
			ID = mountClientId or mountId
		}
	elseif productType == SHOW_ITEM and (itemType or itemId) then
		return {
			VALOR = "item",
			ID = itemType or itemId
		}
	elseif productType == SHOW_OUTFIT then
		if sexId then
			return {
				VALOR = "outfitId",
				ID = sexId
			}
		elseif outfitId then
			return {
				VALOR = "outfitId",
				ID = outfitId
			}
		end
	elseif productType == SHOW_HIRELING then
		local male, female = findHirelingOutfitIds(product)
		local id = resolveHirelingOutfitId(findHirelingSex(product), male, female)

		return buildHirelingProductData(product, id)
	elseif productType == SHOW_NONE and icon then
		return {
			VALOR = "icon",
			ID = icon
		}
	end

	if itemId or itemType then
		return {
			VALOR = "item",
			ID = itemId or itemType
		}
	elseif mountId then
		return {
			VALOR = "mountId",
			ID = mountId
		}
	elseif outfitId then
		return {
			VALOR = "outfitId",
			ID = outfitId
		}
	elseif maleOutfitId or femaleOutfitId or productType == SHOW_HIRELING then
		local male, female = findHirelingOutfitIds(product)
		local id = resolveHirelingOutfitId(findHirelingSex(product), male or maleOutfitId, female or femaleOutfitId)

		return buildHirelingProductData(product, id)
	elseif sexId then
		return {
			VALOR = "outfitId",
			ID = sexId
		}
	elseif icon then
		return {
			VALOR = "icon",
			ID = icon
		}
	end
end

local function getOfferTitleColorByState(state)
	if state == GameStore.States.STATE_NEW then
		return "#44ad25"
	elseif state == GameStore.States.STATE_SALE then
		return "#f7af48"
	elseif state == GameStore.States.STATE_TIMED then
		return "#1872c3"
	end

	return "#c0c0c0"
end

local function resolveOfferState(product)
	if not product then
		return 0
	end

	if product.state and product.state > 0 then
		return product.state
	end

	if product.subOffers and #product.subOffers > 0 then
		local firstSubOffer = product.subOffers[1]

		if firstSubOffer and firstSubOffer.state and firstSubOffer.state > 0 then
			return firstSubOffer.state
		end
	end

	return 0
end

local function getOfferStateFlagImage(state)
	if state == GameStore.States.STATE_NEW then
		return "/game_store/images/store-flag-new"
	elseif state == GameStore.States.STATE_SALE then
		return "/game_store/images/store-flag-sale"
	elseif state == GameStore.States.STATE_TIMED then
		return "/game_store/images/store-flag-expires"
	end

	return nil
end

local function applyOfferStateVisuals(row, product)
	local state = resolveOfferState(product)
	local nameLabel = row:getChildById("lblName")

	if nameLabel then
		nameLabel:setColor(getOfferTitleColorByState(state))
	end

	local stateFlag = row:getChildById("stateFlag")

	if not stateFlag then
		return
	end

	local stateFlagImage = getOfferStateFlagImage(state)

	if stateFlagImage then
		stateFlag:setImageSource(stateFlagImage)
		stateFlag:show()
	else
		stateFlag:setImageSource("")
		stateFlag:hide()
	end
end

local var_0_147 = 10
local var_0_148 = 50

local function var_0_149(itemWidget, arg_95_1, arg_95_2)
	if not itemWidget or itemWidget:isDestroyed() then
		return
	end

	arg_95_2 = arg_95_2 or 0

	local exactSize = g_gameConfig.getSpriteSize()
	local itemThing = false
	local item = itemWidget:getItem()

	if item then
		local var_95_3 = item:getExactSize()

		if var_95_3 and var_95_3 > 0 then
			itemThing = true
			exactSize = math.max(exactSize, var_95_3)
		end
	end

	itemWidget:setSize({
		width = exactSize * arg_95_1,
		height = exactSize * arg_95_1
	})

	if not itemThing and arg_95_2 < var_0_147 then
		scheduleEvent(function()
			var_0_149(itemWidget, arg_95_1, arg_95_2 + 1)
		end, var_0_148)
	end
end

function createProductImage(imageParent, data, opts)
	opts = opts or {}

	local detailLargePreview = opts.detailLargePreview == true
	local packagePreview = opts.packagePreview == true
	local previewSize = 64

	if detailLargePreview then
		previewSize = 128
	elseif packagePreview then
		previewSize = 64
	end

	if data.VALOR == "item" then
		local itemWidget = g_ui.createWidget("Item", imageParent)

		itemWidget:setId("storeItem_" .. data.ID)
		itemWidget:setItemId(data.ID)
		itemWidget:setVirtual(true)
		itemWidget:setImageSource("")

		if detailLargePreview then
			itemWidget:setFixedItemSize(false)
			itemWidget:setPadding(0)
			var_0_149(itemWidget, 2)
		elseif packagePreview then
			itemWidget:setFixedItemSize(false)
			itemWidget:setPadding(0)
			var_0_149(itemWidget, 1)
		else
			itemWidget:setFixedItemSize(true)
			itemWidget:setSize({
				width = previewSize,
				height = previewSize
			})
		end

		itemWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		itemWidget:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
	elseif data.VALOR == "icon" then
		local itemWidget = g_ui.createWidget("UIWidget", imageParent)

		itemWidget:setId("storeIcon_" .. data.ID)
		setImagenHttp(itemWidget, "/64/" .. data.ID, false)
		itemWidget:setSize({
			width = previewSize,
			height = previewSize
		})

		if detailLargePreview then
			itemWidget:setImageFixedRatio(false)
		end

		itemWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		itemWidget:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
	elseif data.VALOR == "mountId" or data.VALOR:find("outfitId") then
		local creature = g_ui.createWidget("StorePreviewCreature", imageParent)

		creature:setId("storeCreature_" .. data.ID)

		local outfit = {
			addons = 3,
			type = data.ID
		}

		if data.outfit then
			outfit.head = data.outfit.head or 0
			outfit.body = data.outfit.body or 0
			outfit.legs = data.outfit.legs or 0
			outfit.feet = data.outfit.feet or 0
		end

		creature:setOutfit(outfit)
		creature:getCreature():setStaticWalking(0)

		local widgetSize = previewSize

		if detailLargePreview then
			widgetSize = 128
		end

		creature:setSize({
			width = widgetSize,
			height = widgetSize
		})

		if data.isHireling then
			if detailLargePreview then
				creature:setCenter(false)
				creature:setFixedCreatureSize(false)
				creature:setCreatureSize(100)
				creature:setBaseScale(true)
			else
				creature:setFixedCreatureSize(true)
			end
		else
			creature:setCenter(true)
			creature:setFixedCreatureSize(true)
			creature:setBaseScale(true)
			creature:setIgnoreDisplacementShift(true)
		end

		creature:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		creature:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
	end
end

local function configureTopCategoryFilter(comboBox, menuFilter)
	comboBox._suppressStoreFilterRequest = true

	local previousOption = comboBox.getCurrentOption and comboBox:getCurrentOption() or nil
	local previousText = previousOption and previousOption.text or "Show All"

	if not comboBox._storeFilterMousePressPatched then
		comboBox._storeFilterMousePressPatched = true
		comboBox._storeFilterBaseOnMousePress = comboBox.onMousePress

		function comboBox.onMousePress(self, mousePos, mouseButton)
			if self._showAllOnly then
				return true
			end

			if self._storeFilterBaseOnMousePress then
				return self._storeFilterBaseOnMousePress(self, mousePos, mouseButton)
			end

			return false
		end
	end

	comboBox:clearOptions()
	comboBox:addOption("Show All", -1)
	comboBox:setCurrentOption("Show All", true)

	if type(menuFilter) == "table" and #menuFilter > 0 then
		local hasPreviousOption = previousText == "Show All"

		for index, categoryName in ipairs(menuFilter) do
			comboBox:addOption(categoryName, index - 1)

			if categoryName == previousText then
				hasPreviousOption = true
			end
		end

		if hasPreviousOption then
			comboBox:setCurrentOption(previousText, true)
		end

		comboBox._showAllOnly = false

		comboBox:setPhantom(false)
		comboBox:setEnabled(true)
		comboBox:setColor("#c0c0c0")
	else
		comboBox._showAllOnly = true

		comboBox:setPhantom(true)
		comboBox:setEnabled(true)
		comboBox:setOn(false)
		comboBox:setColor("#707070")
	end

	comboBox._suppressStoreFilterRequest = false
end

local function getStoreSortOrderFromUi()
	local sortCombo = controllerShop.ui and controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.MostPopularFirst

	if not sortCombo or not sortCombo.getCurrentOption then
		return 0
	end

	local current = sortCombo:getCurrentOption()
	local data = current and current.data or nil

	if data == "Alphabetically" then
		return 1
	elseif data == "NewestFirst" or data == "NewestFist" then
		return 2
	end

	return 0
end

local function requestStoreOffersFromFilters()
	if not controllerShop.ui then
		return
	end

	local selectedCategory = ""

	if controllerShop.ui.openedSubCategory and controllerShop.ui.openedSubCategory.open then
		selectedCategory = controllerShop.ui.openedSubCategory.open
	elseif controllerShop.ui.openedCategory and controllerShop.ui.openedCategory.open then
		selectedCategory = controllerShop.ui.openedCategory.open
	end

	if selectedCategory == "" or selectedCategory == "Home" then
		return
	end

	local showAllCombo = controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.showAll
	local showAllCurrent = showAllCombo and showAllCombo:getCurrentOption() or nil
	local selectedFilterText = showAllCurrent and showAllCurrent.text or "Show All"
	local selectedSubCategory = selectedFilterText ~= "Show All" and selectedFilterText or ""
	local sortOrder = getStoreSortOrderFromUi()

	g_game.requestStoreOffers(selectedCategory, selectedSubCategory, sortOrder, 1)
end

local function resetStoreFilterDefaults()
	if not controllerShop.ui then
		return
	end

	local comboContainer = controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer
	local showAllCombo = comboContainer.showAll
	local sortCombo = comboContainer.MostPopularFirst

	if showAllCombo then
		showAllCombo._suppressStoreFilterRequest = true

		showAllCombo:setCurrentOption("Show All", true)

		showAllCombo._suppressStoreFilterRequest = false
	end

	if sortCombo then
		sortCombo._suppressStoreSortRequest = true

		sortCombo:setCurrentOption("Most Popular First", true)

		sortCombo._suppressStoreSortRequest = false
	end
end

local function normalizeStoreFilterToken(token)
	token = (token or ""):lower()

	if token:sub(-3) == "ies" then
		return token:sub(1, -4) .. "y"
	end

	if token:sub(-3) == "ves" then
		return token:sub(1, -4) .. "f"
	end

	if token:sub(-2) == "es" then
		return token:sub(1, -3)
	end

	if token:sub(-1) == "s" then
		return token:sub(1, -2)
	end

	return token
end

local function productMatchesSubCategoryFilter(product)
	if not product._sortName then
		product._sortName = tostring(product.name or ""):lower()
	end

	return product._sortName
end

local function var_0_156(arg_105_0)
	if not arg_105_0._filterHaystack then
		arg_105_0._filterHaystack = string.format("%s %s", productMatchesSubCategoryFilter(arg_105_0), tostring(arg_105_0.description or ""):lower())
	end

	return arg_105_0._filterHaystack
end

local function var_0_157(product, selectedSubCategory, arg_106_2)
	if not selectedSubCategory or selectedSubCategory == "" then
		return true
	end

	local needle = normalizeStoreFilterToken(selectedSubCategory)
	local collection = normalizeStoreFilterToken(product.collection)

	if collection ~= "" and (collection == needle or collection:find(needle, 1, true) or needle:find(collection, 1, true)) then
		return true
	end

	local haystack = var_0_156(product)
	local var_106_3 = arg_106_2 or selectedSubCategory:lower()

	if haystack:find(var_106_3, 1, true) then
		return true
	end

	local hasAnyToken = false

	for token in var_106_3:gmatch("[%w]+") do
		if #token > 2 then
			hasAnyToken = true

			local normalized = normalizeStoreFilterToken(token)

			if not haystack:find(token, 1, true) and not haystack:find(normalized, 1, true) then
				return false
			end
		end
	end

	return hasAnyToken
end

local function getNewestRankForProduct(product)
	local _newestRank = product._newestRank

	if _newestRank ~= nil then
		return _newestRank
	end

	local numericValue = tonumber(product.stateNewUntil) or 0

	product._newestRank = numericValue

	return numericValue
end

local function applyClientSideOfferFilters(offers, selectedSubCategory, sortOrder)
	offers = offers or {}

	local hasFilter = selectedSubCategory and selectedSubCategory ~= ""

	if not hasFilter and sortOrder == 0 then
		return offers
	end

	local filtered = {}
	local var_108_2 = 0
	local var_108_3 = hasFilter and selectedSubCategory:lower() or nil

	if hasFilter then
		for iter_108_0 = 1, #offers do
			local var_108_4 = offers[iter_108_0]

			if var_0_157(var_108_4, selectedSubCategory, var_108_3) then
				var_108_2 = var_108_2 + 1
				filtered[var_108_2] = var_108_4
			end
		end
	else
		for iter_108_1 = 1, #offers do
			var_108_2 = var_108_2 + 1
			filtered[var_108_2] = offers[iter_108_1]
		end
	end

	if sortOrder == 1 then
		table.sort(filtered, function(a, b)
			return productMatchesSubCategoryFilter(a) < productMatchesSubCategoryFilter(b)
		end)
	elseif sortOrder == 2 then
		table.sort(filtered, function(a, b)
			local newestA = getNewestRankForProduct(a)
			local newestB = getNewestRankForProduct(b)

			if newestA ~= newestB then
				return newestB < newestA
			end

			return productMatchesSubCategoryFilter(a) < productMatchesSubCategoryFilter(b)
		end)
	else
		table.sort(filtered, function(a, b)
			local _popScore = a._popScore

			if _popScore == nil then
				_popScore = tonumber(a.popularityScore) or 0
				a._popScore = _popScore
			end

			local popB = b._popScore

			if popB == nil then
				popB = tonumber(b.popularityScore) or 0
				b._popScore = popB
			end

			if _popScore ~= popB then
				return popB < _popScore
			end

			return productMatchesSubCategoryFilter(a) < productMatchesSubCategoryFilter(b)
		end)
	end

	return filtered
end

local function disableAllButtons()
	local panel = controllerShop.ui.panelItem
	local detail = getPanelItemDetailsContent(panel)

	if detail then
		local image = detail:getChildById("image")

		clearPendingHttpForChildren(image)

		local stack = detail:getChildById("StackOffers")

		if stack then
			stack:destroyChildren()
		end

		if image then
			image:destroyChildren()
		end
	end

	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local widget = controllerShop.ui.listCategory:getChildByIndex(i)

		if widget and widget.Button then
			widget.Button:setEnabled(false)

			if widget.subCategories then
				for subId, _ in ipairs(widget.subCategories) do
					local subWidget = widget:getChildById(subId)

					if subWidget and subWidget.Button then
						subWidget.Button:setEnabled(false)
					end
				end
			end
		end
	end
end

local updateSelectedCategoryTextColor

local function setCategoryButtonVisualState(widget, isSelected)
	local var_113_0 = widget and widget.Button or widget

	if not var_113_0 then
		return
	end

	local icon = var_113_0.Icon
	local title = var_113_0.Title

	if not icon or not title then
		return
	end

	if isSelected then
		icon:setMarginLeft(7)
		icon:setMarginTop(1)
		title:setTextOffset(topoint("1 1"))
	else
		icon:setMarginLeft(6)
		icon:setMarginTop(0)
		title:setTextOffset(topoint("0 1"))
	end
end

local function var_0_163(arg_114_0)
	if not arg_114_0 then
		return
	end

	function arg_114_0.onMousePress(arg_115_0, unusedArgument, arg_115_2)
		if arg_115_2 ~= MouseLeftButton then
			return
		end

		setCategoryButtonVisualState(arg_115_0, true)
	end

	function arg_114_0.onMouseRelease(arg_116_0, unusedArgument, arg_116_2)
		if arg_116_2 ~= MouseLeftButton then
			return
		end

		setCategoryButtonVisualState(arg_116_0, arg_116_0:isChecked())
	end
end

local function enableAllButtons()
	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local widget = controllerShop.ui.listCategory:getChildByIndex(i)

		if widget and widget.Button then
			widget.Button:setEnabled(true)

			if widget.subCategories then
				for subId, _ in ipairs(widget.subCategories) do
					local subWidget = widget:getChildById(subId)

					if subWidget and subWidget.Button then
						subWidget.Button:setEnabled(true)
					end
				end
			end
		end
	end

	local selectedSubCategory = controllerShop.ui.openedSubCategory

	if selectedSubCategory and selectedSubCategory:isVisible() then
		updateSelectedCategoryTextColor(nil, selectedSubCategory)
	else
		updateSelectedCategoryTextColor(controllerShop.ui.openedCategory, nil)
	end
end

function updateSelectedCategoryTextColor(selectedCategory, selectedSubCategory)
	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local widget = controllerShop.ui.listCategory:getChildByIndex(i)

		if widget and widget.Button and widget.Button.Title then
			widget.Button.Title:setColor("#c0c0c0")
			setCategoryButtonVisualState(widget, widget.Button:isChecked())
		end

		if widget and widget.subCategories then
			for subId, _ in ipairs(widget.subCategories) do
				local subWidget = widget:getChildById(subId)

				if subWidget and subWidget.Button and subWidget.Button.Title then
					subWidget.Button.Title:setColor("#c0c0c0")
					setCategoryButtonVisualState(subWidget, subWidget.Button:isChecked())
				end
			end
		end
	end

	if selectedCategory and selectedCategory.Button and selectedCategory.Button.Title then
		selectedCategory.Button.Title:setColor("#f4f4f4")
		setCategoryButtonVisualState(selectedCategory, true)
	end

	if selectedSubCategory and selectedSubCategory.Button and selectedSubCategory.Button.Title then
		selectedSubCategory.Button.Title:setColor("#f4f4f4")
		setCategoryButtonVisualState(selectedSubCategory, true)
	end
end

local function toggleSubCategories(parent, isOpen)
	if parent.SubCategoryRail then
		parent.SubCategoryRail:setVisible(isOpen)
	end

	for subId, _ in ipairs(parent.subCategories) do
		local subWidget = parent:getChildById(subId)

		if subWidget then
			subWidget:setVisible(isOpen)

			if subWidget.Button then
				subWidget.Button:setChecked(false)
			end

			if subWidget.ExternalArrow then
				subWidget.ExternalArrow:setVisible(false)
			end
		end
	end

	if isOpen then
		local sub1 = parent:getChildById(1)

		if sub1 and sub1.Button then
			sub1.Button:setChecked(true)

			if sub1.ExternalArrow then
				sub1.ExternalArrow:setVisible(true)
			end

			controllerShop.ui.openedSubCategory = sub1

			updateSelectedCategoryTextColor(nil, sub1)
		end
	else
		controllerShop.ui.openedSubCategory = nil
	end

	parent:setHeight(isOpen and parent.openedSize or parent.closedSize)

	parent.opened = isOpen

	parent.Button.Arrow:setVisible(not isOpen)
end

local function close(parent)
	if parent.subCategories then
		toggleSubCategories(parent, false)
	end
end

local function open(parent)
	local oldOpen = controllerShop.ui.openedCategory

	if oldOpen and oldOpen ~= parent then
		close(oldOpen)
	end

	toggleSubCategories(parent, true)

	controllerShop.ui.openedCategory = parent
end

local function closeCategoryButtons()
	if not controllerShop.ui or not controllerShop.ui.listCategory then
		return
	end

	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local widget = controllerShop.ui.listCategory:getChildByIndex(i)

		if widget and widget.subCategories then
			for subId, _ in ipairs(widget.subCategories) do
				local subWidget = widget:getChildById(subId)

				if subWidget then
					subWidget.Button:setChecked(false)

					if subWidget.ExternalArrow then
						subWidget.ExternalArrow:setVisible(false)
					end
				end
			end
		end
	end
end

local function clearSelectedStoreCategory()
	if not controllerShop.ui or not controllerShop.ui.listCategory then
		return
	end

	closeCategoryButtons()

	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local widget = controllerShop.ui.listCategory:getChildByIndex(i)

		if widget then
			if widget.subCategories and widget.opened then
				toggleSubCategories(widget, false)
			end

			if widget.Button then
				widget.Button:setChecked(false)
				widget.Button.Arrow:setVisible(widget.subCategoriesSize and widget.subCategoriesSize > 0 or false)
			end
		end
	end

	controllerShop.ui.openedCategory = nil
	controllerShop.ui.openedSubCategory = nil

	updateSelectedCategoryTextColor(nil, nil)
end

local function var_0_170()
	if not controllerShop.ui or not controllerShop.ui.SearchEdit then
		return
	end

	local SearchEdit = controllerShop.ui.SearchEdit

	if (SearchEdit:getText() or "") ~= "" then
		SearchEdit:setText("")
	end
end

local function resetStoreUiOnClose()
	if not controllerShop.ui then
		return
	end

	var_0_39()
	var_0_41()
	var_0_128()

	var_0_28 = nil
	row = nil

	var_0_170()

	controllerShop.ui.openedCategory = nil
	controllerShop.ui.openedSubCategory = nil

	updateSelectedCategoryTextColor(nil, nil)
	resetStoreFilterDefaults()

	local listProduct = controllerShop.ui.panelItem and controllerShop.ui.panelItem.listProduct

	if listProduct then
		for i = 1, listProduct:getChildCount() do
			local row = listProduct:getChildByIndex(i)

			if row then
				clearPendingHttpForChildren(row:getChildById("image"))
			end
		end

		listProduct:destroyChildren()
	end

	clearHomeProducts()
	GameStore.requestIncrementalGC()

	local detail = getPanelItemDetailsContent(controllerShop.ui.panelItem)

	if detail then
		local image = detail:getChildById("image")
		local stack = detail:getChildById("StackOffers")

		if image then
			clearPendingHttpForChildren(image)
			image:destroyChildren()
			image:setImageSource("/images/ui/1pixel-down-frame")
		end

		if stack then
			stack:destroyChildren()
		end
	end

	if controllerShop.ui.listCategory then
		controllerShop.ui.listCategory:destroyChildren()
	end

	offerDescriptions = {}
	var_0_31 = {}

	var_0_109()
end

local function syncSelectedCategoryByName(categoryName)
	if not controllerShop.ui or not categoryName or categoryName == "" then
		return
	end

	if categoryName == "Search" then
		return
	end

	local targetCategory
	local targetSubCategory

	for i = 1, controllerShop.ui.listCategory:getChildCount() do
		local categoryWidget = controllerShop.ui.listCategory:getChildByIndex(i)

		if categoryWidget then
			if categoryWidget.open == categoryName or categoryWidget:getId() == categoryName then
				targetCategory = categoryWidget

				break
			end

			if categoryWidget.subCategories then
				for subId, _ in ipairs(categoryWidget.subCategories) do
					local subWidget = categoryWidget:getChildById(subId)

					if subWidget and (subWidget.open == categoryName or subWidget.Button and subWidget.Button.Title and subWidget.Button.Title:getText() == categoryName) then
						targetCategory = categoryWidget
						targetSubCategory = subWidget

						break
					end
				end

				if targetCategory then
					break
				end
			end
		end
	end

	if not targetCategory then
		return
	end

	closeCategoryButtons()

	if controllerShop.ui.openedCategory and controllerShop.ui.openedCategory ~= targetCategory then
		close(controllerShop.ui.openedCategory)

		if controllerShop.ui.openedCategory.Button then
			controllerShop.ui.openedCategory.Button:setChecked(false)
		end
	end

	controllerShop.ui.openedCategory = targetCategory

	if targetCategory.subCategoriesSize then
		targetCategory.closedSize = 22
		targetCategory.openedSize = targetCategory.closedSize + targetCategory.subCategoriesSize * 20

		open(targetCategory)
	else
		targetCategory.Button:setChecked(true)
		targetCategory.Button.Arrow:setVisible(false)
	end

	if targetSubCategory then
		for subId, _ in ipairs(targetCategory.subCategories) do
			local sw = targetCategory:getChildById(subId)

			if sw and sw.Button then
				local sel = sw == targetSubCategory

				sw.Button:setChecked(sel)

				if sw.ExternalArrow then
					sw.ExternalArrow:setVisible(sel)
				end
			end
		end

		controllerShop.ui.openedSubCategory = targetSubCategory

		updateSelectedCategoryTextColor(nil, targetSubCategory)
	elseif targetCategory.subCategoriesSize then
		local firstSub = targetCategory:getChildById(1)

		controllerShop.ui.openedSubCategory = firstSub

		if firstSub then
			updateSelectedCategoryTextColor(nil, firstSub)
		end
	else
		controllerShop.ui.openedSubCategory = nil

		updateSelectedCategoryTextColor(targetCategory, nil)
	end
end

function showStoreAfterAuction()
	if not controllerShop.ui then
		return
	end

	restoreStoreAfterOverlay()

	local openedCategory = controllerShop.ui.openedCategory

	if openedCategory and (openedCategory:getId() == "Home" or openedCategory.open == "Home") then
		syncSelectedCategoryByName("Home")
		showPanel("HomePanel")

		local homeProductos = controllerShop.ui.HomePanel.HomeRecentlyAdded.HomeProductos

		if homeProductos and homeProductos:getChildCount() == 0 then
			g_game.sendRequestStoreHome()
		end
	elseif controllerShop.ui.panelItem:isVisible() or controllerShop.ui.openedCategory then
		showPanel("panelItem")
	else
		syncSelectedCategoryByName("Home")
		showPanel("HomePanel")
		g_game.sendRequestStoreHome()
	end
end

local function createSubWidget(parent, subId, subButton)
	local subWidget = g_ui.createWidget("storeCategory", parent)

	subWidget:setId(subId)
	subWidget:setImageSource("")
	subWidget:setSize("152 22")
	setImagenHttp(subWidget.Button.Icon, subButton.icon, true, true)
	subWidget.Button.Title:setText(subButton.text)
	subWidget:setVisible(false)

	subWidget.open = subButton.open

	subWidget.Button:setSize("152 20")
	subWidget.Button:addAnchor(AnchorTop, "parent", AnchorTop)
	subWidget.Button:addAnchor(AnchorRight, "parent", AnchorRight)
	subWidget.Button:setMarginTop(1)
	subWidget.Button:setMarginRight(0)
	subWidget.Button:setMarginLeft(0)
	subWidget.Button.Arrow:setVisible(false)
	var_0_163(subWidget.Button)

	local uIWidgetWidget = g_ui.createWidget("UIWidget", parent)

	uIWidgetWidget:setId("arrow_" .. subId)
	uIWidgetWidget:setSize("7 7")
	uIWidgetWidget:setPhantom(true)
	uIWidgetWidget:setImageSource("/images/ui/icon-arrow7x7-right")
	uIWidgetWidget:setVisible(false)
	uIWidgetWidget:addAnchor(AnchorVerticalCenter, tostring(subId), AnchorVerticalCenter)
	uIWidgetWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
	uIWidgetWidget:setMarginLeft(3)

	subWidget.ExternalArrow = uIWidgetWidget

	function subWidget.Button.onClick()
		waitingInitialHome = false

		var_0_170()
		disableAllButtons()
		resetStoreFilterDefaults()

		local selectedOption = controllerShop.ui.selectedOption

		closeCategoryButtons()
		parent.Button:setChecked(false)
		parent.Button.Arrow:setVisible(false)
		subWidget.Button:setChecked(true)
		subWidget.ExternalArrow:setVisible(true)
		updateSelectedCategoryTextColor(nil, subWidget)

		controllerShop.ui.openedSubCategory = subWidget

		if selectedOption then
			selectedOption:hide()
		end

		if subWidget.open == "Home" then
			g_game.sendRequestStoreHome()
		else
			g_game.requestStoreOffers(subButton.text, "", 0, 1)
		end
	end

	if subId == 1 then
		subWidget:addAnchor(AnchorRight, "parent", AnchorRight)
		subWidget:addAnchor(AnchorTop, "parent", AnchorTop)
		subWidget:setMarginTop(20)
		subWidget:setMarginRight(1)
	else
		subWidget:addAnchor(AnchorRight, "parent", AnchorRight)
		subWidget:addAnchor(AnchorTop, tostring(subId - 1), AnchorBottom)
		subWidget:setMarginTop(-1)
		subWidget:setMarginRight(1)
	end

	return subWidget
end

local function createSubCategoryRail(parent)
	if parent.SubCategoryRail or not parent.subCategoriesSize or parent.subCategoriesSize <= 0 then
		return
	end

	local rail = g_ui.createWidget("UIWidget", parent)

	rail:setId("SubCategoryRail")
	rail:setSize(string.format("12 %d", parent.subCategoriesSize * 20))
	rail:setPhantom(true)
	rail:setImageSource("/game_store/images/container-arrow")
	rail:setImageBorder(5)
	rail:addAnchor(AnchorLeft, "parent", AnchorLeft)
	rail:addAnchor(AnchorTop, "parent", AnchorTop)
	rail:setMarginLeft(1)
	rail:setMarginTop(21)
	rail:setVisible(false)

	parent.SubCategoryRail = rail
end

local function updateSearchClearButtonVisual()
	if not controllerShop.ui then
		return
	end

	local edit = controllerShop.ui.SearchEdit
	local btn = controllerShop.ui.SearchClearButton

	if not edit or not btn then
		return
	end

	if (edit:getText() or ""):trim() == "" then
		btn:setImageClip("0 40 20 20")
		btn:setEnabled(false)
	else
		btn:setImageClip("0 0 20 20")
		btn:setEnabled(true)
	end
end

controllerShop = Controller:new()

g_ui.importStyle("style/ui.otui")
g_ui.importStyle("style/auctioncharacter.otui")
controllerShop:setUI("game_store")

function controllerShop.onInit(unusedArgument)
	controllerShop.ui:hide()

	for k, v in pairs({
		{
			"Most Popular First",
			"MostPopularFirst"
		},
		{
			"Alphabetically",
			"Alphabetically"
		},
		{
			"Newest First",
			"NewestFirst"
		}
	}) do
		controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.MostPopularFirst:addOption(v[1], v[2])
	end

	function controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.showAll.onOptionChange(widget, text, data)
		if widget._suppressStoreFilterRequest then
			return
		end

		requestStoreOffersFromFilters()
	end

	function controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.MostPopularFirst.onOptionChange(widget, text, data)
		if widget._suppressStoreSortRequest then
			return
		end

		requestStoreOffersFromFilters()
	end

	controllerShop.ui.transferPoints.onClick = transferPoints

	function controllerShop.ui.panelItem.listProduct.onChildFocusChange(arg_135_0, anim)
		if var_0_23 then
			return
		end

		if var_0_27 and anim then
			var_0_27.userFocused = true
		end

		var_0_39()

		if g_clock.millis() - var_0_29 >= var_0_35 then
			if anim and not anim:isDestroyed() then
				chooseOffert(arg_135_0, anim)
			end

			return
		end

		var_0_21 = scheduleEvent(function()
			var_0_21 = nil

			if var_0_23 then
				return
			end

			if not anim or anim:isDestroyed() then
				return
			end

			chooseOffert(arg_135_0, anim)
		end, var_0_36)
	end

	controllerShop.ui.HomePanel.HomeRecentlyAdded.HomeProductos.onChildFocusChange = chooseHome

	local var_132_0 = getHomeBannerWidget()

	if var_132_0 then
		var_132_0.onClick = onClickHomeBanner
	end

	function controllerShop.ui.SearchEdit.onKeyDown(unusedArgument, keyCode, unusedArgument)
		if g_keyboard.isEnterKey(keyCode) then
			search()

			return true
		end

		return false
	end

	function controllerShop.ui.SearchEdit.onTextChange()
		updateSearchClearButtonVisual()
	end

	local SearchClearButton = controllerShop.ui.SearchClearButton

	function SearchClearButton.onMousePress(arg_139_0, unusedArgument, arg_139_2)
		if not arg_139_0:isEnabled() then
			return
		end

		if arg_139_2 == MouseLeftButton then
			arg_139_0:setImageClip("0 20 20 20")
		end
	end

	function SearchClearButton.onMouseRelease(unusedArgument, unusedArgument, unusedArgument)
		updateSearchClearButtonVisual()
	end

	function SearchClearButton.onClick()
		if not SearchClearButton:isEnabled() then
			return
		end

		controllerShop.ui.SearchEdit:setText("")
		search()
		updateSearchClearButtonVisual()
	end

	updateSearchClearButtonVisual()
	controllerShop:registerEvents(g_game, {
		onParseStoreGetCoin = onParseStoreGetCoin,
		onParseStoreGetCategories = onParseStoreGetCategories,
		onParseStoreCreateHome = onParseStoreCreateHome,
		onParseStoreCreateProducts = onParseStoreCreateProducts,
		onParseStoreGetHistory = onParseStoreGetHistory,
		onParseStoreGetPurchaseStatus = onParseStoreGetPurchaseStatus,
		onParseStoreOfferDescriptions = onParseStoreOfferDescriptions,
		onParseStoreError = onParseStoreError,
		onParseStoreRequestPurchaseData = onParseStoreRequestPurchaseData,
		onHirelingNameChange = onHirelingNameChange,
		onStoreInit = onStoreInit,
		onAuctionCharacterCheckRequirements = onAuctionCharacterCheckRequirements,
		onAuctionCharacterItemsInventory = onAuctionCharacterItemsInventory,
		onAuctionCharacterItemsStore = onAuctionCharacterItemsStore,
		onAuctionCharacterArguments = onAuctionCharacterArguments
	})
end

function controllerShop.onGameStart(unusedArgument)
	oldProtocol = false
end

function controllerShop.onGameEnd(unusedArgument)
	if controllerShop.ui then
		hide()
	end

	resetStoreSessionFlags()
	clearPurchaseCompleteModalEvents(messageBox)
	releasePurchaseCompleteModalRefs(messageBox)
	destroyWindow({
		transferPointsWindow,
		changeNameWindow,
		worldTransferWindow,
		hirelingNameWindow,
		acceptWindow,
		processingWindow,
		messageBox,
		checksAuctionCharacterWindow,
		configAuctionCharacterWindow
	})

	transferPointsWindow = nil
	changeNameWindow = nil
	worldTransferWindow = nil
	hirelingNameWindow = nil
	acceptWindow = nil
	processingWindow = nil
	messageBox = nil
	checksAuctionCharacterWindow = nil
	configAuctionCharacterWindow = nil
	auctionCharacterWindowStep = 0
end

function controllerShop.onTerminate(unusedArgument)
	destroyWindow({
		transferPointsWindow,
		changeNameWindow,
		worldTransferWindow,
		hirelingNameWindow,
		acceptWindow,
		processingWindow,
		messageBox,
		checksAuctionCharacterWindow,
		configAuctionCharacterWindow
	})

	checksAuctionCharacterWindow = nil
	configAuctionCharacterWindow = nil
	auctionCharacterWindowStep = 0
end

function onStoreInit(url, unusedArgument)
	GameStore.website.IMAGES_URL = url
end

function onParseStoreGetCoin(getTibiaCoins, getTransferableCoins)
	a0xF2 = false

	controllerShop.ui.lblCoins.lblTibiaCoins:setText(formatNumberWithCommas(getTibiaCoins))
	controllerShop.ui.lblCoins.lblTibiaTransfer:setText(string.format("(Including: %s", formatNumberWithCommas(getTransferableCoins)))
	updateAuctionCharacterTransferableBalance()
end

function onParseStoreOfferDescriptions(offerId, description)
	var_0_31[offerId] = nil
	var_0_31[normalizeStoreOfferId(offerId)] = nil

	cacheOfferDescription(offerId, description)
	addEvent(function()
		if not controllerShop.ui or not controllerShop.ui.panelItem then
			return
		end

		local var_148_0 = var_0_28

		if var_148_0 and offerIdBelongsToProduct(var_148_0, offerId) then
			local var_148_1 = false
			local subOffers = var_148_0.subOffers or {
				var_148_0
			}

			for _, so in ipairs(subOffers) do
				if so.disabled then
					var_148_1 = true

					break
				end
			end

			local var_148_3 = var_148_1 and "The product is currently not available for this character. See the buy button tooltip for details." or nil

			renderStoreDescription(controllerShop.ui.panelItem, description, var_148_3, var_148_0)
		end
	end)
end

function onParseStoreGetPurchaseStatus(purchaseStatus)
	clearPurchaseCompleteModalEvents(messageBox)
	destroyWindow({
		processingWindow,
		messageBox
	})
	hideStoreForOverlay()

	messageBox = g_ui.createWidget("confirmarSHOP", g_ui.getRootWidget())

	if not messageBox then
		restoreStoreAfterOverlay()

		return
	end

	local text = purchaseStatus

	if not text or text == "" then
		text = tr("Purchase completed successfully.")
	end

	local box = messageBox:recursiveGetChildById("Box")

	if box then
		box:setTextAutoResize(true)
		box:setTextWrap(true)
		box:setWidth(192)
		box:setText(text)

		if box.resizeToText then
			box:resizeToText()
		end

		if box.setTextAlign then
			box:setTextAlign(AlignTopLeft)
		end
	end

	local dragonHeader = messageBox:recursiveGetChildById("dragonHeader")

	if dragonHeader then
		dragonHeader:raise()
	end

	g_modalManager.show(messageBox)

	function messageBox.onEscape()
		clearPurchaseCompleteModalEvents(messageBox)
		closePurchaseSuccessModal(messageBox)
	end

	local function var_149_3()
		if not messageBox or messageBox:isDestroyed() or messageBox._purchaseClosing then
			return
		end

		messageBox._purchaseClosing = true

		local buttonAnimation = messageBox:recursiveGetChildById("buttonAnimation")

		if buttonAnimation and not buttonAnimation:isDestroyed() then
			buttonAnimation:disable()

			local animation = buttonAnimation:getChildById("animation")

			if animation and not animation:isDestroyed() then
				animation:setImageSource("/images/animations/animation-purchasecomplete-pressed")
			end
		end

		if messageBox._closeEvent then
			removeEvent(messageBox._closeEvent)
		end

		messageBox._closeEvent = controllerShop:scheduleEvent(function()
			messageBox._closeEvent = nil

			closePurchaseSuccessModal(messageBox)
		end, 2000)
	end

	messageBox.onEnter = var_149_3

	local buttonAnimation = messageBox:recursiveGetChildById("buttonAnimation")

	if buttonAnimation then
		buttonAnimation.onClick = var_149_3
	end
end

local var_0_176 = {
	skipPreview = true
}
local var_0_177 = {}

local function var_0_178(parentWidget, arg_153_1, arg_153_2)
	if not parentWidget or not arg_153_1 then
		return
	end

	arg_153_2 = arg_153_2 or var_0_177

	local subOffers = arg_153_1.subOffers or {
		arg_153_1
	}
	local var_153_1 = false

	for i, subOffer in ipairs(subOffers) do
		if subOffer.disabled then
			var_153_1 = true

			break
		end
	end

	local var_153_2 = g_ui.createWidget(var_153_1 and STORE_ROW_UNAVAILABLE or STORE_ROW_AVAILABLE, parentWidget)

	if not var_153_2 then
		return
	end

	var_0_131(var_153_2, false)

	var_153_2.product, var_153_2.type = arg_153_1, arg_153_1.type

	local lblName = var_153_2:getChildById("lblName")

	if lblName then
		lblName:setText(arg_153_1.name)
		lblName:setTextAlign(AlignTopLeft)
		lblName:setMarginRight(4)
		lblName:setHeight(34)
	end

	applyOfferStateVisuals(var_153_2, arg_153_1)

	local var_153_4 = arg_153_1.subOffers or {
		arg_153_1
	}
	local validSubOffers = 0

	for unusedValue, entry in ipairs(var_153_4) do
		if not entry.id or entry.id ~= 0 then
			validSubOffers = validSubOffers + 1
		end
	end

	local row = var_153_2:getChildById("StackOffers")

	if row then
		for unusedValue, subOffer in ipairs(var_153_4) do
			if subOffer.id and subOffer.id == 0 then
				-- block empty
			else
				local offerI = g_ui.createWidget("stackOfferPanel", row)

				if not offerI then
					-- block empty
				else
					offerI.offerId = subOffer.id

					if subOffer.disabled then
						offerI:disable()
					end

					local priceLabel = offerI:getChildById("lblPrice")

					if priceLabel then
						priceLabel:setText(formatNumberWithCommas(tonumber(subOffer.price) or 0))
						priceLabel:setColor("#c0c0c0")

						if subOffer.coinType == GameStore.CoinType.Transferable then
							priceLabel:setIcon("/images/icons/icon-tibiacointransferable")
						end
					end

					local shouldShowCount = validSubOffers > 1 or (subOffer.count or 1) > 1
					local offerI = offerI:getChildById("count")

					if offerI then
						if shouldShowCount and subOffer.count and subOffer.count > 0 then
							offerI:setText(subOffer.count .. "x")
						else
							offerI:setText("")
						end
					end
				end
			end
		end
	end

	var_153_2._previewData = arg_153_1._cachedProductData

	if var_153_2._previewData == nil then
		var_153_2._previewData = getProductData(arg_153_1)
		arg_153_1._cachedProductData = var_153_2._previewData
	end

	if not arg_153_2.skipPreview and var_153_2._previewData then
		createProductImage(var_153_2:getChildById("image"), var_153_2._previewData)

		var_153_2._previewReady = true
	end

	return var_153_2
end

local function var_0_179(arg_154_0, arg_154_1)
	if not arg_154_0 or not arg_154_1 or arg_154_1:isDestroyed() then
		return false
	end

	local y = arg_154_0:getY()
	local height = arg_154_0:getHeight()
	local var_154_2 = arg_154_1:getY()

	return y < var_154_2 + arg_154_1:getHeight() and var_154_2 < y + height
end

local function var_0_180(arg_155_0)
	if not arg_155_0 or arg_155_0._previewReady or not arg_155_0._previewData then
		return
	end

	table.insert(subOffers, arg_155_0)
end

local function var_0_181(arg_156_0)
	if arg_156_0 ~= var_0_22 then
		subOffers = {}

		return
	end

	local var_156_0 = controllerShop.ui and controllerShop.ui.panelItem and controllerShop.ui.panelItem.listProduct

	if not var_156_0 or var_156_0:isDestroyed() then
		subOffers = {}

		return
	end

	local var_156_1 = {}
	local validSubOffers = {}

	for _, subOffer in ipairs(subOffers) do
		if subOffer and not subOffer:isDestroyed() and not subOffer._previewReady and subOffer._previewData then
			if var_0_179(var_156_0, subOffer) then
				table.insert(var_156_1, subOffer)
			else
				table.insert(validSubOffers, subOffer)
			end
		end
	end

	local var_156_3 = g_clock.millis()
	local var_156_4 = {}

	local function var_156_5(validSubOffers)
		for _, subOffer in ipairs(validSubOffers) do
			if g_clock.millis() - var_156_3 >= var_0_33 then
				table.insert(var_156_4, subOffer)
			elseif not subOffer:isDestroyed() and not subOffer._previewReady and subOffer._previewData then
				createProductImage(subOffer:getChildById("image"), subOffer._previewData)

				subOffer._previewReady = true
			end
		end
	end

	var_156_5(var_156_1)
	var_156_5(validSubOffers)

	subOffers = var_156_4

	var_0_38("previewBatch", var_156_3)

	if #subOffers > 0 then
		var_0_25 = scheduleEvent(function()
			var_0_25 = nil

			var_0_181(arg_156_0)
		end, 1)
	end
end

local function var_0_182(arg_159_0)
	if var_0_25 or #subOffers == 0 then
		return
	end

	var_0_25 = scheduleEvent(function()
		var_0_25 = nil

		var_0_181(arg_159_0)
	end, 1)
end

local function var_0_183(arg_161_0, arg_161_1)
	local var_161_0 = {
		tonumber(pendingStoreFocusOfferId) or 0,
		tonumber(arg_161_1 and arg_161_1.redirectId) or 0
	}

	for unusedValue, entry in ipairs(var_161_0) do
		if entry > 0 then
			local var_161_1 = normalizeStoreOfferId(entry)

			for unusedValue, entry in ipairs(arg_161_0) do
				for unusedValue, iter_161_5 in ipairs(entry.subOffers or {
					entry
				}) do
					if normalizeStoreOfferId(iter_161_5.id) == var_161_1 then
						return entry
					end
				end
			end
		end
	end

	return arg_161_0[1]
end

local function var_0_184(arg_162_0, arg_162_1, arg_162_2)
	if arg_162_0.focused or arg_162_0.userFocused or not arg_162_2 or arg_162_2:isDestroyed() then
		return
	end

	arg_162_0.focused = true
	var_0_23 = true

	arg_162_1:updateLayout()
	arg_162_1:focusChild(arg_162_2)
	arg_162_1:ensureChildVisible(arg_162_2)

	var_0_23 = false
end

local function var_0_185(arg_163_0)
	if not arg_163_0 or arg_163_0:isDestroyed() then
		return
	end

	local scrollSpacer = arg_163_0:getChildById("_scrollSpacer")

	if scrollSpacer then
		scrollSpacer:destroy()
	end
end

local function var_0_186(arg_164_0, arg_164_1)
	var_0_23 = false

	enableAllButtons()
	var_0_185(arg_164_1)

	if arg_164_0 ~= var_0_22 then
		var_0_27 = nil

		return
	end

	if not controllerShop.ui or not arg_164_1 or arg_164_1:isDestroyed() then
		var_0_27 = nil

		return
	end

	showPanel("panelItem")
	fixServerNoSend0xF2()

	if var_0_32 and var_0_27 and var_0_27.startedAt then
		var_0_38("listRender complete", var_0_27.startedAt)
	end

	var_0_27 = nil

	GameStore.requestIncrementalGC()
end

local function var_0_187(arg_165_0, arg_165_1, arg_165_2, parentWidget, arg_165_4)
	if arg_165_0 ~= var_0_22 then
		var_0_23 = false

		return
	end

	if not controllerShop.ui or not parentWidget or parentWidget:isDestroyed() then
		var_0_23 = false
		var_0_27 = nil

		if controllerShop.ui then
			enableAllButtons()
		end

		return
	end

	var_0_185(parentWidget)

	local var_165_0 = g_clock.millis()
	local var_165_1 = 0
	local var_165_2 = arg_165_4
	local var_165_3 = arg_165_4 == 1 and var_0_34 or 1

	var_0_23 = true

	while var_165_2 <= #arg_165_2 do
		local var_165_4 = arg_165_2[var_165_2]
		local var_165_5, var_165_6 = pcall(var_0_178, parentWidget, var_165_4, var_0_176)

		if not var_165_5 then
			g_logger.warning("[game_store] Failed to render offer row: " .. tostring(var_165_6))
		elseif var_165_6 then
			var_0_180(var_165_6)

			if var_165_4 == arg_165_1.initialProduct then
				var_0_184(arg_165_1, parentWidget, var_165_6)
			end
		end

		var_165_2 = var_165_2 + 1
		var_165_1 = var_165_1 + 1

		if var_165_3 <= var_165_1 and g_clock.millis() - var_165_0 >= var_0_33 then
			break
		end
	end

	var_0_23 = false

	var_0_38(string.format("rowBatch start=%d count=%d", arg_165_4, var_165_1), var_165_0)
	var_0_182(arg_165_0)

	if var_165_2 <= #arg_165_2 then
		local var_165_7 = #arg_165_2 - (var_165_2 - 1)

		if var_165_7 > 0 then
			local uIWidgetWidget = g_ui.createWidget("UIWidget", parentWidget)

			if uIWidgetWidget then
				uIWidgetWidget:setId("_scrollSpacer")
				uIWidgetWidget:setPhantom(true)
				uIWidgetWidget:setFocusable(false)
				uIWidgetWidget:setHeight(var_165_7 * 82)
			end
		end

		var_0_24 = scheduleEvent(function()
			var_0_24 = nil

			var_0_187(arg_165_0, arg_165_1, arg_165_2, parentWidget, var_165_2)
		end, 1)

		return
	end

	var_0_24 = nil

	var_0_186(arg_165_0, parentWidget)
end

function onParseStoreCreateProducts(storeProducts)
	local numericValue = tonumber(storeProducts.windowType) or storeProducts.categoryName == "Search" and 2 or 0

	if numericValue == 3 then
		return onParseStoreCreateHome(storeProducts)
	end

	if waitingInitialHome and numericValue == 0 and not storeRedirectAwaitingOffers then
		return
	end

	if storeRedirectAwaitingOffers and (numericValue == 0 or numericValue == 2) then
		waitingInitialHome = false

		if (tonumber(storeProducts.redirectId) or 0) <= 0 and storeProducts.categoryName == "Exclusive Offers" then
			return
		end

		storeRedirectAwaitingOffers = false

		showPanel("panelItem")
	end

	local showAll = controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.showAll

	configureTopCategoryFilter(showAll, storeProducts.menuFilter)

	reasonCategory = storeProducts.disableReasons

	syncSelectedCategoryByName(storeProducts.categoryName)
	var_0_41()
	var_0_128()

	local listProduct = controllerShop.ui.panelItem.listProduct

	listProduct:destroyChildren()

	if not storeProducts then
		return
	end

	local showAll = controllerShop.ui.panelItem.storeFilterBar.comboBoxContainer.showAll
	local currentOption = showAll and showAll:getCurrentOption() or nil
	local var_167_5 = currentOption and currentOption.text or "Show All"
	local var_167_6 = var_167_5 ~= "Show All" and var_167_5 or ""
	local var_167_7 = getStoreSortOrderFromUi()
	local var_167_8 = applyClientSideOfferFilters(storeProducts.offers, var_167_6, var_167_7)
	local var_167_9 = 82
	local var_167_10 = #var_167_8

	if var_167_10 > 0 then
		local uIWidgetWidget = g_ui.createWidget("UIWidget", listProduct)

		if uIWidgetWidget then
			uIWidgetWidget:setId("_scrollSpacer")
			uIWidgetWidget:setPhantom(true)
			uIWidgetWidget:setFocusable(false)
			uIWidgetWidget:setHeight(var_167_10 * var_167_9)
		end
	end

	local var_167_12 = var_0_22
	local var_167_13 = {
		userFocused = false,
		focused = false,
		initialProduct = var_0_183(var_167_8, storeProducts),
		startedAt = g_clock.millis()
	}

	var_0_27 = var_167_13
	pendingStoreFocusOfferId = nil

	showPanel("panelItem")
	enableAllButtons()

	if var_167_13.initialProduct then
		chooseOffert(listProduct, {
			product = var_167_13.initialProduct
		})
	end

	var_0_187(var_167_12, var_167_13, var_167_8, listProduct, 1)
end

function onParseStoreCreateHome(offer)
	waitingInitialHome = false

	if storeRedirectAwaitingOffers then
		storeRedirectAwaitingOffers = false
		pendingStoreFocusOfferId = nil

		showPanel("panelItem")

		return
	end

	syncSelectedCategoryByName("Home")

	local homeProductos = controllerShop.ui.HomePanel.HomeRecentlyAdded.HomeProductos

	clearHomeProducts()

	for index, offer in ipairs(offer.offers) do
		local var_168_1 = offer.subOffers or {
			offer
		}
		local var_168_2 = false

		for unusedValue, entry in ipairs(var_168_1) do
			if entry.disabled then
				var_168_2 = true

				break
			end
		end

		local row = g_ui.createWidget(var_168_2 and STORE_ROW_UNAVAILABLE or STORE_ROW_AVAILABLE, homeProductos)

		var_0_131(row, false, false)
		row:setSize("250 78")

		if index % 2 == 1 then
			row:setMarginLeft(2)
			row:setMarginTop(2)
			row:setMarginRight(5)
			row:setMarginBottom(2)
		else
			row:setMarginLeft(5)
			row:setMarginTop(2)
			row:setMarginBottom(2)
		end

		row.product, row.type = offer, offer.type

		local lblName = row:getChildById("lblName")

		lblName:setText(offer.name)
		lblName:setTextAlign(AlignTopLeft)
		lblName:setMarginRight(10)
		applyOfferStateVisuals(row, offer)

		local stackOffers = row:getChildById("StackOffers")

		stackOffers:destroyChildren()

		local var_168_6 = offer.subOffers or {
			offer
		}
		local validSubOffers = {}

		for unusedValue, entry in ipairs(var_168_6) do
			if not entry.id or entry.id ~= 0 then
				table.insert(validSubOffers, entry)
			end
		end

		local visibleSubOffers = 0

		for unusedValue, subOffer in ipairs(validSubOffers) do
			local subOfferWidget = g_ui.createWidget("stackOfferPanel", stackOffers)

			subOfferWidget.lblPrice:setText(formatNumberWithCommas(tonumber(subOffer.price) or 0))

			if (#validSubOffers > 1 or (subOffer.count or 1) > 1) and subOffer.count and subOffer.count > 0 then
				subOfferWidget.count:setText(subOffer.count .. "x")
			else
				subOfferWidget.count:setText("")
			end

			if subOffer.coinType == GameStore.CoinType.Transferable then
				subOfferWidget.lblPrice:setIcon("/images/icons/icon-tibiacointransferable")
			else
				subOfferWidget.lblPrice:setIcon("/images/icons/icon-tibiacoin")
			end

			visibleSubOffers = visibleSubOffers + 1
		end

		stackOffers:setHeight(math.max(20, visibleSubOffers * 24))

		local data = offer._cachedProductData

		if data == nil then
			data = getProductData(offer)
			offer._cachedProductData = data
		end

		if data then
			createProductImage(row:getChildById("image"), data)
		end
	end

	function homeProductos.onMouseMove(widget, mousePos)
		updateHomeHoveredRow(widget, mousePos)

		return false
	end

	function homeProductos.onHoverChange(widget, hovered)
		if hovered then
			updateHomeHoveredRow(widget, g_window.getMousePosition())

			return
		end

		if row and not row:isDestroyed() then
			row._isHovered = false

			refreshRowHoverBorder(row)
		end

		row = nil
	end

	bannersHome = offer.banners or {}

	if #bannersHome > 0 then
		currentIndex = math.random(1, #bannersHome)

		local homeBanner = getHomeBannerWidget()

		if homeBanner then
			setImagenHttp(homeBanner, bannersHome[currentIndex].image, false, true)
		end
	end

	enableAllButtons()
	showPanel("HomePanel")
	fixServerNoSend0xF2()
end

function onParseStoreGetHistory(currentPage, pageCount, historyData)
	local transferHistory = controllerShop.ui.transferHistory.historyPanel

	transferHistory:destroyChildren()
	controllerShop.ui.transferHistory.lblPage:setText(string.format("Page %d/%d", currentPage + 1, pageCount))
	controllerShop.ui.transferHistory.btnPrevPage:setVisible(currentPage > 0)
	controllerShop.ui.transferHistory.btnNextPage:setVisible(pageCount > currentPage + 1)

	for i, data in ipairs(historyData) do
		local row = g_ui.createWidget("StoreHistoryData", transferHistory)

		row._normalBackground = i % 2 == 1 and HISTORY_ROW_COLOR_A or HISTORY_ROW_COLOR_B

		row:setBackgroundColor(row._normalBackground)

		function row.onFocusChange(widget, focused)
			widget:setBackgroundColor(focused and HISTORY_ROW_COLOR_SELECTED or widget._normalBackground)
			widget.date:setColor(focused and "#f4f4f4" or "#c0c0c0")
			widget.Description:setColor(focused and "#f4f4f4" or "#c0c0c0")
		end

		row.date:setText(convert_timestamp(data[1]))
		row.date:setColor("#c0c0c0")

		local balance = data[3]
		local balanceText = formatNumberWithCommas(balance)

		if balance > 0 then
			balanceText = "+" .. balanceText
		end

		row.Balance:setText(balanceText)
		row.Balance:setColor(balance < 0 and "#D33C3C" or "#44ad25")
		row.Description:setText(data[5])
		row.Description:setColor("#c0c0c0")
		row.Balance:setIcon(data[4] == GameStore.CoinType.Transferable and "/images/icons/icon-tibiacointransferable" or "/images/icons/icon-tibiacoin")
	end

	clearSelectedStoreCategory()
	showPanel("transferHistory")
end

function onParseStoreGetCategories(buttons)
	if controllerShop.ui.listCategory:getChildCount() > 0 then
		if pendingStoreRedirect then
			addEvent(function()
				executePendingStoreRedirect()
			end)
		end

		return
	end

	controllerShop.ui.listCategory:destroyChildren()

	local categories = {}
	local categoryOrder = {}

	if not oldProtocol then
		categories.Home = {
			state = 0,
			name = "Home",
			subCategories = {},
			icons = {
				[1] = "icon-store-home.png"
			}
		}

		table.insert(categoryOrder, "Home")
	end

	local subcategories = {}

	for _, button in ipairs(buttons) do
		if not button.parent then
			categories[button.name] = button
			categories[button.name].subCategories = {}

			table.insert(categoryOrder, button.name)
		else
			table.insert(subcategories, button)
		end
	end

	for _, subcat in ipairs(subcategories) do
		if categories[subcat.parent] then
			table.insert(categories[subcat.parent].subCategories, subcat)
		end
	end

	for _, categoryName in ipairs(categoryOrder) do
		local category = categories[categoryName]
		local widget = g_ui.createWidget("storeCategory", controllerShop.ui.listCategory)

		widget:setId(category.name)

		if category.icons[1] == "icon-store-home.png" then
			widget.Button.Icon:setIcon("/game_store/images/icon-store-home")
		else
			setImagenHttp(widget.Button.Icon, "/13/" .. category.icons[1], true, true)
		end

		widget.Button.Title:setText(category.name)

		widget.open = category.name

		var_0_163(widget.Button)

		if #category.subCategories > 0 then
			widget.subCategories = category.subCategories
			widget.subCategoriesSize = #category.subCategories

			widget.Button.Arrow:setVisible(true)
			createSubCategoryRail(widget)

			for subId, subButton in ipairs(category.subCategories) do
				local subWidget = createSubWidget(widget, subId, {
					text = subButton.name,
					icon = "/13/" .. subButton.icons[1],
					open = subButton.name
				})
			end
		end

		widget:setMarginTop(10)

		function widget.Button.onClick()
			waitingInitialHome = false

			var_0_170()
			disableAllButtons()
			resetStoreFilterDefaults()

			local parent = widget
			local oldOpen = controllerShop.ui.openedCategory
			local panel = controllerShop.ui.panelItem
			local detail = getPanelItemDetailsContent(panel)

			if detail then
				local image = detail:getChildById("image")
				local stack = detail:getChildById("StackOffers")

				if image then
					clearPendingHttpForChildren(image)
					image:destroyChildren()
					image:setImageSource("/images/ui/1pixel-down-frame")
				end

				if stack then
					stack:destroyChildren()
				end
			end

			if oldOpen and oldOpen ~= parent then
				if oldOpen.Button then
					oldOpen.Button:setChecked(false)
					oldOpen.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-down")
				end

				close(oldOpen)
			end

			if parent.subCategoriesSize then
				parent.closedSize = 22
				parent.openedSize = parent.closedSize + parent.subCategoriesSize * 20

				open(parent)
			else
				widget.Button:setChecked(true)
				widget.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-right")
				widget.Button.Arrow:setVisible(false)

				controllerShop.ui.openedSubCategory = nil

				updateSelectedCategoryTextColor(widget, nil)
			end

			if controllerShop.ui.selectedOption then
				controllerShop.ui.selectedOption:hide()
			end

			if category.name == "Home" then
				clearHomeProducts()
				g_game.sendRequestStoreHome()
			else
				g_game.requestStoreOffers(category.name, "", 0, 1)
			end

			controllerShop.ui.openedCategory = parent
		end
	end

	local firstCategory = controllerShop.ui.listCategory:getChildByIndex(1)

	if pendingStoreRedirect then
		addEvent(function()
			executePendingStoreRedirect()
		end)
	elseif controllerShop.ui.openedCategory == nil and firstCategory then
		controllerShop.ui.openedCategory = firstCategory

		firstCategory.Button:onClick()
	end
end

function onParseStoreError(errorMessage, errorType)
	pendingStoreRedirect = nil
	storeRedirectAwaitingOffers = false
	pendingStoreFocusOfferId = nil
	waitingInitialHome = false

	enableAllButtons()
	destroyWindow({
		processingWindow,
		acceptWindow,
		messageBox
	})
	hideStoreForOverlay()

	local errorBox

	local function okCallback()
		destroyWindow({
			errorBox
		})
		enableAllButtons()
		recoverStoreOpenEnvironment()
		restoreStoreAfterOverlay()
		fixServerNoSend0xF2()
	end

	errorBox = displayGeneralBox(controllerShop.ui:getText(), errorMessage, {
		{
			text = tr("Ok"),
			callback = okCallback
		}
	}, okCallback, okCallback)

	g_modalManager.show(errorBox)
end

function onParseStoreRequestPurchaseData(offerId, offerType, data)
	destroyWindow(processingWindow)

	processingWindow = nil

	restoreStoreAfterOverlay()

	if offerType == GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_NAMECHANGE then
		displayChangeName(offerId)
	elseif offerType == GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_WORLD_TRANSFER then
		displayWorldTransfer(offerId, data)
	elseif offerType == GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_HIRELING then
		displayHirelingName(offerId)
	end
end

function hide()
	if not controllerShop.ui then
		return
	end

	cancelStoreWatchdogEvent()
	resetStoreLuaFlags()
	resetStoreUiOnClose()
	g_modalManager.hide(controllerShop.ui)
	controllerShop.ui:hide()
end

function toggle()
	if not controllerShop.ui then
		return
	end

	recoverStoreOpenEnvironment()

	if controllerShop.ui:isVisible() then
		if g_modalManager.isModal(controllerShop.ui) and not storeHiddenForOverlay then
			return hide()
		end

		g_modalManager.hide(controllerShop.ui)
		controllerShop.ui:hide()

		storeHiddenForOverlay = false
	end

	show()
end

function show()
	if not controllerShop.ui then
		return
	end

	gameOpenStore()
end

function gameOpenStore(skipHomeRequest)
	if not controllerShop.ui then
		return
	end

	recoverStoreOpenEnvironment()

	if skipHomeRequest or pendingStoreRedirect then
		waitingInitialHome = false
	end

	showStoreWindow()
	g_game.openStore()

	if not skipHomeRequest and controllerShop.ui.listCategory:getChildCount() > 0 then
		waitingInitialHome = true

		syncSelectedCategoryByName("Home")
		g_game.sendRequestStoreHome()
	end

	if not skipHomeRequest and not pendingStoreRedirect then
		controllerShop:scheduleEvent(function()
			if pendingStoreRedirect then
				return
			end

			if not controllerShop.ui or not controllerShop.ui:isVisible() then
				return
			end

			if controllerShop.ui.listCategory:getChildCount() == 0 then
				g_game.sendRequestStoreHome()

				local packet1 = GameStore.RecivedPackets.C_OpenStore

				g_logger.warning(string.format("[game_store BUG] Check 0x%X (%d) L827", packet1, packet1))
			end
		end, 1000, STORE_WATCHDOG_EVENT)
	end
end

function executePendingStoreRedirect()
	if not pendingStoreRedirect then
		return
	end

	if not controllerShop.ui or controllerShop.ui.listCategory:getChildCount() == 0 then
		return
	end

	local pending = pendingStoreRedirect

	pendingStoreRedirect = nil
	waitingInitialHome = false

	pending.requestFn()
end

local function openStoreRedirect(label, requestFn, delay, focusOfferId)
	if not controllerShop.ui or not requestFn then
		return
	end

	pendingStoreRedirect = {
		label = label,
		requestFn = requestFn
	}

	local categoriesReady = controllerShop.ui.listCategory:getChildCount() > 0

	prepareStoreRedirectUi(focusOfferId)

	if not categoriesReady then
		g_game.openStore()

		delay = delay or 300
	else
		delay = delay or 50
	end

	controllerShop:scheduleEvent(function()
		executePendingStoreRedirect()
	end, delay, "openStoreRedirect_" .. tostring(label))
end

function openOfferById(offerId)
	if not offerId or offerId <= 0 then
		return
	end

	openStoreRedirect("offerById:" .. offerId, function()
		g_game.sendRequestStoreOfferById(offerId)
	end, nil, offerId)
end

function openPremiumBoost()
	openStoreRedirect("premiumBoost", function()
		g_game.sendRequestStorePremiumBoost()
	end, nil, 5)
end

local USEFUL_THINGS_FOCUS_OFFERS = {
	[0] = 582,
	583,
	579,
	570,
	652,
	654,
	655,
	653,
	656,
	657,
	658,
	492,
	651,
	581
}

function openUsefulThings(offerId)
	offerId = offerId or 0

	openStoreRedirect("usefulThings:" .. tostring(offerId), function()
		g_game.sendRequestUsefulThings(offerId)
	end, nil, USEFUL_THINGS_FOCUS_OFFERS[offerId])
end

function openStoreByRedirect(numericValue)
	numericValue = tonumber(numericValue) or 0

	if numericValue <= 0 then
		return
	end

	openStoreRedirect("redirect:" .. tostring(numericValue), function()
		g_game.sendRequestUsefulThings(numericValue)
	end)
end

function openWeeklyTaskExpansion()
	openUsefulThings(StoreConst.WeeklyTaskExpansion)
end

function openCharmExpansion()
	openUsefulThings(StoreConst.CharmExpansion)
end

function openCharmPoints()
	openOfferById(StoreConst.MajorCharmPoints)
end

function openHirelingSexChange()
	openOfferById(269)
end

function openStoreCategory(categoryName, subCategory, sortOrder, serviceType)
	if not categoryName or categoryName == "" then
		return
	end

	openStoreRedirect("category:" .. categoryName, function()
		g_game.requestStoreOffers(categoryName, subCategory or "", sortOrder or 0, serviceType or 0)
	end)
end

function getCoinsWebsite()
	if GameStore.website.WEBSITE_GETCOINS ~= "" then
		g_platform.openUrl(GameStore.website.WEBSITE_GETCOINS)
	else
		sendMessageBox("Error", "No data for store URL.")
	end
end

function toggleTransferHistory()
	if controllerShop.ui.transferHistory:isVisible() then
		if controllerShop.ui.openedCategory and controllerShop.ui.openedCategory:getId() == "Home" then
			showPanel("HomePanel")
		else
			showPanel("panelItem")
		end
	else
		var_0_170()
		clearSelectedStoreCategory()
		g_game.openTransactionHistory(HISTORY_ENTRIES_PER_PAGE)
	end
end

function requestTransactionHistory(widget)
	local currentPage, pageCount = getPageLabelHistory()
	local newPage = currentPage + (widget:getId() == "btnNextPage" and 1 or -1)

	if newPage > 0 and newPage <= pageCount then
		g_game.requestTransactionHistory(newPage - 1, HISTORY_ENTRIES_PER_PAGE)
	end
end

local function setOfferPanelPriceRow(offerPanel, offer, coinsBalance2, coinsBalance1)
	local pricePanel = offerPanel:getChildById("lblPrice")

	if not pricePanel then
		return
	end

	local row = pricePanel:getChildById("lblPriceRow")

	if not row then
		return
	end

	local priceText = row:getChildById("lblPriceText")
	local priceCoin = row:getChildById("lblPriceCoin")
	local isTransferable = offer.coinType == GameStore.CoinType.Transferable
	local currentBalance = isTransferable and coinsBalance1 or coinsBalance2
	local priceVal = tonumber(offer.price) or 0

	if priceText then
		priceText:setText(formatNumberWithCommas(priceVal))
		priceText:setColor("#c0c0c0")
	end

	if priceCoin then
		if isTransferable then
			priceCoin:setImageSource("/images/icons/icon-tibiacointransferable")
		else
			priceCoin:setImageSource("/images/icons/icon-tibiacoin")
		end

		priceCoin:setImageFixedRatio(true)
		priceCoin:setVisible(true)
	end

	local btnBuy = offerPanel:getChildById("btnBuy")

	if btnBuy then
		if currentBalance < priceVal then
			btnBuy:disable()
		else
			btnBuy:enable()
		end
	end
end

function chooseOffert(self, focusedChild)
	if not focusedChild then
		return
	end

	local product = focusedChild.product

	if not product then
		return
	end

	var_0_29 = g_clock.millis()

	local var_206_1 = var_0_32 and var_0_29 or nil

	var_0_28 = product

	local panel = controllerShop.ui.panelItem
	local var_206_3 = getPanelItemDetailsContent(panel)

	if not var_206_3 then
		return
	end

	local var_206_4 = var_0_110(var_206_3)

	if not var_206_4 then
		return
	end

	local lblName = var_206_4.lblName

	if lblName then
		lblName:setText(product.name)
	end

	local primaryOfferId = getPrimaryPurchasableOfferId(product)
	local description = product.description or getCachedOfferDescription(primaryOfferId)

	if description == "" then
		for _, subOffer in ipairs(product.subOffers or {}) do
			if subOffer.description and subOffer.description ~= "" then
				description = subOffer.description

				break
			end
		end
	end

	if not oldProtocol and primaryOfferId > 0 and description == "" and not var_0_31[primaryOfferId] then
		var_0_31[primaryOfferId] = true

		g_game.requestStoreOfferDescription(primaryOfferId)
	end

	renderStoreDescription(panel, description, nil, product)

	local subOffers = product.subOffers or {}
	local data = product._cachedProductData

	if data == nil then
		data = getProductData(product)
		product._cachedProductData = data
	end

	local imagePanel = var_206_4.image

	clearPendingHttpForChildren(imagePanel)

	if imagePanel then
		imagePanel:destroyChildren()
		imagePanel:setImageSource("/images/ui/1pixel-down-frame")

		if data then
			createProductImage(imagePanel, data, var_0_59)
		end
	end

	fixServerNoSend0xF2()

	local coinsBalance2, coinsBalance1 = getCoinsBalance()
	local offerStackPanel = var_206_4.StackOffers

	if not offerStackPanel then
		if var_206_1 then
			var_0_38("chooseOffert no stack", var_206_1)
		end

		return
	end

	offerStackPanel:destroyChildren()

	local offers = #subOffers > 0 and subOffers or {
		product
	}
	local validOffers = {}
	local showDisabledDescription = false

	for _, o in ipairs(offers) do
		if not o.id or o.id ~= 0 then
			table.insert(validOffers, o)
		end
	end

	for _, offer in ipairs(offers) do
		if offer.id and offer.id == 0 then
			-- block empty
		else
			local offerPanel = g_ui.createWidget("OfferPanel2", offerStackPanel)
			local btnBuyWidget = offerPanel:getChildById("btnBuy")

			if isConfigurableOffer(product, offer) then
				btnBuyWidget:setText(tr("Configure"))
			elseif #validOffers > 1 or (offer.count or 1) > 1 then
				btnBuyWidget:setText("Buy  " .. tostring(offer.count or 1))
			else
				btnBuyWidget:setText(tr("Buy"))
			end

			setOfferPanelPriceRow(offerPanel, offer, coinsBalance2, coinsBalance1)

			if offer.disabled then
				showDisabledDescription = true

				local btnBuy = offerPanel:getChildById("btnBuy")

				btnBuy:disable()
				btnBuy:setOpacity(0.8)

				if offer.reasonIdDisable or offer.reasonIdsDisable and #offer.reasonIdsDisable > 0 then
					local tooltipOverlay = g_ui.createWidget("UIWidget", offerPanel)

					tooltipOverlay:setId("tooltipOverlay")
					tooltipOverlay:setFocusable(false)
					tooltipOverlay:setSize(btnBuy:getSize())
					tooltipOverlay:setPosition(btnBuy:getPosition())

					local reasonLines = {}

					if oldProtocol then
						table.insert(reasonLines, tostring(offer.reasonIdDisable or "Unavailable"))
					else
						local reasonIds = offer.reasonIdsDisable

						if not reasonIds or #reasonIds == 0 then
							reasonIds = {
								offer.reasonIdDisable
							}
						end

						for _, reasonId in ipairs(reasonIds) do
							local reasonText = reasonCategory[(reasonId or 0) + 1]

							if reasonText and reasonText ~= "" then
								table.insert(reasonLines, reasonText)
							end
						end
					end

					if #reasonLines == 0 then
						table.insert(reasonLines, "Unavailable")
					end

					tooltipOverlay:parseColoreDisplayToolTip(string.format("[color=#ff0000]The product is not available for this character:\n\n- %s[/color]", table.concat(reasonLines, "\n- ")))
					tooltipOverlay:setOpacity(0)
					tooltipOverlay:addAnchor(AnchorLeft, btnBuy:getId(), AnchorLeft)
					tooltipOverlay:addAnchor(AnchorTop, btnBuy:getId(), AnchorTop)
				end
			end

			offerPanel:getChildById("btnBuy").onClick = function(widget)
				if acceptWindow then
					destroyWindow(acceptWindow)
				end

				local isTransferable = offer.coinType == GameStore.CoinType.Transferable

				if isConfigurableOffer(product, offer) then
					fixServerNoSend0xF2()
					g_game.buyStoreOffer(offer.id, GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_OTHER)
					showStoreProcessingModal()

					return
				end

				local function shouldAskBeforeBuying()
					if modules.client_options and modules.client_options.getOption then
						local value = modules.client_options.getOption("askBeforeBuying")

						if value ~= nil then
							return value
						end
					end

					return true
				end

				local purchaseInProgress = false

				local function acceptFunc()
					if purchaseInProgress then
						return
					end

					purchaseInProgress = true

					if acceptWindow and applyShopDoNotShowAgainPreference then
						applyShopDoNotShowAgainPreference(acceptWindow)
					end

					destroyWindow(acceptWindow)
					addEvent(function()
						fixServerNoSend0xF2()

						local latestBalance2, latestBalance1 = getCoinsBalance()

						if (isTransferable and latestBalance1 or latestBalance2) >= offer.price then
							g_game.buyStoreOffer(offer.id, GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_OTHER)
							showStoreProcessingModal()
						else
							displayErrorBox(controllerShop.ui:getText(), tr("You don't have enough coins"))
							restoreStoreAfterOverlay()
						end
					end)
				end

				local function cancelFunc()
					destroyWindow(acceptWindow)
					restoreStoreAfterOverlay()
				end

				local formattedPrice = formatNumberWithCommas(tonumber(offer.price) or 0)
				local offerCount = offer.count or 1
				local productLineText = string.format("%dx %s", offerCount, product.name)
				local confirmationMessage = string.format("Do you want to buy the product \"%s\"?", productLineText)
				local priceIcon = isTransferable and "/images/icons/icon-tibiacointransferable" or "/images/icons/icon-tibiacoin"
				local data = product._cachedProductData

				if data == nil then
					data = getProductData(product)
					product._cachedProductData = data
				end

				if not shouldAskBeforeBuying() then
					acceptFunc()

					return
				end

				hideStoreForOverlay()

				acceptWindow = displayGeneralSHOPBox(tr("Confirmation of Purchase"), confirmationMessage, productLineText, formattedPrice, priceIcon, {
					{
						text = tr("Buy"),
						callback = acceptFunc
					},
					{
						text = tr("Cancel"),
						callback = cancelFunc
					},
					anchor = AnchorHorizontalCenter
				}, acceptFunc, cancelFunc)

				if data then
					createProductImage(acceptWindow.Box, data)
				end
			end
		end
	end

	if showDisabledDescription then
		renderStoreDescription(panel, description, "The product is currently not available for this character. See the buy button tooltip for details.", product)
	end

	if var_206_1 then
		var_0_38("chooseOffert", var_206_1)
	end
end

function onHoverHomeBanner(arg_212_0)
	if not arg_212_0 or arg_212_0:isDestroyed() then
		return
	end

	local _bannerCursor = arg_212_0:isHovered()

	if _bannerCursor == arg_212_0._bannerCursor then
		return
	end

	arg_212_0._bannerCursor = _bannerCursor

	if _bannerCursor then
		g_mouse.pushCursor("point")
	else
		g_mouse.popCursor("point")
	end
end

function onClickHomeBanner()
	if not bannersHome or #bannersHome == 0 then
		return
	end

	local currentBanner = bannersHome[currentIndex]

	if not currentBanner then
		return
	end

	if currentBanner.openWebsite or currentBanner.unknownByte1 == 1 then
		getCoinsWebsite()

		return
	end

	local targetOfferId = currentBanner.offerId

	if targetOfferId and targetOfferId ~= 0 then
		g_game.sendRequestStoreOfferById(targetOfferId)
	else
		g_logger.warning("[game_store] Could not redirect from banner: missing offer id")
	end
end

function chooseHome(self, focusedChild)
	if not focusedChild then
		return
	end

	local product = focusedChild.product
	local targetOfferId = product.id

	if (not targetOfferId or targetOfferId == 0) and product.subOffers and #product.subOffers > 0 then
		targetOfferId = product.subOffers[1].id
	end

	if targetOfferId and targetOfferId ~= 0 then
		g_game.sendRequestStoreOfferById(targetOfferId)
	else
		g_logger.warning("[game_store] Could not redirect from Home: missing offer id")
	end
end

function changeImagenHome(direction)
	if direction == "nextImagen" then
		currentIndex = currentIndex + 1

		if currentIndex > #bannersHome then
			currentIndex = 1
		end
	elseif direction == "prevImagen" then
		currentIndex = currentIndex - 1

		if currentIndex < 1 then
			currentIndex = #bannersHome
		end
	end

	local currentBanner = bannersHome[currentIndex]
	local imagePath = "/" .. currentBanner.image
	local homeBanner = getHomeBannerWidget()

	if homeBanner then
		setImagenHttp(homeBanner, imagePath, false, true)
	end
end

local function closeChangeNameWindow(restoreStore)
	destroyWindow(changeNameWindow)

	if restoreStore then
		restoreStoreAfterOverlay()
	end
end

function displayChangeName(offerId)
	offerId = tonumber(offerId)

	if not offerId or offerId == 0 then
		displayErrorBox(controllerShop.ui and controllerShop.ui:getText() or tr("Store"), tr("Invalid offer."))

		return
	end

	hideStoreForOverlay()
	destroyWindow(changeNameWindow)

	changeNameWindow = g_ui.displayUI("style/changename")

	if not changeNameWindow then
		restoreStoreAfterOverlay()

		return
	end

	changeNameWindow:setText(tr("Enter New Character Name"))
	changeNameWindow:show()
	changeNameWindow:raise()
	changeNameWindow:focus()
	g_modalManager.show(changeNameWindow)

	local nameField = changeNameWindow:recursiveGetChildById("transferPointsText")

	changeNameWindow.transferPointsText = nameField

	if nameField then
		nameField:setText("")
		nameField:focus()
	end

	local function updateNameChangeOkButtonState(nameText)
		if not changeNameWindow or changeNameWindow:isDestroyed() then
			return
		end

		local okBtn = changeNameWindow.buttonOk

		if not okBtn or okBtn:isDestroyed() then
			okBtn = changeNameWindow:recursiveGetChildById("buttonOk")
			changeNameWindow.buttonOk = okBtn
		end

		if not okBtn then
			return
		end

		local text = nameText

		if text == nil and nameField and not nameField:isDestroyed() then
			text = nameField:getText()
		end

		local hasName = (text or ""):trim():len() >= 1

		okBtn:setEnabled(hasName)
	end

	local function scheduleNameChangeOkButtonState(nameText)
		if not changeNameWindow or changeNameWindow:isDestroyed() then
			return
		end

		if changeNameWindow._nameOkButtonUpdateEvent then
			removeEvent(changeNameWindow._nameOkButtonUpdateEvent)
		end

		changeNameWindow._nameOkButtonUpdateEvent = addEvent(function()
			changeNameWindow._nameOkButtonUpdateEvent = nil

			updateNameChangeOkButtonState(nameText)
		end)
	end

	function changeNameWindow.onEscape()
		closeChangeNameWindow(true)
	end

	local closeButton = changeNameWindow:recursiveGetChildById("closeButton")

	changeNameWindow.closeButton = closeButton

	local okButton = changeNameWindow:recursiveGetChildById("buttonOk")

	changeNameWindow.buttonOk = okButton

	updateNameChangeOkButtonState("")

	if nameField then
		function nameField.onTextChange(widget, text)
			scheduleNameChangeOkButtonState(text)
		end
	end

	if closeButton then
		function closeButton.onClick()
			closeChangeNameWindow(true)
		end
	end

	if okButton then
		function okButton.onClick()
			if not changeNameWindow or changeNameWindow:isDestroyed() then
				return
			end

			local newName = nameField and nameField:getText():trim() or ""

			if newName:len() < 1 or not okButton:isEnabled() then
				return
			end

			if newName:len() < 2 then
				displayErrorBox(changeNameWindow:getText(), tr("Please enter a valid character name."))

				return
			end

			destroyWindow(changeNameWindow)
			g_game.buyStoreOffer(offerId, GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_NAMECHANGE, newName)
			showStoreProcessingModal()
		end
	end
end

local function closeHirelingNameWindow(restoreStore)
	destroyWindow(hirelingNameWindow)

	if restoreStore then
		restoreStoreAfterOverlay()
	end
end

function displayHirelingName(offerId)
	offerId = tonumber(offerId)

	if not offerId or offerId == 0 then
		displayErrorBox(controllerShop.ui and controllerShop.ui:getText() or tr("Store"), tr("Invalid offer."))

		return
	end

	hideStoreForOverlay()
	destroyWindow(hirelingNameWindow)

	hirelingNameWindow = g_ui.displayUI("style/changename")

	if not hirelingNameWindow then
		restoreStoreAfterOverlay()

		return
	end

	hirelingNameWindow:setText(tr("Enter Hireling Name"))
	hirelingNameWindow:show()
	hirelingNameWindow:raise()
	hirelingNameWindow:focus()
	g_modalManager.show(hirelingNameWindow)

	local nameField = hirelingNameWindow:recursiveGetChildById("transferPointsText")

	hirelingNameWindow.transferPointsText = nameField

	if nameField then
		nameField:setText("")
		nameField:focus()
	end

	local function updateOkButtonState(nameText)
		if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
			return
		end

		local okBtn = hirelingNameWindow.buttonOk

		if not okBtn or okBtn:isDestroyed() then
			okBtn = hirelingNameWindow:recursiveGetChildById("buttonOk")
			hirelingNameWindow.buttonOk = okBtn
		end

		if not okBtn then
			return
		end

		local text = nameText

		if text == nil and nameField and not nameField:isDestroyed() then
			text = nameField:getText()
		end

		okBtn:setEnabled((text or ""):trim():len() >= 1)
	end

	local function scheduleOkButtonState(nameText)
		if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
			return
		end

		if hirelingNameWindow._okUpdateEvent then
			removeEvent(hirelingNameWindow._okUpdateEvent)
		end

		hirelingNameWindow._okUpdateEvent = addEvent(function()
			hirelingNameWindow._okUpdateEvent = nil

			updateOkButtonState(nameText)
		end)
	end

	function hirelingNameWindow.onEscape()
		closeHirelingNameWindow(true)
	end

	local closeButton = hirelingNameWindow:recursiveGetChildById("closeButton")
	local okButton = hirelingNameWindow:recursiveGetChildById("buttonOk")

	hirelingNameWindow.buttonOk = okButton

	updateOkButtonState("")

	if nameField then
		function nameField.onTextChange(widget, text)
			scheduleOkButtonState(text)
		end
	end

	if closeButton then
		function closeButton.onClick()
			closeHirelingNameWindow(true)
		end
	end

	if okButton then
		function okButton.onClick()
			if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
				return
			end

			local newName = nameField and nameField:getText():trim() or ""

			if newName:len() < 1 or not okButton:isEnabled() then
				return
			end

			if newName:len() < 2 then
				displayErrorBox(hirelingNameWindow:getText(), tr("Please enter a valid hireling name."))

				return
			end

			destroyWindow(hirelingNameWindow)
			g_game.buyStoreOffer(offerId, GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_HIRELING, newName, 0)
			showStoreProcessingModal()
		end
	end
end

function displayHirelingRename(creatureId)
	creatureId = tonumber(creatureId)

	if not creatureId or creatureId == 0 then
		return
	end

	destroyWindow(hirelingNameWindow)

	hirelingNameWindow = g_ui.displayUI("style/changename")

	if not hirelingNameWindow then
		return
	end

	hirelingNameWindow:setText(tr("Enter Hireling Name"))
	hirelingNameWindow:show()
	hirelingNameWindow:raise()
	hirelingNameWindow:focus()
	g_modalManager.show(hirelingNameWindow)

	local nameField = hirelingNameWindow:recursiveGetChildById("transferPointsText")

	hirelingNameWindow.transferPointsText = nameField

	if nameField then
		nameField:setText("")
		nameField:focus()
	end

	local function updateOkButtonState(nameText)
		if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
			return
		end

		local okBtn = hirelingNameWindow.buttonOk

		if not okBtn or okBtn:isDestroyed() then
			okBtn = hirelingNameWindow:recursiveGetChildById("buttonOk")
			hirelingNameWindow.buttonOk = okBtn
		end

		if not okBtn then
			return
		end

		local text = nameText

		if text == nil and nameField and not nameField:isDestroyed() then
			text = nameField:getText()
		end

		okBtn:setEnabled((text or ""):trim():len() >= 1)
	end

	local function scheduleOkButtonState(nameText)
		if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
			return
		end

		if hirelingNameWindow._okUpdateEvent then
			removeEvent(hirelingNameWindow._okUpdateEvent)
		end

		hirelingNameWindow._okUpdateEvent = addEvent(function()
			hirelingNameWindow._okUpdateEvent = nil

			updateOkButtonState(nameText)
		end)
	end

	function hirelingNameWindow.onEscape()
		closeHirelingNameWindow(false)
	end

	local closeButton = hirelingNameWindow:recursiveGetChildById("closeButton")
	local okButton = hirelingNameWindow:recursiveGetChildById("buttonOk")

	hirelingNameWindow.buttonOk = okButton

	updateOkButtonState("")

	if nameField then
		function nameField.onTextChange(widget, text)
			scheduleOkButtonState(text)
		end
	end

	if closeButton then
		function closeButton.onClick()
			closeHirelingNameWindow(false)
		end
	end

	if okButton then
		function okButton.onClick()
			if not hirelingNameWindow or hirelingNameWindow:isDestroyed() then
				return
			end

			local newName = nameField and nameField:getText():trim() or ""

			if newName:len() < 1 or not okButton:isEnabled() then
				return
			end

			if newName:len() < 2 then
				displayErrorBox(hirelingNameWindow:getText(), tr("Please enter a valid hireling name."))

				return
			end

			destroyWindow(hirelingNameWindow)
			g_game.sendChangeHirelingName(creatureId, newName)
		end
	end
end

function onHirelingNameChange(playerId, creatureId)
	displayHirelingRename(creatureId)
end

local WORLD_TYPE_NAMES = {
	[0] = "Open PvP",
	"Optional PvP",
	"Hardcore PvP",
	"Retro Open PvP",
	"Retro Hardcore PvP"
}

local function closeWorldTransferWindow(restoreStore)
	destroyWindow(worldTransferWindow)

	worldTransferWindow = nil

	if restoreStore then
		restoreStoreAfterOverlay()
	end
end

function displayWorldTransfer(offerId, data)
	offerId = tonumber(offerId)

	if not offerId or offerId == 0 then
		displayErrorBox(controllerShop.ui and controllerShop.ui:getText() or tr("Store"), tr("Invalid offer."))

		return
	end

	if not data then
		displayErrorBox(controllerShop.ui and controllerShop.ui:getText() or tr("Store"), tr("Missing world transfer data."))

		return
	end

	hideStoreForOverlay()
	destroyWindow(worldTransferWindow)

	worldTransferWindow = g_ui.displayUI("style/worldtransfer")

	if not worldTransferWindow then
		restoreStoreAfterOverlay()

		return
	end

	local transferTitle = data.isExpress and tr("Set Up an Express Character World Transfer") or tr("Set Up a Character World Transfer")

	worldTransferWindow:setText(transferTitle .. tr(" - Step 1 of 2"))
	worldTransferWindow:show()
	worldTransferWindow:raise()
	worldTransferWindow:focus()
	g_modalManager.show(worldTransferWindow)

	local playerName = g_game.getLocalPlayer() and g_game.getLocalPlayer():getName() or ""
	local step1 = worldTransferWindow:getChildById("step1Panel")
	local step2 = worldTransferWindow:getChildById("step2Panel")
	local charLabel1 = step1:getChildById("characterLabel1")

	if charLabel1 then
		charLabel1:setText(tr("Character: %s", playerName))
	end

	local charLabel2 = step2:getChildById("characterLabel2")

	if charLabel2 then
		charLabel2:setText(tr("Character: %s", playerName))
	end

	local worldCombo = step1:getChildById("worldCombo")

	if worldCombo then
		worldCombo:clear()

		for _, world in ipairs(data.worlds or {}) do
			if not world.worldLocked then
				local label = world.name
				local typeName = WORLD_TYPE_NAMES[world.worldType]

				if typeName then
					label = label .. " (" .. typeName .. ")"
				end

				if world.onlyPremium then
					label = label .. " [Premium]"
				end

				worldCombo:addOption(label, world.name)
			end
		end

		worldCombo:setCurrentIndex(1)
	end

	local reqList = step1:getChildById("requirementsList")

	if reqList then
		local requirements = {
			{
				met = not data.hasRedSkull,
				text = tr("Your character has no red skull."),
				fail = tr("Your character has a red skull.")
			},
			{
				met = not data.hasBlackSkull,
				text = tr("Your character has no black skull."),
				fail = tr("Your character has a black skull.")
			},
			{
				met = not data.isGuildLeader,
				text = tr("Your character is no guild leader."),
				fail = tr("Your character is a guild leader.")
			},
			{
				met = not data.hasHouseOrBidActive,
				text = tr("Your character does not own a house."),
				fail = tr("Your character owns a house.")
			},
			{
				met = not data.hasCoinMarketAuction,
				text = tr("You do not have any Clientzin Coin auctions in the Market."),
				fail = tr("You have active Clientzin Coin auctions in the Market.")
			}
		}
		local allMet = true

		for _, req in ipairs(requirements) do
			local row = g_ui.createWidget("WorldTransferReqRow", reqList)

			if row then
				local icon = row:getChildById("reqIcon")
				local label = row:getChildById("reqText")

				if req.met then
					if icon then
						icon:setImageSource("/images/ui/icon-yes")
						icon:setSize("12 9")
					end

					if label then
						label:setText(req.text)
					end
				else
					allMet = false

					if icon then
						icon:setImageSource("/images/ui/icon-no")
						icon:setSize("12 9")
					end

					if label then
						label:setText(req.fail)
						label:setColor("#ff6060")
					end
				end
			end
		end

		local rowHeight = 18

		reqList:setHeight(#requirements * rowHeight + 4)

		local fulfillText = step1:getChildById("fulfillText")

		if fulfillText then
			if allMet then
				fulfillText:setText(tr("You fulfil all conditions for a Character World Transfer. Please select the game world to which you like to transfer."))
			else
				fulfillText:setText(tr("Not all requirements are fulfilled. You cannot proceed with the transfer."))
				fulfillText:setColor("#ff6060")
			end
		end

		local btnNext = step1:getChildById("btnNext")

		if btnNext then
			btnNext:setEnabled(allMet and worldCombo and worldCombo:getOptionsCount() > 0)

			function worldCombo.onOptionChange()
				btnNext:setEnabled(allMet and worldCombo:getCurrentIndex() > 0)
			end
		end
	end

	local function goToStep2()
		local opt = worldCombo and worldCombo:getCurrentOption()
		local selectedWorld = opt and opt.data or ""
		local targetConfirm = step2:getChildById("targetWorldConfirm")

		if targetConfirm then
			targetConfirm:setText(tr("Target world: %s", selectedWorld))
		end

		worldTransferWindow:setText(transferTitle .. tr(" - Step 2 of 2"))
		worldTransferWindow:setSize("450 430")
		step1:setVisible(false)
		step2:setVisible(true)

		local btnBuyNow = step2:getChildById("btnBuyNow")
		local acceptCheckbox = step2:getChildById("acceptCheckbox")

		if btnBuyNow and acceptCheckbox then
			btnBuyNow:setEnabled(acceptCheckbox:isChecked())

			function acceptCheckbox.onCheckChange(widget, checked)
				btnBuyNow:setEnabled(checked)
			end
		end
	end

	local btnNext = step1:getChildById("btnNext")

	if btnNext then
		function btnNext.onClick()
			goToStep2()
		end
	end

	local btnCancel1 = step1:getChildById("btnCancel1")

	if btnCancel1 then
		function btnCancel1.onClick()
			closeWorldTransferWindow(true)
		end
	end

	local btnBuyNow = step2:getChildById("btnBuyNow")

	if btnBuyNow then
		function btnBuyNow.onClick()
			local opt = worldCombo and worldCombo:getCurrentOption()
			local selectedWorld = opt and opt.data or ""

			if selectedWorld == "" then
				return
			end

			closeWorldTransferWindow(false)
			g_game.buyStoreOffer(offerId, GameStore.ClientOfferTypes.CLIENT_STORE_OFFER_WORLD_TRANSFER, selectedWorld)
			showStoreProcessingModal()
		end
	end

	local btnCancel2 = step2:getChildById("btnCancel2")

	if btnCancel2 then
		function btnCancel2.onClick()
			closeWorldTransferWindow(true)
		end
	end

	local btnBack = step2:getChildById("btnBack")

	if btnBack then
		function btnBack.onClick()
			worldTransferWindow:setText(transferTitle .. tr(" - Step 1 of 2"))
			worldTransferWindow:setSize("450 356")
			step2:setVisible(false)
			step1:setVisible(true)
		end
	end

	function worldTransferWindow.onEscape()
		closeWorldTransferWindow(true)
	end

	local closeButton = worldTransferWindow:recursiveGetChildById("closeButton")

	if closeButton then
		function closeButton.onClick()
			closeWorldTransferWindow(true)
		end
	end
end

local function closeTransferPointsWindow()
	destroyWindow(transferPointsWindow)
	restoreStoreAfterOverlay()
end

function transferCancel()
	closeTransferPointsWindow()
end

function transferPoints()
	destroyWindow(transferPointsWindow)
	hideStoreForOverlay()

	transferPointsWindow = g_ui.displayUI("style/transferpoints")

	transferPointsWindow:show()
	transferPointsWindow:raise()
	transferPointsWindow:focus()
	g_modalManager.show(transferPointsWindow)

	local playerBalance = g_game.getLocalPlayer():getResourceBalance(ResourceTypes.COIN_TRANSFERRABLE)

	fixServerNoSend0xF2()

	local coinsBalance2, coinsBalance1 = getCoinsBalance()

	if playerBalance == 0 then
		playerBalance = coinsBalance1
	end

	transferPointsWindow.giftable:setText(formatNumberWithCommas(playerBalance))

	local giftCoinStep = 25
	local canGiftCoins = giftCoinStep <= playerBalance
	local giftAmountMin = canGiftCoins and giftCoinStep or 0
	local giftAmountMax = canGiftCoins and math.floor(playerBalance / giftCoinStep) * giftCoinStep or 0

	transferPointsWindow.amountBar:setMinimum(giftAmountMin)
	transferPointsWindow.amountBar:setMaximum(giftAmountMax)
	transferPointsWindow.amountBar:setStep(giftCoinStep)
	transferPointsWindow.amountBar:setIncrementStep(giftCoinStep)

	local initialAmount = canGiftCoins and giftCoinStep or 0

	transferPointsWindow.amountBar:setEnabled(canGiftCoins)
	transferPointsWindow.amountBar:setValue(initialAmount)
	transferPointsWindow.amount:setText(formatNumberWithCommas(initialAmount))

	local function updateGiftTransferButtonState(recipientText)
		if not transferPointsWindow or transferPointsWindow:isDestroyed() then
			return
		end

		local textEdit = transferPointsWindow.transferPointsText
		local recipient = recipientText

		if recipient == nil and textEdit and not textEdit:isDestroyed() then
			recipient = textEdit:getText()
		end

		local enabled = (recipient or ""):trim():len() >= 1

		transferPointsWindow.buttonOk:setEnabled(enabled)
	end

	local function scheduleGiftTransferButtonState(recipientText)
		if transferPointsWindow._giftButtonUpdateEvent then
			removeEvent(transferPointsWindow._giftButtonUpdateEvent)
		end

		transferPointsWindow._giftButtonUpdateEvent = addEvent(function()
			transferPointsWindow._giftButtonUpdateEvent = nil

			updateGiftTransferButtonState(recipientText)
		end)
	end

	updateGiftTransferButtonState("")

	function transferPointsWindow.transferPointsText.onTextChange(widget, text)
		scheduleGiftTransferButtonState(text)
	end

	transferPointsWindow.onEscape = closeTransferPointsWindow

	local function snapGiftCoinAmount(raw)
		if not canGiftCoins then
			return 0
		end

		local value = math.max(0, math.floor(tonumber(raw) or 0))

		if value <= 0 then
			return giftAmountMin
		end

		local snapped = math.floor((value + giftCoinStep / 2) / giftCoinStep) * giftCoinStep

		if snapped < giftAmountMin then
			snapped = giftAmountMin
		end

		return math.min(snapped, giftAmountMax)
	end

	function transferPointsWindow.amountBar.onValueChange(scrollbar, value)
		local snapped = snapGiftCoinAmount(value)

		if scrollbar:getValue() ~= snapped then
			scrollbar:setValue(snapped)

			return
		end

		transferPointsWindow.amount:setText(formatNumberWithCommas(snapped))
	end

	transferPointsWindow.closeButton.onClick = closeTransferPointsWindow

	function transferPointsWindow.buttonOk.onClick()
		local receipient = transferPointsWindow.transferPointsText:getText():trim()

		if receipient:len() < 1 then
			return
		end

		local amount = transferPointsWindow.amountBar:getValue()

		if not canGiftCoins or amount < giftAmountMin or amount > giftAmountMax then
			return
		end

		g_game.transferCoins(receipient, amount)
		closeTransferPointsWindow()
	end
end

function search()
	if not controllerShop.ui then
		return
	end

	waitingInitialHome = false

	if controllerShop.ui.openedCategory ~= nil then
		close(controllerShop.ui.openedCategory)
	end

	local text = controllerShop.ui.SearchEdit:getText() or ""

	g_game.sendRequestStoreSearch(text:trim(), 0, 1)
	var_0_170()
end
