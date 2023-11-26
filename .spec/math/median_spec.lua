describe("median", function()
	local median = require("math.median")

	local function check(expected, nums)
		assert.equal(expected, median(nums))
		local shuffle = require("random.shuffle")
		for _ = 1, 2 * #nums do
			shuffle(nums)
			assert.equal(expected, median(nums))
		end
	end

	it("should handle general cases", function()
		check(1, { 1 })
		check(1.5, { 1, 2 })
		check(3, { 3, 1, 2, 5, 5 })
		check(2.5, { 2, 3, 1, 4 })
		check(0, { 11, 0, 0, 0, 0, 0, 0, 0, 10 })
		check(4, { 1, 2, 3, 4, 5, 6, 7 })
		check(4.5, { 1, 2, 3, 4, 5, 6, 7, 8 })
	end)

	it("should return nil for empty input", function()
		assert.equal(nil, median({}))
	end)

	it("should not change the input", function()
		local some_nums = { 4, 3, 5, 1 }
		median(some_nums)
		assert.same(some_nums, { 4, 3, 5, 1 })
	end)
end)
