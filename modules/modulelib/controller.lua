local TypeEvent = {
	MODULE_INIT = 1,
	GAME_INIT = 2
}
local _setNextEventSource = g_dispatcher.setNextEventSource

local function tagControllerEventSource(controller, suffix)
	if not _setNextEventSource then
		return
	end

	_setNextEventSource(string.format("%s:%s", controller.name or "?", suffix))
end

local function onGameStart(self)
	if self.__onGameStart ~= nil then
		self.currentTypeEvent = TypeEvent.GAME_INIT

		tagControllerEventSource(self, "onGameStart")
		addEvent(function()
			self:__onGameStart()

			local eventList = self.events[TypeEvent.GAME_INIT]

			if eventList ~= nil then
				for _, event in pairs(eventList) do
					event:connect()
				end
			end
		end)
	end
end

local function onGameEnd(self)
	if self.__onGameEnd ~= nil then
		local ok, err = pcall(function()
			self:__onGameEnd()
		end)

		if not ok then
			g_logger.error(string.format("Controller '%s' onGameEnd failed: %s", tostring(self.name), tostring(err)))
		end
	end

	local eventList = self.events[TypeEvent.GAME_INIT]

	if eventList ~= nil then
		for _, event in pairs(eventList) do
			event:destroy()
		end

		self.events[TypeEvent.GAME_INIT] = nil
	end

	local scheduledEventsList = self.scheduledEvents[TypeEvent.GAME_INIT]

	if scheduledEventsList then
		for _, eventId in pairs(scheduledEventsList) do
			removeEvent(eventId)
		end

		self.scheduledEvents[TypeEvent.GAME_INIT] = nil
	end

	if self.dataUI ~= nil and self.dataUI.onGameStart and self.ui then
		self:destroyUI()
	end

	table.remove_if(self.keyboardEvents, function(i, event)
		local destroy = event.controllerEventType == TypeEvent.GAME_INIT

		if destroy then
			g_keyboard["unbind" .. event.name](event.args[1], event.args[2], event.args[3])
		end

		return destroy
	end)
end

Controller = {}

function Controller.new(self)
	local module = g_modules.getCurrentModule()
	local obj = {
		name = module and module:getName() or nil,
		currentTypeEvent = TypeEvent.MODULE_INIT,
		events = {},
		scheduledEvents = {},
		keyboardEvents = {},
		attrs = {},
		extendedOpcodes = {},
		opcodes = {}
	}

	setmetatable(obj, self)

	self.__index = self

	return obj
end

function Controller.init(self)
	if self.dataUI ~= nil then
		self:loadUI()
	end

	if self.onInit then
		self.currentTypeEvent = TypeEvent.MODULE_INIT

		self:onInit()
	end

	self.__onGameStart = self.onGameStart

	function self.onGameStart()
		onGameStart(self)
	end

	connect(g_game, {
		onGameStart = self.onGameStart
	})

	if g_game.isOnline() then
		self:onGameStart()
	end

	self.__onGameEnd = self.onGameEnd

	function self.onGameEnd()
		onGameEnd(self)
	end

	connect(g_game, {
		onGameEnd = self.onGameEnd
	})

	local eventList = self.events[TypeEvent.MODULE_INIT]

	if eventList then
		for _, event in pairs(eventList) do
			event:connect()
		end
	end
end

function Controller.destroyUI(self)
	if self.ui then
		self.ui:destroy()

		self.ui = nil
	end

	for type, events in pairs(self.events) do
		table.remove_if(events, function(i, event)
			local canRemove = event:actorIsDestroyed()

			if canRemove then
				event:destroy()
			end

			return canRemove
		end)
	end
end

function Controller.loadUI(self, name, parent)
	if self.ui then
		return
	end

	if not self.dataUI then
		self:setUI(name, parent)
	end

	self.ui = g_ui.loadUI("/" .. self.name .. "/" .. self.dataUI.name, self.dataUI.parent or g_ui.getRootWidget())
end

function Controller.setKeyboardAnchor(self, widget)
	self.keyboardAnchor = widget
end

function Controller.setUI(self, name, parent)
	self.dataUI = {
		name = name,
		parent = parent,
		onGameStart = self.currentTypeEvent == TypeEvent.GAME_INIT
	}
end

