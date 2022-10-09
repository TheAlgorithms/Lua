-- Logical ("fill with zeros") right shift (">>")
return function(
	n, -- uint53
	shift -- number from 0 to 53
)
	return math.floor(n / 2 ^ shift)
end
