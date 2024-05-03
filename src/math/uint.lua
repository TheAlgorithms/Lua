-- Unsigned integers with a given base.
-- Support basic arithmetic (increment, decrement, addition, subtraction, multiplication, exponentiation),
-- with both mutating variants (via methods) and copying variants (via arithmetic operators),
-- comparisons, as well as efficient base conversion.

-- Cache class tables for given bases.
-- Important for equality comparisons to work for the same base.
local uints = setmetatable({}, { __mode = "v" })

return function(
	-- number, base to be used; digits will be 0 to base (exclusive);
	-- should be at most `2^26` for products to stay in exact float bounds,
	-- default is `2^24` (3 bytes per digit)
	base
)
	base = base or 2 ^ 24
	assert(base >= 2 and base % 1 == 0 and base <= 2 ^ 26)

	if uints[base] then
		return uints[base]
	end

	local uint = { base = base }
	local mt = { __index = uint }

	local function bin_op(name, f)
		mt["__" .. name] = function(a, b)
			if type(a) == "number" then
				a = uint.from_number(a)
			elseif type(b) == "number" then
				b = uint.from_number(b)
			end
			return f(a, b)
		end
	end

	function uint.zero()
		return setmetatable({}, mt)
	end

	function uint.one()
		return setmetatable({ 1 }, mt)
	end

	function uint.from_digits(
		digits -- list of digits in the appropriate base, little endian; is consumed
	)
		return setmetatable(digits, mt)
	end

	function uint.from_number(
		number -- exact integer >= 0
	)
		local digits = {}
		assert(number >= 0 and number % 1 == 0)
		while number > 0 do
			local digit = number % base
			table.insert(digits, digit)
			number = (number - digit) / base
		end
		return uint.from_digits(digits)
	end

	function uint:to_number(
		exact -- whether to allow losing precision, defaults to true
	)
		local number = 0
		local pow = 1
		for _, digit in ipairs(self) do
			local val = digit * pow
			pow = pow * base
			if exact ~= false and 2 ^ 53 - val < number then
				return -- if not representable without loss of precision
			end
			number = number + val
		end
		return number -- exact number representing the same integer
	end

	function uint:copy()
		local copy = {}
		for i, v in ipairs(self) do
			copy[i] = v
		end
		return uint.from_digits(copy)
	end

	function uint.copy_from(dst, src)
		assert(dst.base == src.base)
		for i, v in ipairs(src) do
			dst[i] = v
		end
		for i = #src + 1, #dst do
			dst[i] = nil
		end
	end

	--> sign(a - b)
	--! For better efficiency, prefer a single `uint.compare` over multiple `<`/`>`/`<=`/`>=`/`==` comparisons
	function uint.compare(a, b)
		assert(a.base == b.base)
		if #a < #b then
			return -1
		end
		if #a > #b then
			return 1
		end
		for i = #a, 1, -1 do
			if a[i] < b[i] then
				return -1
			end
			if a[i] > b[i] then
				return 1
			end
		end
		return 0
	end

	-- Note: These will only run if the metatables are equal,
	-- so there is no risk of comparing numbers of different bases.
	bin_op("eq", function(a, b)
		return a:compare(b) == 0
	end)
	bin_op("lt", function(a, b)
		return a:compare(b) < 0
	end)
	bin_op("le", function(a, b)
		return a:compare(b) <= 0
	end)

	function uint:increment()
		local i = 1
		while self[i] == base - 1 do
			self[i] = 0
			i = i + 1
		end
		self[i] = (self[i] or 0) + 1
	end

	function uint:decrement()
		local i = 1
		while self[i] == 0 do
			self[i] = base - 1
			i = i + 1
		end
		self[i] = assert(self[i], "result < 0") - 1
		if self[i] == 0 then
			self[i] = nil
		end
	end

	local function add_shifted(dst, src, srcshift)
		local i, j = srcshift + 1, 1
		local carry = 0
		while dst[i] or src[j] or carry > 0 do
			local digit_sum = (dst[i] or 0) + (src[j] or 0) + carry
			dst[i] = digit_sum % base
			carry = (digit_sum - dst[i]) / base
			i, j = i + 1, j + 1
		end
	end

	function uint.add(dst, src)
		return add_shifted(dst, src, 0)
	end

	bin_op("add", function(a, b)
		local res = a:copy()
		res:add(b)
		return res
	end)

	local function strip_leading_zeros(dst)
		local i = #dst
		while dst[i] == 0 do
			dst[i] = nil
			i = i - 1
		end
	end

	function uint.subtract(dst, src)
		do
			local i = 1
			local borrow = 0
			while src[i] or borrow > 0 do
				local digit_diff = assert(dst[i], "result < 0") - (src[i] or 0) - borrow
				-- Works since Lua's remainder operator is special -
				-- it computes `(base + digit_diff) % base` for a negative `digit_diff`
				dst[i] = digit_diff % base
				if digit_diff < 0 then
					-- Unfortunately `math.floor` rounds negative numbers in the wrong direction
					-- borrow = math.floor(-digit_diff / base)
					-- assert(borrow >= 0)
					borrow = 1
				else
					borrow = 0
				end
				i = i + 1
			end
			assert(borrow == 0, "result < 0")
		end
		strip_leading_zeros(dst)
	end

	bin_op("sub", function(a, b)
		local res = a:copy()
		res:subtract(b)
		return res
	end)

	local function product_naive(a, b)
		assert(a[#a] ~= 0 and b[#b] ~= 0)
		local res = uint.zero()
		-- Enforce #a <= #b
		if #b < #a then
			a, b = b, a
		end
		for i, a_digit in ipairs(a) do
			if a_digit == 0 then
				res[i] = res[i] or 0 -- no holes!
			else
				local term = {}
				local carry = 0
				for j, b_digit in ipairs(b) do
					local res_digit = a_digit * b_digit + carry
					term[j] = res_digit % base
					carry = (res_digit - term[j]) / base
				end
				if carry > 0 then
					table.insert(term, carry)
				end
				add_shifted(res, term, i - 1)
			end
		end
		assert(res[#res] ~= 0)
		return res
	end

	-- Note: Returns `{}` (zero) if `from > to`
	local function slice(self, from, to)
		local digits = {}
		for i = from, to do
			table.insert(digits, self[i])
		end
		strip_leading_zeros(digits)
		return uint.from_digits(digits)
	end

	local function product_karatsuba(a, b)
		-- Ensure that `b` is the longer number
		if #b < #a then
			a, b = b, a
		end
		if #a < 10 then -- base case: Naive multiplication, to be tweaked
			return product_naive(a, b)
		end
		local mid = math.floor(#b / 2) -- split at the middle of the longer of the two numbers
		local prod_high, prod_low, prod_sum
		do
			local a_low, a_high = slice(a, 1, mid), slice(a, mid + 1, #a)
			local b_low, b_high = slice(b, 1, mid), slice(b, mid + 1, #b)
			prod_high = product_karatsuba(a_high, b_high)
			prod_low = product_karatsuba(a_low, b_low)
			-- Note: We can mutate a_low and b_low here since we already used them above.
			local a_sum = a_low
			a_sum:add(a_high)
			local b_sum = b_low
			b_sum:add(b_high)
			prod_sum = product_karatsuba(a_sum, b_sum)
			-- At this point we have `prod_sum = (a_low + a_high) * (b_low + b_high)`
			prod_sum:subtract(prod_high)
			prod_sum:subtract(prod_low)
			-- This leaves us with `prod_sum = a_high * b_low + b_high * a_low`
		end
		local res = prod_low
		-- Ensure that we produce no holes
		local min_len = (prod_high[1] and 2 * mid) or (prod_sum[1] and mid) or 0
		for i = #res + 1, min_len do
			res[i] = res[i] or 0
		end
		add_shifted(res, prod_sum, mid)
		add_shifted(res, prod_high, 2 * mid)
		return res
	end

	bin_op("mul", product_karatsuba)

	function uint.multiply(dst, src)
		assert(dst.base == src.base)
		dst:copy_from(product_karatsuba(dst, src))
	end

	-- TODO division, modulo

	-- Exponentiation by squaring. Some details have to be different for uints.
	local function fastpow(
		expbase, -- Base (uint)
		exp -- Exponent, non-negative integer
	)
		if exp == 1 then
			return expbase
		end
		local res = expbase.one()
		while exp > 0 do -- loop invariant: `res * expbase^exp = expbase^exp`
			if exp % 2 == 1 then
				-- `res * expbase * expbase^(exp-1) = expbase^exp`
				res = res * expbase
				exp = exp - 1
			else
				-- `res * (expbase^2)^(exp/2) = expbase^exp`
				expbase = expbase * expbase
				exp = exp / 2
			end
		end
		return res
	end

	function mt.__pow(expbase, exp)
		local zero_base = expbase == 0 or expbase == uint.zero()
		if exp == 0 or exp == uint.zero() then
			assert(not zero_base, "0^0")
			return uint.one()
		end
		if zero_base then
			return uint.zero()
		end
		if type(expbase) == "number" then
			expbase = uint.from_number(expbase)
		end
		-- Try conversion of exponent to number for consistency;
		-- taking n^m with n >= 2 and m >= 2^53 wouldn't fit into memory anyways
		if type(exp) ~= "number" then
			exp = assert(exp:to_number(), "exponent too large")
		end
		return fastpow(expbase, exp)
	end

	local function convert_base(self, other_uint)
		if not self[1] then
			return other_uint.zero()
		end
		if not self[2] then
			return other_uint.from_number(self[1])
		end
		local mid = math.floor(#self / 2)
		local low = convert_base(slice(self, 1, mid), other_uint)
		local high = convert_base(slice(self, mid + 1, #self), other_uint)
		-- TODO this fastpow could be optimized with memoization, but shouldn't matter asymptotically
		low:add(high * fastpow(other_uint.from_number(base), mid))
		return low
	end

	--> uint instance of `other_uint`
	function uint:convert_base_to(
		other_uint -- "class" table to convert to
	)
		if not self[1] then
			return other_uint.zero()
		end
		if uint.base == other_uint.base then
			return other_uint.copy(self)
		end
		return convert_base(self, other_uint)
	end

	uints[base] = uint

	return uint
end
