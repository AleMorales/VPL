
##################
##### Meshes #####
##################

"""
    render(m::Mesh, color; kwargs...)

Render a mesh with a given color. This will create a new visualization (see Documentation
for details). Keyword arguments are passed to the `render(scene::GLScene)` method and any  
unmatched keywords will be passed along to `Makie.mesh()`.
"""
function render(m::Geom.Mesh, color; kwargs...)
    render(Geom.GLMesh(m), color; kwargs...)
end

"""
    render!(m::Mesh, color; kwargs...)

Add a mesh with a given color the visualization currently active. This will create a new 
visualization (see Documentation for details). Keyword arguments are passed to the 
`render!(scene::GLScene)` method and any unmatched keywords will be passed along to `Makie.mesh!()`.
"""
function render!(m::Geom.Mesh, color; kwargs...)
    render!(Geom.GLMesh(m), color; kwargs...)
end

# Basic rendering of a triangular mesh that is already in the right format
function render(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, 
                axes::Bool = true, backend = "native", inline = false, resolution = (1920, 1080),
                kwargs...)
    choose_backend(backend, inline)
    fig = Makie.mesh(m, color = color, near = 0, figure = (resolution = resolution, show_axis = axes); kwargs...)
    scene_additions!(m, normals, wireframe)
    fig
end
function render!(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, kwargs...)
    Makie.mesh!(m, color = color, near = 0, figure = (resolution = resolution, show_axis = axes); kwargs...)
    scene_additions!(m, normals, wireframe)
end


# Choose which Makie backend to use
function choose_backend(backend, inline)
    if backend == "native"
        GLMakie.activate!()
        GLMakie.inline!(inline)
    elseif backend == "web"
        WGLMakie.activate!()             
    else
        error("Unknown or unsupported backend, please use of the following: \"default\", \"native\", \"web\"")
    end
end

##################
##### Scenes #####
##################

"""
    render(scene::GLScene; normals::Bool = false, wireframe::Bool = false, kwargs...)

Render a `GLScene` object. This will create a new visualization (see Documentation
for details). `normals = true` will draw arrows in the direction of the normal vector for
each triangle in the mesh, `wireframe = true` will draw the edges of each triangle with 
black lines. Keyword arguments are passed to `Makie.mesh()`.
"""
function render(scene::GLScene; normals::Bool = false, wireframe::Bool = false, kwargs...)
    render(scene.mesh, scene.colors; normals = normals, wireframe = wireframe, kwargs...)
end

"""
    render(graph::Graph; normals::Bool = false, wireframe::Bool = false, kwargs...)

Render the 3D mesh associated to a `Graph` object. This will create a new visualization (see Documentation
for details). `normals = true` will draw arrows in the direction of the normal vector for
each triangle in the mesh, `wireframe = true` will draw the edges of each triangle with 
black lines. Keyword arguments are passed to `Makie.mesh()`.
"""
function render(graph::Graph; normals::Bool = false, wireframe::Bool = false, kwargs...)
    render(GLScene(graph::Graph); normals = normals, wireframe = wireframe, kwargs...)
end

"""
    render(graphs::Vector{<:Graph}; normals::Bool = false, wireframe::Bool = false, kwargs...)

Render the 3D mesh associated to an array of `Graph` objects. This will create a new visualization (see Documentation
for details). `normals = true` will draw arrows in the direction of the normal vector for
each triangle in the mesh, `wireframe = true` will draw the edges of each triangle with 
black lines. Keyword arguments are passed to `Makie.mesh()`.
"""
function render(graphs::Vector{<:Graph}; normals::Bool = false, wireframe::Bool = false, kwargs...)
    render(GLScene(graphs); normals = normals, wireframe = wireframe, kwargs...)
end

#######################
##### Save output #####
#######################

"""
    export_scene(scene, filename; kwargs...)

Export a screenshot of the current visualization (stored as `scene` as output of a call to `render`) as a PNG 
file store in the path given by `filename` (including `.png` extension). Keyword arguments will be passed along
to the corresponding `save` method from Makie (see VPL documentation for details).
"""
function export_scene(scene, filename; kwargs...)
    FileIO.save(filename, scene; kwargs...)
end