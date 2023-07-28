-- Given a biased 0-1-random, this removes the bias,
-- returning an unbiased 0-1-random
return function(
	biased_01_random -- function returning `x` or `y` with `x ~= y` but `x == x` and `y == y` with fixed probabilities
)
	return function()
		local x, y
		repeat
			x, y = biased_01_random(), biased_01_random()
		until x ~= y -- the events (0, 1) and (1, 0) are equiprobable
		return x
	end
end
