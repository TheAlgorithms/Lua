-- Sieve of Eratosthenes
return function(
	n -- number
)
	local is_prime = { false }
	for m = 2, n do -- mark as prime
		is_prime[m] = true
	end
	for m = 2, n / 2 do -- iterate possible primes
		if is_prime[m] then
			for l = 2 * m, n, m do -- iterate multiples
				is_prime[l] = false -- "cross out" composite
			end
		end
	end
	return is_prime -- list [m] = `true` if m is a prime, `false` otherwise for m in range 1 to n (inclusive)
end
