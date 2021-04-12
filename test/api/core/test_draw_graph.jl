using VPL
using Test
import Blink

include("types.jl")
import .GT

let
    ## Static graph
    n = [GT.bar(i) for i = 1:6]
    g = n[1] + n[2] + (n[3], n[4] + n[5]) + n[6]
    
    # DOT version of graph 
    dotg = VPL.Core.dotlang(g)
    @test typeof(dotg) == String
    @test split(dotg, "\n") |> length == 13

    # Render using vis.js library
    w = draw(g, name = "g")
    @test w isa Blink.AtomShell.Window
    @test Blink.title(w) == "g"
    Blink.close(w)

    # Dynamic graph
    axiom = GT.A()
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())
    algae = Graph(axiom, rules = (rule1, rule2))
    rewrite!(algae)
    w = draw(algae, name = "g")
    @test w isa Blink.AtomShell.Window
    @test Blink.title(w) == "g"
    Blink.close(w)

end