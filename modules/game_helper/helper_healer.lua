-- Root locals stored in a lexical table to fit the LuaJIT 200-local limit.
local healerState = {}
HelperHealer = HelperHealer or {}

 healerState.ctx = nil
 healerState.healingEntries = {}
 healerState.healingEntriesPanel = nil
 healerState.healingSpellEntriesPanel = nil
 healerState.healingPotionEntriesPanel = nil
 healerState[5] = 1
 healerState[6] = nil
 healerState.addHealingSlot = nil
 healerState[8] = nil
 healerState[9] = nil
 healerState.syncAddHealingConfirmButtons = nil
 healerState[11] = nil
 healerState[12] = nil
 healerState[13] = nil
 healerState[14] = nil
 healerState[15] = nil
 healerState.helperAssignWindow = nil
 healerState.helperAssignPanel = nil
 healerState.helperAssignMode = nil
 healerState.helperAssignTargetSlot = nil
 healerState.ACTION_SLOT_SPELL_ITEM_ID = 469
 healerState.SLOT_IMG_EMPTY = "/images/game/actionbar/slot-actionbar-empty"
 healerState.SLOT_CLIP_NORMAL = "0 0 34 34"

  healerState[23] = function()
	if type(healerState.healingEntries) ~= "table" then
		healerState.healingEntries = {}
	end
end

  healerState.saveConfigIfReady = function()
	if healerState.ctx and healerState.ctx.isLoadingConfig and healerState.ctx.isLoadingConfig() then
		return
	end

	if healerState.ctx and healerState.ctx.saveConfig then
		healerState.ctx.saveConfig()
	end
end

  healerState[25] = function()
	if SpelllistSettings and SpelllistSettings.Default then
		return "Default"
	end

	if SpelllistSettings then
		for profile in pairs(SpelllistSettings) do
			return profile
		end
	end

	return "Default"
end

  healerState.normalizeEntryWords = function(words)
	if words == nil then
		return nil
	end

	if type(words) == "string" then
		local trimmed = words:match("^%s*(.-)%s*$") or ""

		if trimmed == "" then
			return nil
		end

		return trimmed
	end

	if type(words) == "number" then
		local spell = Spells.getSpellByClientId(words)

		if spell and spell.words then
			return spell.words
		end
	end

	return nil
end

 healerState[27] = 1
 healerState[28] = 100
 healerState[29] = 80
 healerState.IGNORED_HEALING_SPELL_IDS = {
	[144] = true,
	[128] = true,
	[145] = true,
	[146] = true,
	[29] = true,
	[242] = true,
	[84] = true,
	[297] = true
}
 healerState.POTION_WHITELIST = {
	{
		name = "Mana Potion",
		id = 268,
		type = "mana",
		requiredLevel = 1
	},
	{
		name = "Strong Mana Potion",
		id = 237,
		type = "mana",
		requiredLevel = 50
	},
	{
		name = "Great Mana Potion",
		id = 238,
		type = "mana",
		requiredLevel = 80
	},
	{
		name = "Ultimate Mana Potion",
		id = 23373,
		type = "mana",
		requiredLevel = 130
	},
	{
		name = "Health Potion",
		id = 266,
		type = "health",
		requiredLevel = 1
	},
	{
		name = "Strong Health Potion",
		id = 236,
		type = "health",
		requiredLevel = 50
	},
	{
		name = "Great Health Potion",
		id = 239,
		type = "health",
		requiredLevel = 80
	},
	{
		name = "Ultimate Health Potion",
		id = 7643,
		type = "health",
		requiredLevel = 130
	},
	{
		name = "Supreme Health Potion",
		id = 23375,
		type = "health",
		requiredLevel = 200
	},
	{
		name = "Great Spirit Potion",
		id = 7642,
		type = "health",
		requiredLevel = 80
	},
	{
		name = "Ultimate Spirit Potion",
		id = 23374,
		type = "health",
		requiredLevel = 130
	},
	{
		name = "Small Health Potion",
		id = 7876,
		type = "health",
		requiredLevel = 1
	},
	{
		name = "superior mana potion",
		id = 53162,
		type = "mana",
		requiredLevel = 100
	},
	{
		name = "distilled superior mana potion",
		id = 53163,
		type = "mana",
		requiredLevel = 130
	},
	{
		name = "distilled ultimate mana potion",
		id = 53164,
		type = "mana",
		requiredLevel = 200
	}
}
 healerState.BLOCKED_POTION_IDS = {
	[35563] = true
}

  healerState.isBlockedHealingPotionId = function(itemId)
	return itemId and healerState.BLOCKED_POTION_IDS[tonumber(itemId) or itemId] == true
end

  healerState.isHealingFoodEntry = function(data)
	return data and data.useType == "use"
end

 healerState[35] = {
	spells = {},
	groups = {}
}
 healerState.multiUseExDelay = {
	lastHealthPotionWasPlain = false,
	potionUntil = 0,
	spells = {},
	groups = {}
}
 healerState[37] = 0
 healerState[38] = false
 healerState[39] = 1000
 healerState[40] = 1000
 healerState.ZEBRA_COLOR_A = "#484848"
 healerState.ZEBRA_COLOR_B = "#414141"
 healerState.ZEBRA_FOCUS_COLOR = "#585858"
 healerState.ZEBRA_TEXT_COLOR = "#c0c0c0"
 healerState.ZEBRA_FOCUS_TEXT_COLOR = "#f4f4f4"

  healerState[46] = function(panel)
	if not panel then
		return
	end

	local idx = 0

	for _, child in ipairs(panel:getChildren()) do
		if child:isVisible() then
			idx = idx + 1

			local color = idx % 2 == 1 and healerState.ZEBRA_COLOR_A or healerState.ZEBRA_COLOR_B

			child.zebraColor = color

			child:setBackgroundColor(color)
		end
	end
end

  healerState.setHealingRowTextColors = function(row, color)
	for _, childId in ipairs({
		"healingRowValue",
		"healingRowCondition",
		"healingConditionName",
		"healingConditionMetricLabel"
	}) do
		local label = row:recursiveGetChildById(childId)

		if label and label.setColor then
			label:setColor(color)
		end
	end
end

  healerState.resolveHealingEntryPanels = function()
	if healerState.ctx then
		if (not healerState.healingEntriesPanel or healerState.healingEntriesPanel:isDestroyed()) and healerState.ctx.getWidget then
			healerState.healingEntriesPanel = healerState.ctx.getWidget("healingEntriesPanel")
		end

		if (not healerState.healingSpellEntriesPanel or healerState.healingSpellEntriesPanel:isDestroyed()) and healerState.ctx.getWidget then
			healerState.healingSpellEntriesPanel = healerState.ctx.getWidget("healingSpellEntriesPanel")
		end

		if (not healerState.healingPotionEntriesPanel or healerState.healingPotionEntriesPanel:isDestroyed()) and healerState.ctx.getWidget then
			healerState.healingPotionEntriesPanel = healerState.ctx.getWidget("healingPotionEntriesPanel")
		end
	end
end

  healerState.forEachHealingEntryPanel = function(callback)
	healerState.resolveHealingEntryPanels()

	local panels = {
		healerState.healingSpellEntriesPanel,
		healerState.healingPotionEntriesPanel,
		healerState.healingEntriesPanel
	}

	for i = 1, 3 do
		local panel = panels[i]

		if panel and not panel:isDestroyed() then
			callback(panel)
		end
	end
end

  healerState[50] = function()
	local entryId

	healerState.forEachHealingEntryPanel(function(panel)
		if entryId then
			return
		end

		local focused = panel:getFocusedChild()

		if focused and focused.healingEntryId then
			entryId = focused.healingEntryId
		end
	end)

	return entryId
end

  healerState[51] = function(entryId)
	local targetRow

	healerState.forEachHealingEntryPanel(function(panel)
		if targetRow then
			return
		end

		for _, row in ipairs(panel:getChildren()) do
			if row.healingEntryId == entryId then
				targetRow = row

				return
			end
		end
	end)

	return targetRow
end

  healerState[52] = function(row)
	if not row or row:isDestroyed() then
		return
	end

	local parent = row:getParent()

	if parent and parent.focusChild then
		parent:focusChild(row, KeyboardFocusReason)
	end

	row:setBackgroundColor(healerState.ZEBRA_FOCUS_COLOR)
	healerState.setHealingRowTextColors(row, healerState.ZEBRA_FOCUS_TEXT_COLOR)
end

  healerState.resetHealingRowFocusColors = function()
	healerState.forEachHealingEntryPanel(function(panel)
		for _, row in ipairs(panel:getChildren()) do
			if row.zebraColor then
				row:setBackgroundColor(row.zebraColor)
				healerState.setHealingRowTextColors(row, healerState.ZEBRA_TEXT_COLOR)
			end
		end
	end)
end

  healerState[54] = function(widget)
	while widget do
		if widget.healingEntryId then
			return widget
		end

		widget = widget:getParent()
	end

	return nil
end

  healerState.syncHealingActionButtons = function()
	if not healerState.ctx then
		return
	end

	local widget = healerState.ctx.getWidget("addHealingButton")
	local editHealingButton = healerState.ctx.getWidget("editHealingButton")
	local removeHealingButton = healerState.ctx.getWidget("removeHealingButton")

	if not widget or not editHealingButton or not removeHealingButton then
		return
	end

	if healerState[50]() ~= nil then
		removeHealingButton:show()
		editHealingButton:show()
		widget:breakAnchors()
		widget:addAnchor(AnchorTop, "parent", AnchorTop)
		widget:addAnchor(AnchorRight, "editHealingButton", AnchorLeft)
		widget:setMarginRight(6)
	else
		removeHealingButton:hide()
		editHealingButton:hide()
		widget:breakAnchors()
		widget:addAnchor(AnchorTop, "parent", AnchorTop)
		widget:addAnchor(AnchorRight, "parent", AnchorRight)
		widget:setMarginRight(0)
	end
end

  healerState[56] = function(widget)
	connect(widget, {
		onFocusChange = function(self, focused)
			if focused then
				self:setBackgroundColor(healerState.ZEBRA_FOCUS_COLOR)
				healerState.setHealingRowTextColors(self, healerState.ZEBRA_FOCUS_TEXT_COLOR)
				healerState.syncHealingActionButtons()
			else
				addEvent(function()
					if not self:isDestroyed() then
						self:setBackgroundColor(self.zebraColor or healerState.ZEBRA_COLOR_A)
						healerState.setHealingRowTextColors(self, healerState.ZEBRA_TEXT_COLOR)
						healerState.syncHealingActionButtons()
					end
				end)
			end
		end
	})
end

  healerState[57] = function()
	healerState.forEachHealingEntryPanel(function(panel)
		panel:focusChild(nil)
	end)
	healerState.resetHealingRowFocusColors()
	healerState.syncHealingActionButtons()
end

 healerState.SPIRIT_POTION_IDS = {
	[23374] = true,
	[7642] = true
}
 healerState.POTION_TYPE_BY_ID = {}

for _, potion in ipairs(healerState.POTION_WHITELIST) do
	healerState.POTION_TYPE_BY_ID[potion.id] = potion.type
end

  healerState.actionbar = function()
	return modules.game_actionbar
end

  healerState.normalizePotionLevel = function(requiredLevel)
	local level = tonumber(requiredLevel) or 1

	if level < 1 then
		level = 1
	end

	return level
end

  healerState.potionMeetsLevel = function(requiredLevel)
	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	return player:getLevel() >= healerState.normalizePotionLevel(requiredLevel)
end

  healerState[63] = function(itemId)
	for _, potion in ipairs(healerState.POTION_WHITELIST) do
		if potion.id == itemId then
			if potion.requiredLevel then
				return healerState.normalizePotionLevel(potion.requiredLevel)
			end

			break
		end
	end

	if g_things and g_things.getThingType then
		local ok, thing = pcall(function()
			return g_things.getThingType(itemId, ThingCategoryItem)
		end)

		if ok and thing then
			local market = thing.getMarketData and thing:getMarketData() or nil

			if market and market.requiredLevel and market.requiredLevel > 0 then
				return healerState.normalizePotionLevel(market.requiredLevel)
			end
		end
	end

	return 1
end

  healerState.potionItemMeetsLevel = function(arg_30_0)
	return healerState.potionMeetsLevel(healerState[63](arg_30_0))
end

 healerState.shouldShowPotionLevelGray = nil

  healerState.playerCanUseHealingSpellVocations = function(vocations, player)
	if not vocations or not next(vocations) then
		return true
	end

	if not player then
		return false
	end

	local rawVoc = player:getVocation()
	local translatedVoc = type(translateVocation) == "function" and translateVocation(rawVoc) or rawVoc

	for _, voc in ipairs(vocations) do
		if voc == translatedVoc then
			return true
		end
	end

	return false
end

  healerState.shouldShowHealingSpellGray = function(words)
	words = healerState.normalizeEntryWords(words)

	if not words then
		return false
	end

	if not Spells or not Spells.getSpellByWords then
		return false
	end

	local spell = Spells.getSpellByWords(words)

	if not spell then
		return false
	end

	local player = g_game.getLocalPlayer()

	if player and spell.vocations and not healerState.playerCanUseHealingSpellVocations(spell.vocations, player) then
		return true
	end

	if spell.level and player and not healerState.potionMeetsLevel(spell.level) then
		return true
	end

	return false
end

  healerState[68] = function(entry)
	if not entry then
		return false
	end

	local ok, result = pcall(function()
		local words = healerState.normalizeEntryWords(entry.words)

		if words then
			return healerState.shouldShowHealingSpellGray(words)
		end

		if entry.itemId and entry.itemId > 0 then
			if healerState.SPIRIT_POTION_IDS[tonumber(entry.itemId) or entry.itemId] == true then
				return false
			end

			return healerState.shouldShowPotionLevelGray(entry.itemId)
		end

		return false
	end)

	if not ok then
		if g_logger and g_logger.warning then
			g_logger.warning("[HelperHealer] shouldShowHealingRowGray failed: " .. tostring(result))
		end

		return false
	end

	return result
end

  healerState[69] = function(slot)
	if not slot then
		return false
	end

	if slot.words and slot.words ~= "" then
		return false
	end

	local itemId = tonumber(slot.itemId)

	return itemId and itemId > 0 and itemId ~= healerState.ACTION_SLOT_SPELL_ITEM_ID
end

  healerState.isHealingActionSlot = function(slot)
	return slot and (slot._helperHealingSlot == true or healerState.addHealingSlot and slot == healerState.addHealingSlot)
end

  healerState.stackHealingActionSlotLayers = function(slot)
	if not healerState.isHealingActionSlot(slot) then
		return
	end

	local bg = slot:getChildById("healingActionItemBackground")
	local itemIcon = slot:getChildById("healingActionItemIcon")
	local spellIcon = slot:getChildById("spellIcon")
	local gray = slot:getChildById("gray")

	if gray then
		gray:setPhantom(true)
		gray:setFocusable(false)
		gray:setOpacity(0.35)
	end

	if bg then
		slot:raiseChild(bg)
	end

	if spellIcon then
		slot:raiseChild(spellIcon)
	end

	if itemIcon then
		slot:raiseChild(itemIcon)
	end

	if gray then
		slot:raiseChild(gray)
	end
