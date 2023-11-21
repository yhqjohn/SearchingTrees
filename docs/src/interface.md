```@meta
CurrentModule = SearchingTrees.SearchingTreeCore
```

# Interfaces

All binary searching trees are subtypes of `AbstractBinTree{T}`. 
Interfaces for binary searching trees are defined in `SearchingTrees.SearchingTreeCore` module.

## Types

```@docs
AbstractBinTree{T}
```

## Functions

```@docs
AbstractTrees.children(t::T) where {T<:AbstractBinTree}
Base.iterate(t::T) where {T<:AbstractBinTree}
```