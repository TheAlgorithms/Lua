describe("Tower of Hanoi", function()
	local tower_of_hanoi = require("misc.tower_of_hanoi")
	it("should correctly move all disks from the first to the third pole", function()
		local disks = { { 5, 4, 3, 2, 1 }, {}, {} }
		local function move(from, to)
			local disk = assert(table.remove(disks[from]))
			local top_disk = disks[to][#disks[to]]
			if top_disk then
				assert.truthy(disk < top_disk)
			end
			table.insert(disks[to], disk)
		end
		tower_of_hanoi(#disks[1], move)
		assert.same({ {}, {}, { 5, 4, 3, 2, 1 } }, disks)
	end)
end)
