-- Circular right shift ("rotation")
return function(
	n, -- uint53
	shift -- number from 0 to 53
)
	local lowest = n % 2 ^ shift
	return lowest * 2 ^ (53 - shift) + math.floor(n / 2 ^ shift)
end
