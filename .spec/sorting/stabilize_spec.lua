describe("Sorting stabilization", function()
	local stabilize = require("sorting.stabilize")
	local heapsort = require("sorting.heapsort")
	local stabilized_heapsort = stabilize(heapsort)
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
		local list = { { 2, 1 }, { 2, 2 }, { 1, 3 }, { 1, 4 } }
		local copy = { unpack(list) }
		heapsort(list, comparator)
		assert.falsy(is_sorted(list, verifying_comparator))
		list = copy
		stabilized_heapsort(list, comparator)
		assert.truthy(is_sorted(list, verifying_comparator))
	end)

	it("should handle edge cases", function()
		local list = {}
		stabilized_heapsort(list)
		assert.same({}, list)
		list = { 1 }
		stabilized_heapsort(list)
		assert.same({ 1 }, list)
	end)

	it("should sort random lists", function()
		for _ = 1, 100 do
			local list = {}
			for index = 1, 100 do
				list[index] = { math.random(20), index }
			end
			stabilized_heapsort(list, comparator)
			assert.truthy(is_sorted(list, verifying_comparator))
		end
	end)
end)
