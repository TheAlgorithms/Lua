describe("Day of Week", function()
	local weekday = require("date.weekday")
	it("works for selected dates", function()
		assert.equal(1, weekday(1969, 7, 20)) -- Sun.
		assert.equal(2, weekday(1776, 7, 1)) -- Mon.
		assert.equal(3, weekday(1781, 3, 13)) -- Tue.
		assert.equal(4, weekday(2022, 5, 4)) -- Wed.
		assert.equal(5, weekday(1989, 11, 9)) -- Thu.
		assert.equal(6, weekday(2022, 10, 7)) -- Fri.
		assert.equal(7, weekday(2000, 1, 1)) -- Sat.
	end)
	it("is consistent with os.date for random dates", function()
		for _ = 1, 1e3 do
			local year, month, day = math.random(1970), math.random(12), math.random(28)
			assert.equal(
				os.date("*t", os.time({ year = year, month = month, day = day })).wday,
				weekday(year, month, day)
			)
		end
	end)
end)
