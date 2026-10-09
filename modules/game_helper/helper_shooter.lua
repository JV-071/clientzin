HelperShooter = HelperShooter or {}

local ctx
local assignSpellWindow
local assignSpellsPanel
local addShooterWindow
local selectedShooterAction
local presetWindow
local assignMode = "spells"
local editingPriorityListIndex
local assignSpellPreviewById
local assignSpellPreviewByName
local activeAssignPreviewFrame
local hotkeyShooterStatus = false
local magicShooterOnHold = false
local suppressShooterCheckChange = false
local suppressShooterSettingsChange = false
local shooterUiLanguage = "en"
local spellPendingSince = {}
local groupPendingSince = {}
local multiUsePendingSince = 0
local GLOBAL_CAST_COOLDOWN_MS = 200
local lastGlobalCastAt = 0
local lastCastIndex = 0
local lastTickScanUs = 0
local lastTickCreatureCount = 0
local lastTickPriorityCount = 0
local lastTickPriorityUs = 0
local lastTickPriorityLabel = "none"
local comboMode = false
local comboNextIndex = 1
local boundPresetHotkeys = {}
local SHOOTER_PZ_AUTO_ENABLED = "enabled"
local SHOOTER_PZ_AUTO_DISABLED = "disabled"
local shooterPzAuto = SHOOTER_PZ_AUTO_ENABLED
local shooterEnabledBeforePz = false
local wasInProtectionZone = false
local shooterEnabledBeforeFollow = false
local wasFollowingCreature = false
local ignoredSpellsIds = {
	[275] = true,
	[274] = true,
	[84] = true,
	[143] = true,
	[242] = true,
	[297] = true,
	[159] = true,
	[144] = true,
	[160] = true,
	[145] = true,
	[142] = true,
	[146] = true,
	[141] = true,
	[147] = true,
	[140] = true,
	[139] = true,
	[138] = true,
	[29] = true,
	[276] = true
}
local var_0_38 = {
	[93] = {
		defaultIntervalMs = 2000,
		range = 2,
		minRange = 1
	},
	[237] = {
		defaultIntervalMs = 2000,
		range = 6,
		minRange = 2
	},
	[238] = {
		defaultIntervalMs = 16000,
		range = 6,
		minRange = 2
	},
	[280] = {
		defaultIntervalMs = 10000,
		range = 6,
		minRange = 2
	},
	[126] = {
		defaultIntervalMs = 60000
	},
	[127] = {
		defaultIntervalMs = 60000
	},
	[128] = {
		defaultIntervalMs = 60000
	},
	[129] = {
		defaultIntervalMs = 60000
	},
	[281] = {
		defaultIntervalMs = 60000
	},
	[296] = {
		defaultIntervalMs = 12000
	}
}
local var_0_39 = 261
local var_0_40 = 3155
local var_0_41 = {}

local function var_0_42(arg_1_0)
	return type(arg_1_0) == "table" and arg_1_0.type == "rune" and tonumber(arg_1_0.id) == var_0_40
end

local var_0_43 = {
	spell_1 = {
		{
			id = 6,
			maxPoints = 200
		},
		{
			id = 21,
			maxPoints = 50
		}
	},
	spell_4 = {
		{
			id = 13,
			maxPoints = 100
		},
		{
			id = 29,
			maxPoints = 100
		}
	},
	spell_5 = {
		{
			id = 16,
			maxPoints = 50
		},
		{
			id = 31,
			maxPoints = 200
		}
	}
}
local var_0_44 = {
	[283] = 4,
	[258] = 2,
	[295] = 2,
	[268] = 3,
	[267] = 4,
	[266] = 4,
	[265] = 4,
	[264] = 4,
	[263] = 3,
	[262] = 3,
	[261] = 2,
	[260] = 2
}
local ZEBRA_COLOR_A = "#484848"
local ZEBRA_COLOR_B = "#414141"
local MAGICAL_ARCHIVES_PREVIEW_FILE = "/modules/game_cyclopedia/tab/magicalArchives/spells-preview.json"
local defaultShooterProfile = {
	priorityList = {}
}
local shooterState = {
	selectedShooterProfile = "Default"
}
local suppressPresetEvents = false
local shooterActionButtonsState

local function withSuppressedPresetEvents(fn)
	local previous = suppressPresetEvents

	suppressPresetEvents = true

	local ok, err = pcall(fn)

	suppressPresetEvents = previous

	if not ok then
		error(err)
	end
end

local function saveConfigIfReady(deferred)
	if ctx and ctx.isLoadingConfig and ctx.isLoadingConfig() then
		return
	end

	if deferred and ctx and ctx.requestAutoSave then
		ctx.requestAutoSave()

		return
	end

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

local function getPresetComboOptionText(presets)
	if not presets or not presets.getCurrentOption then
		return ""
	end

	local current = presets:getCurrentOption()

	if type(current) == "table" then
		return current.text or ""
	end

	return tostring(current or "")
end

local function widget(id)
	return ctx and ctx.getWidget(id)
end

local function readComboOptionText(combo, fallback)
	if not combo or not combo.getCurrentOption then
		return fallback
	end

	local current = combo:getCurrentOption()

	if type(current) == "table" then
		return current.data or current.text or fallback
	end

	return current or fallback
end

local function normalizeShooterPzAuto(value)
	if type(value) == "string" then
		local normalized = value:lower()

		if normalized == SHOOTER_PZ_AUTO_DISABLED or normalized == "desativado" then
			return SHOOTER_PZ_AUTO_DISABLED
		end
	end

	return SHOOTER_PZ_AUTO_ENABLED
end

local function isShooterPzAutoEnabled()
	return normalizeShooterPzAuto(shooterPzAuto) == SHOOTER_PZ_AUTO_ENABLED
end

local function readShooterPzAutoWidget()
	return normalizeShooterPzAuto(readComboOptionText(widget("shooterPzAutoCombo"), shooterPzAuto))
end

local function applyShooterPzAutoWidget(value)
	local combo = widget("shooterPzAutoCombo")

	if not combo or not combo.setCurrentOption then
		return
	end

	value = normalizeShooterPzAuto(value)

	if combo.setCurrentOptionByData then
		combo:setCurrentOptionByData(value, true)
	else
		combo:setCurrentOption(value == SHOOTER_PZ_AUTO_ENABLED and (shooterUiLanguage == "pt" and "Ativado" or "Enabled") or shooterUiLanguage == "pt" and "Desativado" or "Disabled", true)
	end
end

local function actionbar()
	return modules.game_actionbar
end

local function refreshSpellActionTooltip(targetWidget, words)
	if not targetWidget or targetWidget:isDestroyed() then
		return
	end

	targetWidget.words = words

	if words and words ~= "" then
		local ab = actionbar()

		if ab and ab.refreshActionSlotTooltip then
			ab.refreshActionSlotTooltip(targetWidget)

			return
		end
	end

	if targetWidget.setTooltip then
		targetWidget:setTooltip("")
	end
end

local function deepCopy(original)
	if type(original) ~= "table" then
		return original
	end

	local copy = {}

	for k, v in pairs(original) do
		copy[k] = type(v) == "table" and deepCopy(v) or v
	end

	return copy
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

local function capitalizeWords(text)
	if not text or text == "" then
		return ""
	end

	return (text:gsub("(%a)([%w_']*)", function(a, rest)
		return a:upper() .. rest:lower()
	end))
end

local function playerCanUseSpellVocations(vocations)
	if not vocations or not next(vocations) then
		return true
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return false
	end

	local rawVoc = player:getVocation()

	if not rawVoc or rawVoc <= 0 then
		return false
	end

	local translatedVoc = ctx and ctx.getPlayerVoc and ctx.getPlayerVoc() or 0

	for _, voc in ipairs(vocations) do
		if voc == rawVoc or voc == translatedVoc then
			return true
		end
	end

	return false
end

local function playerCanUseAttackSpell()
	local var_19_0 = modules and modules.game_wheel
	local var_19_1

	if var_19_0 and type(var_19_0.getActiveWheelState) == "function" then
		var_19_1 = var_19_0.getActiveWheelState()
	else
		local var_19_2 = rawget(_G, "WheelOfDestiny")

		if type(var_19_2) == "table" and type(var_19_2.getActiveState) == "function" then
			var_19_1 = var_19_2.getActiveState()
		end
	end

	if type(var_19_1) ~= "table" or var_19_1.ready ~= true then
		return nil
	end

	return var_19_1
end

local function var_0_69(arg_20_0)
	local var_20_0 = playerCanUseAttackSpell()
	local var_20_1 = var_0_43[arg_20_0]

	if not var_20_0 or type(var_20_0.pointInvested) ~= "table" or not var_20_1 then
		return 0
	end

	local var_20_2 = 0

	for unusedValue, entry in ipairs(var_20_1) do
		if (tonumber(var_20_0.pointInvested[entry.id]) or 0) >= entry.maxPoints then
			var_20_2 = var_20_2 + 1
		end
	end

	return var_20_2
end

local function var_0_70(arg_21_0)
	local var_21_0 = playerCanUseAttackSpell()

	if not var_21_0 then
		return false
	end

	return (type(var_21_0.passivePoints) == "table" and (tonumber(var_21_0.passivePoints[arg_21_0]) or 0) or 0) + (type(var_21_0.extraPassivePoints) == "table" and (tonumber(var_21_0.extraPassivePoints[arg_21_0]) or 0) or 0) >= 250
end

local function var_0_71(arg_22_0)
	if type(arg_22_0) ~= "table" then
		return nil
	end

	local area = arg_22_0.area

	if (arg_22_0.id == 22 or arg_22_0.id == 23 or arg_22_0.id == 260) and var_0_70(2) then
		return arg_22_0.id == 22 and SpellAreas.AREA_WIDE_BEAM5 or SpellAreas.AREA_WIDE_BEAM8
	end

	if arg_22_0.id == 59 and var_0_69("spell_1") >= 2 then
		return SpellAreas.AREA_AUGMENTED_FRONT_SWEEP
	end

	if arg_22_0.id == 13 and var_0_69("spell_4") >= 1 then
		return SpellAreas.AREA_SQUAREWAVE6
	end

	if arg_22_0.id == 43 and var_0_69("spell_5") >= 2 then
		return SpellAreas.AREA_SQUAREWAVE6
	end

	if arg_22_0.id == 287 and var_0_69("spell_5") >= 1 then
		return SpellAreas.AREA_GREATER_FLURRYWAVE or area
	end

	return area
end

local function playerCanUseAttackSpell(spellData)
	if not spellData then
		return false
	end

	local player = g_game.getLocalPlayer()

	if player then
		local level = spellData.level

		if level and level > player:getLevel() then
			return false
		end
	end

	local var_23_2 = var_0_44[spellData.id]

	if var_23_2 and not var_0_70(var_23_2) then
		return false
	end

	return playerCanUseSpellVocations(spellData.vocations)
end

function HelperShooter.isWheelSpellUnlocked(arg_24_0)
	local var_24_0 = var_0_44[tonumber(arg_24_0)]

	return not var_24_0 or var_0_70(var_24_0)
end

local function playerCanUseAttackRune(runeData)
	if not runeData then
		return false
	end

	local spellData = Spells.getSpellDataById(runeData.id)

	if not spellData then
		return false
	end

	local player = g_game.getLocalPlayer()

	if not player then
		return false
	end

	if spellData.level and player:getLevel() < spellData.level then
		return false
	end

	if spellData.maglevel and player.getMagicLevel and player:getMagicLevel() < spellData.maglevel then
		return false
	end

	return true
end

local function isHelperAttackRune(itemId, runeData)
	if not runeData or tonumber(runeData.group) ~= 1 then
		return false
	end

	local name = (runeData.name or ""):lower()

	if name:find("field", 1, true) or name:find("wall", 1, true) or name:find("bomb", 1, true) or name:find("paralyze", 1, true) or name:find("wild growth", 1, true) then
		return false
	end

	return Spells.getRuneSpellByItem(itemId) ~= nil
end

local function getSpellProfile()
	if SpelllistSettings and SpelllistSettings.Default then
		return "Default"
	end

	if SpelllistSettings then
		for profile in pairs(SpelllistSettings) do
			return profile
		end
	end

	return "Default"
end

local function getMagicalArchivesPreviewPlayer()
	local cyclopedia

	if type(modules) == "table" and modules.game_cyclopedia and type(modules.game_cyclopedia.Cyclopedia) == "table" then
		cyclopedia = modules.game_cyclopedia.Cyclopedia
	elseif type(Cyclopedia) == "table" then
		cyclopedia = Cyclopedia
	end

	local preview = cyclopedia and cyclopedia.MagicalArchivesPreview

	if type(preview) == "table" and preview.play and preview.stop then
		return preview
	end

	return nil
end

local function readAssignJsonFile(file)
	if not g_resources or not g_resources.fileExists or not g_resources.fileExists(file) then
		return nil
	end

	if not json or not json.decode then
		return nil
	end

	local ok, result = pcall(function()
		return json.decode(g_resources.readFileContents(file))
	end)

	if ok and type(result) == "table" then
		return result
	end

	if g_logger and g_logger.warning then
		g_logger.warning("[HelperShooter] failed to read spell preview data: " .. tostring(result))
	end

	return nil
end

local function normalizeAssignSpellPreviewName(name)
	return tostring(name or ""):lower():gsub("[^%w]+", "")
end

local function getAssignSpellPreviews()
	if assignSpellPreviewById ~= nil and assignSpellPreviewByName ~= nil then
		return assignSpellPreviewById, assignSpellPreviewByName
	end

	assignSpellPreviewById = {}
	assignSpellPreviewByName = {}

	local previews = readAssignJsonFile(MAGICAL_ARCHIVES_PREVIEW_FILE)

	if type(previews) ~= "table" then
		return assignSpellPreviewById, assignSpellPreviewByName
	end

	for key, preview in pairs(previews) do
		if type(preview) == "table" then
			local spellId = tonumber(preview.spellid or key)

			if spellId then
				assignSpellPreviewById[spellId] = preview
			end

			local normalizedName = normalizeAssignSpellPreviewName(preview.name)

			if normalizedName ~= "" then
				assignSpellPreviewByName[normalizedName] = preview
			end
		end
	end

	return assignSpellPreviewById, assignSpellPreviewByName
end

local function getAssignSpellPreview(spellId, spellName)
	local previewsById, previewsByName = getAssignSpellPreviews()
	local previewById = previewsById[spellId]
	local normalizedName = normalizeAssignSpellPreviewName(spellName)

	if previewById and normalizeAssignSpellPreviewName(previewById.name) == normalizedName then
		return previewById
	end

	return previewsByName[normalizedName] or previewById
end

local function assignPreviewHasActions(preview)
	local player = getMagicalArchivesPreviewPlayer()

	if player and player.hasActions then
		return player.hasActions(preview)
	end

	if type(preview) ~= "table" then
		return false
	end

	if type(preview.initActions) == "table" and #preview.initActions > 0 then
		return true
	end

	if type(preview.timestamps) == "table" then
		for _, timestamp in ipairs(preview.timestamps) do
			if type(timestamp) == "table" and type(timestamp.actions) == "table" and #timestamp.actions > 0 then
				return true
			end
		end
	end

	return false
end

local function getAssignPreviewFrame()
	if not assignSpellWindow or assignSpellWindow:isDestroyed() then
		return nil
	end

	return assignSpellWindow:recursiveGetChildById("spellPreviewFrame")
end

local function assignPreviewFrameHasChildren(frame)
	return frame and frame.getChildren and #frame:getChildren() > 0
end

local function clearAssignPreviewFrame(frame, keepVisible)
	frame = frame or getAssignPreviewFrame()

	if not frame or frame:isDestroyed() then
		if activeAssignPreviewFrame == frame then
			activeAssignPreviewFrame = nil
		end

		return
	end

	local player = getMagicalArchivesPreviewPlayer()

	if player and activeAssignPreviewFrame == frame and frame:isVisible() and assignPreviewFrameHasChildren(frame) then
		player.stop()
	else
		frame:destroyChildren()
	end

	if frame and not frame:isDestroyed() then
		frame:setVisible(keepVisible == true)
	end

	if activeAssignPreviewFrame == frame then
		activeAssignPreviewFrame = nil
	end
end

local function buildAssignPreviewSpell(spellId, name, words, isRune)
	spellId = tonumber(spellId)

	if not spellId then
		return nil
	end

	local preview = getAssignSpellPreview(spellId, name)

	if not assignPreviewHasActions(preview) then
		return nil
	end

	return {
		hasPreview = true,
		id = spellId,
		name = name or "Unknown",
		words = words or "",
		isRune = isRune == true,
		preview = preview
	}
end

local function playAssignPreview(frame, spell)
	frame = frame or getAssignPreviewFrame()

	if not frame or frame:isDestroyed() then
		return
	end

	local player = getMagicalArchivesPreviewPlayer()

	if not player or not spell then
		clearAssignPreviewFrame(frame, true)

		return
	end

	local ok, err = pcall(function()
		player.play(frame, spell)
	end)

	if ok then
		activeAssignPreviewFrame = frame
	else
		if g_logger and g_logger.warning then
			g_logger.warning("[HelperShooter] spell preview failed for \"" .. tostring(spell.name) .. "\": " .. tostring(err))
		end

		clearAssignPreviewFrame(frame, true)
	end
end

local function getSpellInfoByName(spellProfile, spellName)
	if type(SpellInfo) ~= "table" or not spellName then
		return nil
	end

	local profileSpells = SpellInfo[spellProfile]

	if type(profileSpells) ~= "table" then
		return nil
	end

	return profileSpells[spellName]
