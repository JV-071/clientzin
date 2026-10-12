local function check(fullApi, disabledWalk, hasCreature)
  local calls = {}
  local function record(name) return function(_, value) calls[#calls + 1] = name .. ":" .. tostring(value) end end
  local previewCreature = {setAnimate = record("animate"),
    isDisabledWalkAnimation = function() return disabledWalk end,
    setDisableWalkAnimation = record("disableWalk")}
  local preview = {setOutfit = record("outfit"), getCreature = function() if hasCreature then return previewCreature end end,
    setCenter = record("center"), setCenterByBoundingBox = record("boundsCenter"),
    setCreatureSize = record("size"), setAutoFit = record("autoFit")}
  if fullApi then
    preview.setFitVisibleBounds = record("fitVisibleBounds")
    preview.setFixedCreatureSize = record("fixedSize")
    preview.setBaseScale = record("baseScale")
    preview.setIgnoreDisplacementShift = record("ignoreDisplacement")
    preview.setCreatureSmooth = record("smooth")
  end
  local button = {getChildById = function(_, id) assert(id == "creature") return preview end}
  UICreatureButton.updateOutfitPreview(button, "testOutfit")
  local expected = {"outfit:testOutfit"}
  if hasCreature then
    expected[#expected + 1] = "animate:true"
    if not disabledWalk then expected[#expected + 1] = "disableWalk:true" end
  end
  expected[#expected + 1] = "center:true"; expected[#expected + 1] = "boundsCenter:true"
  if fullApi then
    expected[#expected + 1] = "fitVisibleBounds:true"; expected[#expected + 1] = "fixedSize:true"
  else expected[#expected + 1] = "autoFit:true" end
  expected[#expected + 1] = "size:0"
  if fullApi then
    expected[#expected + 1] = "baseScale:false"; expected[#expected + 1] = "ignoreDisplacement:false"
    expected[#expected + 1] = "smooth:false"
  end
  assert(table.concat(calls, ",") == table.concat(expected, ","), table.concat(calls, ","))
end
check(false, false, true)
check(false, true, true)
check(false, false, false)
check(true, false, true)
check(true, true, true)
check(true, false, false)
UICreatureButton.updateOutfitPreview({getChildById = function() return nil end}, "testOutfit")
return true
