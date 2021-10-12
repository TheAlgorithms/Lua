return function(
	list,
	-- Value to be searched
	value
)
	local min, max = 1, #list
	while min <= max do
		local pivot = min + math.floor((max - min) / 2)
		local element = list[pivot]
		if value == element then
			-- Index if found
			return pivot
		elseif value > element then
			min = pivot + 1
		else
			assert(value < element, "invalid order operators for binary search")
			max = pivot - 1
		end
	end
	-- Negative insertion index if not found
	return -min
end
