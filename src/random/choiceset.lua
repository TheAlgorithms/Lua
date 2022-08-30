-- Set that allows for O(1) random choice by keeping both
-- an unordered list of elements and a hash map of indices

local choiceset = {}

choiceset.random = math.random

function choiceset.new(
	-- function(n) -> random int between 1 & j (both inclusive)
	-- defaults to `math.random`
	random
)
	return { random = random, idx = {} }
end

function choiceset:add(element)
	if self.idx[element] then
		return -- element already in set
	end
	self[#self + 1] = element -- append to list
	self.idx[element] = #self -- update hash map
	return true -- element added to set
end

function choiceset:has(element)
	return not not self.idx[element] -- boolean: whether the set contains the element
end

function choiceset:remove(element)
	local idx = self.idx[element]
	if not idx then
		return -- set doesn't contain element
	end
	-- Replace element at position idx with last element...
	local last_element = self[#self]
	self[idx] = last_element
	self.idx[last_element] = idx
	-- ... then remove the last element
	self[#self] = nil
	self.idx[element] = nil
	return true -- element was removed
end

function choiceset:choose()
	-- randomly chosen element of the set; equal probabilities
	return self[self.random(#self)]
end

local function next_key(table, key)
	return (next(table, key))
end

function choiceset:elements()
	return next_key, self.idx, nil -- iterator to loop over the elements
end

return require("class")(choiceset)
