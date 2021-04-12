using VPL
using Test
include("types.jl")
import .GT

let

    # Create axiom
    axiom = GT.A()
    
    # Create replacement rules
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())
    
    # Check the created rules
    @test rule1 isa Rule && rule2 isa Rule
    @test !VPL.Core.captures(rule1) && !VPL.Core.captures(rule2)
    
    # Initialize two graphs
    algae_serial = [Graph(axiom, rules = (rule1, rule2)) for i in 1:20]
    algae_parallel = [Graph(axiom, rules = (rule1, rule2)) for i in 1:20]
   
    # Run in series
    for i in 1:10
        for j in 1:length(algae_serial)
            rewrite!(algae_serial[j])
        end
    end

    # Run in parallel
    for i in 1:10
        Threads.@threads for j in 1:length(algae_parallel)
            rewrite!(algae_parallel[j])
        end
    end
    
    # Test that we get the same results for all graphs
    @test length(algae_serial[1]) == length(algae_parallel[2]) 
    Bnodes_serial = sum(n isa GT.B for n in data.(values(VPL.Core.nodes(algae_serial[4]))))
    Anodes_serial = sum(n isa GT.A for n in data.(values(VPL.Core.nodes(algae_serial[4]))))
    Bnodes_parallel = sum(n isa GT.B for n in data.(values(VPL.Core.nodes(algae_parallel[3]))))
    Anodes_parallel = sum(n isa GT.A for n in data.(values(VPL.Core.nodes(algae_parallel[3]))))
    @test Anodes_serial == Anodes_parallel
    @test Bnodes_serial == Bnodes_parallel

    # These results should be different (tests lack of sharing of states)
    @test isempty(intersect(keys(VPL.Core.nodes(algae_parallel[3])), keys(VPL.Core.nodes(algae_parallel[4]))))

    end