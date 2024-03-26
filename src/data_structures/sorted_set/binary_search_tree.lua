local bst = {}

function bst.new(keys, less_than)
	keys = keys or {}
	local function build(from, to)
		if from > to then
			return
		end
		local mid = math.floor((from + to) / 2)
		return {
			[true] = build(from, mid - 1),
			key = keys[mid],
			[false] = build(mid + 1, to),
		}
	end
	return { _root = build(1, #keys), less_than = less_than }
end

function bst:empty()
	return not self._root
end

function bst:clear()
	self._root = nil
end

function bst:copy()
	local function copy(node)
		if node == nil then
			return nil
		end
		return {
			key = node.key,
			[true] = copy(node[true]),
			[false] = copy(node[false]),
		}
	end
	return setmetatable({ less_than = self.less_than, _root = copy(self._root) }, getmetatable(self))
end

local function extremum_node(node, min)
	if not node then
		return nil
	end
	while node[min] do
		node = node[min]
	end
	return node
end

local function min_node(node)
	return extremum_node(node, true)
end

local function max_node(node)
	return extremum_node(node, false)
end

function bst:min()
	local node = min_node(self._root)
	return node and node.key
end

function bst:max()
	local node = max_node(self._root)
	return node and node.key
end

local function nilor(a, b)
	if a == nil then
		return b
	end
	return a
end

local function succ_node(self, key)
	local less_than = self.less_than
	local function succ(node)
		if not node then
			return nil
		end
		-- Search a successor in the appropriate subtree
		if less_than(key, node.key) then
			return nilor(succ(node[true]), node) -- default to ourselves as successor
		end
		if less_than(node.key, key) then
			return succ(node[false])
		end
		return min_node(node[false]) -- if equal, take the minimum of the larger subtree
	end
	return succ(self._root)
end

function bst:succ(key)
	if key == nil then
		return self:min()
	end
	local node = succ_node(self, key)
	return node and node.key
end

-- Analogous to `succ`
local function pred_node(self, key)
	local less_than = self.less_than
	local function pred(node)
		if not node then
			return nil
		end
		if less_than(key, node.key) then
			return pred(node[true])
		end
		if less_than(node.key, key) then
			return nilor(pred(node[false]), node)
		end
		return max_node(node[true])
	end
	return pred(self._root)
end

function bst:pred(key)
	if key == nil then
		return self:max()
	end
	local node = pred_node(self, key)
	return node and node.key
end

function bst:find(key)
	local less_than = self.less_than
	local node = self._root
	while node do
		if less_than(key, node.key) then
			node = node[true]
		elseif less_than(node.key, key) then
			node = node[false]
		else -- neither smaller nor larger than the key => must be equal
			return node.key
		end
	end
	return nil -- if not found
end

function bst:insert(key, upsert)
	if self:empty() then
		self._root = { key = key }
		return
	end
	local less_than = self.less_than
	local tree = self._root
	while true do
		local side
		if less_than(key, tree.key) then
			side = true
		elseif less_than(tree.key, key) then
			side = false
		else
			local prev_key = tree.key
			if upsert then
				tree.key = key
			end
			return prev_key
		end
		if not tree[side] then
			tree[side] = { key = key }
			return nil -- if a new key was inserted
		end
		tree = tree[side]
	end
end

function bst:remove(key)
	if self:empty() then
		return nil
	end
	local function remove(parent, side)
		local tree = parent[side]
		if not tree then
			return nil
		end
		local tree_key = tree.key
		if self.less_than(key, tree_key) then
			return remove(tree, true)
		end
		if self.less_than(tree_key, key) then
			return remove(tree, false)
		end
		-- equals
		if tree[true] then
			if tree[false] then -- two children
				-- pick the leftmost (lm) descendant to replace
				local lm_parent, lm_key = tree, false -- parent of & key to leftmost descendant
				while lm_parent[lm_key][true] do
					lm_parent, lm_key = lm_parent[lm_key], true
				end
				local lm_descendant = lm_parent[lm_key]
				tree.key = lm_descendant.key -- update key
				-- replace leftmost descendant with it's only child (if any)
				lm_parent[lm_key] = lm_descendant[false]
			else -- only child
				parent[side] = tree[true] -- replace with child
			end
		elseif tree[false] then -- only child
			parent[side] = tree[false] -- replace with child
		else -- leaf, simply delete parent reference to this node
			parent[side] = nil
		end
		return tree_key
	end
	return remove(self, "_root")
end

-- Terminate coroutine iteration. Throw an error if restarting the finished iterator is attempted.
local function terminate()
	coroutine.yield(nil)
	error("can not restart iterator")
end

local function range(self, min_key, max_key, asc)
	if min_key == nil and max_key == nil then
		if asc then
			return self:ascending()
		end
		return self:descending()
	end
	local less_than = self.less_than
	if min_key ~= nil and max_key ~= nil and less_than(max_key, min_key) then
		return function()
			return nil
		end
	end
	local from_key
	local to_node -- node up until which to iterate (exclusive)
	if asc then
		from_key = min_key
		to_node = max_key and succ_node(self, max_key)
	else
		from_key = max_key
		to_node = min_key and pred_node(self, min_key)
		-- Invert order
		local _less_than = less_than
		function less_than(a, b)
			return _less_than(b, a)
		end
	end
	local function iter(
		node,
		border -- whether this node is on the "border" of values which may be `< from`
	)
		if not node then
			return
		end
		if border then
			if less_than(from_key, node.key) then
				iter(node[asc], true)
				if node == to_node then
					return terminate()
				end
				coroutine.yield(node.key)
				return iter(node[not asc], false)
			end
			if node == to_node then
				return terminate()
			end
			if less_than(node.key, from_key) then
				return iter(node[not asc], true)
			end
			coroutine.yield(node.key)
			return iter(node[not asc], false)
		end
		-- Not on border => guaranteed to be `>= from`
		if node == to_node then
			iter(node[asc], false)
			return terminate()
		end
		iter(node[asc], false)
		coroutine.yield(node.key)
		return iter(node[not asc], false)
	end
	return coroutine.wrap(function()
		iter(self._root, from_key ~= nil)
		-- Lua would throw an error when the user attempts to resume a dead coroutine already,
		-- but this way we get to control the error message
		return terminate()
	end)
end

function bst:range_ascending(from, to)
	return range(self, from, to, true)
end

function bst:range_descending(from, to)
	return range(self, from, to, false)
end

local function inorder(self, asc)
	local function traverse(node)
		if not node then
			return nil
		end
		traverse(node[asc])
		coroutine.yield(node.key)
		traverse(node[not asc])
	end
	return coroutine.wrap(function()
		traverse(self)
		return terminate()
	end)
end

function bst:ascending()
	return inorder(self._root, true)
end

function bst:descending()
	return inorder(self._root, false)
end

return require("class")(bst, require("data_structures.sorted_set.sorted_set"))
