HelperTarget = HelperTarget or {}

local ctx
local targetAssignWindow
local targetMonstersPanel
local editingPriorityListIndex
local priorityList = {}
local var_0_5
local monsterCache
local allCreaturesEnabled = false
local var_0_8
local openTargetAssignWindowInternal
local targetActionButtonsState
local ALL_CREATURES_ICON = "/images/icons_big/icon-arbitrarymonster64x64"
local spectators = {}
local spectatorMeta = {}
local spectatorAgeCounter = 0
local combatTimer = false
local var_0_16 = 0
local COMBAT_TICK_MS = 150
local TARGET_INTERVAL_MS = 250
local autoTargetOnHold = false
local currentLockedTargetId = 0
local lastTargetAttackId = 0
local lastTargetAttackAt = 0
local suppressTargetCheckChange = false
local suppressTargetSettingsChange = false
local TARGET_SWITCH_DELAY_MS = 700
local TARGET_MODE_STAND = "stand"
local TARGET_MODE_CHASE = "chase"
local targetAttackMode = TARGET_MODE_STAND
local TARGET_OPERATING_MODE_DEFAULT = "F"
local TARGET_OPERATING_MODES = {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I"
}
local targetOperatingMode = TARGET_OPERATING_MODE_DEFAULT
local TARGET_PZ_AUTO_ENABLED = "enabled"
local TARGET_PZ_AUTO_DISABLED = "disabled"
local targetPzAuto = TARGET_PZ_AUTO_ENABLED
local targetEnabledBeforePz = false
local wasInProtectionZone = false
local var_0_37 = "en"
local TARGET_TEXT = {
	en = {
		targetListHelp = "The order of entries in the list is the primary targeting priority. Entries at the top are preferred first.<br><br><li>Right-click an entry to change its order.</li><li>Uncheck an entry to temporarily disable it without removing it.</li>",
		enabled = "Enabled",
		pzBlocked = "Target cannot be enabled inside a protection zone.",
		targetList = "Target List",
		disabled = "Disabled",
		remove = "Remove",
		edit = "Edit",
		moveDown = "Move Down",
		add = "Add",
		moveUp = "Move Up",
		pzAuto = "PZ Auto:",
		allCreatures = "All Creatures",
		priority = "Priority:",
		name = "Name",
		distance = "Distance:",
		creature = "Creature",
		mode = "Mode:",
		enableTarget = "Enable Target",
		targetSettings = "Target Settings",
		chase = "Chase",
		stand = "Stand",
		targetSettingsHelp = "Settings applied when auto-targeting is enabled:<br><li>Mode: Stand attacks in place; Chase follows the target.</li><li>Distance: maximum distance in tiles for a creature to be targeted.</li><li>Priority: selects the operating mode used among creatures with the same list priority.</li><li>PZ Auto enabled: pauses auto-target inside a protection zone and restores it after leaving.</li><li>PZ Auto disabled: turns auto-target off in a protection zone. It stays off after leaving and cannot be enabled while you are inside.</li>",
		operatingModes = {
			H = "Farthest, then Lowest Health",
			G = "Closest, then Highest Health",
			E = "Best Grouped Target (AOE/Runes)",
			D = "Highest Health",
			C = "Lowest Health",
			B = "Farthest Monster",
			A = "Closest Monster",
			F = "Closest, then Lowest Health",
			I = "Farthest, then Highest Health"
		},
		operatingModeOptions = {
			H = "Farthest + Lowest Life",
			G = "Closest + Highest Life",
			E = "Best Grouped (AOE)",
			D = "Highest Life",
			C = "Lowest Life",
			B = "Farthest",
			A = "Closest",
			F = "Closest + Lowest Life",
			I = "Farthest + Highest Life"
		}
	},
	pt = {
		targetListHelp = "A ordem da lista e a prioridade principal do Target. As entradas do topo sao escolhidas primeiro.<br><br><li>Clique com o botao direito para mudar a ordem.</li><li>Desmarque uma entrada para desativa-la sem remove-la.</li>",
		enabled = "Ativado",
		pzBlocked = "O Target nao pode ser ativado dentro de uma protection zone.",
		targetList = "Lista de Alvos",
		disabled = "Desativado",
		remove = "Remover",
		edit = "Editar",
		moveDown = "Mover para Baixo",
		add = "Adicionar",
		moveUp = "Mover para Cima",
		pzAuto = "PZ Auto:",
		allCreatures = "Todas as Criaturas",
		priority = "Prioridade:",
		name = "Nome",
		distance = "Distancia:",
		creature = "Criatura",
		mode = "Modo:",
		enableTarget = "Ativar Target",
		targetSettings = "Configuracoes do Target",
		chase = "Perseguir",
		stand = "Parado",
		targetSettingsHelp = "Configuracoes usadas pelo auto-target:<br><li>Modo: Parado ataca no lugar; Perseguir segue o alvo.</li><li>Distancia: distancia maxima em tiles para selecionar uma criatura.</li><li>Prioridade: escolhe o modo operante entre criaturas com a mesma prioridade na lista.</li><li>PZ Auto ativado: pausa o auto-target dentro de uma protection zone e restaura ao sair.</li><li>PZ Auto desativado: desliga o auto-target dentro de uma protection zone. Ele permanece desligado ao sair e nao pode ser ativado enquanto voce estiver nela.</li>",
		operatingModes = {
			H = "Mais Distante, depois Menor Vida",
			G = "Mais Proximo, depois Maior Vida",
			E = "Melhor Alvo Agrupado (AOE/Runas)",
			D = "Maior Vida",
			C = "Menor Vida",
			B = "Monstro Mais Distante",
			A = "Monstro Mais Proximo",
			F = "Mais Proximo, depois Menor Vida",
			I = "Mais Distante, depois Maior Vida"
		},
		operatingModeOptions = {
			H = "Distante + Menor Vida",
			G = "Proximo + Maior Vida",
			E = "Melhor Grupo (AOE)",
			D = "Maior Vida",
			C = "Menor Vida",
			B = "Mais Distante",
			A = "Mais Proximo",
			F = "Proximo + Menor Vida",
			I = "Distante + Maior Vida"
		}
	}
}
local familiarNames = {
	["knight familiar"] = true,
	["druid familiar"] = true,
	["sorcerer familiar"] = true,
	["paladin familiar"] = true,
	["monk familiar"] = true
}
local ZEBRA_COLOR_A = "#484848"
local ZEBRA_COLOR_B = "#414141"

local function widget(id)
	return ctx and ctx.getWidget(id)
end

local function normalizeTargetLanguage(language)
	return language == "pt" and "pt" or "en"
end

local function targetText(key)
	return (TARGET_TEXT[var_0_37] or TARGET_TEXT.en)[key] or TARGET_TEXT.en[key] or key
end

local function operatingModeText(mode)
	local selected = TARGET_TEXT[var_0_37] or TARGET_TEXT.en

	return selected.operatingModes and selected.operatingModes[mode] or TARGET_TEXT.en.operatingModes[mode] or mode
end

local function operatingModeOptionText(mode)
	local selected = TARGET_TEXT[var_0_37] or TARGET_TEXT.en

	return selected.operatingModeOptions and selected.operatingModeOptions[mode] or TARGET_TEXT.en.operatingModeOptions[mode] or operatingModeText(mode)
end

local function nowMs()
	if g_clock and g_clock.millis then
		return g_clock.millis()
	end

	return math.floor((os.clock() or 0) * 1000)
end

local function saveConfigIfReady()
	if ctx and ctx.isLoadingConfig and ctx.isLoadingConfig() then
		return
	end

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

local function normalizeRaceId(raceId)
	if raceId == nil then
		return nil
	end

	return tonumber(raceId)
end

local function getDistanceBetween()
	var_0_5 = nil
end

local function var_0_51(p1, p2)
	if not p1 or not p2 or p1.x == nil or p2.x == nil then
		return 99
	end

	return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
end

local function isMapCreature(creature)
	if not creature then
		return false
	end

	local creatureType = type(creature)

	if creatureType ~= "userdata" and creatureType ~= "table" then
		return false
	end

	return type(creature.isDead) == "function" and type(creature.getPosition) == "function"
end

local function isFamiliar(creature)
	if not creature or not creature.getName then
		return nil
	end

	local id = creature.getId and creature:getId() or nil
	local var_12_1 = id and spectatorMeta[id] or nil

	if var_12_1 and var_12_1.nameLower then
		return var_12_1.nameLower
	end

	local name = creature:getName()
	local nameLower = name and name ~= "" and name:lower() or nil

	if var_12_1 then
		var_12_1.nameLower = nameLower
	end

	return nameLower
end

