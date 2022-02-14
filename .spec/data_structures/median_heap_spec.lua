describe("Median heap", function()
	local median_heap = require("data_structures.median_heap")
	local heap = median_heap.new()
	for i = 1, 100 do
		heap:push(i)
	end
	assert.equal(50, heap:top())
	assert.equal(50, heap:pop())
	assert.equal(51, heap:pop())
end)
