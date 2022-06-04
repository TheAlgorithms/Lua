-- Simple implementation of a nondeterministic bogosort
-- Never use this algorithm in practice! Purely for illustrational purposes.

local is_sorted = require("sorting.is_sorted")
local shuffle = require("random.shuffle")

return function(list, less_than)
	while not is_sorted(list, less_than) do
		shuffle(list)
	end
end
