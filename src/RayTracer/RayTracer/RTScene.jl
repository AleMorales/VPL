
"""
    RTScene(triangles, material_ids, materials)

Create a ray tracing scene for rendering from a vector of triangles (`triangles`), a vector of ids that 
match each triangle to a material (`ids`) and the vector of material objects (`materials`). 
This method will generally not be used by the author unless 
the components of an `RTScene` were generated manually.
"""
struct RTScene{T, M}
    triangles::Vector{T}
    ids::Vector{Int}
    materials::Vector{M}
end


"""
    RTScene(mesh, ids, materials)

Create a ray tracing scene from a `Mesh` object (`mesh`), vector of `ids` that connects each
triangle on the mesh to a material object and the vector with those `materials`. See VPL
documentation for further details.
"""
function RTScene(mesh::Mesh, ids, materials)
    RTScene(Triangle(mesh), ids, materials)
end

"""
    RTScene(graph, Float64)

Create a ray tracing scene from a `Graph` object (`graph`) By default, the ray tracer will operate on a double
floating point precision standard (i.e., `Float64`), but it is possible to switch to single precision 
by using `Float32` as the third argument. This will speed up the computations at the expense of 
numerical accuracy. See VPL documentation for further details.
"""
function RTScene(graph::Graph, ::Type{FT} = Float64) where FT
    # Retrieve a vector of meshes
    mt = MTurtle(FT)
    feedgeom!(mt, graph)
    mesh = geoms(mt)

    # Assign to each triangle an id related to the geom it belongs to
    ids = vcat(fill.(1:length(mt.ntriangles), mt.ntriangles)...)
    @assert ntriangles(mesh) == length(ids)

    # Retrieve the materials of each primitive in the graph
    # This assumes the user defined a feedmaterial! for every feedgeom!
    # One material object per geometry fed (not per triangle!)
    rtt = RTTurtle()
    feedmaterial!(rtt, graph);

    # Create the RTScene
    RTScene(mesh, ids, materials(rtt))
end

"""
    RTScene(graphs; parallel = false)

Create a 3D scene for ray tracing from a vector of `Graph` objects (`graphs`). The graphs may be processed serially (default)
or in parallel using multithreading (`parallel = true`).
"""
# Process multiple graphs to create a scene
function RTScene(graphs::Vector{<:Graph}; parallel = false)
    scenes = Vector{RTScene}(undef, length(graphs))
    if parallel
        Threads.@threads for i in eachindex(graphs)
            @inbounds scenes[i] = RTScene(graphs[i])
        end
    else
        for i in eachindex(graphs)
            @inbounds scenes[i] = RTScene(graphs[i])
        end
    end
    RTScene(scenes)
end


"""
    RTScene(scene)

Merge multiple `RTScene` objects into one.
"""
function RTScene(scenes::Vector{<:RTScene})
    # Extract components from the original scenes
    triangles = vcat(getproperty.(scenes, :triangles)...)
    materials = vcat(getproperty.(scenes, :materials)...)
    @inbounds ids = scenes[1].ids
    if length(scenes) > 1
        for i in 2:length(scenes)
            @inbounds append!(ids, ids[end] .+ scenes[i].ids)
        end
    end
    RTScene(triangles, ids, materials)
end


"""
    add!(scene, mesh, material)

Add a 3D mesh with a corresponding material (`mesh` and `material`) to an existing `RTScene` object (`scene`).
"""
function add!(scene::RTScene, mesh, material)

    # Convert mesh to array of triangles with barycentric coordinates
    triangles = Triangle(mesh)

    # Vector to material ids updated by current scene
    ids = length(scene.materials) .+ ones(Int, ntriangles(mesh))

    # Add elements to the scene
    append!(scene.triangles, triangles)
    append!(scene.ids, ids)
    push!(scene.materials, material)

    return nothing
end


# Create an AABB around the mesh inside a scene
function AABB(scene::RTScene)
    AABB(scene.triangles)
end