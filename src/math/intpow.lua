-- When exponentiating Lua numbers, always prefer the `^` operator (or `math.pow`) over this
-- Divide-and-conquer approach applied to integer exponentiation, intended for custom types like "big" numbers etc.
-- Exponentiation by squaring
local function pow(base, exponent)
	if exponent == 1 then
		return base
	end
	if exponent % 2 == 1 then
		local root = pow(base, (exponent - 1) / 2)
		return root * root * base
	end
	local root = pow(base, exponent / 2)
	return root * root
end

return function(base, exponent)
	if exponent == 0 then
		return 1
	end
	assert(exponent % 1 == 0)
	if exponent < 0 then
		return 1 / pow(base, -exponent)
	end
	return pow(base, exponent)
end
