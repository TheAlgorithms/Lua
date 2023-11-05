-- Complex numbers with metatable-based operators

local intpow = require("math.intpow")

local complex = {}

local metatable = { __index = complex }

function complex.new(
	real, -- number, real part
	imaginary -- number, imaginary part, defaults to 0
)
	return setmetatable({ real = real, imaginary = imaginary or 0 }, metatable)
end

-- Imaginary unit as a complex number
complex.i = complex.new(0, 1)

function complex.from_polar_coordinates(
	angle, -- number, angle in radians
	abs -- number, radius / norm / length
)
	return complex.new(abs * math.cos(angle), abs * math.sin(angle))
end

local function bin_op(name, operator)
	metatable["__" .. name] = function(self, other)
		-- Treat numbers as complex numbers with an imaginary part of 0
		if type(self) == "number" then
			self = complex.new(self)
		elseif type(other) == "number" then
			other = complex.new(other)
		end
		return operator(self, other)
	end
end

-- Arithmetic binary operators

function complex:sqrt()
	if self.imaginary == 0 then
		return complex.new(math.abs(self.real) ^ 0.5, 0)
	end
	local real = ((self.real + (self.real ^ 2 + self.imaginary ^ 2) ^ 0.5) / 2) ^ 0.5
	local imaginary = self.imaginary / 2 / real
	return complex.new(real, imaginary)
end

function metatable:__pow(exponent)
	if exponent == 0.5 then
		return self:sqrt()
	end
	assert(exponent % 1 == 0, "unsupported operation")
	return intpow(self, exponent)
end

bin_op("add", function(self, other)
	return complex.new(self.real + other.real, self.imaginary + other.imaginary)
end)

bin_op("sub", function(self, other)
	return complex.new(self.real - other.real, self.imaginary - other.imaginary)
end)

bin_op("mul", function(self, other)
	return complex.new(
		self.real * other.real - self.imaginary * other.imaginary,
		self.real * other.imaginary + self.imaginary * other.real
	)
end)

bin_op("div", function(self, other)
	local numerator = self * other:conjugate()
	local denominator = other.real ^ 2 + other.imaginary ^ 2
	return complex.new(numerator.real / denominator, numerator.imaginary / denominator)
end)

-- Unary operators

function metatable:__unm()
	return complex.new(-self.real, -self.imaginary)
end

function complex:conjugate()
	return complex.new(self.real, -self.imaginary)
end

function complex:abs()
	return (self.real ^ 2 + self.imaginary ^ 2) ^ 0.5
end

-- Comparison operators; only equality is reasonable here

bin_op("eq", function(self, other)
	return self.real == other.real and self.imaginary == other.imaginary
end)

-- Conversions

function complex:to_polar_coordinates()
	local angle, abs = math.atan2(self.imaginary, self.real), self:abs()
	return angle, -- number, angle in radians
		abs -- number, radius / norm / length
end

function metatable:__tostring()
	return self.real .. "+" .. self.imaginary .. "i"
end

return complex
