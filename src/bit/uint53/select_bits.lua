return function(
	n, -- uint53
	from, -- index of the first bit to be selected (1-indexed), defaults to 1
	to -- index of the last bit to be selected (1-indexed), defaults to 53
)
	from, to = from or 1, to or 53
	return math.floor((n % 2 ^ to) / 2 ^ (from - 1))
end
