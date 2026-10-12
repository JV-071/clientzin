ModCatalog = {}

local fragmentList = {}

local function containsCaseInsensitive(text, searchText)
	if not text or not searchText then
		return false
	end

	return text:lower():find(searchText:lower(), 1, true) ~= nil
end

function ModCatalog.getFragmentList()
	return fragmentList
end

function ModCatalog.getDataByBonus(bonusId, isSupreme)
	for unusedValue, entry in pairs(fragmentList) do
		if isSupreme and entry.supreme and bonusId == entry.modID or not isSupreme and not entry.supreme and bonusId == entry.modID then
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

	fragmentList = {}

	for modID = 0, #FlatSupremeMods do
		local flatSupremeMod = FlatSupremeMods[modID]

		if not flatSupremeMod or modID == 4 and vocation > 6 then
			-- block empty
		else
			flatSupremeMod.modID = modID
			flatSupremeMod.supreme = true

			table.insert(fragmentList, flatSupremeMod)
		end
	end

	local vocationSupremeMods = VocationSupremeMods[vocation]
	local vocationModRange = ({
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

	if vocationModRange then
		for modID = vocationModRange.fromID, vocationModRange.toID do
			local vocationSupremeMod = vocationSupremeMods[modID]

			if vocationSupremeMod then
				vocationSupremeMod.modID = modID
				vocationSupremeMod.supreme = true

				table.insert(fragmentList, vocationSupremeMod)
			end
		end
	end

	for modID = 0, #BasicMods do
		local basicMod = BasicMods[modID]

		if basicMod then
			basicMod.modID = modID
			basicMod.supreme = false

			table.insert(fragmentList, basicMod)
		end
	end
end

function ModCatalog.buildModCache()
	local basicModsById = {}
	local supremeModsById = {}

	for unusedValue, entry in pairs(fragmentList) do
		if entry.supreme then
			supremeModsById[entry.modID] = entry
		else
			basicModsById[entry.modID] = entry
		end
	end

	return basicModsById, supremeModsById
end

function ModCatalog.getEquippedGemBonus()
	local equippedBasicBonusGems = {}
	local equippedSupremeBonusGems = {}

	local function recordEquippedBonus(bonusId, bonusGemMap, gemId)
		if bonusId ~= -1 then
			bonusGemMap[tostring(bonusId)] = gemId
		end
	end

	for unusedValue, getEquipedGem in pairs(WheelGemState.getEquipedGems()) do
		local gemDataById = WheelGemState.getGemDataById(getEquipedGem)

		if gemDataById then
			recordEquippedBonus(gemDataById.lesserBonus, equippedBasicBonusGems, gemDataById.gemID)
			recordEquippedBonus(gemDataById.regularBonus, equippedBasicBonusGems, gemDataById.gemID)
			recordEquippedBonus(gemDataById.supremeBonus, equippedSupremeBonusGems, gemDataById.gemID)
		end
	end

	return equippedBasicBonusGems, equippedSupremeBonusGems
end

function ModCatalog.getSortList(sortOption, equippedBasic, equippedSupreme, searchText)
	local filteredMods = {}
	local text = sortOption.text
	local upgradeLevelByGrade = {
		["Grade III"] = 2,
		["Grade II"] = 1,
		["Grade IV"] = 3
	}

	for unusedValue, entry in pairs(fragmentList) do
		if searchText and not string.empty(searchText) and not containsCaseInsensitive(entry.tooltip, searchText) then
			-- block empty
		else
			local textValue = tostring(entry.modID)
			local upgradeLevel

			if entry.supreme then
				upgradeLevel = WheelOfDestiny.supremeModsUpgrade[entry.modID]
			else
				upgradeLevel = WheelOfDestiny.basicModsUpgrade[entry.modID]
			end

			if text == "Basic Mods" and not entry.supreme then
				table.insert(filteredMods, entry)
			elseif text == "Supreme Mods" and entry.supreme then
				table.insert(filteredMods, entry)
			elseif text == "In-Vessel Mods" then
				if entry.supreme and equippedSupreme[textValue] or not entry.supreme and equippedBasic[textValue] then
					table.insert(filteredMods, entry)
				end
			elseif text == "Grade I" then
				if not upgradeLevel or upgradeLevel < 1 then
					table.insert(filteredMods, entry)
				end
			elseif upgradeLevelByGrade[text] then
				local requiredUpgradeLevel = upgradeLevelByGrade[text]

				if upgradeLevel and upgradeLevel == requiredUpgradeLevel then
					table.insert(filteredMods, entry)
				end
			end
		end
	end

	return filteredMods
end

function ModCatalog.searchModifications(searchText)
	local matchingMods = {}

	for unusedValue, entry in pairs(fragmentList) do
		if containsCaseInsensitive(entry.tooltip, searchText) then
			table.insert(matchingMods, entry)
		end
	end

	return matchingMods
end

function ModCatalog.findModPageIndex(bonusId, isSupreme, pageSize)
	pageSize = pageSize or 30

	for key, entry in pairs(fragmentList) do
		if isSupreme and entry.supreme and entry.modID == bonusId or not isSupreme and not entry.supreme and entry.modID == bonusId then
			return math.ceil(key / pageSize), (key - 1) % pageSize + 1
		end
	end

	return nil, 0
end
