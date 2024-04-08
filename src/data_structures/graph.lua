-- (Directed) graph using a table of tables data structure,
-- allowing for amortized average case constant time insertion, deletion & traversal

local table_heap = require("data_structures.table_heap")

local graph = {}

function graph.new(
	nodes -- table, `nodes[from][to] = weight`; defaults to `{}`
)
	return { _nodes = nodes or {} }
end

function graph:add_node(node)
	assert(self._nodes[node] == nil, "node already exists")
	self._nodes[node] = {}
end

-- `remove_node` is intentionally omitted for now, since it would either
-- require a reverse mapping to be efficient,
-- or have to be implemented inefficiently using a scan over all edges.

function graph:has_node(node)
	return self._nodes[node] ~= nil
end

-- Set the weight of an edge. Overrides a previous weight.
-- `from` and `to` must already exist in the graph.
function graph:set_weight(
	from, -- node
	to, -- node
	weight -- weight of the edge, `nil` to remove; use `true` if there is no `weight`
)
	assert(self._nodes[to], "destination node missing")
	assert(self._nodes[from], "source node missing")[to] = weight
end

-- Get the weight of an edge or `nil` if there is no edge from `from` to `to`
function graph:get_weight(
	from, --[[node]]
	to --[[node]]
)
	return self._nodes[from] and self._nodes[from][to]
end

--> boolean, whether there is an edge between the two nodes
function graph:has_edge(
	from, --[[node]]
	to --[[node]]
)
	return self:get_weight(from, to) ~= nil
end

-- Adds an edge with "weight" `true`.
function graph:add_edge(
	from, --[[node]]
	to --[[node]]
)
	assert(self:get_weight(from, to) == nil, "edge already exists")
	return self:set_weight(from, to, true)
end

-- Removes an edge. No-op if there was no edge.
function graph:remove_edge(
	from, --[[node]]
	to --[[node]]
)
	return self:set_weight(from, to, nil)
end

-- Copies a graph, copying the structure but not copying the nodes or weights as a deepcopy would.
--> Copy of `self`
function graph:copy()
	local nodes_copy = {}
	for node, neighbors in pairs(self._nodes) do
		local neighbors_copy = {}
		for neighbor, weight in pairs(neighbors) do
			neighbors_copy[neighbor] = weight
		end
		nodes_copy[node] = neighbors_copy
	end
	return graph.new(nodes_copy)
end

local function next_key(t, k)
	return (next(t, k))
end

function graph:nodes()
	-- Iterator over the `node`s, in any order
	return next_key, self._nodes
end

function graph:neighbors(
	from --[[node]]
)
	-- Iterator over `to, weight`, in any order
	return pairs(self._nodes[from])
end

function graph:edges()
	-- Iterator over `from, to, weight`, in any order
	return coroutine.wrap(function()
		for from, tos in pairs(self._nodes) do
			for to, weight in pairs(tos) do
				coroutine.yield(from, to, weight)
			end
		end
	end)
end

--> graph with reversed edge direction
function graph:transposed()
	local transposed = graph.new()
	for node in self:nodes() do
		transposed:add_node(node)
	end
	for from, to, weight in self:edges() do
		transposed:set_weight(to, from, weight)
	end
	return transposed
end

-- Breadth-first traversal. Can be used to solve shortest path problems if all edges have the same weight.
function graph:nodes_breadth_first(
	root -- optional root node to start the traversal from
)
	local visited = {}
	local function breadth_first_traversal(start)
		visited[start] = true
		local level = { start }
		local depth = 0
		coroutine.yield(start, depth, nil)
		repeat
			local next_level = {}
			depth = depth + 1
			for _, node in pairs(level) do
				for neighbor in self:neighbors(node) do
					if not visited[neighbor] then
						coroutine.yield(neighbor, depth, node)
						table.insert(next_level, neighbor)
						visited[neighbor] = true
					end
				end
			end
			level = next_level
		until level[1] == nil
	end
	-- Iterator over `node, hops, predecessor`, starting with `root, 0, nil`
	return coroutine.wrap(function()
		if root ~= nil then
			assert(self._nodes[root])
			return breadth_first_traversal(root)
		end
		for start in self:nodes() do
			if not visited[start] then
				breadth_first_traversal(start)
			end
		end
	end)
