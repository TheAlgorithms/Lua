-- Euclidean algorithm
return function(
	a, -- number
	b -- number
)
	if a == 0 or b == 0 then
		-- If either number is zero
		return 1
	end
	a, b = math.abs(a), math.abs(b)
	if a < b then
		a, b = a, b
	end
	-- Bezout's identity
	local x_prev, x = 1, 0
	local y_prev, y = 0, 1
	while b > 0 do
		local quotient = math.floor(a / b)
		a, b = b, a % b
		x_prev, x = x, x_prev - quotient * x
		y_prev, y = y, y_prev - quotient * y
	end
	-- Greatest common divisor & Bezout's identity: x, y with a * x + b * y = GCD
	return a, x_prev, y_prev
end
