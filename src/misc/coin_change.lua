return function(
	-- value to be achieved as a coin sum
	target_value,
	-- list of available coin values
	coin_values
)
	local values = { [0] = { count = 0 } }
	for value = 1, target_value do
		for _, coin_value in ipairs(coin_values) do
			if coin_value <= value then
				local count_using_coin = values[value - coin_value].count + 1
				if not values[value] or count_using_coin < values[value].count then
					values[value] = { count = count_using_coin, used_coin_value = coin_value }
				end
			end
		end
	end
	local used_coin_values = {}
	while target_value > 0 do
		local used_coin_value = values[target_value].used_coin_value
		table.insert(used_coin_values, used_coin_value)
		target_value = target_value - used_coin_value
	end
	-- values may appear multiple times in the list if a coin is used multiple times
	return used_coin_values
end
