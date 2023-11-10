describe("Integer exponentiation", function()
	local intpow = require("math.intpow")
	it("should work for small numbers & exponents", function()
		for n = -1000, 1000 do
			for exp = -2, 5 do
				assert.equal(n ^ exp, intpow(n, exp))
			end
		end
	end)
	it("should work for large exponents", function()
		-- Powers of two don't suffer from float precision issues
		for i = 1, 100 do
			assert.equal(2 ^ i * intpow(2, -i), 1)
			assert.equal(2 ^ -i * intpow(2, i), 1)
		end
	end)
end)
