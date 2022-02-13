local gcd = require("numeric.greatest_common_divisor")
return function(
	a, -- number
	b -- number
)
	return math.abs(a * b) / gcd(a, b) -- least common multiple of a and b
end
