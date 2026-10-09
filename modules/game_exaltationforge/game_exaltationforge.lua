Forge = {}

function Forge.getForgeContainerHighlightTarget(container)
	local slot = container:getChildById("forgeItem")

	if not slot then
		return nil
	end

	return slot:getChildById("selectionOverlay") or slot
end

function Forge.raiseForgeContainerSelectionOverlay(forgeItemSlot)
	local overlay = forgeItemSlot:getChildById("selectionOverlay")

	if overlay then
		overlay:raise()
	end
end

function Forge.updateTabButtonIconState(buttonPanel, pressed)
	if not buttonPanel or not buttonPanel.forgeIconReleased then
		return
	end

	local button = buttonPanel:getChildById("button")

	if not button then
		return
	end

	local offset = pressed and buttonPanel.forgeIconPressed or buttonPanel.forgeIconReleased

	button:setIconOffset(topoint(offset.left .. " " .. offset.top))
end

function Forge.setupTabButtonIcon(buttonPanel, iconPath, releasedLeft, releasedTop, onlyVertical)
	local button = buttonPanel:getChildById("button")

	button:setIcon(iconPath)

	releasedTop = releasedTop - 3
	buttonPanel.forgeIconReleased = {
		left = releasedLeft,
		top = releasedTop
	}
	buttonPanel.forgeIconPressed = {
		left = onlyVertical and releasedLeft or releasedLeft + 1,
		top = releasedTop + 1
	}

	Forge.updateTabButtonIconState(buttonPanel, button:isDisabled())
end

function Forge.onTabButtonIconPress(buttonPanel)
	Forge.updateTabButtonIconState(buttonPanel, true)
end

function Forge.onTabButtonIconRelease(buttonPanel)
	local button = buttonPanel:getChildById("button")

	if button and not button:isDisabled() then
		Forge.updateTabButtonIconState(buttonPanel, false)
	end
end

function Forge.onTabButtonEnabled(previousButton, nextButtonPanel, enabled)
	if previousButton then
		Forge.updateTabButtonIconState(previousButton:getParent(), false)
	end

	if nextButtonPanel and enabled == false then
		Forge.updateTabButtonIconState(nextButtonPanel, true)
	end
end

function Forge.getMenus()
	if Forge.mainWindow then
		return Forge.mainWindow:getChildById("menus") or Forge.mainWindow
	end

	return nil
end

function Forge.createTabPanel(styleName, arg_9_1)
	local menus = g_ui.createWidget(styleName, Forge.getMenus())

	if arg_9_1 then
		menus:setId(arg_9_1)
	end

	return menus
end

function Forge.anchorContentPanel(arg_10_0)
	arg_10_0:addAnchor(AnchorTop, "menus", AnchorBottom)
	arg_10_0:addAnchor(AnchorLeft, "parent", AnchorLeft)
	arg_10_0:addAnchor(AnchorRight, "parent", AnchorRight)
	arg_10_0:addAnchor(AnchorBottom, "parent", AnchorBottom)
end

function Forge.setActiveTabButton(currentButton)
	if Forge.currentButton and Forge.currentButton ~= currentButton then
		if Forge.currentButton.setOn then
			Forge.currentButton:setOn(false)
		end

		if Forge.currentButton.setChecked then
			Forge.currentButton:setChecked(false)
		end

		Forge.onTabButtonEnabled(Forge.currentButton, nil, true)
	end

	Forge.currentButton = currentButton

	if not currentButton then
		return
	end

	if currentButton.setOn then
		currentButton:setOn(true)
	end

	if currentButton.setChecked then
		currentButton:setChecked(true)
	end

	local parent = currentButton.getParent and currentButton:getParent()

	Forge.onTabButtonEnabled(nil, parent, false)
end

Forge.resourceTypes = {
	core = 72,
	sliver = 71,
	dust = 70,
	money = 0
}
Forge.colors = {
	enough = "#C0C0C0",
	missing = "#D33C3C"
}
Forge.forceApplyNextOpenSnapshot = false

local FORGE_RESULT_SILHOUETTE_SHADER = "forge_result_silhouette"

ACTION_FUSION_TYPE = 0
ACTION_TRANSFER_TYPE = 1
ACTION_DUST_TO_SILVER = 2
ACTION_SILVER_TO_CORE = 3
ACTION_INCREASE_DUST_LIMIT = 4

local Fusion
local Transfer
local Conversion
local History

