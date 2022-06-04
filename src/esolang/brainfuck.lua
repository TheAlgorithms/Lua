-- Simple brainfuck interpreter
-- Has "infinite" memory in both directions
-- Uses unsigned bytes for memory cells
-- Uses a zero byte to indicate that the input stream is exhausted
return function(program, input, output)
	input = input or io.input()
	output = output or io.output()
	-- Parse: Match brackets
	local matching_bracket_pos = {}
	local open_bracket_pos = {}
	for pos, char in program:gmatch("()(.)") do
		if char == "[" then
			table.insert(open_bracket_pos, pos)
		elseif char == "]" then
			if #open_bracket_pos == 0 then
				error("unclosed left bracket ] at pos " .. pos)
			else
				local open_pos = table.remove(open_bracket_pos)
				matching_bracket_pos[open_pos] = pos
				matching_bracket_pos[pos] = open_pos
			end
		end
	end
	if #open_bracket_pos ~= 0 then
		error(#open_bracket_pos .. " closing brackets at EOF expected")
	end
	-- Execute
	local data = {}
	local data_pointer = 1
	local function get_byte()
		return data[data_pointer] or 0
	end
	local function set_byte(byte)
		if byte == 0 then
			byte = nil
		end
		data[data_pointer] = byte
	end
	local instruction_pointer = 1
	while instruction_pointer <= #program do
		local char = program:sub(instruction_pointer, instruction_pointer)
		if char == "." then
			output:write(string.char(get_byte()))
		elseif char == "," then
			local read_char = input:read(1)
			-- Read a zero byte if the input handle is exhausted
			set_byte(read_char and read_char:byte() or 0)
		elseif char == ">" then
			data_pointer = data_pointer + 1
		elseif char == "<" then
			data_pointer = data_pointer - 1
		elseif char == "+" then
			set_byte((get_byte() + 1) % 256) -- unsigned byte arithmetic
		elseif char == "-" then
			set_byte((get_byte() - 1) % 256) -- unsigned byte arithmetic
		elseif char == "[" then
			if get_byte() == 0 then
				-- Jump to closing bracket (skip loop)
				instruction_pointer = matching_bracket_pos[instruction_pointer]
			end
		elseif char == "]" then
			if get_byte() ~= 0 then
				-- Jump back to opening bracket (repeat loop)
				instruction_pointer = matching_bracket_pos[instruction_pointer]
			end
		end
		instruction_pointer = instruction_pointer + 1
	end
end