end

local function isShooterAssignableSpell(spellData)
	if not spellData or ignoredSpellsIds[spellData.id] then
		return false
	end

	if var_0_38[spellData.id] then
		return true
	end

	if spellData.id == 279 then
		return true
	end

	local groups = Spells.getGroupIds(spellData)

	for _, groupId in ipairs({
		1,
		4,
		8
	}) do
		if table.contains(groups, groupId) then
			return true
		end
	end

	if spellData.special and table.contains(groups, 3) then
		return true
	end

	return false
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

local function getEntityPosition(entity)
	if not isMapCreature(entity) then
		return nil
	end

	local pos = entity:getPosition()

	if not pos or pos.x == nil or pos.y == nil or pos.z == nil then
		return nil
	end

	return pos
end

local function isShooterFamiliar(creature)
	if HelperTarget and HelperTarget.isExcludedCombatCreature then
		return HelperTarget.isExcludedCombatCreature(creature)
	end

	return HelperTarget and HelperTarget.isFamiliar and HelperTarget.isFamiliar(creature) or false
end

local function isOffensiveTarget(creature)
	if not isMapCreature(creature) or creature:isDead() then
		return false
	end

	if not creature.isMonster or not creature:isMonster() then
		return false
	end

	if creature.isNpc and creature:isNpc() then
		return false
	end

	if isShooterFamiliar(creature) then
		return false
	end

	return true
end

local function isOffensiveTargetInRange(creature, position, minDist, maxDist)
	if not isOffensiveTarget(creature) then
		return false
	end

	local cPos = getEntityPosition(creature)

	if not cPos or cPos.z ~= position.z then
		return false
	end

	if not HelperTarget.isWithinDistance(position, cPos, minDist, maxDist) then
		return false
	end

	if not g_map.isSightClear(position, cPos) then
		return false
	end

	return true
end

local function buildOffensiveCreatureList(position, minDist, maxDist)
	local spectators = g_map.getSpectators(position, false) or {}
	local creatureList = {}
	local positionIndex = {}

	for _, creature in ipairs(spectators) do
		if isOffensiveTarget(creature) then
			local cPos = getEntityPosition(creature)

			if cPos and cPos.z == position.z and HelperTarget.isWithinDistance(position, cPos, minDist, maxDist) and g_map.isSightClear(position, cPos) then
				local entry = {
					position = cPos,
					creature = creature
				}

				table.insert(creatureList, entry)

				local column = positionIndex[cPos.x]

				if not column then
					column = {}
					positionIndex[cPos.x] = column
				end

				local occupants = column[cPos.y]

				if not occupants then
					occupants = {}
					column[cPos.y] = occupants
				end

				table.insert(occupants, entry)
			end
		end
	end

	creatureList.positionIndex = positionIndex

	return creatureList
end

local function getShooterCombatTarget(position, minDist, maxDist)
	local current = g_game.getAttackingCreature()

	if isOffensiveTargetInRange(current, position, minDist, maxDist) then
		return current
	end

	return nil
end

local function resolveSpellIconId(spell)
	if not spell then
		return 0
	end

	local id = SpellIcons[spell.id]

	return tonumber(id) or 0
end

local function spellUsesHarmonyById(spellId)
	local spell = spellId and Spells.getSpellDataById(spellId)

	return spell and spell.useHarmony == true
end

local function clampCreatures(value)
	if type(value) == "table" then
		value = value.text
	end

	local n = tonumber(tostring(value or ""):match("%d+")) or 1

	if n < 1 then
		return 1
	end

	if n > 12 then
		return 12
	end

	return n
end

local function clampHarmony(value)
	if type(value) == "table" then
		value = value.text
	end

	local n = tonumber(tostring(value or ""):match("%d+")) or 1

	if n < 1 then
		return 1
	end

	if n > 5 then
		return 5
	end

	return n
end

local function formatHarmonyOption(value, arg_54_1)
	local var_54_0 = var_0_38[tonumber(arg_54_1)]
	local var_54_1 = var_54_0 and var_54_0.defaultIntervalMs or 2000
	local var_54_2 = math.floor(tonumber(value) or var_54_1)

	return math.max(1000, math.min(60000, var_54_2))
end

local function var_0_101(text, value)
	if type(text) == "table" then
		text = text.text
	end

	local s = tonumber(tostring(text or ""):match("%d+"))

	return formatHarmonyOption(s and s * 1000 or nil, value)
end

local function var_0_102(arg_56_0, arg_56_1)
	return tostring(math.floor(formatHarmonyOption(arg_56_0, arg_56_1) / 1000))
end

local function var_0_103(value)
	local harmony = clampHarmony(value)

	return harmony >= 5 and "5" or tostring(harmony) .. "+"
end

local function normalizeUseToOption(value)
	if type(value) == "table" then
		value = value.text
	end

	local s = tostring(value or "")

	if s == "Yourself" then
		return "self"
	end

	if s == "Best Position" then
		return "bestTile"
	end

	return "target"
end

local function migratePriorityEntry(entry)
	if type(entry) ~= "table" then
		return nil
	end

	local creatures = clampCreatures(entry.creatures)

	if entry.type == "spell" and entry.id and entry.id > 0 then
		return {
			type = "spell",
			id = entry.id,
			enabled = entry.enabled ~= false,
			hpMin = tonumber(entry.hpMin) or 0,
			hpMax = tonumber(entry.hpMax) or 100,
			rangeMin = tonumber(entry.rangeMin) or 1,
			rangeMax = tonumber(entry.rangeMax) or 7,
			creatures = creatures,
			forceCast = entry.forceCast == true,
			useTo = entry.useTo or entry.selfCast == true and "self" or "target"
		}
	end

	if entry.type == "rune" and entry.id and entry.id > 0 then
		return {
			type = "rune",
			id = entry.id,
			enabled = entry.enabled ~= false,
			hpMin = tonumber(entry.hpMin) or 0,
			hpMax = tonumber(entry.hpMax) or 100,
			rangeMin = tonumber(entry.rangeMin) or 1,
			rangeMax = tonumber(entry.rangeMax) or 7,
			creatures = creatures,
			forceCast = entry.forceCast == true,
			useTo = entry.useTo or entry.selfCast == true and "self" or "target"
		}
	end

	if entry.isRune and entry.itemId and entry.itemId > 0 then
		return {
			type = "rune",
			id = entry.itemId,
			enabled = entry.enabled ~= false,
			hpMin = tonumber(entry.hpMin) or 0,
			hpMax = tonumber(entry.hpMax) or 100,
			rangeMin = tonumber(entry.rangeMin) or 1,
			rangeMax = tonumber(entry.rangeMax) or 7,
			creatures = creatures,
			forceCast = entry.forceCast == true,
			useTo = entry.useTo or entry.selfCast == true and "self" or "target"
		}
	end

	if entry.spellName then
		local spellProfile = getSpellProfile()
		local info = getSpellInfoByName(spellProfile, entry.spellName)

		if info and info.id then
			return {
				type = "spell",
				id = info.id,
				enabled = entry.enabled ~= false,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				rangeMin = tonumber(entry.rangeMin) or 1,
				rangeMax = tonumber(entry.rangeMax) or 7,
				creatures = creatures,
				forceCast = entry.forceCast == true,
				useTo = entry.useTo or entry.selfCast == true and "self" or "target"
			}
		end
	end

	if entry.id and entry.id > 0 and not entry.type then
		if SpellRunesData and SpellRunesData[entry.id] then
			return {
				type = "rune",
				id = entry.id,
				enabled = entry.enabled ~= false,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				rangeMin = tonumber(entry.rangeMin) or 1,
				rangeMax = tonumber(entry.rangeMax) or 7,
				creatures = creatures,
				forceCast = entry.forceCast == true,
				useTo = entry.useTo or entry.selfCast == true and "self" or "target"
			}
		end

		if Spells.getSpellDataById(entry.id) then
			return {
				type = "spell",
				id = entry.id,
				enabled = entry.enabled ~= false,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				rangeMin = tonumber(entry.rangeMin) or 1,
				rangeMax = tonumber(entry.rangeMax) or 7,
				creatures = creatures,
				forceCast = entry.forceCast == true,
				useTo = entry.useTo or entry.selfCast == true and "self" or "target"
			}
		end
	end

	return nil
end

local function sanitizePriorityList(priorityList)
	local sanitized = {}
	local list = type(priorityList) == "table" and priorityList or {}

	for _, entry in ipairs(list) do
		local migrated = migratePriorityEntry(entry)

		if migrated then
			if var_0_42(migrated) then
				migrated.useTo = "target"
			end

			if migrated.type == "spell" and spellUsesHarmonyById(migrated.id) then
				migrated.harmony = clampHarmony(entry.harmony)
			else
				migrated.harmony = nil
			end

			if migrated.type == "spell" then
				migrated.turnToCast = entry.turnToCast == true
				migrated.intervalMs = var_0_38[migrated.id] and formatHarmonyOption(entry.intervalMs, migrated.id) or nil
			end

			migrated.onlyWhenAlone = entry.onlyWhenAlone == true or nil

			table.insert(sanitized, migrated)
		end
	end

	return sanitized
end

local function normalizeProfile(profile)
	if not profile or type(profile) ~= "table" then
		return
	end

	local merged = {}

	for _, spellEntry in ipairs(type(profile.spells) == "table" and profile.spells or {}) do
		if type(spellEntry) == "table" and spellEntry.id and spellEntry.id > 0 then
			table.insert(merged, {
				sortKey = tonumber(spellEntry.priority) or 999,
				entry = {
					type = "spell",
					id = spellEntry.id,
					enabled = spellEntry.enabled ~= false,
					hpMin = tonumber(spellEntry.hpMin) or 0,
					hpMax = tonumber(spellEntry.hpMax) or 100,
					rangeMin = tonumber(spellEntry.rangeMin) or 1,
					rangeMax = tonumber(spellEntry.rangeMax) or 7,
					creatures = clampCreatures(spellEntry.creatures),
					harmony = tonumber(spellEntry.harmony),
					intervalMs = spellEntry.intervalMs,
					forceCast = spellEntry.forceCast == true,
					useTo = spellEntry.useTo or spellEntry.selfCast == true and "self" or "target"
				}
			})
		end
	end

	for _, runeEntry in ipairs(type(profile.runes) == "table" and profile.runes or {}) do
		if type(runeEntry) == "table" and runeEntry.id and runeEntry.id > 0 then
			table.insert(merged, {
				sortKey = tonumber(runeEntry.priority) or 999,
				entry = {
					type = "rune",
					id = runeEntry.id,
					enabled = runeEntry.enabled ~= false,
					hpMin = tonumber(runeEntry.hpMin) or 0,
					hpMax = tonumber(runeEntry.hpMax) or 100,
					rangeMin = tonumber(runeEntry.rangeMin) or 1,
					rangeMax = tonumber(runeEntry.rangeMax) or 7,
					creatures = clampCreatures(runeEntry.creatures),
					forceCast = runeEntry.forceCast == true,
					useTo = runeEntry.useTo or runeEntry.selfCast == true and "self" or "target"
				}
			})
		end
	end

	table.sort(merged, function(a, b)
		return a.sortKey < b.sortKey
	end)

	if #merged > 0 then
		profile.priorityList = {}

		for _, item in ipairs(merged) do
			table.insert(profile.priorityList, item.entry)
		end
	elseif not profile.priorityList then
		profile.priorityList = {}
	end

	profile.priorityList = sanitizePriorityList(profile.priorityList)
	profile.hotkey = type(profile.hotkey) == "string" and profile.hotkey ~= "" and profile.hotkey or nil
	profile.spells = nil
	profile.runes = nil
	profile.autoTargetMode = nil
end

local function ensureProfiles()
	if type(shooterState.shooterProfiles) ~= "table" or not next(shooterState.shooterProfiles) then
		shooterState.shooterProfiles = {
			Default = deepCopy(defaultShooterProfile)
		}
	end

	for name, profile in pairs(shooterState.shooterProfiles) do
		if type(profile) ~= "table" then
			shooterState.shooterProfiles[name] = deepCopy(defaultShooterProfile)
		else
			normalizeProfile(profile)
		end
	end

	if not shooterState.selectedShooterProfile or not shooterState.shooterProfiles[shooterState.selectedShooterProfile] then
		if shooterState.shooterProfiles.Default then
			shooterState.selectedShooterProfile = "Default"
		else
			local names = {}

			for name in pairs(shooterState.shooterProfiles) do
				table.insert(names, name)
			end

			table.sort(names)

			shooterState.selectedShooterProfile = names[1]
		end
	end
end

local function getShooterProfile()
	ensureProfiles()

	return shooterState.shooterProfiles[shooterState.selectedShooterProfile] or defaultShooterProfile
end

local function getShooterProfileCount()
	ensureProfiles()

	local count = 0

	for _ in pairs(shooterState.shooterProfiles) do
		count = count + 1
	end

	return count
end

local function actionbarSpellCooldownRemaining(spell)
	local ab = actionbar()

	if not ab or not ab.getMultiActionCooldownRemaining or type(spell) ~= "table" then
		return 0, 0
	end

	local spellRem, groupRem = ab.getMultiActionCooldownRemaining(spell)

	return tonumber(spellRem) or 0, tonumber(groupRem) or 0
end

local function actionbarItemMultiUseRemaining()
	local ab = actionbar()

	if ab and ab.getItemMultiUseCooldownRemaining then
		return tonumber(ab.getItemMultiUseCooldownRemaining()) or 0
	end

	return 0
end

local function clearShooterCooldownState()
	spellPendingSince = {}
	groupPendingSince = {}
	multiUsePendingSince = 0
	lastGlobalCastAt = 0
	var_0_41 = {}
end

function HelperShooter.onSpellCooldown(spellId, duration)
	return
end

function HelperShooter.onSpellGroupCooldown(groupId, duration)
	return
end

function HelperShooter.onMultiUseCooldown(duration)
	multiUsePendingSince = 0
end

local CAST_CONFIRM_TIMEOUT_MS = 2000

local function pendingConfirmActive(sinceMs, nowMs)
	sinceMs = sinceMs or 0

	return sinceMs > 0 and nowMs - sinceMs < CAST_CONFIRM_TIMEOUT_MS
end

local function isSpellOnCooldown(spell, nowMs)
	if type(spell) ~= "table" or not spell.id then
		return false
	end

	nowMs = nowMs or g_clock.millis()

	local spellRem, groupRem = actionbarSpellCooldownRemaining(spell)

	if spellRem > 0 then
		spellPendingSince[spell.id] = nil
	end

	if groupRem > 0 then
		if type(spell.group) == "table" then
			for groupId in pairs(spell.group) do
				groupPendingSince[groupId] = nil
			end
		elseif spell.group then
			groupPendingSince[spell.group] = nil
		end
	end

	if spellRem > 0 or groupRem > 0 then
		return true
	end

	if pendingConfirmActive(spellPendingSince[spell.id], nowMs) then
		return true
	end

	if type(spell.group) == "table" then
		for groupId in pairs(spell.group) do
			if pendingConfirmActive(groupPendingSince[groupId], nowMs) then
				return true
			end
		end
	elseif spell.group and pendingConfirmActive(groupPendingSince[spell.group], nowMs) then
		return true
	end

	return false
end

local function isMultiUseOnCooldown(nowMs)
	nowMs = nowMs or g_clock.millis()

	if actionbarItemMultiUseRemaining() > 0 then
		multiUsePendingSince = 0

		return true
	end

	return pendingConfirmActive(multiUsePendingSince, nowMs) or HelperHealer and HelperHealer.isItemUsePending and HelperHealer.isItemUsePending() or false
end

function HelperShooter.isItemUsePending()
	return pendingConfirmActive(multiUsePendingSince, g_clock.millis())
end

local function applyLocalCastLock(spell)
	if type(spell) ~= "table" then
		return
	end

	local now = g_clock.millis()

	if spell.id then
		spellPendingSince[spell.id] = now
	end

	if type(spell.group) == "table" then
		for groupId in pairs(spell.group) do
			groupPendingSince[groupId] = now
		end
	elseif spell.group then
		groupPendingSince[spell.group] = now
	end
end

local function getRuneAreaByItemId(itemId)
	if type(SpellAreas) ~= "table" then
		return nil
	end

	return ({
		[3161] = SpellAreas.AREA_CIRCLE3X3,
		[3191] = SpellAreas.AREA_CIRCLE3X3,
		[3202] = SpellAreas.AREA_CIRCLE3X3,
		[3175] = SpellAreas.AREA_CIRCLE3X3,
		[3192] = SpellAreas.AREA_CIRCLE1X1,
		[3149] = SpellAreas.AREA_CIRCLE1X1,
		[3173] = SpellAreas.AREA_CIRCLE1X1,
		[3200] = SpellAreas.AREA_CIRCLE1X1,
		[21351] = SpellAreas.AREA_CIRCLE1X1
	})[itemId]
end

local function getRuneUsageSpell(itemId)
	if not itemId or itemId <= 0 then
		return nil
	end

	local runeSpell = Spells.getRuneUsageSpell and Spells.getRuneUsageSpell(itemId)

	if not runeSpell then
		return nil
	end

	local runeSpell = {
		id = runeSpell.id,
		name = runeSpell.name,
		icon = runeSpell.icon,
		group = runeSpell.group,
		exhaustion = runeSpell.exhaustion,
		area = getRuneAreaByItemId(itemId)
	}
	local conjureSpell = Spells.getSpellDataById(runeSpell.id)

	if conjureSpell then
		runeSpell.range = conjureSpell.range
	end

	return runeSpell
