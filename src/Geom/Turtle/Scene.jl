### This file contains public API ###
# Scene
# materials
# colors


# Structure that contains the information gathered by a turtle
struct Scene{FT}
    mesh::Mesh{FT}
    colors::Vector{Colorant}
    material_ids::Vector{Int}
    materials::Vector{Material}
end

# Constructor to avoid concrete types for colors and materials
function Scene(;mesh = Mesh(Float64), colors = Colorant[], material_ids = Int[], 
                materials = Material[])
    scene = Scene(mesh, Colorant[], Int[], Material[])
    if colors isa Colorant 
        push!(scene.colors, colors) 
    else
        append!(scene.colors, colors)
    end
    if material_ids isa Number 
        push!(scene.material_ids, material_ids) 
    else
        append!(scene.material_ids, material_ids)
    end
    if materials isa Material 
        push!(scene.materials, materials) 
    else
        append!(scene.materials, materials)
    end
    return scene
end

# Accessor functions
"""
    colors(scene::Scene)

Extract the vector of `Colorant` objects stored inside a scene (used for rendering)
"""
colors(scene::Scene)       = scene.colors
"""
    materials(scene::Scene)

Extract the vector of `Material` objects stored inside a scene (used for ray tracing)
"""
materials(scene::Scene)    = scene.materials
material_ids(scene::Scene) = scene.material_ids
"""
    mesh(scene::Scene)

Extract the triangular mesh stored inside a scene (used for ray tracing & rendering)
"""
mesh(scene::Scene)         = scene.mesh
nvertices(scene::Scene)    = nvertices(mesh(scene))
vertices(scene::Scene)     = vertices(mesh(scene))
normals(scene::Scene)      = normals(mesh(scene))
faces(scene::Scene)        = faces(mesh(scene))

"""
    Scene(graph, Float64)

Create a 3D scene from a `Graph` object (`g`). By default, double 
floating precision will be used (`Float64`) but it is possible to generate a 
version with a different precision by specifying the corresponding type as in 
`Scene(g, Float32)`. The Scene object contains a mesh of triangles as well as
colors and materials associated to each primitive.
"""
function Scene(graph::Graph, ::Type{FT} = Float64; message = nothing) where FT
    # Retrieve the mesh of triangles
    turtle = Turtle(FT, message)
    feed!(turtle, graph);
    # Create the scene
    Scene(geoms(turtle), colors(turtle), material_ids(turtle), materials(turtle))
end

"""
    Scene(graphs, Float64; parallel = false, message = nothing)

Create a 3D scene for rendering from an array of `Graph` objects (`graphs`). 
The graphs may be processed serially (default) or in parallel using 
multithreading (`parallel = true`). By default, double floating precision will 
be used (`Float64`) but it is possible to generate a version with a different 
precision by specifying the corresponding type as in `Scene(graphs, Float32)`.
"""
# Process multiple graphs to create a scene
function Scene(graphs::Vector{<:Graph}, ::Type{FT} = Float64; parallel = false,
                 message = nothing) where FT
    scenes = Vector{Scene}(undef, length(graphs))
    if parallel
        Threads.@threads for i in eachindex(graphs)
            @inbounds scenes[i] = Scene(graphs[i], FT, message = message)
        end
    else
        for i in eachindex(graphs)
            @inbounds scenes[i] = Scene(graphs[i], FT, message = message)
        end
    end
    Scene(scenes)
end


"""
    Scene(scenes)

Merge multiple `Scene` objects into one.
"""
function Scene(scenes::Vector{<:Scene})
    allmesh = Mesh(mesh.(scenes))
    allcolors = vcat(colors.(scenes)...)
    allmaterials = vcat(materials.(scenes)...)
    #allmaterial_ids = vcat(material_ids.(scenes)...)
    @inbounds allmaterial_ids = scenes[1].material_ids
    if length(scenes) > 1
        for i in 2:length(scenes)
            @inbounds append!(allmaterial_ids, material_ids[end] .+ scenes[i].material_ids)
        end
    end
    Scene(allmesh, allcolors, allmaterial_ids, allmaterials)
end


"""
    add!(scene; mesh, color = nothing, material = nothing)

Manually add a 3D mesh to an existing `Scene` object (`scene`) with optional
colors and materials
"""
function add!(scene; mesh, color = nothing, material = nothing)
    # Add triangles to scene by adjusting face indices
    nv = nvertices(scene)
    append!(vertices(scene), vertices(mesh))
    append!(normals(scene), normals(mesh))
    append!(faces(scene), (nv .+ face for face in faces(mesh)))
    # Add colors if available
    update_color!(scene, color, nvertices(mesh))
    # Add material if available
    update_material!(scene, material, ntriangles(mesh)) 
    return nothing
end
