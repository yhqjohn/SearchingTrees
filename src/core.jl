module SearchingTreeCore

using AbstractTrees

struct Nil end
nil = Nil()
Nillable{T} = Union{T, Nil}
Base.setproperty!(::Nil, ::Symbol, v) = v

Optional{T} = Union{T, Nothing}


"""
    abstract type AbstractBinTree{T} <: AbstractNode{T}

AbstractBinTree is an abstract type for binary trees. It is a subtype of `AbstractTrees.AbstractNode{T}`.
# interface
Such methods should be implemented for `AbstractBinTree{T}`:
- `left(t::AbstractBinTree)`: return the left child of `t`. The default implementation is `t.left`.
- `right(t::AbstractBinTree)`: return the right child of `t`. The default implementation is `t.right`.
- `parent(t::AbstractBinTree)`: return the parent of `t`. This should be implemented if you want to use the default `iterate` method. The default implementation is `t.parent`.
- `nodevalue(t::AbstractBinTree{T})`: return the value of `t` of type `T`.
"""
abstract type AbstractBinTree{T} <: AbstractNode{T} end

# interface
left(t::T) where {T<:AbstractBinTree} = t.left
right(t::T) where {T<:AbstractBinTree} = t.right
Base.parent(t::T) where {T<:AbstractBinTree} = t.parent
AbstractTrees.nodevalue(t::T) where {T<:AbstractBinTree} = throw(NotImplementedError())
# end interface

left(::Nil) = nil
right(::Nil) = nil
Base.parent(::Nil) = nil

AbstractTrees.children(t::T) where {T<:AbstractBinTree} = compose_tuple(left(t), right(t))

function Base.iterate(root::T) where {T<:AbstractBinTree} # iterate over nodes in in-order DFS order
    node = leftmost(root) # node is leftmost node and might be root
    parent_ = node|>parent

    if node|>right === nil # node is leaf, next node is parent
        return (node, (parent_, T[]))
    elseif parent_ === nil
        return (node, (node|>right, T[]))
    else
        return (node, (leftmost(node|>right), T[parent_]))
    end
end
Base.iterate(::Nil) = nothing
function Base.iterate(::T, state::Tuple{Nillable{T}, Vector{T}}) where {T<:AbstractBinTree}
    nextnode, jumpback = state
    node = nextnode
    if node === nil
        return nothing
    end
    if node|>parent === nil
        nextnode = node|>rightnearest
    elseif isleft(node) # node is left child. right nearest is either parent or leftmost of right subtree
        parent_ = node|>parent
        if node|>right === nil
            nextnode = parent_
        else
            if parent_ !== nil
                push!(jumpback, parent_)
            end
            nextnode = leftmost(node|>right)
        end
    else # node is right child. right nearest leftmost of right subtree
        if node|>right === nil
            if isempty(jumpback)
                nextnode = nil
            else
                nextnode = pop!(jumpback)
            end
        else
            nextnode = leftmost(node|>right)
        end
    end
    return (node, (nextnode, jumpback))
end
Base.iterate(::T, ::Nothing) where {T<:AbstractBinTree} = nothing

Base.IteratorSize(::Type{T}) where {T<:AbstractBinTree} = Base.HasLength()
Base.length(t::T) where {T<:AbstractBinTree} = treesize(t)

Base.IteratorEltype(::T) where {T<:AbstractBinTree} = Base.HasEltype()
Base.eltype(::T) where {T<:AbstractBinTree} = T



struct SubtreeIterator{T<:AbstractBinTree}
    root :: T
end
Base.iterate(iter::SubtreeIterator{T}) where T = iterate(iter.root)
function Base.iterate(iter::SubtreeIterator{T}, state::Tuple{Nillable{T}, Vector{T}}) where {T<:AbstractBinTree}
    nextnode, jumpback = state
    node = nextnode
    if node === nil
        return nothing
    end
    if node === iter.root
        nextnode = node|>rightnearest
    elseif isleft(node) # node is left child. right nearest is either parent or leftmost of right subtree
        parent_ = node|>parent
        if node|>right === nil
            nextnode = parent_
        else
            if parent_ !== nil
                push!(jumpback, parent_)
            end
            nextnode = leftmost(node|>right)
        end
    else # node is right child. right nearest leftmost of right subtree
        if node|>right === nil
            if isempty(jumpback)
                nextnode = nil
            else
                nextnode = pop!(jumpback)
            end
        else
            nextnode = leftmost(node|>right)
        end
    end
    return (node, (nextnode, jumpback))
end
Base.IteratorSize(::Type{SubtreeIterator}) = Base.HasLength()
Base.length(iter::SubtreeIterator) = treesize(iter.root)
Base.IteratorEltype(::Type{SubtreeIterator}) = Base.HasEltype()
Base.eltype(::SubtreeIterator{T}) where {T} = T

function leftmost(node::T) where {T<:AbstractBinTree}
    while node|>left !== nil
        node = node|>left
    end
    return node
end
leftmost(::Nil) = nil

function rightmost(node::T) where {T<:AbstractBinTree}
    while node|>right !== nil
        node = node|>right
    end
    return node
end
rightmost(::Nil) = nil

leftnearest(node::T) where {T<:AbstractBinTree} = node|>left|>rightmost
rightnearest(node::T) where {T<:AbstractBinTree} = node|>right|>leftmost
isleft(node::T) where {T<:AbstractBinTree} = node === node|>parent|>left
isright(::Nil) = false

function compose_tuple(x::Nillable{T}, y::Nillable{T}) where T
    if x === nil && y === nil
        return ()
    elseif x === nil
        return (y,)
    elseif y === nil
        return (x,)
    else
        return (x, y)
    end
end

export Nil, nil, Nillable, Optional
export AbstractBinTree, left, right, parent, SubtreeIterator

end