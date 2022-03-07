describe("Sorting stabilization", function()
	local stabilize = require("sorting.stabilize")
	local quicksort = require("sorting.quicksort")
	local stabilized_quicksort = stabilize(quicksort()) -- random quicksort
	local is_sorted = require("sorting.is_sorted")

	-- Sort by the first element (= value) of the pair
	local function comparator(a, b)
		return a[1] < b[1]
	end

	-- Verifies whether the sort is stable by checking results (stored as the second element of the pair)
	local function verifying_comparator(a, b)
		if a[1] == b[1] then
			return a[2] < b[2]
		end
		return a[1] < b[1]
	end

	it("should fail if not stabilized and work if stabilized", function()
		-- Inefficient but deterministic quicksort which can be used to ensure instable sorting
		local bad_quicksort = quicksort(function(i, _)
			return i
		end)
		local list = { { 1, 1 }, { 2, 2 }, { 1, 3 } }
		bad_quicksort(list, comparator)
		assert.falsy(is_sorted(list, verifying_comparator))
		list = { { 1, 1 }, { 2, 2 }, { 1, 3 } }
		stabilize(bad_quicksort)(list, comparator)
		assert.truthy(is_sorted(list, verifying_comparator))
	end)

	it("should handle edge cases", function()
		local list = {}
		stabilized_quicksort(list)
		assert.same({}, list)
		list = { 1 }
		stabilized_quicksort(list)
		assert.same({ 1 }, list)
	end)

	it("should sort random lists", function()
		for _ = 1, 100 do
			local list = {}
			for index = 1, 100 do
				list[index] = { math.random(20), index }
			end
			stabilized_quicksort(list, comparator)
			assert.truthy(is_sorted(list, verifying_comparator))
		end
	end)
end)