end

  healerState.syncHealingActionSlotLayers = function(slot)
	if not healerState.isHealingActionSlot(slot) then
		return
	end

	local bg = slot:getChildById("healingActionItemBackground")
	local itemIcon = slot:getChildById("healingActionItemIcon")
	local hasSpell = slot.words and slot.words ~= ""

	if healerState[69](slot) then
		local displayItemId = tonumber(slot._helperDisplayItemId or slot.itemId) or 0

		if slot.setItemVisible then
			slot:setItemVisible(false)
		end

		if bg then
			bg:show()
		end

		if itemIcon then
			if itemIcon.clearItem then
				itemIcon:clearItem()
			end

			if itemIcon.setItemId then
				itemIcon:setItemId(displayItemId)
			end

			itemIcon:show()
		end
	else
		if bg then
			bg:hide()
		end

		if itemIcon then
			itemIcon:hide()

			if itemIcon.clearItem then
				itemIcon:clearItem()
			end
		end

		if slot.setItemVisible then
			slot:setItemVisible(not hasSpell)
		end
	end

	healerState.stackHealingActionSlotLayers(slot)
end

  healerState.updateHealingActionSlotGray = function(slot)
	if not healerState.isHealingActionSlot(slot) then
		return
	end

	local gray = slot:getChildById("gray")

	if not gray then
		return
	end

	if slot.words and slot.words ~= "" then
		local ab = healerState.actionbar()

		if ab and ab.updateSlotGray then
			ab.updateSlotGray(slot)
		end

		return
	end

	local numericValue = tonumber(slot._helperDisplayItemId or slot.itemId) or 0

	if healerState.SPIRIT_POTION_IDS[numericValue] == true then
		gray:setVisible(false)

		return
	end

	gray:setVisible(healerState.shouldShowPotionLevelGray(numericValue))
end

  healerState.refreshSlotVisual = function(slot)
	local ab = healerState.actionbar()

	if not slot or not ab then
		return
	end

	local hasSpell = slot.words and slot.words ~= ""

	if healerState[69](slot) or hasSpell then
		if ab.applyActionSlotFrame then
			ab.applyActionSlotFrame(slot)
		end

		if slot._helperAssignPreview and ab.refreshActionSlotFrameClip then
			ab.refreshActionSlotFrameClip(slot)
		end
	elseif slot._helperAssignPreview then
		slot:setImageSource(healerState.SLOT_IMG_EMPTY)
		slot:setImageSize(tosize("34 34"))
		slot:setImageClip(healerState.SLOT_CLIP_NORMAL)

		slot._actionBarFilledFrame = false
	elseif ab.applyActionSlotFrame then
		ab.applyActionSlotFrame(slot)
	end

	healerState.syncHealingActionSlotLayers(slot)

	if healerState.isHealingActionSlot(slot) then
		healerState.updateHealingActionSlotGray(slot)
	else
		local abGray = healerState.actionbar()

		if abGray and abGray.updateSlotGray then
			abGray.updateSlotGray(slot)
		end
	end

	if ab.refreshActionSlotInventoryQuantity then
		ab.refreshActionSlotInventoryQuantity(slot)
	end

	if ab.refreshActionSlotTooltip then
		ab.refreshActionSlotTooltip(slot)
	end

	healerState.stackHealingActionSlotLayers(slot)
end

  healerState.clearSlotData = function(slot)
	local ab = healerState.actionbar()

	if ab and ab.clearSlotActionContent then
		ab.clearSlotActionContent(slot)

		slot._helperDisplayItemId = nil

		if slot == healerState.addHealingSlot then
			healerState.refreshSlotVisual(slot)
		end

		if slot == healerState.addHealingSlot then
			healerState.syncAddHealingConfirmButtons()
		end

		return
	end

	if slot.clearItem then
		slot:clearItem()
	end

	local spellIcon = slot:getChildById("spellIcon")

	if spellIcon then
		spellIcon:hide()
		spellIcon:setImageSource("")
	end

	slot.itemId = nil
	slot._helperDisplayItemId = nil
	slot.words = nil
	slot.text = nil
	slot.subType = nil
	slot.useType = nil
	slot.parameter = nil

	healerState.refreshSlotVisual(slot)

	if slot == healerState.addHealingSlot then
		healerState.syncAddHealingConfirmButtons()
	end
end

  healerState.assignItemToSlot = function(slot, option, arg_42_2)
	if not option or healerState.isHealingFoodEntry(option) or healerState.isBlockedHealingPotionId(option.itemId) then
		return
	end

	healerState.clearSlotData(slot)

	slot.itemId = option.itemId
	slot._helperDisplayItemId = option.itemId
	slot.useType = option.useType or "useOnSelf"

	if slot.setItemId then
		slot:setItemId(option.itemId)
	elseif slot.setItem then
		local item = Item.create(option.itemId)

		if item then
			slot:setItem(item)
		end
	end

	local ab = healerState.actionbar()

	if ab and ab.loadObject then
		ab.loadObject(slot)
	end

	healerState.refreshSlotVisual(slot)

	if not arg_42_2 and healerState.ctx and healerState.ctx.saveConfig then
		healerState.saveConfigIfReady()
	end

	if slot == healerState.addHealingSlot then
		healerState.syncAddHealingConfirmButtons()
	end
end

  healerState.containsGroup = function(groups, targetGroup)
	if not groups then
		return false
	end

	for _, group in ipairs(groups) do
		if group == targetGroup then
			return true
		end
	end

	return false
end

  healerState[78] = function(_, spellData)
	if not spellData then
		return false
	end

	if healerState.IGNORED_HEALING_SPELL_IDS[spellData.id] then
		return false
	end

	if spellData.needTarget and spellData.parameter then
		return false
	end

	return healerState.containsGroup(Spells.getGroupIds(spellData), 2)
end

  healerState[79] = function(slot, filterFn, onAssigned)
	local ab = healerState.actionbar()

	if not ab or not ab.openHelperSpellAssignWindow then
		return
	end

	local slotId = slot:getId()

	if not slotId or slotId == "" then
		return
	end

	ab.openHelperSpellAssignWindow(slot, slotId, filterFn, function(assignedSlot)
		if onAssigned then
			onAssigned(assignedSlot or slot)
		elseif healerState.ctx and healerState.ctx.saveConfig then
			healerState.saveConfigIfReady()
		end
	end)
end

  healerState[80] = function(arg_47_0, id)
	local trim = (arg_47_0:getName() or ""):gsub("^%s+", ""):gsub("%s+$", "")

	if trim ~= "" then
		return trim
	end

	return "#" .. tostring(id)
end

  healerState[81] = function(text)
	if not text or text == "" then
		return ""
	end

	return (text:gsub("(%a)([%w_']*)", function(a, rest)
		return a:upper() .. rest:lower()
	end))
end

  healerState.potionMeetsVocation = function(thing)
	if not thing then
		return true
	end

	local market = thing.getMarketData and thing:getMarketData() or nil

	if not market or not market.restrictVocation or tonumber(market.restrictVocation) == 0 then
		return true
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	local vocation = player:getVocation()
	local demotedVoc = vocation > 10 and vocation - 10 or vocation
	local vocBitMask = Bit.bit(tonumber(demotedVoc))

	return Bit.hasBit(market.restrictVocation, vocBitMask)
end

function HelperHealer.potionAllowedForVocation(thingId)
	local thingType = thingId and g_things and g_things.getThingType and g_things.getThingType(thingId, ThingCategoryItem) or nil

	if not thingType then
		return nil
	end

	local marketData = thingType.getMarketData and thingType:getMarketData() or nil

	if not marketData or marketData.restrictVocation == nil then
		return nil
	end

	return healerState.potionMeetsVocation(thingType)
end

  healerState.formatPotionLevelText = function(requiredLevel)
	return tr("Level:") .. " " .. tostring(healerState.normalizePotionLevel(requiredLevel))
end

  healerState.buildPotionAssignList = function()
	local potions = {}

	for _, potion in ipairs(healerState.POTION_WHITELIST) do
		local thing = g_things.getThingType(potion.id, ThingCategoryItem)

		if thing and healerState.potionMeetsVocation(thing) then
			table.insert(potions, {
				id = potion.id,
				name = potion.name,
				requiredLevel = healerState[63](potion.id)
			})
		end
	end

	table.sort(potions, function(a, b)
		return a.name:lower() < b.name:lower()
	end)

	return potions
end

  healerState.potionItemIsAvailable = function(itemId)
	if not itemId then
		return true
	end

	if healerState.isBlockedHealingPotionId(itemId) then
		return false
	end

	local thing = g_things.getThingType(itemId, ThingCategoryItem)

	return healerState.potionItemMeetsLevel(itemId) and healerState.potionMeetsVocation(thing)
end

 healerState.shouldShowPotionLevelGray = function(itemId)
	if not itemId then
		return false
	end

	return not healerState.potionItemIsAvailable(itemId)
end

  healerState.closeHelperItemAssignInternal = function()
	healerState.helperAssignTargetSlot = nil
	healerState.helperAssignMode = nil
	healerState.helperAssignPanel = nil

	if healerState.helperAssignWindow and not healerState.helperAssignWindow:isDestroyed() then
		healerState.helperAssignWindow:destroy()
	end

	healerState.helperAssignWindow = nil
end

  healerState.helperItemAssignUsesLearntFilter = function()
	return healerState.helperAssignMode == "potion"
end

  healerState.rowMeetsLearntFilter = function(arg_59_0)
	if not healerState.helperItemAssignUsesLearntFilter() then
		return true
	end

	return healerState.potionItemIsAvailable(arg_59_0.assignItemId)
end

  healerState.stackHelperAssignRowLayers = function(row)
	if not row then
		return
	end

	local bg = row:getChildById("listItemBackground")
	local itemIcon = row:getChildById("listItemIcon")
	local gray = row:getChildById("spellIconGray")

	if bg then
		row:raiseChild(bg)
	end

	if itemIcon then
		row:raiseChild(itemIcon)
	end

	if gray then
		row:raiseChild(gray)
	end
end

  healerState.syncHelperAssignRowGray = function(row)
	if not row then
		return
	end

	local gray = row:getChildById("spellIconGray")

	if not gray then
		return
	end

	if healerState.helperAssignMode == "potion" then
		gray:setVisible(healerState.shouldShowPotionLevelGray(row.assignItemId))
	else
		gray:hide()
	end

	healerState.stackHelperAssignRowLayers(row)
end

  healerState.updateHelperItemPreview = function(row)
	if not healerState.helperAssignWindow or healerState.helperAssignWindow:isDestroyed() or not row then
		return
	end

	local preview = healerState.helperAssignWindow:recursiveGetChildById("spellPreview")

	if not preview then
		return
	end

	local spellIcon = preview:getChildById("previewSpellIcon")
	local itemIcon = preview:getChildById("previewItemIcon")
	local spellGray = preview:getChildById("previewSpellGray")
	local itemGray = preview:getChildById("previewItemGray")
	local nameLabel = preview:getChildById("previewSpellName")
	local wordsLabel = preview:getChildById("previewSpellWords")

	if spellIcon then
		spellIcon:hide()
	end

	if spellGray then
		spellGray:hide()
	end

	local itemBg = preview:getChildById("previewItemBackground")

	if itemIcon then
		itemIcon:show()
		itemIcon:setItemId(row.assignItemId or 0)
	end

	if itemBg then
		itemBg:show()
	end

	if nameLabel then
		nameLabel:setText(row.assignItemName or "")
	end

	if wordsLabel then
		wordsLabel:setText("")
	end

	if itemGray then
		if healerState.helperAssignMode == "potion" then
			itemGray:setVisible(healerState.shouldShowPotionLevelGray(row.assignItemId))
		else
			itemGray:hide()
		end

		preview:raiseChild(itemGray)
	end
end

  healerState.clearHelperItemPreview = function()
	if not healerState.helperAssignWindow or healerState.helperAssignWindow:isDestroyed() then
		return
	end

	local preview = healerState.helperAssignWindow:recursiveGetChildById("spellPreview")

	if not preview then
		return
	end

	local spellIcon = preview:getChildById("previewSpellIcon")
	local itemIcon = preview:getChildById("previewItemIcon")
	local itemBg = preview:getChildById("previewItemBackground")
	local itemGray = preview:getChildById("previewItemGray")

	if spellIcon then
		spellIcon:hide()
	end

	if itemIcon then
		itemIcon:hide()
	end

	if itemBg then
		itemBg:hide()
	end

	if itemGray then
		itemGray:hide()
	end

	local nameLabel = preview:getChildById("previewSpellName")
	local wordsLabel = preview:getChildById("previewSpellWords")

	if nameLabel then
		nameLabel:setText("")
	end

	if wordsLabel then
		wordsLabel:setText("")
	end
end

  healerState.syncHelperItemAssignOkButton = function()
	if not healerState.helperAssignWindow or healerState.helperAssignWindow:isDestroyed() or not healerState.helperAssignPanel then
		return
	end

	local okBtn = healerState.helperAssignWindow:recursiveGetChildById("okButton")

	if not okBtn then
		return
	end

	local focused = healerState.helperAssignPanel:getFocusedChild()

	okBtn:setEnabled(focused ~= nil and focused:isVisible() and focused.assignItemId ~= nil)
end

  healerState.focusFirstVisibleHelperAssignRow = function()
	if not healerState.helperAssignPanel then
		return
	end

	local first

	for _, child in ipairs(healerState.helperAssignPanel:getChildren()) do
		if child:isVisible() then
			first = child

			break
		end
	end

	if first then
		healerState.helperAssignPanel:focusChild(first, KeyboardFocusReason)
		healerState.updateHelperItemPreview(first)
	else
		healerState.helperAssignPanel:focusChild(nil)
		healerState.clearHelperItemPreview()
	end

	healerState.syncHelperItemAssignOkButton()
end

  healerState.createHelperItemAssignRow = function(itemId, itemName, requiredLevel)
	local row = g_ui.createWidget("HelperAssignListLabel", healerState.helperAssignPanel)

	row.assignItemId = itemId
	row.assignItemName = itemName
	row.nameLower = itemName:lower()
	row.requiredLevel = requiredLevel

	local spellIcon = row:getChildById("spellIcon")

	if spellIcon then
		spellIcon:hide()
	end

	local groupIcon = row:getChildById("groupCooldownIcon")

	if groupIcon then
		groupIcon:hide()
	end

	local levelLabel = row:getChildById("spellLevel")
	local nameLabel = row:getChildById("spellName")
	local wordsLabel = row:getChildById("spellWords")
	local itemIcon = row:getChildById("listItemIcon")

	if itemIcon then
		itemIcon:show()
		itemIcon:setItemId(itemId)
	end

	local itemBg = row:getChildById("listItemBackground")

	if itemBg then
		itemBg:show()
	end

	healerState.syncHelperAssignRowGray(row)

	if nameLabel then
		nameLabel:setText(itemName)
	end

	if wordsLabel then
		wordsLabel:setText("")
		wordsLabel:hide()
	end

	if levelLabel then
		if healerState.helperAssignMode == "potion" then
			levelLabel:show()
			levelLabel:setText(healerState.formatPotionLevelText(requiredLevel))
		else
			levelLabel:hide()
		end
	end

	return row
