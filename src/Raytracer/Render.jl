### This file contains public API ###
# render!

"""
    render!(source::Source{G, A, nw}; n = 20, alpha = 0.2)

Add a mesh representing the light source to a 3D scene. For each type of light
source a triangular mesh will be created, where `n` is the number of triangles
(see documentation of geometric primitives for details) and `alpha` is the
transparency to be used for each triangle.
"""
function render!(source::Source{G, A, nw}; n = 20, alpha = 0.2) where {G <: Directional, A <: FixedSource, nw}
    FT = eltype(source.geom.rx)
    # Create the mesh
    length = 2norm(source.geom.rx)
    width = 2norm(source.geom.ry)
    e = Ellipse(length = length, width = width, n = n)
    translate!(e, Vec(zero(FT), zero(FT), .-length./2))
    rotate!(e, z = normalize(source.geom.rx), y = normalize(source.geom.ry), 
               x = source.angle.dir)
    translate!(e, source.geom.po)
    # Add the mesh to an existing scene
    render!(e, color = RGBA(0.0,0.0,0.0,alpha), wireframe = true, normals = true, transparency = true)
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