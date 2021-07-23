
# Construction a mesh from a series of vertices and connectivity of the different faces
function construct_mesh(vertices, faces)
    norms = [@inbounds normal(vertices[face]...) for face in faces]
    Mesh(vertices, norms, faces)
end


# Compute the normal of a triangle given three vertices
function normal(v1, v2, v3)
    e1 = v2 .- v1
    e2 = v3 .- v1
    normalize(e2 × e1)
end