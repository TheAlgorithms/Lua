local function check_sort(sort)
	it("should handle edge cases", function()
		local list = {}
		sort(list)
		assert(next(list) == nil)
		list = { 1 }
		sort(list)
		assert(list[1] == 1)
	end)
	it("should sort random lists", function()
		for _ = 1, 100 do
			local list, copy = {}, {}
			for index = 1, 100 do
				list[index] = math.random(1, 1000)
				copy[index] = list[index]
			end
			-- Compare against table.sort
			table.sort(copy)
			sort(list)
			assert.same(copy, list)
		end
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
describe("Radix Sort", function()
	check_sort(require("sorting.radixsort")())
end)
