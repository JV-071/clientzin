CipImportMappings = {}
CipImportMappings.OPTION_KEYS = {
	keyboardDelayMs = {
		key = "hotkeyDelay",
		type = "number"
	},
	autoChaseEnabled = {
		key = "autoChaseOff",
		invert = true,
		type = "bool"
	},
	actionBarShowBottom1 = {
		key = "actionBarShowBottom1",
		type = "bool"
	},
	actionBarShowBottom2 = {
		key = "actionBarShowBottom2",
		type = "bool"
	},
	actionBarShowBottom3 = {
		key = "actionBarShowBottom3",
		type = "bool"
	},
	actionBarShowLeft1 = {
		key = "actionBarShowLeft1",
		type = "bool"
	},
	actionBarShowLeft2 = {
		key = "actionBarShowLeft2",
		type = "bool"
	},
	actionBarShowLeft3 = {
		key = "actionBarShowLeft3",
		type = "bool"
	},
	actionBarShowRight1 = {
		key = "actionBarShowRight1",
		type = "bool"
	},
	actionBarShowRight2 = {
		key = "actionBarShowRight2",
		type = "bool"
	},
	actionBarShowRight3 = {
		key = "actionBarShowRight3",
		type = "bool"
	},
	actionBarBottomLocked = {
		key = "actionBarBottomLocked",
		type = "bool"
	},
	actionBarLeftLocked = {
		key = "actionBarLeftLocked",
		type = "bool"
	},
	actionBarRightLocked = {
		key = "actionBarRightLocked",
		type = "bool"
	},
	actionButtonShowHotkey = {
		key = "showAssignedHKButton",
		type = "bool"
	},
	actionButtonShowSpellParameters = {
		key = "showSpellParameters",
		type = "bool"
	},
	actionButtonShowAmount = {
		key = "showHKObjectsBars",
		type = "bool"
	},
	actionButtonShowCooldownNumbers = {
		key = "showTooltips",
		type = "bool"
	},
	vsyncEnabled = {
		key = "vsync",
		type = "bool"
	},
	frameRateLimit = {
		key = "backgroundFrameRate",
		requires = "frameRateLimitEnabled",
		type = "number"
	},
	frameRateLimitEnabled = {
		key = "noFrameRateLimit",
		invert = true,
		type = "bool"
	},
	antialiasingMode = {
		key = "antialiasingMode",
		type = "number"
	},
	alwaysTurnTowardsMoveDirection = {
		key = "alwaysTurnTowardsMovement",
		type = "bool"
	},
	creatureShowHealth = {
		key = "showOtherHealth",
		type = "bool"
	},
	creatureShowName = {
		key = "showOtherName",
		type = "bool"
	},
	creatureShowMarks = {
		key = "showOtherMarks",
		type = "bool"
	},
	playerShowHealth = {
		key = "showOwnHealth",
		type = "bool"
	},
	playerShowMana = {
		key = "showOwnMana",
		type = "bool"
	},
	playerShowName = {
		key = "showOwnName",
		type = "bool"
	},
	gameWindowShowTextualEffects = {
		key = "showTextualEffects",
		type = "bool"
	},
	gameWindowShowMessages = {
		key = "showMessages",
		type = "bool"
	},
	gameWindowShowPrivateMessages = {
		key = "showPrivateMessages",
		type = "bool"
	},
	gameWindowShowPotionMessages = {
		key = "showPotionSoundEffects",
		type = "bool"
	},
	gameWindowShowOwnSpells = {
		key = "showSpells",
		type = "bool"
	},
	gameWindowShowOthersSpells = {
		key = "showSpellsOfOthers",
		type = "bool"
	},
	gameWindowShowHotkeyUsageMessages = {
		key = "showHotkeyUsageNotifications",
		type = "bool"
	},
	gameWindowShowLootMessages = {
		key = "showLootMessages",
		type = "bool"
	},
	gameWindowShowLootHighlighting = {
		key = "showLootHighlighting",
		type = "bool"
	},
	gameWindowShowBoostedCreatureMessages = {
		key = "showBoostedCreature",
		type = "bool"
	},
	gameWindowShowOfflineTrainingMessages = {
		key = "showOfflineTrainingProgress",
		type = "bool"
	},
	gameWindowShowStoreMessages = {
		key = "showStoreNotificationsInCombat",
		type = "bool"
	},
	combatShowFrames = {
		key = "showCombatFrames",
		type = "bool"
	},
	combatShowPvpFrames = {
		key = "showPvPFrames",
		type = "bool"
	},
	gameWindowShowAttackAnimation = {
		key = "showMeleeAttackAnimation",
		type = "bool"
	},
	gameWindowShowInfoBanner = {
		key = "showInfoBanner",
		type = "bool"
	}
}
CipImportMappings.CONTROL_BUTTON_IDS = {
	bosstiaryDialog = "bosstiary",
	bestiaryTrackerWidget = "trackerButton",
	analyticsSelectorWidget = "analyticsSelectorWidget",
	cyclopediaDialog = "CyclopediaButton",
	preyDialog = "preyButton",
	spellListWidget = "spellListWidget",
	preyWidget = "preyButton",
	compendiumDialog = "compendiumDialog",
	skillWheelDialog = "wheelButton",
	manageShortcuts = "manageShortcuts",
	vipWidget = "vipListButton",
	partyWidget = "partyWidget",
	bossslotsDialog = "bossSlot",
	battleListWidget = "battleButton",
	bosstiaryTrackerWidget = "bosstiarytrackerButton",
	skillsWidget = "skillsButton",
	questDialog = "questLogButton",
	unjustifiedPoinsWidget = "unjustifiedPointsButton",
	questTrackerWidget = "QuestLogTracker",
	rewardWallDialog = "rewardWall",
	taskboard = "taskBoard",
	weaponProficiency = "ProciencyButton",
	highscoresDialog = "highscoresButton",
	friendsDialog = "friendsDialog",
	exaltationForgeDialog = "forgeButton",
	imbuementTrackerWidget = "imbuementTrackerButton"
}
CipImportMappings.USE_TYPE = {
	SelectUseTarget = "useWith",
	Equip = "equip",
	UseOnTarget = "useOnTarget",
	UseOnYourself = "useOnSelf",
	Use = "use"
}
CipImportMappings.USE_TYPE_TO_HOTKEY_ACTION = {
	Equip = HOTKEY_ACTION.EQUIP,
	Use = HOTKEY_ACTION.USE,
	UseOnYourself = HOTKEY_ACTION.USE_YOURSELF,
	UseOnTarget = HOTKEY_ACTION.USE_TARGET,
	SelectUseTarget = HOTKEY_ACTION.USE_CROSSHAIR
}
CipImportMappings.KEYBIND_ACTIONS = {
	AttackNextTarget = {
		"Battle List",
		"Attack Next Target"
	},
	ChangeCharacter = {
		"Misc.",
		"Change Character"
	},
	ClearOldestMessage = {
		"Misc.",
		"Clear oldest message from Game Window"
	},
	Logout = {
		"Misc.",
		"Logout"
	},
	NextHotkeyPreset = {
		"Misc.",
		"Next Hotkey Preset"
	},
	ShowLenshelp = {
		"Misc.",
		"Activate Lenshelp"
	},
	TakeScreenshot = {
		"Misc.",
		"Take Screenshot"
	},
	NextChannel = {
		"Chat Channel",
		"Next Channel"
	},
	PreviousChannel = {
		"Chat Channel",
		"Previous Channel"
	},
	OpenChannelList = {
		"Chat Channel",
		"Open Channel List"
	},
	CloseCurrentChannel = {
		"Chat Channel",
		"Close Current Channel"
	},
	OpenHelpChannel = {
		"Chat Channel",
		"Open Help Channel"
	},
	ShowDefaultChannel = {
		"Chat Channel",
		"Show Default Channel"
	},
	ChatModeTemporaryOn = {
		"Chat Mode",
		"Set to Chat On*"
	},
	Copy = {
		"Chat Text",
		"Copy to clipboard"
	},
	SelectAll = {
		"Chat Text",
		"Select all"
	},
	PressEnterInChat = {
		"Chat",
		"Send current chat line"
	},
	ToggleShowServermessagesInCurrentChannel = {
		"Chat",
		"Show/hide Show Server messages in current channel"
	},
	ToggleBattlelist = {
		"Windows",
		"Show/hide battle list"
	},
	ToggleSkillsWidget = {
		"Windows",
		"Show/hide skills window"
	},
	ToggleSpellListWidget = {
		"Windows",
		"Show/hide spell list"
	},
	ToggleVipWidget = {
		"Windows",
		"Show/hide VIP list"
	},
	ShowCyclopediaMap = {
		"Dialogs",
		"Open Cyclopedia - Map"
	},
	ShowIgnorelist = {
		"Dialogs",
		"Open Ignore List"
	},
	ShowOptionsHotkeys = {
		"Dialogs",
		"Open Options - Custom Hotkeys"
	},
	ShowQuestlog = {
		"Dialogs",
		"Open Questlog"
	},
	ShowPrey = {
		"Dialogs",
		"Open Prey Dialog"
	},
	Bugreport = {
		"Dialogs",
		"Open Bugreport"
	},
	QuickLootAreaAtPlayer = {
		"Loot",
		"Quick Loot Nearby Corpses"
	},
	ToggleManualSortMode = {
		"Containers",
		"Toggle Manual Sort Mode"
	},
	GoEast = {
		"Movement",
		"Go East"
	},
	GoNorth = {
		"Movement",
		"Go North"
	},
	GoNorthEast = {
		"Movement",
		"Go North-East"
	},
	GoNorthWest = {
		"Movement",
		"Go North-West"
	},
	GoSouth = {
		"Movement",
		"Go South"
	},
	GoSouthEast = {
		"Movement",
		"Go South-East"
	},
	GoSouthWest = {
		"Movement",
		"Go South-West"
	},
	GoWest = {
		"Movement",
		"Go West"
	},
	StopPlayer = {
		"Movement",
		"Stop All Actions"
	},
	ToggleMounted = {
		"Movement",
		"Mount/dismount"
	},
	MinimapCenter = {
		"Minimap",
		"Center"
	},
	MinimapFloorDown = {
		"Minimap",
		"One Floor Down"
	},
	MinimapFloorUp = {
		"Minimap",
		"One Floor Up"
	},
	MinimapScrollEast = {
		"Minimap",
		"Scroll East"
	},
	MinimapScrollNorth = {
		"Minimap",
		"Scroll North"
	},
	MinimapScrollSouth = {
		"Minimap",
		"Scroll South"
	},
	MinimapScrollWest = {
		"Minimap",
		"Scroll West"
	},
	MinimapZoomIn = {
		"Minimap",
		"Zoom In"
	},
	MinimapZoomOut = {
		"Minimap",
		"Zoom Out"
	}
}
CipImportMappings.KEY_SEQUENCE_REPLACEMENTS = {
	["Alt+PgUp"] = "Alt+PageUp",
	Return = "Enter",
	Esc = "Escape",
	Backtab = "BackTab",
	["Alt+PgDown"] = "Alt+PageDown"
}
CipImportMappings.PER_CHARACTER_FILES = {
	"wheelOfDestiny.json",
	"cyclopediaMapConfiguration.json",
	"xpanalyser.json",
	"impactanalyser.json",
	"damageinputanalyser.json",
	"gainandwaste.json",
	"huntingsessionanalyser.json",
	"itemtracking.json",
	"itemprices.json",
	"lootBlackWhitelist.json"
}
CipImportMappings.IGNORED_CHARACTER_FILES = {
	questtracking = true,
	aimattargetconfigurationstorage = true,
	statusBarData = true,
	outfitdialog = true,
	actionbars = true
}
CipImportMappings.SIDEBAR_SKIPPED_TYPES = {
	playerGuide = true,
	container = true
}
CipImportMappings.SIDEBAR_WIDGET_MAP = {
	battleList = {
		primaryInstance = 0,
		widgetId = "battleWindow"
	},
	skills = {
		widgetId = "skillWindow"
	},
	questTracker = {
		widgetId = "QuestLogTracker"
	},
	vip = {
		widgetId = "vipWindow"
	},
	vipList = {
		widgetId = "vipWindow"
	},
	partyList = {
		widgetId = "partyWindow"
	},
	unjustifiedPoints = {
		widgetId = "unjustifiedPointsWindow"
	},
	spellList = {
		widgetId = "spellListMiniWindow"
	},
	helperStats = {
		widgetId = "helperStatsWindow"
	},
	prey = {
		widgetId = "preyTracker"
	},
	imbuementTracker = {
		widgetId = "imbuementTracker"
	},
	bestiaryTracker = {
		widgetId = "BestiaryTrackerWindow"
	},
	bosstiaryTracker = {
		widgetId = "BosstiaryTrackerWindow"
	},
	battlePassTracker = {
		widgetId = "BattlePassTrackerWindow"
	},
	battlePassInbox = {
		widgetId = "BattlePassInboxWindow"
	},
	analyticsSelector = {
		widgetId = "analyserMiniWindow"
	},
	lootAnalyser = {
		widgetId = "lootAnalyserMiniWindow"
	},
	supplyAnalyser = {
		widgetId = "supplyAnalyserMiniWindow"
	},
	impactAnalyser = {
		widgetId = "impactAnalyserMiniWindow"
	},
	damageInputAnalyser = {
		widgetId = "inputAnalyserMiniWindow"
	},
	huntingSessionAnalyser = {
		widgetId = "huntingAnalyserMiniWindow"
	},
	partyHuntAnalyser = {
		widgetId = "phAnalyserMiniWindow"
	},
	xpAnalyser = {
		widgetId = "xpAnalyserMiniWindow"
	}
}
CipImportMappings.SIDEBAR_WIDGET_OPTIONS_KEYS = {
	battleList = {
		section = "battleListsOptions",
		useInstance = true
	},
	skills = {
		section = "skillsWidgetOptions"
	},
	questTracker = {
		section = "questTrackerWidgetOptions"
	},
	vip = {
		section = "vipWidgetOptions"
	},
	partyList = {
		section = "partyWidgetOptions"
	},
	unjustifiedPoints = {
		section = "unjustifiedPointsOptions"
	},
	spellList = {
		section = "spellListWidgetOptions"
	},
	helperStats = {
		section = "helperStatsWidgetOptions"
	},
	prey = {
		section = "preyWidgetOptions"
	},
	imbuementTracker = {
		section = "imbuementTrackerWidgetOptions"
	},
	bestiaryTracker = {
		section = "bestiaryTrackerWidgetOptions"
	},
	bosstiaryTracker = {
		section = "bosstiaryTrackerWidgetOptions"
	},
	battlePassTracker = {
		section = "battlePassTrackerWidgetOptions"
	},
	battlePassInbox = {
		section = "battlePassInboxWidgetOptions"
	},
	analyticsSelector = {
		section = "analyticsSelectorOptions"
	},
	lootAnalyser = {
		section = "lootAnalyserWidgetOptions"
	},
	supplyAnalyser = {
		section = "supplyAnalyserWidgetOptions"
	},
	impactAnalyser = {
		section = "impactAnalyserWidgetOptions"
	},
	damageInputAnalyser = {
		section = "damageInputAnalyserWidgetOptions"
	},
	huntingSessionAnalyser = {
		section = "huntingSessionAnalyserWidgetOptions"
	},
	partyHuntAnalyser = {
		section = "partyHuntAnalyserOptions"
	},
	xpAnalyser = {
		section = "xpAnalyserWidgetOptions"
	}
}

