return function(
	-- function(lower_index, upper_index) -> pivot index
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
		local function quicksort(lower_index, upper_index)
			if lower_index >= upper_index then
				return
			end
			local pivot_index = choose_pivot(lower_index, upper_index)
			local pivot_value = list[pivot_index]
			-- Place pivot at last position in range
			list[pivot_index], list[upper_index] = list[upper_index], pivot_value
			-- Index to place the pivot at
			pivot_index = lower_index
			-- Partition
			for j = lower_index, upper_index - 1 do
				if not less_than(pivot_value, list[j]) then
					list[pivot_index], list[j] = list[j], list[pivot_index]
					pivot_index = pivot_index + 1
				end
			end
			-- Place pivot between numbers <= pivot (from lower_index to pivot_index - 1)
			-- and numbers >= pivot (from pivot_index to upper_index)
			list[pivot_index], list[upper_index] = list[upper_index], list[pivot_index]
			-- Sort larger interval first to ensure a worst-case logarithmic stack size (which equals space complexity)
			local lower_interval_size, upper_interval_size =
				pivot_index - 1 - lower_index, upper_index - pivot_index - 1
			if lower_interval_size > upper_interval_size then
				-- lower interval is larger, sort it first
				quicksort(lower_index, pivot_index - 1)
				return quicksort(pivot_index + 1, upper_index)
			end
			-- upper interval is larger, sort it first
			quicksort(pivot_index + 1, upper_index)
			return quicksort(lower_index, pivot_index - 1)
		end
		quicksort(1, #list)
	end
end