end

function HelperShooter.isSingleTargetSpell(arg_79_0)
	if type(arg_79_0) ~= "table" or var_0_38[arg_79_0.id] then
		return false
	end

	if arg_79_0.crossHairTarget == true or arg_79_0.directional == true then
		return false
	end

	if type(var_0_71(arg_79_0)) == "table" then
		return false
	end

	return arg_79_0.needTarget ~= false or (tonumber(arg_79_0.range) or 0) > 0
end

function HelperShooter.isSingleTargetAction(arg_80_0, arg_80_1)
	if type(arg_80_0) ~= "table" or not arg_80_0.id or (arg_80_1 or "target") ~= "target" then
		return false
	end

	if arg_80_0.type == "spell" then
		return arg_80_0.id ~= var_0_39 and HelperShooter.isSingleTargetSpell(Spells.getSpellDataById(arg_80_0.id))
	end

	return arg_80_0.type == "rune" and type(getRuneAreaByItemId(arg_80_0.id)) ~= "table"
end

local function clampPercent(text, fallback)
	if type(text) == "table" then
		text = text.text
	end

	local n = tonumber(text) or fallback or 0

	if n < 0 then
		return 0
	end

	if n > 100 then
		return 100
	end

	return n
end

local function normalizeHpRange(entry)
	local hpMin = clampPercent(entry and entry.hpMin, 0)
	local hpMax = clampPercent(entry and entry.hpMax, 100)

	if hpMax < hpMin then
		hpMin, hpMax = hpMax, hpMin
	end

	return hpMin, hpMax
end

local function isTargetHpWithinRange(config, target)
	if not target or not target.getHealthPercent then
		return true
	end

	local hp = target:getHealthPercent()

	if hp == nil then
		return true
	end

	local hpMin, hpMax = normalizeHpRange(config)

	return hpMin <= hp and hp <= hpMax
end

local function debugLog(msg)
	if g_logger and g_logger.debug then
		g_logger.debug("[Shooter] " .. msg)
	end
end

local function findBestTileForRune(position, direction, runeArea, runeUsage, creatureList, combatTarget)
	if type(runeArea) ~= "table" then
		return nil, 0
	end

	local areaH = #runeArea
	local areaW = areaH > 0 and #(runeArea[1] or {}) or 0
	local radius = math.floor(math.max(areaH, areaW) / 2)
	local bestPos
	local bestHits = 0
	local bestDist = math.huge
	local seen = {}
	local targetPos = combatTarget and getEntityPosition(combatTarget) or nil

	local function evalCandidate(x, y, z)
		local seenColumn = seen[x]

		if not seenColumn then
			seenColumn = {}
			seen[x] = seenColumn
		elseif seenColumn[y] then
			return
		end

		seenColumn[y] = true

		if z ~= position.z then
			return
		end

		local p = {
			x = x,
			y = y,
			z = z
		}
		local inRange

		if runeUsage.range and runeUsage.range > 0 then
			inRange = HelperTarget.getDistanceBetween(position, p) <= runeUsage.range
		else
			inRange = HelperTarget.isWithinReach(position, p)
		end

		if not inRange then
			return
		end

		if not g_map.isSightClear(position, p) then
			return
		end

		local hits = HelperTarget.countAttackableCreatures(p, direction, runeArea, creatureList, true)
		local dist = targetPos and HelperTarget.getDistanceBetween(p, targetPos) or HelperTarget.getDistanceBetween(p, position)

		if hits > bestHits or hits == bestHits and dist < bestDist then
			bestHits = hits
			bestDist = dist
			bestPos = p
		end
	end

	for _, entry in ipairs(creatureList) do
		local p = entry.position

		if p then
			for dy = -radius, radius do
				for dx = -radius, radius do
					evalCandidate(p.x + dx, p.y + dy, p.z)
				end
			end
		end
	end

	return bestPos, bestHits
end

local CARDINAL_DIRECTIONS = {
	Directions.North,
	Directions.East,
	Directions.South,
	Directions.West
}

local function bestAreaDirection(position, area, creatureList, currentDirection, currentHits)
	local bestDir = currentDirection
	local bestHits = currentHits

	if bestHits == nil then
		bestHits = HelperTarget.countAttackableCreatures(position, currentDirection, area, creatureList, true)
	end

	for _, dir in ipairs(CARDINAL_DIRECTIONS) do
		if dir ~= currentDirection then
			local hits = HelperTarget.countAttackableCreatures(position, dir, area, creatureList, true)

			if bestHits < hits then
				bestHits = hits
				bestDir = dir
			end
		end
	end

	return bestDir, bestHits
end

