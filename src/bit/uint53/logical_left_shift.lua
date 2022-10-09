-- Logical ("fill with zeros") left shift ("<<")
return function(
	n, -- uint53
	shift -- number from 0 to 53
)
	return (n * 2 ^ shift) % 2 ^ 53
end
