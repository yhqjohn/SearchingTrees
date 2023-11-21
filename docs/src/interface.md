# Interfaces

All binary searching trees are subtypes of `AbstractBinTree{T}`. 

```@docs
AbstractBinTree{T}
AbstractTrees.children(t::T) where {T<:AbstractBinTree}
Base.iterate(t::T) where {T<:AbstractBinTree}
```