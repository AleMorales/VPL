using VPL
using Test
include("types.jl")
import .GT

let

# Construction of StaticGraph from user-defined type that inherits from Node
n1 = [GT.bar(i) for i = 1:6]
g1 = n1[1] + n1[2] + (n1[3], n1[4] + n1[5]) + n1[6]
n2 = [VPL.Core.GraphNode(GT.bar(i)) for i = 1:6]
g2 = n2[1] + n2[2] + (n2[3], n2[4] + n2[5]) + n2[6]

@test typeof(g1) == typeof(g2) == VPL.Core.StaticGraph
@test length(g1) == length(g2)
@test VPL.Core.rootNode(g1) |> VPL.Core.data == VPL.Core.rootNode(g2) |> VPL.Core.data
@test VPL.Core.insertionNode(g1) |> VPL.Core.data == VPL.Core.insertionNode(g2) |> VPL.Core.data

n3 = [GT.bar(i) for i = 1:4]
g3 = n1[1] + (n1[3] + n1[4], n1[2])
end
