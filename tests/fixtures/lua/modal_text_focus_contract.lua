local function widget(className, parent)
  return {getClassName = function() return className end,
    getId = function() return "fixtureWidget" end, getChildren = function() return {} end,
    getParent = function() return parent end, isDestroyed = function() return false end,
    raise = function() end, focus = function() end, grabKeyboard = function() end,
    ungrabKeyboard = function() end, fill = function() end, setId = function() end,
    setFocusable = function() end, setPhantom = function() end,
    setBackgroundColor = function() end, destroy = function() end}
end
function isWidgetAlive(value) return value and not value:isDestroyed() end
function connect() end
function signalcall(callback, ...) if callback then return callback(...) end end
KeyTab = 1; KeyboardNoModifier = 0; KeyboardShiftModifier = 1
modules = {}; g_game = {}; rootWidget = widget("UIWidget")
local modal = widget("UIWindow", rootWidget)
local selected = 1
local first, second = widget("UIButton", modal), widget("UIButton", modal)
first.isOn = function() return selected == 1 end
second.isOn = function() return selected == 2 end
first.onClick = function() selected = 1 end
second.onClick = function() selected = 2 end
local menus = widget("UIWidget", modal)
menus.getChildren = function() return {first, second} end
modal.recursiveGetChildById = function(_, id) if id == "menus" then return menus end end
local focused
 g_ui = {createWidget = function() return widget("UIWidget", rootWidget) end,
         getFocusedWidget = function() return focused end}
g_modalManager.show(modal)
for _, className in ipairs({"UITextEdit", "UITextEditBox"}) do
  focused = widget(className, modal)
  assert(g_modalManager.handleTabKey(KeyTab, KeyboardNoModifier) == false, "Tab must stay in " .. className)
  assert(selected == 1)
end
focused = first
assert(g_modalManager.handleTabKey(KeyTab, KeyboardNoModifier) == true and selected == 2)
assert(g_modalManager.handleTabKey(KeyTab, KeyboardNoModifier) == true and selected == 1)
assert(g_modalManager.handleTabKey(KeyTab, KeyboardShiftModifier) == true and selected == 2)
assert(g_modalManager.handleTabKey(KeyTab, 9) == false and selected == 2)
assert(g_modalManager.handleTabKey(99, KeyboardNoModifier) == false and selected == 2)
g_modalManager.hide(modal)
assert(g_modalManager.handleTabKey(KeyTab, KeyboardNoModifier) == false)
return true
