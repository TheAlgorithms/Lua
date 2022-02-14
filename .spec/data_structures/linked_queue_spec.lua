describe("Linked queue", function()
	local linked_queue = require("data_structures.linked_queue")
	it("should work", function()
		local queue = linked_queue.new()
		assert.truthy(queue:empty())
		for i = 1, 10 do
			queue:push(i)
		end
		for i = 1, 10 do
			assert.equal(i, queue:top())
			assert.equal(i, queue:pop())
		end
		assert.truthy(queue:empty())
	end)
end)
