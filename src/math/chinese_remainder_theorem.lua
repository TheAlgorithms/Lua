local modular_inverse = require("math.modular_inverse")

local function all_moduli_prod(congruences)
	local res = 1
	for _, congruence in ipairs(congruences) do
		res = res * congruence[2]
	end
	return res
end

-- Solves system of congruences represented by list of pairs.
-- The pair `{a, m}` represents a congruance `x = a mod m`.
-- For the input {{a_0, m_0}, {a_1, m_1}, ...},
-- it finds a number `x`, such that
-- x = a_i mod m_i and 0 < x < m_1 * m_2 * ...
return function(congruences)
	local all_prod = all_moduli_prod(congruences)

	local res = 0
	for _, congruence in ipairs(congruences) do
		local residue = congruence[1]
		local modulus = congruence[2]
		local cur_prod = math.floor(all_prod / modulus)
		local cur_inv = modular_inverse(cur_prod, modulus)
		if cur_inv == nil then
			-- moduli of the congruances are not co-prime
			return nil
		end
		res = (res + residue * cur_inv * cur_prod) % all_prod
	end

	return res
end
