describe("Arithmetic progression", function()
	local arithmetic_progression = require("math.sum.arithmetic_progression")
	-- Compare against a simple for loop
	local function arithmetic_progression_loop(from, to, step)
		local sum = 0
		for i = from, to, step do
			sum = sum + i
		end
		return sum
	end
	it("returns the correct sum", function()
		for step = 1, 5 do
			for from = 1, 10 do
				for to = from, 100 do
					assert.equal(arithmetic_progression_loop(from, to, step), arithmetic_progression(from, to, step))
				end
			end
		end
	end)
end)
