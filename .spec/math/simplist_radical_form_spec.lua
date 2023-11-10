describe("Simplist radical form", function()
	local srf = require("math.simplist_radical_form")
	local function test_srf(x, expected_coeff, expected_root_term)
		assert.same({ expected_coeff, expected_root_term }, { srf(x) })
	end
	it("handles edge cases properly", function()
		test_srf(0, 1, 0)
		test_srf(1, 1, 1)
	end)
	it("works for square numbers", function()
		for n = 1, 1e3 do
			test_srf(n * n, n, 1)
		end
	end)
	it("works for products of primes ppq", function()
		local primes = { 1, 3, 7, 11, 1013, 4903, 7919 }
		for _, p in ipairs(primes) do
			for _, q in ipairs(primes) do
				test_srf(p * p * q, p, q)
			end
		end
	end)
end)
