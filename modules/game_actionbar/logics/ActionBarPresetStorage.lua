actionBarSettingsCache = nil

local GLOBAL_ACTIONBAR_FILE = "/settings/actionbar_presets.json"
local LEGACY_MIGRATION_FLAG = "/settings/.actionbar_presets_migrated"

local function isActionBarSlotKey(key)
	return type(key) == "string" and key:match("^slot%d+$") ~= nil
end

local function isLegacyFlatActionBarFormat(data)
	if type(data) ~= "table" or table.empty(data) then
		return false
	end

	for key in pairs(data) do
		if isActionBarSlotKey(key) then
			return true
		end
	end

	return false
end

function getActionBarDefaultPresetName()
	if Keybind and Keybind.currentPreset and Keybind.currentPreset ~= "" then
		return Keybind.currentPreset
	end

	if Keybind and Keybind.presets and Keybind.presets[1] then
		return Keybind.presets[1]
	end

	return "Default"
end

local function migrateLegacyFlatSlotsToPreset(data, presetName)
	local slots = {}

	for key, value in pairs(data) do
		if isActionBarSlotKey(key) and type(value) == "table" then
			slots[key] = value
		end
	end

	return {
		[presetName] = slots
	}
end

local function ensureActionBarSettingsDirectory()
	if not g_resources.directoryExists("/settings/") then
		g_resources.makeDir("/settings/")
	end
end

local function decodeJsonFile(path)
	if not path or not g_resources.fileExists(path) then
		return nil
	end

	local status, result = pcall(function()
		return json.decode(g_resources.readFileContents(path))
	end)

	if status and type(result) == "table" then
		return result
	end

	if not status then
		g_logger.error("Error while reading action bar settings from " .. path .. ": " .. tostring(result))
	end

	return nil
end

local function encodeAndWriteDocument(path, data)
	local status, encoded = pcall(function()
		return json.encode(data, 2)
	end)

	if not status then
		g_logger.error("Error while saving action bar settings: " .. tostring(encoded))

		return false
	end

	if encoded:len() > 104857600 then
		g_logger.error("Action bar settings file is too large, not saved")

		return false
	end

	ensureActionBarSettingsDirectory()
	g_resources.writeFileContents(path, encoded)

	return true
end

local function actionBarSlotHasContent(slot)
	if type(slot) ~= "table" then
		return false
	end

	if slot.words and slot.words ~= "" then
		return true
	end

	if slot.text and slot.text ~= "" then
		return true
	end

	if type(slot.itemId) == "number" and slot.itemId > 0 then
		return true
	end

	if type(slot.passiveId) == "number" then
		return true
	end

	if type(slot.helperId) == "string" and slot.helperId ~= "" then
		return true
	end

	if type(slot.multiHelper) == "table" then
		for helperIndex = 1, 3 do
			if type(slot.multiHelper[helperIndex]) == "string" and slot.multiHelper[helperIndex] ~= "" then
				return true
			end
		end
	end

	if type(slot.multiActions) == "table" and not table.empty(slot.multiActions) then
		return true
	end

	return false
end

function countActionBarSlotsWithContent(slots)
	if type(slots) ~= "table" then
		return 0
	end

	local count = 0

	for _, slot in pairs(slots) do
		if actionBarSlotHasContent(slot) then
			count = count + 1
		end
	end

	return count
end

local function presetHasStoredContent(document, presetName)
	if type(document) ~= "table" or not presetName or presetName == "" then
		return false
	end

	return countActionBarSlotsWithContent(document[presetName]) > 0
end

local function presetNameFromLegacyFileName(fileName)
	if type(fileName) ~= "string" then
		return nil
	end

	local base = fileName:match("^(.+)_actionbar%.json$")

	if not base or base == "" then
		return nil
	end

	if Keybind and Keybind.presets then
		local lower = base:lower()

		for _, preset in ipairs(Keybind.presets) do
			if type(preset) == "string" and preset:lower() == lower then
				return preset
			end
		end
	end

	return base:sub(1, 1):upper() .. base:sub(2)
end

local function mergePresetDocument(target, source, sourceTime, presetNameOverride)
	if type(source) ~= "table" or table.empty(source) then
		return
	end

	target._mergeTimes = target._mergeTimes or {}

	if isLegacyFlatActionBarFormat(source) then
		local presetName = presetNameOverride or getActionBarDefaultPresetName()

		if presetHasStoredContent(target, presetName) then
			return
		end

		if sourceTime >= (target._mergeTimes[presetName] or 0) then
			target[presetName] = source
			target._mergeTimes[presetName] = sourceTime
		end

		return
	end

	for presetName, slots in pairs(source) do
		if presetName == "_mergeTimes" or type(slots) ~= "table" or table.empty(slots) or presetHasStoredContent(target, presetName) then
			-- block empty
		elseif sourceTime >= (target._mergeTimes[presetName] or 0) then
			target[presetName] = slots
			target._mergeTimes[presetName] = sourceTime
		end
	end
