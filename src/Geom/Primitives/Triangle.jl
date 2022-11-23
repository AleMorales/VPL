### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################
struct TriangleFaces end
iterate(r::TriangleFaces) = (Face(1, 2, 3), 2)
iterate(r::TriangleFaces, i) = nothing
length(r::TriangleFaces) = 1
eltype(::Type{TriangleFaces}) = Face

struct TriangleNormals{FT}
    norm::Vec{FT}
end
TriangleNormals(trans::AbstractMatrix{FT}) where FT = TriangleNormals(normalize(trans*X(FT)))
function iterate(r::TriangleNormals{FT})::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT}
    (r.norm, 2)
end
function iterate(r::TriangleNormals{FT}, i)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT} 
    nothing
end
length(r::TriangleNormals) = 1
eltype(::Type{TriangleNormals{FT}}) where FT = Vec{FT}


all_triangle_vertices(::Type{FT}) where FT = (Vec{FT}(0, -1, 0), Vec{FT}(0, 0, 1), Vec{FT}(0, 1, 0))
struct TriangleVertices{VT,TT}
    trans::TT
    verts::VT
end
function TriangleVertices(trans)
    FT = eltype(trans)
    TriangleVertices(trans, all_triangle_vertices(FT))
end
function iterate(r::RV)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: TriangleVertices
    (@inbounds r.trans(r.verts[1]), 2)
end
function iterate(r::RV, i)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: TriangleVertices
    i > 3 ? nothing : (@inbounds r.trans(r.verts[i]), i + 1)
end
length(r::TriangleVertices) = 3
function eltype(::Type{TriangleVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    Triangle(;length = 1.0, width = 1.0

Create a triangle with dimensions given by `length` and `width`, standard 
location and orientation. 
"""
function Triangle(;length::FT = 1.0, width::FT = 1.0) where FT
    trans = LinearMap(SDiagonal(one(FT), width/FT(2), length))
    Triangle(trans)
end

# Create a triangle from affine transformation
Triangle(trans::AbstractAffineMap) = 
            Primitive(trans, TriangleVertices, TriangleNormals, TriangleFaces)

# Create a triangle from affine transformation and add it in-place to existing mesh
Triangle!(m::Mesh, trans::AbstractAffineMap) = 
          Primitive!(m, trans, TriangleVertices, TriangleNormals, TriangleFaces)
