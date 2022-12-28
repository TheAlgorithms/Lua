-- A "prefix aggregate list" stores aggregates over prefixes of a list of values.
-- Range queries can be answered in constant time;
-- appending and removing values at the end is possible in amortized constant time.
-- It requires that the binary operation has an inverse operation.
-- Segment Trees are preferable if this is not the case or random updates are needed.

local pal = {}

function pal.new(
	-- binary operation: `function(a, b)`
	op,
	-- inverse binary operation: `inv_op(op(a, b), a) == b`
	inv_op,
	-- list of values
	vals
)
	vals = vals or {}
	local aggregates = { vals[1] }
	for i = 2, #vals do
		assert(vals[i] ~= nil)
		aggregates[i] = op(aggregates[i - 1], vals[i])
	end
	return { aggregates = aggregates, op = op, inv_op = inv_op }
end

-- Appends a value at the end
function pal:append(
	val -- value to append
)
	assert(val ~= nil)
	local aggregates = self.aggregates
	aggregates[#aggregates + 1] = self.op(aggregates[#aggregates], val)
end

-- Removes the value at the end
function pal:remove()
	local aggregates = self.aggregates
	aggregates[#aggregates] = nil
end

-- Aggregate over a range of values
function pal:aggregate(
	-- starting index of the range, defaults to the first index
	from,
	-- end index of the range, defaults to the last index
	to
)
	local aggregates = self.aggregates
	from, to = from or 1, to or #aggregates
	if from == 1 then -- no aggregate to remove from the result
		return aggregates[to]
	end
	-- Remove aggregate from `1` to `from`
	return self.inv_op(aggregates[to], aggregates[from - 1])
end

return require("class")(pal)
