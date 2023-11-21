module RBTrees

import ..SearchingTreeCore:AbstractBinTree, leftmost, rightmost, leftnearest, rightnearest, Nil, nil, Nillable, Optional, left, right, SubtreeIterator
using AbstractTrees


mutable struct RBTreeMapNode{K, V} <: AbstractBinTree{Pair{K, V}}
    key::K
    value::V
    left::Nillable{RBTreeMapNode{K, V}}
    right::Nillable{RBTreeMapNode{K, V}}
    parent::Nillable{RBTreeMapNode{K, V}}
    color::Bool # true for red, false for black
end
RBTreeMapNode{K, V}(key, value) where {K, V} = RBTreeMapNode{K, V}(key, value, nil, nil, nil, false)
AbstractTrees.nodevalue(t::RBTreeMapNode{K, V}) where {K, V} = (t.key=>t.value)
AbstractTrees.printnode(io::IO, t::RBTreeMapNode{K, V}) where {K, V} = print(io, (is_red(t) ? "R" : "B"), "(", t.key, "=>", t.value, ")")
is_red(node::RBTreeMapNode{K, V}) where {K, V} = node.color
is_red(::Nil) = false
is_black(node::RBTreeMapNode{K, V}) where {K, V} = !(node.color)
is_black(::Nil) = true


function search_node(root::RBTreeMapNode{K, V}, key::K) where{K, V}
    x = root
    while (x !== nil) && (key !== x.key)
        if key < x.key
            x = x|>left
        else
            x = x|>right
        end
    end
    return x
end
search_node(::Nil, key) = nil

function search_smallest_geq(root::Nillable{RBTreeMapNode{K, V}}, key) where{K, V} 
    closest = root
    closest===nil && return nil
    while closest.key < key
        closest = closest.right
        closest===nil && return nil
    end # closest larger than key and is not nil
    x = closest
    while (x !== nil)
        if x.key < key
            x = x.right
        else
            closest = x # must not be nil
            x = x.left
        end
    end
    return closest
end

function search_largest_leq(root::Nillable{RBTreeMapNode{K, V}}, key) where{K, V} 
    closest = root
    closest===nil && return nil
    while closest.key > key
        closest = closest.left
        closest===nil && return nil
    end # closest smaller than key and is not nil
    x = closest
    while (x !== nil)
        if x.key > key
            x = x.left
        else
            closest = x # must not be nil
            x = x.right
        end
    end
    return closest
end

function left_rotate!(root::RBTreeMapNode{K, V}, x::RBTreeMapNode{K, V}) where{K, V} # assume that x.right ≠ nil
    root = root
    y = x|>right
    x.right = y|>left
    (y|>left).parent = x
    y.parent = x.parent
    if x.parent === nil
        root = y # y becomes root
    elseif x === x.parent.left
        x.parent.left = y
    else
        x.parent.right = y
    end
    y.left = x
    x.parent = y
    return root
end

function right_rotate!(root::RBTreeMapNode{K, V}, x::RBTreeMapNode{K, V}) where{K, V} # assume that x.left ≠ nil
    root = root
    y = x.left
    x.left = y.right
    if y.right !== nil
        y.right.parent = x
    end
    y.parent = x.parent
    if x.parent === nil
        root = y # y becomes root
    elseif x === x.parent.left
        x.parent.left = y
    else
        x.parent.right = y
    end
    y.right = x
    x.parent = y
    return root
end

function rbinsert!(root::RBTreeMapNode{K, V}, key::K, value::V) where{K, V}
    root = root
    x = root
    y = nil
    while x !== nil
        y = x
        if y === nil
            root = RBTreeMapNode{K, V}(key, value)
        elseif key === y.key
            y.value = value
            return root
        elseif key < y.key
            x = y.left
        else
            x = y.right
        end
    end
    z = RBTreeMapNode{K, V}(key, value, nil, nil, y, true)
    if y === nil
        root = z
    elseif key < y.key
        y.left = z
    else
        y.right = z
    end
    root = rbinsert_fixup!(root, z)
    return root
end

