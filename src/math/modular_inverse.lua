--- computes the inverse of a modulo m, i.e.
--- finds number x such that
--- (a * x) % m == 1 and 0 < x < m
return function(
	a, -- number
	m -- modulus
)
	if m <= 0 then
		error("Modulus m = " .. m .. " must be positive.")
	end
	local gcd_fun = require("math.greatest_common_divisor")
	local gcd, x, _ = gcd_fun(a % m, m)
	if a ~= 0 and gcd == 1 then
		--- enure that result is in (0, m)
		return x % m
	end
	return nil
end
