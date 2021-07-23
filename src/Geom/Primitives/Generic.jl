
# Create a primitive from affine transformation
function Primitive(trans::AbstractAffineMap, vertices, normals, faces)
    FT = eltype(trans.linear)
    verts = collect(Vec{FT}, vertices(trans))
    norm_trans = transpose(inv(trans.linear))
    norms = collect(Vec{FT}, normals(norm_trans))
    Mesh(verts, norms, collect(Face, faces()))
end

# Create a primitive from affine transformation and add it in-place to existing mesh
function Primitive!(m::Mesh, trans::AbstractAffineMap, vertices, normals, faces)
    nv = length(m.vertices)
    norm_trans = transpose(inv(trans.linear))
    append!(m.vertices, vertices(trans))
    append!(m.normals, normals(norm_trans))
    append!(m.faces, (nv .+ face for face in faces()))
    nothing
end


# Create normals for a mesh
function create_normals(vertices::Vector{Vec{FT}}, faces) where FT
    nt = length(faces)
    normals = Vector{Vec{FT}}(undef, nt)
    @inbounds for i in 1:nt
        v1, v2, v3 = vertices[faces[i]]
        e1 = v2 .- v1
        e2 = v3 .- v1
        normals[i] = normalize(e2 × e1) 
    end
    normals
end





