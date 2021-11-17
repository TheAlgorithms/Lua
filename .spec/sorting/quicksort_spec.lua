describe("Quicksort", function()
	local is_sorted = require("sorting.is_sorted")
	local quicksort = require("sorting.quicksort")()
	it("should sort random lists", function()
		for _ = 1, 100 do
			local list = {}
			for index = 1, 1000 do
				list[index] = math.random(1, 1000)
			end
			quicksort(list)
			assert.truthy(is_sorted(list))
		end
	end)
end)
