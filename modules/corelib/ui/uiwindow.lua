UIWindow = extends(UIWidget, "UIWindow")

local var_0_0 = 16

local function var_0_1(arg_1_0)
	removeEvent(arg_1_0._windowDragMoveEvent)

	arg_1_0._windowDragMoveEvent = nil
	arg_1_0._windowDragPendingPosition = nil
end

local function var_0_2(arg_2_0, arg_2_1)
	arg_2_0:setPosition(arg_2_1)
	arg_2_0:bindRectToParent()

	arg_2_0._windowLastDragMove = g_clock.millis()
end

function UIWindow.create()
	local window = UIWindow.internalCreate()

	window:setTextAlign(AlignTopCenter)
	window:setDraggable(true)
	window:setAutoFocusPolicy(AutoFocusFirst)

	window.dragMoveInterval = var_0_0
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
	var_0_1(self)

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
		var_0_2(self, {
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

	local var_8_0 = {
		x = mousePos.x - self.movingReference.x,
		y = mousePos.y - self.movingReference.y
	}
	local var_8_1 = self.dragMoveInterval or var_0_0

	if var_8_1 <= 0 then
		var_0_2(self, var_8_0)

		return true
	end

	local var_8_2 = g_clock.millis()
	local var_8_3 = self._windowLastDragMove and var_8_2 - self._windowLastDragMove or var_8_1

	if var_8_1 <= var_8_3 and not self._windowDragMoveEvent then
		self._windowDragPendingPosition = nil

		var_0_2(self, var_8_0)

		return true
	end

	self._windowDragPendingPosition = var_8_0

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
				var_0_2(self, _windowDragPendingPosition)
			end
		end, math.max(1, var_8_1 - var_8_3))
	end

	return true
end

function UIWindow.onDestroy(self)
	var_0_1(self)

	if self.hotkeyBlock then
		self.hotkeyBlock.release()

		self.hotkeyBlock = false
	end
end
