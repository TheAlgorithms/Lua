local extended_gcd = require("math.greatest_common_divisor")

-- Computes the inverse of `a` modulo `m`, i.e.
-- finds a number `x` such that
-- (a * x) % m == 1 and 0 < x < m
return function(
	a, -- number
	m -- modulus
)
	assert(m > 0, "modulus must be positive")
	if m == 1 then
		return nil
	end
	local gcd, x, _ = extended_gcd(a % m, m)
	if gcd == 1 then
		-- Ensure that result is in (0, m)
		return x % m
	end
	return nil
end
