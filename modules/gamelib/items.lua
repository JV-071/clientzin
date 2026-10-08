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

local var_0_4 = 10
local var_0_5 = "/images/inventory/tiers-strip"
local var_0_6 = "/images/inventory/tiers-strip-exaltation-overlord"
local var_0_7 = "/images/inventory/tiers-strip-big"
local var_0_8 = "/images/inventory/tiers-strip-big-exaltation-overlord"

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

local function var_0_9(arg_14_0)
	if type(arg_14_0) == "number" then
		return arg_14_0
	end

	if type(arg_14_0) == "userdata" and arg_14_0 and arg_14_0.getTier then
		return arg_14_0:getTier() or 0
	end

	return 0
end

local function var_0_10(arg_15_0, numericValue, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
	if not arg_15_0 or not arg_15_0.setImageClip then
		return
	end

	arg_15_0:setImageSource(arg_15_2 and arg_15_6 or arg_15_5)

	numericValue = tonumber(numericValue) or 0

	if arg_15_2 then
		numericValue = numericValue + 1
	end

	if numericValue > 0 then
		local var_15_0 = math.min(math.max(numericValue, 1), var_0_4)

		arg_15_0:setImageClip({
			y = 0,
			x = (var_15_0 - 1) * arg_15_3,
			width = arg_15_3,
			height = arg_15_4
		})
		arg_15_0:setVisible(true)
	else
		arg_15_0:setVisible(false)
	end
end

function ItemsDatabase.setTier(widget, item, style)
	if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
		return
	end

	var_0_10(widget.tier, var_0_9(item), style == true, 9, 8, var_0_5, var_0_6)
end

function ItemsDatabase.setBigTier(widget, item, style)
	if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
		return
	end

	var_0_10(widget.bigtier, var_0_9(item), style == true, 18, 16, var_0_7, var_0_8)
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

function ItemsDatabase.setDurationText(arg_19_0, arg_19_1)
	if not arg_19_0 or not arg_19_0.duration then
		return
	end

	local var_19_0 = arg_19_1 and formatItemDuration(arg_19_1) or ""
	local text = arg_19_0.duration:getText()

	arg_19_0.duration:setText(var_19_0)

	local var_19_2 = resolveSlotItemWidget(arg_19_0) or arg_19_0

	if var_19_0 ~= "" then
		var_19_2:setTooltip(var_19_0)
	elseif text ~= "" and var_19_2:getTooltip() == text then
		local item = var_19_2:getItem()
		local tooltip = item and item:getTooltip() or ""

		var_19_2:setTooltip(tooltip ~= "" and tooltip or nil)
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
	local var_21_1 = math.floor(duration % 86400 / 3600)
	local var_21_2 = math.floor(duration % 3600 / 60)
	local seconds = duration % 60

	if hours > 0 then
		return string.format("%dd %dh %dmin", hours, var_21_1, var_21_2)
	elseif var_21_1 > 0 then
		return string.format("%dh %dmin", var_21_1, var_21_2)
	elseif var_21_2 > 0 then
		return string.format("%dmin", var_21_2)
	end

	return string.format("%ds", seconds)
end
