describe("Linked deque", function()
	local linked_deque = require("data_structures.linked_deque")
	local deque = linked_deque.new()
	it("pushing, popping & getting works", function()
		assert.truthy(deque:empty())
		for i = 1, 10 do
			deque:push_head(i)
			assert.equal(i, deque:get_head())
		end
		for i = 1, 10 do
			assert.equal(i, deque:get_tail())
			assert.equal(i, deque:pop_tail())
		end
		assert.truthy(deque:empty())
		for i = 1, 10 do
			deque:push_tail(i)
			assert.equal(i, deque:get_tail())
		end
		for i = 1, 10 do
			assert.equal(i, deque:get_head())
			assert.equal(i, deque:pop_head())
		end
		assert.truthy(deque:empty())
	end)
	it("iteration works", function()
		for i = 1, 10 do
			deque:push_tail(i)
		end
		local expected_i = 0
		for i in deque:values() do
			expected_i = expected_i + 1
			assert.equal(expected_i, i)
		end
		assert.equal(10, expected_i)
		for i in deque:rvalues() do
			assert.equal(expected_i, i)
			expected_i = expected_i - 1
		end
		assert.equal(0, expected_i)
	end)
end)
