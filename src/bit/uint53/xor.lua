-- Bitwise XOR (exclusive OR) of two uint53s
return function(
	n, -- uint53
	m -- uint53
)
	local res = 0
	local bit = 1
	while n * m ~= 0 do -- while both are nonzero
		local n_bit, m_bit = n % 2, m % 2 -- extract LSBs
		-- XOR is bitwise addition mod 2
		res = res + ((n_bit + m_bit) % 2) * bit -- add XOR of LSBs
		n, m = (n - n_bit) / 2, (m - m_bit) / 2 -- remove LSB from n & m
		bit = bit * 2 -- next bit
	end
	-- What's left of n and/or m are/is zero => Keep remaining bits of the other
	return res + (n + m) * bit -- uint53: n XOR m
end
