UIMiniWindowContainer = extends(UIWidget, "UIMiniWindowContainer")

local SIDEBAR_FREE_SPACE_IMAGE = "/images/ui/2pixel-up-frame-borderimage"
local SIDEBAR_FREE_SPACE_BORDER = 2

function UIMiniWindowContainer.create()
	local container = UIMiniWindowContainer.internalCreate()

	container.scheduledWidgets = {}

	container:setFocusable(false)
	container:setPhantom(true)
	connect(container, {
		onGeometryChange = function(widget)
			if type(widget.scheduleSidebarFreeSpaceRefresh) == "function" then
				widget:scheduleSidebarFreeSpaceRefresh()
			end
		end
	})

	return container
end

local function isSidebarFreeSpaceWidget(widget)
	return widget and widget._sidebarFreeSpaceWidget == true
end

local function isSidebarDragPlaceholder(widget)
	return widget and widget._sidebarDragPlaceholder == true
end

local function isSidebarSystemWidget(widget)
	return isSidebarFreeSpaceWidget(widget) or isSidebarDragPlaceholder(widget)
end

local function shouldManageSidebarFreeSpace(container)
	return isSidebarSystemWidget(container) or container and container.moveOnlyToMain
end

local function var_0_6(container)
	if not container or container:isDestroyed() or not container:isVisible() then
		return false
	end

	if container.ignoreFillAll or container.isHorizontalPanel or container.onlyPhantomDrop then
		return false
	end

	return true
end

local function ensureSidebarFreeSpaceWidget(container)
	local widget = container._sidebarFreeSpaceWidget

	if widget and not widget:isDestroyed() then
		return widget
	end

	local widget = g_ui.createWidget("UIWidget")

	widget:setId("sidebarFreeSpace")

	widget._sidebarFreeSpaceWidget = true

	widget:setPhantom(true)
	widget:setFocusable(false)
	widget:setImageSource(SIDEBAR_FREE_SPACE_IMAGE)
	widget:setImageBorder(SIDEBAR_FREE_SPACE_BORDER)
	widget:setImageRepeatedFromBottom(true)

	container._sidebarFreeSpaceWidget = widget

	return widget
end

function UIMiniWindowContainer.scheduleSidebarFreeSpaceRefresh(self)
	if self._sidebarFreeSpaceRefreshScheduled or self._sidebarFreeSpaceRefreshing then
		return
	end

	self._sidebarFreeSpaceRefreshScheduled = true

	addEvent(function()
		if self and not self:isDestroyed() and self._sidebarFreeSpaceRefreshScheduled then
			self._sidebarFreeSpaceRefreshScheduled = nil

			self:refreshSidebarFreeSpace()
		end
	end)
end

function UIMiniWindowContainer.refreshSidebarFreeSpace(self)
	if self._sidebarFreeSpaceRefreshing then
		return
	end

	self._sidebarFreeSpaceRefreshScheduled = nil
	self._sidebarFreeSpaceRefreshing = true

	local function finish()
		self._sidebarFreeSpaceRefreshing = nil
	end

	local filler = self._sidebarFreeSpaceWidget

	if not var_0_6(self) then
		if filler and not filler:isDestroyed() then
			filler:destroy()
		end

		self._sidebarFreeSpaceWidget = nil

		finish()

		return
	end

	local usedHeight = 0
	local children = self:getChildren()

	for i = 1, #children do
		local child = children[i]

		if child:isVisible() and not isSidebarFreeSpaceWidget(child) then
			usedHeight = usedHeight + child:getHeight()
		end
	end

	local availableHeight = self:getHeight() - self:getPaddingTop() - self:getPaddingBottom()
	local freeHeight = math.max(0, availableHeight - usedHeight)

	if freeHeight <= 0 then
		if filler and not filler:isDestroyed() then
			filler:hide()
			filler:setHeight(0)
		end

		finish()

		return
	end

	local filler = ensureSidebarFreeSpaceWidget(self)

	if filler:getParent() ~= self then
		self:addChild(filler)
	else
		self:moveChildToIndex(filler, self:getChildCount())
	end

	filler:setWidth(math.max(0, self:getWidth() - self:getPaddingLeft() - self:getPaddingRight()))
	filler:setHeight(freeHeight)
	filler:show()
	finish()
