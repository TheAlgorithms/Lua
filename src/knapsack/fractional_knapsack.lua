return function(items)
	-- Sort descending by efficiency (profit / weight)
	table.sort(items, function(a, b)
		return (a.profit / a.weight) > (b.profit / b.weight)
	end)
	return function(capacity)
		local capacity_left = capacity
		local total_profit = 0
		local chosen_items = {}
		local index = 1
		while index <= #items and capacity_left > 0 do
			local item = items[index]
			local portion = math.min(1, capacity_left / item.weight)
			table.insert(chosen_items, { item = item, portion = portion })
			total_profit = total_profit + item.profit * portion
			capacity_left = capacity_left - item.weight * portion
			index = index + 1
		end
		return total_profit, chosen_items
	end
end
