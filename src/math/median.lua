-- Computes the median of the input list `nums`.
-- In this iplementantion the input array is sorted
-- and the "middle" value is returned.
return function(nums)
	if #nums == 0 then
		return nil
	end
	table.sort(nums)
	local size = #nums
	if size % 2 == 0 then
		return (nums[size / 2] + nums[size / 2 + 1]) / 2
	else
		return nums[(size + 1) / 2]
	end
end
