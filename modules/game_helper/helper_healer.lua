-- Root locals stored in a lexical table to fit the LuaJIT 200-local limit.
local ptc_root_locals = {}
HelperHealer = HelperHealer or {}

 ptc_root_locals.ctx = nil
 ptc_root_locals.healingEntries = {}
 ptc_root_locals.healingEntriesPanel = nil
 ptc_root_locals.healingSpellEntriesPanel = nil
 ptc_root_locals.healingPotionEntriesPanel = nil
 ptc_root_locals[5] = 1
 ptc_root_locals[6] = nil
 ptc_root_locals.addHealingSlot = nil
 ptc_root_locals[8] = nil
 ptc_root_locals[9] = nil
 ptc_root_locals.syncAddHealingConfirmButtons = nil
 ptc_root_locals[11] = nil
 ptc_root_locals[12] = nil
 ptc_root_locals[13] = nil
 ptc_root_locals[14] = nil
 ptc_root_locals[15] = nil
 ptc_root_locals.helperAssignWindow = nil
 ptc_root_locals.helperAssignPanel = nil
 ptc_root_locals.helperAssignMode = nil
 ptc_root_locals.helperAssignTargetSlot = nil
 ptc_root_locals.ACTION_SLOT_SPELL_ITEM_ID = 469
 ptc_root_locals.SLOT_IMG_EMPTY = "/images/game/actionbar/slot-actionbar-empty"
 ptc_root_locals.SLOT_CLIP_NORMAL = "0 0 34 34"

  ptc_root_locals[23] = function()
	if type(ptc_root_locals.healingEntries) ~= "table" then
		ptc_root_locals.healingEntries = {}
	end
end

  ptc_root_locals.saveConfigIfReady = function()
	if ptc_root_locals.ctx and ptc_root_locals.ctx.isLoadingConfig and ptc_root_locals.ctx.isLoadingConfig() then
		return
	end

	if ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
		ptc_root_locals.ctx.saveConfig()
	end
