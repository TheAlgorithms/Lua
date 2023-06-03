-- TODO (...) move these to "utils"

local function range(from, to, step)
	step = step or 1
	local val = from - step
	return function()
		val = val + step
		if ((step < 0) and (val < to)) or ((step > 0) and (val > to)) then
			return nil
		end
		return val
	end
end

local function ivalues(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

local function wrap(iterator, inv_state, control_var)
	return function()
		control_var = iterator(inv_state, control_var)
		return control_var
	end
end

local function equals_iterator(it1, it2)
	local v1, v2
	repeat
		v1, v2 = it1(), it2()
		if v1 ~= v2 then
			return false
		end
	until not v1
	return true
end

local function assert_iter_eq(expected_wrapped_iterator, ...)
	assert(equals_iterator(expected_wrapped_iterator, wrap(...)))
end

local function assert_set_eq(s1, s2)
	assert_iter_eq(wrap(s1:ascending()), s2:ascending())
end

local function test_sorted_set(module, check_invariant)
	-- Wrap constructor & update functions to check invariants after each update
	local function new(...)
		local set = module.new(...)
		check_invariant(set)
		return set
	end
	local function wrap_update(update_name)
		local function process(set, ...)
			check_invariant(set)
			return ...
		end
		return function(set, ...)
			return process(set, set[update_name](set, ...))
		end
	end
	local clear, insert, remove = wrap_update("clear"), wrap_update("insert"), wrap_update("remove")
	local function random_set()
		local size = math.random(1, 100)
		local set = new()
		for _ = 1, size do
			insert(set, math.random())
		end
		return set
	end

	local function range_set(...)
		local t = {}
		for v in range(...) do
			table.insert(t, v)
		end
		return new(t)
	end
	it("can be built from a list", function()
		local list = {}
		for i = 1, 1e3 do
			list[i] = i
		end
		local set = module.new(list, nil)
		check_invariant(set)
		local expected_i = 1
		for i in set:ascending() do
			assert.equal(expected_i, i)
			expected_i = i + 1
		end
		assert.equal(#list + 1, expected_i)
		assert_iter_eq(range(1, 1e3), set:ascending())
	end)
	it("supports custom comparators", function()
		local list = { { 1 }, { 2 }, { 3 } }
		local set = module.new({}, function(a, b)
			return a[1] > b[1]
		end)
		for _, elem in ipairs(list) do
			set:insert(elem)
		end
		assert_iter_eq(ivalues(list), set:descending())
	end)
	it("empty", function()
		assert.equal(true, new():empty())
		assert.equal(false, new({ 42 }):empty())
	end)
	it("copy", function()
		local set = new({ 1, 2, 3, 4, 5, 6 })
		assert_set_eq(set, set:copy())
	end)
	describe("queries", function()
		it("min", function()
			assert.equal(nil, new():min())
			assert.equal(-42, new({ -42, 1, 2, 3, 4, 5 }):min())
		end)
		it("max", function()
			assert.equal(nil, new():max())
			assert.equal(42, new({ 1, 2, 3, 4, 5, 42 }):max())
		end)
		it("find", function()
			local from, to = 42, 101
			local set = range_set(from, to)
			for i in range(42, 101) do
				assert.equal(i, set:find(i))
				assert.equal(nil, set:find(i + 0.5))
			end
		end)
		it("has", function()
			assert.equal(true, new({ 42 }):has(42))
			assert.equal(false, new():has(42))
		end)
		local function test_iteration(asc_or_desc, succ_or_pred)
			it("can be (ab)used for inefficient iteration", function()
				for _ = 1, 10 do
					local set = random_set()
					assert_iter_eq(wrap(set[asc_or_desc](set)), wrap(set[succ_or_pred], set))
				end
			end)
		end
		describe("successor", function()
			test_iteration("ascending", "succ")
			it("works for values between values", function()
				local set = range_set(1, 100)
				for i = 1, 100 do
					assert.equal(i, set:succ(i - 0.5))
				end
				assert.equal(nil, set:succ(100.5))
			end)
		end)
		describe("predecessor", function()
			test_iteration("descending", "pred")
			it("works for values between values", function()
				local set = range_set(1, 100)
				for i = 1, 100 do
					assert.equal(i, set:pred(i + 0.5))
				end
				assert.equal(nil, set:pred(0.5))
			end)
		end)
	end)
	local n = 100
	describe("updates", function()
		it("clear", function()
			local set = new({ 1, 2, 3, 4, 5, 6 })
			clear(set)
			assert.equal(true, set:empty())
		end)
		describe("insert", function()
			local function insert_new(set, val)
				assert.equal(nil, set:find(val))
				insert(set, val)
				assert.equal(val, set:find(val))
			end
			it("ascending", function()
				local set = new()
				for i = 1, n do
					insert_new(set, i)
				end
				assert_iter_eq(range(1, n), set:ascending())
			end)
			it("descending", function()
				local set = new()
				for i = n, 1, -1 do
					insert_new(set, i)
				end
				assert_iter_eq(range(1, n), set:ascending())
			end)
			it("random", function()
				for _ = 1, 10 do
					local set = new()
					local list = {}
					local seen = {}
					for _ = 1, math.random(n) do
						local v = math.random(n)
						if seen[v] then
							insert(set, v)
							assert.equal(v, set:find(v))
						else
							insert_new(set, v)
							table.insert(list, v)
							seen[v] = true
						end
					end
					table.sort(list)
					assert_iter_eq(ivalues(list), set:ascending())
				end
			end)
			it("upserts & finds existing values", function()
				local set = new({}, function(a, b)
					return a[1] < b[1]
				end)
				local v2s = {}
				for i = 1, 100 do
					local v1, v2 = { i }, { i }
					assert.equal(nil, set:find(v1))
					insert(set, v1)
					assert.equal(v1, insert(set, v2, true))
					assert.equal(v2, set:find(v2))
					v2s[i] = v2
				end
				assert_iter_eq(ivalues(v2s), set:ascending())
			end)
		end)
		describe("remove", function()
			local function remove_existing(set, i)
				assert.equal(i, set:find(i))
				assert.equal(i, remove(set, i))
				assert.equal(nil, set:find(i))
			end
			local function test_removes(name, remove_iter, expect_iter)
				local set = range_set(1, n)
				it(name, function()
					for i in remove_iter do
						remove_existing(set, i)
					end
					assert_iter_eq(expect_iter, set:ascending())
				end)
			end
			describe("ascending", function()
				test_removes("all", range(1, n), function() end)
				test_removes("odd", range(1, n, 2), range(2, n, 2))
			end)
			describe("descending", function()
				test_removes("all", range(n, 1, -1), function() end)
				test_removes("odd", range(2 * math.ceil(n / 2) - 1, 1, -2), range(2, n, 2))
			end)
			it("is a no-op if a value is not in the set", function()
				local set = range_set(1, n)
				for i = 1, n, 2 do
					remove_existing(set, i)
				end
				for i = 1, n, 2 do
					assert.equal(nil, remove(set, i))
				end
				assert_iter_eq(range(2, n, 2), set:ascending())
			end)
			it("random order", function()
				local shuffle = require("random.shuffle")
				local t = {}
				for i = 1, n do
					t[i] = i
				end
				for _ = 1, 10 do
					local set = range_set(1, n)
					shuffle(t)
					for _, v in ipairs(t) do
						remove_existing(set, v)
					end
					assert(set:empty())
				end
			end)
		end)
	end)
	describe("iterators", function()
		local set = range_set(1, n)
		local function test_range_method(name, descending)
			local function test_range(from, to, pass_from, pass_to)
				assert_iter_eq(
					descending and range(to, from, -1) or range(from, to),
					set[name](set, pass_from, pass_to)
				)
			end
			it("empty interval", function()
				test_range(2, 1, 2, 1)
			end)
			it("all", function()
				assert_iter_eq(descending and wrap(set:descending()) or wrap(set:ascending()), set[name](set))
			end)
			it("both bounds", function()
				for _ = 1, n do
					local from = math.random(n)
					local to = math.random(from, n)
					test_range(from, to, from, to)
					test_range(from, to, from - 0.5, to + 0.5)
				end
			end)
			it("lower bound", function()
				for from = 1, n + 1 do
					test_range(from, n, from, nil)
					test_range(from, n, from - 0.5, nil)
				end
			end)
			it("upper bound", function()
				for to = 0, n do
					test_range(1, to, nil, to)
					test_range(1, to, nil, to + 0.5)
				end
			end)
		end
		describe("ascending range", function()
			test_range_method("range_ascending", false)
		end)
		describe("descending range", function()
			test_range_method("range_descending", true)
		end)
		it("ascending", function()
			assert_iter_eq(range(1, n), set:ascending())
		end)
		it("descending", function()
			assert_iter_eq(range(n, 1, -1), set:descending())
		end)
	end)
	describe("set operations", function()
		local function test_setop(name, inc_a_minus_b, inc_a_intersect_b, inc_b_minus_a)
			it(name:gsub("_", " "), function()
				local function random_nums(remainder_mod_3)
					local nums, seen = {}, {}
					for _ = 1, math.random(n) do
						local num = 3 * math.random(n) + remainder_mod_3
						if not seen[num] then
							seen[num] = true
							table.insert(nums, num)
						end
					end
					table.sort(nums)
					return nums
				end
				-- Construct sets of random numbers which are guaranteed to be disjunct through their remainders mod 3
				local a_minus_b, a_intersect_b, b_minus_a = random_nums(0), random_nums(1), random_nums(2)
				local a, b = new({ unpack(a_minus_b) }), new({ unpack(b_minus_a) })
				for _, v in ipairs(a_intersect_b) do
					a:insert(v)
					b:insert(v)
				end
				local c = a[name](a, b)
				local function check_inclusion(expected, list)
					for _, v in ipairs(list) do
						assert.equal(expected, c:has(v))
					end
				end
				check_inclusion(inc_a_minus_b, a_minus_b)
				check_inclusion(inc_a_intersect_b, a_intersect_b)
				check_inclusion(inc_b_minus_a, b_minus_a)
			end)
		end
		test_setop("union", true, true, true)
		test_setop("intersection", false, true, false)
		test_setop("difference", true, false, false)
		test_setop("symmetric_difference", true, false, true)
	end)
	--[[it("putting it together", function()
		local set = new()
		local function count()
			local c = 0
			for _ in set:ascending() do
				c = c + 1
			end
			return c
		end
		-- Insert random numbers
		local hash_set = {}
		for _ = 1, 100 do
			local x = math.random(1e6)
			if not set:has(x) then
				assert.falsy(hash_set[x])
				insert(set, x)
				assert.truthy(set:has(x))
				hash_set[x] = true
			end
		end
		-- Do range queries and compare against sorted list
		local sorted_list = {}
		for x in pairs(hash_set) do
			table.insert(sorted_list, x)
		end
		table.sort(sorted_list)
		assert.equal(#sorted_list, count())
		-- Iterate tree in descending order
		do
			local i = #sorted_list + 1
			assert_iter_eq(function()
				i = i - 1
				return sorted_list[i]
			end, set:descending())
			assert.equal(0, i)
		end
		local function test_range(from, to)
			-- Ascending
			do
				local i = from - 1
				assert_iter_eq(function()
					i = i + 1
					if i > to then
						return nil
					end
					return sorted_list[i]
				end, set:range_ascending(sorted_list[from], sorted_list[to]))
			end
			do
				local i = to + 1
				assert_iter_eq(function()
					i = i - 1
					if i < from then
						return nil
					end
					return sorted_list[i]
				end, set:range_descending(sorted_list[from], sorted_list[to]))
			end
		end
		for _ = 1, 100 do
			local i = math.random(#sorted_list)
			local j = math.random(i, #sorted_list)
			test_range(i, j)
		end
		for i = 1, #sorted_list do
			test_range(i, i)
		end
		-- Delete all numbers
		local c = #sorted_list
		for x in pairs(hash_set) do
			assert.truthy(set:has(x))
			assert.equal(x, set:find(x))
			assert.equal(x, remove(set, x))
			c = c - 1
			assert.equal(c, count())
			assert.falsy(set:has(x))
		end
		assert.truthy(set:empty())
	end)]]
end

local is_sorted = require("sorting.is_sorted")
do
	local btree = require("data_structures.sorted_set.btree")
	local function check_btree_invariant(tree)
		local order = tree.order
		local min_keys, max_keys = order - 1, 2 * order - 1
		local less_than = tree.less_than
		local leaf_depth
		-- Note: Assumes non-boolean-keys
		local function check_node(node, depth, min, max)
			local keys, children = node.keys, node.children
			if node ~= tree._root then
				assert(min_keys <= #keys and #keys <= max_keys, "key count out of range")
			elseif #keys == 0 then
				assert(not children, "empty root is not childfree")
			end
			assert(is_sorted(keys, less_than)) -- keys must be sorted
			-- Keys must be within interval (min, max), where both min & max are optional
			if min then
				assert(less_than(min, keys[1]))
			end
			if max then
				assert(less_than(keys[#keys], max))
			end
			if children then
				assert.equal(#keys + 1, #children)
				-- Recursively check all children
				for i, child in ipairs(children) do
					-- Keys to the left & right dictate boundaries, if present; otherwise just inherit parent boundaries
					check_node(child, depth + 1, keys[i - 1] or min, keys[i] or max)
				end
			else
				-- All leaves must have the same depth
				leaf_depth = leaf_depth or depth
				assert.equal(leaf_depth, depth)
			end
		end
		return check_node(tree._root, 0)
	end

	describe("B-Tree", function()
		local function test_order(name, order)
			describe(name, function()
				local btree_order = btree.order
				setup(function()
					btree.order = order
				end)
				test_sorted_set(btree, check_btree_invariant)
				teardown(function()
					btree.order = btree_order
				end)
			end)
		end
		test_order("1-3", 2)
		test_order("larger", 42)
		test_order("default", btree.order)
	end)
end

do
	local sorted_table = require("data_structures.sorted_set.sorted_table")
	local function check_sorted_table_invariant(tbl)
		assert(is_sorted(tbl, tbl.less_than))
	end
	describe("Sorted Table", function()
		test_sorted_set(sorted_table, check_sorted_table_invariant)
	end)
end

do
	local bst = require("data_structures.sorted_set.binary_search_tree")
	local function check_bst_invariant(tree)
		local function check(node, from, to)
			if node == nil then
				return
			end
			if from ~= nil then
				assert(tree.less_than(from, node.key))
			end
			if to ~= nil then
				assert(tree.less_than(node.key, to))
			end
			check(node[true], from, node.key)
			check(node[false], node.key, to)
		end
		check(tree._root)
	end
	describe("Binary Search Tree", function()
		test_sorted_set(bst, check_bst_invariant)
	end)
	do
		local treap = require("data_structures.sorted_set.treap")
		local function check_treap_invariant(tree)
			check_bst_invariant(tree)
			local function check(node, min_weight)
				if node == nil then
					return
				end
				assert(node.weight >= min_weight)
				check(node[true], node.weight)
				check(node[false], node.weight)
			end
			check(tree._root, -math.huge)
		end
		describe("Treap", function()
			test_sorted_set(treap, check_treap_invariant)
		end)
	end
end
