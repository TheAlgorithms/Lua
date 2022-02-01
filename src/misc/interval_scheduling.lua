-- Earliest Deadline First (EDF) Interval Scheduling
return function(
	intervals -- list of intervals [from, to) as tables with `from` and `to` fields
)
	local selected_intervals = {}
	-- Sort ascending by "deadline"
	table.sort(intervals, function(a, b)
		return a.to < b.to
	end)
	-- Greedily always pick the interval with the first deadline
	table.insert(selected_intervals, intervals[1])
	for _, interval in ipairs(intervals) do
		if interval.from >= selected_intervals[#selected_intervals].to then -- does not collide with selected intervals
			table.insert(selected_intervals, interval)
		end
	end
	-- set of disjoint intervals with maximum cardinality
	return selected_intervals
end
