-- Fisher-Yates shuffle
return function(
	list -- list to be shuffled in-place
)
	for i = 1, #list - 1 do
		local j = math.random(i, #list)
		list[i], list[j] = list[j], list[i]
	end
end
