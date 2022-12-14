local heap = {}
local metatable = { __index = heap }

function heap.less_than(a, b)
	return a < b
end

local function swap(self, i, j)
	self[i], self[j] = self[j], self[i]
end

local function heapify_down(self, index)
	local left_child = index * 2
	if left_child > #self then
		return
	end
	local smallest_child = left_child + 1 -- right child
	if smallest_child > #self or self.less_than(self[left_child], self[smallest_child]) then
		smallest_child = left_child
	end
	if self.less_than(self[smallest_child], self[index]) then
		swap(self, index, smallest_child)
		return heapify_down(self, smallest_child)
	end
end

local function heapify_up(self, index)
	if index == 1 then
		return
	end
	local parent = math.floor(index / 2)
	if self.less_than(self[index], self[parent]) then
		swap(self, index, parent)
		return heapify_up(self, parent)
	end
end

function heap.new(
	self, -- list to heapify, optional, defaults to the empty list
	less_than -- comparator, optional, defaults to `function(a, b) return a < b end`
)
	self = setmetatable(self or {}, metatable)
	self.less_than = less_than
	for i = math.floor(#self / 2), 1, -1 do -- iterate over all parents, from lower to higher levels...
		heapify_down(self, i) -- ... and heapify each.
	end
	return self
end

function heap:empty()
	return self[1] == nil
end

function heap:size()
	return #self
end

function heap:push(value)
	table.insert(self, value)
	heapify_up(self, #self)
end

function heap:top()
	return self[1]
end

function heap:pop()
	local value = self[1]
	self[1] = self[#self]
	local len = #self
	self[#self] = nil
	if self[1] then
		heapify_down(self, 1)
	end
	assert(not self[len])
	return value
end

return heap