function CipImportMappings.sidebarParentIdForIndex(sidebarIndex)
	sidebarIndex = tonumber(sidebarIndex) or 0

	if sidebarIndex == 0 then
		return "gameRightPanel"
	elseif sidebarIndex == 1 then
		return "gameLeftPanel"
	elseif sidebarIndex == 2 then
		return "gameLeftExtraPanel"
	elseif sidebarIndex == 3 then
		return "gameRightExtraPanel"
	end

	return "gameRightPanel"
end

function CipImportMappings.resolveSidebarWidgetId(widgetType, instance)
	if CipImportMappings.SIDEBAR_SKIPPED_TYPES[widgetType] then
		return nil
	end

	local mapping = CipImportMappings.SIDEBAR_WIDGET_MAP[widgetType]

	if not mapping then
		return nil
	end

	if mapping.primaryInstance ~= nil then
		instance = instance or 0

		if instance ~= mapping.primaryInstance then
			return nil
		end
	end

	return mapping.widgetId
end

function CipImportMappings.widgetSettingsFromSidebarsOptions(sidebars, widgetType, instance)
	local optsKey = CipImportMappings.SIDEBAR_WIDGET_OPTIONS_KEYS[widgetType]

	if not optsKey then
		return {}
	end

	local section = sidebars[optsKey.section]

	if type(section) ~= "table" then
		return {}
	end

	local opts = section

	if optsKey.useInstance then
		opts = section[tostring(instance or 0)]
	end

	if type(opts) ~= "table" then
		return {}
	end

	local settings = {}

	if type(opts.contentHeight) == "number" and opts.contentHeight > 0 then
		settings.height = opts.contentHeight
	end

	if opts.contentMaximized == false then
		settings.minimized = true
	elseif opts.contentMaximized == true then
		settings.minimized = false
	end

	return settings