end

-- Depth-first traversal
function graph:nodes_depth_first(
	root -- optional root node to start the traversal from
)
	local visited = {}
	local depth = 0
	local function depth_first_traversal(node)
		if visited[node] then
			return
		end
		visited[node] = true
		coroutine.yield(node, depth)
		depth = depth + 1
		for neighbor in self:neighbors(node) do
			depth_first_traversal(neighbor)
		end
		depth = depth - 1
	end
	-- Iterator over `node, depth`, starting with `root, 0`
	return coroutine.wrap(function()
		if root ~= nil then
			assert(self._nodes[root])
			return depth_first_traversal(root)
		end
		for node in self:nodes() do
			depth_first_traversal(node)
		end
	end)
end

-- Uses a DFS to determine whether `self` has a cycle.
function graph:has_cycle()
	local done = {} -- current state of each node
	local function has_cycle(node)
		if done[node] == false then
			return true -- node is a successor of itself => cycle
		end
		if done[node] == true then
			return false
		end
		done[node] = false
		for neighbor in self:neighbors(node) do
			if has_cycle(neighbor) then
				return true
			end
		end
		done[node] = true
		return false
	end
	for node in self:nodes() do
		if has_cycle(node) then
			return true -- if `self` has a cycle consisting of edges satisfying `follow_edge`
		end
	end
	return false -- if `self` has no cycle consisting of edges satisfying `follow_edge`
end

-- Topological sort implemented as reverse postorder.
-- Requires a cycle-free graph.
--> Stateful iterator returning nodes in topological order.
function graph:nodes_topological_order()
	-- Find roots (nodes without ingoing edges)
	local roots = {}
	for node in self:nodes() do
		roots[node] = true
	end
	for _, to in self:edges() do
		roots[to] = nil
	end
	local nodes = {}
	local done = {}
	local function topo_sort(node)
		if done[node] then
			return -- done with node
		end
		-- Re-encountered parent which is still in progress => cycle
		assert(done[node] == nil, "graph contains cycle")
		done[node] = false -- node is still in progress
		for neighbor in self:neighbors(node) do
			topo_sort(neighbor)
		end
		done[node] = true
		table.insert(nodes, node)
	end
	-- Topo. sort each connected component (order among them is arbitrary though)
	for root in pairs(roots) do
		topo_sort(root)
	end
	-- Check that all nodes have been seen
	for node in self:nodes() do
		assert(done[node], "graph contains cycle")
	end
	-- Iterate over nodes in reverse order
	local i = #nodes + 1
	return function()
		i = i - 1
		return nodes[i] -- will be `nil` for `i < 1`
	end
end

-- Kosaraju's algorithm
--> list of strongly connected components (sets of nodes), topologically sorted
function graph:strongly_connected_components()
	local nodes_depth_first = {}
	do -- "postorder", depth-first traversal
		local seen = {}
		local function visit(node)
			if seen[node] then
				return
			end
			seen[node] = true
			for neighbor in self:neighbors(node) do
				visit(neighbor)
			end
			table.insert(nodes_depth_first, node)
		end
		for node in self:nodes() do
			visit(node)
		end
	end
	local transposed = self:transposed()
	local seen = {}
	local connected_components = {}
	for i = #nodes_depth_first, 1, -1 do
		local root = nodes_depth_first[i]
		if not seen[root] then
			seen[root] = true
			local component = {}
			local to_visit = { root }
			repeat
				local node = table.remove(to_visit)
				component[node] = true
				for neighbor in transposed:neighbors(node) do
					if not seen[neighbor] then
						seen[neighbor] = true
						table.insert(to_visit, neighbor)
					end
				end
			until to_visit[1] == nil
			table.insert(connected_components, component)
		end
	end
	return connected_components
end

