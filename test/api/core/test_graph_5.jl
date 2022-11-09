using VPL
using Test
include("types.jl")
import .GT


let

# This should prune the graph
prune = Rule(GT.B, rhs = x -> nothing)
axiom = GT.A() + GT.A() + GT.B() + GT.A()
pop = Graph(axiom = axiom, rules = prune)

@test length(pop) == 4

rewrite!(pop)

@test length(pop) == 2

end
