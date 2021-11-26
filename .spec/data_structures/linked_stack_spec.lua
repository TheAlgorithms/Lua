describe("Linked stack", function()
	local linked_stack = require("data_structures.linked_stack")
	it("should work", function()
		local stack = linked_stack.new()
		assert.truthy(stack:empty())
		for i = 1, 10 do
			stack:push(i)
		end
		for i = 10, 1, -1 do
			assert.equals(stack:top(), i)
			assert.equals(stack:pop(), i)
		end
		assert.truthy(stack:empty())
	end)
end)
