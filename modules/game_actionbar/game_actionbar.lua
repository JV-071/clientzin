-- Root locals stored in a lexical table to fit the LuaJIT 200-local limit.
local actionbarState = {}
HOTKEY_USE = nil
HOTKEY_USEONSELF = 1
HOTKEY_USEONTARGET = 2
HOTKEY_USEWITH = 3

 actionbarState.maxSlots = 50
 actionbarState.SIDE_BAR_TOTAL_SLOTS = 36
 actionbarState.SIDE_BAR_VISIBLE_SLOTS = 18
 actionbarState[3] = 36
 actionbarState[4] = 22 + (actionbarState.SIDE_BAR_VISIBLE_SLOTS * 34 + (actionbarState.SIDE_BAR_VISIBLE_SLOTS - 1) * 3) + 22

SIDE_BAR_WIDTH = 36
SIDE_BAR_SPACING = 0
actionBarLocks = {
	right = false,
	left = false,
	bottom = false
}
isLocked = false
NUM_BARS = 9
BAR_BOTTOM_1 = 1
BAR_BOTTOM_2 = 2
BAR_BOTTOM_3 = 3
BAR_LEFT_1 = 4
BAR_LEFT_2 = 5
BAR_LEFT_3 = 6
BAR_RIGHT_1 = 7
BAR_RIGHT_2 = 8
BAR_RIGHT_3 = 9
actionBars = {}
actionBarPanels = {}
actionBar = nil
actionBarPanel = nil
actionBarPreparedPreset = nil
actionBarPreloadEvent = nil
bottomPanel = nil
bottomLockButton = nil
slotToEdit = nil
spellAssignWindow = nil
spellsPanel = nil
spellAssignPreferredSpellOverride = nil

 actionbarState.spellAssignFocusParameterOnOpen = false

externalAssignSlot = nil
externalAssignSlotId = nil
spellAssignListFilter = nil
onExternalSpellAssignApplied = nil
onExternalObjectAssignApplied = nil
onExternalTextAssignApplied = nil
cyclopediaSpellAssign = nil
cyclopediaSpellAssignReturnWindow = nil
textAssignWindow = nil
equipmentAssignWindow = nil
equipmentAssignIconWindow = nil

 actionbarState.equipmentAssignDraft = nil
 actionbarState.equipmentAssignPickInvSlot = nil
 actionbarState.equipmentAssignHiddenForPick = false
 actionbarState.equipmentAssignHiddenForIconPicker = false
 actionbarState.equipmentAssignIconIndex = 0
 actionbarState.equipmentAssignDescription = ""
 actionbarState.equipmentAssignIconPickerRevertIndex = 0
 actionbarState.equipmentAssignIconPickerRevertDescription = ""
 actionbarState.equipmentAssignTypeIndex = 0
 actionbarState.equipmentAssignTypePickerRevertIndex = 0
 actionbarState.equipmentAssignTypeRadioGroup = nil
 actionbarState.EQUIPMENT_TYPE_ICON_BASE = "/game_cyclopedia/images/bestiary/icons/monster-icon-"
 actionbarState.EQUIPMENT_TYPE_OPTIONS = {
	"energy-resist",
	"earth-resist",
	"fire-resist",
	"lifedrain-resist",
	"manadrain-resist",
	"ice-resist",
	"holy-resist",
	"death-resist",
	"spellcaster",
	"armor",
	"physical-resist",
	"melee",
	"ranged",
	"speed",
	"noattack"
}
 actionbarState.EQUIPMENT_TYPE_MAX_INDEX = #actionbarState.EQUIPMENT_TYPE_OPTIONS
 actionbarState.EQUIPMENT_SLOT_DECOR_ICON_SIZE = {
	width = 9,
	height = 9
}
 actionbarState.EQUIPMENT_ICONS_SHEET = "/images/game/spells/equipment-icons"
 actionbarState.EQUIPMENT_ICON_SIZE = 32
 actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX = 0
 actionbarState.EQUIPMENT_ICON_PICKER_COUNT = 6
 actionbarState.EQUIPMENT_ICON_MAX_INDEX = actionbarState.EQUIPMENT_ICON_PICKER_COUNT
 actionbarState[26] = nil
 actionbarState[27] = nil
 actionbarState.resolvePickItemAtMouse = nil
 actionbarState[29] = nil
 actionbarState.isEquippableActionBarItem = nil
 actionbarState[31] = nil
 actionbarState[32] = nil
 actionbarState.normalizeEquipmentsFromSetting = nil
 actionbarState.startEquipmentSetActionCooldownVisual = nil
 actionbarState.refreshAllSmartModeSlots = nil
 actionbarState[36] = nil
 actionbarState.updateSmartModeAssignCheckboxState = nil

objectAssignWindow = nil
objectAssignHiddenForPick = false
mouseGrabberWidget = nil
actionRadioGroup = nil
editHotkeyWindow = nil
editHotkeyOverlay = nil
editHotkeyPendingCombo = ""
hotkeyPauseDepth = 0
actionBarCorruptHotkeySeen = false
actionBarBatchDepth = 0
missedSlotToEdit = nil
itemDragRetry = nil
slotReassign = nil
multiActionEditIndex = nil
cooldown = {}
groupCooldown = {}
GIFT_OF_LIFE_PASSIVE_ID = 1
PASSIVE_COOLDOWN_KEY = "passive:" .. GIFT_OF_LIFE_PASSIVE_ID
PASSIVE_COOLDOWN_PROGRESS_ID = "progressPassive" .. GIFT_OF_LIFE_PASSIVE_ID
passiveCooldownData = nil
virtuesYellowBorderSpellIds = {}

 actionbarState.managedVirtueYellowBorderSpellIds = {}
 actionbarState.managedVirtueYellowBorderSelection = {}

VIRTUE_YELLOW_BORDER_IMAGE = "/assets/images/game/actionbar/border_activespell"

 actionbarState.ACTIONBAR_ITEM_MULTI_CD_KEY = "itemShared"
 actionbarState.slotGrayRefreshEvent = nil

slotGrayFullRefreshPending = false
slotGrayStatsPendingSlots = {}
slotGrayInventoryRefreshPending = false

function isVirtueYellowBorderActive(spellId)
	if not spellId or spellId <= 0 then
		return false
	end

	if actionbarState.managedVirtueYellowBorderSpellIds[spellId] then
		return actionbarState.managedVirtueYellowBorderSelection[spellId] == true
	end

	return virtuesYellowBorderSpellIds[spellId] == true
end

  actionbarState.resolveBorderSpellId = function(incomingId)
	if not incomingId or incomingId <= 0 then
		return nil
	end

	local spell = Spells.getSpellByClientId(incomingId)

	if spell then
		return spell.id
	end

	return incomingId
end

  actionbarState.registerVirtueBorderSpellId = function(arg_3_0)
	local var_3_0 = actionbarState.resolveBorderSpellId(arg_3_0)

	if var_3_0 then
		virtuesYellowBorderSpellIds[var_3_0] = true
	end
end

function slotSpellMatchesVirtueBorder(spell)
	return spell and isVirtueYellowBorderActive(spell.id)
end

function refreshActionSlotVirtueBorder(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local overlay = slot:recursiveGetChildById("activeSpell")

	if not overlay then
		return
	end

	local show = false

	if slot.words and slot.words ~= "" then
		local spell = Spells.getSpellByWords(slot.words)

		if slotSpellMatchesVirtueBorder(spell) then
			show = true
		end
	end

	if show then
		overlay:setImageSource(VIRTUE_YELLOW_BORDER_IMAGE)
		overlay:show()

		if overlay.raise then
			overlay:raise()
		end
	else
		overlay:hide()
	end
end

function refreshAllVirtueYellowBorders()
	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				refreshActionSlotVirtueBorder(slot)
			end
		end
	end

	if refreshMultiActionPanelVirtueBorders then
		refreshMultiActionPanelVirtueBorders()
	end
end

function onVirtuesYellowBorder(spellIds)
	virtuesYellowBorderSpellIds = {}

	if spellIds then
		if type(spellIds) == "table" then
			for unusedValue, entry in ipairs(spellIds) do
				actionbarState.registerVirtueBorderSpellId(entry)
			end
		elseif type(spellIds) == "number" then
			actionbarState.registerVirtueBorderSpellId(spellIds)
		end
	end

	refreshAllVirtueYellowBorders()

	local game_spelllist = modules.game_spelllist

	if game_spelllist and game_spelllist.refreshVirtueYellowBorders then
		game_spelllist.refreshVirtueYellowBorders()
	end
end

function setManagedVirtueYellowBorderSpellIds(selectedSpellIds, managedSpellIds)
	actionbarState.managedVirtueYellowBorderSpellIds = {}
	actionbarState.managedVirtueYellowBorderSelection = {}

	if type(managedSpellIds) == "table" then
		for unusedValue, entry in ipairs(managedSpellIds) do
			local var_8_0 = actionbarState.resolveBorderSpellId(entry)

			if var_8_0 then
				actionbarState.managedVirtueYellowBorderSpellIds[var_8_0] = true
			end
		end
	end

	if type(selectedSpellIds) == "table" then
		for unusedValue, entry in ipairs(selectedSpellIds) do
			local var_8_1 = actionbarState.resolveBorderSpellId(entry)

			if var_8_1 and actionbarState.managedVirtueYellowBorderSpellIds[var_8_1] then
				actionbarState.managedVirtueYellowBorderSelection[var_8_1] = true
			end
		end
	end

	refreshAllVirtueYellowBorders()

	local game_spelllist = modules.game_spelllist

	if game_spelllist and game_spelllist.refreshVirtueYellowBorders then
		game_spelllist.refreshVirtueYellowBorders()
	end
end

modules.game_actionbar = modules.game_actionbar or {}
modules.game_actionbar.slotSpellMatchesVirtueBorder = slotSpellMatchesVirtueBorder
modules.game_actionbar.isVirtueYellowBorderActive = isVirtueYellowBorderActive
modules.game_actionbar.refreshAllVirtueYellowBorders = refreshAllVirtueYellowBorders
modules.game_actionbar.setManagedVirtueYellowBorderSpellIds = setManagedVirtueYellowBorderSpellIds

 actionbarState.syncSlotHotkeyMirror = nil

  actionbarState.actionSlotItemTier = function(slot)
	if g_game.getFeature(GameThingUpgradeClassification) then
		local stored = slot.getTier

		if type(stored) == "number" then
			return stored
		end
	end

	return 0
end

  actionbarState.playerHasActionBarItem = function(arg_10_0)
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return true
	end

	if not arg_10_0.itemId or arg_10_0.itemId <= 0 then
		return true
	end

	return getActionBarInventoryDisplayCount(arg_10_0.itemId, actionbarState.actionSlotItemTier(arg_10_0), localPlayer) > 0
end

 actionbarState.EQUIPMENT_ASSIGN_BACKPACK_SLOT = InventorySlotBack

  actionbarState.isEquipmentAssignVisualBackpackSlot = function(arg_11_0)
	return arg_11_0 == actionbarState.EQUIPMENT_ASSIGN_BACKPACK_SLOT
end

  actionbarState.isActionSlotEquip = function(slot)
	return slot and slot.useType == "equip"
end

  actionbarState.normalizeEquipmentIconIndex = function(arg_13_0)
	if type(arg_13_0) ~= "number" then
		return actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX
	end

	return math.max(actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX, math.min(actionbarState.EQUIPMENT_ICON_MAX_INDEX, math.floor(arg_13_0)))
end

  actionbarState.isEquipmentIconDeterminedOnSlot = function(arg_14_0)
	return type(arg_14_0.equipmentIconIndex) == "number" and actionbarState.normalizeEquipmentIconIndex(arg_14_0.equipmentIconIndex) > actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX
end

  actionbarState[52] = function(entry)
	if not actionbarState.isActionSlotEquip(entry) then
		return false
	end

	if entry.equipments ~= nil or actionbarState.isEquipmentIconDeterminedOnSlot(entry) then
		return true
	end

	return entry.itemId and entry.itemId > 0
end

  actionbarState.equipmentEntryFromItem = function(item)
	if not item then
		return nil
	end

	local entry = {
		itemId = item:getId()
	}

	if g_game.getFeature(GameThingUpgradeClassification) then
		entry.getTier = item:getTier()
	end

	if item:isFluidContainer() then
		entry.subType = item:getSubType()
	end

	return entry
end

  actionbarState.equipmentEntryToItem = function(entry)
	if not entry or not entry.itemId or entry.itemId <= 0 then
		return nil
	end

	local item = Item.create(entry.itemId)

	if not item then
		return nil
	end

	if entry.getTier then
		item:setTier(entry.getTier)
	end

	if entry.subType then
		item:setSubType(entry.subType)
	end

	return item
end

  actionbarState.equipmentAssignDisplayEntry = function(panel)
	if not panel then
		return nil
	end

	local order = {
		InventorySlotBody,
		InventorySlotHead,
		InventorySlotLeg,
		InventorySlotFeet,
		InventorySlotNeck,
		InventorySlotLeft,
		InventorySlotRight,
		InventorySlotFinger,
		InventorySlotAmmo
	}

	for _, invSlot in ipairs(order) do
		local entry = panel[invSlot]

		if entry and entry.itemId and entry.itemId > 0 then
			return entry
		end
	end

	for _, entry in pairs(panel) do
		if entry and entry.itemId and entry.itemId > 0 then
			return entry
		end
	end

	return nil
end

  actionbarState.copyEquipmentAssignDraft = function(panel)
	actionbarState.equipmentAssignDraft = {}

	if not panel then
		return
	end

	for _, slot in pairs(panel) do
		if not actionbarState.isEquipmentAssignVisualBackpackSlot(_) and slot and slot.itemId and slot.itemId > 0 then
			actionbarState.equipmentAssignDraft[_] = {
				itemId = slot.itemId,
				getTier = slot.getTier,
				subType = slot.subType
			}
		end
	end
end

  actionbarState.isActionSlotEquipmentPreset = function(arg_20_0)
	if not actionbarState.isActionSlotEquip(arg_20_0) then
		return false
	end

	if arg_20_0.equipments ~= nil then
		return true
	end

	return actionbarState.isEquipmentIconDeterminedOnSlot(arg_20_0)
end

  actionbarState.isEquipmentAssignIconDetermined = function()
	return actionbarState.normalizeEquipmentIconIndex(actionbarState.equipmentAssignIconIndex) > actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX
end

  actionbarState.normalizeEquipmentTypeIndex = function(arg_22_0)
	if type(arg_22_0) ~= "number" then
		return 0
	end

	return math.max(0, math.min(actionbarState.EQUIPMENT_TYPE_MAX_INDEX, math.floor(arg_22_0)))
end

  actionbarState.destroyEquipmentAssignTypeRadioGroup = function()
	if actionbarState.equipmentAssignTypeRadioGroup then
		actionbarState.equipmentAssignTypeRadioGroup:destroy()

		actionbarState.equipmentAssignTypeRadioGroup = nil
	end
end

 actionbarState.refreshAssignActionSlotPreview = nil

  actionbarState.setupEquipmentAssignTypePicker = function()
	if not equipmentAssignIconWindow or equipmentAssignIconWindow:isDestroyed() then
		return
	end

	local typeButtonsPanel = equipmentAssignIconWindow:recursiveGetChildById("typeButtonsPanel")

	if not typeButtonsPanel then
		return
	end

	actionbarState.destroyEquipmentAssignTypeRadioGroup()
	typeButtonsPanel:destroyChildren()

	actionbarState.equipmentAssignTypeRadioGroup = UIRadioGroup.create()

	local var_24_1

	for typeIndex = 0, actionbarState.EQUIPMENT_TYPE_MAX_INDEX do
		local equipmentTypeButtonWidget = g_ui.createWidget("EquipmentTypeButton", typeButtonsPanel)

		equipmentTypeButtonWidget.typeIndex = typeIndex

		if typeIndex > 0 then
			local var_24_3 = actionbarState.EQUIPMENT_TYPE_OPTIONS[typeIndex]

			if var_24_3 then
				local typeIcon = equipmentTypeButtonWidget:getChildById("typeIcon")

				typeIcon:setImageSource(actionbarState.EQUIPMENT_TYPE_ICON_BASE .. var_24_3)
				typeIcon:show()
			end
		end

		actionbarState.equipmentAssignTypeRadioGroup:addWidget(equipmentTypeButtonWidget)

		if typeIndex == actionbarState.equipmentAssignTypeIndex then
			var_24_1 = equipmentTypeButtonWidget
		end
	end

	if var_24_1 then
		actionbarState.equipmentAssignTypeRadioGroup:selectWidget(var_24_1, true)
	end

	 actionbarState.equipmentAssignTypeRadioGroup.onSelectionChange = function(unusedArgument, arg_25_1)
		if arg_25_1 and arg_25_1.typeIndex ~= nil then
			actionbarState.equipmentAssignTypeIndex = arg_25_1.typeIndex
		else
			actionbarState.equipmentAssignTypeIndex = 0
		end

		actionbarState.refreshAssignActionSlotPreview()
	end
end

  actionbarState.equipmentIconClip = function(arg_26_0)
	local var_26_0 = actionbarState.normalizeEquipmentIconIndex(arg_26_0)

	return string.format("%d 0 %d %d", var_26_0 * actionbarState.EQUIPMENT_ICON_SIZE, actionbarState.EQUIPMENT_ICON_SIZE, actionbarState.EQUIPMENT_ICON_SIZE)
end

  actionbarState.applyEquipmentIconToWidget = function(arg_27_0, arg_27_1)
	if not arg_27_0 or arg_27_0:isDestroyed() then
		return
	end

	arg_27_0:setImageSource(actionbarState.EQUIPMENT_ICONS_SHEET)
	arg_27_0:setImageSize(tosize("32 32"))
	arg_27_0:setImageClip(actionbarState.equipmentIconClip(arg_27_1))
	arg_27_0:show()
end

  actionbarState.equipmentTypeIconSource = function(arg_28_0)
	arg_28_0 = actionbarState.normalizeEquipmentTypeIndex(arg_28_0)

	if arg_28_0 <= 0 then
		return nil
	end

	local var_28_0 = actionbarState.EQUIPMENT_TYPE_OPTIONS[arg_28_0]

	if not var_28_0 then
		return nil
	end

	return actionbarState.EQUIPMENT_TYPE_ICON_BASE .. var_28_0
end

  actionbarState.ensureEquipmentTypeIconWidget = function(parentWidget)
	if not parentWidget or parentWidget:isDestroyed() then
		return nil
	end

	local equipmentTypeIcon = parentWidget:getChildById("equipmentTypeIcon")

	if equipmentTypeIcon and not equipmentTypeIcon:isDestroyed() then
		return equipmentTypeIcon
	end

	local uIWidgetWidget = g_ui.createWidget("UIWidget", parentWidget)

	uIWidgetWidget:setId("equipmentTypeIcon")
	uIWidgetWidget:setSize(actionbarState.EQUIPMENT_SLOT_DECOR_ICON_SIZE)
	uIWidgetWidget:addAnchor(AnchorBottom, "parent", AnchorBottom)
	uIWidgetWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
	uIWidgetWidget:setMarginLeft(1)
	uIWidgetWidget:setMarginBottom(1)
	uIWidgetWidget:setPhantom(true)
	uIWidgetWidget:setFocusable(false)
	uIWidgetWidget:setVisible(false)

	return uIWidgetWidget
end

function refreshActionSlotEquipmentTypeIcon(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local var_30_0 = actionbarState.ensureEquipmentTypeIconWidget(slot)

	if not var_30_0 then
		return
	end

	if not actionbarState.isActionSlotEquipmentPreset(slot) then
		var_30_0:setVisible(false)

		return
	end

	local imageSourcePath = actionbarState.equipmentTypeIconSource(slot.equipmentTypeIndex)

	if not imageSourcePath then
		var_30_0:setVisible(false)

		return
	end

	var_30_0:setImageSource(imageSourcePath)
	var_30_0:setImageSize(actionbarState.EQUIPMENT_SLOT_DECOR_ICON_SIZE)

	local multiIcon = slot:getChildById("multiIcon")

	if multiIcon and not multiIcon:isDestroyed() and multiIcon:isVisible() then
		var_30_0:setMarginLeft(12)
	else
		var_30_0:setMarginLeft(1)
	end

	var_30_0:show()

	if var_30_0.raise then
		var_30_0:raise()
	end
end

  actionbarState.refreshActionSlotEquipmentDecorations = function(slot)
	refreshActionSlotEquipmentTypeIcon(slot)
end

function loadEquipmentSetDisplay(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local spellIcon = slot:getChildById("spellIcon")

	if spellIcon then
		if actionbarState.isEquipmentIconDeterminedOnSlot(slot) then
			actionbarState.applyEquipmentIconToWidget(spellIcon, slot.equipmentIconIndex)
		else
			spellIcon:hide()
			spellIcon:setImageSource("")
		end
	end

	slot:setItemId(0)

	local text = slot:getChildById("text")

	if text then
		text:setText("")
	end

	slot:setBorderWidth(0)
	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	refreshActionSlotTooltip(slot)
	updateSlotGray(slot)
	refreshActionSlotInventoryQuantity(slot)
	applyActionSlotFrame(slot)
	maybeSetupHotkeysAfterSlotLoad()
end

function clearSlotActionContent(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	if clearSlotMultiActions then
		clearSlotMultiActions(slot)
	end

	local spellIcon = slot:getChildById("spellIcon")

	if spellIcon then
		spellIcon:hide()
		spellIcon:setImageSource("")
	end

	if slot.clearItem then
		slot:clearItem()
	end

	slot:setText("")

	slot.itemId = nil
	slot.subType = nil
	slot.words = nil
	slot.text = nil
	slot.useType = nil
	slot.getTier = nil
	slot.passiveId = nil
	slot.helperId = nil
	slot.multiHelper = nil

	hideHelperSlotBorder(slot)

	slot.equipments = nil
	slot.equipmentIconIndex = nil
	slot.equipmentDescription = nil
	slot.equipmentTypeIndex = nil
	slot.parameter = nil
	slot.crossHairMode = nil
	slot.autoSend = nil
	slot.smartMode = nil
	slot.smartBaseItemId = nil
	slot._smartEquipPending = nil

	local tier = slot:getChildById("tier")

	if tier then
		tier:setVisible(false)
	end

	local text = slot:getChildById("text")

	if text then
		text:setText("")
	end

	local gray = slot:getChildById("gray")

	if gray then
		gray:setVisible(false)
	end

	refreshActionSlotVirtueBorder(slot)
	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	refreshActionSlotTooltip(slot)
	refreshActionSlotInventoryQuantity(slot)
	applyActionSlotFrame(slot)
end

  actionbarState.copyEquipmentAssignMetaFromSlot = function(arg_34_0)
	if arg_34_0 then
		actionbarState.equipmentAssignIconIndex = actionbarState.normalizeEquipmentIconIndex(arg_34_0.equipmentIconIndex)
		actionbarState.equipmentAssignDescription = arg_34_0.equipmentDescription or ""
		actionbarState.equipmentAssignTypeIndex = actionbarState.normalizeEquipmentTypeIndex(arg_34_0.equipmentTypeIndex)
	else
		actionbarState.equipmentAssignIconIndex = actionbarState.EQUIPMENT_ICON_UNDETERMINED_INDEX
		actionbarState.equipmentAssignDescription = ""
		actionbarState.equipmentAssignTypeIndex = 0
	end
end

 actionbarState.refreshAssignActionSlotPreview = function()
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() then
		return
	end

	local assignActionSlot = equipmentAssignWindow:recursiveGetChildById("assignActionSlot")

	if not assignActionSlot then
		return
	end

	local equipmentSlotIcon = assignActionSlot:recursiveGetChildById("equipmentSlotIcon")

	actionbarState.applyEquipmentIconToWidget(equipmentSlotIcon, actionbarState.equipmentAssignIconIndex)

	local equipmentTypeIcon = assignActionSlot:recursiveGetChildById("equipmentTypeIcon")

	if equipmentTypeIcon then
		local imageSourcePath = actionbarState.equipmentTypeIconSource(actionbarState.equipmentAssignTypeIndex)

		if imageSourcePath then
			equipmentTypeIcon:setImageSource(imageSourcePath)
			equipmentTypeIcon:setImageSize(actionbarState.EQUIPMENT_SLOT_DECOR_ICON_SIZE)
			equipmentTypeIcon:show()
		else
			equipmentTypeIcon:setVisible(false)
		end
	end
end

  actionbarState.refreshEquipmentAssignIconPickerSelection = function()
	if not equipmentAssignIconWindow or equipmentAssignIconWindow:isDestroyed() then
		return
	end

	local iconScrollPanel = equipmentAssignIconWindow:recursiveGetChildById("iconScrollPanel")

	if not iconScrollPanel then
		return
	end

	for unusedValue, child in pairs(iconScrollPanel:getChildren()) do
		if child.iconIndex ~= nil then
			child:setImageSource("/images/game/actionbar/slot-actionbar-filled")
			child:setImageSize(tosize("34 34"))

			if child.iconIndex == actionbarState.equipmentAssignIconIndex then
				child:setImageClip("0 34 34 34")
			else
				child:setImageClip("0 0 34 34")
			end
		end
	end
end

  actionbarState.setupEquipmentAssignIconPicker = function()
	if not equipmentAssignIconWindow or equipmentAssignIconWindow:isDestroyed() then
		return
	end

	local iconScrollPanel = equipmentAssignIconWindow:recursiveGetChildById("iconScrollPanel")

	if not iconScrollPanel then
		return
	end

	iconScrollPanel:destroyChildren()

	for iter_37_0 = 1, actionbarState.EQUIPMENT_ICON_PICKER_COUNT do
		local equipmentIconPickerOptionWidget = g_ui.createWidget("EquipmentIconPickerOption", iconScrollPanel)

		equipmentIconPickerOptionWidget.iconIndex = iter_37_0

		local icon = equipmentIconPickerOptionWidget:getChildById("icon")

		actionbarState.applyEquipmentIconToWidget(icon, iter_37_0)

		function equipmentIconPickerOptionWidget.onClick()
			actionbarState.equipmentAssignIconIndex = iter_37_0

			actionbarState.refreshEquipmentAssignIconPickerSelection()
			actionbarState.refreshAssignActionSlotPreview()
			equipmentAssignUpdateButtons()
		end
	end

	actionbarState.refreshEquipmentAssignIconPickerSelection()
end

  actionbarState.commitEquipmentAssignIconPicker = function()
	local descriptionTextEdit = equipmentAssignIconWindow and equipmentAssignIconWindow:recursiveGetChildById("descriptionTextEdit")

	if descriptionTextEdit then
		actionbarState.equipmentAssignDescription = descriptionTextEdit:getText() or ""
	end

	if actionbarState.equipmentAssignTypeRadioGroup then
		local selectedWidget = actionbarState.equipmentAssignTypeRadioGroup:getSelectedWidget()

		if selectedWidget and selectedWidget.typeIndex ~= nil then
			actionbarState.equipmentAssignTypeIndex = selectedWidget.typeIndex
		end
	end

	actionbarState.refreshAssignActionSlotPreview()
	equipmentAssignUpdateButtons()
end

  actionbarState.forEachEquipmentAssignSlot = function(callback)
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() then
		return
	end

	local panel = equipmentAssignWindow:recursiveGetChildById("equipmentPanel")

	if not panel then
		return
	end

	for _, child in ipairs(panel:getChildren()) do
		local invSlot = child.inventorySlot

		if invSlot then
			callback(child, invSlot)
		end
	end
end

  actionbarState.equipmentAssignItemHasRarityFrame = function(item)
	if not item or not g_game.getFeature(GameColorizedLootValue) then
		return false
	end

	if modules.client_options.getOption("framesRarity") == "none" then
		return false
	end

	return (item:getMeanPrice() or 0) >= 50
end

  actionbarState.clearEquipmentAssignItemFrame = function(itemWidget)
	itemWidget:setImageSource("")
	itemWidget:setImageClip("0 0 0 0")
end

  actionbarState.applyEquipmentAssignItemRarity = function(arg_43_0, arg_43_1)
	if actionbarState.equipmentAssignItemHasRarityFrame(arg_43_1) then
		ItemsDatabase.setRarityItem(arg_43_0, arg_43_1)

		return
	end

	ItemsDatabase.setRarityItem(arg_43_0, nil)
	actionbarState.clearEquipmentAssignItemFrame(arg_43_0)
end

  actionbarState.clearEquipmentAssignSlotItemWidget = function(arg_44_0)
	arg_44_0:setItem(nil)
	ItemsDatabase.setTier(arg_44_0, 0)
	ItemsDatabase.setBigTier(arg_44_0, 0)
	actionbarState.applyEquipmentAssignItemRarity(arg_44_0, nil)
end

EAssign = {}

function EAssign.getMarketCategory(item)
	local md = item.getMarketData and item:getMarketData()

	return md and md.category
end

function EAssign.isDualWielding(item)
	if not item then
		return false
	end

	local thingType = g_things.getThingType(item:getId(), ThingCategoryItem)

	return thingType and thingType:isDualWielding()
end

function EAssign.isQuiver(item)
	if not item then
		return false
	end

	local cat = EAssign.getMarketCategory(item)

	return MarketCategory and cat == MarketCategory.Quivers
end

function EAssign.isBowOrCrossbow(item)
	if not item then
		return false
	end

	local cat = EAssign.getMarketCategory(item)

	if not MarketCategory or cat ~= MarketCategory.DistanceWeapons then
		return false
	end

	return item:getClothSlot() == InventorySlotOther
end

function EAssign.isShield(item)
	if not item or EAssign.isQuiver(item) then
		return false
	end

	if item:getClothSlot() == InventorySlotRight then
		return true
	end

	local cat = EAssign.getMarketCategory(item)

	return MarketCategory and cat == MarketCategory.Shields
end

function EAssign.getWeaponMarketSlots(item)
	local cat = EAssign.getMarketCategory(item)

	if cat and MarketCategoryWeapons and MarketCategoryWeapons[cat] then
		return MarketCategoryWeapons[cat].slots
	end

	return nil
end

function EAssign.weaponHandFlags(item)
	local weaponMarketSlots = EAssign.getWeaponMarketSlots(item)

	if not weaponMarketSlots then
		return false, false
	end

	local var_51_1 = false
	local var_51_2 = false

	for unusedValue, entry in ipairs(weaponMarketSlots) do
		if entry == InventorySlotLeft then
			var_51_1 = true
		elseif entry == 255 or entry == InventorySlotOther then
			var_51_2 = true
		end
	end

	return var_51_1, var_51_2
end

function EAssign.blocksShieldSlot(item)
	if not item or EAssign.isShield(item) then
		return false
	end

	if EAssign.isBowOrCrossbow(item) then
		return false
	end

	if EAssign.isDualWielding(item) then
		return true
	end

	local canOneHand, canTwoHand = EAssign.weaponHandFlags(item)

	if canTwoHand and not canOneHand then
		return true
	end

	if item:getClothSlot() == InventorySlotOther then
		return true
	end

	return false
end

function EAssign.draftLeftHandItem()
	local var_53_0 = actionbarState.equipmentAssignDraft and actionbarState.equipmentAssignDraft[InventorySlotLeft]

	return var_53_0 and actionbarState.equipmentEntryToItem(var_53_0) or nil
end

function EAssign.resolveRightSlotEntry(slot)
	if slot and slot.itemId and slot.itemId > 0 then
		return slot, false
	end

	local var_54_0 = EAssign.draftLeftHandItem()

	if var_54_0 and EAssign.isDualWielding(var_54_0) then
		return actionbarState.equipmentAssignDraft[InventorySlotLeft], true
	end

	return nil, false
end

function EAssign.reconcileHandSlots()
	if not actionbarState.equipmentAssignDraft then
		return
	end

	local var_55_0 = EAssign.draftLeftHandItem()
	local var_55_1 = actionbarState.equipmentAssignDraft[InventorySlotRight]

	if not var_55_1 then
		return
	end

	local var_55_2 = actionbarState.equipmentEntryToItem(var_55_1)

	if var_55_0 and EAssign.isDualWielding(var_55_0) then
		actionbarState.equipmentAssignDraft[InventorySlotRight] = nil

		return
	end

	if var_55_0 and EAssign.blocksShieldSlot(var_55_0) then
		actionbarState.equipmentAssignDraft[InventorySlotRight] = nil

		return
	end

	if var_55_2 and var_55_0 and EAssign.isBowOrCrossbow(var_55_0) and EAssign.isShield(var_55_2) then
		actionbarState.equipmentAssignDraft[InventorySlotRight] = nil
	end
end

  actionbarState.refreshEquipmentAssignSlotWidget = function(arg_56_0, arg_56_1)
	local equippedItem = arg_56_0:getChildById("equippedItem")
	local slotIcon = arg_56_0:getChildById("slotIcon")

	if not equippedItem then
		return
	end

	local inventorySlot = arg_56_0.inventorySlot
	local var_56_3 = false

	if inventorySlot == InventorySlotRight then
		arg_56_1, var_56_3 = EAssign.resolveRightSlotEntry(arg_56_1)
	end

	local var_56_4 = actionbarState.equipmentEntryToItem(arg_56_1)

	if var_56_4 then
		if var_56_3 then
			local var_56_5 = var_56_4:clone()

			equippedItem:setItem(var_56_5)

			var_56_4 = var_56_5
		else
			equippedItem:setItem(var_56_4)
		end

		equippedItem:setMirrorHorizontal(var_56_3)

		if inventorySlot == InventorySlotRight then
			if var_56_3 then
				arg_56_0:setOpacity(0.6)
				equippedItem:setOpacity(0.6)
			else
				arg_56_0:setOpacity(1)
				equippedItem:setOpacity(1)
			end
		end

		actionbarState.applyEquipmentAssignItemRarity(equippedItem, var_56_4)
		ItemsDatabase.setTier(equippedItem, 0)
		ItemsDatabase.setBigTier(equippedItem, var_56_4)

		if not actionbarState.equipmentAssignItemHasRarityFrame(var_56_4) then
			actionbarState.clearEquipmentAssignItemFrame(equippedItem)
		end

		local quickloot = equippedItem:recursiveGetChildById("quickloot")

		if quickloot then
			quickloot:setVisible(false)
		end

		if slotIcon then
			slotIcon:setVisible(false)
		end
	else
		equippedItem:setMirrorHorizontal(false)

		if inventorySlot == InventorySlotRight then
			arg_56_0:setOpacity(1)
			equippedItem:setOpacity(1)
		end

		actionbarState.clearEquipmentAssignSlotItemWidget(equippedItem)

		if slotIcon then
			slotIcon:setVisible(true)
			slotIcon:raise()
		end
	end
end

function EAssign.refreshHandSlotWidgets()
	actionbarState.forEachEquipmentAssignSlot(function(arg_58_0, arg_58_1)
		if arg_58_1 == InventorySlotLeft or arg_58_1 == InventorySlotRight then
			local var_58_0 = actionbarState.equipmentAssignDraft and actionbarState.equipmentAssignDraft[arg_58_1]

			actionbarState.refreshEquipmentAssignSlotWidget(arg_58_0, var_58_0)
		end
	end)
end

  actionbarState.refreshEquipmentAssignBackpackSlot = function()
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() then
		return
	end

	local backSlot = equipmentAssignWindow:recursiveGetChildById("backSlot")

	if not backSlot then
		return
	end

	local localPlayer = g_game.getLocalPlayer()
	local inventoryItem = localPlayer and actionbarState.equipmentEntryFromItem(localPlayer:getInventoryItem(actionbarState.EQUIPMENT_ASSIGN_BACKPACK_SLOT))

	actionbarState.refreshEquipmentAssignSlotWidget(backSlot, inventoryItem)
end

  actionbarState.refreshAllEquipmentAssignSlots = function()
	EAssign.reconcileHandSlots()
	actionbarState.forEachEquipmentAssignSlot(function(arg_61_0, arg_61_1)
		if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_61_1) then
			return
		end

		local var_61_0 = actionbarState.equipmentAssignDraft and actionbarState.equipmentAssignDraft[arg_61_1] or nil

		actionbarState.refreshEquipmentAssignSlotWidget(arg_61_0, var_61_0)
	end)
	actionbarState.refreshEquipmentAssignBackpackSlot()
end

function equipmentAssignUpdateButtons()
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() then
		return
	end

	local okButton = equipmentAssignWindow:getChildById("okButton")
	local applyButton = equipmentAssignWindow:getChildById("applyButton")
	local enabled = actionbarState.isEquipmentAssignIconDetermined()

	if okButton then
		okButton:setEnabled(enabled)
	end

	if applyButton then
		applyButton:setEnabled(enabled)
	end
end

function equipmentAssignCopyCurrentSet()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	actionbarState.equipmentAssignDraft = {}

	actionbarState.forEachEquipmentAssignSlot(function(unusedArgument, arg_64_1)
		if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_64_1) then
			return
		end

		local inventoryItem = actionbarState.equipmentEntryFromItem(localPlayer:getInventoryItem(arg_64_1))

		if inventoryItem then
			actionbarState.equipmentAssignDraft[arg_64_1] = inventoryItem
		end
	end)
	actionbarState.refreshAllEquipmentAssignSlots()
	equipmentAssignUpdateButtons()
end

  actionbarState.itemFitsEquipmentAssignSlot = function(arg_65_0, arg_65_1)
	if not arg_65_0 or actionbarState.isEquipmentAssignVisualBackpackSlot(arg_65_1) then
		return false
	end

	if not actionbarState.isEquippableActionBarItem(arg_65_0) then
		return false
	end

	local clothSlot = arg_65_0:getClothSlot()

	if clothSlot == InventorySlotBack then
		return false
	end

	if arg_65_1 == InventorySlotRight then
		local var_65_1 = EAssign.draftLeftHandItem()

		if var_65_1 and EAssign.isBowOrCrossbow(var_65_1) then
			return EAssign.isQuiver(arg_65_0)
		end

		if EAssign.isQuiver(arg_65_0) then
			return not var_65_1 or not EAssign.blocksShieldSlot(var_65_1)
		end

		if not EAssign.isShield(arg_65_0) then
			return false
		end

		return not var_65_1 or not EAssign.blocksShieldSlot(var_65_1)
	end

	if arg_65_1 == InventorySlotLeft then
		if EAssign.isShield(arg_65_0) then
			return false
		end

		if EAssign.isDualWielding(arg_65_0) then
			return true
		end

		if clothSlot > 0 then
			return clothSlot == arg_65_1
		end

		local weaponMarketSlots = EAssign.getWeaponMarketSlots(arg_65_0)

		if weaponMarketSlots then
			if #weaponMarketSlots == 1 and weaponMarketSlots[1] == 255 then
				return false
			end

			local var_65_3, var_65_4 = EAssign.weaponHandFlags(arg_65_0)

			return var_65_3 or var_65_4
		end

		local marketCategory = EAssign.getMarketCategory(arg_65_0)

		if MarketCategory and (marketCategory == MarketCategory.FistWeapons or marketCategory == MarketCategory.Quivers) then
			return true
		end

		local thingType = g_things.getThingType(arg_65_0:getId(), ThingCategoryItem)

		if thingType and thingType.isCloth and thingType:isCloth() then
			return true
		end

		return false
	end

	if clothSlot > 0 then
		return clothSlot == arg_65_1
	end

	return false
end

  actionbarState.equipmentAssignDraggedItem = function(draggingWidget)
	if not draggingWidget or draggingWidget:getClassName() ~= "UIItem" or draggingWidget:isVirtual() then
		return nil
	end

	local item = draggingWidget.currentDragThing

	if item and item.isItem and item:isItem() then
		return item
	end

	return nil
end

  actionbarState.equipmentAssignSetSlotItem = function(arg_67_0, arg_67_1, arg_67_2)
	if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_67_0) or not arg_67_1 then
		return false
	end

	if not actionbarState.itemFitsEquipmentAssignSlot(arg_67_1, arg_67_0) then
		if arg_67_0 == InventorySlotRight and EAssign.isQuiver(arg_67_1) and EAssign.draftLeftHandItem() and EAssign.blocksShieldSlot(EAssign.draftLeftHandItem()) then
			modules.game_textmessage.displayFailureMessage(tr("You cannot use a quiver while wielding a two-handed weapon."))
		elseif arg_67_0 == InventorySlotRight and EAssign.isShield(arg_67_1) and EAssign.draftLeftHandItem() and EAssign.isBowOrCrossbow(EAssign.draftLeftHandItem()) then
			modules.game_textmessage.displayFailureMessage(tr("You cannot use a shield while wielding a bow or crossbow."))
		elseif arg_67_0 == InventorySlotRight and EAssign.isShield(arg_67_1) and EAssign.draftLeftHandItem() and EAssign.blocksShieldSlot(EAssign.draftLeftHandItem()) then
			modules.game_textmessage.displayFailureMessage(tr("You cannot use a shield while wielding a two-handed weapon."))
		else
			modules.game_textmessage.displayFailureMessage(tr("This item is not suitable for this equipment slot."))
		end

		return false
	end

	actionbarState.equipmentAssignDraft = actionbarState.equipmentAssignDraft or {}
	actionbarState.equipmentAssignDraft[arg_67_0] = actionbarState.equipmentEntryFromItem(arg_67_1)

	EAssign.reconcileHandSlots()

	if arg_67_0 == InventorySlotLeft or arg_67_0 == InventorySlotRight then
		EAssign.refreshHandSlotWidgets()
	elseif arg_67_2 then
		actionbarState.refreshEquipmentAssignSlotWidget(arg_67_2, actionbarState.equipmentAssignDraft[arg_67_0])
	else
		actionbarState.forEachEquipmentAssignSlot(function(arg_68_0, arg_68_1)
			if arg_68_1 == arg_67_0 then
				actionbarState.refreshEquipmentAssignSlotWidget(arg_68_0, actionbarState.equipmentAssignDraft[arg_67_0])
			end
		end)
	end

	equipmentAssignUpdateButtons()

	return true
end

  actionbarState[83] = function(arg_69_0, arg_69_1, unusedArgument, arg_69_3)
	if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_69_3) then
		return false
	end

	local var_69_0 = actionbarState.equipmentAssignDraggedItem(arg_69_1)

	if not var_69_0 then
		return false
	end

	if actionbarState.equipmentAssignSetSlotItem(arg_69_3, var_69_0, arg_69_0) then
		arg_69_0:setBorderWidth(0)

		if arg_69_1 then
			arg_69_1:setBorderWidth(0)
		end

		return true
	end

	return false