local function var_0_54(arg_13_0)
	local var_13_0 = isFamiliar(arg_13_0)

	return var_13_0 and familiarNames[var_13_0] == true or false
end

local function var_0_55(arg_14_0)
	if not arg_14_0 or not arg_14_0.getMasterId then
		return false
	end

	local masterId = tonumber(arg_14_0:getMasterId()) or 0

	if masterId <= 0 then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if localPlayer and masterId == localPlayer:getId() then
		return true
	end

	local var_14_2 = modules and modules.game_party or nil
	local var_14_3 = var_14_2 and var_14_2.PartyListRegistry or nil

	if var_14_3 and type(var_14_3.byId) == "table" and var_14_3.byId[masterId] then
		return true
	end

	local creatureById = g_map.getCreatureById(masterId)

	if not creatureById then
		return false
	end

	if CreatureList and CreatureList.isRemotePartyMember then
		return CreatureList.isRemotePartyMember(creatureById)
	end

	return creatureById.isPartyMember and creatureById:isPartyMember() or false
end

local function var_0_56(arg_15_0)
	return var_0_54(arg_15_0) or var_0_55(arg_15_0)
end

local function isWithinReach(playerPos, targetPos)
	if not playerPos or not targetPos or playerPos.x == nil or targetPos.x == nil then
		return false
	end

	local deltaX = math.abs(playerPos.x - targetPos.x)
	local deltaY = math.abs(playerPos.y - targetPos.y)

	return deltaX <= 7 and deltaY <= 5 and playerPos.z == targetPos.z
end

local function readDistanceRange()
	if ctx and ctx.readDistanceValue then
		return 0, ctx.readDistanceValue("targetDistanceCombo")
	end

	return 0, 7
end

local function normalizeTargetMode(mode)
	if type(mode) == "string" then
		local value = mode:lower()

		if value == TARGET_MODE_CHASE or value == "perseguir" then
			return TARGET_MODE_CHASE
		end
	end

	return TARGET_MODE_STAND
end

local function readComboOptionValue(combo, fallback)
	if not combo or not combo.getCurrentOption then
		return fallback
	end

	local current = combo:getCurrentOption()

	if type(current) == "table" then
		return current.data or current.text or fallback
	end

	return current or fallback
end

local function readTargetModeWidget()
	local combo = widget("targetModeCombo")

	if not combo or not combo.getCurrentOption then
		return targetAttackMode
	end

	return normalizeTargetMode(readComboOptionValue(combo, targetAttackMode))
end

local function applyTargetModeWidget(mode)
	local combo = widget("targetModeCombo")

	if not combo or not combo.setCurrentOption then
		return
	end

	mode = normalizeTargetMode(mode)

	if combo.setCurrentOptionByData then
		combo:setCurrentOptionByData(mode, true)
	else
		combo:setCurrentOption(mode == TARGET_MODE_CHASE and targetText("chase") or targetText("stand"), true)
	end
end

local function normalizeTargetOperatingMode(mode)
	local value = tostring(mode or TARGET_OPERATING_MODE_DEFAULT):upper()

	if not value:match("^[A-I]$") then
		return TARGET_OPERATING_MODE_DEFAULT
	end

	return value
end

local function compactLegacyValue(value)
	return tostring(value or ""):lower():gsub("%s+", "")
end

local function operatingModeFromLegacyConfig(data)
	if type(data) ~= "table" then
		return TARGET_OPERATING_MODE_DEFAULT
	end

	if data.priorityOrder == nil and data.prioritySort == nil and data.prioritySecondary == nil then
		return TARGET_OPERATING_MODE_DEFAULT
	end

	local order = compactLegacyValue(data.priorityOrder)
	local sortBy = compactLegacyValue(data.prioritySort)
	local secondary = compactLegacyValue(data.prioritySecondary)

	if order == "besttarget" or sortBy == "besttarget" or sortBy == "displaytime" then
		return "E"
	end

	local ascending = order == "ascending"

	if sortBy == "distance" then
		if secondary == "lowhealth" then
			return ascending and "F" or "H"
		end

		if secondary == "highhealth" then
			return ascending and "G" or "I"
		end

		return ascending and "A" or "B"
	end

	return ascending and "C" or "D"
end

local function readTargetOperatingModeWidget()
	return normalizeTargetOperatingMode(readComboOptionValue(widget("targetOperatingModeCombo"), targetOperatingMode))
end

local function applyTargetOperatingModeWidget(mode)
	local combo = widget("targetOperatingModeCombo")

	if not combo or not combo.setCurrentOption then
		return
	end

	mode = normalizeTargetOperatingMode(mode)

	if combo.setCurrentOptionByData then
		combo:setCurrentOptionByData(mode, true)
	else
		combo:setCurrentOption(operatingModeOptionText(mode), true)
	end

	if combo.setTooltip then
		combo:setTooltip(operatingModeText(mode))
	end
end

local function normalizeTargetPzAuto(value)
	if type(value) == "string" then
		local normalized = value:lower()

		if normalized == TARGET_PZ_AUTO_DISABLED or normalized == "desativado" then
			return TARGET_PZ_AUTO_DISABLED
		end
	end

	return TARGET_PZ_AUTO_ENABLED
end

local function isTargetPzAutoEnabled()
	return normalizeTargetPzAuto(targetPzAuto) == TARGET_PZ_AUTO_ENABLED
end

local function readTargetPzAutoWidget()
	return normalizeTargetPzAuto(readComboOptionValue(widget("targetPzAutoCombo"), targetPzAuto))
end

local function applyTargetPzAutoWidget(value)
	local combo = widget("targetPzAutoCombo")

	if not combo or not combo.setCurrentOption then
		return
	end

	value = normalizeTargetPzAuto(value)

	if combo.setCurrentOptionByData then
		combo:setCurrentOptionByData(value, true)
	else
		combo:setCurrentOption(value == TARGET_PZ_AUTO_ENABLED and targetText("enabled") or targetText("disabled"), true)
	end
end

local function rebuildTargetSettingOptions()
	suppressTargetSettingsChange = true

	local modeCombo = widget("targetModeCombo")

	if modeCombo and modeCombo.clearOptions and modeCombo.addOption then
		modeCombo:clearOptions()
		modeCombo:addOption(targetText("stand"), TARGET_MODE_STAND)
		modeCombo:addOption(targetText("chase"), TARGET_MODE_CHASE)
		applyTargetModeWidget(targetAttackMode)
	end

	local operatingCombo = widget("targetOperatingModeCombo")

	if operatingCombo and operatingCombo.clearOptions and operatingCombo.addOption then
		operatingCombo:clearOptions()

		for _, mode in ipairs(TARGET_OPERATING_MODES) do
			operatingCombo:addOption(operatingModeOptionText(mode), mode)
		end

		applyTargetOperatingModeWidget(targetOperatingMode)
	end

	local pzCombo = widget("targetPzAutoCombo")

	if pzCombo and pzCombo.clearOptions and pzCombo.addOption then
		pzCombo:clearOptions()
		pzCombo:addOption(targetText("enabled"), TARGET_PZ_AUTO_ENABLED)
		pzCombo:addOption(targetText("disabled"), TARGET_PZ_AUTO_DISABLED)
		applyTargetPzAutoWidget(targetPzAuto)
	end

	suppressTargetSettingsChange = false
end

local countAttackableCreatures

local function getGroupedTargetCount(creature, areaCreatureList)
	if not creature then
		return 0
	end

	local area = SpellAreas and SpellAreas.AREA_CIRCLE2X2
	local creaturePos = creature:getPosition()

	if not area or not creaturePos then
		return 0
	end

	return countAttackableCreatures(creaturePos, Directions.North, area, areaCreatureList or {}, true)
end

local function isStableOperatingCandidateBetter(candidate, best)
	if not best or not best.id then
		return true
	end

	if candidate.distance ~= best.distance then
		return candidate.distance < best.distance
	end

	if candidate.health ~= best.health then
		return candidate.health < best.health
	end

	return candidate.creatureId < best.creatureId
end

