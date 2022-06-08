describe("Miller-Rabin probabilistic primality test", function()
	local test_prime = require("math.prime.miller_rabin_test")
	it("works for small primes & composite numbers", function()
		local is_prime = require("math.prime.sieve_of_eratosthenes")(1e6)
		for number = 1, 100 do -- covers all edge cases
			assert.equal(is_prime[number], test_prime(number, 20))
		end
		for _ = 1, 1e5 do
			local number = math.random(101, 1e6)
			assert.equal(is_prime[number], test_prime(number, 20))
		end
	end)
	it("works for selected large primes", function()
		for _, prime in pairs({ 6199, 7867, 2946901, 39916801 }) do
			assert.truthy(test_prime(prime))
		end
	end)
	it("works for random composite numbers", function()
		for _ = 1, 1e3 do
			-- Care is taken to stay well within double (and int) bounds
			local composite = math.random(2 ^ 7, 2 ^ 13) * math.random(2 ^ 7, 2 ^ 13)
			assert.falsy(test_prime(composite))
		end
	end)
end)