end

  healerState.openHelperItemAssignWindow = function(helperAssignTargetSlot)
	if healerState.helperAssignWindow and not healerState.helperAssignWindow:isDestroyed() then
		healerState.closeHelperItemAssignInternal()
	end

	healerState.helperAssignWindow = g_ui.loadUI("assign_helper", g_ui.getRootWidget())

	if not healerState.helperAssignWindow then
		return
	end

	healerState.helperAssignMode = "potion"
	healerState.helperAssignTargetSlot = helperAssignTargetSlot
	healerState.helperAssignPanel = healerState.helperAssignWindow:recursiveGetChildById("spellsPanel")

	healerState.helperAssignWindow:setText(tr("Assign Potion"))

	local learntPanel = healerState.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsPanel")

	if learntPanel then
		learntPanel:setVisible(true)
	end

	local learntCb = healerState.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

	if learntCb then
		learntCb:setChecked(false)
		learntCb:setText(tr("Only show available potions"))
	end

	local okBtn = healerState.helperAssignWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setEnabled(false)
	end

	for _, potion in ipairs(healerState.buildPotionAssignList()) do
		healerState.createHelperItemAssignRow(potion.id, potion.name, potion.requiredLevel)
	end

	connect(healerState.helperAssignPanel, {
		onChildFocusChange = function(_, focusedChild)
			if not focusedChild then
				healerState.syncHelperItemAssignOkButton()

				return
			end

			healerState.updateHelperItemPreview(focusedChild)
			healerState.syncHelperItemAssignOkButton()
		end
	})
	HelperHealer.filterHelperAssignEntries("")
	healerState.focusFirstVisibleHelperAssignRow()
	healerState.helperAssignWindow:raise()
	healerState.helperAssignWindow:focus()

	local edit = healerState.helperAssignWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:focus()
	end
end

  healerState[97] = function(targetSlot)
	healerState.openHelperItemAssignWindow(targetSlot)
end

function HelperHealer.isHelperItemAssignActive()
	return healerState.helperAssignWindow and not healerState.helperAssignWindow:isDestroyed()
end

function HelperHealer.closeHelperItemAssignWindow()
	if HelperHealer.cancelPendingHealingEntryAssign then
		HelperHealer.cancelPendingHealingEntryAssign()
	end

	healerState.closeHelperItemAssignInternal()
end

function HelperHealer.helperItemAssignOk()
	if not HelperHealer.isHelperItemAssignActive() or not healerState.helperAssignPanel or not healerState.helperAssignTargetSlot then
		return
	end

	local focused = healerState.helperAssignPanel:getFocusedChild()

	if not focused or not focused.assignItemId then
		return
	end

	local targetSlot = healerState.helperAssignTargetSlot
	local useType = "useOnSelf"
	local skipSave = healerState.addHealingSlot and targetSlot == healerState.addHealingSlot or targetSlot._helperAssignSkipSave == true

	healerState.assignItemToSlot(targetSlot, {
		itemId = focused.assignItemId,
		useType = useType
	}, skipSave)
	healerState.closeHelperItemAssignInternal()

	if targetSlot.onHelperPotionAssigned then
		targetSlot.onHelperPotionAssigned(targetSlot)
	end
end

function HelperHealer.filterHelperAssignEntries(text)
	if not healerState.helperAssignPanel or not HelperHealer.isHelperItemAssignActive() then
		return
	end

	text = text or ""

	local textActive = #text > 0
	local textLower = textActive and text:lower() or ""
	local onlyLearnt = false

	if healerState.helperAssignWindow then
		local learntCb = healerState.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

		onlyLearnt = learntCb and learntCb:isChecked() or false
	end

	for _, row in ipairs(healerState.helperAssignPanel:getChildren()) do
		local visible = true

		if onlyLearnt and not healerState.rowMeetsLearntFilter(row) then
			visible = false
		end

		if visible and textActive then
			visible = row.nameLower and row.nameLower:find(textLower, 1, true) ~= nil or false
		end

		row:setVisible(visible)
	end

	healerState.focusFirstVisibleHelperAssignRow()
end

function HelperHealer.clearHelperItemAssignFilter()
	if not HelperHealer.isHelperItemAssignActive() then
		return
	end

	local edit = healerState.helperAssignWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:setText("")
		HelperHealer.filterHelperAssignEntries("")
		edit:focus()
	end
end

function HelperHealer.onHelperAssignLearntChange()
	if not HelperHealer.isHelperItemAssignActive() then
		return
	end

	local edit = healerState.helperAssignWindow:recursiveGetChildById("filterTextEdit")

	HelperHealer.filterHelperAssignEntries(edit and edit:getText() or "")
end

function HelperHealer.closePotionAssignWindow()
	healerState.closeHelperItemAssignInternal()
end

function HelperHealer.potionAssignOk()
	HelperHealer.helperItemAssignOk()
end

function HelperHealer.filterPotions(text)
	HelperHealer.filterHelperAssignEntries(text)
end

function HelperHealer.clearPotionFilter()
	HelperHealer.clearHelperItemAssignFilter()
end

function HelperHealer.openPotionSelectWindow(targetSlot)
	if not targetSlot then
		return
	end

	healerState.openHelperItemAssignWindow(targetSlot)
end

  healerState[98] = function(slot)
	if g_game.getFeature and g_game.getFeature(GameThingUpgradeClassification) then
		local stored = slot and slot.getTier

		if type(stored) == "number" then
			return stored
		end
	end

	return 0
end

  healerState[99] = function(spellId)
	if Spells and Spells.resolveSpellId then
		return Spells.resolveSpellId(spellId)
	end

	return spellId
end

  healerState[100] = function()
	local exhaustion = g_game.getPing and tonumber(g_game.getPing()) or 0

	if exhaustion and exhaustion > 0 then
		return math.max(250, math.min(2000, exhaustion * 2 + 100))
	end

	return healerState[40]
end

  healerState[101] = function(spell, arg_84_1)
	healerState.multiUseExDelay.spells[healerState[99](spell.id)] = arg_84_1

	if type(spell.group) == "table" then
		for groupId in pairs(spell.group) do
			healerState.multiUseExDelay.groups[groupId] = arg_84_1
		end
	elseif spell.group then
		healerState.multiUseExDelay.groups[spell.group] = arg_84_1
	end
end

  healerState[102] = function()
	healerState[35] = {
		spells = {},
		groups = {}
	}
	healerState.multiUseExDelay = {
		lastHealthPotionWasPlain = false,
		potionUntil = 0,
		spells = {},
		groups = {}
	}
	healerState[37] = 0
end

  healerState[103] = function(arg_86_0, arg_86_1)
	local var_86_0 = healerState[99](arg_86_0)

	if not var_86_0 then
		return
	end

	healerState.multiUseExDelay.spells[var_86_0] = nil
	healerState[35].spells[var_86_0] = g_clock.millis() + math.max(0, tonumber(arg_86_1) or 0)
end

  healerState[104] = function(arg_87_0, arg_87_1)
	if not arg_87_0 then
		return
	end

	healerState.multiUseExDelay.groups[arg_87_0] = nil
	healerState[35].groups[arg_87_0] = g_clock.millis() + math.max(0, tonumber(arg_87_1) or 0)
end

  healerState[105] = function(arg_88_0)
	healerState.multiUseExDelay.potionUntil = 0

	if not arg_88_0 or arg_88_0 <= 0 then
		healerState[37] = 0

		return
	end

	healerState[37] = g_clock.millis() + arg_88_0
end

  healerState[106] = function()
	if healerState[38] then
		return
	end

	connect(g_game, {
		onSpellCooldown = healerState[103],
		onSpellGroupCooldown = healerState[104],
		onMultiUseCooldown = healerState[105],
		onGameEnd = healerState[102]
	})

	healerState[38] = true
end

  healerState[107] = function()
	if not healerState[38] then
		return
	end

	disconnect(g_game, {
		onSpellCooldown = healerState[103],
		onSpellGroupCooldown = healerState[104],
		onMultiUseCooldown = healerState[105],
		onGameEnd = healerState[102]
	})

	healerState[38] = false
end

  healerState[108] = function(arg_91_0)
	return healerState[35].spells[arg_91_0] or 0
end

  healerState[109] = function(arg_92_0)
	return healerState[35].groups[arg_92_0] or 0
end

  healerState[110] = function(arg_93_0)
	return healerState.POTION_TYPE_BY_ID[tonumber(arg_93_0) or arg_93_0] == "mana"
end

  healerState[111] = function(arg_94_0)
	return healerState.POTION_TYPE_BY_ID[tonumber(arg_94_0) or arg_94_0] == "health"
end

  healerState[112] = function(arg_95_0)
	return healerState.SPIRIT_POTION_IDS[tonumber(arg_95_0) or arg_95_0] == true
end

  healerState[113] = function(arg_96_0, arg_96_1, arg_96_2)
	if not arg_96_0 or not arg_96_1 then
		return false
	end

	local spellByWords = Spells.getSpellByWords(arg_96_0)

	if not spellByWords or not spellByWords.id or spellByWords.id <= 0 or not healerState[78](nil, spellByWords) then
		return false
	end

	if not arg_96_2 and spellByWords.mana and arg_96_1:getMana() < spellByWords.mana then
		return false
	end

	if spellByWords.level and arg_96_1:getLevel() < spellByWords.level then
		return false
	end

	if spellByWords.soul and arg_96_1:getSoul() < spellByWords.soul then
		return false
	end

	if spellByWords.vocations and not healerState.playerCanUseHealingSpellVocations(spellByWords.vocations, arg_96_1) then
		return false
	end

	if GameSpellList and g_game.getFeature(GameSpellList) then
		local spells = arg_96_1.getSpells and arg_96_1:getSpells() or {}
		local var_96_2 = false

		for unusedValue, entry in ipairs(spells) do
			if tonumber(entry) == spellByWords.id then
				var_96_2 = true

				break
			end
		end

		if not var_96_2 then
			return false
		end
	end

	return true
end

  healerState[114] = function(arg_97_0)
	local spellByWords = Spells.getSpellByWords(arg_97_0)

	if not spellByWords or spellByWords.id == 0 then
		return false
	end

	local var_97_1 = g_clock.millis()
	local var_97_2 = healerState[99](spellByWords.id)

	if var_97_1 < healerState[108](var_97_2) then
		return true
	end

	if type(spellByWords.group) == "table" then
		for key, unusedValue in pairs(spellByWords.group) do
			if var_97_1 < healerState[109](key) then
				return true
			end
		end
	elseif spellByWords.group and var_97_1 < healerState[109](spellByWords.group) then
		return true
	end

	local var_97_3 = healerState.actionbar()

	if var_97_3 and var_97_3.getMultiActionCooldownRemaining then
		local var_97_4, var_97_5 = var_97_3.getMultiActionCooldownRemaining(spellByWords)

		if var_97_4 > 0 then
			healerState.multiUseExDelay.spells[var_97_2] = nil
		end

		if var_97_5 > 0 then
			if type(spellByWords.group) == "table" then
				for iter_97_2 in pairs(spellByWords.group) do
					healerState.multiUseExDelay.groups[iter_97_2] = nil
				end
			elseif spellByWords.group then
				healerState.multiUseExDelay.groups[spellByWords.group] = nil
			end
		end

		if var_97_4 > 0 or var_97_5 > 0 then
			return true
		end
	end

	if var_97_1 < (healerState.multiUseExDelay.spells[var_97_2] or 0) then
		return true
	end

	if type(spellByWords.group) == "table" then
		for iter_97_3 in pairs(spellByWords.group) do
			if var_97_1 < (healerState.multiUseExDelay.groups[iter_97_3] or 0) then
				return true
			end
		end
	elseif spellByWords.group and var_97_1 < (healerState.multiUseExDelay.groups[spellByWords.group] or 0) then
		return true
	end

	return false
end

function HelperHealer.isItemUsePending()
	return healerState.multiUseExDelay.potionUntil > g_clock.millis()
end

  healerState[115] = function()
	local var_99_0 = g_clock.millis()
	local var_99_1 = healerState.actionbar()

	if var_99_1 and var_99_1.getItemMultiUseCooldownRemaining and var_99_1.getItemMultiUseCooldownRemaining() > 0 then
		healerState.multiUseExDelay.potionUntil = 0

		return true
	end

	return var_99_0 < healerState[37] or var_99_0 < healerState.multiUseExDelay.potionUntil or HelperShooter and HelperShooter.isItemUsePending and HelperShooter.isItemUsePending() or false
end

  healerState[116] = function(arg_100_0, arg_100_1, arg_100_2)
	if not arg_100_0 or not arg_100_1 or arg_100_1 <= 0 then
		return false
	end

	local var_100_0 = healerState[98](arg_100_2)

	if arg_100_0.getInventoryCount and arg_100_0:getInventoryCount(arg_100_1, var_100_0) > 0 then
		return true
	end

	if g_game.findPlayerItem then
		return g_game.findPlayerItem(arg_100_1, arg_100_2 and arg_100_2.subType or -1, var_100_0) ~= nil
	end

	return false
end

  healerState[117] = function(value, threshold, condition)
	if condition == "<" then
		return value < threshold
	end

	if condition == ">" then
		return threshold < value
	end

	if condition == ">=" then
		return threshold <= value
	end

	return value <= threshold
end

  healerState[118] = function(combo)
	if not combo then
		return nil
	end

	if combo.getCurrentOption then
		local current = combo:getCurrentOption()

		if type(current) == "table" then
			return current.text or current.value or current.label
		end

		if type(current) == "string" then
			return current
		end
	end

	if combo.getText then
		local text = combo:getText()

		if text and text ~= "" then
			return text
		end
	end

	return nil
end

  healerState[119] = function(metric)
	metric = tostring(metric or "HP"):upper():gsub("%%", "")

	if metric == "MP" or metric == "MANA" then
		return "MP"
	end

	return "HP"
end

  healerState[120] = function(arg_104_0)
	return healerState[119](arg_104_0) == "MP" and "MP%" or "HP%"
end

  healerState[121] = function(logic)
	logic = tostring(logic or "and"):lower()

	if logic == "or" then
		return "or"
	end

	return "and"
end

function HelperHealer.resolveLoadedSpiritMetric(raw)
	if raw.spiritMetric then
		return healerState[119](raw.spiritMetric)
	end

	local var_106_0 = type(raw.spiritConfig) == "table" and raw.spiritConfig or nil

	if var_106_0 then
		if var_106_0.mpEnabled and not var_106_0.hpEnabled then
			return "MP"
		end

		return "HP"
	end

	local textValue = tostring(raw.spiritMode or ""):lower()

	if textValue == "mp" or textValue == "mana" then
		return "MP"
	end

	if textValue == "hp" or textValue == "health" or textValue == "both" then
		return "HP"
	end

	return healerState[119](raw.whenMetric1 or raw.metric)
end

 healerState[122] = 1
 healerState[123] = 100
 healerState[124] = 1
 healerState[125] = 80
 healerState[126] = 80
 healerState[127] = 50
 healerState[128] = 1
 healerState[129] = 350

  healerState[130] = function(arg_107_0, arg_107_1)
	local numericValue = tonumber(arg_107_0)

	if not numericValue then
		return arg_107_1
	end

	if numericValue < healerState[122] then
		numericValue = healerState[122]
	end

	if numericValue > healerState[123] then
		numericValue = healerState[123]
	end

	return numericValue
