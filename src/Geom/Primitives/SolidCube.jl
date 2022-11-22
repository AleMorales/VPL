### This file contains public API ###

const all_solid_cube_faces = (Face(1,4,3), Face(1,3,2), Face(1,5,8), 
                        Face(1,8,4), Face(4,8,7), Face(4,7,3),
                        Face(3,7,6), Face(3,6,2), Face(2,6,5), 
                        Face(2,5,1), Face(5,6,7), Face(5,7,8))
struct SolidCubeFaces end
@inbounds iterate(c::SolidCubeFaces) = (all_solid_cube_faces[1], 2)
@inbounds iterate(c::SolidCubeFaces, i) = i > 12 ? nothing : (all_solid_cube_faces[i], i + 1)
length(c::SolidCubeFaces) = 12
eltype(::Type{SolidCubeFaces}) = Face


all_solid_cube_normals(::Type{FT}) where FT = 
                         (Vec{FT}(0,0,-1), Vec{FT}(0,0,-1), Vec{FT}(0,-1,0), 
                          Vec{FT}(0,-1,0), Vec{FT}(1,0, 0), Vec{FT}(1, 0,0), 
                          Vec{FT}(0, 1,0), Vec{FT}(0,1, 0), Vec{FT}(-1,0,0), 
                          Vec{FT}(-1,0,0), Vec{FT}(0,0, 1), Vec{FT}(0, 0,1))
struct SolidCubeNormals{VT,TT}
    trans::TT
    normals::VT
end
function SolidCubeNormals(trans)
       FT = eltype(trans)
       SolidCubeNormals(trans, all_solid_cube_normals(FT))
end
function iterate(c::SCN)::Union{Nothing, Tuple{eltype(SCN), Int64}} where SCN <: SolidCubeNormals
    (@inbounds normalize(c.trans*c.normals[1]), 2)
end
function iterate(c::SCN, i)::Union{Nothing, Tuple{eltype(SCN), Int64}} where SCN <: SolidCubeNormals 
    i > 12 ? nothing : (@inbounds normalize(c.trans*c.normals[i]), i + 1)
end
length(c::SolidCubeNormals) = 12
function eltype(::Type{SolidCubeNormals{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


all_solid_cube_vertices(::Type{FT}) where FT = 
                          (Vec{FT}(-1, -1, 0), Vec{FT}(-1, 1, 0), Vec{FT}(1, 1, 0), 
                           Vec{FT}(1, -1, 0), Vec{FT}(-1, -1, 1), Vec{FT}(-1, 1, 1), 
                           Vec{FT}(1, 1, 1), Vec{FT}(1, -1, 1))
struct SolidCubeVertices{VT,TT}
    trans::TT
    verts::VT
end
function SolidCubeVertices(trans)
    FT = eltype(trans.linear)
    SolidCubeVertices(trans, all_solid_cube_vertices(FT))
end
function iterate(c::SCV)::Union{Nothing, Tuple{eltype(SCV), Int64}} where SCV <: SolidCubeVertices  
    (@inbounds c.trans(c.verts[1]), 2)
end
function iterate(c::SCV, i)::Union{Nothing, Tuple{eltype(SCV), Int64}} where SCV <: SolidCubeVertices  
    i > 8 ? nothing : (@inbounds c.trans(c.verts[i]), i + 1)
end
length(c::SolidCubeVertices) = 8
function eltype(::Type{SolidCubeVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end



"""
    SolidCube(;length = 1.0, width = 1.0, height = 1.0)

Create a solid cube with dimensions given by `length`, `width` and `height`, 
standard location and orientation. 
"""
function SolidCube(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where FT
    SolidCube(LinearMap(SDiagonal(height/FT(2), width/FT(2), length)))
end

# Create a solid_cube from affine transformation
SolidCube(trans::AbstractAffineMap) = Primitive(trans, SolidCubeVertices, SolidCubeNormals, SolidCubeFaces)

# Create a solid_cube from affine transformation and add it in-place to existing mesh
SolidCube!(m::Mesh, trans::AbstractAffineMap) = Primitive!(m, trans, SolidCubeVertices, SolidCubeNormals, SolidCubeFaces)