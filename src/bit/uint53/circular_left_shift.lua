-- Circular left shift ("rotation")
return function(
	n, -- uint53
	shift -- number from 0 to 53
)
	local highest_bits = math.floor(n / 2 ^ (53 - shift))
	return (n * 2 ^ shift) % 2 ^ 53 + highest_bits
end