end

  healerState[131] = function(condition)
	condition = tostring(condition or "<")

	if condition:find("<=", 1, true) then
		return "<="
	end

	if condition:find(">=", 1, true) then
		return ">="
	end

	if condition:find(">", 1, true) then
		return ">"
	end

	return "<"
end

  healerState[132] = function(arg_109_0)
	if arg_109_0.whenMetric1 or arg_109_0.thresholdMin ~= nil then
		return {
			whenMetric1 = healerState[119](arg_109_0.whenMetric1 or arg_109_0.metric),
			whenMetric2 = healerState[119](arg_109_0.whenMetric2 or arg_109_0.whenMetric1 or arg_109_0.metric),
			conditionLogic = healerState[121](arg_109_0.conditionLogic),
			conditionMin = healerState[131](arg_109_0.conditionMin or arg_109_0.condition),
			thresholdMin = healerState[130](arg_109_0.thresholdMin, healerState[124]),
			conditionMax = healerState[131](arg_109_0.conditionMax or "<="),
			thresholdMax = healerState[130](arg_109_0.thresholdMax, arg_109_0.threshold or healerState[125])
		}
	end

	local var_109_0 = healerState[119](arg_109_0.metric)
	local var_109_1 = healerState[131](arg_109_0.condition)
	local var_109_2 = healerState[130](arg_109_0.threshold, healerState[125])
	local var_109_3 = ">="
	local var_109_4 = healerState[122]
	local var_109_5 = "<="
	local var_109_6 = healerState[123]

	if var_109_1 == "<=" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", healerState[122], "<=", var_109_2
	elseif var_109_1 == "<" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", healerState[122], "<", var_109_2
	elseif var_109_1 == ">=" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", var_109_2, "<=", healerState[123]
	else
		var_109_3, var_109_4, var_109_5, var_109_6 = ">", var_109_2, "<=", healerState[123]
	end

	return {
		whenMetric1 = var_109_0,
		whenMetric2 = var_109_0,
		conditionLogic = healerState[121](arg_109_0.conditionLogic),
		conditionMin = var_109_3,
		thresholdMin = var_109_4,
		conditionMax = var_109_5,
		thresholdMax = var_109_6
	}
end

  healerState[133] = function(arg_110_0, arg_110_1)
	return healerState[119](arg_110_1) == "MP" and arg_110_0.manaPercent or arg_110_0.healthPercent
end

  healerState[134] = function(arg_111_0)
	if not arg_111_0 then
		return "spell"
	end

	if healerState.normalizeEntryWords(arg_111_0.words) then
		return "spell"
	end

	local numericValue = tonumber(arg_111_0.itemId)

	if numericValue and numericValue > 0 then
		return "potion"
	end

	return arg_111_0.kind == "potion" and "potion" or "spell"
end

  healerState[135] = function(arg_112_0)
	if healerState[134](arg_112_0) == "potion" then
		return healerState[127]
	end

	return healerState[126]
end

  healerState[136] = function(arg_113_0)
	if healerState[134](arg_113_0) == "potion" then
		if arg_113_0 and arg_113_0.itemId and healerState[112](arg_113_0.itemId) then
			return healerState[119](arg_113_0.spiritMetric)
		end

		if arg_113_0 and arg_113_0.itemId and healerState[110](arg_113_0.itemId) then
			return "MP"
		end

		return "HP"
	end

	return "HP"
end

function HelperHealer.getHealingEntryMetricText(entry)
	return healerState[136](entry)
end

  healerState[137] = function(arg_115_0, arg_115_1)
	arg_115_1 = arg_115_1 or healerState[135](arg_115_0)

	if arg_115_0 and arg_115_0.percent ~= nil then
		return healerState[130](arg_115_0.percent, arg_115_1)
	end

	local var_115_0 = arg_115_0 and healerState[132](arg_115_0) or nil

	if var_115_0 then
		return healerState[130](var_115_0.thresholdMax, arg_115_1)
	end

	return healerState[130](arg_115_1, arg_115_1)
end

  healerState[138] = function(arg_116_0, arg_116_1)
	if not arg_116_0 then
		return
	end

	arg_116_1 = healerState[130](arg_116_1, healerState[135](arg_116_0))

	local var_116_0 = healerState[136](arg_116_0)

	arg_116_0.percent = arg_116_1
	arg_116_0.whenMetric1 = var_116_0
	arg_116_0.whenMetric2 = var_116_0
	arg_116_0.conditionLogic = "and"
	arg_116_0.conditionMin = ">="
	arg_116_0.thresholdMin = healerState[122]
	arg_116_0.conditionMax = "<="
	arg_116_0.thresholdMax = arg_116_1
end

  healerState[139] = function(arg_117_0, arg_117_1)
	if not arg_117_0 or not arg_117_1 then
		return false
	end

	local var_117_0 = healerState[133](arg_117_1, healerState[136](arg_117_0))

	return var_117_0 ~= nil and var_117_0 <= healerState[137](arg_117_0)
end

function HelperHealer.entryMetricPercentConditionMet(entry, state, metric)
	if not entry or not state then
		return false
	end

	local var_118_0 = healerState[133](state, metric)

	return var_118_0 ~= nil and var_118_0 <= healerState[137](entry)
end

  healerState[140] = function(arg_119_0)
	local numericValue = tonumber(arg_119_0)

	if not numericValue then
		return healerState[29]
	end

	if numericValue < healerState[27] then
		numericValue = healerState[27]
	end

	if numericValue > healerState[28] then
		numericValue = healerState[28]
	end

	return numericValue
end

  healerState[141] = function(text)
	return tostring(text or ""):gsub("%D", "")
end

  healerState[142] = function(arg_121_0)
	if not arg_121_0 or not arg_121_0.getText then
		return healerState[29]
	end

	local text = arg_121_0:getText() or ""

	if text == "" then
		return healerState[29]
	end

	return healerState[140](text)
end

  healerState[143] = function(arg_122_0, arg_122_1)
	if not arg_122_0 then
		return arg_122_1
	end

	local var_122_0 = healerState[118](arg_122_0)

	if var_122_0 and var_122_0 ~= "" then
		return healerState[130](var_122_0, arg_122_1)
	end

	if not arg_122_0.getText then
		return arg_122_1
	end

	local text = arg_122_0:getText() or ""

	if text == "" then
		return arg_122_1
	end

	return healerState[130](text, arg_122_1)
end

  healerState[144] = function(arg_123_0, textValue)
	if not arg_123_0 then
		return
	end

	textValue = tostring(healerState[130](textValue, healerState[125]))

	if arg_123_0.setCurrentOption then
		arg_123_0:setCurrentOption(textValue)
	elseif arg_123_0.setText then
		arg_123_0:setText(textValue)
	end
end

function HelperHealer.onThresholdChange(edit)
	if not edit then
		return
	end

	local text = edit:getText() or ""
	local var_124_1 = healerState[141](text)

	if var_124_1 == "" then
		if text ~= "" then
			edit:setText("")
		end

		healerState.saveConfigIfReady()

		return
	end

	local numericValue = tonumber(var_124_1)

	if numericValue == 0 then
		edit:setText(tostring(healerState[27]))
		healerState.saveConfigIfReady()

		return
	end

	if numericValue > healerState[28] then
		edit:setText(tostring(healerState[28]))
		healerState.saveConfigIfReady()

		return
	end

	if var_124_1 ~= text then
		edit:setText(var_124_1)

		return
	end

	healerState.saveConfigIfReady()
end

function HelperHealer.onThresholdFocusChange(edit, focused)
	if focused or not edit then
		return
	end

	local text = edit:getText() or ""

	if text == "" then
		edit:setText(tostring(healerState[29]))
		healerState.saveConfigIfReady()

		return
	end

	local var_125_1 = healerState[140](text)

	if tostring(var_125_1) ~= text then
		edit:setText(tostring(var_125_1))
		healerState.saveConfigIfReady()
	end
end

  healerState[145] = function(slot)
	if not slot then
		return nil
	end

	return {
		words = slot.words,
		itemId = slot.itemId,
		subType = slot.subType,
		useType = slot.useType,
		parameter = slot.parameter
	}
end

  healerState[146] = function(arg_127_0)
	if not arg_127_0 then
		return false
	end

	if healerState.normalizeEntryWords(arg_127_0.words) then
		return true
	end

	local numericValue = tonumber(arg_127_0.itemId)

	return numericValue and numericValue > 0 and arg_127_0.useType ~= nil and arg_127_0.useType ~= ""
end

  healerState[147] = function(arg_128_0)
	return healerState[146](healerState[145](arg_128_0))
end

  healerState[148] = function(arg_129_0, arg_129_1)
	if not healerState[146](arg_129_0) then
		return false
	end

	local var_129_0 = healerState.normalizeEntryWords(arg_129_0.words)

	if var_129_0 then
		if healerState[114](var_129_0) then
			return false
		end

		local localPlayer = arg_129_1 and arg_129_1.player or g_game.getLocalPlayer()

		return healerState[113](var_129_0, localPlayer)
	end

	local localPlayer = arg_129_1 and arg_129_1.player or g_game.getLocalPlayer()

	if not localPlayer then
		return false
	end

	if healerState.isBlockedHealingPotionId(arg_129_0.itemId) or healerState.isHealingFoodEntry(arg_129_0) then
		return false
	end

	local numericValue = tonumber(arg_129_0.itemId)

	if not healerState.POTION_TYPE_BY_ID[numericValue] or localPlayer:getLevel() < healerState[63](numericValue) or HelperHealer.potionAllowedForVocation(numericValue) == false then
		return false
	end

	if not healerState[116](localPlayer, numericValue, arg_129_0) then
		return false
	end

	return not healerState[115]()
end

  healerState[149] = function(arg_130_0, arg_130_1)
	return healerState[148](healerState[145](arg_130_0), arg_130_1)
end

  healerState[150] = function()
	if not g_game.isOnline() or g_game.isDead and g_game.isDead() then
		return false
	end

	if g_game.getProtocolGame then
		local protocolGame = g_game.getProtocolGame()

		if not protocolGame or not protocolGame:isConnected() then
			return false
		end
	end

	return true
end

  healerState[151] = function(arg_132_0)
	if not arg_132_0 or not arg_132_0.words or arg_132_0.words == "" then
		return false
	end

	if not healerState[150]() or healerState[114](arg_132_0.words) then
		return false
	end

	local words = arg_132_0.words

	if arg_132_0.parameter and arg_132_0.parameter ~= "" then
		words = string.format("%s \"%s\"", arg_132_0.words, arg_132_0.parameter)
	end

	local spellByWords = Spells.getSpellByWords(arg_132_0.words)

	if not spellByWords then
		return false
	end

	healerState[101](spellByWords, g_clock.millis() + healerState[100]())

	local var_132_2, var_132_3 = pcall(g_game.talk, words)

	if not var_132_2 or var_132_3 == false then
		healerState[101](spellByWords, nil)

		return false
	end

	return true
end

  healerState[152] = function(arg_133_0, arg_133_1)
	local localPlayer = arg_133_1 and arg_133_1.player or g_game.getLocalPlayer()
	local numericValue = tonumber(arg_133_0 and arg_133_0.itemId)

	if not localPlayer or not numericValue or numericValue <= 0 or healerState.isBlockedHealingPotionId(numericValue) then
		return false
	end

	if not healerState[150]() or not healerState[148](arg_133_0, arg_133_1) then
		return false
	end

	healerState.multiUseExDelay.potionUntil = g_clock.millis() + math.max(healerState[39], healerState[100]())

	local var_133_2, var_133_3 = pcall(g_game.useInventoryItemWith, numericValue, localPlayer)

	if not var_133_2 or var_133_3 == false then
		healerState.multiUseExDelay.potionUntil = 0

		return false
	end

	healerState.multiUseExDelay.lastHealthPotionWasPlain = healerState[111](numericValue) and not healerState[112](numericValue)

	return true
end

  healerState[153] = function(arg_134_0)
	for unusedValue, ptc_root_local in ipairs(healerState.healingEntries) do
		if ptc_root_local.id == arg_134_0 then
			return ptc_root_local
		end
	end

	return nil
end

  healerState[154] = function(arg_135_0)
	for index, ptc_root_local in ipairs(healerState.healingEntries) do
		if ptc_root_local.id == arg_135_0 then
			return index, ptc_root_local
		end
	end

	return nil
end

  healerState[155] = function(arg_136_0)
	healerState.resetHealingRowFocusColors()

	local var_136_0 = healerState[51](arg_136_0)

	if not var_136_0 then
		return
	end

	healerState[52](var_136_0)
	healerState.syncHealingActionButtons()
end

  healerState[156] = function(arg_137_0)
	local var_137_0 = healerState[154](arg_137_0)

	if not var_137_0 then
		return false
	end

	table.remove(healerState.healingEntries, var_137_0)

	return true
end

  healerState[157] = function(arg_138_0, arg_138_1, arg_138_2, arg_138_3)
	local var_138_0, var_138_1 = healerState[154](arg_138_0)

	if not var_138_1 then
		return false
	end

	local var_138_2 = healerState[134](var_138_1)

	if arg_138_3 and var_138_2 ~= arg_138_3 then
		return false
	end

	local var_138_3

	if arg_138_1 then
		if arg_138_0 == arg_138_1 then
			return false
		end

		local unusedValue
		local var_138_5

		var_138_3, var_138_5 = healerState[154](arg_138_1)

		if not var_138_5 or healerState[134](var_138_5) ~= var_138_2 then
			return false
		end
	end

	table.remove(healerState.healingEntries, var_138_0)

	if var_138_3 then
		if var_138_0 < var_138_3 then
			var_138_3 = var_138_3 - 1
		end

		table.insert(healerState.healingEntries, var_138_3 + (arg_138_2 and 1 or 0), var_138_1)

		return true
	end

	for iter_138_0 = #healerState.healingEntries, 1, -1 do
		if healerState[134](healerState.healingEntries[iter_138_0]) == var_138_2 then
			table.insert(healerState.healingEntries, iter_138_0 + 1, var_138_1)

			return true
		end
	end

	table.insert(healerState.healingEntries, var_138_1)

	return true
end

  healerState[158] = function()
	if healerState.ctx and healerState.ctx.saveConfig then
		healerState.saveConfigIfReady()
	end
end

  healerState[159] = function()
	if healerState[9] then
		removeEvent(healerState[9])

		healerState[9] = nil
	end
end

  healerState[160] = function()
	local var_141_0 = healerState[9] ~= nil

	healerState[159]()

	if var_141_0 then
		healerState[158]()
	end
end

  healerState[161] = function()
	healerState[159]()

	healerState[9] = scheduleEvent(function()
		healerState[9] = nil

		healerState[158]()
	end, 250)
