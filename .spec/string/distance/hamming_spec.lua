describe("Hamming distance", function()
	local hamming_distance = require("string.distance.hamming")

	local function check_basic(a, b, expected)
		assert.equal(expected, hamming_distance(a, b))
		assert.equal(0, hamming_distance(a, a))
	end

	local function check_with_reversed_inputs(a, b, expected)
		assert.equal(expected, hamming_distance(a:reverse(), b:reverse()))
		assert.equal(0, hamming_distance(a:reverse(), a:reverse()))
	end

	local function check_all(a, b, expected)
		check_basic(a, b, expected)
		check_with_reversed_inputs(a, b, expected)
	end

	local function test(a, b, expected)
		check_all(a, b, expected)
		check_all(b, a, expected)
	end

	it("should handle general cases", function()
		test("", "", 0)
		test("a", "a", 0)
		test("a", "A", 1)
		test("cąx", "cąy", 1)
		test("mama", "tata", 2)
		test("xxx", "Xxx", 1)
		test("1234", "2345", 4)
	end)

	it("should throw error for inputs of different length", function()
		assert.has_error(function()
			hamming_distance("z", "")
		end)
	end)
end)
