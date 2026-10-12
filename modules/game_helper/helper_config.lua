HelperConfigTab = HelperConfigTab or {}
HelperConfigTab.DEFAULT_PROFILE_NAME = "Default"

local ctx
local selectedProfileName
local currentLanguage = "en"
local suppressLanguageChange = false
local suppressQuickProfileChange = false
local profileInputBox
local QUICK_PROFILE_MAX_VISIBLE_ROWS = 7
local CONFIG_TEXT = {
	en = {
		deleteConfirm = "Delete shared profile \"%s\" for every character?",
		load = "Load",
		deletePreset = "Delete Preset",
		rename = "Rename",
		newPreset = "New Preset",
		new = "New",
		preset = "Preset:",
		generalSettings = "General Settings",
		prioritizeHotkeys = "Prioritize Hotkeys",
		autoSwitchHotkeyPreset = "Auto-Switch Hotkey Preset",
		renameFailed = "Failed to rename profile.",
		autoSave = "Auto Save",
		renamed = "Profile \"%s\" renamed to \"%s\".",
		language = "Language:",
		lastProfile = "This is the only profile, so it cannot be deleted. Create another one first.",
		profileName = "Profile name:",
		nameTaken = "A profile named \"%s\" already exists.",
		delete = "Delete",
		newProfileName = "New name:",
		save = "Save",
		renamePreset = "Rename Profile",
		savedProfiles = "Shared Profiles",
		no = "No",
		yes = "Yes"
	},
	pt = {
		deleteConfirm = "Excluir o perfil compartilhado \"%s\" para todos os personagens?",
		load = "Carregar",
		deletePreset = "Excluir Perfil",
		rename = "Renomear",
		newPreset = "Novo Perfil",
		new = "Novo",
		preset = "Perfil:",
		generalSettings = "Configuracoes Gerais",
		prioritizeHotkeys = "Priorizar Hotkeys",
		autoSwitchHotkeyPreset = "Troca Automatica de Preset de Hotkeys",
		renameFailed = "Falha ao renomear o perfil.",
		autoSave = "Salvar Auto",
		renamed = "Perfil \"%s\" renomeado para \"%s\".",
		language = "Idioma:",
		lastProfile = "Este e o unico perfil, entao nao pode ser excluido. Crie outro antes.",
		profileName = "Nome do perfil:",
		nameTaken = "Ja existe um perfil chamado \"%s\".",
		delete = "Excluir",
		newProfileName = "Novo nome:",
		save = "Salvar",
		renamePreset = "Renomear Perfil",
		savedProfiles = "Perfis Compartilhados",
		no = "Nao",
		yes = "Sim"
	}
}

local function normalizeLanguage(language)
	return language == "pt" and "pt" or "en"
end

local function configText(key)
	return (CONFIG_TEXT[currentLanguage] or CONFIG_TEXT.en)[key] or CONFIG_TEXT.en[key] or key
end

local function setWidgetText(id, text)
	if not ctx or not ctx.getWidget then
		return
	end

	local target = ctx.getWidget(id)

	if target and target.setText then
		target:setText(text)
	end
end

local function trimProfileName(name)
	if not name then
		return ""
	end

	return tostring(name):match("^%s*(.-)%s*$") or ""
end

local function profileTr(text, name)
	return tr(text, tostring(name or ""))
end

local function getProfileNameFromItem(item)
	if not item then
		return ""
	end

	if item.profileName and item.profileName ~= "" then
		return item.profileName
	end

	local lbl = item:recursiveGetChildById("itemLabel")

	return lbl and lbl:getText() or ""
end

function HelperConfigTab.getSelectedProfileName()
	return selectedProfileName
end

function HelperConfigTab.setSelectedProfileName(name)
	selectedProfileName = trimProfileName(name)

	if selectedProfileName == "" then
		selectedProfileName = nil
	end
end

