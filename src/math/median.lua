local quickselect = require("sorting.quickselect_median_of_medians")

-- Computes the median of the input list `nums`.
return function(nums)
	if #nums == 0 then
		return nil
	end
	if #nums == 1 then
		return nums[1]
	end
	local copy = {}
	for i = 1, #nums do
		copy[i] = nums[i]
	end
	local mid_pos = quickselect(copy, math.ceil(#copy / 2))
	if #nums % 2 == 1 then
		return copy[mid_pos]
	end
	local next_mid_pos = quickselect(copy, 1, nil, mid_pos + 1)
	return (copy[mid_pos] + copy[next_mid_pos]) / 2
end