end

  healerState[162] = function(arg_144_0)
	local var_144_0 = healerState[137](arg_144_0)
	local var_144_1 = healerState[136](arg_144_0)
	local var_144_2 = {
		conditionLogic = "and",
		conditionMax = "<=",
		conditionMin = ">=",
		id = arg_144_0.id,
		kind = healerState[134](arg_144_0),
		enabled = arg_144_0.enabled ~= false,
		percent = var_144_0,
		spiritMetric = healerState[112](arg_144_0.itemId) and var_144_1 or nil,
		whenMetric1 = var_144_1,
		whenMetric2 = var_144_1,
		thresholdMin = healerState[122],
		thresholdMax = var_144_0,
		words = healerState.normalizeEntryWords(arg_144_0.words)
	}

	if healerState.isBlockedHealingPotionId(arg_144_0.itemId) then
		-- block empty
	end

	var_144_2.itemId = arg_144_0.itemId
	var_144_2.subType = arg_144_0.subType

	if healerState.isHealingFoodEntry(arg_144_0) then
		-- block empty
	end

	var_144_2.useType = arg_144_0.useType
	var_144_2.parameter = arg_144_0.parameter

	return var_144_2
end

function HelperHealer.copyLegacyHealingSlot(savedEntry)
	if not savedEntry then
		return nil
	end

	local var_145_0 = savedEntry.whenMetric1 or savedEntry.whenMetric2 or savedEntry.metric or "HP"
	local var_145_1 = savedEntry.percent or savedEntry.thresholdMax or savedEntry.threshold or healerState[125]

	return {
		condition = "<=",
		enabled = savedEntry.enabled ~= false,
		metric = var_145_0,
		whenMetric1 = savedEntry.whenMetric1 or var_145_0,
		whenMetric2 = savedEntry.whenMetric2 or var_145_0,
		conditionLogic = savedEntry.conditionLogic or "and",
		conditionMin = savedEntry.conditionMin or ">=",
		thresholdMin = savedEntry.thresholdMin or healerState[122],
		conditionMax = savedEntry.conditionMax or "<=",
		thresholdMax = savedEntry.thresholdMax or var_145_1,
		threshold = var_145_1,
		words = savedEntry.words,
		itemId = savedEntry.itemId,
		subType = savedEntry.subType,
		useType = savedEntry.useType,
		parameter = savedEntry.parameter,
		spiritMetric = savedEntry.spiritMetric
	}
end

  healerState[163] = function(arg_146_0, arg_146_1)
	if type(arg_146_0) ~= "table" then
		return nil
	end

	if healerState.isHealingFoodEntry(arg_146_0) then
		return nil
	end

	if not healerState[146](arg_146_0) then
		return nil
	end

	local var_146_0 = healerState[132](arg_146_0)
	local var_146_1 = arg_146_0.kind == "potion" and "potion" or healerState.normalizeEntryWords(arg_146_0.words) and "spell" or "potion"
	local numericValue = tonumber(arg_146_0.itemId)

	if healerState.isBlockedHealingPotionId(numericValue) then
		-- block empty
	end

	local var_146_3 = numericValue
	local var_146_4 = {
		id = tonumber(arg_146_0.id) or arg_146_1,
		kind = var_146_1,
		enabled = arg_146_0.enabled ~= false,
		whenMetric1 = var_146_0.whenMetric1,
		whenMetric2 = var_146_0.whenMetric2,
		conditionLogic = var_146_0.conditionLogic,
		conditionMin = var_146_0.conditionMin,
		thresholdMin = var_146_0.thresholdMin,
		conditionMax = var_146_0.conditionMax,
		thresholdMax = var_146_0.thresholdMax,
		percent = healerState[130](arg_146_0.percent or var_146_0.thresholdMax, var_146_1 == "potion" and healerState[127] or healerState[126]),
		words = healerState.normalizeEntryWords(arg_146_0.words),
		itemId = var_146_3,
		subType = arg_146_0.subType,
		useType = arg_146_0.useType,
		parameter = arg_146_0.parameter
	}

	if healerState[112](var_146_4.itemId) then
		var_146_4.spiritMetric = HelperHealer.resolveLoadedSpiritMetric(arg_146_0)
	end

	healerState[138](var_146_4, var_146_4.percent)

	return var_146_4
end

  healerState[164] = function(arg_147_0)
	local var_147_0 = healerState.normalizeEntryWords(arg_147_0.words)

	if var_147_0 then
		return var_147_0
	end

	if arg_147_0.itemId and arg_147_0.itemId > 0 then
		local thingType = g_things.getThingType(arg_147_0.itemId, ThingCategoryItem)

		if thingType then
			return healerState[80](thingType, arg_147_0.itemId)
		end

		return tostring(arg_147_0.itemId)
	end

	return ""
end

  healerState[165] = function(entry)
	if not entry then
		return
	end

	entry.words = nil
	entry.itemId = nil
	entry.spiritMetric = nil
	entry.subType = nil
	entry.useType = nil
	entry.parameter = nil
end

  healerState[166] = function(arg_149_0, arg_149_1)
	if not arg_149_0 or not arg_149_1 then
		return
	end

	local var_149_0 = healerState[145](arg_149_1)
	local spiritMetric = arg_149_0.spiritMetric

	healerState[165](arg_149_0)

	local words = healerState.normalizeEntryWords(var_149_0.words)

	if words then
		arg_149_0.kind = "spell"
		arg_149_0.words = words
		arg_149_0.itemId = var_149_0.itemId or healerState.ACTION_SLOT_SPELL_ITEM_ID
		arg_149_0.parameter = var_149_0.parameter
	else
		local numericValue = tonumber(var_149_0.itemId)

		if not numericValue or numericValue <= 0 then
			return
		end

		arg_149_0.kind = "potion"
		arg_149_0.itemId = numericValue
		arg_149_0.subType = var_149_0.subType
		arg_149_0.useType = var_149_0.useType or "useOnSelf"

		if healerState[112](numericValue) then
			arg_149_0.spiritMetric = healerState[119](spiritMetric or "HP")
		end
	end

	healerState[138](arg_149_0, healerState[137](arg_149_0))
end

  healerState[167] = function(entry)
	return string.format("%s%%", HelperHealer.getHealingEntryMetricText(entry))
end

  healerState[168] = function(arg_151_0, arg_151_1)
	local healingConditionPercentStepper = arg_151_0 and arg_151_0:recursiveGetChildById("healingConditionPercentStepper") or nil

	if not healingConditionPercentStepper then
		return
	end

	healingConditionPercentStepper:show()

	local var_151_1 = healerState[137](arg_151_1)
	local numberValue = healingConditionPercentStepper:recursiveGetChildById("numberValue")

	if numberValue then
		numberValue:setText(tostring(var_151_1))
	end

	local btnDec = healingConditionPercentStepper:recursiveGetChildById("btnDec")

	if btnDec then
		btnDec:setEnabled(var_151_1 > healerState[122])
	end

	local btnInc = healingConditionPercentStepper:recursiveGetChildById("btnInc")

	if btnInc then
		btnInc:setEnabled(var_151_1 < healerState[123])
	end
end

function HelperHealer.updateHealingConditionMetricLabel(row, entry)
	local healingConditionMetricLabel = row and row:recursiveGetChildById("healingConditionMetricLabel") or nil

	if not healingConditionMetricLabel then
		return
	end

	healingConditionMetricLabel:setText(healerState[167](entry))
	healingConditionMetricLabel:setTooltip("")
end

function HelperHealer.healingMetricDropdownText(metric)
	return healerState[119](metric) == "MP" and "MP%" or "HP%"
end

function HelperHealer.setHealingMetricDropdownOption(dropdown, metric)
	if not dropdown or dropdown:isDestroyed() then
		return
	end

	local text = HelperHealer.healingMetricDropdownText(metric)

	dropdown.currentMetric = healerState[119](metric)

	dropdown:setTooltip(text)

	local metricText = dropdown:recursiveGetChildById("metricText")

	if metricText then
		metricText:setText(text)
	end
end

function HelperHealer.openHealingMetricDropdown(row, dropdown)
	if not row or not dropdown or dropdown:isDestroyed() then
		return true
	end

	local healingEntryId = row.healingEntryId
	local var_155_1 = healerState[153](healingEntryId)

	if not var_155_1 or not healerState[112](var_155_1.itemId) then
		return true
	end

	healerState[52](row)

	local function applyMetric(metric)
		local var_156_0 = healerState[153](healingEntryId)

		if not var_156_0 or not healerState[112](var_156_0.itemId) then
			return
		end

		var_156_0.spiritMetric = healerState[119](metric)

		healerState[138](var_156_0, healerState[137](var_156_0))
		HelperHealer.setHealingMetricDropdownOption(dropdown, var_156_0.spiritMetric)
		healerState[158]()
	end

	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:addOption("HP%", function()
		applyMetric("HP")
	end, nil, false, {
		minWidth = 44
	})
	gamePopupMenuWidget:addOption("MP%", function()
		applyMetric("MP")
	end, nil, false, {
		minWidth = 44
	})
	gamePopupMenuWidget:setWidth(44)
	gamePopupMenuWidget:display({
		x = dropdown:getX(),
		y = dropdown:getY() + dropdown:getHeight()
	})

	return true
end

function HelperHealer.updateHealingConditionMetricSelector(row, entry)
	if not row or not entry then
		return
	end

	local healingConditionMetricLabel = row:recursiveGetChildById("healingConditionMetricLabel")
	local healingConditionMetricCombo = row:recursiveGetChildById("healingConditionMetricCombo")

	if healerState[112](entry.itemId) then
		if healingConditionMetricLabel then
			healingConditionMetricLabel:hide()
		end

		if healingConditionMetricCombo then
			healingConditionMetricCombo:show()
			HelperHealer.setHealingMetricDropdownOption(healingConditionMetricCombo, healerState[136](entry))
		end
	else
		if healingConditionMetricCombo then
			healingConditionMetricCombo:hide()
		end

		if healingConditionMetricLabel then
			healingConditionMetricLabel:show()
		end

		HelperHealer.updateHealingConditionMetricLabel(row, entry)
	end
end

function HelperHealer.elideHealingLabel(label, text)
	if not label or label:isDestroyed() then
		return
	end

	text = text or ""

	label:setText(text)

	local width = label:getWidth()

	if not width or width < 40 then
		width = 114
	end

	if width >= label:getTextSize().width then
		return
	end

	local var_160_1 = "..."
	local var_160_2 = 0
	local var_160_3 = #text
	local var_160_4 = var_160_1

	while var_160_2 <= var_160_3 do
		local var_160_5 = math.floor((var_160_2 + var_160_3) / 2)
		local text = text:sub(1, var_160_5) .. var_160_1

		label:setText(text)

		if width >= label:getTextSize().width then
			var_160_4 = text
			var_160_2 = var_160_5 + 1
		else
			var_160_3 = var_160_5 - 1
		end
	end

	label:setText(var_160_4)
end

  healerState[169] = function(arg_161_0, arg_161_1)
	if not arg_161_0 or not arg_161_1 then
		return
	end

	local healingConditionEnabled = arg_161_0:recursiveGetChildById("healingConditionEnabled")

	if healingConditionEnabled then
		local onCheckChange = healingConditionEnabled.onCheckChange

		healingConditionEnabled.onCheckChange = nil

		healingConditionEnabled:setChecked(arg_161_1.enabled ~= false)

		healingConditionEnabled.onCheckChange = onCheckChange
	end

	local healingConditionName = arg_161_0:recursiveGetChildById("healingConditionName")

	if healingConditionName then
		local var_161_3 = healerState[164](arg_161_1)

		if var_161_3 == "" then
			var_161_3 = healerState[134](arg_161_1) == "potion" and tr("Select Potion") or tr("Select Spell")
		end

		healingConditionName:setTooltip(var_161_3)
		HelperHealer.elideHealingLabel(healingConditionName, var_161_3)
	end

	HelperHealer.updateHealingConditionMetricSelector(arg_161_0, arg_161_1)
	healerState[168](arg_161_0, arg_161_1)

	local healingConditionActionSlot = arg_161_0:recursiveGetChildById("healingConditionActionSlot")

	if healingConditionActionSlot then
		if healerState[146](arg_161_1) and healerState[15] then
			healerState[15](healingConditionActionSlot, arg_161_1)
		else
			healerState.clearSlotData(healingConditionActionSlot)
		end

		local gray = healingConditionActionSlot:getChildById("gray")

		if gray then
			gray:setVisible(healerState[68](arg_161_1))
		end

		healerState.syncHealingActionSlotLayers(healingConditionActionSlot)
	end
end

function HelperHealer.destroyHealingEntryDragGhost()
	if HelperHealer.healingEntryDragGhost and not HelperHealer.healingEntryDragGhost:isDestroyed() then
		HelperHealer.healingEntryDragGhost:destroy()
	end

	HelperHealer.healingEntryDragGhost = nil
end

function HelperHealer.updateHealingEntryDragGhostPosition(mousePos)
	if not HelperHealer.healingEntryDragGhost or HelperHealer.healingEntryDragGhost:isDestroyed() or not mousePos then
		return
	end

	local size = HelperHealer.healingEntryDragGhost:getSize()
	local width = size and size.width or 180
	local height = size and size.height or 42

	HelperHealer.healingEntryDragGhost:setPosition({
		x = mousePos.x - math.floor(width / 2),
		y = mousePos.y - math.floor(height / 2)
	})
	HelperHealer.healingEntryDragGhost:raise()
end

function HelperHealer.ensureHealingEntryDragGhost(row)
	if HelperHealer.healingEntryDragGhost and not HelperHealer.healingEntryDragGhost:isDestroyed() then
		return HelperHealer.healingEntryDragGhost
	end

	local root = g_ui.getRootWidget()

	if not root then
		return nil
	end

	HelperHealer.healingEntryDragGhost = g_ui.createWidget("HealingConditionDragGhost", root)

	HelperHealer.healingEntryDragGhost:setId("healingConditionDragGhost")
	HelperHealer.healingEntryDragGhost:setPhantom(true)
	HelperHealer.healingEntryDragGhost:setFocusable(false)
	HelperHealer.healingEntryDragGhost:setDraggable(false)
	HelperHealer.healingEntryDragGhost:setVisible(false)

	if row and row.getWidth then
		HelperHealer.healingEntryDragGhost:setWidth(math.max(160, row:getWidth()))
	end

	return HelperHealer.healingEntryDragGhost
end

function HelperHealer.updateHealingEntryDragGhost(row, entry, mousePos)
	if not entry then
		return
	end

	local var_165_0 = HelperHealer.ensureHealingEntryDragGhost(row)

	if not var_165_0 then
		return
	end

	local dragGhostName = var_165_0:recursiveGetChildById("dragGhostName")

	if dragGhostName then
		dragGhostName:setText(healerState[164](entry))
	end

	local dragGhostCondition = var_165_0:recursiveGetChildById("dragGhostCondition")

	if dragGhostCondition then
		dragGhostCondition:setText(string.format("%s %d", healerState[167](entry), healerState[137](entry)))
	end

	local dragGhostActionSlot = var_165_0:recursiveGetChildById("dragGhostActionSlot")

	if dragGhostActionSlot then
		if healerState[146](entry) and healerState[15] then
			healerState[15](dragGhostActionSlot, entry)
		else
			healerState.clearSlotData(dragGhostActionSlot)
		end

		healerState.syncHealingActionSlotLayers(dragGhostActionSlot)
	end

	var_165_0:setVisible(true)
	HelperHealer.updateHealingEntryDragGhostPosition(mousePos or g_window.getMousePosition())
