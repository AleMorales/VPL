
# Common triangle mesh
struct Mesh{VT}
    vertices::Vector{VT}
    normals::Vector{VT}
    faces::Vector{Face}
end

# Construct empty meshes
function Mesh(::Type{FT} = Float64)  where FT <: AbstractFloat 
    Mesh(Vec{FT}[], Vec{FT}[], Face[])
end
function Mesh(nt, nv = nt*3, ::Type{FT} = Float64) where FT <: AbstractFloat
    verts = Vec{FT}[]; sizehint!(verts, nv)
    norms = Vec{FT}[]; sizehint!(verts, nt)
    faces = Face[]; sizehint!(verts, nv)
    Mesh(verts, norms, faces)
end

# Retrieve dimensions of a mesh
ntriangles(mesh::Mesh) = length(mesh.faces)
nvertices(mesh::Mesh) = length(mesh.vertices)


# Merge multiple meshes into a single one
function Mesh(meshes::Vector{Mesh{VT}}) where VT
    # Positions where each old mesh starts in the new mesh
    nverts = cumsum(nvertices(m) for m in meshes)
    ntriangs = cumsum(ntriangles(m) for m in meshes)
    # Allocate elements of the new mesh
    vertices = Vector{VT}(undef, last(nverts))
    faces = Vector{Face}(undef, last(ntriangs))
    normals = Vector{VT}(undef, last(ntriangs))
    # Fill up the elements of the new mesh
    @inbounds for i in eachindex(meshes)
      mesh = meshes[i]
      # First mesh is simple
      if i == 1
        for v in 1:nverts[1]
          vertices[v] = mesh.vertices[v]
        end
        for f in 1:ntriangs[1]
          faces[f] = mesh.faces[f]
          normals[f] = mesh.normals[f]
        end
      # Other meshes start where previous mesh ended
      else
        v0 = nverts[i - 1]
        f0 = ntriangs[i - 1]
        for v in v0 + 1:nverts[i]
          vertices[v] = mesh.vertices[v - v0]
        end
        for f in f0 + 1:ntriangs[i]
          faces[f] = mesh.faces[f - f0] .+ v0
          normals[f] = mesh.normals[f - f0]
        end
      end
    end
    Mesh(vertices, normals, faces)
end

# Area of a mesh
function area_triangle(v1::Vec{FT}, v2::Vec{FT}, v3::Vec{FT}) where FT <: AbstractFloat
    e1 = v2 .- v1
    e2 = v3 .- v1
    FT(0.5)*norm(e1 × e2)
  end

area(m::Mesh) = sum(@inbounds area_triangle(m.vertices[face]...) for face in m.faces)
areas(m::Mesh) = [@inbounds area_triangle(m.vertices[face]...) for face in m.faces]

# Facilitate testing
==(m1::Mesh, m2::Mesh) = m1.vertices == m2.vertices && m1.normals == m2.normals &&
                         m1.faces == m2.faces

# ≈(m1::Mesh, m2::Mesh) = m1.vertices ≈ m2.vertices && m1.normals ≈ m2.normals &&
#                          m1.faces ≈ m2.faces     
                         
function isapprox(m1::Mesh, m2::Mesh; atol::Real=0.0, rtol::Real=atol>0.0 ? 0.0 : sqrt(eps(1.0)))
    isapprox(m1.vertices, m2.vertices, atol = atol, rtol = rtol) &&
    isapprox(m1.normals, m2.normals, atol = atol, rtol = rtol) &&
    isapprox(m1.faces, m2.faces, atol = atol, rtol = rtol)
end