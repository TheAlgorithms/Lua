local function modpow(base, exp, mod)
	if exp == 1 then
		return base % mod
	end
	if exp % 2 == 1 then
		return (modpow(base, exp - 1, mod) * base) % mod
	end
	return modpow(base, exp / 2, mod) ^ 2 % mod
end

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
	return modpow(base, exp, mod) -- base^exp % mod otherwise
end
