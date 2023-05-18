# Binary Search Tree

## Design Decisions

The children typically called "left" and "right" use the boolean keys `true` and `false`,
corresponding to the values `less_than` assumes for the values of the subtrees in comparison to the pivot.

This might seem unintuitive at first, but it allows shortening a few constructs and in particular
allows conveniently "mirroring" code by simply negating the booleans.
