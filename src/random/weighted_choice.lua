local binary_search = require("searches.binary_search")

return function(
	weights -- list of weights
)
	-- Linear time preparation
	local val_upper_bounds = {} -- Scaled upper bounds of random value (distribution)
	local sum = 0
	for index, weight in pairs(weights) do
		sum = sum + weight
		val_upper_bounds[index] = sum
	end
	-- Scale to 1
	for index, val_upper_bound in pairs(val_upper_bounds) do
		val_upper_bounds[index] = val_upper_bound / sum
	end
	-- Performs the weighted choice, returns the index of the chosen element
	return function()
		-- Logarithmic time weighted choice
		return math.abs(binary_search(val_upper_bounds, math.random()))
	end
end