function Controller.terminate(self)
	if self.onGameStart then
		disconnect(g_game, {
			onGameStart = self.onGameStart
		})
	end

	if self.onGameEnd then
		if g_game.isOnline() then
			self:onGameEnd()
		end

		disconnect(g_game, {
			onGameEnd = self.onGameEnd
		})
	end

	if self.onTerminate then
		self:onTerminate()
	end

	for i, event in pairs(self.keyboardEvents) do
		g_keyboard["unbind" .. event.name](event.args[1], event.args[2], event.args[3])
	end

	for i, opcode in pairs(self.extendedOpcodes) do
		ProtocolGame.unregisterExtendedOpcode(opcode)
	end

	for _, opcode in ipairs(self.opcodes) do
		ProtocolGame.unregisterOpcode(opcode)
	end

	for type, events in pairs(self.events) do
		if events ~= nil then
			for _, event in pairs(events) do
				event:destroy()
			end
		end
	end

	for type, events in pairs(self.scheduledEvents) do
		if events ~= nil then
			for _, eventId in pairs(events) do
				removeEvent(eventId)
			end
		end
	end

	if self.ui ~= nil then
		self.ui:destroy()
	end

	self.ui = nil
	self.attrs = nil
	self.events = nil
	self.dataUI = nil
	self.extendedOpcodes = nil
	self.opcodes = nil
	self.keyboardEvents = nil
	self.keyboardAnchor = nil
	self.scheduledEvents = nil
	self.__onGameStart = nil
	self.__onGameEnd = nil
end

function Controller.registerEvents(self, actor, events)
	if self.events[self.currentTypeEvent] == nil then
		self.events[self.currentTypeEvent] = {}
	end

	local evt = EventController:new(actor, events)

	table.insert(self.events[self.currentTypeEvent], evt)

	return evt
end

function Controller.registerExtendedOpcode(self, opcode, fnc)
	ProtocolGame.registerExtendedOpcode(opcode, fnc)
	table.insert(self.extendedOpcodes, opcode)
end

function Controller.registerOpcode(self, opcode, fnc)
	ProtocolGame.registerOpcode(opcode, fnc)
	table.insert(self.opcodes, opcode)
end

function Controller.sendExtendedOpcode(self, opcode, ...)
	local protocol = g_game.getProtocolGame()

	if protocol then
		protocol:sendExtendedOpcode(opcode, ...)
	end
end

local function registerScheduledEvent(controller, fncRef, fnc, delay, name)
	local currentType = controller.currentTypeEvent

	if controller.scheduledEvents[currentType] == nil then
		controller.scheduledEvents[currentType] = {}
	end

	local function _rmvEvent()
		if controller.scheduledEvents[currentType][name] then
			removeEvent(controller.scheduledEvents[currentType][name])

			controller.scheduledEvents[currentType][name] = nil
		end
	end

	_rmvEvent()

	local evt

	local function action()
		fnc()

		if fncRef == scheduleEvent then
			if name then
				_rmvEvent()
			else
				table.removevalue(controller.scheduledEvents[currentType], evt)
			end
		end
	end

	evt = fncRef(action, delay)

	if name then
		controller.scheduledEvents[currentType][name] = evt
	else
		table.insert(controller.scheduledEvents[currentType], evt)
	end

	return evt
end

function Controller.scheduleEvent(self, fnc, delay, name)
	if name then
		tagControllerEventSource(self, "scheduleEvent:" .. name)
	else
		tagControllerEventSource(self, "scheduleEvent")
	end

	return registerScheduledEvent(self, scheduleEvent, fnc, delay, name)
end

function Controller.cycleEvent(self, fnc, delay, name)
	if name then
		tagControllerEventSource(self, "cycleEvent:" .. name)
	else
		tagControllerEventSource(self, "cycleEvent")
	end

	return registerScheduledEvent(self, cycleEvent, fnc, delay, name)
end

function Controller.removeEvent(self, evt)
	if self.scheduledEvents[TypeEvent.GAME_INIT] and table.removevalue(self.scheduledEvents[TypeEvent.GAME_INIT], evt) then
		removeEvent(evt)

		return
	end

	if self.scheduledEvents[TypeEvent.MODULE_INIT] and table.find(self.scheduledEvents[TypeEvent.MODULE_INIT], evt) then
		error("It is not possible to remove events registered at controller init.")

		return
	end

	error("The event was not registered by the controller.")
end

function Controller.bindKeyDown(self, ...)
	local args = {
		...
	}

	if args[3] == nil or type(args[3]) == "boolean" then
		args[4] = args[3]
		args[3] = self.keyboardAnchor
	end

	table.insert(self.keyboardEvents, {
		name = "KeyDown",
		args = args,
		controllerEventType = self.currentTypeEvent
	})
	g_keyboard.bindKeyDown(args[1], args[2], args[3], args[4])
end

function Controller.bindKeyUp(self, ...)
	local args = {
		...
	}

	if args[3] == nil or type(args[3]) == "boolean" then
		args[4] = args[3]
		args[3] = self.keyboardAnchor
	end

	table.insert(self.keyboardEvents, {
		name = "KeyUp",
		args = args,
		controllerEventType = self.currentTypeEvent
	})
	g_keyboard.bindKeyUp(args[1], args[2], args[3], args[4])
end

function Controller.bindKeyPress(self, ...)
	local args = {
		...
	}

	if args[3] == nil or type(args[3]) == "boolean" then
		args[4] = args[3]
		args[3] = self.keyboardAnchor
	end

	table.insert(self.keyboardEvents, {
		name = "KeyPress",
		args = args,
		controllerEventType = self.currentTypeEvent
	})
	g_keyboard.bindKeyPress(args[1], args[2], args[3])
end
