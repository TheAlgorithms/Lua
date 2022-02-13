return function(
	list,
	-- Value to be searched
	value,
	-- Whether the list is sorted
	sorted,
	-- Comparator
	less_than
)
	less_than = less_than or function(a, b)
		return a < b
	end
	for index, element in ipairs(list) do
		if less_than(value, element) then
			if sorted then
				-- Negative insertion index if the list is sorted and the value was not found
				return -index
			end
		elseif not less_than(element, value) then -- must be equal
			-- Index if found
			return index
		end
	end
	-- Negative insertion index after the last element
	-- Returned if the list is unsorted or the value is bigger than all values in the sorted list
	return -#list - 1
end
