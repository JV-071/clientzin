HelperProfileStorage = HelperProfileStorage or {}

local var_0_0 = "/settings"
local var_0_1 = "/characterdata"
local var_0_2 = var_0_0 .. "/game_helper_profiles.json"
local var_0_3 = var_0_2 .. ".bak"
local var_0_4 = var_0_0 .. "/game_helper_profiles.pre-v4.bak"
local var_0_5 = var_0_0 .. "/.game_helper_profiles_initialized_v4"
local var_0_6 = var_0_0 .. "/game_helper_data.json"
local var_0_7 = "game_helper_state.json"
local var_0_8 = 4
local var_0_9 = "Default"
local var_0_10 = 104857600
local var_0_11
local var_0_12 = false
local var_0_13 = false
local var_0_14
local var_0_15 = false
local var_0_16
local var_0_17
local var_0_18

local function var_0_19(arg_1_0, arg_1_1)
	if var_0_11 then
		var_0_11(arg_1_0, "[profile-storage] " .. arg_1_1)
	elseif g_logger then
		(g_logger[arg_1_0] or g_logger.info)("[game_helper] [profile-storage] " .. arg_1_1)
	end
end

local function var_0_20(arg_2_0, arg_2_1)
	if type(arg_2_0) ~= "table" then
		return arg_2_0
	end

	arg_2_1 = arg_2_1 or {}

	if arg_2_1[arg_2_0] then
		return arg_2_1[arg_2_0]
	end

	local var_2_0 = {}

	arg_2_1[arg_2_0] = var_2_0

	for key, entry in pairs(arg_2_0) do
		var_2_0[var_0_20(key, arg_2_1)] = var_0_20(entry, arg_2_1)
	end

	return var_2_0
end

local function var_0_21(arg_3_0, arg_3_1, arg_3_2)
	if arg_3_0 == arg_3_1 then
		return true
	end

	if type(arg_3_0) ~= type(arg_3_1) or type(arg_3_0) ~= "table" then
		return false
	end

	arg_3_2 = arg_3_2 or {}

	if arg_3_2[arg_3_0] == arg_3_1 then
		return true
	end

	arg_3_2[arg_3_0] = arg_3_1

	for key, entry in pairs(arg_3_0) do
		if not var_0_21(entry, arg_3_1[key], arg_3_2) then
			return false
		end
	end

	for iter_3_2 in pairs(arg_3_1) do
		if arg_3_0[iter_3_2] == nil then
			return false
		end
	end

	return true
end

local function var_0_22(arg_4_0)
	return arg_4_0 == "pt" and "pt" or "en"
end

local function var_0_23(arg_5_0)
	local var_5_0, var_5_1 = pcall(g_resources.directoryExists, arg_5_0)

	if var_5_0 and var_5_1 then
		return true
	end

	local var_5_2, var_5_3 = pcall(g_resources.makeDir, arg_5_0)

	if not var_5_2 or var_5_3 == false then
		var_0_19("error", "Failed to create directory " .. tostring(arg_5_0) .. ": " .. tostring(var_5_3))

		return false
	end

	local var_5_4, var_5_5 = pcall(g_resources.directoryExists, arg_5_0)

	return var_5_4 and var_5_5 == true
end

local function var_0_24()
	return var_0_23(var_0_0)
end

local function var_0_25(arg_7_0)
	return var_0_1 .. "/" .. tostring(arg_7_0)
end

local function var_0_26(arg_8_0)
	return var_0_25(arg_8_0) .. "/" .. var_0_7
end

local function var_0_27(arg_9_0)
	if not arg_9_0 or tostring(arg_9_0) == "" then
		return false
	end

	if not var_0_23(var_0_1) then
		return false
	end

	return var_0_23(var_0_25(arg_9_0))
end

local function var_0_28(arg_10_0)
	if not arg_10_0 or not g_resources.fileExists(arg_10_0) then
		return nil, "missing"
	end

	local var_10_0, var_10_1 = pcall(g_resources.readFileContents, arg_10_0)

	if not var_10_0 or type(var_10_1) ~= "string" or var_10_1 == "" then
		return nil, "read"
	end

	local var_10_2, var_10_3 = pcall(json.decode, var_10_1)

	if not var_10_2 or type(var_10_3) ~= "table" then
		return nil, "invalid"
	end

	return var_10_3, nil, var_10_1
end

