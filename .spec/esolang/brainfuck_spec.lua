describe("Brainfuck interpreter", function()
	local exec_bf = require("esolang.brainfuck")
	it("executes hello world", function()
		local hello_world = {}
		local last_char = "\0"
		for char in ("Hello World!\n"):gmatch(".") do
			local diff = char:byte() - last_char:byte()
			if diff > 0 then
				for _ = 1, diff do
					table.insert(hello_world, "+")
				end
			else
				for _ = diff, -1 do
					table.insert(hello_world, "-")
				end
			end
			table.insert(hello_world, ".")
			last_char = char
		end
		local buffer = {}
		exec_bf(table.concat(hello_world), nil, {
			write = function(_, str)
				table.insert(buffer, str)
			end,
		})
		assert.same("Hello World!\n", table.concat(buffer))
	end)
	it("executes uppercasing", function()
		local uppercasing = [[
			,              char = read(1)
			[              while (char) {
				>              i
				++++++++       i = 8
				[              while (i) {
					<----           char minus= 4: 4 * 8 = 32 = lower minus upper ASCII
					>-              i minus= 1
				]              }
				<.             print(char)
				,              char = read(1)
			]              }
		]]
		local input, input_idx = "helloworld\0", 0
		local buffer = {}
		exec_bf(uppercasing, {
			read = function(_, chars)
				assert.equal(1, chars)
				input_idx = input_idx + 1
				return input:sub(input_idx, input_idx)
			end,
		}, {
			write = function(_, str)
				table.insert(buffer, str)
			end,
		})
		assert.equal("HELLOWORLD", table.concat(buffer))
	end)
end)
