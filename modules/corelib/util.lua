function print(...)
	local msg = ""
	local args = {
		...
	}
	local appendSpace = #args > 1

	for i, v in ipairs(args) do
		msg = msg .. tostring(v)

		if appendSpace and i < #args then
			msg = msg .. "    "
		end
	end

	g_logger.log(LogInfo, msg)
end

function pinfo(msg)
	g_logger.log(LogInfo, msg)
end

function perror(msg)
	g_logger.log(LogError, msg)
end

function pwarning(msg)
	g_logger.log(LogWarning, msg)
end

function pdebug(msg)
	g_logger.log(LogDebug, msg)
end

function fatal(msg)
	g_logger.log(LogFatal, msg)
end

local formatTraceback = type(debug) == "table" and debug.traceback or tostring

function iscallable(callableValue)
	local callableType = type(callableValue)

	if callableType == "function" then
		return true
	end

	if callableType == "userdata" or callableType == "table" then
		local callableMetatable = getmetatable(callableValue)

		return callableMetatable ~= nil and callableMetatable.__call ~= nil
	end

	return false
end

function exit()
	g_app.exit()
end

function quit()
	g_app.quit()
end

function connect(object, arg1, arg2, arg3)
	if not object then
		return
	end

	local signalsAndSlots
	local pushFront

	if type(arg1) == "string" then
		signalsAndSlots = {
			[arg1] = arg2
		}
		pushFront = arg3
	else
		signalsAndSlots = arg1
		pushFront = arg2
	end

	for signal, slot in pairs(signalsAndSlots) do
		if not object[signal] then
			local mt = getmetatable(object)

			if mt and type(object) == "userdata" then
				object[signal] = function(...)
					return signalcall(mt[signal], ...)
				end
			end
		end

		if not object[signal] then
			object[signal] = slot
		elseif iscallable(object[signal]) then
			object[signal] = {
				object[signal]
			}
		end

		if not iscallable(slot) then
			perror(formatTraceback("unable to connect a non function value"))
		end

		if type(object[signal]) == "table" then
			if pushFront then
				table.insert(object[signal], 1, slot)
			else
				table.insert(object[signal], #object[signal] + 1, slot)
			end
		end
	end
end

function disconnect(object, arg1, arg2)
	local signalsAndSlots

	if type(arg1) == "string" then
		if arg2 == nil then
			object[arg1] = nil

			return
		end

		signalsAndSlots = {
			[arg1] = arg2
		}
	elseif type(arg1) == "table" then
		signalsAndSlots = arg1
	else
		perror(formatTraceback("unable to disconnect"))
	end

	for signal, slot in pairs(signalsAndSlots) do
		if not object[signal] then
			-- block empty
		elseif iscallable(object[signal]) then
			if object[signal] == slot then
				object[signal] = nil
			end
		elseif type(object[signal]) == "table" then
			for k, func in pairs(object[signal]) do
				if func == slot then
					table.remove(object[signal], k)

					if #object[signal] == 1 then
						object[signal] = object[signal][1]
					end

					break
				end
			end
		end
	end
end

function newclass(name)
	if not name then
		perror(formatTraceback("new class has no name."))
	end

	local class = {}

	function class.internalCreate()
		local instance = {}

		for k, v in pairs(class) do
			instance[k] = v
		end

		return instance
	end

	class.create = class.internalCreate
	class.__class = name

	function class.getClassName()
		return name
	end

	return class
end

function extends(base, name)
	if not name then
		perror(formatTraceback("extended class has no name."))
	end

	local derived = {}

	function derived.internalCreate()
		local instance = base.create()

		for k, v in pairs(derived) do
			instance[k] = v
		end

		return instance
	end

	derived.create = derived.internalCreate
	derived.__class = name

	function derived.getClassName()
		return name
	end

	return derived
end

function runinsandbox(func, ...)
	if type(func) == "string" then
		func, err = loadfile(resolvepath(func, 2))

		if not func then
			error(err)
		end
	end

	local env = {}
	local oldenv = getfenv(0)

	setmetatable(env, {
		__index = oldenv
	})
	setfenv(0, env)
	func(...)
	setfenv(0, oldenv)

	return env
end

function loadasmodule(name, file)
	file = file or resolvepath(name, 2)

	if package.loaded[name] then
		return package.loaded[name]
	end

	local env = runinsandbox(file)

	package.loaded[name] = env

	return env
end

local function module_loader(modname)
	local module = g_modules.getModule(modname)

	if not module then
		return "\n\tno module '" .. modname .. "'"
	end

	return function()
		if not module:load() then
			error("unable to load required module " .. modname)
		end

		return module:getSandbox()
	end
end

table.insert(package.loaders, 1, module_loader)

function import(table)
	assert(type(table) == "table")

	local env = getfenv(2)

	for k, v in pairs(table) do
		env[k] = v
	end
end

function formatFreeCapacity(freeCapacity)
	if freeCapacity > 99999 then
		return math.min(9999, math.floor(freeCapacity / 1000)) .. "k"
	end

	if freeCapacity > 999 then
		return math.floor(freeCapacity)
	end

	if freeCapacity > 99 then
		return math.floor(freeCapacity * 10) / 10
	end

	return freeCapacity
end

function export(what, key)
	if key ~= nil then
		_G[key] = what
	else
		for k, v in pairs(what) do
			_G[k] = v
		end
	end
end

function unexport(key)
	if type(key) == "table" then
		for _k, v in pairs(key) do
			_G[v] = nil
		end
	else
		_G[key] = nil
	end
end

function getfsrcpath(unusedArgument)
	local _lua_debug = _G.getCurrentSourcePath

	if _lua_debug == nil then
		return "/"
	end

	local info = _lua_debug(0)
	local path = info

	if type(info) == "string" and info ~= "" then
		for stackDepth = 1, 12 do
			local frameSourcePath = _lua_debug(stackDepth)

			if type(frameSourcePath) == "string" and frameSourcePath ~= "" and frameSourcePath ~= info then
				path = frameSourcePath

				break
			end
		end

		if path:sub(1, 1) ~= "/" then
			path = "/" .. path
		end

		return path
	end

	return "/"
end

function resolvepath(filePath, depth)
	if not filePath then
		return nil
	end

	depth = depth or 1

	if filePath then
		if filePath:sub(0, 1) ~= "/" then
			local basepath = getfsrcpath(depth + 1)

			if basepath:sub(#basepath) ~= "/" then
				basepath = basepath .. "/"
			end

			return basepath .. filePath
		else
			return filePath
		end
	else
		local basepath = getfsrcpath(depth + 1)

		if basepath:sub(#basepath) ~= "/" then
			basepath = basepath .. "/"
		end

		return basepath
	end
end

function toboolean(v)
	if type(v) == "string" then
		v = v:trim():lower()

		if v == "1" or v == "true" then
			return true
		end
	elseif type(v) == "number" then
		if v == 1 then
			return true
		end
	elseif type(v) == "boolean" then
		return v
	end

	return false
end

function fromboolean(boolean)
	if boolean then
		return "true"
	else
		return "false"
	end
end

function booleantonumber(boolean)
	if boolean then
		return 1
	else
		return 0
	end
end

function numbertoboolean(number)
	if number ~= 0 then
		return true
	else
		return false
	end
end

function protectedcall(func, ...)
	local status, ret = pcall(func, ...)

	if status then
		return ret
	end

	perror(ret)

	return false
end

function isWidgetAlive(w)
	if not w then
		return false
	end

	if type(w) ~= "userdata" then
		return false
	end

	if type(w.isDestroyed) ~= "function" then
		return false
	end

	return not w:isDestroyed()
end

function signalcall(param, ...)
	if iscallable(param) then
		local status, ret = pcall(param, ...)

		if status then
			return ret
		else
			perror(ret)
		end
	elseif type(param) == "table" then
		for k, v in pairs(param) do
			local status, ret = pcall(v, ...)

			if status then
				if ret then
					return true
				end
			else
				perror(ret)
			end
		end
	elseif param ~= nil then
		error("attempt to call a non function value")
	end

	return false
end

function tr(s, ...)
	return string.format(s, ...)
end

function getOppositeAnchor(anchor)
	if anchor == AnchorLeft then
		return AnchorRight
	elseif anchor == AnchorRight then
		return AnchorLeft
	elseif anchor == AnchorTop then
		return AnchorBottom
	elseif anchor == AnchorBottom then
		return AnchorTop
	elseif anchor == AnchorVerticalCenter then
		return AnchorHorizontalCenter
	elseif anchor == AnchorHorizontalCenter then
		return AnchorVerticalCenter
	end

	return anchor
end

function makesingleton(obj)
	local singleton = {}

	if obj.getClassName then
		for key, value in pairs(_G[obj:getClassName()]) do
			if iscallable(value) then
				local value = value

				singleton[key] = function(...)
					return value(obj, ...)
				end
			end
		end
	end

	return singleton
end

function dumpLevel(input, level)
	local indent = ""

	for i = 1, level do
		indent = indent .. "    "
	end

	if type(input) == "table" then
		local str = "{ \n"
		local lines = {}

		for k, v in pairs(input) do
			if type(k) ~= "number" then
				k = "\"" .. k .. "\""
			end

			if type(v) == "string" then
				v = "\"" .. v .. "\""
			end

			table.insert(lines, indent .. "    [" .. k .. "] = " .. dumpLevel(v, level + 1))
		end

		return str .. table.concat(lines, ",\n") .. "\n" .. indent .. "}"
	end

	return tostring(input)
end

function dump(input)
	return dumpLevel(input, 0)
end

function pdump(input)
	local dump_str = dump(input)

	print(dump_str)

	return dump_str
end

function tdump(title, input)
	local title_fill = ""

	for i = 1, title:len() do
		title_fill = title_fill .. "="
	end

	local header_str = (("\n====" .. title_fill .. "====\n") .. "=== " .. title .. " ===\n") .. "====" .. title_fill .. "====\n"
	local dump_str = dump(input)
	local footer_str = "\n====" .. title_fill .. "====\n"

	print(header_str .. dump_str .. footer_str)

	return dump_str
end

function io.content(path)
	return g_resources.readFileContents("/" .. path)
end

function pdumpWidgetId(widget, indent)
	indent = indent or ""

	local children = widget:getChildren()

	for i, child in ipairs(children) do
		local prefix = i == #children and "`-- " or "|-- "

		print(indent .. prefix .. child:getId())

		local newIndent = i == #children and indent .. "    " or indent .. "|   "

		pdumpWidgetId(child, newIndent)
	end
end

local combatNames = {
	[0] = "Physical",
	"Fire",
	"Earth",
	"Energy",
	"Ice",
	"Holy",
	"Death",
	"Healing",
	"Drowning",
	"Life Drain",
	"Mana Drain",
	"Agony"
}

function getCombatName(combatId)
	return combatNames[combatId] or "Unknown"
end
