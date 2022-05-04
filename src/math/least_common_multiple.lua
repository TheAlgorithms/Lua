local gcd = require("math.greatest_common_divisor")
return function(
	a, -- number
	b -- number
)
	-- |a * b / gcd(a, b)| reordered in order to keep intermediate results small (to not hit number representation bounds)
	return math.abs(a / gcd(a, b) * b) -- least common multiple of a and b
end
