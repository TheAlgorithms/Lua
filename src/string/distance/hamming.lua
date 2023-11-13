-- computs the Hemming "edit" distance, i.e.
-- for the strings of the same length,
-- the number of indices at which the corresponding characters are different.
return function(
	a, --- some string
	b --- other string
)
	assert(#a == #b, "inputs must have the same length.")
	local res = 0
	for i = 1, #a do
		if string.byte(a, i) ~= string.byte(b, i) then
			res = res + 1
		end
	end
	return res
end