end

function CipImportMappings.convertSidebarsToCharMiniWindows(sidebars)
	if type(sidebars) ~= "table" then
		return nil
	end

	local manager = sidebars.sidebarWidgetsMangerOptions

	if type(manager) ~= "table" then
		return nil
	end

	local orderPerSidebar = manager.openWidgetsOrderPerSidebar

	if type(orderPerSidebar) ~= "table" then
		return nil
	end

	local result = {}

	for sidebarIndex, widgetList in ipairs(orderPerSidebar) do
		if type(widgetList) == "table" then
			local parentId = CipImportMappings.sidebarParentIdForIndex(sidebarIndex - 1)
			local slotIndex = 0

			for _, widget in ipairs(widgetList) do
				if type(widget) == "table" and type(widget.type) == "string" then
					local widgetType = widget.type
					local instance = widget.instance
					local widgetId = CipImportMappings.resolveSidebarWidgetId(widgetType, instance)

					if widgetId and not result[widgetId] then
						slotIndex = slotIndex + 1

						local settings = CipImportMappings.widgetSettingsFromSidebarsOptions(sidebars, widgetType, instance)

						settings.parentId = parentId
						settings.index = slotIndex
						settings.closed = false
						result[widgetId] = settings
					end
				end
			end
		end
	end

	if table.empty(result) then
		return nil
	end

	return result
