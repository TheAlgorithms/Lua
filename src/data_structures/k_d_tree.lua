-- k-d trees are k-dimensional binary search trees.
-- They are particularly suitable for answering nearest neighbor queries after preprocessing a set of points.

local k_d_tree = {}
local metatable = { __index = k_d_tree }

local function constructor(build_root)
	return function(points)
		if #points == 0 then
			return setmetatable({}, metatable)
		end
		local dimension = #points[1]
		for i = 2, #points do
			assert(#points[i] == dimension)
		end
		return setmetatable({ _root = build_root(points, dimension) }, metatable)
	end
end

-- Constructs a k-d-tree by repeatedly sorting the points (and sublists thereof) by a given axis.
-- Time complexity of O(k*n log n) where k is the number of dimensions.
-- Small constant factors, suitable for few dimensions.
--: points list of points (`math.vector`s)
k_d_tree.new_presorting = constructor(function(points, dimension)
	-- Out-of-band values for partitioning the points
	local value = {}
	for i = 1, #points do
		value[i] = 0
	end
	-- Presort indices by every axis
	local presorted = {}
	for axis = 1, dimension do
		local idx = {}
		for i = 1, #points do
			idx[i] = i
		end
		table.sort(idx, function(i, j)
			return points[i][axis] < points[j][axis]
		end)
		presorted[axis] = idx
	end
	local function build(from, to, axis)
		if to < from then
			return
		end
		local mid = math.floor((from + to) / 2)
		local pidx_by_axis = presorted[axis]
		local midx = pidx_by_axis[mid]
		value[midx] = 0
		for i = from, mid - 1 do
			value[pidx_by_axis[i]] = -1
		end
		for i = mid + 1, to do
			value[pidx_by_axis[i]] = 1
		end
		local function partition_axis(a)
			local pidx_by_a = presorted[a]
			-- TODO (?) can we get rid of this allocation?
			-- Note that we can't use `sorting.three_way_partition`,
			-- since that doesn't preserve the relative order (it is not a stable partition).
			-- Linear time stable partitioning without using an extra "buffer" doesn't seem to be possible.
			local right = {}
			local i = from
			for j = from, to do
				local pidx = pidx_by_a[j]
				if value[pidx] == -1 then
					-- Move point to next slot
					pidx_by_a[i] = pidx
					i = i + 1
				elseif value[pidx] == 1 then
					-- Remember values to the right (these are overwritten)
					table.insert(right, pidx)
				end
			end
			pidx_by_a[i] = midx
			for j = 1, #right do
				i = i + 1
				pidx_by_a[i] = right[j]
			end
		end
		for a = 1, axis - 1 do
			partition_axis(a)
		end
		for a = axis + 1, dimension do
			partition_axis(a)
		end
		local next_axis = axis + 1
		if next_axis > dimension then
			next_axis = 1
		end
		return {
			[true] = build(from, mid - 1, next_axis),
			[false] = build(mid + 1, to, next_axis),
			pivot = points[midx],
		}
	end
	return build(1, #points, 1)
end)

-- Partitions a sorted list evenly into a pivot and lists of values left and right to the pivot
local function partition(sorted)
	local mid = math.ceil(#sorted / 2) -- note: use `ceil` since indices are 1-based
	local leq, geq = {}, {}
	for i = 1, mid - 1 do
		leq[i] = sorted[i]
	end
	for i = mid + 1, #sorted do
		table.insert(geq, sorted[i])
	end
	return leq, sorted[mid], geq
end

-- Constructs a k-d-tree by repeatedly sorting the points (and sublists thereof) by a given axis.
-- Time complexity of O((log n)^2 n).
-- Use this for small n if the constant factors are good.
--: points list of points (`math.vector`s)
k_d_tree.new_sorting = constructor(function(points, dimension)
	local function build(points, axis) -- luacheck: ignore
		if #points == 0 then
			return
		end
		table.sort(points, function(p, q)
			return p[axis] < q[axis]
		end)
		-- We can't partition in place here since `table.sort` doesn't allow passing from & to indices.
		-- TODO (?) use custom sorting function to allow for in-place partitioning?
		local leq, pivot, geq = partition(points)
		local next_axis = axis + 1
		if next_axis > dimension then
			next_axis = 1
		end
		return {
			[true] = build(leq, next_axis),
			[false] = build(geq, next_axis),
			pivot = pivot,
		}
	end
	return build(points, 1)
end)

local quickselect = require("sorting.quickselect_median_of_medians")

-- Constructs a k-d-tree by repeatedly partitioning the points in-place by a given axis,
-- determining a median in linear time using quickselect with medians of medians as the pivot picking strategy.
-- Asymptotically optimal time complexity of O(n log n).
-- Prefer this over the other two methods if in doubt
-- (unless benchmarking shows this method having higher constant factors for your use case).
--: points list of points (`math.vector`s)
k_d_tree.new_median_of_medians = constructor(function(points, dimension)
	local function build(from, to, axis)
		if to < from then
			return
		end
		local index = math.ceil((to - from + 1) / 2)
		-- The call to quickselect also partitions the slice.
		-- It even ultimately induces a tree structure in the resulting table
		-- (the resulting table is the inorder traversal of the tree).
		-- Yet we still build a linked tree structure to allow efficient insertion of points.
		local mid = quickselect(points, index, function(p, q)
			return p[axis] < q[axis]
		end, from, to)
		local next_axis = axis + 1
		if next_axis > dimension then
			next_axis = 1
		end
		return {
			[true] = build(from, mid - 1, next_axis),
			[false] = build(mid + 1, to, next_axis),
			pivot = points[mid],
		}
	end
	return build(1, #points, 1)
end)

-- Median of medians is chosen as the default construction strategy for its optimal time complexity.
--: points list of points (`math.vector`s)
k_d_tree.new = k_d_tree.new_median_of_medians

function k_d_tree:empty()
	return self._root == nil
end

function k_d_tree:nearest_neighbor(
	point -- `math.vector`
)
	if self:empty() then
		return -- if `self` is empty
	end
	local root = self._root
	assert(#point == #root.pivot, "dimensions don't match")
	local min_dist, closest_point = math.huge, nil
	local function search_nearest_neighbor(node, axis)
		if not node then
			return
		end
		local pivot = node.pivot
		local dist = pivot:distance(point)
		if dist < min_dist then
			min_dist, closest_point = dist, pivot
		end
		local leq = point[axis] <= pivot[axis]
		local next_axis = axis + 1
		if next_axis > #point then
			next_axis = 1
		end
		search_nearest_neighbor(node[leq], next_axis)
		local dist_to_plane = math.abs(pivot[axis] - point[axis])
		if min_dist >= dist_to_plane then
			-- There may be closer points on the other side of the splitting plane
			search_nearest_neighbor(node[not leq], next_axis)
		end
	end
	search_nearest_neighbor(root, 1)
	return min_dist, closest_point
end

-- Insert a point into the k-d tree.
-- May be expected to be fine if points are drawn from a uniform distribution.
--! May cause the tree to become unbalanced. Avoid using this.
function k_d_tree:insert(
	point -- `math.vector`
)
	if self:empty() then
		self._root = { pivot = point }
		return
	end
	local node = self._root
	assert(#point == #node.pivot, "dimensions don't match")
	local axis = 1
	while true do
		local pivot = node.pivot
		local left
		if point[axis] < pivot[axis] then
			left = true
		elseif point[axis] > pivot[axis] then
			left = false
		else
			-- if the point is equal to the pivot on the axis,
			-- randomly pick left or right for balance
			left = math.random() < 0.5
		end
		-- No appropriate child to descend into - add a leaf
		if not node[left] then
			node[left] = { pivot = point }
			return
		end
		node = node[left]
		axis = axis + 1
		if axis > #point then
			axis = 1
		end
	end
end

return require("class")(k_d_tree)
