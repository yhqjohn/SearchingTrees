module BinarySearchTrees

import ..SearchingTreeCore:AbstractBinTree, leftmost, Nil, Nillable, nil
using AbstractTrees

mutable struct BinarySearchTree{T} <: AbstractBinTree{T}
    key::T
    parent::Nillable{BinarySearchTree{T}}
    left::Nillable{BinarySearchTree{T}}
    right::Nillable{BinarySearchTree{T}}
end
BinarySearchTree{T}(key) where T = BinarySearchTree{T}(key, nil, nil, nil)
BinarySearchTree(key::T) where T = BinarySearchTree{T}(key)

AbstractTrees.nodevalue(t::BinarySearchTree{T}) where T = t.key
Base.IteratorEltype(::Type{<:TreeIterator{BinarySearchTree}}) = Base.HasEltype()
Base.eltype(::Type{<:TreeIterator{BinarySearchTree{T}}}) where T = BinarySearchTree{T}

function Base.push!(root::BinarySearchTree{T}, key::T) where T
    node = root
    while true
        if dataeq(node.key, key)
            node.key = key
            return root
        elseif datacomp(node.key, key) # key < node.key
            if node.left === nil
                node.left = BinarySearchTree(key, node, nil, nil)
                return root
            else
                node = node.left # loop converges
            end
        else # key > node.key
            if node.right === nil
                node.right = BinarySearchTree(key, node, nil, nil)
                return root
            else
                node = node.right # loop converges
            end
        end
    end
end

function Base.delete!(root::BinarySearchTree{T}, key::T) where T
    node = getnode(root, key, nothing)
    if node === nil
        return root
    else
        return deletenode!(root, node)
    end
end

function Base.get(t::BinarySearchTree{T}, key::T, default) where T
    node = getnode(t, key, nothing)
    if node === nothing
        return default
    else
        return node.key
    end
end

function getnode(root::BinarySearchTree{T}, key::T, default) where T
    node = root
    while node !== nil
        if dataeq(node.key, key)
            return node
        elseif datacomp(node.key, key) # key < node.key
            node = node.left
        else # key > node.key
            node = node.right
        end
    end
    return default
end

function deletenode!(root::BinarySearchTree{T}, node::BinarySearchTree{T}) where T
    if node.left === nil
        root = replacenode(root, node, node.right)
    elseif node.right === nil
        replacenode(root, node, node.left)
    else
        nearest = rightnearest(node)
        replacenode(root, nearest, nearest.right)
        node.key = nearest.key
    end
    return root
end

function replacenode(root::BinarySearchTree{T}, node::BinarySearchTree{T}, newnode::Nillable{BinarySearchTree{T}}) where T
    if node.parent === nil
        return newnode
    elseif node.parent.left === node
        node.parent.left = newnode
    else
        node.parent.right = newnode
    end
    if newnode !== nil
        newnode.parent = node.parent
    end
    return root
end

rightnearest(node::BinarySearchTree{T}) where T = leftmost(node.right)

export BinarySearchTree

end