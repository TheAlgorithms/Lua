describe("Unsigned integers", function()
	local uint = require("math.uint")
	local hex = uint(16) -- use a small base for testing

	local function randuint(uint_cls)
		uint_cls = uint_cls or hex
		local n_digits = math.random(0, 50)
		local digits = {}
		for i = 1, n_digits - 1 do
			digits[i] = math.random(0, uint_cls.base - 1)
		end
		if n_digits > 0 then
			digits[n_digits] = math.random(1, uint_cls.base - 1)
		end
		return uint_cls.from_digits(digits)
	end

	it("class tables are cached", function()
		assert.equal(hex, uint(16))
	end)

	describe("constructors & equality testing", function()
		assert.equal(hex.from_number(0), hex.zero())
		assert.equal(hex.from_number(1), hex.one())
		assert.equal(hex.from_number(0xF), hex.from_digits({ 0xF }))
		assert.equal(hex.from_number(hex.base), hex.from_digits({ 0, 1 }))
		assert.equal(hex.from_number(0xC0FFEE), hex.from_digits({ 0xE, 0xE, 0xF, 0xF, 0x0, 0xC }))
	end)

	it("copy (from)", function()
		local n = hex.from_number(42)
		local m = n:copy()
		m:increment()
		assert.equal(hex.from_number(42), n)
		assert.equal(hex.from_number(43), m)
		m:copy_from(n)
		assert.equal(hex.from_number(42), m)
	end)

	describe("to number", function()
		it("works for exactly representable uints", function()
			assert.equal(123456789, hex.from_number(123456789):to_number())
		end)
		it("returns nothing for not exactly representable uints if exact=true", function()
			assert.equal(nil, ((hex.from_number(2 ^ 53) + 1):to_number()))
		end)
		it("returns rounded uint if exact=false", function()
			assert.equal(2 ^ 53, (hex.from_number(2 ^ 53) + 1):to_number(false))
		end)
	end)

	describe("base conversions", function()
		local dec = uint(10)
		it("small numbers", function()
			assert.equal(hex.from_number(1234), dec.from_number(1234):convert_base_to(hex))
			for _ = 1, 100 do
				-- Workaround for a limitation of Lua random, which uses 32-bit ints internally
				local n = math.random(2 ^ 26) * 2 ^ 26 + math.random(0, 2 ^ 26 - 1)
				assert.equal(hex.from_number(n), dec.from_number(n):convert_base_to(hex))
				assert.equal(dec.from_number(n), hex.from_number(n):convert_base_to(dec))
			end
		end)
		it("round-trip random numbers", function()
			for _ = 1, 100 do
				local n, m = randuint(), randuint(dec)
				assert.equal(n, n:convert_base_to(dec):convert_base_to(hex))
				assert.equal(m, m:convert_base_to(hex):convert_base_to(dec))
			end
		end)
	end)

	describe("comparisons", function()
		local function test_compare(name, fn)
			local function rand_uint()
				return math.random(0, 2 ^ 30)
			end
			local function test(a, b)
				assert.equal(fn(a, b), fn(hex.from_number(a), hex.from_number(b)))
			end
			it(name, function()
				for _ = 1, 100 do
					local a = rand_uint()
					test(a, a)
					test(rand_uint(), rand_uint())
				end
			end)
		end
		test_compare("less than", function(a, b)
			return a < b
		end)
		test_compare("less than or equal", function(a, b)
			return a <= b
		end)
		test_compare("equal to", function(a, b)
			return a == b
		end)
		test_compare("compare", function(a, b)
			if type(a) == "number" then
				if a < b then
					return -1
				elseif b < a then
					return 1
				end
				return 0
			end
			return a:compare(b)
		end)
	end)

	describe("arithmetic", function()
		local function test_law(name, n_params, f)
			it(name, function()
				local params = {}
				for _ = 1, 100 do
					for i = 1, n_params do
						params[i] = randuint()
					end
					assert(f(unpack(params)))
				end
			end)
		end
		describe("addition", function()
			it("is consistent with Lua numbers", function()
				local function rand_uint()
					return math.random(0, 2 ^ 50)
				end
				local function test(a, b)
					assert.equal(hex.from_number(a + b), hex.from_number(a) + hex.from_number(b))
				end
				for _ = 1, 100 do
					local a = rand_uint()
					test(a, a)
					test(rand_uint(), 0)
					test(0, rand_uint())
					test(rand_uint(), rand_uint())
				end
			end)
			test_law("associativity", 3, function(a, b, c)
				return a + (b + c) == (a + b) + c
			end)
			test_law("commutativity", 2, function(a, b)
				return a + b == b + a
			end)
			test_law("neutral element", 1, function(a)
				return a + 0 == a
			end)
			test_law("a + b - b = a", 2, function(a, b)
				return a + b - b == a
			end)
		end)
		describe("subtraction", function()
			it("is consistent with Lua numbers", function()
				local function rand_uint()
					return math.random(0, 2 ^ 50)
				end
				local function test(a, b)
					assert.equal(hex.from_number(a - b), hex.from_number(a) - hex.from_number(b))
				end
				for _ = 1, 100 do
					local a = rand_uint()
					test(a, a)
					test(rand_uint(), 0)
					test(a + rand_uint(), a)
				end
			end)
			test_law("a - a = 0", 1, function(a)
				return a - a == hex.zero()
			end)
			test_law("a - 0 = a", 1, function(a)
				return a - 0 == a
			end)
		end)
		describe("multiplication", function()
			it("is consistent with Lua numbers", function()
				local function rand_uint()
					return math.random(0, 2 ^ 24)
				end
				local function test(a, b)
					assert.equal(hex.from_number(a * b), hex.from_number(a) * hex.from_number(b))
				end
				for _ = 1, 100 do
					local a = rand_uint()
					test(a, a)
					test(rand_uint(), 0)
					test(0, rand_uint())
					test(rand_uint(), 1)
					test(1, rand_uint())
					test(rand_uint(), rand_uint())
				end
			end)
			test_law("distributivity", 3, function(a, b, c)
				return a * (b + c) == a * b + a * c
			end)
			test_law("associativity", 3, function(a, b, c)
				return a * (b * c) == (a * b) * c
			end)
			test_law("commutativity", 2, function(a, b)
				return a * b == b * a
			end)
			test_law("neutral element", 1, function(a)
				return a * 1 == a
			end)
		end)
		describe("exponentiation", function()
			it("throws on 0^0", function()
				assert.has_error(function()
					return hex.zero() ^ hex.zero()
				end)
			end)
			it("0^n = 0", function()
				assert.equal(hex.zero(), hex.zero() ^ 42)
			end)
			it("1^n = 1", function()
				assert.equal(hex.one(), hex.one() ^ 42)
			end)
			it("supports small uint exponents", function()
				assert.equal(hex.from_number(13 ^ 7), 13 ^ hex.from_number(7))
			end)
			it("is consistent with naive implementation", function()
				for _ = 1, 10 do
					local base = randuint()
					local exp = math.random(1, 10)
					local pow = hex.one()
					for _ = 1, exp do
						pow = pow * base
					end
					assert.equal(pow, base ^ exp)
				end
			end)
		end)
	end)
	describe("updates", function()
		local function test_unary(initial, expected, update)
			local n = hex.from_number(initial)
			update(n)
			assert.equal(n, hex.from_number(expected))
		end
		describe("increment", function()
			it("without carry", function()
				test_unary(1234, 1235, hex.increment)
			end)
			it("with carry", function()
				test_unary(hex.base - 1, hex.base, hex.increment)
			end)
		end)
		describe("decrement", function()
			it("without carry", function()
				test_unary(1235, 1234, hex.decrement)
			end)
			it("with carry", function()
				test_unary(hex.base - 1, hex.base, hex.increment)
			end)
		end)
		local function test_binary(name, fn)
			it(name, function()
				for _ = 1, 100 do
					local n, m = randuint(), randuint()
					if name == "subtract" then
						n = n + m
					end
					local res = fn(n, m)
					n[name](n, m)
					assert.equal(res, n)
				end
			end)
		end
		test_binary("add", function(a, b)
			return a + b
		end)
		test_binary("subtract", function(a, b)
			return a - b
		end)
		test_binary("multiply", function(a, b)
			return a * b
		end)
	end)
end)