end

function CipImportMappings.normalizeKeySequence(keysequence)
	if type(keysequence) ~= "string" or keysequence == "" then
		return nil
	end

	return CipImportMappings.KEY_SEQUENCE_REPLACEMENTS[keysequence] or keysequence
end

function CipImportMappings.isValidKeyCombo(key)
	if type(key) ~= "string" or key == "" then
		return false
	end

	key = CipImportMappings.normalizeKeySequence(key)

	if not key or key == "" then
		return false
	end

	if not retranslateKeyComboDesc then
		return true
	end

	local ok, translated = pcall(retranslateKeyComboDesc, key)

	return ok and translated ~= nil and translated ~= ""
end

function CipImportMappings.slotIdFor(barId, buttonIndex)
	barId = tonumber(barId)
	buttonIndex = tonumber(buttonIndex)

	if not barId or not buttonIndex or barId < 1 or barId > 9 or buttonIndex < 1 then
		return nil
	end

	if barId == 1 then
		return "slot" .. buttonIndex
	end

	return "bar" .. barId .. "_slot" .. buttonIndex
end

function CipImportMappings.parseTriggerActionButton(actionName)
	if type(actionName) ~= "string" then
		return nil, nil
	end

	local barId, buttonIndex = actionName:match("^TriggerActionButton_(%d+)%.(%d+)$")

	return barId, buttonIndex
