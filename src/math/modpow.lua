-- Simple integer exponentiation by squaring mod some number
-- Apply mod after every operation to not run into issues with number size or precision
return function(
	base, -- Base number
	exp, -- Exponent, non-negative integer
	mod -- Modulus (number)
)
	if exp == 0 then
		assert(base ~= 0)
		return 1 % mod -- 1 % mod if exponent is 0
	end
	if base == 0 then
		return 0 -- 0 if base is 0
	end
	local res = 1 % mod
	while exp > 0 do -- loop invariant: `res * base^exp % mod = base^exp % mod`
		if exp % 2 == 1 then
			-- `res * base * base^(exp-1) % mod = base^exp % mod`
			res = (res * base) % mod
			exp = exp - 1
		else
			-- `res * (base^2)^(exp/2) % mod = base^exp % mod`
			base = (base * base) % mod
			exp = exp / 2
		end
	end
	return res
end
