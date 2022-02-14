describe("Table list", function()
	local table_list = require("data_structures.table_list")
	local list = table_list.new({ 1, 2, 3 })
	assert.equal(3, list:len())
	for i = 1, 3 do
		assert.truthy(list:in_bounds(i))
		assert.equal(i, list:get(i))
		list:set(i, i)
		assert(i, list:get(i))
	end
	local expected_index = 0
	for index, element in list:ipairs() do
		expected_index = expected_index + 1
		assert(expected_index <= 3)
		assert.equal(expected_index, index)
		assert.equal(index, element)
	end
	for index, element in list:rpairs() do
		assert.truthy(expected_index >= 1)
		assert.equal(expected_index, index)
		assert.equal(index, element)
		expected_index = expected_index - 1
	end
	list:push_head(0)
	assert.equal(0, list:get_head())
	list:push_tail(4)
	assert.equal(4, list:get_tail())
	assert.equal(5, list:len())
	for i = 1, 5 do
		assert.equal(i - 1, list:get(i))
	end
	list:pop_head()
	list:pop_tail()
	assert(3, list:len())
	for i = 1, 3 do
		assert.equal(i, list:get(i))
	end
end)
