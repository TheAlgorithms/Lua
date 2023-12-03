-- Sieve of Eratosthenes
return function(
	n -- number
)
	assert(n > 0, "n must be positive")
	local is_prime = { false }
	for m = 2, n do -- mark as prime
		is_prime[m] = true
	end
	for m = 2, math.sqrt(n) do -- iterate possible primes
		if is_prime[m] then
			for l = m * m, n, m do -- iterate multiples
				is_prime[l] = false -- "cross out" composite
			end
		end
	end
	return is_prime -- list [m] = `true` if m is a prime, `false` otherwise for m in range 1 to n (inclusive)
end
