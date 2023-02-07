-- Simple union-find / disjoint-set data structure

local union_find = {}

function union_find.new()
	return {}
end

-- Create a set containing only `elem`
function union_find:make_set(elem)
	assert(not self[elem], "element already exists")
	self[elem] = { elem }
end

-- Union the sets of the two representants;
-- n union operations run in time O(n log n)
function union_find:union(rep_1, rep_2)
	local larger_set, smaller_set = self[rep_1], self[rep_2]
	if larger_set == smaller_set then
		return -- same set, nothing to do
	end
	if #larger_set < #smaller_set then
		larger_set, smaller_set = smaller_set, larger_set
	end
	-- Add the elements of the smaller set to the larger set
	for _, elem in ipairs(smaller_set) do
		table.insert(larger_set, elem)
		self[elem] = larger_set
	end
end

-- Return any representant of the set containing `elem`
function union_find:find(elem)
	return assert(self[elem], "element doesn't exist")[1]
end

return require("class")(union_find)