function rbinsert_fixup!(root::RBTreeMapNode{K, V}, z::RBTreeMapNode{K, V}) where {K, V}
    while z.parent|>is_red # z.parent must exist and must not be root
        if z.parent === z.parent.parent.left
            y = z.parent.parent.right
            if y|>is_red
                z.parent.color = false
                y.color = false
                z.parent.parent.color = true
                z = z.parent.parent
            elseif z === z.parent.right
                z = z.parent
                root = left_rotate!(root, z)
            else
                z.parent.color = false
                z.parent.parent.color = true
                root = right_rotate!(root, z.parent.parent)
            end
        else
            y = z.parent.parent.left
            if y|>is_red
                z.parent.color = false
                y.color = false
                z.parent.parent.color = true
                z = z.parent.parent
            elseif z === z.parent.left
                z = z.parent
                root = right_rotate!(root, z)
            else
                z.parent.color = false
                z.parent.parent.color = true
                root = left_rotate!(root, z.parent.parent)
            end
        end
    end 
    root.color = false
    return root
end

function rb_delete!(root::RBTreeMapNode{K, V}, z::RBTreeMapNode{K, V}) where {K, V}
    root = root
    if z.left === nil || z.right === nil
        y = z
    else
        y = successor(z)
    end
    if y.left !== nil
        x = y.left
    else
        x = y.right
    end
    x !== nil && (x.parent = y.parent)
    if y.parent === nil
        root = x
    elseif y === y.parent.left
        y.parent.left = x
    else
        y.parent.right = x
    end
    if y !== z
        z.key = y.key
        z.value = y.value
    end
    if y|>is_black
        root = rb_delete_fixup!(root, x)
    end
    return root
end

function rb_delete_fixup!(root::RBTreeMapNode{K, V}, x::RBTreeMapNode{K, V}) where {K, V}
    root = root
    while (x !== root) && (x|>is_black)
        if x === x.parent.left
            w = x.parent.right
            if w|>is_red
                w.color = false
                x.parent.color = true
                root = left_rotate!(root, x.parent)
                w = x.parent.right
            end
            if (w|>left|>is_black) && (w|>right|>is_black)
                w.color = true
                x = x.parent
            elseif (w.right)|>is_black
                w.left.color = false
                w.color = true
                root = right_rotate!(root, w)
                w = x.parent.right
            else
                w.color = x.parent.color
                x.parent.color = false
                w.right.color = false
                root = left_rotate!(root, x.parent)
                x = root
            end
        else # left and right exchanged
            w = x.parent.left
            if w|>is_red
                w.color = false
                x.parent.color = true
                root = right_rotate!(root, x.parent)
                w = x.parent.left
            end
            if (w|>right|>is_black) && (w|>left|>is_black)
                w.color = true
                x = x.parent
            elseif (w.left)|>is_black
                w.right.color = false
                w.color = true
                root = left_rotate!(root, w)
                w = x.parent.left
            else
                w.color = x.parent.color
                x.parent.color = false
                w.left.color = false
                root = right_rotate!(root, x.parent)
                x = root
            end
        end
    end
    x.color = false
    return root
end

rb_delete_fixup!(root, ::Nil) = root

successor(x::RBTreeMapNode{K, V}) where {K, V} = leftmost(x.right)
is_leaf(x::RBTreeMapNode{K, V}) where {K, V} = (x.left === nil) && (x.right === nil)

"""
    RBTreeMap{K, V}

A red-black tree map with key type `K` and value type `V`.

# Fields

- `root::Union{RBTreeMapNode{K, V}, Nil}`: the root node of the tree, might either be a [`RBTreeMapNode`](@ref) or `nil` when the tree is empty.

# Constructors

- `RBTreeMap{K, V}()`: create an empty tree map

An RBTreeMap is a subtype of `AbstractDict{K, V}` and it is an ordered map based on red-black tree data structure.
It implements the following interfaces:
- [`Base.get(d::RBTreeMap{K, V}, key::K, default) where{K, V}`](@ref): 
- [`Base.getindex(d::RBTreeMap{K, V}, key::K) where{K, V}`](@ref)
- [`Base.setindex!(d::RBTreeMap{K, V}, value::V, key::K) where{K, V}`](@ref)
- [`Base.delete!(d::RBTreeMap{K, V}, key::K) where{K, V}`](@ref)
- [`Base.iterate(d::RBTreeMap{K, V}) where{K, V}`](@ref)
- [`Base.empty(d::RBTreeMap{K, V}) where{K, V}`](@ref): return an empty RBTreeMap with the same key and value types as `d`
- [`Base.empty!(d::RBTreeMap{K, V}) where{K, V}`](@ref): empty `d` in place
- [`Base.isempty(d::RBTreeMap{K, V}) where{K, V}`](@ref): return `true` if `d` is empty
"""
mutable struct RBTreeMap{K, V} <: AbstractDict{K, V}
    root::Nillable{RBTreeMapNode{K, V}}
