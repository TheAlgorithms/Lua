describe("Sieve of Eratosthenes", function()
	local sieve = require("math.prime.sieve_of_eratosthenes")
	local check_primality = require("math.prime.is_prime")

	local function check_sieve(n)
		local sieve_result = sieve(n)
		assert.equal(n, #sieve_result)
		for number, is_prime in ipairs(sieve_result) do
			assert.equal(check_primality(number), is_prime)
		end
	end

	it("works for small numbers", function()
		for i = 1, 10 do
			check_sieve(i)
		end
		check_sieve(24)
		check_sieve(25)
		check_sieve(26)
		check_sieve(1000)
		check_sieve(4000)
		check_sieve(9000)
		check_sieve(16000)
		check_sieve(25000)
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
	it("should throw error when input is not positive", function()
		assert.has_error(function()
			sieve(0)
		end)
	end)
end)
