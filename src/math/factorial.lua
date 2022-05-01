-- Only accurate up to and including n = 22 if Lua 5.1 numbers (doubles) are used
-- Verified using the below Python 3 script:
--[[
	def factorial(x):
		return x if x == 1 else x * factorial(x-1)
	for x in range(1, 1000):
		if factorial(float(x)) != factorial(x):
			print(x)
			break
]]
return function(
	n -- number
)
	local fac = 1
	for m = 2, n do
		fac = fac * m
	end
	return fac -- n!
end
