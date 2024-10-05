-- Fibonacci.lua

-- Fibonacci Sequence:
-- The Fibonacci sequence is a series of numbers where each number (after the first two) is the sum of the two preceding ones.
-- More information: https://en.wikipedia.org/wiki/Fibonacci_number

-- Author: Gyandeep

--      Implemented nth Fibonacci number using different approaches in O(2^N) , O(N) , O(logN) , O(1) .


-- Function to calculate Fibonacci numbers using recursion
-- Time Complexity: O(2^n)
function fibonacci_recursive(n)
    if n <= 0 then
        return 0
    elseif n == 1 then
        return 1
    else
        return fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)
    end
end

-- Function to calculate Fibonacci numbers using dynamic programming (DP)
-- Time Complexity: O(n)
function fibonacci_dp(n)
    local fib = {}
    fib[0] = 0
    fib[1] = 1
    for i = 2, n do
        fib[i] = fib[i - 1] + fib[i - 2]
    end
    return fib[n]
end

-- Function to calculate Fibonacci numbers using Binet's formula
-- Time Complexity: O(1)
-- Limitation: Accurate results up to n = 70 due to limitations of floating-point precision.
function fibonacci_binet(n)
    local phi = (1 + math.sqrt(5)) / 2
    local psi = (1 - math.sqrt(5)) / 2
    return math.floor((math.pow(phi, n) - math.pow(psi, n)) / math.sqrt(5))
end

-- Function to multiply two 2x2 matrices
-- Time Complexity: O(1)
function matrix_multiply(a, b)
    local c = {}
    c[1] = a[1] * b[1] + a[2] * b[3]
    c[2] = a[1] * b[2] + a[2] * b[4]
    c[3] = a[3] * b[1] + a[4] * b[3]
    c[4] = a[3] * b[2] + a[4] * b[4]
    return c
end

-- Function to raise a 2x2 matrix to a power n using divide and conquer
-- Time Complexity: O(log(n))
function matrix_power(matrix, n)
    if n == 0 then
        return {1, 0, 0, 1} -- Identity matrix
    elseif n % 2 == 0 then
        local half_pow = matrix_power(matrix, n / 2)
        return matrix_multiply(half_pow, half_pow)
    else
        local half_pow = matrix_power(matrix, (n - 1) / 2)
        return matrix_multiply(matrix, matrix_multiply(half_pow, half_pow))
    end
end

-- Function to calculate Fibonacci numbers using matrix exponentiation
-- Time Complexity: O(log(n))
function fibonacci_matrix(n)
    if n <= 0 then
        return 0
    else
        local matrix = {1, 1, 1, 0}
        local result_matrix = matrix_power(matrix, n - 1)
        return result_matrix[1]
    end
end