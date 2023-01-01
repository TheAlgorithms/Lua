-- Dijkstra's Three-Way Partitioning:
-- In-place partitions a slice into three partitions relative to a pivot value:
-- Smaller elements, equal elements, and greater elements
-- See: "Dutch national flag problem"
-- This is primarily a helper function for Quickselect and Quicksort; it is transitively tested through them.
return function(arr, from, to, pivot_val, less_than)
	local i = from -- start index of equal values; everything below is smaller
	local j = from -- start index of unpartitioned values
	local k = to -- start index (exclusive) of larger values
	while j <= k do -- while there are unpartitioned values
		if less_than(arr[j], pivot_val) then -- smaller
			arr[i], arr[j] = arr[j], arr[i] -- swap value to low partition
			i, j = i + 1, j + 1
		elseif less_than(pivot_val, arr[j]) then -- greater
			arr[j], arr[k] = arr[k], arr[j] -- swap value to high partition
			k = k - 1
		else -- equal
			j = j + 1
		end
	end
	return i - 1, k + 1 -- return end index of smaller values and start index of larger values
end
