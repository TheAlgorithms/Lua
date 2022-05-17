-- Simple primality test that runs in O(sqrt n) time
return function(
	n -- number
)
	if n == 1 then
		return false -- if n is 1
	end
	if n % 2 == 0 then
		return n == 2
	end
	for factor = 3, n ^ 0.5, 2 do -- iterate odd factors up to sqrt(n)
		if n % factor == 0 then
			return false -- if n is a composite number
		end
	end
	return true -- if n is a prime
end
