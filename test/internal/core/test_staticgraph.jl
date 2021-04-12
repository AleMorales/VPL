import VPL
const C = VPL.Core
using Test

let
### Constructors and DSL

# Empty StaticGraph constructor
g1 = C.StaticGraph()
@test C.root(g1) == C.insertion(g1) == -1
@test length(g1) == 0
@test length(g1.nodetypes) == 0

# Single node StaticGraph constructor
n1 = C.GraphNode(1)
g2 = C.StaticGraph(n1)
@test C.root(g2) == C.insertion(g2) == collect(keys(g2.nodes))[1]
@test length(g2) == 1
@test length(g2.nodetypes) == 1
@test C.hasNodetype(g2, Int)

# DSL with GraphNodes
n1 = C.GraphNode(1)
n2 = C.GraphNode(2)
n3 = C.GraphNode(3)
g3 = n1 + n2 + n3
@test C.root(g3) < C.insertion(g3)
@test length(g3) == 3
@test length(g3.nodetypes) == 1
@test sum(i.data for i in C.nodes(g3) |> values |> collect) == 6
@test C.nodetypes(g3)[Int] |> values |> collect |> sort ==
      C.nodes(g3) |> keys |> collect |> sort
@test isRoot(g3[C.root(g3)])
@test !isLeaf(g3[C.root(g3)])
@test isLeaf(g3[C.insertion(g3)])
@test !isRoot(g3[C.insertion(g3)])
@test sum(isLeaf(node) for node in C.nodes(g3) |> values) == 1
@test sum(isRoot(node) for node in C.nodes(g3) |> values) == 1

# DSL with GraphNodes with branches
n = [C.GraphNode(i) for i = 1:6]
g4 = n[1] + n[2] + (n[3], n[4] + n[5]) + n[6]
@test length(g4) == 6
@test sum(isLeaf(node) for node in C.nodes(g4) |> values) == 3
@test sum(isRoot(node) for node in C.nodes(g4) |> values) == 1

end
