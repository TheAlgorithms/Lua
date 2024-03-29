describe("Solve simultaneous congruences", function()
	local ssc = require("math.solve_simultaneous_congruences")

	it("should handle cases with solutions", function()
		assert.equal(0, ssc({ { 0, 3 } }))
		assert.equal(65, ssc({ { 1, 8 }, { 2, 9 } }))
		assert.equal(1, ssc({ { 1, 54 }, { 1, 73 }, { 1, 997 }, { 1, 102353 } }))
		assert.equal(39, ssc({ { 0, 3 }, { 3, 4 }, { 4, 5 } }))
		assert.equal(23, ssc({ { 2, 3 }, { 3, 5 }, { 2, 7 } }))
		assert.equal(34, ssc({ { 1, 3 }, { 4, 5 }, { 6, 7 } }))
		assert.equal(388, ssc({ { 3, 7 }, { 3, 5 }, { 4, 12 } }))
		assert.equal(87, ssc({ { 2, 5 }, { 3, 7 }, { 10, 11 } }))
		assert.equal(29, ssc({ { 2, 3 }, { 1, 4 }, { 7, 11 } }))
		assert.equal(125, ssc({ { 6, 7 }, { 8, 9 }, { 4, 11 }, { 8, 13 } }))
		assert.equal(89469, ssc({ { 6, 11 }, { 13, 16 }, { 9, 21 }, { 19, 25 } }))
	end)

	it("should handle cases without solution", function()
		assert.equal(nil, ssc({ { 5, 17 }, { 4, 17 } }))
		assert.equal(nil, ssc({ { 3, 4 }, { 0, 6 } }))
		assert.equal(nil, ssc({ { 3, 13 }, { 7, 1 } }))
	end)

	it("should throw error when a modulus is zero", function()
		assert.has_error(function()
			ssc({ { 0, 0 } })
		end)
	end)

	it("should throw error when a modulus is negative", function()
		assert.has_error(function()
			ssc({ { 0, -1 } })
		end)
	end)
end)
