-- Bitwise inclusive OR of two uint53s
return function(
	n, -- uint53
	m -- uint53
)
	local res = 0
	local bit = 1
	while n * m ~= 0 do -- while both are nonzero
		local n_bit, m_bit = n % 2, m % 2 -- extract LSBs
		-- n OR m for n, m in {0, 1}
		-- <=> (n + m) % 2 + (n and m)
		-- <=> (n + m) / (1 + n * m)
		-- <=> not ((not n) and (not m))
		-- <=> the below parenthesized expression, which is the most suitable of the above equivalent expressions
		res = res + (1 - ((1 - n_bit) * (1 - m_bit))) * bit -- add OR of LSBs
		n, m = (n - n_bit) / 2, (m - m_bit) / 2 -- remove LSB from n & m
		bit = bit * 2 -- next bit
	end
	-- What's left of n and/or m are/is zero => Keep remaining bits of the other
	return res + (n + m) * bit -- uint53: n OR m
end
