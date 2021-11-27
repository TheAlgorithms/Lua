-- Implementation helper for metatable-based "classes"
return function(class_table)
	local new = assert(class_table.new)
	local metatable = { __index = class_table }
	function class_table.new(...)
		return setmetatable(new(...), metatable)
	end
	return class_table
end
