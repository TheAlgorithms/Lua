-- Arithmetic ("sticky") right shift: Vacant bits are filled with the MSB
return function(
	n, -- uint53
	shift -- number from 0 to 53
)
	local msb = math.floor(n / 2 ^ 52)
	local vacant_bits = 2 ^ 53 - 1 - (2 ^ (53 - shift) - 1) -- mask of the highest `shift` bits
	return msb * vacant_bits + math.floor(n / 2 ^ shift)
end
