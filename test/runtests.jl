using VPL
using Test

################################################################################
############################# Test grahps ######################################
################################################################################

# Internal tests
@testset "Graph node" begin include("internal/core/test_graphnode.jl") end
@testset "Static graph" begin include("internal/core/test_staticgraph.jl") end
@testset "Internals draw" begin include("internal/core/test_draw_graph.jl") end

# Graph creation, queries and rewriting
@testset "API/Core/DSL" begin include("api/core/test_DSL.jl") end
@testset "API/Core/Graph_1" begin include("api/core/test_graph_1.jl") end
@testset "API/Core/Graph_2" begin include("api/core/test_graph_2.jl") end
@testset "API/Core/Graph_3" begin include("api/core/test_graph_3.jl") end
@testset "API/Core/Graph_4" begin include("api/core/test_graph_4.jl") end
@testset "API/Core/Graph_5" begin include("api/core/test_graph_5.jl") end
@testset "API/Core/Graph_6" begin include("api/core/test_graph_6.jl") end
@testset "API/Core/Graph_parallel" begin include("api/core/test_graph_parallel.jl") end
@testset "API/Core/Draw" begin include("api/core/test_draw_graph.jl") end


################################################################################
########################### Test geometry ######################################
################################################################################

# Turtle geometry
@testset "Core/Geom/Turtle" begin include("internal/geom/test_turtle.jl") end
@testset "Core/Geom/Gravitropism" begin include("internal/geom/test_gravitropism.jl") end

# Direct meshing and rendering of 3D primitives
@testset "API/Geom/ellipse" begin include("api/geom/test_ellipse.jl") end
@testset "API/Geom/bbox" begin include("api/geom/test_bbox.jl") end
@testset "API/Geom/rectangle" begin include("api/geom/test_rectangle.jl") end
@testset "API/Geom/rectangle" begin include("api/geom/test_trapezoid.jl") end
@testset "API/Geom/solid_cube" begin include("api/geom/test_solid_cube.jl") end
@testset "API/Geom/hollow_cube" begin include("api/geom/test_hollow_cube.jl") end
@testset "API/Geom/hollow_cylinder" begin include("api/geom/test_hollow_cylinder.jl") end
@testset "API/Geom/solid_cylinder" begin include("api/geom/test_solid_cylinder.jl") end
@testset "API/Geom/hollow_frustum" begin include("api/geom/test_hollow_frustum.jl") end
@testset "API/Geom/solid_frustum" begin include("api/geom/test_solid_frustum.jl") end
@testset "API/Geom/hollow_cone" begin include("api/geom/test_hollow_cone.jl") end
@testset "API/Geom/solid_cone" begin include("api/geom/test_solid_cone.jl") end
@testset "API/Geom/transformations" begin include("api/geom/test_transformations.jl") end
@testset "API/Geom/meshio" begin include("api/geom/test_meshio.jl") end


################################################################################
######################### Test 3D rendering ####################################
################################################################################

@testset "API/render/snowflake" begin include("api/render/test_snowflakes.jl") end
@testset "API/render/message" begin include("api/render/test_message.jl") end
@testset "API/render/binary_tree" begin include("api/render/test_binarytree.jl") end

################################################################################
########################## Test ray tracer #####################################
################################################################################

@testset "internal/raytracer/basics" begin include("internal/raytracer/test_raytracer.jl") end