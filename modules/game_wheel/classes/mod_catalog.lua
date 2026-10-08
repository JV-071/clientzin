ModCatalog = {}

local var_0_0 = {}

local function var_0_1(arg_1_0, arg_1_1)
	if not arg_1_0 or not arg_1_1 then
		return false
	end

	return arg_1_0:lower():find(arg_1_1:lower(), 1, true) ~= nil
end

function ModCatalog.getFragmentList()
	return var_0_0
end

function ModCatalog.getDataByBonus(arg_3_0, arg_3_1)
	for unusedValue, entry in pairs(var_0_0) do
		if arg_3_1 and entry.supreme and arg_3_0 == entry.modID or not arg_3_1 and not entry.supreme and arg_3_0 == entry.modID then
			return entry
		end
	end

	return nil
end

function ModCatalog.createFragments()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return true
	end

	local vocation = translateVocation(localPlayer:getVocation())

	var_0_0 = {}

	for iter_4_0 = 0, #FlatSupremeMods do
		local var_4_2 = FlatSupremeMods[iter_4_0]

		if not var_4_2 or iter_4_0 == 4 and vocation > 6 then
			-- block empty
		else
			var_4_2.modID = iter_4_0
			var_4_2.supreme = true

			table.insert(var_0_0, var_4_2)
		end
	end

	local var_4_3 = VocationSupremeMods[vocation]
	local var_4_4 = ({
		[8] = {
			fromID = 6,
			toID = 24
		},
		[7] = {
			fromID = 23,
			toID = 41
		},
		[5] = {
			fromID = 42,
			toID = 58
		},
		[6] = {
			fromID = 59,
			toID = 75
		},
		[9] = {
			fromID = 76,
			toID = 93
		}
	})[vocation]

	if var_4_4 then
		for iter_4_1 = var_4_4.fromID, var_4_4.toID do
			local var_4_5 = var_4_3[iter_4_1]

			if var_4_5 then
				var_4_5.modID = iter_4_1
				var_4_5.supreme = true

				table.insert(var_0_0, var_4_5)
			end
		end
	end

	for iter_4_2 = 0, #BasicMods do
		local var_4_6 = BasicMods[iter_4_2]

		if var_4_6 then
			var_4_6.modID = iter_4_2
			var_4_6.supreme = false

			table.insert(var_0_0, var_4_6)
		end
	end
end

function ModCatalog.buildModCache()
	local var_5_0 = {}
	local var_5_1 = {}

	for unusedValue, entry in pairs(var_0_0) do
		if entry.supreme then
			var_5_1[entry.modID] = entry
		else
			var_5_0[entry.modID] = entry
		end
	end

	return var_5_0, var_5_1
end

function ModCatalog.getEquippedGemBonus()
	local var_6_0 = {}
	local var_6_1 = {}

	local function var_6_2(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_0 ~= -1 then
			arg_7_1[tostring(arg_7_0)] = arg_7_2
		end
	end

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		local gemDataById = WheelGemState.getGemDataById(getEquipedGem)

		if gemDataById then
			var_6_2(gemDataById.lesserBonus, var_6_0, gemDataById.gemID)
			var_6_2(gemDataById.regularBonus, var_6_0, gemDataById.gemID)
			var_6_2(gemDataById.supremeBonus, var_6_1, gemDataById.gemID)
		end
	end

	return var_6_0, var_6_1
end

function ModCatalog.getSortList(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	local var_8_0 = {}
	local text = arg_8_0.text
	local var_8_2 = {
		["Grade III"] = 2,
		["Grade II"] = 1,
		["Grade IV"] = 3
	}

	for unusedValue, entry in pairs(var_0_0) do
		if arg_8_3 and not string.empty(arg_8_3) and not var_0_1(arg_8_3, entry.tooltip) then
			-- block empty
		else
			local textValue = tostring(entry.modID)
			local var_8_4

			if entry.supreme then
				var_8_4 = WheelOfDestiny.supremeModsUpgrade[entry.modID]
			else
				var_8_4 = WheelOfDestiny.basicModsUpgrade[entry.modID]
			end

			if text == "Basic Mods" and not entry.supreme then
				table.insert(var_8_0, entry)
			elseif text == "Supreme Mods" and entry.supreme then
				table.insert(var_8_0, entry)
			elseif text == "In-Vessel Mods" then
				if entry.supreme and arg_8_2[textValue] or not entry.supreme and arg_8_1[textValue] then
					table.insert(var_8_0, entry)
				end
			elseif text == "Grade I" then
				if not var_8_4 or var_8_4 < 1 then
					table.insert(var_8_0, entry)
				end
			elseif var_8_2[text] then
				local var_8_5 = var_8_2[text]

				if var_8_4 and var_8_4 == var_8_5 then
					table.insert(var_8_0, entry)
				end
			end
		end
	end

	return var_8_0
end

function ModCatalog.searchModifications(arg_9_0)
	local var_9_0 = {}

	for unusedValue, entry in pairs(var_0_0) do
		if var_0_1(arg_9_0, entry.tooltip) then
			table.insert(var_9_0, entry)
		end
	end

	return var_9_0
end

function ModCatalog.findModPageIndex(arg_10_0, arg_10_1, arg_10_2)
	arg_10_2 = arg_10_2 or 30

	for key, entry in pairs(var_0_0) do
		if arg_10_1 and entry.supreme and entry.modID == arg_10_0 or not arg_10_1 and not entry.supreme and entry.modID == arg_10_0 then
			return math.ceil(key / arg_10_2), (key - 1) % arg_10_2 + 1
		end
	end

	return nil, 0
end
