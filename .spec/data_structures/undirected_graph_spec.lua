describe("Undirected graph", function()
	local undirected_graph = require("data_structures.undirected_graph")
	it("wraps a directed graph with symmetrical edges", function()
		local g = undirected_graph.new({
			[1] = { [2] = true, [3] = true },
			[2] = {},
			[3] = {},
		})
		g:add_edge(2, 3)
		assert(g:has_edge(2, 1))
		assert(g:has_edge(3, 1))
		assert(g:has_edge(3, 2))
		assert.same(g, g:copy())
	end)
	local function normalize_connected_components(g, msf)
		local normalized = {}
		for conn_comp in g:connected_components() do
			local nodes = {}
			for node in conn_comp:nodes() do
				table.insert(nodes, node)
			end
			table.sort(nodes)
			if msf then
				local weight_sum = 0
				local edge_count = 0
				for _, _, weight in conn_comp:edges() do
					weight_sum = weight_sum + weight
					edge_count = edge_count + 0.5 -- edges are otherwise counted twice
				end
				assert.equal(#nodes - 1, edge_count)
				nodes.weight_sum = weight_sum
			end
			table.insert(normalized, nodes)
		end
		table.sort(normalized, function(a, b)
			return a[1] < b[1]
		end)
		return normalized
	end
	local function random_graph(n_conn_comps)
		local g = undirected_graph.new({})
		local expected_comps = {}
		local node = 0
		for i = 1, n_conn_comps do
			local n_nodes = math.random(10)
			local comp = {}
			node = node + 1
			local first_node = node
			g:add_node(first_node)
			table.insert(comp, first_node)
			local max_weight = 14 -- of edges in the spanning forest
			for _ = 2, n_nodes do
				-- Connect to any of the previously added nodes
				local connect_to = math.random(first_node, node)
				node = node + 1
				g:add_node(node)
				table.insert(comp, node)
				g:set_weight(connect_to, node, math.random(max_weight))
			end
			for _ = 1, math.random(0, 3 * n_nodes) do
				g:set_weight(
					math.random(first_node, node),
					math.random(first_node, node),
					math.random(max_weight + 1, 42)
				)
			end
			expected_comps[i] = comp
		end
		return g, expected_comps
	end
	describe("connected components", function()
		it("empty graph", function()
			for _ in undirected_graph.new({}):connected_components() do
				assert(false)
			end
		end)
		it("node-only graph", function()
			local g = undirected_graph.new({})
			local expected_set = {}
			for node = 1, 100 do
				g:add_node(node)
				expected_set[node] = true
			end
			for comp in g:connected_components() do
				local iterator, state, cvar = comp:nodes()
				local node = iterator(state, cvar)
				assert(expected_set[node])
				expected_set[node] = nil
				assert.equal(nil, iterator(state, node))
			end
			assert.equal(nil, next(expected_set))
		end)
		it("selected graph", function()
			assert.same(
				{
					{ 1 },
					{ 2, 3, 4 },
					{ 5, 6, 7, 8, 9 },
					{ 10, 11, 12, 13 },
				},
				normalize_connected_components(undirected_graph.new({
					[1] = {},
					[2] = { [3] = true },
					[3] = { [4] = true },
					[4] = {},
					[5] = { [6] = true },
					[6] = { [7] = true, [8] = true, [9] = true },
					[7] = {},
					[8] = {},
					[9] = {},
					[10] = { [11] = true, [12] = true, [13] = true },
					[11] = { [12] = true, [13] = true },
					[12] = { [13] = true },
					[13] = {},
				}))
			)
		end)
		it("random graphs", function()
			for n_comps = 1, 10 do
				local g, expected_comps = random_graph(n_comps)
				assert.same(expected_comps, normalize_connected_components(g))
			end
		end)
	end)
	local function test_msf(msf_name)
		it("selected graph", function()
			local g = undirected_graph.new({
				a = { b = 1, c = 2 },
				b = { c = 3 },
				c = {},
				[1] = { [4] = 7, [2] = 8 },
				[2] = { [4] = 4, [5] = 9 },
				[3] = { [6] = 2, [5] = 4 },
				[4] = { [7] = 12 },
				[5] = { [6] = 1, [7] = 7, [8] = 6 },
				[6] = { [8] = 5, [9] = 11 },
				[7] = { [8] = 3 },
				[8] = { [9] = 10 },
				[9] = {},
			})
			assert.same({
				undirected_graph.new({
					a = { b = 1, c = 2 },
					b = {},
					c = {},
					[1] = { [4] = 7 },
					[2] = { [4] = 4, [5] = 9 },
					[3] = { [6] = 2 },
					[4] = {},
					[5] = { [6] = 1 },
					[6] = { [8] = 5 },
					[7] = { [8] = 3 },
					[8] = { [9] = 10 },
					[9] = {},
				}),
				2,
			}, { g[msf_name](g) })
		end)
		it("connected components of random graphs & their MSFs match", function()
			for n_comps = 1, 10 do
				local g, expected_comps = random_graph(n_comps)
				local msf, n_conn_comps = g[msf_name](g)
				assert.equal(n_comps, n_conn_comps)
				assert.same(expected_comps, normalize_connected_components(msf))
			end
		end)
	end
	describe("Minimum spanning forest", function()
		describe("Prim", function()
			test_msf("msf_prim")
		end)
		describe("Kruskal", function()
			test_msf("msf_kruskal")
		end)
		it("Prim matches Kruskal for random graphs", function()
			for n_comps = 1, 10 do
				local g = random_graph(n_comps)
				local msf_prim, n_comps_prim = g:msf_prim()
				local msf_kruskal, n_comps_kruskal = g:msf_kruskal()
				assert.equal(n_comps_prim, n_comps_kruskal)
				assert.same(
					normalize_connected_components(msf_prim, true),
					normalize_connected_components(msf_kruskal, true)
				)
			end
		end)
	end)
end)
