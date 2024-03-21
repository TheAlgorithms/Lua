# Sorted Set

## Design Decisions

All operations operate on *values* rather than *references*.

Contrary to popular textbooks, operations don't return references to internally used data structures (such as tree nodes).

This makes some sequences of operations slower.
For example if you first `find` a key and then upsert the same key using `insert`;
with a pointer/node-based approach the subsequent upsert could be performed
in constant time - the value would not have to be searched again.

In particular, successor and predecessor operations have worse time complexity than versions of them using references to tree nodes since they need to find the key again each time. Thus efficient iterators are provided.

The problem with operating on node references is that it requires managing these references properly.
It is way too easy to get an invalid reference, breaking data structure invariants.

Major programming languages, including Lua, also provide no "references" to entries e.g. of hash maps.