function init()
	Forge.mainButton = modules.game_mainpanel.addToggleButton("forgeButton", tr("Open Exaltation Forge"), "/images/options/button_exaltation_forge", function()
		Forge:displayPreview()
	end, false, 17)

	Forge.mainButton:setOn(false)

	Forge.mainWindow = g_ui.displayUI("game_exaltationforge")

	Forge.mainWindow:setId("forge")
	Forge.mainWindow:setVisible(false)

	function Forge.mainWindow.onVisibilityChange(widget, visible)
		if visible then
			g_modalManager.show(widget)
		else
			g_modalManager.hide(widget)
		end
	end

	Forge.firstTooltip = Forge.mainWindow:getChildById("firstTooltip")
	Forge.goldBalancePanel = Forge.mainWindow:getChildById("goldBalancePanel")
	Forge.goldBalanceValue = Forge.goldBalancePanel:getChildById("value")
	Forge.dustBalancePanel = Forge.mainWindow:getChildById("dustBalancePanel")
	Forge.dustBalanceValue = Forge.dustBalancePanel:getChildById("value")
	Forge.sliverBalancePanel = Forge.mainWindow:getChildById("sliverBalancePanel")
	Forge.sliverBalanceValue = Forge.sliverBalancePanel:getChildById("value")
	Forge.coreBalancePanel = Forge.mainWindow:getChildById("coreBalancePanel")
	Forge.coreBalanceValue = Forge.coreBalancePanel:getChildById("value")
	Forge.mainWindow:getChildById("close").onClick = function(self)
		Forge:close()
	end
	Fusion = Forge.Fusion:get()
	Transfer = Forge.Transfer
	Conversion = Forge.Conversion
	History = Forge.History:get()

	Forge.Fusion:createButton()
	Forge.Transfer:createButton()
	Forge.Conversion:createButton()
	Forge.History:createButton()
	connect(g_game, {
		onOpenExaltationForge = onOpenExaltationForge,
		onResultExaltationForge = onResultExaltationForge,
		onItemClasses = onPlayerResourcesChange,
		onForgeHistory = onForgeHistory,
		onResourceBalance = onResourceBalance,
		onGameEnd = function()
			Forge:close()
		end
	})
	Keybind.new("Dialogs", "Open Exaltation Forge", "", "")
	Keybind.bind("Dialogs", "Open Exaltation Forge", {
		{
			type = KEY_DOWN,
			callback = function()
				Forge:displayPreview()

				return true
			end
		}
	}, modules.game_interface.getRootPanel())
	g_shaders.createFragmentShader(FORGE_RESULT_SILHOUETTE_SHADER, "menu/shaders/silhouette.frag", false)
end

function onResourceBalance()
	Forge:updateResources()

	if Conversion and Forge.data and Forge.data.config then
		Conversion:parseResourcesChange(Forge.data)
	end
end

function Forge.getDustLevel(self)
	return math.max(0, self.dustLevel or 0)
end

function Forge.updateResources(self)
	self.goldBalanceValue:setText(self:formatNumber(self:getResourceBalance("money")))

	local dustLevel = 100 + self:getDustLevel() * 20

	self.dustBalanceValue:setText(self:formatNumber(self:getResourceBalance("dust")) .. "/" .. self:formatNumber(dustLevel))
	self.sliverBalanceValue:setText(self:getResourceBalance("sliver"))
	self.coreBalanceValue:setText(self:getResourceBalance("core"))
end

function Forge.resetConvergenceModes(self)
	if Forge.Fusion and Forge.Fusion.resetConvergenceMode then
		Forge.Fusion:resetConvergenceMode()
	end

	if Forge.Transfer and Forge.Transfer.resetConvergenceMode then
		Forge.Transfer:resetConvergenceMode()
	end
end

function Forge.close(self)
	self:resetConvergenceModes()
	self.mainWindow:setVisible(false)

	if self.mainButton then
		self.mainButton:setOn(false)
	end

	if self.resultWindow then
		self.resultWindow:setVisible(false)
	end

	Forge.preview = false
end

function Forge.get(self)
	return self
end

function Forge.displayPreview(self)
	if not self.mainWindow:isVisible() then
		g_game.sendResourceBalance()

		Forge.preview = true

		self.mainWindow:setVisible(true)
		self.mainWindow:focus()
		Conversion:showWindow()
		Transfer:updateWidgets()
		self:updateResources()

		if Conversion and self.data and self.data.config then
			Conversion:parseResourcesChange(self.data)
		end

		if Transfer and self.data then
			Transfer:parseResourcesChange(self.data)
		end
	else
		Forge:close()
	end
end

