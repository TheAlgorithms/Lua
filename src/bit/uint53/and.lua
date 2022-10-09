-- Bitwise AND of two uint53s
return function(
	n, -- uint53
	m -- uint53
)
	local res = 0
	local bit = 1
	while n * m ~= 0 do -- while both are nonzero
		local n_bit, m_bit = n % 2, m % 2 -- extract LSB
		res = res + (n_bit * m_bit) * bit -- add AND of LSBs
		n, m = (n - n_bit) / 2, (m - m_bit) / 2 -- remove LSB from n & m
		bit = bit * 2 -- next bit
	end
	return res -- uint53: n AND m
end