local function var_0_29(arg_11_0)
	local var_11_0, var_11_1 = pcall(json.encode, arg_11_0, 2)

	if not var_11_0 or type(var_11_1) ~= "string" or var_11_1 == "" then
		return nil, tostring(var_11_1)
	end

	if #var_11_1 > var_0_10 then
		return nil, "document exceeds 100 MB"
	end

	local var_11_2, var_11_3 = pcall(json.decode, var_11_1)

	if not var_11_2 or type(var_11_3) ~= "table" then
		return nil, "encoded document failed validation"
	end

	return var_11_1
end

local function var_0_30(arg_12_0, arg_12_1)
	local var_12_0, var_12_1 = var_0_29(arg_12_1)

	if not var_12_0 then
		var_0_19("error", "Failed to encode " .. tostring(arg_12_0) .. ": " .. tostring(var_12_1))

		return false
	end

	local var_12_2, var_12_3 = pcall(g_resources.writeFileContents, arg_12_0, var_12_0)

	if not var_12_2 or var_12_3 == false then
		var_0_19("error", "Failed to write " .. tostring(arg_12_0) .. ": " .. tostring(var_12_3))

		return false
	end

	return true
end

local function var_0_31(arg_13_0, arg_13_1)
	local var_13_0 = var_0_28(arg_13_0)

	return type(var_13_0) == "table" and var_0_21(var_13_0, arg_13_1)
end

local function var_0_32(arg_14_0)
	local var_14_0 = {}

	for iter_14_0 in pairs(arg_14_0 or {}) do
		if type(iter_14_0) == "string" and iter_14_0 ~= "" then
			table.insert(var_14_0, iter_14_0)
		end
	end

	table.sort(var_14_0, function(arg_15_0, arg_15_1)
		local var_15_0 = arg_15_0:lower()
		local var_15_1 = arg_15_1:lower()

		if var_15_0 == var_15_1 then
			return arg_15_0 < arg_15_1
		end

		return var_15_0 < var_15_1
	end)

	return var_14_0
end

local function var_0_33(arg_16_0, arg_16_1)
	arg_16_0 = type(arg_16_0) == "table" and arg_16_0 or {}

	local var_16_0 = {
		version = var_0_8,
		language = var_0_22(arg_16_0.language),
		profiles = {}
	}

	if type(arg_16_0.profiles) == "table" then
		for unusedValue, profile in ipairs(var_0_32(arg_16_0.profiles)) do
			if type(arg_16_0.profiles[profile]) == "table" then
				var_16_0.profiles[profile] = var_0_20(arg_16_0.profiles[profile])
			end
		end
	end

	if arg_16_1 ~= false and next(var_16_0.profiles) == nil then
		var_16_0.profiles[var_0_9] = {}
	end

	return var_16_0
end

local function var_0_34(arg_17_0)
	if type(arg_17_0.profiles[var_0_9]) == "table" then
		return var_0_9
	end

	return var_0_32(arg_17_0.profiles)[1] or var_0_9
end

local function var_0_35(arg_18_0)
	arg_18_0 = type(arg_18_0) == "table" and arg_18_0 or {}

	local var_18_0 = var_0_33({
		language = arg_18_0.language,
		profiles = arg_18_0.profiles
	}, false)

	if type(var_18_0.profiles[var_0_9]) ~= "table" then
		var_18_0.profiles[var_0_9] = type(arg_18_0.current) == "table" and var_0_20(arg_18_0.current) or {}
	end

	return var_0_33(var_18_0)
end

local function var_0_36(arg_19_0, arg_19_1)
	arg_19_0 = type(arg_19_0) == "table" and arg_19_0 or {}
	arg_19_1 = var_0_33(arg_19_1)

	local var_19_0 = type(arg_19_0.activeProfile) == "string" and arg_19_0.activeProfile or var_0_9

	if not (type(arg_19_1.profiles[var_19_0]) == "table") then
		var_19_0 = var_0_34(arg_19_1)
	end

	return {
		version = var_0_8,
		activeProfile = var_19_0,
		autoSaveEnabled = arg_19_0.autoSaveEnabled ~= false,
		language = var_0_22(arg_19_0.language or arg_19_1.language)
	}
end

local function var_0_37(arg_20_0, arg_20_1)
	if not g_resources.fileExists(arg_20_0) or g_resources.fileExists(arg_20_1) then
		return true
	end

	local var_20_0, var_20_1 = pcall(g_resources.readFileContents, arg_20_0)

	if not var_20_0 or type(var_20_1) ~= "string" then
		var_0_19("warning", "Could not read " .. arg_20_0 .. " for backup.")

		return false
	end

	local var_20_2, var_20_3 = pcall(g_resources.writeFileContents, arg_20_1, var_20_1)

	if not var_20_2 or var_20_3 == false then
		var_0_19("warning", "Could not create backup " .. arg_20_1 .. ".")

		return false
	end

	return true
