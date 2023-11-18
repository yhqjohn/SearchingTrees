using Test
import SearchingTrees.SearchingTreeCore:nil
using SearchingTrees: BinarySearchTree

# Test creating a binary search tree
bst = BinarySearchTree(5)
@test bst.key == 5
@test bst.parent === nil
@test bst.left === nil
@test bst.right === nil

# Test adding nodes to the tree
push!(bst, 3)
push!(bst, 7)
push!(bst, 2)
push!(bst, 4)
push!(bst, 6)
push!(bst, 8)
display(bst)
@test bst.left.key == 3
@test bst.right.key == 7
@test bst.left.left.key == 2
@test bst.left.right.key == 4
@test bst.right.left.key == 6
@test bst.right.right.key == 8

# Test getting values from the tree
@test get(bst, 5, "not found") == 5
@test get(bst, 2, "not found") == 2
@test get(bst, 9, "not found") == "not found"

# Test deleting nodes from the tree
delete!(bst, 2)
delete!(bst, 7)
delete!(bst, 5)
@test bst.key == 6
@test bst.left.key == 3
@test bst.right.key == 8
display(bst)

# test iteration
# @test collect(values(bst)) == [3, 4, 6, 8] # in order DFS for BinarySearchTree is ascending order
using Random
ls = shuffle(1:100)
bst = BinarySearchTree(popfirst!(ls))
for i in ls
    push!(bst, i)
end
# display(bst)
l1 = collect(values(bst))
# println(l1)
@test l1 == collect(1:100)

