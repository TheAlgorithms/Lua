-- Dense matrices, represented as lists in row-major order
-- plus width and height (storing height redundantly makes for a nicer interface).

local vector = require("math.vector")
local abs = require("math.abs")
local intpow = require("math.intpow")

local function assert_isint(x)
	assert(x % 1 == 0)
end

local matrix = {}
local metatable = { __index = matrix }

-- Constructors

function matrix.zero(
	h,
	w -- defaults to `h`
)
	w = w or h
	local self = {}
	for i = 1, h * w do
		self[i] = 0
	end
	self.h, self.w = h, w
	setmetatable(self, metatable)
	return self
end

function matrix.with_height(
	h, -- height, width is inferred from the length of the list
	self -- list, reused as matrix object
)
	assert_isint(h)
	local w = #self / h
	assert_isint(w)
	self.h, self.w = h, w
	setmetatable(self, metatable)
	return self
end

function matrix.with_width(
	w, -- width, height is inferred from the length of the list
	self -- list, reused as matrix object
)
	assert_isint(w)
	local h = #self / w
	assert_isint(h)
	self.h, self.w = h, w
	setmetatable(self, metatable)
	return self
end

function matrix.square(
	self -- list, reused as matrix object
)
	local h = (#self) ^ 0.5
	return matrix.with_height(h, self)
end

function matrix.identity(n)
	local self = matrix.zero(n)
	for i = 1, n do
		self:set(i, i, 1)
	end
	return self
end

function matrix.diagonal(vec)
	local n = #vec
	local self = matrix.zero(n)
	for i = 1, n do
		self:set(i, i, vec[i])
	end
	return self -- square matrix with vec on the diagonal
end

-- is, copy, equals

function matrix.is(any)
	return getmetatable(any) == metatable
end

function matrix:copy()
	local copy = { h = self.h, w = self.w }
	for i = 1, self.h * self.w do
		copy[i] = self[i]
	end
	setmetatable(copy, metatable)
	return copy
end

function matrix:equals(
	other, -- other matrix
	tolerance -- absolute tolerance for number comparisons, defaults to 0
)
	tolerance = tolerance or 0
	if rawequal(self, other) then
		return true
	end
	if self.h ~= other.h or self.w ~= other.w then
		return false
	end
	for i = 1, self.h * self.w do
		if abs(self[i] - other[i]) > tolerance then
			return false
		end
	end
	return true
end

-- Getters & setters

function matrix:get(row, col)
	return self[self.w * (row - 1) + col]
end

function matrix:set(row, col, val)
	self[self.w * (row - 1) + col] = val
end

function matrix:set_height(h)
	assert_isint(h)
	local n = self.w * self.h
	local w = n / h
	assert_isint(w)
	self.w, self.h = w, h
end

function matrix:set_width(w)
	assert_isint(w)
	local n = self.w * self.h
	local h = n / w
	assert_isint(h)
	self.w, self.h = w, h
end

function matrix:transposed()
	local w, h = self.w, self.h
	local n = w * h
	local transposed = matrix.zero(w, h)
	local j = 1
	for i = 1, n do
		transposed[j] = self[i]
		j = j + h
		if j > n then
			-- Advance to next column
			j = j - n + 1
		end
	end
	return transposed
end

-- Negate `self`
function matrix:negate()
	for i = 1, self.w * self.h do
		self[i] = -self[i]
	end
end

-- Add `addend` to `self`
function matrix:add(
	addend -- matrix
)
	assert(self.w == addend.w and self.h == addend.h)
	for i = 1, self.w * self.h do
		self[i] = self[i] + addend[i]
	end
end

-- Subtract `subtrahend` from `self`
function matrix:subtract(
	subtrahend -- matrix
)
	assert(self.w == subtrahend.w and self.h == subtrahend.h)
	for i = 1, self.w * self.h do
		self[i] = self[i] - subtrahend[i]
	end
end

-- Scalar multiplication
function matrix:scale(scalar)
	for i = 1, self.w * self.h do
		self[i] = scalar * self[i]
	end
end

-- Matrix-vector multiplication: Apply `self` to a column vector `vec_rhs` (vector on the right side)
function matrix:multiply_column_vector(vec_rhs)
	local res = {}
	local w, h = self.w, self.h
	assert(w == #vec_rhs)
	local j = 1
	for i = 1, h do
		local sum = 0 -- dot product of i-th row of `self` with `vec`
		for k = 1, w do
			sum = sum + self[j] * vec_rhs[k]
			j = j + 1
		end
		res[i] = sum
	end
	return vector.new(res)
end

-- Vector-matrix multiplication: Apply `self` to a row vector `vec_lhs` (vector on the left side)
function matrix:multiply_row_vector(vec_lhs)
	local res = {}
	local w, h = self.w, self.h
	assert(h == #vec_lhs)
	for i = 1, w do
		local j = i
		local sum = 0 -- dot product of i-th column of `self` with `vec`
		for k = 1, h do
			sum = sum + self[j] * vec_lhs[k]
			j = j + w -- advance to next row
		end
		res[i] = sum
	end
	return vector.new(res)
end

-- TODO (...?) multiplication by first transposing,
-- then taking row-row dot products (better cache locality);
-- Strassen's algorithm (better asymptotic time complexity).
-- Needs benchmarks, may not be worthwhile.

-- Matrix multiplication (function composition of `outer` and `inner`)
function matrix.multiply_matrix(
	outer, -- matrix
	inner -- matrix
)
	assert(inner.h == outer.w)
	local product = { w = inner.w, h = outer.h }
	for i = 1, outer.h do
		for j = 1, inner.w do
			local sum = 0 -- dot product of row of outer & column of inner
			for k = 1, inner.h do
				sum = sum + outer:get(i, k) * inner:get(k, j)
			end
			table.insert(product, sum)
		end
	end
	setmetatable(product, metatable)
	return product -- composition of `outer` and `inner`
end

-- Matrix inversion & determinant, both based on Gaussian elimination
do
	local function swap_rows(mat, i, j)
		if i == j then
			return
		end
		local k, l = (i - 1) * mat.w, (j - 1) * mat.w
		for m = 1, mat.w do
			mat[k + m], mat[l + m] = mat[l + m], mat[k + m]
		end
	end
	local function scale_row(mat, factor, i)
		if factor == 1 then
			return
		end
		for j = (i - 1) * mat.w + 1, i * mat.w do
			mat[j] = factor * mat[j]
		end
	end
	local function add_scaled_row(mat, factor, from_row, to_row)
		if factor == 0 then
			return
		end
		local i, j = (from_row - 1) * mat.w, (to_row - 1) * mat.w
		for k = 1, mat.w do
			mat[j + k] = factor * mat[i + k] + mat[j + k]
		end
	end
	-- Gaussian elimination: Brings `mat` into upper triangle matrix form,
	-- returns success
	local function eliminate(mat, swap, add_scaled, epsilon)
		-- Loop over the column to be eliminated
		for i = 1, mat.w do
			-- Find a pivot row: Choose the row with the largest absolute component
			local max_row_idx = i
			local max_abs_comp = abs(mat:get(max_row_idx, i))
			for j = i + 1, mat.h do
				local cand_comp = abs(mat:get(j, i))
				if cand_comp > max_abs_comp then
					max_row_idx, max_abs_comp = j, cand_comp
				end
			end

			if max_abs_comp <= epsilon then
				return false -- no row has this component "nonzero"
			end

			swap(i, max_row_idx) -- swap row to correct position
			-- Eliminate the `i`-th component in all rows *below* the pivot row
			local pivot_value = mat:get(i, i)
			for j = i + 1, mat.w do
				add_scaled(-mat:get(j, i) / pivot_value, i, j)
				assert(abs(mat:get(j, i)) <= epsilon)
			end
		end
		return true
	end
	-- Resubstitution: Turn an upper triangle matrix into the identity matrix
	local function resubstitute(mat, scale, add_scaled)
		for i = mat.w, 1, -1 do
			local pivot_value = mat:get(i, i)
			-- Eliminate the `i`-th component in all rows *above* the pivot row
			for j = i - 1, 1, -1 do
				add_scaled(-mat:get(j, i) / pivot_value, i, j)
			end
			scale(1 / pivot_value, i) -- normalize row
		end
	end
	function matrix:inverse(
		epsilon -- threshold for numbers to be considered zero
	)
		epsilon = epsilon or 1e-9
		if self.w ~= self.h then
			return -- if matrix is not invertible
		end

		local copy = self:copy() -- copy to execute Gaussian elimination on
		local inverse = matrix.identity(self.w) -- inverse matrix, to which all operations are mirrored

		-- All operations must be mirrored to the inverse matrix
		local function swap_rows_mirrored(i, j)
			swap_rows(copy, i, j)
			swap_rows(inverse, i, j)
		end
		local function scale_row_mirrored(factor, row)
			scale_row(copy, factor, row)
			scale_row(inverse, factor, row)
		end
		local function add_scaled_row_mirrored(factor, from_row, to_row)
			add_scaled_row(copy, factor, from_row, to_row)
			add_scaled_row(inverse, factor, from_row, to_row)
		end

		if not eliminate(copy, swap_rows_mirrored, add_scaled_row_mirrored, epsilon) then
			return
		end
		resubstitute(copy, scale_row_mirrored, add_scaled_row_mirrored)

		return inverse -- if matrix is invertible
	end

	function matrix:determinant(
		epsilon -- threshold for numbers to be considered zero
	)
		epsilon = epsilon or 1e-9
		if self.w ~= self.h then
			return 0 -- if matrix is not invertible
		end

		local copy = self:copy() -- copy to execute Gaussian elimination on
		local determinant = 1
		local function swap_row_det(i, j)
			if i == j then
				return
			end
			swap_rows(copy, i, j)
			determinant = -determinant
		end
		local function add_scaled_row_det(factor, from_row, to_row)
			add_scaled_row(copy, factor, from_row, to_row)
		end

		if not eliminate(copy, swap_row_det, add_scaled_row_det, epsilon) then
			return 0
		end

		for i = 1, self.w do
			determinant = determinant * copy:get(i, i)
		end

		return determinant -- if matrix is invertible
	end
end

metatable.__eq = matrix.equals

function metatable:__unm()
	local negated = self:copy()
	negated:negate()
	return negated
end

function metatable:__add(addend)
	local sum = self:copy()
	sum:add(addend)
	return sum
end

function metatable:__sub(subtrahend)
	local difference = self:copy()
	difference:subtract(subtrahend)
	return difference
end

-- Overloaded matrix multiplication;
-- does scalar-matrix, vector-matrix, matrix-vector or matrix-matrix multiplication
-- depending on argument types
function metatable.__mul(
	lhs, -- scalar, vector or matrix
	rhs -- scalar, vector or matrix
)
	if matrix.is(lhs) then
		if matrix.is(rhs) then
			return lhs:multiply_matrix(rhs)
		end
		if vector.is(rhs) then
			return lhs:multiply_column_vector(rhs)
		end
		-- Default: Assume `rhs` is a scalar (may be a custom number type like fractions)
		local scaled = lhs:copy()
		scaled:scale(rhs)
		return scaled
	end
	if vector.is(lhs) then
		return rhs:multiply_row_vector(lhs)
	end
	-- Default: Assume `lhs` is a scalar (may be a custom number type like fractions)
	local scaled = rhs:copy()
	scaled:scale(lhs)
	return scaled
end

function metatable:__pow(exponent)
	assert(matrix.is(self))
	assert(self.w == self.h)
	if exponent == 0 then
		-- Note: `matrix.zero(n)^0` is also `matrix.identity(n)`
		return matrix.identity(self.w)
	end
	if exponent == 1 then
		return self:copy()
	end
	local base = self
	if exponent < 0 then
		exponent = -exponent
		base = assert(base:inverse())
	end
	return intpow(base, exponent)
end

return matrix
