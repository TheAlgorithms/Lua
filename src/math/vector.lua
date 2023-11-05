local vector = {}

local metatable = { __index = vector }
vector.metatable = metatable

function vector.new(
	self -- list of numbers without holes; #self is the dimension
)
	return setmetatable(self, metatable)
end

function vector.is(any)
	return getmetatable(any) == metatable
end

function vector.make(num, dimension)
	local v = {}
	for i = 1, dimension do
		v[i] = num
	end
	return vector.new(v)
end

local function scalar_multiplication(scalar, self)
	local res = {}
	for i, component in ipairs(self) do
		res[i] = scalar * component
	end
	return vector.new(res)
end

local function dot_product(self, other)
	assert(#self == #other, "dimensions don't match")
	local res = 0
	for i = 1, #self do
		res = res + self[i] * other[i]
	end
	return res
end

function vector:cross(other)
	assert(#self == 3 and #other == 3)
	return vector.new({
		self[2] * other[3] - self[3] * other[2],
		self[3] * other[1] - self[1] * other[3],
		self[1] * other[2] - self[2] * other[1],
	})
end

function metatable:__mul(other)
	if vector.is(self) then
		if vector.is(other) then
			return dot_product(self, other)
		end
		local mt = getmetatable(other)
		if not (mt and mt.__mul) then
			assert(type(other) == "number")
			return scalar_multiplication(other, self)
		end
		-- HACK delegate to other metatable (specifically matrix metatable).
		return mt.__mul(self, other)
	end
	-- `self` can't have a metatable providing `__mul`,
	-- otherwise Lua would already have called that.
	assert(type(self) == "number")
	return scalar_multiplication(self, other)
end

function metatable:__unm()
	return -1 * self
end

function metatable:__add(other)
	local res = {}
	for i = 1, #self do
		res[i] = self[i] + other[i]
	end
	return vector.new(res)
end

function metatable:__sub(other)
	return self + -other
end

function metatable:__div(other)
	if type(other) == "number" then
		return 1 / other * self
	end
	assert(type(self) == "number", "one argument must be a scalar")
	if type(self) == "number" then
		local res = {}
		for i, component in ipairs(other) do
			res[i] = self / component
		end
		return vector.new(res)
	end
end

function metatable:__eq(other)
	assert(#self == #other)
	for i = 1, #self do
		if self[i] ~= other[i] then
			return false
		end
	end
	return true
end

function vector:length()
	local len = 0
	for i = 1, #self do
		len = len + self[i] ^ 2
	end
	return len ^ 0.5
end

function vector:distance(other)
	return (self - other):length()
end

function vector:normalize()
	local len = self:length()
	if len == 0 then
		return vector.make(0, #self) -- zero vector if input has length zero
	end
	return self / len -- normalized vector
end

function vector:angle(other)
	local cos_angle = (self * other) / (self:length() * other:length())
	-- Deal gracefully with floating point imprecisions
	if cos_angle < -1 then
		cos_angle = -1
	elseif cos_angle > 1 then
		cos_angle = 1
	end
	return math.acos(cos_angle) -- number: signed angle in radians
end

function vector:orthogonal(other)
	return self * other == 0 -- boolean: whether the vectors are orthogonal
end

function vector:parallel(other)
	assert(#self == #other)
	local scale_factor = self[1] / other[1]
	for i = 2, #self do
		if self[i] / other[i] ~= scale_factor then
			return false -- vectors are not parallel
		end
	end
	return true -- vectors are parallel / colinear
end

function vector:reflect(
	normal -- vector: the surface normal to reflect `self` at; **must be normalized**
)
	local parallel_component = self * normal
	return self - 2 * parallel_component * normal -- reflected vector
end

function metatable:__tostring()
	local comp_strs = {}
	for i = 1, #self do
		comp_strs[i] = tostring(self[i])
	end
	return "(" .. table.concat(comp_strs, " ") .. ")"
end

return vector
