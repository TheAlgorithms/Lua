local ones = 2 ^ 53 - 1

local function b(str)
	return tonumber(str, 2)
end

local function rand_uint53()
	-- HACK Lua's random uses (usually 32-bit) integers in its implementation,
	-- thus we need two calls with smaller limits; using floats would not work,
	-- because that would only give us 32 bits of randomness as well
	return math.random(0, 2 ^ 26 - 1) + 2 ^ 26 * math.random(0, 2 ^ 27)
end

local function test_equation(name, func)
	it(name, function()
		for _ = 1, 1e3 do
			assert.equal(func(rand_uint53()))
		end
	end)
end

local function is_commutative(func)
	it("is commutative", function()
		for _ = 1, 1e3 do
			local n, m = rand_uint53(), rand_uint53()
			assert.equal(func(n, m), func(m, n))
		end
	end)
end

local function is_associative(func)
	it("is associative", function()
		for _ = 1, 1e3 do
			local n, m, l = rand_uint53(), rand_uint53(), rand_uint53()
			assert.equal(func(n, func(m, l)), func(func(n, m), l))
		end
	end)
end

describe("uint53 check", function()
	local is_uint53 = require("bit.uint53.is")
	it("other types & non-uint numbers", function()
		assert.equal(false, is_uint53("str")) -- string
		assert.equal(false, is_uint53({ x = 42 })) -- table
		assert.equal(false, is_uint53(-42)) -- negative
		assert.equal(false, is_uint53(42.5)) -- float
		assert.equal(false, is_uint53(2 ^ 53)) -- out of range
	end)
	it("min & max uint53", function()
		assert.equal(true, is_uint53(0))
		assert.equal(true, is_uint53(ones))
	end)
	it("random uint53s", function()
		for _ = 1, 1e3 do
			assert.equal(true, is_uint53(rand_uint53()))
		end
	end)
end)

describe("bitwise and", function()
	local band = require("bit.uint53.and")
	it("bitwise truth table", function()
		assert.equal(b("1000"), band(b("1100"), b("1010")))
	end)
	test_equation("x = x and x", function(x)
		return x, band(x, x)
	end)
	test_equation("0 = 0 or x", function(x)
		return 0, band(0, x)
	end)
	test_equation("x = 11..11 or x", function(x)
		return x, band(ones, x)
	end)
	is_commutative(band)
	is_associative(band)
end)

describe("bitwise or", function()
	local bor = require("bit.uint53.or")
	it("bitwise truth table", function()
		assert.equal(b("1110"), bor(b("1100"), b("1010")))
	end)
	test_equation("x = x or x", function(x)
		return x, bor(x, x)
	end)
	test_equation("x = 0 or x", function(x)
		return x, bor(0, x)
	end)
	test_equation("11..11 = x or 11..11", function(x)
		return ones, bor(ones, x)
	end)
	is_commutative(bor)
	is_associative(bor)
end)

local bxor = require("bit.uint53.xor")

describe("bitwise xor", function()
	it("bitwise truth table", function()
		assert.equal(b("0110"), bxor(b("1100"), b("1010")))
	end)
	test_equation("0 = x xor x", function(x)
		return 0, bxor(x, x)
	end)
	test_equation("x = 0 xor x", function(x)
		return x, bxor(0, x)
	end)
	is_commutative(bxor)
	is_associative(bxor)
end)

local bnot = require("bit.uint53.not")

describe("bitwise not", function()
	it("bitwise truth table", function()
		assert.equal(b("01"), bnot(b("10")) % 4) -- keep only the last two bits
	end)
	it("edge cases", function()
		assert.equal(0, bnot(ones))
		assert.equal(ones, bnot(0))
	end)
	test_equation("x = not not x", function(x)
		return x, bnot(bnot(x))
	end)
	test_equation("11..11 xor x = not x", function(x)
		return bxor(ones, x), bnot(x)
	end)
end)

describe("set bit count", function()
	local ones_count = require("bit.uint53.ones_count")
	it("edge cases", function()
		assert.equal(0, ones_count(0))
		assert.equal(53, ones_count(ones))
	end)
	it("random uint53s", function()
		for _ = 1, 1e3 do
			local set_count = 0
			local binary_rep = ("0"):rep(53):gsub("0", function()
				if math.random() < 0.5 then
					set_count = set_count + 1
					return "1"
				end
			end)
			assert.equal(set_count, ones_count(b(binary_rep)))
		end
	end)
end)

describe("bitshifts", function()
	describe("logical", function()
		local prefix, suffix = "1100110", "101010"
		it("left", function()
			local logical_left_shift = require("bit.uint53.logical_left_shift")
			assert.equal(2 ^ 52, logical_left_shift(1, 52))
			assert.equal(b(suffix) * 2 ^ (53 - #suffix), logical_left_shift(b(prefix .. suffix), 53 - #suffix))
		end)
		it("right", function()
			local logical_right_shift = require("bit.uint53.logical_right_shift")
			assert.equal(1, logical_right_shift(2 ^ 52, 52))
			assert.equal(b(prefix), logical_right_shift(b(prefix .. suffix), #suffix))
		end)
	end)
	describe("arithmetic", function()
		it("left is the same function as logical left shift", function()
			assert.equal(require("bit.uint53.logical_left_shift"), require("bit.uint53.arithmetic_left_shift"))
		end)
		it("right", function()
			local arithmetic_right_shift = require("bit.uint53.arithmetic_right_shift")
			assert.equal(2 ^ 52 + 2 ^ 51, arithmetic_right_shift(2 ^ 52, 1))
			assert.equal(ones, arithmetic_right_shift(2 ^ 52, 52))
		end)
	end)
	describe("circular", function()
		it("left", function()
			local circular_left_shift = require("bit.uint53.circular_left_shift")
			assert.equal(1, circular_left_shift(2 ^ 52, 1))
			local binary_rep = "110111"
			assert.equal(b(binary_rep), circular_left_shift(b(binary_rep) * 2 ^ (53 - #binary_rep), #binary_rep))
		end)
		it("right", function()
			local circular_right_shift = require("bit.uint53.circular_right_shift")
			assert.equal(2 ^ 52, circular_right_shift(1, 1))
			local binary_rep = "110111"
			assert.equal(b(binary_rep) * 2 ^ (53 - #binary_rep), circular_right_shift(b(binary_rep), #binary_rep))
		end)
	end)
end)

it("select bits", function()
	local select_bits = require("bit.uint53.select_bits")
	local prefix, infix, suffix = "101010101", "1100110111", "0000101"
	assert.equal(b(infix), select_bits(b(prefix .. infix .. suffix), #suffix + 1, #infix + #suffix))
	assert.equal(b(infix), select_bits(b(infix .. suffix), #suffix + 1))
	assert.equal(b(infix), select_bits(b(prefix .. infix), nil, #infix))
end)

describe("bit iterator", function()
	local ibits = require("bit.uint53.ibits")
	it("edge cases", function()
		for _ in ibits(0) do
			assert(false)
		end
		local i = 0
		for j, one in ibits(ones) do
			i = i + 1
			assert.equal(i, j)
			assert.equal(1, one)
		end
		assert.equal(53, i)
	end)
	it("example number", function()
		local bits = { 1, 0, 1, 1, 1, 0, 0, 1 } -- reverse order (LSB to MSB)
		for i, bit in ibits(b("10011101")) do
			assert.equal(bits[i], bit)
			bits[i] = nil
		end
		assert.equal(nil, next(bits))
	end)
end)
