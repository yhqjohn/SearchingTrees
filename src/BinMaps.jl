module BinMaps

import ..SearchingTreeCore: AbstractTreeMap, TreeMapPair, treetype, nil, Nillable
using ..BinarySearchTrees

mutable struct BinMap{K, V} <: AbstractTreeMap{K, V}
    tree::Nillable{BinarySearchTree{TreeMapPair{K, V}}}
end
BinMap{K, V}() where {K, V} = BinMap{K, V}(nil)
BinMap(t::BinarySearchTree{TreeMapPair{K, V}}) where {K, V} = BinMap{K, V}(t)
treetype(::Type{BinMap{K, V}}) where {K, V} = BinarySearchTree{TreeMapPair{K, V}}

function Base.show(io::IO, b::BinMap{K, V}) where {K, V}
    print(io, "BinMap{", K, ", ", V, "}")
    if length(b) == 0
        print(io, "()\n")
    elseif length(b) <=10
        print(io, "with ", length(b), " entries:\n")
        for p in pairs(b)
            print(io, "  ", p, "\n")
        end
    else
        print(io, "with ", length(b), " entries\n")
        for p in first(pairs(b), 10)
            print(io, "  ", p, "\n")
        end
        print(io, "  ⋮  => ⋮ \n")
    end 

end

export BinMap
    
end