end

function UIMiniWindowContainer.fitAll(self, noRemoveChild)
	if not self:isVisible() then
		return
	end

	if self.ignoreFillAll then
		return
	end

	if not noRemoveChild then
		local children = self:getChildren()

		for i = #children, 1, -1 do
			if not isSidebarSystemWidget(children[i]) then
				noRemoveChild = children[i]

				break
			end
		end

		if not noRemoveChild then
			self:refreshSidebarFreeSpace()

			return
		end
	end

	local sumHeight = 0
	local children = self:getChildren()

	for i = 1, #children do
		if children[i]:isVisible() and not isSidebarSystemWidget(children[i]) then
			sumHeight = sumHeight + children[i]:getHeight()
		end
	end

	local selfHeight = self:getHeight() - (self:getPaddingTop() + self:getPaddingBottom())

	if sumHeight <= selfHeight then
		self:refreshSidebarFreeSpace()

		return
	end

	local removeChildren = {}
	local neededReduction = sumHeight - selfHeight

	if neededReduction > 0 then
		for i = #children, 1, -1 do
			if neededReduction <= 0 then
				break
			end

			local child = children[i]

			if child ~= noRemoveChild and not shouldManageSidebarFreeSpace(child) and child:isVisible() and child:isResizeable() then
				local curH = child:getHeight()
				local minH = child:getMinimumHeight()
				local avail = math.max(0, curH - minH)

				if avail > 0 then
					local reduceBy = math.min(avail, neededReduction)
					local newH = curH - reduceBy

					neededReduction = neededReduction - reduceBy

					if noRemoveChild then
						if child and not child:isDestroyed() then
							child:setHeight(newH)
						end
					else
						addEvent(function()
							if child and not child:isDestroyed() then
								child:setHeight(newH)
							end
						end)
					end
				end
			end
		end
	end

	if neededReduction > 0 and noRemoveChild and noRemoveChild:isResizeable() then
		local maximumHeight = selfHeight - (sumHeight - noRemoveChild:getHeight())

		if maximumHeight >= noRemoveChild:getMinimumHeight() then
			sumHeight = sumHeight - noRemoveChild:getHeight() + maximumHeight

			if noRemoveChild then
				if noRemoveChild and not noRemoveChild:isDestroyed() then
					noRemoveChild:setHeight(maximumHeight)
				end
			else
				addEvent(function()
					if noRemoveChild and not noRemoveChild:isDestroyed() then
						noRemoveChild:setHeight(maximumHeight)
					end
				end)
			end

			neededReduction = math.max(0, neededReduction - (sumHeight - selfHeight))
		end
	end

	if neededReduction > 0 then
		local lockerSearchWindow = self:getChildById("lockerSearchWindow")

		if lockerSearchWindow and lockerSearchWindow:isVisible() and modules.game_search_locker and type(modules.game_search_locker.relocateForSpace) == "function" and modules.game_search_locker.relocateForSpace(self) then
			self:refreshSidebarFreeSpace()

			return
		end
	end

	if neededReduction > 0 then
		for i = #children, 1, -1 do
			if sumHeight <= selfHeight then
				break
			end

			local child = children[i]

			if child ~= noRemoveChild and not shouldManageSidebarFreeSpace(child) and not child.save then
				sumHeight = sumHeight - child:getHeight()

				table.insert(removeChildren, child)
			end
		end

		for i = #children, 1, -1 do
			if sumHeight <= selfHeight then
				break
			end

			local child = children[i]

			if child ~= noRemoveChild and not shouldManageSidebarFreeSpace(child) and child:isVisible() then
				sumHeight = sumHeight - child:getHeight()

				table.insert(removeChildren, child)
			end
		end
	end

	for i = 1, #removeChildren do
		removeChildren[i]:close()
	end

	self:refreshSidebarFreeSpace()
end

