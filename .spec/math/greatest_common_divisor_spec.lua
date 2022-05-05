describe("GCD", function()
	local gcd = require("math.greatest_common_divisor")
	it("should handle edge cases properly", function()
		-- Zero
		assert.equal(1, gcd(0, 0))
		assert.equal(1e6, gcd(1e6, 0))
		assert.equal(1e6, gcd(0, -1e6))
		-- Same number
		for _ = 1, 10 do
			local a = math.random(-1e3, 1e3)
			assert.equal(math.abs(a), gcd(a, a))
		end
	end)
	it("should handle negative numbers", function()
		assert.equal(33, gcd(-7 * 33, 11 * 33))
		assert.equal(33, gcd(7 * 33, -11 * 33))
		assert.equal(33, gcd(-7 * 33, -11 * 33))
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
		assert.equal(7, gcd(7 * 17, 7 * 23))
		assert.equal(17, gcd(17 * 29, 17 * 31))
		assert.equal(67, gcd(67 * 101, 67 * 67))
		-- Test against a naive "brute force" implementation
		for _ = 1, 1e3 do
			local a, b = math.random(1e3), math.random(1e3)
			assert.equal(naive_gcd(a, b), gcd(a, b))
		end
	end)
	it("should return Bezout's identity", function()
		local function test_bezout_identity(a, b)
			local div, x, y = gcd(a, b)
			assert.equal(div, a * x + b * y)
		end
		for _ = 1, 1e3 do
			test_bezout_identity(math.random(1e3), math.random(1e3))
		end
	end)
end)
