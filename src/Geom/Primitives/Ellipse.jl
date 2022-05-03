
struct EllipseFaces
    nt::Int
end
iterate(e::EllipseFaces) = (Face(1,3,2), 2)
function iterate(e::EllipseFaces, i) 
    if i < e.nt
        (Face(1, i + 2, i + 1), i + 1)
    elseif i == e.nt
        (Face(1, 2, e.nt + 1), i + 1)
    else
        nothing
    end
end
length(e::EllipseFaces) = e.nt
eltype(::Type{EllipseFaces}) = Face


struct EllipseNormals{FT}
    nt::Int
    norm::Vec{FT}
end
EllipseNormals(nt, trans::AbstractMatrix{FT}) where FT = EllipseNormals(nt, normalize(trans*Vec{FT}(1, 0, 0)))
function iterate(e::EllipseNormals{FT})::Union{Nothing, Tuple{Vec{FT}, Int64}} where FT 
    (e.norm, 2)
end
function iterate(e::EllipseNormals{FT}, i)::Union{Nothing, Tuple{Vec{FT}, Int64}} where FT 
    i > e.nt ? nothing : (e.norm, i + 1)
end
length(e::EllipseNormals) = e.nt
eltype(::Type{EllipseNormals{FT}}) where FT = Vec{FT}

struct EllipseVertices{FT,TT}
    nt::Int
    Δ::FT
    trans::TT
end
function EllipseVertices(nt, trans) 
    FT = eltype(trans.linear)
    EllipseVertices(nt, FT(2pi/nt), trans)
end
function iterate(e::EllipseVertices{FT,TT})::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT} 
    (e.trans(Vec{FT}(0,0,1)), 2)
end
function iterate(e::EllipseVertices{FT,TT}, i)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i > e.nt + 1 
      nothing 
    else
        α = (i - 2)*e.Δ
        sina = sin(α)
        cosa = cos(α)
        orig = Z(FT) .+ sina.*Z(FT) .+  cosa.*Y(FT)
        vert = e.trans(orig)
        (vert, i + 1)
    end
end
length(e::EllipseVertices) = e.nt + 1
eltype(::Type{EllipseVertices{FT}}) where FT = Vec{FT}


"""
    Ellipse(;l = 1.0, w = 1.0, n = 20)

Create a standard ellipse with length `l`, width `w` and discretized into `n` triangles (see VPL documentation for details). 
"""
function Ellipse(;l::FT = one(FT), w::FT = one(FT) , n::Int = 20) where FT <: AbstractFloat
    trans = LinearMap(SDiagonal(one(FT), w/FT(2), l/FT(2)))
    Ellipse(trans; n = n)
end

# Create a ellipse from affine transformation
function Ellipse(trans::AbstractAffineMap; n::Int = 20)
    Primitive(trans, x -> EllipseVertices(n, x), x -> EllipseNormals(n,x), 
        () -> EllipseFaces(n))
end

# Create a ellipse from affine transformation and add it in-place to existing mesh
function Ellipse!(m::Mesh, trans::AbstractAffineMap; n::Int = 20)
    Primitive!(m, trans, x -> EllipseVertices(n, x), x -> EllipseNormals(n, x), 
    () -> EllipseFaces(n))
end
        
