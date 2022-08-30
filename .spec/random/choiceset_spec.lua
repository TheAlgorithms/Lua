describe("Random choice set", function()
	local choiceset = require("random.choiceset")
	it("works as a set", function()
		local set = choiceset.new()
		local sum = 0
		for i = 1, 100 do
			sum = sum + i
			assert(set:add(i))
			assert(not set:add(i))
			assert(set:has(i))
		end
		for i = 1, 100, 2 do -- remove odd numbers
			sum = sum - i
			assert(set:remove(i))
			assert(not set:remove(i))
			assert(not set:has(i))
		end
		for i in set:elements() do
			sum = sum - i
		end
		assert.equal(0, sum)
	end)
	it("provides random choice with equal probabilities", function()
		local set = choiceset.new()
		for i = 1, 100 do
			set:add(i)
		end

		local function check_dist(max)
			local counts = {}
			for i = 1, max do
				counts[i] = 0
			end

			local sum = 0
			local n = 1e6
			for _ = 1, n do
				local chosen = set:choose()
				sum = sum + chosen
				counts[chosen] = counts[chosen] + 1
			end

			-- Check average
			local expected_avg = (max + 1) / 2
			local avg = sum / n
			local deviation = math.abs(expected_avg - avg) / expected_avg
			assert(deviation < 0.1)

			-- The count range shouldn't be too large
			local range = math.max(unpack(counts)) - math.min(unpack(counts))
			local avg_count = 1e6 / (max + 1)
			assert(range < avg_count * 0.1)
		end
		check_dist(100)

		-- Check that rnd. choice continues to work after removing elements
		for i = 11, 100 do
			set:remove(i)
		end
		check_dist(10)
	end)
end)
