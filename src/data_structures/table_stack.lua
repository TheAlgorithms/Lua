-- Table (implementation-dependant, in practice array list) based stack
-- Worst-case linear time for basic operations, in practice amortized constant time and significantly less overhead
-- Merely a OOP wrapper for Lua's table library
local table_stack = {}

function table_stack.new()
	return {}
end

function table_stack:empty()
	return self[1] == nil
end

function table_stack:push(value)
	table.insert(self, value)
end

function table_stack:top()
	return self[#self]
end

function table_stack:pop()
	return table.remove(self)
end

return require("class")(table_stack)
