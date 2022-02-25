local bst = {}

function bst.less_than(a, b)
	-- boolean indicating if a < b
	return a < b
end

function bst.new(less_than)
	return { less_than = less_than }
end

function bst:empty()
	return not self.root
end

function bst:get(key)
	local less_than = self.less_than
	local tree = self.root
	while tree do
		if less_than(key, tree.key) then
			tree = tree[true]
		elseif less_than(tree.key, key) then
			tree = tree[false]
		else -- neither smaller nor larger than the key => must be equal
			return tree.key
		end
	end
end

function bst:has(key)
	-- Check if nothing was returned. This also works for `nil` keys.
	return select("#", self:get(key)) > 0
end

-- adding keys multiple times is possible (multisets), but not guaranteed to work; it also has worst-case linear time
function bst:add(key)
	if self:empty() then
		self.root = { key = key }
		return
	end
	local less_than = self.less_than
	local tree = self.root
	while true do
		local is_smaller = less_than(key, tree.key)
		if tree[is_smaller] then
			tree = tree[is_smaller]
		else
			tree[is_smaller] = { key = key }
			break
		end
	end
end

function bst:remove(key)
	if self:empty() then
		return
	end
	local function remove(parent, side)
		local tree = parent[side]
		if not tree then
			return
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
	return remove(self, "root")
end

function bst:range(
	-- callback, called with key
	func,
	-- optional min value, inclusive
	from,
	-- optional max value, inclusive; if `to < from`, traverses in reverse (descending) order
	to
)
	local ascending, descending = self.less_than(from, to), self.less_than(to, from)
	if descending then
		from, to = to, from -- swap to & from so that from < to
	end
	local function range(tree)
		if not tree then
			return
		end

		local geq_from = (from == nil) or not self.less_than(tree.key, from)
		local leq_to = (to == nil) or not self.less_than(to, tree.key)

		if ascending then
			if geq_from then
				range(tree[true])
			end
		elseif leq_to then
			range(tree[false])
		end

		if geq_from and leq_to then
			func(tree.key)
		end

		if ascending then
			if leq_to then
				range(tree[false])
			end
		elseif geq_from then
			range(tree[true])
		end
	end
	range(self.root)
end

function bst:ascending(func)
	return self:range(func)
end

function bst:descending(func)
	local function traverse(tree)
		if not tree then
			return
		end
		traverse(tree[false])
		func(tree.key)
		traverse(tree[true])
	end
	traverse(self.root)
end

-- [post|pre|level]order have been omitted as they make little sense in the context of a sorted set implementation

return require("class")(bst)
