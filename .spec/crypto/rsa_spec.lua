describe("RSA", function()
	local rsa = require("crypto.rsa")
	local function gen_rand_num()
		return math.random(1e3, 1e4)
	end
	local n, e, d = rsa.generate_key_pair(gen_rand_num)
	it("encrypts & decrypts (both ways)", function()
		for _ = 1, 1e3 do
			local x = math.random(1e3, 1e4)
			assert.equal(x, rsa.cryption(n, d, rsa.cryption(n, e, x)))
			assert.equal(x, rsa.cryption(n, e, rsa.cryption(n, d, x)))
		end
	end)
end)
