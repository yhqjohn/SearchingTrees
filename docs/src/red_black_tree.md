# Red Black Tree

## Introduction

Red Black Tree is a self-balancing binary search tree. 
It is a binary search tree with one extra bit of information per node: the color, which is either red or black. 
By constraining the node colors on any simple path from the root to a leaf, red-black tree ensures that no such path is more than twice as long as any other, so that the tree is approximately balanced.
A red-black tree is a binary search tree that satisfies the following red-black properties:
- Every node is either red or black.
- The root is black.
- A red node cannot have a red child.
- Every path from the root to a leaf contains the same number of black nodes.

## API
```@docs
RBTreeMap{K, V}
Base.get(d::RBTreeMap{K, V}, key::K, default) where {K, V}
Base.getindex(d::RBTreeMap{K, V}, key::K) where {K, V}
Base.setindex!(d::RBTreeMap{K, V}, value::V, key::K) where{K, V}
Base.delete!(d::RBTreeMap{K, V}, key::K) where {K, V}
Base.iterate(d::RBTreeMap{K, V}) where {K, V}
Base.empty(d::RBTreeMap{K, V}) where {K, V}
Base.empty!(d::RBTreeMap{K, V}) where {K, V}
```
