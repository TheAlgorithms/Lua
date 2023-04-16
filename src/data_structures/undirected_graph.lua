-- A graph which is guaranteed to always have edges with the same weight in both directions ("undirected edges");
-- under the hood this is still stored as a directed graph.
-- Thus, for consistency, edges (except for trivial cycles) will be iterated twice when using `:edges()`,
-- once as `x, y, weight` and a second time as `y, x, weight`.

local heap = require("data_structures.heap")
local table_heap = require("data_structures.table_heap")
local union_find = require("data_structures.union_find")
local graph = require("data_structures.graph")

local undirected_graph = {}

-- Create a new graph from undirected edges.
-- An undirected edge between nodes `x` and `y` can be specified as
-- `nodes[x][y] = weight` or `nodes[y][x] = weight`.
-- If both are specified, the weights must match.
function undirected_graph.new(nodes)
	nodes = nodes or {}
	for from, tos in pairs(nodes) do
		for to, weight in pairs(tos) do
			assert(nodes[to], "destination node missing")
			if nodes[to][from] == nil then
				nodes[to][from] = weight
			else
				assert(nodes[to][from] == weight, "weights don't match")
			end
		end
	end
	return graph.new(nodes)
end

-- Set the weight of an edge in both directions. Overrides a previous weight.
-- `node` and `other_node` must already exist in the graph.
function undirected_graph:set_weight(
	node,
	other_node,
	weight -- weight of the edge, `nil` to remove; use `true` if there is no `weight`
)
	graph.set_weight(self, node, other_node, weight)
	graph.set_weight(self, other_node, node, weight)
end

-- Partitions the graph into connected components
--> Iterator over connected components (undirected subgraphs)
function undirected_graph:connected_components()
	local seen = {}
	local iterator, state, root = self:nodes()
	return function()
		repeat
			root = iterator(state, root)
		until not seen[root] -- note: terminates if `root == nil`
		if root == nil then
			return nil
		end
		local connected_component = undirected_graph.new()
		connected_component:add_node(root)
		local to_visit = { root } -- stack of nodes to visit (depth-first traversal)
		seen[root] = true
		repeat
			local node = table.remove(to_visit)
			for neighbor, weight in self:neighbors(node) do
				if not connected_component:has_node(neighbor) then
					connected_component:add_node(neighbor)
				end
				connected_component:set_weight(node, neighbor, weight)
				if not seen[neighbor] then
					seen[neighbor] = true
					table.insert(to_visit, neighbor)
				end
			end
		until #to_visit == 0
		return connected_component
	end
end

-- Finds a Minimum Spanning Forest using Prim's algorithm
function undirected_graph:msf_prim()
	local spanning_forest = undirected_graph.new()

	local function grow_spanning_tree(root)
		local min_dist = {} -- [node] = minimum distance to reach from any node of spanning tree
		local predec = {} -- [node] = other node such that the weight of the edge is minimal
		-- Immediate neighbors by their distance to the spanning tree (always a single edge!)
		local neighbors = table_heap.new({}, function(a, b)
			return min_dist[a] < min_dist[b]
		end)
		-- Update the neighbors of a node which has already been added to the spanning tree
		local function update_neighbors(node)
			for neighbor, weight in self:neighbors(node) do
				if not spanning_forest:has_node(neighbor) then -- neighbor not in spanning tree?
					if min_dist[neighbor] == nil then -- add neighbor
						min_dist[neighbor], predec[neighbor] = weight, node
						neighbors:push(neighbor)
					elseif weight < min_dist[neighbor] then -- update neighbor: cheaper edge found
						min_dist[neighbor], predec[neighbor] = weight, node
						neighbors:decrease(neighbor)
					end
				end
			end
			-- These entries aren't needed anymore, node is now part of the spanning tree
			min_dist[node], predec[node] = nil, nil
		end

		spanning_forest:add_node(root)
		update_neighbors(root) -- update nodes reachable from this "root"
		while #neighbors > 0 do -- grow the spanning tree while there are still reachable nodes
			-- Pick the closest neighbor of the current spanning tree...
			local node = neighbors:pop()
			spanning_forest:add_node(node) -- ... add the node
			spanning_forest:set_weight(predec[node], node, min_dist[node]) -- ... and connect it using the cheapest edge
			update_neighbors(node) -- now update the neighbors of the spanning tree
		end
	end

	-- Grow a spanning tree for each root that isn't yet part of one
	local n_conn_comps = 0
	for root in self:nodes() do
		if not spanning_forest:has_node(root) then
			n_conn_comps = n_conn_comps + 1
			grow_spanning_tree(root)
		end
	end

	return spanning_forest, n_conn_comps
end

-- Finds a Minimum Spanning Forest using Kruskal's algorithm
function undirected_graph:msf_kruskal()
	local spanning_forest = undirected_graph.new()

	-- Build a heap of edges by weight (we could also sort, but using a heap is more efficient in the best case)
	local edges = {}
	for node, other_node, weight in self:edges() do
		table.insert(edges, { node = node, other_node = other_node, weight = weight })
	end
	edges = heap.new(edges, function(a, b)
		return a.weight < b.weight
	end)

	local connected_components = union_find.new()
	local n_conn_comps = 0
	for node in self:nodes() do
		spanning_forest:add_node(node)
		connected_components:make_set(node)
		n_conn_comps = n_conn_comps + 1
	end

	while n_conn_comps > 1 and not edges:empty() do
		local min_edge = edges:pop()
		local node, other_node = min_edge.node, min_edge.other_node
		-- Nodes are in two distinct connected components currently
		-- <=> adding the edge does not introduce a cycle
		if connected_components:find(node) ~= connected_components:find(other_node) then
			-- Add edge, connecting the two components.
			connected_components:union(node, other_node)
			spanning_forest:set_weight(node, other_node, min_edge.weight)
			n_conn_comps = n_conn_comps - 1
		end
	end

	return spanning_forest, n_conn_comps
end

-- Default choice for finding Minimum Spanning Forests is Prim's algorithm:
-- Prim theoretically runs faster than Kruskal for graphs with n > m,
-- requiring O(m log n) vs. O(m log m) time.
--> spanning forest (undirected graph), number of connected components
undirected_graph.msf = undirected_graph.msf_prim -- TODO (...) benchmark Kruskal vs Prim for small & sparse graphs

return require("class")(undirected_graph, graph)
