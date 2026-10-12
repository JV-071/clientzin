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
local STATUS_ICON_WIDTH = 11
local STATUS_ICON_SPACING = 2
local text = "..."
local STATUS_ICON_IDS = {
	"iconsMonsterSlot3",
	"iconsMonsterSlot2",
	"iconsMonsterSlot1",
	"emblem",
	"partyShield",
	"skull"
}

local function findStatusIcon(button, iconId)
	return button:recursiveGetChildById(iconId)
end

local function updateStatusIcon(button, iconId, imageSource, imageClip)
	local iconWidget = findStatusIcon(button, iconId)

	if not iconWidget then
		return
	end

	local visible = imageSource ~= nil

	iconWidget:setVisible(visible)
	iconWidget:setImageSource(imageSource or "")

	if visible and imageClip then
		iconWidget:setImageClip(torect(imageClip))
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

	labelWidget:setText(text)

	if width < labelWidget:getTextSize().width then
		labelWidget:setText("")

		return
	end

	local minimumPrefixLength = 0
	local maximumPrefixLength = #name
	local fittingName = text

	while minimumPrefixLength <= maximumPrefixLength do
		local prefixLength = math.floor((minimumPrefixLength + maximumPrefixLength) / 2)
		local text = name:sub(1, prefixLength) .. text

		labelWidget:setText(text)

		if width >= labelWidget:getTextSize().width then
			fittingName = text
			minimumPrefixLength = prefixLength + 1
		else
			maximumPrefixLength = prefixLength - 1
		end
	end

	labelWidget:setText(fittingName)
end

function UICreatureButton.updateStatusIconLayout(button)
	local statusIcons = button:getChildById("statusIcons")

	if not statusIcons then
		return
	end

	local visibleIconCount = 0

	for unusedValue, entry in ipairs(STATUS_ICON_IDS) do
		local iconWidget = findStatusIcon(button, entry)

		if iconWidget and iconWidget:isExplicitlyVisible() then
			visibleIconCount = visibleIconCount + 1
		end
	end

	local width = visibleIconCount > 0 and visibleIconCount * STATUS_ICON_WIDTH + (visibleIconCount - 1) * STATUS_ICON_SPACING or 0

	statusIcons:setWidth(width)
	statusIcons:getLayout():update()

	local layout = button:getLayout()

	if layout then
		layout:update()
	end

	button:updateNameLabel()
end

function UICreatureButton.updateOutfitPreview(self, outfit)
	local creature = self:getChildById("creature")

	if not creature then
		return
	end

	creature:setOutfit(outfit)

	local previewCreature = creature:getCreature()

	if previewCreature then
		previewCreature:setAnimate(true)

		if not previewCreature:isDisabledWalkAnimation() then
			previewCreature:setDisableWalkAnimation(true)
		end
	end

	creature:setCenter(true)
	creature:setCenterByBoundingBox(true)
	if creature.setFitVisibleBounds then
		creature:setFitVisibleBounds(true)
	elseif creature.setAutoFit then
		creature:setAutoFit(true)
	end

	if creature.setFixedCreatureSize then
		creature:setFixedCreatureSize(true)
	end

	creature:setCreatureSize(0)

	if creature.setBaseScale then
		creature:setBaseScale(false)
	end

	if creature.setIgnoreDisplacementShift then
		creature:setIgnoreDisplacementShift(false)
	end

	if creature.setCreatureSmooth then
		creature:setCreatureSmooth(false)
	end
end

function UICreatureButton.setup(self, targetCreature, onlyOutfit)
	self.creature = targetCreature
	self.isHovered = nil
	self.creatureHovered = g_game.getHoveredCreature() == targetCreature

	local creature = self:getChildById("creature")
	local label = self:getChildById("label")

	if not label._nameEllipsisBound then
		label._nameEllipsisBound = true

		function label.onGeometryChange(labelWidget)
			local parent = labelWidget:getParent()

			if parent and parent.updateNameLabel then
				parent:updateNameLabel()
			end
		end
	end

	self:updateNameLabel()

	if onlyOutfit == true then
		self:updateOutfitPreview(targetCreature:getOutfit())
	else
		creature:setCreature(targetCreature)
	end

	self:setId("CreatureButton_" .. targetCreature:getName():gsub("%s", "_"))
	self:setLifeBarPercent(targetCreature:getHealthPercent())
	self:updateSkull(targetCreature:getSkull())
	self:updateEmblem(targetCreature:getEmblem())
	self:updateIcons(targetCreature:getIcons())

	if self:getChildById("manaBar") then
		self:setManaBarPercent(targetCreature:getManaPercent())
	end

	if self.updatePartyShield then
		self:updatePartyShield(targetCreature:getShield())
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

		updateStatusIcon(self, "skull", imagePath, clip)
	else
		updateStatusIcon(self, "skull", nil)
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

		updateStatusIcon(self, "emblem", imagePath, clip)
	else
		updateStatusIcon(self, "emblem", nil)
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

	if not findStatusIcon(self, "partyShield") then
		return
	end

	shieldId = shieldId or self.creature:getShield()

	if shieldId ~= ShieldNone then
		local imagePath, clip = getShieldImagePath(shieldId)

		updateStatusIcon(self, "partyShield", imagePath, clip)
	else
		updateStatusIcon(self, "partyShield", nil)
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
		local w = findStatusIcon(self, "iconsMonsterSlot" .. i)

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
		local widget = findStatusIcon(self, "iconsMonsterSlot" .. index)

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

	for unusedValue, entry in ipairs(STATUS_ICON_IDS) do
		local w = findStatusIcon(self, entry)

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
