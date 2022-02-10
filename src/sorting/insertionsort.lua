--! Insertionsort has quadratic time complexity and should not be used in practice
return function(
	-- list to be sorted in-place
	list,
	-- function(a, b) -> truthy value if a < b
	less_than
)
	less_than = less_than or function(a, b)
		return a < b
	end
	for index = 2, #list do
		local value = list[index]
		-- Even if a binary search was used to determine the insertion index,
		-- time complexity would remain quadratic due to the series of swaps required for insertion
		local insertion_index = 1
		while less_than(list[insertion_index], value) and insertion_index < #list do
			insertion_index = insertion_index + 1
		end
		-- Shift all elements - starting at the insertion index - up by one
		for shift_index = index - 1, insertion_index, -1 do
			list[shift_index + 1] = list[shift_index]
		end
		list[insertion_index] = value
	end
end
