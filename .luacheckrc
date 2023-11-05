files[".spec/**/*"] = {
	read_globals = {
		"describe",
		"it",
		"before_each",
		"setup",
		"teardown",
		assert = {
			fields = {
				truthy = {},
				falsy = {},
				equal = {},
				same = {},
				has_error = {},
				near = {}
			}
		}
	}
}
