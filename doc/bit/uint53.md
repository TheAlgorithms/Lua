# `uint53`

Lua 5.1 provides neither an integer type nor bitwise operators by default;
the provided number type - 64-bit floats (unless configured otherwise) - can however store unsigned integers up to and including $2^{53}$ accurately.
This allows treating integer floats in the range from $0$ to $2^{53} - 1$ (both inclusive) as if they were 53-bit unsigned integers ("`uint53`").
In practice, normalization means that that the mantissa does not actually store the binary representation of an `uint53`.
The bitwise operators can then be implemented using arithmetical operators. For unary operators, bytewise lookup tables are used to speed matters up.
