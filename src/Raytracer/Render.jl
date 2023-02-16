### This file contains public API ###
# render!

"""
    render!(source::Source{G, A, nw}; n = 20, alpha = 0.2, point = false,
            scale = 0.2)

Add a mesh representing the light source to a 3D scene (if `point = false`) or
a series of points representing the center of the light sources (if 
`point = true`). When `point = false`, for each type of light source a 
triangular mesh will be created, where `n` is the number of triangles (see 
documentation of geometric primitives for details) and `alpha` is the 
transparency to be used for each triangle. When `point = true`, only the center
of the light source is rendered along with the normal vector at that point 
(representative of the direction at which rays are generated). In the current
version, `point = true` is only possible for directional light sources.
"""
function render!(sources::Vector{Source{G, A, nw}}; n = 20, alpha = 0.2, 
                 scale = 0.2) where {G <: Directional, A <: FixedSource, nw}
    FT = eltype(sources[1].geom.xmin)
    # Compute point and arrow for each light source
    temp = compute_dir_p.(sources)
    origins, norms = Tuple(getindex.(temp,i) for i in 1:2)
    # Render the points and scaled normal vectors
    scatter!(origins)
    linesegments!(norms)

end

# Compute a point to represent a directional light source
function compute_dir_p(s)
    # Point in the center of the AABB
    p = Vec((s.geom.xmin + s.geom.xmax)/2, 
            (s.geom.ymin + s.geom.ymax)/2,
            s.geom.zmax) 
    # Normal vector
    n = s.angle.dir
    # Scaling
    Δx = s.geom.xmax - s.geom.xmin
    Δy = s.geom.ymax - s.geom.ymin
    s = max(Δx, Δy)
    # Possible origin of source
    point = p .- n.*s
    # Arrow
    arrow = point => point .+ n.*s./5
    # Return the point and arrow
    return point, arrow
end


function render!(sources::Source{G, A, nw}; kwargs...) where {G <: Directional, A <: FixedSource, nw}
    render!([sources]; kwargs...)
end

"""
    render!(grid::GridCloner; alpha = 0.2)

Add a mesh representing the bounding boxes of the grid cloner to a 3D scene, 
where `alpha` represents the transparency of each box.
"""
function render!(grid::GridCloner; alpha = 0.2)
    leaf_nodes = filter(x -> x.leaf, grid.nodes.data)
    AABBs = getfield.(leaf_nodes, :box)
    mesh = Mesh([BBox(box.min, box.max) for box in AABBs])
    render!(mesh, color = RGBA(0.0,0.0,0.0, alpha), transparency = true)
end