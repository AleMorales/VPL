### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################
struct TrapezoidFaces end
iterate(r::TrapezoidFaces) = (Face(1, 2, 3), 2)
iterate(r::TrapezoidFaces, i) = i > 2 ? nothing : (Face(1, 3, 4), 3)
length(r::TrapezoidFaces) = 2
eltype(::Type{TrapezoidFaces}) = Face

struct TrapezoidNormals{FT}
    norm::Vec{FT}
end
TrapezoidNormals(trans::AbstractMatrix{FT}) where FT = TrapezoidNormals(normalize(trans*X(FT)))
function iterate(r::TrapezoidNormals{FT})::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT}
    (r.norm, 2)
end
function iterate(r::TrapezoidNormals{FT}, i)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT} 
    i > 2 ? nothing : (r.norm, 3)
end
length(r::TrapezoidNormals) = 2
eltype(::Type{TrapezoidNormals{FT}}) where FT = Vec{FT}


all_trapezoid_vertices(ratio::FT, ::Type{FT}) where FT = (Vec{FT}(0, -1, 0), Vec{FT}(0, -ratio, 1), Vec{FT}(0, ratio, 1), Vec{FT}(0, 1, 0))
struct TrapezoidVertices{VT,TT}
    trans::TT
    verts::VT
end
function genTrapezoidVertices(ratio::FT, trans) where FT
    TrapezoidVertices(trans, all_trapezoid_vertices(ratio, FT))
end
function iterate(r::RV)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: TrapezoidVertices
    (@inbounds r.trans(r.verts[1]), 2)
end
function iterate(r::RV, i)::Union{Nothing, Tuple{eltype(RV), Int64}} where RV <: TrapezoidVertices
    i > 4 ? nothing : (@inbounds r.trans(r.verts[i]), i + 1)
end
length(r::TrapezoidVertices) = 4
function eltype(::Type{TrapezoidVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0)

Create a trapezoid with dimensions given by `length` and the larger `width` and
the `ratio` between the smaller and larger widths. The trapezoid is generted at 
the standard location and orientation. 
"""
function Trapezoid(;length::FT = 1.0, width::FT = 1.0, ratio::FT = 1.0) where FT
    trans = LinearMap(SDiagonal(one(FT), width/FT(2), length))
    Trapezoid(trans, ratio)
end

# Create a trapezoid from affine transformation
Trapezoid(trans::AbstractAffineMap, ratio) = 
            Primitive(trans, x -> genTrapezoidVertices(ratio, x), 
                             TrapezoidNormals, TrapezoidFaces)

# Create a trapezoid from affine transformation and add it in-place to existing mesh
Trapezoid!(m::Mesh, trans::AbstractAffineMap, ratio) = 
            Primitive!(m, trans, x -> genTrapezoidVertices(ratio, x), 
                          TrapezoidNormals, TrapezoidFaces)
