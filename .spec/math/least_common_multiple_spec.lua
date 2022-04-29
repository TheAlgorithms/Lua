describe("LCM", function()
	local lcm = require("math.least_common_multiple")
	it("should handle edge cases properly", function()
		-- Zero
		assert.equal(0, lcm(0, 0))
		assert.equal(0, lcm(1e6, 0))
		assert.equal(0, lcm(0, -1e6))
		-- Same number
		for _ = 1, 10 do
			local a = math.random(-1e3, 1e3)
			assert.equal(math.abs(a), lcm(a, a))
		end
	end)
	it("should handle negative numbers", function()
		assert.equal(7 * 11 * 33, lcm(-7 * 33, 11 * 33))
		assert.equal(7 * 11 * 33, lcm(7 * 33, -11 * 33))
		assert.equal(7 * 11 * 33, lcm(-7 * 33, -11 * 33))
	end)
	it("should return the LCM", function()
		-- Products of primes with an obvious GCD and thus obvious LCM
		assert.equal(17 * 23 * 7, lcm(7 * 17, 7 * 23))
		assert.equal(29 * 31 * 17, lcm(17 * 29, 17 * 31))
		assert.equal(101 * 67 * 67, lcm(67 * 101, 67 * 67))
	end)
end)
