describe("Random uniform distribution rescaling", function()
	local rescale = require("random.rescale")
	local function test_uniform_distribution(max, random)
		local n = 1e5
		local counts = {}
		for i = 1, max do
			counts[i] = 0
		end
		for _ = 1, n do
			local m = random() + 1
			counts[m] = counts[m] + 1
		end
		local expected_count = n / max
		local stddev = (n * (1 / max) * (1 - 1 / max)) ^ 0.5
		for i = 1, max do
			local dev = math.abs(counts[i] - expected_count)
			assert(dev <= 5 * stddev) -- 5 sigma interval => near certainity
		end
	end
	local function test_rescale(name, max, new_max)
		local function random()
			return math.random(0, max - 1)
		end
		test_uniform_distribution(max, random)
		it(name, function()
			test_uniform_distribution(new_max, rescale(max, new_max, random))
		end)
	end
	test_rescale("no rescaling", 5, 5)
	test_rescale("perfect downscaling", 9, 3)
	test_rescale("perfect upscaling", 3, 9)
	test_rescale("downscaling", 5, 2)
	test_rescale("upscaling", 2, 5)
end)
