using SearchingTrees, Test, SafeTestsets

# @safetestset "Test binary searching trees" begin
#     include("test_binary_searching_trees.jl")
# end

# @safetestset "Test binary maps" begin
#     include("test_binmaps.jl")
# end

@safetestset "Test red-black trees" begin
    include("test_rb_trees.jl")
end