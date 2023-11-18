using Test
using SearchingTrees: BinMap

# Create a new BinMap
b = BinMap{Int, String}()

# Test setindex! and getindex
b[1] = "one"
b[2] = "two"
b[3] = "three"
@test b[1] == "one"
@test b[2] == "two"
@test b[3] == "three"

# Test length
@test length(b) == 3

# Test haskey
@test haskey(b, 1) == true
@test haskey(b, 4) == false

# Test delete!
delete!(b, 1)
@test length(b) == 2
@test haskey(b, 1) == false

# Test iterate
b = BinMap{Int, String}()
for i in 1:100
    b[i] = string(i)
end
println(b)
ps1 = collect(pairs(b))
ps2 = [i => string(i) for i in 1:100]
@test ps1 == ps2
s1 = collect(values(b))
@test s1 == [string(i) for i in 1:100]
_is = collect(keys(b))
@test _is == collect(1:100)

# test other keys
b = BinMap{String, Int}()
b["one"] = 1
b["two"] = 2
b["three"] = 3
b["four"] = 4
b["five"] = 5
b["six"] = 6
b["seven"] = 7
b["eight"] = 8
b["nine"] = 9
b["ten"] = 10

@test b["one"] == 1
@test b["two"] == 2
@test b["three"] == 3
@test b["four"] == 4
@test b["five"] == 5
@test b["six"] == 6
@test b["seven"] == 7
@test b["eight"] == 8
@test b["nine"] == 9
@test b["ten"] == 10

# test delete!
delete!(b, "one")
@test length(b) == 9

# test iterate
vs = collect(values(b))
@test vs == [8, 5, 4, 9, 7, 6, 10, 3, 2] # lex order
