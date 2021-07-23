
struct GLScene{FT, C}
    mesh::Geom.Mesh{FT}
    colors::Vector{C}
end

function GLScene(g::Graph, ::Type{FT} = Float64) where FT
    # Retrieve the mesh of triangles
    mt = Geom.MTurtle{FT}()
    Geom.feedgeom!(mt, g);
    # Retrieve the colors of each primitive
    glt = GLTurtle()
    feedcolor!(glt, g);
    # Extend the colors to match the number of triangles
    longcolors = vcat(fill.(colors(glt), Geom.nvertices(mt))...)
    # Create the scene
    GLScene(Geom.geoms(mt), longcolors)
end

# Process multiple graphs to create a scene
function GLScene(graphs::Vector{<:Graph}, ::Type{FT} = Float64; parallel = false) where FT
    scenes = Vector{GLScene}(undef, length(graphs))
    if parallel
        Threads.@threads for i in eachindex(graphs)
            @inbounds scenes[i] = GLScene(graphs[i], FT)
        end
    else
        for i in eachindex(graphs)
            @inbounds scenes[i] = GLScene(graphs[i], FT)
        end
    end
    GLScene(scenes)
end

# Merge multiple scenes into a single one
function GLScene(scenes::Vector{<:GLScene})
    mesh = Geom.Mesh(getproperty.(scenes, :mesh))
    colors = vcat(getproperty.(scenes, :colors)...)
    GLScene(mesh, colors)
end


# Add a mesh to a scene
function add!(;scene, mesh, color)
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