end
RBTreeMap{K, V}() where {K, V} = RBTreeMap{K, V}(nil)

"""
    Base.get(d::RBTreeMap{K, V}, key::K, default)

Get the value of `key` in `d`, return `default` if `key` is not in `d`
"""
function Base.get(d::RBTreeMap{K, V}, key::K, default) where{K, V}
    node = search_node(d.root, key)
    if node === nil
        return default
    else
        return node.value
    end
end

"""
    Base.getindex(d::RBTreeMap{K, V}, key::K)

Get the value of `key` in `d`, throw `KeyError` if `key` is not in `d`. Called by `d[key]`.
"""
function Base.getindex(d::RBTreeMap{K, V}, key::K) where{K, V}
    node = search_node(d.root, key)
    if node === nil
        throw(KeyError(key))
    else
        return node.value
    end
end

"""
    Base.setindex!(d::RBTreeMap{K, V}, value::V, key::K)

Set the value of `key` in `d` to `value`. Called by `d[key] = value`.
"""
function Base.setindex!(d::RBTreeMap{K, V}, value::V, key::K) where{K, V}
    if d.root === nil
        d.root = RBTreeMapNode{K, V}(key, value)
    else
        d.root = rbinsert!(d.root, key, value)
    end
end

"""
    Base.delete!(d::RBTreeMap{K, V}, key::K)

Delete `key` in `d`. Called by `delete!(d, key)`.
"""
function Base.delete!(d::RBTreeMap{K, V}, key::K) where{K, V}
    node = search_node(d.root, key)
    if node !== nil
        d.root = rb_delete!(d.root, node)
    end
    return d
end

"""
    Base.iterate(d::RBTreeMap{K, V})

Iterate through `d` in ascending order of keys.
"""
function Base.iterate(d::RBTreeMap{K, V}) where{K, V}
    if d.root === nil
        return nothing
    else
        node, state = iterate(d.root)
        return (node.key=>node.value), state
    end
end
function Base.iterate(d::RBTreeMap{K, V}, state) where{K, V}
    result = iterate(d.root, state)
    result === nothing && return nothing
    node, state = result
    return node.key=>node.value, state
end
Base.IteratorSize(::Type{RBTreeMap{K, V}}) where{K, V} = Base.HasLength()
Base.length(d::RBTreeMap{K, V}) where{K, V} = if d.root === nil 0 else length(d.root) end
Base.IteratorEltype(::Type{RBTreeMap{K, V}}) where{K, V} = Base.HasEltype()
Base.eltype(::RBTreeMap{K, V}) where{K, V} = Pair{K, V}

"""
    Base.empty(d::RBTreeMap{K, V})

Return an empty RBTreeMap with the same key and value types as `d`.
"""
Base.empty(::RBTreeMap{K, V}) where{K, V} = RBTreeMap{K, V}()

"""
    Base.empty!(d::RBTreeMap{K, V})

Empty `d` in place.
"""
Base.empty!(d::RBTreeMap{K, V}) where{K, V} = (d.root = nil; d)

"""
    Base.isempty(d::RBTreeMap{K, V})

Return `true` if `d` is empty.
"""
Base.isempty(d::RBTreeMap{K, V}) where{K, V} = d.root === nil


struct Range{S}
    start::Optional{S}
    stop::Optional{S}
end

Range(::Nothing, ::Nothing) = Range{Nothing}(nothing, nothing)
# Range(start::S, stop::T) where {S, T} = Range{S, T}(start, stop)
(..)(s, t) = Range(s, t)
Base.show(io::IO, r::Range) = print(io, r.start, "..", r.stop)
Base.lastindex(::RBTreeMap{K, V}) where{K, V} = nothing
Base.firstindex(::RBTreeMap{K, V}) where{K, V} = nothing


