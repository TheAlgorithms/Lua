describe("Primality test", function()
	local is_prime = require("math.prime.is_prime")
	it("works for primes", function()
		for _, prime in pairs({ 2, 3, 5, 7, 11, 1213, 5039, 7919 }) do
			assert.truthy(is_prime(prime))
		end
	end)
	it("works for composite numbers", function()
		for _ = 1, 1e3 do
			assert.falsy(is_prime(math.random(2, 1e3) * math.random(2, 1e3)))
		end
	end)
end)
