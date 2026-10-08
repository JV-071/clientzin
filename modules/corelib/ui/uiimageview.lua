UIImageView = extends(UIWidget, "UIImageView")

function UIImageView.create()
	local imageView = UIImageView.internalCreate()

	imageView.zoom = 1
	imageView.minZoom = math.pow(10, -2)
	imageView.maxZoom = math.pow(10, 2)

	imageView:setClipping(true)

	return imageView
end

function UIImageView.getDefaultZoom(self)
	local width = self:getWidth()
	local height = self:getHeight()
	local textureWidth = self:getImageTextureWidth()
	local textureHeight = self:getImageTextureHeight()
	local zoomX = width / textureWidth
	local zoomY = height / textureHeight

	return math.min(zoomX, zoomY)
end

function UIImageView.getImagePosition(self, x, y)
	x = x or self:getWidth() / 2
	y = y or self:getHeight() / 2

	local offsetX = self:getImageOffsetX()
	local offsetY = self:getImageOffsetY()
	local posX = (x - offsetX) / self.zoom
	local posY = (y - offsetY) / self.zoom

	return posX, posY
end

function UIImageView.setImage(self, image)
	self:setImageSource(image)

	local zoom = self:getDefaultZoom()

	self:setZoom(zoom)
	self:center()
end

function UIImageView.setZoom(self, zoom, x, y)
	zoom = math.max(math.min(zoom, self.maxZoom), self.minZoom)

	local posX, posY = self:getImagePosition(x, y)
	local textureWidth = self:getImageTextureWidth()
	local textureHeight = self:getImageTextureHeight()
	local imageWidth = textureWidth * zoom
	local imageHeight = textureHeight * zoom

	self:setImageWidth(imageWidth)
	self:setImageHeight(imageHeight)

	self.zoom = zoom

	self:move(posX, posY, x, y)
end

function UIImageView.zoomIn(self, x, y)
	local zoom = self.zoom * 1.1

	self:setZoom(zoom, x, y)
end

function UIImageView.zoomOut(self, x, y)
	local zoom = self.zoom / 1.1

	self:setZoom(zoom, x, y)
end

function UIImageView.center(self)
	self:move(self:getImageTextureWidth() / 2, self:getImageTextureHeight() / 2)
end

function UIImageView.clampImageOffset(self, offsetX, offsetY)
	local viewportWidth = self:getWidth()
	local viewportHeight = self:getHeight()
	local imageWidth = self:getImageWidth()
	local imageHeight = self:getImageHeight()

	if imageWidth <= viewportWidth then
		if self.alignRight then
			offsetX = viewportWidth - imageWidth
		else
			offsetX = (viewportWidth - imageWidth) / 2
		end
	else
		local minOffsetX = viewportWidth - imageWidth

		offsetX = math.min(0, math.max(minOffsetX, offsetX))
	end

	if imageHeight <= viewportHeight then
		if self.alignBottom then
			offsetY = viewportHeight - imageHeight
		else
			offsetY = (viewportHeight - imageHeight) / 2
		end
	else
		local minOffsetY = viewportHeight - imageHeight

		offsetY = math.min(0, math.max(minOffsetY, offsetY))
	end

	return offsetX, offsetY
end

function UIImageView.move(self, x, y, centerX, centerY)
	local textureWidth = self:getImageTextureWidth()
	local textureHeight = self:getImageTextureHeight()

	if textureWidth <= 0 or textureHeight <= 0 then
		return
	end

	x = math.max(math.min(x, textureWidth), 0)
	y = math.max(math.min(y, textureHeight), 0)
	centerX = centerX or self:getWidth() / 2
	centerY = centerY or self:getHeight() / 2

	local offsetX = centerX - x * self.zoom
	local offsetY = centerY - y * self.zoom
	local clampedOffsetX, clampedOffsetY = self:clampImageOffset(offsetX, offsetY)

	self:setImageOffset({
		x = clampedOffsetX,
		y = clampedOffsetY
	})
end

function UIImageView.onDragEnter(self, pos)
	return true
end

function UIImageView.onDragMove(self, pos, moved)
	local posX, posY = self:getImagePosition()

	self:move(posX - moved.x / self.zoom, posY - moved.y / self.zoom)

	return true
end

function UIImageView.onDragLeave(self, widget, pos)
	return true
end

function UIImageView.onMouseWheel(self, mousePos, direction)
	local x = mousePos.x - self:getX()
	local y = mousePos.y - self:getY()

	if direction == MouseWheelUp then
		self:zoomIn(x, y)
	elseif direction == MouseWheelDown then
		self:zoomOut(x, y)
	end
end
