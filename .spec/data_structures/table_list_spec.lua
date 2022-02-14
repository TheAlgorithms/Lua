describe("Table list", function()
	local table_list = require("data_structures.table_list")
	local list = table_list.new({ 1, 2, 3 })
	assert.equals(3, list:len())
	for i = 1, 3 do
		assert.truthy(list:in_bounds(i))
		assert.equals(i, list:get(i))
		list:set(i, i)
		assert(i, list:get(i))
	end
	local expected_index = 0
	for index, element in list:ipairs() do
		expected_index = expected_index + 1
		assert(expected_index <= 3)
		assert.equals(expected_index, index)
		assert.equals(index, element)
	end
	for index, element in list:rpairs() do
		assert.truthy(expected_index >= 1)
		assert.equals(expected_index, index)
		assert.equals(index, element)
		expected_index = expected_index - 1
	end
	list:push_head(0)
	assert.equals(0, list:get_head())
	list:push_tail(4)
	assert.equals(4, list:get_tail())
	assert.equals(5, list:len())
	for i = 1, 5 do
		assert.equals(i - 1, list:get(i))
	end
	list:pop_head()
	list:pop_tail()
	assert(3, list:len())
	for i = 1, 3 do
		assert.equals(i, list:get(i))
	end
end)
