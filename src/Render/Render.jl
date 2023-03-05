
##################
##### Meshes #####
##################

"""
    render(m::Mesh; kwargs...)

Render a mesh. This will create a new visualization (see Documentation for 
details). Keyword arguments are passed to the `render(scene::Geom.Scene)` method 
and any unmatched keywords will be passed along to `Makie.mesh()`.
"""
function render(m::Geom.Mesh; kwargs...)
    render(Geom.GLMesh(m); kwargs...)
end

"""
    render!(m::Mesh; kwargs...)

Add a mesh to the visualization currently active. This will create a new 
visualization (see Documentation for details). Keyword arguments are passed to 
the `render!(scene::Geom.Scene)` method and any unmatched keywords will be passed 
along to `Makie.mesh!()`.
"""
function render!(m::Geom.Mesh; kwargs...)
    render!(Geom.GLMesh(m); kwargs...)
end

# Basic rendering of a triangular mesh that is already in the right format
function render(m::GeometryBasics.Mesh; color = :green, normals::Bool = false, wireframe::Bool = false, 
                axes::Bool = true, backend = "native", inline = false, resolution = (1920, 1080),
                kwargs...)
    choose_backend(backend, inline)
    fig = Makie.Figure(resolution = resolution)
    lscene = Makie.LScene(fig[1,1], show_axis = axes)
    Makie.mesh!(lscene, m, color = color, near = 0; kwargs...)
    scene_additions!(m, normals, wireframe)
    fig
end
function render!(m::GeometryBasics.Mesh; color = :green, normals::Bool = false, 
                 wireframe::Bool = false, kwargs...)
    Makie.mesh!(m, color = color, near = 0; kwargs...)
    scene_additions!(m, normals, wireframe)
end


# Choose which Makie backend to use
function choose_backend(backend, inline)
    if backend == "native"
        GLMakie.activate!()
        #GLMakie.inline!(inline)
    elseif backend == "web"
        WGLMakie.activate!()             
    else
        error("Unknown or unsupported backend, please use of the following: \"native\" or \"web\"")
    end
end

##################
##### Scenes #####
##################

"""
    render(scene::Geom.Scene; normals::Bool = false, wireframe::Bool = false, kwargs...)

Render a `Geom.Scene` object. This will create a new visualization (see 
Documentation for details). `normals = true` will draw arrows in the direction 
of the normal vector for each triangle in the mesh, `wireframe = true` will draw 
the edges of each triangle with black lines. Keyword arguments are passed to 
`Makie.mesh()`.
"""
function render(scene::Geom.Scene; normals::Bool = false, wireframe::Bool = false, kwargs...)
    render(Geom.mesh(scene); color = Geom.colors(scene), normals = normals, 
           wireframe = wireframe, kwargs...)
end

"""
    render(graph::Graph, Float64; normals::Bool = false, message = nothing,
           wireframe::Bool = false, kwargs...)

Render the 3D mesh associated to a `Graph` object. This will create a new 
visualization (see Documentation for details). `normals = true` will draw arrows 
in the direction of the normal vector for each triangle in the mesh, 
`wireframe = true` will draw the edges of each triangle with black lines. 
Keyword arguments are passed to `Makie.mesh()`. The argument `message` is any
user-defined object that will be stored in the turtles and hence available 
within the `feedgeom!` and `feedcolor!` methods. By default, double 
floating precision will be used (`Float64`) but it is possible to generate a 
version with a different precision by specifying the corresponding type as in 
`render(graph, Float32)`.
"""
function render(graph::Graph, ::Type{FT} = Float64; normals::Bool = false, 
                wireframe::Bool = false, message = nothing, kwargs...) where FT
    render(Geom.Scene(graph::Graph, FT, message = message); normals = normals, 
                   wireframe = wireframe, kwargs...)
end

"""
    render(graphs::Vector{<:Graph}, Float64; normals::Bool = false, 
           wireframe::Bool = false, messsage = nothing, kwargs...)

Render the 3D mesh associated to an array of `Graph` objects. This will create a 
new visualization (see Documentation for details). `normals = true` will draw 
arrows in the direction of the normal vector for each triangle in the mesh, 
`wireframe = true` will draw the edges of each triangle with black lines. 
Keyword arguments are passed to `Makie.mesh()`. The argument `message` is any
user-defined object that will be stored in the turtles and hence available 
within the `feedgeom!` and `feedcolor!` methods. By default, double 
floating precision will be used (`Float64`) but it is possible to generate a 
version with a different precision by specifying the corresponding type as in 
`render(graphs, Float32)`.
"""
function render(graphs::Vector{<:Graph}, ::Type{FT} = Float64; 
             normals::Bool = false, wireframe::Bool = false, message = nothing, 
             kwargs...) where FT
    render(Geom.Scene(graphs, FT, message = message); normals = normals, 
                   wireframe = wireframe, kwargs...)
end

#######################
##### Save output #####
#######################

"""
    export_scene(;scene, filename, kwargs...)

Export a screenshot of the current visualization (stored as `scene` as output of
a call to `render`) as a PNG file store in the path given by `filename` 
(including `.png` extension). Keyword arguments will be passed along to the 
corresponding `save` method from Makie (see VPL documentation for details).
"""
function export_scene(;scene, filename, kwargs...)
    FileIO.save(filename, scene; kwargs...)
end