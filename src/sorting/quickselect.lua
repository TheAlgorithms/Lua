local three_way_partition = require("sorting.three_way_partition")

-- Builder for a Quickselect function given a pivot choosing strategy
return function(
	-- `function(arr, less_than, quickselect) return function(from, to) return pivot_idx`
	-- where from <= pivot_idx <= to and `quickselect` is a `function(from, to, sort_idx)`;
	-- defaults to `function() return math.random end`
	choose_pivot_builder
)
	choose_pivot_builder = choose_pivot_builder or function()
		return math.random
	end
	-- Actual Quickselect function
	return function(
		-- unsorted table to select from; is permuted
		arr,
		-- index of the value to select if the table were sorted
		sort_idx,
		-- optional, defaults to `function(a, b) return a < b end`
		less_than,
		-- optional start index of a slice (default `1`)
		from,
		-- optional end index of a slice (default `#arr`)
		to
	)
		less_than = less_than or function(a, b)
			return a < b
		end
		from, to = from or 1, to or #arr
		assert(sort_idx >= 1 and sort_idx <= #arr and sort_idx == math.floor(sort_idx), "invalid index")
		local choose_pivot
		local function quickselect(from, to, sort_idx) -- luacheck: ignore
			if from == to then -- single element
				assert(sort_idx == 1)
				return from
			end
			-- Partition slice into three parts:
			-- 1. Values smaller than the pivot from `from` to `smaller_to`
			-- 2. Values equal to the pivot from `smaller_to + 1` to `larger_from - 1`
			-- 3. Values larger than the pivot from `larger_from` to `to`
			local pivot_val = arr[choose_pivot(from, to)]
			local smaller_to, larger_from = three_way_partition(arr, from, to, pivot_val, less_than)

			local abs_idx = sort_idx + from - 1 -- absolute index: offset by left bound
			-- Value at the index must be...
			if abs_idx <= smaller_to then -- ... in the first part
				return quickselect(from, smaller_to, sort_idx)
			end
			if abs_idx < larger_from then -- ... in the second part (equal values), return
				return abs_idx
			end
			-- ... in the third part
			local leq_count = larger_from - from
			return quickselect(larger_from, to, sort_idx - leq_count)
		end
		choose_pivot = choose_pivot_builder(arr, less_than, quickselect)
		return quickselect(from, to, sort_idx) -- index of the value in the array after the array has been permuted
	end
end
