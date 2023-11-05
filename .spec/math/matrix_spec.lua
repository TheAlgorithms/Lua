-- Turn off StyLua to preserve matrix formatting
-- stylua: ignore
describe("Matrix", function()
	local matrix = require("math.matrix")
	local vector = require("math.vector")
	describe("constructors", function()
		it("zero", function()
			assert.same({h = 3, w = 2; 0, 0, 0, 0, 0, 0}, matrix.zero(3, 2))
		end)
		it("from list, with height", function()
			assert.same({
				h = 2, w = 3;
				1, 2, 3;
				4, 5, 6
			}, matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			}))
		end)
		it("from list, with width", function()
			assert.same({
				h = 2, w = 3;
				1, 2, 3;
				4, 5, 6
			}, matrix.with_width(3, {
				1, 2, 3;
				4, 5, 6
			}))
		end)
		it("square", function()
			assert.equal(matrix.with_height(2, {
				1, 2;
				3, 4
			}), matrix.square{
				1, 2;
				3, 4
			})
		end)
		it("identity", function()
			assert.equal(matrix.square{
				1, 0;
				0, 1
			}, matrix.identity(2))
		end)
		it("diagonal", function()
			assert.equal(matrix.square{
				1, 0;
				0, 2
			}, matrix.diagonal{1, 2})
		end)
	end)
	it("copy", function()
		local m = matrix.with_height(2, {
			1, 2, 3;
			4, 5, 6
		})
		local copy = m:copy()
		m:set(2, 3, 9)
		assert.equal(matrix.with_height(2, {
			1, 2, 3;
			4, 5, 6
		}), copy)
	end)
	describe("equals", function()
		local m = matrix.with_height(2, {
			1, 2, 3;
			4, 5, 6
		})
		it("itself", function()
			assert(m:equals(m))
		end)
		it("copy of itself", function()
			assert(m:equals(m:copy()))
		end)
		it("supports tolerance", function()
			assert(matrix.square{0}:equals(matrix.square{1e-9}, 1e-9))
		end)
		it("different dimensions", function()
			assert(not m:equals(matrix.with_height(3, {unpack(m)})))
		end)
		it("different values", function()
			assert(not m:equals(matrix.zero(2, 3)))
		end)
	end)
	describe("getters & setters", function()
		it("elements", function()
			local m = matrix.with_height(2, {
				0, 2, 3;
				4, 5, 9
			})
			assert.equal(0, m:get(1, 1))
			assert.equal(9, m:get(2, 3))
			m:set(1, 1, 1)
			m:set(2, 3, 6)
			assert.equal(1, m:get(1, 1))
			assert.equal(6, m:get(2, 3))
			assert.equal(matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			}), m)
		end)
		it("shape", function()
			local m = matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			})
			m:set_height(2)
			assert.equal(matrix.with_height(2, {unpack(m)}), m)
			m:set_width(6)
			assert.equal(matrix.with_width(6, {unpack(m)}), m)
		end)
	end)
	it("transposition", function()
		assert.equal(matrix.square{
			1, 2;
			3, 4
		}, matrix.square{
			1, 3;
			2, 4
		}:transposed())
		assert.equal(matrix.with_height(3, {
			1, 4;
			2, 5;
			3, 6
		}), matrix.with_height(2, {
			1, 2, 3;
			4, 5, 6
		}):transposed())
	end)
	it("negation", function()
		local m = matrix.square{1}
		m:negate()
		assert.equal(matrix.square{-1}, m)
	end)
	it("addition", function()
		local m = matrix.square{1, 2, 3, 4}
		m:add(matrix.square{4, 3, 2, 1})
		assert.equal(matrix.square{5, 5, 5, 5}, m)
	end)
	it("subtraction", function()
		local m = matrix.square{5, 5, 5, 5}
		m:subtract(matrix.square{4, 3, 2, 1})
		assert.equal(matrix.square{1, 2, 3, 4}, m)
	end)
	it("scalar multiplication", function()
		local m = matrix.square{1, 2, 3, 4}
		m:scale(2)
		assert.equal(matrix.square{2, 4, 6, 8}, m)
	end)
	it("matrix-vector multiplication", function()
		assert.equal(vector.new{1*1 + 2*2 + 3*3, 4*1 + 5*2 + 6*3},
			matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			}):multiply_column_vector({1, 2, 3}))
	end)
	it("vector-matrix multiplication", function()
		assert.equal(vector.new{1*1 + 2*4, 1*2 + 2*5, 1*3 + 2*6},
			matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			}):multiply_row_vector({1, 2}))
	end)
	describe("matrix multiplication", function()
		it("dot product", function()
			assert.equal(matrix.square{1*1 + 2*2 + 3*3}, matrix.with_width(3, {1, 2, 3})
				:multiply_matrix(matrix.with_height(3, {1, 2, 3})))
		end)
		it("outer product", function()
			assert.equal(matrix.square{
				1*1, 1*2, 1*3;
				1*2, 2*2, 2*3;
				1*3, 3*2, 3*3
			}, matrix.with_height(3, {1, 2, 3})
				:multiply_matrix(matrix.with_width(3, {1, 2, 3})))
		end)
		local m = matrix.with_height(2, {
			1, 2, 3;
			4, 5, 6
		})
		it("2x3 * 3x2 -> 2x2", function()
			assert.equal(matrix.square{
				1*1 + 2*2 + 3*3, 1*4 + 2*5 + 3*6;
				4*1 + 5*2 + 6*3, 4*4 + 5*5 + 6*6
			}, m:multiply_matrix(m:transposed()))
		end)
		it("3x2 * 2x3 -> 3x3", function()
			assert.equal(matrix.square{
				1*1 + 4*4, 1*2 + 4*5, 1*3 + 4*6;
				2*1 + 5*4, 2*2 + 5*5, 2*3 + 5*6;
				3*1 + 6*4, 3*2 + 6*5, 3*3 + 6*6
			}, m:transposed():multiply_matrix(m))
		end)
	end)
	describe("operators", function()
		it("equals", function()
			assert(matrix.square{1} == matrix.square{1})
		end)
		it("negation", function()
			assert.equal(matrix.square{-1}, -matrix.square{1})
		end)
		it("subtraction", function()
			assert.equal(matrix.square{1}, matrix.square{3} - matrix.square{2})
		end)
		it("addition", function()
			assert.equal(matrix.square{3}, matrix.square{1} + matrix.square{2})
		end)
		describe("multiplication", function()
			it("scalar-matrix, matrix-scalar", function()
				assert.equal(matrix.square{2, 4, 6, 8}, 2*matrix.square{1, 2, 3, 4})
				assert.equal(matrix.square{2, 4, 6, 8}, matrix.square{1, 2, 3, 4}*2)
			end)
			local m = matrix.with_height(2, {
				1, 2, 3;
				4, 5, 6
			})
			it("matrix-vector", function()
				local v = vector.new{1, 2, 3}
				assert.equal(m:multiply_column_vector(v), m*v)
			end)
			it("vector-matrix", function()
				local v = vector.new{1, 2}
				assert.equal(m:multiply_row_vector(v), v*m)
			end)
			it("matrix-matrix", function()
				local t = m:transposed()
				assert.equal(t:multiply_matrix(m), t*m)
				assert.equal(m:multiply_matrix(t), m*t)
			end)
		end)
		describe("exponentiation", function()
			it("rejects non-endomorphisms", function()
				assert.has_error(function() return matrix.zero(2, 3)^10 end)
			end)
			it("identity matrix for exponent 0", function()
				assert.equal(matrix.identity(2), matrix.zero(2)^0)
			end)
			it("equals repeated multiplication", function()
				local m = matrix.square{1, 2, 3, 4}
				assert.equal(m*m*m*m, m^4)
			end)
			it("inverts & multiplies", function()
				local m = matrix.square{1, 2, 3, 4}
				local inv = m:inverse()
				assert((inv*inv*inv):equals(m^-3, 1e-9))
			end)
		end)
	end)
	describe("inversion", function()
		it("returns nothing for non-invertible matrices", function()
			assert.equal(nil, (matrix.with_width(2, {1, 2}):inverse()))
			assert.equal(nil, (matrix.with_height(2, {1, 2}):inverse()))
			assert.equal(nil, (matrix.square{
				1, 1;
				0, 0,
			}:inverse()))
		end)
		it("works for a 2x2 matrix", function()
			assert((1/(1*4 - 2*3) * matrix.square{
				4, -2;
				-3, 1
			}):equals(matrix.square{
				1, 2,
				3, 4,
			}:inverse(), 1e-9))
		end)
		it("works exactly for fractions", function()
			local fraction = require("math.fraction")
			local intfrac = fraction.from_number
			local m = matrix.square{
				4, -2;
				-3, 1
			}
			m:scale(fraction.new(1, 1*4 - 2*3))
			assert(m:equals(matrix.square{
				intfrac(1), intfrac(2),
				intfrac(3), intfrac(4),
			}:inverse(intfrac(0)), intfrac(0)))
		end)
		it("works for random matrices", function()
			for n = 1, 10 do
				local id = matrix.identity(n)
				for _ = 1, 10 do
					local random_nums = {}
					for i = 1, n^2 do
						random_nums[i] = math.random(-1e7, 1e7)
					end
					local m = matrix.with_height(n, random_nums)
					-- It is highly probable that the matrix is invertible;
					-- we do not need to account for non-invertible matrices
					local inv = m:inverse(1e-6)
					assert(id:equals(m*inv, 1e-6))
					assert(id:equals(inv*m, 1e-6))
				end
			end
		end)
	end)
	describe("determinant", function()
		it("is zero for non-invertible matrices", function()
			assert.equal(0, matrix.with_width(2, {1, 2}):determinant())
			assert.equal(0, matrix.with_height(2, {1, 2}):determinant())
			assert.equal(0, matrix.square{
				1, 1;
				0, 0,
			}:determinant())
		end)
		it("2d", function()
			assert.near(1 * 4 - 2 * 3, matrix.square{
				1, 2;
				3, 4
			}:determinant(), 1e-9)
		end)
		it("3d", function()
			assert.near(60, matrix.square{
				1, 4, 3;
				2, 5, 6;
				9, 8, 7
			}:determinant(), 1e-9)
		end)
	end)
end)