local function tryCastPrioritySpell(config, ctx)
	local player = ctx.player
	local position = ctx.position
	local direction = ctx.direction
	local creatureList = ctx.creatureList
	local nowMs = ctx.nowMs
	local combatTarget = ctx.combatTarget
	local spell = Spells.getSpellDataById(config.id)

	if not spell then
		return false
	end

	if HelperHealer and HelperHealer.shouldYieldToHealing and HelperHealer.shouldYieldToHealing(player, spell.mana) then
		return false
	end

	if not playerCanUseAttackSpell(spell) then
		debugLog("Skip " .. tostring(spell.words) .. ": spell is not available in the active Wheel/level")

		return false
	end

	local var_88_7 = var_0_71(spell)
	local var_88_8 = var_0_38[spell.id]

	if var_88_8 then
		local var_88_9 = formatHarmonyOption(config.intervalMs, spell.id)
		local var_88_10 = var_0_41[spell.id] or 0

		if var_88_10 > 0 and var_88_9 > nowMs - var_88_10 then
			debugLog(string.format("Skip %s: timer has %d ms remaining", spell.words, var_88_9 - (nowMs - var_88_10)))

			return false
		end

		local var_88_11 = #creatureList

		if var_88_8.minRange then
			var_88_11 = 0

			for unusedValue, entry in ipairs(creatureList) do
				if entry.position then
					local distanceBetween = HelperTarget.getDistanceBetween(position, entry.position)

					if distanceBetween >= var_88_8.minRange and distanceBetween <= var_88_8.range then
						var_88_11 = var_88_11 + 1
					end
				end
			end
		end

		local var_88_13 = config.forceCast and 1 or clampCreatures(config.creatures)

		if var_88_11 < var_88_13 then
			debugLog(string.format("Skip %s: %d creatures in range < %d required", spell.words, var_88_11, var_88_13))

			return false
		end
	end

	if spell.mana and player:getMana() < spell.mana then
		debugLog("Skip " .. spell.words .. ": not enough mana")

		return false
	end

	if spell.soul and player:getSoul() < spell.soul then
		debugLog("Skip " .. spell.words .. ": not enough soul")

		return false
	end

	if isSpellOnCooldown(spell, nowMs) then
		debugLog("Skip " .. spell.words .. ": on cooldown")

		return false
	end

	if spell.useHarmony == true then
		local var_88_14 = clampHarmony(config.harmony)
		local harmony = player.getHarmony and player:getHarmony() or 0

		if harmony < var_88_14 then
			debugLog(string.format("Skip %s: harmony %d < %d required", spell.words, harmony, var_88_14))

			return false
		end
	end

	local isSelfCast = config.useTo == "self" or not config.useTo and config.selfCast == true
	local isCrossHairSpell = spell.crossHairTarget == true
	local isSingleTargetRanged = (tonumber(spell.range) or 0) > 0 and type(var_88_7) ~= "table" and spell.directional ~= true

	if not isSelfCast and not isCrossHairSpell and spell.directional ~= true and (spell.needTarget ~= false or isSingleTargetRanged) then
		if not isMapCreature(combatTarget) then
			return false
		end

		if not isTargetHpWithinRange(config, combatTarget) then
			debugLog("Skip " .. spell.words .. ": target HP outside configured range")

			return false
		end

		local attackPos = getEntityPosition(combatTarget)

		if not attackPos then
			return false
		end

		if not g_map.isSightClear(position, attackPos) then
			debugLog("Skip " .. spell.words .. ": no line of sight")

			return false
		end

		if spell.range and spell.range > 0 then
			if HelperTarget.getDistanceBetween(position, attackPos) > spell.range then
				debugLog("Skip " .. spell.words .. ": out of range")

				return false
			end
		elseif not HelperTarget.isWithinReach(position, attackPos) then
			debugLog("Skip " .. spell.words .. ": out of reach")

			return false
		end

		if spell.id == var_0_39 then
			local var_88_20 = clampCreatures(config.creatures)

			if var_88_20 > #creatureList and not config.forceCast then
				debugLog(string.format("Skip %s: %d monsters nearby < %d required", spell.words, #creatureList, var_88_20))

				return false
			end
		end

		if spell.id ~= var_0_39 and config.onlyWhenAlone == true and #creatureList > 1 and HelperShooter.isSingleTargetSpell(spell) then
			debugLog(string.format("Skip %s: %d monsters around, Cast with 1+ is off", spell.words, #creatureList))

			return false
		end
	end

	if isCrossHairSpell then
		local useTo = config.useTo or "target"
		local castPos

		if useTo == "bestTile" then
			if isMapCreature(combatTarget) and not isTargetHpWithinRange(config, combatTarget) then
				debugLog("Skip " .. spell.words .. ": target HP outside configured range")

				return false
			end

			if type(var_88_7) == "table" then
				local spellUsage = {
					range = spell.range
				}
				local bestPos, bestHits = findBestTileForRune(position, direction, var_88_7, spellUsage, creatureList, combatTarget)

				if not bestPos then
					debugLog("Skip " .. spell.words .. ": no valid Best Position candidate")

					return false
				end

				if bestHits < (config.creatures or 1) and not config.forceCast then
					debugLog(string.format("Skip %s: best position %d hits < %d required", spell.words, bestHits, config.creatures or 1))

					return false
				end

				castPos = bestPos
			else
				if not isMapCreature(combatTarget) then
					return false
				end

				castPos = getEntityPosition(combatTarget)
			end
		elseif useTo == "self" then
			castPos = position
		else
			if not isMapCreature(combatTarget) then
				return false
			end

			if not isTargetHpWithinRange(config, combatTarget) then
				debugLog("Skip " .. spell.words .. ": target HP outside configured range")

				return false
			end

			castPos = getEntityPosition(combatTarget)

			if not castPos then
				return false
			end
		end

		if not castPos then
			return false
		end

		if not g_map.isSightClear(position, castPos) then
			debugLog("Skip " .. spell.words .. ": no line of sight to cast position")

			return false
		end

		if spell.range and spell.range > 0 and HelperTarget.getDistanceBetween(position, castPos) > spell.range then
			debugLog("Skip " .. spell.words .. ": cast position out of spell range")

			return false
		end

		if useTo ~= "bestTile" and type(var_88_7) == "table" then
			local creaturesInArea = HelperTarget.countAttackableCreatures(castPos, direction, var_88_7, creatureList, true)

			if creaturesInArea < (config.creatures or 1) and not config.forceCast then
				debugLog(string.format("Skip %s: %d creatures in area < %d required", spell.words, creaturesInArea, config.creatures or 1))

				return false
			end
		end

		if g_game.talkSpell then
			g_game.talkSpell(spell.words, 1, castPos)
		else
			g_game.talk(spell.words, true)
		end

		applyLocalCastLock(spell)

		if var_88_8 then
			var_0_41[spell.id] = nowMs
		end

		lastGlobalCastAt = nowMs

		return true
	end

	if type(var_88_7) == "table" then
		local required = config.creatures or 1
		local creaturesInArea = HelperTarget.countAttackableCreatures(position, direction, var_88_7, creatureList, true)

		if config.turnToCast == true and spell.directional == true then
			local bestDir, bestHits = bestAreaDirection(position, var_88_7, creatureList, direction, creaturesInArea)

			if bestDir ~= direction and creaturesInArea < bestHits and required <= bestHits then
				g_game.turn(bestDir)

				local direction = bestDir

				creaturesInArea = bestHits
			end
		end

		if creaturesInArea < required and not config.forceCast then
			debugLog(string.format("Skip %s: %d creatures in area < %d required", spell.words, creaturesInArea, required))

			return false
		end
	end

	g_game.talk(spell.words, true)
	applyLocalCastLock(spell)

	if var_88_8 then
		var_0_41[spell.id] = nowMs
	end

	lastGlobalCastAt = nowMs

	return true
end

local function isRuneTargetInRange(position, targetPos, runeUsage)
	if not targetPos or not g_map.isSightClear(position, targetPos) then
		return false
	end

	if runeUsage.range and runeUsage.range > 0 then
		return HelperTarget.getDistanceBetween(position, targetPos) <= runeUsage.range
	end

	return HelperTarget.isWithinReach(position, targetPos)
end

local function tryCastPriorityRune(config, ctx)
	local player = ctx.player
	local position = ctx.position
	local direction = ctx.direction
	local creatureList = ctx.creatureList
	local nowMs = ctx.nowMs
	local combatTarget = ctx.combatTarget
	local runeUsage = getRuneUsageSpell(config.id)

	if not runeUsage then
		return false
	end

	local runeName = runeUsage.name or "Rune #" .. config.id

	if player:getInventoryCount(config.id) <= 0 then
		debugLog("Skip rune " .. runeName .. ": not in inventory")

		return false
	end

	if isMultiUseOnCooldown(nowMs) then
		debugLog("Skip rune " .. runeName .. ": multi-use cooldown")

		return false
	end

	if isSpellOnCooldown(runeUsage, nowMs) then
		debugLog("Skip rune " .. runeName .. ": on cooldown")

		return false
	end

	local useTo = var_0_42(config) and "target" or config.useTo or config.selfCast == true and "self" or "target"
	local profile = runeUsage.area or getRuneAreaByItemId(config.id)
	local topMultiUseThing
	local unusedValue

	if useTo == "bestTile" then
		if isMapCreature(combatTarget) and not isTargetHpWithinRange(config, combatTarget) then
			debugLog("Skip rune " .. runeName .. ": target HP outside configured range")

			return false
		end

		if type(profile) ~= "table" then
			debugLog("Skip rune " .. runeName .. ": no area mapped, cannot use Best Position")

			return false
		end

		local tilePosition, var_90_13 = findBestTileForRune(position, direction, profile, runeUsage, creatureList, combatTarget)

		if not tilePosition then
			debugLog("Skip rune " .. runeName .. ": no valid Best Position candidate")

			return false
		end

		if var_90_13 < (config.creatures or 1) and not config.forceCast then
			debugLog(string.format("Skip rune %s: best position %d hits < %d required", runeName, var_90_13, config.creatures or 1))

			return false
		end

		local tile = g_map.getTile(tilePosition)

		if not tile then
			debugLog("Skip rune " .. runeName .. ": Best Position not in map")

			return false
		end

		topMultiUseThing = tile:getTopMultiUseThing()

		if not topMultiUseThing then
			debugLog("Skip rune " .. runeName .. ": Best Position has no top thing")

			return false
		end

		local unusedValue = tilePosition
	elseif useTo == "self" then
		topMultiUseThing = player

		local var_90_16 = position

		if not topMultiUseThing or not var_90_16 then
			return false
		end

		if type(profile) == "table" then
			local var_90_17 = HelperTarget.countAttackableCreatures(var_90_16, direction, profile, creatureList, true)

			if var_90_17 < (config.creatures or 1) and not config.forceCast then
				debugLog(string.format("Skip rune %s: %d creatures hit < %d required", runeName, var_90_17, config.creatures or 1))

				return false
			end
		end
	else
		if not isMapCreature(combatTarget) then
			return false
		end

		if not isTargetHpWithinRange(config, combatTarget) then
			debugLog("Skip rune " .. runeName .. ": target HP outside configured range")

			return false
		end

		local var_90_18 = getEntityPosition(combatTarget)

		if not var_90_18 then
			return false
		end

		if not isRuneTargetInRange(position, var_90_18, runeUsage) then
			debugLog("Skip rune " .. runeName .. ": target out of range")

			return false
		end

		if type(profile) == "table" then
			local var_90_19 = HelperTarget.countAttackableCreatures(var_90_18, direction, profile, creatureList, true)

			if var_90_19 < (config.creatures or 1) and not config.forceCast then
				debugLog(string.format("Skip rune %s: %d creatures hit < %d required", runeName, var_90_19, config.creatures or 1))

				return false
			end
		elseif config.onlyWhenAlone == true and #creatureList > 1 then
			debugLog(string.format("Skip rune %s: %d monsters around, Cast with 1+ is off", runeName, #creatureList))

			return false
		end

		topMultiUseThing = combatTarget
	end

	g_game.useInventoryItemWith(config.id, topMultiUseThing, 0, true)
	applyLocalCastLock(runeUsage)

	multiUsePendingSince = nowMs
	lastGlobalCastAt = nowMs

	return true
end

local function var_0_131()
	local var_91_0 = widget("checkbox")

	return var_91_0 and var_91_0:isChecked() or false
end

local function var_0_132()
	local helper = modules.game_helper

	if helper and helper.syncCombatSchedulerState then
		helper.syncCombatSchedulerState()
	end
end

local function var_0_133()
	if not var_0_131() then
		return false
	end

	local var_93_0 = widget("enableShooterCheckBox")

	return var_93_0 and var_93_0:isChecked() or false
end

local function var_0_134(checked)
	local var_94_0 = widget("enableShooterCheckBox")

	if var_94_0 and var_94_0:isChecked() ~= checked then
		suppressShooterCheckChange = true

		var_94_0:setChecked(checked)

		suppressShooterCheckChange = false
	end

	hotkeyShooterStatus = checked == true

	if not hotkeyShooterStatus then
		clearShooterCooldownState()
	end
end

local function var_0_135(arg_95_0)
	var_0_134(arg_95_0)
end

local function setShooterCheckEnabled(enabled)
	local var_96_0 = widget("enableShooterCheckBox")

	if var_96_0 and var_96_0.setEnabled then
		var_96_0:setEnabled(enabled == true)
	end
end

local function var_0_137()
	local localPlayer = g_game.getLocalPlayer()

	return not isShooterPzAutoEnabled() and localPlayer and localPlayer.isInProtectionZone and localPlayer:isInProtectionZone() or false
end

local function var_0_138(arg_98_0)
	if not var_0_137() then
		return false
	end

	shooterEnabledBeforePz = false

	var_0_134(false)
	setShooterCheckEnabled(false)

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end

	if not arg_98_0 then
		showFailure(shooterUiLanguage == "pt" and "O Shooter nao pode ser ativado dentro de uma protection zone." or "Shooter cannot be enabled inside a protection zone.")
	end

	return true
end

local function var_0_139()
	if g_game.isFollowing then
		return g_game.isFollowing() == true
	end

	return g_game.getFollowingCreature and g_game.getFollowingCreature() ~= nil or false
end

local function var_0_140(arg_100_0)
	if not var_0_139() then
		return false
	end

	var_0_134(false)
	setShooterCheckEnabled(false)

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end

	if not arg_100_0 then
		showFailure("Follow active!\nShooter disabled.")
	end

	return true
end

local function var_0_141(unusedArgument)
	local var_101_0 = var_0_139()

	if var_0_137() then
		shooterEnabledBeforeFollow = false
		wasFollowingCreature = var_101_0

		var_0_138(true)

		return
	end

	if not var_0_131() then
		setShooterCheckEnabled(not var_101_0)

		wasFollowingCreature = var_101_0

		if not var_101_0 then
			shooterEnabledBeforeFollow = false
		end

		if modules.game_helper and modules.game_helper.refreshHelperStats then
			modules.game_helper.refreshHelperStats()
		end

		return
	end

	local var_101_1 = widget("enableShooterCheckBox")

	if var_101_0 then
		if not wasFollowingCreature then
			shooterEnabledBeforeFollow = var_101_1 and var_101_1:isChecked() or hotkeyShooterStatus
		end

		if var_101_1 and var_101_1:isChecked() then
			var_0_134(false)
		end

		setShooterCheckEnabled(false)
	elseif wasFollowingCreature then
		setShooterCheckEnabled(true)

		if shooterEnabledBeforeFollow then
			var_0_134(true)
		end

		shooterEnabledBeforeFollow = false
	else
		setShooterCheckEnabled(true)
	end

	wasFollowingCreature = var_101_0

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end
end

function HelperShooter.setMagicShooterOnHold(value)
	magicShooterOnHold = value == true
end

function HelperShooter.isMagicShooterActive()
	return var_0_133()
end

function HelperShooter.isDisabledByFollow()
	return wasFollowingCreature == true and shooterEnabledBeforeFollow == true
end

function HelperShooter.isDisabledByProtectionZone()
	return shooterEnabledBeforePz == true
end

function HelperShooter.enableProtectionZonePause()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer or not localPlayer.isInProtectionZone or not localPlayer:isInProtectionZone() then
		return false
	end

	if not isShooterPzAutoEnabled() then
		return false
	end

	shooterEnabledBeforePz = true
	wasInProtectionZone = true

	var_0_135(false)

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end

	return true
end

function HelperShooter.disablePausedState()
	shooterEnabledBeforeFollow = false
	shooterEnabledBeforePz = false

	var_0_134(false)

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end
end

function HelperShooter.syncHotkeyStatus()
	local var_108_0 = widget("enableShooterCheckBox")

	hotkeyShooterStatus = var_108_0 and var_108_0:isChecked() or false
end

function HelperShooter.toggleMagicShooter(checkWidget, message, silent)
	if not checkWidget then
		checkWidget = widget("enableShooterCheckBox")

		if not checkWidget then
			return
		end

		local checked = not checkWidget:isChecked()

		if checked and var_0_138(silent) then
			var_0_132()

			return
		end

		if checked and var_0_140(silent) then
			var_0_132()

			return
		end

		checkWidget:setChecked(checked)
	end

	if not checkWidget then
		return
	end

	if checkWidget:isChecked() and var_0_138(silent) then
		if ctx and ctx.saveConfig then
			ctx.saveConfig()
		end

		var_0_132()

		return
	end

	if checkWidget:isChecked() and var_0_140(silent) then
		var_0_132()

		return
	end

	hotkeyShooterStatus = checkWidget:isChecked()

	if not hotkeyShooterStatus then
		clearShooterCooldownState()
	end

	if suppressShooterCheckChange then
		var_0_132()

		return
	end

	if not silent then
		showMessage(message or string.format("Shooter is %s.", hotkeyShooterStatus and "enabled" or "disabled"))
	end

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end

	var_0_132()
end

local function var_0_142(arg_110_0)
	if not arg_110_0 then
		return
	end

	local var_110_0 = arg_110_0:isInProtectionZone()

	if not isShooterPzAutoEnabled() then
		local var_110_1 = widget("enableShooterCheckBox")
		local var_110_2 = shooterEnabledBeforePz == true or var_110_1 and var_110_1:isChecked()

		shooterEnabledBeforePz = false

		if var_110_0 then
			var_0_138(true)

			if var_110_2 and ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		else
			setShooterCheckEnabled(not var_0_139())
		end
	else
		setShooterCheckEnabled(not var_0_139())

		if not var_0_131() then
			wasInProtectionZone = var_110_0

			if modules.game_helper and modules.game_helper.refreshHelperStats then
				modules.game_helper.refreshHelperStats()
			end

			return
		end

		if isShooterPzAutoEnabled() then
			if var_110_0 and not wasInProtectionZone then
				local var_110_3 = widget("enableShooterCheckBox")

				if var_110_3 and var_110_3:isChecked() then
					shooterEnabledBeforePz = true

					var_0_135(false)
				else
					shooterEnabledBeforePz = false
				end
			elseif not var_110_0 and wasInProtectionZone and shooterEnabledBeforePz then
				shooterEnabledBeforePz = false

				var_0_135(true)
			end
		elseif not var_110_0 then
			shooterEnabledBeforePz = false
		end
	end

	wasInProtectionZone = var_110_0

	if modules.game_helper and modules.game_helper.refreshHelperStats then
		modules.game_helper.refreshHelperStats()
	end
end

function HelperShooter.refreshProtectionZoneState()
	var_0_142(g_game.getLocalPlayer())
end

local function var_0_143()
	return 1, 7
end

local function getPriorityRowEnabledCheck(row)
	if not row then
		return nil
	end

	if row.recursiveGetChildById then
		local check = row:recursiveGetChildById("shooterRowEnabled")

		if check then
			return check
		end
	end

	return row:getChildById("shooterRowEnabled")
end

local function var_0_145(arg_114_0, arg_114_1)
	if HelperActionCoordinator and HelperActionCoordinator.isAutomaticActionBlocked and HelperActionCoordinator.isAutomaticActionBlocked() then
		return
	end

	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return
	end

	var_0_142(localPlayer)

	if localPlayer:isInProtectionZone() then
		return
	end

	var_0_141(false)

	if var_0_139() then
		return
	end

	if HelperHealer and HelperHealer.shouldYieldToHealing and HelperHealer.shouldYieldToHealing(localPlayer) then
		return
	end

	arg_114_0 = arg_114_0 or g_clock.millis()

	local var_114_1 = getEntityPosition(localPlayer)

	if not var_114_1 then
		return
	end

	local var_114_2, var_114_3 = var_0_143()
	local var_114_4 = g_clock.realMicros()
	local var_114_5 = buildOffensiveCreatureList(var_114_1, var_114_2, var_114_3)

	lastTickScanUs = g_clock.realMicros() - var_114_4
	lastTickCreatureCount = #var_114_5

	local var_114_6 = isOffensiveTargetInRange(arg_114_1, var_114_1, var_114_2, var_114_3) and arg_114_1 or getShooterCombatTarget(var_114_1, var_114_2, var_114_3)
	local var_114_7 = var_0_133()
	local var_114_8 = var_114_6 ~= nil or #var_114_5 > 0
	local var_114_9 = arg_114_0 - lastGlobalCastAt >= GLOBAL_CAST_COOLDOWN_MS

	if not var_114_8 and var_114_9 then
		local function var_114_10(arg_115_0)
			if HelperHealer and HelperHealer.shouldYieldToHealing and HelperHealer.shouldYieldToHealing(localPlayer, arg_115_0.mana) then
				return false
			end

			return not isSpellOnCooldown(arg_115_0, arg_114_0)
		end

		if HelperPosture and HelperPosture.castPending and HelperPosture.castPending(localPlayer, var_114_10) then
			lastGlobalCastAt = arg_114_0

			return
		end
	end

	if not var_114_7 then
		return
	end

	local var_114_11 = getShooterProfile()

	if type(var_114_11) ~= "table" then
		return
	end

	local direction = localPlayer:getDirection()
	local var_114_13 = localPlayer
	local var_114_14 = {
		player = var_114_13,
		position = var_114_1,
		direction = direction,
		creatureList = var_114_5,
		combatTarget = var_114_6,
		nowMs = arg_114_0
	}

	if not var_114_9 then
		return
	end

	local var_114_15 = type(var_114_11.priorityList) == "table" and var_114_11.priorityList or {}
	local listSize = #var_114_15

	lastTickPriorityCount = listSize

	if listSize == 0 then
		return
	end

	local var_114_17 = 0

	if comboMode and listSize > 1 then
		var_114_17 = ((comboNextIndex or 1) - 1) % listSize
	end

	for iter_114_0 = 1, listSize do
		if magicShooterOnHold then
			break
		end

		local var_114_18 = (var_114_17 + iter_114_0 - 1) % listSize + 1
		local entry = var_114_15[var_114_18]

		if type(entry) ~= "table" then
			-- block empty
		elseif entry.enabled == false then
			-- block empty
		elseif not entry.id or entry.id <= 0 then
			-- block empty
		else
			local var_114_20 = g_clock.realMicros()
			local var_114_21 = false

			if entry.type == "spell" then
				var_114_21 = tryCastPrioritySpell(entry, var_114_14)
			elseif entry.type == "rune" then
				var_114_21 = tryCastPriorityRune(entry, var_114_14)
			end

			local var_114_22 = g_clock.realMicros() - var_114_20

			if var_114_22 > lastTickPriorityUs then
				lastTickPriorityUs = var_114_22
				lastTickPriorityLabel = string.format("%d:%s:%s:%s", var_114_18, tostring(entry.type or "unknown"), tostring(entry.useTo or "target"), tostring(entry.id))
			end

			if var_114_21 then
				debugLog(string.format("Cast #%d (%s id=%d)", var_114_18, entry.type, entry.id))

				if comboMode and listSize > 1 then
					comboNextIndex = var_114_18 % listSize + 1
				end

				return
			end
		end
	end
end

local var_0_146 = 2000
local var_0_147 = false

function HelperShooter.getLastTickProfile()
	return lastTickScanUs, lastTickCreatureCount, lastTickPriorityCount, lastTickPriorityLabel, lastTickPriorityUs
end

function HelperShooter.runTick(state)
	lastTickScanUs = 0
	lastTickCreatureCount = 0
	lastTickPriorityCount = 0
	lastTickPriorityUs = 0
	lastTickPriorityLabel = "none"

	local var_117_0 = state and state.nowMs or g_clock.millis()

	if g_game.getAttackingCreature() ~= nil or var_117_0 - lastGlobalCastAt < var_0_146 then
		var_0_147 = false

		var_0_145(var_117_0)

		return
	end

	var_0_147 = not var_0_147

	if var_0_147 then
		return
	end

	var_0_145(var_117_0)
end

function HelperShooter.onAttackingCreatureChange(creature)
	if not creature or not g_game.isOnline() or not var_0_133() then
		return
	end

	var_0_145(g_clock.millis(), creature)
end

function HelperShooter.onFollowingCreatureChange()
	var_0_141(false)
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

local function getEntryDisplayName(entry)
	if not entry or not entry.id or entry.id <= 0 then
		return ""
	end

	if entry.type == "spell" then
		local spell = Spells.getSpellDataById(entry.id)

		if spell then
			return Spells.getSpellNameByWords(spell.words) or spell.words or "Spell #" .. entry.id
		end
	elseif entry.type == "rune" then
		local rune = Spells.getRuneSpellByItem(entry.id)

		if rune then
			return rune.name or "Rune #" .. entry.id
		end
	end

	return ""
end

local function clearPriorityListSelection()
	local list = widget("shooterPriorityList")

	if not list or list:isDestroyed() then
		return
	end

	list:focusChild(nil)

	for _, row in ipairs(list:getChildren()) do
		if row.zebraColor then
			row:setBackgroundColor(row.zebraColor)
		end
	end

	HelperShooter.syncActionButtons()
end

local function focusPriorityRowByIndex(index)
	local list = widget("shooterPriorityList")

	if not list or list:isDestroyed() then
		return
	end

	local row = list:getChildren()[index]

	if row then
		list:focusChild(row, KeyboardFocusReason)
		row:setBackgroundColor("#585858")
		HelperShooter.syncActionButtons()
	end
end

local function removePriorityEntryAt(index)
	local profile = getShooterProfile()

	if not profile.priorityList or not profile.priorityList[index] then
		return false
	end

	table.remove(profile.priorityList, index)

	return true
end

local swapPriorityEntries

local function getEntryConditionText(entry)
	if not entry then
		return ""
	end

	local hpMin, hpMax = normalizeHpRange(entry)
	local showUseTo = entry.type == "rune" or entry.type == "spell" and entry.useTo and entry.useTo ~= "target"

	if not showUseTo and entry.type == "spell" then
		local spellData = Spells.getSpellDataById(entry.id)

		showUseTo = spellData and spellData.crossHairTarget == true
	end

	local conditionText = entry.useTo or entry.selfCast == true and "self" or "target"
	local useToLabel = clampCreatures(entry.creatures) .. "+"

	if HelperShooter.isSingleTargetAction(entry, conditionText) then
		useToLabel = entry.onlyWhenAlone == true and "1" or "1+"
	end

	local formattedText

	if showUseTo then
		local var_127_7 = conditionText == "self" and "Yourself" or conditionText == "bestTile" and "Best Position" or "Target"

		formattedText = string.format("Creatures: %s, Use to: %s, HP: %d-%d", useToLabel, var_127_7, hpMin, hpMax)
	else
		formattedText = string.format("Creatures: %s, HP: %d-%d", useToLabel, hpMin, hpMax)
	end

	if entry.type == "spell" and spellUsesHarmonyById(entry.id) then
		formattedText = formattedText .. string.format(", Harmony: %s", var_0_103(entry.harmony))
	end

	if entry.type == "spell" and var_0_38[entry.id] then
		formattedText = formattedText .. string.format(", Interval: %s s", var_0_102(entry.intervalMs, entry.id))
	end

	return formattedText
end

function HelperShooter.destroyPriorityDragGhost()
	if HelperShooter.priorityDragGhost and not HelperShooter.priorityDragGhost:isDestroyed() then
		HelperShooter.priorityDragGhost:destroy()
	end

	HelperShooter.priorityDragGhost = nil
end

function HelperShooter.updatePriorityDragGhostPosition(mousePos)
	if not HelperShooter.priorityDragGhost or HelperShooter.priorityDragGhost:isDestroyed() or not mousePos then
		return
	end

	local size = HelperShooter.priorityDragGhost:getSize()
	local width = size and size.width or 220
	local height = size and size.height or 40

	HelperShooter.priorityDragGhost:setPosition({
		x = mousePos.x - math.floor(width / 2),
		y = mousePos.y - math.floor(height / 2)
	})
	HelperShooter.priorityDragGhost:raise()
end

function HelperShooter.ensurePriorityDragGhost(row)
	if HelperShooter.priorityDragGhost and not HelperShooter.priorityDragGhost:isDestroyed() then
		return HelperShooter.priorityDragGhost
	end

	local root = g_ui.getRootWidget()

	if not root then
		return nil
	end

	HelperShooter.priorityDragGhost = g_ui.createWidget("ShooterPriorityDragGhost", root)

	HelperShooter.priorityDragGhost:setId("shooterPriorityDragGhost")
	HelperShooter.priorityDragGhost:setPhantom(true)
	HelperShooter.priorityDragGhost:setFocusable(false)
	HelperShooter.priorityDragGhost:setDraggable(false)
	HelperShooter.priorityDragGhost:setVisible(false)

	if row and row.getWidth then
		HelperShooter.priorityDragGhost:setWidth(math.max(220, row:getWidth()))
	end

	return HelperShooter.priorityDragGhost
end

function HelperShooter.updatePriorityDragGhost(row, entry, mousePos)
	if not entry then
		return
	end

	local ghost = HelperShooter.ensurePriorityDragGhost(row)

	if not ghost then
		return
	end

	local nameLabel = ghost:recursiveGetChildById("dragGhostName")

	if nameLabel then
		nameLabel:setText(getEntryDisplayName(entry))
	end

	local conditionLabel = ghost:recursiveGetChildById("dragGhostCondition")

	if conditionLabel then
		conditionLabel:setText(getEntryConditionText(entry))
	end

	local spellIcon = ghost:recursiveGetChildById("dragGhostSpellIcon")
	local runeIconBackground = ghost:recursiveGetChildById("dragGhostRuneIconBackground")
	local runeIcon = ghost:recursiveGetChildById("dragGhostRuneIcon")

	if entry.type == "spell" then
		local spell = Spells.getSpellDataById(entry.id)

		if spellIcon and spell then
			spellIcon:setVisible(true)

			local spellProfile = getSpellProfile()
			local settings = SpelllistSettings and SpelllistSettings[spellProfile]
			local iconId = resolveSpellIconId(spell)

			if settings then
				spellIcon:setImageSource(settings.iconFile)
				spellIcon:setImageClip(Spells.getImageClip(iconId, spellProfile))
			end
		elseif spellIcon then
			spellIcon:setVisible(false)
		end

		if runeIconBackground then
			runeIconBackground:setVisible(false)
		end

		if runeIcon then
			runeIcon:setVisible(false)
		end
	else
		if spellIcon then
			spellIcon:setVisible(false)
		end

		if runeIconBackground then
			runeIconBackground:setVisible(true)
		end

		if runeIcon then
			runeIcon:setVisible(true)
			runeIcon:setItemId(entry.id)
		end
	end

	ghost:setVisible(true)
	HelperShooter.updatePriorityDragGhostPosition(mousePos or g_window.getMousePosition())
end

function HelperShooter.setPriorityDragSourceVisual(row, dragging)
	if not row or row:isDestroyed() then
		return
	end

	if dragging then
		row:setOpacity(0.45)
		row:setBackgroundColor("#6a6a6a")

		return
	end

	row:setOpacity(1)

	if row.zebraColor then
		row:setBackgroundColor(row.zebraColor)
	end
end

function HelperShooter.syncActionButtons()
	local addBtn = widget("shooterAddBtn")
	local editBtn = widget("shooterEditBtn")
	local removeBtn = widget("shooterRemoveBtn")

	if not addBtn or not editBtn or not removeBtn then
		return
	end

	local list = widget("shooterPriorityList")
	local focused = list and list:getFocusedChild()
	local showActions = focused and focused.shooterEntryIndex ~= nil
	local stateKey = showActions and "actions" or "default"

	if shooterActionButtonsState == stateKey then
		return
	end

	shooterActionButtonsState = stateKey

	addBtn:setEnabled(true)

	if showActions then
		removeBtn:show()
		editBtn:show()
		addBtn:breakAnchors()
		addBtn:addAnchor(AnchorTop, "parent", AnchorTop)
		addBtn:addAnchor(AnchorRight, "shooterEditBtn", AnchorLeft)
		addBtn:setMarginRight(6)
		editBtn:setEnabled(true)
		removeBtn:setEnabled(true)
		removeBtn:setMarginRight(0)
	else
		removeBtn:hide()
		editBtn:hide()
		addBtn:breakAnchors()
		addBtn:addAnchor(AnchorTop, "parent", AnchorTop)
		addBtn:addAnchor(AnchorRight, "parent", AnchorRight)
		addBtn:setMarginRight(0)
	end
end

local function scheduleShooterActionButtonsSync()
	addEvent(function()
		HelperShooter.syncActionButtons()
	end)
end

local function applyEntryToRow(row, entry, index)
	if not row or not entry then
		return
	end

	row.shooterEntryIndex = index

	local enabledCheck = getPriorityRowEnabledCheck(row)
	local spellIcon = row:getChildById("spellIcon")
	local runeIconBackground = row:getChildById("runeIconBackground")
	local runeIcon = row:getChildById("runeIcon")
	local nameLabel = row:getChildById("spellName")
	local conditionLabel = row:getChildById("shooterCondition")

	if enabledCheck then
		local onCheckChange = enabledCheck.onCheckChange

		enabledCheck.onCheckChange = nil

		enabledCheck:setChecked(entry.enabled ~= false)

		enabledCheck.onCheckChange = onCheckChange
	end

	if entry.type == "spell" then
		local spell = Spells.getSpellDataById(entry.id)

		if spellIcon and spell then
			spellIcon:setVisible(true)

			local spellProfile = getSpellProfile()
			local settings = SpelllistSettings and SpelllistSettings[spellProfile]
			local iconId = resolveSpellIconId(spell)

			if settings then
				spellIcon:setImageSource(settings.iconFile)
				spellIcon:setImageClip(Spells.getImageClip(iconId, spellProfile))
			end
		end

		refreshSpellActionTooltip(spellIcon or row, spell and spell.words or nil)

		if runeIconBackground then
			runeIconBackground:setVisible(false)
		end

		if runeIcon then
			runeIcon:setVisible(false)
		end
	else
		if spellIcon then
			spellIcon:setVisible(false)
		end

		refreshSpellActionTooltip(spellIcon or row, nil)

		if runeIconBackground then
			runeIconBackground:setVisible(true)
		end

		if runeIcon then
			runeIcon:setVisible(true)
			runeIcon:setItemId(entry.id)
		end
	end

	if nameLabel then
		nameLabel:setText(getEntryDisplayName(entry))
	end

	if conditionLabel then
		conditionLabel:setText(getEntryConditionText(entry))
	end
end

local function reorderPriorityEntryByDrop(sourceIndex, targetIndex, afterTarget)
	sourceIndex = tonumber(sourceIndex)
	targetIndex = tonumber(targetIndex)

	local list = getShooterProfile().priorityList

	if not list or not sourceIndex or not list[sourceIndex] then
		return nil
	end

	if targetIndex and (sourceIndex == targetIndex or not list[targetIndex]) then
		return nil
	end

	local sourceEntry = table.remove(list, sourceIndex)

	if targetIndex then
		local originalTargetIndex = targetIndex

		if sourceIndex < targetIndex then
			targetIndex = targetIndex - 1
		end

		local insertIndex = targetIndex + (afterTarget and 1 or 0)
		local insertIndex = math.max(1, math.min(insertIndex, #list + 1))

		if insertIndex == sourceIndex then
			insertIndex = sourceIndex < originalTargetIndex and insertIndex + 1 or insertIndex - 1
			insertIndex = math.max(1, math.min(insertIndex, #list + 1))
		end

		table.insert(list, insertIndex, sourceEntry)

		return insertIndex
	end

	table.insert(list, sourceEntry)

	return #list
end

local function finishPriorityEntryDrop(newIndex)
	HelperShooter.destroyPriorityDragGhost()
	saveConfigIfReady()
	addEvent(function()
		HelperShooter.refreshPriorityListUI()
		focusPriorityRowByIndex(newIndex)
	end)
end

local function dropPriorityEntryOnRow(targetRow, draggedWidget, mousePos, forcedAfterTarget)
	if not targetRow or not draggedWidget or not draggedWidget.shooterEntryIndex or not targetRow.shooterEntryIndex then
		return false
	end

	local afterTarget = forcedAfterTarget

	if afterTarget == nil then
		afterTarget = mousePos and mousePos.y >= targetRow:getY() + targetRow:getHeight() / 2
	end

	local newIndex = reorderPriorityEntryByDrop(draggedWidget.shooterEntryIndex, targetRow.shooterEntryIndex, afterTarget)

	if newIndex then
		HelperShooter.setPriorityDragSourceVisual(draggedWidget, false)
		finishPriorityEntryDrop(newIndex)

		return true
	end

	return false
end

local function dropPriorityEntryOnPanel(panel, draggedWidget)
	if not panel or not draggedWidget or not draggedWidget.shooterEntryIndex then
		return false
	end

	local newIndex = reorderPriorityEntryByDrop(draggedWidget.shooterEntryIndex, nil, false)

	if newIndex then
		HelperShooter.setPriorityDragSourceVisual(draggedWidget, false)
		finishPriorityEntryDrop(newIndex)

		return true
	end

	return false
end

function HelperShooter.isMouseInsidePriorityDropPanel(panel, mousePos)
	if not panel or panel:isDestroyed() or not mousePos then
		return false
	end

	if panel.containsPaddingPoint then
		return panel:containsPaddingPoint(mousePos)
	end

	return mousePos.x >= panel:getX() and mousePos.x <= panel:getX() + panel:getWidth() and mousePos.y >= panel:getY() and mousePos.y <= panel:getY() + panel:getHeight()
end

function HelperShooter.getPriorityDropPanel(draggedWidget, mousePos)
	if not draggedWidget or not draggedWidget.shooterEntryIndex then
		return nil
	end

	local panel = draggedWidget.getParent and draggedWidget:getParent() or nil

	if panel and panel:getId() == "shooterPriorityList" and HelperShooter.isMouseInsidePriorityDropPanel(panel, mousePos) then
		return panel
	end

	local panel = widget("shooterPriorityList")

	if panel and HelperShooter.isMouseInsidePriorityDropPanel(panel, mousePos) then
		return panel
	end

	return nil
end

function HelperShooter.resolvePriorityDropTarget(draggedWidget, mousePos)
	local panel = HelperShooter.getPriorityDropPanel(draggedWidget, mousePos)

	if not panel then
		return nil, nil, nil
	end

	local lastRow

	for _, row in ipairs(panel:getChildren()) do
		if row:isVisible() and row.shooterEntryIndex then
			lastRow = row

			if mousePos.y < row:getY() + row:getHeight() / 2 then
				return panel, row, false
			end
		end
	end

	if lastRow then
		return panel, lastRow, true
	end

	return panel, nil, false
end

function HelperShooter.dropPriorityEntryAtMouse(fallbackRow, draggedWidget, mousePos)
	if not draggedWidget or not draggedWidget.shooterEntryIndex then
		return false
	end

	local panel, targetRow, afterTarget = HelperShooter.resolvePriorityDropTarget(draggedWidget, mousePos)

	if targetRow then
		return dropPriorityEntryOnRow(targetRow, draggedWidget, mousePos, afterTarget)
	end

	if panel then
		return dropPriorityEntryOnPanel(panel, draggedWidget)
	end

	if fallbackRow then
		return dropPriorityEntryOnRow(fallbackRow, draggedWidget, mousePos)
	end

	return false
end

function HelperShooter.bindPriorityRowDropForwarder(widget, row)
	if not widget then
		return
	end

	local previousOnDrop = widget.onDrop

	function widget.onDrop(self, draggedWidget, mousePos)
		if draggedWidget and draggedWidget.shooterEntryIndex then
			return HelperShooter.dropPriorityEntryAtMouse(row, draggedWidget, mousePos)
		end

		if previousOnDrop then
			return previousOnDrop(self, draggedWidget, mousePos)
		end

		return false
	end
end

function HelperShooter.bindPriorityRowDragSource(widget, row, entry)
	if not widget or not row then
		return
	end

	widget.shooterEntryIndex = row.shooterEntryIndex
	widget._shooterPriorityRow = row

	if widget.setDraggable then
		widget:setDraggable(true)
	end

	if widget.setPhantom then
		widget:setPhantom(false)
	end

	function widget.onDragEnter(self, mousePos)
		local sourceRow = self._shooterPriorityRow or row
		local profile = getShooterProfile()
		local current = profile.priorityList and profile.priorityList[self.shooterEntryIndex] or entry

		HelperShooter.updatePriorityDragGhost(sourceRow, current, mousePos)
		HelperShooter.setPriorityDragSourceVisual(sourceRow, true)

		return true
	end

	function widget.onDragMove(_, mousePos)
		HelperShooter.updatePriorityDragGhostPosition(mousePos)

		return true
	end

	function widget.onDragLeave(self)
		local sourceRow = self._shooterPriorityRow or row

		HelperShooter.destroyPriorityDragGhost()

		if sourceRow:isDestroyed() then
			return true
		end

		HelperShooter.setPriorityDragSourceVisual(sourceRow, false)

		return true
	end

	HelperShooter.bindPriorityRowDropForwarder(widget, row)
end

local function bindPriorityPanelDropTarget(panel)
	if not panel then
		return
	end

	function panel.onDrop(_, draggedWidget, mousePos)
		return HelperShooter.dropPriorityEntryAtMouse(nil, draggedWidget, mousePos)
	end
end

local function bindPriorityRowDragChildren(widget, row, entry, enabledCheck)
	if not widget or not widget.getChildren then
		return
	end

	for _, child in ipairs(widget:getChildren()) do
		if child ~= enabledCheck and child:getId() ~= "shooterRowEnabled" then
			HelperShooter.bindPriorityRowDragSource(child, row, entry)
			bindPriorityRowDragChildren(child, row, entry, enabledCheck)
		end
	end
end

local function bindPriorityRowDrag(row, entry)
	if not row or not entry then
		return
	end

	if row.setDraggable then
		row:setDraggable(true)
	end

	HelperShooter.bindPriorityRowDragSource(row, row, entry)

	local enabledCheck = getPriorityRowEnabledCheck(row)

	bindPriorityRowDragChildren(row, row, entry, enabledCheck)
	HelperShooter.bindPriorityRowDropForwarder(enabledCheck, row)

	function row.onDragEnter(self, mousePos)
		local profile = getShooterProfile()
		local current = profile.priorityList and profile.priorityList[self.shooterEntryIndex] or entry

		HelperShooter.updatePriorityDragGhost(self, current, mousePos)
		HelperShooter.setPriorityDragSourceVisual(self, true)

		return true
	end

	function row.onDragMove(_, mousePos)
		HelperShooter.updatePriorityDragGhostPosition(mousePos)

		return true
	end

	function row.onDragLeave(self)
		HelperShooter.destroyPriorityDragGhost()

		if self:isDestroyed() then
			return true
		end

		HelperShooter.setPriorityDragSourceVisual(self, false)

		return true
	end

	function row.onDrop(self, draggedWidget, mousePos)
		return HelperShooter.dropPriorityEntryAtMouse(self, draggedWidget, mousePos)
	end
end

function HelperShooter.refreshPriorityListUI()
	local list = widget("shooterPriorityList")

	if not list then
		return
	end

	bindPriorityPanelDropTarget(list)

	local profile = getShooterProfile()
	local entries = {}

	for idx, entry in ipairs(profile.priorityList or {}) do
		if entry.id and entry.id > 0 then
			table.insert(entries, {
				entry = entry,
				index = idx
			})
		end
	end

	local rows = list:getChildren()

	for position, item in ipairs(entries) do
		local row = rows[position]

		if not row then
			local rowType = position % 2 == 1 and "HelperShooterPriorityItemOdd" or "HelperShooterPriorityItemEven"

			row = g_ui.createWidget(rowType, list)
			rows[position] = row
		end

		applyEntryToRow(row, item.entry, item.index)

		if not row._shooterPriorityInitialized then
			local enabledCheck = getPriorityRowEnabledCheck(row)

			if enabledCheck then
				function enabledCheck.onCheckChange(check, checked)
					local isChecked = checked

					if isChecked == nil and check and check.isChecked then
						isChecked = check:isChecked()
					elseif isChecked == nil and enabledCheck.isChecked then
						isChecked = enabledCheck:isChecked()
					end

					HelperShooter.updateEntryEnabled(row.shooterEntryIndex, isChecked == true)
				end
			end

			connectZebraFocus(row)
			bindPriorityRowDrag(row, item.entry)

			function row.onMouseRelease(self, _, button)
				if button == MouseRightButton then
					HelperShooter.openPriorityRowContextMenu(self)
				end
			end

			row._shooterPriorityInitialized = true
		end
	end

	for position = #rows, #entries + 1, -1 do
		local row = rows[position]

		if row and not row:isDestroyed() then
			row:destroy()
		end
	end

	clearPriorityListSelection()
end

function HelperShooter.updateEntryCreatures(index, creatures)
	local profile = getShooterProfile()
	local entry = profile.priorityList and profile.priorityList[index]

	if not entry then
		return
	end

	entry.creatures = clampCreatures(creatures)

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

function HelperShooter.updateEntryEnabled(index, enabled)
	local profile = getShooterProfile()
	local entry = profile.priorityList and profile.priorityList[index]

	if not entry then
		return
	end

	entry.enabled = enabled ~= false

	saveConfigIfReady()
end

function HelperShooter.openPriorityRowContextMenu(row)
	if not row or not row.shooterEntryIndex then
		return
	end

	local index = row.shooterEntryIndex
	local profile = getShooterProfile()
	local entry = profile.priorityList and profile.priorityList[index]

	if not entry then
		return
	end

	local list = widget("shooterPriorityList")

	if list and not list:isDestroyed() then
		list:focusChild(row, KeyboardFocusReason)
		scheduleShooterActionButtonsSync()
	end

	local menu = g_ui.createWidget("GamePopupMenu")

	menu:setWidth(120)
	menu:addOption(tr("Edit"), function()
		HelperShooter.openEditAssignWindow(index)
	end)
	menu:addOption(tr("Remove"), function()
		if removePriorityEntryAt(index) then
			HelperShooter.refreshPriorityListUI()
			clearPriorityListSelection()

			if ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		end
	end)

	if index > 1 then
		menu:addOption(tr("Move Up"), function()
			if swapPriorityEntries(index, index - 1) then
				HelperShooter.refreshPriorityListUI()
				focusPriorityRowByIndex(index - 1)

				if ctx and ctx.saveConfig then
					ctx.saveConfig()
				end
			end
		end)
	end

	if index < #(profile.priorityList or {}) then
		menu:addOption(tr("Move Down"), function()
			if swapPriorityEntries(index, index + 1) then
				HelperShooter.refreshPriorityListUI()
				focusPriorityRowByIndex(index + 1)

				if ctx and ctx.saveConfig then
					ctx.saveConfig()
				end
			end
		end)
	end

	if entry.enabled ~= false then
		menu:addOption(tr("Disable"), function()
			entry.enabled = false

			HelperShooter.refreshPriorityListUI()
			focusPriorityRowByIndex(index)

			if ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		end)
	else
		menu:addOption(tr("Enable"), function()
			entry.enabled = true

			HelperShooter.refreshPriorityListUI()
			focusPriorityRowByIndex(index)

			if ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		end)
	end

	menu:display()
end

function swapPriorityEntries(indexA, indexB)
	local list = getShooterProfile().priorityList

	if not list or not list[indexA] or not list[indexB] then
		return false
	end

	list[indexA], list[indexB] = list[indexB], list[indexA]

	return true
end

function HelperShooter.onMoveUpClick()
	local list = widget("shooterPriorityList")

	if not list then
		return
	end

	local focused = list:getFocusedChild()

	if not focused or not focused.shooterEntryIndex then
		return
	end

	local idx = focused.shooterEntryIndex

	if idx <= 1 then
		return
	end

	if swapPriorityEntries(idx, idx - 1) then
		HelperShooter.refreshPriorityListUI()

		local children = list:getChildren()

		if children[idx - 1] then
			list:focusChild(children[idx - 1])
		end

		scheduleShooterActionButtonsSync()

		if ctx and ctx.saveConfig then
			ctx.saveConfig()
		end
	end
end

function HelperShooter.onMoveDownClick()
	local list = widget("shooterPriorityList")

	if not list then
		return
	end

	local focused = list:getFocusedChild()

	if not focused or not focused.shooterEntryIndex then
		return
	end

	local idx = focused.shooterEntryIndex

	if idx >= #(getShooterProfile().priorityList or {}) then
		return
	end

	if swapPriorityEntries(idx, idx + 1) then
		HelperShooter.refreshPriorityListUI()

		local children = list:getChildren()

		if children[idx + 1] then
			list:focusChild(children[idx + 1])
		end

		scheduleShooterActionButtonsSync()

		if ctx and ctx.saveConfig then
			ctx.saveConfig()
		end
	end
end

function HelperShooter.onRemoveClick()
	local list = widget("shooterPriorityList")

	if not list then
		return
	end

	local focused = list:getFocusedChild()

	if not focused or not focused.shooterEntryIndex then
		return
	end

	local profile = getShooterProfile()

	table.remove(profile.priorityList, focused.shooterEntryIndex)
	HelperShooter.refreshPriorityListUI()
	clearPriorityListSelection()

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

local function closeAssignWindowInternal()
	clearAssignPreviewFrame()

	if assignSpellWindow and not assignSpellWindow:isDestroyed() then
		assignSpellWindow:destroy()
	end

	assignSpellWindow = nil
	assignSpellsPanel = nil
end

local populateAssignList
local updateAssignModeButtons
local filterAssignRows

local function updateAssignPreview(row)
	if not assignSpellWindow or assignSpellWindow:isDestroyed() or not row then
		return
	end

	local preview = assignSpellWindow:recursiveGetChildById("shooterSpellPreview")

	if not preview then
		return
	end

	local spellIcon = preview:getChildById("previewSpellIcon")
	local spellGray = preview:getChildById("previewSpellGray")
	local runeBackground = preview:getChildById("previewRuneBackground")
	local runeIcon = preview:getChildById("previewRuneIcon")
	local nameLabel = preview:getChildById("previewSpellName")
	local wordsLabel = preview:getChildById("previewSpellWords")
	local previewFrame = getAssignPreviewFrame()

	if assignMode == "spells" and row.spellInfo then
		if spellIcon then
			spellIcon:setVisible(true)

			local spellProfile = getSpellProfile()

			spellIcon:setImageSource(SpelllistSettings[spellProfile].iconFile)

			local iconId = SpellIcons[row.spellInfo.id]

			spellIcon:setImageClip(Spells.getImageClip(iconId, spellProfile))
		end

		if spellGray then
			spellGray:setVisible(not playerCanUseAttackSpell(row.spellInfo))
			preview:raiseChild(spellGray)
		end

		if runeBackground then
			runeBackground:setVisible(false)
		end

		if runeIcon then
			runeIcon:setVisible(false)
		end

		if nameLabel then
			nameLabel:setText(row.spellName or "")
		end

		if wordsLabel then
			wordsLabel:setVisible(true)
			wordsLabel:setText(row.spellInfo.words)
		end
	elseif assignMode == "runes" and row.runeId then
		if spellIcon then
			spellIcon:setVisible(false)
		end

		if runeBackground then
			runeBackground:setVisible(true)
		end

		if runeIcon then
			runeIcon:setVisible(true)
			runeIcon:setItemId(row.runeId)
		end

		if spellGray then
			spellGray:setVisible(row.runeAvailable == false)
			preview:raiseChild(spellGray)
		end

		if nameLabel then
			nameLabel:setText(row.runeName or "")
		end

		if wordsLabel then
			wordsLabel:setText("")
			wordsLabel:setVisible(false)
		end
	end

	local previewSpell

	if assignMode == "spells" and row.spellInfo then
		previewSpell = buildAssignPreviewSpell(row.spellInfo.id, row.spellName, row.spellInfo.words, false)
	elseif assignMode == "runes" and row.runeData then
		local runeSpellId = row.runeData.id
		local runeSpell = runeSpellId and Spells.getSpellDataById(runeSpellId)

		previewSpell = buildAssignPreviewSpell(runeSpellId, row.runeName, runeSpell and runeSpell.words or "", true)
	end

	playAssignPreview(previewFrame, previewSpell)
end

local function focusAssignRow(row)
	if not assignSpellsPanel or assignSpellsPanel:isDestroyed() then
		return
	end

	local okBtn = assignSpellWindow and assignSpellWindow:recursiveGetChildById("okButton")

	if row and not row:isDestroyed() then
		assignSpellsPanel:focusChild(row, KeyboardFocusReason)

		if row.focus then
			row:focus()
		end

		if assignSpellsPanel.ensureChildVisible then
			assignSpellsPanel:ensureChildVisible(row)
		end

		updateAssignPreview(row)

		if okBtn then
			okBtn:setEnabled(true)
		end
	else
		assignSpellsPanel:focusChild(nil)
		clearAssignPreviewFrame(nil, true)

		if okBtn then
			okBtn:setEnabled(false)
		end
	end
end

function HelperShooter.refreshCastOnePlusRow()
	if not addShooterWindow or addShooterWindow:isDestroyed() then
		return
	end

	local useToRow = addShooterWindow:recursiveGetChildById("addShooterCastOnePlusUnit")
	local harmonyRow = addShooterWindow:recursiveGetChildById("addShooterCastOnePlusCheck")
	local autoTurnRow = addShooterWindow:recursiveGetChildById("addShooterCreaturesCombo")

	if not useToRow or not harmonyRow or not autoTurnRow then
		return
	end

	local currentOption = "target"
	local addShooterUseToRow = addShooterWindow:recursiveGetChildById("addShooterUseToRow")
	local addShooterUseToCombo = addShooterWindow:recursiveGetChildById("addShooterUseToCombo")

	if addShooterUseToRow and addShooterUseToRow:isVisible() and addShooterUseToCombo then
		currentOption = normalizeUseToOption(addShooterUseToCombo:getCurrentOption())
	end

	local visible = HelperShooter.isSingleTargetAction(selectedShooterAction, currentOption)

	useToRow:setVisible(visible)

	if visible then
		if not autoTurnRow.castOnePlusLocked then
			local curOpt = autoTurnRow:getCurrentOption()

			autoTurnRow.castOnePlusRestore = type(curOpt) == "table" and curOpt.text or "1+"
			autoTurnRow.castOnePlusLocked = true

			autoTurnRow:setCurrentOption("1+", true)
			autoTurnRow:setEnabled(false)
			autoTurnRow:setColor("#909090")
			autoTurnRow:setTooltip(shooterUiLanguage == "pt" and "Magia ou runa de alvo unico: atinge so o monstro que voce esta atacando, " .. "entao aqui nao ha quantidade minima. Mostra 1+ ou 1 conforme o Cast with 1+." or "Single-target spell or rune: it hits only the monster you are attacking, " .. "so there is no minimum count here. It shows 1+ or 1 following Cast with 1+.")
		end

		autoTurnRow:setText(harmonyRow:isChecked() and "1+" or "1")
	elseif autoTurnRow.castOnePlusLocked then
		autoTurnRow.castOnePlusLocked = nil

		autoTurnRow:setEnabled(true)
		autoTurnRow:setColor("#c0c0c0")
		autoTurnRow:removeTooltip()
		autoTurnRow:setCurrentOption(autoTurnRow.castOnePlusRestore or "1+", true)

		autoTurnRow.castOnePlusRestore = nil

		local currentOption = autoTurnRow:getCurrentOption()

		autoTurnRow:setText(type(currentOption) == "table" and currentOption.text or "1+")
	end
end

local function updateShooterFormRows()
	if not addShooterWindow or addShooterWindow:isDestroyed() then
		return
	end

	local addShooterUseToRow = addShooterWindow:recursiveGetChildById("addShooterUseToRow")
	local addShooterHarmonyRow = addShooterWindow:recursiveGetChildById("addShooterHarmonyRow")
	local harmonyRow = addShooterWindow:recursiveGetChildById("addShooterAutoTurnRow")
	local autoTurnRow = addShooterWindow:recursiveGetChildById("addShooterIntervalRow")
	local showUseTo = selectedShooterAction ~= nil and (selectedShooterAction.type == "rune" or selectedShooterAction.type == "spell" and selectedShooterAction.crossHairTarget == true)
	local var_180_5 = var_0_42(selectedShooterAction)
	local var_180_6 = showUseTo and (selectedShooterAction.type == "rune" or not selectedShooterAction.noBestTile)
	local showHarmony = selectedShooterAction ~= nil and selectedShooterAction.type == "spell" and selectedShooterAction.useHarmony == true
	local visible = selectedShooterAction ~= nil and selectedShooterAction.type == "spell" and selectedShooterAction.directional == true
	local showAutoTurn = selectedShooterAction ~= nil and selectedShooterAction.type == "spell" and var_0_38[selectedShooterAction.id] ~= nil

	if addShooterUseToRow then
		addShooterUseToRow:setVisible(showUseTo)
		addShooterUseToRow:setHeight(showUseTo and 20 or 0)
		addShooterUseToRow:setMarginTop(showUseTo and 6 or 0)

		local addShooterUseToCombo = addShooterWindow:recursiveGetChildById("addShooterUseToCombo")

		if addShooterUseToCombo then
			local currentOption = addShooterUseToCombo:getCurrentOption()
			local var_180_12 = type(currentOption) == "table" and currentOption.text or tostring(currentOption or "Target")

			addShooterUseToCombo:clearOptions()
			addShooterUseToCombo:addOption("Target")

			if not var_180_5 then
				addShooterUseToCombo:addOption("Yourself")

				if var_180_6 then
					addShooterUseToCombo:addOption("Best Position")
				end
			end

			if var_180_5 or var_180_12 == "Best Position" and not var_180_6 then
				var_180_12 = "Target"
			end

			addShooterUseToCombo:setCurrentOption(var_180_12)
		end
	end

	if addShooterHarmonyRow then
		addShooterHarmonyRow:setVisible(showHarmony)
		addShooterHarmonyRow:setHeight(showHarmony and 20 or 0)
		addShooterHarmonyRow:setMarginTop(showHarmony and 6 or 0)
	end

	if harmonyRow then
		harmonyRow:setVisible(visible)
		harmonyRow:setHeight(visible and 20 or 0)
		harmonyRow:setMarginTop(visible and 6 or 0)
	end

	if autoTurnRow then
		autoTurnRow:setVisible(showAutoTurn)
		autoTurnRow:setHeight(showAutoTurn and 20 or 0)
		autoTurnRow:setMarginTop(showAutoTurn and 6 or 0)
	end

	local formHeight = 95 + (showUseTo and 26 or 0) + (showHarmony and 26 or 0) + (visible and 26 or 0) + (showAutoTurn and 26 or 0)
	local windowHeight = 171 + (showUseTo and 26 or 0) + (showHarmony and 26 or 0) + (visible and 26 or 0) + (showAutoTurn and 26 or 0)
	local form = addShooterWindow:recursiveGetChildById("addShooterForm")

	if form then
		form:setHeight(formHeight)
	end

	addShooterWindow:setHeight(windowHeight)
	HelperShooter.refreshCastOnePlusRow()
end

local function setSelectedShooterAction(action)
	selectedShooterAction = action

	if not addShooterWindow or addShooterWindow:isDestroyed() then
		return
	end

	updateShooterFormRows()

	local addShooterIntervalCombo = addShooterWindow:recursiveGetChildById("addShooterIntervalCombo")

	if addShooterIntervalCombo and action and action.type == "spell" and var_0_38[action.id] then
		addShooterIntervalCombo:setCurrentOption(var_0_102(nil, action.id))
	end

	local preview = addShooterWindow:recursiveGetChildById("addShooterActionPreview")

	if not preview then
		return
	end

	local spellIcon = preview:getChildById("previewSpellIcon")
	local runeBackground = preview:getChildById("previewRuneBackground")
	local runeIcon = preview:getChildById("previewRuneIcon")

	if not action then
		if spellIcon then
			spellIcon:setVisible(false)
		end

		if runeBackground then
			runeBackground:setVisible(false)
		end

		if runeIcon then
			runeIcon:setVisible(false)
		end
	elseif action.type == "spell" then
		if spellIcon then
			spellIcon:setVisible(true)

			local spellProfile = getSpellProfile()

			spellIcon:setImageSource(SpelllistSettings[spellProfile].iconFile)
			spellIcon:setImageClip(Spells.getImageClip(action.iconId or 0, spellProfile))
		end

		if runeBackground then
			runeBackground:setVisible(false)
		end

		if runeIcon then
			runeIcon:setVisible(false)
		end
	elseif action.type == "rune" then
		if spellIcon then
			spellIcon:setVisible(false)
		end

		if runeBackground then
			runeBackground:setVisible(true)
		end

		if runeIcon then
			runeIcon:setVisible(true)
			runeIcon:setItemId(action.id)
		end
	end

	refreshSpellActionTooltip(preview, action and action.type == "spell" and action.words or nil)

	local okBtn = addShooterWindow:recursiveGetChildById("addShooterOkButton")

	if okBtn then
		okBtn:setEnabled(selectedShooterAction ~= nil)
	end
end

local function openShooterActionSelectWindow(mode)
	closeAssignWindowInternal()

	assignMode = mode == "runes" and "runes" or "spells"
	assignSpellWindow = g_ui.loadUI("assign_shooter_spell", g_ui.getRootWidget())

	if not assignSpellWindow then
		return
	end

	assignSpellsPanel = assignSpellWindow:recursiveGetChildById("shooterSpellsPanel")

	if not assignSpellsPanel then
		showFailure("Could not load spell/rune list.")
		closeAssignWindowInternal()

		return
	end

	updateAssignModeButtons()
	populateAssignList()
	connect(assignSpellsPanel, {
		onChildFocusChange = function(_, focusedChild)
			if focusedChild then
				updateAssignPreview(focusedChild)
			else
				clearAssignPreviewFrame(nil, true)
			end

			local okBtn = assignSpellWindow:recursiveGetChildById("okButton")

			if okBtn then
				okBtn:setEnabled(focusedChild ~= nil)
			end
		end
	})
	assignSpellWindow:show()
	assignSpellWindow:raise()
	assignSpellWindow:focus()
	scheduleEvent(function()
		if assignSpellWindow and not assignSpellWindow:isDestroyed() then
			filterAssignRows("")
		end
	end, 1)
end

local function openShooterEntryActionContextMenu()
	local menu = g_ui.createWidget("GamePopupMenu")

	menu:setWidth(180)
	menu:addOption(tr("Assign Spell"), function()
		openShooterActionSelectWindow("spells")
	end)
	menu:addOption(tr("Assign Rune"), function()
		openShooterActionSelectWindow("runes")
	end)
	menu:addSeparator()
	menu:addOption(tr("Clear Action"), function()
		setSelectedShooterAction(nil)
	end)
	menu:display()
end

local function bindShooterEntryActionPreview()
	if not addShooterWindow or addShooterWindow:isDestroyed() then
		return
	end

	local preview = addShooterWindow:recursiveGetChildById("addShooterActionPreview")

	if not preview then
		return
	end

	function preview.onMousePress(_, _, mouseButton)
		return mouseButton == MouseLeftButton
	end

	function preview.onMouseRelease(_, _, mouseButton)
		if mouseButton == MouseRightButton then
			openShooterEntryActionContextMenu()

			return true
		end

		return mouseButton == MouseLeftButton
	end
end

local function closeEntryWindowInternal()
	closeAssignWindowInternal()

	if addShooterWindow and not addShooterWindow:isDestroyed() then
		addShooterWindow:destroy()
	end

	addShooterWindow = nil
	selectedShooterAction = nil
	editingPriorityListIndex = nil
end

local function readShooterEntryForm()
	if not addShooterWindow or addShooterWindow:isDestroyed() or not selectedShooterAction then
		return nil
	end

	local hpMinCombo = addShooterWindow:recursiveGetChildById("addShooterHpMinEdit")
	local hpMaxCombo = addShooterWindow:recursiveGetChildById("addShooterHpMaxEdit")
	local creaturesCombo = addShooterWindow:recursiveGetChildById("addShooterCreaturesCombo")
	local useToCombo = addShooterWindow:recursiveGetChildById("addShooterUseToCombo")
	local harmonyCombo = addShooterWindow:recursiveGetChildById("addShooterHarmonyCombo")
	local hpMin = addShooterWindow:recursiveGetChildById("addShooterIntervalCombo")
	local var_193_6, var_193_7 = normalizeHpRange({
		hpMin = hpMinCombo and hpMinCombo:getCurrentOption() or 0,
		hpMax = hpMaxCombo and hpMaxCombo:getCurrentOption() or 100
	})
	local creatures = 1

	if creaturesCombo and creaturesCombo.getCurrentOption then
		local option = creaturesCombo:getCurrentOption()
		local text = type(option) == "table" and option.text or tostring(option or "1")

		creatures = clampCreatures(text)
	end

	local form = {
		type = selectedShooterAction.type,
		id = selectedShooterAction.id,
		hpMin = var_193_6,
		hpMax = var_193_7,
		creatures = creatures
	}

	if selectedShooterAction.type == "rune" or selectedShooterAction.type == "spell" and selectedShooterAction.crossHairTarget then
		local useToRow = addShooterWindow:recursiveGetChildById("addShooterUseToRow")

		if var_0_42(selectedShooterAction) then
			form.useTo = "target"
		elseif useToRow and useToRow:isVisible() and useToCombo then
			form.useTo = normalizeUseToOption(useToCombo:getCurrentOption())
		else
			form.useTo = "target"
		end
	end

	if selectedShooterAction.type == "spell" and selectedShooterAction.useHarmony == true then
		form.harmony = clampHarmony(harmonyCombo and harmonyCombo:getCurrentOption() or 1)
	end

	if selectedShooterAction.type == "spell" and var_0_38[selectedShooterAction.id] then
		form.intervalMs = var_0_101(hpMin and hpMin:getCurrentOption() or nil, selectedShooterAction.id)
	end

	if selectedShooterAction.type == "spell" and selectedShooterAction.directional == true then
		local autoTurnCheck = addShooterWindow:recursiveGetChildById("addShooterAutoTurnCheck")

		form.turnToCast = autoTurnCheck and autoTurnCheck:isChecked() or false
	end

	if HelperShooter.isSingleTargetAction(selectedShooterAction, form.useTo) then
		local addShooterCastOnePlusCheck = addShooterWindow:recursiveGetChildById("addShooterCastOnePlusCheck")

		form.onlyWhenAlone = addShooterCastOnePlusCheck and not addShooterCastOnePlusCheck:isChecked() or nil
	end

	return form
end

local function populateShooterEntryForm(entry)
	if not addShooterWindow or addShooterWindow:isDestroyed() then
		return
	end

	local hpMinCombo = addShooterWindow:recursiveGetChildById("addShooterHpMinEdit")
	local addShooterHpMaxEdit = addShooterWindow:recursiveGetChildById("addShooterHpMaxEdit")
	local addShooterCreaturesCombo = addShooterWindow:recursiveGetChildById("addShooterCreaturesCombo")
	local addShooterUseToCombo = addShooterWindow:recursiveGetChildById("addShooterUseToCombo")
	local harmonyCombo = addShooterWindow:recursiveGetChildById("addShooterHarmonyCombo")
	local addShooterIntervalCombo = addShooterWindow:recursiveGetChildById("addShooterIntervalCombo")
	local okBtn = addShooterWindow:recursiveGetChildById("addShooterOkButton")
	local hpMin, hpMax = normalizeHpRange(entry or {})

	if hpMinCombo then
		hpMinCombo:setCurrentOption(tostring(hpMin))
	end

	if addShooterHpMaxEdit then
		addShooterHpMaxEdit:setCurrentOption(tostring(hpMax))
	end

	if addShooterCreaturesCombo then
		addShooterCreaturesCombo:setCurrentOption(tostring(clampCreatures(entry and entry.creatures or 1)) .. "+")
	end

	if addShooterUseToCombo then
		local useToText = "Target"

		if entry then
			local useTo = entry.useTo or entry.selfCast == true and "self" or "target"

			if useTo == "self" then
				useToText = "Yourself"
			elseif useTo == "bestTile" then
				useToText = "Best Position"
			end
		end

		addShooterUseToCombo:setCurrentOption(useToText)
	end

	if harmonyCombo then
		harmonyCombo:setCurrentOption(var_0_103(entry and entry.harmony or 1))
	end

	local autoTurnCheck = addShooterWindow:recursiveGetChildById("addShooterAutoTurnCheck")

	if autoTurnCheck then
		autoTurnCheck:setChecked(entry ~= nil and entry.turnToCast == true)
	end

	local addShooterCastOnePlusCheck = addShooterWindow:recursiveGetChildById("addShooterCastOnePlusCheck")

	if addShooterCastOnePlusCheck then
		addShooterCastOnePlusCheck:setChecked(not entry or entry.onlyWhenAlone ~= true)
	end

	if okBtn then
		okBtn:setEnabled(false)
	end

	if entry and entry.id then
		if entry.type == "spell" then
			local spell = Spells.getSpellDataById(entry.id)

			if spell then
				setSelectedShooterAction({
					type = "spell",
					id = entry.id,
					name = Spells.getSpellNameByWords(spell.words) or spell.words,
					words = spell.words,
					iconId = resolveSpellIconId(spell),
					useHarmony = spell.useHarmony == true,
					crossHairTarget = spell.crossHairTarget == true,
					noBestTile = spell.special == true,
					directional = spell.directional == true
				})
			end
		elseif entry.type == "rune" then
			local rune = Spells.getRuneSpellByItem(entry.id)

			setSelectedShooterAction({
				type = "rune",
				id = entry.id,
				name = rune and rune.name or "Rune #" .. entry.id
			})
		end
	else
		setSelectedShooterAction(nil)
	end

	if addShooterIntervalCombo and entry and entry.type == "spell" and var_0_38[entry.id] then
		addShooterIntervalCombo:setCurrentOption(var_0_102(entry.intervalMs, entry.id))
	end
end

local function populateAssignSpellRows()
	if not assignSpellsPanel then
		return
	end

	assignSpellsPanel:destroyChildren()

	local spellProfile = getSpellProfile()
	local vocId = 0
	local player = g_game.getLocalPlayer()

	if player and type(translateVocation) == "function" then
		vocId = translateVocation(player:getVocation())
	end

	local sortedSpells = Spells.getSpellNamesSortedForVocation(vocId, spellProfile)
	local visibleIdx = 0

	for _, spellName in ipairs(sortedSpells) do
		local spellData = getSpellInfoByName(spellProfile, spellName)

		if spellData and isShooterAssignableSpell(spellData) then
			visibleIdx = visibleIdx + 1

			local row = g_ui.createWidget("HelperAttackSpellListRow", assignSpellsPanel)

			row.spellName = spellName
			row.spellInfo = spellData
			row.spellId = spellData.id
			row.nameLower = spellName:lower()
			row.wordsLower = (spellData.words or ""):lower()

			refreshSpellActionTooltip(row, spellData.words)

			local icon = row:getChildById("spellIcon")

			if icon then
				icon:setImageSource(SpelllistSettings[spellProfile].iconFile)

				local iconId = SpellIcons[spellData.id]

				icon:setImageClip(Spells.getImageClip(iconId, spellProfile))
			end

			local nameLabel = row:getChildById("spellName")

			if nameLabel then
				nameLabel:setText(spellName)
			end

			local wordsLabel = row:getChildById("spellWords")

			if wordsLabel then
				wordsLabel:setText(spellData.words)
			end

			local gray = row:getChildById("spellIconGray")

			if gray then
				gray:setVisible(not playerCanUseAttackSpell(spellData))
				row:raiseChild(gray)
			end
		end
	end

	local okBtn = assignSpellWindow and assignSpellWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setEnabled(false)
	end
end

local function populateAssignRuneRows()
	if not assignSpellsPanel then
		showFailure("Could not load rune list.")

		return
	end

	assignSpellsPanel:destroyChildren()

	if not SpellRunesData then
		showFailure("Rune data not loaded.")

		return
	end

	local runes = {}

	for itemId, runeData in pairs(SpellRunesData) do
		if isHelperAttackRune(itemId, runeData) then
			table.insert(runes, {
				itemId = itemId,
				runeData = runeData
			})
		end
	end

	table.sort(runes, function(a, b)
		return (a.runeData.name or ""):lower() < (b.runeData.name or ""):lower()
	end)

	local visibleIdx = 0

	for _, runeEntry in ipairs(runes) do
		local itemId = runeEntry.itemId
		local runeData = runeEntry.runeData
		local displayName = capitalizeWords(runeData.name or "Rune #" .. itemId)

		visibleIdx = visibleIdx + 1

		local row = g_ui.createWidget("HelperAttackRuneListRow", assignSpellsPanel)

		row.runeId = itemId
		row.runeName = displayName
		row.runeData = runeData
		row.runeAvailable = playerCanUseAttackRune(runeData)
		row.nameLower = displayName:lower()

		local icon = row:getChildById("runeIcon")

		if icon then
			icon:setItemId(itemId)
		end

		local background = row:getChildById("runeIconBackground")

		if background then
			background:setVisible(true)
		end

		local gray = row:getChildById("runeIconGray")

		if gray then
			gray:setVisible(not row.runeAvailable)
			row:raiseChild(gray)
		end

		local nameLabel = row:getChildById("runeName")

		if nameLabel then
			nameLabel:setText(displayName)
		end
	end

	if visibleIdx == 0 then
		showFailure("No attack runes available.")
	end

	local okBtn = assignSpellWindow and assignSpellWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setEnabled(false)
	end
end

function populateAssignList()
	if assignMode == "runes" then
		populateAssignRuneRows()
	else
		populateAssignSpellRows()
	end
end

function filterAssignRows(text)
	if not assignSpellsPanel then
		return
	end

	text = text or ""

	local active = #text > 0
	local lower = active and text:lower() or ""
	local onlyLearnt = false

	if assignSpellWindow then
		local learntCb = assignSpellWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

		onlyLearnt = learntCb and learntCb:isChecked() or false
	end

	for _, row in pairs(assignSpellsPanel:getChildren()) do
		local visible = true

		if assignMode == "spells" and onlyLearnt and not playerCanUseAttackSpell(row.spellInfo) then
			visible = false
		elseif assignMode == "runes" and onlyLearnt and row.runeAvailable == false then
			visible = false
		end

		if active then
			visible = visible and (row.nameLower and row.nameLower:find(lower, 1, true) ~= nil or row.wordsLower and row.wordsLower:find(lower, 1, true) ~= nil)
		end

		row:setVisible(visible)
	end

	local firstVisible

	for _, row in ipairs(assignSpellsPanel:getChildren()) do
		if row:isVisible() then
			firstVisible = row

			break
		end
	end

	if firstVisible then
		focusAssignRow(firstVisible)
	else
		focusAssignRow(nil)
	end
end

function updateAssignModeButtons()
	if not assignSpellWindow or assignSpellWindow:isDestroyed() then
		return
	end

	local spellsBtn = assignSpellWindow:recursiveGetChildById("shooterAssignSpellsBtn")
	local runesBtn = assignSpellWindow:recursiveGetChildById("shooterAssignRunesBtn")

	if spellsBtn then
		spellsBtn:setOn(assignMode == "spells")
	end

	if runesBtn then
		runesBtn:setOn(assignMode == "runes")
	end

	local learntPanel = assignSpellWindow:recursiveGetChildById("onlyShowLearntSpellsPanel")

	if learntPanel then
		learntPanel:setVisible(true)
	end

	local learntCheckBox = assignSpellWindow:recursiveGetChildById("onlyShowLearntSpellsCheckBox")

	if learntCheckBox then
		learntCheckBox:setText(assignMode == "runes" and tr("Only show usable runes") or tr("Only show learnt spells"))
	end

	if assignSpellWindow.setText then
		assignSpellWindow:setText(assignMode == "runes" and tr("Assign Rune") or tr("Assign Spell"))
	end

	local okBtn = assignSpellWindow:recursiveGetChildById("okButton")

	if okBtn then
		okBtn:setText(tr("Ok"))
	end
end

function HelperShooter.setAssignMode(mode)
	if not assignSpellWindow or assignSpellWindow:isDestroyed() then
		return
	end

	if not assignSpellsPanel then
		showFailure("Could not load rune list.")

		return
	end

	assignMode = mode == "runes" and "runes" or "spells"

	updateAssignModeButtons()
	populateAssignList()
	filterAssignRows("")

	local edit = assignSpellWindow and assignSpellWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:setText("")
	end
end

function HelperShooter.openAssignWindow(editIndex)
	closeEntryWindowInternal()

	editingPriorityListIndex = editIndex
	addShooterWindow = g_ui.loadUI("assign_shooter", g_ui.getRootWidget())

	if not addShooterWindow then
		editingPriorityListIndex = nil

		return
	end

	if ctx and ctx.applyWidgetLanguage then
		ctx.applyWidgetLanguage(addShooterWindow)
	end

	bindShooterEntryActionPreview()

	local profile = addShooterWindow:recursiveGetChildById("addShooterCastOnePlusCheck")

	if profile then
		function profile.onCheckChange()
			HelperShooter.refreshCastOnePlusRow()
		end
	end

	local addShooterUseToCombo = addShooterWindow:recursiveGetChildById("addShooterUseToCombo")

	if addShooterUseToCombo then
		function addShooterUseToCombo.onOptionChange()
			HelperShooter.refreshCastOnePlusRow()
		end
	end

	local profile = getShooterProfile()
	local editEntry = editIndex and profile.priorityList and profile.priorityList[editIndex]

	addShooterWindow:setText(editEntry and tr("Edit Shooter") or tr("Add Shooter"))
	populateShooterEntryForm(editEntry)
	addShooterWindow:raise()
	addShooterWindow:focus()
end

function HelperShooter.openEditAssignWindow(index)
	local profile = getShooterProfile()

	if not index then
		local list = widget("shooterPriorityList")
		local focused = list and list:getFocusedChild()

		index = focused and focused.shooterEntryIndex
	end

	if not profile.priorityList or not profile.priorityList[index] then
		return
	end

	HelperShooter.openAssignWindow(index)
end

function HelperShooter.closeAssignWindow()
	closeAssignWindowInternal()
end

function HelperShooter.closeEntryWindow()
	closeEntryWindowInternal()
end

function HelperShooter.filterSpells(text)
	filterAssignRows(text)
end

function HelperShooter.clearSpellFilter()
	if not assignSpellWindow or assignSpellWindow:isDestroyed() then
		return
	end

	local edit = assignSpellWindow:recursiveGetChildById("filterTextEdit")

	if edit then
		edit:setText("")
		edit:focus()
	end

	filterAssignRows("")
end

function HelperShooter.onAssignLearntChange()
	if not assignSpellWindow or assignSpellWindow:isDestroyed() then
		return
	end

	local edit = assignSpellWindow:recursiveGetChildById("filterTextEdit")

	filterAssignRows(edit and edit:getText() or "")
end

function HelperShooter.assignOk()
	if not assignSpellsPanel then
		return
	end

	local focused = assignSpellsPanel:getFocusedChild()

	if not focused then
		return
	end

	if assignMode == "spells" and focused.spellId then
		setSelectedShooterAction({
			type = "spell",
			id = focused.spellId,
			name = focused.spellName,
			words = focused.spellInfo and focused.spellInfo.words or "",
			iconId = focused.spellInfo and SpellIcons[focused.spellInfo.id] or 0,
			useHarmony = focused.spellInfo and focused.spellInfo.useHarmony == true,
			crossHairTarget = focused.spellInfo and focused.spellInfo.crossHairTarget == true or false,
			noBestTile = focused.spellInfo and focused.spellInfo.special == true or false,
			directional = focused.spellInfo and focused.spellInfo.directional == true or false
		})
	elseif assignMode == "runes" and focused.runeId then
		setSelectedShooterAction({
			type = "rune",
			id = focused.runeId,
			name = focused.runeName
		})
	else
		return
	end

	closeAssignWindowInternal()
end

function HelperShooter.addEntryOk()
	local form = readShooterEntryForm()

	if not form then
		return
	end

	local profile = getShooterProfile()

	profile.priorityList = profile.priorityList or {}

	local oldEntry = editingPriorityListIndex and profile.priorityList[editingPriorityListIndex]

	form.enabled = oldEntry and oldEntry.enabled ~= false
	form.forceCast = oldEntry and oldEntry.forceCast == true

	local focusIndex = editingPriorityListIndex

	if editingPriorityListIndex and oldEntry then
		profile.priorityList[editingPriorityListIndex] = form
	else
		table.insert(profile.priorityList, form)

		focusIndex = #profile.priorityList
	end

	closeEntryWindowInternal()
	HelperShooter.refreshPriorityListUI()

	if focusIndex then
		focusPriorityRowByIndex(focusIndex)
	end

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

function HelperShooter.onHpTextChange(edit)
	if not edit or not edit.getText then
		return
	end

	local digits = tostring(edit:getText() or ""):gsub("%D", "")

	if digits ~= edit:getText() then
		edit:setText(digits)
	end
end

function HelperShooter.onHpFocusChange(edit, focused)
	if focused or not edit or not edit.getText then
		return
	end

	edit:setText(tostring(clampPercent(edit:getText(), edit:getId() == "addShooterHpMaxEdit" and 100 or 0)))
end

function HelperShooter.loadShooterProfileByName(profileName, skipSave, forceRefresh)
	ensureProfiles()

	if not shooterState.shooterProfiles[profileName] then
		return
	end

	if shooterState.selectedShooterProfile == profileName and not forceRefresh then
		return false
	end

	shooterState.selectedShooterProfile = profileName
	lastCastIndex = 0

	local presets = widget("shooterPresets")

	if presets and getPresetComboOptionText(presets) ~= profileName then
		presets:setCurrentOption(profileName, true)
	end

	local removeButton = widget("shooterRemovePresetBtn")

	if removeButton then
		removeButton:setEnabled(getShooterProfileCount() > 1)
	end

	if not ctx or not ctx.isTabActive or ctx.isTabActive("shooter") then
		HelperShooter.refreshPriorityListUI()
	end

	if not skipSave then
		saveConfigIfReady(true)
	end

	return true
end

function HelperShooter.loadProfileOptions()
	local presets = widget("shooterPresets")

	if not presets or not presets.clearOptions or not presets.addOption then
		return
	end

	ensureProfiles()

	local names = {}

	for name in pairs(shooterState.shooterProfiles) do
		table.insert(names, name)
	end

	table.sort(names)
	withSuppressedPresetEvents(function()
		presets:clearOptions()

		for _, name in ipairs(names) do
			presets:addOption(name)
		end

		presets:setCurrentOption(shooterState.selectedShooterProfile, true)
	end)

	local removeButton = widget("shooterRemovePresetBtn")

	if removeButton then
		removeButton:setEnabled(#names > 1)
	end
end

function HelperShooter.getPresetHotkey(profileName)
	ensureProfiles()

	local profile = shooterState.shooterProfiles[profileName]

	if not profile then
		return nil
	end

	return type(profile.hotkey) == "string" and profile.hotkey or ""
end

function HelperShooter.hasPresetHotkey(combo, excludedProfileName)
	if type(combo) ~= "string" or combo == "" then
		return false
	end

	ensureProfiles()

	for profileName, profile in pairs(shooterState.shooterProfiles) do
		if profileName ~= excludedProfileName and type(profile) == "table" and profile.hotkey == combo then
			return true
		end
	end

	return false
end

function HelperShooter.setPresetHotkey(profileName, combo)
	ensureProfiles()

	local profile = shooterState.shooterProfiles[profileName]

	if not profile then
		return false
	end

	profile.hotkey = type(combo) == "string" and combo ~= "" and combo or nil

	return true
end

function HelperShooter.openPresetMenu(combo)
	if not combo or not combo.options then
		return false
	end

	local menu = g_ui.createWidget(combo:getStyleName() .. "PopupMenu")

	if not menu then
		return false
	end

	menu:setId(combo:getId() .. "PopupMenu")

	local menuWidth = combo:getWidth()

	for _, option in ipairs(combo.options) do
		local profileName = option.text
		local optionWidget = menu:addOption(profileName, function()
			combo:setCurrentOption(profileName)
		end, nil, false, {
			minWidth = combo:getWidth()
		})
		local editButton = g_ui.createWidget("Button", optionWidget)

		editButton:setId("editHotkey")
		editButton:setSize({
			width = 13,
			height = 13
		})
		editButton:addAnchor(AnchorRight, "parent", AnchorRight)
		editButton:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		editButton:setMarginRight(2)
		editButton:setMarginTop(1)
		editButton:setIcon("/images/ui/icon-edit")

		function editButton.onClick()
			if menu and not menu:isDestroyed() then
				menu:destroy()
			end

			modules.game_helper.openPresetHotkeyWindow(profileName)
		end

		menuWidth = math.max(menuWidth, optionWidget:getTextSize().width + 34)
	end

	menu:setWidth(menuWidth)
	menu:display({
		x = combo:getX(),
		y = combo:getY() + combo:getHeight()
	})
	connect(menu, {
		onDestroy = function()
			if combo and not combo:isDestroyed() then
				combo:setOn(false)
			end
		end
	})
	combo:setOn(true)

	return true
end

function HelperShooter.toggleShooterPreset(combo, hideMessage)
	if suppressPresetEvents then
		return
	end

	if ctx and ctx.isLoadingConfig and ctx.isLoadingConfig() then
		return
	end

	if not combo then
		return
	end

	local current = combo.getCurrentOption and combo:getCurrentOption() or nil
	local option = type(current) == "table" and current.text or ""

	if shooterState.shooterProfiles[option] then
		if not HelperShooter.loadShooterProfileByName(option) then
			return
		end
	else
		HelperShooter.loadProfileOptions()

		return
	end

	if not hideMessage then
		showMessage(shooterUiLanguage == "pt" and string.format("Perfil do Shooter alterado para %s.", option) or string.format("Shooter profile switched to %s.", option))
	end
end

local function invalidPresetName(name)
	ensureProfiles()

	if shooterState.shooterProfiles[name] then
		return true, "There is already a preset with this name."
	elseif name:len() == 0 then
		return true, "The name cannot be empty."
	elseif name:len() > 7 then
		return true, "The name cannot be longer than 7 characters."
	elseif name:match("[^%w]") then
		return true, "The name cannot contain special characters or spaces."
	end

	return false
end

function HelperShooter.sendRenameOrAddWindow(isRename)
	if presetWindow and not presetWindow:isDestroyed() then
		presetWindow:destroy()
	end

	presetWindow = g_ui.loadUI("shooter_preset", g_ui.getRootWidget())

	if not presetWindow then
		return
	end

	local content = presetWindow:getChildById("contentPanel") or presetWindow.contentPanel

	if not content then
		return
	end

	if isRename then
		presetWindow:setText("Rename shooter preset")
		content:getChildById("target"):setText(shooterState.selectedShooterProfile)
	else
		presetWindow:setText("Add shooter preset")
		content:getChildById("target"):setText("")
	end

	presetWindow:show()
	presetWindow:raise()
	presetWindow:focus()
	content:getChildById("target"):focus()

	local function onWrite()
		local warning = content:getChildById("warning")
		local text = content:getChildById("target"):getText()
		local invalid, message = invalidPresetName(text)

		if invalid then
			warning:setVisible(true)
			warning:setTooltip(message)
		else
			warning:setVisible(false)
			warning:setTooltip("")
		end
	end

	local function closePreset()
		if presetWindow and not presetWindow:isDestroyed() then
			presetWindow:destroy()
		end

		presetWindow = nil
	end

	content:getChildById("cancelButton").onClick = closePreset
	presetWindow.onEscape = closePreset
	content:getChildById("target").onTextChange = onWrite

	if isRename then
		content:getChildById("okButton").onClick = function()
			local input = content:getChildById("target"):getText()

			if input == shooterState.selectedShooterProfile or invalidPresetName(input) then
				return
			end

			local oldName = shooterState.selectedShooterProfile

			shooterState.shooterProfiles[input] = shooterState.shooterProfiles[oldName]
			shooterState.shooterProfiles[oldName] = nil
			shooterState.selectedShooterProfile = input

			HelperShooter.loadProfileOptions()
			HelperShooter.loadShooterProfileByName(input, true, true)
			closePreset()

			if ctx and ctx.rebindCombatHotkeys then
				ctx.rebindCombatHotkeys()
			end

			if ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		end
	else
		content:getChildById("okButton").onClick = function()
			local input = content:getChildById("target"):getText()

			if invalidPresetName(input) then
				return
			end

			shooterState.shooterProfiles[input] = deepCopy(defaultShooterProfile)
			shooterState.selectedShooterProfile = input

			HelperShooter.loadProfileOptions()
			HelperShooter.loadShooterProfileByName(input, true, true)
			closePreset()

			if ctx and ctx.saveConfig then
				ctx.saveConfig()
			end
		end
	end
end

function HelperShooter.removeProfile()
	ensureProfiles()

	if getShooterProfileCount() <= 1 then
		showMessage("You can't delete your only preset.")

		return
	end

	local currentName = shooterState.selectedShooterProfile

	if not currentName or not shooterState.shooterProfiles[currentName] then
		HelperShooter.loadProfileOptions()

		return
	end

	local remaining = {}

	for name in pairs(shooterState.shooterProfiles) do
		if name ~= currentName then
			table.insert(remaining, name)
		end
	end

	table.sort(remaining)

	shooterState.shooterProfiles[currentName] = nil
	shooterState.selectedShooterProfile = shooterState.shooterProfiles.Default and "Default" or remaining[1]

	HelperShooter.loadProfileOptions()
	HelperShooter.loadShooterProfileByName(shooterState.selectedShooterProfile, true, true)
	showMessage(string.format("Preset %s deleted.", currentName))

	if ctx and ctx.rebindCombatHotkeys then
		ctx.rebindCombatHotkeys()
	end

	if ctx and ctx.saveConfig then
		ctx.saveConfig()
	end
end

function HelperShooter.onShooterPzAutoChange()
	if suppressShooterSettingsChange then
		return
	end

	shooterPzAuto = readShooterPzAutoWidget()

	saveConfigIfReady()
	HelperShooter.refreshProtectionZoneState()
end

function HelperShooter.refreshLanguage(language)
	shooterUiLanguage = language == "pt" and "pt" or "en"

	local combo = widget("shooterPzAutoCombo")

	if not combo or not combo.clearOptions or not combo.addOption then
		return
	end

	suppressShooterSettingsChange = true

	combo:clearOptions()
	combo:addOption(shooterUiLanguage == "pt" and "Ativado" or "Enabled", SHOOTER_PZ_AUTO_ENABLED)
	combo:addOption(shooterUiLanguage == "pt" and "Desativado" or "Disabled", SHOOTER_PZ_AUTO_DISABLED)
	applyShooterPzAutoWidget(shooterPzAuto)

	suppressShooterSettingsChange = false
end

local function migrateLegacyPriorityList(data)
	if not data.priorityList or #data.priorityList == 0 then
		return
	end

	if data.shooterProfiles and next(data.shooterProfiles) then
		return
	end

	ensureProfiles()

	local profile = shooterState.shooterProfiles.Default

	profile.priorityList = {}

	for _, entry in ipairs(data.priorityList) do
		if entry.isRune and entry.itemId then
			table.insert(profile.priorityList, {
				type = "rune",
				id = entry.itemId,
				enabled = entry.enabled ~= false,
				hpMin = tonumber(entry.hpMin) or 0,
				hpMax = tonumber(entry.hpMax) or 100,
				rangeMin = tonumber(entry.rangeMin) or 1,
				rangeMax = tonumber(entry.rangeMax) or 7,
				creatures = clampCreatures(entry.creatures),
				forceCast = entry.forceCast == true,
				useTo = entry.useTo or entry.selfCast == true and "self" or "target"
			})
		elseif entry.spellName then
			local spellProfile = getSpellProfile()
			local info = getSpellInfoByName(spellProfile, entry.spellName)

			if info then
				table.insert(profile.priorityList, {
					type = "spell",
					id = info.id,
					enabled = entry.enabled ~= false,
					hpMin = tonumber(entry.hpMin) or 0,
					hpMax = tonumber(entry.hpMax) or 100,
					rangeMin = tonumber(entry.rangeMin) or 1,
					rangeMax = tonumber(entry.rangeMax) or 7,
					creatures = clampCreatures(entry.creatures),
					intervalMs = entry.intervalMs,
					forceCast = entry.forceCast == true,
					useTo = entry.useTo or entry.selfCast == true and "self" or "target"
				})
			end
		end
	end
end

function HelperShooter.bindPresetHotkeys(arg_236_0)
	for _, binding in pairs(boundPresetHotkeys or {}) do
		g_keyboard.unbindKeyPress(binding.key, binding.callback)
	end

	boundPresetHotkeys = {}

	ensureProfiles()

	local skippedPresetHotkeys = {}

	for profileName, profile in pairs(shooterState.shooterProfiles) do
		local hotkey = type(profile) == "table" and profile.hotkey or nil

		if type(hotkey) == "string" and hotkey ~= "" then
			if arg_236_0 and arg_236_0(profileName, hotkey) or false then
				table.insert(skippedPresetHotkeys, {
					profile = profileName,
					key = hotkey
				})
			else
				local boundProfileName = profileName
				local boundHotkey = hotkey

				local function callback()
					if not HotkeyUtils.canPerformKeyCombo(boundHotkey) then
						return
					end

					if not shooterState.shooterProfiles[boundProfileName] then
						return
					end

					if not HelperShooter.loadShooterProfileByName(boundProfileName) then
						return
					end

					showMessage(shooterUiLanguage == "pt" and string.format("Perfil do Shooter alterado para %s.", boundProfileName) or string.format("Shooter profile switched to %s.", boundProfileName))
				end

				boundPresetHotkeys[boundProfileName] = {
					key = boundHotkey,
					callback = callback
				}

				g_keyboard.bindKeyPress(boundHotkey, callback)
			end
		end
	end

	return skippedPresetHotkeys
end

function HelperShooter.unbindPresetHotkeys()
	for _, binding in pairs(boundPresetHotkeys or {}) do
		g_keyboard.unbindKeyPress(binding.key, binding.callback)
	end

	boundPresetHotkeys = {}
end

function HelperShooter.init(pctx)
	ctx = pctx
	lastCastIndex = 0
	lastGlobalCastAt = 0
	var_0_41 = {}

	ensureProfiles()

	if HelperPosture and HelperPosture.init then
		HelperPosture.init(pctx)
	end

	HelperShooter.refreshLanguage(ctx and ctx.getLanguage and ctx.getLanguage() or "en")
end

function HelperShooter.onShow()
	HelperShooter.refreshPriorityListUI()

	if HelperPosture and HelperPosture.refreshUI then
		HelperPosture.refreshUI()
	end

	clearPriorityListSelection()

	local var_240_0 = widget("shooterPriorityList")

	if var_240_0 and not var_240_0._shooterButtonsSyncConnected then
		var_240_0._shooterButtonsSyncConnected = true

		connect(var_240_0, {
			onChildFocusChange = function()
				HelperShooter.syncActionButtons()
			end
		})
	end
end

function HelperShooter.onHide()
	closeEntryWindowInternal()

	if presetWindow and not presetWindow:isDestroyed() then
		presetWindow:destroy()
	end

	presetWindow = nil

	HelperShooter.destroyPriorityDragGhost()
	clearPriorityListSelection()
end

function HelperShooter.onGameStart()
	lastCastIndex = 0
	lastGlobalCastAt = 0
	var_0_41 = {}
	comboNextIndex = 1
	shooterEnabledBeforeFollow = false
	wasFollowingCreature = false

	HelperShooter.syncHotkeyStatus()
	var_0_141(true)

	if HelperPosture and HelperPosture.onGameStart then
		HelperPosture.onGameStart()
	end
end

function HelperShooter.terminate()
	HelperShooter.unbindPresetHotkeys()
	HelperShooter.onHide()

	spellPendingSince = {}
	groupPendingSince = {}
	multiUsePendingSince = 0
	lastCastIndex = 0
	lastGlobalCastAt = 0
	var_0_41 = {}
	shooterEnabledBeforePz = false
	wasInProtectionZone = false
	shooterEnabledBeforeFollow = false
	wasFollowingCreature = false
	suppressShooterSettingsChange = false
	shooterUiLanguage = "en"

	if HelperPosture and HelperPosture.terminate then
		HelperPosture.terminate()
	end
end

function HelperShooter.collectConfig(config)
	config.shooter = config.shooter or {}

	local var_245_0 = widget("enableShooterCheckBox")
	local var_245_1 = var_245_0 and var_245_0:isChecked() or false

	config.shooter.enableShooter = var_245_1 or isShooterPzAutoEnabled() and shooterEnabledBeforePz == true
	config.shooter.pzAuto = readShooterPzAutoWidget()

	ensureProfiles()

	config.shooter.selectedShooterProfile = shooterState.selectedShooterProfile
	config.shooter.shooterProfiles = deepCopy(shooterState.shooterProfiles)
	config.shooter.magicShooterOnHold = magicShooterOnHold
	config.shooter.comboMode = comboMode

	if HelperPosture and HelperPosture.collectConfig then
		HelperPosture.collectConfig(config)
	end
end

function HelperShooter.loadFromConfig(config)
	local data = config.shooter or {}
	local enableCheck = widget("enableShooterCheckBox")

	if enableCheck then
		enableCheck:setChecked(data.enableShooter == true)
	end

	hotkeyShooterStatus = data.enableShooter == true
	shooterPzAuto = normalizeShooterPzAuto(data.pzAuto)

	applyShooterPzAutoWidget(shooterPzAuto)

	shooterEnabledBeforePz = false
	wasInProtectionZone = false
	shooterEnabledBeforeFollow = false
	wasFollowingCreature = false

	setShooterCheckEnabled(true)

	shooterState.selectedShooterProfile = data.selectedShooterProfile or "Default"

	if data.shooterProfiles then
		shooterState.shooterProfiles = deepCopy(data.shooterProfiles)
	else
		shooterState.shooterProfiles = {
			Default = deepCopy(defaultShooterProfile)
		}
	end

	migrateLegacyPriorityList(data)
	ensureProfiles()
	withSuppressedPresetEvents(function()
		HelperShooter.loadProfileOptions()
		HelperShooter.loadShooterProfileByName(shooterState.selectedShooterProfile, true, true)
	end)

	magicShooterOnHold = data.magicShooterOnHold == true
	lastCastIndex = 0
	comboMode = data.comboMode == true
	comboNextIndex = 1

	local comboCheck = widget("enableComboModeCheckBox")

	if comboCheck then
		comboCheck:setChecked(comboMode)
	end

	if HelperPosture and HelperPosture.loadFromConfig then
		HelperPosture.loadFromConfig(config)
	end
end

function HelperShooter.isComboMode()
	return comboMode == true
end

function HelperShooter.setComboMode(enabled)
	comboMode = enabled == true
	comboNextIndex = 1

	saveConfigIfReady()

	return comboMode
end

function HelperShooter.getActiveProfile()
	return getShooterProfile()
end
