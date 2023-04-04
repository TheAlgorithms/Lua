-- Gale-Shapley algorithm for the Stable Marriage problem;
-- finds the unique solution optimal for men and pessimal for women
return function(
	women, -- table `[woman] = men` where `men` is a list of men in order of descending preference
	men -- table `[man] = women` where `women` is a list of women in order of descending preference
)
	-- Build rank lookup for women to efficiently query whether a new partner is preferred
	local women_ranks = {} -- [woman][man] = rank
	for woman, prefs in pairs(women) do
		women_ranks[woman] = {}
		for rank, man in ipairs(prefs) do
			women_ranks[woman][man] = rank
		end
	end

	local free_men = {} -- list of men without a fiancée (no particular order required)
	local men_rank = {} -- [man] = rank of current fiancée
	for man in pairs(men) do
		table.insert(free_men, man)
		men_rank[man] = 0
	end

	local elopements = {} -- [woman] = man
	while #free_men > 0 do
		local man = table.remove(free_men)
		men_rank[man] = men_rank[man] + 1
		local woman = men[man][men_rank[man]] -- next woman on the preference list of the man
		local woman_ranks = women_ranks[woman]
		local cur_fiance = elopements[woman] -- may be `nil`, but this is handled fine
		if woman_ranks[man] < (woman_ranks[cur_fiance] or math.huge) then -- ranks higher <=> lower index than current fiancé
			table.insert(free_men, cur_fiance) -- (potential) previous man is free now
			elopements[woman] = man
		else -- rejected, man stays free
			table.insert(free_men, man)
		end
	end
	return elopements -- table `[woman] = man`
end
