-- Segment Trees are - except for the last layer, which may have gaps - complete binary trees of aggregate values.
-- They allow - assuming a constant time operator - logarithmic time range queries and updates on an array,
-- requiring only linear build time & space and demanding a semigroup (associative) operator.

local segment_tree = {}

-- Build a segment tree in linear time
function segment_tree.new(
	-- `function(a, b)`, semigroup operator
	binary_op,
	-- list of values the binary operation accepts
	vals
)
	vals = vals or {}
	local nodes = {}
	local function build(idx, from, to)
		if from == to then
			-- TODO this may land in the hash part, which is unnecessary
			-- for every layer but the last layer (which may have gaps);
			-- consider using a BFS instead
			nodes[idx] = vals[from]
			return
		end
		local left_idx, right_idx = 2 * idx, 2 * idx + 1 -- indices of left / right child
		local mid = math.floor((from + to) / 2) -- mid index (in list)
		build(left_idx, from, mid) -- build left tree
		build(right_idx, mid + 1, to) -- build right tree
		nodes[idx] = binary_op(nodes[left_idx], nodes[right_idx]) -- combine children
	end
	if #vals > 0 then
		build(1, 1, #vals)
	end
	-- Segment Tree
	return {
		op = binary_op,
		len = #vals,
		nodes = nodes,
	}
end

-- Update a value in the array
function segment_tree:update(
	idx, --[[index]]
	val --[[new value]]
)
	local op, nodes = self.op, self.nodes
	local function set(seg_idx, seg_from, seg_to)
		if seg_from == seg_to then -- leaf reached
			assert(idx == seg_from, "out of bounds")
			nodes[seg_idx] = val -- update
			return
		end
		-- Update either the left or right child, depending on where the index lies
		local seg_mid = math.floor((seg_from + seg_to) / 2)
		local left_idx, right_idx = 2 * seg_idx, 2 * seg_idx + 1
		if idx <= seg_mid then
			set(left_idx, seg_from, seg_mid)
		else
			set(right_idx, seg_mid + 1, seg_to)
		end
		-- Recombine left & right child
		nodes[seg_idx] = op(nodes[left_idx], nodes[right_idx])
	end
	set(1, 1, self.len)
end

function segment_tree:aggregate(
	-- starting index of the range, defaults to the first index
	from,
	-- end index of the range, defaults to the last index
	to
)
	from, to = from or 1, to or self.len
	local op, nodes = self.op, self.nodes
	local function get(seg_idx, seg_from, seg_to, want_from, want_to)
		if want_from == seg_from and want_to == seg_to then
			return nodes[seg_idx] -- wanted segment matches segment exactly, return
		end

		local seg_mid = math.floor((seg_from + seg_to) / 2)
		local left_idx, right_idx = 2 * seg_idx, 2 * seg_idx + 1
		if want_to <= seg_mid then -- wanted segment is part of the left child
			return get(left_idx, seg_from, seg_mid, want_from, want_to)
		end
		if want_from >= seg_mid + 1 then -- wanted segment is part of the right child
			return get(right_idx, seg_mid + 1, seg_to, want_from, want_to)
		end
		-- Wanted segment contains parts from both the left & right child;
		-- continue search there to combine the two results afterwards.
		-- Note that runtime is still logarithmic since it can be shown
		-- that at most two nodes are visited at each level.
		return op(
			get(left_idx, seg_from, seg_mid, want_from, seg_mid),
			get(right_idx, seg_mid + 1, seg_to, seg_mid + 1, want_to)
		)
	end
	return get(1, 1, self.len, from, to)
end

return require("class")(segment_tree)
