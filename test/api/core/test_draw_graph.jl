using VPL
using Test

include("types.jl")
import .GT
import Makie

let

    VPL.node_label(n::GT.A, id) = "A"
    VPL.node_label(n::GT.B, id) = "B"
    axiom = GT.A()
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())
    organism = Graph(axiom, rules = (rule1, rule2))
    rewrite!(organism)

    # Test the backends run 
    fn = draw(organism);
    @test fn isa Makie.Figure
    fw = draw(organism, backend = "web");
    @test fw isa Makie.Figure
    fv = draw(organism, backend = "vector");
    @test fv isa Makie.Figure

    # Export as png
    export_graph(fn, "api/core/test/f.png")
    fnref = read("api/core/reference/f.png")
    fntest = read("api/core/test/f.png")
    fnref == fntest

    # Export as pdf
    export_graph(fv, "api/core/test/f.pdf")
    fpref = read("api/core/reference/f.pdf")
    fptest = read("api/core/test/f.pdf")
    fpref == fptest    

    # Export as svg
    export_graph(fv, "api/core/test/f.svg")
    fsref = read("api/core/reference/f.svg")
    fstest = read("api/core/test/f.svg")
    fsref == fstest    
end