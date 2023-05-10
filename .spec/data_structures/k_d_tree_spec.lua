describe("k-d tree", function()
	local k_d_tree = require("data_structures.k_d_tree")
	local vector = require("math.vector")
	local n = 1e3
	local d = 2
	local function random_point()
		local v = {}
		for j = 1, d do
			v[j] = math.random()
		end
		return vector.new(v)
	end
	local function random_points()
		local points = {}
		local point_set = {}
		for i = 1, n do
			points[i] = random_point()
			point_set[points[i]] = true
		end
		return points, point_set
	end
	-- Naive linear search on the first k points
	local function find_nearest_neighbor(points, p)
		local min_distance, nearest = math.huge, nil
		for _, q in ipairs(points) do
			local distance = p:distance(q)
			if distance < min_distance then
				nearest, min_distance = q, distance
			end
		end
		return min_distance, nearest
	end
	local function test_constructor(name, funcname)
		local constructor = k_d_tree[funcname]
		describe(name, function()
			local points, point_set = random_points()
			local tree = constructor(points)
			it("empty trees", function()
				local empty_tree = constructor({})
				assert.equal(true, empty_tree:empty())
				assert.equal(false, tree:empty())
				assert.same({}, { empty_tree:nearest_neighbor(random_point()) })
			end)
			it("nearest neighbor queries match naive linear search", function()
				for _ = 1, 100 do
					local p = random_point()
					local dist, nearest = tree:nearest_neighbor(p)
					assert(point_set[nearest])
					local expected_dist = find_nearest_neighbor(points, p)
					-- Allow only a small deviation of the distances (due to floating point error)
					assert(math.abs(dist - expected_dist) < 1e-6)
				end
			end)
			it("still matches linear search after insertions", function()
				-- Insert another n random points
				local points_to_insert, point_to_insert_set = random_points()
				for _, p in ipairs(points_to_insert) do
					tree:insert(p)
				end
				for _ = 1, 100 do
					local p = random_point()
					local dist, nearest = tree:nearest_neighbor(p)
					assert(point_set[nearest] or point_to_insert_set[nearest])
					local expected_dist =
						math.min(find_nearest_neighbor(points_to_insert, p), (find_nearest_neighbor(points, p)))
					assert(math.abs(dist - expected_dist) < 1e-6)
				end
			end)
		end)
	end
	test_constructor("presorting", "new_presorting")
	test_constructor("sorting", "new_sorting")
	test_constructor("median-of-medians", "new_median_of_medians")
end)
