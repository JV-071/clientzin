UICreatureButton = extends(UIWidget, "UICreatureButton")

local CreatureButtonColors = {
	onIdle = {
		notHovered = "#C0C0C0",
		hovered = "#FFFFFF"
	},
	onTargeted = {
		notHovered = "#FF0000",
		hovered = "#FF8888"
	},
	onFollowed = {
		notHovered = "#00FF00",
		hovered = "#88FF88"
	}
}
local NameBorderColors = {
	red = "#FF2020",
	pink = "#C850C0",
	orange = "#EE8413"
}
local var_0_2 = 11
local var_0_3 = 2
local var_0_4 = "..."
local var_0_5 = {
	"iconsMonsterSlot3",
	"iconsMonsterSlot2",
	"iconsMonsterSlot1",
	"emblem",
	"partyShield",
	"skull"
}

local function var_0_6(arg_1_0, arg_1_1)
	return arg_1_0:recursiveGetChildById(arg_1_1)
end

local function var_0_7(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	local var_2_0 = var_0_6(arg_2_0, arg_2_1)

	if not var_2_0 then
		return
	end

	local var_2_1 = arg_2_2 ~= nil

	var_2_0:setVisible(var_2_1)
	var_2_0:setImageSource(arg_2_2 or "")

	if var_2_1 and arg_2_3 then
		var_2_0:setImageClip(torect(arg_2_3))
	end
end

local function resolveNameBorderColor(creature)
	if not creature then
		return nil
	end

	local echoRaidColor = creature.getEchoRaidColor and creature:getEchoRaidColor() or -1

	if echoRaidColor == 0 then
		return NameBorderColors.red
	elseif echoRaidColor == 1 then
		return NameBorderColors.pink
	end

	local icons = creature.getIcons and creature:getIcons() or nil

	if icons then
		for _, iconData in pairs(icons) do
			if iconData[1] == 5 then
				return NameBorderColors.orange
			end
		end
	end

	return nil
end

function UICreatureButton.update(self)
	local labelColor = CreatureButtonColors.onIdle.notHovered
	local borderColor
	local showBorder = false

	if self.creatureHovered then
		labelColor = "#FFFFFF"
		borderColor = "#FFFFFF"
		showBorder = true
	end

	if self.isFollowed then
		labelColor = "#FFFFFF"
		borderColor = CreatureButtonColors.onFollowed.notHovered
		showBorder = true
	end

	if self.isTarget then
		borderColor = CreatureButtonColors.onTargeted.notHovered
		showBorder = true
	end

	local creatureWidget = self:getChildById("creature")
	local labelWidget = self:getChildById("label")

	if showBorder then
		creatureWidget:setBorderWidth(1)
		creatureWidget:setBorderColor(borderColor)
	else
		creatureWidget:setBorderWidth(0)
	end

	if self.isPartyButton and self.creature and not CreatureList.canBeSeen(self.creature) then
		labelColor = "#808080"
	end

	labelWidget:setColor(labelColor)
	self:updateNameBorder()
end

function UICreatureButton.updateNameBorder(self)
	local labelWidget = self:getChildById("label")

	if not labelWidget or not labelWidget.setTextOutlineColor then
		return
	end

	if not self.isBattleButton or not self.creature then
		labelWidget:setTextOutlineColor("alpha")

		return
	end

	local borderColor = resolveNameBorderColor(self.creature)

	labelWidget:setTextOutlineColor(borderColor or "alpha")
end

function UICreatureButton.create()
	local button = UICreatureButton.internalCreate()

	button:setFocusable(false)

	button.creature = nil
	button.creatureHovered = false
	button.isTarget = false
	button.isFollowed = false

	return button
end

function UICreatureButton.getCreatureButtonColors()
	return CreatureButtonColors
end

function UICreatureButton.setCreature(self, creature)
	self.creature = creature
end

function UICreatureButton.getCreature(self)
	return self.creature
end

function UICreatureButton.getCreatureId(self)
	return self.creature:getId()
end

function UICreatureButton.updateNameLabel(self)
	local labelWidget = self:getChildById("label")

	if not labelWidget then
		return
	end

	local name = self.creature and self.creature:getName() or ""

	labelWidget:setText(name)

	local width = labelWidget:getWidth() - labelWidget:getPaddingLeft() - labelWidget:getPaddingRight()

	if width <= 0 or width >= labelWidget:getTextSize().width then
		return
	end

	labelWidget:setText(var_0_4)

	if width < labelWidget:getTextSize().width then
		labelWidget:setText("")

		return
	end

	local var_11_3 = 0
	local var_11_4 = #name
	local var_11_5 = var_0_4

	while var_11_3 <= var_11_4 do
		local var_11_6 = math.floor((var_11_3 + var_11_4) / 2)
		local var_11_7 = name:sub(1, var_11_6) .. var_0_4

		labelWidget:setText(var_11_7)

		if width >= labelWidget:getTextSize().width then
			var_11_5 = var_11_7
			var_11_3 = var_11_6 + 1
		else
			var_11_4 = var_11_6 - 1
		end
	end

	labelWidget:setText(var_11_5)
end

function UICreatureButton.updateStatusIconLayout(arg_12_0)
	local statusIcons = arg_12_0:getChildById("statusIcons")

	if not statusIcons then
		return
	end

	local var_12_1 = 0

	for unusedValue, entry in ipairs(var_0_5) do
		local var_12_2 = var_0_6(arg_12_0, entry)

		if var_12_2 and var_12_2:isExplicitlyVisible() then
			var_12_1 = var_12_1 + 1
		end
	end

	local var_12_3 = var_12_1 > 0 and var_12_1 * var_0_2 + (var_12_1 - 1) * var_0_3 or 0

	statusIcons:setWidth(var_12_3)
	statusIcons:getLayout():update()

	local layout = arg_12_0:getLayout()

	if layout then
		layout:update()
	end

	arg_12_0:updateNameLabel()
end

function UICreatureButton.updateOutfitPreview(self, outfit)
	local creature = self:getChildById("creature")

	if not creature then
		return
	end

	creature:setOutfit(outfit)

	local var_13_1 = creature:getCreature()

	if var_13_1 then
		var_13_1:setAnimate(true)

		if not var_13_1:isDisabledWalkAnimation() then
			var_13_1:setDisableWalkAnimation(true)
		end
	end

	creature:setCenter(true)
	creature:setCenterByBoundingBox(true)
	creature:setFitVisibleBounds(true)
	creature:setFixedCreatureSize(true)
	creature:setCreatureSize(0)
	creature:setBaseScale(false)
	creature:setIgnoreDisplacementShift(false)
	creature:setCreatureSmooth(false)
end

function UICreatureButton.setup(self, arg_14_1, onlyOutfit)
	self.creature = arg_14_1
	self.isHovered = nil
	self.creatureHovered = g_game.getHoveredCreature() == arg_14_1

	local creature = self:getChildById("creature")
	local label = self:getChildById("label")

	if not label._nameEllipsisBound then
		label._nameEllipsisBound = true

		function label.onGeometryChange(arg_15_0)
			local parent = arg_15_0:getParent()

			if parent and parent.updateNameLabel then
				parent:updateNameLabel()
			end
		end
	end

	self:updateNameLabel()

	if onlyOutfit == true then
		self:updateOutfitPreview(arg_14_1:getOutfit())
	else
		creature:setCreature(arg_14_1)
	end

	self:setId("CreatureButton_" .. arg_14_1:getName():gsub("%s", "_"))
	self:setLifeBarPercent(arg_14_1:getHealthPercent())
	self:updateSkull(arg_14_1:getSkull())
	self:updateEmblem(arg_14_1:getEmblem())
	self:updateIcons(arg_14_1:getIcons())

	if self:getChildById("manaBar") then
		self:setManaBarPercent(arg_14_1:getManaPercent())
	end

	if self.updatePartyShield then
		self:updatePartyShield(arg_14_1:getShield())
	end

	if self.isBattleButton then
		local lifeBarWidget = self:getChildById("lifeBar")

		if lifeBarWidget then
			lifeBarWidget:setVisible(true)
		end
	elseif self.updateShowStatus and self.creature.getShowStatus then
		self:updateShowStatus(self.creature:getShowStatus())
	end

	self:update()
end

function UICreatureButton.updateSkull(self, skullId)
	if not self.creature then
		return
	end

	local skullId = skullId or self.creature:getSkull()

	if skullId ~= SkullNone then
		local imagePath, clip = getSkullImagePath(skullId)

		var_0_7(self, "skull", imagePath, clip)
	else
		var_0_7(self, "skull", nil)
	end

	self:updateStatusIconLayout()
end

function UICreatureButton.updateEmblem(self, emblemId)
	if not self.creature then
		return
	end

	local emblemId = emblemId or self.creature:getEmblem()

	if emblemId ~= EmblemNone then
		local imagePath, clip = getEmblemImagePath(emblemId)

		var_0_7(self, "emblem", imagePath, clip)
	else
		var_0_7(self, "emblem", nil)
	end

	self:updateStatusIconLayout()
end

function UICreatureButton.setLifeBarPercent(self, percent)
	local lifeBarWidget = self:getChildById("lifeBar")

	lifeBarWidget:setPercent(percent)
	lifeBarWidget:setBackgroundColor(getHealthColorByPercent(percent))
end

function UICreatureButton.setManaBarPercent(self, percent)
	local manaBarWidget = self:getChildById("manaBar")

	if not manaBarWidget then
		return
	end

	manaBarWidget:setPercent(percent)
	manaBarWidget:setBackgroundColor("#0000FF")
end

function UICreatureButton.updatePartyShield(self, shieldId)
	if not self.creature then
		return
	end

	if not var_0_6(self, "partyShield") then
		return
	end

	shieldId = shieldId or self.creature:getShield()

	if shieldId ~= ShieldNone then
		local imagePath, clip = getShieldImagePath(shieldId)

		var_0_7(self, "partyShield", imagePath, clip)
	else
		var_0_7(self, "partyShield", nil)
	end

	self:updateStatusIconLayout()
end

function UICreatureButton.updateShowStatus(self, showStatus)
	if showStatus == nil and self.creature and self.creature.getShowStatus then
		showStatus = self.creature:getShowStatus()
	end

	if showStatus == nil then
		showStatus = true
	end

	local lifeBarWidget = self:getChildById("lifeBar")
	local manaBarWidget = self:getChildById("manaBar")

	if lifeBarWidget then
		local visible = self.isBattleButton or showStatus

		lifeBarWidget:setVisible(visible)

		if visible and self.creature and self.creature.getHealthPercent then
			self:setLifeBarPercent(self.creature:getHealthPercent())
		end
	end

	if manaBarWidget then
		manaBarWidget:setVisible(showStatus)
	end
end

function UICreatureButton.updateIcons(self, icons)
	for i = 1, 3 do
		local w = var_0_6(self, "iconsMonsterSlot" .. i)

		if w then
			w:setImageSource("")
			w:setVisible(false)
		end
	end

	if not self.creature or not icons or #icons == 0 then
		self:updateStatusIconLayout()
		self:updateNameBorder()

		return
	end

	if not self.creature:isMonster() then
		self:updateStatusIconLayout()
		self:updateNameBorder()

		return
	end

	for index, iconData in pairs(icons) do
		if index > 3 then
			break
		end

		local iconId = iconData[1]
		local widget = var_0_6(self, "iconsMonsterSlot" .. index)

		if widget then
			widget:setVisible(true)
			widget:setImageSource("/images/game/creatures/hud/flags/modifications")
			widget:setImageClip(torect((iconId - 1) * 11 .. " 0 11 11"))
		end
	end

	self:updateStatusIconLayout()
	self:updateNameBorder()
end

function UICreatureButton.resetState(self)
	self.isHovered = nil
	self.creatureHovered = false
	self.isTarget = false
	self.isFollowed = false

	self:getChildById("creature"):setBorderWidth(0)
	self:getChildById("label"):setColor(CreatureButtonColors.onIdle.notHovered)

	for unusedValue, entry in ipairs(var_0_5) do
		local w = var_0_6(self, entry)

		if w then
			w:setImageSource("")
			w:setVisible(false)
		end
	end

	self:updateStatusIconLayout()

	local labelWidget = self:getChildById("label")

	if labelWidget and labelWidget.setTextOutlineColor then
		labelWidget:setTextOutlineColor("alpha")
	end
end
