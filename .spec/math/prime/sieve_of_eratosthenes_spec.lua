describe("Sieve of Eratosthenes", function()
	local sieve = require("math.prime.sieve_of_eratosthenes")
	local check_primality = require("math.prime.is_prime")
	it("works for small numbers", function()
		for n = 1, 5 do
			for number, is_prime in ipairs(sieve(n ^ 2 * 1000)) do
				assert.equal(check_primality(number), is_prime)
			end
		end
	end)
	it("yields the correct count for large numbers", function()
		local count = 0
		for _, is_prime in ipairs(sieve(1e6)) do
			if is_prime then
				count = count + 1
			end
		end
		assert.equal(78498, count)
	end)
end)