function UIMiniWindowContainer.redistributeChildrenWidths(self)
	if not self.isHorizontalPanel then
		return
	end

	if self:isDestroyed() or not self:isVisible() then
		return
	end

	local children = self:getChildren()
	local visibleChildren = {}

	for i = 1, #children do
		if children[i]:isExplicitlyVisible() and not isSidebarSystemWidget(children[i]) then
			visibleChildren[#visibleChildren + 1] = children[i]
		end
	end

	local count = #visibleChildren

	if count == 0 then
		return
	end

	local availableWidth = self:getWidth() - self:getPaddingLeft() - self:getPaddingRight()

	if availableWidth <= 0 then
		return
	end

	local widthPerChild = math.floor(availableWidth / count)

	if widthPerChild <= 0 then
		return
	end

	for i = 1, count do
		visibleChildren[i]:setWidth(widthPerChild)
	end
end

function UIMiniWindowContainer.fits(self, child, minContentHeight, maxContentHeight)
	if self.ignoreFillAll then
		return 0
	end

	local containerPanel = child:getChildById("contentsPanel")
	local indispensableHeight = containerPanel:getMarginTop() + containerPanel:getMarginBottom() + containerPanel:getPaddingTop() + containerPanel:getPaddingBottom()
	local totalHeight = 0
	local children = self:getChildren()

	for i = 1, #children do
		if children[i]:isVisible() and not isSidebarSystemWidget(children[i]) then
			totalHeight = totalHeight + children[i]:getHeight()
		end
	end

	local available = self:getHeight() - (self:getPaddingTop() + self:getPaddingBottom()) - totalHeight

	if maxContentHeight > 0 and available >= maxContentHeight + indispensableHeight then
		return maxContentHeight + indispensableHeight
	elseif available >= minContentHeight + indispensableHeight then
		return available
	else
		return -1
	end
end

function UIMiniWindowContainer.onDrop(self, widget, mousePos)
	if self.onlyPhantomDrop and not widget.moveOnlyToMain then
		return true
	end

	if widget.moveOnlyToMain and not self.onlyPhantomDrop and (not widget.allowHorizontalDrop or not self.isHorizontalPanel) then
		return true
	end

	if widget.moveOnlyToSideBars and self.onlyPhantomDrop then
		return true
	end

	if widget.UIMiniWindowContainer then
		local oldParent = widget:getParent()

		if oldParent == self then
			return true
		end

		if oldParent then
			oldParent:removeChild(widget)
		end

		local placeholder = widget._sidebarDragPlaceholder

		if widget._fromSidebar and widget.oldParentDrag and widget.oldParentDrag ~= self then
			self:addChild(widget)
		elseif placeholder and not placeholder:isDestroyed() and placeholder:getParent() == self then
			local index = self:getChildIndex(placeholder)

			self:insertChild(index, widget)
		elseif widget.movedWidget then
			local index = self:getChildIndex(widget.movedWidget)

			self:insertChild(index + widget.movedIndex, widget)
		else
			self:addChild(widget)
		end

		local parentId = widget:getParent():getId()

		if widget:getId() == "botWindow" and modules.game_interface.isGameSidePanelId(parentId) then
			widget:getParent():setWidth(190)
		end

		if modules.game_containers and modules.game_containers.isContainerMiniWindow and modules.game_containers.isContainerMiniWindow(widget) and modules.game_containers.applyContainerContextLayout then
			modules.game_containers.applyContainerContextLayout(widget)
		end

		self:fitAll(widget)
		self:redistributeChildrenWidths()
		self:refreshSidebarFreeSpace()

		if oldParent and oldParent ~= self and not oldParent:isDestroyed() and oldParent:getClassName() == "UIMiniWindowContainer" and type(oldParent.refreshSidebarFreeSpace) == "function" then
			oldParent:refreshSidebarFreeSpace()
		end

		return true
	end
end

function UIMiniWindowContainer.swapInsert(self, widget, index)
	local oldParent = widget:getParent()
	local oldIndex = self:getChildIndex(widget)

	if oldParent == self and oldIndex ~= index then
		local oldWidget = self:getChildByIndex(index)

		if oldWidget then
			self:removeChild(oldWidget)
			self:insertChild(oldIndex, oldWidget)
		end

		self:removeChild(widget)
		self:insertChild(index, widget)
	end
end

local function isUsableWidget(w)
	if type(w) ~= "userdata" then
		return false
	end

	if type(w.isDestroyed) ~= "function" or w:isDestroyed() then
		return false
	end

	if type(w.getClassName) ~= "function" then
		return false
	end

	return true
end

local function safeInsertChild(container, index, widget)
	if not isUsableWidget(widget) then
		return false
	end

	if widget:getParent() == container then
		return true
	end

	local ok, err = pcall(container.insertChild, container, index, widget)

	if not ok then
		pdebug("UIMiniWindowContainer: insertChild failed for widget id=" .. tostring(widget.getId and widget:getId() or "?") .. " index=" .. tostring(index) .. ": " .. tostring(err))
	end

	return ok
end

function UIMiniWindowContainer.scheduleInsert(self, widget, index)
	if not isUsableWidget(widget) then
		return
	end

	if type(self.scheduledWidgets) ~= "table" then
		self.scheduledWidgets = {}
	end

	if type(index) ~= "number" then
		index = tonumber(index)

		if not index then
			return
		end
	end

	for nIndex, nWidget in pairs(self.scheduledWidgets) do
		if not isUsableWidget(nWidget) or nWidget == widget then
			self.scheduledWidgets[nIndex] = nil
		end
	end

	if index - 1 > self:getChildCount() then
		if self.scheduledWidgets[index] then
			pdebug("replacing scheduled widget id " .. widget:getId())
		end

		self.scheduledWidgets[index] = widget
	else
		local oldParent = widget:getParent()

		if oldParent ~= self then
			if oldParent then
				oldParent:removeChild(widget)

				if oldParent:getClassName() == "UIMiniWindowContainer" and type(oldParent.refreshSidebarFreeSpace) == "function" then
					oldParent:refreshSidebarFreeSpace()
				end
			end

			if not safeInsertChild(self, index, widget) then
				return
			end

			repeat
				local placed = false

				for nIndex, nWidget in pairs(self.scheduledWidgets) do
					if not isUsableWidget(nWidget) then
						pdebug("UIMiniWindowContainer: skipping invalid scheduled widget at index " .. tostring(nIndex) .. " (type=" .. type(nWidget) .. ")")

						self.scheduledWidgets[nIndex] = nil
					elseif nIndex - 1 <= self:getChildCount() then
						safeInsertChild(self, nIndex, nWidget)

						self.scheduledWidgets[nIndex] = nil
						placed = true

						break
					end
				end
			until not placed

			self:redistributeChildrenWidths()
			self:scheduleSidebarFreeSpaceRefresh()

			if widget.save and SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
				SidebarLayoutState.noteWidgetPlacement(widget)
			end
		end
	end
end

function UIMiniWindowContainer.order(self)
	for unusedValue, child in ipairs(self:getChildren()) do
		if child.miniIndex and child.miniLoaded == false then
			return
		end
	end

	local var_23_0 = {}

	for unusedValue, child in ipairs(self:getChildren()) do
		if child and child.save and child.miniIndex then
			var_23_0[#var_23_0 + 1] = child
		end
	end

	table.sort(var_23_0, function(arg_24_0, arg_24_1)
		return arg_24_0.miniIndex < arg_24_1.miniIndex
	end)

	for unusedValue, entry in ipairs(var_23_0) do
		local children = self:getChildren()
		local var_23_2 = 0
		local childCount = self:getChildCount()

		for index, iter_23_7 in ipairs(children) do
			if iter_23_7 and iter_23_7.save then
				var_23_2 = var_23_2 + 1

				if var_23_2 == entry.miniIndex then
					childCount = index

					break
				end
			end
		end

		if self:getChildIndex(entry) ~= childCount then
			pcall(self.moveChildToIndex, self, entry, childCount)
		end
	end
end

function UIMiniWindowContainer.saveChildren(self)
	local children = self:getChildren()
	local ignoreIndex = 0

	for i = 1, #children do
		if isSidebarSystemWidget(children[i]) then
			ignoreIndex = ignoreIndex + 1
		elseif children[i].save then
			children[i]:saveParentIndex(self:getId(), i - ignoreIndex)

			if SidebarLayoutState and SidebarLayoutState.noteWidgetPlacement then
				SidebarLayoutState.noteWidgetPlacement(children[i])
			end
		else
			ignoreIndex = ignoreIndex + 1
		end
	end
end
