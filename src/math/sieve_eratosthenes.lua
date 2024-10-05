-- Sieve.lua

-- Sieve of Eratosthenes:
-- The Sieve of Eratosthenes is an efficient algorithm for finding all prime numbers up to a given limit.
-- More information: https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

-- Author: Gyandeep (https://www.linkedin.com/in/gyandeep-katiyar-790ba6256/)

-- Function to find all prime numbers up to a given limit using the Sieve of Eratosthenes
-- Time Complexity: O(n log log n)
function sieve_eratosthenes(limit)
    -- Create a boolean array "is_prime" and initialize all entries as true
    local is_prime = {}
    for i = 2, limit do
        is_prime[i] = true
    end

    -- Start with the first prime number, 2
    local p = 2
    while p * p <= limit do
        -- If is_prime[p] is still true, then it is a prime number
        if is_prime[p] == true then
            -- Mark all multiples of p as non-prime
            for i = p * p, limit, p do
                is_prime[i] = false
            end
        end
        p = p + 1
    end

    -- Collect the prime numbers into a table
    local primes = {}
    for i = 2, limit do
        if is_prime[i] == true then
            table.insert(primes, i)
        end
    end

    return primes
end

-- Assert tests for the Sieve of Eratosthenes function
assert(#sieve_eratosthenes(10) == 4)  -- There are 4 prime numbers up to 10 (2, 3, 5, 7)
assert(#sieve_eratosthenes(20) == 8)  -- There are 8 prime numbers up to 20 (2, 3, 5, 7, 11, 13, 17, 19)
assert(#sieve_eratosthenes(50) == 15) -- There are 15 prime numbers up to 50

print("All tests passed!")