end

  ptc_root_locals[25] = function()
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

  ptc_root_locals.normalizeEntryWords = function(words)
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

 ptc_root_locals[27] = 1
 ptc_root_locals[28] = 100
 ptc_root_locals[29] = 80
 ptc_root_locals.IGNORED_HEALING_SPELL_IDS = {
	[144] = true,
	[128] = true,
	[145] = true,
	[146] = true,
	[29] = true,
	[242] = true,
	[84] = true,
	[297] = true
}
 ptc_root_locals.POTION_WHITELIST = {
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
 ptc_root_locals.BLOCKED_POTION_IDS = {
	[35563] = true
}

  ptc_root_locals.isBlockedHealingPotionId = function(itemId)
	return itemId and ptc_root_locals.BLOCKED_POTION_IDS[tonumber(itemId) or itemId] == true
end

  ptc_root_locals.isHealingFoodEntry = function(data)
	return data and data.useType == "use"
end

 ptc_root_locals[35] = {
	spells = {},
	groups = {}
}
 ptc_root_locals.multiUseExDelay = {
	lastHealthPotionWasPlain = false,
	potionUntil = 0,
	spells = {},
	groups = {}
}
 ptc_root_locals[37] = 0
 ptc_root_locals[38] = false
 ptc_root_locals[39] = 1000
 ptc_root_locals[40] = 1000
 ptc_root_locals.ZEBRA_COLOR_A = "#484848"
 ptc_root_locals.ZEBRA_COLOR_B = "#414141"
 ptc_root_locals.ZEBRA_FOCUS_COLOR = "#585858"
 ptc_root_locals.ZEBRA_TEXT_COLOR = "#c0c0c0"
 ptc_root_locals.ZEBRA_FOCUS_TEXT_COLOR = "#f4f4f4"

  ptc_root_locals[46] = function(panel)
	if not panel then
		return
	end

	local idx = 0

	for _, child in ipairs(panel:getChildren()) do
		if child:isVisible() then
			idx = idx + 1

			local color = idx % 2 == 1 and ptc_root_locals.ZEBRA_COLOR_A or ptc_root_locals.ZEBRA_COLOR_B

			child.zebraColor = color

			child:setBackgroundColor(color)
		end
	end
end

  ptc_root_locals.setHealingRowTextColors = function(row, color)
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

  ptc_root_locals.resolveHealingEntryPanels = function()
	if ptc_root_locals.ctx then
		if (not ptc_root_locals.healingEntriesPanel or ptc_root_locals.healingEntriesPanel:isDestroyed()) and ptc_root_locals.ctx.getWidget then
			ptc_root_locals.healingEntriesPanel = ptc_root_locals.ctx.getWidget("healingEntriesPanel")
		end

		if (not ptc_root_locals.healingSpellEntriesPanel or ptc_root_locals.healingSpellEntriesPanel:isDestroyed()) and ptc_root_locals.ctx.getWidget then
			ptc_root_locals.healingSpellEntriesPanel = ptc_root_locals.ctx.getWidget("healingSpellEntriesPanel")
		end

		if (not ptc_root_locals.healingPotionEntriesPanel or ptc_root_locals.healingPotionEntriesPanel:isDestroyed()) and ptc_root_locals.ctx.getWidget then
			ptc_root_locals.healingPotionEntriesPanel = ptc_root_locals.ctx.getWidget("healingPotionEntriesPanel")
		end
	end
end

  ptc_root_locals.forEachHealingEntryPanel = function(callback)
	ptc_root_locals.resolveHealingEntryPanels()

	local panels = {
		ptc_root_locals.healingSpellEntriesPanel,
		ptc_root_locals.healingPotionEntriesPanel,
		ptc_root_locals.healingEntriesPanel
	}

	for i = 1, 3 do
		local panel = panels[i]

		if panel and not panel:isDestroyed() then
			callback(panel)
		end
	end
end

  ptc_root_locals[50] = function()
	local entryId

	ptc_root_locals.forEachHealingEntryPanel(function(panel)
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

  ptc_root_locals[51] = function(entryId)
	local targetRow

	ptc_root_locals.forEachHealingEntryPanel(function(panel)
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

  ptc_root_locals[52] = function(row)
	if not row or row:isDestroyed() then
		return
	end

	local parent = row:getParent()

	if parent and parent.focusChild then
		parent:focusChild(row, KeyboardFocusReason)
	end

	row:setBackgroundColor(ptc_root_locals.ZEBRA_FOCUS_COLOR)
	ptc_root_locals.setHealingRowTextColors(row, ptc_root_locals.ZEBRA_FOCUS_TEXT_COLOR)
end

  ptc_root_locals.resetHealingRowFocusColors = function()
	ptc_root_locals.forEachHealingEntryPanel(function(panel)
		for _, row in ipairs(panel:getChildren()) do
			if row.zebraColor then
				row:setBackgroundColor(row.zebraColor)
				ptc_root_locals.setHealingRowTextColors(row, ptc_root_locals.ZEBRA_TEXT_COLOR)
			end
		end
	end)
end

  ptc_root_locals[54] = function(widget)
	while widget do
		if widget.healingEntryId then
			return widget
		end

		widget = widget:getParent()
	end

	return nil
end

  ptc_root_locals.syncHealingActionButtons = function()
	if not ptc_root_locals.ctx then
		return
	end

	local widget = ptc_root_locals.ctx.getWidget("addHealingButton")
	local var_19_1 = ptc_root_locals.ctx.getWidget("editHealingButton")
	local var_19_2 = ptc_root_locals.ctx.getWidget("removeHealingButton")

	if not widget or not var_19_1 or not var_19_2 then
		return
	end

	if ptc_root_locals[50]() ~= nil then
		var_19_2:show()
		var_19_1:show()
		widget:breakAnchors()
		widget:addAnchor(AnchorTop, "parent", AnchorTop)
		widget:addAnchor(AnchorRight, "editHealingButton", AnchorLeft)
		widget:setMarginRight(6)
	else
		var_19_2:hide()
		var_19_1:hide()
		widget:breakAnchors()
		widget:addAnchor(AnchorTop, "parent", AnchorTop)
		widget:addAnchor(AnchorRight, "parent", AnchorRight)
		widget:setMarginRight(0)
	end
end

  ptc_root_locals[56] = function(widget)
	connect(widget, {
		onFocusChange = function(self, focused)
			if focused then
				self:setBackgroundColor(ptc_root_locals.ZEBRA_FOCUS_COLOR)
				ptc_root_locals.setHealingRowTextColors(self, ptc_root_locals.ZEBRA_FOCUS_TEXT_COLOR)
				ptc_root_locals.syncHealingActionButtons()
			else
				addEvent(function()
					if not self:isDestroyed() then
						self:setBackgroundColor(self.zebraColor or ptc_root_locals.ZEBRA_COLOR_A)
						ptc_root_locals.setHealingRowTextColors(self, ptc_root_locals.ZEBRA_TEXT_COLOR)
						ptc_root_locals.syncHealingActionButtons()
					end
				end)
			end
		end
	})
end

  ptc_root_locals[57] = function()
	ptc_root_locals.forEachHealingEntryPanel(function(panel)
		panel:focusChild(nil)
	end)
	ptc_root_locals.resetHealingRowFocusColors()
	ptc_root_locals.syncHealingActionButtons()
end

 ptc_root_locals.SPIRIT_POTION_IDS = {
	[23374] = true,
	[7642] = true
}
 ptc_root_locals.POTION_TYPE_BY_ID = {}

for _, potion in ipairs(ptc_root_locals.POTION_WHITELIST) do
	ptc_root_locals.POTION_TYPE_BY_ID[potion.id] = potion.type
end

  ptc_root_locals.actionbar = function()
	return modules.game_actionbar
end

  ptc_root_locals.normalizePotionLevel = function(requiredLevel)
	local level = tonumber(requiredLevel) or 1

	if level < 1 then
		level = 1
	end

	return level
end

  ptc_root_locals.potionMeetsLevel = function(requiredLevel)
	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	return player:getLevel() >= ptc_root_locals.normalizePotionLevel(requiredLevel)
end

  ptc_root_locals[63] = function(itemId)
	for _, potion in ipairs(ptc_root_locals.POTION_WHITELIST) do
		if potion.id == itemId then
			if potion.requiredLevel then
				return ptc_root_locals.normalizePotionLevel(potion.requiredLevel)
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
				return ptc_root_locals.normalizePotionLevel(market.requiredLevel)
			end
		end
	end

	return 1
end

  ptc_root_locals.potionItemMeetsLevel = function(arg_30_0)
	return ptc_root_locals.potionMeetsLevel(ptc_root_locals[63](arg_30_0))
end

 ptc_root_locals.shouldShowPotionLevelGray = nil

  ptc_root_locals.playerCanUseHealingSpellVocations = function(vocations, player)
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

  ptc_root_locals.shouldShowHealingSpellGray = function(words)
	words = ptc_root_locals.normalizeEntryWords(words)

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

	if player and spell.vocations and not ptc_root_locals.playerCanUseHealingSpellVocations(spell.vocations, player) then
		return true
	end

	if spell.level and player and not ptc_root_locals.potionMeetsLevel(spell.level) then
		return true
	end

	return false
end

  ptc_root_locals[68] = function(entry)
	if not entry then
		return false
	end

	local ok, result = pcall(function()
		local words = ptc_root_locals.normalizeEntryWords(entry.words)

		if words then
			return ptc_root_locals.shouldShowHealingSpellGray(words)
		end

		if entry.itemId and entry.itemId > 0 then
			if ptc_root_locals.SPIRIT_POTION_IDS[tonumber(entry.itemId) or entry.itemId] == true then
				return false
			end

			return ptc_root_locals.shouldShowPotionLevelGray(entry.itemId)
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

  ptc_root_locals[69] = function(slot)
	if not slot then
		return false
	end

	if slot.words and slot.words ~= "" then
		return false
	end

	local itemId = tonumber(slot.itemId)

	return itemId and itemId > 0 and itemId ~= ptc_root_locals.ACTION_SLOT_SPELL_ITEM_ID
end

  ptc_root_locals.isHealingActionSlot = function(slot)
	return slot and (slot._helperHealingSlot == true or ptc_root_locals.addHealingSlot and slot == ptc_root_locals.addHealingSlot)
end

  ptc_root_locals.stackHealingActionSlotLayers = function(slot)
	if not ptc_root_locals.isHealingActionSlot(slot) then
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

  ptc_root_locals.syncHealingActionSlotLayers = function(slot)
	if not ptc_root_locals.isHealingActionSlot(slot) then
		return
	end

	local bg = slot:getChildById("healingActionItemBackground")
	local itemIcon = slot:getChildById("healingActionItemIcon")
	local hasSpell = slot.words and slot.words ~= ""

	if ptc_root_locals[69](slot) then
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

	ptc_root_locals.stackHealingActionSlotLayers(slot)
end

  ptc_root_locals.updateHealingActionSlotGray = function(slot)
	if not ptc_root_locals.isHealingActionSlot(slot) then
		return
	end

	local gray = slot:getChildById("gray")

	if not gray then
		return
	end

	if slot.words and slot.words ~= "" then
		local ab = ptc_root_locals.actionbar()

		if ab and ab.updateSlotGray then
			ab.updateSlotGray(slot)
		end

		return
	end

	local numericValue = tonumber(slot._helperDisplayItemId or slot.itemId) or 0

	if ptc_root_locals.SPIRIT_POTION_IDS[numericValue] == true then
		gray:setVisible(false)

		return
	end

	gray:setVisible(ptc_root_locals.shouldShowPotionLevelGray(numericValue))
end

  ptc_root_locals.refreshSlotVisual = function(slot)
	local ab = ptc_root_locals.actionbar()

	if not slot or not ab then
		return
	end

	local hasSpell = slot.words and slot.words ~= ""

	if ptc_root_locals[69](slot) or hasSpell then
		if ab.applyActionSlotFrame then
			ab.applyActionSlotFrame(slot)
		end

		if slot._helperAssignPreview and ab.refreshActionSlotFrameClip then
			ab.refreshActionSlotFrameClip(slot)
		end
	elseif slot._helperAssignPreview then
		slot:setImageSource(ptc_root_locals.SLOT_IMG_EMPTY)
		slot:setImageSize(tosize("34 34"))
		slot:setImageClip(ptc_root_locals.SLOT_CLIP_NORMAL)

		slot._actionBarFilledFrame = false
	elseif ab.applyActionSlotFrame then
		ab.applyActionSlotFrame(slot)
	end

	ptc_root_locals.syncHealingActionSlotLayers(slot)

	if ptc_root_locals.isHealingActionSlot(slot) then
		ptc_root_locals.updateHealingActionSlotGray(slot)
	else
		local abGray = ptc_root_locals.actionbar()

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

	ptc_root_locals.stackHealingActionSlotLayers(slot)
end

  ptc_root_locals.clearSlotData = function(slot)
	local ab = ptc_root_locals.actionbar()

	if ab and ab.clearSlotActionContent then
		ab.clearSlotActionContent(slot)

		slot._helperDisplayItemId = nil

		if slot == ptc_root_locals.addHealingSlot then
			ptc_root_locals.refreshSlotVisual(slot)
		end

		if slot == ptc_root_locals.addHealingSlot then
			ptc_root_locals.syncAddHealingConfirmButtons()
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

	ptc_root_locals.refreshSlotVisual(slot)

	if slot == ptc_root_locals.addHealingSlot then
		ptc_root_locals.syncAddHealingConfirmButtons()
	end
end

  ptc_root_locals.assignItemToSlot = function(slot, option, arg_42_2)
	if not option or ptc_root_locals.isHealingFoodEntry(option) or ptc_root_locals.isBlockedHealingPotionId(option.itemId) then
		return
	end

	ptc_root_locals.clearSlotData(slot)

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

	local ab = ptc_root_locals.actionbar()

	if ab and ab.loadObject then
		ab.loadObject(slot)
	end

	ptc_root_locals.refreshSlotVisual(slot)

	if not arg_42_2 and ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
		ptc_root_locals.saveConfigIfReady()
	end

	if slot == ptc_root_locals.addHealingSlot then
		ptc_root_locals.syncAddHealingConfirmButtons()
	end
end

  ptc_root_locals.containsGroup = function(groups, targetGroup)
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

  ptc_root_locals[78] = function(_, spellData)
	if not spellData then
		return false
	end

	if ptc_root_locals.IGNORED_HEALING_SPELL_IDS[spellData.id] then
		return false
	end

	if spellData.needTarget and spellData.parameter then
		return false
	end

	return ptc_root_locals.containsGroup(Spells.getGroupIds(spellData), 2)
end

  ptc_root_locals[79] = function(slot, filterFn, onAssigned)
	local ab = ptc_root_locals.actionbar()

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
		elseif ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
			ptc_root_locals.saveConfigIfReady()
		end
	end)
end

  ptc_root_locals[80] = function(arg_47_0, id)
	local trim = (arg_47_0:getName() or ""):gsub("^%s+", ""):gsub("%s+$", "")

	if trim ~= "" then
		return trim
	end

	return "#" .. tostring(id)
end

  ptc_root_locals[81] = function(text)
	if not text or text == "" then
		return ""
	end

	return (text:gsub("(%a)([%w_']*)", function(a, rest)
		return a:upper() .. rest:lower()
	end))
end

  ptc_root_locals.potionMeetsVocation = function(thing)
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

function HelperHealer.potionAllowedForVocation(arg_51_0)
	local thingType = arg_51_0 and g_things and g_things.getThingType and g_things.getThingType(arg_51_0, ThingCategoryItem) or nil

	if not thingType then
		return nil
	end

	local marketData = thingType.getMarketData and thingType:getMarketData() or nil

	if not marketData or marketData.restrictVocation == nil then
		return nil
	end

	return ptc_root_locals.potionMeetsVocation(thingType)
end

  ptc_root_locals.formatPotionLevelText = function(requiredLevel)
	return tr("Level:") .. " " .. tostring(ptc_root_locals.normalizePotionLevel(requiredLevel))
end

  ptc_root_locals.buildPotionAssignList = function()
	local potions = {}

	for _, potion in ipairs(ptc_root_locals.POTION_WHITELIST) do
		local thing = g_things.getThingType(potion.id, ThingCategoryItem)

		if thing and ptc_root_locals.potionMeetsVocation(thing) then
			table.insert(potions, {
				id = potion.id,
				name = potion.name,
				requiredLevel = ptc_root_locals[63](potion.id)
			})
		end
	end

	table.sort(potions, function(a, b)
		return a.name:lower() < b.name:lower()
	end)

	return potions
end

  ptc_root_locals.potionItemIsAvailable = function(itemId)
	if not itemId then
		return true
	end

	if ptc_root_locals.isBlockedHealingPotionId(itemId) then
		return false
	end

	local thing = g_things.getThingType(itemId, ThingCategoryItem)

	return ptc_root_locals.potionItemMeetsLevel(itemId) and ptc_root_locals.potionMeetsVocation(thing)
end

 ptc_root_locals.shouldShowPotionLevelGray = function(itemId)
	if not itemId then
		return false
	end

	return not ptc_root_locals.potionItemIsAvailable(itemId)
end

  ptc_root_locals.closeHelperItemAssignInternal = function()
	ptc_root_locals.helperAssignTargetSlot = nil
	ptc_root_locals.helperAssignMode = nil
	ptc_root_locals.helperAssignPanel = nil

	if ptc_root_locals.helperAssignWindow and not ptc_root_locals.helperAssignWindow:isDestroyed() then
		ptc_root_locals.helperAssignWindow:destroy()
	end

	ptc_root_locals.helperAssignWindow = nil
end

  ptc_root_locals.helperItemAssignUsesLearntFilter = function()
	return ptc_root_locals.helperAssignMode == "potion"
end

  ptc_root_locals.rowMeetsLearntFilter = function(arg_59_0)
	if not ptc_root_locals.helperItemAssignUsesLearntFilter() then
		return true
	end

	return ptc_root_locals.potionItemIsAvailable(arg_59_0.assignItemId)
end

  ptc_root_locals.stackHelperAssignRowLayers = function(row)
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

  ptc_root_locals.syncHelperAssignRowGray = function(row)
	if not row then
		return
	end

	local gray = row:getChildById("spellIconGray")

	if not gray then
		return
	end

	if ptc_root_locals.helperAssignMode == "potion" then
		gray:setVisible(ptc_root_locals.shouldShowPotionLevelGray(row.assignItemId))
	else
		gray:hide()
	end

	ptc_root_locals.stackHelperAssignRowLayers(row)
end

  ptc_root_locals.updateHelperItemPreview = function(row)
	if not ptc_root_locals.helperAssignWindow or ptc_root_locals.helperAssignWindow:isDestroyed() or not row then
		return
	end

	local preview = ptc_root_locals.helperAssignWindow:recursiveGetChildById("spellPreview")

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
		if ptc_root_locals.helperAssignMode == "potion" then
			itemGray:setVisible(ptc_root_locals.shouldShowPotionLevelGray(row.assignItemId))
		else
			itemGray:hide()
		end

		preview:raiseChild(itemGray)
	end
end

  ptc_root_locals.clearHelperItemPreview = function()
	if not ptc_root_locals.helperAssignWindow or ptc_root_locals.helperAssignWindow:isDestroyed() then
		return
	end

	local preview = ptc_root_locals.helperAssignWindow:recursiveGetChildById("spellPreview")

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

  ptc_root_locals.syncHelperItemAssignOkButton = function()
	if not ptc_root_locals.helperAssignWindow or ptc_root_locals.helperAssignWindow:isDestroyed() or not ptc_root_locals.helperAssignPanel then
		return
	end

	local okBtn = ptc_root_locals.helperAssignWindow:recursiveGetChildById("okButton")

	if not okBtn then
		return
	end

	local focused = ptc_root_locals.helperAssignPanel:getFocusedChild()

	okBtn:setEnabled(focused ~= nil and focused:isVisible() and focused.assignItemId ~= nil)
end

  ptc_root_locals.focusFirstVisibleHelperAssignRow = function()
	if not ptc_root_locals.helperAssignPanel then
		return
	end

	local first

	for _, child in ipairs(ptc_root_locals.helperAssignPanel:getChildren()) do
		if child:isVisible() then
			first = child

			break
		end
	end

	if first then
		ptc_root_locals.helperAssignPanel:focusChild(first, KeyboardFocusReason)
		ptc_root_locals.updateHelperItemPreview(first)
	else
		ptc_root_locals.helperAssignPanel:focusChild(nil)
		ptc_root_locals.clearHelperItemPreview()
	end

	ptc_root_locals.syncHelperItemAssignOkButton()
end

  ptc_root_locals.createHelperItemAssignRow = function(itemId, itemName, requiredLevel)
	local row = g_ui.createWidget("HelperAssignListLabel", ptc_root_locals.helperAssignPanel)

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

	ptc_root_locals.syncHelperAssignRowGray(row)

	if nameLabel then
		nameLabel:setText(itemName)
	end

	if wordsLabel then
		wordsLabel:setText("")
		wordsLabel:hide()
	end

	if levelLabel then
		if ptc_root_locals.helperAssignMode == "potion" then
			levelLabel:show()
			levelLabel:setText(ptc_root_locals.formatPotionLevelText(requiredLevel))
		else
			levelLabel:hide()
		end
	end

	return row
end

  ptc_root_locals.openHelperItemAssignWindow = function(arg_67_0)
	if ptc_root_locals.helperAssignWindow and not ptc_root_locals.helperAssignWindow:isDestroyed() then
		ptc_root_locals.closeHelperItemAssignInternal()
	end

	ptc_root_locals.helperAssignWindow = g_ui.loadUI("assign_helper", g_ui.getRootWidget())

	if not ptc_root_locals.helperAssignWindow then
		return
	end

	ptc_root_locals.helperAssignMode = "potion"
	ptc_root_locals.helperAssignTargetSlot = arg_67_0
	ptc_root_locals.helperAssignPanel = ptc_root_locals.helperAssignWindow:recursiveGetChildById("spellsPanel")

	ptc_root_locals.helperAssignWindow:setText(tr("Assign Potion"))

	local learntPanel = ptc_root_locals.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsPanel")

	if learntPanel then
		learntPanel:setVisible(true)
	end

	local learntCb = ptc_root_locals.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

	if learntCb then
		learntCb:setChecked(false)
		learntCb:setText(tr("Only show available potions"))
	end

	local okBtn = ptc_root_locals.helperAssignWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setEnabled(false)
	end

	for _, potion in ipairs(ptc_root_locals.buildPotionAssignList()) do
		ptc_root_locals.createHelperItemAssignRow(potion.id, potion.name, potion.requiredLevel)
	end

	connect(ptc_root_locals.helperAssignPanel, {
		onChildFocusChange = function(_, focusedChild)
			if not focusedChild then
				ptc_root_locals.syncHelperItemAssignOkButton()

				return
			end

			ptc_root_locals.updateHelperItemPreview(focusedChild)
			ptc_root_locals.syncHelperItemAssignOkButton()
		end
	})
	HelperHealer.filterHelperAssignEntries("")
	ptc_root_locals.focusFirstVisibleHelperAssignRow()
	ptc_root_locals.helperAssignWindow:raise()
	ptc_root_locals.helperAssignWindow:focus()

	local edit = ptc_root_locals.helperAssignWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:focus()
	end
end

  ptc_root_locals[97] = function(targetSlot)
	ptc_root_locals.openHelperItemAssignWindow(targetSlot)
end

function HelperHealer.isHelperItemAssignActive()
	return ptc_root_locals.helperAssignWindow and not ptc_root_locals.helperAssignWindow:isDestroyed()
end

function HelperHealer.closeHelperItemAssignWindow()
	if HelperHealer.cancelPendingHealingEntryAssign then
		HelperHealer.cancelPendingHealingEntryAssign()
	end

	ptc_root_locals.closeHelperItemAssignInternal()
end

function HelperHealer.helperItemAssignOk()
	if not HelperHealer.isHelperItemAssignActive() or not ptc_root_locals.helperAssignPanel or not ptc_root_locals.helperAssignTargetSlot then
		return
	end

	local focused = ptc_root_locals.helperAssignPanel:getFocusedChild()

	if not focused or not focused.assignItemId then
		return
	end

	local targetSlot = ptc_root_locals.helperAssignTargetSlot
	local useType = "useOnSelf"
	local skipSave = ptc_root_locals.addHealingSlot and targetSlot == ptc_root_locals.addHealingSlot or targetSlot._helperAssignSkipSave == true

	ptc_root_locals.assignItemToSlot(targetSlot, {
		itemId = focused.assignItemId,
		useType = useType
	}, skipSave)
	ptc_root_locals.closeHelperItemAssignInternal()

	if targetSlot.onHelperPotionAssigned then
		targetSlot.onHelperPotionAssigned(targetSlot)
	end
end

function HelperHealer.filterHelperAssignEntries(text)
	if not ptc_root_locals.helperAssignPanel or not HelperHealer.isHelperItemAssignActive() then
		return
	end

	text = text or ""

	local textActive = #text > 0
	local textLower = textActive and text:lower() or ""
	local onlyLearnt = false

	if ptc_root_locals.helperAssignWindow then
		local learntCb = ptc_root_locals.helperAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

		onlyLearnt = learntCb and learntCb:isChecked() or false
	end

	for _, row in ipairs(ptc_root_locals.helperAssignPanel:getChildren()) do
		local visible = true

		if onlyLearnt and not ptc_root_locals.rowMeetsLearntFilter(row) then
			visible = false
		end

		if visible and textActive then
			visible = row.nameLower and row.nameLower:find(textLower, 1, true) ~= nil or false
		end

		row:setVisible(visible)
	end

	ptc_root_locals.focusFirstVisibleHelperAssignRow()
end

function HelperHealer.clearHelperItemAssignFilter()
	if not HelperHealer.isHelperItemAssignActive() then
		return
	end

	local edit = ptc_root_locals.helperAssignWindow:recursiveGetChildById("filterTextEdit")

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

	local edit = ptc_root_locals.helperAssignWindow:recursiveGetChildById("filterTextEdit")

	HelperHealer.filterHelperAssignEntries(edit and edit:getText() or "")
end

function HelperHealer.closePotionAssignWindow()
	ptc_root_locals.closeHelperItemAssignInternal()
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

	ptc_root_locals.openHelperItemAssignWindow(targetSlot)
end

  ptc_root_locals[98] = function(slot)
	if g_game.getFeature and g_game.getFeature(GameThingUpgradeClassification) then
		local stored = slot and slot.getTier

		if type(stored) == "number" then
			return stored
		end
	end

	return 0
end

  ptc_root_locals[99] = function(spellId)
	if Spells and Spells.resolveSpellId then
		return Spells.resolveSpellId(spellId)
	end

	return spellId
end

  ptc_root_locals[100] = function()
	local exhaustion = g_game.getPing and tonumber(g_game.getPing()) or 0

	if exhaustion and exhaustion > 0 then
		return math.max(250, math.min(2000, exhaustion * 2 + 100))
	end

	return ptc_root_locals[40]
end

  ptc_root_locals[101] = function(spell, arg_84_1)
	ptc_root_locals.multiUseExDelay.spells[ptc_root_locals[99](spell.id)] = arg_84_1

	if type(spell.group) == "table" then
		for groupId in pairs(spell.group) do
			ptc_root_locals.multiUseExDelay.groups[groupId] = arg_84_1
		end
	elseif spell.group then
		ptc_root_locals.multiUseExDelay.groups[spell.group] = arg_84_1
	end
end

  ptc_root_locals[102] = function()
	ptc_root_locals[35] = {
		spells = {},
		groups = {}
	}
	ptc_root_locals.multiUseExDelay = {
		lastHealthPotionWasPlain = false,
		potionUntil = 0,
		spells = {},
		groups = {}
	}
	ptc_root_locals[37] = 0
end

  ptc_root_locals[103] = function(arg_86_0, arg_86_1)
	local var_86_0 = ptc_root_locals[99](arg_86_0)

	if not var_86_0 then
		return
	end

	ptc_root_locals.multiUseExDelay.spells[var_86_0] = nil
	ptc_root_locals[35].spells[var_86_0] = g_clock.millis() + math.max(0, tonumber(arg_86_1) or 0)
end

  ptc_root_locals[104] = function(arg_87_0, arg_87_1)
	if not arg_87_0 then
		return
	end

	ptc_root_locals.multiUseExDelay.groups[arg_87_0] = nil
	ptc_root_locals[35].groups[arg_87_0] = g_clock.millis() + math.max(0, tonumber(arg_87_1) or 0)
end

  ptc_root_locals[105] = function(arg_88_0)
	ptc_root_locals.multiUseExDelay.potionUntil = 0

	if not arg_88_0 or arg_88_0 <= 0 then
		ptc_root_locals[37] = 0

		return
	end

	ptc_root_locals[37] = g_clock.millis() + arg_88_0
end

  ptc_root_locals[106] = function()
	if ptc_root_locals[38] then
		return
	end

	connect(g_game, {
		onSpellCooldown = ptc_root_locals[103],
		onSpellGroupCooldown = ptc_root_locals[104],
		onMultiUseCooldown = ptc_root_locals[105],
		onGameEnd = ptc_root_locals[102]
	})

	ptc_root_locals[38] = true
end

  ptc_root_locals[107] = function()
	if not ptc_root_locals[38] then
		return
	end

	disconnect(g_game, {
		onSpellCooldown = ptc_root_locals[103],
		onSpellGroupCooldown = ptc_root_locals[104],
		onMultiUseCooldown = ptc_root_locals[105],
		onGameEnd = ptc_root_locals[102]
	})

	ptc_root_locals[38] = false
end

  ptc_root_locals[108] = function(arg_91_0)
	return ptc_root_locals[35].spells[arg_91_0] or 0
end

  ptc_root_locals[109] = function(arg_92_0)
	return ptc_root_locals[35].groups[arg_92_0] or 0
end

  ptc_root_locals[110] = function(arg_93_0)
	return ptc_root_locals.POTION_TYPE_BY_ID[tonumber(arg_93_0) or arg_93_0] == "mana"
end

  ptc_root_locals[111] = function(arg_94_0)
	return ptc_root_locals.POTION_TYPE_BY_ID[tonumber(arg_94_0) or arg_94_0] == "health"
end

  ptc_root_locals[112] = function(arg_95_0)
	return ptc_root_locals.SPIRIT_POTION_IDS[tonumber(arg_95_0) or arg_95_0] == true
end

  ptc_root_locals[113] = function(arg_96_0, arg_96_1, arg_96_2)
	if not arg_96_0 or not arg_96_1 then
		return false
	end

	local spellByWords = Spells.getSpellByWords(arg_96_0)

	if not spellByWords or not spellByWords.id or spellByWords.id <= 0 or not ptc_root_locals[78](nil, spellByWords) then
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

	if spellByWords.vocations and not ptc_root_locals.playerCanUseHealingSpellVocations(spellByWords.vocations, arg_96_1) then
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

  ptc_root_locals[114] = function(arg_97_0)
	local spellByWords = Spells.getSpellByWords(arg_97_0)

	if not spellByWords or spellByWords.id == 0 then
		return false
	end

	local var_97_1 = g_clock.millis()
	local var_97_2 = ptc_root_locals[99](spellByWords.id)

	if var_97_1 < ptc_root_locals[108](var_97_2) then
		return true
	end

	if type(spellByWords.group) == "table" then
		for key, unusedValue in pairs(spellByWords.group) do
			if var_97_1 < ptc_root_locals[109](key) then
				return true
			end
		end
	elseif spellByWords.group and var_97_1 < ptc_root_locals[109](spellByWords.group) then
		return true
	end

	local var_97_3 = ptc_root_locals.actionbar()

	if var_97_3 and var_97_3.getMultiActionCooldownRemaining then
		local var_97_4, var_97_5 = var_97_3.getMultiActionCooldownRemaining(spellByWords)

		if var_97_4 > 0 then
			ptc_root_locals.multiUseExDelay.spells[var_97_2] = nil
		end

		if var_97_5 > 0 then
			if type(spellByWords.group) == "table" then
				for iter_97_2 in pairs(spellByWords.group) do
					ptc_root_locals.multiUseExDelay.groups[iter_97_2] = nil
				end
			elseif spellByWords.group then
				ptc_root_locals.multiUseExDelay.groups[spellByWords.group] = nil
			end
		end

		if var_97_4 > 0 or var_97_5 > 0 then
			return true
		end
	end

	if var_97_1 < (ptc_root_locals.multiUseExDelay.spells[var_97_2] or 0) then
		return true
	end

	if type(spellByWords.group) == "table" then
		for iter_97_3 in pairs(spellByWords.group) do
			if var_97_1 < (ptc_root_locals.multiUseExDelay.groups[iter_97_3] or 0) then
				return true
			end
		end
	elseif spellByWords.group and var_97_1 < (ptc_root_locals.multiUseExDelay.groups[spellByWords.group] or 0) then
		return true
	end

	return false
end

function HelperHealer.isItemUsePending()
	return ptc_root_locals.multiUseExDelay.potionUntil > g_clock.millis()
end

  ptc_root_locals[115] = function()
	local var_99_0 = g_clock.millis()
	local var_99_1 = ptc_root_locals.actionbar()

	if var_99_1 and var_99_1.getItemMultiUseCooldownRemaining and var_99_1.getItemMultiUseCooldownRemaining() > 0 then
		ptc_root_locals.multiUseExDelay.potionUntil = 0

		return true
	end

	return var_99_0 < ptc_root_locals[37] or var_99_0 < ptc_root_locals.multiUseExDelay.potionUntil or HelperShooter and HelperShooter.isItemUsePending and HelperShooter.isItemUsePending() or false
end

  ptc_root_locals[116] = function(arg_100_0, arg_100_1, arg_100_2)
	if not arg_100_0 or not arg_100_1 or arg_100_1 <= 0 then
		return false
	end

	local var_100_0 = ptc_root_locals[98](arg_100_2)

	if arg_100_0.getInventoryCount and arg_100_0:getInventoryCount(arg_100_1, var_100_0) > 0 then
		return true
	end

	if g_game.findPlayerItem then
		return g_game.findPlayerItem(arg_100_1, arg_100_2 and arg_100_2.subType or -1, var_100_0) ~= nil
	end

	return false
end

  ptc_root_locals[117] = function(value, threshold, condition)
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

  ptc_root_locals[118] = function(combo)
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

  ptc_root_locals[119] = function(metric)
	metric = tostring(metric or "HP"):upper():gsub("%%", "")

	if metric == "MP" or metric == "MANA" then
		return "MP"
	end

	return "HP"
end

  ptc_root_locals[120] = function(arg_104_0)
	return ptc_root_locals[119](arg_104_0) == "MP" and "MP%" or "HP%"
end

  ptc_root_locals[121] = function(logic)
	logic = tostring(logic or "and"):lower()

	if logic == "or" then
		return "or"
	end

	return "and"
end

function HelperHealer.resolveLoadedSpiritMetric(raw)
	if raw.spiritMetric then
		return ptc_root_locals[119](raw.spiritMetric)
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

	return ptc_root_locals[119](raw.whenMetric1 or raw.metric)
end

 ptc_root_locals[122] = 1
 ptc_root_locals[123] = 100
 ptc_root_locals[124] = 1
 ptc_root_locals[125] = 80
 ptc_root_locals[126] = 80
 ptc_root_locals[127] = 50
 ptc_root_locals[128] = 1
 ptc_root_locals[129] = 350

  ptc_root_locals[130] = function(arg_107_0, arg_107_1)
	local numericValue = tonumber(arg_107_0)

	if not numericValue then
		return arg_107_1
	end

	if numericValue < ptc_root_locals[122] then
		numericValue = ptc_root_locals[122]
	end

	if numericValue > ptc_root_locals[123] then
		numericValue = ptc_root_locals[123]
	end

	return numericValue
end

  ptc_root_locals[131] = function(condition)
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

  ptc_root_locals[132] = function(arg_109_0)
	if arg_109_0.whenMetric1 or arg_109_0.thresholdMin ~= nil then
		return {
			whenMetric1 = ptc_root_locals[119](arg_109_0.whenMetric1 or arg_109_0.metric),
			whenMetric2 = ptc_root_locals[119](arg_109_0.whenMetric2 or arg_109_0.whenMetric1 or arg_109_0.metric),
			conditionLogic = ptc_root_locals[121](arg_109_0.conditionLogic),
			conditionMin = ptc_root_locals[131](arg_109_0.conditionMin or arg_109_0.condition),
			thresholdMin = ptc_root_locals[130](arg_109_0.thresholdMin, ptc_root_locals[124]),
			conditionMax = ptc_root_locals[131](arg_109_0.conditionMax or "<="),
			thresholdMax = ptc_root_locals[130](arg_109_0.thresholdMax, arg_109_0.threshold or ptc_root_locals[125])
		}
	end

	local var_109_0 = ptc_root_locals[119](arg_109_0.metric)
	local var_109_1 = ptc_root_locals[131](arg_109_0.condition)
	local var_109_2 = ptc_root_locals[130](arg_109_0.threshold, ptc_root_locals[125])
	local var_109_3 = ">="
	local var_109_4 = ptc_root_locals[122]
	local var_109_5 = "<="
	local var_109_6 = ptc_root_locals[123]

	if var_109_1 == "<=" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", ptc_root_locals[122], "<=", var_109_2
	elseif var_109_1 == "<" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", ptc_root_locals[122], "<", var_109_2
	elseif var_109_1 == ">=" then
		var_109_3, var_109_4, var_109_5, var_109_6 = ">=", var_109_2, "<=", ptc_root_locals[123]
	else
		var_109_3, var_109_4, var_109_5, var_109_6 = ">", var_109_2, "<=", ptc_root_locals[123]
	end

	return {
		whenMetric1 = var_109_0,
		whenMetric2 = var_109_0,
		conditionLogic = ptc_root_locals[121](arg_109_0.conditionLogic),
		conditionMin = var_109_3,
		thresholdMin = var_109_4,
		conditionMax = var_109_5,
		thresholdMax = var_109_6
	}
end

  ptc_root_locals[133] = function(arg_110_0, arg_110_1)
	return ptc_root_locals[119](arg_110_1) == "MP" and arg_110_0.manaPercent or arg_110_0.healthPercent
end

  ptc_root_locals[134] = function(arg_111_0)
	if not arg_111_0 then
		return "spell"
	end

	if ptc_root_locals.normalizeEntryWords(arg_111_0.words) then
		return "spell"
	end

	local numericValue = tonumber(arg_111_0.itemId)

	if numericValue and numericValue > 0 then
		return "potion"
	end

	return arg_111_0.kind == "potion" and "potion" or "spell"
end

  ptc_root_locals[135] = function(arg_112_0)
	if ptc_root_locals[134](arg_112_0) == "potion" then
		return ptc_root_locals[127]
	end

	return ptc_root_locals[126]
end

  ptc_root_locals[136] = function(arg_113_0)
	if ptc_root_locals[134](arg_113_0) == "potion" then
		if arg_113_0 and arg_113_0.itemId and ptc_root_locals[112](arg_113_0.itemId) then
			return ptc_root_locals[119](arg_113_0.spiritMetric)
		end

		if arg_113_0 and arg_113_0.itemId and ptc_root_locals[110](arg_113_0.itemId) then
			return "MP"
		end

		return "HP"
	end

	return "HP"
end

function HelperHealer.getHealingEntryMetricText(entry)
	return ptc_root_locals[136](entry)
end

  ptc_root_locals[137] = function(arg_115_0, arg_115_1)
	arg_115_1 = arg_115_1 or ptc_root_locals[135](arg_115_0)

	if arg_115_0 and arg_115_0.percent ~= nil then
		return ptc_root_locals[130](arg_115_0.percent, arg_115_1)
	end

	local var_115_0 = arg_115_0 and ptc_root_locals[132](arg_115_0) or nil

	if var_115_0 then
		return ptc_root_locals[130](var_115_0.thresholdMax, arg_115_1)
	end

	return ptc_root_locals[130](arg_115_1, arg_115_1)
end

  ptc_root_locals[138] = function(arg_116_0, arg_116_1)
	if not arg_116_0 then
		return
	end

	arg_116_1 = ptc_root_locals[130](arg_116_1, ptc_root_locals[135](arg_116_0))

	local var_116_0 = ptc_root_locals[136](arg_116_0)

	arg_116_0.percent = arg_116_1
	arg_116_0.whenMetric1 = var_116_0
	arg_116_0.whenMetric2 = var_116_0
	arg_116_0.conditionLogic = "and"
	arg_116_0.conditionMin = ">="
	arg_116_0.thresholdMin = ptc_root_locals[122]
	arg_116_0.conditionMax = "<="
	arg_116_0.thresholdMax = arg_116_1
end

  ptc_root_locals[139] = function(arg_117_0, arg_117_1)
	if not arg_117_0 or not arg_117_1 then
		return false
	end

	local var_117_0 = ptc_root_locals[133](arg_117_1, ptc_root_locals[136](arg_117_0))

	return var_117_0 ~= nil and var_117_0 <= ptc_root_locals[137](arg_117_0)
end

function HelperHealer.entryMetricPercentConditionMet(entry, state, metric)
	if not entry or not state then
		return false
	end

	local var_118_0 = ptc_root_locals[133](state, metric)

	return var_118_0 ~= nil and var_118_0 <= ptc_root_locals[137](entry)
end

  ptc_root_locals[140] = function(arg_119_0)
	local numericValue = tonumber(arg_119_0)

	if not numericValue then
		return ptc_root_locals[29]
	end

	if numericValue < ptc_root_locals[27] then
		numericValue = ptc_root_locals[27]
	end

	if numericValue > ptc_root_locals[28] then
		numericValue = ptc_root_locals[28]
	end

	return numericValue
end

  ptc_root_locals[141] = function(text)
	return tostring(text or ""):gsub("%D", "")
end

  ptc_root_locals[142] = function(arg_121_0)
	if not arg_121_0 or not arg_121_0.getText then
		return ptc_root_locals[29]
	end

	local text = arg_121_0:getText() or ""

	if text == "" then
		return ptc_root_locals[29]
	end

	return ptc_root_locals[140](text)
end

  ptc_root_locals[143] = function(arg_122_0, arg_122_1)
	if not arg_122_0 then
		return arg_122_1
	end

	local var_122_0 = ptc_root_locals[118](arg_122_0)

	if var_122_0 and var_122_0 ~= "" then
		return ptc_root_locals[130](var_122_0, arg_122_1)
	end

	if not arg_122_0.getText then
		return arg_122_1
	end

	local text = arg_122_0:getText() or ""

	if text == "" then
		return arg_122_1
	end

	return ptc_root_locals[130](text, arg_122_1)
end

  ptc_root_locals[144] = function(arg_123_0, textValue)
	if not arg_123_0 then
		return
	end

	textValue = tostring(ptc_root_locals[130](textValue, ptc_root_locals[125]))

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
	local var_124_1 = ptc_root_locals[141](text)

	if var_124_1 == "" then
		if text ~= "" then
			edit:setText("")
		end

		ptc_root_locals.saveConfigIfReady()

		return
	end

	local numericValue = tonumber(var_124_1)

	if numericValue == 0 then
		edit:setText(tostring(ptc_root_locals[27]))
		ptc_root_locals.saveConfigIfReady()

		return
	end

	if numericValue > ptc_root_locals[28] then
		edit:setText(tostring(ptc_root_locals[28]))
		ptc_root_locals.saveConfigIfReady()

		return
	end

	if var_124_1 ~= text then
		edit:setText(var_124_1)

		return
	end

	ptc_root_locals.saveConfigIfReady()
end

function HelperHealer.onThresholdFocusChange(edit, focused)
	if focused or not edit then
		return
	end

	local text = edit:getText() or ""

	if text == "" then
		edit:setText(tostring(ptc_root_locals[29]))
		ptc_root_locals.saveConfigIfReady()

		return
	end

	local var_125_1 = ptc_root_locals[140](text)

	if tostring(var_125_1) ~= text then
		edit:setText(tostring(var_125_1))
		ptc_root_locals.saveConfigIfReady()
	end
end

  ptc_root_locals[145] = function(slot)
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

  ptc_root_locals[146] = function(arg_127_0)
	if not arg_127_0 then
		return false
	end

	if ptc_root_locals.normalizeEntryWords(arg_127_0.words) then
		return true
	end

	local numericValue = tonumber(arg_127_0.itemId)

	return numericValue and numericValue > 0 and arg_127_0.useType ~= nil and arg_127_0.useType ~= ""
end

  ptc_root_locals[147] = function(arg_128_0)
	return ptc_root_locals[146](ptc_root_locals[145](arg_128_0))
end

  ptc_root_locals[148] = function(arg_129_0, arg_129_1)
	if not ptc_root_locals[146](arg_129_0) then
		return false
	end

	local var_129_0 = ptc_root_locals.normalizeEntryWords(arg_129_0.words)

	if var_129_0 then
		if ptc_root_locals[114](var_129_0) then
			return false
		end

		local localPlayer = arg_129_1 and arg_129_1.player or g_game.getLocalPlayer()

		return ptc_root_locals[113](var_129_0, localPlayer)
	end

	local localPlayer = arg_129_1 and arg_129_1.player or g_game.getLocalPlayer()

	if not localPlayer then
		return false
	end

	if ptc_root_locals.isBlockedHealingPotionId(arg_129_0.itemId) or ptc_root_locals.isHealingFoodEntry(arg_129_0) then
		return false
	end

	local numericValue = tonumber(arg_129_0.itemId)

	if not ptc_root_locals.POTION_TYPE_BY_ID[numericValue] or localPlayer:getLevel() < ptc_root_locals[63](numericValue) or HelperHealer.potionAllowedForVocation(numericValue) == false then
		return false
	end

	if not ptc_root_locals[116](localPlayer, numericValue, arg_129_0) then
		return false
	end

	return not ptc_root_locals[115]()
end

  ptc_root_locals[149] = function(arg_130_0, arg_130_1)
	return ptc_root_locals[148](ptc_root_locals[145](arg_130_0), arg_130_1)
end

  ptc_root_locals[150] = function()
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

  ptc_root_locals[151] = function(arg_132_0)
	if not arg_132_0 or not arg_132_0.words or arg_132_0.words == "" then
		return false
	end

	if not ptc_root_locals[150]() or ptc_root_locals[114](arg_132_0.words) then
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

	ptc_root_locals[101](spellByWords, g_clock.millis() + ptc_root_locals[100]())

	local var_132_2, var_132_3 = pcall(g_game.talk, words)

	if not var_132_2 or var_132_3 == false then
		ptc_root_locals[101](spellByWords, nil)

		return false
	end

	return true
end

  ptc_root_locals[152] = function(arg_133_0, arg_133_1)
	local localPlayer = arg_133_1 and arg_133_1.player or g_game.getLocalPlayer()
	local numericValue = tonumber(arg_133_0 and arg_133_0.itemId)

	if not localPlayer or not numericValue or numericValue <= 0 or ptc_root_locals.isBlockedHealingPotionId(numericValue) then
		return false
	end

	if not ptc_root_locals[150]() or not ptc_root_locals[148](arg_133_0, arg_133_1) then
		return false
	end

	ptc_root_locals.multiUseExDelay.potionUntil = g_clock.millis() + math.max(ptc_root_locals[39], ptc_root_locals[100]())

	local var_133_2, var_133_3 = pcall(g_game.useInventoryItemWith, numericValue, localPlayer)

	if not var_133_2 or var_133_3 == false then
		ptc_root_locals.multiUseExDelay.potionUntil = 0

		return false
	end

	ptc_root_locals.multiUseExDelay.lastHealthPotionWasPlain = ptc_root_locals[111](numericValue) and not ptc_root_locals[112](numericValue)

	return true
end

  ptc_root_locals[153] = function(arg_134_0)
	for unusedValue, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		if ptc_root_local.id == arg_134_0 then
			return ptc_root_local
		end
	end

	return nil
end

  ptc_root_locals[154] = function(arg_135_0)
	for index, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		if ptc_root_local.id == arg_135_0 then
			return index, ptc_root_local
		end
	end

	return nil
end

  ptc_root_locals[155] = function(arg_136_0)
	ptc_root_locals.resetHealingRowFocusColors()

	local var_136_0 = ptc_root_locals[51](arg_136_0)

	if not var_136_0 then
		return
	end

	ptc_root_locals[52](var_136_0)
	ptc_root_locals.syncHealingActionButtons()
end

  ptc_root_locals[156] = function(arg_137_0)
	local var_137_0 = ptc_root_locals[154](arg_137_0)

	if not var_137_0 then
		return false
	end

	table.remove(ptc_root_locals.healingEntries, var_137_0)

	return true
end

  ptc_root_locals[157] = function(arg_138_0, arg_138_1, arg_138_2, arg_138_3)
	local var_138_0, var_138_1 = ptc_root_locals[154](arg_138_0)

	if not var_138_1 then
		return false
	end

	local var_138_2 = ptc_root_locals[134](var_138_1)

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

		var_138_3, var_138_5 = ptc_root_locals[154](arg_138_1)

		if not var_138_5 or ptc_root_locals[134](var_138_5) ~= var_138_2 then
			return false
		end
	end

	table.remove(ptc_root_locals.healingEntries, var_138_0)

	if var_138_3 then
		if var_138_0 < var_138_3 then
			var_138_3 = var_138_3 - 1
		end

		table.insert(ptc_root_locals.healingEntries, var_138_3 + (arg_138_2 and 1 or 0), var_138_1)

		return true
	end

	for iter_138_0 = #ptc_root_locals.healingEntries, 1, -1 do
		if ptc_root_locals[134](ptc_root_locals.healingEntries[iter_138_0]) == var_138_2 then
			table.insert(ptc_root_locals.healingEntries, iter_138_0 + 1, var_138_1)

			return true
		end
	end

	table.insert(ptc_root_locals.healingEntries, var_138_1)

	return true
end

  ptc_root_locals[158] = function()
	if ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
		ptc_root_locals.saveConfigIfReady()
	end
end

  ptc_root_locals[159] = function()
	if ptc_root_locals[9] then
		removeEvent(ptc_root_locals[9])

		ptc_root_locals[9] = nil
	end
end

  ptc_root_locals[160] = function()
	local var_141_0 = ptc_root_locals[9] ~= nil

	ptc_root_locals[159]()

	if var_141_0 then
		ptc_root_locals[158]()
	end
end

  ptc_root_locals[161] = function()
	ptc_root_locals[159]()

	ptc_root_locals[9] = scheduleEvent(function()
		ptc_root_locals[9] = nil

		ptc_root_locals[158]()
	end, 250)
end

  ptc_root_locals[162] = function(arg_144_0)
	local var_144_0 = ptc_root_locals[137](arg_144_0)
	local var_144_1 = ptc_root_locals[136](arg_144_0)
	local var_144_2 = {
		conditionLogic = "and",
		conditionMax = "<=",
		conditionMin = ">=",
		id = arg_144_0.id,
		kind = ptc_root_locals[134](arg_144_0),
		enabled = arg_144_0.enabled ~= false,
		percent = var_144_0,
		spiritMetric = ptc_root_locals[112](arg_144_0.itemId) and var_144_1 or nil,
		whenMetric1 = var_144_1,
		whenMetric2 = var_144_1,
		thresholdMin = ptc_root_locals[122],
		thresholdMax = var_144_0,
		words = ptc_root_locals.normalizeEntryWords(arg_144_0.words)
	}

	if ptc_root_locals.isBlockedHealingPotionId(arg_144_0.itemId) then
		-- block empty
	end

	var_144_2.itemId = arg_144_0.itemId
	var_144_2.subType = arg_144_0.subType

	if ptc_root_locals.isHealingFoodEntry(arg_144_0) then
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
	local var_145_1 = savedEntry.percent or savedEntry.thresholdMax or savedEntry.threshold or ptc_root_locals[125]

	return {
		condition = "<=",
		enabled = savedEntry.enabled ~= false,
		metric = var_145_0,
		whenMetric1 = savedEntry.whenMetric1 or var_145_0,
		whenMetric2 = savedEntry.whenMetric2 or var_145_0,
		conditionLogic = savedEntry.conditionLogic or "and",
		conditionMin = savedEntry.conditionMin or ">=",
		thresholdMin = savedEntry.thresholdMin or ptc_root_locals[122],
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

  ptc_root_locals[163] = function(arg_146_0, arg_146_1)
	if type(arg_146_0) ~= "table" then
		return nil
	end

	if ptc_root_locals.isHealingFoodEntry(arg_146_0) then
		return nil
	end

	if not ptc_root_locals[146](arg_146_0) then
		return nil
	end

	local var_146_0 = ptc_root_locals[132](arg_146_0)
	local var_146_1 = arg_146_0.kind == "potion" and "potion" or ptc_root_locals.normalizeEntryWords(arg_146_0.words) and "spell" or "potion"
	local numericValue = tonumber(arg_146_0.itemId)

	if ptc_root_locals.isBlockedHealingPotionId(numericValue) then
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
		percent = ptc_root_locals[130](arg_146_0.percent or var_146_0.thresholdMax, var_146_1 == "potion" and ptc_root_locals[127] or ptc_root_locals[126]),
		words = ptc_root_locals.normalizeEntryWords(arg_146_0.words),
		itemId = var_146_3,
		subType = arg_146_0.subType,
		useType = arg_146_0.useType,
		parameter = arg_146_0.parameter
	}

	if ptc_root_locals[112](var_146_4.itemId) then
		var_146_4.spiritMetric = HelperHealer.resolveLoadedSpiritMetric(arg_146_0)
	end

	ptc_root_locals[138](var_146_4, var_146_4.percent)

	return var_146_4
end

  ptc_root_locals[164] = function(arg_147_0)
	local var_147_0 = ptc_root_locals.normalizeEntryWords(arg_147_0.words)

	if var_147_0 then
		return var_147_0
	end

	if arg_147_0.itemId and arg_147_0.itemId > 0 then
		local thingType = g_things.getThingType(arg_147_0.itemId, ThingCategoryItem)

		if thingType then
			return ptc_root_locals[80](thingType, arg_147_0.itemId)
		end

		return tostring(arg_147_0.itemId)
	end

	return ""
end

  ptc_root_locals[165] = function(entry)
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

  ptc_root_locals[166] = function(arg_149_0, arg_149_1)
	if not arg_149_0 or not arg_149_1 then
		return
	end

	local var_149_0 = ptc_root_locals[145](arg_149_1)
	local spiritMetric = arg_149_0.spiritMetric

	ptc_root_locals[165](arg_149_0)

	local var_149_2 = ptc_root_locals.normalizeEntryWords(var_149_0.words)

	if var_149_2 then
		arg_149_0.kind = "spell"
		arg_149_0.words = var_149_2
		arg_149_0.itemId = var_149_0.itemId or ptc_root_locals.ACTION_SLOT_SPELL_ITEM_ID
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

		if ptc_root_locals[112](numericValue) then
			arg_149_0.spiritMetric = ptc_root_locals[119](spiritMetric or "HP")
		end
	end

	ptc_root_locals[138](arg_149_0, ptc_root_locals[137](arg_149_0))
end

  ptc_root_locals[167] = function(entry)
	return string.format("%s%%", HelperHealer.getHealingEntryMetricText(entry))
end

  ptc_root_locals[168] = function(arg_151_0, arg_151_1)
	local healingConditionPercentStepper = arg_151_0 and arg_151_0:recursiveGetChildById("healingConditionPercentStepper") or nil

	if not healingConditionPercentStepper then
		return
	end

	healingConditionPercentStepper:show()

	local var_151_1 = ptc_root_locals[137](arg_151_1)
	local numberValue = healingConditionPercentStepper:recursiveGetChildById("numberValue")

	if numberValue then
		numberValue:setText(tostring(var_151_1))
	end

	local btnDec = healingConditionPercentStepper:recursiveGetChildById("btnDec")

	if btnDec then
		btnDec:setEnabled(var_151_1 > ptc_root_locals[122])
	end

	local btnInc = healingConditionPercentStepper:recursiveGetChildById("btnInc")

	if btnInc then
		btnInc:setEnabled(var_151_1 < ptc_root_locals[123])
	end
end

function HelperHealer.updateHealingConditionMetricLabel(row, entry)
	local healingConditionMetricLabel = row and row:recursiveGetChildById("healingConditionMetricLabel") or nil

	if not healingConditionMetricLabel then
		return
	end

	healingConditionMetricLabel:setText(ptc_root_locals[167](entry))
	healingConditionMetricLabel:setTooltip("")
end

function HelperHealer.healingMetricDropdownText(metric)
	return ptc_root_locals[119](metric) == "MP" and "MP%" or "HP%"
end

function HelperHealer.setHealingMetricDropdownOption(dropdown, metric)
	if not dropdown or dropdown:isDestroyed() then
		return
	end

	local var_154_0 = HelperHealer.healingMetricDropdownText(metric)

	dropdown.currentMetric = ptc_root_locals[119](metric)

	dropdown:setTooltip(var_154_0)

	local metricText = dropdown:recursiveGetChildById("metricText")

	if metricText then
		metricText:setText(var_154_0)
	end
end

function HelperHealer.openHealingMetricDropdown(row, dropdown)
	if not row or not dropdown or dropdown:isDestroyed() then
		return true
	end

	local healingEntryId = row.healingEntryId
	local var_155_1 = ptc_root_locals[153](healingEntryId)

	if not var_155_1 or not ptc_root_locals[112](var_155_1.itemId) then
		return true
	end

	ptc_root_locals[52](row)

	local function applyMetric(metric)
		local var_156_0 = ptc_root_locals[153](healingEntryId)

		if not var_156_0 or not ptc_root_locals[112](var_156_0.itemId) then
			return
		end

		var_156_0.spiritMetric = ptc_root_locals[119](metric)

		ptc_root_locals[138](var_156_0, ptc_root_locals[137](var_156_0))
		HelperHealer.setHealingMetricDropdownOption(dropdown, var_156_0.spiritMetric)
		ptc_root_locals[158]()
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

	if ptc_root_locals[112](entry.itemId) then
		if healingConditionMetricLabel then
			healingConditionMetricLabel:hide()
		end

		if healingConditionMetricCombo then
			healingConditionMetricCombo:show()
			HelperHealer.setHealingMetricDropdownOption(healingConditionMetricCombo, ptc_root_locals[136](entry))
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
		local var_160_6 = text:sub(1, var_160_5) .. var_160_1

		label:setText(var_160_6)

		if width >= label:getTextSize().width then
			var_160_4 = var_160_6
			var_160_2 = var_160_5 + 1
		else
			var_160_3 = var_160_5 - 1
		end
	end

	label:setText(var_160_4)
end

  ptc_root_locals[169] = function(arg_161_0, arg_161_1)
	if not arg_161_0 or not arg_161_1 then
		return
	end

	local healingConditionEnabled = arg_161_0:recursiveGetChildById("healingConditionEnabled")

	if healingConditionEnabled then
		local var_161_1 = healingConditionEnabled.onCheckChange

		healingConditionEnabled.onCheckChange = nil

		healingConditionEnabled:setChecked(arg_161_1.enabled ~= false)

		healingConditionEnabled.onCheckChange = var_161_1
	end

	local healingConditionName = arg_161_0:recursiveGetChildById("healingConditionName")

	if healingConditionName then
		local var_161_3 = ptc_root_locals[164](arg_161_1)

		if var_161_3 == "" then
			var_161_3 = ptc_root_locals[134](arg_161_1) == "potion" and tr("Select Potion") or tr("Select Spell")
		end

		healingConditionName:setTooltip(var_161_3)
		HelperHealer.elideHealingLabel(healingConditionName, var_161_3)
	end

	HelperHealer.updateHealingConditionMetricSelector(arg_161_0, arg_161_1)
	ptc_root_locals[168](arg_161_0, arg_161_1)

	local healingConditionActionSlot = arg_161_0:recursiveGetChildById("healingConditionActionSlot")

	if healingConditionActionSlot then
		if ptc_root_locals[146](arg_161_1) and ptc_root_locals[15] then
			ptc_root_locals[15](healingConditionActionSlot, arg_161_1)
		else
			ptc_root_locals.clearSlotData(healingConditionActionSlot)
		end

		local gray = healingConditionActionSlot:getChildById("gray")

		if gray then
			gray:setVisible(ptc_root_locals[68](arg_161_1))
		end

		ptc_root_locals.syncHealingActionSlotLayers(healingConditionActionSlot)
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
		dragGhostName:setText(ptc_root_locals[164](entry))
	end

	local dragGhostCondition = var_165_0:recursiveGetChildById("dragGhostCondition")

	if dragGhostCondition then
		dragGhostCondition:setText(string.format("%s %d", ptc_root_locals[167](entry), ptc_root_locals[137](entry)))
	end

	local dragGhostActionSlot = var_165_0:recursiveGetChildById("dragGhostActionSlot")

	if dragGhostActionSlot then
		if ptc_root_locals[146](entry) and ptc_root_locals[15] then
			ptc_root_locals[15](dragGhostActionSlot, entry)
		else
			ptc_root_locals.clearSlotData(dragGhostActionSlot)
		end

		ptc_root_locals.syncHealingActionSlotLayers(dragGhostActionSlot)
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
		ptc_root_locals.setHealingRowTextColors(row, ptc_root_locals.ZEBRA_FOCUS_TEXT_COLOR)

		return
	end

	row:setOpacity(1)

	if row.zebraColor then
		row:setBackgroundColor(row.zebraColor)
		ptc_root_locals.setHealingRowTextColors(row, ptc_root_locals.ZEBRA_TEXT_COLOR)
	end
end

  ptc_root_locals[170] = function(arg_167_0, arg_167_1, arg_167_2, arg_167_3)
	if not arg_167_0 or not arg_167_1 then
		return
	end

	ptc_root_locals[138](arg_167_1, ptc_root_locals[137](arg_167_1) + arg_167_2)
	ptc_root_locals[168](arg_167_0, arg_167_1)

	if arg_167_3 ~= false then
		ptc_root_locals[158]()
	else
		ptc_root_locals[161]()
	end
end

  ptc_root_locals[171] = function(arg_168_0, arg_168_1, arg_168_2, arg_168_3)
	if not arg_168_0 then
		return
	end

	if g_mouse and g_mouse.bindAutoPress then
		g_mouse.bindAutoPress(arg_168_0, function()
			ptc_root_locals[170](arg_168_1, arg_168_2, arg_168_3, false)
		end, ptc_root_locals[129])
	else
		function arg_168_0.onClick()
			ptc_root_locals[170](arg_168_1, arg_168_2, arg_168_3, false)
		end
	end

	function arg_168_0.onMouseRelease(unusedArgument, unusedArgument, arg_171_2)
		if arg_171_2 == MouseLeftButton then
			ptc_root_locals[160]()

			return false
		end

		return false
	end
end

  ptc_root_locals[172] = function(arg_172_0)
	ptc_root_locals[158]()
	addEvent(function()
		ptc_root_locals[14]()
		ptc_root_locals[155](arg_172_0)
	end)
end

  ptc_root_locals[173] = function(arg_174_0, arg_174_1, arg_174_2, arg_174_3)
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

	if ptc_root_locals[157](arg_174_1.healingEntryId, arg_174_0.healingEntryId, y, arg_174_0.healingEntryKind) then
		ptc_root_locals[172](arg_174_1.healingEntryId)

		return true
	end

	return false
end

  ptc_root_locals[174] = function(arg_175_0, arg_175_1)
	if not arg_175_0 or not arg_175_1 or not arg_175_1.healingEntryId then
		return false
	end

	if arg_175_1.healingEntryKind ~= arg_175_0.healingEntryKind then
		return false
	end

	if ptc_root_locals[157](arg_175_1.healingEntryId, nil, false, arg_175_0.healingEntryKind) then
		ptc_root_locals[172](arg_175_1.healingEntryId)

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

	local var_177_0 = ptc_root_locals[51](draggedWidget.healingEntryId) or draggedWidget
	local parent = var_177_0 and var_177_0:getParent() or nil

	if parent and parent.healingEntryKind == draggedWidget.healingEntryKind and HelperHealer.isMouseInsideHealingDropPanel(parent, mousePos) then
		return parent
	end

	local var_177_2 = draggedWidget.healingEntryKind == "potion" and ptc_root_locals.healingPotionEntriesPanel or ptc_root_locals.healingSpellEntriesPanel

	if var_177_2 and var_177_2.healingEntryKind == draggedWidget.healingEntryKind and HelperHealer.isMouseInsideHealingDropPanel(var_177_2, mousePos) then
		return var_177_2
	end

	if ptc_root_locals.healingEntriesPanel and HelperHealer.isMouseInsideHealingDropPanel(ptc_root_locals.healingEntriesPanel, mousePos) then
		return ptc_root_locals.healingEntriesPanel
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
		return ptc_root_locals[173](var_179_1, draggedWidget, mousePos, var_179_2)
	end

	if var_179_0 then
		return ptc_root_locals[174](var_179_0, draggedWidget)
	end

	if fallbackRow then
		return ptc_root_locals[173](fallbackRow, draggedWidget, mousePos)
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

			ptc_root_locals[11](row)
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

  ptc_root_locals[175] = function(panel, group)
	if not panel then
		return
	end

	panel.healingEntryKind = group

	function panel.onDrop(_, draggedWidget, mousePos)
		return HelperHealer.dropHealingEntryAtMouse(nil, draggedWidget, mousePos)
	end
end

  ptc_root_locals[176] = function(arg_191_0, arg_191_1)
	if not arg_191_0 or not arg_191_1 then
		return
	end

	arg_191_0._helperHealingSlot = true
	arg_191_0._helperAssignPreview = true
	arg_191_0._helperAssignSkipSave = true
	arg_191_0.healingEntryId = arg_191_1.id
	arg_191_0.healingEntryKind = ptc_root_locals[134](arg_191_1)

	function arg_191_0.onHelperPotionAssigned(arg_192_0)
		local var_192_0 = ptc_root_locals[153](arg_192_0.healingEntryId)

		if not var_192_0 then
			return
		end

		var_192_0.kind = "potion"
		var_192_0.pendingAdd = nil

		ptc_root_locals[166](var_192_0, arg_192_0)
		ptc_root_locals[14]()
		ptc_root_locals[155](var_192_0.id)
		ptc_root_locals[158]()
	end

	function arg_191_0.onMousePress(arg_193_0, unusedArgument, arg_193_2)
		if arg_193_2 == MouseRightButton then
			local var_193_0 = ptc_root_locals[54](arg_193_0)

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
			ptc_root_locals[12](arg_194_0)

			return true
		end

		if arg_194_2 == MouseRightButton then
			local var_194_0 = ptc_root_locals[54](arg_194_0)

			if var_194_0 then
				return HelperHealer.queueHealingRowContextMenu(var_194_0)
			end
		end

		return false
	end

	if not ptc_root_locals[69](arg_191_0) then
		local var_191_0 = ptc_root_locals.actionbar()

		if var_191_0 and var_191_0.refreshActionSlotFrameClip then
			var_191_0.refreshActionSlotFrameClip(arg_191_0)
		end
	end

	ptc_root_locals.syncHealingActionSlotLayers(arg_191_0)
end

  ptc_root_locals[177] = function(row, arg_195_1)
	if not row or not arg_195_1 then
		return
	end

	row.healingEntryId = arg_195_1.id
	row.healingEntryKind = ptc_root_locals[134](arg_195_1)

	if row.setDraggable then
		row:setDraggable(true)
	end

	local healingConditionEnabled = row:recursiveGetChildById("healingConditionEnabled")

	if healingConditionEnabled then
		function healingConditionEnabled.onCheckChange(unusedArgument, arg_196_1)
			arg_195_1.enabled = arg_196_1

			ptc_root_locals[158]()
		end

		HelperHealer.bindHealingRowDropForwarder(healingConditionEnabled, row)
		HelperHealer.bindHealingRowContextForwarder(healingConditionEnabled, row)
	end

	local healingConditionActionSlot = row:recursiveGetChildById("healingConditionActionSlot")

	ptc_root_locals[176](healingConditionActionSlot, arg_195_1)
	HelperHealer.bindHealingRowDropForwarder(healingConditionActionSlot, row)
	HelperHealer.bindHealingRowContextForwarder(healingConditionActionSlot, row)
	HelperHealer.bindHealingSlotChildContextForwarders(healingConditionActionSlot, row)

	local healingConditionPercentStepper = row:recursiveGetChildById("healingConditionPercentStepper")

	if healingConditionPercentStepper then
		HelperHealer.bindHealingRowDropForwarder(healingConditionPercentStepper, row)
		HelperHealer.bindHealingRowContextForwarder(healingConditionPercentStepper, row)

		local btnDec = healingConditionPercentStepper:recursiveGetChildById("btnDec")

		ptc_root_locals[171](btnDec, row, arg_195_1, -ptc_root_locals[128])
		HelperHealer.bindHealingRowDropForwarder(btnDec, row)

		local numberBox = healingConditionPercentStepper:recursiveGetChildById("numberBox")

		HelperHealer.bindHealingRowDropForwarder(numberBox, row)

		local btnInc = healingConditionPercentStepper:recursiveGetChildById("btnInc")

		ptc_root_locals[171](btnInc, row, arg_195_1, ptc_root_locals[128])
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
			if ptc_root_locals[156](arg_195_1.id) then
				ptc_root_locals[14]()
				ptc_root_locals[57]()
				ptc_root_locals[158]()
			end
		end
	end

	ptc_root_locals[56](row)

	function row.onMousePress(self, _, mouseButton)
		if mouseButton == MouseRightButton then
			return HelperHealer.queueHealingRowContextMenu(self)
		end

		return false
	end

	function row.onDragEnter(self, mousePos)
		HelperHealer.updateHealingEntryDragGhost(self, ptc_root_locals[153](self.healingEntryId) or arg_195_1, mousePos)
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

 ptc_root_locals[12] = function(arg_205_0)
	if not arg_205_0 then
		return
	end

	local var_205_0 = ptc_root_locals[153](arg_205_0.healingEntryId)

	if not var_205_0 then
		return
	end

	if ptc_root_locals[134](var_205_0) == "potion" then
		HelperHealer.openPotionSelectWindow(arg_205_0)

		return
	end

	ptc_root_locals[79](arg_205_0, ptc_root_locals[78], function(arg_206_0)
		local var_206_0 = ptc_root_locals[153](arg_205_0.healingEntryId)

		if not var_206_0 then
			return
		end

		var_206_0.kind = "spell"
		var_206_0.pendingAdd = nil

		ptc_root_locals[166](var_206_0, arg_206_0 or arg_205_0)
		ptc_root_locals[14]()
		ptc_root_locals[155](var_206_0.id)
		ptc_root_locals[158]()
	end)
end

 ptc_root_locals[14] = function()
	ptc_root_locals[23]()
	ptc_root_locals.resolveHealingEntryPanels()

	if not ptc_root_locals.healingSpellEntriesPanel and not ptc_root_locals.healingPotionEntriesPanel and not ptc_root_locals.healingEntriesPanel then
		return
	end

	ptc_root_locals[175](ptc_root_locals.healingSpellEntriesPanel, "spell")
	ptc_root_locals[175](ptc_root_locals.healingPotionEntriesPanel, "potion")

	if ptc_root_locals.healingSpellEntriesPanel and not ptc_root_locals.healingSpellEntriesPanel:isDestroyed() then
		ptc_root_locals.healingSpellEntriesPanel:destroyChildren()
	end

	if ptc_root_locals.healingPotionEntriesPanel and not ptc_root_locals.healingPotionEntriesPanel:isDestroyed() then
		ptc_root_locals.healingPotionEntriesPanel:destroyChildren()
	end

	if ptc_root_locals.healingEntriesPanel and not ptc_root_locals.healingEntriesPanel:isDestroyed() then
		ptc_root_locals.healingEntriesPanel:destroyChildren()
	end

	for index, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		local var_207_0 = ptc_root_locals[134](ptc_root_local) == "potion" and ptc_root_locals.healingPotionEntriesPanel or ptc_root_locals.healingSpellEntriesPanel

		var_207_0 = var_207_0 or ptc_root_locals.healingEntriesPanel

		if not var_207_0 or var_207_0:isDestroyed() then
			return
		end

		local healingConditionRowWidget = g_ui.createWidget("HealingConditionRow", var_207_0)
		local var_207_2 = index % 2 == 1 and ptc_root_locals.ZEBRA_COLOR_A or ptc_root_locals.ZEBRA_COLOR_B

		healingConditionRowWidget.zebraColor = var_207_2

		healingConditionRowWidget:setBackgroundColor(var_207_2)
		ptc_root_locals[177](healingConditionRowWidget, ptc_root_local)
		ptc_root_locals[169](healingConditionRowWidget, ptc_root_local)
	end

	ptc_root_locals.syncHealingActionButtons()
end

  ptc_root_locals[178] = function(arg_208_0)
	arg_208_0 = arg_208_0 or {}
	ptc_root_locals.healingEntries = {}
	ptc_root_locals[5] = 1

	if type(arg_208_0.healingEntries) == "table" then
		for index, healingEntry in ipairs(arg_208_0.healingEntries) do
			local var_208_0 = ptc_root_locals[163](healingEntry, index)

			if var_208_0 then
				table.insert(ptc_root_locals.healingEntries, var_208_0)

				if var_208_0.id >= ptc_root_locals[5] then
					ptc_root_locals[5] = var_208_0.id + 1
				end
			end
		end
	end

	if #ptc_root_locals.healingEntries == 0 then
		local healingSlots = arg_208_0.healingSlots

		if type(healingSlots) == "table" then
			for index, entry in ipairs(healingSlots) do
				local var_208_2 = ptc_root_locals[163]({
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
					table.insert(ptc_root_locals.healingEntries, var_208_2)

					if var_208_2.id >= ptc_root_locals[5] then
						ptc_root_locals[5] = var_208_2.id + 1
					end
				end
			end
		end
	end

	for iter_208_4 = #ptc_root_locals.healingEntries, 1, -1 do
		local var_208_3 = ptc_root_locals.healingEntries[iter_208_4]

		if ptc_root_locals.isBlockedHealingPotionId(var_208_3.itemId) or ptc_root_locals.isHealingFoodEntry(var_208_3) then
			var_208_3.itemId = nil
			var_208_3.useType = nil

			if not ptc_root_locals[146](var_208_3) then
				table.remove(ptc_root_locals.healingEntries, iter_208_4)
			end
		end
	end
end

  ptc_root_locals[179] = function(arg_209_0, arg_209_1)
	if not ptc_root_locals[148](arg_209_0, arg_209_1) then
		return false
	end

	local var_209_0 = ptc_root_locals.normalizeEntryWords(arg_209_0.words)

	if var_209_0 then
		arg_209_0.words = var_209_0

		return ptc_root_locals[151](arg_209_0)
	end

	local numericValue = tonumber(arg_209_0.itemId)

	if numericValue and numericValue > 0 then
		return ptc_root_locals[152](arg_209_0, arg_209_1)
	end

	return false
end

  ptc_root_locals[180] = function(arg_210_0, arg_210_1)
	return ptc_root_locals[179](ptc_root_locals[145](arg_210_0), arg_210_1)
end

 ptc_root_locals[11] = function(arg_211_0)
	if not arg_211_0 or not arg_211_0.healingEntryId then
		return
	end

	local healingEntryId = arg_211_0.healingEntryId
	local unusedValue, var_211_2 = ptc_root_locals[154](healingEntryId)

	if not var_211_2 then
		return
	end

	ptc_root_locals[52](arg_211_0)
	ptc_root_locals.syncHealingActionButtons()

	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setWidth(150)
	gamePopupMenuWidget:addOption(ptc_root_locals[134](var_211_2) == "potion" and tr("Assign Potion") or tr("Assign Spell"), function()
		addEvent(function()
			local var_213_0 = ptc_root_locals[51](healingEntryId)
			local healingConditionActionSlot = var_213_0 and var_213_0:recursiveGetChildById("healingConditionActionSlot") or nil

			if healingConditionActionSlot and not healingConditionActionSlot:isDestroyed() then
				ptc_root_locals[12](healingConditionActionSlot)
			end
		end)
	end)
	gamePopupMenuWidget:addOption(tr("Remove"), function()
		if ptc_root_locals[156](healingEntryId) then
			ptc_root_locals[14]()
			ptc_root_locals[57]()
			ptc_root_locals[158]()
		end
	end)

	if var_211_2.enabled ~= false then
		gamePopupMenuWidget:addOption(tr("Disable"), function()
			var_211_2.enabled = false

			ptc_root_locals[14]()
			ptc_root_locals[155](healingEntryId)
			ptc_root_locals[158]()
		end)
	else
		gamePopupMenuWidget:addOption(tr("Enable"), function()
			var_211_2.enabled = true

			ptc_root_locals[14]()
			ptc_root_locals[155](healingEntryId)
			ptc_root_locals[158]()
		end)
	end

	gamePopupMenuWidget:display()
end

  ptc_root_locals[181] = function(slot)
	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setWidth(220)

	local var_217_1 = ptc_root_locals.addHealingSlot and slot == ptc_root_locals.addHealingSlot

	gamePopupMenuWidget:addOption("Assign Spell", function()
		addEvent(function()
			if slot and not slot:isDestroyed() then
				ptc_root_locals[79](slot, ptc_root_locals[78], var_217_1 and ptc_root_locals.syncAddHealingConfirmButtons or nil)
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
		ptc_root_locals.clearSlotData(slot)

		if not var_217_1 and ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
			ptc_root_locals.saveConfigIfReady()
		end

		if var_217_1 then
			ptc_root_locals.syncAddHealingConfirmButtons()
		end
	end)
	gamePopupMenuWidget:display()
end

  ptc_root_locals[182] = function(arg_223_0)
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
			ptc_root_locals[181](arg_225_0)

			return true
		end

		if arg_225_2 == MouseLeftButton then
			return true
		end

		return false
	end

	if not ptc_root_locals[69](arg_223_0) then
		local var_223_0 = ptc_root_locals.actionbar()

		if var_223_0 and var_223_0.refreshActionSlotFrameClip then
			var_223_0.refreshActionSlotFrameClip(arg_223_0)
		end
	end

	ptc_root_locals.syncHealingActionSlotLayers(arg_223_0)
end

 ptc_root_locals.syncAddHealingConfirmButtons = function()
	if not ptc_root_locals[6] or ptc_root_locals[6]:isDestroyed() then
		return
	end

	local var_226_0 = ptc_root_locals.addHealingSlot and ptc_root_locals[147](ptc_root_locals.addHealingSlot)
	local addHealingOkButton = ptc_root_locals[6]:recursiveGetChildById("addHealingOkButton")
	local addHealingApplyButton = ptc_root_locals[6]:recursiveGetChildById("addHealingApplyButton")

	if addHealingOkButton then
		addHealingOkButton:setEnabled(var_226_0)
	end

	if addHealingApplyButton then
		addHealingApplyButton:setEnabled(var_226_0)
	end

	ptc_root_locals[182](ptc_root_locals.addHealingSlot)
end

  ptc_root_locals[183] = function()
	if not ptc_root_locals[6] or ptc_root_locals[6]:isDestroyed() then
		return
	end

	ptc_root_locals.addHealingSlot = ptc_root_locals[6]:recursiveGetChildById("addHealingActionSlot")

	if not ptc_root_locals.addHealingSlot then
		return
	end

	ptc_root_locals[182](ptc_root_locals.addHealingSlot)
	ptc_root_locals.stackHealingActionSlotLayers(ptc_root_locals.addHealingSlot)
end

  ptc_root_locals[184] = function()
	if ptc_root_locals.addHealingSlot and not ptc_root_locals.addHealingSlot:isDestroyed() then
		ptc_root_locals.addHealingSlot._helperAssignPreview = nil
		ptc_root_locals.addHealingSlot._helperHealingSlot = nil
	end

	ptc_root_locals.addHealingSlot = nil
	ptc_root_locals[8] = nil

	if ptc_root_locals[6] and not ptc_root_locals[6]:isDestroyed() then
		ptc_root_locals[6]:destroy()
	end

	ptc_root_locals[6] = nil
end

  ptc_root_locals[185] = function(arg_229_0)
	for unusedValue, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		if ptc_root_local.id == arg_229_0 then
			return ptc_root_local
		end
	end

	return nil
end

 ptc_root_locals[15] = function(arg_230_0, arg_230_1)
	if not arg_230_0 or not arg_230_1 then
		return
	end

	ptc_root_locals.clearSlotData(arg_230_0)

	arg_230_0.words = arg_230_1.words
	arg_230_0.itemId = arg_230_1.itemId
	arg_230_0._helperDisplayItemId = arg_230_1.itemId
	arg_230_0.subType = arg_230_1.subType
	arg_230_0.useType = arg_230_1.useType
	arg_230_0.parameter = arg_230_1.parameter

	local var_230_0 = ptc_root_locals.actionbar()
	local var_230_1 = ptc_root_locals.normalizeEntryWords(arg_230_1.words)

	if var_230_1 then
		arg_230_0.words = var_230_1

		if arg_230_0.setItemId then
			arg_230_0:setItemId(ptc_root_locals.ACTION_SLOT_SPELL_ITEM_ID)
		end

		if var_230_0 and var_230_0.loadSpell then
			var_230_0.loadSpell(arg_230_0)
		end

		ptc_root_locals.refreshSlotVisual(arg_230_0)
	elseif arg_230_1.itemId and arg_230_1.itemId > 0 then
		if arg_230_0.setItemId then
			arg_230_0:setItemId(arg_230_1.itemId)
		end

		if var_230_0 and var_230_0.loadObject then
			var_230_0.loadObject(arg_230_0)
		end

		ptc_root_locals.refreshSlotVisual(arg_230_0)
	end

	if arg_230_0 == ptc_root_locals.addHealingSlot then
		ptc_root_locals.syncAddHealingConfirmButtons()
	end
end

  ptc_root_locals[186] = function(arg_231_0)
	if not ptc_root_locals[6] or ptc_root_locals[6]:isDestroyed() then
		return
	end

	ptc_root_locals[6]:setText(arg_231_0)
end

  ptc_root_locals[187] = function(arg_232_0)
	if not ptc_root_locals[6] or ptc_root_locals[6]:isDestroyed() then
		return
	end

	local addHealingWhenMetric1Combo = ptc_root_locals[6]:recursiveGetChildById("addHealingWhenMetric1Combo")
	local addHealingConditionLogicCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionLogicCombo")
	local addHealingWhenMetric2Combo = ptc_root_locals[6]:recursiveGetChildById("addHealingWhenMetric2Combo")
	local addHealingConditionMinCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionMinCombo")
	local addHealingThresholdMinEdit = ptc_root_locals[6]:recursiveGetChildById("addHealingThresholdMinEdit")
	local addHealingConditionMaxCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionMaxCombo")
	local addHealingThresholdMaxEdit = ptc_root_locals[6]:recursiveGetChildById("addHealingThresholdMaxEdit")
	local var_232_7 = arg_232_0 and ptc_root_locals[132](arg_232_0) or nil

	if arg_232_0 and var_232_7 then
		ptc_root_locals[186](tr("Edit Healing"))

		if addHealingWhenMetric1Combo then
			addHealingWhenMetric1Combo:setCurrentOption(ptc_root_locals[120](var_232_7.whenMetric1))
		end

		if addHealingConditionLogicCombo then
			addHealingConditionLogicCombo:setCurrentOption(ptc_root_locals[121](var_232_7.conditionLogic))
		end

		if addHealingWhenMetric2Combo then
			addHealingWhenMetric2Combo:setCurrentOption(ptc_root_locals[120](var_232_7.whenMetric2))
		end

		if addHealingConditionMinCombo then
			addHealingConditionMinCombo:setCurrentOption(var_232_7.conditionMin)
		end

		ptc_root_locals[144](addHealingThresholdMinEdit, var_232_7.thresholdMin)

		if addHealingConditionMaxCombo then
			addHealingConditionMaxCombo:setCurrentOption(var_232_7.conditionMax)
		end

		ptc_root_locals[144](addHealingThresholdMaxEdit, var_232_7.thresholdMax)

		if ptc_root_locals.addHealingSlot then
			ptc_root_locals[15](ptc_root_locals.addHealingSlot, arg_232_0)
		end
	else
		ptc_root_locals[186](tr("Add Healing"))

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

		ptc_root_locals[144](addHealingThresholdMinEdit, ptc_root_locals[124])

		if addHealingConditionMaxCombo then
			addHealingConditionMaxCombo:setCurrentOption("<=")
		end

		ptc_root_locals[144](addHealingThresholdMaxEdit, ptc_root_locals[125])

		if ptc_root_locals.addHealingSlot then
			ptc_root_locals.clearSlotData(ptc_root_locals.addHealingSlot)
		end
	end

	ptc_root_locals.syncAddHealingConfirmButtons()
end

  ptc_root_locals[188] = function(arg_233_0)
	if ptc_root_locals[6] and not ptc_root_locals[6]:isDestroyed() then
		ptc_root_locals[184]()
	end

	ptc_root_locals[8] = arg_233_0
	ptc_root_locals[6] = g_ui.loadUI("assign_healing", g_ui.getRootWidget())

	if not ptc_root_locals[6] then
		ptc_root_locals[8] = nil

		return
	end

	if ptc_root_locals.ctx and ptc_root_locals.ctx.applyWidgetLanguage then
		ptc_root_locals.ctx.applyWidgetLanguage(ptc_root_locals[6])
	end

	ptc_root_locals[183]()

	local var_233_0 = arg_233_0 and ptc_root_locals[185](arg_233_0) or nil

	ptc_root_locals[187](var_233_0)
	ptc_root_locals[6]:raise()
	ptc_root_locals[6]:focus()
end

  ptc_root_locals[189] = function()
	if not ptc_root_locals[6] or ptc_root_locals[6]:isDestroyed() then
		return nil
	end

	local addHealingWhenMetric1Combo = ptc_root_locals[6]:recursiveGetChildById("addHealingWhenMetric1Combo")
	local addHealingConditionLogicCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionLogicCombo")
	local addHealingWhenMetric2Combo = ptc_root_locals[6]:recursiveGetChildById("addHealingWhenMetric2Combo")
	local addHealingConditionMinCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionMinCombo")
	local addHealingThresholdMinEdit = ptc_root_locals[6]:recursiveGetChildById("addHealingThresholdMinEdit")
	local addHealingConditionMaxCombo = ptc_root_locals[6]:recursiveGetChildById("addHealingConditionMaxCombo")
	local addHealingThresholdMaxEdit = ptc_root_locals[6]:recursiveGetChildById("addHealingThresholdMaxEdit")

	if not addHealingWhenMetric1Combo or not addHealingConditionLogicCombo or not addHealingWhenMetric2Combo or not addHealingConditionMinCombo or not addHealingThresholdMinEdit or not addHealingConditionMaxCombo or not addHealingThresholdMaxEdit or not ptc_root_locals.addHealingSlot then
		return nil
	end

	if not ptc_root_locals[147](ptc_root_locals.addHealingSlot) then
		return nil
	end

	local var_234_7 = ptc_root_locals[145](ptc_root_locals.addHealingSlot)

	return {
		enabled = true,
		whenMetric1 = ptc_root_locals[119](ptc_root_locals[118](addHealingWhenMetric1Combo)),
		conditionLogic = ptc_root_locals[121](ptc_root_locals[118](addHealingConditionLogicCombo)),
		whenMetric2 = ptc_root_locals[119](ptc_root_locals[118](addHealingWhenMetric2Combo)),
		conditionMin = ptc_root_locals[131](ptc_root_locals[118](addHealingConditionMinCombo)),
		thresholdMin = ptc_root_locals[143](addHealingThresholdMinEdit, ptc_root_locals[124]),
		conditionMax = ptc_root_locals[131](ptc_root_locals[118](addHealingConditionMaxCombo)),
		thresholdMax = ptc_root_locals[143](addHealingThresholdMaxEdit, ptc_root_locals[125]),
		words = var_234_7.words,
		itemId = var_234_7.itemId,
		subType = var_234_7.subType,
		useType = var_234_7.useType,
		parameter = var_234_7.parameter
	}
end

  ptc_root_locals[190] = function(arg_235_0)
	addEvent(function()
		local var_236_0 = ptc_root_locals[51](arg_235_0)

		if not var_236_0 then
			return
		end

		ptc_root_locals[52](var_236_0)

		local healingConditionActionSlot = var_236_0:recursiveGetChildById("healingConditionActionSlot")

		if healingConditionActionSlot then
			ptc_root_locals[12](healingConditionActionSlot)
		end
	end)
end

  ptc_root_locals[191] = function(arg_237_0)
	ptc_root_locals[23]()

	local var_237_0 = {
		pendingAdd = true,
		enabled = true,
		id = ptc_root_locals[5],
		kind = arg_237_0 == "potion" and "potion" or "spell"
	}

	ptc_root_locals[5] = ptc_root_locals[5] + 1

	ptc_root_locals[138](var_237_0, ptc_root_locals[135](var_237_0))
	table.insert(ptc_root_locals.healingEntries, var_237_0)
	ptc_root_locals[14]()
	ptc_root_locals[190](var_237_0.id)

	return var_237_0
end

function HelperHealer.cancelPendingHealingEntryAssign()
	ptc_root_locals[23]()

	for iter_238_0 = #ptc_root_locals.healingEntries, 1, -1 do
		local var_238_0 = ptc_root_locals.healingEntries[iter_238_0]

		if var_238_0.pendingAdd and not ptc_root_locals[146](var_238_0) then
			table.remove(ptc_root_locals.healingEntries, iter_238_0)
			ptc_root_locals[14]()
			ptc_root_locals[57]()
			ptc_root_locals[158]()

			return true
		end
	end

	return false
end

function HelperHealer.openAddHealingSpellWindow()
	ptc_root_locals[191]("spell")
end

function HelperHealer.openAddHealingPotionWindow()
	ptc_root_locals[191]("potion")
end

function HelperHealer.openAddHealingWindow()
	HelperHealer.openAddHealingSpellWindow()
end

function HelperHealer.openEditHealingWindow()
	local var_242_0 = ptc_root_locals[50]()

	if not var_242_0 then
		return
	end

	ptc_root_locals[188](var_242_0)
end

function HelperHealer.closeAddHealingWindow()
	ptc_root_locals[184]()
end

  ptc_root_locals[192] = function(arg_244_0)
	local var_244_0 = ptc_root_locals[189]()

	if not var_244_0 then
		return false
	end

	local id = ptc_root_locals[8]

	if ptc_root_locals[8] then
		local var_244_2 = ptc_root_locals[185](ptc_root_locals[8])

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
		var_244_0.id = ptc_root_locals[5]
		ptc_root_locals[5] = ptc_root_locals[5] + 1

		table.insert(ptc_root_locals.healingEntries, var_244_0)

		ptc_root_locals[8] = var_244_0.id
		id = var_244_0.id
	end

	ptc_root_locals[14]()

	if ptc_root_locals.ctx and ptc_root_locals.ctx.saveConfig then
		ptc_root_locals.saveConfigIfReady()
	end

	if arg_244_0 then
		ptc_root_locals[184]()
	end

	if id then
		addEvent(function()
			ptc_root_locals[155](id)
		end)
	else
		ptc_root_locals.syncHealingActionButtons()
	end

	return true
end

function HelperHealer.addHealingEntryOk()
	ptc_root_locals[192](true)
end

function HelperHealer.addHealingEntryApply()
	ptc_root_locals[192](false)
end

function HelperHealer.addHealingEntryConfirm()
	HelperHealer.addHealingEntryOk()
end

function HelperHealer.removeSelectedEntry()
	local var_249_0 = ptc_root_locals[50]()

	if not var_249_0 then
		return
	end

	if ptc_root_locals[156](var_249_0) then
		ptc_root_locals[14]()
		ptc_root_locals[57]()
		ptc_root_locals[158]()
	end
end

function HelperHealer.onAddHealingThresholdChange(edit)
	if not edit then
		return
	end

	local text = edit:getText() or ""
	local var_250_1 = ptc_root_locals[141](text)

	if var_250_1 == "" then
		if text ~= "" then
			edit:setText("")
		end

		return
	end

	local numericValue = tonumber(var_250_1)

	if not numericValue or numericValue < ptc_root_locals[122] then
		edit:setText(tostring(ptc_root_locals[122]))

		return
	end

	if numericValue > ptc_root_locals[123] then
		edit:setText(tostring(ptc_root_locals[123]))

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
	local var_251_1 = ptc_root_locals[125]

	if edit:getId() == "addHealingThresholdMinEdit" then
		var_251_1 = ptc_root_locals[124]
	end

	if text == "" then
		edit:setText(tostring(var_251_1))

		return
	end

	local var_251_2 = ptc_root_locals[130](text, var_251_1)

	if tostring(var_251_2) ~= text then
		edit:setText(tostring(var_251_2))
	end
end

  ptc_root_locals[193] = function(arg_252_0)
	return ptc_root_locals[134](arg_252_0) == "spell" and ptc_root_locals.normalizeEntryWords(arg_252_0.words) ~= nil
end

  ptc_root_locals[194] = function(arg_253_0)
	local var_253_0 = arg_253_0 and tonumber(arg_253_0.itemId)

	return ptc_root_locals[134](arg_253_0) == "potion" and var_253_0 and var_253_0 > 0 and arg_253_0.useType ~= nil and arg_253_0.useType ~= ""
end

  ptc_root_locals[195] = function(arg_254_0)
	if not ptc_root_locals[194](arg_254_0) then
		return false
	end

	if ptc_root_locals[112](arg_254_0.itemId) then
		return ptc_root_locals[136](arg_254_0) == "MP"
	end

	return ptc_root_locals[110](arg_254_0.itemId)
end

  ptc_root_locals[196] = function(arg_255_0)
	if not ptc_root_locals[194](arg_255_0) then
		return false
	end

	if ptc_root_locals[112](arg_255_0.itemId) then
		return ptc_root_locals[136](arg_255_0) == "HP"
	end

	return not ptc_root_locals[110](arg_255_0.itemId)
end

  ptc_root_locals[197] = function(entryHasAction, unusedArgument)
	local config = {}

	for _, copy in ipairs(ptc_root_locals.healingEntries) do
		if copy.enabled ~= false and ptc_root_locals[146](copy) and entryHasAction(copy) then
			table.insert(config, {
				entry = copy,
				index = _,
				percent = ptc_root_locals[137](copy)
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

  ptc_root_locals[198] = function(arg_258_0, arg_258_1, arg_258_2)
	for unusedValue, entry in ipairs(ptc_root_locals[197](arg_258_1, arg_258_2)) do
		local entry = entry.entry

		if (arg_258_2 and HelperHealer.entryMetricPercentConditionMet(entry, arg_258_0, arg_258_2) or ptc_root_locals[139](entry, arg_258_0)) and ptc_root_locals[179](entry, arg_258_0) then
			return true
		end
	end

	return false
end

  ptc_root_locals[199] = function()
	local widget = ptc_root_locals.ctx and ptc_root_locals.ctx.getWidget("enableHealingCheckBox")

	return widget and widget:isChecked() or false
end

  ptc_root_locals[200] = function(arg_260_0, arg_260_1)
	local var_260_0

	for unusedValue, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		if ptc_root_local.enabled ~= false and ptc_root_locals[193](ptc_root_local) and ptc_root_locals[139](ptc_root_local, arg_260_0) and ptc_root_locals[113](ptc_root_local.words, arg_260_0.player, true) and (not arg_260_1 or not ptc_root_locals[114](ptc_root_local.words)) then
			local spellByWords = Spells.getSpellByWords(ptc_root_local.words)
			local numericValue = tonumber(spellByWords.mana) or 0

			var_260_0 = math.min(var_260_0 or numericValue, numericValue)
		end
	end

	return var_260_0
end

function HelperHealer.shouldYieldToHealing(arg_261_0, arg_261_1)
	if not arg_261_0 or not ptc_root_locals[199]() then
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

	for unusedValue, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		if ptc_root_local.enabled ~= false and (ptc_root_locals[193](ptc_root_local) or ptc_root_locals[196](ptc_root_local) or ptc_root_locals[195](ptc_root_local)) and ptc_root_locals[139](ptc_root_local, var_261_4) and ptc_root_locals[148](ptc_root_local, var_261_4) then
			return true
		end
	end

	local var_261_5 = ptc_root_locals[200](var_261_4)

	if var_261_5 ~= nil then
		local var_261_6 = g_clock.millis()

		for unusedValue, spell in pairs(ptc_root_locals.multiUseExDelay.spells) do
			if var_261_6 < spell then
				return true
			end
		end
	end

	return var_261_5 ~= nil and var_261_5 > mana - (tonumber(arg_261_1) or 0)
end

function HelperHealer.runTick(state)
	ptc_root_locals[23]()

	if not state or not state.player or not ptc_root_locals[199]() then
		return false
	end

	local var_262_0 = false
	local var_262_1 = ptc_root_locals[200](state, true)
	local mana = var_262_1 and var_262_1 > state.player:getMana()

	if not mana then
		ptc_root_locals.multiUseExDelay.lastHealthPotionWasPlain = false
	end

	local var_262_3 = mana and ptc_root_locals.multiUseExDelay.lastHealthPotionWasPlain and ptc_root_locals[198](state, ptc_root_locals[195], "MP")

	if var_262_3 then
		var_262_0 = true
	end

	local var_262_4 = not var_262_3 and ptc_root_locals[198](state, ptc_root_locals[196], "HP")

	if var_262_4 then
		var_262_0 = true
	end

	if ptc_root_locals[198](state, ptc_root_locals[193]) then
		var_262_0 = true
	end

	if not var_262_4 and not var_262_3 and ptc_root_locals[198](state, ptc_root_locals[195], "MP") then
		var_262_0 = true
	end

	return var_262_0
end

function HelperHealer.init(pctx)
	ptc_root_locals.ctx = pctx

	ptc_root_locals[23]()
	ptc_root_locals[106]()
	ptc_root_locals.resolveHealingEntryPanels()
	ptc_root_locals.forEachHealingEntryPanel(function(arg_264_0)
		connect(arg_264_0, {
			onChildFocusChange = function()
				ptc_root_locals.syncHealingActionButtons()
			end
		})
	end)
	ptc_root_locals.syncHealingActionButtons()
end

function HelperHealer.onGameStart()
	ptc_root_locals[106]()
end

function HelperHealer.onShow()
	ptc_root_locals[14]()
	ptc_root_locals[57]()
end

function HelperHealer.onHide()
	ptc_root_locals[160]()
	HelperHealer.destroyHealingEntryDragGhost()
	ptc_root_locals.closeHelperItemAssignInternal()
	ptc_root_locals[184]()
	ptc_root_locals[57]()
end

function HelperHealer.clearListSelection()
	ptc_root_locals[57]()
end

function HelperHealer.terminate()
	ptc_root_locals[160]()
	HelperHealer.destroyHealingEntryDragGhost()
	ptc_root_locals.closeHelperItemAssignInternal()
	ptc_root_locals[184]()
	ptc_root_locals[107]()
	ptc_root_locals[102]()
end

function HelperHealer.collectConfig(config)
	ptc_root_locals[23]()

	config.healingEntries = {}
	config.healingSlots = {}

	for unusedValue, ptc_root_local in ipairs(ptc_root_locals.healingEntries) do
		local var_271_0 = ptc_root_locals[162](ptc_root_local)

		if ptc_root_locals[146](var_271_0) then
			table.insert(config.healingEntries, var_271_0)
			table.insert(config.healingSlots, HelperHealer.copyLegacyHealingSlot(var_271_0))
		end
	end
end

function HelperHealer.loadFromConfig(config)
	ptc_root_locals[178](config)
	ptc_root_locals[23]()
	scheduleEvent(function()
		local var_273_0, var_273_1 = pcall(ptc_root_locals[14])

		if not var_273_0 and g_logger and g_logger.warning then
			g_logger.warning("[HelperHealer] refreshHealingListUI after load failed: " .. tostring(var_273_1))
		end
	end, 50)
end

function HelperHealer.onEnableHealingChange(unusedArgument, unusedArgument)
	ptc_root_locals.saveConfigIfReady()
end