end

function CipImportMappings.isValidItemId(itemId)
	if type(itemId) ~= "number" or itemId <= 0 then
		return false
	end

	if not g_things or not g_things.getThingType then
		return true
	end

	return g_things.getThingType(itemId, ThingCategoryItem) ~= nil
end

function CipImportMappings.convertActionSettingToSlot(setting)
	if type(setting) ~= "table" then
		return nil
	end

	if setting.chatText and setting.chatText ~= "" then
		local text = setting.chatText
		local words = text:lower():gsub("^%s+", ""):gsub("%s+$", "")

		if Spells and Spells.getSpellByWords and Spells.getSpellByWords(words) then
			local slot = {
				words = words
			}

			if setting.sendAutomatically then
				slot.autoSend = true
			end

			return slot
		end

		local slot = {
			text = text
		}

		if setting.sendAutomatically then
			slot.autoSend = true
		end

		return slot
	end

	if setting.useObject then
		if not CipImportMappings.isValidItemId(setting.useObject) then
			return nil
		end

		local slot = {
			itemId = setting.useObject,
			useType = CipImportMappings.USE_TYPE[setting.useType] or "use"
		}

		if type(setting.upgradeTier) == "number" and setting.upgradeTier > 0 then
			slot.getTier = setting.upgradeTier
		end

		if setting.useEquipSmartMode then
			slot.smartMode = true
		end

		return slot
	end

	return nil
