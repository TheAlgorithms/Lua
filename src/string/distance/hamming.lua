-- Computes the Hamming "edit" distance for two strings of the same length:
-- The number of indices at which the corresponding bytes are different.
return function(
	a, -- some string
	b -- other string
)
	assert(#a == #b, "lengths don't match")
	local dist = 0
	for i = 1, #a do
		if a:byte(i) ~= b:byte(i) then
			dist = dist + 1
		end
	end
	return dist
end
