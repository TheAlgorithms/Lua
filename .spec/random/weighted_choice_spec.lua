describe("Weighted choice", function()
	local weighted_choice = require("random.weighted_choice")
	it("evenly distributes choices according to weights", function()
		local items, runs = 10, 1e5
		for _ = 1, 10 do
			local sum = 0
			local weights, counts = {}, {}
			for i = 1, items do
				local rnd = math.random()
				sum = sum + rnd
				weights[i] = rnd
				counts[i] = 0
			end
			local choose = weighted_choice(weights)
			for _ = 1, runs do
				local chosen = choose()
				counts[chosen] = counts[chosen] + 1
			end
			for i = 1, items do
				local diff = math.abs(weights[i] / sum - counts[i] / runs)
				assert.truthy(diff < 1e-2)
			end
		end
	end)
end)
