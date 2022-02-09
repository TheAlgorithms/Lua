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
	while b > 0 do
		a, b = b, a % b
	end
	-- Greatest common divisor
	return a
end