-- Single source shortest paths using Dijkstra.
-- Requires positive weights.
function graph:sssp_dijkstra(source)
	local dist, predec = {}, {}
	dist[source] = 0
	local closest = table_heap.new({}, function(v, w)
		return dist[v] < dist[w]
	end)
	closest:push(source)
	repeat
		local closest_node = closest:pop()
		for neighbor, weight in self:neighbors(closest_node) do
			assert(weight >= 0, "negative weight edge")
			local candidate_dist = dist[closest_node] + weight
			if dist[neighbor] == nil then -- new node reached
				dist[neighbor], predec[neighbor] = candidate_dist, closest_node
				closest:push(neighbor)
			elseif candidate_dist < dist[neighbor] then
				dist[neighbor], predec[neighbor] = candidate_dist, closest_node
				closest:decrease(neighbor)
			end
		end
	until closest:top() == nil
	return dist, predec -- unreachable nodes will have `dist[node] = predec[node] = nil`
end

-- Single source shortest paths using Bellman-Ford.
-- Supports negative weights.
function graph:sssp_bellman_ford(source)
	local dist, predec = {}, {}
	dist[source] = 0
	for _ in next, self._nodes, next(self._nodes) do -- skip the first node => |nodes| - 1 iterations
		for from, to, weight in self:edges() do
			if dist[from] then -- from is reachable?
				local candidate_dist = dist[from] + weight
				-- Try relaxing the distance to `to`
				if dist[to] == nil or candidate_dist < dist[to] then
					-- `to` is currently unreachable or using `from` as predecessor is shorter
					dist[to], predec[to] = candidate_dist, from
				end
			end
		end
	end
	-- Final iteration to check for a negative weight cycle
	for from, to, weight in self:edges() do
		if dist[from] then
			local candidate_dist = dist[from] + weight
			if dist[to] == nil or candidate_dist < dist[to] then
				error("negative weight cycle")
			end
		end
	end
	return dist, predec -- unreachable nodes will have `dist[node] = predec[node] = nil`
end

-- Single source shortest paths using either Bellman-Ford or Dijkstra
-- depending on whether the graph contains negative weights
--> `dist, predec` such that
--> * `dist[from][to]` is the distance between the nodes `from` and `to` or `nil` if `to` is unreachable from `from`
--> * `predec[from][to]` is the predecessor of `to` on the shortest path from `from` or `nil` if `to` is unreachable
function graph:sssp(
	source --[[node, start of all shortest paths]]
)
	for _, _, weight in self:edges() do
		if weight < 0 then
			return self:sssp_bellman_ford(source)
		end
	end
	return self:sssp_dijkstra(source)
end

-- All pair shortest paths using single source shortest paths
local function _apsp_sssp(self, sssp_name)
	local dist, predec = {}, {}
	for node in self:nodes() do
		dist[node], predec[node] = self[sssp_name](self, node)
	end
	return dist, predec
end

-- All pair shortest paths using Dijkstra.
-- Requires positive weights. Suitable for "sparse" graphs.
function graph:apsp_dijkstra()
	return _apsp_sssp(self, "sssp_dijkstra")
end

-- All pair shortest paths using Bellman-Ford.
-- Allows negative weights. Rarely suitable (only for *very* sparse graphs).
function graph:apsp_bellman_ford()
	return _apsp_sssp(self, "sssp_bellman_ford")
end

-- All pair shortest paths using Floyd-Warshall.
-- Allows negative weights. Detects negative weight cycles.
-- Go-to choice for APSP.
function graph:apsp_floyd_warshall()
	local dist, predec = {}, {}
	for from in self:nodes() do
		dist[from], predec[from] = {}, {}
		for to, weight in self:neighbors(from) do
			dist[from][to], predec[from][to] = weight, from
		end
		dist[from][from] = 0
	end
	for over in self:nodes() do
		for from in self:nodes() do
			for to in self:nodes() do
				local d_fo, d_ot = dist[from][over], dist[over][to]
				if d_fo and d_ot then
					local d = dist[from][to]
					local d_over = d_fo + d_ot
					if d == nil or d_over < d then
						-- Path is `from` -...-> `over` -...-> `to` => predecessor of `to`
						-- on the path from `from` to `to` is the predecessor of `to` on the path from `over` to `to`
						dist[from][to], predec[from][to] = d_over, predec[over][to]
					end
				end
			end
		end
	end
	for node in self:nodes() do
		assert(dist[node][node] == 0, "negative weight cycle")
	end
	return dist, predec
end