function Forge.formatNumber(unusedArgument, n)
	n = math.floor(tonumber(n) or 0)

	local formattedText = string.format("%.0f", n):reverse():gsub("(%d%d%d)", "%1,"):reverse()

	if formattedText:sub(1, 1) == "," then
		formattedText = formattedText:sub(2)
	end

	return formattedText
end

function Forge.updateWidget(self, resourceType, widget, value, _disabled)
	local balance = Forge:getResourceBalance(resourceType)

	value = tonumber(value)

	if value <= balance then
		widget:setColor(Forge.colors.enough)

		if _disabled then
			widget:setEnabled(false)
		end
	else
		widget:setColor(Forge.colors.missing)

		if _disabled then
			widget:setEnabled(true)
		end
	end
end

function Forge.setWidget(self, widget, value, boolean)
	widget:setText(value)

	if boolean then
		widget:setColor(Forge.colors.enough)
	else
		widget:setColor(Forge.colors.missing)
	end
end

function Forge.getResourceBalance(self, str)
	local t = self.resourceTypes[str]

	if not t then
		return 0
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return 0
	end

	if str == "money" then
		return player:getTotalMoney()
	end

	return player:getResourceBalance(t)
end

local function getResultBigTier(widget)
	if not widget then
		return nil
	end

	return widget:getChildById("bigtier") or widget.bigtier
end

local function setResultBigTier(widget, tier)
	if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
		return
	end

	local bigtier = getResultBigTier(widget)

	if not bigtier then
		return
	end

	tier = tonumber(tier) or 0

	if tier > 0 then
		local xOffset = (math.min(math.max(tier, 1), 10) - 1) * 18

		bigtier:setImageClip({
			height = 16,
			width = 18,
			y = 0,
			x = xOffset
		})
		bigtier:setMarginRight(-1)
		bigtier:setVisible(true)
	else
		bigtier:setVisible(false)
	end
end

local function setResultItemShader(widget, item, shaderName)
	local shader = shaderName or ""

	if widget and widget.setShader then
		widget:setShader(shader)
	elseif item then
		item:setShader(shaderName)
	end

	local bigtier = getResultBigTier(widget)

	if bigtier and bigtier.setShader then
		if shaderName then
			bigtier:setShader(shaderName)
		else
			bigtier:setShader("")
		end
	end
end