end

local function var_0_38(arg_21_0, arg_21_1, arg_21_2)
	if not var_0_24() then
		return false
	end

	arg_21_0 = var_0_33(arg_21_0)

	if not arg_21_2 then
		local var_21_0, unusedValue, var_21_2 = var_0_28(var_0_2)

		arg_21_2 = var_21_0 and var_21_2 or nil
	end

	if arg_21_2 and not var_0_15 then
		var_0_15 = true

		local var_21_3, var_21_4 = pcall(g_resources.writeFileContents, var_0_3, arg_21_2)

		if not var_21_3 or var_21_4 == false then
			var_0_19("warning", "Could not update the shared Helper profile backup this session.")
		end
	end

	if not var_0_30(var_0_2, arg_21_0) then
		return false
	end

	if arg_21_1 and not var_0_31(var_0_2, arg_21_0) then
		var_0_19("error", "Global Helper profile library failed post-write validation.")

		return false
	end

	var_0_14 = var_0_20(arg_21_0)

	return true
end

local function var_0_39()
	local var_22_0, var_22_1, var_22_2 = var_0_28(var_0_2)

	if var_22_0 then
		return var_0_33(var_22_0), nil, var_22_2
	end

	local var_22_3, unusedValue, var_22_5 = var_0_28(var_0_3)

	if var_22_3 then
		var_0_19("warning", "Using the Helper profile library backup because the main file is unavailable.")

		return var_0_33(var_22_3), "backup", var_22_5
	end

	return nil, var_22_1
end

local function var_0_40(arg_23_0, arg_23_1, arg_23_2)
	arg_23_0 = var_0_33(arg_23_0)
	arg_23_1 = var_0_33(arg_23_1)
	arg_23_2 = var_0_33(arg_23_2)

	if arg_23_1.language ~= arg_23_0.language then
		arg_23_2.language = arg_23_1.language
	end

	for key, profile in pairs(arg_23_1.profiles) do
		local var_23_0 = arg_23_0.profiles[key]

		if type(var_23_0) ~= "table" or not var_0_21(profile, var_23_0) then
			arg_23_2.profiles[key] = var_0_20(profile)
		end
	end

	for iter_23_2 in pairs(arg_23_0.profiles) do
		if arg_23_1.profiles[iter_23_2] == nil then
			arg_23_2.profiles[iter_23_2] = nil
		end
	end

	return var_0_33(arg_23_2)
end

local function var_0_41(arg_24_0, arg_24_1, arg_24_2)
	if not var_0_27(arg_24_0) then
		return false
	end

	return var_0_30(var_0_26(arg_24_0), var_0_36(arg_24_1, arg_24_2))
end

local function var_0_42(arg_25_0)
	return var_0_30(var_0_5, {
		version = var_0_8,
		completedAt = os.time(),
		source = arg_25_0
	})
end

local function var_0_43()
	if not var_0_37(var_0_2, var_0_4) then
		return false
	end

	local var_26_0, var_26_1 = var_0_28(var_0_6)
	local var_26_2 = "clean"
	local var_26_3 = var_0_33({})

	if var_26_0 then
		var_26_3 = var_0_35(var_26_0)
		var_26_2 = "legacy-global"
	elseif var_26_1 and var_26_1 ~= "missing" then
		var_26_2 = "clean-invalid-legacy"

		var_0_19("warning", "The old global Helper settings are invalid; starting with a clean Default profile.")
	end

	if not var_0_38(var_26_3, true) then
		return false
	end

	if not var_0_42(var_26_2) then
		return false
	end

	var_0_19("info", "Shared Helper profiles initialized without scanning characterdata.")

	return true
end

function HelperProfileStorage.initialize(arg_27_0)
	if arg_27_0 then
		var_0_11 = arg_27_0
	end

	if var_0_12 and var_0_14 then
		return true
	end

	if var_0_13 then
		return false
	end

	var_0_13 = true

	if not var_0_24() then
		return false
	end

	if not g_resources.fileExists(var_0_5) and not var_0_43() then
		return false
	end

	local var_27_0, var_27_1 = var_0_39()

	if not var_27_0 then
		var_0_19("warning", "The shared Helper profile library is unavailable; rebuilding it without character data.")

		if not var_0_43() then
			return false
		end

		var_27_0, var_27_1 = var_0_39()
	end

	if not var_27_0 then
		return false
	end

	if var_27_1 == "backup" and not var_0_38(var_27_0, true) then
		return false
	end

	var_0_14 = var_27_0
	var_0_12 = true

	return true
