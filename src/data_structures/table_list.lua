-- Table based list, can handle up to 2^52 elements
-- See https://www.lua.org/pil/11.4.html

local list = {}

function list.new(
	self -- a list (table) using integer keys
)
	self._head_index = 0 -- zero-based head index simplifies one-based list indices
	self._length = #self
	return self
end

function list:len()
	-- list length
	return self._length
end

function list:in_bounds(index)
	-- boolean whether the index is in list bounds
	return index >= 1 and index <= self:len()
end

function list:get(
	index -- index from 1 (head) to length (tail)
)
	assert(self:in_bounds(index))
	return self[self._head_index + index]
end

function list:set(
	-- index from 1 (head) to length (tail)
	index,
	-- value to set
	value
)
	assert(self:in_bounds(index) and value ~= nil)
	self[self._head_index + index] = value
end

function list:ipairs()
	local index = 0
	-- iterator -> index, value
	return function()
		index = index + 1
		if index > self._length then
			return
		end
		return index, self[self._head_index + index]
	end
end

function list:rpairs()
	local index = self._length + 1
	-- reverse iterator (starting at tail) -> index, value
	return function()
		index = index - 1
		if index < 1 then
			return
		end
		return index, self[self._head_index + index]
	end
end

function list:push_tail(value)
	assert(value ~= nil)
	self._length = self._length + 1
	self[self._head_index + self._length] = value
end

function list:get_tail()
	return self[self._head_index + self._length]
end

function list:pop_tail()
	if self._length == 0 then
		return
	end
	local value = self:get_tail()
	self[self._head_index + self._length] = nil
	self._length = self._length - 1
	return value
end

function list:push_head(value)
	self[self._head_index] = value
	self._head_index = self._head_index - 1
	self._length = self._length + 1
end

function list:get_head()
	return self[self._head_index + 1]
end

function list:pop_head()
	if self._length == 0 then
		return
	end
	local value = self:get_head()
	self._head_index = self._head_index + 1
	self._length = self._length - 1
	self[self._head_index] = nil
	return value
end

return require("class")(list)
