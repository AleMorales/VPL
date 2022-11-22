### This file contains public API ###

struct HollowConeFaces
    n::Int
end
function iterate(c::HollowConeFaces, i::Int = 1) 
    if i < c.n
        (Face(1, i + 1, i + 2), i + 1)
    elseif i == c.n
        (Face(1, c.n + 1, 2), i + 1)
    else
        nothing
    end
end
length(c::HollowConeFaces) = c.n
eltype(::Type{HollowConeFaces}) = Face


function normal_cone(α, trans::AbstractMatrix{FT}) where FT
    sina = sin(α)
    cosa = cos(α)
    sin45 = sin(FT(pi/4))
    orig = sina.*X(FT) .+  cosa.*Y(FT) .+ sin45.*Z(FT)
    norm = normalize(trans*orig)
end

struct HollowConeNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowConeNormals(n, trans::AbstractMatrix{FT})  where FT
    HollowConeNormals(n, FT(2pi/n), trans)
end
function iterate(c::HollowConeNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i < c.n + 1
        norm = normal_cone((i - 1)*c.Δ + c.Δ/2, c.trans)
        (norm, i + 1)
    else
        nothing
    end
end
length(c::HollowConeNormals) = c.n
eltype(::Type{HollowConeNormals{FT,TT}}) where {FT,TT} = Vec{FT}



function vertex_cone(α, trans)
    FT = eltype(trans.linear)
    sina = sin(α)
    cosa = cos(α)
    orig = sina.*X(FT) .+  cosa.*Y(FT)
    vert = trans(orig)
end


struct HollowConeVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowConeVertices(n, trans) 
    FT = eltype(trans.linear)
    HollowConeVertices(n, FT(2pi/n), trans)
end
function iterate(c::HollowConeVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i == 1
        (c.trans(Vec{FT}(0,0,1)), 2)
    elseif i < c.n + 2
        vert = vertex_cone((i - 1)*c.Δ, c.trans)
        (vert, i + 1)
    else 
        nothing
    end
end
length(c::HollowConeVertices) = c.n + 1
eltype(::Type{HollowConeVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create a hollow cone with dimensions given by `length`, `width` and `height`, 
discretized into `n` triangles (must be even) and standard location and orientation. 
"""
function HollowCone(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where FT
    trans = LinearMap(SDiagonal(height/FT(2), width/FT(2), length))
    HollowCone(trans, n = n)
end

# Create a HollowCone from affine transformation
function HollowCone(trans::AbstractAffineMap; n::Int = 20)
    Primitive(trans, x -> HollowConeVertices(n, x), x -> HollowConeNormals(n,x), 
              () -> HollowConeFaces(n))
end

# Create a HollowCone from affine transformation and add it in-place to existing mesh
function HollowCone!(m::Mesh, trans::AbstractAffineMap; n::Int = 20) 
    Primitive!(m, trans, x -> HollowConeVertices(n, x), x -> HollowConeNormals(n, x), 
               () -> HollowConeFaces(n))
end
        