local function isOperatingCandidateBetter(candidate, best, mode)
	if not best or not best.id then
		return true
	end

	mode = normalizeTargetOperatingMode(mode)

	if mode == "A" then
		if candidate.distance ~= best.distance then
			return candidate.distance < best.distance
		end
	elseif mode == "B" then
		if candidate.distance ~= best.distance then
			return candidate.distance > best.distance
		end
	elseif mode == "C" then
		if candidate.health ~= best.health then
			return candidate.health < best.health
		end
	elseif mode == "D" then
		if candidate.health ~= best.health then
			return candidate.health > best.health
		end
	elseif mode == "E" then
		if candidate.areaCount ~= best.areaCount then
			return candidate.areaCount > best.areaCount
		end
	elseif mode == "F" then
		if candidate.distance ~= best.distance then
			return candidate.distance < best.distance
		end

		if candidate.health ~= best.health then
			return candidate.health < best.health
		end
	elseif mode == "G" then
		if candidate.distance ~= best.distance then
			return candidate.distance < best.distance
		end

		if candidate.health ~= best.health then
			return candidate.health > best.health
		end
	elseif mode == "H" then
		if candidate.distance ~= best.distance then
			return candidate.distance > best.distance
		end

		if candidate.health ~= best.health then
			return candidate.health < best.health
		end
	elseif mode == "I" then
		if candidate.distance ~= best.distance then
			return candidate.distance > best.distance
		end

		if candidate.health ~= best.health then
			return candidate.health > best.health
		end
	end

	return isStableOperatingCandidateBetter(candidate, best)
end

local applyTargetAttackMode

local function isWithinDistance(playerPos, targetPos, minDist, maxDist)
	if not isWithinReach(playerPos, targetPos) then
		return false
	end

	local dist = var_0_51(playerPos, targetPos)

	minDist = tonumber(minDist) or 1
	maxDist = tonumber(maxDist) or 7

	return minDist <= dist and dist <= maxDist
end

local function rotateArea(area, direction)
	if type(area) ~= "table" or not area[1] then
		return {}
	end

	local rotatedArea = {}
	local rows = #area
	local cols = #area[1]

	if direction == Directions.North then
		return area
	elseif direction == Directions.South then
		for y = 1, rows do
			rotatedArea[y] = {}

			for x = 1, cols do
				rotatedArea[y][x] = area[rows - y + 1][cols - x + 1]
			end
		end
	elseif direction == Directions.East then
		for x = 1, cols do
			rotatedArea[x] = {}

			for y = 1, rows do
				rotatedArea[x][y] = area[rows - y + 1][x]
			end
		end
	elseif direction == Directions.West then
		for x = 1, cols do
			rotatedArea[x] = {}

			for y = 1, rows do
				rotatedArea[x][y] = area[y][cols - x + 1]
			end
		end
	else
		return area
	end

	return rotatedArea
end

local function findPlayerPosition(area)
	for y, row in ipairs(area) do
		for x, value in ipairs(row) do
			if value == 3 or value == 2 then
				return x, y
			end
		end
	end

	return nil, nil
end

local function getAttackAreaOffsets(area, direction, ranged, creatureList)
	local cache = type(creatureList) == "table" and creatureList.areaOffsetCache or nil

	if not cache and type(creatureList) == "table" then
		cache = {}
		creatureList.areaOffsetCache = cache
	end

	local areaCache = cache and cache[area] or nil

	if not areaCache and cache then
		areaCache = {}
		cache[area] = areaCache
	end

	local cacheKey = tostring(direction) .. (ranged and ":1" or ":0")

	if areaCache and areaCache[cacheKey] then
		return areaCache[cacheKey]
	end

	local rotated = rotateArea(area, direction)
	local playerX, playerY = findPlayerPosition(rotated)

	if not playerX or not playerY then
		return nil
	end

	local offsets = {}

	for yOffset, row in ipairs(rotated) do
		for xOffset, value in ipairs(row) do
			if value == 1 or ranged and (value == 3 or value == 2) then
				table.insert(offsets, {
					x = xOffset - playerX,
					y = yOffset - playerY
				})
			end
		end
	end

	if areaCache then
		areaCache[cacheKey] = offsets
	end

	return offsets
end

function countAttackableCreatures(casterPos, direction, area, creatureList, ranged)
	if type(area) ~= "table" then
		return 0
	end

	if direction == Directions.SouthEast or direction == Directions.NorthEast then
		direction = Directions.East
	elseif direction == Directions.SouthWest or direction == Directions.NorthWest then
		direction = Directions.West
	end

	local offsets = getAttackAreaOffsets(area, direction, ranged, creatureList)

	if not offsets then
		return 0
	end

	local creatures = 0
	local positionIndex = type(creatureList) == "table" and creatureList.positionIndex or nil

	for _, offset in ipairs(offsets) do
		local x = casterPos.x + offset.x
		local y = casterPos.y + offset.y

		if positionIndex then
			local column = positionIndex[x]
			local occupants = column and column[y] or nil

			if occupants then
				for _, creature in ipairs(occupants) do
					local creaturePos = creature.position

					if creaturePos and creaturePos.x == x and creaturePos.y == y and creaturePos.z == casterPos.z and g_map.isSightClear(casterPos, creaturePos) then
						creatures = creatures + 1

						break
					end
				end
			end
		else
			for _, creature in ipairs(creatureList) do
				local creaturePos = type(creature) == "table" and creature.position or nil

				if creaturePos and creaturePos.x == x and creaturePos.y == y and creaturePos.z == casterPos.z and g_map.isSightClear(casterPos, creaturePos) then
					creatures = creatures + 1

					break
				end
			end
		end
	end

	return creatures
end

local function addAreaCreature(creatureList, positionIndex, creature, creaturePos)
	local entry = {
		position = creaturePos,
		creature = creature
	}

	table.insert(creatureList, entry)

	local column = positionIndex[creaturePos.x]

	if not column then
		column = {}
		positionIndex[creaturePos.x] = column
	end

	local occupants = column[creaturePos.y]

	if not occupants then
		occupants = {}
		column[creaturePos.y] = occupants
	end

	table.insert(occupants, entry)
end

local function buildBestTargetAreaCreatureList(position)
	local creatureList = {}
	local positionIndex = {}

	for _, creature in pairs(spectators) do
		if isMapCreature(creature) and not creature:isDead() and creature.isMonster and creature:isMonster() and not var_0_56(creature) then
			local creaturePos = creature:getPosition()

			if creaturePos and creaturePos.z == position.z then
				addAreaCreature(creatureList, positionIndex, creature, creaturePos)
			end
		end
	end

	creatureList.positionIndex = positionIndex

	return creatureList
end

local function createAllCreaturesEntry(enabled)
	return {
		allCreatures = true,
		enabled = enabled ~= false
	}
end

local function ensureAllCreaturesEntry()
	local existingIndex
	local var_43_1 = false

	for i = #priorityList, 1, -1 do
		if priorityList[i].allCreatures then
			if existingIndex then
				table.remove(priorityList, i)

				var_43_1 = true
			else
				existingIndex = i
			end
		end
	end

	if not existingIndex then
		table.insert(priorityList, 1, createAllCreaturesEntry(allCreaturesEnabled))

		existingIndex = 1
		var_43_1 = true
	end

	allCreaturesEnabled = priorityList[existingIndex].enabled ~= false

	if var_43_1 then
		getDistanceBetween()
	end

	return existingIndex
end

local function movePriorityEntryAt(index, delta)
	local newIndex = index + delta

	if newIndex < 1 or newIndex > #priorityList then
		return nil
	end

	local entry = table.remove(priorityList, index)

	table.insert(priorityList, newIndex, entry)
	getDistanceBetween()

	return newIndex
end

local function removePriorityEntryAt(index)
	local entry = priorityList[index]

	if not entry or entry.allCreatures then
		return false
	end

	table.remove(priorityList, index)
	getDistanceBetween()

	return true
end

local function focusTargetRowByIndex(index)
	local list = widget("targetPriorityList")

	if not list or list:isDestroyed() then
		return
	end

	for _, row in ipairs(list:getChildren()) do
		if row.priorityListIndex == index then
			list:focusChild(row, KeyboardFocusReason)

			break
		end
	end
end

local function getPriorityRaceOrder()
	if var_0_5 then
		return var_0_5
	end

	local order = {}

	for idx, entry in ipairs(priorityList) do
		local raceId = normalizeRaceId(entry.raceId)

		if raceId and entry.enabled ~= false then
			order[raceId] = idx
		end
	end

	var_0_5 = order

	return var_0_5
end

local monsterNameToRaceId

local function buildMonsterCache()
	local all = g_things.getMonsterList() or {}
	local filtered = {}

	for _, monster in ipairs(all) do
		if type(monster) == "table" and not monster.boss then
			table.insert(filtered, monster)
		end
	end

	table.sort(filtered, function(a, b)
		return (a.name or ""):lower() < (b.name or ""):lower()
	end)

	monsterCache = filtered
	monsterNameToRaceId = nil
end

local function getMonstersSorted()
	if not monsterCache then
		buildMonsterCache()
	end

	return monsterCache
end

local function rebuildMonsterNameIndex()
	local monsters = getMonstersSorted()
	local index = {}

	for _, race in ipairs(monsters) do
		if type(race) == "table" and race.name and race.raceId then
			index[race.name:lower()] = race.raceId
		end
	end

	monsterNameToRaceId = index
