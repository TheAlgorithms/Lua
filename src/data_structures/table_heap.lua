-- Min heap plus Lua hash table to allow updating the stored values
local table_heap = {}

function table_heap.less_than(a, b)
	return a < b
end

--> empty, duplicate-free min heap with priority queue functionality
function table_heap.new(less_than)
	return { less_than = less_than, indices = {} }
end

local function swap(self, child_index, parent_index)
	local child_value, parent_value = self[child_index], self[parent_index]
	self.indices[parent_value], self.indices[child_value] = child_index, parent_index
	self[parent_index], self[child_index] = child_value, parent_value
end

local function heapify_up(self, index)
	if index == 1 then
		return
	end
	local parent_index = math.floor(index / 2)
	if self.less_than(self[index], self[parent_index]) then
		swap(self, index, parent_index)
		heapify_up(self, parent_index)
	end
end

local function heapify_down(self, index)
	local left_child = index * 2
	if left_child > #self then
		return
	end
	local smallest_child = left_child + 1
	if smallest_child > #self or self.less_than(self[left_child], self[smallest_child]) then
		smallest_child = left_child
	end
	if self.less_than(self[smallest_child], self[index]) then
		swap(self, smallest_child, index)
		heapify_down(self, smallest_child)
	end
end

function table_heap:push(value)
	table.insert(self, value)
	local last = #self
	self.indices[value] = last
	heapify_up(self, last)
end

function table_heap:top()
	return self[1]
end

function table_heap:pop()
	local value = self[1]
	self.indices[value] = nil
	local last = #self
	if last == 1 then
		self[1] = nil
		return value
	end
	self[1], self[last] = self[last], nil
	heapify_down(self, 1)
	return value
end

function table_heap:find_index(element)
	return self.indices[element]
end

-- Notify heap that the element has been decreased
function table_heap:decrease(element)
	heapify_up(self, assert(self:find_index(element)))
end

-- Notify heap that the element has been increased
function table_heap:increase(element)
	heapify_down(self, assert(self:find_index(element)))
end

-- Replaces the specified element - by identity - with the new element
function table_heap:replace(element, new_element)
	local index = assert(self:find_index(element))
	assert(self:find_index(new_element) == nil, "no duplicates allowed")
	self[index] = new_element
	self.indices[element] = nil
	self.indices[new_element] = index;
	(self.less_than(new_element, element) and heapify_up or heapify_down)(self, index)
end

function table_heap:remove(element)
	local index = assert(self:find_index(element), "element not found")
	self.indices[element] = nil
	if index == #self then
		self[index] = nil
	else
		local last_index = #self
		local last_element = self[last_index]
		self[last_index] = nil
		self[index] = last_element
		self.indices[last_element] = index;
		(self.less_than(last_element, element) and heapify_up or heapify_down)(self, index)
	end
end

return require("class")(table_heap)
