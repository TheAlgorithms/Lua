# Contribution Guidelines

## Licensing

* Code submitted in pull requests must be your own.
* You must license your work under the projects license, the MIT license.

## Code Quality

Contributed Lua code must fulfill the following criteria:

* Tests: Busted unit tests must be added in `.spec`. The code must pass them. See the [Binary search tests](https://github.com/TheAlgorithms/Lua/blob/main/.spec/searches/binary_search_spec.lua) for an example.
* Modularity: Return the algorithm or data structure as a function or an API table. This also means no side effects: The global environment in particular may not be altered by modules.
* Redundancy free: If a module, it should `require` them instead of implementing them itself.
* Formatting: StyLua defaults
* Linting: Luacheck
* Comments: Please add explanatory comments for code which isn't self-explaining. Comments are not a replacement for good variable naming and a clear and concise control flow using functions when necessary. To document the usage of your algorithm, place comments right above `return` statements to document return values, and add comments next to function arguments - in the parameter list - to document them. See [Binary Search](https://github.com/TheAlgorithms/Lua/blob/main/src/searches/binary_search.lua) for an example.
