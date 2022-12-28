describe("Segment tree", function()
	local segment_tree = require("data_structures.segment_tree")
	local function concat(...)
		return table.concat({ ... })
	end -- concatenation is an associative operation
	it("selected test cases", function()
		local strs = { "abc", "xxx", "ghi", "xxx", "mno" } -- "xxx" marks entries to be replaced
		local tree = segment_tree.new(concat, strs)
		-- Update 2nd element
		strs[2] = "def"
		tree:update(2, strs[2])
		assert.equal(strs[1] .. strs[2] .. strs[3], tree:aggregate(1, 3))
		-- Update 4th element & test
		strs[4] = "jkl"
		tree:update(4, strs[4])
		assert.equal(strs[3] .. strs[4] .. strs[5], tree:aggregate(3, 5))

		assert.equal(table.concat(strs), tree:aggregate())
	end)
	it("random test cases", function()
		local function random_num()
			return math.random(-1e3, 1e3)
		end
		local function random_str()
			return ("%x"):format(math.random(1, 2 ^ 30))
		end
		-- Try multiple associative operators with associated functions for generating random values
		for variadic_op, random_value in pairs({
			[math.min] = random_num,
			[math.max] = random_num,
			[concat] = random_str,
		}) do
			local vals = {}
			local len = math.random(10, 1e3)
			for i = 1, len do
				vals[i] = random_value()
			end
			local tree = segment_tree.new(variadic_op, vals)
			for _ = 1, len do
				-- Pick a random range
				local from = math.random(len)
				local to = math.random(from, len)
				-- Check that naive linear-time aggregation yields the same result
				assert.equal(variadic_op(unpack(vals, from, to)), tree:aggregate(from, to))
				-- Mutate a random value
				local mut = math.random(len)
				vals[mut] = random_value()
				tree:update(mut, vals[mut])
			end
		end
	end)
end)
