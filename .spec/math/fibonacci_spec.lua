-- Define the test suite for the Fibonacci module
describe("Fibonacci", function()
    -- Test the recursive Fibonacci function
    it("works with fibonacci_recursive", function()
        assert.is_equal(0, fibonacci.fibonacci_recursive(0))
        assert.is_equal(1, fibonacci.fibonacci_recursive(1))
        assert.is_equal(5, fibonacci.fibonacci_recursive(5))
        assert.is_equal(55, fibonacci.fibonacci_recursive(10))
    end)

    -- Test the dynamic programming Fibonacci function
    it("works with fibonacci_dp", function()
        assert.is_equal(0, fibonacci.fibonacci_dp(0))
        assert.is_equal(1, fibonacci.fibonacci_dp(1))
        assert.is_equal(5, fibonacci.fibonacci_dp(5))
        assert.is_equal(55, fibonacci.fibonacci_dp(10))
    end)

    -- Test Binet's formula Fibonacci function
    it("works with fibonacci_binet", function()
        assert.is_equal(0, fibonacci.fibonacci_binet(0))
        assert.is_equal(1, fibonacci.fibonacci_binet(1))
        assert.is_equal(5, fibonacci.fibonacci_binet(5))
        assert.is_equal(55, fibonacci.fibonacci_binet(10))
    end)

    -- Test matrix exponentiation Fibonacci function
    it("works with fibonacci_matrix", function()
        assert.is_equal(0, fibonacci.fibonacci_matrix(0))
        assert.is_equal(1, fibonacci.fibonacci_matrix(1))
        assert.is_equal(5, fibonacci.fibonacci_matrix(5))
        assert.is_equal(55, fibonacci.fibonacci_matrix(10))
    end)
end)
