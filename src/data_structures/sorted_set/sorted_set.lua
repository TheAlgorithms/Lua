-- "Abstract" common base "class" for dynamic sorted sets;
-- serves code and documentation deduplication purposes

local sorted_set = {}

function sorted_set.less_than(a, b)
	return a < b
end

-- "Abstract" functions for documentation purposes

--> a sorted set instance containing all `keys` and ordered by `less_than`
--: keys optional list of keys (defaults to `{}`), **must be sorted ascendingly by `less_than`**
--: less_than optional comparator `function(a, b)`, defaults to `sorted_set.less_than`
--$ function sorted_set.new(keys, less_than)

--> whether the sorted set is empty
--$ function sorted_set:empty()

-- Clears (empties) the sorted set
--$ function sorted_set:clear()

-- Copies the sorted set, but does not copy the keys
--$ function sorted_set:copy()

-- Find a key in the sorted set
--> the equal (as per `self.less_than`) key in the set if found
--> `nil` if not found
--$ function sorted_set:find(key)

--> whether `key` is in the sorted set
function sorted_set:has(key)
	return self:find(key) ~= nil
end

--> `nil` if `self` is empty
--> the smallest key (per `self.less_than`) otherwise
--$ function sorted_set:min()

--> `nil` if `self` is empty
--> the largest key (per `self.less_than`) otherwise
--$ function sorted_set:max()

--: key optional key
--> `self:min()` if `key == nil`
--> the smallest key in `self` which is larger than `key`
--> `nil` if `self` is empty or `key` is at least `self:max()`
--! Prefer `self:range_ascending` or `self:ascending` over repeatedly calling this for iteration
--$ function sorted_set:succ(key)

--: key optional key
--> `self:max()` if `key == nil`
--> the largest key in `self` which is smaller than `key`
--> `nil` if `self` is empty or `key` is at most `self:min()`
--! Prefer `self:range_descending` or `self:descending` over repeatedly calling this for iteration
--$ function sorted_set:pred(key)

--: from start element, defaults to `self:min()`
--: to end element, defaults to `self:max()`
--> non-restartable iterator over all elements in the inclusive range [from, to] in ascending order
--> non-restartable empty iterator if `to < from`
--$ function sorted_set:range_ascending(from, to)

--: from start element, defaults to `self:min()`
--: to end element, defaults to `self:max()`
--> non-restartable iterator over all elements in the inclusive range [from, to] in descending order
--> non-restartable empty iterator if `to < from`
--$ function sorted_set:range_descending(from, to)

--> non-restartable iterator over all elements in `self` in ascending order
--$ function sorted_set:ascending()

--> non-restartable iterator over all elements in `self` in descending order
--$ function sorted_set:descending()

--: key the key to insert
--: upsert optional, whether to replace an existing key, `false` by default
--> the value of `self:find(key)` before the insertion
--! Do not use this for filling empty sets. Instead, directly build the set from a list.
--$ function sorted_set:insert(key, upsert)

--: key the key to remove
--> the value of `self:find(key)` before the removal
--$ function sorted_set:remove(key)

-- Uses a simple sorted merge
local function setop(
	self, -- determines the resulting class
	other,
	add_self, -- whether to add elements in `self` but not in `other`
	add_common, -- whether to add elements common to both sets
	add_other -- whether to add elements in `self` but not in `self`
)
	assert(self.less_than == other.less_than, "inequal orderings")
	local less_than = self.less_than
	-- Note: This assumes that the iterators are closures and don't rely on an invariant state / control variable.
	local next_self = self:ascending()
	local next_other = other:ascending()
	local elems = {}
	local elem_self, elem_other = next_self(), next_other()
	while elem_self ~= nil and elem_other ~= nil do
		if less_than(elem_self, elem_other) then
			if add_self then
				table.insert(elems, elem_self)
			end
			elem_self = next_self()
		elseif less_than(elem_other, elem_self) then
			if add_other then
				table.insert(elems, elem_other)
			end
			elem_other = next_other()
		else -- equal
			if add_common then
				table.insert(elems, elem_self)
			end
			elem_self, elem_other = next_self(), next_other()
		end
	end
	if add_self then
		while elem_self ~= nil do
			table.insert(elems, elem_self)
			elem_self = next_self()
		end
	end
	if add_other then
		while elem_other ~= nil do
			table.insert(elems, elem_other)
			elem_other = next_other()
		end
	end
	return self.new(elems)
end

--> sorted set containing the keys of `self` and `other`; uses the class of `self`
function sorted_set:union(other)
	return setop(self, other, true, true, true)
end

--> sorted set containing the keys of `self` and `other`; uses the class of `self`
function sorted_set:difference(other)
	return setop(self, other, true, false, false)
end

--> sorted set containing the keys which are exclusively in `self` or `other`
function sorted_set:symmetric_difference(other)
	return setop(self, other, true, false, true)
end

--> sorted set containing the keys of `self` which are also in `other`
function sorted_set:intersection(other)
	return setop(self, other, false, true, false)
end

return sorted_set
