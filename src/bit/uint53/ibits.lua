local function inextbit(n, i)
	if n < 2 ^ i then
		return
	end -- only leading zeroes left
	local bit = math.floor((n % 2 ^ (i + 1)) / 2 ^ i)
	return i + 1, bit
end

-- Stateless iterator over the bits, from lowest (LSB) to highest (MSB);
-- does not iterate over leading zeroes, including a single zero
return function(
	n -- uint53
)
	-- Iterator
	return inextbit, n, 0
end
