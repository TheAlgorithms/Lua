-- A treap is a binary search tree which additionally
-- fulfills the heap property for random attached weights.
-- It provides expected logarithmic time operations.
local treap = {}

function treap.new(keys, less_than)
	keys = keys or {}
	if #keys == 0 then
		return { less_than = less_than }
	end
	-- Simple "sink down" with links rather than indices into a table
	local function heapify_down(node)
		local min_weight_child = node[true] or node[false]
		if not min_weight_child then
			return
		end
		if node[true] and node[false] and node[false].weight < node[true].weight then
			min_weight_child = node[false]
		end
		if min_weight_child.weight < node.weight then
			node.weight, min_weight_child.weight = min_weight_child.weight, node.weight
			return heapify_down(min_weight_child)
		end
	end
	local function build(from, to)
		if to < from then
			return nil
		end
		local mid = math.floor((from + to) / 2)
		local node = {
			key = keys[mid],
			weight = math.random(),
			[true] = build(from, mid - 1),
			[false] = build(mid + 1, to),
		}
		heapify_down(node)
		return node
	end
	return { less_than = less_than, _root = build(1, #keys) }
end

function treap:copy()
	local function copy(node)
		if node == nil then
			return nil
		end
		return {
			key = node.key,
			weight = node.weight,
			[true] = copy(node[true]),
			[false] = copy(node[false]),
		}
	end
	return setmetatable({ less_than = self.less_than, _root = copy(self._root) }, getmetatable(self))
end

function treap:insert(key, upsert)
	local weight = math.random()
	local prev_key
	local function insert(node)
		if not node then
			return { key = key, weight = weight }
		end
		local lt = self.less_than(key, node.key)
		if not (lt or self.less_than(node.key, key)) then -- key "==" node.key
			prev_key = node.key
			if upsert then
				node.key = key
			end
			return node
		end
		local child = insert(node[lt])
		node[lt] = child
		if child.weight < node.weight then
			-- Rotate child up ("heapify up")
			node[lt], child[not lt] = child[not lt], node
			return child
		end
		return node
	end
	self._root = insert(self._root)
	return prev_key
end

function treap:remove(key)
	-- Remove an adjacent node in the sorted order and return it
	local function remove_adjacent(node)
		local lt = math.random() < 0.5 -- randomize which side we try first
		if not node[lt] then
			lt = not lt
		end
		local parent, side = node, lt
		node = assert(parent[side])
		while node[not lt] do
			parent, side = node, not lt
			node = parent[side]
		end
		parent[side] = node[lt] -- replace with only child (or just delete)
		return node
	end
	-- Uses tree rotations to do "sinking down" without violating the BST property
	local function heapify_down(node)
		if not (node[true] or node[false]) then
			return node -- leaf
		end
		local min_key
		if not node[true] then
			min_key = false
		elseif not node[false] then
			min_key = true
		elseif node[true].weight < node[false].weight then
			min_key = true
		else
			min_key = false
		end
		local child = node[min_key]
		if node.weight <= child.weight then
			return node
		end
		-- Tree rotation
		node[min_key] = child[not min_key]
		child[not min_key] = heapify_down(node)
		return child
	end
	local prev_key
	local function remove(node)
		if node == nil then
			return node
		end
		local lt = self.less_than(key, node.key)
		local eq = not (lt or self.less_than(node.key, key))
		if eq then
			prev_key = node.key
			if node[true] and node[false] then
				node.key = remove_adjacent(node).key
				return heapify_down(node)
			end
			-- replace with only child or nil; no heapify necessary
			return node[true] or node[false]
		end
		node[lt] = remove(node[lt])
		return node
	end
	self._root = remove(self._root)
	return prev_key
end

return require("class")(treap, require("data_structures.sorted_set.binary_search_tree"))
