local heap = require("data_structures.heap")
return function(
	-- list to be sorted in-place
	list,
	-- function(a, b) -> truthy value if a < b
	less_than
)
	local elements = heap.new(less_than)
	for _, value in ipairs(list) do
		elements:push(value)
	end
	for index = 1, #list do
		list[index] = elements:pop()
	end
end
