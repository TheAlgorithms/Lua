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

bin_op("le", function(self, other)
	local self_numerator, other_numerator = extend_to_common_denominator(self, other)
	return self_numerator <= other_numerator
end)

-- Conversions

function metatable:__tostring()
	return self.numerator .. "/" .. self.denominator
end

function fraction:to_number()
	return self.numerator / self.denominator -- numeric value of the fraction - possibly lossy
end

return fraction
