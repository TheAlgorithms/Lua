return function(
	list -- list to be shuffled in-place
)
	for index = 1, #list - 1 do
		local index_2 = math.random(index, #list)
		list[index], list[index_2] = list[index_2], list[index]
	end
end
