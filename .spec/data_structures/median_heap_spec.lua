describe("Median heap", function()
	local median_heap = require("data_structures.median_heap")
	it("constructs the correct heap when inserting sorted elements", function()
		local heap = median_heap.new()
		for i = 1, 100 do
			heap:push(i)
		end
		assert.equal(100, heap:size())
		assert.equal(50, heap:top())
		assert.equal(50, heap:pop())
		assert.equal(51, heap:pop())
	end)
	it("constructs the correct heap when inserting sorted elements in reverse", function()
		local heap = median_heap.new()
		for i = 100, 1, -1 do
			heap:push(i)
		end
		assert.equal(100, heap:size())
		assert.equal(50, heap:top())
		assert.equal(50, heap:pop())
		assert.equal(51, heap:pop())
	end)
	it("works when inserting and popping some elements", function()
		local heap = median_heap.new()
		heap:push(3)
		heap:push(2)
		heap:push(10)
		heap:push(1)
		heap:push(7)
		-- Numbers in heap: 1, 2, 3, 7, 10
		assert.equal(3, heap:top())
		assert.equal(5, heap:size())
		assert.equal(3, heap:pop())
		-- Numbers in heap: 1, 2, 7, 10
		assert.equal(4, heap:size())
		assert.equal(2, heap:pop())
		-- Numbers in heap: 1, 7, 10
		assert.equal(3, heap:size())
		assert.equal(7, heap:pop())
		-- Numbers in heap: 1, 10
		assert.equal(2, heap:size())
		assert.equal(1, heap:pop())
		-- Numbers in heap: 10
		assert.equal(1, heap:size())
		assert.equal(10, heap:pop())
		assert.equal(0, heap:size())
	end)
end)