local FORGE_RESULT_INITIAL_DELAY_MS = 1250
local FORGE_RESULT_PULSE_SLOW_MS = 200
local FORGE_RESULT_PULSE_FAST_MS = 100
local FORGE_RESULT_FINAL_FLASH_MS = 500
local FORGE_RESULT_FADE_MS = 800
local FORGE_RESULT_SHADER_CREATE_MS = 50
local FORGE_RESULT_STEPS = {
	{
		on = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		pause = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		fill = 1,
		on = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		pause = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		fill = 2,
		on = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		pause = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		fill = 3,
		on = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		pause = FORGE_RESULT_PULSE_SLOW_MS
	},
	{
		unfill = 1,
		on = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		pause = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		on = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		pause = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		unfill = 2,
		on = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		pause = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		on = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		pause = FORGE_RESULT_PULSE_FAST_MS
	},
	{
		final = true,
		unfill = 3,
		on = FORGE_RESULT_FINAL_FLASH_MS
	}
}
local FORGE_RESULT_FLASHES, FORGE_RESULT_FADE_START_MS = (function(steps, initialDelayMs)
	local t = initialDelayMs
	local flashes = {}

	for _, step in ipairs(steps) do
		if step.pause then
			t = t + step.pause
		else
			table.insert(flashes, {
				at = t,
				onMs = step.on,
				fill = step.fill,
				unfill = step.unfill,
				final = step.final
			})

			t = t + step.on
		end
	end

	return flashes, t
end)(FORGE_RESULT_STEPS, FORGE_RESULT_INITIAL_DELAY_MS)
local FORGE_RESULT_FINAL_FLASH = FORGE_RESULT_FLASHES[#FORGE_RESULT_FLASHES]
local FORGE_RESULT_BLINK_SHADER = "Item - ForgeBlink"
local FORGE_RESULT_BLINK_RED_SHADER = "Item - ForgeBlinkRed"
local FORGE_RESULT_FADE_OUT_SHADER = "Item - ForgeFadeOut"
local FORGE_RESULT_FADE_IN_SHADER = "Item - ForgeFadeIn"
local FORGE_RESULT_FADE_OUT_RED_SHADER = "Item - ForgeFadeOutRed"

local function recreateForgeResultShader(shaderName, shaderPath)
	g_shaders.removeShader(shaderName)
	g_shaders.createFragmentShader(shaderName, shaderPath, false)
end

local function applyShaderWhenReady(shaderName, applyFn, attempt)
	if g_shaders.getShader(shaderName) then
		applyFn()

		return
	end

	if (attempt or 0) < 20 then
		scheduleEvent(function()
			applyShaderWhenReady(shaderName, applyFn, (attempt or 0) + 1)
		end, 16)
	end
end

local function applyResultSilhouette(widget, onApplied)
	if not widget then
		if onApplied then
			onApplied()
		end

		return
	end

	if not g_shaders.getShader(FORGE_RESULT_SILHOUETTE_SHADER) then
		g_shaders.createFragmentShader(FORGE_RESULT_SILHOUETTE_SHADER, "menu/shaders/silhouette.frag", false)
	end

	applyShaderWhenReady(FORGE_RESULT_SILHOUETTE_SHADER, function()
		widget:setColor("white")
		setResultItemShader(widget, widget:getItem(), FORGE_RESULT_SILHOUETTE_SHADER)

		if widget.updateLayout then
			widget:updateLayout()
		end

		if widget.repaint then
			widget:repaint()
		end

		if onApplied then
			onApplied()
		end
	end, 0)
end

local function buildForgeResultText(prefix, success)
	local gray = "#C0C0C0"
	local word = success and "successful" or "failed"
	local wordColor = success and "#44AD25" or "#D33C3C"

	return string.format("{%s, %s}{%s, %s}{., %s}", prefix, gray, word, wordColor, gray)
end

local function setResultCloseLocked(closeWidget, locked)
	if not closeWidget then
		return
	end

	closeWidget:setEnabled(not locked)

	if locked then
		local currentText = closeWidget:getText()

		if currentText and currentText ~= "" then
			closeWidget.resultActionText = currentText
		elseif not closeWidget.resultActionText then
			closeWidget.resultActionText = "Close"
		end

		closeWidget:setText("")
	else
		closeWidget:setText(closeWidget.resultActionText or "Close")
	end

	local dither = closeWidget:getChildById("closeDither")

	if dither then
		dither:setVisible(locked)

		if locked then
			dither:raise()
		end
	end
end

local function revealResultOutcomeUi(descWidget, description, closeWidget)
	if descWidget then
		descWidget:setColoredText(description)
		descWidget:setVisible(true)
	end

	setResultCloseLocked(closeWidget, false)
end

local function scheduleForgeResultDryPhase(leftWidget, leftItem, blinkShader, arrows)
	local emptyIcon = "/images/game/forge/icon-arrow-rightlarge"
	local filledIcon = "/images/game/forge/icon-arrow-rightlarge-filled"

	if arrows then
		for _, arrow in ipairs(arrows) do
			if arrow then
				arrow:setImageSource(emptyIcon)
			end
		end
	end

	for _, flash in ipairs(FORGE_RESULT_FLASHES) do
		if not flash.final then
			scheduleEvent(function()
				setResultItemShader(leftWidget, leftItem, blinkShader)
				scheduleEvent(function()
					setResultItemShader(leftWidget, leftItem, nil)
				end, flash.onMs)
			end, flash.at)
		end

		if arrows and flash.fill then
			scheduleEvent(function()
				local arrow = arrows[flash.fill]

				if arrow then
					arrow:setImageSource(filledIcon)
				end
			end, flash.at)
		end

		if arrows and flash.unfill then
			scheduleEvent(function()
				local arrow = arrows[flash.unfill]

				if arrow then
					arrow:setImageSource(emptyIcon)
				end
			end, flash.at)
		end
	end
end

local function prepareResultRightItem(widget2, item2, revealTier)
	if not widget2 or not item2 then
		return
	end

	setResultItemShader(widget2, item2, nil)
	widget2:setColor("white")
	widget2:setItem(item2)

	if revealTier and revealTier > 0 then
		item2:setTier(revealTier)
		widget2:setTier(revealTier)
		setResultBigTier(widget2, revealTier)
	elseif item2:getTier() > 0 then
		setResultBigTier(widget2, item2:getTier())
	end
end

local function playResultFade(leftWidget, leftItem, rightWidget, rightItem, leftFadeShader, leftFadePath, rightFadeShader, rightFadePath, onComplete, onFadeComplete)
	recreateForgeResultShader(leftFadeShader, leftFadePath)
	recreateForgeResultShader(rightFadeShader, rightFadePath)

	local function applyFadeShaders(attempt)
		if not g_shaders.getShader(leftFadeShader) or not g_shaders.getShader(rightFadeShader) then
			if (attempt or 0) < 20 then
				scheduleEvent(function()
					applyFadeShaders((attempt or 0) + 1)
				end, 16)
			else
				if onFadeComplete then
					onFadeComplete()
				end

				if onComplete then
					onComplete()
				end
			end

			return
		end

		setResultItemShader(leftWidget, leftItem, leftFadeShader)
		setResultItemShader(rightWidget, rightItem, rightFadeShader)
		scheduleEvent(function()
			if onFadeComplete then
				onFadeComplete()
			end

			if onComplete then
				onComplete()
			end

			setResultItemShader(leftWidget, leftItem, nil)
			setResultItemShader(rightWidget, rightItem, nil)
			leftWidget:setColor("white")
		end, FORGE_RESULT_FADE_MS)
	end

	scheduleEvent(function()
		applyFadeShaders(0)
	end, FORGE_RESULT_SHADER_CREATE_MS)
end

local function setupResultPreviewItem(widget, item, showTier)
	if not widget or not item then
		return
	end

	widget:setFixedItemSize(false)
	widget:setItem(item)

	if showTier == false then
		setResultBigTier(widget, 0)
	else
		setResultBigTier(widget, item:getTier())
	end
end

local function resolveTransferRevealTier(success, convergence, leftTier, rightTier)
	if not success or not leftTier or leftTier <= 0 then
		return nil
	end

	if rightTier and rightTier > 0 then
		return rightTier
	end

	if convergence == 1 then
		return leftTier
	end

	return math.max(0, leftTier - 1)
end

local FORGE_DUST_ITEM_ID = 37160
local FORGE_CORE_ITEM_ID = 37110
local FORGE_GOLD_ITEM_ID = 3031
local var_0_37 = "#C0C0C0"

local function var_0_38(ch, arg_54_1)
	arg_54_1 = arg_54_1 or var_0_37

	if not ch:find("{icon:", 1, true) then
		return string.format("{%s, %s}", ch, arg_54_1)
	end

	local var_54_0 = {}
	local buffer = 1

	while buffer <= #ch do
		local var_54_2 = ch:find("{icon:", buffer, true)

		if not var_54_2 then
			local var_54_3 = ch:sub(buffer)

			if var_54_3 ~= "" then
				var_54_0[#var_54_0 + 1] = string.format("{%s, %s}", var_54_3, arg_54_1)
			end

			break
		end

		local var_54_4 = ch:find("}", var_54_2, true)

		if not var_54_4 then
			var_54_0[#var_54_0 + 1] = string.format("{%s, %s}", ch:sub(buffer), arg_54_1)

			break
		end

		local var_54_5 = ch:sub(buffer, var_54_2 - 1)

		if var_54_5 ~= "" then
			var_54_0[#var_54_0 + 1] = string.format("{%s, %s}", var_54_5, arg_54_1)
		end

		var_54_0[#var_54_0 + 1] = ch:sub(var_54_2, var_54_4)
		buffer = var_54_4 + 1
	end

	return table.concat(var_54_0)
end

local function buildForgeBonusPresentation(bonus, leftItemId)
	if not Fusion or not Fusion.classificationTable then
		return 0
	end

	local probe = Item.create(bonus)

	if not probe then
		return 0
	end

	local byClass = Fusion.classificationTable[tostring(probe:getClassification())]

	if not byClass then
		return 0
	end

	return tonumber(byClass[tostring(leftItemId or 0)]) or 0
end

local function var_0_40(bonus, leftItemId, leftTier, coreCount, extraItemId, extraTier)
	bonus = tonumber(bonus) or 0

	if bonus <= 0 then
		return nil
	end

	leftItemId = tonumber(leftItemId) or 0
	leftTier = tonumber(leftTier) or 0
	coreCount = tonumber(coreCount) or 0
	extraItemId = tonumber(extraItemId) or 0
	extraTier = tonumber(extraTier) or 0

	local bonusItemId = extraItemId > 0 and extraItemId or leftItemId

	if bonus == 1 then
		local text = "Neat! The used 100{icon:dust} were not consumed."

		return {
			tier = 0,
			count = 1,
			itemId = FORGE_DUST_ITEM_ID,
			text = text
		}
	elseif bonus == 2 then
		local text = "Great! The used{icon:exalted-core} was not consumed."

		return {
			tier = 0,
			itemId = FORGE_CORE_ITEM_ID,
			count = math.max(coreCount, 1),
			text = text
		}
	elseif bonus == 3 then
		local goldCost = buildForgeBonusPresentation(leftItemId, leftTier)
		local text = string.format("Awesome! The used %s{icon:gold-coin} were not consumed.", Forge:formatNumber(goldCost))

		return {
			tier = 0,
			count = 100,
			itemId = FORGE_GOLD_ITEM_ID,
			text = text
		}
	elseif bonus >= 4 and bonus <= 8 then
		local texts = {
			nil,
			nil,
			nil,
			"What luck! Your item only lost one tier instead of being\nconsumed.",
			"Lucky you! You kept the second item and its tier.",
			"Terrific! Both of your items gained an additional tier.",
			"Unbelievable! You must be blessed by the Tibian gods!\nYour fused item gained two instead of one tier!",
			"Stroke of luck! The second item was not consumed."
		}

		return {
			count = 1,
			itemId = bonusItemId,
			tier = extraTier,
			text = texts[bonus]
		}
	end

	return nil
end

local function hideResultFusionWidgets(resultWindow)
	if not resultWindow then
		return
	end

	for _, id in ipairs({
		"previewItem1",
		"previewItem2",
		"arrowsIcon1",
		"arrowsIcon2",
		"arrowsIcon3"
	}) do
		local widget = resultWindow:recursiveGetChildById(id)

		if widget then
			widget:setVisible(false)
		end
	end

	local dragonHeader = resultWindow:recursiveGetChildById("dragonHeader")

	if dragonHeader then
		dragonHeader:setVisible(true)
		dragonHeader:raise()
	end
end

function Forge.showResultBonus(self, bonusInfo)
	local resultWindow = self.resultWindow

	if not resultWindow or not bonusInfo then
		return
	end

	hideResultFusionWidgets(resultWindow)

	local bonusWidget = resultWindow:recursiveGetChildById("bonusItem")
	local descWidget = resultWindow:recursiveGetChildById("resultText")
	local closeWidget = resultWindow:getChildById("close")

	if bonusWidget and bonusInfo.itemId and bonusInfo.itemId > 0 then
		local item = Item.create(bonusInfo.itemId)

		if item then
			local count = math.max(tonumber(bonusInfo.count) or 1, 1)

			if item.setCount then
				item:setCount(count)
			end

			if (bonusInfo.tier or 0) > 0 then
				item:setTier(bonusInfo.tier)
			end

			bonusWidget:setVisible(true)
			bonusWidget:setFixedItemSize(false)

			if bonusWidget.setShowCount then
				bonusWidget:setShowCount(false)
			end

			setupResultPreviewItem(bonusWidget, item, (bonusInfo.tier or 0) > 0)
		end
	end

	if descWidget then
		local text = bonusInfo.text or ""
		local var_58_7, line2 = text:match("^(.-)\n(.*)$")

		if not var_58_7 then
			var_58_7 = text
			line2 = nil
		end

		local descWidget2 = resultWindow:recursiveGetChildById("resultText2")

		descWidget:breakAnchors()
		descWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		descWidget:addAnchor(AnchorTop, "bonusItem", AnchorBottom)
		descWidget:setMarginTop(10)
		descWidget:setMarginLeft(0)
		descWidget:setMarginRight(0)

		if descWidget.setTextWrap then
			descWidget:setTextWrap(false)
		end

		descWidget:setColor(var_0_37)

		if var_58_7:find("{icon:", 1, true) and not line2 then
			descWidget:setColoredText(var_0_38(var_58_7))
		else
			descWidget:setText(var_58_7)
		end

		descWidget:setVisible(true)

		if descWidget2 then
			if line2 and line2 ~= "" then
				descWidget2:setColor(var_0_37)
				descWidget2:setText(line2)
				descWidget2:setVisible(true)
			else
				descWidget2:setText("")
				descWidget2:setVisible(false)
			end
		end
	end

	if closeWidget then
		closeWidget.resultActionText = "Close"
		closeWidget.pendingBonus = nil

		setResultCloseLocked(closeWidget, false)
	end
end

function Forge.ProcessFlash(item, item, widget, startDelay, item2, widget2, descWidget, description, success, revealTier, closeWidget)
	local animationId = Forge.resultAnimationId

	local function isAnimationActive()
		return animationId == Forge.resultAnimationId and Forge.resultWindow ~= nil
	end

	local animationStartDelay = startDelay or 10
	local finalFlashAt = FORGE_RESULT_FINAL_FLASH.at
	local finalFlashOnMs = FORGE_RESULT_FINAL_FLASH.onMs
	local totalDuration = FORGE_RESULT_FADE_START_MS + FORGE_RESULT_SHADER_CREATE_MS + FORGE_RESULT_FADE_MS + 200

	recreateForgeResultShader(FORGE_RESULT_BLINK_SHADER, "menu/shaders/blink_white.frag")

	local arrows

	if Forge.resultWindow then
		arrows = {
			Forge.resultWindow:recursiveGetChildById("arrowsIcon1"),
			Forge.resultWindow:recursiveGetChildById("arrowsIcon2"),
			Forge.resultWindow:recursiveGetChildById("arrowsIcon3")
		}
	end

	scheduleEvent(function()
		if not isAnimationActive() then
			return
		end

		scheduleForgeResultDryPhase(widget, item, FORGE_RESULT_BLINK_SHADER, arrows)
		scheduleEvent(function()
			if not isAnimationActive() then
				return
			end

			if success then
				prepareResultRightItem(widget2, item2, revealTier)
				widget:setColor("white")
				setResultItemShader(widget, item, FORGE_RESULT_BLINK_SHADER)
				setResultItemShader(widget2, item2, FORGE_RESULT_BLINK_SHADER)
			else
				recreateForgeResultShader(FORGE_RESULT_BLINK_RED_SHADER, "menu/shaders/blink_red.frag")
				widget:setColor("white")
				setResultItemShader(widget, item, FORGE_RESULT_BLINK_SHADER)
				applyShaderWhenReady(FORGE_RESULT_BLINK_RED_SHADER, function()
					setResultItemShader(widget2, item2, FORGE_RESULT_BLINK_RED_SHADER)
				end, 0)
			end

			scheduleEvent(function()
				if not isAnimationActive() then
					return
				end

				local function onFadeComplete()
					revealResultOutcomeUi(descWidget, description, closeWidget)
				end

				if success then
					playResultFade(widget, item, widget2, item2, FORGE_RESULT_FADE_OUT_SHADER, "menu/shaders/fade_out_white.frag", FORGE_RESULT_FADE_IN_SHADER, "menu/shaders/fade_in_white.frag", function()
						widget:setVisible(false)
					end, onFadeComplete)
				else
					playResultFade(widget, item, widget2, item2, FORGE_RESULT_FADE_IN_SHADER, "menu/shaders/fade_in_white.frag", FORGE_RESULT_FADE_OUT_RED_SHADER, "menu/shaders/fade_out_red.frag", function()
						widget2:setVisible(false)
					end, onFadeComplete)
				end
			end, finalFlashOnMs)
		end, finalFlashAt)
	end, animationStartDelay)
	scheduleEvent(function()
		g_shaders.removeShader(FORGE_RESULT_BLINK_SHADER)
		g_shaders.removeShader(FORGE_RESULT_BLINK_RED_SHADER)
		g_shaders.removeShader(FORGE_RESULT_FADE_OUT_SHADER)
		g_shaders.removeShader(FORGE_RESULT_FADE_IN_SHADER)
		g_shaders.removeShader(FORGE_RESULT_FADE_OUT_RED_SHADER)
	end, animationStartDelay + totalDuration)
end

function Forge.displayResult(self, actionType, convergence, success, leftItemId, rightItemId, leftTier, rightTier, bonus, coreCount, extraItemId, extraTier)
	if self.resultWindow then
		self.resultWindow:destroy()

		self.resultWindow = nil
	end

	Forge.resultAnimationId = (Forge.resultAnimationId or 0) + 1
	self.resultWindow = g_ui.displayUI("result")

	self.resultWindow:setVisible(false)

	local resultWindow = self.resultWindow
	local descWidget = resultWindow:recursiveGetChildById("resultText")

	if descWidget then
		descWidget:setVisible(false)
	end

	local descWidget2 = resultWindow:recursiveGetChildById("resultText2")

	if descWidget2 then
		descWidget2:setVisible(false)
	end

	local bonusInfo

	if actionType == ACTION_FUSION_TYPE then
		bonusInfo = var_0_40(bonus, leftItemId, leftTier, coreCount, extraItemId, extraTier)
	end

	local closeWidget = resultWindow:getChildById("close")

	if closeWidget then
		closeWidget.pendingBonus = bonusInfo
		closeWidget.resultActionText = bonusInfo and "Next" or "Close"
	end

	setResultCloseLocked(closeWidget, true)

	function closeWidget.onClick(widget)
		if widget.pendingBonus then
			local pending = widget.pendingBonus

			widget.pendingBonus = nil

			Forge:showResultBonus(pending)

			return
		end

		if self.resultWindow then
			self.resultWindow:destroy()

			self.resultWindow = nil
		end

		g_game.sendResourceBalance()
		self:close()
	end

	local function beginResultAnimation(leftItem, leftWidget, rightItem, rightWidget, revealTier, resultText)
		scheduleEvent(function()
			self:ProcessFlash(leftItem, leftWidget, false, rightItem, rightWidget, descWidget, resultText, success, revealTier, closeWidget)
		end, 200)
		self.resultWindow:setVisible(true)
	end

	if actionType == ACTION_FUSION_TYPE then
		if convergence == 1 then
			resultWindow:setText("Convergence Fusion Result")
		else
			resultWindow:setText("Fusion Result")
		end

		local text = buildForgeResultText("Your fusion attempt was ", success)
		local rightItem = Item.create(rightItemId)
		local rightWidget = resultWindow:recursiveGetChildById("previewItem2")
		local leftWidget = resultWindow:recursiveGetChildById("previewItem1")
		local leftItem = Item.create(leftItemId)

		rightItem:setTier(rightTier)
		leftItem:setTier(leftTier)
		setupResultPreviewItem(rightWidget, rightItem)
		setupResultPreviewItem(leftWidget, leftItem)
		applyResultSilhouette(rightWidget, function()
			beginResultAnimation(leftItem, leftWidget, rightItem, rightWidget, nil, text)
		end)
	elseif actionType == ACTION_TRANSFER_TYPE then
		if convergence == 1 then
			resultWindow:setText("Convergence Tier Transfer Result")
		else
			resultWindow:setText("Tier Transfer Result")
		end

		local text = buildForgeResultText("Your transfer was ", success)
		local rightItem = Item.create(rightItemId)
		local rightWidget = resultWindow:recursiveGetChildById("previewItem2")

		rightItem:setTier(0)
		setupResultPreviewItem(rightWidget, rightItem, false)

		local leftWidget = resultWindow:recursiveGetChildById("previewItem1")
		local leftItem = Item.create(leftItemId)

		leftItem:setTier(leftTier)
		setupResultPreviewItem(leftWidget, leftItem, true)
		beginResultAnimation(leftItem, leftWidget, rightItem, rightWidget, resolveTransferRevealTier(success, convergence, leftTier, rightTier), text)
	end
end

function onOpenExaltationForge(data)
	Forge.preview = false
	Forge.dustLevel = data.dustLevel

	Forge:updateResources()

	if Conversion and Forge.data and Forge.data.config then
		Conversion:parseResourcesChange(Forge.data)
	end

	local fusionCount = data.fusionItems and #data.fusionItems or 0
	local transferCount = data.transfers and #data.transfers or 0
	local convergenceCount = data.convergenceTransfers and #data.convergenceTransfers or 0
	local incomingHasItems = fusionCount > 0 or transferCount > 0 or convergenceCount > 0
	local hadFusionItems = Fusion and Fusion.data and Fusion.data.fusionItems and #Fusion.data.fusionItems > 0
	local hadTransfers = Transfer and (Transfer.transfers and #Transfer.transfers > 0 or Transfer.convergenceTransfers and #Transfer.convergenceTransfers > 0)

	if not incomingHasItems and (hadFusionItems or hadTransfers) and not Forge.forceApplyNextOpenSnapshot then
		return
	end

	Fusion:parseData(data)
	Transfer:parseData(data)

	Forge.forceApplyNextOpenSnapshot = false
end

function onPlayerResourcesChange(data)
	Forge.data = data

	if data.config and data.config.maxDust ~= nil then
		Forge.dustLevel = data.config.maxDust
	end

	Forge:updateResources()
	Fusion:parseResourcesChange(data)
	Conversion:parseResourcesChange(data)
	Transfer:parseResourcesChange(data)
end

function onResultExaltationForge(data)
	local success

	if data.success == 1 then
		success = true
	end

	scheduleEvent(function()
		Forge.mainWindow:setVisible(false)
	end, 10)
	Forge:displayResult(data.actionType, data.convergence, success, data.leftItemId, data.rightItemId, data.leftTier, data.rightTier, data.bonus, data.coreCount, data.extraItemId, data.extraTier)

	if data.actionType == ACTION_FUSION_TYPE then
		Fusion:parseResult(data)

		return
	end

	if data.actionType == ACTION_TRANSFER_TYPE then
		Transfer:parseResult(data)
	end
end

function onForgeHistory(currentPage, lastPage, data)
	History:parse(currentPage, lastPage, data)
end

function terminate()
	Keybind.delete("Dialogs", "Open Exaltation Forge")
end
