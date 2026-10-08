HotkeyUtils = HotkeyUtils or {}

local hotkeyBlockingSources = {}
local nextSourceId = 1
local HOTKEY_COOLDOWN_MS = 250
local lastHotkeyTimeByCombo = {}
local HOTKEY_USE
local HOTKEY_USEONSELF = 1
local HOTKEY_USEONTARGET = 2
local HOTKEY_USEWITH = 3

local function getCallerModule()
	local dbg = rawget(_G, "debug")

	if type(dbg) ~= "table" then
		return "unknown"
	end

	local getinfo = dbg.getinfo

	if type(getinfo) ~= "function" then
		return "unknown"
	end

	local ok, info = pcall(function()
		return getinfo(3, "S")
	end)

	if not ok or type(info) ~= "table" or not info.source then
		return "unknown"
	end

	local source = info.source:gsub("@", "")

	return (source:match("/modules/([^/]+)/") or source:match("\\modules\\([^\\]+)\\") or source:match("([^/\\]+)%.lua$") or "unknown"):gsub("_", "")
end

function HotkeyUtils.enableHotkeys(sourceId)
	if sourceId then
		hotkeyBlockingSources[sourceId] = nil
	end
end

function HotkeyUtils.disableHotkeys(sourceIdentifier)
	local sourceId = sourceIdentifier or "auto_" .. nextSourceId

	nextSourceId = nextSourceId + 1
	hotkeyBlockingSources[sourceId] = true

	return sourceId
end

function HotkeyUtils.createHotkeyBlock(sourceIdentifier)
	local callerModule = getCallerModule()
	local fullId = sourceIdentifier and sourceIdentifier .. "_" .. callerModule or "auto_" .. callerModule .. "_" .. nextSourceId
	local blockId = HotkeyUtils.disableHotkeys(fullId)

	return {
		release = function()
			HotkeyUtils.enableHotkeys(blockId)
		end,
		getId = function()
			return fullId
		end
	}
end

function HotkeyUtils.areHotkeysDisabled()
	for _ in pairs(hotkeyBlockingSources) do
		return true
	end

	return false
end

function HotkeyUtils.clearAllHotkeyBlocks()
	hotkeyBlockingSources = {}

	if modules.game_actionbar and modules.game_actionbar.forceResumeHotkeys then
		modules.game_actionbar.forceResumeHotkeys()
	end
end

function HotkeyUtils.tryAcquireHotkeyCooldown(keyCombo)
	if not keyCombo or keyCombo == "" then
		return false
	end

	local now = g_clock.millis()

	if now - (lastHotkeyTimeByCombo[keyCombo] or 0) < HOTKEY_COOLDOWN_MS then
		return false
	end

	lastHotkeyTimeByCombo[keyCombo] = now

	return true
end

function HotkeyUtils.canPerformKeyCombo(keyCombo)
	if HotkeyUtils.areHotkeysDisabled() then
		return false
	end

	if g_mouse.isMouseHotkeyDesc(keyCombo) then
		return true
	end

	if not modules.game_console or not modules.game_console.isChatEnabled or not modules.game_console.isChatEnabled() then
		return true
	end

	return string.match(keyCombo, "Ctrl%+") or string.match(keyCombo, "Alt%+") or string.match(keyCombo, "F%d+")
end

function HotkeyUtils.executeHotkeyItem(action, itemId, subType, onItemUse)
	if action == HOTKEY_USE then
		if subType then
			local item = g_game.findPlayerItem(itemId, subType or -1)

			if item then
				if onItemUse then
					onItemUse(true)
				end

				g_game.use(item)
			end
		else
			if onItemUse then
				onItemUse(true)
			end

			g_game.useInventoryItem(itemId)
		end
	elseif action == HOTKEY_USEONSELF then
		if subType then
			local item = g_game.findPlayerItem(itemId, subType or -1)

			if item then
				if onItemUse then
					onItemUse(true)
				end

				g_game.useWith(item, g_game.getLocalPlayer())
			end
		else
			if onItemUse then
				onItemUse(true)
			end

			g_game.useInventoryItemWith(itemId, g_game.getLocalPlayer())
		end
	elseif action == HOTKEY_USEONTARGET then
		local attackingCreature = g_game.getAttackingCreature()

		if not attackingCreature then
			local item = Item.create(itemId)

			if subType then
				local tmpItem = g_game.findPlayerItem(itemId, subType or -1)

				if not tmpItem then
					return
				end

				item = tmpItem
			end

			modules.game_interface.startUseWith(item, onItemUse)

			return
		end

		if not attackingCreature:getTile() then
			return
		end

		if subType then
			local item = g_game.findPlayerItem(itemId, subType or -1)

			if item then
				if onItemUse then
					onItemUse(true)
				end

				g_game.useWith(item, attackingCreature)
			end
		else
			if onItemUse then
				onItemUse(true)
			end

			g_game.useInventoryItemWith(itemId, attackingCreature)
		end
	elseif action == HOTKEY_USEWITH then
		local item = Item.create(itemId)

		if subType then
			local tmpItem = g_game.findPlayerItem(itemId, subType or -1)

			if not tmpItem then
				return true
			end

			item = tmpItem
		end

		modules.game_interface.startUseWith(item, onItemUse)
	end
end
