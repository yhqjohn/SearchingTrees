module SearchingTrees

using Reexport

include("core.jl")
# include("binary_searching_tree.jl")
# include("BinMaps.jl")
include("rbtrees.jl")

@reexport using .SearchingTreeCore

# export AbstractSearchingTree, TreeMapPair, datacomp, dataeq, topair, AbstactTreeMap
# @reexport using .BinarySearchTrees
# @reexport using .BinMaps
@reexport using .RBTrees

end # module SearchingTrees