end

  actionbarState.onEquipmentAssignSlotHoverChange = function(arg_70_0, arg_70_1, arg_70_2)
	if UIWidget.onHoverChange then
		UIWidget.onHoverChange(arg_70_0, arg_70_1)
	end

	if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_70_2) then
		return
	end

	local draggingWidget = g_ui.getDraggingWidget()
	local var_70_1 = actionbarState.equipmentAssignDraggedItem(draggingWidget)

	if arg_70_1 and var_70_1 and actionbarState.itemFitsEquipmentAssignSlot(var_70_1, arg_70_2) then
		arg_70_0:setBorderWidth(1)
		arg_70_0:setBorderColor("#ffffff")
	else
		arg_70_0:setBorderWidth(0)
	end
end

  actionbarState.restoreEquipmentAssignWindowAfterPick = function()
	if not actionbarState.equipmentAssignHiddenForPick then
		return
	end

	actionbarState.equipmentAssignHiddenForPick = false

	if equipmentAssignWindow and not equipmentAssignWindow:isDestroyed() then
		equipmentAssignWindow:show()
		equipmentAssignWindow:raise()
		equipmentAssignWindow:focus()
	end
end

  actionbarState.startEquipmentAssignChooseItem = function(equipmentAssignPickInvSlot)
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() or actionbarState.isEquipmentAssignVisualBackpackSlot(equipmentAssignPickInvSlot) or g_ui.isMouseGrabbed() then
		return
	end

	actionbarState.equipmentAssignPickInvSlot = equipmentAssignPickInvSlot

	equipmentAssignWindow:hide()

	actionbarState.equipmentAssignHiddenForPick = true

	mouseGrabberWidget:grabMouse()
	g_mouse.pushCursor("target")
end

  actionbarState.onEquipmentAssignChooseItemMouseRelease = function(arg_73_0, arg_73_1, arg_73_2)
	local equipmentAssignPickInvSlot = actionbarState.equipmentAssignPickInvSlot

	actionbarState.equipmentAssignPickInvSlot = nil

	local var_73_1

	if arg_73_2 == MouseLeftButton then
		var_73_1 = actionbarState.resolvePickItemAtMouse(arg_73_1)

		if var_73_1 and not actionbarState.itemFitsEquipmentAssignSlot(var_73_1, equipmentAssignPickInvSlot) then
			modules.game_textmessage.displayFailureMessage(tr("This item is not suitable for this equipment slot."))

			var_73_1 = nil
		end
	end

	if var_73_1 then
		actionbarState.equipmentAssignSetSlotItem(equipmentAssignPickInvSlot, var_73_1, nil)
	end

	actionbarState.restoreEquipmentAssignWindowAfterPick()
	g_mouse.popCursor("target")
	arg_73_0:ungrabMouse()

	return true
end

  actionbarState.equipmentAssignRemoveSlot = function(arg_74_0)
	if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_74_0) then
		return
	end

	if not actionbarState.equipmentAssignDraft then
		actionbarState.equipmentAssignDraft = {}
	end

	actionbarState.equipmentAssignDraft[arg_74_0] = nil

	if arg_74_0 == InventorySlotLeft or arg_74_0 == InventorySlotRight then
		EAssign.refreshHandSlotWidgets()
	else
		actionbarState.forEachEquipmentAssignSlot(function(arg_75_0, arg_75_1)
			if arg_75_1 == arg_74_0 then
				actionbarState.refreshEquipmentAssignSlotWidget(arg_75_0, nil)
			end
		end)
	end

	equipmentAssignUpdateButtons()
end

  actionbarState.onEquipmentAssignSlotMouseRelease = function(unusedArgument, arg_76_1, arg_76_2, arg_76_3)
	if arg_76_2 ~= MouseRightButton or actionbarState.isEquipmentAssignVisualBackpackSlot(arg_76_3) then
		return false
	end

	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:addOption(tr("Select Equipment"), function()
		actionbarState.startEquipmentAssignChooseItem(arg_76_3)
	end)

	local slot = actionbarState.equipmentAssignDraft and actionbarState.equipmentAssignDraft[arg_76_3]

	if slot and slot.itemId and slot.itemId > 0 then
		gamePopupMenuWidget:addOption(tr("Remove Equipment"), function()
			actionbarState.equipmentAssignRemoveSlot(arg_76_3)
		end)
	end

	gamePopupMenuWidget:display(arg_76_1)

	return true
end

  actionbarState.setupEquipmentAssignSlotHandlers = function()
	actionbarState.forEachEquipmentAssignSlot(function(arg_80_0, arg_80_1)
		if actionbarState.isEquipmentAssignVisualBackpackSlot(arg_80_1) then
			arg_80_0.onMouseRelease = nil
			arg_80_0.onDrop = nil
			arg_80_0.onHoverChange = nil

			return
		end

		function arg_80_0.onMouseRelease(arg_81_0, arg_81_1, arg_81_2)
			return actionbarState.onEquipmentAssignSlotMouseRelease(arg_81_0, arg_81_1, arg_81_2, arg_80_1)
		end

		function arg_80_0.onDrop(unusedArgument, arg_82_1, arg_82_2)
			return actionbarState[83](arg_80_0, arg_82_1, arg_82_2, arg_80_1)
		end

		function arg_80_0.onHoverChange(unusedArgument, arg_83_1)
			actionbarState.onEquipmentAssignSlotHoverChange(arg_80_0, arg_83_1, arg_80_1)
		end

		local equippedItem = arg_80_0:recursiveGetChildById("equippedItem")

		if equippedItem then
			function equippedItem.onDrop(unusedArgument, draggedWidget, mousePos)
				return actionbarState[83](arg_80_0, draggedWidget, mousePos, arg_80_1)
			end

			function equippedItem.onHoverChange(unusedArgument, hovered)
				actionbarState.onEquipmentAssignSlotHoverChange(arg_80_0, hovered, arg_80_1)
			end
		end
	end)
end

  actionbarState.actionSlotEquippedItemMatches = function(arg_86_0, arg_86_1, arg_86_2)
	local var_86_0 = type(arg_86_0)

	if var_86_0 ~= "userdata" and var_86_0 ~= "table" or arg_86_0:getId() ~= arg_86_1 then
		return false
	end

	if g_game.getFeature(GameThingUpgradeClassification) then
		return (arg_86_0.getTier and arg_86_0:getTier() or 0) == (arg_86_2 or 0)
	end

	return true
end

  actionbarState[92] = function(panel)
	if not panel or not panel.equipments then
		return false
	end

	for _, slot in pairs(panel.equipments) do
		if not actionbarState.isEquipmentAssignVisualBackpackSlot(_) and slot and slot.itemId and slot.itemId > 0 then
			return true
		end
	end

	return false
end

 actionbarState.EQUIPMENT_SET_EQUIP_ORDER = {
	InventorySlotHead,
	InventorySlotNeck,
	InventorySlotBody,
	InventorySlotRight,
	InventorySlotLeft,
	InventorySlotLeg,
	InventorySlotFeet,
	InventorySlotFinger,
	InventorySlotAmmo
}
 actionbarState.EQUIPMENT_SET_COOLDOWN_MS = 1000
 actionbarState.EQUIPMENT_SET_CD_PROGRESS_ID = "progressEquipmentSet"
 actionbarState[96] = "equipmentSetShared"
 actionbarState.equipmentSetSharedCooldownUntil = nil

  actionbarState.equipmentSetCooldownGroupId = function()
	return actionbarState[96]
end

  actionbarState.forEachEquipmentSetActionSlot = function(arg_89_0)
	if not arg_89_0 then
		return
	end

	for iter_89_0 = 1, NUM_BARS do
		local var_89_0 = actionBarPanels[iter_89_0]

		if var_89_0 then
			for unusedValue, child in pairs(var_89_0:getChildren()) do
				if actionbarState.isActionSlotEquipmentPreset(child) then
					arg_89_0(child)
				end
			end
		end
	end
end

  actionbarState.isEquipmentSetActionOnCooldown = function(arg_90_0)
	if not actionbarState.isActionSlotEquipmentPreset(arg_90_0) then
		return false
	end

	return actionbarState.equipmentSetSharedCooldownUntil and g_clock.millis() < actionbarState.equipmentSetSharedCooldownUntil
end

  actionbarState.startEquipmentSetActionCooldown = function()
	actionbarState.equipmentSetSharedCooldownUntil = g_clock.millis() + actionbarState.EQUIPMENT_SET_COOLDOWN_MS

	actionbarState.forEachEquipmentSetActionSlot(function(arg_92_0)
		arg_92_0._equipmentSetCooldownUntil = actionbarState.equipmentSetSharedCooldownUntil

		if actionbarState.startEquipmentSetActionCooldownVisual then
			actionbarState.startEquipmentSetActionCooldownVisual(arg_92_0)
		end
	end)
end

  actionbarState.actionSlotPresetEntryMatchesEquipped = function(arg_93_0, arg_93_1, arg_93_2)
	if not arg_93_0 or not arg_93_2 or not arg_93_2.itemId or arg_93_2.itemId <= 0 then
		return true
	end

	return actionbarState.actionSlotEquippedItemMatches(arg_93_0:getInventoryItem(arg_93_1), arg_93_2.itemId, arg_93_2.getTier or 0)
end

  actionbarState.actionSlotPresetEntryForSlot = function(slot, invSlot)
	if not slot or not slot.equipments then
		return nil
	end

	local slot = slot.equipments[invSlot]

	if slot and slot.itemId and slot.itemId > 0 then
		return slot
	end

	return nil
end

  actionbarState[104] = function(arg_95_0)
	if not actionbarState.isActionSlotEquipmentPreset(arg_95_0) then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer or not localPlayer.getInventoryItem then
		return false
	end

	for unusedValue, ptc_root_local in ipairs(actionbarState.EQUIPMENT_SET_EQUIP_ORDER) do
		local var_95_1 = actionbarState.actionSlotPresetEntryForSlot(arg_95_0, ptc_root_local)

		if var_95_1 and not actionbarState.actionSlotPresetEntryMatchesEquipped(localPlayer, ptc_root_local, var_95_1) then
			return true
		end

		if not var_95_1 and localPlayer:getInventoryItem(ptc_root_local) then
			return true
		end
	end

	return false
end

  actionbarState.isActionSlotEquipSetActive = function(arg_96_0)
	if not actionbarState.isActionSlotEquipmentPreset(arg_96_0) then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer or not localPlayer.getInventoryItem then
		return false
	end

	for unusedValue, ptc_root_local in ipairs(actionbarState.EQUIPMENT_SET_EQUIP_ORDER) do
		local var_96_1 = actionbarState.actionSlotPresetEntryForSlot(arg_96_0, ptc_root_local)

		if var_96_1 then
			if not actionbarState.actionSlotPresetEntryMatchesEquipped(localPlayer, ptc_root_local, var_96_1) then
				return false
			end
		elseif localPlayer:getInventoryItem(ptc_root_local) then
			return false
		end
	end

	return true
end

  actionbarState.isActionSlotEquipEquipped = function(arg_97_0)
	if not actionbarState.isActionSlotEquip(arg_97_0) then
		return false
	end

	if actionbarState.isActionSlotEquipmentPreset(arg_97_0) then
		return actionbarState.isActionSlotEquipSetActive(arg_97_0)
	end

	if not arg_97_0.itemId or arg_97_0.itemId <= 0 then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer or not localPlayer.getInventoryItem then
		return false
	end

	local itemId = arg_97_0.itemId
	local var_97_2 = actionbarState.actionSlotItemTier(arg_97_0)
	local var_97_3 = InventorySlotFirst or 1
	local var_97_4 = InventorySlotLast or 10

	for iter_97_0 = var_97_3, var_97_4 do
		if actionbarState.actionSlotEquippedItemMatches(localPlayer:getInventoryItem(iter_97_0), itemId, var_97_2) then
			return true
		end
	end

	return false
end

  actionbarState.refreshSpellAssignPreviewIfOpen = function()
	if not spellAssignWindow or not spellsPanel then
		return
	end

	local fc = spellsPanel:getFocusedChild()

	if fc then
		updatePreviewSpell(fc)
	end
end

  actionbarState.scheduleSlotGrayRefresh = function(arg_99_0)
	slotGrayFullRefreshPending = slotGrayFullRefreshPending or arg_99_0 == true

	if actionbarState.slotGrayRefreshEvent then
		return
	end

	tagHitchEventSource("game_actionbar.scheduleSlotGrayRefresh")

	actionbarState.slotGrayRefreshEvent = scheduleEvent(function()
		actionbarState.slotGrayRefreshEvent = nil

		local var_100_0 = slotGrayFullRefreshPending
		local var_100_1 = slotGrayInventoryRefreshPending
		local var_100_2 = next(slotGrayStatsPendingSlots) ~= nil

		slotGrayFullRefreshPending = false
		slotGrayInventoryRefreshPending = false

		if var_100_0 then
			slotGrayStatsPendingSlots = {}

			updateSlotsVocation()

			if actionbarState.refreshAllSmartModeSlots then
				actionbarState.refreshAllSmartModeSlots()
			end

			actionbarState.refreshSpellAssignPreviewIfOpen()
			actionbarState.refreshAllEquipmentAssignSlots()
		else
			if var_100_1 and updateInventoryDependentActionSlots then
				updateInventoryDependentActionSlots()
			end

			if var_100_2 and updateStatsDependentSlotGray then
				updateStatsDependentSlotGray()
			end
		end

		if var_100_0 or var_100_2 and spellAssignWindow then
			refreshAssignSpellListGrayOverlays()
		end
	end, 50)
end

function scheduleFullSlotGrayRefresh()
	actionbarState.scheduleSlotGrayRefresh(true)
end

function scheduleInventorySlotGrayRefresh()
	slotGrayInventoryRefreshPending = true

	actionbarState.scheduleSlotGrayRefresh(false)
end

  actionbarState.onLocalPlayerManaChange = function(unusedArgument, arg_103_1, unusedArgument, arg_103_3, unusedArgument)
	local numericValue = tonumber(arg_103_1)
	local var_103_1 = tonumber(arg_103_3)

	if not numericValue or not var_103_1 or numericValue == var_103_1 then
		return
	end

	local var_103_2 = false

	for iter_103_0 = 1, NUM_BARS do
		local slots = actionBarPanels[iter_103_0]

		if slots then
			for slotKey, setting in pairs(slots:getChildren()) do
				local grayManaCost = setting.grayManaCost

				if grayManaCost and grayManaCost > 0 and (var_103_1 < grayManaCost and grayManaCost <= numericValue or grayManaCost <= var_103_1 and numericValue < grayManaCost) then
					slotGrayStatsPendingSlots[setting] = true
					var_103_2 = true
				end
			end
		end
	end

	if var_103_2 then
		actionbarState.scheduleSlotGrayRefresh(false)
	end
end

  actionbarState.playerMeetsSpellLevelForAssign = function(spell)
	if not spell then
		return false
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	if spell.level and player:getLevel() < spell.level then
		return false
	end

	return true
end

  actionbarState.spellPassesAssignLearntFilter = function(arg_105_0)
	if not arg_105_0 then
		return false
	end

	return canUseSpell(arg_105_0) and actionbarState.playerMeetsSpellLevelForAssign(arg_105_0)
