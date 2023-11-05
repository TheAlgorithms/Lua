return function(
	x -- number
)
	if type(x) == "number" then
		return math.abs(x)
	end
	local mt = getmetatable(x)
	assert(mt and mt.__lt)
	if mt.__lt(x, 0) then
		return -x
	end
	return x
end
