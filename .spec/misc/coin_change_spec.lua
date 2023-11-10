local coin_change = require("misc.coin_change")
describe("Coin change", function()
	it("should find a set of coins with minimal count and correct sum", function()
		for value, count in pairs({
			[13] = 3,
			[33] = 4,
			[42] = 3,
			[50] = 1,
		}) do
			local coin_values = coin_change(value, { 1, 2, 5, 10, 20, 50 })
			assert(count, #coin_values)
			local sum = 0
			for _, coin_value in ipairs(coin_values) do
				sum = sum + coin_value
			end
			assert(sum == value)
		end
	end)
end)
