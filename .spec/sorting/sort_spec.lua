local is_sorted = require("sorting.is_sorted")
local function check_sort(sort)
	it("should sort random lists", function()
		for _ = 1, 100 do
			local list = {}
			for index = 1, 100 do
				list[index] = math.random(1, 1000)
			end
			sort(list)
			assert.truthy(is_sorted(list))
		end
	end)
end
describe("Quicksort", function()
	check_sort(require("sorting.quicksort")())
end)
describe("Selectionsort", function()
	check_sort(require("sorting.selectionsort"))
end)
