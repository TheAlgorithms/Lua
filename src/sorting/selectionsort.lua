--! Selectionsort has quadratic time complexity and should not be used in practice
return function(
	-- list to be sorted in-place
	list,
	-- function(a, b) -> truthy value if a < b
	less_than
)
	less_than = less_than or function(a, b)
		return a < b
	end
	for index = 1, #list do
		local min_index = index
		for min_candidate_index = index + 1, #list do
			if less_than(list[min_candidate_index], list[min_index]) then
				min_index = min_candidate_index
			end
		end
		list[index], list[min_index] = list[min_index], list[index]
	end
end
