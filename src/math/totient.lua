local gcd = require("math.greatest_common_divisor")

return function(
  n -- number
)
  local result = 0
  for i = 1, n do
    if gcd(i, n) == 1 then
      result = result + 1
    end
  end
  return result
end
