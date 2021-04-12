using VPL
using Test

################################################################################
############################# Test grahps ######################################
################################################################################

# Internal tests
@testset "Graph node" begin include("internal/core/test_graphnode.jl") end
@testset "Static graph" begin include("internal/core/test_staticgraph.jl") end

# Test API of VPL
@testset "API/Core/DSL" begin include("api/core/test_DSL.jl") end
@testset "API/Core/Graph_1" begin include("api/core/test_graph_1.jl") end
@testset "API/Core/Graph_2" begin include("api/core/test_graph_2.jl") end
@testset "API/Core/Graph_3" begin include("api/core/test_graph_3.jl") end
@testset "API/Core/Graph_4" begin include("api/core/test_graph_4.jl") end
@testset "API/Core/Graph_5" begin include("api/core/test_graph_5.jl") end
@testset "API/Core/Graph_6" begin include("api/core/test_graph_6.jl") end
@testset "API/Core/Graph_6" begin include("api/core/test_graph_parallel.jl") end
@testset "API/Core/Graph_1" begin include("api/core/test_draw_graph.jl") end
