describe("Binary search", function()
	local binary_search = require("searches/binary_search")
	it("should return one index if found", function()
		assert.equals(binary_search({ 1, 2, 3 }, 2), 2)
	end)
	it("should return the negative insertion index if not found", function()
		assert.equals(binary_search({ 2, 3, 4 }, 1), -1)
		assert.equals(binary_search({ 2, 3, 4 }, 5), -4)
		assert.equals(binary_search({ 2, 4, 6 }, 3), -2)
	end)
	it("should return the correct index for unique elements", function()
		for _ = 1, 100 do
			local distinct_ints = { 1 }
			for i = 2, 1000 do
				distinct_ints[i] = distinct_ints[i - 1] + math.random(1, 10)
			end
			local pick_index = math.random(1, #distinct_ints)
			assert.equals(binary_search(distinct_ints, distinct_ints[pick_index]), pick_index)
		end
	end)
end)
