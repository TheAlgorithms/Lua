return function(
	-- list to be sorted in-place
	list,
	-- function(a, b) -> truthy value if a < b
	less_than
)
	less_than = less_than or function(a, b)
		return a < b
	end
	-- Merges two sorted lists; elements of a come before those of b
	local function merge(result, list, other_list)
		local result_index = 1
		local index = 1
		local other_index = 1
		while index <= #list and other_index <= #other_list do
			-- Compare "head" element, insert "winner"
			if less_than(other_list[other_index], list[index]) then
				result[result_index] = other_list[other_index]
				other_index = other_index + 1
			else
				result[result_index] = list[index]
				index = index + 1
			end
			result_index = result_index + 1
		end
		-- Add remaining elements of either list or other_list
		for offset = 0, #list - index do
			result[result_index + offset] = list[index + offset]
		end
		for offset = 0, #other_list - other_index do
			result[result_index + offset] = other_list[other_index + offset]
		end
	end

	local function mergesort(list_to_sort, lower_index, upper_index)
		if lower_index == upper_index then
			list_to_sort[1] = list[lower_index]
		end
		if lower_index >= upper_index then
			return
		end
		local middle_index = math.floor((upper_index + lower_index) / 2)

		local left = {}
		mergesort(left, lower_index, middle_index)
		local right = {}
		mergesort(right, middle_index + 1, upper_index)

		merge(list_to_sort, left, right)
	end
	mergesort(list, 1, #list)
end