end

local function getCreatureRaceId(creature)
	if not creature then
		return nil
	end

	local id = creature.getId and creature:getId() or nil
	local var_52_1 = id and spectatorMeta[id] or nil

	if var_52_1 and var_52_1.raceId ~= nil then
		return var_52_1.raceId
	end

	local raceId

	if creature.getRaceId then
		raceId = normalizeRaceId(creature:getRaceId())
	else
		local var_52_3 = isFamiliar(creature)

		if var_52_3 then
			if not monsterNameToRaceId then
				rebuildMonsterNameIndex()
			end

			raceId = normalizeRaceId(monsterNameToRaceId[var_52_3])
		end
	end

	if var_52_1 and raceId ~= nil then
		var_52_1.raceId = raceId
	end

	return raceId
end

local function var_0_95(arg_53_0, arg_53_1)
	local var_53_0 = normalizeRaceId(getCreatureRaceId(arg_53_0))

	if not var_53_0 then
		return nil
	end

	return arg_53_1[var_53_0]
end

local function var_0_96(arg_54_0, arg_54_1)
	if HelperCavebot and HelperCavebot.isCreatureReachable then
		return HelperCavebot.isCreatureReachable(arg_54_0, arg_54_1)
	end

	return g_map.isSightClear(arg_54_0, arg_54_1)
end

local function isLockedTargetValid(creature, arg_55_1, position, arg_55_3, creatureMatchesPriority, allCreatures)
	if not creature or creature:isDead() then
		return false
	end

	if not creature.isMonster or not creature:isMonster() then
		return false
	end

	if var_0_56(creature) then
		return false
	end

	if not creatureMatchesPriority and not var_0_95(creature, allCreatures) then
		return false
	end

	local creaturePos = creature:getPosition()

	if not creaturePos or creaturePos.z ~= arg_55_1.z then
		return false
	end

	local keepMaxDist = (tonumber(arg_55_3) or 7) + 2

	if not isWithinDistance(arg_55_1, creaturePos, 0, keepMaxDist) then
		return false
	end

	if not var_0_96(arg_55_1, creaturePos) then
		return false
	end

	return true
end

local function var_0_98(arg_56_0, arg_56_1, arg_56_2, arg_56_3, arg_56_4, arg_56_5)
	if not isMapCreature(arg_56_0) or arg_56_0:isDead() or var_0_56(arg_56_0) then
		return nil
	end

	local var_56_0 = var_0_95(arg_56_0, arg_56_5)

	if not arg_56_4 and not var_56_0 then
		return nil
	end

	local position = arg_56_0:getPosition()

	if not isWithinDistance(arg_56_1, position, arg_56_2, arg_56_3) or not var_0_96(arg_56_1, position) then
		return nil
	end

	return position, var_56_0 or 9999
end

local function var_0_99()
	local check = widget("checkbox")

	return check and check:isChecked() or false
end

local function syncCombatSchedulerState()
	local helper = modules.game_helper

	if helper and helper.syncCombatSchedulerState then
		helper.syncCombatSchedulerState()
	end
end

local function isAutoTargetEnabled()
	if not var_0_99() then
		return false
	end

	local var_59_0 = widget("enableTargetCheckBox")

	return var_59_0 and var_59_0:isChecked() or false
end

local function applyTargetAttackMode()
	if not isAutoTargetEnabled() or autoTargetOnHold then
		return
	end

	if not g_game.getAttackingCreature() then
		return
	end

	local desiredChase = targetAttackMode == TARGET_MODE_CHASE and ChaseOpponent or DontChase

	if g_game.getChaseMode() == desiredChase then
		return
	end

	if modules.game_inventory and modules.game_inventory.selectPosture then
		modules.game_inventory.selectPosture(targetAttackMode == TARGET_MODE_CHASE and "follow" or "stand")
	else
		g_game.setChaseMode(desiredChase)
	end
end

local function showMessage(text)
	if modules.game_textmessage and modules.game_textmessage.displayGameMessage then
		modules.game_textmessage.displayGameMessage(text)
	end
end

local function showFailure(text)
	if modules.game_textmessage and modules.game_textmessage.displayFailureMessage then
		modules.game_textmessage.displayFailureMessage(text)
	end
end

local function isTargetBlockedByProtectionZone()
	local player = g_game.getLocalPlayer()

	return not isTargetPzAutoEnabled() and player and player.isInProtectionZone and player:isInProtectionZone() or false
end

local function setTargetCheckEnabled(enabled)
	local check = widget("enableTargetCheckBox")

	if check and check.setEnabled then
		check:setEnabled(enabled == true)
	end
end

local function blockTargetEnableInProtectionZone(silent)
	if not isTargetBlockedByProtectionZone() then
		return false
	end

	local check = widget("enableTargetCheckBox")

	if check and check:isChecked() then
		suppressTargetCheckChange = true

		check:setChecked(false)

		suppressTargetCheckChange = false
	end

	setTargetCheckEnabled(false)

	targetEnabledBeforePz = false

	if currentLockedTargetId > 0 then
		currentLockedTargetId = 0

		g_game.cancelAttack()
	end

	if not silent then
		showFailure(targetText("pzBlocked"))
	end

	return true
end

function HelperTarget.isFamiliar(creature)
	return var_0_54(creature)
end

function HelperTarget.isFriendlySummon(arg_67_0)
	return var_0_55(arg_67_0)
end

function HelperTarget.isExcludedCombatCreature(arg_68_0)
	return var_0_56(arg_68_0)
end

function HelperTarget.getSpectators()
	return spectators
end

function HelperTarget.isWithinDistance(playerPos, targetPos, p1, p2)
	return isWithinDistance(playerPos, targetPos, p1, p2)
end

function HelperTarget.isWithinReach(creatureList, ranged)
	return isWithinReach(creatureList, ranged)
end

function HelperTarget.getDistanceBetween(p1, p2)
	return var_0_51(p1, p2)
end

function HelperTarget.countAttackableCreatures(casterPos, direction, area, creatureList, ranged)
	return countAttackableCreatures(casterPos, direction, area, creatureList, ranged)
end

function HelperTarget.isAutoTargetActive()
	return isAutoTargetEnabled()
end

function HelperTarget.shouldHoldCavebotMovement()
	if not isAutoTargetEnabled() or autoTargetOnHold then
		return false
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer or localPlayer:isInProtectionZone() then
		return false
	end

	if g_game.getAttackingCreature() or currentLockedTargetId > 0 then
		return true
	end

	local var_75_1 = allCreaturesEnabled
	local var_75_2 = getPriorityRaceOrder()

	if not var_75_1 and not next(var_75_2) then
		return false
	end

	local position = localPlayer:getPosition()
	local var_75_4, var_75_5 = readDistanceRange()

	for unusedValue, spectator in pairs(spectators) do
		if var_0_98(spectator, position, var_75_4, var_75_5, var_75_1, var_75_2) then
			return true
		end
	end

	return false
end

function HelperTarget.setAutoTargetOnHold(value)
	autoTargetOnHold = value == true
end

function HelperTarget.onHelperDisabled()
	if currentLockedTargetId > 0 then
		currentLockedTargetId = 0

		g_game.cancelAttack()
	end
end

function HelperTarget.onCreatureAppear(creature)
	if not creature or creature:isPlayer() then
		return
	end

	if creature:getHealthPercent() <= 0 then
		return
	end

	local var_78_0 = isFamiliar(creature)

	if var_78_0 and familiarNames[var_78_0] then
		return
	end

	local id = creature:getId()

	if creature:isMonster() and not spectators[id] then
		spectatorAgeCounter = spectatorAgeCounter + 1
		spectatorMeta[id] = {
			age = spectatorAgeCounter,
			nameLower = var_78_0
		}
		spectators[id] = creature
	end
end

local function handleChangeName(arg_79_0, arg_79_1)
	if not arg_79_0 or not arg_79_0.getId then
		return
	end

	local id = spectatorMeta[arg_79_0:getId()]

	if not id then
		return
	end

	id.nameLower = arg_79_1 and arg_79_1 ~= "" and arg_79_1:lower() or nil
	id.raceId = nil
end

function HelperTarget.onCreatureDisappear(creature)
	if not creature then
		return
	end

	local id = creature:getId()

	if spectators[id] then
		spectators[id] = nil
	end

	spectatorMeta[id] = nil

	if creature:getId() == currentLockedTargetId then
		currentLockedTargetId = 0
	end
end

function HelperTarget.onAttackingCreatureChange(creature, unusedArgument)
	if not isAutoTargetEnabled() or autoTargetOnHold then
		return
	end

	if creature then
		currentLockedTargetId = creature:getId()
	else
		currentLockedTargetId = 0
	end
