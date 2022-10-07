local floor = math.floor

-- Converts a date to a day-of-week
return function(
	-- positive integer, year AD
	year,
	-- integer from 1 to 12 corresponding to Jan. - Dec. (both inclusive)
	month,
	-- integer from 1 to days of month
	day_of_month
)
	-- Count Jan. & Feb. as 13th & 14th month of the prev. year respectively
	if month <= 2 then
		year = year - 1
		month = month + 12
	end
	-- Zeller's congruence
	local day_of_week = (
		day_of_month
		+ floor(13 / 5 * (month + 1))
		+ year
		+ floor(year / 4)
		- floor(year / 100)
		+ floor(year / 400)
	) % 7 -- Lua's remainder operator properly returns a positive number here
	if day_of_week == 0 then -- Sat.
		day_of_week = 7 -- convert to 1-based 7
	end
	return day_of_week -- number: Sun. is 1, Sat. is 7 - consistent with the `wday` field of `os.date("*t", ...)`
end
