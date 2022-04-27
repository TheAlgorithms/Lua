local function check_sort(sort, len, not_comparison_based)
	len = len or 100
	it("should handle edge cases", function()
		local list = {}
		sort(list)
		assert(next(list) == nil)
		list = { 1 }
		sort(list)
		assert(list[1] == 1)
	end)
	local function test_lists(less_than)
		for _ = 1, len do
			local list, copy = {}, {}
			for index = 1, len do
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
	local quicksort = require("sorting.quicksort")
	check_sort(quicksort()) -- default pivot picking strategy
	-- Pick last/first element as pivot; both strategy are efficient for the random lists used
	check_sort(quicksort(function(from)
		return from
	end))
	check_sort(quicksort(function(_, to)
		return to
	end))
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
describe("Radixsort", function()
	-- Test with multiple radii
	local radixsort = require("sorting.radixsort")
	check_sort(radixsort(), nil, true)
	check_sort(radixsort(2), nil, true)
	check_sort(radixsort(1e3), nil, true)
end)
describe("Bogosort", function()
	check_sort(require("sorting.bogosort"), 5)
end)
