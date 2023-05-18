# B-Tree

## Design Decisions

### Iteration

Coroutines have significant memory overhead, but allow for a very elegant implementation.
From rudimentary testing, they also seem to be in the same ballpark performance-wise as iterative implementations.

Since object comparisons may be expensive, the maximum and minimum key are effectively only searched once.
This leads to logarithmically many object comparisons as opposed to linearly many object comparisons if this was implemented naively.

No parent pointers are stored in nodes; instead, we always store the current path in the tree in the call stack.
