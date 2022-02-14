local function check_sort(sort, not_comparison_based)
	it("should handle edge cases", function()
		local list = {}
		sort(list)
		assert(next(list) == nil)
		list = { 1 }
		sort(list)
		assert(list[1] == 1)
	end)
	local function test_lists(less_than)
		for _ = 1, 100 do
			local list, copy = {}, {}
			for index = 1, 100 do
				list[index] = math.random(1e3)
				copy[index] = list[index]
			end
			-- Compare against table.sort
			table.sort(copy, less_than)
			sort(list, less_than)
			assert.same(copy, list)
		end
	end
	it("should sort random lists", function()
		test_lists()
	end)
	if not_comparison_based then
		return
	end
	it("should support custom less_than functions", function()
		test_lists(function(a, b)
			return -a < -b
		end)
		test_lists(function(a, b)
			return a > b
		end)
		test_lists(function(a, b)
			return 1 / a > 1 / b
		end)
	end)
end
describe("Heapsort", function()
	check_sort(require("sorting.heapsort"))
end)
describe("Mergesort", function()
	check_sort(require("sorting.mergesort"))
end)
describe("Quicksort", function()
	check_sort(require("sorting.quicksort")())
end)
describe("Selectionsort", function()
	check_sort(require("sorting.selectionsort"))
end)
describe("Insertionsort", function()
	check_sort(require("sorting.insertionsort"))
end)
describe("Bubblesort", function()
	check_sort(require("sorting.bubblesort"))
end)
describe("Radix Sort", function()
	local radixsort = require("sorting.radixsort")
	check_sort(radixsort(), true)
	check_sort(radixsort(2), true)
	check_sort(radixsort(1e3), true)
end)
