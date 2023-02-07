describe("Union-find", function()
	local union_find = require("data_structures.union_find")
	local sets = union_find.new()
	local exp = 8
	it("make set & find", function()
		-- Create a series of sets
		for i = 1, 2 ^ exp do
			sets:make_set(i)
			assert.equal(i, sets:find(i))
		end
	end)
	it("union & find", function()
		-- Union neighboring sets until there is only one set left
		for step_exp = 1, exp do
			local step = 2 ^ step_exp
			for i = 1, 2 ^ exp, step do
				local j = i + step - 1
				sets:union(i, j)
				local rep_i, rep_j = sets:find(i), sets:find(j)
				assert.equal(rep_i, rep_j)
				assert(rep_i == i or rep_i == j)
			end
		end
		-- Afterwards, all elements should be in one set
		local rep = sets:find(1)
		for i = 2, 2 ^ exp do
			assert.equal(rep, sets:find(i))
		end
	end)
end)
