ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new(createFunc, resetFunc)
	return setmetatable({
		create = createFunc,
		reset = resetFunc,
		pool = {}
	}, ObjectPool)
end

function ObjectPool.get(self)
	return table.remove(self.pool) or self.create()
end

function ObjectPool.release(self, obj)
	if self.reset then
		self.reset(obj)
	end

	table.insert(self.pool, obj)
end

function ObjectPool.clear(self)
	self.pool = {}
end
