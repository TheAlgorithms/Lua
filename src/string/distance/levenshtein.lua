-- Levenshtein "edit" distance:
-- Minimum number of single-char edits (insertions, deletions or substitutions) required to change one word into another
return function(
	s, -- string
	t -- other string
)
	-- Dynamic programming; only one row of lookbehind is needed to compute the next row.
	-- The `j`-th element of the `i`-th row is the Levenshtein distance from
	-- the first `i` chars of s to the first `j` chars of `t`.
	local prev_row, cur_row = {}, {}

	-- Build 0-th row: distance from empty suffix of str to suffixes of t
	for j = 0, #t do
		prev_row[j] = j -- j insertions required from empty string to first j chars of t
	end

	for i = 1, #s do
		-- Build the i-th row
		cur_row[0] = i -- i deletions required from first i chars of s to empty string
		for j = 1, #t do
			cur_row[j] = s:byte(i) == t:byte(j) and prev_row[j - 1] -- same chars at positions i & j
				or 1 -- edit required
					+ math.min(
						prev_row[j - 1], -- substitution (replace s[i] with t[j])
						prev_row[j], -- deletion (of s[i])
						cur_row[j - 1] -- insertion (appending t[j] to first i chars of s)
					)
		end
		prev_row, cur_row = cur_row, prev_row -- swap rows
	end

	return prev_row[#t] -- last entry of the last row = distance between str & other_str
end
