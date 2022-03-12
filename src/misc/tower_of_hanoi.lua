return function(
	height, -- height of the tower on the first pole
	move -- function(from_pole, to_pole), where the poles are one of 1, 2, or 3
)
	local function solve(left, from, spare, to)
		if left == 0 then
			return
		end
		solve(left - 1, from, to, spare)
		move(from, to)
		solve(left - 1, spare, from, to)
	end
	solve(height, 1, 2, 3)
end
