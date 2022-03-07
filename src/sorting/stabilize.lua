-- Stabilizes any sorting algorithm, using linear auxiliary space (for the indices) per sorting
return function(
	sort -- function(list, less_than)
)
	-- stabilized sorting function
	return function(list, less_than)
		less_than = less_than or function(a, b)
			return a < b
		end
		-- Build a list of indices
		local indices = {}
		for index = 1, #list do
			indices[index] = index
		end
		-- Sort the list of indices according to values; compare indices only if they have the same value
		sort(indices, function(index_a, index_b)
			if less_than(list[index_a], list[index_b]) then
				return true
			end
			if less_than(list[index_b], list[index_a]) then
				return false
			end
			return index_a < index_b
		end)
		-- Map indices to values
		for index = 1, #list do
			indices[index] = list[indices[index]]
		end
		-- Replace elements in original list (sorting is supposed to be in-place)
		for index = 1, #list do
			list[index] = indices[index]
		end
	end
end
