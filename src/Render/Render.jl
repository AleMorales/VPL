
##################
##### Meshes #####
##################

# Basic rendering of a triangular mesh with conversion to the right format
function render(m::Geom.Mesh, color; kwargs...)
    render(Geom.GLMesh(m), color; kwargs...)
end
function render!(m::Geom.Mesh, color; kwargs...)
    render!(Geom.GLMesh(m), color; kwargs...)
end

# Basic rendering of a triangular mesh that is already in the right format
function render(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, 
                axes::Bool = true, backend = "native", inline = false, resolution = (1920, 1080),
                kwargs...)
    choose_backend(backend, inline)
    fig = Makie.mesh(m, color = color, near = 0, show_axis = axes, figure = (resolution = resolution,); kwargs...)
    scene_additions!(m, normals, wireframe)
    fig
end
function render!(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, kwargs...)
    Makie.mesh!(m, color = color, near = 0; kwargs...)
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

# Basic rendering of a scene
function render(scene::GLScene; normals::Bool = false, wireframe::Bool = false, kwargs...)
    render(scene.mesh, scene.colors; normals = normals, wireframe = wireframe, kwargs...)
end

# Basic rendering of a graph by creating a scene
function render(graph::Graph, ::Type{FT} = Float64; normals::Bool = false, wireframe::Bool = false, kwargs...) where FT
    render(GLScene(graph::Graph, FT); normals = normals, wireframe = wireframe, kwargs...)
end

# Basic rendering of a collection of graphs by creating a scene
function render(graphs::Vector{<:Graph}, ::Type{FT} = Float64; normals::Bool = false, wireframe::Bool = false, kwargs...) where FT
    render(GLScene(graphs, FT); normals = normals, wireframe = wireframe, kwargs...)
end

#######################
##### Save output #####
#######################

function export_scene(scene, filename; kwargs...)
    FileIO.save(filename, scene; kwargs...)
end