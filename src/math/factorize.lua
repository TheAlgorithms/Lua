-- Prime-factorize a number. Runs in sqrt(n) time. "Naive" implementation as opposed to advanced "sieves".
return function(
	n -- integer to factorize
)
	local factors = {}
	for factor = 2, n ^ 0.5 do
		local count = 0
		while n % factor == 0 do
			count = count + 1
			n = n / factor
		end
		if count > 0 then
			factors[factor] = count
		end
	end
	if next(factors) == nil then -- no factors: number is a prime (or 0 or 1)
		factors[n] = 1
	end
	-- prime factorization as table `[factor] = count`; `{[1] = 1}` for `n=1`
	return factors
end
