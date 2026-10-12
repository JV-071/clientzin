ItemsDatabase = {}
ItemsDatabase.rarityColors = {
	grey = "#aaaaaa",
	green = "#00f000",
	white = "#f0f0f0",
	blue = "#20a0ff",
	purple = "#ff68ff",
	yellow = "#f0f000"
}

local function getColorForValue(value)
	if value >= 1000000 then
		return "yellow"
	elseif value >= 100000 then
		return "purple"
	elseif value >= 10000 then
		return "blue"
	elseif value >= 1000 then
		return "green"
	elseif value >= 50 then
		return "grey"
	else
		return "white"
	end
end

local function clipfunction(value)
	if value >= 1000000 then
		return "128 0 32 32"
	elseif value >= 100000 then
		return "96 0 32 32"
	elseif value >= 10000 then
		return "64 0 32 32"
	elseif value >= 1000 then
		return "32 0 32 32"
	elseif value >= 50 then
		return "0 0 32 32"
	end

	return ""
end

function ItemsDatabase.setRarityItem(widget, item, style, isBackground)
	if not g_game.getFeature(GameColorizedLootValue) or not widget then
		return
	end

	local frameOption = modules.client_options.getOption("framesRarity")

	if frameOption == "none" then
		return
	end

	local imagePath = "/images/ui/item"
	local clip
	local useSpecialArt = false

	if item then
		local price = type(item) == "number" and item or item and item:getMeanPrice() or 0

		if getColorForValue(price) then
			clip = clipfunction(price)

			if clip ~= "" then
				if frameOption == "frames" then
					imagePath = "/images/ui/containerslot-glowingborders"
					useSpecialArt = true
				elseif frameOption == "corners" then
					imagePath = "/images/ui/containerslot-coloredges"
					useSpecialArt = true
				end
			else
				clip = nil
			end
		end
	end

	if not useSpecialArt then
		local cn = widget:getClassName()

		if cn == "UIItem" or cn == "UIActionSlot" then
			imagePath = "/images/ui/item"
			clip = nil
		else
			imagePath = ""
			clip = nil
		end
	end

	widget:setImageClip(clip)
	widget:setImageSource(imagePath)

	if style then
		widget:setStyle(style)
	end

	return useSpecialArt
end

function ItemsDatabase.syncRarityWidgetVisibility(rarityWidget)
	if not rarityWidget then
		return
	end

	local imageSource = rarityWidget:getImageSource()

	rarityWidget:setVisible(imageSource and imageSource ~= "" and imageSource ~= "/images/ui/item")
end

local function resolveSlotRarityWidget(slotWidget)
	if slotWidget.rarity and slotWidget.rarity.getClassName then
		return slotWidget.rarity
	end

	return slotWidget:getChildById("rarity")
end

local function resolveSlotItemWidget(slotWidget)
	local itemUi = slotWidget:getChildById("item")

	if itemUi then
		return itemUi
	end

	if slotWidget.item and slotWidget.item.getClassName then
		return slotWidget.item
	end

	return nil
end

function ItemsDatabase.applyContainerRarityStackOrder(slotWidget, extraOverlayIds)
	if not slotWidget then
		return
	end

	local rarity = resolveSlotRarityWidget(slotWidget)
	local itemUi = resolveSlotItemWidget(slotWidget)

	if not rarity or not itemUi or itemUi:getClassName() ~= "UIItem" then
		return
	end

	local frameOption = modules.client_options and modules.client_options.getOption("framesRarity") or "frames"
	local hasItemSlot = slotWidget.itemSlot ~= nil
	local rarityIndex = hasItemSlot and 2 or 1
	local itemIndex = hasItemSlot and 3 or 2

	if frameOption == "corners" then
		rarityIndex = hasItemSlot and 3 or 2
		itemIndex = hasItemSlot and 2 or 1
	end

	if slotWidget.itemSlot then
		slotWidget:moveChildToIndex(slotWidget.itemSlot, 1)
	end

	slotWidget:moveChildToIndex(rarity, rarityIndex)
	slotWidget:moveChildToIndex(itemUi, itemIndex)

	local overlayIds = {
		"tier",
		"amount",
		"charges",
		"duration",
		"quickloot",
		"boxed"
	}

	if extraOverlayIds then
		for _, id in ipairs(extraOverlayIds) do
			table.insert(overlayIds, id)
		end
	end

	local overlayIndex = itemIndex + 1

	for _, id in ipairs(overlayIds) do
		local overlay = slotWidget[id]

		if overlay then
			slotWidget:moveChildToIndex(overlay, overlayIndex)

			overlayIndex = overlayIndex + 1
		end
	end
end

function ItemsDatabase.getColorForRarity(rarity)
	return ItemsDatabase.rarityColors[rarity] or TextColors.white
end

function ItemsDatabase.shouldHideExpiryForUnusedItem(item)
	if not item then
		return false
	end

	if not item.isBrandNew or type(item.isBrandNew) ~= "function" then
		return false
	end

	local ok, brandNew = pcall(function()
		return item:isBrandNew()
	end)

	if not ok or not brandNew then
		return false
	end

	if not modules.client_options or not modules.client_options.getOption then
		return false
	end

	return not modules.client_options.getOption("showExpiryOnUnusedItems")
end

