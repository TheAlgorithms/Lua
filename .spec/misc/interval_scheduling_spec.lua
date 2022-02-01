local interval_scheduling = require("misc.interval_scheduling")
describe("Interval scheduling", function()
	it("should find a largest set of disjoint intervals", function()
		local intervals = {
			{ from = 0, to = 5 },
			{ from = 1, to = 2 },
			{ from = 2, to = 3 },
			{ from = 3, to = 4 },
		}
		assert.same({
			intervals[2],
			intervals[3],
			intervals[4],
		}, interval_scheduling(intervals))
		intervals = {
			{ from = 0, to = 3 },
			{ from = 3, to = 6 },
			{ from = 2, to = 4 },
		}
		assert.same({
			intervals[1],
			intervals[2],
		}, interval_scheduling(intervals))
	end)
	it("should gracefully handle an empty list", function()
		assert.same(interval_scheduling({}), {})
	end)
end)
