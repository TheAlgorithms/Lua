local gcd = require("math.greatest_common_divisor")

return function(
	n -- number
)
	local totient = 0
	for i = 1, n do
		if gcd(i, n) == 1 then -- relatively prime?
			totient = totient + 1
		end
	end
	return totient -- number of positive integers less than n that are relatively prime to n
end
