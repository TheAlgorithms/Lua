local fractional_knapsack = require("knapsack.fractional_knapsack")
describe("Fractional knapsack", function()
	it("should maximize profit & choose the corresponding items", function()
		-- Store items in local variables as the items table is sorted in-place
		local a, b, c = { profit = 1, weight = 10 }, { profit = 10, weight = 1 }, { profit = 2, weight = 2 }
		local solution = fractional_knapsack({ a, b, c })
		assert.same({ 10, {
			{ item = b, portion = 1 },
		} }, { solution(1) })
		assert.same({ 11, {
			{ item = b, portion = 1 },
			{ item = c, portion = 0.5 },
		} }, { solution(2) })
		assert.same({ 12, {
			{ item = b, portion = 1 },
			{ item = c, portion = 1 },
		} }, { solution(3) })
		assert.same({
			13,
			{
				{ item = b, portion = 1 },
				{ item = c, portion = 1 },
				{ item = a, portion = 1 },
			},
		}, { solution(1e3) })
	end)
	it("should handle empty item sets", function()
		assert.same({ 0, {} }, { fractional_knapsack({})(10) })
		assert.same({ 0, {} }, { fractional_knapsack({})(42) })
	end)
end)
