describe("Gale-Shapley", function()
	local gale_shapley = require("misc.stable_marriage.gale_shapley")
	it("finds the unique solution optimal for men and pessimal for women", function()
		assert.same(
			{
				Diana = "Blake",
				Ellen = "Caleb",
				Fiona = "Arnie",
			},
			gale_shapley({
				Diana = { "Caleb", "Blake", "Arnie" },
				Ellen = { "Blake", "Arnie", "Caleb" },
				Fiona = { "Arnie", "Caleb", "Blake" },
			}, {
				Arnie = { "Diana", "Fiona", "Ellen" },
				Blake = { "Fiona", "Diana", "Ellen" },
				Caleb = { "Fiona", "Ellen", "Diana" },
			})
		)
	end)
end)