end

function HelperProfileStorage.activateCharacter(textValue, arg_28_1)
	textValue = tostring(textValue or "")

	if textValue == "" or textValue == "0" then
		return false
	end

	if not HelperProfileStorage.initialize(var_0_11) then
		return false
	end

	local var_28_0 = var_0_39()

	if var_28_0 then
		var_0_14 = var_28_0
	end

	var_0_16 = textValue
	var_0_17 = tostring(arg_28_1 or "")

	local var_28_1 = var_0_26(textValue)
	local var_28_2 = var_0_28(var_28_1)

	if var_28_2 then
		var_0_18 = var_0_36(var_28_2, var_0_14)

		if not var_0_21(var_28_2, var_0_18) and not var_0_41(textValue, var_0_18, var_0_14) then
			var_0_16 = nil
			var_0_17 = nil
			var_0_18 = nil

			return false
		end

		return true
	end

	var_0_18 = var_0_36({}, var_0_14)

	if not var_0_41(textValue, var_0_18, var_0_14) then
		var_0_16 = nil
		var_0_17 = nil
		var_0_18 = nil

		return false
	end

	return true
end

function HelperProfileStorage.clearActiveCharacter()
	var_0_16 = nil
	var_0_17 = nil
	var_0_18 = nil
end

function HelperProfileStorage.refreshLibrary()
	if not HelperProfileStorage.initialize(var_0_11) then
		return false
	end

	local var_30_0 = var_0_39()

	if not var_30_0 then
		return false
	end

	var_0_14 = var_30_0

	if var_0_18 then
		local var_30_1 = var_0_36(var_0_18, var_0_14)

		if not var_0_21(var_30_1, var_0_18) and var_0_16 and not var_0_41(var_0_16, var_30_1, var_0_14) then
			return false
		end

		var_0_18 = var_30_1
	end

	return true
end

function HelperProfileStorage.readDocument()
	if not HelperProfileStorage.initialize(var_0_11) then
		return {
			autoSaveEnabled = true,
			language = "en",
			version = var_0_8,
			profiles = {
				[var_0_9] = {}
			},
			activeProfile = var_0_9,
			current = {}
		}
	end

	local var_31_0 = var_0_18 or var_0_36({}, var_0_14)

	return {
		version = var_0_8,
		language = var_31_0.language,
		profiles = var_0_20(var_0_14.profiles),
		activeProfile = var_31_0.activeProfile,
		current = var_0_20(var_0_14.profiles[var_31_0.activeProfile] or {}),
		autoSaveEnabled = var_31_0.autoSaveEnabled
	}
end

function HelperProfileStorage.writeDocument(arg_32_0)
	if not HelperProfileStorage.initialize(var_0_11) then
		return false
	end

	arg_32_0 = type(arg_32_0) == "table" and arg_32_0 or {}

	local var_32_0 = var_0_33({
		version = var_0_8,
		language = var_0_16 and var_0_14.language or arg_32_0.language or var_0_14.language,
		profiles = type(arg_32_0.profiles) == "table" and arg_32_0.profiles or var_0_14.profiles
	})

	if not var_0_21(var_32_0, var_0_14) then
		local var_32_1, unusedValue, var_32_3 = var_0_39()

		var_32_1 = var_32_1 or var_0_14

		local var_32_4 = var_0_40(var_0_14, var_32_0, var_32_1)

		if not var_0_38(var_32_4, false, var_32_3) then
			return false
		end
	end

	if not var_0_16 then
		return true
	end

	local var_32_5 = var_0_36({
		activeProfile = arg_32_0.activeProfile,
		autoSaveEnabled = arg_32_0.autoSaveEnabled,
		language = arg_32_0.language
	}, var_0_14)

	if var_0_18 and var_0_21(var_32_5, var_0_18) then
		return true
	end

	if not var_0_41(var_0_16, var_32_5, var_0_14) then
		return false
	end

	var_0_18 = var_32_5

	return true
end

function HelperProfileStorage.getActiveCharacterId()
	return var_0_16
end

function HelperProfileStorage.getActiveCharacterName()
	return var_0_17
end

function HelperProfileStorage.getActiveStatePath()
	return var_0_16 and var_0_26(var_0_16) or nil
end

function HelperProfileStorage.getPaths()
	return {
		profiles = var_0_2,
		backup = var_0_3,
		preV4Backup = var_0_4,
		marker = var_0_5
	}
end