end

function CipImportMappings.convertActionSettingToHotkey(setting)
	if type(setting) ~= "table" then
		return nil, nil
	end

	if setting.chatText and setting.chatText ~= "" then
		return setting.sendAutomatically and HOTKEY_ACTION.TEXT_AUTO or HOTKEY_ACTION.TEXT, {
			text = setting.chatText
		}
	end

	if setting.useObject then
		if not CipImportMappings.isValidItemId(setting.useObject) then
			return nil, nil
		end

		return CipImportMappings.USE_TYPE_TO_HOTKEY_ACTION[setting.useType] or HOTKEY_ACTION.USE, {
			itemId = setting.useObject
		}
	end

	if setting.action then
		local mapping = CipImportMappings.KEYBIND_ACTIONS[setting.action]

		if mapping then
			return "keybind", mapping
		end
	end

	return nil, nil
end

CipImportMappings.BRIDGE_CHARACTER_FILES = {
	"questtracking.json",
	"outfitdialog.json"
}
CipImportMappings.OTCLIENT_PRESERVED_SETTINGS = {
	"game_helper_data.json",
	"outfit.json",
	"questtracking.json",
	"npc_modal.json"
}

function CipImportMappings.convertQuestTrackingToOtClient(cipData, charNameLower)
	if type(cipData) ~= "table" then
		return nil
	end

	local result = {}

	if type(cipData.options) == "table" then
		if cipData.options.autoTrackNewQuests ~= nil then
			result.autoTrackNewQuests = cipData.options.autoTrackNewQuests
		end

		if cipData.options.autoUntrackCompletedQuests ~= nil then
			result.autoUntrackCompleted = cipData.options.autoUntrackCompletedQuests
		end
	end

	if charNameLower and charNameLower ~= "" and type(cipData.trackedQuests) == "table" then
		local tracked = {}

		for _, entry in ipairs(cipData.trackedQuests) do
			if type(entry) == "table" then
				local missionId = entry.missionId or entry.mission or entry.id
				local questId = entry.questId or entry.quest or entry.questLineId
				local missionName = entry.missionName or entry.name or entry.title or ""
				local missionDesc = entry.missionDescription or entry.description or missionName

				if missionId then
					table.insert(tracked, {
						tonumber(missionId),
						tostring(missionName),
						tostring(missionDesc),
						questId and tonumber(questId) or nil
					})
				end
			end
		end

		if #tracked > 0 then
			result[charNameLower] = tracked
		end
	end

	if table.empty(result) then
		return nil
	end

	return result
end

function CipImportMappings.convertOutfitDialogToOtClient(cipData)
	if type(cipData) ~= "table" then
		return nil
	end

	local presets = cipData.customiseCharacterPresets

	if type(presets) ~= "table" or #presets == 0 then
		return nil
	end

	local convertedPresets = {}

	for index, preset in ipairs(presets) do
		if type(preset) == "table" and not table.empty(preset) then
			convertedPresets[index] = preset
		end
	end

	if #convertedPresets == 0 then
		return nil
	end

	return {
		cipImportedPresets = convertedPresets,
		configureShowOffSocketPresets = cipData.configureShowOffSocketPresets
	}
end
