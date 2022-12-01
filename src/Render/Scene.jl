"""
    GLScene(mesh, colors)

Create a 3D scene for rendering from a `Mesh` object (`m`) and colors associated to the different 
primitives (`colors`). This method is useful when the user has generated separately the 3D mesh and
array with colors, as otherwise other methods of `GLScene()` will be more useful.
"""
struct GLScene{C, FT}
    mesh::Geom.Mesh{FT}
    colors::Vector{C}
end

"""
    GLScene(g, Float64)

Create a 3D scene for rendering from a `Graph` object (`g`). By default, double 
floating precision will be used (`Float64`) but it is possible to generate a 
version with a different precision by specifying the corresponding type as in 
`GLScene(g, Float32)`.
"""
function GLScene(g::Graph, ::Type{FT} = Float64; message = nothing) where FT
    # Retrieve the mesh of triangles
    mt = Geom.MTurtle(FT, message)
    Geom.feedgeom!(mt, g);
    # Retrieve the colors of each primitive
    glt = GLTurtle(message = message)
    feedcolor!(glt, g);
    # Extend the colors to match the number of triangles
    longcolors = vcat(fill.(colors(glt), Geom.nvertices(mt))...)
    # Create the scene
    GLScene(Geom.geoms(mt), longcolors)
end

"""
    GLScene(graphs, Float64; parallel = false)

Create a 3D scene for rendering from an array of `Graph` objects (`graphs`). 
The graphs may be processed serially (default) or in parallel using 
multithreading (`parallel = true`). By default, double floating precision will 
be used (`Float64`) but it is possible to generate a version with a different 
precision by specifying the corresponding type as in `GLScene(graphs, Float32)`.
"""
# Process multiple graphs to create a scene
function GLScene(graphs::Vector{<:Graph}, ::Type{FT} = Float64; parallel = false,
                 message = nothing) where FT
    scenes = Vector{GLScene}(undef, length(graphs))
    if parallel
        Threads.@threads for i in eachindex(graphs)
            @inbounds scenes[i] = GLScene(graphs[i], FT, message = message)
        end
    else
        for i in eachindex(graphs)
            @inbounds scenes[i] = GLScene(graphs[i], FT, message = message)
        end
    end
    GLScene(scenes)
end


"""
    GLScene(scene)

Merge multiple `GLScene` objects into one.
"""
function GLScene(scenes::Vector{<:GLScene})
    mesh = Geom.Mesh(getproperty.(scenes, :mesh))
    colors = vcat(getproperty.(scenes, :colors)...)
    GLScene(mesh, colors)
end


"""
    add!(scene; mesh, color)

Manually add a 3D mesh with corresponding colors (`mesh` and `color`) to an 
existing `GLScene` object (`scene`).
"""
function add!(scene; mesh, color)
    # Add colors to scene
    colors = fill(color, Geom.nvertices(mesh))
    append!(scene.colors, colors)
    # Add triangles to scene by adjusting face indices
    nv = Geom.nvertices(scene.mesh)
    append!(scene.mesh.vertices, mesh.vertices)
    append!(scene.mesh.normals, mesh.normals)
    append!(scene.mesh.faces, (nv .+ face for face in mesh.faces))
    return nothing
end