function HelperConfigTab.syncProfileNameEdit(name)
	if not ctx or not ctx.getWidget then
		return
	end

	local edit = ctx.getWidget("configsNameEdit")

	if edit then
		edit:setText(name or "")
	end
end

local function getProfileList()
	return ctx and ctx.getWidget("configsProfileList")
end

local function getQuickProfileCombo()
	return ctx and ctx.getWidget("quickProfileCombo")
end

local function getSortedProfileNames(data)
	local names = {}

	for name in pairs(data and data.profiles or {}) do
		if type(name) == "string" and name ~= "" then
			table.insert(names, name)
		end
	end

	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)

	return names
end

local function profileExists(names, wanted)
	for _, name in ipairs(names or {}) do
		if name == wanted then
			return true
		end
	end

	return false
end

function HelperConfigTab.getFallbackProfileName(profiles, excludedProfileName)
	profiles = type(profiles) == "table" and profiles or {}

	local DEFAULT_PROFILE_NAME = HelperConfigTab.DEFAULT_PROFILE_NAME

	if DEFAULT_PROFILE_NAME ~= excludedProfileName and type(profiles[DEFAULT_PROFILE_NAME]) == "table" then
		return DEFAULT_PROFILE_NAME
	end

	for unusedValue, profileName in ipairs(getSortedProfileNames({
		profiles = profiles
	})) do
		if profileName ~= excludedProfileName and type(profiles[profileName]) == "table" then
			return profileName
		end
	end

	return DEFAULT_PROFILE_NAME
end

function HelperConfigTab.getQuickProfileName()
	local combo = getQuickProfileCombo()
	local option = combo and combo.getCurrentOption and combo:getCurrentOption() or nil

	return trimProfileName(option and (option.data or option.text) or "")
end

