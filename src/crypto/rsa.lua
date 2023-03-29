local test_prime = require("math.prime.miller_rabin_test")
local find_gcd = require("math.greatest_common_divisor")
local modpow = require("math.modpow")

local rsa = {}

-- Generate a key pair
function rsa.generate_key_pair(
	gen_rand_num -- function() returning a random number (preferably with a high chance of it being prime)
)
	local function random_prime()
		local prime
		repeat
			prime = gen_rand_num()
		until test_prime(prime)
		return prime
	end
	local p, q = random_prime(), random_prime()
	local n = p * q
	local phi_n = (p - 1) * (q - 1) -- euler totient of n
	-- Now choose an e coprime to n; d is generated as a byproduct by the extended euclidean algorithm
	local e, gcd, _, d
	repeat
		e = gen_rand_num()
		gcd, _, d = find_gcd(phi_n, e) -- ed = 1 mod phi_n
	until gcd == 1 -- e is coprime to n
	d = d % phi_n -- force d to be positive and less than phi_n
	return n, -- shared part of the key (common to private & public key pair)
		e, -- public part of the key - (usually) used for encryption
		d -- private part of the key - (usually) used for decryption
end

-- Encrypt/decrypt (depending on what is passed)
function rsa.cryption(
	n, -- shared part of the key (common to private & public key pair)
	e_or_d, -- public/private part of the key
	m -- message (number)
)
	return modpow(m, e_or_d, n)
end

return rsa
