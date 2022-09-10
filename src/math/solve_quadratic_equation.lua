-- Solves a quadratic equation of the form x² + px + q = 0 for x using the p-q-formula
return function(
	p, --[[coefficient of x]]
	q --[[remaining term]]
)
	local root = (p ^ 2 / 4 - q) ^ 0.5
	if root ~= root then -- nan check: negative discriminant
		return -- no solution
	end
	local x_1, x_2 = -p / 2 - root, -p / 2 + root
	if x_1 == x_2 then
		return x_1 -- exactly one solution
	end
	return x_1, x_2 -- two solutions
end
