-- A simple naive reference implementation for a sorted set data structure.
-- Uses a sorted table ("array list"), providing fast (logarithmic time) queries, but slow (linear time) updates.
-- You will usually want to use a more advanced data structure such as a B-Tree for logarithmic time updates.

local binary_search = require("searches.binary_search")

local sorted_table = {}

function sorted_table.less_than(a, b)
	return a < b
end

function sorted_table.new(keys, less_than)
	keys = keys or {}
	keys.less_than = less_than
	return keys
end

function sorted_table:empty()
	return self[1] == nil
end

function sorted_table:clear()
	for i = 1, #self do
		self[i] = nil
	end
end

function sorted_table:copy()
	local keys = {}
	for i, v in ipairs(self) do
		keys[i] = v
	end
	return sorted_table.new(keys, self.less_than)
end

function sorted_table:find(key)
	local index = binary_search(self, key, self.less_than)
	return self[index] -- nil if index < 0
end

function sorted_table:min()
	return self[1]
end

function sorted_table:max()
	return self[#self]
end

function sorted_table:succ(key)
	if key == nil then
		return self:min()
	end
	local index = binary_search(self, key, self.less_than)
	if index < 0 then
		index = -index
	else
		index = index + 1
	end
	return self[index]
end

function sorted_table:pred(key)
	if key == nil then
		return self:max()
	end
	local index = math.abs(binary_search(self, key, self.less_than))
	return self[index - 1]
end

local function get_range_indices(self, from_key, to_key)
	local from_idx, to_idx
	if from_key then
		from_idx = math.abs(binary_search(self, from_key, self.less_than))
	else
		from_idx = 1
	end
	if to_key then
		to_idx = binary_search(self, to_key, self.less_than)
		if to_idx < 0 then
			to_idx = -to_idx - 1 -- note: may be 0
		end
	else
		to_idx = #self
	end
	return from_idx, to_idx
end

function sorted_table:range_ascending(from_key, to_key)
	local from_idx, to_idx = get_range_indices(self, from_key, to_key)
	if from_idx > to_idx then
		return function()
			return nil
		end -- empty iterator
	end
	local idx = from_idx
	return function()
		if idx > to_idx then
			return nil
		end
		local key = self[idx]
		idx = idx + 1
		return key
	end
end

function sorted_table:range_descending(from_key, to_key)
	local from_idx, to_idx = get_range_indices(self, from_key, to_key)
	if from_idx > to_idx then
		return function() end
	end
	local idx = to_idx
	return function()
		if idx < from_idx then
			return nil
		end
		local key = self[idx]
		idx = idx - 1
		return key
	end
end

local function inorder(self, asc)
	local i, di = 1, 1
	if not asc then
		i, di = #self, -1
	end
	return function()
		local key = self[i]
		if key == nil then
			return
		end
		i = i + di
		return key
	end
end

function sorted_table:ascending()
	return inorder(self, true)
end

function sorted_table:descending()
	return inorder(self, false)
end

function sorted_table:insert(key, upsert)
	local index = binary_search(self, key, self.less_than)
	if index > 0 then
		local old = self[index]
		if upsert then
			self[index] = key
		end
		return old
	end
	table.insert(self, -index, key)
	return nil
end

function sorted_table:remove(key)
	local index = binary_search(self, key, self.less_than)
	if index > 0 then
		return table.remove(self, index)
	end
	return nil
end

return require("class")(sorted_table, require("data_structures.sorted_set.sorted_set"))
