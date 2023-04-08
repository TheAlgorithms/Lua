-- Implementation helper for metatable-based "classes"
return function(class_table, superclass_table)
	if superclass_table then
		setmetatable(class_table, { __index = superclass_table })
	end
	local new = assert(class_table.new)
	local metatable = { __index = class_table }
	function class_table.new(...)
		return setmetatable(new(...), metatable)
	end
	return class_table
end