end

function HelperHealer.setHealingEntryDragSourceVisual(row, dragging)
	if not row or row:isDestroyed() then
		return
	end

	if dragging then
		row:setOpacity(0.45)
		row:setBackgroundColor("#6a6a6a")
		healerState.setHealingRowTextColors(row, healerState.ZEBRA_FOCUS_TEXT_COLOR)

		return
	end

	row:setOpacity(1)

	if row.zebraColor then
		row:setBackgroundColor(row.zebraColor)
		healerState.setHealingRowTextColors(row, healerState.ZEBRA_TEXT_COLOR)
	end
end

  healerState[170] = function(arg_167_0, arg_167_1, arg_167_2, arg_167_3)
	if not arg_167_0 or not arg_167_1 then
		return
	end

	healerState[138](arg_167_1, healerState[137](arg_167_1) + arg_167_2)
	healerState[168](arg_167_0, arg_167_1)

	if arg_167_3 ~= false then
		healerState[158]()
	else
		healerState[161]()
	end
end

  healerState[171] = function(arg_168_0, arg_168_1, arg_168_2, arg_168_3)
	if not arg_168_0 then
		return
	end

	if g_mouse and g_mouse.bindAutoPress then
		g_mouse.bindAutoPress(arg_168_0, function()
			healerState[170](arg_168_1, arg_168_2, arg_168_3, false)
		end, healerState[129])
	else
		function arg_168_0.onClick()
			healerState[170](arg_168_1, arg_168_2, arg_168_3, false)
		end
	end

	function arg_168_0.onMouseRelease(unusedArgument, unusedArgument, arg_171_2)
		if arg_171_2 == MouseLeftButton then
			healerState[160]()

			return false
		end

		return false
	end
end

  healerState[172] = function(arg_172_0)
	healerState[158]()
	addEvent(function()
		healerState[14]()
		healerState[155](arg_172_0)
	end)
end

  healerState[173] = function(arg_174_0, arg_174_1, arg_174_2, arg_174_3)
	if not arg_174_0 or not arg_174_1 or not arg_174_1.healingEntryId or not arg_174_0.healingEntryId then
		return false
	end

	if arg_174_1.healingEntryKind ~= arg_174_0.healingEntryKind then
		return false
	end

	local y = arg_174_3

	if y == nil then
		y = arg_174_2 and arg_174_2.y >= arg_174_0:getY() + arg_174_0:getHeight() / 2
	end

	if healerState[157](arg_174_1.healingEntryId, arg_174_0.healingEntryId, y, arg_174_0.healingEntryKind) then
		healerState[172](arg_174_1.healingEntryId)

		return true
	end

	return false
end

  healerState[174] = function(arg_175_0, arg_175_1)
	if not arg_175_0 or not arg_175_1 or not arg_175_1.healingEntryId then
		return false
	end

	if arg_175_1.healingEntryKind ~= arg_175_0.healingEntryKind then
		return false
	end

	if healerState[157](arg_175_1.healingEntryId, nil, false, arg_175_0.healingEntryKind) then
		healerState[172](arg_175_1.healingEntryId)

		return true
	end

	return false
end

function HelperHealer.isMouseInsideHealingDropPanel(panel, mousePos)
	if not panel or panel:isDestroyed() or not mousePos then
		return false
	end

	if panel.containsPaddingPoint then
		return panel:containsPaddingPoint(mousePos)
	end

	return mousePos.x >= panel:getX() and mousePos.x <= panel:getX() + panel:getWidth() and mousePos.y >= panel:getY() and mousePos.y <= panel:getY() + panel:getHeight()
end

function HelperHealer.getHealingDropPanel(draggedWidget, mousePos)
	if not draggedWidget or not draggedWidget.healingEntryKind then
		return nil
	end

	local var_177_0 = healerState[51](draggedWidget.healingEntryId) or draggedWidget
	local parent = var_177_0 and var_177_0:getParent() or nil

	if parent and parent.healingEntryKind == draggedWidget.healingEntryKind and HelperHealer.isMouseInsideHealingDropPanel(parent, mousePos) then
		return parent
	end

	local var_177_2 = draggedWidget.healingEntryKind == "potion" and healerState.healingPotionEntriesPanel or healerState.healingSpellEntriesPanel

	if var_177_2 and var_177_2.healingEntryKind == draggedWidget.healingEntryKind and HelperHealer.isMouseInsideHealingDropPanel(var_177_2, mousePos) then
		return var_177_2
	end

	if healerState.healingEntriesPanel and HelperHealer.isMouseInsideHealingDropPanel(healerState.healingEntriesPanel, mousePos) then
		return healerState.healingEntriesPanel
	end

	return nil
end

function HelperHealer.resolveHealingDropTarget(draggedWidget, mousePos)
	local panel = HelperHealer.getHealingDropPanel(draggedWidget, mousePos)

	if not panel then
		return nil, nil, nil
	end

	local lastRow

	for _, row in ipairs(panel:getChildren()) do
		if row:isVisible() and row.healingEntryKind == draggedWidget.healingEntryKind then
			lastRow = row

			if mousePos.y < row:getY() + row:getHeight() / 2 then
				return panel, row, false
			end
		end
	end

	if lastRow then
		return panel, lastRow, true
	end

	return panel, nil, false
end

function HelperHealer.dropHealingEntryAtMouse(fallbackRow, draggedWidget, mousePos)
	if not draggedWidget or not draggedWidget.healingEntryId then
		return false
	end

	local var_179_0, var_179_1, var_179_2 = HelperHealer.resolveHealingDropTarget(draggedWidget, mousePos)

	if var_179_1 then
		return healerState[173](var_179_1, draggedWidget, mousePos, var_179_2)
	end

	if var_179_0 then
		return healerState[174](var_179_0, draggedWidget)
	end

	if fallbackRow then
		return healerState[173](fallbackRow, draggedWidget, mousePos)
	end

	return false
end

function HelperHealer.bindHealingRowDropForwarder(widget, row)
	if not widget then
		return
	end

	local previousOnDrop = widget.onDrop

	function widget.onDrop(self, draggedWidget, mousePos)
		if draggedWidget and draggedWidget.healingEntryId then
			return HelperHealer.dropHealingEntryAtMouse(row, draggedWidget, mousePos)
		end

		if previousOnDrop then
			return previousOnDrop(self, draggedWidget, mousePos)
		end

		return false
	end
end

function HelperHealer.queueHealingRowContextMenu(row)
	if not row or row:isDestroyed() then
		return true
	end

	if row._healingContextMenuQueued then
		return true
	end

	row._healingContextMenuQueued = true

	scheduleEvent(function()
		if row and not row:isDestroyed() then
			row._healingContextMenuQueued = nil

			healerState[11](row)
		end
	end, 60)

	return true
end

function HelperHealer.bindHealingRowContextForwarder(widget, row)
	if not widget then
		return
	end

	local previousOnMousePress = widget.onMousePress

	function widget.onMousePress(self, mousePos, mouseButton)
		if mouseButton == MouseRightButton and row and not row:isDestroyed() then
			return HelperHealer.queueHealingRowContextMenu(row)
		end

		if previousOnMousePress then
			return previousOnMousePress(self, mousePos, mouseButton)
		end

		return false
	end

	local previousOnMouseRelease = widget.onMouseRelease

	function widget.onMouseRelease(self, mousePos, mouseButton)
		if mouseButton == MouseRightButton and row and not row:isDestroyed() then
			return HelperHealer.queueHealingRowContextMenu(row)
		end

		if previousOnMouseRelease then
			return previousOnMouseRelease(self, mousePos, mouseButton)
		end

		return false
	end
end

function HelperHealer.bindHealingSlotChildContextForwarders(slot, row)
	if not slot then
		return
	end

	local function bindChild(child)
		if child and child ~= slot then
			HelperHealer.bindHealingRowContextForwarder(child, row)
		end
	end

	if slot.getChildren then
		for _, child in ipairs(slot:getChildren()) do
			bindChild(child)

			if child.getChildren then
				for _, nestedChild in ipairs(child:getChildren()) do
					bindChild(nestedChild)
				end
			end
		end

		return
	end

	for _, childId in ipairs({
		"count",
		"tier",
		"spellIcon",
		"gray",
		"key",
		"text",
		"spellParameter",
		"multiIcon",
		"equipmentTypeIcon",
		"activeSpell",
		"healingActionItemBackground",
		"healingActionItemIcon"
	}) do
		bindChild(slot:getChildById(childId))
	end
end

  healerState[175] = function(panel, group)
	if not panel then
		return
	end

	panel.healingEntryKind = group

	function panel.onDrop(_, draggedWidget, mousePos)
		return HelperHealer.dropHealingEntryAtMouse(nil, draggedWidget, mousePos)
	end
end

  healerState[176] = function(arg_191_0, arg_191_1)
	if not arg_191_0 or not arg_191_1 then
		return
	end

	arg_191_0._helperHealingSlot = true
	arg_191_0._helperAssignPreview = true
	arg_191_0._helperAssignSkipSave = true
	arg_191_0.healingEntryId = arg_191_1.id
	arg_191_0.healingEntryKind = healerState[134](arg_191_1)

	function arg_191_0.onHelperPotionAssigned(arg_192_0)
		local var_192_0 = healerState[153](arg_192_0.healingEntryId)

		if not var_192_0 then
			return
		end

		var_192_0.kind = "potion"
		var_192_0.pendingAdd = nil

		healerState[166](var_192_0, arg_192_0)
		healerState[14]()
		healerState[155](var_192_0.id)
		healerState[158]()
	end

	function arg_191_0.onMousePress(arg_193_0, unusedArgument, arg_193_2)
		if arg_193_2 == MouseRightButton then
			local var_193_0 = healerState[54](arg_193_0)

			if var_193_0 then
				return HelperHealer.queueHealingRowContextMenu(var_193_0)
			end
		end

		if arg_193_2 == MouseLeftButton then
			return true
		end

		return false
	end

	function arg_191_0.onMouseRelease(arg_194_0, unusedArgument, arg_194_2)
		if arg_194_2 == MouseLeftButton then
			healerState[12](arg_194_0)

			return true
		end

		if arg_194_2 == MouseRightButton then
			local var_194_0 = healerState[54](arg_194_0)

			if var_194_0 then
				return HelperHealer.queueHealingRowContextMenu(var_194_0)
			end
		end

		return false
	end

	if not healerState[69](arg_191_0) then
		local var_191_0 = healerState.actionbar()

		if var_191_0 and var_191_0.refreshActionSlotFrameClip then
			var_191_0.refreshActionSlotFrameClip(arg_191_0)
		end
	end

	healerState.syncHealingActionSlotLayers(arg_191_0)
end

  healerState[177] = function(row, arg_195_1)
	if not row or not arg_195_1 then
		return
	end

	row.healingEntryId = arg_195_1.id
	row.healingEntryKind = healerState[134](arg_195_1)

	if row.setDraggable then
		row:setDraggable(true)
	end

	local healingConditionEnabled = row:recursiveGetChildById("healingConditionEnabled")

	if healingConditionEnabled then
		function healingConditionEnabled.onCheckChange(unusedArgument, enabled)
			arg_195_1.enabled = enabled

			healerState[158]()
		end

		HelperHealer.bindHealingRowDropForwarder(healingConditionEnabled, row)
		HelperHealer.bindHealingRowContextForwarder(healingConditionEnabled, row)
	end

	local healingConditionActionSlot = row:recursiveGetChildById("healingConditionActionSlot")

	healerState[176](healingConditionActionSlot, arg_195_1)
	HelperHealer.bindHealingRowDropForwarder(healingConditionActionSlot, row)
	HelperHealer.bindHealingRowContextForwarder(healingConditionActionSlot, row)
	HelperHealer.bindHealingSlotChildContextForwarders(healingConditionActionSlot, row)

	local healingConditionPercentStepper = row:recursiveGetChildById("healingConditionPercentStepper")

	if healingConditionPercentStepper then
		HelperHealer.bindHealingRowDropForwarder(healingConditionPercentStepper, row)
		HelperHealer.bindHealingRowContextForwarder(healingConditionPercentStepper, row)

		local btnDec = healingConditionPercentStepper:recursiveGetChildById("btnDec")

		healerState[171](btnDec, row, arg_195_1, -healerState[128])
		HelperHealer.bindHealingRowDropForwarder(btnDec, row)

		local numberBox = healingConditionPercentStepper:recursiveGetChildById("numberBox")

		HelperHealer.bindHealingRowDropForwarder(numberBox, row)

		local btnInc = healingConditionPercentStepper:recursiveGetChildById("btnInc")

		healerState[171](btnInc, row, arg_195_1, healerState[128])
		HelperHealer.bindHealingRowDropForwarder(btnInc, row)
	end

	local healingConditionMetricCombo = row:recursiveGetChildById("healingConditionMetricCombo")

	if healingConditionMetricCombo then
		function healingConditionMetricCombo.onMousePress(self, _, mouseButton)
			if mouseButton == MouseLeftButton then
				return HelperHealer.openHealingMetricDropdown(row, self)
			end

			if mouseButton == MouseRightButton then
				return HelperHealer.queueHealingRowContextMenu(row)
			end

			return false
		end

		HelperHealer.bindHealingRowDropForwarder(healingConditionMetricCombo, row)
	end

	local healingConditionRemoveButton = row:recursiveGetChildById("healingConditionRemoveButton")

	if healingConditionRemoveButton then
		HelperHealer.bindHealingRowDropForwarder(healingConditionRemoveButton, row)
		HelperHealer.bindHealingRowContextForwarder(healingConditionRemoveButton, row)

		function healingConditionRemoveButton.onClick()
			if healerState[156](arg_195_1.id) then
				healerState[14]()
				healerState[57]()
				healerState[158]()
			end
		end
	end

	healerState[56](row)

	function row.onMousePress(self, _, mouseButton)
		if mouseButton == MouseRightButton then
			return HelperHealer.queueHealingRowContextMenu(self)
		end

		return false
	end

	function row.onDragEnter(self, mousePos)
		HelperHealer.updateHealingEntryDragGhost(self, healerState[153](self.healingEntryId) or arg_195_1, mousePos)
		HelperHealer.setHealingEntryDragSourceVisual(self, true)

		return true
	end

	function row.onDragMove(_, mousePos)
		HelperHealer.updateHealingEntryDragGhostPosition(mousePos)

		return true
	end

	function row.onDragLeave(self)
		HelperHealer.destroyHealingEntryDragGhost()

		if self:isDestroyed() then
			return true
		end

		HelperHealer.setHealingEntryDragSourceVisual(self, false)

		return true
	end

	function row.onDrop(self, draggedWidget, mousePos)
		return HelperHealer.dropHealingEntryAtMouse(self, draggedWidget, mousePos)
	end

	function row.onMouseRelease(self, _, mouseButton)
		if mouseButton == MouseRightButton then
			return HelperHealer.queueHealingRowContextMenu(self)
		end

		return false
	end