function HelperConfigTab.refreshQuickProfileCombo(preferredName)
	local quickProfileCombo = getQuickProfileCombo()

	if not quickProfileCombo or not ctx or not ctx.readHelperJSON then
		return
	end

	local helperConfig = ctx.readHelperJSON()
	local profileNames = getSortedProfileNames(helperConfig)

	quickProfileCombo.menuScroll = #profileNames > QUICK_PROFILE_MAX_VISIBLE_ROWS

	local fallbackProfileName = trimProfileName(preferredName or helperConfig.activeProfile or "")

	if not profileExists(profileNames, fallbackProfileName) then
		fallbackProfileName = #profileNames > 0 and HelperConfigTab.getFallbackProfileName(helperConfig.profiles) or ""
	end

	suppressQuickProfileChange = true

	quickProfileCombo:clearOptions()

	for unusedValue, entry in ipairs(profileNames) do
		quickProfileCombo:addOption(entry, entry)
	end

	if fallbackProfileName ~= "" then
		if quickProfileCombo.setCurrentOptionByData then
			quickProfileCombo:setCurrentOptionByData(fallbackProfileName, true)
		else
			quickProfileCombo:setCurrentOption(fallbackProfileName, true)
		end
	end

	suppressQuickProfileChange = false

	local widget = ctx.getWidget("quickProfileSaveButton")

	if widget then
		widget:setEnabled(fallbackProfileName ~= "")
	end

	local widget = ctx.getWidget("quickProfileRenameButton")

	if widget then
		widget:setEnabled(fallbackProfileName ~= "")
	end

	local widget = ctx.getWidget("quickProfileDeleteButton")

	if widget then
		widget:setEnabled(fallbackProfileName ~= "" and #profileNames > 1)
	end
end

local function selectProfileListItem(name)
	if not ctx or not ctx.getWidget then
		return
	end

	local list = getProfileList()

	if not list then
		return
	end

	for _, child in ipairs(list:getChildren()) do
		if getProfileNameFromItem(child) == name then
			list:focusChild(child, KeyboardFocusReason)
			HelperConfigTab.setSelectedProfileName(name)
			HelperConfigTab.syncProfileNameEdit(name)

			return
		end
	end
end

local function onProfileItemSelected(item)
	if not item then
		return
	end

	local name = getProfileNameFromItem(item)

	if name == "" then
		return
	end

	HelperConfigTab.setSelectedProfileName(name)
	HelperConfigTab.syncProfileNameEdit(name)
end

function HelperConfigTab.refreshProfileList()
	if not ctx or not ctx.getWidget then
		return
	end

	local data = ctx.readHelperJSON()

	HelperConfigTab.refreshQuickProfileCombo(data.activeProfile)

	local list = getProfileList()

	if not list then
		return
	end

	list:destroyChildren()

	local names = getSortedProfileNames(data)

	for idx, name in ipairs(names) do
		local widgetType = idx % 2 == 1 and "ProfileListItemOdd" or "ProfileListItemEven"
		local item = g_ui.createWidget(widgetType, list)

		item.profileName = name

		item:setId("profileItem_" .. name:gsub("[^%w]", "_"))

		local lbl = item:recursiveGetChildById("itemLabel")

		if lbl then
			lbl:setText(name)
		end

		connect(item, {
			onFocusChange = function(self, focused)
				if focused then
					onProfileItemSelected(self)
				end
			end
		})
	end

	if selectedProfileName then
		selectProfileListItem(selectedProfileName)
	end
end

local function resolveProfileName(preferEdit)
	if not ctx or not ctx.getWidget then
		return selectedProfileName
	end

	if not preferEdit then
		local list = getProfileList()

		if list then
			local focused = list:getFocusedChild()

			if focused then
				local name = getProfileNameFromItem(focused)

				if name ~= "" then
					HelperConfigTab.setSelectedProfileName(name)

					return name
				end
			end
		end

		if selectedProfileName and selectedProfileName ~= "" then
			return selectedProfileName
		end
	end

	local edit = ctx.getWidget("configsNameEdit")
	local name = trimProfileName(edit and edit:getText() or "")

	if name ~= "" then
		HelperConfigTab.setSelectedProfileName(name)

		return name
	end

	return nil
end

function HelperConfigTab.isOtherProfileSelected()
	return selectedProfileName and selectedProfileName ~= "" and selectedProfileName ~= HelperConfigTab.DEFAULT_PROFILE_NAME
end

function HelperConfigTab.getProfileNameForAutoSave()
	if not ctx or not ctx.isAutoSaveEnabled or not ctx.isAutoSaveEnabled() then
		return nil
	end

	if not ctx.readHelperJSON then
		return nil
	end

	local data = ctx.readHelperJSON()
	local activeName = trimProfileName(data.activeProfile)

	if activeName ~= "" and type(data.profiles) == "table" and type(data.profiles[activeName]) == "table" then
		return activeName
	end

	return HelperConfigTab.DEFAULT_PROFILE_NAME
end

function HelperConfigTab.selectProfileInList(name)
	if not name or name == "" then
		return
	end

	selectProfileListItem(name)
end

function HelperConfigTab.initProfilesPanel()
	local list = getProfileList()

	if list then
		connect(list, {
			onChildFocusChange = function(_, focusedChild)
				onProfileItemSelected(focusedChild)
			end
		})
	end

	local data = ctx.readHelperJSON()

	HelperConfigTab.setLanguage(data.language, false)
	HelperConfigTab.setSelectedProfileName(data.activeProfile)
	HelperConfigTab.syncProfileNameEdit(selectedProfileName or "")

	if ctx.applyAutoSavePreferenceToCheckbox then
		ctx.applyAutoSavePreferenceToCheckbox(data.autoSaveEnabled ~= false)
	end

	HelperConfigTab.refreshAutoSwitchHotkeyPreset()
	HelperConfigTab.refreshProfileList()
end

function HelperConfigTab.initQuickProfileBar()
	local combo = getQuickProfileCombo()

	if not combo then
		return
	end

	function combo.onOptionChange(_, text, data)
		if suppressQuickProfileChange then
			return
		end

		local name = trimProfileName(data or text)

		if name == "" then
			return
		end

		HelperConfigTab.loadProfile(name)
	end
end

function HelperConfigTab.getLanguage()
	return currentLanguage
end

function HelperConfigTab.toggleLanguage()
	HelperConfigTab.setLanguage(currentLanguage == "pt" and "en" or "pt", true)
end

function HelperConfigTab.refreshLanguage(language)
	currentLanguage = normalizeLanguage(language or currentLanguage)

	setWidgetText("configsProfilesTitle", configText("savedProfiles"))
	setWidgetText("configsLoadBtn", configText("load"))
	setWidgetText("configsSaveBtn", configText("save"))
	setWidgetText("configsDeleteBtn", configText("delete"))
	setWidgetText("configsNameLabel", configText("profileName"))
	setWidgetText("configsLanguageLabel", configText("language"))
	setWidgetText("configsAutoSaveLabel", configText("autoSave"))
	setWidgetText("configsAutoSwitchHotkeyPresetLabel", configText("autoSwitchHotkeyPreset"))
	setWidgetText("configsPrioritizeHotkeysLabel", configText("prioritizeHotkeys"))
	setWidgetText("configsGeneralSection", configText("generalSettings"))
	setWidgetText("quickProfileLabel", configText("preset"))
	setWidgetText("quickProfileNewButton", configText("new"))
	setWidgetText("quickProfileSaveButton", configText("save"))
	setWidgetText("quickProfileRenameButton", configText("rename"))
	setWidgetText("quickProfileDeleteButton", configText("delete"))

	local widget = ctx and ctx.getWidget and ctx.getWidget("configsLanguageCombo") or nil

	if widget and widget.clearOptions and widget.addOption then
		suppressLanguageChange = true

		widget:clearOptions()
		widget:addOption("English", "en")
		widget:addOption("Portugues", "pt")

		if widget.setCurrentOptionByData then
			widget:setCurrentOptionByData(currentLanguage, true)
		else
			widget:setCurrentOption(currentLanguage == "pt" and "Portugues" or "English", true)
		end

		suppressLanguageChange = false
	end
end

function HelperConfigTab.setLanguage(language, persist)
	currentLanguage = normalizeLanguage(language)

	if ctx and ctx.applyLanguage then
		ctx.applyLanguage(currentLanguage)
	else
		HelperConfigTab.refreshLanguage(currentLanguage)
	end

	if persist == false or not ctx or not ctx.readHelperJSON or not ctx.writeHelperJSON then
		return
	end

	if ctx.isLoadingConfig and ctx.isLoadingConfig() then
		return
	end

	local data = ctx.readHelperJSON()

	if data.language ~= currentLanguage then
		data.language = currentLanguage

		ctx.writeHelperJSON(data)
	end
end

function HelperConfigTab.initLanguageSelector()
	local combo = ctx and ctx.getWidget and ctx.getWidget("configsLanguageCombo") or nil

	if not combo then
		return
	end

	function combo.onOptionChange(_, _, data)
		if suppressLanguageChange or not data then
			return
		end

		HelperConfigTab.setLanguage(data, true)
	end

	HelperConfigTab.refreshLanguage(currentLanguage)
end

function HelperConfigTab.openProfileWindow()
	if ctx.openHelperWindow then
		ctx.openHelperWindow()
	end

	HelperConfigTab.refreshProfileList()
end

function HelperConfigTab.saveProfile(explicitName)
	if not ctx or not ctx.getWidget then
		return false
	end

	local activeProfile = explicitName ~= nil and trimProfileName(explicitName) or resolveProfileName(true)

	if not activeProfile or activeProfile == "" then
		if ctx.log then
			ctx.log("info", "[PROFILE] Save aborted (empty name): " .. tostring(activeProfile))
		end

		if ctx.showMessage then
			ctx.showMessage(true, tr("Profile name cannot be empty."))
		end

		return false
	end

	if ctx.log then
		ctx.log("info", "[PROFILE] Saving: " .. tostring(activeProfile))
	end

	if ctx.cancelAutoSave then
		ctx.cancelAutoSave()
	end

	local config = ctx.readHelperJSON()

	config.profiles = config.profiles or {}

	local profileAlreadyExists = config.profiles[activeProfile] ~= nil
	local configSnapshot = ctx.collectConfig()

	config.profiles[activeProfile] = ctx.copyConfig(configSnapshot)
	config.current = ctx.copyConfig(configSnapshot)
	config.activeProfile = activeProfile

	if ctx.isAutoSaveEnabled then
		config.autoSaveEnabled = ctx.isAutoSaveEnabled()
	end

	if not ctx.writeHelperJSON(config) then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Failed to save profile."))
		end

		if ctx.log then
			ctx.log("error", "Save profile failed for \"" .. tostring(activeProfile) .. "\".")
		end

		return false
	end

	if ctx.applyConfigSnapshot then
		ctx.applyConfigSnapshot(configSnapshot)
	end

	HelperConfigTab.setSelectedProfileName(activeProfile)
	HelperConfigTab.refreshProfileList()
	HelperConfigTab.syncProfileNameEdit(activeProfile)

	if ctx.log then
		ctx.log("info", "Profile saved: \"" .. tostring(activeProfile) .. "\".")
	end

	if ctx.showMessage then
		if profileAlreadyExists then
			ctx.showMessage(false, profileTr("Profile \"%s\" updated.", activeProfile))
		else
			ctx.showMessage(false, profileTr("Profile \"%s\" created.", activeProfile))
		end
	end

	return true
end

function HelperConfigTab.loadProfile(explicitName)
	if not ctx or not ctx.getWidget then
		return
	end

	local name = explicitName ~= nil and trimProfileName(explicitName) or resolveProfileName(false)

	if not name or name == "" then
		if ctx.log then
			ctx.log("info", "[PROFILE] Load aborted (none selected): " .. tostring(name))
		end

		if ctx.showMessage then
			ctx.showMessage(true, tr("Select a profile to load."))
		end

		return
	end

	if ctx.log then
		ctx.log("info", "[PROFILE] Loading: " .. tostring(name))
	end

	if ctx.flushAutoSave then
		ctx.flushAutoSave()
	elseif ctx.cancelAutoSave then
		ctx.cancelAutoSave()
	end

	local data = ctx.readHelperJSON()
	local config = data.profiles and data.profiles[name]

	if type(config) ~= "table" then
		if ctx.showMessage then
			ctx.showMessage(true, profileTr("Profile \"%s\" not found.", name))
		end

		if ctx.log then
			ctx.log("error", "Load profile failed, not found: \"" .. tostring(name) .. "\".")
		end

		HelperConfigTab.refreshProfileList()

		return
	end

	local snapshot = ctx.copyConfig(config)

	data.current = ctx.copyConfig(snapshot)
	data.activeProfile = name

	if not ctx.writeHelperJSON(data) then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Failed to load profile."))
		end

		if ctx.log then
			ctx.log("error", "Load profile failed to write JSON: \"" .. tostring(name) .. "\".")
		end

		HelperConfigTab.refreshQuickProfileCombo(data.activeProfile)

		return
	end

	if ctx.applyConfig then
		ctx.applyConfig(snapshot)
	end

	HelperConfigTab.setSelectedProfileName(name)
	HelperConfigTab.syncProfileNameEdit(name)

	if ctx.applyAutoSavePreferenceToCheckbox then
		ctx.applyAutoSavePreferenceToCheckbox(data.autoSaveEnabled ~= false)
	end

	HelperConfigTab.refreshProfileList()

	if ctx.log then
		ctx.log("info", "Profile loaded: \"" .. tostring(name) .. "\".")
	end

	if ctx.showMessage then
		ctx.showMessage(false, profileTr("Profile \"%s\" loaded.", name))
	end
end

function HelperConfigTab.deleteProfile(explicitName)
	if not ctx or not ctx.getWidget then
		return
	end

	local profileName = explicitName ~= nil and trimProfileName(explicitName) or resolveProfileName(false)

	if not profileName or profileName == "" then
		if ctx.log then
			ctx.log("info", "[PROFILE] Delete aborted (none selected): " .. tostring(profileName))
		end

		if ctx.showMessage then
			ctx.showMessage(true, tr("Select a profile to delete."))
		end

		return
	end

	if ctx.log then
		ctx.log("info", "[PROFILE] Deleting: " .. tostring(profileName))
	end

	if ctx.flushAutoSave then
		ctx.flushAutoSave()
	elseif ctx.cancelAutoSave then
		ctx.cancelAutoSave()
	end

	local helperConfig = ctx.readHelperJSON()

	if type(helperConfig.profiles) ~= "table" or helperConfig.profiles[profileName] == nil then
		if ctx.showMessage then
			ctx.showMessage(true, profileTr("Profile \"%s\" not found.", profileName))
		end

		if ctx.log then
			ctx.log("error", "Delete profile failed, not found: \"" .. tostring(profileName) .. "\".")
		end

		HelperConfigTab.refreshProfileList()

		return
	end

	local hasAnotherProfile = false

	for key, profile in pairs(helperConfig.profiles) do
		if key ~= profileName and type(profile) == "table" then
			hasAnotherProfile = true

			break
		end
	end

	if not hasAnotherProfile then
		if ctx.showMessage then
			ctx.showMessage(true, configText("lastProfile"))
		end

		HelperConfigTab.refreshProfileList()

		return
	end

	local wasActive = helperConfig.activeProfile == profileName

	helperConfig.profiles[profileName] = nil

	local activeProfile = helperConfig.activeProfile

	if wasActive or type(helperConfig.profiles[activeProfile]) ~= "table" then
		activeProfile = HelperConfigTab.getFallbackProfileName(helperConfig.profiles)
	end

	local fallbackConfig = type(helperConfig.profiles[activeProfile]) == "table" and ctx.copyConfig(helperConfig.profiles[activeProfile]) or {}

	if wasActive then
		helperConfig.activeProfile = activeProfile
		helperConfig.current = ctx.copyConfig(fallbackConfig)
	end

	if not ctx.writeHelperJSON(helperConfig) then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Failed to delete profile."))
		end

		if ctx.log then
			ctx.log("error", "Delete profile failed to write JSON: \"" .. tostring(profileName) .. "\".")
		end

		return
	end

	if ctx.log then
		ctx.log("info", "Profile deleted: \"" .. tostring(profileName) .. "\".")
	end

	if ctx.showMessage then
		ctx.showMessage(false, profileTr("Profile \"%s\" deleted.", profileName))
	end

	if wasActive and ctx.applyConfig then
		ctx.applyConfig(fallbackConfig)
	end

	HelperConfigTab.setSelectedProfileName(activeProfile)
	HelperConfigTab.syncProfileNameEdit(activeProfile or "")
	HelperConfigTab.refreshProfileList()
end

function HelperConfigTab.createBlankProfile(profileName)
	if not ctx or not ctx.getWidget then
		return
	end

	profileName = trimProfileName(profileName)

	if profileName == "" then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Profile name cannot be empty."))
		end

		return
	end

	local helperConfig = ctx.readHelperJSON()

	if type(helperConfig.profiles) == "table" and helperConfig.profiles[profileName] ~= nil then
		if ctx.showMessage then
			ctx.showMessage(true, string.format(configText("nameTaken"), profileName))
		end

		return
	end

	if ctx.flushAutoSave then
		ctx.flushAutoSave()
	elseif ctx.cancelAutoSave then
		ctx.cancelAutoSave()
	end

	local previousConfigSnapshot = ctx.collectConfig()

	ctx.applyConfig({})

	if not HelperConfigTab.saveProfile(profileName) then
		ctx.applyConfig(previousConfigSnapshot)
	end
end

function HelperConfigTab.renameProfile(oldProfileName, newProfileName)
	if not ctx or not ctx.getWidget then
		return
	end

	oldProfileName = trimProfileName(oldProfileName)
	newProfileName = trimProfileName(newProfileName)

	if oldProfileName == "" then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Select a profile to rename."))
		end

		return
	end

	if newProfileName == "" then
		if ctx.showMessage then
			ctx.showMessage(true, tr("Profile name cannot be empty."))
		end

		return
	end

	if newProfileName == oldProfileName then
		return
	end

	if ctx.flushAutoSave then
		ctx.flushAutoSave()
	elseif ctx.cancelAutoSave then
		ctx.cancelAutoSave()
	end

	local helperConfig = ctx.readHelperJSON()

	helperConfig.profiles = helperConfig.profiles or {}

	if type(helperConfig.profiles[oldProfileName]) ~= "table" then
		if ctx.showMessage then
			ctx.showMessage(true, profileTr("Profile \"%s\" not found.", oldProfileName))
		end

		HelperConfigTab.refreshProfileList()

		return
	end

	if helperConfig.profiles[newProfileName] ~= nil then
		if ctx.showMessage then
			ctx.showMessage(true, string.format(configText("nameTaken"), newProfileName))
		end

		return
	end

	helperConfig.profiles[newProfileName] = helperConfig.profiles[oldProfileName]
	helperConfig.profiles[oldProfileName] = nil

	local wasActiveProfile = helperConfig.activeProfile == oldProfileName

	if wasActiveProfile then
		helperConfig.activeProfile = newProfileName
	end

	if not ctx.writeHelperJSON(helperConfig) then
		if ctx.showMessage then
			ctx.showMessage(true, configText("renameFailed"))
		end

		if ctx.log then
			ctx.log("error", "Rename profile failed for \"" .. tostring(oldProfileName) .. "\".")
		end

		HelperConfigTab.refreshProfileList()

		return
	end

	if wasActiveProfile or selectedProfileName == oldProfileName then
		HelperConfigTab.setSelectedProfileName(newProfileName)
		HelperConfigTab.syncProfileNameEdit(newProfileName)
	end

	HelperConfigTab.refreshProfileList()

	if ctx.log then
		ctx.log("info", "Profile renamed: \"" .. oldProfileName .. "\" -> \"" .. newProfileName .. "\".")
	end

	if ctx.showMessage then
		ctx.showMessage(false, string.format(configText("renamed"), oldProfileName, newProfileName))
	end
end

local function showProfileNameInput(title, labelText, initialName, onAccept)
	if not UIInputBox or not UIInputBox.create then
		if ctx and ctx.showMessage then
			ctx.showMessage(true, tr("Profile name input is unavailable."))
		end

		return
	end

	if profileInputBox and not profileInputBox:isDestroyed() then
		profileInputBox:destroy()
	end

	local unusedValue
	local inputBox = UIInputBox.create(title, onAccept, function()
		profileInputBox = nil
	end)

	profileInputBox = inputBox

	local labelWidget = inputBox:addLabel(labelText)
	local nameEdit = inputBox:addLineEdit(nil, initialName, 48)

	if labelWidget then
		labelWidget:setStyle("HelperProfileInputLabel")
		labelWidget:resizeToText()
	end

	if nameEdit then
		nameEdit:setStyle("HelperProfileInputLineEdit")
	end

	inputBox:display()
	inputBox:setStyle("HelperProfileInputBox")

	function inputBox.onDestroy()
		if profileInputBox == inputBox then
			profileInputBox = nil
		end
	end

	if nameEdit then
		nameEdit:focus()

		if initialName and nameEdit.selectAll then
			nameEdit:selectAll()
		end
	end
end

function HelperConfigTab.newQuickProfile()
	showProfileNameInput(configText("newPreset"), configText("profileName"), nil, HelperConfigTab.createBlankProfile)
end

function HelperConfigTab.renameQuickProfile()
	local quickProfileName = HelperConfigTab.getQuickProfileName()

	if quickProfileName == "" then
		HelperConfigTab.renameProfile(quickProfileName, quickProfileName)

		return
	end

	showProfileNameInput(configText("renamePreset"), configText("newProfileName"), quickProfileName, function(newProfileName)
		HelperConfigTab.renameProfile(quickProfileName, newProfileName)
	end)
end

function HelperConfigTab.saveQuickProfile()
	local quickProfileName = HelperConfigTab.getQuickProfileName()

	if quickProfileName == "" then
		showProfileNameInput(configText("newPreset"), configText("profileName"), nil, HelperConfigTab.saveProfile)

		return
	end

	HelperConfigTab.saveProfile(quickProfileName)
end

function HelperConfigTab.deleteQuickProfile()
	local name = HelperConfigTab.getQuickProfileName()

	if name == "" or not displayGeneralBox then
		HelperConfigTab.deleteProfile(name)

		return
	end

	local confirmBox

	local function closeConfirm()
		if confirmBox and not confirmBox:isDestroyed() then
			confirmBox:destroy()
		end

		confirmBox = nil
	end

	local function confirmDelete()
		closeConfirm()
		HelperConfigTab.deleteProfile(name)
	end

	confirmBox = displayGeneralBox(configText("deletePreset"), string.format(configText("deleteConfirm"), name), {
		{
			text = configText("no"),
			callback = closeConfirm
		},
		{
			text = configText("yes"),
			callback = confirmDelete
		}
	}, confirmDelete, closeConfirm)
end

function HelperConfigTab.init(pctx)
	ctx = pctx

	HelperConfigTab.initLanguageSelector()
	HelperConfigTab.initQuickProfileBar()
	HelperConfigTab.initProfilesPanel()
end

function HelperConfigTab.refreshAutoSwitchHotkeyPreset()
	if not ctx or not ctx.isAutoSwitchHotkeyPresetEnabled or not ctx.applyAutoSwitchHotkeyPresetToCheckbox then
		return
	end

	ctx.applyAutoSwitchHotkeyPresetToCheckbox(ctx.isAutoSwitchHotkeyPresetEnabled())
end

function HelperConfigTab.onShow()
	if ctx and ctx.refreshProfileLibrary then
		ctx.refreshProfileLibrary()
	end

	HelperConfigTab.refreshAutoSwitchHotkeyPreset()
	HelperConfigTab.refreshProfileList()
end

function HelperConfigTab.onHide()
	return
end

function HelperConfigTab.terminate()
	if profileInputBox and not profileInputBox:isDestroyed() then
		profileInputBox:destroy()
	end

	profileInputBox = nil
	selectedProfileName = nil
	currentLanguage = "en"
	suppressLanguageChange = false
	suppressQuickProfileChange = false
end

function HelperConfigTab.collectConfig(config)
	if ctx and ctx.isAutoSaveEnabled then
		config.autoSaveEnabled = ctx.isAutoSaveEnabled()
	end

	config.strictPzAuto = nil
	config.sharedCombatHotkey = nil
	config.allowSharedCombatHotkey = nil
end

function HelperConfigTab.loadFromConfig(config)
	config = config or {}
	config.strictPzAuto = nil
	config.sharedCombatHotkey = nil
	config.allowSharedCombatHotkey = nil
end