end

function HelperTarget.clearSpectators()
	spectators = {}
	spectatorMeta = {}
	spectatorAgeCounter = 0
end

local function updateProtectionZoneAutoTarget()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	local var_83_1 = localPlayer:isInProtectionZone()

	if not isTargetPzAutoEnabled() then
		local var_83_2 = targetEnabledBeforePz == true

		targetEnabledBeforePz = false

		if var_83_1 then
			local var_83_3 = widget("enableTargetCheckBox")
			local var_83_4 = var_83_2 or var_83_3 and var_83_3:isChecked()

			blockTargetEnableInProtectionZone(true)

			if var_83_4 then
				saveConfigIfReady()
			end
		else
			setTargetCheckEnabled(true)
		end
	else
		setTargetCheckEnabled(true)

		if not var_0_99() then
			wasInProtectionZone = var_83_1

			if modules.game_helper and modules.game_helper.refreshHelperStats then
				modules.game_helper.refreshHelperStats()
			end

			return
		end

		if isTargetPzAutoEnabled() then
			if var_83_1 and not wasInProtectionZone then
				local var_83_5 = widget("enableTargetCheckBox")

				if var_83_5 and var_83_5:isChecked() then
					targetEnabledBeforePz = true
					suppressTargetCheckChange = true

					var_83_5:setChecked(false)

					suppressTargetCheckChange = false

					if currentLockedTargetId > 0 then
						currentLockedTargetId = 0

						g_game.cancelAttack()
					end
				else
					targetEnabledBeforePz = false
				end
			elseif not var_83_1 and wasInProtectionZone and targetEnabledBeforePz then
				targetEnabledBeforePz = false

				local var_83_6 = widget("enableTargetCheckBox")

				if var_83_6 and not var_83_6:isChecked() then
					suppressTargetCheckChange = true

					var_83_6:setChecked(true)

					suppressTargetCheckChange = false
				end
			end
		elseif not var_83_1 then
			targetEnabledBeforePz = false
		end
	end

	wasInProtectionZone = var_83_1

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end
end

function HelperTarget.refreshProtectionZoneState()
	updateProtectionZoneAutoTarget()
end

local function checkAutoTarget()
	updateProtectionZoneAutoTarget()

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	if localPlayer:isInProtectionZone() then
		return
	end

	if not isAutoTargetEnabled() then
		return
	end

	if autoTargetOnHold then
		return
	end

	local position = localPlayer:getPosition()
	local minDist, maxDist = readDistanceRange()
	local allCreatures = allCreaturesEnabled
	local var_85_5 = getPriorityRaceOrder()

	if not allCreatures and not next(var_85_5) then
		currentLockedTargetId = 0

		if g_game.getAttackingCreature() then
			g_game.cancelAttack()
		end

		return
	end

	targetOperatingMode = readTargetOperatingModeWidget()

	local areaCreatureList = targetOperatingMode == "E" and buildBestTargetAreaCreatureList(position) or nil
	local bestTarget = {
		creatureId = 0,
		areaCount = 0,
		priority = 9999,
		health = 0,
		distance = 99
	}

	for _, creature in pairs(spectators) do
		local var_85_8, var_85_9 = var_0_98(creature, position, minDist, maxDist, allCreatures, var_85_5)

		if var_85_8 and var_85_9 <= bestTarget.priority then
			local id = creature:getId()
			local candidate = {
				id = id,
				priority = var_85_9,
				distance = var_0_51(position, var_85_8),
				health = creature:getHealthPercent() or 0,
				areaCount = targetOperatingMode == "E" and getGroupedTargetCount(creature, areaCreatureList) or 0,
				creatureId = id
			}

			if var_85_9 < bestTarget.priority or isOperatingCandidateBetter(candidate, bestTarget, targetOperatingMode) then
				bestTarget = candidate
			end
		end
	end

	local tickNow = nowMs()
	local target = bestTarget.id and g_map.getCreatureById(bestTarget.id) or nil
	local currentTarget = g_game.getAttackingCreature()

	if target and currentTarget and currentTarget:getId() ~= target:getId() and lastTargetAttackId == currentTarget:getId() and lastTargetAttackAt > 0 and tickNow - lastTargetAttackAt < TARGET_SWITCH_DELAY_MS and isLockedTargetValid(currentTarget, position, minDist, maxDist, allCreatures, var_85_5) then
		target = currentTarget
	end

	if target then
		currentLockedTargetId = target:getId()

		if not currentTarget or currentTarget:getId() ~= target:getId() then
			g_game.attack(target, true)

			lastTargetAttackId = target:getId()
			lastTargetAttackAt = tickNow
		end

		applyTargetAttackMode()
	else
		currentLockedTargetId = 0

		if currentTarget then
			g_game.cancelAttack()
		end
	end
end

function HelperTarget.onTargetModeChange()
	if suppressTargetSettingsChange then
		return
	end

	targetAttackMode = readTargetModeWidget()

	applyTargetAttackMode()
	saveConfigIfReady()
end

function HelperTarget.onTargetPriorityChange()
	if suppressTargetSettingsChange then
		return
	end

	targetOperatingMode = readTargetOperatingModeWidget()

	local combo = widget("targetOperatingModeCombo")

	if combo and combo.setTooltip then
		combo:setTooltip(operatingModeText(targetOperatingMode))
	end

	currentLockedTargetId = 0
	lastTargetAttackId = 0
	lastTargetAttackAt = 0

	saveConfigIfReady()
end

function HelperTarget.onTargetPzAutoChange()
	if suppressTargetSettingsChange then
		return
	end

	targetPzAuto = readTargetPzAutoWidget()

	saveConfigIfReady()
	updateProtectionZoneAutoTarget()
end

function HelperTarget.isDisabledByProtectionZone()
	return targetEnabledBeforePz == true
end

function HelperTarget.enableProtectionZonePause()
	local player = g_game.getLocalPlayer()

	if not player or not player.isInProtectionZone or not player:isInProtectionZone() then
		return false
	end

	if not isTargetPzAutoEnabled() then
		return false
	end

	targetEnabledBeforePz = true
	wasInProtectionZone = true

	local autoTarget = widget("enableTargetCheckBox")

	if autoTarget and autoTarget:isChecked() then
		suppressTargetCheckChange = true

		autoTarget:setChecked(false)

		suppressTargetCheckChange = false
	end

	if currentLockedTargetId > 0 then
		currentLockedTargetId = 0

		g_game.cancelAttack()
	end

	saveConfigIfReady()

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end

	return true
end

function HelperTarget.disableProtectionZonePause()
	targetEnabledBeforePz = false

	setTargetCheckEnabled(not isTargetBlockedByProtectionZone())

	local autoTarget = widget("enableTargetCheckBox")

	if autoTarget and autoTarget:isChecked() then
		suppressTargetCheckChange = true

		autoTarget:setChecked(false)

		suppressTargetCheckChange = false
	end

	saveConfigIfReady()

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end
end

function HelperTarget.runTick(_state)
	var_0_16 = var_0_16 + COMBAT_TICK_MS

	if var_0_16 >= TARGET_INTERVAL_MS then
		var_0_16 = 0

		checkAutoTarget()
	end
end

function HelperTarget.toggleAutoTarget(checkWidget, silent)
	if not checkWidget then
		checkWidget = widget("enableTargetCheckBox")

		if checkWidget then
			suppressTargetCheckChange = true

			checkWidget:setChecked(not checkWidget:isChecked())

			suppressTargetCheckChange = false
		end
	end

	if not checkWidget then
		return
	end

	if checkWidget:isChecked() and blockTargetEnableInProtectionZone(silent) then
		saveConfigIfReady()
		syncCombatSchedulerState()

		if modules.game_helper and modules.game_helper.refreshHelperStats then
			modules.game_helper.refreshHelperStats()
		end

		return
	end

	if not checkWidget:isChecked() and currentLockedTargetId > 0 then
		currentLockedTargetId = 0

		g_game.cancelAttack()
	end

	if not silent then
		showMessage(string.format("Auto Target is %s.", checkWidget:isChecked() and "enabled" or "disabled"))
	end

	saveConfigIfReady()
	syncCombatSchedulerState()
end

function HelperTarget.onEnableTargetCheckChange(checkWidget)
	if not checkWidget then
		return
	end

	if suppressTargetCheckChange then
		syncCombatSchedulerState()

		return
	end

	if checkWidget:isChecked() and blockTargetEnableInProtectionZone(false) then
		saveConfigIfReady()
		syncCombatSchedulerState()

		if modules.game_helper and modules.game_helper.refreshHelperStats then
			modules.game_helper.refreshHelperStats()
		end

		return
	end

	if not checkWidget:isChecked() and currentLockedTargetId > 0 then
		currentLockedTargetId = 0

		g_game.cancelAttack()
	end

	saveConfigIfReady()
	syncCombatSchedulerState()
