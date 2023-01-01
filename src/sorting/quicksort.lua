local three_way_partition = require("sorting.three_way_partition")

return function(
	-- function(from, to) -> pivot index
	choose_pivot
)
	choose_pivot = choose_pivot or math.random
	return function(
		-- list to be sorted in-place
		list,
		-- function(a, b) -> truthy value if a < b
		less_than
	)
		less_than = less_than or function(a, b)
			return a < b
		end
		local function quicksort(from, to)
			if from >= to then
				return
			end
			-- Partition slice into three parts:
			-- 1. Values smaller than the pivot from `from` to `smaller_to`
			-- 2. Values equal to the pivot from `smaller_to + 1` to `larger_from - 1`
			-- 3. Values larger than the pivot from `larger_from` to `to`
			-- Subsequent recursive calls only have to sort part (1) and (3), never (2).
			local pivot_val = list[choose_pivot(from, to)]
			local smaller_to, larger_from = three_way_partition(list, from, to, pivot_val, less_than)
			-- Sort smaller interval first to ensure a worst-case logarithmic stack size (which equals space complexity)
			if smaller_to - from < to - larger_from then
				quicksort(from, smaller_to) -- lower interval is smaller, sort it first
				return quicksort(larger_from, to) -- note: tail call
			end
			quicksort(larger_from, to) -- upper interval is smaller, sort it first
			return quicksort(from, smaller_to) -- note: tail call
		end
		quicksort(1, #list)
	end
end