end

local function stripMergeMetadata(document)
	if type(document) ~= "table" then
		return {}
	end

	document._mergeTimes = nil

	return document
end

local function migrateLegacyCharacterActionBarFiles(globalDoc)
	local files = g_resources.listDirectoryFiles("/settings/", false, false, false)

	if type(files) ~= "table" then
		return
	end

	for _, fileName in ipairs(files) do
		if type(fileName) == "string" and fileName:match("_actionbar%.json$") then
			local path = "/settings/" .. fileName
			local data = decodeJsonFile(path)

			if data then
				local fileTime = g_resources.getFileTime(path) or 0
				local presetName = presetNameFromLegacyFileName(fileName)

				mergePresetDocument(globalDoc, data, fileTime, presetName)
			end
		end
	end
end

local function migrateLegacyConfigNode(globalDoc)
	local hotkeySettings = g_settings.getNode("game_actionbar")

	if type(hotkeySettings) ~= "table" then
		return
	end

	for charName, charData in pairs(hotkeySettings) do
		if type(charData) == "table" and not table.empty(charData) then
			local presetName = charName

			if Keybind and Keybind.presetToIndex and not Keybind.presetToIndex[presetName] then
				presetName = getActionBarDefaultPresetName()
			end

			local existing = globalDoc[presetName]

			if type(existing) == "table" and not table.empty(existing) then
				-- block empty
			else
				local wrapped = charData

				if isLegacyFlatActionBarFormat(charData) then
					wrapped = {
						[presetName] = charData
					}
				end

				mergePresetDocument(globalDoc, wrapped, os.time())
			end
		end
	end
end

local function backupLegacyCharacterFiles()
	local files = g_resources.listDirectoryFiles("/settings/", false, false, false)

	if type(files) ~= "table" then
		return
	end

	for _, fileName in ipairs(files) do
		if type(fileName) == "string" and fileName:match("_actionbar%.json$") then
			local path = "/settings/" .. fileName
			local backupPath = path .. ".bak"

			if not g_resources.fileExists(backupPath) then
				local contents = g_resources.readFileContents(path)

				if contents and contents ~= "" then
					g_resources.writeFileContents(backupPath, contents)
				end
			end
		end
	end
end

local function runLegacyMigrationIfNeeded()
	if g_resources.fileExists(LEGACY_MIGRATION_FLAG) then
		return
	end

	local globalDoc = decodeJsonFile(GLOBAL_ACTIONBAR_FILE) or {}

	migrateLegacyCharacterActionBarFiles(globalDoc)
	migrateLegacyConfigNode(globalDoc)
	stripMergeMetadata(globalDoc)

	if not table.empty(globalDoc) or g_resources.fileExists(GLOBAL_ACTIONBAR_FILE) then
		encodeAndWriteDocument(GLOBAL_ACTIONBAR_FILE, globalDoc)
	end

	backupLegacyCharacterFiles()
	g_resources.writeFileContents(LEGACY_MIGRATION_FLAG, "1")

	actionBarSettingsCache = nil
end

function invalidateActionBarSettingsCache()
	actionBarSettingsCache = nil
end

function markActionBarPresetsMigrationComplete()
	ensureActionBarSettingsDirectory()
	g_resources.writeFileContents(LEGACY_MIGRATION_FLAG, "1")
end

function beginActionBarBatch()
	actionBarBatchDepth = (actionBarBatchDepth or 0) + 1
end

function endActionBarBatch()
	if actionBarBatchDepth and actionBarBatchDepth > 0 then
		actionBarBatchDepth = actionBarBatchDepth - 1
	end
end

local function isLuaTypeName(value)
	if type(value) ~= "string" then
		return false
	end

	if value == "string" then
		return true
	end

	if value == "number" then
		return true
	end

	if value == "nil" then
		return true
	end

	if value == "boolean" then
		return true
	end

	if value == "table" then
		return true
	end

	if value == "function" then
		return true
	end

	if value == "userdata" then
		return true
	end

	if value == "thread" then
		return true
	end

	return false
end

local function getDefaultFunctionHotkey(slotId)
	if type(slotId) ~= "string" then
		return ""
	end

	local slotNumberText = slotId:match("^slot(%d+)$")

	if not slotNumberText then
		return ""
	end

	local numericValue = tonumber(slotNumberText)

	if not numericValue then
		return ""
	end

	if numericValue < 1 or numericValue > 12 then
		return ""
	end

	return "F" .. tostring(numericValue)
end

