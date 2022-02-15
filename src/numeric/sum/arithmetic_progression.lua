-- Based on the gaussian sum formula
return function(
	from, -- inclusive lower bound
	to, -- inclusive upper bound
	step -- step between values
)
	if from > to then
		assert(step < 0, "empty interval")
	end
	step = step or 1
	local count = math.floor((to - from) / step)
	local last = from + count * step
	-- sum of numbers from `from` to `to` with step `step`
	return (count + 1) * (from + last) / 2
end