function ItemsDatabase.setColorLootMessage(text)
	local function coloringLootName(match)
		local id, itemName = match:match("(%d+)|(.+)")
		local itemInfo = g_things.getThingType(tonumber(id), ThingCategoryItem):getMeanPrice()

		if itemInfo then
			local color = ItemsDatabase.getColorForRarity(getColorForValue(itemInfo))

			return "{" .. itemName .. ", " .. color .. "}"
		else
			return itemName
		end
	end

	return text:gsub("{(.-)}", coloringLootName)
end

local MAX_TIER_STRIP_FRAMES = 10
local TIER_STRIP_IMAGE = "/images/inventory/tiers-strip"
local OVERLORD_TIER_STRIP_IMAGE = "/images/inventory/tiers-strip-exaltation-overlord"
local BIG_TIER_STRIP_IMAGE = "/images/inventory/tiers-strip-big"
local BIG_OVERLORD_TIER_STRIP_IMAGE = "/images/inventory/tiers-strip-big-exaltation-overlord"

ItemsDatabase.OVERLORD_TIER_SLOTS = {
	[InventorySlotHead] = true,
	[InventorySlotBody] = true,
	[InventorySlotLeg] = true,
	[InventorySlotFeet] = true,
	[InventorySlotLeft] = true
}

function ItemsDatabase.isOverlordActive()
	return OtcOpCode and g_game.isOtcToggleEnabled and g_game.isOtcToggleEnabled(OtcOpCode.OVERLORD_ACTIVE)
end

local function resolveItemTier(itemOrTier)
	if type(itemOrTier) == "number" then
		return itemOrTier
	end

	if type(itemOrTier) == "userdata" and itemOrTier and itemOrTier.getTier then
		return itemOrTier:getTier() or 0
	end

	return 0
end

local function updateTierStrip(tierWidget, numericValue, overlordActive, frameWidth, frameHeight, normalImage, overlordImage)
	if not tierWidget or not tierWidget.setImageClip then
		return
	end

	tierWidget:setImageSource(overlordActive and overlordImage or normalImage)

	numericValue = tonumber(numericValue) or 0

	if overlordActive then
		numericValue = numericValue + 1
	end

	if numericValue > 0 then
		local frameIndex = math.min(math.max(numericValue, 1), MAX_TIER_STRIP_FRAMES)

		tierWidget:setImageClip({
			y = 0,
			x = (frameIndex - 1) * frameWidth,
			width = frameWidth,
			height = frameHeight
		})
		tierWidget:setVisible(true)
	else
		tierWidget:setVisible(false)
	end
end

function ItemsDatabase.setTier(widget, item, style)
	if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
		return
	end

	updateTierStrip(widget.tier, resolveItemTier(item), style == true, 9, 8, TIER_STRIP_IMAGE, OVERLORD_TIER_STRIP_IMAGE)
end

function ItemsDatabase.setBigTier(widget, item, style)
	if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
		return
	end

	updateTierStrip(widget.bigtier, resolveItemTier(item), style == true, 18, 16, BIG_TIER_STRIP_IMAGE, BIG_OVERLORD_TIER_STRIP_IMAGE)
end

function ItemsDatabase.setCharges(widget, item, style)
	if not g_game.getFeature(GameThingCounter) or not widget then
		return
	end

	if ItemsDatabase.shouldHideExpiryForUnusedItem(item) then
		widget.charges:setText("")

		if style then
			widget:setStyle(style)
		end

		return
	end

	if item and item:getCharges() > 0 then
		widget.charges:setText(item:getCharges())
	else
		widget.charges:setText("")
	end

	if style then
		widget:setStyle(style)
	end
end

function ItemsDatabase.setDurationText(slotWidget, remainingDuration)
	if not slotWidget or not slotWidget.duration then
		return
	end

	local durationText = remainingDuration and formatItemDuration(remainingDuration) or ""
	local text = slotWidget.duration:getText()

	slotWidget.duration:setText(durationText)

	local itemWidget = resolveSlotItemWidget(slotWidget) or slotWidget

	if durationText ~= "" then
		itemWidget:setTooltip(durationText)
	elseif text ~= "" and itemWidget:getTooltip() == text then
		local item = itemWidget:getItem()
		local tooltip = item and item:getTooltip() or ""

		itemWidget:setTooltip(tooltip ~= "" and tooltip or nil)
	end
end

function ItemsDatabase.setDuration(widget, item, style)
	if not widget then
		return
	end

	if g_game.getFeature(GameThingClock) and item and item:getDurationTime() > 0 and not ItemsDatabase.shouldHideExpiryForUnusedItem(item) then
		ItemsDatabase.setDurationText(widget, item:getDurationTime())
	else
		ItemsDatabase.setDurationText(widget, nil)
	end

	if style then
		widget:setStyle(style)
	end
end

function formatItemDuration(duration)
	local hours = math.floor(duration / 86400)
	local remainingHours = math.floor(duration % 86400 / 3600)
	local minutes = math.floor(duration % 3600 / 60)
	local seconds = duration % 60

	if hours > 0 then
		return string.format("%dd %dh %dmin", hours, remainingHours, minutes)
	elseif remainingHours > 0 then
		return string.format("%dh %dmin", remainingHours, minutes)
	elseif minutes > 0 then
		return string.format("%dmin", minutes)
	end

	return string.format("%ds", seconds)
end