end

 healerState[12] = function(arg_205_0)
	if not arg_205_0 then
		return
	end

	local var_205_0 = healerState[153](arg_205_0.healingEntryId)

	if not var_205_0 then
		return
	end

	if healerState[134](var_205_0) == "potion" then
		HelperHealer.openPotionSelectWindow(arg_205_0)

		return
	end

	healerState[79](arg_205_0, healerState[78], function(arg_206_0)
		local var_206_0 = healerState[153](arg_205_0.healingEntryId)

		if not var_206_0 then
			return
		end

		var_206_0.kind = "spell"
		var_206_0.pendingAdd = nil

		healerState[166](var_206_0, arg_206_0 or arg_205_0)
		healerState[14]()
		healerState[155](var_206_0.id)
		healerState[158]()
	end)
end

 healerState[14] = function()
	healerState[23]()
	healerState.resolveHealingEntryPanels()

	if not healerState.healingSpellEntriesPanel and not healerState.healingPotionEntriesPanel and not healerState.healingEntriesPanel then
		return
	end

	healerState[175](healerState.healingSpellEntriesPanel, "spell")
	healerState[175](healerState.healingPotionEntriesPanel, "potion")

	if healerState.healingSpellEntriesPanel and not healerState.healingSpellEntriesPanel:isDestroyed() then
		healerState.healingSpellEntriesPanel:destroyChildren()
	end

	if healerState.healingPotionEntriesPanel and not healerState.healingPotionEntriesPanel:isDestroyed() then
		healerState.healingPotionEntriesPanel:destroyChildren()
	end

	if healerState.healingEntriesPanel and not healerState.healingEntriesPanel:isDestroyed() then
		healerState.healingEntriesPanel:destroyChildren()
	end

	for index, ptc_root_local in ipairs(healerState.healingEntries) do
		local parentWidget = healerState[134](ptc_root_local) == "potion" and healerState.healingPotionEntriesPanel or healerState.healingSpellEntriesPanel

		parentWidget = parentWidget or healerState.healingEntriesPanel

		if not parentWidget or parentWidget:isDestroyed() then
			return
		end

		local healingConditionRowWidget = g_ui.createWidget("HealingConditionRow", parentWidget)
		local zebraColor = index % 2 == 1 and healerState.ZEBRA_COLOR_A or healerState.ZEBRA_COLOR_B

		healingConditionRowWidget.zebraColor = zebraColor

		healingConditionRowWidget:setBackgroundColor(zebraColor)
		healerState[177](healingConditionRowWidget, ptc_root_local)
		healerState[169](healingConditionRowWidget, ptc_root_local)
	end

	healerState.syncHealingActionButtons()
end

  healerState[178] = function(arg_208_0)
	arg_208_0 = arg_208_0 or {}
	healerState.healingEntries = {}
	healerState[5] = 1

	if type(arg_208_0.healingEntries) == "table" then
		for index, healingEntry in ipairs(arg_208_0.healingEntries) do
			local var_208_0 = healerState[163](healingEntry, index)

			if var_208_0 then
				table.insert(healerState.healingEntries, var_208_0)

				if var_208_0.id >= healerState[5] then
					healerState[5] = var_208_0.id + 1
				end
			end
		end
	end

	if #healerState.healingEntries == 0 then
		local healingSlots = arg_208_0.healingSlots

		if type(healingSlots) == "table" then
			for index, entry in ipairs(healingSlots) do
				local var_208_2 = healerState[163]({
					id = index,
					enabled = entry.enabled ~= false,
					whenMetric1 = entry.metric or entry.whenMetric1,
					whenMetric2 = entry.whenMetric2 or entry.metric,
					conditionLogic = entry.conditionLogic,
					conditionMin = entry.conditionMin,
					thresholdMin = entry.thresholdMin,
					conditionMax = entry.conditionMax,
					thresholdMax = entry.thresholdMax,
					metric = entry.metric,
					condition = entry.condition,
					threshold = entry.threshold,
					words = entry.words,
					itemId = entry.itemId,
					subType = entry.subType,
					useType = entry.useType,
					parameter = entry.parameter,
					spiritMetric = entry.spiritMetric,
					spiritMode = entry.spiritMode,
					spiritConfig = entry.spiritConfig
				}, index)

				if var_208_2 then
					table.insert(healerState.healingEntries, var_208_2)

					if var_208_2.id >= healerState[5] then
						healerState[5] = var_208_2.id + 1
					end
				end
			end
		end
	end

	for iter_208_4 = #healerState.healingEntries, 1, -1 do
		local var_208_3 = healerState.healingEntries[iter_208_4]

		if healerState.isBlockedHealingPotionId(var_208_3.itemId) or healerState.isHealingFoodEntry(var_208_3) then
			var_208_3.itemId = nil
			var_208_3.useType = nil

			if not healerState[146](var_208_3) then
				table.remove(healerState.healingEntries, iter_208_4)
			end
		end
	end
end

  healerState[179] = function(arg_209_0, arg_209_1)
	if not healerState[148](arg_209_0, arg_209_1) then
		return false
	end

	local words = healerState.normalizeEntryWords(arg_209_0.words)

	if words then
		arg_209_0.words = words

		return healerState[151](arg_209_0)
	end

	local numericValue = tonumber(arg_209_0.itemId)

	if numericValue and numericValue > 0 then
		return healerState[152](arg_209_0, arg_209_1)
	end

	return false
end

  healerState[180] = function(arg_210_0, arg_210_1)
	return healerState[179](healerState[145](arg_210_0), arg_210_1)
end

 healerState[11] = function(arg_211_0)
	if not arg_211_0 or not arg_211_0.healingEntryId then
		return
	end

	local healingEntryId = arg_211_0.healingEntryId
	local unusedValue, var_211_2 = healerState[154](healingEntryId)

	if not var_211_2 then
		return
	end

	healerState[52](arg_211_0)
	healerState.syncHealingActionButtons()

	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setWidth(150)
	gamePopupMenuWidget:addOption(healerState[134](var_211_2) == "potion" and tr("Assign Potion") or tr("Assign Spell"), function()
		addEvent(function()
			local var_213_0 = healerState[51](healingEntryId)
			local healingConditionActionSlot = var_213_0 and var_213_0:recursiveGetChildById("healingConditionActionSlot") or nil

			if healingConditionActionSlot and not healingConditionActionSlot:isDestroyed() then
				healerState[12](healingConditionActionSlot)
			end
		end)
	end)
	gamePopupMenuWidget:addOption(tr("Remove"), function()
		if healerState[156](healingEntryId) then
			healerState[14]()
			healerState[57]()
			healerState[158]()
		end
	end)

	if var_211_2.enabled ~= false then
		gamePopupMenuWidget:addOption(tr("Disable"), function()
			var_211_2.enabled = false

			healerState[14]()
			healerState[155](healingEntryId)
			healerState[158]()
		end)
	else
		gamePopupMenuWidget:addOption(tr("Enable"), function()
			var_211_2.enabled = true

			healerState[14]()
			healerState[155](healingEntryId)
			healerState[158]()
		end)
	end

	gamePopupMenuWidget:display()
end

  healerState[181] = function(slot)
	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setWidth(220)

	local var_217_1 = healerState.addHealingSlot and slot == healerState.addHealingSlot

	gamePopupMenuWidget:addOption("Assign Spell", function()
		addEvent(function()
			if slot and not slot:isDestroyed() then
				healerState[79](slot, healerState[78], var_217_1 and healerState.syncAddHealingConfirmButtons or nil)
			end
		end)
	end)
	gamePopupMenuWidget:addOption("Assign Potion", function()
		addEvent(function()
			if slot and not slot:isDestroyed() then
				HelperHealer.openPotionSelectWindow(slot)
			end
		end)
	end)
	gamePopupMenuWidget:addSeparator()
	gamePopupMenuWidget:addOption("Clear Action", function()
		healerState.clearSlotData(slot)

		if not var_217_1 and healerState.ctx and healerState.ctx.saveConfig then
			healerState.saveConfigIfReady()
		end

		if var_217_1 then
			healerState.syncAddHealingConfirmButtons()
		end
	end)
	gamePopupMenuWidget:display()
end

  healerState[182] = function(arg_223_0)
	if not arg_223_0 then
		return
	end

	arg_223_0._helperAssignPreview = true

	function arg_223_0.onMousePress(_, _, mouseButton)
		if mouseButton == MouseLeftButton then
			return true
		end

		return false
	end

	function arg_223_0.onMouseRelease(arg_225_0, unusedArgument, arg_225_2)
		if arg_225_2 == MouseRightButton then
			healerState[181](arg_225_0)

			return true
		end

		if arg_225_2 == MouseLeftButton then
			return true
		end

		return false
	end

	if not healerState[69](arg_223_0) then
		local var_223_0 = healerState.actionbar()

		if var_223_0 and var_223_0.refreshActionSlotFrameClip then
			var_223_0.refreshActionSlotFrameClip(arg_223_0)
		end
	end

	healerState.syncHealingActionSlotLayers(arg_223_0)
end

 healerState.syncAddHealingConfirmButtons = function()
	if not healerState[6] or healerState[6]:isDestroyed() then
		return
	end

	local enabled = healerState.addHealingSlot and healerState[147](healerState.addHealingSlot)
	local addHealingOkButton = healerState[6]:recursiveGetChildById("addHealingOkButton")
	local addHealingApplyButton = healerState[6]:recursiveGetChildById("addHealingApplyButton")

	if addHealingOkButton then
		addHealingOkButton:setEnabled(enabled)
	end

	if addHealingApplyButton then
		addHealingApplyButton:setEnabled(enabled)
	end

	healerState[182](healerState.addHealingSlot)
end

  healerState[183] = function()
	if not healerState[6] or healerState[6]:isDestroyed() then
		return
	end

	healerState.addHealingSlot = healerState[6]:recursiveGetChildById("addHealingActionSlot")

	if not healerState.addHealingSlot then
		return
	end

	healerState[182](healerState.addHealingSlot)
	healerState.stackHealingActionSlotLayers(healerState.addHealingSlot)
end

  healerState[184] = function()
	if healerState.addHealingSlot and not healerState.addHealingSlot:isDestroyed() then
		healerState.addHealingSlot._helperAssignPreview = nil
		healerState.addHealingSlot._helperHealingSlot = nil
	end

	healerState.addHealingSlot = nil
	healerState[8] = nil

	if healerState[6] and not healerState[6]:isDestroyed() then
		healerState[6]:destroy()
	end

	healerState[6] = nil
end

  healerState[185] = function(arg_229_0)
	for unusedValue, ptc_root_local in ipairs(healerState.healingEntries) do
		if ptc_root_local.id == arg_229_0 then
			return ptc_root_local
		end
	end

	return nil
end

 healerState[15] = function(arg_230_0, arg_230_1)
	if not arg_230_0 or not arg_230_1 then
		return
	end

	healerState.clearSlotData(arg_230_0)

	arg_230_0.words = arg_230_1.words
	arg_230_0.itemId = arg_230_1.itemId
	arg_230_0._helperDisplayItemId = arg_230_1.itemId
	arg_230_0.subType = arg_230_1.subType
	arg_230_0.useType = arg_230_1.useType
	arg_230_0.parameter = arg_230_1.parameter

	local var_230_0 = healerState.actionbar()
	local words = healerState.normalizeEntryWords(arg_230_1.words)

	if words then
		arg_230_0.words = words

		if arg_230_0.setItemId then
			arg_230_0:setItemId(healerState.ACTION_SLOT_SPELL_ITEM_ID)
		end

		if var_230_0 and var_230_0.loadSpell then
			var_230_0.loadSpell(arg_230_0)
		end

		healerState.refreshSlotVisual(arg_230_0)
	elseif arg_230_1.itemId and arg_230_1.itemId > 0 then
		if arg_230_0.setItemId then
			arg_230_0:setItemId(arg_230_1.itemId)
		end

		if var_230_0 and var_230_0.loadObject then
			var_230_0.loadObject(arg_230_0)
		end

		healerState.refreshSlotVisual(arg_230_0)
	end

	if arg_230_0 == healerState.addHealingSlot then
		healerState.syncAddHealingConfirmButtons()
	end
end

  healerState[186] = function(text)
	if not healerState[6] or healerState[6]:isDestroyed() then
		return
	end

	healerState[6]:setText(text)
end

  healerState[187] = function(arg_232_0)
	if not healerState[6] or healerState[6]:isDestroyed() then
		return
	end

	local addHealingWhenMetric1Combo = healerState[6]:recursiveGetChildById("addHealingWhenMetric1Combo")
	local addHealingConditionLogicCombo = healerState[6]:recursiveGetChildById("addHealingConditionLogicCombo")
	local addHealingWhenMetric2Combo = healerState[6]:recursiveGetChildById("addHealingWhenMetric2Combo")
	local addHealingConditionMinCombo = healerState[6]:recursiveGetChildById("addHealingConditionMinCombo")
	local addHealingThresholdMinEdit = healerState[6]:recursiveGetChildById("addHealingThresholdMinEdit")
	local addHealingConditionMaxCombo = healerState[6]:recursiveGetChildById("addHealingConditionMaxCombo")
	local addHealingThresholdMaxEdit = healerState[6]:recursiveGetChildById("addHealingThresholdMaxEdit")
	local var_232_7 = arg_232_0 and healerState[132](arg_232_0) or nil

	if arg_232_0 and var_232_7 then
		healerState[186](tr("Edit Healing"))

		if addHealingWhenMetric1Combo then
			addHealingWhenMetric1Combo:setCurrentOption(healerState[120](var_232_7.whenMetric1))
		end

		if addHealingConditionLogicCombo then
			addHealingConditionLogicCombo:setCurrentOption(healerState[121](var_232_7.conditionLogic))
		end

		if addHealingWhenMetric2Combo then
			addHealingWhenMetric2Combo:setCurrentOption(healerState[120](var_232_7.whenMetric2))
		end

		if addHealingConditionMinCombo then
			addHealingConditionMinCombo:setCurrentOption(var_232_7.conditionMin)
		end

		healerState[144](addHealingThresholdMinEdit, var_232_7.thresholdMin)

		if addHealingConditionMaxCombo then
			addHealingConditionMaxCombo:setCurrentOption(var_232_7.conditionMax)
		end

		healerState[144](addHealingThresholdMaxEdit, var_232_7.thresholdMax)

		if healerState.addHealingSlot then
			healerState[15](healerState.addHealingSlot, arg_232_0)
		end
	else
		healerState[186](tr("Add Healing"))

		if addHealingWhenMetric1Combo then
			addHealingWhenMetric1Combo:setCurrentOption("HP%")
		end

		if addHealingConditionLogicCombo then
			addHealingConditionLogicCombo:setCurrentOption("and")
		end

		if addHealingWhenMetric2Combo then
			addHealingWhenMetric2Combo:setCurrentOption("HP%")
		end

		if addHealingConditionMinCombo then
			addHealingConditionMinCombo:setCurrentOption(">=")
		end

		healerState[144](addHealingThresholdMinEdit, healerState[124])

		if addHealingConditionMaxCombo then
			addHealingConditionMaxCombo:setCurrentOption("<=")
		end

		healerState[144](addHealingThresholdMaxEdit, healerState[125])

		if healerState.addHealingSlot then
			healerState.clearSlotData(healerState.addHealingSlot)
		end
	end

	healerState.syncAddHealingConfirmButtons()
