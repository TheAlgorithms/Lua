describe("Fraction", function()
	local fraction = require("math.fraction")
	local frac = fraction.new

	local frac_strs = {
		[0 .. "/" .. 1] = frac(0, 1),
		[-12 .. "/" .. 11] = frac(-12, 11),
		[12 .. "/" .. 11] = frac(-12, -11),
	}

	local frac_floats = {
		{ base = 2, str = "0.1", val = frac(1, 2) },
		{ base = 2, str = "0.(10)", val = frac(2, 3) },
		{ base = nil, str = "3.(3)", val = frac(10, 3) }, -- test default base
		{ base = 10, str = "1.2(3)", val = frac(12, 10) + frac(1, 30) },
		{ base = 10, str = "1", val = frac(1, 1) },
		{ base = 10, str = "-2", val = frac(-2, 1) },
		{ base = 10, str = "-1.25", val = frac(-5, 4) },
		{ base = 10, str = "-1.3(51)", val = frac(-223, 165) },
		{ base = 16, str = "1.(45d17)", val = frac(42, 33) },
	}

	describe("construction", function()
		it("can be created from numerator & denominator", function()
			assert.same({ numerator = 0, denominator = 1 }, frac(0, 100))
			assert.same({ numerator = 33, denominator = 41 }, frac(33, 41))
		end)
		it("can be parsed from string", function()
			for str, val in pairs(frac_strs) do
				assert.equal(val, fraction.from_string(str))
			end
		end)
		it("can be parsed from floating point string", function()
			for _, float in pairs(frac_floats) do
				assert.equal(float.val, fraction.from_float_string(float.str, float.base))
			end
			assert.equal(frac(1, 1), fraction.from_float_string("0.(9)"))
			assert.equal(frac(1, 1), fraction.from_float_string("0.(1)", 2))
		end)
	end)
	describe("string conversion", function()
		it("tostring formats as numerator/denominator", function()
			for str, val in pairs(frac_strs) do
				assert.equal(str, tostring(val))
			end
		end)
		it("to floating point", function()
			for _, float in pairs(frac_floats) do
				assert.equal(float.str, float.val:to_float_string(float.base))
			end
		end)
	end)
	it("is shortened", function()
		assert.same({ numerator = 3, denominator = 41 * 7 }, frac(33, 41 * 77))
	end)
	it("always has the sign in the numerator", function()
		assert.same({ numerator = -1, denominator = 1 }, frac(-1, 1))
		assert.same({ numerator = -1, denominator = 1 }, frac(1, -1))
		assert.same({ numerator = 1, denominator = 1 }, frac(-1, -1))
		assert.same({ numerator = 1, denominator = 1 }, frac(1, 1))
	end)
	it("can be created from decimals", function()
		for n = 1, 100 do
			assert.same(frac(1, 2 ^ n), fraction.from_number(2 ^ -n))
		end
		-- Test using random mantissas; this has to be more limited
		-- as Lua 5.1 uses ints for its random
		for n = 1, 30 do
			local mantissa = math.random(1, 2 ^ n)
			assert.same(fraction.new(mantissa, 2 ^ n), fraction.from_number(mantissa * 2 ^ -n))
		end
		assert.same(frac(1, 3), fraction.from_number(1 / 3))
		-- TODO assert.same(fraction.new(3, 10), fraction.from_number(0.3))
	end)
	describe("arithmetic", function()
		it("minus", function()
			assert.same(frac(1, 2), -frac(1, -2))
			assert.same(frac(-1, 2), -frac(1, 2))
		end)
		it("addition", function()
			assert.same(frac(4, 15), frac(1, 5) + frac(1, 15))
			assert.same(frac(1, 2), frac(-1, 2) + 1)
		end)
		it("subtraction", function()
			assert.same(frac(2, 15), frac(1, 5) - frac(1, 15))
			assert.same(frac(-1, 2), frac(1, 2) - 1)
		end)
		it("multiplication", function()
			assert.same(frac(11 * 7, 3 * 5), frac(11, 3) * frac(7, 5))
			assert.same(frac(1, 1), frac(1, 2) * 2)
		end)
		it("modulo", function()
			assert.same(frac(55 % 21, 15), frac(11, 3) % frac(7, 5))
			assert.same(frac(1, 1), 3 % frac(2, 1))
		end)
		it("integer exponentiation", function()
			assert.same(frac(-100, 1), frac(-1, 100) ^ -1)
			assert.same(frac(2 ^ 100, 1), frac(2, 1) ^ 100)
		end)
	end)
	describe("comparison", function()
		local function srand(to) -- signed, nonzero random
			if math.random() < 0.5 then
				return -math.random(to)
			end
			return math.random(to)
		end
		for _ = 1, 1e3 do
			local a, b = frac(srand(1e3), srand(1e3)), frac(srand(1e3), srand(1e3))
			local a_num, b_num = a:to_number(), b:to_number()
			assert.truthy(a == a)
			assert.truthy(b == b)
			assert.equal(a_num == b_num, a == b)
			assert.equal(a_num < b_num, a < b)
			assert.equal(a_num > b_num, a > b)
			assert.equal(a_num <= b_num, a <= b)
			assert.equal(a_num >= b_num, a >= b)
		end
	end)
end)
