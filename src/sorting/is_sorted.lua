return function(
	list,
	-- function(a, b) -> truthy value if a < b
	less_than
)
	less_than = less_than or function(a, b)
		return a < b
	end
	for i = 2, #list do
		-- Check whether an element is smaller than it's predecessor;
		-- If all elements are less than or equal to their predecessor, the list must be sorted
		-- due to the transitivity of the comparison operator
		if less_than(list[i], list[i - 1]) then
			-- list is not sorted ascendingly
			return false
		end
	end
	-- list is sorted ascendingly
	return true
end
