using Test
using SearchingTrees.RBTrees: RBTreeMap, is_rbtree, search_smallest_geq
import SearchingTrees.SearchingTreeCore: nil, SubtreeIterator
using AbstractTrees
using Random

# test tree map creation
d = RBTreeMap{Int, Int}()
# ls = unique([rand(Int) for i in 1:10])
ls = shuffle(collect(1:20))
for i in ls
    d[i] = i
end
display(d.root)
for p in d
    @test p.first == p.second
end

node7 = search_smallest_geq(d.root, 6.5)
# display(node7)
@test node7.key == 7
node7 = search_smallest_geq(d.root, 7)
display(node7)
@test node7.key == 7

for n in SubtreeIterator(d.root.left)
    println(n)
end

display(d)


# test larger 
d = RBTreeMap{Int, Int}()
ls = unique([rand(Int) for i in 1:1000])
len = 0
for i in ls
    @test len == length(d)
    d[i] = i
    global len += 1
    # @test is_rbtree(d.root)
end
for p in d
    @test p.first == p.second
end
ks = collect(keys(d))
@test ks == sort(ls)
vs = collect(values(d))
@test vs == sort(ls)

# test deletion
len = 1000
for i in ls
    @test len == length(d)
    delete!(d, i)
    global len -= 1
    # @test is_rbtree(d.root)
end
@test isempty(d)
display(d.root)