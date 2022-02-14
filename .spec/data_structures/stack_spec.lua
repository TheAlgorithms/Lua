local function test_stack(stack_class)
	it("should work", function()
		local stack = stack_class.new()
		assert.truthy(stack:empty())
		for i = 1, 10 do
			stack:push(i)
		end
		for i = 10, 1, -1 do
			assert.equal(i, stack:top())
			assert.equal(i, stack:pop())
		end
		assert.truthy(stack:empty())
	end)
end
describe("Linked stack", function()
	test_stack(require("data_structures.linked_stack"))
end)
describe("Table stack", function()
	test_stack(require("data_structures.table_stack"))
end)
