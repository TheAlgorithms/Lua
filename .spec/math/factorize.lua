describe("Prime factorization", function()
	local factorize = require("math.factorize")
	it("works for edge cases 0 and 1", function()
		assert.same({ [0] = 1 }, factorize(0))
		assert.same({ [1] = 1 }, factorize(1))
	end)
	it("works for a select few primes", function()
		for _, prime in pairs({ 3, 7, 11, 13, 5077, 53441 }) do
			assert.same({ [prime] = 1 }, factorize(prime))
		end
	end)
	it("works for powers of primes", function()
		for _, prime in pairs({ 2, 3, 5, 7 }) do
			for exponent = 2, 8 do
				assert.same({ [prime] = exponent }, factorize(prime ^ exponent))
			end
		end
	end)
	it("works for some products", function()
		assert.same({ [2] = 3, [5] = 1, [11] = 2, [13] = 1 }, factorize(2 ^ 3 * 5 * 11 ^ 2 * 13))
		assert.same({ [3] = 1, [7] = 2, [17] = 3, [19] = 4 }, factorize(3 * 7 ^ 2 * 17 ^ 3 * 19 ^ 4))
		assert.same({ [3] = 4, [7] = 3, [17] = 2, [19] = 1 }, factorize(3 ^ 4 * 7 ^ 3 * 17 ^ 2 * 19))
	end)
end)
