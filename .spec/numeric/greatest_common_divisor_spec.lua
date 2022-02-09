describe("GCD", function()
	local gcd = require("numeric.greatest_common_divisor")
	it("should handle edge cases properly", function()
		-- Zero
		assert.equals(1, gcd(0, 0))
		assert.equals(1, gcd(1e6, 0))
		assert.equals(1, gcd(0, -1e6))
		-- Same number
		for _ = 1, 10 do
			local a = math.random(-1e3, 1e3)
			assert.equals(math.abs(a), gcd(a, a))
		end
	end)
	it("should handle negative numbers", function()
		assert.equals(33, gcd(-7 * 33, 11 * 33))
		assert.equals(33, gcd(7 * 33, -11 * 33))
		assert.equals(33, gcd(-7 * 33, -11 * 33))
	end)
	local function naive_gcd(a, b)
		for i = math.max(a, b), 1, -1 do
			if a % i == 0 and b % i == 0 then
				return i
			end
		end
		return 1
	end
	it("should return the GCD", function()
		-- Products of primes with an obvious GCD
		assert.equals(7, gcd(7 * 17, 7 * 23))
		assert.equals(17, gcd(17 * 29, 17 * 31))
		assert.equals(67, gcd(67 * 101, 67 * 67))
		-- Test against a naive "brute force" implementation
		for _ = 1, 1e3 do
			local a, b = math.random(1e3), math.random(1e3)
			assert.equals(naive_gcd(a, b), gcd(a, b))
		end
	end)
end)
