describe("Binary search", function()
	local binary_search = require("searches.binary_search")
	it("should return one index if found", function()
		assert.equal(2, binary_search({ 1, 2, 3 }, 2))
	end)
	it("should support a custom less_than function", function()
		assert.equal(
			1,
			binary_search({ 3, 2, 1 }, 3, function(a, b)
				return a > b
			end)
		)
	end)
	it("should return the negative insertion index if not found", function()
		assert.equal(-1, binary_search({ 2, 3, 4 }, 1))
		assert.equal(-4, binary_search({ 2, 3, 4 }, 5))
		assert.equal(-2, binary_search({ 2, 4, 6 }, 3))
	end)
	it("should return the correct index for unique elements", function()
		for _ = 1, 100 do
			local distinct_ints = { 1 }
			for i = 2, 1000 do
				distinct_ints[i] = distinct_ints[i - 1] + math.random(10)
			end
			local pick_index = math.random(1, #distinct_ints)
			assert.equal(pick_index, binary_search(distinct_ints, distinct_ints[pick_index]))
		end
	end)
end)
