return function(
	... -- any values implementing `<`
)
	local n_args = select("#", ...)
	assert(n_args > 0)
	local max = ...
	for i = 2, n_args do
		local candidate = select(i, ...)
		if max < candidate then
			max = candidate
		end
	end
	return max
end
