describe("Heap", function()
	local shuffle = require("random.shuffle")
	local heap = require("data_structures.heap")
	local function test(aspect, build)
		it(aspect, function()
			-- Create shuffled list
			local list = {}
			for index = 1, 100 do
				list[index] = index
			end
			shuffle(list)
			-- Build heap
			local nums = build(list)
			-- Pop elements
			for index = 1, #list do
				assert.equal(#list - index + 1, nums:size())
				assert.equal(index, nums:top())
				local popped = nums:pop()
				assert.equal(index, popped)
			end
			assert(nums:empty())
		end)
	end
	test("building & popping", function(list)
		-- Copy the list because the constructor won't do it for us
		-- and we need to keep the original list intact for our tests
		local copy = {}
		for i, num in ipairs(list) do
			copy[i] = num
		end
		return heap.new(copy)
	end)
	test("inserting & popping", function(list)
		-- Build heap by inserting elements one by one
		local nums = heap.new()
		assert(nums:empty())
		for i, num in ipairs(list) do
			nums:push(num)
			assert.equal(i, nums:size())
		end
		return nums
	end)
end)
