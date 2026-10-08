function string.split(self, delim)
	local start = 1
	local results = {}

	while true do
		local pos = string.find(self, delim, start, true)

		if not pos then
			break
		end

		table.insert(results, string.sub(self, start, pos - 1))

		start = pos + string.len(delim)
	end

	table.insert(results, string.sub(self, start))
	table.removevalue(results, "")

	return results
end

function string.starts(self, start)
	return string.sub(self, 1, #start) == start
end

function string.ends(self, test)
	return test == "" or string.sub(self, -string.len(test)) == test
end

function string.trim(self)
	return string.match(self, "^%s*(.*%S)") or ""
end

function string.explode(self, sep, limit)
	if type(sep) ~= "string" or tostring(self):len() == 0 or sep:len() == 0 then
		return {}
	end

	local i = 0
	local pos = 1
	local unusedValue = ""
	local t = {}

	for s, e in function()
		return string.find(self, sep, pos)
	end do
		local tmp = self:sub(pos, s - 1):trim()

		table.insert(t, tmp)

		pos = e + 1
		i = i + 1

		if limit ~= nil and i == limit then
			break
		end
	end

	local tmp = self:sub(pos):trim()

	table.insert(t, tmp)

	return t
end

function string.contains(self, str, checkCase, start, plain)
	if not checkCase then
		self = self:lower()
		str = str:lower()
	end

	return string.find(self, str, start and start or 1, plain == nil and true or false)
end

function string.wrap(self, width)
	local wrapped = ""
	local lineWidth = 0

	for word in self:gmatch("%S+") do
		local wordWidth = #word * 10

		if width < lineWidth + wordWidth then
			wrapped = wrapped .. "\n" .. word .. " "
			lineWidth = wordWidth + 1
		else
			wrapped = wrapped .. word .. " "
			lineWidth = lineWidth + wordWidth + 1
		end
	end

	return wrapped
end

function string.empty(str)
	return str == nil or str == "" or #str == 0
end

function string.searchEscape(str)
	return (str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

function string.capitalize(self)
	return string.gsub(self, "(%w)([%w]*)", function(firstLetter, restOfString)
		return string.upper(firstLetter) .. string.lower(restOfString)
	end)
end

function string.unpack_custom(format, data)
	local result = {}
	local index = 1
	local i = 1

	while i <= #format do
		local fmt = format:sub(i, i)
		local nextChar = format:sub(i + 1, i + 1)
		local specifier = fmt

		if nextChar:match("%d") then
			specifier = fmt .. nextChar
			i = i + 1
		end

		if specifier == "I1" then
			result[#result + 1] = string.byte(data, index)
			index = index + 1
		elseif specifier == "I2" then
			local b1, b2 = string.byte(data, index, index + 1)

			result[#result + 1] = b1 + b2 * 256
			index = index + 2
		elseif specifier == "I4" then
			local b1, b2, b3, b4 = string.byte(data, index, index + 3)

			result[#result + 1] = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
			index = index + 4
		else
			error("Invalid format specifier: " .. specifier)
		end

		i = i + 1
	end

	return unpack(result)
end

function string.pack_custom(format, ...)
	local args = {
		...
	}
	local result = {}
	local index = 1
	local i = 1

	while i <= #format do
		local fmt = format:sub(i, i)
		local nextChar = format:sub(i + 1, i + 1)
		local specifier = fmt

		if nextChar:match("%d") then
			specifier = fmt .. nextChar
			i = i + 1
		end

		local value = args[index] or 0

		if specifier == "I1" then
			if value < 0 or value > 255 then
				error("Value out of range for I1: " .. tostring(value))
			end

			table.insert(result, string.char(value))
		elseif specifier == "I2" then
			if value < 0 or value > 65535 then
				error("Value out of range for I2: " .. tostring(value))
			end

			table.insert(result, string.char(value % 256, math.floor(value / 256)))
		elseif specifier == "I4" then
			if value < 0 or value > 4294967295 then
				error("Value out of range for I4: " .. tostring(value))
			end

			table.insert(result, string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216)))
		else
			error("Invalid format specifier: " .. specifier)
		end

		index = index + 1
		i = i + 1
	end

	return table.concat(result)
end

function setStringColor(t, text, color)
	table.insert(t, text)
	table.insert(t, color)
end

function tableToColoredText(arg_16_0)
	if type(arg_16_0) ~= "table" then
		return arg_16_0 or ""
	end

	local var_16_0 = ""

	for iter_16_0 = 1, #arg_16_0, 2 do
		var_16_0 = var_16_0 .. "{" .. (arg_16_0[iter_16_0] or "") .. ", " .. (arg_16_0[iter_16_0 + 1] or "#ffffff") .. "}"
	end

	return var_16_0
end
