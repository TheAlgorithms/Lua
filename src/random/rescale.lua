local function downscale(max, new_max, random)
	-- We divide `max` into sections of length `new_max`.
	-- To not skew the results, we have to ignore a possible last segment of length `< new_max`.
	local max_i = max - max % new_max -- all exclusive
	return function()
		-- Since the probability of landing in this last segment is `< 1/2`,
		-- the probability of this loop requiring `i` iterations is at most `(1/2)^(i-1)`;
		-- it runs in expected constant time
		local i
		repeat
			i = random()
		until i < max_i
		return i % new_max
	end
end

local function upscale(max, new_max, random)
	-- Upscaled, possibly "overscaled" random
	local function upscaled_random()
		local res, pow = 0, 1
		repeat
			res = res + pow * random()
			pow = pow * max
		until pow >= new_max
		return res
	end
	-- This will be dwarfed by calls to `upscaled_random` anyways
	local pow = 1
	repeat
		pow = pow * max
	until pow >= new_max
	if pow == new_max then
		return upscaled_random
	end
	-- The `upscaled_random` overshoots, so we need to downscale it
	return downscale(pow, new_max, upscaled_random)
end

-- Rescales the value range of an equally distributed discrete random source without skewing it
--> discrete random source returning numbers from `0` to `new_max` with equal probabilities
return function(
	max, -- maximum value produced by the random source, **exclusive**
	new_max, -- new maximum value the rescaled random source should produce, **exclusive**
	random -- uniform random source returning integers from 0 (inclusive) to `max` (**exclusive**)
)
	if new_max == max then
		return random
	end
	if new_max < max then
		return downscale(max, new_max, random)
	end
	return upscale(max, new_max, random)
end
