-- B-trees are a generalization of binary search trees.
-- Providing logarithmic time updates and queries with little memory overhead and good cache locality,
-- B-trees are the go-to choice for a sorted set implementation, especially in a scripting language like Lua.

local binary_search = require("searches.binary_search")

local btree = {}
local metatable = { __index = btree }

-- Default order - experimentally tweak(ed) for optimal performance and memory consumption:
-- 1. Tables are usually grown using powers of two.
-- 2. An overfull node will have `2*order` keys and `2*order + 1` children.
--    Thus an exact power of two might lead to allocating 2x the space for a single child.
-- Tweak this either directly or "extend" this "class" to "override" it.
btree.order = 255

-- TODO (...) move these to utils

-- We could use the shorter (and sometimes faster) `{unpack(t, from, to)}` here,
-- but that would unnecessarily impose a limit of the stack size on `t`
local function slice(t, from, to)
	local res = {}
	local j = from
	for i = 1, to - from + 1 do
		res[i] = t[j]
		j = j + 1
	end
	return res
end

local function list_copy(t)
	local copy = {}
	for i = 1, #t do
		copy[i] = t[i]
	end
	return copy
end

-- Append all items from table `src` to `dst`
local function table_append_all(dst, src)
	for _, v in ipairs(src) do
		table.insert(dst, v)
	end
end

function btree.new(keys, less_than)
	-- TODO (?) reduce auxiliary space; support an iterator of keys instead of a list
	keys = keys or {}
	-- Construct the tree bottom-up, level by level
	local max_keys = 2 * btree.order - 1
	local children
	while #keys > max_keys do
		local next_keys, next_children = {}, {}
		local key_idx, child_idx = 1, 1
		local rem_keys = #keys
		local function add_child(n_keys)
			assert(n_keys > 0)
			local new_key_idx, new_child_idx = key_idx + n_keys - 1, child_idx + n_keys
			table.insert(next_children, {
				keys = slice(keys, key_idx, new_key_idx),
				children = children and slice(children, child_idx, new_child_idx),
			})
			new_key_idx = new_key_idx + 1
			if keys[new_key_idx] then -- not the last node?
				table.insert(next_keys, keys[new_key_idx])
				new_key_idx = new_key_idx + 1
				rem_keys = rem_keys - 1
			end
			key_idx, child_idx = new_key_idx, new_child_idx + 1
			rem_keys = rem_keys - n_keys
		end
		while rem_keys > 2 * max_keys do -- <=> more than 2 nodes left to create
			add_child(max_keys)
		end
		-- Divide the leftover keys evenly between the last two nodes:
		-- max_keys <= left_keys <= 2*max_keys => floor(left_keys)/2 >= min_keys
		add_child(math.floor(rem_keys / 2))
		add_child(rem_keys)
		assert(rem_keys == 0)
		keys, children = next_keys, next_children
	end
	return setmetatable({
		_root = {
			keys = keys,
			children = children,
		},
		less_than = less_than,
	}, metatable)
end

function btree:empty()
	return self._root.keys[1] == nil
end

function btree:clear()
	self._root = { keys = {} }
end

function btree:copy()
	local function copy(node)
		-- Copy node
		local res = { keys = list_copy(node.keys) }
		-- Recursively copy children
		if node.children then
			local children = {}
			for i, child in ipairs(node.children) do
				children[i] = copy(child)
			end
			res.children = children
		end
		return res
	end
	-- Preserve metatable
	return setmetatable({
		_root = copy(self._root),
		-- Use `rawget` to not copy the metatable-provided defaults here
		less_than = rawget(self, "less_than"),
	}, getmetatable(self))
end

function btree:find(key)
	local less_than = self.less_than
	local node = self._root
	repeat
		local i = binary_search(node.keys, key, less_than)
		if i > 0 then
			return node.keys[i] -- key if found
		end
		-- If inner node, continue search in appropriate child
		node = node.children and node.children[-i]
	until not node -- not found?
	return nil -- if not found
end

local function min(node)
	while node.children do
		node = node.children[1]
	end
	return node.keys[1] -- min key, or `nil` if empty
end

function btree:min()
	return min(self._root)
end

