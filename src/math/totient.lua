-- The totient function returns the number of positive integers less than n that are relatively prime to n

local gcd = require("math.greatest_common_divisor")

return function(
  n -- number
)
  local result = 0
  for i = 1, n do
    if gcd(i, n) == 1 then -- check if relatively prime
      result = result + 1
    end
  end
  return result
end
