Circle = {}
Circle.__index = Circle

function Circle.new(centerX, centerY, radius)
	local self = setmetatable({}, Circle)

	self._centerX = centerX
	self._centerY = centerY
	self._radius = radius

	return self
end

function Circle.inArea(self, point)
	local dx = point.x - self._centerX
	local dy = point.y - self._centerY

	return dx * dx + dy * dy <= self._radius * self._radius
end

function Circle.divideIntoSlices(self, n)
	local slices = {}
	local angleStep = 2 * math.pi / n

	for i = 0, n - 1 do
		local angle = i * angleStep
		local x = self._centerX + self._radius * math.cos(angle)
		local y = self._centerY + self._radius * math.sin(angle)

		table.insert(slices, {
			x = x,
			y = y
		})
	end

	return slices
end

function Circle.isPointInSlice(self, point, sliceIndex, totalSlices)
	local dx = point.x - self._centerX
	local dy = point.y - self._centerY

	if dx * dx + dy * dy > self._radius * self._radius then
		return false
	end

	local angleStep = 2 * math.pi / totalSlices
	local startAngle = math.atan2(dy, dx)

	if startAngle < 0 then
		startAngle = startAngle + 2 * math.pi
	end

	local distanceSquared = math.floor(startAngle / angleStep)

	if totalSlices <= distanceSquared then
		distanceSquared = totalSlices - 1
	end

	return distanceSquared == sliceIndex
end