end

local function capitalizeWords(text)
	if not text or text == "" then
		return ""
	end

	return (text:gsub("(%a)([%w_']*)", function(a, rest)
		return a:upper() .. rest:lower()
	end))
end

local function applyZebraToPanel(panel)
	if not panel then
		return
	end

	local idx = 0

	for _, child in ipairs(panel:getChildren()) do
		if child:isVisible() then
			idx = idx + 1

			local color = idx % 2 == 1 and ZEBRA_COLOR_A or ZEBRA_COLOR_B

			child.zebraColor = color

			child:setBackgroundColor(color)
		end
	end
end

local function connectZebraFocus(item)
	connect(item, {
		onFocusChange = function(self, focused)
			if focused then
				self:setBackgroundColor("#585858")
			else
				addEvent(function()
					if not self:isDestroyed() then
						self:setBackgroundColor(self.zebraColor or ZEBRA_COLOR_A)
					end
				end)
			end
		end
	})
end

local function findRaceById(raceId)
	local id = normalizeRaceId(raceId)

	if not id then
		return nil
	end

	for _, race in ipairs(getMonstersSorted()) do
		if normalizeRaceId(race.raceId) == id then
			return race
		end
	end

	return nil
end

local function getPriorityRaceIds(excludeIndex)
	local ids = {}

	for i, entry in ipairs(priorityList) do
		local raceId = normalizeRaceId(entry.raceId)

		if raceId and i ~= excludeIndex then
			ids[raceId] = true
		end
	end

	return ids
end

local function applyCreaturePreview(creatureWidget, outfit)
	if not creatureWidget or not creatureWidget.setCreatureSize or not g_things or not g_things.getCreatureBoundingBox then
		return
	end

	local creature = creatureWidget:getCreature()
	local numericValue = tonumber(outfit and outfit.type) or 0

	if not creature or not creature.getExactSize or numericValue <= 0 then
		return
	end

	local direction = creature:getDirection()
	local var_103_3 = (tonumber(outfit.mount) or 0) > 0 and 1 or 0
	local var_103_4, var_103_5 = pcall(function()
		return g_things.getCreatureBoundingBox(numericValue, 0, direction, var_103_3)
	end)
	local var_103_6, var_103_7 = pcall(function()
		return creature:getExactSize()
	end)

	if not var_103_4 or type(var_103_5) ~= "table" or not var_103_6 then
		return
	end

	local numericValue

	numericValue = tonumber(var_103_7) or 0

	local var_103_9 = math.max(tonumber(var_103_5.width) or 0, tonumber(var_103_5.height) or 0)

	if numericValue <= 0 or var_103_9 <= numericValue then
		return
	end

	local spriteSize = tonumber(g_gameConfig.getSpriteSize()) or 32
	local var_103_11 = math.max(numericValue, spriteSize * 2)

	creatureWidget:setCreatureSize(math.min(255, math.ceil(var_103_9 * 100 / var_103_11)))
end

local function var_0_117(arg_106_0, arg_106_1)
	if not arg_106_0 or not arg_106_1 then
		return
	end

	arg_106_0:setOutfit(arg_106_1)

	if arg_106_0.setFixedCreatureSize then
		arg_106_0:setFixedCreatureSize(false)
	end

	if arg_106_0.setCenter then
		arg_106_0:setCenter(true)
	end

	if arg_106_0.setCenterByBoundingBox then
		arg_106_0:setCenterByBoundingBox(true)
	end

	if arg_106_0.setCreatureSize then
		arg_106_0:setCreatureSize(0)
	end

	applyCreaturePreview(arg_106_0, arg_106_1)
end

local function var_0_118(arg_107_0, arg_107_1)
	if not arg_107_0 or not arg_107_1 then
		return
	end

	arg_107_0.targetRaceId = arg_107_1.raceId

	local creatureSprite = arg_107_0:recursiveGetChildById("creatureSprite")
	local creatureIcon = arg_107_0:recursiveGetChildById("creatureIcon")

	if creatureIcon then
		creatureIcon:hide()
	end

	if creatureSprite then
		creatureSprite:show()
		var_0_117(creatureSprite, arg_107_1.outfit)
	end

	local creatureName = arg_107_0:recursiveGetChildById("creatureName")

	if creatureName then
		creatureName:setText(capitalizeWords(arg_107_1.name))
	end
end

local function var_0_119(arg_108_0, arg_108_1)
	if not arg_108_0 then
		return
	end

	local targetRowEnabled = arg_108_0:recursiveGetChildById("targetRowEnabled")

	if targetRowEnabled then
		local var_108_1 = arg_108_1 and arg_108_1.enabled ~= false or allCreaturesEnabled

		targetRowEnabled:setChecked(var_108_1)
	end

	local creatureSprite = arg_108_0:recursiveGetChildById("creatureSprite")
	local creatureIcon = arg_108_0:recursiveGetChildById("creatureIcon")

	if creatureSprite then
		creatureSprite:hide()
	end

	if creatureIcon then
		creatureIcon:setImageSource(ALL_CREATURES_ICON)
		creatureIcon:show()
	end

	local creatureName = arg_108_0:recursiveGetChildById("creatureName")

	if creatureName then
		creatureName:setText(targetText("allCreatures"))
	end
end

local function var_0_120(arg_109_0, arg_109_1)
	if not arg_109_0 or not arg_109_1 then
		return
	end

	local targetRowEnabled = arg_109_0:recursiveGetChildById("targetRowEnabled")

	if targetRowEnabled then
		targetRowEnabled:setChecked(arg_109_1.enabled ~= false)
	end

	local var_109_1 = findRaceById(arg_109_1.raceId) or arg_109_1

	var_0_118(arg_109_0, var_109_1)
end

local function getSelectedRemovableTargetRow()
	local var_110_0 = widget("targetPriorityList")

	if not var_110_0 or var_110_0:isDestroyed() then
		return nil
	end

	local focusedChild = var_110_0:getFocusedChild()

	if focusedChild and not focusedChild.isAllCreaturesRow and focusedChild.priorityListIndex then
		return focusedChild
	end

	return nil
end

local function var_0_122()
	targetActionButtonsState = nil
end

local function syncTargetActionButtons()
	local var_112_0 = widget("targetAddBtn")
	local var_112_1 = widget("targetEditBtn")
	local var_112_2 = widget("targetRemoveBtn")

	if not var_112_0 or not var_112_1 or not var_112_2 then
		return
	end

	local var_112_3 = getSelectedRemovableTargetRow() ~= nil
	local var_112_4 = var_112_3 and "actions" or "default"

	if targetActionButtonsState == var_112_4 then
		return
	end

	targetActionButtonsState = var_112_4

	var_112_0:setEnabled(true)

	if var_112_3 then
		var_112_2:show()
		var_112_1:show()
		var_112_0:breakAnchors()
		var_112_0:addAnchor(AnchorTop, "parent", AnchorTop)
		var_112_0:addAnchor(AnchorRight, "targetEditBtn", AnchorLeft)
		var_112_0:setMarginRight(6)
		var_112_1:setEnabled(true)
		var_112_2:setEnabled(true)
		var_112_2:setMarginRight(0)
	else
		var_112_2:hide()
		var_112_1:hide()
		var_112_0:breakAnchors()
		var_112_0:addAnchor(AnchorTop, "parent", AnchorTop)
		var_112_0:addAnchor(AnchorRight, "parent", AnchorRight)
		var_112_0:setMarginRight(0)
	end
end

local function scheduleTargetActionButtonsSync()
	addEvent(function()
		syncTargetActionButtons()
	end)
end

local function clearTargetListSelection()
	local var_115_0 = widget("targetPriorityList")

	if not var_115_0 or var_115_0:isDestroyed() then
		return
	end

	var_115_0:focusChild(nil)
	var_0_122()
	scheduleTargetActionButtonsSync()
end

local function updateTargetPreview(row)
	if not targetAssignWindow or targetAssignWindow:isDestroyed() or not row then
		return
	end

	local targetPreview = targetAssignWindow:recursiveGetChildById("targetPreview")

	if not targetPreview then
		return
	end

	local targetRace = row.targetRace
	local previewCreatureSprite = targetPreview:getChildById("previewCreatureSprite")

	if previewCreatureSprite and targetRace then
		var_0_117(previewCreatureSprite, targetRace.outfit)
	end

	local previewCreatureName = targetPreview:getChildById("previewCreatureName")

	if previewCreatureName and targetRace then
		previewCreatureName:setText(capitalizeWords(targetRace.name))
	end
