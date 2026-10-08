UIComboBox = extends(UIWidget, "UIComboBox")

function UIComboBox.create()
	local combobox = UIComboBox.internalCreate()

	combobox:setFocusable(false)

	combobox.options = {}
	combobox.currentIndex = -1
	combobox.mouseScroll = true
	combobox.menuScroll = false
	combobox.menuHeight = 100
	combobox.menuScrollStep = 0

	return combobox
end

function UIComboBox.clear(self)
	return self:clearOptions()
end

function UIComboBox.clearOptions(self)
	self.options = {}
	self.currentIndex = -1

	self:clearText()
end

function UIComboBox.isOption(self, text)
	if not self.options then
		return false
	end

	for i, v in ipairs(self.options) do
		if v.text == text then
			return true
		end
	end

	return false
end

function UIComboBox.setOption(self, text, dontSignal)
	self:setCurrentOption(text, dontSignal)
end

function UIComboBox.setCurrentOption(self, text, dontSignal)
	if not self.options then
		return
	end

	for i, v in ipairs(self.options) do
		if v.text == text and self.currentIndex ~= i then
			self.currentIndex = i

			self:setText(text)

			if not dontSignal then
				signalcall(self.onOptionChange, self, text, v.data)
			end

			return
		end
	end
end

function UIComboBox.getOptionsCount(self)
	return #self.options
end

function UIComboBox.setCurrentOptionByData(self, data, dontSignal)
	if not self.options then
		return
	end

	for i, v in ipairs(self.options) do
		if v.data == data and self.currentIndex ~= i then
			self.currentIndex = i

			self:setText(v.text)

			if not dontSignal then
				signalcall(self.onOptionChange, self, v.text, v.data)
			end

			return
		end
	end
end

function UIComboBox.setCurrentIndex(self, index)
	if index >= 1 and index <= #self.options then
		local v = self.options[index]

		self.currentIndex = index

		self:setText(v.text)
		signalcall(self.onOptionChange, self, v.text, v.data)
	end
end

function UIComboBox.getCurrentOption(self)
	if table.haskey(self.options, self.currentIndex) then
		return self.options[self.currentIndex]
	end
end

function UIComboBox.addOption(self, text, data)
	table.insert(self.options, {
		text = text,
		data = data
	})

	local index = #self.options

	if index == 1 then
		self:setCurrentOption(text)
	end

	return index
end

function UIComboBox.removeOption(self, text)
	for i, v in ipairs(self.options) do
		if v.text == text then
			table.remove(self.options, i)

			if self.currentIndex == i then
				self:setCurrentIndex(1)
			elseif i < self.currentIndex then
				self.currentIndex = self.currentIndex - 1
			end

			return
		end
	end
end

function UIComboBox.onMousePress(self, mousePos, mouseButton)
	local menu

	if self.menuScroll then
		menu = g_ui.createWidget(self:getStyleName() .. "PopupScrollMenu")

		menu:setHeight(self.menuHeight)

		if self.menuScrollStep > 0 then
			menu:setScrollbarStep(self.menuScrollStep)
		end
	else
		menu = g_ui.createWidget(self:getStyleName() .. "PopupMenu")
	end

	menu:setId(self:getId() .. "PopupMenu")

	for i, v in ipairs(self.options) do
		menu:addOption(v.text, function()
			self:setCurrentOption(v.text)
		end)
	end

	menu:setWidth(self:getWidth())
	menu:display({
		x = self:getX(),
		y = self:getY() + self:getHeight()
	})
	connect(menu, {
		onDestroy = function()
			self:setOn(false)
		end
	})
	self:setOn(true)

	return true
end

function UIComboBox.onMouseWheel(self, mousePos, direction)
	if not self.mouseScroll then
		return false
	end

	if direction == MouseWheelUp and self.currentIndex > 1 then
		self:setCurrentIndex(self.currentIndex - 1)
	elseif direction == MouseWheelDown and self.currentIndex < #self.options then
		self:setCurrentIndex(self.currentIndex + 1)
	end

	return true
end

function UIComboBox.onStyleApply(self, styleName, styleNode)
	if styleNode.options then
		for k, option in pairs(styleNode.options) do
			self:addOption(option)
		end
	end

	if styleNode.data then
		for k, data in pairs(styleNode.data) do
			local option = self.options[k]

			if option then
				option.data = data
			end
		end
	end

	for name, value in pairs(styleNode) do
		if name == "mouse-scroll" then
			self.mouseScroll = value
		elseif name == "menu-scroll" then
			self.menuScroll = value
		elseif name == "menu-height" then
			self.menuHeight = value
		elseif name == "menu-scroll-step" then
			self.menuScrollStep = value
		end
	end
end

function UIComboBox.setMouseScroll(self, scroll)
	self.mouseScroll = scroll
end

function UIComboBox.canMouseScroll(self)
	return self.mouseScroll
end

function UIComboBox.getCurrentIndex(self)
	return self.currentIndex
end

function UIComboBox.updateCurrentOption(self, newText)
	self.options[self.currentIndex].text = newText

	self:setText(newText)
end
