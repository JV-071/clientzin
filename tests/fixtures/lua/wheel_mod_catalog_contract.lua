-- Search must match a literal substring of a modification description.
string.empty = string.empty or function(value) return value == nil or value == "" end
WheelOfDestiny = {basicModsUpgrade = {[1] = 1}, supremeModsUpgrade = {[2] = 2}}
local fragments = ModCatalog.getFragmentList()
fragments[1] = {modID = 1, supreme = false, tooltip = "+5% Damage and Healing"}
fragments[2] = {modID = 2, supreme = true, tooltip = "Ice Resistance"}
fragments[3] = {modID = 3, supreme = false, tooltip = "Cooldown reduction"}
fragments[4] = {modID = 4, supreme = false}
local function expectIds(actual, expected)
  local ids = {}
  for _, entry in ipairs(actual) do ids[#ids + 1] = entry.modID end
  table.sort(ids)
  assert(table.concat(ids, ",") == expected, "expected " .. expected .. ", got " .. table.concat(ids, ","))
end
expectIds(ModCatalog.searchModifications("damage"), "1")
expectIds(ModCatalog.searchModifications("HEALING"), "1")
expectIds(ModCatalog.searchModifications("Resistance"), "2")
expectIds(ModCatalog.searchModifications("+5%"), "1")
expectIds(ModCatalog.searchModifications(".*"), "")
expectIds(ModCatalog.searchModifications("missing"), "")
expectIds(ModCatalog.searchModifications(nil), "")
expectIds(ModCatalog.getSortList({text = "Basic Mods"}, {}, {}, "DAMAGE"), "1")
expectIds(ModCatalog.getSortList({text = "Supreme Mods"}, {}, {}, "ice"), "2")
expectIds(ModCatalog.getSortList({text = "Basic Mods"}, {}, {}, "ice"), "")
expectIds(ModCatalog.getSortList({text = "Grade II"}, {}, {}, "healing"), "1")
expectIds(ModCatalog.getSortList({text = "In-Vessel Mods"}, {["1"] = 42}, {["2"] = 43}, "ice"), "2")
expectIds(ModCatalog.getSortList({text = "Basic Mods"}, {}, {}, ""), "1,3,4")
return true
