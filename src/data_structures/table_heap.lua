local heap = require("data_structures.heap")

-- Min. heap plus Lua (hash) table to allow updating the stored values
local table_heap = {}

--> empty, duplicate-free min heap with priority queue functionality
function table_heap.new(self, less_than)
	self = heap.new(self, less_than)
	local indices = {}
	for i, val in ipairs(self) do
		indices[val] = i
	end
	self.indices = indices
	return self
end

function table_heap:_swap(child_index, parent_index)
	local child_value, parent_value = self[child_index], self[parent_index]
	self.indices[parent_value], self.indices[child_value] = child_index, parent_index
	self[parent_index], self[child_index] = child_value, parent_value
end

function table_heap:_insert(val)
	table.insert(self, val)
	self.indices[val] = #self
end

function table_heap:_remove()
	local value = table.remove(self)
	self.indices[value] = nil
	return value
end

function table_heap:find_index(element)
	return self.indices[element]
end

-- Notify heap that the element has been decreased
function table_heap:decrease(element)
	self:_heapify_up(assert(self:find_index(element)))
end

-- Notify heap that the element has been increased
function table_heap:increase(element)
	self:_heapify_down(assert(self:find_index(element)))
end

-- Replaces the specified element - by identity - with the new element
function table_heap:replace(element, new_element)
	local index = assert(self:find_index(element))
	local new_index = self:find_index(new_element)
	if new_index ~= nil then
		assert(new_index == index, "new element is already a member")
		return
	end
	self[index] = new_element
	self.indices[element] = nil
	self.indices[new_element] = index
	if self.less_than(new_element, element) then
		self:_heapify_up(index)
	else
		self:_heapify_down(index)
	end
end

function table_heap:remove(element)
	local index = assert(self:find_index(element), "element not found")
	self.indices[element] = nil
	if index == #self then
		self[index] = nil
		return
	end
	local last_index = #self
	local last_element = self[last_index]
	self[last_index] = nil
	self[index] = last_element
	self.indices[last_element] = index
	if self.less_than(last_element, element) then
		self:_heapify_up(index)
	else
		self:_heapify_down(index)
	end
end

return require("class")(table_heap, heap)