end

local function refreshAddButtonState()
	syncTargetActionButtons()
end

local function refreshPriorityListUI()
	ensureAllCreaturesEntry()
	var_0_122()

	local var_118_0 = widget("targetPriorityList")

	if not var_118_0 then
		return
	end

	var_118_0:destroyChildren()

	for index, entry in ipairs(priorityList) do
		local var_118_1 = entry
		local targetPriorityListRowWidget = g_ui.createWidget("TargetPriorityListRow", var_118_0)
		local zebraColor = index % 2 == 1 and ZEBRA_COLOR_A or ZEBRA_COLOR_B

		targetPriorityListRowWidget.zebraColor = zebraColor

		targetPriorityListRowWidget:setBackgroundColor(zebraColor)

		targetPriorityListRowWidget.priorityListIndex = index
		targetPriorityListRowWidget.isAllCreaturesRow = var_118_1.allCreatures == true

		if var_118_1.allCreatures then
			var_0_119(targetPriorityListRowWidget, var_118_1)
		else
			targetPriorityListRowWidget.targetRaceId = var_118_1.raceId

			var_0_120(targetPriorityListRowWidget, var_118_1)
		end

		local targetRowEnabled = targetPriorityListRowWidget:recursiveGetChildById("targetRowEnabled")

		if targetRowEnabled then
			function targetRowEnabled.onCheckChange(unusedArgument, enabled)
				var_118_1.enabled = enabled

				if var_118_1.allCreatures then
					allCreaturesEnabled = enabled == true

					var_0_122()
					scheduleTargetActionButtonsSync()
				else
					getDistanceBetween()
				end

				saveConfigIfReady()
			end
		end

		connectZebraFocus(targetPriorityListRowWidget)

		function targetPriorityListRowWidget.onMouseRelease(arg_120_0, unusedArgument, arg_120_2)
			if arg_120_2 == MouseRightButton then
				var_0_8(arg_120_0)
			end
		end
	end

	syncTargetActionButtons()
end

function var_0_8(arg_121_0)
	if not arg_121_0 or not arg_121_0.priorityListIndex then
		return
	end

	local index = arg_121_0.priorityListIndex
	local var_121_1 = priorityList[index]

	if not var_121_1 then
		return
	end

	local var_121_2 = widget("targetPriorityList")

	if var_121_2 and not var_121_2:isDestroyed() then
		var_121_2:focusChild(arg_121_0, KeyboardFocusReason)
		var_0_122()
		scheduleTargetActionButtonsSync()
	end

	local gamePopupMenuWidget = g_ui.createWidget("GamePopupMenu")

	gamePopupMenuWidget:setWidth(120)

	if index > 1 then
		gamePopupMenuWidget:addOption(targetText("moveUp"), function()
			local newIndex = movePriorityEntryAt(index, -1)

			if newIndex then
				refreshPriorityListUI()
				focusTargetRowByIndex(newIndex)
				syncTargetActionButtons()
				saveConfigIfReady()
			end
		end)
	end

	if index < #priorityList then
		gamePopupMenuWidget:addOption(targetText("moveDown"), function()
			local newIndex = movePriorityEntryAt(index, 1)

			if newIndex then
				refreshPriorityListUI()
				focusTargetRowByIndex(newIndex)
				syncTargetActionButtons()
				saveConfigIfReady()
			end
		end)
	end

	if not var_121_1.allCreatures then
		gamePopupMenuWidget:addOption(targetText("edit"), function()
			openTargetAssignWindowInternal(index)
		end)
		gamePopupMenuWidget:addOption(targetText("remove"), function()
			if removePriorityEntryAt(index) then
				refreshPriorityListUI()
				syncTargetActionButtons()
				saveConfigIfReady()
			end
		end)
	end

	gamePopupMenuWidget:display()
end

local function closeTargetAssignWindowInternal()
	if targetAssignWindow and not targetAssignWindow:isDestroyed() then
		targetAssignWindow:destroy()
	end

	targetAssignWindow = nil
	targetMonstersPanel = nil
	editingPriorityListIndex = nil
end

local function populateTargetMonsterList()
	if not targetMonstersPanel then
		return
	end

	targetMonstersPanel:destroyChildren()

	local var_127_0 = getPriorityRaceIds(editingPriorityListIndex)
	local var_127_1 = 0

	for unusedValue, entry in ipairs(getMonstersSorted()) do
		if not var_127_0[entry.raceId] then
			var_127_1 = var_127_1 + 1

			local var_127_2 = var_127_1 % 2 == 1 and "HelperCreatureListRowOdd" or "HelperCreatureListRowEven"
			local var_127_3 = g_ui.createWidget(var_127_2, targetMonstersPanel)

			var_127_3.targetRace = entry
			var_127_3.nameLower = (entry.name or ""):lower()

			var_0_118(var_127_3, entry)
			connectZebraFocus(var_127_3)
		end
	end

	local okButton = targetAssignWindow and targetAssignWindow:recursiveGetChildById("okButton")

	if okButton then
		okButton:setEnabled(false)
	end
end

local function filterTargetMonsterRows(text)
	if not targetMonstersPanel then
		return
	end

	text = text or ""

	local active = #text > 0
	local lower = active and text:lower() or ""

	for _, row in pairs(targetMonstersPanel:getChildren()) do
		local visible = true

		if active then
			visible = row.nameLower and row.nameLower:find(lower, 1, true) ~= nil
		end

		row:setVisible(visible)
	end

	applyZebraToPanel(targetMonstersPanel)
end

local function focusTargetMonsterRowByRaceId(raceId)
	if not targetMonstersPanel or not raceId then
		return
	end

	local wantedId = normalizeRaceId(raceId)

	if not wantedId then
		return
	end

	for _, row in pairs(targetMonstersPanel:getChildren()) do
		if row:isVisible() and row.targetRace and normalizeRaceId(row.targetRace.raceId) == wantedId then
			targetMonstersPanel:focusChild(row, KeyboardFocusReason)
			updateTargetPreview(row)

			local okBtn = targetAssignWindow and targetAssignWindow:recursiveGetChildById("okButton")

			if okBtn then
				okBtn:setEnabled(true)
			end

			return
		end
	end
end

function openTargetAssignWindowInternal(editIndex)
	closeTargetAssignWindowInternal()

	editingPriorityListIndex = editIndex
	targetAssignWindow = g_ui.loadUI("assign_target", g_ui.getRootWidget())

	if not targetAssignWindow then
		editingPriorityListIndex = nil

		return
	end

	targetAssignWindow:setText(editIndex and targetText("edit") .. " Target" or targetText("add") .. " Target")

	local okBtn = targetAssignWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setText(editIndex and targetText("edit") or targetText("add"))
	end

	targetMonstersPanel = targetAssignWindow:recursiveGetChildById("targetMonstersPanel")

	connect(targetMonstersPanel, {
		onChildFocusChange = function(_, focusedChild)
			if focusedChild then
				updateTargetPreview(focusedChild)
			end

			local okBtn = targetAssignWindow:recursiveGetChildById("okButton")

			if okBtn then
				okBtn:setEnabled(focusedChild ~= nil)
			end
		end
	})
	populateTargetMonsterList()
	filterTargetMonsterRows("")
	targetAssignWindow:show()
	targetAssignWindow:raise()
	targetAssignWindow:focus()

	if editIndex then
		local entry = priorityList[editIndex]

		if entry and entry.raceId then
			addEvent(function()
				if targetAssignWindow and not targetAssignWindow:isDestroyed() then
					focusTargetMonsterRowByRaceId(entry.raceId)
				end
			end)
		end
	end
end

local function setTargetWidgetText(id, text)
	local target = widget(id)

	if target and target.setText then
		target:setText(text)
	end
end

function HelperTarget.refreshLanguage(language)
	var_0_37 = normalizeTargetLanguage(language)

	setTargetWidgetText("targetListWindow", targetText("targetList"))
	setTargetWidgetText("targetSettingsWindow", targetText("targetSettings"))
	setTargetWidgetText("enableTargetLabel", targetText("enableTarget"))
	setTargetWidgetText("targetModeLabel", targetText("mode"))
	setTargetWidgetText("targetDistanceLabel", targetText("distance"))
	setTargetWidgetText("targetPriorityLabel", targetText("priority"))
	setTargetWidgetText("targetPzAutoLabel", targetText("pzAuto"))
	setTargetWidgetText("targetAddBtn", targetText("add"))
	setTargetWidgetText("targetEditBtn", targetText("edit"))
	setTargetWidgetText("targetRemoveBtn", targetText("remove"))
	setTargetWidgetText("targetHeaderCreature", targetText("creature"))
	setTargetWidgetText("targetHeaderName", targetText("name"))

	local listHelp = widget("targetListHelp")

	if listHelp and listHelp.setTooltip then
		listHelp:setTooltip(targetText("targetListHelp"))
	end

	local settingsHelp = widget("targetSettingsHelp")

	if settingsHelp and settingsHelp.setTooltip then
		settingsHelp:setTooltip(targetText("targetSettingsHelp"))
	end

	rebuildTargetSettingOptions()
	refreshPriorityListUI()
	refreshAddButtonState()

	if targetAssignWindow and not targetAssignWindow:isDestroyed() then
		targetAssignWindow:setText(editingPriorityListIndex and targetText("edit") .. " Target" or targetText("add") .. " Target")

		local okBtn = targetAssignWindow:recursiveGetChildById("okButton")

		if okBtn then
			okBtn:setText(editingPriorityListIndex and targetText("edit") or targetText("add"))
		end
	end
