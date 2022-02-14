describe("Heap", function()
	-- Create shuffled list
	local shuffle = require("random.fisher_yates_shuffle")
	local list = {}
	for index = 1, 100 do
		list[index] = index
	end
	shuffle(list)
	-- Test heap
	local heap = require("data_structures.heap")
	local nums = heap.new()
	for index = 1, #list do
		nums:push(list[index])
		assert.equal(index, nums:size())
	end
	for index = 1, #list do
		assert.equal(#list - index + 1, nums:size())
		assert.equal(index, nums:top())
		local popped = nums:pop()
		assert.equal(index, popped)
	end
	assert(nums:empty())
end)
