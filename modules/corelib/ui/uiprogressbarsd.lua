UIProgressBarSD = extends(UIWidget, "UIProgressBarSD")

function UIProgressBarSD.create()
	local progressbar = UIProgressBarSD.internalCreate()

	progressbar:setFocusable(false)
	progressbar:setOn(true)

	progressbar.min = 0
	progressbar.max = 100
	progressbar.value = 0
	progressbar.bgBorderLeft = 0
	progressbar.bgBorderRight = 0
	progressbar.bgBorderTop = 0
	progressbar.bgBorderBottom = 0

	return progressbar
end

function UIProgressBarSD.setMinimum(self, minimum)
	self.minimum = minimum

	if minimum > self.value then
		self:setValue(minimum)
	end
end

function UIProgressBarSD.setMaximum(self, maximum)
	self.maximum = maximum

	if maximum < self.value then
		self:setValue(maximum)
	end
end

function UIProgressBarSD.setValue(self, value, minimum, maximum)
	if minimum then
		self:setMinimum(minimum)
	end

	if maximum then
		self:setMaximum(maximum)
	end

	self.value = math.max(math.min(value, self.maximum), self.minimum)

	self:updateBackground()
end

function UIProgressBarSD.setPercent(self, percent)
	self:setValue(percent, 0, 100)
end

function UIProgressBarSD.getPercent(self)
	return self.value
end

function UIProgressBarSD.getPercentPixels(self)
	return (self.maximum - self.minimum) / self:getWidth()
end

function UIProgressBarSD.getProgress(self)
	if self.minimum == self.maximum then
		return 1
	end

	return (self.value - self.minimum) / (self.maximum - self.minimum)
end

function UIProgressBarSD.updateBackground(self)
	if self:isOn() then
		local progress = self:getProgress()

		if self.vertical then
			local maxW = self:getHeight() - self.bgBorderTop - self.bgBorderBottom
			local width = self:getWidth() - self.bgBorderLeft - self.bgBorderRight

			if progress <= 0 or maxW <= 0 then
				self:setImageColor("alpha")

				return
			end

			self:setImageColor("white")

			local fillHeight = math.round(math.max(progress * maxW, 1))
			local bgBorderTop = self.bgBorderTop

			if not self.fillFromTop then
				bgBorderTop = self:getHeight() - self.bgBorderBottom - fillHeight
			end

			local rect = {
				x = self.bgBorderLeft,
				y = bgBorderTop,
				width = width,
				height = fillHeight
			}

			self:setImageRect(rect)

			return
		end

		local width = self:getWidth() - self.bgBorderLeft - self.bgBorderRight
		local height = self:getHeight() - self.bgBorderTop - self.bgBorderBottom

		if progress <= 0 or width <= 0 then
			self:setImageColor("alpha")

			return
		end

		self:setImageColor("white")

		local fillWidth = math.round(math.max(progress * width, 1))
		local fillRect = {
			x = self.bgBorderLeft,
			y = self.bgBorderTop,
			width = fillWidth,
			height = height
		}

		self:setImageRect(fillRect)
	end
end

function UIProgressBarSD.onSetup(self)
	self:updateBackground()
end

function UIProgressBarSD.onStyleApply(self, name, node)
	for name, value in pairs(node) do
		if name == "background-border-left" then
			self.bgBorderLeft = tonumber(value)
		elseif name == "background-border-right" then
			self.bgBorderRight = tonumber(value)
		elseif name == "background-border-top" then
			self.bgBorderTop = tonumber(value)
		elseif name == "background-border-bottom" then
			self.bgBorderBottom = tonumber(value)
		elseif name == "background-border" then
			self.bgBorderLeft = tonumber(value)
			self.bgBorderRight = tonumber(value)
			self.bgBorderTop = tonumber(value)
			self.bgBorderBottom = tonumber(value)
		elseif name == "percent" then
			self.percent = self:setPercent(tonumber(value))
		elseif name == "tooltip-delayed" then
			self.tooltipDelayed = value
		end
	end
end

function UIProgressBarSD.onGeometryChange(self, oldRect, newRect)
	if not self:isOn() then
		self:setHeight(0)
	end

	self:updateBackground()
end
