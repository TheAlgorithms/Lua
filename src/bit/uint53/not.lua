-- Build lookup table for bytes
local bytes = {}
for byte = 0, 0xFF do
	local res = 0
	for i = 0, 7 do -- iterate over bits
		local bit = math.floor(byte / (2 ^ i)) % 2
		res = res + 2 ^ i * (1 - bit)
	end
	bytes[byte] = res
end

return function(
	n -- uint53
)
	local res = 0
	local bit = 1
	-- First process byte-wise to leverage the lookup table
	while n >= 0xFF do
		local byte = n % 0x100
		res = res + bytes[byte] * bit
		n = (n - byte) / 0x100
		bit = bit * 0x100
	end
	-- Then process the remaining < 8 bits until only (leading) zeroes are left
	while n ~= 0 do
		local n_bit = n % 2 -- extract LSB
		res = res + (1 - n_bit) * bit
		n = (n - n_bit) / 2
		bit = bit * 2 -- next bit
	end
	local leading_ones = 2 ^ 53 - bit
	return leading_ones + res
end
