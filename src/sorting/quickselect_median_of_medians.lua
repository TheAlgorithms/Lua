local quickselect_builder = require("sorting.quickselect")

-- Quickselect, using median of medians as pivot strategy and thus guaranteeing linear time.
return quickselect_builder(function(arr, less_than, quickselect)
	-- Partition a slice of at most 5 elements, returning the index of the median after permuting it
	local function partition_5(from, to)
		-- Sort elements up to and including mid using a simple selectionsort
		local mid = math.floor((from + to) / 2)
		for i = from, mid do
			local min_idx, min_val = i, arr[i]
			for j = i + 1, to do
				if less_than(arr[j], min_val) then
					min_idx, min_val = j, arr[j]
				end
			end
			arr[i], arr[min_idx] = arr[min_idx], arr[i]
		end
		return mid -- index of the median
	end

	return function(from, to)
		if to - from < 5 then -- <= 5 elements
			return partition_5(from, to)
		end
		local medians_to = from -- build a slice of medians starting at `from`
		for i = from, to - 4, 5 do -- iterate over 5 element subslices
			local median_5 = partition_5(i, i + 4) -- find median
			-- Swap to the slice of medians
			arr[median_5], arr[medians_to] = arr[medians_to], arr[median_5]
			-- Extend the slice of medians
			medians_to = medians_to + 1
		end
		local rem = (from - to + 1) % 5 -- count of remaining elements
		if rem == 0 then -- no remaining elements
			medians_to = medians_to - 1 -- last index goes unused
		else -- deal with the remaining less than five elements
			local median_rem = partition_5(to - rem + 1, to) -- find median of remaining elements
			-- Swap to the slice of medians
			arr[median_rem], arr[medians_to] = arr[medians_to], arr[median_rem]
		end
		local medians_cnt = medians_to - from + 1
		local median_sorted_idx = math.ceil(medians_cnt / 2)
		return quickselect(from, medians_to, median_sorted_idx)
	end
end)