end

 actionbarState.SPELL_PARAM_MAX_WIDTH_PX = 34

  actionbarState.ellipsizeSpellParameterLabelText = function(arg_106_0, text)
	if not arg_106_0 or not text or text == "" then
		return ""
	end

	arg_106_0:setText(text)

	local textSize = arg_106_0:getTextSize()

	if not textSize or textSize.width <= actionbarState.SPELL_PARAM_MAX_WIDTH_PX then
		return text
	end

	local var_106_1 = "..."

	arg_106_0:setText(var_106_1)

	local textSize = arg_106_0:getTextSize()
	local var_106_3 = textSize and textSize.width or actionbarState.SPELL_PARAM_MAX_WIDTH_PX
	local var_106_4 = actionbarState.SPELL_PARAM_MAX_WIDTH_PX - var_106_3

	if var_106_4 <= 0 then
		return var_106_1
	end

	local var_106_5 = 1
	local var_106_6 = #text
	local var_106_7 = ""

	while var_106_5 <= var_106_6 do
		local var_106_8 = math.floor((var_106_5 + var_106_6) / 2)
		local text = string.sub(text, 1, var_106_8)

		arg_106_0:setText(text)

		if var_106_4 >= arg_106_0:getTextSize().width then
			var_106_7 = text
			var_106_5 = var_106_8 + 1
		else
			var_106_6 = var_106_8 - 1
		end
	end

	if var_106_7 == "" then
		return var_106_1
	end

	local text = var_106_7 .. var_106_1

	arg_106_0:setText(text)

	local var_106_11 = 0

	while var_106_7 ~= "" and arg_106_0:getTextSize().width > actionbarState.SPELL_PARAM_MAX_WIDTH_PX and var_106_11 < 64 do
		var_106_7 = string.sub(var_106_7, 1, #var_106_7 - 1)
		text = var_106_7 ~= "" and var_106_7 .. var_106_1 or var_106_1

		arg_106_0:setText(text)

		var_106_11 = var_106_11 + 1
	end

	return text
end

  actionbarState.refreshActionSlotSpellParameter = function(arg_107_0)
	if not arg_107_0 or arg_107_0:isDestroyed() then
		return
	end

	local spellParameter = arg_107_0:recursiveGetChildById("spellParameter")

	if not spellParameter then
		return
	end

	if arg_107_0.words and arg_107_0.words ~= "" then
		local spellByWords = Spells.getSpellByWords(arg_107_0.words)

		if spellByWords and spellByWords.parameter then
			local parameter = arg_107_0.parameter
			local var_107_3 = parameter ~= nil and tostring(parameter):gsub("^%s+", ""):gsub("%s+$", "") or ""

			if var_107_3 ~= "" then
				spellParameter:setVisible(true)
				spellParameter:setText(actionbarState.ellipsizeSpellParameterLabelText(spellParameter, var_107_3))

				return
			end
		end
	end

	spellParameter:setVisible(false)
	spellParameter:setText("")
end

function refreshActionSlotInventoryQuantity(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local lbl = slot:getChildById("count")

	local function var_108_1()
		if lbl then
			lbl:setVisible(false)
			lbl:setText("")
		end
	end

	if slot.text or slot.passiveId or isHelperActionSlot(slot) or isMultiHelperSlot(slot) then
		var_108_1()
		actionbarState.refreshActionSlotSpellParameter(slot)

		return
	end

	if slot.words and slot.words ~= "" then
		var_108_1()
		actionbarState.refreshActionSlotSpellParameter(slot)

		return
	end

	if actionbarState.isActionSlotEquip(slot) and actionbarState.isActionSlotEquipmentPreset(slot) then
		var_108_1()
		actionbarState.refreshActionSlotSpellParameter(slot)

		return
	end

	if not slot.itemId or slot.itemId <= 0 then
		var_108_1()
		actionbarState.refreshActionSlotSpellParameter(slot)

		return
	end

	local localPlayer = g_game.getLocalPlayer()
	local var_108_3 = 0

	if localPlayer then
		var_108_3 = getActionBarInventoryDisplayCount(slot.itemId, actionbarState.actionSlotItemTier(slot), localPlayer)
	end

	if not lbl then
		return
	end

	local visible = slot._actionBarShowCount == true

	lbl:setVisible(visible)

	if visible then
		lbl:setText(tostring(var_108_3))
	else
		lbl:setText("")
	end

	actionbarState.refreshActionSlotSpellParameter(slot)
end

 actionbarState[115] = {
	update = 1,
	finish = 2
}

  actionbarState.isBottomBar = function(barId)
	return barId and barId >= BAR_BOTTOM_1 and barId <= BAR_BOTTOM_3
end

  actionbarState.isLeftBar = function(barId)
	return barId and barId >= BAR_LEFT_1 and barId <= BAR_LEFT_3
end

  actionbarState.isRightBar = function(barId)
	return barId and barId >= BAR_RIGHT_1 and barId <= BAR_RIGHT_3
end

  actionbarState.isSideBar = function(arg_113_0)
	return actionbarState.isLeftBar(arg_113_0) or actionbarState.isRightBar(arg_113_0)
end

function normalizeSideBarChildOrder(side)
	local order

	if side == "left" then
		order = {
			BAR_LEFT_3,
			BAR_LEFT_2,
			BAR_LEFT_1
		}
	elseif side == "right" then
		order = {
			BAR_RIGHT_1,
			BAR_RIGHT_2,
			BAR_RIGHT_3
		}
	else
		return
	end

	for _, bid in ipairs(order) do
		local b = actionBars[bid]

		if b and not b:isDestroyed() then
			b:raise()
		end
	end
end

function actionBarLockGroupForBar(barId)
	if actionbarState.isLeftBar(barId) then
		return "left"
	elseif actionbarState.isRightBar(barId) then
		return "right"
	end

	return "bottom"
end

function isActionBarGroupLocked(group)
	if not actionBarLocks then
		return isLocked
	end

	return actionBarLocks[group or "bottom"] == true
end

function isActionBarLocked(barId)
	if not barId then
		return false
	end

	return isActionBarGroupLocked(actionBarLockGroupForBar(barId))
end

  actionbarState[120] = function(arg_118_0)
	return actionbarState.isSideBar(arg_118_0) and actionbarState.SIDE_BAR_TOTAL_SLOTS or actionbarState.maxSlots
end

function barWidgetChild(bar, id)
	if not bar or bar:isDestroyed() or not id then
		return nil
	end

	if bar.recursiveGetChildById then
		return bar:recursiveGetChildById(id)
	end

	return bar:getChildById(id)
end

 actionbarState.SLOT_IMG_EMPTY = "/images/game/actionbar/slot-actionbar-empty"
 actionbarState.SLOT_IMG_FILLED = "/images/game/actionbar/slot-actionbar-filled"
 actionbarState.SLOT_CLIP_EMPTY = "0 0 0 0"
 actionbarState.SLOT_CLIP_FILLED_NORMAL = "0 0 34 34"
 actionbarState[125] = "0 34 34 34"

HelperAction = {
	MAX_MULTI = 3,
	BORDER_CLIP_3_ON = "170 0 34 34",
	BORDER_CLIP_3_OFF = "136 0 34 34",
	BORDER_CLIP_2_ON = "102 0 34 34",
	BORDER_CLIP_2_OFF = "68 0 34 34",
	BORDER_CLIP_ON = "34 0 34 34",
	BORDER_CLIP_OFF = "0 0 34 34",
	BORDER_FILE = "/images/game/actionbar/border_active_helper",
	ICON_FILE = "/images/game/spells/helper-icons",
	CLIP_SHADER = {
		[2] = {
			"helper_clip_2_0",
			"helper_clip_2_1"
		},
		[3] = {
			"helper_clip_3_0",
			"helper_clip_3_1",
			"helper_clip_3_2"
		}
	},
	SHADER_FILES = {
		{
			"helper_clip_2_0",
			"shaders/helper_clip_2_0.frag"
		},
		{
			"helper_clip_2_1",
			"shaders/helper_clip_2_1.frag"
		},
		{
			"helper_clip_3_0",
			"shaders/helper_clip_3_0.frag"
		},
		{
			"helper_clip_3_1",
			"shaders/helper_clip_3_1.frag"
		},
		{
			"helper_clip_3_2",
			"shaders/helper_clip_3_2.frag"
		}
	},
	OVERLAY_IDS = {
		"gray",
		"text",
		"spellParameter",
		"multiIcon",
		"equipmentTypeIcon",
		"helperBorder",
		"activeSpell",
		"count",
		"tier",
		"key"
	},
	ITEMS = {
		{
			iconIndex = 0,
			label = "Healing",
			id = "healing"
		},
		{
			iconIndex = 1,
			label = "Heal Friend",
			id = "healFriend"
		},
		{
			iconIndex = 2,
			label = "Target Helper",
			id = "target"
		},
		{
			iconIndex = 3,
			label = "Shooter Helper",
			id = "shooter"
		},
		{
			iconIndex = 4,
			label = "Cavebot Helper",
			id = "cavebot"
		},
		{
			iconIndex = 5,
			label = "Auto Invite",
			id = "autoInvite"
		},
		{
			iconIndex = 6,
			label = "Auto Accept",
			id = "autoAccept"
		},
		{
			iconIndex = 7,
			label = "Auto Haste",
			id = "autoHaste"
		},
		{
			iconIndex = 8,
			label = "Auto Training",
			id = "autoTraining"
		},
		{
			iconIndex = 9,
			label = "Anti Idle",
			id = "antiIdle"
		},
		{
			iconIndex = 10,
			label = "Mana Training",
			id = "manaTraining"
		},
		{
			iconIndex = 11,
			label = "Change Gold",
			id = "changeGold"
		},
		{
			iconIndex = 12,
			label = "Eat Food",
			id = "eatFood"
		},
		{
			iconIndex = 13,
			label = "Reconnect",
			id = "reconnect"
		}
	}
}

function HelperAction.isItemVisible(arg_120_0)
	if not arg_120_0 then
		return false
	end

	if arg_120_0.id == "healFriend" then
		local game_helper = modules.game_helper

		if game_helper and game_helper.isHealFriendAllowed then
			return game_helper.isHealFriendAllowed() == true
		end

		if HelperHealFriend and HelperHealFriend.isAllowedVocation then
			return HelperHealFriend.isAllowedVocation() == true
		end

		return false
	end

	return true
end

function HelperAction.getItem(arg_121_0)
	if type(arg_121_0) ~= "string" or arg_121_0 == "" then
		return nil
	end

	for unusedValue, entry in ipairs(HelperAction.ITEMS) do
		if entry.id == arg_121_0 then
			return entry
		end
	end

	return nil
end

function HelperAction.iconClip(arg_122_0)
	return string.format("%d 0 32 32", (tonumber(arg_122_0) or 0) * 32)
end

function HelperAction.registerShaders()
	if not g_shaders or not g_shaders.createFragmentShader then
		return
	end

	for unusedValue, entry in ipairs(HelperAction.SHADER_FILES) do
		if not g_shaders.getShader(entry[1]) then
			g_shaders.createFragmentShader(entry[1], entry[2], true)
		end
	end
end

function HelperAction.countFilled(arg_124_0)
	if type(arg_124_0) ~= "table" then
		return 0
	end

	local var_124_0 = 0

	for iter_124_0 = 1, HelperAction.MAX_MULTI do
		if HelperAction.getItem(arg_124_0[iter_124_0]) then
			var_124_0 = var_124_0 + 1
		end
	end

	return var_124_0
end

function HelperAction.filledEntries(arg_125_0)
	local var_125_0 = {}

	if type(arg_125_0) ~= "table" then
		return var_125_0
	end

	for iter_125_0 = 1, HelperAction.MAX_MULTI do
		if HelperAction.getItem(arg_125_0[iter_125_0]) then
			var_125_0[#var_125_0 + 1] = {
				index = iter_125_0,
				id = arg_125_0[iter_125_0]
			}
		end
	end

	return var_125_0
end

function HelperAction.copyList(arg_126_0)
	if type(arg_126_0) ~= "table" then
		return nil
	end

	local out = {}

	for invSlot = 1, HelperAction.MAX_MULTI do
		out[invSlot] = arg_126_0[invSlot] or false
	end

	if HelperAction.countFilled(out) == 0 then
		return nil
	end

	return out
end

function HelperAction.normalizeList(arg_127_0)
	if type(arg_127_0) ~= "table" then
		return nil
	end

	local var_127_0 = {}
	local var_127_1 = {}

	for iter_127_0 = 1, HelperAction.MAX_MULTI do
		local var_127_2 = arg_127_0[iter_127_0]

		if type(var_127_2) == "string" and var_127_2 ~= "" and not var_127_0[var_127_2] and HelperAction.getItem(var_127_2) then
			var_127_0[var_127_2] = true
			var_127_1[iter_127_0] = var_127_2
		else
			var_127_1[iter_127_0] = false
		end
	end

	if HelperAction.countFilled(var_127_1) == 0 then
		return nil
	end

	return var_127_1
end

function isMultiHelperSlot(arg_128_0)
	return arg_128_0 and HelperAction.countFilled(arg_128_0.multiHelper) >= 1
end

function isHelperActionSlot(arg_129_0)
	if isMultiHelperSlot(arg_129_0) then
		return false
	end

	return arg_129_0 and type(arg_129_0.helperId) == "string" and arg_129_0.helperId ~= "" and HelperAction.getItem(arg_129_0.helperId) ~= nil
end

function HelperAction.clearIcons(arg_130_0)
	if not arg_130_0 or arg_130_0:isDestroyed() then
		return
	end

	for iter_130_0 = 0, HelperAction.MAX_MULTI - 1 do
		local multiHelperIcon = arg_130_0:getChildById("multiHelperIcon" .. iter_130_0)

		if multiHelperIcon then
			multiHelperIcon:destroy()
		end
	end
end

function HelperAction.raiseHotkey(arg_131_0)
	if not arg_131_0 or arg_131_0:isDestroyed() then
		return
	end

	local key = arg_131_0:getChildById("key")

	if key then
		key:raise()
	end
end

function HelperAction.raiseOverlays(arg_132_0)
	if not arg_132_0 or arg_132_0:isDestroyed() then
		return
	end

	for unusedValue, entry in ipairs(HelperAction.OVERLAY_IDS) do
		local childById = arg_132_0:getChildById(entry)

		if childById then
			childById:raise()
		end
	end

	HelperAction.raiseHotkey(arg_132_0)
end

function HelperAction.allEnabled(arg_133_0)
	local var_133_0 = HelperAction.filledEntries(arg_133_0)

	if #var_133_0 == 0 then
		return false
	end

	for iter_133_0 = 1, #var_133_0 do
		if not HelperAction.isEnabled(var_133_0[iter_133_0].id) then
			return false
		end
	end

	return true
end

function HelperAction.applyIconWidget(arg_134_0, arg_134_1, arg_134_2)
	local item = HelperAction.getItem(arg_134_1)

	if not arg_134_0 or not item then
		return
	end

	arg_134_0:setImageSource(HelperAction.ICON_FILE)
	arg_134_0:setImageClip(HelperAction.iconClip(item.iconIndex))

	if arg_134_0.setShader then
		arg_134_0:setShader(arg_134_2 or "")
	end

	arg_134_0:show()
end

function HelperAction.getBarId(arg_135_0)
	if arg_135_0 and arg_135_0._actionBarId then
		return arg_135_0._actionBarId
	end

	if arg_135_0 and getSlotBarId then
		return getSlotBarId(arg_135_0:getId()) or BAR_BOTTOM_1
	end

	return BAR_BOTTOM_1
end

function HelperAction.getPanelLayout(arg_136_0)
	if getMultiActionLayout then
		return getMultiActionLayout(arg_136_0) or "slot-multi-action-bottom"
	end

	if arg_136_0 and arg_136_0 >= BAR_BOTTOM_1 and arg_136_0 <= BAR_BOTTOM_3 then
		return "slot-multi-action-bottom"
	end

	if arg_136_0 and arg_136_0 >= BAR_LEFT_1 and arg_136_0 <= BAR_LEFT_3 then
		return "LeftMultiAction"
	end

	if arg_136_0 and arg_136_0 >= BAR_RIGHT_1 and arg_136_0 <= BAR_RIGHT_3 then
		return "RightMultiAction"
	end

	return "slot-multi-action-bottom"
end

function HelperAction.getPanelPosition(arg_137_0)
	if getMultiActionPosition then
		return getMultiActionPosition(arg_137_0)
	end

	local barId = HelperAction.getBarId(arg_137_0)

	if barId >= BAR_BOTTOM_1 and barId <= BAR_BOTTOM_3 then
		return topoint(string.format("%s %s", arg_137_0:getX() - 28, arg_137_0:getY() - 116))
	end

	if barId >= BAR_LEFT_1 and barId <= BAR_LEFT_3 then
		return topoint(string.format("%s %s", arg_137_0:getX() + 34, arg_137_0:getY() - 28))
	end

	return topoint(string.format("%s %s", arg_137_0:getX() - 116, arg_137_0:getY() - 28))
end

function HelperAction.stopPanelTracking()
	if HelperAction.panelEvent then
		removeEvent(HelperAction.panelEvent)

		HelperAction.panelEvent = nil
	end
end

function HelperAction.closePanel()
	HelperAction.stopPanelTracking()

	local panel = HelperAction.panel

	if not panel then
		return
	end

	local parentSlot = panel.parentSlot

	if parentSlot and not parentSlot:isDestroyed() then
		parentSlot._multiHelperPanelOpen = nil
		parentSlot.onVisibilityChange = nil
	end

	if not panel:isDestroyed() then
		panel:destroy()
	end

	HelperAction.panel = nil
end

function HelperAction.paintSubSlot(arg_140_0, arg_140_1)
	if not arg_140_0 or arg_140_0:isDestroyed() then
		return
	end

	arg_140_0.helperId = nil
	arg_140_0.multiHelper = nil
	arg_140_0.itemId = nil

	if arg_140_0.clearItem then
		arg_140_0:clearItem()
	end

	local spellIcon = arg_140_0:getChildById("spellIcon")
	local helperBorder = arg_140_0:getChildById("helperBorder")
	local text = arg_140_0:getChildById("text")

	if text then
		text:setText("")
	end

	local item = HelperAction.getItem(arg_140_1)

	if not item then
		if spellIcon then
			spellIcon:hide()
			spellIcon:setImageSource("")
		end

		if helperBorder then
			helperBorder:hide()
		end

		arg_140_0:setTooltip(tr("Action: None"))
		arg_140_0:setImageSource(actionbarState.SLOT_IMG_EMPTY)
		arg_140_0:setImageClip(actionbarState.SLOT_CLIP_EMPTY)

		return
	end

	if spellIcon then
		HelperAction.applyIconWidget(spellIcon, arg_140_1, "")
	end

	arg_140_0:setTooltip(tr(item.label))
	arg_140_0:setImageSource(actionbarState.SLOT_IMG_FILLED)

	if actionbarState.SLOT_CLIP_FILLED_NORMAL then
		arg_140_0:setImageClip(actionbarState.SLOT_CLIP_FILLED_NORMAL)
	end

	if helperBorder then
		helperBorder:setImageSource(HelperAction.BORDER_FILE)

		if HelperAction.isEnabled(arg_140_1) then
			helperBorder:setImageClip(HelperAction.BORDER_CLIP_ON)
		else
			helperBorder:setImageClip(HelperAction.BORDER_CLIP_OFF)
		end

		helperBorder:show()
		helperBorder:raise()
	end
end

function HelperAction.refreshPanel()
	local panel = HelperAction.panel

	if not panel or panel:isDestroyed() or not panel.parentSlot then
		return
	end

	local parentSlot = panel.parentSlot

	for iter_141_0 = 1, HelperAction.MAX_MULTI do
		local actionButton = panel:recursiveGetChildById("actionButton" .. iter_141_0)

		if actionButton then
			HelperAction.paintSubSlot(actionButton, parentSlot.multiHelper and parentSlot.multiHelper[iter_141_0] or nil)
		end
	end
end

function HelperAction.openSubSlotMenu(arg_142_0, arg_142_1, arg_142_2)
	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setGameMenu(true)

	local var_142_1 = arg_142_0.multiHelper and arg_142_0.multiHelper[arg_142_1] or nil
	local item = HelperAction.getItem(var_142_1) ~= nil

	gamePopupMenuWidget:addOption(item and tr("Edit Helper") or tr("Assign Helper"), function()
		slotToEdit = arg_142_0:getId()

		assignHelper(arg_142_0:getId(), arg_142_1)
	end)

	if item then
		gamePopupMenuWidget:addSeparator()
		gamePopupMenuWidget:addOption(tr("Clear Action"), function()
			HelperAction.clearIndex(arg_142_0, arg_142_1)
		end)
	end

	gamePopupMenuWidget:display(arg_142_2)
end

function HelperAction.prepareSlot(arg_145_0)
	if not arg_145_0 or arg_145_0:isDestroyed() then
		return
	end

	if HelperAction.countFilled(arg_145_0.multiHelper) > 0 then
		arg_145_0.multiHelper = HelperAction.normalizeList(arg_145_0.multiHelper)

		return
	end

	if arg_145_0.helperId and HelperAction.getItem(arg_145_0.helperId) then
		arg_145_0.multiHelper = HelperAction.normalizeList({
			arg_145_0.helperId
		})
		arg_145_0.helperId = nil

		return
	end

	arg_145_0.multiHelper = nil
end

function HelperAction.clearIndex(arg_146_0, arg_146_1)
	if not arg_146_0 or type(arg_146_1) ~= "number" then
		return
	end

	local var_146_0 = HelperAction.copyList(arg_146_0.multiHelper) or {}

	var_146_0[arg_146_1] = nil
	arg_146_0.multiHelper = HelperAction.normalizeList(var_146_0)

	if isMultiHelperSlot(arg_146_0) then
		loadMultiHelper(arg_146_0)
	else
		HelperAction.clearIcons(arg_146_0)
		hideHelperSlotBorder(arg_146_0)

		arg_146_0.itemId = nil

		if arg_146_0.clearItem then
			arg_146_0:clearItem()
		end

		applyActionSlotFrame(arg_146_0)
		refreshActionSlotTooltip(arg_146_0)
	end

	HelperAction.refreshPanel()
	saveActionBar()
end

function HelperAction.handleDropOnSubSlot(arg_147_0, arg_147_1)
	if not arg_147_0 or arg_147_0:isDestroyed() then
		return
	end

	if isActionBarLocked and isActionBarLocked(arg_147_0._actionBarId) then
		return
	end

	local pressedWidget = g_ui.getPressedWidget()

	if not pressedWidget or pressedWidget:isDestroyed() then
		return
	end

	if pressedWidget.multiHelperIndex and pressedWidget.parentSlot then
		local multiHelperIndex = pressedWidget.multiHelperIndex
		local parentSlot = pressedWidget.parentSlot

		if not parentSlot or parentSlot:isDestroyed() then
			return
		end

		if parentSlot == arg_147_0 and multiHelperIndex == arg_147_1 then
			return
		end

		local var_147_3 = HelperAction.copyList(parentSlot.multiHelper) or {}
		local var_147_4 = parentSlot == arg_147_0 and var_147_3 or HelperAction.copyList(arg_147_0.multiHelper) or {}

		var_147_4[arg_147_1], var_147_3[multiHelperIndex] = var_147_3[multiHelperIndex], var_147_4[arg_147_1]
		parentSlot.multiHelper = HelperAction.normalizeList(var_147_3)

		if parentSlot ~= arg_147_0 then
			arg_147_0.multiHelper = HelperAction.normalizeList(var_147_4)
		end

		if isMultiHelperSlot(parentSlot) then
			loadMultiHelper(parentSlot)
		else
			HelperAction.clearIcons(parentSlot)
			hideHelperSlotBorder(parentSlot)

			parentSlot.itemId = nil

			if parentSlot.clearItem then
				parentSlot:clearItem()
			end

			applyActionSlotFrame(parentSlot)
			refreshActionSlotTooltip(parentSlot)
		end

		if parentSlot ~= arg_147_0 then
			if isMultiHelperSlot(arg_147_0) then
				loadMultiHelper(arg_147_0)
			else
				HelperAction.clearIcons(arg_147_0)
				hideHelperSlotBorder(arg_147_0)

				arg_147_0.itemId = nil

				if arg_147_0.clearItem then
					arg_147_0:clearItem()
				end

				applyActionSlotFrame(arg_147_0)
				refreshActionSlotTooltip(arg_147_0)
			end
		end

		HelperAction.refreshPanel()
		saveActionBar()

		return
	end

	if pressedWidget:getClassName() == "UIActionSlot" and pressedWidget ~= arg_147_0 then
		local helperId = pressedWidget.helperId

		if not helperId or not HelperAction.getItem(helperId) then
			return
		end

		if pressedWidget.multiHelper then
			return
		end

		local var_147_6 = HelperAction.copyList(arg_147_0.multiHelper) or {}

		for iter_147_0 = 1, HelperAction.MAX_MULTI do
			if var_147_6[iter_147_0] == helperId and iter_147_0 ~= arg_147_1 then
				return
			end
		end

		local replacementHelperId = var_147_6[arg_147_1]

		if replacementHelperId == helperId then
			return
		end

		var_147_6[arg_147_1] = helperId
		arg_147_0.multiHelper = HelperAction.normalizeList(var_147_6)

		loadMultiHelper(arg_147_0)

		if replacementHelperId and HelperAction.getItem(replacementHelperId) then
			clearSlotActionContent(pressedWidget)

			pressedWidget.helperId = replacementHelperId
			pressedWidget.itemId = 469

			if pressedWidget.setItemId then
				pressedWidget:setItemId(469)
			end

			loadHelper(pressedWidget)
		else
			clearSlotActionContent(pressedWidget)
			applyActionSlotFrame(pressedWidget)
			refreshActionSlotTooltip(pressedWidget)
		end

		HelperAction.refreshPanel()
		saveActionBar()

		return
	end
end

function HelperAction.handleDropFromSubSlotOntoSlot(arg_148_0, arg_148_1)
	if not arg_148_0 or arg_148_0:isDestroyed() then
		return
	end

	local parentSlot = arg_148_0.parentSlot
	local multiHelperIndex = arg_148_0.multiHelperIndex

	if not parentSlot or parentSlot:isDestroyed() or not multiHelperIndex then
		return
	end

	if isActionBarLocked and isActionBarLocked(parentSlot._actionBarId) then
		return
	end

	local var_148_2 = findSlotById and findSlotById(arg_148_1) or nil

	if not var_148_2 or var_148_2:isDestroyed() then
		return
	end

	if isActionBarLocked and isActionBarLocked(var_148_2._actionBarId) then
		return
	end

	if var_148_2 == parentSlot then
		return
	end

	local helperId = parentSlot.multiHelper and parentSlot.multiHelper[multiHelperIndex] or nil

	if not helperId or not HelperAction.getItem(helperId) then
		return
	end

	local var_148_4 = HelperAction.copyList(parentSlot.multiHelper) or {}

	var_148_4[multiHelperIndex] = nil
	parentSlot.multiHelper = HelperAction.normalizeList(var_148_4)

	if isMultiHelperSlot(parentSlot) then
		loadMultiHelper(parentSlot)
	else
		HelperAction.clearIcons(parentSlot)
		hideHelperSlotBorder(parentSlot)

		parentSlot.itemId = nil

		if parentSlot.clearItem then
			parentSlot:clearItem()
		end

		applyActionSlotFrame(parentSlot)
		refreshActionSlotTooltip(parentSlot)
	end

	var_148_2.words = nil
	var_148_2.text = nil
	var_148_2.passiveId = nil
	var_148_2.multiHelper = nil
	var_148_2.useType = nil
	var_148_2.parameter = nil
	var_148_2.equipments = nil
	var_148_2.equipmentIconIndex = nil

	if clearSlotMultiActions then
		clearSlotMultiActions(var_148_2)
	end

	var_148_2.helperId = helperId
	var_148_2.itemId = 469

	if var_148_2.setItemId then
		var_148_2:setItemId(469)
	end

	loadHelper(var_148_2)
	applyActionSlotFrame(var_148_2)
	refreshActionSlotTooltip(var_148_2)
	HelperAction.refreshPanel()
	saveActionBar()
end

function HelperAction.applyToIndex(arg_149_0, arg_149_1, arg_149_2)
	if not arg_149_0 or type(arg_149_1) ~= "number" or not HelperAction.getItem(arg_149_2) then
		return
	end

	arg_149_0.words = nil
	arg_149_0.text = nil
	arg_149_0.passiveId = nil
	arg_149_0.helperId = nil
	arg_149_0.useType = nil
	arg_149_0.parameter = nil
	arg_149_0.equipments = nil
	arg_149_0.equipmentIconIndex = nil

	if clearSlotMultiActions then
		clearSlotMultiActions(arg_149_0)
	end

	local var_149_0 = HelperAction.copyList(arg_149_0.multiHelper) or {}

	for iter_149_0 = 1, HelperAction.MAX_MULTI do
		if iter_149_0 ~= arg_149_1 and var_149_0[iter_149_0] == arg_149_2 then
			var_149_0[iter_149_0] = nil
		end
	end

	var_149_0[arg_149_1] = arg_149_2
	arg_149_0.multiHelper = HelperAction.normalizeList(var_149_0)
	arg_149_0.itemId = 469

	if arg_149_0.setItemId then
		arg_149_0:setItemId(469)
	end

	loadMultiHelper(arg_149_0)
	HelperAction.refreshPanel()
	saveActionBar()
end

function HelperAction.openPanel(parentSlot)
	if not parentSlot or parentSlot:isDestroyed() then
		return
	end

	if closeCurrentMultiActionPanel then
		closeCurrentMultiActionPanel()
	end

	local barId = HelperAction.getBarId(parentSlot)

	parentSlot._actionBarId = barId

	local panelLayout = HelperAction.getPanelLayout(barId)

	if HelperAction.panel and HelperAction.panel.parentSlot == parentSlot then
		HelperAction.closePanel()

		return
	end

	HelperAction.closePanel()
	HelperAction.prepareSlot(parentSlot)

	local rootPanel = modules.game_interface.getRootPanel()
	local panel = g_ui.createWidget(panelLayout, rootPanel)

	if not panel then
		return
	end

	HelperAction.panel = panel
	panel.parentSlot = parentSlot

	panel:breakAnchors()
	panel:setPosition(HelperAction.getPanelPosition(parentSlot))

	parentSlot._multiHelperPanelOpen = true

	function parentSlot.onVisibilityChange()
		if not parentSlot:isVisible() then
			HelperAction.closePanel()
		end
	end

	for multiHelperIndex = 1, HelperAction.MAX_MULTI do
		local actionButton = panel:recursiveGetChildById("actionButton" .. multiHelperIndex)

		if actionButton then
			actionButton.multiHelperIndex = multiHelperIndex
			actionButton.parentSlot = parentSlot

			g_mouse.bindPress(actionButton, function()
				return
			end, MouseLeftButton)
			g_mouse.bindPress(actionButton, function()
				HelperAction.openSubSlotMenu(parentSlot, multiHelperIndex, g_window.getMousePosition())
			end, MouseRightButton)
			g_mouse.bindOnDrop(actionButton, function()
				HelperAction.handleDropOnSubSlot(parentSlot, multiHelperIndex)
			end)
		end
	end

	HelperAction.refreshPanel()

	local function var_150_5()
		HelperAction.panelEvent = nil

		if not HelperAction.panel or HelperAction.panel:isDestroyed() then
			return
		end

		if not parentSlot or parentSlot:isDestroyed() or not parentSlot:isVisible() then
			HelperAction.closePanel()

			return
		end

		HelperAction.panel:breakAnchors()
		HelperAction.panel:setPosition(HelperAction.getPanelPosition(parentSlot))
		HelperAction.panel:raise()
		tagHitchEventSource("game_actionbar.HelperAction.panelTick")

		HelperAction.panelEvent = scheduleEvent(var_150_5, 50)
	end

	var_150_5()
end

function closeCurrentMultiHelperPanel()
	HelperAction.closePanel()
end

function HelperAction.isEnabled(arg_157_0)
	local game_helper = modules.game_helper

	if game_helper and game_helper.isHelperStatsEntryEnabled then
		return game_helper.isHelperStatsEntryEnabled(arg_157_0) == true
	end

	return false
end

function hideHelperSlotBorder(arg_158_0)
	if not arg_158_0 or arg_158_0:isDestroyed() then
		return
	end

	HelperAction.clearIcons(arg_158_0)

	local helperBorder = arg_158_0:getChildById("helperBorder")

	if helperBorder then
		helperBorder:hide()
	end
end

function refreshMultiHelperSlotBorder(arg_159_0)
	if not arg_159_0 or arg_159_0:isDestroyed() then
		return
	end

	local helperBorder = arg_159_0:getChildById("helperBorder")

	if not helperBorder then
		return
	end

	if not isMultiHelperSlot(arg_159_0) then
		helperBorder:hide()

		return
	end

	local var_159_1 = HelperAction.countFilled(arg_159_0.multiHelper)
	local var_159_2 = HelperAction.allEnabled(arg_159_0.multiHelper)

	helperBorder:setImageSource(HelperAction.BORDER_FILE)

	if var_159_1 >= 3 then
		helperBorder:setImageClip(var_159_2 and HelperAction.BORDER_CLIP_3_ON or HelperAction.BORDER_CLIP_3_OFF)
	elseif var_159_1 == 2 then
		helperBorder:setImageClip(var_159_2 and HelperAction.BORDER_CLIP_2_ON or HelperAction.BORDER_CLIP_2_OFF)
	elseif var_159_2 then
		helperBorder:setImageClip(HelperAction.BORDER_CLIP_ON)
	else
		helperBorder:setImageClip(HelperAction.BORDER_CLIP_OFF)
	end

	helperBorder:show()
	helperBorder:raise()
	HelperAction.raiseHotkey(arg_159_0)
end

function refreshHelperSlotBorder(arg_160_0)
	if not arg_160_0 or arg_160_0:isDestroyed() then
		return
	end

	if isMultiHelperSlot(arg_160_0) then
		refreshMultiHelperSlotBorder(arg_160_0)

		return
	end

	local helperBorder = arg_160_0:getChildById("helperBorder")

	if not helperBorder then
		return
	end

	if not isHelperActionSlot(arg_160_0) then
		helperBorder:hide()

		return
	end

	helperBorder:setImageSource(HelperAction.BORDER_FILE)

	if HelperAction.isEnabled(arg_160_0.helperId) then
		helperBorder:setImageClip(HelperAction.BORDER_CLIP_ON)
	else
		helperBorder:setImageClip(HelperAction.BORDER_CLIP_OFF)
	end

	helperBorder:show()
	helperBorder:raise()
	HelperAction.raiseHotkey(arg_160_0)
end

function refreshHelperActionBarSlots()
	for iter_161_0 = 1, NUM_BARS do
		local hotkeys = actionBarPanels[iter_161_0]

		if hotkeys then
			for slotKey, setting in pairs(hotkeys:getChildren()) do
				if isMultiHelperSlot(setting) then
					refreshMultiHelperSlotBorder(setting)
					refreshActionSlotTooltip(setting)
				elseif isHelperActionSlot(setting) then
					refreshHelperSlotBorder(setting)
					refreshActionSlotTooltip(setting)
				end
			end
		end
	end

	HelperAction.refreshPanel()
end

  actionbarState[126] = function(arg_162_0)
	if not arg_162_0 or arg_162_0:isDestroyed() or not arg_162_0._actionBarFilledFrame then
		return
	end

	if arg_162_0.passiveId ~= nil then
		arg_162_0:setImageClip(actionbarState[125])
	elseif arg_162_0._helperAssignPreview then
		arg_162_0:setImageClip(actionbarState.SLOT_CLIP_FILLED_NORMAL)
	elseif arg_162_0:isPressed() or not actionbarState.isActionSlotEquipmentPreset(arg_162_0) and actionbarState.isActionSlotEquipEquipped(arg_162_0) then
		arg_162_0:setImageClip(actionbarState[125])
	else
		arg_162_0:setImageClip(actionbarState.SLOT_CLIP_FILLED_NORMAL)
	end
end

function applyActionSlotFrame(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local var_163_0 = type(slot.text) == "string" and slot.text ~= ""
	local item = slot:getItem() ~= nil
	local var_163_2 = slot.words ~= nil and slot.words ~= ""
	local var_163_3 = slot.passiveId ~= nil
	local var_163_4 = isHelperActionSlot(slot) or isMultiHelperSlot(slot)
	local var_163_5 = actionbarState.isActionSlotEquipmentPreset(slot)

	if var_163_0 or item or var_163_2 or var_163_3 or var_163_4 or var_163_5 then
		slot:setImageSource(actionbarState.SLOT_IMG_FILLED)

		slot._actionBarFilledFrame = true

		actionbarState[126](slot)
	else
		slot:setImageSource(actionbarState.SLOT_IMG_EMPTY)
		slot:setImageClip(actionbarState.SLOT_CLIP_EMPTY)

		slot._actionBarFilledFrame = false
	end

	refreshHelperSlotBorder(slot)
	actionbarState.syncSlotHotkeyMirror(slot)
end

function refreshActionSlotFrameClip(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	actionbarState[126](slot)
end

  actionbarState.anchorGroupCooldownBelowBottomStack = function()
	local cd = modules.game_cooldown and modules.game_cooldown.cooldownWindow

	if not cd or cd:isDestroyed() then
		return
	end

	cd:removeAnchor(AnchorTop)
	cd:setMarginTop(1)

	if modules.game_interface and modules.game_interface.isBottomStatsBarDockActive and modules.game_interface.isBottomStatsBarDockActive() then
		local statsPanel = modules.game_interface.getGameBottomStatsBar and modules.game_interface.getGameBottomStatsBar()
		local totalMargin = 0

		if statsPanel and not statsPanel:isDestroyed() then
			totalMargin = statsPanel:getMarginTop() + statsPanel:getHeight()
		end

		cd:addAnchor(AnchorTop, "parent", AnchorTop)
		cd:setMarginTop(math.max(0, totalMargin - 6))
	else
		local anchorBar

		for barId = BAR_BOTTOM_3, BAR_BOTTOM_1, -1 do
			local bar = actionBars[barId]

			if bar and not bar:isDestroyed() and bar:isVisible() and bar:getHeight() > 0 then
				anchorBar = bar

				break
			end
		end

		if anchorBar then
			cd:addAnchor(AnchorTop, anchorBar:getId(), AnchorBottom)
			cd:setMarginTop(1)
		else
			cd:addAnchor(AnchorTop, "parent", AnchorTop)
		end
	end

	if modules.game_cooldown and modules.game_cooldown.refreshConsoleAnchor then
		modules.game_cooldown.refreshConsoleAnchor()
	end
end

function refreshBottomCooldownDock()
	actionbarState.anchorGroupCooldownBelowBottomStack()
end

function slotIdFor(barId, i)
	if barId == BAR_BOTTOM_1 then
		return "slot" .. i
	end

	return "bar" .. barId .. "_slot" .. i
end

  actionbarState.clearExternalSpellAssignContext = function()
	externalAssignSlot = nil
	externalAssignSlotId = nil
	spellAssignListFilter = nil
	onExternalSpellAssignApplied = nil
	onExternalObjectAssignApplied = nil
	onExternalTextAssignApplied = nil
end

function openHelperSpellAssignWindow(slotWidget, slotId, filterFn, onAppliedFn)
	if not slotWidget or not slotId then
		return
	end

	if spellAssignWindow and not spellAssignWindow:isDestroyed() then
		closeSpellAssignWindow()
	end

	externalAssignSlot = slotWidget
	externalAssignSlotId = slotId
	spellAssignListFilter = filterFn
	onExternalSpellAssignApplied = onAppliedFn
	slotToEdit = slotId

	if slotWidget.words and slotWidget.words ~= "" then
		spellAssignPreferredSpellOverride = Spells.getSpellNameByWords(slotWidget.words:lower():trim())
	else
		spellAssignPreferredSpellOverride = nil
	end

	openSpellAssignWindow()
end

function findSlotById(slotId)
	if not slotId then
		return nil, nil
	end

	if externalAssignSlotId and slotId == externalAssignSlotId and externalAssignSlot then
		return externalAssignSlot, nil
	end

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			local s = panel:getChildById(slotId)

			if s then
				return s, i
			end
		end
	end

	return nil, nil
end

  actionbarState.slotBarAndIndexFromSlotId = function(slotId)
	if not slotId then
		return nil, nil
	end

	local only = slotId:match("^slot(%d+)$")

	if only then
		return BAR_BOTTOM_1, tonumber(only)
	end

	local bid, idx = slotId:match("^bar(%d+)_slot(%d+)$")

	if bid and idx then
		return tonumber(bid), tonumber(idx)
	end

	return nil, nil
end

function getSlotBarId(slotId)
	return (actionbarState.slotBarAndIndexFromSlotId(slotId))
end

  actionbarState.actionBarRegionTitle = function(barId)
	if not barId then
		return tr("Action Bar")
	end

	if barId >= BAR_BOTTOM_1 and barId <= BAR_BOTTOM_3 then
		return tr("Bottom Action Bar")
	end

	if barId >= BAR_LEFT_1 and barId <= BAR_LEFT_3 then
		return tr("Left Action Bar")
	end

	if barId >= BAR_RIGHT_1 and barId <= BAR_RIGHT_3 then
		return tr("Right Action Bar")
	end

	return tr("Action Bar")
end

  actionbarState[131] = function(barId)
	if barId >= BAR_BOTTOM_1 and barId <= BAR_BOTTOM_3 then
		return barId
	end

	if barId == BAR_LEFT_3 then
		return 4
	end

	if barId == BAR_LEFT_2 then
		return 5
	end

	if barId == BAR_LEFT_1 then
		return 6
	end

	if barId == BAR_RIGHT_1 then
		return 7
	end

	if barId == BAR_RIGHT_2 then
		return 8
	end

	if barId == BAR_RIGHT_3 then
		return 9
	end

	return barId
end

  actionbarState.actionBarDisplayNumber = function(arg_175_0)
	return actionbarState[131](arg_175_0)
end

  actionbarState.setObjectAssignWindowTitle = function()
	if not objectAssignWindow then
		return
	end

	local var_176_0 = slotToEdit and findSlotById(slotToEdit) or nil
	local var_176_1 = var_176_0 and var_176_0.itemId and var_176_0.itemId > 0
	local var_176_2, var_176_3 = actionbarState.slotBarAndIndexFromSlotId(slotToEdit)

	if var_176_2 and var_176_3 then
		local var_176_4 = actionbarState.actionBarDisplayNumber(var_176_2)

		if var_176_1 then
			objectAssignWindow:setText(tr("Edit Object to Action Button %d.%02d", var_176_4, var_176_3))
		else
			objectAssignWindow:setText(tr("Assign Object to Action Button %d.%02d", var_176_4, var_176_3))
		end
	else
		objectAssignWindow:setText(tr(var_176_1 and "Edit Object" or "Assign Object"))
	end
end

  actionbarState.setTextAssignWindowTitle = function()
	if not textAssignWindow then
		return
	end

	local var_177_0 = slotToEdit and findSlotById(slotToEdit) or nil
	local var_177_1 = var_177_0 and var_177_0.text and var_177_0.text ~= ""
	local var_177_2, var_177_3 = actionbarState.slotBarAndIndexFromSlotId(slotToEdit)

	if var_177_2 and var_177_3 then
		local var_177_4 = actionbarState.actionBarDisplayNumber(var_177_2)

		if var_177_1 then
			textAssignWindow:setText(tr("Edit Text to Action Button %d.%02d", var_177_4, var_177_3))
		else
			textAssignWindow:setText(tr("Assign Text to Action Button %d.%02d", var_177_4, var_177_3))
		end
	else
		textAssignWindow:setText(tr(var_177_1 and "Edit Text" or "Assign Text"))
	end
end

  actionbarState.setSpellAssignWindowTitle = function()
	if not spellAssignWindow then
		return
	end

	local var_178_0 = slotToEdit and findSlotById(slotToEdit) or nil
	local var_178_1 = var_178_0 and var_178_0.words and var_178_0.words ~= ""
	local var_178_2, var_178_3 = actionbarState.slotBarAndIndexFromSlotId(slotToEdit)

	if var_178_2 and var_178_3 then
		local var_178_4 = actionbarState.actionBarDisplayNumber(var_178_2)

		if var_178_1 then
			spellAssignWindow:setText(tr("Edit Spell to Action Button %d.%02d", var_178_4, var_178_3))
		else
			spellAssignWindow:setText(tr("Assign Spell to Action Button %d.%02d", var_178_4, var_178_3))
		end
	else
		spellAssignWindow:setText(tr(var_178_1 and "Edit Spell" or "Assign Spell"))
	end
end

function isCorruptHotkeyTypeName(arg_179_0)
	if type(arg_179_0) ~= "string" then
		return false
	end

	if arg_179_0 == "string" then
		return true
	end

	if arg_179_0 == "number" then
		return true
	end

	if arg_179_0 == "nil" then
		return true
	end

	if arg_179_0 == "boolean" then
		return true
	end

	if arg_179_0 == "table" then
		return true
	end

	if arg_179_0 == "function" then
		return true
	end

	if arg_179_0 == "userdata" then
		return true
	end

	if arg_179_0 == "thread" then
		return true
	end

	return false
end

function hotkeyFieldToString(textValue)
	if textValue == nil then
		return ""
	end

	if type(textValue) ~= "string" then
		textValue = tostring(textValue)
	end

	if textValue == "" then
		return ""
	end

	if isCorruptHotkeyTypeName(textValue) then
		return ""
	end

	return textValue
end

function getSlotHotkeyForChatMode(slot, chatOn)
	if not slot then
		return ""
	end

	if chatOn == nil then
		chatOn = modules.game_console and modules.game_console.isChatEnabled and modules.game_console.isChatEnabled()
	end

	local var_181_0

	if chatOn then
		var_181_0 = slot.hotkeyChatOn
	else
		var_181_0 = slot.hotkeyChatOff
	end

	return hotkeyFieldToString(var_181_0)
end

 actionbarState[136] = {
	useAtCursor = "Use this object at Cursor Position",
	useOnSelf = "Use this object on Yourself",
	equip = "Equip this object",
	use = "Use this object",
	useWith = "Use this object with Crosshair",
	useOnTarget = "Use this object on Target"
}

  actionbarState[137] = function(ms)
	if type(ms) ~= "number" or ms <= 0 then
		return "0s"
	end

	local sec = math.floor(ms / 1000)

	if sec >= 3600 and sec % 3600 == 0 then
		return string.format("%dh", sec / 3600)
	end

	if sec >= 60 and sec % 60 == 0 then
		return string.format("%dmin", sec / 60)
	end

	return string.format("%ds", sec)
end

  actionbarState[138] = function(slot)
	local hk = getSlotHotkeyForChatMode(slot)

	if hk == nil or hk == "" then
		return "None"
	end

	local shown = ActionBarHotkeyLogic.formatHotkeyTooltipText(hk)

	if shown == nil or shown == "" then
		return hk
	end

	return shown
end

  actionbarState[139] = function(arg_184_0)
	if not arg_184_0 then
		return false
	end

	if arg_184_0.words and arg_184_0.words ~= "" then
		return true
	end

	if arg_184_0.text and arg_184_0.text ~= "" then
		return true
	end

	if arg_184_0.passiveId then
		return true
	end

	if isHelperActionSlot(arg_184_0) or isMultiHelperSlot(arg_184_0) then
		return true
	end

	if actionbarState.isActionSlotEquipmentPreset(arg_184_0) then
		return true
	end

	if arg_184_0.itemId and arg_184_0.itemId > 0 and arg_184_0.useType then
		return true
	end

	if slotHasMultiActions and slotHasMultiActions(arg_184_0) then
		return true
	end

	return false
end

  actionbarState[140] = function(arg_185_0)
	if not arg_185_0 then
		return ""
	end

	local var_185_0, var_185_1 = actionbarState.slotBarAndIndexFromSlotId(arg_185_0:getId())
	local formattedText = "Action Button"

	if var_185_0 and var_185_1 then
		formattedText = string.format("Action Button %d.%d", actionbarState.actionBarDisplayNumber(var_185_0), var_185_1)
	end

	local var_185_3 = "Hotkeys: " .. actionbarState[138](arg_185_0)

	if not actionbarState[139](arg_185_0) then
		return formattedText .. "\n\nAction: None\n" .. var_185_3
	end

	if arg_185_0.passiveId and PassiveAbilities[arg_185_0.passiveId] then
		return formattedText .. "\n\nPassive Ability: " .. PassiveAbilities[arg_185_0.passiveId].name .. "\n" .. var_185_3
	end

	if isMultiHelperSlot(arg_185_0) then
		local var_185_4 = {
			formattedText,
			"",
			"Multi-Helper:"
		}
		local var_185_5 = HelperAction.filledEntries(arg_185_0.multiHelper)

		for iter_185_0 = 1, #var_185_5 do
			local var_185_6 = var_185_5[iter_185_0].id
			local item = HelperAction.getItem(var_185_6)
			local var_185_8 = HelperAction.isEnabled(var_185_6) and "Enabled" or "Disabled"

			var_185_4[#var_185_4 + 1] = var_185_5[iter_185_0].index .. ". " .. (item and item.label or var_185_6) .. ": " .. var_185_8
		end

		var_185_4[#var_185_4 + 1] = var_185_3

		return table.concat(var_185_4, "\n")
	end

	if isHelperActionSlot(arg_185_0) then
		local item = HelperAction.getItem(arg_185_0.helperId)
		local var_185_10 = HelperAction.isEnabled(arg_185_0.helperId) and "Enabled" or "Disabled"

		return formattedText .. "\n\nHelper: " .. (item and item.label or arg_185_0.helperId) .. "\nStatus: " .. var_185_10 .. "\n" .. var_185_3
	end

	if arg_185_0.words and arg_185_0.words ~= "" then
		local var_185_11, unusedValue, var_185_13 = Spells.getSpellByWords(arg_185_0.words)
		local var_185_14 = var_185_13 or var_185_11 and var_185_11.name or arg_185_0.words
		local var_185_15 = {
			"Action: Cast " .. var_185_14,
			"Formula: " .. arg_185_0.words
		}

		if var_185_11 and var_185_11.exhaustion then
			table.insert(var_185_15, "Cooldown: " .. actionbarState[137](var_185_11.exhaustion))
		end

		if var_185_11 and var_185_11.mana then
			table.insert(var_185_15, "Mana: " .. tostring(var_185_11.mana))
		end

		table.insert(var_185_15, var_185_3)

		return formattedText .. "\n\n" .. table.concat(var_185_15, "\n")
	end

	if type(arg_185_0.text) == "string" and arg_185_0.text ~= "" then
		return formattedText .. "\n\nAction: Say \"" .. arg_185_0.text .. "\"\nAuto sent: " .. (arg_185_0.autoSend and "Yes" or "No") .. "\n" .. var_185_3
	end

	if actionbarState.isActionSlotEquipmentPreset(arg_185_0) then
		local equipmentDescription = "Equip equipment set"

		if arg_185_0.equipmentDescription and arg_185_0.equipmentDescription ~= "" then
			equipmentDescription = arg_185_0.equipmentDescription
		end

		return formattedText .. "\n\nAction: " .. equipmentDescription .. "\n" .. var_185_3
	end

	if slotHasMultiActions and slotHasMultiActions(arg_185_0) then
		return formattedText .. "\n\nAction: Multi-Action\n" .. var_185_3
	end

	if arg_185_0.itemId and arg_185_0.itemId > 0 and arg_185_0.useType then
		local var_185_17 = actionbarState[136][arg_185_0.useType] or "Use this object"
		local inventoryCount = 0
		local localPlayer = g_game.getLocalPlayer()

		if localPlayer then
			inventoryCount = localPlayer:getInventoryCount(arg_185_0.itemId, actionbarState.actionSlotItemTier(arg_185_0))
		end

		return formattedText .. "\n\nAction: " .. var_185_17 .. "\nAmount: " .. tostring(inventoryCount) .. "\n" .. var_185_3
	end

	return formattedText .. "\n\nAction: None\n" .. var_185_3
end

function refreshActionSlotTooltip(slot)
	if not slot or slot:isDestroyed() or not slot.setTooltip then
		return
	end

	if modules.client_options and modules.client_options.getOption("actionTooltip") == false then
		slot:setTooltip("")

		return
	end

	slot:setTooltip(actionbarState[140](slot))
end

  actionbarState[141] = function(slot, combo)
	local key = slot:getChildById("key")

	if key then
		key:setText(ActionBarHotkeyLogic.formatHotkeySlotText(combo))
	end
end

 actionbarState.syncSlotHotkeyMirror = function(arg_188_0)
	local hotkey = getSlotHotkeyForChatMode(arg_188_0)

	arg_188_0.hotkey = hotkey

	actionbarState[141](arg_188_0, hotkey)
	refreshActionSlotTooltip(arg_188_0)
end

  actionbarState.refreshAllSlotsHotkeyMirror = function()
	for iter_189_0 = 1, NUM_BARS do
		local var_189_0 = actionBarPanels[iter_189_0]

		if var_189_0 then
			for unusedValue, child in pairs(var_189_0:getChildren()) do
				actionbarState.syncSlotHotkeyMirror(child)
			end
		end
	end
end

  actionbarState[143] = function(arg_190_0, arg_190_1)
	local var_190_0 = arg_190_0

	if var_190_0 == nil then
		var_190_0 = arg_190_1
	end

	return hotkeyFieldToString(var_190_0)
end

  actionbarState.initDefaultHotkeysFirstBottomBarSlot = function(arg_191_0, arg_191_1)
	if arg_191_1 >= 1 and arg_191_1 <= 12 then
		local var_191_0 = "F" .. tostring(arg_191_1)

		arg_191_0.hotkeyChatOn = var_191_0
		arg_191_0.hotkeyChatOff = var_191_0
	else
		arg_191_0.hotkeyChatOn = ""
		arg_191_0.hotkeyChatOff = ""
	end

	actionbarState.syncSlotHotkeyMirror(arg_191_0)
end

  actionbarState[145] = function(arg_192_0, arg_192_1)
	local hotkey = arg_192_1.hotkey

	if arg_192_1.hotkeyChatOn ~= nil or arg_192_1.hotkeyChatOff ~= nil or hotkey ~= nil then
		local var_192_1 = isCorruptHotkeyTypeName(arg_192_1.hotkeyChatOn)

		if not var_192_1 and arg_192_1.hotkeyChatOn == nil then
			var_192_1 = isCorruptHotkeyTypeName(hotkey)
		end

		local var_192_2 = isCorruptHotkeyTypeName(arg_192_1.hotkeyChatOff)

		if not var_192_2 and arg_192_1.hotkeyChatOff == nil then
			var_192_2 = isCorruptHotkeyTypeName(hotkey)
		end

		if var_192_1 then
			actionBarCorruptHotkeySeen = true
		elseif var_192_2 then
			actionBarCorruptHotkeySeen = true
		end

		arg_192_0.hotkeyChatOn = actionbarState[143](arg_192_1.hotkeyChatOn, hotkey)
		arg_192_0.hotkeyChatOff = actionbarState[143](arg_192_1.hotkeyChatOff, hotkey)

		local var_192_3 = false

		if var_192_1 then
			var_192_3 = true
		elseif var_192_2 then
			var_192_3 = true
		end

		if var_192_3 and arg_192_0.hotkeyChatOn == "" and arg_192_0.hotkeyChatOff == "" then
			local var_192_4, var_192_5 = actionbarState.slotBarAndIndexFromSlotId(arg_192_0:getId())

			if var_192_4 == BAR_BOTTOM_1 then
				actionbarState.initDefaultHotkeysFirstBottomBarSlot(arg_192_0, var_192_5)

				return
			end
		end
	end

	actionbarState.syncSlotHotkeyMirror(arg_192_0)
end

  actionbarState[146] = function(arg_193_0, arg_193_1)
	if not arg_193_0 or not arg_193_1 then
		return
	end

	actionbarState[145](arg_193_0, arg_193_1)

	if arg_193_1.multiActions and not table.empty(arg_193_1.multiActions) and loadSlotMultiActions then
		loadSlotMultiActions(arg_193_0, arg_193_1.multiActions)

		return
	end

	if initMultiActionSlot then
		initMultiActionSlot(arg_193_0)
	end

	arg_193_0.itemId = arg_193_1.itemId

	arg_193_0:setItemId(arg_193_1.itemId)

	arg_193_0.subType = arg_193_1.subType
	arg_193_0.words = arg_193_1.words
	arg_193_0.text = arg_193_1.text
	arg_193_0.useType = arg_193_1.useType
	arg_193_0.autoSend = arg_193_1.autoSend
	arg_193_0.parameter = arg_193_1.parameter
	arg_193_0.crossHairMode = type(arg_193_1.crossHairMode) == "string" and arg_193_1.crossHairMode or nil

	local getTier = arg_193_1.getTier

	arg_193_0.getTier = type(getTier) == "number" and getTier or nil
	arg_193_0.passiveId = arg_193_1.passiveId
	arg_193_0.helperId = type(arg_193_1.helperId) == "string" and arg_193_1.helperId ~= "" and arg_193_1.helperId or nil
	arg_193_0.multiHelper = HelperAction.normalizeList(arg_193_1.multiHelper)
	arg_193_0.equipmentIconIndex = type(arg_193_1.equipmentIconIndex) == "number" and actionbarState.normalizeEquipmentIconIndex(arg_193_1.equipmentIconIndex) or nil
	arg_193_0.equipmentDescription = arg_193_1.equipmentDescription or ""
	arg_193_0.equipmentTypeIndex = type(arg_193_1.equipmentTypeIndex) == "number" and actionbarState.normalizeEquipmentTypeIndex(arg_193_1.equipmentTypeIndex) or 0
	arg_193_0.smartMode = arg_193_1.smartMode == true and true or nil
	arg_193_0.smartBaseItemId = type(arg_193_1.smartBaseItemId) == "number" and arg_193_1.smartBaseItemId or nil
	arg_193_0.equipments = actionbarState.normalizeEquipmentsFromSetting(arg_193_1.equipments)

	ItemsDatabase.setTier(arg_193_0, arg_193_0.getTier)

	if arg_193_0.words then
		loadSpell(arg_193_0)
	elseif arg_193_0.text then
		loadText(arg_193_0)
	elseif arg_193_0.passiveId then
		loadPassive(arg_193_0)
	elseif arg_193_0.multiHelper then
		loadMultiHelper(arg_193_0)
	elseif arg_193_0.helperId then
		loadHelper(arg_193_0)
	elseif arg_193_0.useType == "equip" then
		if actionbarState.isEquipmentIconDeterminedOnSlot(arg_193_0) or arg_193_0.equipments ~= nil then
			arg_193_0.equipments = arg_193_0.equipments or {}

			local var_193_1 = actionbarState.equipmentAssignDisplayEntry(arg_193_0.equipments)

			if var_193_1 then
				arg_193_0.itemId = var_193_1.itemId
				arg_193_0.getTier = var_193_1.getTier
				arg_193_0.subType = var_193_1.subType
			else
				arg_193_0.itemId = 0
				arg_193_0.getTier = nil
				arg_193_0.subType = nil
			end

			loadEquipmentSetDisplay(arg_193_0)
		elseif arg_193_0.itemId and arg_193_0.itemId > 0 then
			arg_193_0.equipments = nil
			arg_193_0.equipmentIconIndex = nil
			arg_193_0.equipmentDescription = nil
			arg_193_0.equipmentTypeIndex = nil

			loadObject(arg_193_0)
		end
	elseif arg_193_0.itemId and arg_193_0.itemId > 0 then
		loadObject(arg_193_0)
	end
end

function maybeSetupHotkeysAfterSlotLoad()
	if actionBarBatchDepth <= 0 then
		setupHotkeys()
	end
end

  actionbarState.applyPresetSlotsToActionBar = function(arg_195_0)
	if not arg_195_0 then
		return
	end

	for key, entry in pairs(arg_195_0) do
		local var_195_0 = findSlotById(key)

		if var_195_0 then
			actionbarState[146](var_195_0, entry)
		end
	end
end

  actionbarState[148] = function(value)
	local t = type(value)

	if t == "number" or t == "string" or t == "boolean" then
		return value
	end

	return nil
end

  actionbarState.serializeEquipmentsForJson = function(arg_197_0)
	if not arg_197_0 then
		return nil
	end

	local var_197_0 = {}

	for key, entry in pairs(arg_197_0) do
		if type(key) == "number" and entry and entry.itemId and entry.itemId > 0 and not actionbarState.isEquipmentAssignVisualBackpackSlot(key) then
			var_197_0[tostring(key)] = {
				itemId = entry.itemId,
				getTier = type(entry.getTier) == "number" and entry.getTier or nil,
				subType = type(entry.subType) == "number" and entry.subType or nil
			}
		end
	end

	return var_197_0
end

 actionbarState.normalizeEquipmentsFromSetting = function(arg_198_0)
	if arg_198_0 == nil then
		return nil
	end

	if type(arg_198_0) ~= "table" then
		return nil
	end

	local var_198_0 = {}

	for key, entry in pairs(arg_198_0) do
		if type(entry) == "table" and type(entry.itemId) == "number" and entry.itemId > 0 then
			local var_198_1 = type(key) == "number" and key or tonumber(key)

			if var_198_1 and not actionbarState.isEquipmentAssignVisualBackpackSlot(var_198_1) then
				var_198_0[var_198_1] = {
					itemId = entry.itemId,
					getTier = type(entry.getTier) == "number" and entry.getTier or nil,
					subType = type(entry.subType) == "number" and entry.subType or nil
				}
			end
		end
	end

	return var_198_0
end

  actionbarState[150] = function(arg_199_0)
	local getTier = arg_199_0.getTier

	if type(getTier) ~= "number" then
		getTier = nil
	end

	local var_199_1 = hotkeyFieldToString(arg_199_0.hotkeyChatOn)
	local var_199_2 = hotkeyFieldToString(arg_199_0.hotkeyChatOff)

	return {
		hotkeyChatOn = var_199_1,
		hotkeyChatOff = var_199_2,
		autoSend = arg_199_0.autoSend == true and true or (arg_199_0.autoSend ~= false or true) and nil,
		itemId = type(arg_199_0.itemId) == "number" and arg_199_0.itemId or nil,
		subType = type(arg_199_0.subType) == "number" and arg_199_0.subType or nil,
		useType = actionbarState[148](arg_199_0.useType),
		text = actionbarState[148](arg_199_0.text),
		words = actionbarState[148](arg_199_0.words),
		parameter = actionbarState[148](arg_199_0.parameter),
		crossHairMode = type(arg_199_0.crossHairMode) == "string" and arg_199_0.crossHairMode or nil,
		getTier = getTier,
		passiveId = type(arg_199_0.passiveId) == "number" and arg_199_0.passiveId or nil,
		helperId = actionbarState[148](arg_199_0.helperId),
		multiHelper = HelperAction.normalizeList(arg_199_0.multiHelper),
		multiActions = serializeSlotMultiActions and serializeSlotMultiActions(arg_199_0) or nil,
		equipments = arg_199_0.equipments ~= nil and actionbarState.serializeEquipmentsForJson(arg_199_0.equipments) or nil,
		equipmentIconIndex = type(arg_199_0.equipmentIconIndex) == "number" and actionbarState.normalizeEquipmentIconIndex(arg_199_0.equipmentIconIndex) or nil,
		equipmentDescription = actionbarState[148](arg_199_0.equipmentDescription),
		equipmentTypeIndex = type(arg_199_0.equipmentTypeIndex) == "number" and actionbarState.normalizeEquipmentTypeIndex(arg_199_0.equipmentTypeIndex) or nil,
		smartMode = arg_199_0.smartMode == true and true or nil,
		smartBaseItemId = type(arg_199_0.smartBaseItemId) == "number" and arg_199_0.smartBaseItemId or nil
	}
end

  actionbarState.collectCharacterActionBarSlots = function()
	local var_200_0 = {}

	for iter_200_0 = 1, NUM_BARS do
		local var_200_1 = actionBarPanels[iter_200_0]

		if var_200_1 then
			for unusedValue, child in ipairs(var_200_1:getChildren()) do
				var_200_0[child:getId()] = actionbarState[150](child)
			end
		end
	end

	return var_200_0
end

  actionbarState.loadActionBarSettingsForCurrentPreset = function()
	local var_201_0 = getActionBarDefaultPresetName()
	local var_201_1, var_201_2 = getActionBarSlotsForPreset(var_201_0)

	return var_201_1, var_201_2, var_201_0
end

function getCurrentSlot()
	return (findSlotById(slotToEdit))
end

  actionbarState.updateSideContainerWidths = function()
	local leftContainer = modules.game_interface.getActionBarLeftPanel and modules.game_interface.getActionBarLeftPanel()
	local rightContainer = modules.game_interface.getActionBarRightPanel and modules.game_interface.getActionBarRightPanel()

	if leftContainer and not leftContainer:isDestroyed() then
		local w = 0
		local visibleBars = 0

		for _, barId in ipairs({
			BAR_LEFT_1,
			BAR_LEFT_2,
			BAR_LEFT_3
		}) do
			local bar = actionBars[barId]

			if bar and not bar:isDestroyed() and bar:getWidth() > 0 then
				w = w + SIDE_BAR_WIDTH
				visibleBars = visibleBars + 1
			end
		end

		if visibleBars > 1 then
			w = w + SIDE_BAR_SPACING * (visibleBars - 1)
		end

		leftContainer:setWidth(w)
		leftContainer:setVisible(w > 0)
		leftContainer:setPhantom(true)
		leftContainer:setImageSource("/images/ui/background")
		leftContainer:setImageRepeated(true)

		local layout = leftContainer:getLayout()

		if layout and layout.setSpacing then
			layout:setSpacing(SIDE_BAR_SPACING)
		end
	end

	if rightContainer and not rightContainer:isDestroyed() then
		local w = 0
		local visibleBars = 0

		for _, barId in ipairs({
			BAR_RIGHT_1,
			BAR_RIGHT_2,
			BAR_RIGHT_3
		}) do
			local bar = actionBars[barId]

			if bar and not bar:isDestroyed() and bar:getWidth() > 0 then
				w = w + SIDE_BAR_WIDTH
				visibleBars = visibleBars + 1
			end
		end

		if visibleBars > 1 then
			w = w + SIDE_BAR_SPACING * (visibleBars - 1)
		end

		rightContainer:setWidth(w)
		rightContainer:setVisible(w > 0)
		rightContainer:setPhantom(true)
		rightContainer:setImageSource("/images/ui/background")
		rightContainer:setImageRepeated(true)

		local layout = rightContainer:getLayout()

		if layout and layout.setSpacing then
			layout:setSpacing(SIDE_BAR_SPACING)
		end
	end

	if modules.game_interface and modules.game_interface.applyBottomSplitterLayoutHeight then
		modules.game_interface.applyBottomSplitterLayoutHeight()
	end

	if modules.game_interface and modules.game_interface.refreshSidebarLayout then
		modules.game_interface.refreshSidebarLayout()
		scheduleEvent(function()
			if modules.game_interface and modules.game_interface.refreshSidebarLayout then
				modules.game_interface.refreshSidebarLayout()
			end
		end, 0)
	end
end

  actionbarState[154] = function(arg_205_0)
	local game_interface = modules.game_interface

	if not game_interface or not game_interface[arg_205_0] then
		return false
	end

	local var_205_1 = game_interface[arg_205_0]()

	return var_205_1 and not var_205_1:isDestroyed() and var_205_1:isVisible() and (tonumber(var_205_1:getWidth()) or 0) > 0
end

  actionbarState[155] = function(arg_206_0)
	if actionbarState.isLeftBar(arg_206_0) and actionbarState[154]("getGameLeftStatsBar") then
		return 0
	end

	if actionbarState.isRightBar(arg_206_0) and actionbarState[154]("getGameRightStatsBar") then
		return 0
	end

	local height = 54

	if g_settings.getString("statsbar_placement") ~= "top" then
		return height
	end

	local gameTopStatsBar = modules.game_interface.getGameTopStatsBar and modules.game_interface.getGameTopStatsBar()

	if gameTopStatsBar and not gameTopStatsBar:isDestroyed() and gameTopStatsBar:isVisible() then
		height = math.max(height, gameTopStatsBar:getHeight())
	end

	return height
end

function refreshSideActionBarOffsets()
	for unusedValue, iter_207_1 in ipairs({
		BAR_LEFT_1,
		BAR_LEFT_2,
		BAR_LEFT_3,
		BAR_RIGHT_1,
		BAR_RIGHT_2,
		BAR_RIGHT_3
	}) do
		local var_207_0 = actionBars[iter_207_1]

		if var_207_0 and not var_207_0:isDestroyed() then
			local var_207_1 = barWidgetChild(var_207_0, "prevButton")

			if var_207_1 then
				var_207_1:setMarginTop(actionbarState[155](iter_207_1))
			end
		end
	end
end

function clipSideBarPanelToWholeSlots(arg_208_0)
	if not arg_208_0 or arg_208_0:isDestroyed() then
		return
	end

	local height = arg_208_0:getHeight()
	local var_208_1 = math.max(height - height % actionbarState[3], 1)
	local var_208_2 = math.max(height - var_208_1, 0)

	if arg_208_0:getPaddingBottom() ~= var_208_2 then
		arg_208_0:setPaddingBottom(var_208_2)
	end

	local verticalScrollBar = arg_208_0.verticalScrollBar
	local maximum = verticalScrollBar and verticalScrollBar:getMaximum()

	arg_208_0:updateScrollBars()

	if verticalScrollBar and verticalScrollBar:getMaximum() ~= maximum then
		updateScrollButtonsForBar(arg_208_0:getParent())
	end
end

  actionbarState[156] = function(barId)
	if barId <= BAR_BOTTOM_1 then
		return "parent", AnchorTop
	end

	for prev = barId - 1, BAR_BOTTOM_1, -1 do
		local b = actionBars[prev]

		if b and not b:isDestroyed() and b:isVisible() and b:getHeight() > 0 then
			return b:getId(), AnchorBottom
		end
	end

	return "parent", AnchorTop
end

  actionbarState.applyBottomAnchors = function()
	for unusedValue, iter_210_1 in ipairs({
		BAR_BOTTOM_1,
		BAR_BOTTOM_2,
		BAR_BOTTOM_3
	}) do
		local var_210_0 = actionBars[iter_210_1]

		if var_210_0 and not var_210_0:isDestroyed() then
			var_210_0:breakAnchors()
			var_210_0:addAnchor(AnchorLeft, "parent", AnchorLeft)
			var_210_0:addAnchor(AnchorRight, "parent", AnchorRight)

			local var_210_1, var_210_2 = actionbarState[156](iter_210_1)

			var_210_0:addAnchor(AnchorTop, var_210_1, var_210_2)
		end
	end

	layoutBottomLockButton()
	actionbarState.anchorGroupCooldownBelowBottomStack()
end

  actionbarState[158] = function(_actionBarId, parentWidget)
	local styleName = actionbarState.isSideBar(_actionBarId) and "ActionSlotV" or "ActionSlot"
	local var_211_1 = actionbarState[120](_actionBarId)

	for iter_211_0 = 1, var_211_1 do
		local sid = slotIdFor(_actionBarId, iter_211_0)
		local var_211_3 = g_ui.createWidget(styleName, parentWidget)

		var_211_3:setId(sid)

		var_211_3._actionBarId = _actionBarId

		if initMultiActionSlot then
			initMultiActionSlot(var_211_3)
		end

		var_211_3:setVisible(true)

		var_211_3.itemId = nil
		var_211_3.subType = nil
		var_211_3.words = nil
		var_211_3.text = nil
		var_211_3.useType = nil
		var_211_3.getTier = nil
		var_211_3.helperId = nil
		var_211_3.multiHelper = nil

		if _actionBarId == BAR_BOTTOM_1 then
			actionbarState.initDefaultHotkeysFirstBottomBarSlot(var_211_3, iter_211_0)
		else
			var_211_3.hotkeyChatOn = ""
			var_211_3.hotkeyChatOff = ""
			var_211_3.hotkey = ""

			actionbarState.syncSlotHotkeyMirror(var_211_3)
		end

		g_mouse.bindPress(var_211_3, function()
			slotToEdit = sid
		end, MouseLeftButton)
		g_mouse.bindPress(var_211_3, function()
			createMenu(sid)
		end, MouseRightButton)

		if not isActionBarLocked(_actionBarId) then
			g_mouse.bindOnDrop(var_211_3, function()
				local pressedWidget = g_ui.getPressedWidget()

				if pressedWidget and pressedWidget ~= var_211_3 and pressedWidget.multiActionIndex and pressedWidget.parentSlot and handleDropFromMultiSubSlotOntoSlot then
					handleDropFromMultiSubSlotOntoSlot(pressedWidget, sid)

					return
				end

				if pressedWidget and pressedWidget ~= var_211_3 and pressedWidget.multiHelperIndex and pressedWidget.parentSlot then
					HelperAction.handleDropFromSubSlotOntoSlot(pressedWidget, sid)

					return
				end

				if slotToEdit == sid then
					slotReassign = sid
				end

				onDropFunc(sid)
			end)
		end

		if iter_211_0 == 1 then
			var_211_3:breakAnchors()

			if actionbarState.isSideBar(_actionBarId) then
				var_211_3:addAnchor(AnchorTop, "parent", AnchorTop)
				var_211_3:addAnchor(AnchorLeft, "parent", AnchorLeft)
				var_211_3:setMarginTop(2)
			else
				var_211_3:addAnchor(AnchorLeft, "parent", AnchorLeft)
				var_211_3:addAnchor(AnchorTop, "parent", AnchorTop)
				var_211_3:setMarginLeft(2)
			end
		end
	end
end

function actionBarPanelHasExpectedSlots(barId, panel)
	if not panel or panel:isDestroyed() then
		return false
	end

	local var_215_0 = actionbarState[120](barId)

	if #panel:getChildren() ~= var_215_0 then
		return false
	end

	for iter_215_0 = 1, var_215_0 do
		if not panel:getChildById(slotIdFor(barId, iter_215_0)) then
			return false
		end
	end

	return true
end

function ensureActionBarPanelSlots(barId, panel)
	if actionBarPanelHasExpectedSlots(barId, panel) then
		return false
	end

	panel:destroyChildren()
	actionbarState[158](barId, panel)

	return true
end

  actionbarState.loadSavedSlotsForBar = function(arg_217_0)
	if not actionBarPanels[arg_217_0] then
		return
	end

	local var_217_0 = actionbarState.loadActionBarSettingsForCurrentPreset()

	if not var_217_0 then
		return
	end

	for key, entry in pairs(var_217_0) do
		local childById = actionBarPanels[arg_217_0]:getChildById(key)

		if childById then
			actionbarState[146](childById, entry)
		end
	end
end

  actionbarState.ensureBarLoaded = function(barId)
	if actionBars[barId] then
		return actionBars[barId]
	end

	if not bottomPanel then
		bottomPanel = modules.game_interface.getBottomPanel()
	end

	local var_218_0
	local bar

	if actionbarState.isSideBar(barId) then
		local var_218_2

		if actionbarState.isLeftBar(barId) then
			var_218_2 = modules.game_interface.getActionBarLeftPanel and modules.game_interface.getActionBarLeftPanel()
		else
			var_218_2 = modules.game_interface.getActionBarRightPanel and modules.game_interface.getActionBarRightPanel()
		end

		if not var_218_2 then
			return nil
		end

		var_218_0, bar = pcall(g_ui.loadUI, "game_actionbar_side", var_218_2)
	else
		var_218_0, bar = pcall(g_ui.loadUI, "game_actionbar", bottomPanel)
	end

	if not var_218_0 or not bar then
		return nil
	end

	bar:setId("actionBar" .. barId)
	bar:setVisible(false)

	if actionbarState.isSideBar(barId) then
		bar:setWidth(0)
		bar:setImageSource("/images/ui/background")
		bar:setImageRepeated(true)
		bar:setClipping(false)
	else
		bar:setHeight(0)
	end

	actionBars[barId] = bar
	actionBarPanels[barId] = barWidgetChild(bar, "actionBarPanel")

	if actionBarPanels[barId] then
		actionBarPanels[barId].onMouseWheel = function()
			return true
		end
	end

	if actionbarState.isSideBar(barId) then
		local var_218_3 = barWidgetChild(bar, "verticalScroll")

		if var_218_3 then
			function var_218_3.onMouseWheel()
				return true
			end
		end
	else
		local var_218_4 = barWidgetChild(bar, "horizontalScroll")

		if var_218_4 then
			function var_218_4.onMouseWheel()
				return true
			end
		end
	end

	if actionbarState.isBottomBar(barId) then
		actionbarState.applyBottomAnchors()
	end

	if actionbarState.isSideBar(barId) then
		local marginTop = actionbarState[155](barId)
		local var_218_6 = actionbarState.isRightBar(barId) and 2 or 0
		local marginLeft = actionbarState.isRightBar(barId) and 2 or 0
		local marginRight = actionbarState.isLeftBar(barId) and 2 or 0
		local var_218_9 = barWidgetChild(bar, "prevButton")

		if var_218_9 then
			var_218_9:setMarginTop(marginTop)
			var_218_9:setMarginLeft(marginLeft)
		end

		local var_218_10 = barWidgetChild(bar, "sideLockButton")

		if var_218_10 then
			var_218_10:setMarginLeft(var_218_6)
			var_218_10:setMarginBottom(1)
		end

		local var_218_11 = barWidgetChild(bar, "nextButton")

		if var_218_11 then
			var_218_11:setMarginBottom(1)
		end

		local var_218_12 = barWidgetChild(bar, "nextSkipButton")

		if var_218_12 then
			var_218_12:setMarginRight(marginRight)
			var_218_12:setMarginBottom(1)
		end

		local var_218_13 = barWidgetChild(bar, "actionBarPanel")

		if var_218_13 then
			var_218_13:setMarginTop(1)
			var_218_13:setMarginLeft(var_218_6)

			var_218_13.onLayoutUpdate = clipSideBarPanelToWholeSlots
		end

		local var_218_14 = barWidgetChild(bar, "verticalScroll")

		if var_218_14 then
			var_218_14:setMarginTop(0)
		end
	end

	if actionbarState.isLeftBar(barId) then
		normalizeSideBarChildOrder("left")
	elseif actionbarState.isRightBar(barId) then
		normalizeSideBarChildOrder("right")
	end

	if actionBarPanels[barId] then
		ensureActionBarPanelSlots(barId, actionBarPanels[barId])

		if g_game.isOnline() then
			actionbarState.loadSavedSlotsForBar(barId)
			setupHotkeys()
		end
	end

	return bar
end

actionBarVisibilityKeybinds = {
	{
		option = "actionBarShowBottom1",
		action = "Show/hide Bottom Action Bar 1"
	},
	{
		option = "actionBarShowBottom2",
		action = "Show/hide Bottom Action Bar 2"
	},
	{
		option = "actionBarShowBottom3",
		action = "Show/hide Bottom Action Bar 3"
	},
	{
		option = "actionBarShowLeft1",
		action = "Show/hide Left Action Bar 1"
	},
	{
		option = "actionBarShowLeft2",
		action = "Show/hide Left Action Bar 2"
	},
	{
		option = "actionBarShowLeft3",
		action = "Show/hide Left Action Bar 3"
	},
	{
		option = "allActionBar46",
		action = "Show/hide Left Action Bars"
	},
	{
		option = "actionBarShowRight1",
		action = "Show/hide Right Action Bar 1"
	},
	{
		option = "actionBarShowRight2",
		action = "Show/hide Right Action Bar 2"
	},
	{
		option = "actionBarShowRight3",
		action = "Show/hide Right Action Bar 3"
	},
	{
		option = "allActionBar79",
		action = "Show/hide Right Action Bars"
	}
}

function init()
	HelperAction.registerShaders()

	if initMultiActionStyles then
		initMultiActionStyles()
	end

	bottomPanel = modules.game_interface.getBottomPanel()
	actionBars[BAR_BOTTOM_1] = g_ui.loadUI("game_actionbar", bottomPanel)

	actionBars[BAR_BOTTOM_1]:setId("actionBar1")

	actionBarPanels[BAR_BOTTOM_1] = barWidgetChild(actionBars[BAR_BOTTOM_1], "actionBarPanel")
	actionBar = actionBars[BAR_BOTTOM_1]
	actionBarPanel = actionBarPanels[BAR_BOTTOM_1]

	if actionBarPanel then
		function actionBarPanel.onMouseWheel()
			return true
		end

		ensureActionBarPanelSlots(BAR_BOTTOM_1, actionBarPanel)
	end

	local hScroll1 = barWidgetChild(actionBars[BAR_BOTTOM_1], "horizontalScroll")

	if hScroll1 then
		function hScroll1.onMouseWheel()
			return true
		end
	end

	setupBottomLockButton()

	actionBarPreloadEvent = scheduleEvent(function()
		actionBarPreloadEvent = nil

		if prepareActionBarForLogin then
			prepareActionBarForLogin()
		end
	end, 300)
	mouseGrabberWidget = g_ui.createWidget("UIWidget")

	mouseGrabberWidget:setVisible(false)
	mouseGrabberWidget:setFocusable(false)

	mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease

	if g_game.isOnline() then
		addEvent(function()
			online()
			setupActionBar()
			loadActionBar()
		end)
	end

	connect(g_game, {
		onGameStart = online,
		onGameEnd = offline,
		onPassiveData = onPassiveData,
		onSpellGroupCooldown = onSpellGroupCooldown,
		onSpellCooldown = onSpellCooldown,
		onMultiUseCooldown = onMultiUseCooldown,
		onVirtuesYellowBorder = onVirtuesYellowBorder
	})
	connect(LocalPlayer, {
		onInventoryChange = scheduleFullSlotGrayRefresh,
		onInventoryCountChange = scheduleInventorySlotGrayRefresh,
		onManaChange = actionbarState.onLocalPlayerManaChange,
		onLevelChange = scheduleFullSlotGrayRefresh
	})
	connect(Container, {
		onAddItem = scheduleInventorySlotGrayRefresh,
		onUpdateItem = scheduleInventorySlotGrayRefresh,
		onRemoveItem = scheduleInventorySlotGrayRefresh
	})

	if Keybind then
		function Keybind.isKeyComboUsedOnActionBar(keyCombo, chatMode)
			if not keyCombo or keyCombo == "" then
				return false
			end

			return isKeyComboUsedOnActionBar(keyCombo, chatMode == CHAT_MODE.ON)
		end

		function Keybind.clearActionBarHotkeyConflicts(keyCombo, chatMode)
			if not keyCombo or keyCombo == "" then
				return false
			end

			return clearActionBarHotkeyConflicts(keyCombo, chatMode == CHAT_MODE.ON)
		end

		for unusedValue, actionBarVisibilityKeybind in ipairs(actionBarVisibilityKeybinds) do
			local option = actionBarVisibilityKeybind.option

			Keybind.new("Action Bar", actionBarVisibilityKeybind.action, "", "")
			Keybind.bind("Action Bar", actionBarVisibilityKeybind.action, {
				{
					type = KEY_DOWN,
					callback = function()
						if not g_game.isOnline() or not modules.client_options then
							return false
						end

						local var_229_0 = modules.client_options.getOption(option) == true

						modules.client_options.setOption(option, not var_229_0)

						return true
					end
				}
			}, modules.game_interface.getRootPanel())
		end
	end

	modules.game_actionbar.replaceActionBarPresetSlots = replaceActionBarPresetSlots
	modules.game_actionbar.invalidateActionBarSettingsCache = invalidateActionBarSettingsCache
	modules.game_actionbar.markPresetsMigrationComplete = markActionBarPresetsMigrationComplete
	modules.game_actionbar.loadActionBar = loadActionBar
	modules.game_actionbar.reloadActionBarForPreset = reloadActionBarForPreset
	modules.game_actionbar.copyActionBarPreset = copyActionBarPreset
	modules.game_actionbar.renameActionBarPreset = renameActionBarPreset
	modules.game_actionbar.removeActionBarPreset = removeActionBarPreset
	modules.game_actionbar.onHotkeyPresetChanged = onHotkeyPresetChanged
end

function terminate()
	if Keybind then
		for unusedValue, actionBarVisibilityKeybind in ipairs(actionBarVisibilityKeybinds) do
			Keybind.delete("Action Bar", actionBarVisibilityKeybind.action)
		end
	end

	if actionBarPreloadEvent then
		removeEvent(actionBarPreloadEvent)

		actionBarPreloadEvent = nil
	end

	if terminateMultiAction then
		terminateMultiAction()
	end

	if closeCurrentMultiHelperPanel then
		closeCurrentMultiHelperPanel()
	end

	if bottomLockPressDeferredEvent then
		removeEvent(bottomLockPressDeferredEvent)

		bottomLockPressDeferredEvent = nil
	end

	if actionbarState.slotGrayRefreshEvent then
		removeEvent(actionbarState.slotGrayRefreshEvent)

		actionbarState.slotGrayRefreshEvent = nil
	end

	slotGrayFullRefreshPending = false
	slotGrayStatsPendingSlots = {}
	slotGrayInventoryRefreshPending = false

	disconnect(LocalPlayer, {
		onInventoryChange = scheduleFullSlotGrayRefresh,
		onInventoryCountChange = scheduleInventorySlotGrayRefresh,
		onManaChange = actionbarState.onLocalPlayerManaChange,
		onLevelChange = scheduleFullSlotGrayRefresh
	})
	disconnect(Container, {
		onAddItem = scheduleInventorySlotGrayRefresh,
		onUpdateItem = scheduleInventorySlotGrayRefresh,
		onRemoveItem = scheduleInventorySlotGrayRefresh
	})

	bottomLockButton = nil
	slotToEdit = nil
	slotReassign = nil
	missedSlotToEdit = nil

	for i = 1, NUM_BARS do
		if actionBars[i] then
			actionBars[i]:destroy()

			actionBars[i] = nil
			actionBarPanels[i] = nil
		end
	end

	actionBar = nil
	actionBarPanel = nil

	mouseGrabberWidget:destroy()
	disconnect(g_game, {
		onGameStart = online,
		onGameEnd = offline,
		onPassiveData = onPassiveData,
		onSpellGroupCooldown = onSpellGroupCooldown,
		onSpellCooldown = onSpellCooldown,
		onMultiUseCooldown = onMultiUseCooldown,
		onVirtuesYellowBorder = onVirtuesYellowBorder
	})

	if spellAssignWindow then
		closeSpellAssignWindow()
	end

	if objectAssignWindow then
		closeObjectAssignWindow()
	end

	if textAssignWindow then
		closeTextAssignWindow()
	end

	if equipmentAssignWindow then
		closeEquipmentAssignWindow()
	end

	if editHotkeyWindow then
		closeEditHotkeyWindow()
	end

	if spellsPanel then
		disconnect(spellsPanel, {
			onChildFocusChange = function(self, focusedChild)
				if focusedChild == nil then
					return
				end

				updatePreviewSpell(focusedChild)
			end
		})
	end
end

function online()
	invalidateActionBarSettingsCache()
	actionbarState.anchorGroupCooldownBelowBottomStack()

	slotToEdit = nil
	slotReassign = nil
	missedSlotToEdit = nil

	if terminateMultiAction then
		terminateMultiAction()
	end

	addEvent(function()
		local startedAt = g_clock.realMillis()

		setupActionBar()

		local presetName = Keybind.currentPreset
		local reusedPreparedPreset = actionBarPreparedPreset == presetName

		if reusedPreparedPreset then
			setupHotkeys()
			applyClientOptionsToActionBar()
			refreshAllVirtueYellowBorders()
			updateSlotsVocation()

			if actionBarCorruptHotkeySeen then
				saveActionBar()

				actionBarCorruptHotkeySeen = false
			end
		else
			reloadActionBarForPreset(presetName, nil)
		end

		g_logger.info(string.format("[login] actionbar ready in %d ms (preloaded=%s)", g_clock.realMillis() - startedAt, tostring(reusedPreparedPreset)))
	end)
end

function offline()
	if closeCurrentMultiActionPanel then
		closeCurrentMultiActionPanel()
	end

	passiveCooldownData = nil

	if refreshAllPassiveCooldownSlots then
		refreshAllPassiveCooldownSlots()
	end

	virtuesYellowBorderSpellIds = {}
	actionbarState.managedVirtueYellowBorderSpellIds = {}
	actionbarState.managedVirtueYellowBorderSelection = {}

	if not g_settings or not g_settings.getBoolean("cip_import_skip_session_save") then
		saveActionBar()
	end

	unbindHotkeys()
	invalidateActionBarSettingsCache()
end

 actionbarState.DRAG_PREVIEW_CHILD_IDS = {
	"count",
	"tier",
	"spellIcon",
	"gray",
	"text",
	"spellParameter",
	"multiIcon",
	"equipmentTypeIcon",
	"helperBorder",
	"activeSpell"
}

  actionbarState.copyDragPreviewChild = function(srcChild, dstChild)
	if not srcChild or not dstChild then
		return
	end

	if srcChild:isDestroyed() or dstChild:isDestroyed() then
		return
	end

	local visible = srcChild:isVisible()

	dstChild:setVisible(visible)

	if not visible then
		if dstChild.setText then
			pcall(dstChild.setText, dstChild, "")
		end

		return
	end

	if srcChild.getText and dstChild.setText then
		local ok, txt = pcall(srcChild.getText, srcChild)

		if ok and txt ~= nil then
			dstChild:setText(txt)
		end
	end

	local imgSrc = srcChild:getImageSource()

	if imgSrc and imgSrc ~= "" then
		dstChild:setImageSource(imgSrc)

		local clip = srcChild:getImageClip()

		if clip then
			dstChild:setImageClip(clip)
		end
	end

	if srcChild.getMarginLeft and dstChild.setMarginLeft then
		local ok2, m = pcall(srcChild.getMarginLeft, srcChild)

		if ok2 and type(m) == "number" then
			dstChild:setMarginLeft(m)
		end
	end
end

function applyDragPreviewFromSlot(sourceSlot, previewSlot)
	if not sourceSlot or not previewSlot then
		return
	end

	if sourceSlot:isDestroyed() or previewSlot:isDestroyed() then
		return
	end

	previewSlot:setImageSource(sourceSlot:getImageSource())

	local sourceImage = sourceSlot:getImageSource()

	if sourceSlot._actionBarFilledFrame or sourceImage == actionbarState.SLOT_IMG_FILLED then
		previewSlot:setImageClip(actionbarState.SLOT_CLIP_FILLED_NORMAL)
	else
		local frameClip = sourceSlot:getImageClip()

		if frameClip then
			previewSlot:setImageClip(frameClip)
		end
	end

	local srcItem = sourceSlot:getItem()

	if srcItem then
		previewSlot:setItem(srcItem)
	else
		previewSlot:setItem(nil)
	end

	for _, id in ipairs(actionbarState.DRAG_PREVIEW_CHILD_IDS) do
		actionbarState.copyDragPreviewChild(sourceSlot:getChildById(id), previewSlot:getChildById(id))
	end

	previewSlot.words = sourceSlot.words
	previewSlot.parameter = sourceSlot.parameter
	previewSlot.itemId = sourceSlot.itemId
	previewSlot.subType = sourceSlot.subType
	previewSlot.useType = sourceSlot.useType
	previewSlot.getTier = sourceSlot.getTier
	previewSlot.text = sourceSlot.text
	previewSlot.helperId = sourceSlot.helperId

	HelperAction.clearIcons(previewSlot)

	previewSlot.multiHelper = HelperAction.copyList(sourceSlot.multiHelper)
	previewSlot.multiActions = sourceSlot.multiActions

	if isMultiHelperSlot(previewSlot) then
		loadMultiHelper(previewSlot)
	end

	if clearSlotProgressWidgets then
		clearSlotProgressWidgets(previewSlot)
	end

	if refreshMultiActionSlotCooldownDisplay then
		refreshMultiActionSlotCooldownDisplay(previewSlot, false)
	end
end

function hideSourceSlotForDrag(sourceSlot)
	if not sourceSlot or sourceSlot:isDestroyed() then
		return
	end

	if sourceSlot._multiPanelOpen and closeCurrentMultiActionPanel then
		closeCurrentMultiActionPanel()
	end

	if sourceSlot._multiHelperPanelOpen and closeCurrentMultiHelperPanel then
		closeCurrentMultiHelperPanel()
	end

	local existing = sourceSlot._dragSourceOverlay

	if existing and not existing:isDestroyed() then
		return
	end

	local rootW = rootWidget or g_ui.getRootWidget()

	if not rootW then
		return
	end

	local overlay = g_ui.createWidget("UIWidget", rootW)

	overlay:setId("dragSourceOverlay")
	overlay:setPhantom(true)
	overlay:setFocusable(false)
	overlay:setDraggable(false)
	overlay:setSize(sourceSlot:getSize())
	overlay:setPosition(sourceSlot:getPosition())
	overlay:setImageSource(actionbarState.SLOT_IMG_EMPTY)
	overlay:setImageSize({
		width = 34,
		height = 34
	})
	overlay:setImageClip(actionbarState.SLOT_CLIP_EMPTY)
	overlay:setBackgroundColor("#1a1a1aff")
	overlay:setBorderWidth(1)
	overlay:setBorderColor("#ffffff")
	overlay:raise()

	local srcKey = sourceSlot:getChildById("key")

	if srcKey and not srcKey:isDestroyed() and srcKey:isVisible() then
		local keyText = ""
		local ok, txt = pcall(srcKey.getText, srcKey)

		if ok and type(txt) == "string" then
			keyText = txt
		end

		if keyText ~= "" then
			local keyLabel = g_ui.createWidget("UILabel", overlay)

			keyLabel:setId("key")
			keyLabel:setPhantom(true)
			keyLabel:setFocusable(false)
			keyLabel:setDraggable(false)
			keyLabel:setFont("Verdana-8px-outline")
			keyLabel:setColor("#ffffff")
			keyLabel:setTextAutoResize(true)
			keyLabel:setText(keyText)
			keyLabel:addAnchor(AnchorTop, "parent", AnchorTop)
			keyLabel:addAnchor(AnchorRight, "parent", AnchorRight)
			keyLabel:setMarginRight(1)
		end
	end

	sourceSlot._dragSourceOverlay = overlay
end

function restoreSourceSlotAfterDrag(sourceSlot)
	if not sourceSlot or sourceSlot:isDestroyed() then
		return
	end

	local overlay = sourceSlot._dragSourceOverlay

	if overlay and not overlay:isDestroyed() then
		overlay:destroy()
	end

	sourceSlot._dragSourceOverlay = nil

	refreshActionSlotVirtueBorder(sourceSlot)
end

function clearDragPreviewSlot(previewSlot)
	if not previewSlot or previewSlot:isDestroyed() then
		return
	end

	previewSlot:setItem(nil)

	for _, id in ipairs(actionbarState.DRAG_PREVIEW_CHILD_IDS) do
		local child = previewSlot:getChildById(id)

		if child and not child:isDestroyed() then
			child:setVisible(false)

			if child.setText then
				pcall(child.setText, child, "")
			end
		end
	end

	if clearSlotProgressWidgets then
		clearSlotProgressWidgets(previewSlot)
	end

	previewSlot.words = nil
	previewSlot.parameter = nil
	previewSlot.itemId = nil
	previewSlot.subType = nil
	previewSlot.useType = nil
	previewSlot.getTier = nil
	previewSlot.text = nil
	previewSlot.helperId = nil
	previewSlot.multiHelper = nil

	HelperAction.clearIcons(previewSlot)

	previewSlot.multiActions = nil
end

  actionbarState.clearCopiedSlotMultiActions = function(slot)
	if detachMultiActionFromSlot then
		detachMultiActionFromSlot(slot)

		return
	end

	slot.multiActions = nil

	local icon = slot:getChildById("multiIcon")

	if icon then
		icon:setVisible(false)
	end
end

  actionbarState.copySlotMultiActions = function(arg_241_0, arg_241_1)
	if not arg_241_1 then
		return
	end

	if slotHasMultiActions and slotHasMultiActions(arg_241_0) and serializeSlotMultiActions and loadSlotMultiActions then
		local var_241_0 = serializeSlotMultiActions(arg_241_0)

		if var_241_0 then
			loadSlotMultiActions(arg_241_1, var_241_0)

			return
		end
	end

	actionbarState.clearCopiedSlotMultiActions(arg_241_1)
end

  actionbarState.copySlotEquipmentPreset = function(fromSlot, toSlot)
	if not toSlot then
		return
	end

	if not actionbarState.isActionSlotEquipmentPreset(fromSlot) then
		toSlot.equipments = nil
		toSlot.equipmentIconIndex = nil
		toSlot.equipmentDescription = nil
		toSlot.equipmentTypeIndex = nil

		return
	end

	if actionbarState.serializeEquipmentsForJson and actionbarState.normalizeEquipmentsFromSetting then
		toSlot.equipments = actionbarState.normalizeEquipmentsFromSetting(actionbarState.serializeEquipmentsForJson(fromSlot.equipments))
	else
		toSlot.equipments = nil
	end

	if fromSlot.equipments ~= nil and toSlot.equipments == nil then
		toSlot.equipments = {}
	end

	toSlot.equipmentIconIndex = type(fromSlot.equipmentIconIndex) == "number" and actionbarState.normalizeEquipmentIconIndex(fromSlot.equipmentIconIndex) or nil
	toSlot.equipmentDescription = fromSlot.equipmentDescription or ""
	toSlot.equipmentTypeIndex = type(fromSlot.equipmentTypeIndex) == "number" and actionbarState.normalizeEquipmentTypeIndex(fromSlot.equipmentTypeIndex) or 0
end

function copySlot(fromSlotId, toSlotId, visible)
	local fromSlot, fromBar = findSlotById(fromSlotId)

	if not fromSlot then
		return
	end

	local tmpslot = findSlotById(toSlotId)
	local destAlreadyExisted = tmpslot ~= nil
	local savedHotkeyOn
	local savedHotkeyOff

	if destAlreadyExisted then
		savedHotkeyOn = tmpslot.hotkeyChatOn or ""
		savedHotkeyOff = tmpslot.hotkeyChatOff or ""
	end

	if not tmpslot then
		local panel = actionBarPanels[fromBar]
		local template = actionbarState.isSideBar(fromBar) and "ActionSlotV" or "ActionSlot"

		tmpslot = g_ui.createWidget(template, panel)

		tmpslot:setId(toSlotId)
	end

	tmpslot:setVisible(visible)
	tmpslot:setImageSource(fromSlot:getImageSource())
	tmpslot:setImageClip(fromSlot:getImageClip())

	local tmpItem = fromSlot:getItem()

	if tmpItem then
		tmpslot:setItem(tmpItem)
	else
		tmpslot:setItem(nil)
	end

	tmpslot:setText(fromSlot:getText())

	tmpslot.autoSend = fromSlot.autoSend
	tmpslot.itemId = fromSlot.itemId
	tmpslot.subType = fromSlot.subType
	tmpslot.words = fromSlot.words
	tmpslot.text = fromSlot.text
	tmpslot.parameter = fromSlot.parameter
	tmpslot.useType = fromSlot.useType
	tmpslot.getTier = fromSlot.getTier
	tmpslot.passiveId = fromSlot.passiveId
	tmpslot.helperId = fromSlot.helperId

	HelperAction.clearIcons(tmpslot)

	tmpslot.multiHelper = HelperAction.copyList(fromSlot.multiHelper)
	tmpslot.smartMode = fromSlot.smartMode
	tmpslot.smartBaseItemId = fromSlot.smartBaseItemId

	actionbarState.copySlotEquipmentPreset(fromSlot, tmpslot)

	if destAlreadyExisted then
		tmpslot.hotkeyChatOn = savedHotkeyOn
		tmpslot.hotkeyChatOff = savedHotkeyOff
	else
		tmpslot.hotkeyChatOn = fromSlot.hotkeyChatOn or ""
		tmpslot.hotkeyChatOff = fromSlot.hotkeyChatOff or ""
	end

	actionbarState.syncSlotHotkeyMirror(tmpslot)
	tmpslot:getChildById("text"):setText(fromSlot:getChildById("text"):getText())
	tmpslot:setTooltip(fromSlot:getTooltip())

	local toSpellIcon = tmpslot:getChildById("spellIcon")

	if toSpellIcon then
		toSpellIcon:hide()
		toSpellIcon:setImageSource("")
	end

	if tmpslot.words and tmpslot.words ~= "" and toSpellIcon then
		local spell, profile, spellName = Spells.getSpellByWords(tmpslot.words)

		if spellName and profile then
			local iconId = tonumber(Spells.getClientId(spellName))

			toSpellIcon:setImageSource(Spells.getIconFileByProfile(profile))
			toSpellIcon:setImageClip(Spells.getImageClip(iconId, profile))
			toSpellIcon:show()
		end
	elseif tmpslot.passiveId and toSpellIcon then
		local passiveData = PassiveAbilities[tmpslot.passiveId]

		if passiveData then
			toSpellIcon:setImageSource(passiveData.icon)
			toSpellIcon:setImageClip("0 0 32 32")
			toSpellIcon:show()
		end
	elseif isMultiHelperSlot(tmpslot) then
		loadMultiHelper(tmpslot)
	elseif tmpslot.helperId then
		loadHelper(tmpslot)
	end

	actionbarState.copySlotMultiActions(fromSlot, tmpslot)

	if actionbarState.isActionSlotEquipmentPreset(tmpslot) then
		loadEquipmentSetDisplay(tmpslot)
	end

	applyActionSlotFrame(tmpslot)
	updateSlotGray(tmpslot)
	refreshActionSlotVirtueBorder(tmpslot)
	ItemsDatabase.setTier(tmpslot, tmpslot.getTier or 0)
end

function onDropFunc(slotId)
	if isActionBarLocked(getSlotBarId(slotId)) then
		return
	end

	if slotReassign then
		local fromSlotId = slotToEdit
		local toSlotId = slotId
		local fromSlot = findSlotById(fromSlotId)
		local toSlot = findSlotById(toSlotId)

		if fromSlot and toSlot then
			local tmpslotid = "slot" .. actionbarState.maxSlots + 1

			copySlot(fromSlotId, tmpslotid, false)
			copySlot(toSlotId, fromSlotId, true)
			copySlot(tmpslotid, toSlotId, true)

			local tmpWidget = findSlotById(tmpslotid)

			if tmpWidget and not tmpWidget:isDestroyed() then
				tmpWidget:destroy()
			else
				clearSlotById(tmpslotid)
			end

			updateSlotsVocation()

			if refreshMultiActionSlotCooldownDisplay then
				local refreshedFrom = findSlotById(fromSlotId)
				local refreshedTo = findSlotById(toSlotId)

				if refreshedFrom then
					clearSlotProgressWidgets(refreshedFrom)

					if slotHasMultiActions and slotHasMultiActions(refreshedFrom) and syncMultiActionSlot then
						syncMultiActionSlot(refreshedFrom)
					else
						refreshMultiActionSlotCooldownDisplay(refreshedFrom, false)
					end
				end

				if refreshedTo then
					clearSlotProgressWidgets(refreshedTo)

					if slotHasMultiActions and slotHasMultiActions(refreshedTo) and syncMultiActionSlot then
						syncMultiActionSlot(refreshedTo)
					else
						refreshMultiActionSlotCooldownDisplay(refreshedTo, false)
					end
				end
			end
		end

		slotReassign = nil
		slotToEdit = nil
	end

	slotToEdit = slotId

	if itemDragRetry and missedSlotToEdit then
		local widget1 = missedSlotToEdit[1]
		local mousePos1 = missedSlotToEdit[2]
		local item1 = missedSlotToEdit[3]

		if widget1 and mousePos1 and item1 then
			onChooseItemByDrag(widget1, mousePos1, item1)
		end

		itemDragRetry = nil
		missedSlotToEdit = nil
	end

	setupHotkeys()
end

function setupActionBar()
	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			ensureActionBarPanelSlots(barId, panel)
		end
	end
end

  actionbarState.assignOrEditMenuLabel = function(assignLabel, editLabel, hasAssigned)
	return hasAssigned and editLabel or assignLabel
end

function createMenu(slotId)
	local menu = g_ui.createWidget("GamePopupMenu")

	menu:setWidth(195)

	slotToEdit = slotId

	local slotForMenu = findSlotById(slotId)
	local slotHasSpell = slotForMenu and slotForMenu.words and slotForMenu.words ~= ""
	local slotIsEquipPreset = slotForMenu and actionbarState.isActionSlotEquipmentPreset(slotForMenu)
	local slotHasObject = slotForMenu and not slotIsEquipPreset and slotForMenu.useType and slotForMenu.itemId and slotForMenu.itemId > 0
	local slotHasText = slotForMenu and slotForMenu.text and slotForMenu.text ~= ""
	local slotHasPassive = slotForMenu and slotForMenu.passiveId ~= nil
	local slotHasHotkey = slotForMenu and isHelperActionSlot(slotForMenu)
	local var_247_8 = slotForMenu and isMultiHelperSlot(slotForMenu)
	local var_247_9 = slotForMenu and ((slotForMenu.hotkeyChatOn or "") ~= "" or (slotForMenu.hotkeyChatOff or "") ~= "")
	local slotHasMulti = slotForMenu and slotHasMultiActions and slotHasMultiActions(slotForMenu)
	local slotMultiPanelOpen = slotForMenu and slotForMenu._multiPanelOpen
	local spellMenuLabel = slotForMenu and slotForMenu._multiHelperPanelOpen
	local var_247_13 = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Spell", "Edit Spell", slotHasSpell) or "Assign Spell"
	local objectMenuLabel = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Object", "Edit Object", slotHasObject) or "Assign Object"
	local textMenuLabel = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Text", "Edit Text", slotHasText) or "Assign Text"
	local passiveMenuLabel = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Passive Ability", "Edit Passive Ability", slotHasPassive) or "Assign Passive Ability"
	local hotkeyMenuLabel = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Helper", "Edit Helper", slotHasHotkey) or "Assign Helper"
	local var_247_18

	if spellMenuLabel then
		var_247_18 = tr("Close Multi-Helper")
	else
		var_247_18 = not slotHasMulti and actionbarState.assignOrEditMenuLabel("Assign Multi-Helper", "Edit Multi-Helper", var_247_8) or "Assign Multi-Helper"
	end

	local var_247_19 = actionbarState.assignOrEditMenuLabel(tr("Assign Hotkey"), tr("Edit Hotkey"), var_247_9)

	menu:addOption(var_247_13, function()
		openSpellAssignWindow()
	end)
	menu:addOption(objectMenuLabel, function()
		if slotHasMulti then
			startChooseItem()
			openObjectAssignWindow()
		elseif slotHasObject then
			local slot = findSlotById(slotToEdit)

			if slot and slot.itemId and slot.itemId > 0 then
				openObjectAssignWindow()

				local item = slot.subType and Item.create(slot.itemId, slot.subType) or Item.create(slot.itemId)

				populateObjectAssignWindowFromItem(item, slot.useType, actionbarState.actionSlotItemTier(slot), {
					smartMode = slot.smartMode,
					smartBaseItemId = slot.smartBaseItemId
				})
			else
				startChooseItem()
				openObjectAssignWindow()
			end
		else
			startChooseItem()
			openObjectAssignWindow()
		end
	end)
	menu:addOption(textMenuLabel, function()
		openTextAssignWindow()
	end)
	menu:addOption(passiveMenuLabel, function()
		assignPassive(slotId)
	end)
	menu:addOption(hotkeyMenuLabel, function()
		assignHelper(slotId)
	end)

	if not (slotHasPassive or slotIsEquipPreset or slotHasMulti) or spellMenuLabel then
		menu:addOption(var_247_18, function()
			if spellMenuLabel then
				HelperAction.closePanel()
			else
				assignMultiHelper(slotId)
			end
		end)
	end

	local var_247_20 = slotHasPassive or slotHasHotkey or var_247_8 or slotIsEquipPreset
	local multiMenuLabel

	if slotMultiPanelOpen then
		multiMenuLabel = tr("Close Multi-Action")
	else
		multiMenuLabel = actionbarState.assignOrEditMenuLabel(tr("Assign Multi-Action"), tr("Edit Multi-Action"), slotHasMulti)
	end

	if not var_247_20 or slotMultiPanelOpen then
		menu:addOption(multiMenuLabel, function()
			if slotMultiPanelOpen and closeCurrentMultiActionPanel then
				closeCurrentMultiActionPanel()
			elseif assignMultiAction then
				assignMultiAction(slotId)
			end
		end)
	end

	local equipmentMenuLabel

	if slotHasMulti then
		equipmentMenuLabel = tr("Assign Equipments")
	else
		equipmentMenuLabel = actionbarState.assignOrEditMenuLabel(tr("Assign Equipments"), tr("Edit Equipments"), slotIsEquipPreset)
	end

	menu:addOption(equipmentMenuLabel, function()
		openEquipmentAssignWindow()
	end)
	menu:addOption(var_247_19, function()
		openEditHotkeyWindow()
	end)

	local actionSlot = findSlotById(slotToEdit)
	local slotHasEquipPreset = actionSlot and actionbarState.isActionSlotEquipmentPreset(actionSlot)

	if actionSlot and (actionSlot.itemId or actionSlot.words or actionSlot.text or actionSlot.useType or var_247_9 or actionSlot.passiveId or actionSlot.helperId or var_247_8 or slotHasMulti or slotHasEquipPreset) then
		menu:addSeparator()
		menu:addOption("Clear Action", function()
			clearSlot()
			setupHotkeys()
			saveActionBar()
		end)
	end

	menu:display()
end

CastMode = {
	_radioUpdating = false,
	panelHeight = 45,
	panelMargin = 6,
	ids = {
		"castWithCrosshairRadio",
		"castAtCursorRadio",
		"castAtTargetRadio"
	},
	byRadio = {
		castAtTargetRadio = "target",
		castAtCursorRadio = "cursor",
		castWithCrosshairRadio = "crosshair"
	},
	toRadio = {
		target = "castAtTargetRadio",
		cursor = "castAtCursorRadio",
		crosshair = "castWithCrosshairRadio"
	},
	validModes = {
		target = true,
		cursor = true,
		crosshair = true
	}
}

  actionbarState.normalizeCrossHairMode = function(mode)
	if type(mode) == "string" and CastMode.validModes[mode] then
		return mode
	end

	return "crosshair"
end

CrosshairCast = {}

function CastMode.getPanel()
	if not spellAssignWindow or spellAssignWindow:isDestroyed() then
		return nil
	end

	local panel = spellAssignWindow:getChildById("castModePanel")

	if not panel or panel:isDestroyed() then
		return nil
	end

	return panel
end

function CastMode.setSelection(mode)
	local panel = CastMode.getPanel()

	if not panel then
		return
	end

	local selectedRadioId = CastMode.toRadio[actionbarState.normalizeCrossHairMode(mode)] or CastMode.toRadio.crosshair

	CastMode._radioUpdating = true

	for _, radioId in ipairs(CastMode.ids) do
		local radio = panel:getChildById(radioId)

		if radio and not radio:isDestroyed() then
			radio:setChecked(radioId == selectedRadioId)
		end
	end

	CastMode._radioUpdating = false
end

function CastMode.getSelected()
	local panel = CastMode.getPanel()

	if not panel then
		return "crosshair"
	end

	for _, radioId in ipairs(CastMode.ids) do
		local radio = panel:getChildById(radioId)

		if radio and not radio:isDestroyed() and radio:isChecked() then
			return actionbarState.normalizeCrossHairMode(CastMode.byRadio[radioId])
		end
	end

	return "crosshair"
end

function CastMode.setVisible(visible)
	local panel = CastMode.getPanel()

	if not panel or not spellAssignWindow or spellAssignWindow:isDestroyed() then
		return
	end

	local spellsListFrame = spellAssignWindow:getChildById("spellsListFrame")

	if not spellsListFrame or spellsListFrame:isDestroyed() then
		return
	end

	if visible == panel:isVisible() then
		return
	end

	if CastMode._spellsListBaseHeight == nil then
		CastMode._spellsListBaseHeight = spellsListFrame:getHeight()
	end

	local delta = CastMode.panelHeight + CastMode.panelMargin

	if visible then
		panel:setHeight(CastMode.panelHeight)
		panel:setMarginTop(CastMode.panelMargin)
		panel:setVisible(true)
		spellsListFrame:setHeight(math.max(120, CastMode._spellsListBaseHeight - delta))
	else
		panel:setVisible(false)
		panel:setHeight(0)
		panel:setMarginTop(0)
		spellsListFrame:setHeight(CastMode._spellsListBaseHeight)
	end
end

function CastMode.setupRadios()
	local panel = CastMode.getPanel()

	if not panel then
		return
	end

	for _, radioId in ipairs(CastMode.ids) do
		local radio = panel:getChildById(radioId)

		if radio and not radio:isDestroyed() then
			function radio.onClick(widget)
				if CastMode._radioUpdating or not widget or widget:isDestroyed() then
					return
				end

				CastMode._radioUpdating = true

				for _, id in ipairs(CastMode.ids) do
					local other = panel:getChildById(id)

					if other and not other:isDestroyed() then
						other:setChecked(other == widget)
					end
				end

				CastMode._radioUpdating = false
			end
		end
	end
end

function openSpellAssignWindow()
	if spellAssignWindow and not spellAssignWindow:isDestroyed() then
		closeSpellAssignWindow()
	end

	local uiFile = externalAssignSlotId and "/game_helper/assign_helper" or "assign_spell"

	spellAssignWindow = g_ui.loadUI(uiFile, g_ui.getRootWidget())

	actionbarState.setSpellAssignWindowTitle()

	spellsPanel = spellAssignWindow:recursiveGetChildById("spellsPanel")
	CastMode._spellsListBaseHeight = nil
	CastMode._previewSpellKey = nil

	CastMode.setupRadios()
	CastMode.setSelection("crosshair")
	CastMode.setVisible(false)
	addEvent(function()
		initializeSpelllist()
	end)
	spellAssignWindow:raise()
	spellAssignWindow:focus()

	if not actionbarState.spellAssignFocusParameterOnOpen then
		spellAssignWindow:recursiveGetChildById("filterTextEdit"):focus()
	end

	spellAssignWindow.hotkeyBlock = HotkeyUtils.createHotkeyBlock("spell_assign_window")
end

function openSpellAssignWindowForDraggedSpell(slotId, words, multiIndex)
	if not slotId or not words or words == "" then
		return
	end

	local normalizedWords = words:lower():trim()
	local spell = Spells.getSpellByWords(normalizedWords)

	if not spell or not spell.parameter then
		return
	end

	slotToEdit = slotId
	multiActionEditIndex = multiIndex or nil
	spellAssignPreferredSpellOverride = Spells.getSpellNameByWords(normalizedWords)
	actionbarState.spellAssignFocusParameterOnOpen = true

	openSpellAssignWindow()
end

function closeSpellAssignWindow()
	spellAssignPreferredSpellOverride = nil
	actionbarState.spellAssignFocusParameterOnOpen = false
	multiActionEditIndex = nil

	actionbarState.clearExternalSpellAssignContext()

	CastMode._spellsListBaseHeight = nil
	CastMode._previewSpellKey = nil

	if spellAssignWindow and not spellAssignWindow:isDestroyed() then
		spellAssignWindow:destroy()
	end

	spellAssignWindow = nil
	spellsPanel = nil
end

  actionbarState.getSpellAssignPreferredSpellName = function()
	if spellAssignPreferredSpellOverride then
		return spellAssignPreferredSpellOverride
	end

	local slot = slotToEdit and findSlotById(slotToEdit)

	if not slot or not slot.words or slot.words == "" then
		return nil
	end

	return Spells.getSpellNameByWords(slot.words:lower():trim())
end

  actionbarState.syncSpellAssignParameterFieldFromSlot = function(focusedChild)
	if not spellAssignWindow or not focusedChild then
		return
	end

	local paramEdit = spellAssignWindow:getChildById("parameterTextEdit")

	if not paramEdit then
		return
	end

	local preferred = actionbarState.getSpellAssignPreferredSpellName()
	local slot = slotToEdit and findSlotById(slotToEdit)

	if preferred and focusedChild:getId() == preferred and slot then
		paramEdit:setText(slot.parameter or "")
	else
		paramEdit:setText("")
	end
end

  actionbarState.pickSpellAssignListFocusWidget = function()
	if not spellsPanel then
		return nil
	end

	local preferredName = actionbarState.getSpellAssignPreferredSpellName()

	if preferredName then
		for _, child in ipairs(spellsPanel:getChildren()) do
			if child:getId() == preferredName and child:isVisible() then
				return child
			end
		end
	end

	for _, child in ipairs(spellsPanel:getChildren()) do
		if child:isVisible() then
			return child
		end
	end

	return nil
end

function initializeSpelllist()
	g_keyboard.bindKeyPress("Down", function()
		spellsPanel:focusNextChild(KeyboardFocusReason)
	end, spellAssignWindow)
	g_keyboard.bindKeyPress("Up", function()
		spellsPanel:focusPreviousChild(KeyboardFocusReason)
	end, spellAssignWindow)

	local vocId = 0
	local player = g_game.getLocalPlayer()

	if player then
		vocId = translateVocation(player:getVocation())
	end

	for spellProfile, _ in pairs(SpelllistSettings) do
		local sortedSpells = Spells.getSpellNamesSortedForVocation(vocId, spellProfile)

		for _, spell in ipairs(sortedSpells) do
			local info = SpellInfo[spellProfile][spell]

			if info and (not spellAssignListFilter or spellAssignListFilter(spell, info)) then
				local tmpLabel = g_ui.createWidget("SpellListLabel", spellsPanel)

				tmpLabel:setId(spell)
				tmpLabel:setPhantom(false)

				tmpLabel._filterWords = info.words:lower()
				tmpLabel._filterName = spell:lower()

				local spellNameWidget = tmpLabel:getChildById("spellName")
				local spellWordsWidget = tmpLabel:getChildById("spellWords")
				local spellLevelWidget = tmpLabel:getChildById("spellLevel")
				local spellIconWidget = tmpLabel:getChildById("spellIcon")

				spellNameWidget:setText(spell)
				spellWordsWidget:setText(info.words)

				if spellLevelWidget then
					spellLevelWidget:setText(tr("Level:") .. " " .. tostring(info.level or 0))
				end

				local iconId = SpellIcons[info.id]

				tmpLabel:setHeight(SpelllistSettings[spellProfile].iconSize.height + 2)

				tmpLabel.defaultHeight = tmpLabel:getHeight()

				spellIconWidget:setImageSource(SpelllistSettings[spellProfile].iconFile)

				local clip = iconId and Spells.getImageClip(iconId, spellProfile)

				if clip then
					spellIconWidget:setImageClip(clip)
				end

				spellIconWidget:setImageSize(tosize(SpelllistSettings[spellProfile].iconSize.width .. " " .. SpelllistSettings[spellProfile].iconSize.height))

				local groupIconWidget = tmpLabel:getChildById("groupCooldownIcon")

				if groupIconWidget then
					local gid = Spells.getPrimaryGroupId(info)
					local clip = gid and Spells.getSpellGroupIconClip(gid)

					if clip then
						groupIconWidget:setImageSource(SpellGroupIconFile)
						groupIconWidget:setImageClip(clip)
						groupIconWidget:setVisible(true)
					else
						groupIconWidget:setVisible(false)
					end
				end

				local spellIconGray = tmpLabel:getChildById("spellIconGray")

				if spellIconGray then
					spellIconGray:setVisible(not actionbarState.spellPassesAssignLearntFilter(info))
				end

				connect(tmpLabel, {
					onFocusChange = function(widget, focused)
						local c = focused and "#ffffff" or "#c0c0c0"

						widget:getChildById("spellName"):setColor(c)
						widget:getChildById("spellWords"):setColor(c)

						local lvl = widget:getChildById("spellLevel")

						if lvl then
							lvl:setColor(c)
						end
					end
				})
			end
		end
	end

	connect(spellsPanel, {
		onChildFocusChange = function(self, focusedChild)
			if focusedChild == nil then
				return
			end

			updatePreviewSpell(focusedChild)
			actionbarState.syncSpellAssignParameterFieldFromSlot(focusedChild)
		end
	})

	local learntCb = spellAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

	if learntCb then
		connect(learntCb, {
			onCheckChange = function()
				local edit = spellAssignWindow:recursiveGetChildById("filterTextEdit")

				filterSpells(edit and edit:getText() or "")
			end
		})
	end

	filterSpells("")

	local toFocus = actionbarState.pickSpellAssignListFocusWidget()

	if toFocus then
		spellsPanel:focusChild(toFocus, KeyboardFocusReason)

		local sn = toFocus:getChildById("spellName")
		local sw = toFocus:getChildById("spellWords")
		local sl = toFocus:getChildById("spellLevel")

		if sn and sw then
			sn:setColor("#ffffff")
			sw:setColor("#ffffff")
		end

		if sl then
			sl:setColor("#ffffff")
		end
	end

	if actionbarState.spellAssignFocusParameterOnOpen then
		actionbarState.spellAssignFocusParameterOnOpen = false
		spellAssignPreferredSpellOverride = nil

		local paramEdit = spellAssignWindow:getChildById("parameterTextEdit")

		if paramEdit and paramEdit:isFocusable() and paramEdit:isEditable() then
			paramEdit:focus()
		else
			local filterEdit = spellAssignWindow:recursiveGetChildById("filterTextEdit")

			if filterEdit then
				filterEdit:focus()
			end
		end
	end
end

  actionbarState.updateSpellAssignParameterField = function(spell)
	if not spellAssignWindow then
		return
	end

	local paramEdit = spellAssignWindow:getChildById("parameterTextEdit")

	if not paramEdit then
		return
	end

	local paramLabel = spellAssignWindow:getChildById("parameterLabel")
	local canEditParam = spell and spell.parameter
	local placeholder = ""

	if canEditParam then
		local ph = Spells.getParameterPlaceholder(spell)

		if ph then
			placeholder = "\"" .. ph .. "\""
		end
	end

	if paramEdit then
		paramEdit:setEditable(canEditParam)
		paramEdit:setFocusable(canEditParam)
		paramEdit:setCursorVisible(canEditParam)
		paramEdit:setPlaceholder(placeholder)
	end

	if paramLabel then
		paramLabel:setColor(canEditParam and "#c0c0c0" or "#707070")
	end

	local hasCrossHair = Spells.hasCrossHairTarget(spell)

	CastMode.setVisible(hasCrossHair)

	if hasCrossHair then
		local spellKey = spell and spell.name or nil

		if spellKey ~= CastMode._previewSpellKey then
			CastMode._previewSpellKey = spellKey

			local slot = slotToEdit and findSlotById(slotToEdit) or nil
			local savedMode = actionbarState.normalizeCrossHairMode(slot and slot.crossHairMode or "crosshair")

			CastMode.setSelection(savedMode)
		end
	else
		CastMode._previewSpellKey = nil

		CastMode.setSelection("crosshair")
	end
end

function spellAssignPreviewNoSpellSelected()
	if not spellAssignWindow then
		return
	end

	local previewPanel = spellAssignWindow:getChildById("spellPreview")

	if not previewPanel then
		return
	end

	local icon = previewPanel:getChildById("previewSpellIcon")

	if icon then
		icon:setVisible(false)
	end

	local nameLabel = previewPanel:getChildById("previewSpellName")
	local wordsLabel = previewPanel:getChildById("previewSpellWords")

	if nameLabel then
		nameLabel:setMarginLeft(-27)
		nameLabel:setText(tr("No spell selected"))
	end

	if wordsLabel then
		wordsLabel:setText("")
	end

	local previewGray = previewPanel:getChildById("previewSpellGray")

	if previewGray then
		previewGray:setVisible(false)
	end

	local previewItemBg = previewPanel:getChildById("previewItemBackground")

	if previewItemBg then
		previewItemBg:setVisible(false)
	end

	local previewItemIcon = previewPanel:getChildById("previewItemIcon")

	if previewItemIcon then
		previewItemIcon:setVisible(false)
	end

	actionbarState.updateSpellAssignParameterField(nil)
end

function updatePreviewSpell(focusedChild)
	local spellName = focusedChild:getId()
	local spell = Spells.getSpellByName(spellName)
	local profile = Spells.getSpellProfileByName(spellName)
	local iconId = spell and SpellIcons[spell.id] or tonumber(Spells.getClientId(spellName))
	local previewPanel = spellAssignWindow:getChildById("spellPreview")

	if previewPanel then
		local icon = previewPanel:getChildById("previewSpellIcon")

		if icon then
			icon:setVisible(true)

			if iconId and profile and SpelllistSettings[profile] then
				icon:setImageSource(SpelllistSettings[profile].iconFile)

				local clip = Spells.getImageClip(iconId, profile)

				if clip then
					icon:setImageClip(clip)
				end
			end
		end

		local nameLabel = previewPanel:getChildById("previewSpellName")

		if nameLabel then
			nameLabel:setMarginLeft(5)
			nameLabel:setText(spellName)
		end

		local previewWords = previewPanel:getChildById("previewSpellWords")

		if previewWords then
			previewWords:setText(spell and spell.words or "")
		end

		local previewGray = previewPanel:getChildById("previewSpellGray")

		if previewGray then
			previewGray:setVisible(spell ~= nil and not actionbarState.spellPassesAssignLearntFilter(spell))
		end

		local previewItemBg = previewPanel:getChildById("previewItemBackground")

		if previewItemBg then
			previewItemBg:setVisible(false)
		end

		local previewItemIcon = previewPanel:getChildById("previewItemIcon")

		if previewItemIcon then
			previewItemIcon:setVisible(false)
		end
	end

	actionbarState.updateSpellAssignParameterField(spell)
end

function spellAssignApply(closeAfter)
	local focusedChild = spellsPanel:getFocusedChild()

	if not focusedChild then
		return
	end

	local spellName = focusedChild:getId()
	local spell = Spells.getSpellByName(spellName)

	if not spell then
		return
	end

	local slot = findSlotById(slotToEdit)

	if not slot then
		return
	end

	if multiActionEditIndex then
		local param

		if spell.parameter then
			local paramEdit = spellAssignWindow:getChildById("parameterTextEdit")

			if paramEdit then
				param = paramEdit:getText():gsub("\"", "")
			end
		end

		commitMultiActionSubEntry(slot, multiActionEditIndex, {
			autoSend = true,
			words = spell.words,
			parameter = param
		})

		if closeAfter then
			multiActionEditIndex = nil
		end

		return
	end

	clearSlot()

	slot.words = spell.words
	slot.itemId = 469

	slot:setItemId(469)

	local paramEdit = spellAssignWindow and spellAssignWindow:getChildById("parameterTextEdit")

	if spell.parameter and paramEdit then
		slot.parameter = paramEdit:getText():gsub("\"", "")
	else
		slot.parameter = nil
	end

	if Spells.hasCrossHairTarget(spell) then
		slot.crossHairMode = actionbarState.normalizeCrossHairMode(CastMode.getSelected())
	else
		slot.crossHairMode = nil
	end

	loadSpell(slot)

	if externalAssignSlotId and slotToEdit == externalAssignSlotId then
		if onExternalSpellAssignApplied then
			onExternalSpellAssignApplied(slot)
		end

		return
	end
end

function spellAssignOk()
	spellAssignApply(true)
	closeSpellAssignWindow()
end

function resolveCyclopediaSpellAssignSlotAtMouse(mousePosition)
	local root = modules.game_interface.getRootPanel()
	local widget = root and root:recursiveGetChildByPos(mousePosition, false) or nil

	while widget do
		if widget._actionBarId and widget.getId then
			local slot = findSlotById(widget:getId())

			if slot == widget then
				return slot
			end
		end

		widget = widget:getParent()
	end

	return nil
end

function finishCyclopediaSpellSlotAssign()
	local returnWindow = cyclopediaSpellAssignReturnWindow

	cyclopediaSpellAssign = nil
	cyclopediaSpellAssignReturnWindow = nil

	if mouseGrabberWidget then
		mouseGrabberWidget:ungrabMouse()
	end

	g_mouse.popCursor("target")

	if returnWindow and modules.game_cyclopedia and modules.game_cyclopedia.toggle then
		modules.game_cyclopedia.toggle(returnWindow)
	end
end

function applyCyclopediaSpellToActionSlot(slot)
	local spell = cyclopediaSpellAssign

	finishCyclopediaSpellSlotAssign()

	if not slot or not spell then
		return false
	end

	slotToEdit = slot:getId()

	clearSlot()

	slot.words = spell.words
	slot.itemId = 469

	slot:setItemId(469)

	slot.parameter = nil

	loadSpell(slot)

	return true
end

function onCyclopediaSpellAssignMouseRelease(self, mousePosition, mouseButton)
	if mouseButton ~= MouseLeftButton then
		finishCyclopediaSpellSlotAssign()

		return true
	end

	local slot = resolveCyclopediaSpellAssignSlotAtMouse(mousePosition)

	if not slot then
		if modules.game_textmessage then
			modules.game_textmessage.displayFailureMessage(tr("Select an action bar slot."))
		end

		finishCyclopediaSpellSlotAssign()

		return true
	end

	applyCyclopediaSpellToActionSlot(slot)

	return true
end

function startCyclopediaSpellSlotAssign(spellName, spellWords, returnWindow)
	local spell

	if spellWords and spellWords ~= "" then
		spell = Spells.getSpellByWords(spellWords)
	end

	if not spell and spellName and spellName ~= "" then
		spell = Spells.getSpellByName(spellName)
	end

	if not spell or not mouseGrabberWidget then
		if modules.game_textmessage then
			modules.game_textmessage.displayFailureMessage(tr("This spell cannot be assigned to the action bar."))
		end

		return false
	end

	if cyclopediaSpellAssign then
		finishCyclopediaSpellSlotAssign()
	end

	cyclopediaSpellAssign = spell
	cyclopediaSpellAssignReturnWindow = returnWindow

	mouseGrabberWidget:grabMouse()
	g_mouse.pushCursor("target")

	return true
end

function clearSlot()
	local slot = findSlotById(slotToEdit)

	if not slot then
		return
	end

	if slotHasMultiActions and slotHasMultiActions(slot) and clearSlotMultiActions then
		clearSlotMultiActions(slot)
	end

	clearSlotActionContent(slot)
end

function clearSlotById(slotId)
	local slot = findSlotById(slotId)

	if not slot then
		return
	end

	clearSlotActionContent(slot)

	slot.hotkeyChatOn = ""
	slot.hotkeyChatOff = ""

	actionbarState.syncSlotHotkeyMirror(slot)
	refreshActionSlotInventoryQuantity(slot)
	applyActionSlotFrame(slot)
end

function clearHotkey()
	local slot = findSlotById(slotToEdit)

	if not slot then
		return
	end

	slot.hotkeyChatOn = ""
	slot.hotkeyChatOff = ""

	actionbarState.syncSlotHotkeyMirror(slot)
	setupHotkeys()
	saveActionBar()
end

function isEquipmentAssignBlockingItemMove()
	return equipmentAssignWindow ~= nil and not equipmentAssignWindow:isDestroyed()
end

function openEquipmentAssignWindow()
	if equipmentAssignWindow then
		closeEquipmentAssignWindow()
	end

	equipmentAssignWindow = g_ui.loadUI("assign_equipment", g_ui.getRootWidget())

	if equipmentAssignWindow then
		equipmentAssignWindow:breakAnchors()
		equipmentAssignWindow:centerIn("parent")
	end

	equipmentAssignWindow:raise()
	equipmentAssignWindow:focus()

	equipmentAssignWindow.hotkeyBlock = HotkeyUtils.createHotkeyBlock("equipment_assign_window")

	local actionSlot = findSlotById(slotToEdit)

	actionbarState.copyEquipmentAssignDraft(actionSlot and actionSlot.equipments or nil)
	actionbarState.copyEquipmentAssignMetaFromSlot(actionSlot)
	actionbarState.refreshAllEquipmentAssignSlots()
	actionbarState.setupEquipmentAssignSlotHandlers()
	actionbarState.refreshAssignActionSlotPreview()
	equipmentAssignUpdateButtons()
end

function openEquipmentAssignIconWindow()
	if not equipmentAssignWindow or equipmentAssignWindow:isDestroyed() then
		return
	end

	if equipmentAssignIconWindow then
		closeEquipmentAssignIconWindow(false)
	end

	actionbarState.equipmentAssignIconPickerRevertIndex = actionbarState.equipmentAssignIconIndex
	actionbarState.equipmentAssignIconPickerRevertDescription = actionbarState.equipmentAssignDescription
	actionbarState.equipmentAssignTypePickerRevertIndex = actionbarState.equipmentAssignTypeIndex

	equipmentAssignWindow:hide()

	actionbarState.equipmentAssignHiddenForIconPicker = true
	equipmentAssignIconWindow = g_ui.loadUI("assign_equipment_icon", g_ui.getRootWidget())

	if not equipmentAssignIconWindow then
		actionbarState.equipmentAssignHiddenForIconPicker = false

		equipmentAssignWindow:show()

		return
	end

	equipmentAssignIconWindow:raise()
	equipmentAssignIconWindow:focus()

	equipmentAssignIconWindow.hotkeyBlock = HotkeyUtils.createHotkeyBlock("equipment_assign_icon_window")

	local edit = equipmentAssignIconWindow:recursiveGetChildById("descriptionTextEdit")

	if edit then
		edit:setText(actionbarState.equipmentAssignDescription or "")
	end

	actionbarState.setupEquipmentAssignIconPicker()
	actionbarState.setupEquipmentAssignTypePicker()
end

function closeEquipmentAssignIconWindow(revert)
	if not equipmentAssignIconWindow then
		return
	end

	if revert then
		actionbarState.equipmentAssignIconIndex = actionbarState.equipmentAssignIconPickerRevertIndex
		actionbarState.equipmentAssignDescription = actionbarState.equipmentAssignIconPickerRevertDescription
		actionbarState.equipmentAssignTypeIndex = actionbarState.equipmentAssignTypePickerRevertIndex

		actionbarState.refreshAssignActionSlotPreview()
		equipmentAssignUpdateButtons()
	end

	actionbarState.destroyEquipmentAssignTypeRadioGroup()
	equipmentAssignIconWindow:destroy()

	equipmentAssignIconWindow = nil

	if actionbarState.equipmentAssignHiddenForIconPicker then
		actionbarState.equipmentAssignHiddenForIconPicker = false

		if equipmentAssignWindow and not equipmentAssignWindow:isDestroyed() then
			equipmentAssignWindow:show()
			equipmentAssignWindow:raise()
			equipmentAssignWindow:focus()
		end
	end
end

function equipmentAssignIconApply()
	if not equipmentAssignIconWindow then
		return
	end

	actionbarState.commitEquipmentAssignIconPicker()
end

function equipmentAssignIconOk()
	equipmentAssignIconApply()
	closeEquipmentAssignIconWindow(false)
end

function closeEquipmentAssignWindow()
	if not equipmentAssignWindow then
		return
	end

	closeEquipmentAssignIconWindow(false)

	if actionbarState.equipmentAssignPickInvSlot ~= nil then
		actionbarState.equipmentAssignPickInvSlot = nil

		if mouseGrabberWidget and not mouseGrabberWidget:isDestroyed() then
			mouseGrabberWidget:ungrabMouse()
		end

		g_mouse.popCursor("target")
	end

	actionbarState.equipmentAssignHiddenForPick = false
	actionbarState.equipmentAssignHiddenForIconPicker = false

	equipmentAssignWindow:destroy()

	equipmentAssignWindow = nil
	actionbarState.equipmentAssignDraft = nil
end

function equipmentAssignApply()
	applyEquipmentAssign(false)
end

function equipmentAssignOk()
	applyEquipmentAssign(true)
end

function applyEquipmentAssign(closeAfter)
	local slot = findSlotById(slotToEdit)

	if not slot then
		if closeAfter then
			closeEquipmentAssignWindow()
		end

		return
	end

	if not actionbarState.isEquipmentAssignIconDetermined() then
		return
	end

	if clearSlotMultiActions then
		clearSlotMultiActions(slot)
	end

	local icon = slot:getChildById("spellIcon")

	if icon then
		icon:hide()
		icon:setImageSource("")
	end

	slot.words = nil
	slot.grayManaCost = nil
	slot.text = nil
	slot.passiveId = nil
	slot.helperId = nil
	slot.multiHelper = nil

	hideHelperSlotBorder(slot)

	slot.parameter = nil
	slot.equipments = {}

	for invSlot, entry in pairs(actionbarState.equipmentAssignDraft or {}) do
		if not actionbarState.isEquipmentAssignVisualBackpackSlot(invSlot) and entry and entry.itemId and entry.itemId > 0 then
			slot.equipments[invSlot] = {
				itemId = entry.itemId,
				getTier = entry.getTier,
				subType = entry.subType
			}
		end
	end

	slot.useType = "equip"

	local display = actionbarState.equipmentAssignDisplayEntry(actionbarState.equipmentAssignDraft)

	if display then
		slot.itemId = display.itemId
		slot.getTier = display.getTier
		slot.subType = display.subType
	else
		slot.itemId = 0
		slot.getTier = nil
		slot.subType = nil
	end

	slot.equipmentIconIndex = actionbarState.normalizeEquipmentIconIndex(actionbarState.equipmentAssignIconIndex)
	slot.equipmentDescription = actionbarState.equipmentAssignDescription or ""
	slot.equipmentTypeIndex = actionbarState.normalizeEquipmentTypeIndex(actionbarState.equipmentAssignTypeIndex)

	loadEquipmentSetDisplay(slot)
	setupHotkeys()
	saveActionBar()

	if closeAfter then
		closeEquipmentAssignWindow()
	end
end

function openTextAssignWindow()
	textAssignWindow = g_ui.loadUI("assign_text", g_ui.getRootWidget())

	local slot = findSlotById(slotToEdit)
	local textEdit = textAssignWindow:getChildById("textToSendTextEdit")
	local sendAutoBox = textAssignWindow:recursiveGetChildById("sendAutomaticallyCheckBox")

	if multiActionEditIndex and slot and slot.multiActions and slot.multiActions[multiActionEditIndex] then
		local data = slot.multiActions[multiActionEditIndex]

		if textEdit then
			textEdit:setText(data.text or data.words or "")
		end

		if sendAutoBox then
			sendAutoBox:setChecked(data.autoSend ~= false)
		end
	elseif slot and slot.text and slot.text ~= "" then
		if textEdit then
			textEdit:setText(slot.text)
		end

		if sendAutoBox then
			sendAutoBox:setChecked(slot.autoSend ~= false)
		end
	else
		if textEdit then
			textEdit:setText("")
		end

		if sendAutoBox then
			sendAutoBox:setChecked(true)
		end
	end

	actionbarState.setTextAssignWindowTitle()
	textAssignWindow:raise()
	textAssignWindow:focus()

	if textEdit then
		textEdit:focus()
		textEdit:setCursorPos(-1)
	end

	textAssignWindow.hotkeyBlock = HotkeyUtils.createHotkeyBlock("text_assign_window")

	if g_client.setInputLockWidget then
		g_client.setInputLockWidget(textAssignWindow)
	end

	textAssignUpdateButtons()
end

function textAssignUpdateButtons()
	if not textAssignWindow then
		return
	end

	local edit = textAssignWindow:getChildById("textToSendTextEdit")
	local okBtn = textAssignWindow:getChildById("okButton")
	local applyBtn = textAssignWindow:getChildById("applyButton")
	local hasText = edit and edit:getText():trim() ~= ""

	if okBtn then
		okBtn:setEnabled(hasText)
	end

	if applyBtn then
		applyBtn:setEnabled(hasText)
	end
end

function assignPassive(slotId)
	local window = g_ui.loadUI("assign_passive", g_ui.getRootWidget())

	g_client.setInputLockWidget(window)
	window:raise()
	scheduleEvent(function()
		window:focus()
	end, 50)

	local slotForTitle = findSlotById(slotId)
	local isEditPassive = slotForTitle and slotForTitle.passiveId ~= nil
	local barId, slotIdx = actionbarState.slotBarAndIndexFromSlotId(slotId)

	if barId and slotIdx then
		local barNum = actionbarState.actionBarDisplayNumber(barId)

		if isEditPassive then
			window:setText(tr("Edit Passive to Action Button %d.%02d", barNum, slotIdx))
		else
			window:setText(tr("Assign Passive to Action Button %d.%02d", barNum, slotIdx))
		end
	else
		window:setText(tr(isEditPassive and "Edit Passive" or "Assign Passive"))
	end

	local selectedPassiveId
	local passiveList = window.contentPanel.passiveList
	local passiveIds = {}

	for id in pairs(PassiveAbilities) do
		table.insert(passiveIds, id)
	end

	table.sort(passiveIds)

	local function applyPassiveAssignFocus(focusedChild)
		if not focusedChild then
			return
		end

		selectedPassiveId = tonumber(focusedChild:getId())

		for _, child in ipairs(passiveList:getChildren()) do
			if child.setChecked then
				child:setChecked(child == focusedChild)
			end
		end

		window.contentPanel.preview.previewLabel:setText(focusedChild:getText())
		window.contentPanel.preview.previewIcon:setImageSource(focusedChild.source)
		window.contentPanel.preview.previewIcon:setImageClip("0 0 32 32")
		passiveList:ensureChildVisible(focusedChild)
	end

	for _, id in ipairs(passiveIds) do
		local passiveData = PassiveAbilities[id]
		local widget = g_ui.createWidget("PassivePreview", passiveList)

		widget:setId(id)
		widget:setText(passiveData.name)
		widget.image:setImageSource(passiveData.icon)
		widget.image:setImageClip("0 0 32 32")

		widget.source = passiveData.icon
	end

	function passiveList.onChildFocusChange(unusedArgument, focusedChild)
		applyPassiveAssignFocus(focusedChild)
	end

	local children = passiveList:getChildren()

	if children and #children > 0 then
		window.contentPanel.preview.previewLabel:setColor("$var-text-cip-color")
		scheduleEvent(function()
			if window:isDestroyed() then
				return
			end

			local first = passiveList:getChildren()[1]

			if first then
				applyPassiveAssignFocus(first)
				passiveList:focusChild(first, KeyboardFocusReason)
			end
		end, 1)
	end

	local function okFunc(destroy)
		if not selectedPassiveId then
			return
		end

		local passiveData = PassiveAbilities[selectedPassiveId]

		if not passiveData then
			return
		end

		clearSlot()

		local slot = findSlotById(slotToEdit)

		if not slot then
			return
		end

		slot.passiveId = selectedPassiveId
		slot.itemId = 469

		slot:setItemId(469)

		local icon = slot:getChildById("spellIcon")

		if icon then
			icon:setImageSource(passiveData.icon)
			icon:setImageClip("0 0 32 32")
			icon:show()
		end

		loadPassive(slot)

		if destroy then
			g_client.setInputLockWidget(nil)
			window:destroy()
		end
	end

	local function cancelFunc()
		g_client.setInputLockWidget(nil)
		window:destroy()
	end

	function window.contentPanel.buttonOk.onClick()
		okFunc(true)
	end

	function window.contentPanel.buttonApply.onClick()
		okFunc(false)
	end

	window.contentPanel.buttonClose.onClick = cancelFunc

	function window.onEnter()
		okFunc(true)
	end

	window.onEscape = cancelFunc
end

function assignHelper(arg_313_0, arg_313_1)
	local rootWidget = g_ui.loadUI("assign_helper", g_ui.getRootWidget())

	if not rootWidget then
		return
	end

	g_client.setInputLockWidget(rootWidget)

	if rootWidget.centerIn then
		rootWidget:centerIn("parent")
	end

	rootWidget:raise()
	rootWidget:focus()

	local var_313_1 = findSlotById(arg_313_0)
	local item = var_313_1 and isHelperActionSlot(var_313_1)

	if type(arg_313_1) == "number" then
		local var_313_3 = var_313_1 and var_313_1.multiHelper and var_313_1.multiHelper[arg_313_1]

		item = HelperAction.getItem(var_313_3) ~= nil

		rootWidget:setText(tr(item and "Edit Helper %d" or "Assign Helper %d", arg_313_1))
	else
		local var_313_4, var_313_5 = actionbarState.slotBarAndIndexFromSlotId(arg_313_0)

		if var_313_4 and var_313_5 then
			local var_313_6 = actionbarState.actionBarDisplayNumber(var_313_4)

			if item then
				rootWidget:setText(tr("Edit Helper to Action Button %d.%02d", var_313_6, var_313_5))
			else
				rootWidget:setText(tr("Assign Helper to Action Button %d.%02d", var_313_6, var_313_5))
			end
		else
			rootWidget:setText(tr(item and "Edit Helper" or "Assign Helper"))
		end
	end

	local id
	local helperList = rootWidget.contentPanel.helperList
	local helperId
	local var_313_10 = findSlotById(arg_313_0)

	if type(arg_313_1) == "number" and var_313_10 and var_313_10.multiHelper then
		helperId = var_313_10.multiHelper[arg_313_1]
	elseif var_313_10 and isHelperActionSlot(var_313_10) then
		helperId = var_313_10.helperId
	end

	local function var_313_11(arg_314_0)
		if not arg_314_0 then
			return ""
		end

		local helperName = arg_314_0:getChildById("helperName")

		if helperName then
			return helperName:getText()
		end

		return arg_314_0:getText() or ""
	end

	local function var_313_12(arg_315_0)
		if not arg_315_0 then
			return
		end

		id = arg_315_0:getId()

		rootWidget.contentPanel.preview.previewLabel:setText(var_313_11(arg_315_0))
		rootWidget.contentPanel.preview.previewLabel:setColor("#C0C0C0")
		rootWidget.contentPanel.preview.previewIcon:setImageSource(HelperAction.ICON_FILE)
		rootWidget.contentPanel.preview.previewIcon:setImageClip(arg_315_0.helperClip or "0 0 32 32")
		helperList:ensureChildVisible(arg_315_0)
	end

	local var_313_13

	for unusedValue, entry in ipairs(HelperAction.ITEMS) do
		if not HelperAction.isItemVisible(entry) then
			-- block empty
		else
			local helperPreviewWidget = g_ui.createWidget("HelperPreview", helperList)

			helperPreviewWidget:setId(entry.id)

			helperPreviewWidget.helperClip = HelperAction.iconClip(entry.iconIndex)

			helperPreviewWidget.image:setImageSource(HelperAction.ICON_FILE)
			helperPreviewWidget.image:setImageClip(helperPreviewWidget.helperClip)

			local helperName = helperPreviewWidget:getChildById("helperName")

			if helperName then
				helperName:setText(tr(entry.label))
			end

			connect(helperPreviewWidget, {
				onFocusChange = function(arg_316_0, arg_316_1)
					local helperName = arg_316_0:getChildById("helperName")

					if helperName then
						helperName:setColor(arg_316_1 and "#ffffff" or "#c0c0c0")
					end
				end
			})

			if entry.id == helperId then
				var_313_13 = helperPreviewWidget
			end
		end
	end

	function helperList.onChildFocusChange(unusedArgument, arg_317_1)
		var_313_12(arg_317_1)
	end

	local children = var_313_13

	if not children and type(arg_313_1) ~= "number" then
		children = helperList:getChildren()[1]
	end

	if children then
		var_313_12(children)
		helperList:focusChild(children, KeyboardFocusReason)

		local helperName = children:getChildById("helperName")

		if helperName then
			helperName:setColor("#ffffff")
		end
	end

	local function var_313_18()
		if g_client.setInputLockWidget then
			g_client.setInputLockWidget(nil)
		end

		if rootWidget and not rootWidget:isDestroyed() then
			rootWidget:destroy()
		end
	end

	local function var_313_19(arg_319_0)
		if not id or not HelperAction.getItem(id) then
			return
		end

		local var_319_0 = findSlotById(slotToEdit)

		if not var_319_0 then
			if arg_319_0 then
				var_313_18()
			end

			return
		end

		if arg_319_0 then
			var_313_18()
		end

		if type(arg_313_1) == "number" then
			HelperAction.applyToIndex(var_319_0, arg_313_1, id)
		else
			clearSlot()

			local var_319_1 = findSlotById(slotToEdit)

			if not var_319_1 then
				return
			end

			var_319_1.helperId = id
			var_319_1.itemId = 469

			var_319_1:setItemId(469)
			loadHelper(var_319_1)
			saveActionBar()
		end
	end

	local function var_313_20()
		var_313_18()
	end

	function rootWidget.contentPanel.buttonOk.onClick()
		var_313_19(true)
	end

	function rootWidget.contentPanel.buttonApply.onClick()
		var_313_19(false)
	end

	rootWidget.contentPanel.buttonClose.onClick = var_313_20

	function rootWidget.onEnter()
		var_313_19(true)
	end

	rootWidget.onEscape = var_313_20
end

function assignMultiHelper(arg_324_0)
	local var_324_0 = findSlotById(arg_324_0)

	if not var_324_0 then
		return
	end

	slotToEdit = arg_324_0

	HelperAction.openPanel(var_324_0)
end

function closeTextAssignWindow()
	if textAssignWindow then
		if textAssignWindow.hotkeyBlock then
			textAssignWindow.hotkeyBlock.release()

			textAssignWindow.hotkeyBlock = nil
		end

		if g_client.setInputLockWidget then
			g_client.setInputLockWidget(nil)
		end

		textAssignWindow:destroy()
	end

	textAssignWindow = nil
end

function textAssignApply()
	applyTextAssign(false)
end

function textAssignOk()
	applyTextAssign(true)
end

function applyTextAssign(closeAfter)
	local text = textAssignWindow:getChildById("textToSendTextEdit"):getText()

	if text == "" then
		return
	end

	local sendAutomaticallyCheckBox = textAssignWindow:recursiveGetChildById("sendAutomaticallyCheckBox"):isChecked()

	if externalAssignSlotId and slotToEdit == externalAssignSlotId then
		if onExternalTextAssignApplied then
			onExternalTextAssignApplied(text, sendAutomaticallyCheckBox)
		end

		if closeAfter then
			closeTextAssignWindow()
		end

		return
	end

	local checkForParameter = text:split(" \"")
	local name
	local parameter

	if #checkForParameter == 2 then
		name = checkForParameter[1]
		parameter = checkForParameter[2]
	else
		name = text
	end

	local spell, profile, spellName = Spells.getSpellByWords(name)
	local slot = findSlotById(slotToEdit)

	if not slot then
		closeTextAssignWindow()

		return
	end

	if multiActionEditIndex then
		if spellName then
			commitMultiActionSubEntry(slot, multiActionEditIndex, {
				words = spell.words,
				parameter = parameter and spell.parameter and parameter or nil,
				autoSend = textAssignWindow:recursiveGetChildById("sendAutomaticallyCheckBox"):isChecked()
			})
		else
			commitMultiActionSubEntry(slot, multiActionEditIndex, {
				text = text,
				autoSend = textAssignWindow:recursiveGetChildById("sendAutomaticallyCheckBox"):isChecked()
			})
		end

		if closeAfter then
			multiActionEditIndex = nil

			closeTextAssignWindow()
		end

		return
	end

	if spellName then
		clearSlot()

		slot.words = spell.words
		slot.itemId = 469

		slot:setItemId(469)

		if parameter and spell.parameter then
			slot.parameter = parameter
		else
			slot.parameter = nil
		end

		loadSpell(slot)
	else
		clearSlot()
		slot:getChildById("text"):setText(text)

		while slot:getChildById("text"):getTextSize().height > 30 do
			local subString = slot:getChildById("text"):getText()
			local subString = string.sub(subString, 1, #subString - 1)

			slot:getChildById("text"):setText(subString)
		end

		slot.text = text
		slot.itemId = 469

		slot:setItemId(469)

		slot.autoSend = textAssignWindow:recursiveGetChildById("sendAutomaticallyCheckBox"):isChecked()

		loadText(slot)
	end

	if closeAfter then
		closeTextAssignWindow()
	end
end

function openObjectAssignWindow()
	if objectAssignWindow ~= nil then
		objectAssignWindow:destroy()
	end

	objectAssignWindow = g_ui.loadUI("assign_object", g_ui.getRootWidget())
	actionRadioGroup = UIRadioGroup.create()

	actionRadioGroup:addWidget(objectAssignWindow:getChildById("useOnYourselfCheckbox"))
	actionRadioGroup:addWidget(objectAssignWindow:getChildById("useOnTargetCheckbox"))
	actionRadioGroup:addWidget(objectAssignWindow:getChildById("useWithCrosshairCheckbox"))
	actionRadioGroup:addWidget(objectAssignWindow:getChildById("useCursorPositionCheckbox"))
	actionRadioGroup:addWidget(objectAssignWindow:getChildById("equipCheckbox"))
	actionRadioGroup:addWidget(objectAssignWindow:getChildById("useCheckbox"))

	function actionRadioGroup.onSelectionChange()
		if not objectAssignWindow then
			return
		end

		local previewItem = objectAssignWindow:recursiveGetChildById("previewItem")
		local item = previewItem and previewItem:getItem()

		if item then
			actionbarState.updateSmartModeAssignCheckboxState(item, objectAssignWindow._smartModeAssignContext)
		end
	end

	objectAssignWindow:setVisible(false)
	actionbarState.setObjectAssignWindowTitle()
end

function closeObjectAssignWindow()
	objectAssignHiddenForPick = false

	if objectAssignWindow and not objectAssignWindow:isDestroyed() then
		objectAssignWindow:destroy()
	end

	objectAssignWindow = nil
	actionRadioGroup = nil
end

 actionbarState.ASSIGN_OBJECT_CB_ENABLED = "#c0c0c0"
 actionbarState.ASSIGN_OBJECT_CB_DISABLED = "#707070"

  actionbarState[174] = function(item)
	if not item then
		return false
	end

	return item:hasClockExpire() or item:hasExpire() or item:hasExpireStop()
end

  actionbarState.itemIdHasDurationDecay = function(itemId)
	if not itemId or itemId <= 0 then
		return false
	end

	local tt = g_things.getThingType(itemId, ThingCategoryItem)

	if not tt then
		return false
	end

	return tt:hasClockExpire() or tt:hasExpire() or tt:hasExpireStop()
end

  actionbarState.getClothSlotForItemId = function(itemId)
	if not itemId or itemId <= 0 then
		return 0
	end

	local item = Item.create(itemId)

	return item and item:getClothSlot() or 0
end

  actionbarState.smartModeItemMatchesBase = function(baseId, itemId)
	if not baseId or not itemId or baseId <= 0 or itemId <= 0 then
		return false
	end

	if baseId == itemId then
		return true
	end

	local baseTT = g_things.getThingType(baseId, ThingCategoryItem)
	local itemTT = g_things.getThingType(itemId, ThingCategoryItem)

	if not baseTT or not itemTT then
		return false
	end

	local baseName = baseTT:getName()

	if baseName and baseName ~= "" and baseName == itemTT:getName() then
		return true
	end

	local baseMd = baseTT.getMarketData and baseTT:getMarketData()
	local itemMd = itemTT.getMarketData and itemTT:getMarketData()

	return baseMd and itemMd and baseMd.name and baseMd.name ~= "" and baseMd.name == itemMd.name
end

function getActionBarInventoryDisplayCount(itemId, tier, player)
	player = player or g_game.getLocalPlayer()

	if not player or not itemId or itemId <= 0 then
		return 0
	end

	tier = tier or 0

	local count = player:getInventoryCount(itemId, tier)
	local equipped = player:getInventoryItem(InventorySlotFinger)

	if not equipped or equipped:getId() == itemId then
		return count
	end

	local itemType = g_things.getThingType(itemId, ThingCategoryItem)

	if not itemType then
		return count
	end

	local marketData = itemType.getMarketData and itemType:getMarketData()

	if not (itemType:getClothSlot() == InventorySlotFinger or MarketCategory and marketData and marketData.category == MarketCategory.Rings) or not actionbarState.smartModeItemMatchesBase(itemId, equipped:getId()) then
		return count
	end

	if g_game.getFeature(GameThingUpgradeClassification) and (equipped.getTier and equipped:getTier() or 0) ~= tier then
		return count
	end

	return count + 1
end

  actionbarState.smartModeItemMatchesEntry = function(entry, itemId)
	local baseId = entry.smartBaseItemId or entry.itemId

	if actionbarState.smartModeItemMatchesBase(baseId, itemId) then
		return true
	end

	if entry.itemId and entry.itemId ~= baseId then
		return actionbarState.smartModeItemMatchesBase(entry.itemId, itemId)
	end

	return false
end

  actionbarState.updateSmartModeAssignLayout = function(smartVisible)
	if not objectAssignWindow then
		return
	end

	local useCb = objectAssignWindow:getChildById("useCheckbox")
	local equipCb = objectAssignWindow:getChildById("equipCheckbox")
	local smartCb = objectAssignWindow:getChildById("smartModeCheckbox")

	if not useCb or not equipCb then
		return
	end

	useCb:breakAnchors()
	useCb:addAnchor(AnchorLeft, equipCb:getId(), AnchorLeft)
	useCb:setMarginTop(6)

	if smartVisible and smartCb and smartCb:isVisible() then
		useCb:addAnchor(AnchorTop, smartCb:getId(), AnchorBottom)
	else
		useCb:addAnchor(AnchorTop, equipCb:getId(), AnchorBottom)
	end

	objectAssignWindow:updateLayout()
end

 actionbarState.updateSmartModeAssignCheckboxState = function(item, assignContext)
	if not objectAssignWindow or not item then
		return
	end

	local smartCb = objectAssignWindow:getChildById("smartModeCheckbox")
	local equipCb = objectAssignWindow:getChildById("equipCheckbox")

	if not smartCb or not equipCb then
		return
	end

	local baseItemId = assignContext and type(assignContext.smartBaseItemId) == "number" and assignContext.smartBaseItemId or item:getId()
	local showSmart = actionbarState.isEquippableActionBarItem(item) and actionbarState.itemIdHasDurationDecay(baseItemId)

	smartCb:setVisible(showSmart)

	if not showSmart then
		smartCb:setChecked(false)
		smartCb:setEnabled(false)
		actionbarState.updateSmartModeAssignLayout(false)

		return
	end

	local equipSelected = equipCb:isChecked()

	smartCb:setEnabled(equipSelected)
	smartCb:setColor(equipSelected and actionbarState.ASSIGN_OBJECT_CB_ENABLED or actionbarState.ASSIGN_OBJECT_CB_DISABLED)

	if assignContext and assignContext.smartMode == true then
		smartCb:setChecked(true)
	elseif assignContext and assignContext.smartMode == false then
		smartCb:setChecked(false)
	end

	actionbarState.updateSmartModeAssignLayout(true)
end

  actionbarState.readSmartModeFromAssignWindow = function(item, useType, assignContext)
	if useType ~= "equip" or not item then
		return false, nil
	end

	local baseItemId = assignContext and type(assignContext.smartBaseItemId) == "number" and assignContext.smartBaseItemId or item:getId()

	if not actionbarState.itemIdHasDurationDecay(baseItemId) then
		return false, nil
	end

	local smartCb = objectAssignWindow and objectAssignWindow:getChildById("smartModeCheckbox")

	if not smartCb or not smartCb:isVisible() or not smartCb:isChecked() then
		return false, nil
	end

	return true, baseItemId
end

  actionbarState.refreshSmartModeEntry = function(entry, player)
	if not entry or not player or not entry.smartMode or entry.useType ~= "equip" then
		return false
	end

	if not entry.itemId or entry.itemId <= 0 then
		return false
	end

	local baseId = entry.smartBaseItemId or entry.itemId
	local clothSlot = actionbarState.getClothSlotForItemId(baseId)

	if not clothSlot or clothSlot <= 0 then
		return false
	end

	local equipped = player:getInventoryItem(clothSlot)
	local changed = false

	if equipped then
		local eqId = equipped:getId()

		if actionbarState.smartModeItemMatchesEntry(entry, eqId) then
			if eqId ~= entry.itemId then
				if not entry.smartBaseItemId then
					entry.smartBaseItemId = baseId
				end

				entry.itemId = eqId
				changed = true
			end
		elseif entry.itemId ~= baseId then
			entry.itemId = baseId
			changed = true
		end

		entry._smartEquipPending = nil
	elseif entry.smartBaseItemId and entry.itemId ~= entry.smartBaseItemId then
		entry.itemId = entry.smartBaseItemId
		changed = true
		entry._smartEquipPending = nil
	end

	return changed
end

  actionbarState.refreshSmartModeSlot = function(slot)
	if not slot then
		return false
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return false
	end

	if actionbarState.isActionSlotEquipmentPreset(slot) then
		return false
	end

	local changed = false

	if slotHasMultiActions and slotHasMultiActions(slot) and slot.multiActions then
		for i = 1, 3 do
			local entry = slot.multiActions[i]

			if entry and actionbarState.refreshSmartModeEntry(entry, player) then
				changed = true
			end
		end

		if changed and syncMultiActionSlot then
			syncMultiActionSlot(slot)
		end
	elseif slot.smartMode and actionbarState.refreshSmartModeEntry(slot, player) then
		loadObject(slot)
		applyActionSlotFrame(slot)

		changed = true
	end

	return changed
end

 actionbarState.refreshAllSmartModeSlots = function()
	if not g_game.getLocalPlayer() then
		return
	end

	local anyChanged = false

	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				if actionbarState.refreshSmartModeSlot(slot) then
					anyChanged = true
				end
			end
		end
	end

	if anyChanged then
		saveActionBar()
	end
end

  actionbarState.styleAssignObjectCheckbox = function(id, enabled)
	local cb = objectAssignWindow:getChildById(id)

	if not cb then
		return
	end

	cb:setEnabled(enabled)
	cb:setColor(enabled and actionbarState.ASSIGN_OBJECT_CB_ENABLED or actionbarState.ASSIGN_OBJECT_CB_DISABLED)
end

 actionbarState.isEquippableActionBarItem = function(item)
	if not item then
		return false
	end

	local clothSlot = item:getClothSlot()

	if clothSlot == InventorySlotBack then
		return false
	end

	if clothSlot > 0 then
		return true
	end

	local md = item.getMarketData and item:getMarketData()

	if md and md.category then
		local cat = md.category

		if MarketCategoryWeapons and MarketCategoryWeapons[cat] then
			return true
		end

		if MarketCategory and (cat == MarketCategory.FistWeapons or cat == MarketCategory.Quivers or cat == MarketCategory.Shields) then
			return true
		end
	end

	local thingType = g_things.getThingType(item:getId(), ThingCategoryItem)

	if thingType and thingType.isCloth and thingType:isCloth() then
		return true
	end

	return false
end

  actionbarState.isValidActionBarObjectItem = function(arg_346_0, arg_346_1)
	if not arg_346_0 or not arg_346_0.getId then
		return false
	end

	local id = arg_346_0:getId()

	if not id or id <= 0 then
		return false
	end

	local thingType = g_things.getThingType(id, ThingCategoryItem)

	if not thingType then
		return false
	end

	if thingType.isGround and thingType:isGround() then
		return false
	end

	if thingType.isGroundBorder and thingType:isGroundBorder() then
		return false
	end

	if thingType.isFullGround and thingType:isFullGround() then
		return false
	end

	if not thingType.isPickupable or not thingType:isPickupable() then
		return false
	end

	if not arg_346_1 then
		return true
	end

	if actionbarState.isEquippableActionBarItem(arg_346_0) then
		return true
	end

	if thingType.isUsable and thingType:isUsable() then
		return true
	end

	if thingType.isMultiUse and thingType:isMultiUse() then
		return true
	end

	if thingType.isContainer and thingType:isContainer() then
		return true
	end

	if thingType.isMarketable and thingType:isMarketable() then
		return true
	end

	return false
end

function populateObjectAssignWindowFromItem(item, preferredUseType, tierOverride, assignContext)
	if not objectAssignWindow or not item then
		return
	end

	objectAssignWindow._smartModeAssignContext = assignContext

	actionbarState.setObjectAssignWindowTitle()

	local previewItem = objectAssignWindow:recursiveGetChildById("previewItem")

	previewItem:setItemId(item:getId())

	local tier = tierOverride ~= nil and tierOverride or item:getTier()

	ItemsDatabase.setTier(previewItem, 0)
	ItemsDatabase.setBigTier(previewItem, tier)

	previewItem.auxTier = tier

	previewItem:setItemCount(1)

	local var_347_2
	local var_347_3 = actionbarState.isEquippableActionBarItem(item)
	local var_347_4 = item:isMultiUse()

	if var_347_3 and var_347_4 then
		actionbarState.styleAssignObjectCheckbox("useOnYourselfCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useOnTargetCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useWithCrosshairCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useCursorPositionCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("equipCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useCheckbox", false)

		var_347_2 = objectAssignWindow:getChildById("equipCheckbox")
	elseif var_347_3 then
		actionbarState.styleAssignObjectCheckbox("equipCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useOnYourselfCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useOnTargetCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useWithCrosshairCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useCursorPositionCheckbox", false)

		var_347_2 = objectAssignWindow:getChildById("equipCheckbox")
	elseif var_347_4 then
		actionbarState.styleAssignObjectCheckbox("useOnYourselfCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useOnTargetCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useWithCrosshairCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("useCursorPositionCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("equipCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useCheckbox", false)

		var_347_2 = objectAssignWindow:getChildById("useOnYourselfCheckbox")
	else
		actionbarState.styleAssignObjectCheckbox("useCheckbox", true)
		actionbarState.styleAssignObjectCheckbox("equipCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useOnYourselfCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useOnTargetCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useWithCrosshairCheckbox", false)
		actionbarState.styleAssignObjectCheckbox("useCursorPositionCheckbox", false)

		var_347_2 = objectAssignWindow:getChildById("useCheckbox")
	end

	local var_347_5 = {
		useWith = "useWithCrosshairCheckbox",
		useOnSelf = "useOnYourselfCheckbox",
		useAtCursor = "useCursorPositionCheckbox",
		use = "useCheckbox",
		equip = "equipCheckbox",
		useOnTarget = "useOnTargetCheckbox"
	}
	local var_347_6 = var_347_2

	if preferredUseType then
		local var_347_7 = var_347_5[preferredUseType]

		if var_347_7 then
			local childById = objectAssignWindow:getChildById(var_347_7)

			if childById and childById:isEnabled() then
				var_347_6 = childById
			end
		end
	end

	if var_347_6 then
		actionRadioGroup:selectWidget(var_347_6)
	end

	actionbarState.updateSmartModeAssignCheckboxState(item, assignContext)

	if not objectAssignWindow:isVisible() then
		objectAssignWindow:show()
	end

	local smartModeCheckbox = objectAssignWindow:getChildById("smartModeCheckbox")

	actionbarState.updateSmartModeAssignLayout(smartModeCheckbox and smartModeCheckbox:isVisible())
	objectAssignWindow:raise()
	objectAssignWindow:focus()
end

  actionbarState.findGameMapWidgetAtClick = function(clickedWidget)
	if not clickedWidget then
		return nil
	end

	if clickedWidget:getClassName() == "UIGameMap" then
		return clickedWidget
	end

	local w = clickedWidget

	while w do
		if w:getClassName() == "UIGameMap" then
			return w
		end

		w = w:getParent()
	end

	return nil
end

 actionbarState.resolvePickItemAtMouse = function(arg_349_0)
	local rootPanel = modules.game_interface.getRootPanel()

	if not rootPanel then
		return nil
	end

	local var_349_1 = rootPanel:recursiveGetChildByPos(arg_349_0, false)

	if not var_349_1 then
		return nil
	end

	if var_349_1:getClassName() == "UIItem" and not var_349_1:isVirtual() then
		local item = var_349_1:getItem()

		if actionbarState.isValidActionBarObjectItem(item, false) then
			return item
		end

		return nil
	end

	local var_349_3 = actionbarState.findGameMapWidgetAtClick(var_349_1)

	if var_349_3 and var_349_3.getTile then
		local tile = var_349_3:getTile(arg_349_0)

		if tile then
			local topMoveThing = tile:getTopMoveThing()

			if topMoveThing and topMoveThing.isItem and topMoveThing:isItem() and actionbarState.isValidActionBarObjectItem(topMoveThing, true) then
				return topMoveThing
			end
		end
	end

	return nil
end

  actionbarState.restoreObjectAssignWindowAfterPick = function()
	if not objectAssignHiddenForPick then
		return
	end

	objectAssignHiddenForPick = false

	if objectAssignWindow and not objectAssignWindow:isDestroyed() then
		objectAssignWindow:show()

		local smartModeCheckbox = objectAssignWindow:getChildById("smartModeCheckbox")

		actionbarState.updateSmartModeAssignLayout(smartModeCheckbox and smartModeCheckbox:isVisible())
		objectAssignWindow:raise()
		objectAssignWindow:focus()
	end
end

function startChooseItem()
	if g_ui.isMouseGrabbed() then
		return
	end

	if objectAssignWindow and not objectAssignWindow:isDestroyed() and objectAssignWindow:isVisible() then
		objectAssignWindow:hide()

		objectAssignHiddenForPick = true
	end

	mouseGrabberWidget:grabMouse()
	g_mouse.pushCursor("target")
end

  actionbarState.applyObjectAssign = function(closeAfter)
	local item = objectAssignWindow:recursiveGetChildById("previewItem"):getItem()

	if not item then
		return
	end

	local slot = findSlotById(slotToEdit)

	if not slot then
		closeObjectAssignWindow()

		return
	end

	local useType = "use"

	if objectAssignWindow:getChildById("equipCheckbox"):isChecked() then
		useType = "equip"
	elseif objectAssignWindow:getChildById("useCheckbox"):isChecked() then
		useType = "use"
	elseif objectAssignWindow:getChildById("useOnYourselfCheckbox"):isChecked() then
		useType = "useOnSelf"
	elseif objectAssignWindow:getChildById("useOnTargetCheckbox"):isChecked() then
		useType = "useOnTarget"
	elseif objectAssignWindow:getChildById("useWithCrosshairCheckbox"):isChecked() then
		useType = "useWith"
	elseif objectAssignWindow:getChildById("useCursorPositionCheckbox"):isChecked() then
		useType = "useAtCursor"
	end

	local smartMode, smartBaseItemId = actionbarState.readSmartModeFromAssignWindow(item, useType, objectAssignWindow and objectAssignWindow._smartModeAssignContext)

	if externalAssignSlotId and slotToEdit == externalAssignSlotId then
		slot.itemId = item:getId()
		slot.useType = useType
		slot.getTier = objectAssignWindow:recursiveGetChildById("previewItem").auxTier

		if item:isFluidContainer() then
			slot.subType = item:getSubType()
		else
			slot.subType = nil
		end

		if onExternalObjectAssignApplied then
			onExternalObjectAssignApplied(slot)
		end

		if closeAfter then
			closeObjectAssignWindow()
		end

		return
	end

	if multiActionEditIndex then
		local subType

		if item:isFluidContainer() then
			subType = item:getSubType()
		end

		commitMultiActionSubEntry(slot, multiActionEditIndex, {
			itemId = item:getId(),
			subType = subType,
			useType = useType,
			getTier = objectAssignWindow:recursiveGetChildById("previewItem").auxTier,
			smartMode = smartMode and true or nil,
			smartBaseItemId = smartBaseItemId
		})
		actionbarState.refreshSmartModeSlot(slot)

		if closeAfter then
			multiActionEditIndex = nil

			closeObjectAssignWindow()
		end

		return
	end

	clearSlot()
	slot:setItem(item)
	slot:setBorderWidth(0)

	slot.itemId = item:getId()
	slot.getTier = objectAssignWindow:recursiveGetChildById("previewItem").auxTier

	ItemsDatabase.setTier(slot, slot.getTier)

	if item:isFluidContainer() then
		slot.subType = item:getSubType()
	end

	slot.useType = useType
	slot.smartMode = smartMode and true or nil
	slot.smartBaseItemId = smartBaseItemId

	updateSlotGray(slot)
	refreshActionSlotInventoryQuantity(slot)
	applyActionSlotFrame(slot)
	actionbarState.refreshSmartModeSlot(slot)
	setupHotkeys()

	if closeAfter then
		closeObjectAssignWindow()
	end
end

function objectAssignApply()
	actionbarState.applyObjectAssign(false)
end

function objectAssignOk()
	actionbarState.applyObjectAssign(true)
end

function objectAssignAccept()
	objectAssignOk()
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
	if CrosshairCast.isActive() then
		return onSpellCrosshairMouseRelease(self, mousePosition, mouseButton)
	end

	if cyclopediaSpellAssign then
		return onCyclopediaSpellAssignMouseRelease(self, mousePosition, mouseButton)
	end

	if actionbarState.equipmentAssignPickInvSlot ~= nil then
		return actionbarState.onEquipmentAssignChooseItemMouseRelease(self, mousePosition, mouseButton)
	end

	local item
	local hadMapClick = false

	if mouseButton == MouseLeftButton then
		local root = modules.game_interface.getRootPanel()
		local clickedWidget = root and root:recursiveGetChildByPos(mousePosition, false)

		if clickedWidget and actionbarState.findGameMapWidgetAtClick(clickedWidget) then
			hadMapClick = true
		end

		item = actionbarState.resolvePickItemAtMouse(mousePosition)

		if hadMapClick and not item and objectAssignHiddenForPick then
			modules.game_textmessage.displayFailureMessage(tr("Sorry, not possible."))
		end
	end

	if item and (slotToEdit or objectAssignHiddenForPick) then
		objectAssignHiddenForPick = false

		populateObjectAssignWindowFromItem(item)
	else
		actionbarState.restoreObjectAssignWindowAfterPick()
	end

	g_mouse.popCursor("target")
	self:ungrabMouse()

	return true
end

function onChooseItemByDrag(self, mousePosition, item)
	if slotToEdit and isActionBarLocked(getSlotBarId(slotToEdit)) then
		return
	end

	if item and slotToEdit then
		openObjectAssignWindow()
		populateObjectAssignWindowFromItem(item)
	elseif not slotToEdit then
		itemDragRetry = true
		missedSlotToEdit = {
			self,
			mousePosition,
			item
		}
	end
end

function onDragReassign(self, item)
	slotReassign = self
end

function openEditHotkeyWindow()
	local rootW = g_ui.getRootWidget()

	editHotkeyOverlay = g_ui.createWidget("UIWidget", rootW)

	editHotkeyOverlay:setId("editHotkeyCaptureOverlay")
	editHotkeyOverlay:setFocusable(true)
	editHotkeyOverlay:setDraggable(false)
	editHotkeyOverlay:addAnchor(AnchorLeft, "parent", AnchorLeft)
	editHotkeyOverlay:addAnchor(AnchorRight, "parent", AnchorRight)
	editHotkeyOverlay:addAnchor(AnchorTop, "parent", AnchorTop)
	editHotkeyOverlay:addAnchor(AnchorBottom, "parent", AnchorBottom)

	editHotkeyWindow = g_ui.loadUI("assign_hotkey", editHotkeyOverlay)

	editHotkeyWindow:breakAnchors()
	editHotkeyWindow:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	editHotkeyWindow:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)

	local chatModeLabel = editHotkeyWindow:recursiveGetChildById("chatMode")

	if chatModeLabel and modules.game_console and modules.game_console.isChatEnabled then
		local chatOn = modules.game_console.isChatEnabled()

		chatModeLabel:setText(chatOn and tr("Mode: \"Chat On\"") or tr("Mode: \"Chat Off\""))
	end

	local instrLabel = editHotkeyWindow:recursiveGetChildById("hotkeyInstructionLabel")
	local barId, slotIdx = actionbarState.slotBarAndIndexFromSlotId(slotToEdit)

	if barId and slotIdx then
		local region = actionbarState.actionBarRegionTitle(barId)
		local barNum = actionbarState.actionBarDisplayNumber(barId)

		editHotkeyWindow:setText(tr("Edit Hotkey for \"%s: Action Button %d.%d\"", region, barNum, slotIdx))

		if instrLabel then
			instrLabel:setText(tr("Click \"Ok\" to assign the hotkey. Click \"Clear\" to remove the hotkey from \"%s: Action Button %d.%d\".", region, barNum, slotIdx))
		end
	else
		editHotkeyWindow:setText(tr("Edit Hotkey"))

		if instrLabel then
			instrLabel:setText(tr("Click \"Ok\" to assign the hotkey. Click \"Clear\" to remove the hotkey."))
		end
	end

	local slotBeingEdited = findSlotById(slotToEdit)
	local existingCombo = ""

	if slotBeingEdited then
		existingCombo = getSlotHotkeyForChatMode(slotBeingEdited)
	end

	editHotkeyPendingCombo = existingCombo

	local comboLabel = editHotkeyWindow:recursiveGetChildById("comboPreview")

	if comboLabel then
		comboLabel:setText(tr("%s", existingCombo))
		comboLabel:resizeToText()
	end

	local errPreview = editHotkeyWindow:recursiveGetChildById("errorLabel")

	ActionBarHotkeyLogic.updateHotkeyCaptureUI(editHotkeyWindow, existingCombo, slotToEdit)
	editHotkeyOverlay:grabMouse()
	editHotkeyWindow:grabKeyboard()

	editHotkeyWindow.onKeyDown = hotkeyCapture

	function editHotkeyOverlay.onMousePress(_, mousePos, mouseButton)
		return hotkeyCaptureMousePress(editHotkeyWindow, mousePos, mouseButton)
	end

	function editHotkeyOverlay.onMouseWheel(_, mousePos, direction)
		return hotkeyCaptureMouseWheel(editHotkeyWindow, mousePos, direction)
	end

	function editHotkeyWindow.onMousePress(_, mousePos, mouseButton)
		return hotkeyCaptureMousePress(editHotkeyWindow, mousePos, mouseButton)
	end

	function editHotkeyWindow.onMouseWheel(_, mousePos, direction)
		return hotkeyCaptureMouseWheel(editHotkeyWindow, mousePos, direction)
	end

	editHotkeyOverlay:raise()
	editHotkeyWindow:raise()
	editHotkeyWindow:focus()

	editHotkeyWindow.hotkeyBlock = HotkeyUtils.createHotkeyBlock("edit_hotkey_window")
end

function closeEditHotkeyWindow()
	if editHotkeyOverlay then
		editHotkeyOverlay:ungrabMouse()
		editHotkeyOverlay:destroy()
	end

	editHotkeyOverlay = nil
	editHotkeyWindow = nil
	editHotkeyPendingCombo = ""
end

function unbindHotkeys()
	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				local a = slot.hotkeyChatOn
				local b = slot.hotkeyChatOff

				if a == nil or a == "" then
					a = ""
				elseif type(a) ~= "string" then
					a = tostring(a)
				end

				if b == nil or b == "" then
					b = ""
				elseif type(b) ~= "string" then
					b = tostring(b)
				end

				if a ~= "" then
					g_mouse.unbindComboHotkeyPress(a, modules.game_interface and modules.game_interface.getRootPanel())
				end

				if b ~= "" and b ~= a then
					g_mouse.unbindComboHotkeyPress(b, modules.game_interface and modules.game_interface.getRootPanel())
				end
			end
		end
	end
end

  actionbarState.actionBarResolveSourceItem = function(slot)
	local tier = slot.getTier or 0

	if slot.subType then
		return g_game.findPlayerItem(slot.itemId, slot.subType or -1, tier)
	end

	return nil
end

  actionbarState.actionBarPerformInventoryUseWith = function(slot, toThing, arg_367_2)
	if not toThing then
		return
	end

	local invItem = actionbarState.actionBarResolveSourceItem(slot)

	if not slot.subType then
		CrosshairCast.prioritizeManualHotkey(arg_367_2)
		g_game.useInventoryItemWith(slot.itemId, toThing)
	elseif invItem then
		CrosshairCast.prioritizeManualHotkey(arg_367_2)
		g_game.useWith(invItem, toThing)
	else
		local item = Item.create(slot.itemId)

		if not item then
			return
		end

		if slot.subType then
			item:setSubType(slot.subType)
		end

		if slot.getTier then
			item:setTier(slot.getTier)
		end

		CrosshairCast.prioritizeManualHotkey(arg_367_2)
		g_game.useWith(item, toThing)
	end
end

  actionbarState.actionBarPickTileTargetForUseWith = function(tile, logicItem)
	if not tile or not logicItem then
		return nil
	end

	local target

	if logicItem:isFluidContainer() or logicItem:isMultiUse() then
		target = tile:getTopMultiUseThing()
	else
		target = tile:getTopUseThing()
	end

	target = target or tile:getTopCreature()

	return target
end

  actionbarState.actionBarUseItemAtCursor = function(slot, arg_369_1)
	if not slot or not slot.itemId then
		return
	end

	local mousePos = g_window.getMousePosition()
	local root = modules.game_interface.getRootPanel()

	if not root then
		return
	end

	local leaf = root:recursiveGetChildByPos(mousePos, false)
	local mapWidget = leaf

	while mapWidget and mapWidget:getClassName() ~= "UIGameMap" do
		mapWidget = mapWidget:getParent()
	end

	local logicItem = actionbarState.actionBarResolveSourceItem(slot)

	if not logicItem then
		logicItem = Item.create(slot.itemId)

		if not logicItem then
			return
		end

		if slot.subType then
			logicItem:setSubType(slot.subType)
		end

		if slot.getTier then
			logicItem:setTier(slot.getTier)
		end
	end

	if mapWidget then
		local tile = mapWidget:getTile(mousePos)

		if not tile then
			return
		end

		local var_369_6 = actionbarState.actionBarPickTileTargetForUseWith(tile, logicItem)

		if var_369_6 then
			actionbarState.actionBarPerformInventoryUseWith(slot, var_369_6, arg_369_1)
		end

		return
	end

	if leaf then
		local cn = leaf:getClassName()

		if cn == "UIItem" and not leaf:isVirtual() then
			local item = leaf:getItem()

			if item then
				actionbarState.actionBarPerformInventoryUseWith(slot, item, arg_369_1)
			end

			return
		end

		if cn == "UICreatureButton" then
			local creature = leaf:getCreature()

			if creature then
				actionbarState.actionBarPerformInventoryUseWith(slot, creature, arg_369_1)
			end
		end
	end
end

  actionbarState.actionSlotSpellStillOnCooldown = function(slot)
	if not slot then
		return false
	end

	if slot.words and slot.words ~= "" then
		local spell = Spells.getSpellByWords(slot.words)

		if not spell then
			return false
		end

		if getMultiActionCooldownRemaining then
			local spellRem, groupRem = getMultiActionCooldownRemaining(spell)

			if spellRem > 0 or groupRem > 0 then
				return true
			end
		end

		local spellCd = cooldown[spell.id]

		if spellCd and spellCd > 0 then
			return true
		end

		if spell.group then
			for groupId, _ in pairs(spell.group) do
				if groupCooldown[groupId] then
					return true
				end
			end
		end

		return false
	end

	return false
end

function CrosshairCast.prioritizeManualHotkey(arg_371_0)
	if not arg_371_0 then
		return
	end

	local game_helper = modules.game_helper

	if game_helper and game_helper.beginManualHotkeyAction then
		game_helper.beginManualHotkeyAction()
	end
end

function CrosshairCast.isActive()
	return CrosshairCast.activeWords ~= nil
end

function CrosshairCast.getMapTilePositionAt(pos)
	local gameInterface = modules.game_interface

	if not gameInterface or not gameInterface.getRootPanel then
		return nil
	end

	local root = gameInterface.getRootPanel()

	if not root then
		return nil
	end

	local node = root:recursiveGetChildByPos(pos, false)

	while node and node:getClassName() ~= "UIGameMap" do
		node = node:getParent()
	end

	if not node then
		return nil
	end

	local tile = node:getTile(pos)

	if not tile then
		return nil
	end

	return tile:getPosition()
end

function CrosshairCast.finish()
	CrosshairCast.activeWords = nil
	CrosshairCast.activeHotkey = nil

	if mouseGrabberWidget and not mouseGrabberWidget:isDestroyed() then
		mouseGrabberWidget:ungrabMouse()
	end

	if g_mouse and g_mouse.popCursor then
		g_mouse.popCursor("target")
	end
end

function CrosshairCast.start(words, mode)
	if not words or words == "" then
		return
	end

	if not mouseGrabberWidget or mouseGrabberWidget:isDestroyed() then
		return
	end

	if g_ui.isMouseGrabbed and g_ui.isMouseGrabbed() then
		return
	end

	CrosshairCast.activeWords = words
	CrosshairCast.activeHotkey = mode == true

	mouseGrabberWidget:grabMouse()

	if g_mouse and g_mouse.pushCursor then
		g_mouse.pushCursor("target")
	end
end

function CrosshairCast.castWithMode(words, arg_376_1, arg_376_2)
	if not words or words == "" then
		return
	end

	if type(words) ~= "string" then
		words = tostring(words)
	end

	if not g_game.talkSpell then
		CrosshairCast.prioritizeManualHotkey(arg_376_2)
		g_game.talk(words)

		return
	end

	arg_376_1 = actionbarState.normalizeCrossHairMode(arg_376_1)

	if arg_376_1 == "cursor" then
		local mapTilePositionAt = CrosshairCast.getMapTilePositionAt(g_window.getMousePosition())

		if mapTilePositionAt then
			CrosshairCast.prioritizeManualHotkey(arg_376_2)
			g_game.talkSpell(words, 2, mapTilePositionAt)
		end
	elseif arg_376_1 == "target" then
		CrosshairCast.prioritizeManualHotkey(arg_376_2)
		g_game.talkSpell(words, 3, {
			x = 0,
			z = 0,
			y = 0
		})
	else
		CrosshairCast.start(words, arg_376_2)
	end
end

function onSpellCrosshairMouseRelease(self, mousePosition, mouseButton)
	local words = CrosshairCast.activeWords
	local activeHotkey = CrosshairCast.activeHotkey

	CrosshairCast.finish()

	if mouseButton ~= MouseLeftButton then
		return true
	end

	if not words or words == "" then
		return true
	end

	local mapTilePositionAt = CrosshairCast.getMapTilePositionAt(mousePosition)

	if mapTilePositionAt and g_game.talkSpell then
		CrosshairCast.prioritizeManualHotkey(activeHotkey)
		g_game.talkSpell(words, 1, mapTilePositionAt)
	end

	return true
end

function executeActionSlot(slot, fromKeyboard)
	if closeCurrentMultiActionPanel then
		closeCurrentMultiActionPanel()
	end

	if closeCurrentMultiHelperPanel then
		closeCurrentMultiHelperPanel()
	end

	if isMultiHelperSlot(slot) then
		local game_helper = modules.game_helper

		if game_helper and game_helper.toggleHelperStatsEntry then
			local var_378_1 = HelperAction.filledEntries(slot.multiHelper)
			local var_378_2 = not HelperAction.allEnabled(slot.multiHelper)

			for iter_378_0 = 1, #var_378_1 do
				local var_378_3 = var_378_1[iter_378_0].id

				if HelperAction.isEnabled(var_378_3) ~= var_378_2 then
					game_helper.toggleHelperStatsEntry(var_378_3)
				end
			end
		end

		refreshMultiHelperSlotBorder(slot)
		refreshActionSlotTooltip(slot)

		return
	end

	if isHelperActionSlot(slot) then
		local game_helper = modules.game_helper

		if game_helper and game_helper.toggleHelperStatsEntry then
			game_helper.toggleHelperStatsEntry(slot.helperId)
		end

		refreshHelperSlotBorder(slot)
		refreshActionSlotTooltip(slot)

		return
	end

	if slot.itemId and slot.useType then
		if slot.useType == "use" then
			HotkeyUtils.executeHotkeyItem(HOTKEY_USE, slot.itemId, slot.subType, fromKeyboard and CrosshairCast.prioritizeManualHotkey or nil)
		elseif slot.useType == "useOnTarget" then
			HotkeyUtils.executeHotkeyItem(HOTKEY_USEONTARGET, slot.itemId, slot.subType, fromKeyboard and CrosshairCast.prioritizeManualHotkey or nil)
		elseif slot.useType == "useWith" then
			HotkeyUtils.executeHotkeyItem(HOTKEY_USEWITH, slot.itemId, slot.subType, fromKeyboard and CrosshairCast.prioritizeManualHotkey or nil)
		elseif slot.useType == "useOnSelf" then
			HotkeyUtils.executeHotkeyItem(HOTKEY_USEONSELF, slot.itemId, slot.subType, fromKeyboard and CrosshairCast.prioritizeManualHotkey or nil)
		elseif slot.useType == "equip" then
			if actionbarState.isActionSlotEquipmentPreset(slot) then
				if actionbarState[104](slot) then
					local player = g_game.getLocalPlayer()

					if player then
						local game_helper = modules.game_helper

						if game_helper and game_helper.beginManualEquipmentAction then
							pcall(game_helper.beginManualEquipmentAction)
						end

						for _, invSlot in ipairs(actionbarState.EQUIPMENT_SET_EQUIP_ORDER) do
							if not actionbarState.actionSlotPresetEntryForSlot(slot, invSlot) then
								local equipped = player:getInventoryItem(invSlot)

								if equipped then
									local tier = equipped.getTier and equipped:getTier() or 0

									g_game.equipItemId(equipped:getId(), tier)
								end
							end
						end

						for _, invSlot in ipairs(actionbarState.EQUIPMENT_SET_EQUIP_ORDER) do
							local entry = actionbarState.actionSlotPresetEntryForSlot(slot, invSlot)

							if entry and not actionbarState.actionSlotPresetEntryMatchesEquipped(player, invSlot, entry) then
								g_game.equipItemId(entry.itemId, entry.getTier or 0)
							end
						end
					end
				end

				actionbarState.startEquipmentSetActionCooldown()
			elseif slot.itemId and slot.itemId > 0 then
				local player = g_game.getLocalPlayer()

				if player then
					local tier = actionbarState.actionSlotItemTier(slot)

					if player:getInventoryCount(slot.itemId, tier) > 0 or actionbarState.isActionSlotEquipEquipped(slot) then
						local game_helper = modules.game_helper

						if game_helper and game_helper.beginManualEquipmentAction then
							pcall(game_helper.beginManualEquipmentAction, slot.itemId)
						end

						if slot.smartMode then
							slot._smartEquipPending = true

							if slotHasMultiActions and slotHasMultiActions(slot) and slot._activeMultiIndex and slot.multiActions then
								local entry = slot.multiActions[slot._activeMultiIndex]

								if entry then
									entry._smartEquipPending = true
								end
							end
						end

						g_game.equipItemId(slot.itemId, tier)
					end
				end
			end
		elseif slot.useType == "useAtCursor" then
			actionbarState.actionBarUseItemAtCursor(slot, fromKeyboard)
		end
	elseif slot.words and slot.words ~= "" then
		local words = slot.parameter and slot.parameter ~= "" and slot.words .. " \"" .. slot.parameter or slot.words
		local spell = Spells.getSpellByWords and Spells.getSpellByWords(slot.words) or nil

		if spell and Spells.hasCrossHairTarget(spell) then
			CrosshairCast.castWithMode(words, actionbarState.normalizeCrossHairMode(slot.crossHairMode), fromKeyboard)
		else
			CrosshairCast.prioritizeManualHotkey(fromKeyboard)
			g_game.talk(words)
		end
	elseif slot.text then
		if slot.autoSend then
			modules.game_console.sendActionBarMessage(slot.text)
		elseif fromKeyboard then
			scheduleEvent(function()
				if not modules.game_console.isChatEnabled() then
					modules.game_console.switchChatOnCall()
				end

				modules.game_console.setTextEditText(slot.text)
			end, 1)
		else
			if not modules.game_console.isChatEnabled() then
				modules.game_console.switchChatOnCall()
			end

			modules.game_console.setTextEditText(slot.text)
		end
	end
end

  actionbarState.tryExecuteActionSlot = function(slot, fromKeyboard)
	if not slot then
		return
	end

	local isEquip = actionbarState.isActionSlotEquip(slot)

	if isEquip and actionbarState.isActionSlotEquipmentPreset(slot) and actionbarState.isEquipmentSetActionOnCooldown(slot) then
		return
	end

	if slotHasMultiActions and slotHasMultiActions(slot) and executeMultiActionSlot and executeMultiActionSlot(slot, fromKeyboard) then
		if syncMultiActionSlot then
			syncMultiActionSlot(slot)
		end

		return
	end

	if slot.words and slot.words ~= "" and actionbarState.actionSlotSpellStillOnCooldown(slot) then
		executeActionSlot(slot, fromKeyboard)

		return
	end

	executeActionSlot(slot, fromKeyboard)

	if isEquip then
		refreshActionSlotFrameClip(slot)
	end
end

  actionbarState.bindSlotHotkey = function(slot)
	function slot.onMouseRelease()
		actionbarState.tryExecuteActionSlot(slot, false)
	end

	if slot.hotkey and slot.hotkey ~= "" then
		g_mouse.bindComboHotkeyPress(slot.hotkey, function()
			if not HotkeyUtils.canPerformKeyCombo(slot.hotkey) then
				return
			end

			if not HotkeyUtils.tryAcquireHotkeyCooldown(slot.hotkey) then
				return
			end

			actionbarState.tryExecuteActionSlot(slot, true)
		end, modules.game_interface and modules.game_interface.getRootPanel())
	end
end

function setupHotkeys()
	updateScrollButtons()
	unbindHotkeys()
	actionbarState.refreshAllSlotsHotkeyMirror()

	if hotkeyPauseDepth > 0 then
		return
	end

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				actionbarState.bindSlotHotkey(slot)
			end
		end
	end

	local game_walk = modules.game_walk

	if game_walk and game_walk.movementKeyBindsNeedSync and game_walk.movementKeyBindsNeedSync() and modules.game_console and modules.game_console.syncMovingKeys then
		modules.game_console.syncMovingKeys()
	end
end

function pauseHotkeys()
	hotkeyPauseDepth = hotkeyPauseDepth + 1

	if hotkeyPauseDepth == 1 then
		unbindHotkeys()
	end
end

function resumeHotkeys()
	if hotkeyPauseDepth <= 0 then
		return
	end

	hotkeyPauseDepth = hotkeyPauseDepth - 1

	if hotkeyPauseDepth == 0 and not HotkeyUtils.areHotkeysDisabled() then
		setupHotkeys()
	end
end

function forceResumeHotkeys()
	hotkeyPauseDepth = 0

	if not HotkeyUtils.areHotkeysDisabled() then
		setupHotkeys()
	end
end

function isKeyComboUsedOnActionBar(keyCombo, chatOn)
	if not keyCombo or keyCombo == "" then
		return false
	end

	if chatOn == nil then
		chatOn = modules.game_console and modules.game_console.isChatEnabled and modules.game_console.isChatEnabled()
	end

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				if getSlotHotkeyForChatMode(slot, chatOn) == keyCombo then
					return true
				end
			end
		end
	end

	return false
end

function clearActionBarHotkeyConflicts(keyCombo, chatOn)
	if not keyCombo or keyCombo == "" then
		return false
	end

	if chatOn == nil then
		chatOn = modules.game_console and modules.game_console.isChatEnabled and modules.game_console.isChatEnabled()
	end

	local cleared = false

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				if getSlotHotkeyForChatMode(slot, chatOn) == keyCombo then
					if chatOn then
						slot.hotkeyChatOn = ""
					else
						slot.hotkeyChatOff = ""
					end

					actionbarState.syncSlotHotkeyMirror(slot)

					cleared = true
				end
			end
		end
	end

	if cleared then
		unbindHotkeys()
		setupHotkeys()
		saveActionBar()
	end

	return cleared
end

function checkHotkey(hotkey, excludeSlotId)
	if not hotkey or hotkey == "" then
		return false
	end

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, k in pairs(panel:getChildren()) do
				if excludeSlotId and k:getId() == excludeSlotId then
					-- block empty
				elseif getSlotHotkeyForChatMode(k) == hotkey then
					return true
				end
			end
		end
	end

	return false
end

function hotkeyCapture(assignWindow, keyCode, keyboardModifiers, keyText)
	local keyCombo = determineKeyComboDesc(keyCode, keyboardModifiers, keyText)

	ActionBarHotkeyLogic.updateHotkeyCaptureUI(assignWindow, keyCombo, slotToEdit)

	return true
end

function hotkeyCaptureMousePress(assignWindow, mousePos, mouseButton)
	if mouseButton == MouseLeftButton or mouseButton == MouseRightButton then
		return false
	end

	local keyCombo = g_mouse.mouseButtonToHotkeyDesc(mouseButton)

	if not keyCombo then
		return false
	end

	ActionBarHotkeyLogic.updateHotkeyCaptureUI(assignWindow, keyCombo, slotToEdit)

	return true
end

function hotkeyCaptureMouseWheel(assignWindow, mousePos, direction)
	local keyCombo = g_mouse.wheelDirectionToHotkeyDesc(direction)

	if not keyCombo then
		return false
	end

	ActionBarHotkeyLogic.updateHotkeyCaptureUI(assignWindow, keyCombo, slotToEdit)

	return true
end

function hotkeyClear(assignWindow)
	local slot = findSlotById(slotToEdit)

	if slot then
		if modules.game_console.isChatEnabled() then
			slot.hotkeyChatOn = ""
		else
			slot.hotkeyChatOff = ""
		end

		actionbarState.syncSlotHotkeyMirror(slot)
		setupHotkeys()
		saveActionBar()
	end

	if assignWindow == editHotkeyWindow then
		closeEditHotkeyWindow()

		return
	end

	editHotkeyPendingCombo = ""

	local comboPreview = assignWindow:recursiveGetChildById("comboPreview")

	if comboPreview then
		comboPreview:setText(tr(""))
		comboPreview:resizeToText()
	end
end

function hotkeyCaptureOk(assignWindow)
	local keyCombo = editHotkeyPendingCombo

	if type(keyCombo) ~= "string" then
		keyCombo = keyCombo ~= nil and tostring(keyCombo) or ""
	end

	if keyCombo == "" then
		return
	end

	if g_keyboard.isReservedMovementHotkey(keyCombo) then
		return
	end

	local slot = findSlotById(slotToEdit)

	if not slot then
		if assignWindow == editHotkeyWindow then
			closeEditHotkeyWindow()

			return
		end

		assignWindow:destroy()

		return
	end

	if checkHotkey(keyCombo, slotToEdit) then
		local chatOn = modules.game_console.isChatEnabled()

		for i = 1, NUM_BARS do
			local panel = actionBarPanels[i]

			if panel then
				for _, k in pairs(panel:getChildren()) do
					if k:getId() ~= slotToEdit and getSlotHotkeyForChatMode(k) == keyCombo then
						if chatOn then
							k.hotkeyChatOn = ""
						else
							k.hotkeyChatOff = ""
						end

						actionbarState.syncSlotHotkeyMirror(k)
					end
				end
			end
		end
	end

	local chatMode = modules.game_console.isChatEnabled() and CHAT_MODE.ON or CHAT_MODE.OFF
	local clearedCustom = false

	if Keybind and Keybind.clearCustomHotkeyConflicts then
		clearedCustom = Keybind.clearCustomHotkeyConflicts(keyCombo, chatMode)
	elseif CustomHotkeyManager and CustomHotkeyManager.clearKeyComboConflicts then
		clearedCustom = CustomHotkeyManager.clearKeyComboConflicts(keyCombo, chatMode)
	end

	if clearedCustom and CustomHotkeys and CustomHotkeys.refreshPanel then
		CustomHotkeys.refreshPanel()
	end

	unbindHotkeys()

	if modules.game_console.isChatEnabled() then
		slot.hotkeyChatOn = keyCombo or ""
	else
		slot.hotkeyChatOff = keyCombo or ""
	end

	actionbarState.syncSlotHotkeyMirror(slot)
	setupHotkeys()
	saveActionBar()

	if assignWindow == editHotkeyWindow then
		closeEditHotkeyWindow()

		return
	end

	assignWindow:destroy()
end

function saveActionBar()
	if actionBarBatchDepth > 0 then
		return
	end

	local preset = actionBarPreparedPreset or getActionBarDefaultPresetName()

	if not preset or preset == "" then
		return
	end

	saveActionBarSlotsForPreset(preset, actionbarState.collectCharacterActionBarSlots())
end

function canUseSpell(spell)
	if not spell or not spell.vocations then
		return true
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	local vocation = translateVocation(player:getVocation())

	return table.contains(spell.vocations, vocation)
end

  actionbarState.playerMeetsSpellLevelAndMana = function(spell)
	if not spell then
		return false
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return true
	end

	if spell.level and player:getLevel() < spell.level then
		return false
	end

	if spell.mana and player:getMana() < spell.mana then
		return false
	end

	return true
end

function refreshAssignSpellListGrayOverlays()
	if not spellsPanel then
		return
	end

	for _, row in pairs(spellsPanel:getChildren()) do
		local spellName = row:getId()
		local spell = spellName and spellName ~= "" and Spells.getSpellByName(spellName) or nil
		local gray = row:getChildById("spellIconGray")

		if gray then
			gray:setVisible(spell ~= nil and not actionbarState.spellPassesAssignLearntFilter(spell))
		end
	end
end

function updateSlotGray(slot)
	local grayPanel = slot:getChildById("gray")

	if not grayPanel then
		return
	end

	local show = false

	slot.grayManaCost = nil

	if slot.words then
		local spell = Spells.getSpellByWords(slot.words)
		local manaCost = spell and tonumber(spell.mana) or nil

		slot.grayManaCost = manaCost and manaCost > 0 and manaCost or nil

		local vocOk = canUseSpell(spell)
		local statsOk = actionbarState.playerMeetsSpellLevelAndMana(spell)

		show = not vocOk or not statsOk
	elseif slot.passiveId then
		show = not PassiveAbilityUnlockedInWheel(slot.passiveId)
	elseif isHelperActionSlot(slot) or isMultiHelperSlot(slot) then
		show = false
	elseif slot.text then
		show = false
	elseif actionbarState.isActionSlotEquipmentPreset(slot) then
		show = false
	elseif slot.itemId and slot.itemId > 0 then
		show = not actionbarState.playerHasActionBarItem(slot)
	end

	grayPanel:setVisible(show)
end

function updateSlotsVocation()
	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				updateSlotGray(slot)
				refreshActionSlotInventoryQuantity(slot)
				actionbarState.refreshActionSlotEquipmentDecorations(slot)
				refreshActionSlotFrameClip(slot)
			end
		end
	end

	local mab = modules.game_actionbar

	if mab and mab.refreshOpenMultiActionPanelInventory then
		mab.refreshOpenMultiActionPanelInventory()
	end
end

function updateInventoryDependentActionSlots()
	local smartModeChanged = false

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				local hasMultiActions = slotHasMultiActions and slotHasMultiActions(slot)

				if (slot.smartMode or hasMultiActions) and actionbarState.refreshSmartModeSlot(slot) then
					smartModeChanged = true
				end

				if slot.itemId and slot.itemId > 0 and not slot.words and not slot.text and not slot.passiveId and not isHelperActionSlot(slot) and not isMultiHelperSlot(slot) and not actionbarState.isActionSlotEquipmentPreset(slot) then
					updateSlotGray(slot)
					refreshActionSlotInventoryQuantity(slot)
				end
			end
		end
	end

	if smartModeChanged then
		saveActionBar()
	end

	local mab = modules.game_actionbar

	if mab and mab.refreshOpenMultiActionPanelInventory then
		mab.refreshOpenMultiActionPanelInventory()
	end
end

function updateStatsDependentSlotGray()
	local pendingSlots = slotGrayStatsPendingSlots

	slotGrayStatsPendingSlots = {}

	for slot in pairs(pendingSlots) do
		if slot and not slot:isDestroyed() and slot.words and slot.words ~= "" then
			updateSlotGray(slot)
		end
	end
end

function loadSpell(slot)
	local spell, profile, spellName = Spells.getSpellByWords(slot.words)

	if not spell then
		return
	end

	iconId = tonumber(Spells.getClientId(spellName))

	local icon = slot:getChildById("spellIcon")

	if icon then
		icon:setImageSource(Spells.getIconFileByProfile(profile))
		icon:setImageClip(Spells.getImageClip(iconId, profile))
		icon:show()
	end

	slot:getChildById("text"):setText("")
	slot:setBorderWidth(0)
	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	updateSlotGray(slot)
	applyActionSlotFrame(slot)
	maybeSetupHotkeysAfterSlotLoad()
	refreshActionSlotInventoryQuantity(slot)
	refreshActionSlotTooltip(slot)
	refreshActionSlotVirtueBorder(slot)
end

function loadObject(slot)
	local icon = slot:getChildById("spellIcon")

	if icon then
		icon:hide()
		icon:setImageSource("")
	end

	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	slot:setItemId(slot.itemId)
	slot:getChildById("text"):setText("")
	slot:setBorderWidth(0)
	ItemsDatabase.setTier(slot, slot.getTier)
	updateSlotGray(slot)
	refreshActionSlotInventoryQuantity(slot)
	applyActionSlotFrame(slot)
	maybeSetupHotkeysAfterSlotLoad()
	refreshActionSlotTooltip(slot)
end

function loadPassive(slot)
	local passiveData = PassiveAbilities[slot.passiveId]

	if passiveData then
		local icon = slot:getChildById("spellIcon")

		if icon then
			icon:setImageSource(passiveData.icon)
			icon:setImageClip("0 0 32 32")
			icon:show()
		end

		slot:getChildById("text"):setText("")
		slot:setBorderWidth(0)
		actionbarState.refreshActionSlotEquipmentDecorations(slot)
		updateSlotGray(slot)
		applyActionSlotFrame(slot)

		if refreshPassiveCooldownSlot then
			refreshPassiveCooldownSlot(slot)
		end

		maybeSetupHotkeysAfterSlotLoad()
		refreshActionSlotTooltip(slot)
	end
end

function loadHelper(slot)
	local item = HelperAction.getItem(slot and slot.helperId)

	if not item then
		return
	end

	slot.multiHelper = nil

	HelperAction.clearIcons(slot)

	local icon = slot:getChildById("spellIcon")

	if icon then
		icon:setImageSource(HelperAction.ICON_FILE)
		icon:setImageClip(HelperAction.iconClip(item.iconIndex))
		icon:show()
	end

	local text = slot:getChildById("text")

	if text then
		text:setText("")
	end

	slot:setBorderWidth(0)
	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	updateSlotGray(slot)
	applyActionSlotFrame(slot)
	refreshHelperSlotBorder(slot)
	maybeSetupHotkeysAfterSlotLoad()
	refreshActionSlotInventoryQuantity(slot)
	refreshActionSlotTooltip(slot)
end

function loadMultiHelper(parentWidget)
	parentWidget.multiHelper = HelperAction.normalizeList(parentWidget and parentWidget.multiHelper)

	if not isMultiHelperSlot(parentWidget) then
		return
	end

	parentWidget.helperId = nil

	HelperAction.clearIcons(parentWidget)

	if parentWidget.clearItem then
		parentWidget:clearItem()
	end

	local spellIcon = parentWidget:getChildById("spellIcon")

	if spellIcon then
		spellIcon:hide()
		spellIcon:setImageSource("")
	end

	local var_408_1 = HelperAction.filledEntries(parentWidget.multiHelper)
	local var_408_2 = HelperAction.CLIP_SHADER[#var_408_1]

	for iter_408_0 = 1, #var_408_1 do
		local uIWidgetWidget = g_ui.createWidget("UIWidget", parentWidget)

		uIWidgetWidget:setId("multiHelperIcon" .. iter_408_0 - 1)
		uIWidgetWidget:setSize({
			width = 32,
			height = 32
		})
		uIWidgetWidget:setImageSize({
			width = 32,
			height = 32
		})
		uIWidgetWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		uIWidgetWidget:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		uIWidgetWidget:setPhantom(true)
		uIWidgetWidget:setFocusable(false)
		HelperAction.applyIconWidget(uIWidgetWidget, var_408_1[iter_408_0].id, #var_408_1 >= 2 and var_408_2 and var_408_2[iter_408_0] or "")
	end

	HelperAction.raiseOverlays(parentWidget)

	local text = parentWidget:getChildById("text")

	if text then
		text:setText("")
	end

	parentWidget:setBorderWidth(0)
	actionbarState.refreshActionSlotEquipmentDecorations(parentWidget)
	updateSlotGray(parentWidget)
	applyActionSlotFrame(parentWidget)
	refreshMultiHelperSlotBorder(parentWidget)
	maybeSetupHotkeysAfterSlotLoad()
	refreshActionSlotInventoryQuantity(parentWidget)
	refreshActionSlotTooltip(parentWidget)
end

function loadText(slot)
	local spellIcon = slot:getChildById("spellIcon")

	if spellIcon then
		spellIcon:hide()
		spellIcon:setImageSource("")
	end

	actionbarState.refreshActionSlotEquipmentDecorations(slot)
	slot:getChildById("text"):setText(slot.text)

	while slot:getChildById("text"):getTextSize().height > 30 do
		local subString = slot:getChildById("text"):getText()
		local subString = string.sub(subString, 1, #subString - 1)

		slot:getChildById("text"):setText(subString)
	end

	applyActionSlotFrame(slot)
	maybeSetupHotkeysAfterSlotLoad()
	refreshActionSlotTooltip(slot)
end

function loadActionBar()
	unbindHotkeys()

	actionBarCorruptHotkeySeen = false

	local var_410_0, var_410_1, var_410_2 = actionbarState.loadActionBarSettingsForCurrentPreset()

	beginActionBarBatch()
	actionbarState.applyPresetSlotsToActionBar(var_410_0)
	endActionBarBatch()

	actionBarPreparedPreset = var_410_2

	if var_410_1 or actionBarCorruptHotkeySeen then
		saveActionBar()

		actionBarCorruptHotkeySeen = false
	end

	setupHotkeys()
	applyClientOptionsToActionBar()
	refreshAllVirtueYellowBorders()

	if actionbarState.refreshAllSmartModeSlots then
		actionbarState.refreshAllSmartModeSlots()
	end
end

function setBarVisible(barId, visible)
	local bar = actionBars[barId]

	if not bar then
		if not visible then
			return
		end

		local ok, result = pcall(actionbarState.ensureBarLoaded, barId)

		if not ok or not result then
			return
		end

		bar = result
	end

	if not bar or bar:isDestroyed() then
		actionBars[barId] = nil
		actionBarPanels[barId] = nil

		return
	end

	if visible then
		if actionbarState.isSideBar(barId) then
			bar:setWidth(SIDE_BAR_WIDTH)
			actionbarState.updateSideContainerWidths()
			bar:show()
			layoutSideLockButton(actionbarState.isLeftBar(barId) and "left" or "right")
		else
			bar:setHeight(37)
			bar:show()
		end

		updateScrollButtonsForBar(bar)
	else
		if actionbarState.isSideBar(barId) then
			bar:setWidth(0)
		else
			bar:setHeight(0)
		end

		bar:hide()

		if actionbarState.isSideBar(barId) then
			actionbarState.updateSideContainerWidths()
			layoutSideLockButton(actionbarState.isLeftBar(barId) and "left" or "right")
		end
	end

	if actionbarState.isBottomBar(barId) then
		actionbarState.applyBottomAnchors()
		refreshBottomCooldownDock()

		if modules.game_interface and modules.game_interface.refreshStatsBarDockLayout then
			modules.game_interface.refreshStatsBarDockLayout()
		end
	end
end

function setActionBarVisible(visible)
	setBarVisible(BAR_BOTTOM_1, visible)
end

function setBottomBarGroupVisible(allEnabled, bar1, bar2, bar3)
	if not allEnabled then
		setBarVisible(BAR_BOTTOM_1, false)
		setBarVisible(BAR_BOTTOM_2, false)
		setBarVisible(BAR_BOTTOM_3, false)

		return
	end

	setBarVisible(BAR_BOTTOM_1, bar1 == true)
	setBarVisible(BAR_BOTTOM_2, bar2 == true)
	setBarVisible(BAR_BOTTOM_3, bar3 == true)
end

function setLeftBarGroupVisible(allEnabled, bar1, bar2, bar3)
	if not allEnabled then
		setBarVisible(BAR_LEFT_1, false)
		setBarVisible(BAR_LEFT_2, false)
		setBarVisible(BAR_LEFT_3, false)

		return
	end

	setBarVisible(BAR_LEFT_1, bar1 == true)
	setBarVisible(BAR_LEFT_2, bar2 == true)
	setBarVisible(BAR_LEFT_3, bar3 == true)
	normalizeSideBarChildOrder("left")
end

function setRightBarGroupVisible(allEnabled, bar1, bar2, bar3)
	if not allEnabled then
		setBarVisible(BAR_RIGHT_1, false)
		setBarVisible(BAR_RIGHT_2, false)
		setBarVisible(BAR_RIGHT_3, false)

		return
	end

	setBarVisible(BAR_RIGHT_1, bar1 == true)
	setBarVisible(BAR_RIGHT_2, bar2 == true)
	setBarVisible(BAR_RIGHT_3, bar3 == true)
	normalizeSideBarChildOrder("right")
end

function configureActionBar(id, enabled)
	if not id or type(id) ~= "string" then
		return
	end

	if not modules.client_options then
		return
	end

	if id:find("actionBarShowBottom", 1, true) then
		local b1 = modules.client_options.getOption("actionBarShowBottom1")
		local b2 = modules.client_options.getOption("actionBarShowBottom2")
		local b3 = modules.client_options.getOption("actionBarShowBottom3")

		if id == "actionBarShowBottom1" then
			b1 = enabled
		end

		if id == "actionBarShowBottom2" then
			b2 = enabled
		end

		if id == "actionBarShowBottom3" then
			b3 = enabled
		end

		local allOn = modules.client_options.getOption("allActionBar13")

		setBottomBarGroupVisible(allOn, b1, b2, b3)
	elseif id:find("actionBarShowLeft", 1, true) then
		local c1 = modules.client_options.getOption("actionBarShowLeft1")
		local c2 = modules.client_options.getOption("actionBarShowLeft2")
		local c3 = modules.client_options.getOption("actionBarShowLeft3")

		if id == "actionBarShowLeft1" then
			c1 = enabled
		end

		if id == "actionBarShowLeft2" then
			c2 = enabled
		end

		if id == "actionBarShowLeft3" then
			c3 = enabled
		end

		local allOn = modules.client_options.getOption("allActionBar46")

		setLeftBarGroupVisible(allOn, c1, c2, c3)
	elseif id:find("actionBarShowRight", 1, true) then
		local c1 = modules.client_options.getOption("actionBarShowRight1")
		local c2 = modules.client_options.getOption("actionBarShowRight2")
		local c3 = modules.client_options.getOption("actionBarShowRight3")

		if id == "actionBarShowRight1" then
			c1 = enabled
		end

		if id == "actionBarShowRight2" then
			c2 = enabled
		end

		if id == "actionBarShowRight3" then
			c3 = enabled
		end

		local allOn = modules.client_options.getOption("allActionBar79")

		setRightBarGroupVisible(allOn, c1, c2, c3)
	end
end

  actionbarState.shouldShowGraphicalCooldown = function()
	if not modules or not modules.client_options then
		return true
	end

	return modules.client_options.getOption("graphicalCooldown") ~= false
end

  actionbarState.shouldShowCooldownSeconds = function()
	if not modules or not modules.client_options then
		return true
	end

	return modules.client_options.getOption("cooldownSecond") ~= false
end

function clearCooldownVisuals()
	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				slot._equipmentSetCooldownUntil = nil

				for __, ch in pairs(slot:getChildren()) do
					local cid = ch:getId()

					if cid and tostring(cid):sub(1, 8) == "progress" then
						ch:destroy()
					end
				end
			end
		end
	end

	cooldown = {}
	groupCooldown = {}
	actionbarState.equipmentSetSharedCooldownUntil = nil
end

function toggleCooldownOption()
	if not actionbarState.shouldShowGraphicalCooldown() then
		clearCooldownVisuals()
	elseif refreshAllPassiveCooldownSlots then
		refreshAllPassiveCooldownSlots()
	end
end

function updateVisibleOptions(opt, value)
	reapplyAllSlotDisplayOpts()
end

function reapplyAllSlotDisplayOpts()
	if not modules or not modules.client_options then
		return
	end

	local showKey = modules.client_options.getOption("showAssignedHKButton") ~= false
	local showCount = modules.client_options.getOption("showHKObjectsBars") ~= false
	local showTT = modules.client_options.getOption("actionTooltip") ~= false

	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				local k = slot:getChildById("key")

				if k then
					k:setVisible(showKey)
				end

				pcall(function()
					slot:setShowCount(showCount)
				end)

				slot._actionBarShowCount = showCount

				pcall(function()
					slot:setShowItemCount(false)
				end)
				refreshActionSlotInventoryQuantity(slot)

				if not showTT then
					if slot.setTooltip then
						slot:setTooltip("")
					end
				else
					refreshActionSlotTooltip(slot)
				end
			end
		end
	end

	local mab = modules.game_actionbar

	if mab and mab.reapplyMultiSubSlotDisplayOpts then
		mab.reapplyMultiSubSlotDisplayOpts()
	end

	actionbarState.refreshAllSlotsHotkeyMirror()
end

function applyClientOptionsToActionBar()
	if not actionBar or not modules or not modules.client_options then
		return
	end

	local allBottom = modules.client_options.getOption("allActionBar13")

	if allBottom == nil then
		allBottom = true
	end

	local b1 = modules.client_options.getOption("actionBarShowBottom1")
	local b2 = modules.client_options.getOption("actionBarShowBottom2")
	local b3 = modules.client_options.getOption("actionBarShowBottom3")

	if b1 == nil then
		b1 = true
	end

	setBottomBarGroupVisible(allBottom, b1, b2, b3)

	local allLeft = modules.client_options.getOption("allActionBar46")

	if allLeft == nil then
		allLeft = false
	end

	setLeftBarGroupVisible(allLeft, modules.client_options.getOption("actionBarShowLeft1"), modules.client_options.getOption("actionBarShowLeft2"), modules.client_options.getOption("actionBarShowLeft3"))

	local allRight = modules.client_options.getOption("allActionBar79")

	if allRight == nil then
		allRight = false
	end

	setRightBarGroupVisible(allRight, modules.client_options.getOption("actionBarShowRight1"), modules.client_options.getOption("actionBarShowRight2"), modules.client_options.getOption("actionBarShowRight3"))
	normalizeSideBarChildOrder("left")
	normalizeSideBarChildOrder("right")
	reapplyAllSlotDisplayOpts()

	if not actionbarState.shouldShowGraphicalCooldown() then
		clearCooldownVisuals()
	end
end

function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function formatActionBarCooldownTime(arg_427_0)
	local var_427_0 = math.max(0, arg_427_0 / 1000)
	local var_427_1 = math.floor(var_427_0)

	if var_427_1 >= 36000 then
		return math.floor(var_427_1 / 3600) .. "h"
	elseif var_427_1 >= 3600 then
		local var_427_2 = math.floor(var_427_1 / 3600)
		local var_427_3 = math.floor(var_427_1 % 3600 / 60)

		return string.format("%dh%02d", var_427_2, var_427_3)
	elseif var_427_1 >= 600 then
		return math.floor(var_427_1 / 60) .. "m"
	elseif var_427_1 >= 60 then
		local var_427_4 = math.floor(var_427_1 / 60)

		return string.format("%dm%02d", var_427_4, var_427_1 % 60)
	end

	return string.format("%.1f", var_427_0)
end

function resolveActionBarCooldownTiming(arg_428_0, arg_428_1, arg_428_2, arg_428_3, remainingMs)
	if arg_428_3 and arg_428_3 > 0 then
		local remainingMs = math.max(0, remainingMs or 0)

		return math.max(arg_428_3, remainingMs), remainingMs
	end

	arg_428_2 = arg_428_2 or 0

	if not arg_428_0.cooldownEndTime or arg_428_2 == 0 then
		local var_428_1 = math.max(0, arg_428_1 - arg_428_2 * 100)

		arg_428_0.cooldownDuration = math.max(arg_428_1, var_428_1)
		arg_428_0.cooldownEndTime = g_clock.millis() + var_428_1
	end

	local var_428_2 = math.max(0, arg_428_0.cooldownEndTime - g_clock.millis())

	return math.max(arg_428_0.cooldownDuration or arg_428_1, var_428_2), var_428_2
end

multiActionCooldownSyncLock = false

  actionbarState[198] = function(widget)
	if multiActionCooldownSyncLock or not widget or widget:isDestroyed() or not syncMultiActionSlot then
		return
	end

	local target = widget

	if not slotHasMultiActions or not slotHasMultiActions(target) then
		target = widget.parentSlot
	end

	if not target or target:isDestroyed() or not slotHasMultiActions(target) then
		return
	end

	if updateMultiSlotState then
		updateMultiSlotState(target, true)
	end

	if refreshMultiActionPanel and target._multiPanelOpen then
		refreshMultiActionPanel(target)
	end

	if refreshMultiActionPanelCooldowns then
		refreshMultiActionPanelCooldowns(target, false)
	end
end

function resolveCooldownProgressState(totalDuration, remainingMs)
	local total = totalDuration

	if not total or total <= 0 then
		total = remainingMs > 0 and remainingMs or 1
	end

	remainingMs = math.max(0, remainingMs or 0)

	local total = math.max(total, remainingMs)
	local elapsed = total - remainingMs
	local count = math.max(0, math.floor(elapsed / 100 + 0.5))
	local maxCount = math.max(1, math.floor(total / 100 + 0.5))

	if maxCount <= count then
		count = math.max(0, maxCount - 1)
	end

	local percent = math.min(99, count * 10000 / total)

	return total, remainingMs, count, percent
end

function updateCooldown(progressRect, duration, spellId, count)
	if not progressRect or progressRect:isDestroyed() or not spellId or not duration or duration <= 0 then
		return
	end

	count = count or 0

	local percent
	local var_431_1

	if getMultiActionSpellCooldownTiming then
		percent, var_431_1 = getMultiActionSpellCooldownTiming(spellId)
	end

	local var_431_2, var_431_3 = resolveActionBarCooldownTiming(progressRect, duration, count, percent, var_431_1)
	local percent = var_431_3 <= 0 and 100 or math.min(99.99, math.max(0, (var_431_2 - var_431_3) * 100 / var_431_2))

	progressRect:setPercent(percent)

	if actionbarState.shouldShowCooldownSeconds() and var_431_3 > 0 then
		progressRect:setText(formatActionBarCooldownTime(var_431_3))
		progressRect:setTextOffset("-1 0")
	else
		progressRect:setText("")
	end

	if percent < 100 then
		removeEvent(progressRect.event)

		cooldown[spellId] = var_431_3
		progressRect.event = scheduleEvent(function()
			updateCooldown(progressRect, duration, spellId, count + 1)
		end, 100)
	else
		cooldown[spellId] = nil

		local slotItem = progressRect.item

		if progressRect and not progressRect:isDestroyed() then
			removeEvent(progressRect.event)

			progressRect.event = nil
			progressRect.cooldownEndTime = nil
			progressRect.cooldownDuration = nil

			progressRect:setPercent(0)
			progressRect:setText("")
			progressRect:hide()
		end

		if slotItem and not multiActionCooldownSyncLock then
			scheduleEvent(function()
				if not slotItem or slotItem:isDestroyed() then
					return
				end

				if slotHasMultiActions and slotHasMultiActions(slotItem) and updateMultiSlotState then
					multiActionCooldownSyncLock = true

					updateMultiSlotState(slotItem, true)

					multiActionCooldownSyncLock = false
				elseif syncMultiActionSlot then
					syncMultiActionSlot(slotItem)
				end
			end, 0)
		end
	end
end

  actionbarState.layoutActionBarCooldownProgress = function(progressRect)
	progressRect:breakAnchors()
	progressRect:setSize(tosize("32 32"))
	progressRect:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
	progressRect:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
end

function raiseMultiActionMarkerAboveCooldown(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local icon = slot:getChildById("multiIcon")

	if icon and not icon:isDestroyed() and icon:isVisible() and icon.raise then
		icon:raise()
	end
end

  actionbarState.raiseEquipmentSlotDecorIconsAboveCooldown = function(slot)
	if not slot or slot:isDestroyed() then
		return
	end

	local icon = slot:getChildById("equipmentTypeIcon")

	if icon and not icon:isDestroyed() and icon:isVisible() and icon.raise then
		icon:raise()
	end
end

  actionbarState.raiseActionBarCooldownProgress = function(arg_437_0, arg_437_1)
	if arg_437_1 and arg_437_1.raise then
		arg_437_1:raise()
	end

	raiseMultiActionMarkerAboveCooldown(arg_437_0)
	actionbarState.raiseEquipmentSlotDecorIconsAboveCooldown(arg_437_0)
end

function passiveCooldownRemainingMs()
	if not passiveCooldownData then
		return 0
	end

	local remainingMs = passiveCooldownData.remainingMs

	if passiveCooldownData.canDecay then
		remainingMs = remainingMs - (g_clock.millis() - passiveCooldownData.updatedAt)
	end

	return math.max(0, remainingMs)
end

function formatPassiveCooldownTime(arg_439_0)
	local var_439_0 = math.max(0, math.ceil(arg_439_0 / 1000))

	if var_439_0 >= 3600 then
		return math.ceil(var_439_0 / 3600) .. "h"
	elseif var_439_0 >= 60 then
		return math.ceil(var_439_0 / 60) .. "m"
	end

	return var_439_0 .. "s"
end

function clearPassiveCooldownProgress(arg_440_0)
	local var_440_0 = arg_440_0 and arg_440_0:recursiveGetChildById(PASSIVE_COOLDOWN_PROGRESS_ID)

	if var_440_0 and not var_440_0:isDestroyed() then
		removeEvent(var_440_0.event)

		var_440_0.event = nil

		var_440_0:setPercent(0)
		var_440_0:setText("")
		var_440_0:hide()
	end

	cooldown[PASSIVE_COOLDOWN_KEY] = nil
end

function updatePassiveCooldownProgress(arg_441_0)
	if not arg_441_0 or arg_441_0:isDestroyed() or not passiveCooldownData then
		return
	end

	local var_441_0 = passiveCooldownRemainingMs()

	if var_441_0 <= 0 then
		clearPassiveCooldownProgress(arg_441_0.item)

		return
	end

	local var_441_1 = math.max(passiveCooldownData.totalMs, var_441_0)

	arg_441_0:setPercent(math.min(99, (var_441_1 - var_441_0) * 100 / var_441_1))

	if actionbarState.shouldShowCooldownSeconds() then
		arg_441_0:setText(formatPassiveCooldownTime(var_441_0))
		arg_441_0:setTextOffset("-1 0")
	else
		arg_441_0:setText("")
	end

	cooldown[PASSIVE_COOLDOWN_KEY] = var_441_0

	removeEvent(arg_441_0.event)

	arg_441_0.event = nil

	if passiveCooldownData.canDecay then
		arg_441_0.event = scheduleEvent(function()
			updatePassiveCooldownProgress(arg_441_0)
		end, 1000)
	end
end

function refreshPassiveCooldownSlot(item)
	if not item or item:isDestroyed() or item.passiveId ~= GIFT_OF_LIFE_PASSIVE_ID then
		return
	end

	if not actionbarState.shouldShowGraphicalCooldown() or passiveCooldownRemainingMs() <= 0 then
		clearPassiveCooldownProgress(item)

		return
	end

	local actionBarCooldownProgressWidget = item:recursiveGetChildById(PASSIVE_COOLDOWN_PROGRESS_ID)

	if not actionBarCooldownProgressWidget then
		actionBarCooldownProgressWidget = g_ui.createWidget("ActionBarCooldownProgress", item)

		actionBarCooldownProgressWidget:setId(PASSIVE_COOLDOWN_PROGRESS_ID)
	else
		removeEvent(actionBarCooldownProgressWidget.event)

		actionBarCooldownProgressWidget.event = nil
	end

	actionBarCooldownProgressWidget.item = item

	actionbarState.layoutActionBarCooldownProgress(actionBarCooldownProgressWidget)
	actionbarState.raiseActionBarCooldownProgress(item, actionBarCooldownProgressWidget)
	actionBarCooldownProgressWidget:show()
	updatePassiveCooldownProgress(actionBarCooldownProgressWidget)
end

function refreshAllPassiveCooldownSlots()
	for iter_444_0 = 1, NUM_BARS do
		local var_444_0 = actionBarPanels[iter_444_0]

		if var_444_0 then
			for unusedValue, child in pairs(var_444_0:getChildren()) do
				if child.passiveId == GIFT_OF_LIFE_PASSIVE_ID then
					refreshPassiveCooldownSlot(child)
				end
			end
		end
	end
end

function onPassiveData(arg_445_0, arg_445_1, arg_445_2)
	local var_445_0 = math.max(0, tonumber(arg_445_0) or 0) * 1000
	local var_445_1 = math.max(var_445_0, math.max(0, tonumber(arg_445_1) or 0) * 1000)

	passiveCooldownData = {
		remainingMs = var_445_0,
		totalMs = var_445_1,
		canDecay = arg_445_2 == true,
		updatedAt = g_clock.millis()
	}

	refreshAllPassiveCooldownSlots()
end

function clearSlotProgressWidgets(arg_446_0, arg_446_1)
	for unusedValue, child in pairs(arg_446_0:getChildren()) do
		local id = child:getId()

		if id and id ~= arg_446_1 and tostring(id):sub(1, 8) == "progress" then
			if child.event then
				removeEvent(child.event)

				child.event = nil
			end

			child.cooldownEndTime = nil
			child.cooldownDuration = nil

			child:setPercent(0)
			child:setText("")
			child:hide()
		end
	end
end

  actionbarState.progressId = function(arg_447_0, arg_447_1)
	local var_447_0 = arg_447_1 and arg_447_0:recursiveGetChildById(arg_447_1)

	return var_447_0 ~= nil and var_447_0:isExplicitlyVisible()
end

function refreshMultiActionSlotCooldownDisplay(slot, onlyIfMissing)
	if not slot or slot:isDestroyed() then
		return
	end

	if not actionbarState.shouldShowGraphicalCooldown() then
		return
	end

	if not getMultiActionCooldownRemaining then
		return
	end

	local remaining = 0
	local var_448_1
	local useGroupCooldown = false
	local groupId
	local spellId
	local spell

	if slot.words and slot.words ~= "" then
		spell = Spells.getSpellByWords(slot.words)

		if not spell then
			clearSlotProgressWidgets(slot)

			return
		end

		local spellRem, groupRem = getMultiActionCooldownRemaining(spell)

		remaining = math.max(spellRem, groupRem)
		useGroupCooldown = spellRem < groupRem

		if useGroupCooldown then
			groupId = getMultiActionActiveGroupId and getMultiActionActiveGroupId(spell)

			if not groupId then
				useGroupCooldown = false
			else
				var_448_1 = "progress" .. groupId
			end
		end

		if not useGroupCooldown then
			spellId = spell.id
			var_448_1 = "progress" .. spellId
		end
	elseif slot.itemId and slot.itemId > 0 and slot.useType and slot.useType ~= "equip" then
		local runeSpell = getRuneUsageSpell and getRuneUsageSpell(slot.itemId) or Spells.getRuneSpellByItem(slot.itemId)

		if runeSpell then
			local spellRem, groupRem = getMultiActionCooldownRemaining(runeSpell)

			remaining = math.max(spellRem, groupRem)
			useGroupCooldown = spellRem < groupRem

			if useGroupCooldown then
				groupId = getMultiActionActiveGroupId and getMultiActionActiveGroupId(runeSpell)

				if groupId then
					var_448_1 = "progress" .. groupId
				else
					useGroupCooldown = false
				end
			end

			if not useGroupCooldown then
				spellId = runeSpell.id
				var_448_1 = "progress" .. spellId
			end
		else
			if shouldPaintItemMultiCdOnMainSlot and not shouldPaintItemMultiCdOnMainSlot(slot) then
				clearSlotProgressWidgets(slot)

				return
			end

			remaining = getItemMultiUseCooldownRemaining and getItemMultiUseCooldownRemaining() or 0

			if remaining > 0 and remaining < 100 and clearItemMultiUseCooldownCache then
				clearItemMultiUseCooldownCache()

				remaining = 0
			end

			if remaining > 0 then
				groupId = actionbarState.ACTIONBAR_ITEM_MULTI_CD_KEY
				var_448_1 = "progress" .. groupId
				useGroupCooldown = true
			end
		end
	else
		clearSlotProgressWidgets(slot)

		return
	end

	if remaining <= 0 then
		clearSlotProgressWidgets(slot)

		return
	end

	if onlyIfMissing and actionbarState.progressId(slot, var_448_1) then
		return
	end

	clearSlotProgressWidgets(slot, var_448_1)

	if useGroupCooldown then
		groupCooldown[groupId] = true
	elseif spellId then
		cooldown[spellId] = remaining
	end

	local totalDuration = remaining
	local remainingMs = remaining

	if spell then
		if useGroupCooldown and getMultiActionGroupCooldownTiming then
			totalDuration, remainingMs = getMultiActionGroupCooldownTiming(spell)
		elseif getMultiActionSpellCooldownTiming then
			totalDuration, remainingMs = getMultiActionSpellCooldownTiming(spell.id)
		end
	elseif slot.itemId and slot.itemId > 0 then
		local runeSpell = getRuneUsageSpell and getRuneUsageSpell(slot.itemId) or Spells.getRuneSpellByItem(slot.itemId)

		if runeSpell then
			if useGroupCooldown and getMultiActionGroupCooldownTiming then
				totalDuration, remainingMs = getMultiActionGroupCooldownTiming(runeSpell)
			elseif getMultiActionSpellCooldownTiming then
				totalDuration, remainingMs = getMultiActionSpellCooldownTiming(runeSpell.id)
			end
		elseif getMultiActionItemCooldownTiming then
			totalDuration, remainingMs = getMultiActionItemCooldownTiming()
		end
	end

	if not totalDuration or totalDuration <= 0 then
		totalDuration = remaining
		remainingMs = remaining
	end

	local total, rem, tickCount, initialPercent = resolveCooldownProgressState(totalDuration, remainingMs)
	local progressRect = slot:recursiveGetChildById(var_448_1)

	if progressRect and not progressRect:isDestroyed() then
		removeEvent(progressRect.event)

		progressRect.event = nil
		progressRect.cooldownEndTime = nil
		progressRect.cooldownDuration = nil
	else
		progressRect = g_ui.createWidget("ActionBarCooldownProgress", slot)

		progressRect:setId(var_448_1)
	end

	progressRect.item = slot

	actionbarState.layoutActionBarCooldownProgress(progressRect)
	actionbarState.raiseActionBarCooldownProgress(slot, progressRect)
	progressRect:setPercent(initialPercent)
	progressRect:show()

	multiActionCooldownSyncLock = true

	if useGroupCooldown then
		updateGroupCooldown(progressRect, total, groupId, tickCount)
	elseif spellId then
		updateCooldown(progressRect, total, spellId, tickCount)
	end

	multiActionCooldownSyncLock = false
end

function refreshMultiActionSlotCooldownDisplayIfNeeded(slot)
	refreshMultiActionSlotCooldownDisplay(slot, true)
end

function updateGroupCooldown(progressRect, duration, groupId, count)
	if not progressRect or progressRect:isDestroyed() or not groupId or not duration or duration <= 0 then
		return
	end

	count = count or 0

	local percent
	local var_450_1

	if groupId == actionbarState.ACTIONBAR_ITEM_MULTI_CD_KEY and getMultiActionItemCooldownTiming then
		percent, var_450_1 = getMultiActionItemCooldownTiming()
	elseif getMultiActionGroupCooldownTimingById then
		percent, var_450_1 = getMultiActionGroupCooldownTimingById(groupId)
	end

	local var_450_2, remainingMs = resolveActionBarCooldownTiming(progressRect, duration, count, percent, var_450_1)
	local percent = remainingMs <= 0 and 100 or math.min(99.99, math.max(0, (var_450_2 - remainingMs) * 100 / var_450_2))

	progressRect:setPercent(percent)

	if actionbarState.shouldShowCooldownSeconds() and remainingMs > 0 then
		progressRect:setText(formatActionBarCooldownTime(remainingMs))
	else
		progressRect:setText("")
	end

	if percent < 100 then
		removeEvent(progressRect.event)

		progressRect.event = scheduleEvent(function()
			updateGroupCooldown(progressRect, duration, groupId, count + 1)
		end, 100)
	else
		groupCooldown[groupId] = nil

		local slotItem = progressRect.item

		if progressRect and not progressRect:isDestroyed() then
			removeEvent(progressRect.event)

			progressRect.event = nil
			progressRect.cooldownEndTime = nil
			progressRect.cooldownDuration = nil

			progressRect:setPercent(0)
			progressRect:setText("")
			progressRect:hide()
		end

		if groupId == actionbarState.ACTIONBAR_ITEM_MULTI_CD_KEY and onMultiActionItemMultiUseCooldown then
			onMultiActionItemMultiUseCooldown(0)

			return
		end

		if slotItem and not multiActionCooldownSyncLock then
			scheduleEvent(function()
				if not slotItem or slotItem:isDestroyed() then
					return
				end

				if slotHasMultiActions and slotHasMultiActions(slotItem) and updateMultiSlotState then
					multiActionCooldownSyncLock = true

					updateMultiSlotState(slotItem, true)

					multiActionCooldownSyncLock = false
				elseif syncMultiActionSlot then
					syncMultiActionSlot(slotItem)
				end
			end, 0)
		end
	end
end

 actionbarState.startEquipmentSetActionCooldownVisual = function(slot)
	if not slot or slot:isDestroyed() or not actionbarState.isActionSlotEquipmentPreset(slot) then
		return
	end

	if not actionbarState.shouldShowGraphicalCooldown() then
		return
	end

	local groupId = actionbarState.equipmentSetCooldownGroupId()
	local duration = actionbarState.EQUIPMENT_SET_COOLDOWN_MS
	local progressRect = slot:recursiveGetChildById(actionbarState.EQUIPMENT_SET_CD_PROGRESS_ID)

	if not progressRect then
		progressRect = g_ui.createWidget("ActionBarCooldownProgress", slot)

		progressRect:setId(actionbarState.EQUIPMENT_SET_CD_PROGRESS_ID)

		progressRect.item = slot

		actionbarState.layoutActionBarCooldownProgress(progressRect)
		actionbarState.raiseActionBarCooldownProgress(slot, progressRect)
	else
		removeEvent(progressRect.event)
		actionbarState.layoutActionBarCooldownProgress(progressRect)
		progressRect:setPercent(0)
		progressRect:show()
		actionbarState.raiseActionBarCooldownProgress(slot, progressRect)
	end

	groupCooldown[groupId] = true

	local total, rem, tickCount, initialPercent = resolveCooldownProgressState(duration, duration)

	progressRect:setPercent(initialPercent)
	updateGroupCooldown(progressRect, total, groupId, tickCount)
end

function onMultiUseCooldown(duration)
	if onMultiActionItemMultiUseCooldown then
		onMultiActionItemMultiUseCooldown(duration)
	end

	if not actionbarState.shouldShowGraphicalCooldown() then
		return
	end

	local key = actionbarState.ACTIONBAR_ITEM_MULTI_CD_KEY
	local progressWidgetId = "progress" .. key

	if not duration or duration <= 0 then
		groupCooldown[key] = nil

		for barId = 1, NUM_BARS do
			local panel = actionBarPanels[barId]

			if panel then
				for _, slot in pairs(panel:getChildren()) do
					local pr = slot:recursiveGetChildById(progressWidgetId)

					if pr then
						removeEvent(pr.event)

						pr.event = nil

						pr:setPercent(0)
						pr:setText("")
						pr:hide()
					end
				end
			end
		end

		return
	end

	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				if slotHasMultiActions and slotHasMultiActions(slot) then
					-- block empty
				elseif slot.words and slot.words ~= "" or slot.passiveId or slot.helperId or isMultiHelperSlot(slot) or not slot.itemId or not (slot.itemId > 0) or slot.useType == "equip" or getRuneUsageSpell and getRuneUsageSpell(slot.itemId) then
					-- block empty
				else
					local progressRect = slot:recursiveGetChildById(progressWidgetId)

					if not progressRect then
						progressRect = g_ui.createWidget("ActionBarCooldownProgress", slot)

						progressRect:setId(progressWidgetId)

						progressRect.item = slot

						actionbarState.layoutActionBarCooldownProgress(progressRect)
						actionbarState.raiseActionBarCooldownProgress(slot, progressRect)
					else
						actionbarState.layoutActionBarCooldownProgress(progressRect)
						progressRect:setPercent(0)
						progressRect:show()
						actionbarState.raiseActionBarCooldownProgress(slot, progressRect)
					end

					local total, rem, tickCount, initialPercent = resolveCooldownProgressState(duration, duration)

					progressRect:setPercent(initialPercent)
					updateGroupCooldown(progressRect, total, key, tickCount)

					groupCooldown[key] = true
				end
			end
		end
	end
end

function onSpellCooldown(spellId, duration)
	if onMultiActionSpellCooldown then
		onMultiActionSpellCooldown(spellId, duration)
	end

	if not actionbarState.shouldShowGraphicalCooldown() then
		return true
	end

	local spell, profile, spellName = Spells.getSpellByIcon(spellId)

	if not spell then
		print("[WARNING] Can not set cooldown on spell with id: " .. spellId)

		return true
	end

	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, k in pairs(panel:getChildren()) do
				if slotHasMultiActions and slotHasMultiActions(k) then
					-- block empty
				else
					local runeSpell = k.itemId and k.itemId > 0 and getRuneUsageSpell and getRuneUsageSpell(k.itemId)

					if k.words == spell.words or spell.clientId and spell.clientId == k.itemId or runeSpell and runeSpell.id == spell.id then
						local slot = k
						local progressRect = slot:recursiveGetChildById("progress" .. spell.id)

						if not progressRect then
							progressRect = g_ui.createWidget("ActionBarCooldownProgress", slot)

							progressRect:setId("progress" .. spell.id)

							progressRect.item = slot

							actionbarState.layoutActionBarCooldownProgress(progressRect)

							if progressRect.raise then
								progressRect:raise()
							end
						else
							actionbarState.layoutActionBarCooldownProgress(progressRect)
							progressRect:setPercent(0)
							progressRect:show()

							if progressRect.raise then
								progressRect:raise()
							end
						end

						local function updateFunc()
							updateCooldown(progressRect, duration, spell.id, 0)
						end

						progressRect:setPercent(0)
						updateFunc()

						cooldown[spell.id] = duration
					end
				end
			end
		end
	end
end

function onSpellGroupCooldown(groupId, duration)
	if onMultiActionSpellGroupCooldown then
		onMultiActionSpellGroupCooldown(groupId, duration)
	end

	if not actionbarState.shouldShowGraphicalCooldown() then
		return
	end

	for barId = 1, NUM_BARS do
		local panel = actionBarPanels[barId]

		if panel then
			for _, k in pairs(panel:getChildren()) do
				if slotHasMultiActions and slotHasMultiActions(k) then
					-- block empty
				else
					local spell
					local unusedValue
					local spellName

					if k.words and k.words ~= "" then
						local profile, spellName

						spell, profile, spellName = Spells.getSpellByWords(k.words)
					elseif k.itemId and k.itemId > 0 and getRuneUsageSpell then
						spell = getRuneUsageSpell(k.itemId)
					else
						spell = nil
					end

					if spell and spell.group[groupId] ~= nil then
						local continue = false

						if not cooldown[spell.id] or cooldown[spell.id] and duration > cooldown[spell.id] then
							local oldProgressBar = k:recursiveGetChildById("progress" .. spell.id)

							if oldProgressBar then
								cooldown[spell.id] = nil

								oldProgressBar:hide()
							end

							continue = true
						elseif cooldown[spell.id] and duration <= cooldown[spell.id] then
							continue = false
						end

						if continue then
							local slot = k
							local progressRect = slot:recursiveGetChildById("progress" .. groupId)

							if not progressRect then
								progressRect = g_ui.createWidget("ActionBarCooldownProgress", slot)

								progressRect:setId("progress" .. groupId)

								progressRect.item = slot

								actionbarState.layoutActionBarCooldownProgress(progressRect)

								if progressRect.raise then
									progressRect:raise()
								end
							else
								actionbarState.layoutActionBarCooldownProgress(progressRect)
								progressRect:setPercent(0)
								progressRect:show()

								if progressRect.raise then
									progressRect:raise()
								end
							end

							local function updateFunc()
								updateGroupCooldown(progressRect, duration, groupId)
							end

							progressRect:setPercent(0)
							updateFunc()

							groupCooldown[groupId] = true
						end
					end
				end
			end
		end
	end
end

function getSpellAssignFilterText()
	if not spellAssignWindow or spellAssignWindow:isDestroyed() then
		return ""
	end

	local edit = spellAssignWindow:recursiveGetChildById("filterTextEdit")

	return edit and edit:getText() or ""
end

function clearSpellFilter()
	if not spellAssignWindow then
		return
	end

	local edit = spellAssignWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:setText("")
		filterSpells("")
		edit:focus()
	end
end

function filterSpells(text)
	if not spellsPanel then
		return
	end

	text = text or ""

	local onlyLearnt = false

	if spellAssignWindow then
		local learntCb = spellAssignWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

		onlyLearnt = learntCb and learntCb:isChecked() or false
	end

	local textFilterActive = #text > 0
	local textLower = textFilterActive and text:lower() or ""

	for _, spellListLabel in pairs(spellsPanel:getChildren()) do
		local visible = true

		if onlyLearnt then
			local spellName = spellListLabel:getId()
			local spell = spellName and spellName ~= "" and Spells.getSpellByName(spellName) or nil

			if not actionbarState.spellPassesAssignLearntFilter(spell) then
				visible = false
			end
		end

		if visible and textFilterActive then
			local rawName = spellListLabel._filterName
			local rawWords = spellListLabel._filterWords
			local labelName = type(rawName) == "string" and rawName:lower() or ""
			local labelWords = type(rawWords) == "string" and rawWords:lower() or ""

			if not string.find(labelName, textLower, 1, true) and not string.find(labelWords, textLower, 1, true) then
				visible = false
			end
		end

		if visible then
			showSpell(spellListLabel)
		else
			hideSpell(spellListLabel)
		end
	end

	local firstVisible

	for _, child in ipairs(spellsPanel:getChildren()) do
		if child:isVisible() then
			firstVisible = child

			break
		end
	end

	if not firstVisible then
		spellAssignPreviewNoSpellSelected()

		return
	end

	if not textFilterActive then
		local filterEdit = spellAssignWindow and spellAssignWindow:recursiveGetChildById("filterTextEdit")
		local typingInFilter = filterEdit and filterEdit:isFocused()
		local focusTarget = actionbarState.pickSpellAssignListFocusWidget() or firstVisible

		spellsPanel:focusChild(focusTarget, KeyboardFocusReason)

		local sn = focusTarget:getChildById("spellName")
		local sw = focusTarget:getChildById("spellWords")
		local sl = focusTarget:getChildById("spellLevel")

		if sn and sw then
			sn:setColor("#ffffff")
			sw:setColor("#ffffff")
		end

		if sl then
			sl:setColor("#ffffff")
		end

		updatePreviewSpell(focusTarget)
		actionbarState.syncSpellAssignParameterFieldFromSlot(focusTarget)

		if typingInFilter and filterEdit then
			filterEdit:focus()
		end

		return
	end

	local focused = spellsPanel:getFocusedChild()

	if focused and focused:isVisible() then
		updatePreviewSpell(focused)
		actionbarState.syncSpellAssignParameterFieldFromSlot(focused)
	else
		spellsPanel:focusChild(firstVisible, KeyboardFocusReason)

		local sn = firstVisible:getChildById("spellName")
		local sw = firstVisible:getChildById("spellWords")
		local sl = firstVisible:getChildById("spellLevel")

		if sn and sw then
			sn:setColor("#ffffff")
			sw:setColor("#ffffff")
		end

		if sl then
			sl:setColor("#ffffff")
		end

		updatePreviewSpell(firstVisible)
		actionbarState.syncSpellAssignParameterFieldFromSlot(firstVisible)
	end
end

function hideSpell(spellListLabel)
	if spellListLabel:isVisible() then
		spellListLabel:hide()
		spellListLabel:setHeight(0)
	end
end

function showSpell(spellListLabel)
	if not spellListLabel:isVisible() then
		local h = spellListLabel.defaultHeight

		if type(h) ~= "number" then
			h = 34
		end

		spellListLabel:setHeight(h)
		spellListLabel:show()
	end
end

function onDecrementHorizontalScroll(bar, value)
	bar = bar or actionBar

	if not bar or bar:isDestroyed() then
		return
	end

	local panel = barWidgetChild(bar, "actionBarPanel")
	local horizontalScroll = barWidgetChild(bar, "horizontalScroll")

	if not panel or not horizontalScroll then
		return
	end

	if value == 999 then
		value = math.floor(panel:getWidth() / 36) * 36
	end

	local nextBtn = barWidgetChild(bar, "nextButton")
	local nextSkip = barWidgetChild(bar, "nextSkipButton")

	if nextBtn then
		nextBtn:setEnabled(true)
	end

	if nextSkip then
		nextSkip:setEnabled(true)
	end

	local prevBtn = barWidgetChild(bar, "prevButton")
	local prevSkip = barWidgetChild(bar, "prevSkipButton")

	if horizontalScroll:getValue() - value <= horizontalScroll:getMinimum() then
		if prevBtn then
			prevBtn:setEnabled(false)
		end

		if prevSkip then
			prevSkip:setEnabled(false)
		end
	else
		if prevBtn then
			prevBtn:setEnabled(true)
		end

		if prevSkip then
			prevSkip:setEnabled(true)
		end
	end

	horizontalScroll:decrement(value)
end

function onIncrementHorizontalScroll(bar, value)
	bar = bar or actionBar

	if not bar or bar:isDestroyed() then
		return
	end

	local panel = barWidgetChild(bar, "actionBarPanel")
	local horizontalScroll = barWidgetChild(bar, "horizontalScroll")

	if not panel or not horizontalScroll then
		return
	end

	if value == 999 then
		value = math.floor(panel:getWidth() / 36) * 36
	end

	local prevBtn = barWidgetChild(bar, "prevButton")
	local prevSkip = barWidgetChild(bar, "prevSkipButton")

	if prevBtn then
		prevBtn:setEnabled(true)
	end

	if prevSkip then
		prevSkip:setEnabled(true)
	end

	local nextBtn = barWidgetChild(bar, "nextButton")
	local nextSkip = barWidgetChild(bar, "nextSkipButton")

	if horizontalScroll:getValue() + value >= horizontalScroll:getMaximum() then
		if nextBtn then
			nextBtn:setEnabled(false)
		end

		if nextSkip then
			nextSkip:setEnabled(false)
		end
	else
		if nextBtn then
			nextBtn:setEnabled(true)
		end

		if nextSkip then
			nextSkip:setEnabled(true)
		end
	end

	horizontalScroll:increment(value)
end

function onDecrementVerticalScroll(bar, value)
	if not bar or bar:isDestroyed() then
		return
	end

	local scroll = barWidgetChild(bar, "verticalScroll")

	if not scroll then
		return
	end

	value = value or actionbarState[3]

	local newVal

	if value == 999 then
		newVal = scroll:getMinimum()
	else
		newVal = math.max(scroll:getMinimum(), scroll:getValue() - value)
	end

	scroll:setValue(newVal - newVal % actionbarState[3])
	updateScrollButtonsForBar(bar)
end

function onIncrementVerticalScroll(bar, value)
	if not bar or bar:isDestroyed() then
		return
	end

	local scroll = barWidgetChild(bar, "verticalScroll")

	if not scroll then
		return
	end

	value = value or actionbarState[3]

	local newVal

	if value == 999 then
		newVal = scroll:getMaximum()
	else
		newVal = math.min(scroll:getMaximum(), scroll:getValue() + value)
	end

	scroll:setValue(newVal - newVal % actionbarState[3])
	updateScrollButtonsForBar(bar)
end

function getLocked(group)
	return isActionBarGroupLocked(group or "bottom")
end

function setLocked(v, group)
	group = group or "bottom"
	actionBarLocks[group] = not not v
	isLocked = isActionBarGroupLocked("bottom")

	if group == "bottom" then
		applyBottomLockAppearance(false, bottomLockButton)
	elseif group == "left" then
		layoutSideLockButton("left")
	elseif group == "right" then
		layoutSideLockButton("right")
	else
		applyBottomLockAppearance(false, bottomLockButton)
		layoutSideLockButton("left")
		layoutSideLockButton("right")
	end
end

function getPanelActionbar()
	return actionBar
end

  actionbarState.clearSlotData = function(slot)
	clearSlotActionContent(slot)

	local sid = slot:getId()
	local idxBottom = sid and tonumber(sid:match("^slot(%d+)$"))

	if idxBottom then
		actionbarState.initDefaultHotkeysFirstBottomBarSlot(slot, idxBottom)
	else
		slot.hotkeyChatOn = ""
		slot.hotkeyChatOff = ""
		slot.hotkey = ""

		local key = slot:getChildById("key")

		if key then
			key:setText("")
		end
	end
end

function resetAction(barId)
	if not barId or not actionBarPanels[barId] then
		return
	end

	unbindHotkeys()

	for _, slot in pairs(actionBarPanels[barId]:getChildren()) do
		actionbarState.clearSlotData(slot)
	end

	setupHotkeys()
	saveActionBar()
end

function resetActionBars()
	unbindHotkeys()

	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				actionbarState.clearSlotData(slot)
			end
		end
	end

	setupHotkeys()
	saveActionBar()
end

  actionbarState.clearAllActionBarSlotsWithoutSave = function()
	for i = 1, NUM_BARS do
		local panel = actionBarPanels[i]

		if panel then
			for _, slot in pairs(panel:getChildren()) do
				actionbarState.clearSlotData(slot)
			end
		end
	end
end

function prepareActionBarForLogin()
	if g_game.isOnline() then
		return
	end

	local presetName = getActionBarDefaultPresetName()

	if not presetName or presetName == "" or actionBarPreparedPreset == presetName then
		return
	end

	local startedAt = g_clock.realMillis()
	local storedSlots = getActionBarSlotsForPreset(presetName)

	setupActionBar()
	applyClientOptionsToActionBar()
	setupActionBar()
	beginActionBarBatch()
	actionbarState.clearAllActionBarSlotsWithoutSave()
	actionbarState.applyPresetSlotsToActionBar(storedSlots)
	endActionBarBatch()

	actionBarPreparedPreset = presetName

	g_logger.info(string.format("[login] actionbar preset %s preloaded in %d ms", presetName, g_clock.realMillis() - startedAt))
end

function reloadActionBarForPreset(presetName, previousPreset)
	if not g_game.isOnline() then
		return
	end

	if not actionBarPanels or not actionBarPanels[BAR_BOTTOM_1] then
		return
	end

	if not presetName or presetName == "" then
		return
	end

	local var_476_0 = actionBarPreparedPreset

	if var_476_0 and var_476_0 ~= "" and var_476_0 ~= presetName then
		saveActionBarSlotsForPreset(var_476_0, actionbarState.collectCharacterActionBarSlots())
	end

	local var_476_1 = getActionBarSlotsForPreset(presetName)
	local storedCount = countActionBarSlotsWithContent(var_476_1)

	actionBarCorruptHotkeySeen = false

	beginActionBarBatch()
	unbindHotkeys()
	actionbarState.clearAllActionBarSlotsWithoutSave()
	actionbarState.applyPresetSlotsToActionBar(var_476_1)
	endActionBarBatch()

	actionBarPreparedPreset = presetName

	if actionBarCorruptHotkeySeen then
		saveActionBar()

		actionBarCorruptHotkeySeen = false
	end

	setupHotkeys()
	applyClientOptionsToActionBar()
	refreshAllVirtueYellowBorders()
	updateSlotsVocation()
	g_logger.info(string.format("[actionbar] reload preset=%s storedSlots=%d", presetName, storedCount))
end

function onHotkeyPresetChanged(newPreset, oldPreset)
	if not g_game.isOnline() then
		return
	end

	if not actionBarPanels or not actionBarPanels[BAR_BOTTOM_1] then
		return
	end

	addEvent(function()
		if not g_game.isOnline() then
			return
		end

		if not actionBarPanels or not actionBarPanels[BAR_BOTTOM_1] then
			return
		end

		if Keybind.currentPreset ~= newPreset then
			return
		end

		if actionBarPreparedPreset == newPreset then
			return
		end

		reloadActionBarForPreset(newPreset, oldPreset)
	end)
end
