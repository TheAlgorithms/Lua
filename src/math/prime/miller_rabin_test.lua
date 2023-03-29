local modpow = require("math.modpow")

-- Miller-Rabin primality test; nondeterministic variant
-- Be careful when using this with doubles as precision issues may lead to incorrect results
return function(
	n, -- number to test for primality; may not exceed (2^52)^.5 = 2^26 = 67108864 due to double limitations
	rounds -- rounds determine accuracy: probability that a composite is considered probably prime does not exceed 4^-k
)
	-- Handle edge cases
	if n == 1 then
		return false
	end
	if n % 2 == 0 then
		return n == 2
	end
	if n == 3 then
		return true
	end

	rounds = rounds or 100 -- decent default for a false positive probability < 1e-60

	-- Write n as d*2^r + 1
	local d = n - 1
	local r = 0
	while d % 2 == 0 do
		r = r + 1
		d = d / 2
	end

	for _ = 1, rounds do
		local a = math.random(2, n - 2)
		local x = modpow(a, d, n) -- a^d % n
		if x ~= 1 and x ~= n - 1 then
			local composite = true
			for _ = 1, rounds - 1 do
				x = x ^ 2 % n
				if x == n - 1 then
					composite = false
					break
				end
			end
			if composite then
				return false -- certainly not prime
			end
		end
	end

	return true -- likely prime (confidence based on rounds)
end
