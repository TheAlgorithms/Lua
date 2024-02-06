-- Fraction "class" with metatable-based operators, featuring modulo and integer exponentiation
-- Fractions are often used to improve numerical stability in algorithms that rely on accurate division
-- which imprecise floating-point operations often can't provide

local gcd = require("math.greatest_common_divisor")
local intpow = require("math.intpow")

local fraction = {}

local metatable = { __index = fraction }

local function shorten(self)
	-- Divide numerator & denominator by their GCD
	local divisor = gcd(self.numerator, self.denominator)
	self.numerator = self.numerator / divisor
	self.denominator = self.denominator / divisor
	if self.denominator < 0 then -- always move signs to the numerator
		self.denominator = -self.denominator
		self.numerator = -self.numerator
	end
end

local function extend_to_common_denominator(self, other)
	local divisor = gcd(self.denominator, other.denominator)
	local extend_other = self.denominator / divisor
	return other.denominator / divisor * self.numerator,
		extend_other * other.numerator,
		extend_other * other.denominator
end

local function new(numerator, denominator)
	return setmetatable({ numerator = numerator, denominator = denominator }, metatable)
end

-- Constants

fraction.zero = new(0, 1)
fraction.one = new(1, 1)

-- Constructors

function fraction.new(numerator, denominator)
	assert(denominator ~= 0)
	local self = new(numerator, denominator)
	shorten(self)
	return self
end

function fraction.from_number(
	number -- may be decimal; note that some decimals aren't accurately represented by floats
)
	local denominator = 1
	while number % 1 ~= 0 do
		number = number * 2
		denominator = denominator * 2
	end
	return fraction.new(number, denominator)
end

function fraction.from_string(
	str -- string numerator/denominator as produced by tostring(fraction)
)
	local numerator, denominator = str:match("^(.-)/(.+)")
	return fraction.new(assert(tonumber(assert(numerator))), assert(tonumber(denominator)))
end

local function read_base_param(base)
	base = base or 10
	assert(base % 1 == 0 and base >= 2 and base <= 36, "invalid base")
	return base
end

