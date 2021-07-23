
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

# Scaled rectangle
function Rectangle(;l::FT = one(FT), w::FT = one(FT)) where FT
    trans = LinearMap(SDiagonal(one(FT), w/FT(2), l))
    Rectangle(trans)
end

# Create a rectangle from affine transformation
Rectangle(trans::AbstractAffineMap) = Primitive(trans, RectangleVertices, RectangleNormals, RectangleFaces)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(m::Mesh, trans::AbstractAffineMap) = Primitive!(m, trans, RectangleVertices, RectangleNormals, RectangleFaces)


#########################################################
################# Manual constructors ###################
#########################################################

function Rectangle(v1::Vec, l::Vec, w::Vec)
    v2 = v1 .+ l
    v3 = v2 .+ w
    v4 = v1 .+ w
    construct_mesh([v1, v2, v3, v4], [Face(1,2,3), Face(1,3,4)])
end