struct RBTreeMapRangeView{K, V}<:AbstractDict{K, V}
    original::RBTreeMap{K, V}
    start::Nillable{RBTreeMapNode{K, V}}
    jumpback::Vector{RBTreeMapNode{K, V}}
    stop::Optional{K}
end

function Base.get(d::RBTreeMapRangeView{K, V}, key::K, default) where{K, V}
    start, stop = d.start, d.stop
    (
        ((start !== nil) && (key < start.value)) ||
        ((stop !== nothing) && (key > stop))
    ) && return default

    node = search_node(d.original.root, key)
    if node === nil
        return default
    else
        return node.value
    end
end

function Base.iterate(d::RBTreeMapRangeView{K, V}) where{K, V}
    result = iterate(root, (d.start, d.jumpback))
    result === nothing && return nothing
    node, state = result
    return node.key=>node.value, state
end

# function Base.iterate(d::RBTreeMapRangeView{K, V}, state) where{K, V}
#     result = iterate(d.original.root, state)
#     result === nothing && return nothing
#     node, state = result
#     if node.value > d.stop
#     return node.key=>node.value, state
# end

# Base.IteratorSize(::Type{RBTreeMapRangeView{K, V}}) where{K, V} = Base.SizeUnknown()
# Base.length(d::RBTreeMapRangeView{K, V}) where{K, V} = if d.subtreeroot === nil 0 else length(d.subtreeroot) - length(d.subsubtreeroot) end
# Base.IteratorEltype(::Type{RBTreeMapRangeView{K, V}}) where{K, V} = Base.HasEltype()
# Base.eltype(::RBTreeMapRangeView{K, V}) where {K, V} = Pair{K, V}

# Base.empty(::RBTreeMapRangeView{K, V}) where {K, V} = RBTreeMap{K, V}()
# Base.isempty(d::RBTreeMapRangeView{K, V}) where {K, V} = ((d.original.root) === nil)
# Base.getindex(d::RBTreeMap{K, V}, ::Range{Nothing}) where {K, V} = d
# function Base.getindex(d::RBTreeMap{K, V}, r::Range{K}) where {K, V}
#     start, stop = r.start, r.stop
#     if (start === nothing) && (stop === nothing)
#         return d
#     end
#     next = iterate(d.original.root)
#     if next === nothing
#         return RBTreeMapRangeView{K, V}(d, nil, [], nothing)
#     end
#     node, state = next
# end



# struct LastIndex end
# struct FirstIndex end
# Base.(<)(::FirstIndex, other) = true
# Base.(<)(other, ::FirstIndex) = false
# Base.(<)(::FirstIndex, ::FirstIndex) = false
# Base.(<=)(::FirstIndex, other) = true
# Base.(<=)(other, ::FirstIndex) = false
# Base.(<=)(::FirstIndex, ::FirstIndex) = true


# Base.(<)(other, ::LastIndex) = true
# Base.(<)(::LastIndex, other) = false
# Base.(<)(::LastIndex, ::LastIndex) = false
# Base.(<=)(other, ::LastIndex) = true
# Base.(<=)(::LastIndex, other) = false
# Base.(<=)(::LastIndex, ::LastIndex) = true

# Base.(<)(::FirstIndex, ::LastIndex) = true
# Base.(<)(::LastIndex, ::FirstIndex) = false
# Base.(<=)(::FirstIndex, ::LastIndex) = true
# Base.(<=)(::LastIndex, ::FirstIndex) = false





function bloodline(node::Nillable{RBTreeMapNode})
    if node === nil
        return []
    else
        return [node, bloodline(node.parent)...]
    end
end

blackroot_test(root::RBTreeMapNode) = is_black(root)
function red_child_test(root::RBTreeMapNode)
    if root === nil
        return true
    else
        nodes = collect(root)
        reds = filter(is_red, nodes)
        return all(
            (node->is_black(node.left) && is_black(node.right)),
            reds
        )
    end
end
function black_height_test(root::RBTreeMapNode)
    leafs = filter(is_leaf, collect(root))
    pathes = bloodline.(leafs)
    black_heights = [
        length(filter(is_black, path)) for path in pathes
    ]
    return length(unique(black_heights)) <= 1
end

function is_rbtree(root::RBTreeMapNode)
    return blackroot_test(root) && red_child_test(root) && black_height_test(root)
end
is_rbtree(::Nil) = true

export RBTreeMap

end