local function parse_positive_double_string(
	str, -- EBNF: digit { digit } "." { digit } [ "(" digit { digit } ")" ], ex.: `1.2(3)`
	base -- integer from 2 to 36, defaults to 10 (decimal)
)
	base = read_base_param(base)
	local function read_number(str_)
		return assert(tonumber(str_, base))
	end

	local integer, fractional = str:match("^([0-9a-zA-Z][0-9a-zA-Z]-)%.([0-9a-zA-Z%(%)]+)")
	if not fractional then
		assert(str:match("[0-9a-zA-Z]+"))
		return new(read_number(str), 1)
	end

	local pre_period, period = fractional:match("^([0-9a-zA-Z]-)%(([0-9a-zA-Z]+)%)$")
	if not period then
		return read_number(integer) + fraction.new(read_number(fractional), base ^ #fractional)
	end

	local after_dot = (
		read_number(pre_period == "" and "0" or pre_period) -- digits before the period
		+ fraction.new(read_number(period), base ^ #period - 1)
	) -- period
	return read_number(integer) + after_dot / base ^ #pre_period
end

function fraction.from_float_string(
	str, -- EBNF: [ "-" ] digit { digit } "." { digit } [ "(" digit { digit } ")" ], ex.: `-1.2(3)`
	base -- integer from 2 to 36, defaults to 10 (decimal)
)
	if str:sub(1, 1) == "-" then
		return -parse_positive_double_string(str:sub(2), base)
	end
	return parse_positive_double_string(str, base)
end

-- Conversions

function metatable:__tostring()
	return self.numerator .. "/" .. self.denominator
end

local function digit(value)
	if value < 10 then -- decimals for bases <= 10
		return string.char(("0"):byte() + value)
	end
	-- letters for bases > 10 up to 36
	return string.char(("a"):byte() + value - 10)
end

-- Converts a fraction to a floating point string exactly representing the fraction in the given base
function fraction:to_float_string(
	base -- integer from 2 to 36, defaults to 10 (decimal)
)
	base = read_base_param(base)
	local base_fraction = new(base, 1)

	-- Determine sign
	local sign = ""
	if self < fraction.zero then
		sign = "-"
		self = -self
	end

	-- Split in integer (>= 1) & fractional (< 1) part
	local fractional = self % fraction.one
	local integer = self - fractional
	assert(integer.denominator == 1)
	integer = integer.numerator

	-- Format integer in given base
	local int_digits = {}
	while integer ~= 0 do
		local digit_value = integer % base -- last (least significant) digit
		table.insert(int_digits, digit(digit_value))
		integer = (integer - digit_value) / base -- remove last digit, move to next digit
	end
	-- concat & reverse digits: resulting order is most significant to least significant digit
	int_digits = table.concat(int_digits):reverse()
	if int_digits == "" then
		int_digits = 0
	end

	if fractional == fraction.zero then -- no fractional part
		return sign .. int_digits -- signed integer (ex.: `-42`)
	end

	local seen_divisions = {} -- [division key] = index of the first fractional digit resulting from the division
	local fractional_digits = {} -- list of digits after the point, from most significant to least significant
	while fractional ~= fraction.zero do
		-- Period handling
		local div_key = ("%x/%x"):format(fractional.numerator, fractional.denominator) -- format division as hex a/b
		local last_digit_index = seen_divisions[div_key]
		if last_digit_index then -- have we seen this division already?
			local pre_period_digits = last_digit_index > 1
					and table.concat(fractional_digits, "", 1, last_digit_index - 1)
				or ""
			local period = "(" .. table.concat(fractional_digits, "", last_digit_index) .. ")"
			-- signed integer plus fractional part and optional period in parentheses (ex.: `-42.42(3)`)
			return sign .. int_digits .. "." .. pre_period_digits .. period
		end

		local digit_index = #fractional_digits + 1 -- index where the new digit is to be appended
		seen_divisions[div_key] = digit_index -- mark division as seen, store index of occurrence

		fractional = fractional * base_fraction -- move the point one to the right...
		local remaining_fractional = fractional % fraction.one
		local digit_value = fractional - remaining_fractional
		assert(digit_value.denominator == 1)
		digit_value = digit_value.numerator
		fractional_digits[digit_index] = digit(digit_value) -- append digit
		fractional = remaining_fractional -- proceed with remaining digits, remove this one
	end

	fractional_digits = table.concat(fractional_digits)
	-- signed integer plus fractional part (ex.: `-42.33`)
	return sign .. int_digits .. "." .. fractional_digits
end

function fraction:to_number()
	return self.numerator / self.denominator -- numeric value of the fraction - possibly lossy
end

-- Operators

local function bin_op(name, operator)
	metatable["__" .. name] = function(self, other)
		-- Treat numbers as fractions with denominator 1
		if type(self) == "number" then
			self = fraction.from_number(self)
		elseif type(other) == "number" then
			other = fraction.from_number(other)
		end
		return operator(self, other)
	end
end

-- Arithmetic binary operators

metatable.__pow = intpow

bin_op("add", function(self, other)
	local self_numerator, other_numerator, common_denominator = extend_to_common_denominator(self, other)
	return fraction.new(self_numerator + other_numerator, common_denominator)
end)

bin_op("sub", function(self, other)
	local self_numerator, other_numerator, common_denominator = extend_to_common_denominator(self, other)
	return fraction.new(self_numerator - other_numerator, common_denominator)
end)

bin_op("mul", function(self, other)
	return fraction.new(self.numerator * other.numerator, self.denominator * other.denominator)
end)

bin_op("div", function(self, other)
	assert(other.numerator ~= 0, "division by zero")
	return fraction.new(self.numerator * other.denominator, self.denominator * other.numerator)
end)

bin_op("mod", function(self, other)
	local self_numerator, other_numerator, common_denominator = extend_to_common_denominator(self, other)
	return fraction.new(self_numerator % other_numerator, common_denominator)
end)

-- Unary minus

function metatable:__unm()
	return new(-self.numerator, self.denominator)
end

-- Comparison operators

bin_op("eq", function(self, other)
	-- extending the fractions is not needed for equality comparison as fractions are always shortened
	return self.numerator == other.numerator and self.denominator == other.denominator
end)

bin_op("lt", function(self, other)
	local self_numerator, other_numerator = extend_to_common_denominator(self, other)
	return self_numerator < other_numerator
end)

-- Technically this need not be provided, as Lua automatically defaults properly
bin_op("le", function(self, other)
	local self_numerator, other_numerator = extend_to_common_denominator(self, other)
	return self_numerator <= other_numerator
end)

return fraction
