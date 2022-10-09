return function(
	any -- any value
)
	-- whether any is an unsigned integer number representable using 53 bits ("uint53")
	return type(any) == "number" and any % 1 == 0 and any >= 0 and any < 2 ^ 53
end
