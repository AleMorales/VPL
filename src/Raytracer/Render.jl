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
function render!(sources::Vector{Source{G, A, nw}}; n = 20, alpha = 0.2, point = false, 
                 scale = 0.2) where {G <: Directional, A <: FixedSource, nw}
    FT = eltype(sources[1].geom.rx)
    if point
        if all(isa.(getproperty.(sources, :geom), Directional))
            # Compute center of each light source and the normal vectors scaled
            origins = [source.geom.po for source in sources]
            norms = [source.geom.po => source.geom.po .+ source.angle.dir.*scale for source in sources]
            # Render the points and scaled normal vectors
            scatter!(origins)
            linesegments!(norms)
        else
            error("Point-based rendering of light sources only works for directional sources.")
        end
    else
        # Create the mesh
        N = length(sources)
        lengths = [2norm(source.geom.rx) for source in sources]
        widths = [2norm(source.geom.ry) for source in sources]
        e = [Ellipse(length = lengths[i], width = widths[i], n = n) for i in 1:N]
        for i in 1:N
            translate!(e[i], Vec(zero(FT), zero(FT), .-lengths[i]./2))
            rotate!(e[i], z = normalize(sources[i].geom.rx), 
                          y = normalize(sources[i].geom.ry), 
                          x = sources[i].angle.dir)
            translate!(e[i], sources[i].geom.po)
        end
        # Add the mesh to an existing scene
        render!(Mesh(e), color = RGBA(0.0,0.0,0.0,alpha), wireframe = true, normals = true, transparency = true)
    end
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