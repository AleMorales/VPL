

struct SolidConeFaces
    n::Int
end
function iterate(c::SolidConeFaces, i::Int = 1) 
    if i < c.n
        (Face(1, i + 1, i + 2), i + 1)
    elseif i == c.n
        (Face(1, c.n + 1, 2), i + 1)
    elseif i < 2c.n
        j = i - c.n + 1
        (Face(c.n + 2, j + 1, j), i + 1)
    elseif i == 2c.n
        (Face(c.n + 2, 2, c.n + 1), i + 1)
    else
        nothing
    end
end
length(c::SolidConeFaces) = 2c.n
eltype(::Type{SolidConeFaces}) = Face

struct SolidConeNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
    normbase::Vec{FT}
end
function SolidConeNormals(n, trans::AbstractMatrix{FT})  where FT
    SolidConeNormals(n, FT(2pi/n), trans,normalize(trans*Vec{FT}(0,0,-1)))
end
function iterate(c::SolidConeNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i < c.n + 1
        norm = normal_cone((i - 1)*c.Δ + c.Δ/2, c.trans)
        (norm, i + 1)
    elseif i < 2c.n + 1
        (c.normbase, i + 1)
    else
        nothing
    end
end
length(c::SolidConeNormals) = 2c.n
eltype(::Type{SolidConeNormals{FT,TT}}) where {FT,TT} = Vec{FT}


struct SolidConeVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function SolidConeVertices(n, trans) 
    FT = eltype(trans.linear)
    SolidConeVertices(n, FT(2pi/n), trans)
end
function iterate(c::SolidConeVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i == 1
        (c.trans(Vec{FT}(0,0,1)), 2)
    elseif i < c.n + 2
        vert = vertex_cone((i - 1)*c.Δ, c.trans)
        (vert, i + 1)
    elseif i == c.n + 2
        (c.trans(Vec{FT}(0,0,0)), i + 1)
    else 
        nothing
    end
end
length(c::SolidConeVertices) = c.n + 2
eltype(::Type{SolidConeVertices{FT,TT}}) where {FT,TT} = Vec{FT}


# Scaled SolidCone
function SolidCone(;l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20) where FT
    trans = LinearMap(SDiagonal(h/FT(2), w/FT(2), l))
    SolidCone(trans, n = n)
end

# Create a SolidCone from affine transformation
function SolidCone(trans::AbstractAffineMap; n::Int = 20)
    Primitive(trans, x -> SolidConeVertices(n, x), x -> SolidConeNormals(n,x), 
              () -> SolidConeFaces(n))
end

# Create a SolidCone from affine transformation and add it in-place to existing mesh
function SolidCone!(m::Mesh, trans::AbstractAffineMap; n::Int = 20) 
    Primitive!(m, trans, x -> SolidConeVertices(n, x), x -> SolidConeNormals(n, x), 
               () -> SolidConeFaces(n))
end
        