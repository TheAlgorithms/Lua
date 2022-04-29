-- Finds the simplist radical form of sqrt x
return function(
	x -- number
)
	if x == 0 then
		return 1, 0
	end -- 0 = 1 sqrt 0
	assert(x > 0)
	local coefficient = 1
	local root_term = 1
	for factor = 2, math.sqrt(x) do -- Prime-factorize x
		local count = 0
		while x % factor == 0 do
			x = x / factor
			count = count + 1
		end
		coefficient = coefficient * factor ^ math.floor(count / 2) -- extract sqrt(factor^(2y)) = factor^y
		root_term = root_term * factor ^ (count % 2) -- possible leftover prime factor is multiplied with root term
	end
	-- x may itself be prime; the prime factorization only iterates up to sqrt x for efficiency, not handling that case
	root_term = root_term * x -- multiply by leftover prime factor x (which is either the original x or 1)
	-- Simplist radical form as coefficient * sqrt(root_term)
	return coefficient, root_term
end
