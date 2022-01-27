local bst = require("data_structures.sorted_set.binary_search_tree")

describe("Binary search tree", function()
	local tree = bst.new()
	-- Checks a BST
	local function check_bst(subtree)
		if not subtree then
			return
		end
		if subtree[true] then
			assert.truthy(subtree[true].key < subtree.key)
		end
		if subtree[false] then
			assert.truthy(subtree[false].key > subtree.key)
		end
	end
	local function count(tree)
		if not tree then
			return 0
		end
		if tree.root then
			return count(tree.root)
		end
		if not tree.key then
			return 0
		end
		return 1 + count(tree[true]) + count(tree[false])
	end
	check_bst(tree.root)
	-- Insert random numbers
	local hash_set = {}
	for _ = 1, 100 do
		local x = math.random(1, 1e6)
		if not tree:has(x) then
			assert.falsy(hash_set[x])
			tree:add(x)
			assert.truthy(tree:has(x))
			check_bst(tree.root)
			hash_set[x] = true
		end
	end
	-- Do range queries and compare against sorted list
	local sorted_list = {}
	for number in pairs(hash_set) do
		table.insert(sorted_list, number)
	end
	table.sort(sorted_list)
	assert.equal(#sorted_list, count(tree))
	-- Iterate tree in descending order
	local i = #sorted_list
	tree:descending(function(key)
		assert.equal(sorted_list[i], key)
		i = i - 1
	end)
	assert.equal(0, i)
	local function test_range(i, j)
		-- Ascending
		local k = i
		tree:range(function(key)
			assert.truthy(k <= j)
			assert.equal(sorted_list[k], key)
			k = k + 1
		end, sorted_list[i], sorted_list[j])
		assert.equal(j + 1, k)
		-- Descending
		tree:range(function(key)
			k = k - 1
			assert.truthy(k >= i)
			assert.equal(sorted_list[k], key)
		end, sorted_list[j], sorted_list[i])
		assert(i, k)
	end
	for _ = 1, 100 do
		local i = math.random(1, #sorted_list)
		local j = math.random(i, #sorted_list)
		test_range(i, j)
	end
	for i = 1, #sorted_list do
		test_range(i, i)
	end
	-- Delete all numbers
	local c = #sorted_list
	for x in pairs(hash_set) do
		assert.truthy(tree:has(x))
		assert.truthy(tree:remove(x))
		c = c - 1
		assert.equal(c, count(tree))
		check_bst(tree)
		assert.falsy(tree:has(x))
	end
	assert.truthy(bst:empty())
end)
