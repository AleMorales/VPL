
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
function render(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, kwargs...)
    scene = GLMakie.mesh(m, color = color, camera = GLMakie.cam3d!, near = 0; kwargs...)
    scene_additions!(scene, m, normals, wireframe)
end
function render!(m::GeometryBasics.Mesh, color; normals::Bool = false, wireframe::Bool = false, kwargs...)
    scene = GLMakie.mesh!(m, color = color, camera = GLMakie.cam3d!, near = 0; kwargs...)
    scene_additions!(scene, m, normals, wireframe)
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

function save_scene(filename, scene; kwargs...)
    FileIO.save(filename, scene; kwargs...)
end