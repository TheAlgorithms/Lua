return function(
	... -- any values implementing `<`
)
	local n_args = select("#", ...)
	assert(n_args > 0)
	local min = ...
	for i = 2, n_args do
		local candidate = select(i, ...)
		if candidate < min then
			min = candidate
		end
	end
	return min
end
