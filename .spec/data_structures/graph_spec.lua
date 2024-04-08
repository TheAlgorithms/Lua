describe("Graph", function()
	local graph = require("data_structures.graph")
	local shuffle = require("random.shuffle")
	local function create_n_nodes(n)
		local g = graph.new()
		for i = 1, n do
			g:add_node(i)
		end
		return g
	end
	-- Helpers to create random graphs
	local function random_n_nodes()
		local n = math.random(30)
		return create_n_nodes(n), n
	end
	local function random_directed_cyclic_graph()
		local g, n = random_n_nodes()
		local cyc_len = math.random(n)
		-- Set up the cycle
		for v = 2, cyc_len do
			g:add_edge(v - 1, v)
		end
		g:add_edge(cyc_len, 1)
		-- Now set random edges (may add more cycles)
		for _ = 1, math.random(n ^ 2) do
			g:set_weight(math.random(n), math.random(n), true)
		end
		return g, n
	end
	local function random_directed_acyclic_graph(random_weight)
		random_weight = random_weight or function()
			return true
		end
		local g = graph.new()
		-- Add nodes
		local n = math.random(2, 30)
		local nodes = {}
		for i = 1, n do
			g:add_node(i)
			nodes[i] = i
		end
		shuffle(nodes) -- pick a random topological ordering
		-- Now add random edges which do not conflict with the topological ordering
		for _ = 1, math.random(n ^ 2) do
			local from = math.random(n - 1)
			local to = math.random(from + 1, n)
			g:set_weight(from, to, random_weight())
		end
		return g, n
	end
	local function random_graph_pos_weights()
		local g, n = random_n_nodes()
		for _ = 1, math.random(n ^ 2) do
			g:set_weight(math.random(n), math.random(n), math.random(30))
		end
		return g, n
	end
	local function random_graph_with_shortest_path(negative_weights)
		local max_weight_abs = 10
		local g, n = random_n_nodes()
		local dist, predec = { [1] = 0 }, {}
		for node = 1, n - 1 do
			local weight = negative_weights and math.random(-max_weight_abs, max_weight_abs)
				or math.random(max_weight_abs)
			g:set_weight(node, node + 1, weight)
			dist[node + 1], predec[node + 1] = dist[node] + weight, node
		end
		-- Add edges which are longer than the total length of the path
		local min_len = (negative_weights and max_weight_abs * n or dist[n]) + 1 -- make negative weight cycles impossible
		for _ = 1, math.random(n ^ 2) do
			local from, to = math.random(n), math.random(n)
			if from + 1 ~= to then -- don't break the existing path
				g:set_weight(from, to, math.random(min_len, 5 * min_len))
			end
		end
		return g, dist, predec
	end
	it("construction, getting & setting nodes & edges", function()
		local g = graph.new()
		local expected_nodes, expected_weights = {}, {}
		for i = 100, 1, -1 do
			assert.equal(false, g:has_node(i))
			g:add_node(i)
			assert.equal(true, g:has_node(i))
			expected_nodes[i] = true
			expected_weights[i] = {}
			for j = i, 100 do
				local weight = math.random()
				g:set_weight(i, j, weight)
				expected_weights[i][j] = weight
			end
		end

		for node in g:nodes() do
			assert(expected_nodes[node]) -- node must be expected
			expected_nodes[node] = nil -- node may not be seen again
			-- Copy the expected neighbors
			local expected_neighbors = {}
			for neighbor, weight in pairs(expected_weights[node]) do
				expected_neighbors[neighbor] = weight
			end
			-- Go over neighbors
			for neighbor, weight in g:neighbors(node) do
				assert.equal(expected_neighbors[neighbor], weight)
				expected_neighbors[neighbor] = nil -- neighbor may not be seen again
			end
			-- Each neighbor should have been seen
			assert.equal(nil, next(expected_neighbors))
		end
		assert.equal(nil, next(expected_nodes)) -- all nodes must have been seen

		for from, to, weight in g:edges() do
			assert.equal(true, g:has_node(from))
			assert.equal(true, g:has_node(to))
			assert.equal(weight, g:get_weight(from, to))
			assert.equal(expected_weights[from][to], weight) -- weight must be as expected
			expected_weights[from][to] = nil -- edge may not be seen again
		end

		-- All edges must have been seen
		for _, neighbors in pairs(expected_weights) do
			assert.equal(nil, next(neighbors))
		end
	end)
	it("copy", function()
		local g = graph.new({ a = { b = 42 }, b = {} })
		assert.same(g, g:copy())
	end)
	it("transposed", function()
		local g = graph.new({ a = { b = 42 }, b = {}, c = { a = 1, b = 2 } })
		assert.same(
			graph.new({
				a = { c = 1 },
				b = { a = 42, c = 2 },
				c = {},
			}),
			g:transposed()
		)
	end)
	local function traversal_common(fname)
		local function visits_all_nodes(g)
			local expected_nodes = {}
			for node in g:nodes() do
				expected_nodes[node] = true
			end
			for node in g[fname](g) do
				assert(expected_nodes[node])
				expected_nodes[node] = nil
			end
			assert.equal(nil, next(expected_nodes))
		end
		it("iterates the connected component if given a root", function()
			local n = 42
			local g = create_n_nodes(2 * n)
			for node = 1, n - 1 do
				g:add_edge(node, node + 1)
			end
			local expected_node = 0
			for node, depth in g[fname](g, 1) do
				expected_node = expected_node + 1
				assert.equal(expected_node, node)
				assert.equal(expected_node, depth + 1)
			end
			assert.equal(n, expected_node)
		end)
		it("handles chains correctly", function()
			local n = 42
			local g = create_n_nodes(n)
			for i = 1, n - 1 do
				g:add_edge(i, i + 1)
			end
			local expected_node = 0
			for node, depth in g[fname](g) do
				expected_node = expected_node + 1
				assert.equal(expected_node, node)
				assert.equal(expected_node, depth + 1)
			end
			assert.equal(n, expected_node)
		end)
		describe("visits all nodes", function()
			it("for cyclic graphs", function()
				visits_all_nodes(random_directed_cyclic_graph())
			end)
			it("for acyclic graphs", function()
				visits_all_nodes(random_directed_acyclic_graph())
			end)
		end)
	end
	describe("breadth-first traversal", function()
		traversal_common("nodes_breadth_first")
	end)
	describe("depth-first traversal", function()
		traversal_common("nodes_depth_first")
	end)
	describe("cycle detection", function()
		it("works on random cyclic graphs", function()
			for _ = 1, 10 do
				assert.equal(true, random_directed_cyclic_graph():has_cycle())
			end
		end)
		it("works on random acyclic graphs", function()
			for _ = 1, 10 do
				assert.equal(false, random_directed_acyclic_graph():has_cycle())
			end
		end)
	end)
	describe("topological sort", function()
		it("errors on cyclic graphs", function()
			for _ = 1, 10 do
				assert.has_error(function()
					random_directed_cyclic_graph():nodes_topological_order()
				end)
			end
		end)
		it("returns a valid ordering on acyclic graphs", function()
			for _ = 1, 10 do
				local g = random_directed_acyclic_graph()
				local ranks = {}
				local i = 0
				for node in g:nodes_topological_order() do
					i = i + 1
					ranks[node] = i
				end
				for from, to in g:edges() do
					assert(ranks[from] < ranks[to])
				end
			end
		end)
	end)
	describe("strongly connected components", function()
		it("works on a simple example", function()
			local g = graph.new({
				[1] = { [2] = true },
				[2] = { [1] = true, [3] = true },
				[3] = { [4] = true },
				[4] = { [3] = true },
			})
			assert.same({
				{ [1] = true, [2] = true },
				{ [3] = true, [4] = true },
			}, g:strongly_connected_components())
		end)
		it("sorts result topologically", function()
			for _ = 1, 10 do
				local g = random_directed_acyclic_graph()
				local rank = {}
				local i = 0
				for _, component in ipairs(g:strongly_connected_components()) do
					local node = assert(next(component))
					assert.same({ [node] = true }, component)
					assert.equal(nil, next(component, node))
					i = i + 1
					rank[node] = i
				end
				for from, to in g:edges() do
					assert(rank[from] < rank[to])
				end
			end
		end)
	end)
	local function test_sssp_limited(name, negative_weights)
		it("selected graph", negative_weights and function()
			-- This is an example where the invariant of Dijkstra's algorithm would be broken
			local g = graph.new({
				[1] = { [2] = 1, [3] = 3 },
				[2] = { [4] = 1 },
				[3] = { [2] = -3 },
				[4] = {},
			})
			assert.same({
				{
					[1] = 0,
					[2] = 0,
					[3] = 3,
					[4] = 1,
				},
				{
					[2] = 3,
					[3] = 1,
					[4] = 2,
				},
			}, { g[name](g, 1) })
		end or function()
			local g = graph.new({
				[1] = { [1] = 1, [2] = 2, [4] = 3, [5] = 9 },
				[2] = { [1] = 2, [3] = 4, [4] = 2 },
				[3] = {},
				[4] = { [2] = 5, [5] = 1 },
				[5] = { [3] = 1, [6] = 1 },
				[6] = { [2] = 1, [5] = 6, [4] = 3 },
			})
			assert.same({
				{
					[1] = 0,
					[2] = 2,
					[3] = 5,
					[4] = 3,
					[5] = 4,
					[6] = 5,
				},
				{
					[2] = 1,
					[3] = 5,
					[4] = 1,
					[5] = 4,
					[6] = 5,
				},
			}, { g[name](g, 1) })
		end)
		it("random graphs", function()
			for _ = 1, 10 do
				local g, dist, predec = random_graph_with_shortest_path(negative_weights)
				assert.same({ dist, predec }, { g[name](g, 1) })
			end
		end)
	end
	describe("SSSP", function()
		describe("Dijkstra", function()
			test_sssp_limited("sssp_dijkstra", false)
			it("errors on negative weights", function()
				assert.has_error(function()
					graph.new({ [1] = { [2] = -1 }, [2] = {} }):sssp_dijkstra(1)
				end)
			end)
		end)
		local function test_sssp(name)
			describe("supports positive weights", function()
				test_sssp_limited(name, false)
			end)
			describe("supports negative weights", function()
				test_sssp_limited(name, true)
			end)
			it("errors on negative weight cycles", function()
				assert.has_error(function()
					local g = graph.new({ [1] = { [2] = -1 }, [2] = { [1] = -1 } })
					g[name](g, 1)
				end)
			end)
		end
		describe("Bellman-Ford", function()
			test_sssp("sssp_bellman_ford")
		end)
		describe("Dispatcher", function()
			test_sssp("sssp")
		end)
	end)
	-- Checks that the implicit shortest path tree given as predecessor links matches the distances
	local function check_shortest_path_tree(g, source, dist, predec)
		local checked = {}
		assert.equal(0, dist[source])
		checked[source] = true
		local function check(to)
			if checked[to] then
				return
			end
			local from = predec[to]
			assert.equal(dist[to], g:get_weight(from, to) + dist[from])
			check(from)
			checked[to] = true
		end
		for node in pairs(predec) do
			check(node)
		end
		for node in pairs(dist) do
			assert(checked[node])
		end
	end
	local function check_shortest_path_forest(g, dists, predecs)
		for source, dist in pairs(dists) do
			check_shortest_path_tree(g, source, dist, predecs[source])
		end
		return dists -- return the distances for convenience
	end
	local function test_apsp_pos_weights(name)
		it("selected graph (positive weights)", function()
			local g = graph.new({
				[1] = { [4] = 2 },
				[2] = { [1] = 3, [3] = 7 },
				[3] = {},
				[4] = { [2] = 5 },
			})
			assert.same({
				{
					[1] = { [1] = 0, [2] = 7, [3] = 14, [4] = 2 },
					[2] = { [1] = 3, [2] = 0, [3] = 7, [4] = 5 },
					[3] = { [3] = 0 },
					[4] = { [1] = 8, [2] = 5, [3] = 12, [4] = 0 },
				},
				{
					[1] = { [2] = 4, [3] = 2, [4] = 1 },
					[2] = { [1] = 2, [3] = 2, [4] = 1 },
					[3] = {},
					[4] = { [1] = 2, [2] = 4, [3] = 2 },
				},
			}, { g[name](g) })
		end)
	end
	local function test_apsp(name)
		it("selected graph (negative weights)", function()
			local g = graph.new({
				[1] = { [2] = 5, [3] = 2 },
				[2] = { [3] = -2, [4] = 3 },
				[3] = { [1] = -1 },
				[4] = { [1] = 1, [3] = 4 },
			})
			assert.same({
				{
					[1] = { [1] = 0, [2] = 5, [3] = 2, [4] = 8 },
					[2] = { [1] = -3, [2] = 0, [3] = -2, [4] = 3 },
					[3] = { [1] = -1, [2] = 4, [3] = 0, [4] = 7 },
					[4] = { [1] = 1, [2] = 6, [3] = 3, [4] = 0 },
				},
				{
					[1] = { [2] = 1, [3] = 1, [4] = 2 },
					[2] = { [1] = 3, [3] = 2, [4] = 2 },
					[3] = { [1] = 3, [2] = 1, [4] = 2 },
					[4] = { [1] = 4, [2] = 1, [3] = 1 },
				},
			}, { g[name](g) })
		end)
		test_apsp_pos_weights(name)
	end
	describe("APSP", function()
		describe("Floyd-Warshall", function()
			test_apsp("apsp_floyd_warshall")
		end)
		describe("Bellman-Ford", function()
			test_apsp("apsp_bellman_ford")
			it("matches Floyd-Warshall", function()
				local g = random_directed_acyclic_graph(function()
					return math.random(-30, 30)
				end)
				local dist_bellman_ford = check_shortest_path_forest(g, g:apsp_bellman_ford())
				local dist_floyd_warshall = check_shortest_path_forest(g, g:apsp_floyd_warshall())
				assert.same(dist_bellman_ford, dist_floyd_warshall)
			end)
		end)
		describe("Dijkstra", function()
			test_apsp_pos_weights("apsp_dijkstra")
			-- Note: Implicitly also tests whether SSSP matches
			it("matches Bellman-Ford", function()
				for _ = 1, 10 do
					local g = random_graph_pos_weights()
					local dist_dijkstra = check_shortest_path_forest(g, g:apsp_dijkstra())
					local dist_bellman_ford = check_shortest_path_forest(g, g:apsp_bellman_ford())
					assert.same(dist_bellman_ford, dist_dijkstra)
				end
			end)
		end)
		describe("Dispatch", function()
			test_apsp("apsp")
		end)
	end)
	it("Max flow", function()
		assert.same(
			graph.new({
				s = { a = 2, b = 2 },
				a = { c = 1, d = 1 },
				b = { d = 2 },
				c = { t = 1 },
				d = { t = 3 },
				t = {},
			}),
			graph
				.new({
					s = { a = 3, b = 2 },
					a = { c = 2, d = 1 },
					b = { c = 1, d = 3 },
					c = { t = 1 },
					d = { t = 4 },
					t = {},
				})
				:max_flow("s", "t")
		)
	end)
end)
