describe("Quadratic equation solving", function()
	local solve_quadratic_equation = require("math.solve_quadratic_equation")
	local function assert_solutions(expected_a, expected_b, a, b)
		assert((a == expected_a and b == expected_b) or (b == expected_a and a == expected_b))
	end
	it("works on square roots", function()
		-- Construct equations  x^2 - a^2 = 0
		for _ = 1, 10 do
			local a = math.random(1e3)
			assert_solutions(-a, a, solve_quadratic_equation(0, -a ^ 2))
		end
	end)
	it("works on random equations", function()
		-- Construct equations (x - a)^2 = x^2 - 2ax + a^2 = 0
		for _ = 1, 100 do
			local a = math.random(1e3)
			assert.same({ a }, { solve_quadratic_equation(-2 * a, a ^ 2) })
		end
		-- Construct equations (x - a)(x - b) = x^2 - (a+b)x + ab = 0
		for _ = 1, 100 do
			local a, b = math.random(1e3), math.random(1e3)
			assert_solutions(a, b, solve_quadratic_equation(-(a + b), a * b))
		end
	end)
	it("works on a selected equation with complex numbers", function()
		local complex = require("math.complex")
		local p, q = complex.new(-1, 1), complex.new(-4, -8)
		local a, b = solve_quadratic_equation(p, q)
		assert.equal(complex.new(0, 0), a ^ 2 + p * a + q)
		assert.equal(complex.new(0, 0), b ^ 2 + p * b + q)
	end)
	it("handles the case with no real solutions", function()
		assert.equal(solve_quadratic_equation(0, 1), nil)
	end)
end)
