-- Build a lookup table of counts per byte
local byte_ones = {}
for byte = 0, 0xFF do
	local ones = 0
	-- Iterate over the bits of the byte
	local i = byte
	while i > 0 do
		local bit = i % 2
		ones = ones + bit
		i = (i - bit) / 2
	end
	byte_ones[byte] = ones
end

-- Count set bits ("ones"); also known as "population count"
return function(
	n -- uint53
)
	local ones = 0
	while n ~= 0 do
		local byte = n % 0x100 -- extract least significant byte
		ones = ones + byte_ones[byte] -- look up & add to count
		n = (n - byte) / 0x100 -- reduce n: proceed with next byte
	end
	return ones -- set bits in the binary representation of n
end