local function max(node)
	while node.children do
		node = node.children[#node.children]
	end
	return node.keys[#node.keys] -- max key, or `nil` if empty
end

function btree:max()
	return max(self._root)
end

function btree:succ(key)
	if key == nil then
		return self:min()
	end
	local less_than = self.less_than
	local function succ(node)
		local keys, children = node.keys, node.children
		local i = binary_search(keys, key, less_than)
		if not children then -- leaf?
			return keys[i > 0 and (i + 1) or -i] -- successor (note: nil if out of bounds)
		end
		if i > 0 then -- key found?
			return min(children[i + 1]) -- successor is minimum of next child
		end
		i = -i
		local got = succ(children[i]) -- search in appropriate child
		if got ~= nil then
			return got
		end
		return keys[i] -- note: may be nil
	end
	return succ(self._root) -- successor or `nil` if `key == self:max() or self:empty()`
end

function btree:pred(key)
	if key == nil then
		return self:max()
	end
	local less_than = self.less_than
	local function pred(node)
		local keys, children = node.keys, node.children
		local i = binary_search(keys, key, less_than)
		if not children then -- leaf?
			return keys[math.abs(i) - 1] -- predecessor (note: nil if out of bounds)
		end
		if i > 0 then -- key found?
			return max(children[i]) -- predecessor is maximum of previous child
		end
		i = -i
		local got = pred(children[i]) -- search in appropriate child
		if got ~= nil then
			return got
		end
		return keys[i - 1] -- note: may be nil
	end
	return pred(self._root) -- predecessor or `nil` if `key == self:min() or self:empty()`
end

function btree:range_ascending(min_key, max_key)
	if min_key == nil and max_key == nil then
		return self:ascending()
	end
	local less_than = self.less_than
	if min_key ~= nil and max_key ~= nil and less_than(max_key, min_key) then
		return function()
			return nil
		end -- empty iterator
	end
	-- First find the maximum node & corresponding index
	local max_node, max_i
	if max_key ~= nil then
		max_node = self._root
		while true do
			max_i = binary_search(max_node.keys, max_key, less_than)
			if max_i > 0 then -- key found?
				break
			end
			max_i = -max_i
			if max_node.children then
				max_node = assert(max_node.children[max_i])
			else
				max_i = max_i - 1 -- exclude the next larger key
				break
			end
		end
	end
	local function iter(
		node,
		border -- whether this node is on the "border" of values which may be `< from`
	)
		local i
		if border then
			i = binary_search(node.keys, min_key, less_than)
			if i > 0 then -- key found?
				coroutine.yield(node.keys[i])
				i = i + 1
				border = false
			else
				i = -i
			end
		else -- no lower bound
			i = 1
		end
		-- Do not use a `less_than(max_key, key)` check here as object comparisons may be expensive
		local to_i = node == max_node and max_i or #node.keys
		local children = node.children
		for j = i, to_i do
			if children and iter(children[j], border and j == i) then
				return true -- max reached
			end
			coroutine.yield(node.keys[j])
		end
		if node == max_node then
			return true
		end
		if children then
			return iter(children[#children], border and i == #children) -- max reached?
		end
	end
	return coroutine.wrap(function()
		iter(self._root, min_key ~= nil)
	end)
end

-- Analogous to `range_ascending`
function btree:range_descending(min_key, max_key)
	if min_key == nil and max_key == nil then
		return self:descending()
	end
	local less_than = self.less_than
	if min_key ~= nil and max_key ~= nil and less_than(max_key, min_key) then
		return function()
			return nil
		end -- empty iterator
	end
	-- First find the minimum node & corresponding index
	local min_node, min_i
	if min_key ~= nil then
		min_node = self._root
		while true do
			min_i = binary_search(min_node.keys, min_key, less_than)
			if min_i > 0 then -- key found?
				break
			end
			min_i = -min_i
			if min_node.children then
				min_node = assert(min_node.children[min_i])
			else
				break
			end
		end
	end
	local function iter(node, border)
		local i
		if border then
			i = binary_search(node.keys, max_key, less_than)
			if i > 0 then -- key found?
				coroutine.yield(node.keys[i])
				i = i - 1
				border = false
			else
				i = -i - 1 -- exclude the next smaller key
			end
		else -- no upper bound
			i = #node.keys
		end
		-- Do not use a `less_than(max_key, key)` check here as object comparisons may be expensive
		local to_i = node == min_node and min_i or 1
		local children = node.children
		for j = i, to_i, -1 do
			if children and iter(children[j + 1], border and j == i) then
				return true -- min reached
			end
			coroutine.yield(node.keys[j])
		end
		if node == min_node then
			return true
		end
		if children then
			return iter(children[1], border and i == 0) -- min reached?
		end
	end
	return coroutine.wrap(function()
		iter(self._root, max_key ~= nil)
	end)
end

function btree:ascending()
	local function inorder_ascending(node)
		for i = 1, #node.keys do
			if node.children then
				inorder_ascending(node.children[i])
			end
			coroutine.yield(node.keys[i])
		end
		if node.children then
			return inorder_ascending(node.children[#node.children])
		end
	end
	return coroutine.wrap(function()
		inorder_ascending(self._root)
	end)
end

function btree:descending()
	local function inorder_descending(node)
		for i = #node.keys, 1, -1 do
			if node.children then
				inorder_descending(node.children[i + 1])
			end
			coroutine.yield(node.keys[i])
		end
		if node.children then
			return inorder_descending(node.children[1])
		end
	end
	return coroutine.wrap(function()
		inorder_descending(self._root)
	end)
end

function btree:insert(key, upsert)
	local order = self.order
	local mid = order -- could use `order + 1` just as well
	local max_keys = 2 * order - 1
	local less_than = self.less_than
	local previous_key

	-- This takes an overfull node with `2 * order` keys and splits it
	-- TODO (...) this means there are `2 * order + 1` children,
	-- forcing us to choose `order` one lower than we'd like to
	-- to avoid Lua allocating twice the space for a single key
	-- By inserting the new key *after* splitting, we could avoid this
	local function split(node)
		local keys, children = node.keys, node.children
		local low, high = {}, {}
		local pivot
		low.keys, pivot, high.keys = slice(keys, 1, mid - 1), keys[mid], slice(keys, mid + 1, #keys)
		if children then
			low.children, high.children = slice(children, 1, mid), slice(children, mid + 1, #children)
		end
		return low, pivot, high
	end

	local function insert(node)
		local i = binary_search(node.keys, key, less_than)
		if i > 0 then -- key found?
			previous_key = node.keys[i]
			if upsert then -- update
				node.keys[i] = key
			end
			return
		end
		i = -i
		if node.children then -- not a leaf node?
			local low_child, pivot, high_child = insert(node.children[i]) -- insert in appropriate child
			if pivot then -- split happened?
				table.insert(node.keys, i, pivot)
				node.children[i] = low_child
				table.insert(node.children, i + 1, high_child)
			end
		else
			table.insert(node.keys, i, key)
		end
		if #node.keys > max_keys then -- split needed?
			return split(node)
		end
	end
	local low_child, pivot, high_child = insert(self._root)
	if pivot then -- split happened?
		self._root = {
			keys = { pivot },
			children = { low_child, high_child },
		}
	end
	return previous_key -- nil if there was no previous key
end

function btree:remove(key)
	local order, less_than = self.order, self.less_than
	local min_keys = order - 1
	local found

	-- Merge the children next to the i-th key (the child with the next smaller / larger values respectively)
	local function merge(node, i)
		local low_node, pivot, high_node = node.children[i], node.keys[i], node.children[i + 1]
		table.insert(low_node.keys, pivot)
		table_append_all(low_node.keys, high_node.keys)
		if low_node.children then
			table_append_all(low_node.children, assert(high_node.children))
		else
			assert(not high_node.children) -- same level => both may not have children
		end
		-- Remove pivot & high child
		table.remove(node.keys, i)
		table.remove(node.children, i + 1)
	end

	-- Repairs `node`'s `i`th child which has too few keys
	local function repair(node, i)
		local child = node.children[i]
		-- Try rotations
		local low_sibling = node.children[i - 1]
		if low_sibling and #low_sibling.keys > min_keys then
			-- Note: The key between child and low_sibling is at `i - 1`
			table.insert(child.keys, 1, node.keys[i - 1])
			node.keys[i - 1] = table.remove(low_sibling.keys)
			if child.children then
				table.insert(child.children, 1, table.remove(low_sibling.children))
			end
			return -- done rebalancing
		end
		local high_sibling = node.children[i + 1]
		if high_sibling and #high_sibling.keys > min_keys then
			table.insert(child.keys, node.keys[i])
			node.keys[i] = table.remove(high_sibling.keys, 1)
			if child.children then
				table.insert(child.children, table.remove(high_sibling.children, 1))
			end
			return -- done rebalancing
		end
		-- Merge
		if low_sibling then
			merge(node, i - 1)
		else
			assert(high_sibling)
			merge(node, i)
		end
		return #node.keys < min_keys -- do we have too few keys now?
	end
	local function delete_from(node)
		local i = binary_search(node.keys, key, less_than)
		if i > 0 then -- key found?
			found = node.keys[i]
			if node.children then -- inner node
				-- If we're in an inner node, we need to swap with a key in a leaf
				-- which is next to us in the sorted order; swap with the largest key
				local function delete_largest_key(descendant)
					if descendant.children then
						local j = #descendant.children
						return delete_largest_key(descendant.children[j]) and repair(descendant, j)
					else
						node.keys[i] = table.remove(descendant.keys)
						return #descendant.keys < min_keys -- do we have too few keys now?
					end
				end
				return delete_largest_key(node.children[i]) and repair(node, i) -- rotation/merge needed?
			else -- leaf
				table.remove(node.keys, i)
				return #node.keys < min_keys -- do we have too few keys now?
			end
		elseif node.children then
			assert(#node.children == #node.keys + 1)
			i = -i
			if delete_from(node.children[i]) then -- rotation/merge needed?
				return repair(node, i)
			end
		end
	end
	-- Start the actual deletion
	if delete_from(self._root) and #self._root.keys == 0 then
		-- Replace with only child (if we didn't become empty)
		if self._root.children then
			local only_child = self._root.children[1]
			self._root = only_child
		end
	end
	return found
end

return require("class")(btree, require("data_structures.sorted_set.sorted_set"))
