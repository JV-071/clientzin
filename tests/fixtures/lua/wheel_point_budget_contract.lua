-- Exercise the actual point-investment handlers against a finite point budget.
local noop = function() end
local widget = {setValue = noop, setText = noop}
wheelOfDestinyWindow = {
  selection = {tabContent = {dedicationPb = widget}, points = widget},
  recursiveGetChildById = function() return {setVisible = noop, setEnabled = noop} end
}
GemAtelier = {setupVesselPanel = noop}
comma_value = tostring
table.reserve = function(count, value)
  local result = {}; for index = 1, count do result[index] = value end; return result
end
WheelBonus = {[0] = {maxPoints = 50, domain = 1}}
WheelNodes = {}
for _, name in ipairs({"configureDedication", "configureConviction", "insertPoint",
  "configureDedicationPerk", "configureConvictionPerk", "configureVessels",
  "configureSummary", "configurePassives", "configureEquippedGems", "checkApplyButton", "checkManagerPointsButtons"}) do
  WheelOfDestiny[name] = noop
end
local function reset(total, invested, extra, scroll)
  WheelOfDestiny.isPreview = false
  WheelOfDestiny.vocationId = 1
  WheelOfDestiny.changeState = 1
  WheelOfDestiny.points = total
  WheelOfDestiny.extraGemPoints = extra or 0
  WheelOfDestiny.scrollPoints = scroll or 0
  WheelOfDestiny.pointInvested = {[1] = invested}
  WheelOfDestiny.usedPoints = invested
  WheelOfDestiny.clickIndex = 1
end
local function expect(handler, total, invested, amount, expected, extra, scroll)
  reset(total, invested, extra, scroll)
  handler(1, amount)
  assert(WheelOfDestiny.pointInvested[1] == expected,
    'point budget violated: expected ' .. expected .. ', got ' .. WheelOfDestiny.pointInvested[1])
  assert(WheelOfDestiny.usedPoints == expected, 'used point total diverged')
end
expect(onAddOne, 3, 3, nil, 3)
expect(onAddOne, 3, 2, nil, 3)
expect(onAddCustom, 3, 2, 50, 3)
expect(onAddCustom, 3, 3, 50, 3)
expect(onAddCustom, 10, 2, 3, 5)
expect(onAddCustom, 100, 49, 50, 50)
expect(onAddCustom, 3, 2, 0, 2)
expect(onAddCustom, 3, 2, -2, 2)
expect(onAddCustom, 3, 2, 50, 6, 1, 2)
reset(3, 2); WheelOfDestiny.isPreview = true; onAddCustom(1, 50)
assert(WheelOfDestiny.pointInvested[1] == 2)
return true
