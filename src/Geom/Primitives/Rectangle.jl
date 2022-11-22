### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################
struct RectangleFaces end
iterate(r::RectangleFaces) = (Face(1, 2, 3), 2)
iterate(r::RectangleFaces, i) = i > 2 ? nothing : (Face(1, 3, 4), 3)
length(r::RectangleFaces) = 2
eltype(::Type{RectangleFaces}) = Face

struct RectangleNormals{FT}
    norm::Vec{FT}
end
RectangleNormals(trans::AbstractMatrix{FT}) where FT = RectangleNormals(normalize(trans*X(FT)))
function iterate(r::RectangleNormals{FT})::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT}
    (r.norm, 2)
end
function iterate(r::RectangleNormals{FT}, i)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT} 
    i > 2 ? nothing : (r.norm, 3)
end
length(r::RectangleNormals) = 2
eltype(::Type{RectangleNormals{FT}}) where FT = Vec{FT}


all_rectangle_vertices(::Type{FT}) where FT = (Vec{FT}(0, -1, 0), Vec{FT}(0, -1, 1), Vec{FT}(0, 1, 1), Vec{FT}(0, 1, 0))
struct RectangleVertices{VT,TT}
    trans::TT
    verts::VT
end
function RectangleVertices(trans)
    FT = eltype(trans.linear)
    RectangleVertices(trans, all_rectangle_vertices(FT))
end
function iterate(r::RV)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: RectangleVertices
    (@inbounds r.trans(r.verts[1]), 2)
end
function iterate(r::RV, i)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: RectangleVertices
    i > 4 ? nothing : (@inbounds r.trans(r.verts[i]), i + 1)
end
length(r::RectangleVertices) = 4
function eltype(::Type{RectangleVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    Rectangle(;length = 1.0, width = 1.0)

Create a rectangle with dimensions given by `length` and width, standard location 
and orientation. 
"""
function Rectangle(;length::FT = 1.0, width::FT = 1.0) where FT
    trans = LinearMap(SDiagonal(one(FT), width/FT(2), length))
    Rectangle(trans)
end

# Create a rectangle from affine transformation
Rectangle(trans::AbstractAffineMap) = Primitive(trans, RectangleVertices, RectangleNormals, RectangleFaces)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(m::Mesh, trans::AbstractAffineMap) = Primitive!(m, trans, RectangleVertices, RectangleNormals, RectangleFaces)


#########################################################
################# Manual constructors ###################
#########################################################

"""
    Rectangle(;v = O(), length = 1.0, width = 1.0)

Create a rectangle from a vertex (`v`) and vectors `length` and `width` 
representing the side of the primitive. 
"""
function Rectangle(v::Vec{FT}; length::Vec{FT} = 1.0, width::Vec{FT} = 1.0) where FT
    v2 = v .+ length
    v3 = v2 .+ width
    v4 = v .+ width
    construct_mesh([v, v2, v3, v4], [Face(1,2,3), Face(1,3,4)])
end