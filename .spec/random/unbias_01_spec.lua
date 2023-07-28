it("Unbiasing 0-1-random", function()
	local unbias_01 = require("random.unbias_01")
	local function biased_01_random()
		return math.random() < 0.9
	end
	local unbiased_random = unbias_01(biased_01_random)
	-- Count successes and check whether it's close enough to the expected count
	local n = 1e5
	local successes = 0
	for _ = 1, n do
		successes = successes + (unbiased_random() and 1 or 0)
	end
	local stddev = n ^ 0.5 / 2
	local dev = math.abs(successes - n / 2)
	assert(dev <= 5 * stddev) -- 5 sigma interval => near certainity
end)