-- All pairs shortest paths.
-- Uses either Dijkstra, Bellman-Ford or Floyd-Warshall
-- depending on how sparse the graph is and whether negative weights occur.
--> `dist, predec` such that
--> * `dist[from][to]` is the distance between the nodes `from` and `to` or `nil` if `to` is unreachable from `from`
--> * `predec[from][to]` is the predecessor of `to` on the shortest path from `from` or `nil` if `to` is unreachable
function graph:apsp()
	-- TODO (...) Introduce constant factor(s) here after profiling
	local nodes = 0
	for _ in self:nodes() do
		nodes = nodes + 1
	end
	local edges = 0
	local negative_weight = false
	for _, _, weight in self:edges() do
		edges = edges + 1
		if weight < 0 then
			negative_weight = true
		end
	end
	if negative_weight then -- Dijkstra is not an option
		if edges >= nodes then
			-- nodes^2 * edges >= nodes^3 => Floyd-Warshall ">=" Bellman-Ford
			return self:apsp_floyd_warshall()
		end
		return self:apsp_bellman_ford()
	end
	-- Expected running times divided by the common factor of the amount of nodes
	local time_dijkstra = (nodes + edges) * math.log(nodes)
	local time_floyd_warshall = nodes ^ 2
	if time_floyd_warshall <= time_dijkstra then
		return self:apsp_floyd_warshall()
	end
	local time_bellman_ford = nodes * edges
	-- For *extremely* sparse graphs Bellman-Ford is faster; it's also simpler
	if time_bellman_ford <= time_dijkstra then
		return self:apsp_bellman_ford()
	end
	return self:apsp_dijkstra()
end

-- All pairs shortest paths if `source == nil`, single source shortest paths otherwise.
function graph:shortest_paths(
	source -- source node (for SSSP) or `nil` (for APSP)
)
	if source == nil then
		return self:apsp()
	end
	return self:sssp(source)
end

-- Uses Edmonds-Karp. Weights are interpreted as capacities.
--> Flow graph. Does not contain edges with `0` flow:
--> * Source set S can be found as everything reachable from source (e.g. using DFS/BFS).
--> * Sink set T can be found as all nodes not in S.
--> * Min-cut can be found as the set of all edges from S to T.
function graph:max_flow(source, sink)
	local residual = self:copy()
	-- Calculates the bottleneck along a path given as a predecessor chain from sink to source
	local function calc_max_augment(predec)
		local max_augment = math.huge -- min. of weights along the path
		local to = sink
		repeat
			local from = predec[to]
			max_augment = math.min(max_augment, residual:get_weight(from, to))
			to = from
		until to == source
		return max_augment
	end
	-- Augments a given path given as a predecessor chain from sink to source
	local function augment_path(predec)
		local max_augment = calc_max_augment(predec)
		local to = sink
		repeat
			local from = predec[to]
			residual:set_weight(from, to, residual:get_weight(from, to) - max_augment) -- reduce capacity
			residual:set_weight(to, from, (residual:get_weight(to, from) or 0) + max_augment) -- increase capacity of back edge
			to = from
		until to == source
	end
	-- Tries augmenting a path from source to sink.
	-- Uses a BFS to try paths with fewer edges first.
	-- Recurses until there is no path from source to sink in the residual network.
	local function try_augment_path()
		local level = { source }
		local predec = { [source] = source } -- HACK to prevent the source from being "discovered"
		repeat
			local next_level = {}
			for _, node in ipairs(level) do
				for neighbor, capacity in residual:neighbors(node) do
					if capacity > 0 and predec[neighbor] == nil then -- TODO remove edges instead?
						predec[neighbor] = node
						if neighbor == sink then -- path to sink found
							augment_path(predec)
							return try_augment_path()
						end
						table.insert(next_level, neighbor)
					end
				end
			end
			level = next_level
		until #level == 0
	end
	try_augment_path()
	-- Reconstruct the flow from the final residual network.
	local flow = self:copy()
	for from, to in flow:edges() do
		-- Note: Works as expected if weight from `to` to `from` is `nil` in the residual network
		flow:set_weight(from, to, residual:get_weight(to, from))
	end
	return flow
end

return require("class")(graph)
