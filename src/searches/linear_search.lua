return function(
	list,
	-- Value to be searched
	value,
	-- Whether the list is sorted
	sorted
)
	for index, element in ipairs(list) do
		if element == value then
			-- Index if found
			return index
		elseif element > value and sorted then
			-- Negative insertion index if the list is sorted and the value was not found
			return -index
		end
	end
	-- Negative insertion index after the last element
	-- Returned if the list is unsorted or the value is bigger than all values in the sorted list
	return -#list - 1
end