end

function HelperTarget.init(pctx)
	ctx = pctx
	var_0_16 = 0

	if not combatTimer then
		connect(Creature, {
			onChangeName = handleChangeName
		})

		combatTimer = true
	end

	HelperTarget.refreshLanguage(ctx and ctx.getLanguage and ctx.getLanguage() or "en")

	local list = widget("targetPriorityList")

	if list then
		connect(list, {
			onChildFocusChange = function()
				scheduleTargetActionButtonsSync()
			end
		})
	end

	refreshAddButtonState()
end

function HelperTarget.onShow()
	refreshAddButtonState()
	clearTargetListSelection()
end

function HelperTarget.onHide()
	closeTargetAssignWindowInternal()
	clearTargetListSelection()
end

function HelperTarget.onGameStart()
	HelperTarget.clearSpectators()

	currentLockedTargetId = 0
	var_0_16 = 0
end

function HelperTarget.terminate()
	closeTargetAssignWindowInternal()

	if combatTimer then
		disconnect(Creature, {
			onChangeName = handleChangeName
		})

		combatTimer = false
	end

	priorityList = {}

	getDistanceBetween()

	allCreaturesEnabled = false
	monsterCache = nil
	monsterNameToRaceId = nil
	spectators = {}
	spectatorMeta = {}
	spectatorAgeCounter = 0
	currentLockedTargetId = 0
	targetEnabledBeforePz = false
	wasInProtectionZone = false
end

function HelperTarget.openAssignWindow()
	openTargetAssignWindowInternal(nil)
end

function HelperTarget.openEditAssignWindow()
	local row = getSelectedRemovableTargetRow()

	if not row or not row.priorityListIndex then
		return
	end

	openTargetAssignWindowInternal(row.priorityListIndex)
end

function HelperTarget.closeAssignWindow()
	closeTargetAssignWindowInternal()
end

function HelperTarget.filterMonsters(text)
	filterTargetMonsterRows(text or "")
end

function HelperTarget.clearMonsterFilter()
	if not targetAssignWindow or targetAssignWindow:isDestroyed() then
		return
	end

	local edit = targetAssignWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:setText("")
		edit:focus()
	end

	filterTargetMonsterRows("")
end

function HelperTarget.assignOk()
	if not targetMonstersPanel then
		return
	end

	local focused = targetMonstersPanel:getFocusedChild()

	if not focused or not focused.targetRace then
		return
	end

	local race = focused.targetRace
	local raceId = normalizeRaceId(race.raceId)

	if not raceId then
		return
	end

	local editIndex = editingPriorityListIndex

	for i, entry in ipairs(priorityList) do
		if normalizeRaceId(entry.raceId) == raceId and i ~= editIndex then
			closeTargetAssignWindowInternal()

			return
		end
	end

	local focusIndex = editIndex

	if editIndex then
		local entry = priorityList[editIndex]

		if not entry or entry.allCreatures then
			closeTargetAssignWindowInternal()

			return
		end

		entry.raceId = raceId
		entry.name = race.name
		entry.outfit = race.outfit
	else
		table.insert(priorityList, {
			enabled = true,
			raceId = raceId,
			name = race.name,
			outfit = race.outfit
		})

		focusIndex = #priorityList
	end

	getDistanceBetween()
	refreshPriorityListUI()
	saveConfigIfReady()
	closeTargetAssignWindowInternal()

	if focusIndex then
		addEvent(function()
			focusTargetRowByIndex(focusIndex)
		end)
	end
end

function HelperTarget.onAllCreaturesChange(_, checked)
	allCreaturesEnabled = checked == true

	ensureAllCreaturesEntry()

	for _, entry in ipairs(priorityList) do
		if entry.allCreatures then
			entry.enabled = allCreaturesEnabled

			break
		end
	end

	refreshAddButtonState()
	saveConfigIfReady()
end

function HelperTarget.onRemoveClick()
	local list = widget("targetPriorityList")

	if not list then
		return
	end

	local focused = list:getFocusedChild()

	if not focused or focused.isAllCreaturesRow or not focused.priorityListIndex then
		return
	end

	if removePriorityEntryAt(focused.priorityListIndex) then
		refreshPriorityListUI()
		saveConfigIfReady()
	end
end

function HelperTarget.collectConfig(config)
	ensureAllCreaturesEntry()

	config.target = config.target or {}

	local enableCheck = widget("enableTargetCheckBox")
	local enabled = enableCheck and enableCheck:isChecked() or false

	config.target.enableTarget = enabled or isTargetPzAutoEnabled() and targetEnabledBeforePz == true

	if ctx.readDistanceValue then
		config.target.distance = ctx.readDistanceValue("targetDistanceCombo")
	end

	config.target.mode = readTargetModeWidget()
	config.target.autoTargetMode = readTargetOperatingModeWidget()
	config.target.pzAuto = readTargetPzAutoWidget()
	config.target.minDist = nil
	config.target.maxDist = nil
	config.target.priorityOrder = nil
	config.target.prioritySort = nil
	config.target.prioritySecondary = nil

	local allCreaturesIndex = 1

	config.target.allCreatures = allCreaturesEnabled
	config.target.priorityList = {}

	for i, entry in ipairs(priorityList) do
		if entry.allCreatures then
			allCreaturesIndex = i
			config.target.allCreatures = entry.enabled ~= false
		elseif entry.raceId then
			local raceId = normalizeRaceId(entry.raceId)

			if raceId then
				table.insert(config.target.priorityList, {
					raceId = raceId,
					name = entry.name,
					enabled = entry.enabled ~= false
				})
			end
		end
	end

	config.target.allCreaturesIndex = allCreaturesIndex
end

function HelperTarget.loadFromConfig(config)
	local data = config.target or {}
	local enableCheck = widget("enableTargetCheckBox")

	if enableCheck then
		enableCheck:setChecked(data.enableTarget == true)
	end

	if ctx.applyDistanceValue then
		ctx.applyDistanceValue("targetDistanceCombo", data.distance or data.maxDist or 7)
	end

	targetAttackMode = normalizeTargetMode(data.mode)

	applyTargetModeWidget(targetAttackMode)

	if data.autoTargetMode ~= nil or data.operatingMode ~= nil then
		targetOperatingMode = normalizeTargetOperatingMode(data.autoTargetMode or data.operatingMode)
	else
		targetOperatingMode = operatingModeFromLegacyConfig(data)
	end

	applyTargetOperatingModeWidget(targetOperatingMode)

	targetPzAuto = normalizeTargetPzAuto(data.pzAuto)

	applyTargetPzAutoWidget(targetPzAuto)

	targetEnabledBeforePz = false
	wasInProtectionZone = false

	setTargetCheckEnabled(true)

	allCreaturesEnabled = data.allCreatures == true
	currentLockedTargetId = 0
	lastTargetAttackId = 0
	lastTargetAttackAt = 0
	priorityList = {}

	getDistanceBetween()

	for _, entry in ipairs(data.priorityList or {}) do
		if entry.raceId and not entry.allCreatures then
			local raceId = normalizeRaceId(entry.raceId)

			if raceId then
				local race = findRaceById(raceId)

				table.insert(priorityList, {
					raceId = raceId,
					name = entry.name or race and race.name or "",
					outfit = race and race.outfit or nil,
					enabled = entry.enabled ~= false
				})
			end
		end
	end

	local allCreaturesIndex = tonumber(data.allCreaturesIndex) or 1

	if allCreaturesIndex < 1 then
		allCreaturesIndex = 1
	end

	if allCreaturesIndex > #priorityList + 1 then
		allCreaturesIndex = #priorityList + 1
	end

	table.insert(priorityList, allCreaturesIndex, createAllCreaturesEntry(allCreaturesEnabled))
	ensureAllCreaturesEntry()
	refreshPriorityListUI()
	refreshAddButtonState()
end
