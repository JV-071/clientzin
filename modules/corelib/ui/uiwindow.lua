UIWindow = extends(UIWidget, "UIWindow")

local dragMoveInterval = 16

local function cancelPendingWindowDrag(window)
	removeEvent(window._windowDragMoveEvent)

	window._windowDragMoveEvent = nil
	window._windowDragPendingPosition = nil
end

local function applyWindowDragPosition(window, position)
	window:setPosition(position)
	window:bindRectToParent()

	window._windowLastDragMove = g_clock.millis()
end

function UIWindow.create()
	local window = UIWindow.internalCreate()

	window:setTextAlign(AlignTopCenter)
	window:setDraggable(true)
	window:setAutoFocusPolicy(AutoFocusFirst)

	window.dragMoveInterval = dragMoveInterval
	window.hotkeyBlock = false

	return window
end

function UIWindow.onKeyPress(self, keyCode, keyboardModifiers)
	if keyboardModifiers == KeyboardNoModifier then
		if g_keyboard.isEnterKey(keyCode) then
			signalcall(self.onEnter, self)
		elseif keyCode == KeyEscape then
			signalcall(self.onEscape, self)
		end
	end
end

function UIWindow.onFocusChange(self, focused)
	if focused then
		self:raise()
	end
end

function UIWindow.onDragEnter(self, mousePos)
	cancelPendingWindowDrag(self)

	self._windowLastDragMove = nil

	self:breakAnchors()

	self.movingReference = {
		x = mousePos.x - self:getX(),
		y = mousePos.y - self:getY()
	}

	return true
end

function UIWindow.onDragLeave(self, unusedArgument, mousePos)
	removeEvent(self._windowDragMoveEvent)

	self._windowDragMoveEvent = nil
	self._windowDragPendingPosition = nil

	if self.movingReference and mousePos and (mousePos.x ~= 0 or mousePos.y ~= 0) then
		applyWindowDragPosition(self, {
			x = mousePos.x - self.movingReference.x,
			y = mousePos.y - self.movingReference.y
		})
	end

	self.movingReference = nil
	self._windowLastDragMove = nil

	return true
end

function UIWindow.onDragMove(self, mousePos, unusedArgument)
	if not self.movingReference then
		return false
	end

	local _windowDragPendingPosition = {
		x = mousePos.x - self.movingReference.x,
		y = mousePos.y - self.movingReference.y
	}
	local moveInterval = self.dragMoveInterval or dragMoveInterval

	if moveInterval <= 0 then
		applyWindowDragPosition(self, _windowDragPendingPosition)

		return true
	end

	local now = g_clock.millis()
	local elapsedSinceMove = self._windowLastDragMove and now - self._windowLastDragMove or moveInterval

	if moveInterval <= elapsedSinceMove and not self._windowDragMoveEvent then
		self._windowDragPendingPosition = nil

		applyWindowDragPosition(self, _windowDragPendingPosition)

		return true
	end

	self._windowDragPendingPosition = _windowDragPendingPosition

	if not self._windowDragMoveEvent then
		self._windowDragMoveEvent = scheduleEvent(function()
			self._windowDragMoveEvent = nil

			if self:isDestroyed() or not self.movingReference then
				self._windowDragPendingPosition = nil

				return
			end

			local _windowDragPendingPosition = self._windowDragPendingPosition

			self._windowDragPendingPosition = nil

			if _windowDragPendingPosition then
				applyWindowDragPosition(self, _windowDragPendingPosition)
			end
		end, math.max(1, moveInterval - elapsedSinceMove))
	end

	return true
end

function UIWindow.onDestroy(self)
	cancelPendingWindowDrag(self)

	if self.hotkeyBlock then
		self.hotkeyBlock.release()

		self.hotkeyBlock = false
	end
end
