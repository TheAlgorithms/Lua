describe("Quickselect", function()
	local build_quickselect = require("sorting.quickselect")
	local quickselect_median_of_medians = require("sorting.quickselect_median_of_medians")
	local function test_quickselect(quickselect, n)
		local function test_order(descending)
			local less_than
			if descending then
				less_than = function(a, b)
					return a > b
				end
			end
			-- Test that Quickselect correctly handles an (ascendingly) sorted array
			local function test_sorted(arr)
				local copy = { unpack(arr) }
				for i = 1, #arr do
					local expected = i
					if descending then
						expected = #arr - i + 1 -- from end (reverse order)
					end
					-- Expect the correct value; only call Quickselect a copy of the array
					assert.equal(arr[expected], copy[quickselect(copy, i, less_than)])
				end
			end
			-- Test a permutation from 1 to n
			local function test_permutation(arr)
				for i = 1, #arr do
					local expected = i
					if descending then
						expected = #arr - i + 1 -- from end (reverse order)
					end
					assert.equal(expected, arr[quickselect(arr, i, less_than)])
				end
			end
			describe("selected", function()
				it("out of bound indices", function()
					assert.has_error(function()
						quickselect({}, 1, less_than)
					end)
					assert.has_error(function()
						quickselect({}, 0, less_than)
					end)
					assert.has_error(function()
						quickselect({ 1, 2, 3 }, 0, less_than)
					end)
					assert.has_error(function()
						quickselect({ 1, 2, 3 }, 4, less_than)
					end)
				end)
				it("edge cases", function()
					test_sorted({ 42 })
					test_permutation({ 1 })
				end)
				it("sorted arrays", function()
					test_sorted({ "aa", "bb", "cb", "cc" })
					test_sorted({ 1, 3, 5, 9, 42, 101 })
				end)
				it("permutations", function()
					test_permutation({ 5, 4, 1, 2, 3 })
				end)
				it("slices", function()
					local function test_slice(expected, t, sorted_idx, from, to)
						assert.equal(expected, t[quickselect(t, sorted_idx, less_than, from, to)])
					end
					test_slice(2, { 4, 3, 2, 1 }, 2, 2, nil)
					test_slice(2, { 4, 3, 2, 1 }, 2, 2, 4)
					test_slice(3, { 4, 3, 2, 1 }, 2, nil, 3)
				end)
			end)
			describe("random", function()
				it("sorted arrays", function()
					for _ = 1, n do
						-- Test a sorted array of random values from 1 to n
						local len = math.random(n)
						local arr = {}
						for i = 1, len do
							arr[i] = math.random(n)
						end
						table.sort(arr)
						test_sorted(arr)
					end
				end)
				it("permutations", function()
					local shuffle = require("random.shuffle")
					for _ = 1, n do
						-- Test a random permutation of 1 to n
						local len = math.random(n)
						local arr = {}
						for i = 1, len do
							arr[i] = i
						end
						shuffle(arr)
						test_permutation(arr)
					end
				end)
			end)
		end
		describe("ascending (default)", function()
			test_order(false)
		end)
		describe("descending", function()
			test_order(true)
		end)
	end
	describe("default pivot picking strategy (random)", function()
		test_quickselect(build_quickselect(), 100)
	end)
	describe("supports different pivot picking strategies", function()
		local function test_strategy(name, choose_pivot)
			describe("select " .. name, function()
				test_quickselect(
					build_quickselect(function()
						return choose_pivot
					end),
					20
				)
			end)
		end
		test_strategy("first", function(from, _)
			return from
		end)
		test_strategy("last", function(_, to)
			return to
		end)
		test_strategy("mid", function(from, to)
			return math.floor((from + to) / 2)
		end)
		describe("median of medians", function()
			test_quickselect(quickselect_median_of_medians, 50)
		end)
	end)
end)