local function repairSerializedHotkeys(document)
	if type(document) ~= "table" then
		return false
	end

	local changed = false

	for key, entry in pairs(document) do
		if key ~= "_mergeTimes" and type(entry) == "table" then
			for key, entry in pairs(entry) do
				if type(entry) == "table" then
					local defaultHotkey = getDefaultFunctionHotkey(key)

					if isLuaTypeName(entry.hotkeyChatOn) then
						entry.hotkeyChatOn = defaultHotkey
						changed = true
					end

					if isLuaTypeName(entry.hotkeyChatOff) then
						entry.hotkeyChatOff = defaultHotkey
						changed = true
					end

					if isLuaTypeName(entry.hotkey) then
						entry.hotkey = defaultHotkey
						changed = true
					end
				end
			end
		end
	end

	return changed
end

function readActionBarPresetsDocument()
	runLegacyMigrationIfNeeded()

	if actionBarSettingsCache then
		return actionBarSettingsCache
	end

	local document = decodeJsonFile(GLOBAL_ACTIONBAR_FILE) or {}

	if repairSerializedHotkeys(document) then
		encodeAndWriteDocument(GLOBAL_ACTIONBAR_FILE, document)
	end

	actionBarSettingsCache = document

	return document
end

function writeActionBarPresetsDocument(data)
	if type(data) ~= "table" then
		return false
	end

	stripMergeMetadata(data)
	repairSerializedHotkeys(data)

	if not encodeAndWriteDocument(GLOBAL_ACTIONBAR_FILE, data) then
		return false
	end

	actionBarSettingsCache = data

	return true
end

local function copyActionBarSlotsTable(slots)
	if not slots or table.empty(slots) then
		return {}
	end

	local status, copied = pcall(function()
		return json.decode(json.encode(slots))
	end)

	if status and type(copied) == "table" then
		return copied
	end

	return {}
end

function saveActionBarSlotsForPreset(preset, slots)
	if not preset or preset == "" then
		return
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	local incomingContent = countActionBarSlotsWithContent(slots)
	local existingContent = countActionBarSlotsWithContent(document[preset])

	if incomingContent == 0 and existingContent > 0 then
		g_logger.info(string.format("[actionbar] skip empty save for preset \"%s\" (%d stored slots)", preset, existingContent))

		return
	end

	document[preset] = slots

	writeActionBarPresetsDocument(document)
end

function getActionBarSlotsForPreset(preset)
	if not preset or preset == "" then
		return nil, false
	end

	local document = readActionBarPresetsDocument()
	local migrated = false

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
		migrated = true
	end

	local slots = document[preset]

	if migrated then
		writeActionBarPresetsDocument(document)
	end

	if slots and type(slots) == "table" and not table.empty(slots) then
		return slots, migrated
	end

	return nil, migrated
end

function copyActionBarPreset(fromPreset, toPreset)
	if not fromPreset or not toPreset or fromPreset == "" or toPreset == "" then
		return
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	local fromSlots = document[fromPreset]

	if fromSlots and not table.empty(fromSlots) then
		document[toPreset] = copyActionBarSlotsTable(fromSlots)
	else
		document[toPreset] = {}
	end

	writeActionBarPresetsDocument(document)
end

function renameActionBarPreset(oldName, newName)
	if not oldName or not newName or oldName == "" or newName == "" or oldName == newName then
		return
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	if document[oldName] then
		document[newName] = document[oldName]
		document[oldName] = nil

		if writeActionBarPresetsDocument(document) and actionBarPreparedPreset == oldName then
			actionBarPreparedPreset = newName
		end
	end
end

function removeActionBarPreset(presetName)
	if not presetName or presetName == "" then
		return
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	if document[presetName] then
		document[presetName] = nil

		if writeActionBarPresetsDocument(document) and actionBarPreparedPreset == presetName then
			actionBarPreparedPreset = nil
		end
	end
end

function replaceActionBarPresetSlots(presetName, slots)
	if not presetName or presetName == "" then
		return 0
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	document[presetName] = slots or {}

	writeActionBarPresetsDocument(document)

	local count = 0

	for _ in pairs(document[presetName]) do
		count = count + 1
	end

	return count
end

function mergeActionBarPresetSlots(presetName, slots)
	if not presetName or presetName == "" or type(slots) ~= "table" or table.empty(slots) then
		return 0
	end

	local document = readActionBarPresetsDocument()

	if isLegacyFlatActionBarFormat(document) then
		document = migrateLegacyFlatSlotsToPreset(document, getActionBarDefaultPresetName())
	end

	if not document[presetName] or type(document[presetName]) ~= "table" then
		document[presetName] = {}
	end

	local count = 0

	for slotId, slotData in pairs(slots) do
		if type(slotData) == "table" then
			document[presetName][slotId] = slotData
			count = count + 1
		end
	end

	writeActionBarPresetsDocument(document)

	return count
end
