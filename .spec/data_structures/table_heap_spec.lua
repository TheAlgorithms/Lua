describe("Table heap", function()
	local table_heap = require("data_structures.table_heap")
	local shuffle = require("random.shuffle")

	local list = {}
	for index = 1, 100 do
		list[index] = index
	end
	shuffle(list)
	local heap = table_heap.new()
	for index = 1, #list do
		heap:push(list[index])
	end
	for index = 1, #list do
		local popped = heap:pop()
		assert.equal(index, popped)
	end
	heap = table_heap.new()
	for i = 1, 100 do
		heap:push(i)
	end
	heap:replace(42, 0)
	assert.equal(0, heap:pop())
	heap:replace(69, 101)
	assert.falsy(heap:find_index(69))
	assert.truthy(heap:find_index(101))
	heap:remove(101)
	assert.falsy(heap:find_index(101))
	heap:push(101)
	local last = 0
	for _ = 1, 98 do
		local new = heap:pop()
		assert.truthy(new > last)
		last = new
	end
	assert.equal(101, heap:pop())
end)
