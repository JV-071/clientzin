-- A subtype belongs to the item; startUseWith's second argument is a callback.
local trace, available, target = {}, false, nil
local player = {}
local function makeItem(subtype, tier)
  return {subType = subtype, tier = tier or 0,
    setSubType = function(self, value) self.subType = value end,
    setTier = function(self, value) self.tier = value end}
end
Item = {create = function(id) if id == 0 then return nil end return makeItem(-1, 0) end}
modules = {game_interface = {startUseWith = function(item, callback)
  assert(callback == nil, "subtype was passed as a callback")
  trace[#trace + 1] = "crosshair:" .. item.subType .. ":" .. item.tier
end}}
g_game = {
  getLocalPlayer = function() return player end,
  getAttackingCreature = function() return target end,
  findPlayerItem = function(id, subtype, tier)
    trace[#trace + 1] = "find:" .. subtype .. ":" .. tier
    if available then return makeItem(subtype, tier) end
  end,
  useInventoryItemWith = function(id, destination, ...)
    assert(select("#", ...) == 0, "unsupported subtype argument")
    trace[#trace + 1] = "inventoryWith"
  end,
  useWith = function(item, destination) trace[#trace + 1] = "useWith:" .. item.subType end,
  useInventoryItem = function(id) trace[#trace + 1] = "inventory" end,
  use = function(item) trace[#trace + 1] = "use:" .. item.subType end
}
Keybind.currentPreset = "test"
local function check(action, subtype, tier, found, attacking, expected, itemId)
  trace = {}; available = found; target = attacking
  Keybind.hotkeys[CHAT_MODE.ON].test = {[1] = {action = action, data = {itemId = itemId or 200, subType = subtype, getTier = tier}}}
  Keybind.hotkeyCallback(1, CHAT_MODE.ON)
  assert(table.concat(trace, ",") == expected, "expected " .. expected .. ", got " .. table.concat(trace, ","))
end
check(HOTKEY_ACTION.USE_CROSSHAIR, nil, nil, false, nil, "crosshair:-1:0")
check(HOTKEY_ACTION.USE_CROSSHAIR, 0, 2, true, nil, "find:0:2,crosshair:0:2")
check(HOTKEY_ACTION.USE_CROSSHAIR, 7, 2, false, nil, "find:7:2,crosshair:7:2")
check(HOTKEY_ACTION.USE_CROSSHAIR, nil, nil, false, nil, "", 0)
check(HOTKEY_ACTION.USE_TARGET, 7, nil, false, nil, "find:7:0,crosshair:7:0")
local creature = {getTile = function() return {} end}
check(HOTKEY_ACTION.USE_TARGET, nil, nil, false, creature, "inventoryWith")
check(HOTKEY_ACTION.USE_TARGET, 0, 2, true, creature, "find:0:2,useWith:0")
check(HOTKEY_ACTION.USE_TARGET, 7, nil, false, creature, "find:7:0")
check(HOTKEY_ACTION.USE_TARGET, nil, nil, false, {getTile = function() return nil end}, "")
check(HOTKEY_ACTION.USE_YOURSELF, nil, nil, false, nil, "inventoryWith")
check(HOTKEY_ACTION.USE_YOURSELF, 0, 2, true, nil, "find:0:2,useWith:0")
check(HOTKEY_ACTION.USE_YOURSELF, 7, nil, false, nil, "find:7:0")
check(HOTKEY_ACTION.USE, nil, nil, false, nil, "inventory")
check(HOTKEY_ACTION.USE, 0, 2, true, nil, "find:0:2,use:0")
check(HOTKEY_ACTION.USE, 7, nil, false, nil, "find:7:0")
return true