end

  healerState[188] = function(arg_233_0)
	if healerState[6] and not healerState[6]:isDestroyed() then
		healerState[184]()
	end

	healerState[8] = arg_233_0
	healerState[6] = g_ui.loadUI("assign_healing", g_ui.getRootWidget())

	if not healerState[6] then
		healerState[8] = nil

		return
	end

	if healerState.ctx and healerState.ctx.applyWidgetLanguage then
		healerState.ctx.applyWidgetLanguage(healerState[6])
	end

	healerState[183]()

	local var_233_0 = arg_233_0 and healerState[185](arg_233_0) or nil

	healerState[187](var_233_0)
	healerState[6]:raise()
	healerState[6]:focus()
end

  healerState[189] = function()
	if not healerState[6] or healerState[6]:isDestroyed() then
		return nil
	end

	local addHealingWhenMetric1Combo = healerState[6]:recursiveGetChildById("addHealingWhenMetric1Combo")
	local addHealingConditionLogicCombo = healerState[6]:recursiveGetChildById("addHealingConditionLogicCombo")
	local addHealingWhenMetric2Combo = healerState[6]:recursiveGetChildById("addHealingWhenMetric2Combo")
	local addHealingConditionMinCombo = healerState[6]:recursiveGetChildById("addHealingConditionMinCombo")
	local addHealingThresholdMinEdit = healerState[6]:recursiveGetChildById("addHealingThresholdMinEdit")
	local addHealingConditionMaxCombo = healerState[6]:recursiveGetChildById("addHealingConditionMaxCombo")
	local addHealingThresholdMaxEdit = healerState[6]:recursiveGetChildById("addHealingThresholdMaxEdit")

	if not addHealingWhenMetric1Combo or not addHealingConditionLogicCombo or not addHealingWhenMetric2Combo or not addHealingConditionMinCombo or not addHealingThresholdMinEdit or not addHealingConditionMaxCombo or not addHealingThresholdMaxEdit or not healerState.addHealingSlot then
		return nil
	end

	if not healerState[147](healerState.addHealingSlot) then
		return nil
	end

	local var_234_7 = healerState[145](healerState.addHealingSlot)

	return {
		enabled = true,
		whenMetric1 = healerState[119](healerState[118](addHealingWhenMetric1Combo)),
		conditionLogic = healerState[121](healerState[118](addHealingConditionLogicCombo)),
		whenMetric2 = healerState[119](healerState[118](addHealingWhenMetric2Combo)),
		conditionMin = healerState[131](healerState[118](addHealingConditionMinCombo)),
		thresholdMin = healerState[143](addHealingThresholdMinEdit, healerState[124]),
		conditionMax = healerState[131](healerState[118](addHealingConditionMaxCombo)),
		thresholdMax = healerState[143](addHealingThresholdMaxEdit, healerState[125]),
		words = var_234_7.words,
		itemId = var_234_7.itemId,
		subType = var_234_7.subType,
		useType = var_234_7.useType,
		parameter = var_234_7.parameter
	}
end

  healerState[190] = function(arg_235_0)
	addEvent(function()
		local var_236_0 = healerState[51](arg_235_0)

		if not var_236_0 then
			return
		end

		healerState[52](var_236_0)

		local healingConditionActionSlot = var_236_0:recursiveGetChildById("healingConditionActionSlot")

		if healingConditionActionSlot then
			healerState[12](healingConditionActionSlot)
		end
	end)
end

  healerState[191] = function(arg_237_0)
	healerState[23]()

	local var_237_0 = {
		pendingAdd = true,
		enabled = true,
		id = healerState[5],
		kind = arg_237_0 == "potion" and "potion" or "spell"
	}

	healerState[5] = healerState[5] + 1

	healerState[138](var_237_0, healerState[135](var_237_0))
	table.insert(healerState.healingEntries, var_237_0)
	healerState[14]()
	healerState[190](var_237_0.id)

	return var_237_0
end

function HelperHealer.cancelPendingHealingEntryAssign()
	healerState[23]()

	for iter_238_0 = #healerState.healingEntries, 1, -1 do
		local var_238_0 = healerState.healingEntries[iter_238_0]

		if var_238_0.pendingAdd and not healerState[146](var_238_0) then
			table.remove(healerState.healingEntries, iter_238_0)
			healerState[14]()
			healerState[57]()
			healerState[158]()

			return true
		end
	end

	return false
end

function HelperHealer.openAddHealingSpellWindow()
	healerState[191]("spell")
end

function HelperHealer.openAddHealingPotionWindow()
	healerState[191]("potion")
end

function HelperHealer.openAddHealingWindow()
	HelperHealer.openAddHealingSpellWindow()
end

function HelperHealer.openEditHealingWindow()
	local var_242_0 = healerState[50]()

	if not var_242_0 then
		return
	end

	healerState[188](var_242_0)
end

function HelperHealer.closeAddHealingWindow()
	healerState[184]()
end

  healerState[192] = function(arg_244_0)
	local var_244_0 = healerState[189]()

	if not var_244_0 then
		return false
	end

	local id = healerState[8]

	if healerState[8] then
		local var_244_2 = healerState[185](healerState[8])

		if var_244_2 then
			var_244_2.whenMetric1 = var_244_0.whenMetric1
			var_244_2.conditionLogic = var_244_0.conditionLogic
			var_244_2.whenMetric2 = var_244_0.whenMetric2
			var_244_2.conditionMin = var_244_0.conditionMin
			var_244_2.thresholdMin = var_244_0.thresholdMin
			var_244_2.conditionMax = var_244_0.conditionMax
			var_244_2.thresholdMax = var_244_0.thresholdMax
			var_244_2.words = var_244_0.words
			var_244_2.itemId = var_244_0.itemId
			var_244_2.subType = var_244_0.subType
			var_244_2.useType = var_244_0.useType
			var_244_2.parameter = var_244_0.parameter
		end
	else
		var_244_0.id = healerState[5]
		healerState[5] = healerState[5] + 1

		table.insert(healerState.healingEntries, var_244_0)

		healerState[8] = var_244_0.id
		id = var_244_0.id
	end

	healerState[14]()

	if healerState.ctx and healerState.ctx.saveConfig then
		healerState.saveConfigIfReady()
	end

	if arg_244_0 then
		healerState[184]()
	end

	if id then
		addEvent(function()
			healerState[155](id)
		end)
	else
		healerState.syncHealingActionButtons()
	end

	return true
end

function HelperHealer.addHealingEntryOk()
	healerState[192](true)
end

function HelperHealer.addHealingEntryApply()
	healerState[192](false)
end

function HelperHealer.addHealingEntryConfirm()
	HelperHealer.addHealingEntryOk()
end

function HelperHealer.removeSelectedEntry()
	local var_249_0 = healerState[50]()

	if not var_249_0 then
		return
	end

	if healerState[156](var_249_0) then
		healerState[14]()
		healerState[57]()
		healerState[158]()
	end
end

function HelperHealer.onAddHealingThresholdChange(edit)
	if not edit then
		return
	end

	local text = edit:getText() or ""
	local var_250_1 = healerState[141](text)

	if var_250_1 == "" then
		if text ~= "" then
			edit:setText("")
		end

		return
	end

	local numericValue = tonumber(var_250_1)

	if not numericValue or numericValue < healerState[122] then
		edit:setText(tostring(healerState[122]))

		return
	end

	if numericValue > healerState[123] then
		edit:setText(tostring(healerState[123]))

		return
	end

	if var_250_1 ~= text then
		edit:setText(var_250_1)
	end
end

function HelperHealer.onAddHealingThresholdFocusChange(edit, focused)
	if focused or not edit then
		return
	end

	local text = edit:getText() or ""
	local var_251_1 = healerState[125]

	if edit:getId() == "addHealingThresholdMinEdit" then
		var_251_1 = healerState[124]
	end

	if text == "" then
		edit:setText(tostring(var_251_1))

		return
	end

	local var_251_2 = healerState[130](text, var_251_1)

	if tostring(var_251_2) ~= text then
		edit:setText(tostring(var_251_2))
	end
end

  healerState[193] = function(arg_252_0)
	return healerState[134](arg_252_0) == "spell" and healerState.normalizeEntryWords(arg_252_0.words) ~= nil
end

  healerState[194] = function(arg_253_0)
	local var_253_0 = arg_253_0 and tonumber(arg_253_0.itemId)

	return healerState[134](arg_253_0) == "potion" and var_253_0 and var_253_0 > 0 and arg_253_0.useType ~= nil and arg_253_0.useType ~= ""
end

  healerState[195] = function(arg_254_0)
	if not healerState[194](arg_254_0) then
		return false
	end

	if healerState[112](arg_254_0.itemId) then
		return healerState[136](arg_254_0) == "MP"
	end

	return healerState[110](arg_254_0.itemId)
end

  healerState[196] = function(arg_255_0)
	if not healerState[194](arg_255_0) then
		return false
	end

	if healerState[112](arg_255_0.itemId) then
		return healerState[136](arg_255_0) == "HP"
	end

	return not healerState[110](arg_255_0.itemId)
end

  healerState[197] = function(entryHasAction, unusedArgument)
	local config = {}

	for _, copy in ipairs(healerState.healingEntries) do
		if copy.enabled ~= false and healerState[146](copy) and entryHasAction(copy) then
			table.insert(config, {
				entry = copy,
				index = _,
				percent = healerState[137](copy)
			})
		end
	end

	table.sort(config, function(a, b)
		if a.percent == b.percent then
			return a.index < b.index
		end

		return a.percent < b.percent
	end)

	return config
end

  healerState[198] = function(arg_258_0, arg_258_1, arg_258_2)
	for unusedValue, entry in ipairs(healerState[197](arg_258_1, arg_258_2)) do
		local entry = entry.entry

		if (arg_258_2 and HelperHealer.entryMetricPercentConditionMet(entry, arg_258_0, arg_258_2) or healerState[139](entry, arg_258_0)) and healerState[179](entry, arg_258_0) then
			return true
		end
	end

	return false
end

  healerState[199] = function()
	local widget = healerState.ctx and healerState.ctx.getWidget("enableHealingCheckBox")

	return widget and widget:isChecked() or false
end

  healerState[200] = function(arg_260_0, arg_260_1)
	local var_260_0

	for unusedValue, ptc_root_local in ipairs(healerState.healingEntries) do
		if ptc_root_local.enabled ~= false and healerState[193](ptc_root_local) and healerState[139](ptc_root_local, arg_260_0) and healerState[113](ptc_root_local.words, arg_260_0.player, true) and (not arg_260_1 or not healerState[114](ptc_root_local.words)) then
			local spellByWords = Spells.getSpellByWords(ptc_root_local.words)
			local numericValue = tonumber(spellByWords.mana) or 0

			var_260_0 = math.min(var_260_0 or numericValue, numericValue)
		end
	end

	return var_260_0
end

function HelperHealer.shouldYieldToHealing(arg_261_0, arg_261_1)
	if not arg_261_0 or not healerState[199]() then
		return false
	end

	local maxHealth = arg_261_0:getMaxHealth() or 0
	local health = arg_261_0:getHealth()
	local maxMana = arg_261_0:getMaxMana() or 0
	local mana = arg_261_0:getMana()
	local var_261_4 = {
		player = arg_261_0,
		healthPercent = maxHealth > 0 and health and health / maxHealth * 100 or arg_261_0.getHealthPercent and arg_261_0:getHealthPercent() or 100,
		manaPercent = maxMana > 0 and mana and mana / maxMana * 100 or 100
	}

	for unusedValue, ptc_root_local in ipairs(healerState.healingEntries) do
		if ptc_root_local.enabled ~= false and (healerState[193](ptc_root_local) or healerState[196](ptc_root_local) or healerState[195](ptc_root_local)) and healerState[139](ptc_root_local, var_261_4) and healerState[148](ptc_root_local, var_261_4) then
			return true
		end
	end

	local var_261_5 = healerState[200](var_261_4)

	if var_261_5 ~= nil then
		local var_261_6 = g_clock.millis()

		for unusedValue, spell in pairs(healerState.multiUseExDelay.spells) do
			if var_261_6 < spell then
				return true
			end
		end
	end

	return var_261_5 ~= nil and var_261_5 > mana - (tonumber(arg_261_1) or 0)
end

function HelperHealer.runTick(state)
	healerState[23]()

	if not state or not state.player or not healerState[199]() then
		return false
	end

	local var_262_0 = false
	local var_262_1 = healerState[200](state, true)
	local mana = var_262_1 and var_262_1 > state.player:getMana()

	if not mana then
		healerState.multiUseExDelay.lastHealthPotionWasPlain = false
	end

	local var_262_3 = mana and healerState.multiUseExDelay.lastHealthPotionWasPlain and healerState[198](state, healerState[195], "MP")

	if var_262_3 then
		var_262_0 = true
	end

	local var_262_4 = not var_262_3 and healerState[198](state, healerState[196], "HP")

	if var_262_4 then
		var_262_0 = true
	end

	if healerState[198](state, healerState[193]) then
		var_262_0 = true
	end

	if not var_262_4 and not var_262_3 and healerState[198](state, healerState[195], "MP") then
		var_262_0 = true
	end

	return var_262_0
end

function HelperHealer.init(pctx)
	healerState.ctx = pctx

	healerState[23]()
	healerState[106]()
	healerState.resolveHealingEntryPanels()
	healerState.forEachHealingEntryPanel(function(arg_264_0)
		connect(arg_264_0, {
			onChildFocusChange = function()
				healerState.syncHealingActionButtons()
			end
		})
	end)
	healerState.syncHealingActionButtons()
end

function HelperHealer.onGameStart()
	healerState[106]()
end

function HelperHealer.onShow()
	healerState[14]()
	healerState[57]()
end

function HelperHealer.onHide()
	healerState[160]()
	HelperHealer.destroyHealingEntryDragGhost()
	healerState.closeHelperItemAssignInternal()
	healerState[184]()
	healerState[57]()
end

function HelperHealer.clearListSelection()
	healerState[57]()
end

function HelperHealer.terminate()
	healerState[160]()
	HelperHealer.destroyHealingEntryDragGhost()
	healerState.closeHelperItemAssignInternal()
	healerState[184]()
	healerState[107]()
	healerState[102]()
end

function HelperHealer.collectConfig(config)
	healerState[23]()

	config.healingEntries = {}
	config.healingSlots = {}

	for unusedValue, ptc_root_local in ipairs(healerState.healingEntries) do
		local var_271_0 = healerState[162](ptc_root_local)

		if healerState[146](var_271_0) then
			table.insert(config.healingEntries, var_271_0)
			table.insert(config.healingSlots, HelperHealer.copyLegacyHealingSlot(var_271_0))
		end
	end
end

function HelperHealer.loadFromConfig(config)
	healerState[178](config)
	healerState[23]()
	scheduleEvent(function()
		local var_273_0, var_273_1 = pcall(healerState[14])

		if not var_273_0 and g_logger and g_logger.warning then
			g_logger.warning("[HelperHealer] refreshHealingListUI after load failed: " .. tostring(var_273_1))
		end
	end, 50)
end

function HelperHealer.onEnableHealingChange(unusedArgument, unusedArgument)
	healerState.saveConfigIfReady()
end
