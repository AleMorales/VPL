
# Note: The compiler was struggling to infer the return type of the iterators, so I annotated them

struct HollowFrustumFaces
    n::Int
end
function iterate(c::HollowFrustumFaces, i::Int = 1) 
    if i == 1
        (Face(c.n, c.n + 1, 1), 2) # Lateral - end
    elseif i == 2
        (Face(c.n, 2c.n, c.n + 1), 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 2
        (Face(j, j + c.n, j + c.n + 1), i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n - 1
        (Face(j, j + c.n + 1, j + 1), i + 1) # Lateral - intermedaite
    else 
        nothing
    end
end
length(c::HollowFrustumFaces) = 2c.n
eltype(::Type{HollowFrustumFaces}) = Face


function normal_frustum(α::FT, trans::AbstractMatrix{FT}, sinβ::FT)::Vec{FT} where FT
    sina = sin(α)
    cosa = cos(α)
    orig = sina.*X(FT) .+  cosa.*Y(FT) .+ sinβ.*Z(FT)
    norm = normalize(trans*orig)
end

struct HollowFrustumNormals{FT,TT}
    sinβ::FT
    n::Int
    Δ::FT
    trans::TT
end
function HollowFrustumNormals(ratio, n, trans::AbstractMatrix{FT}) where FT 
    HollowFrustumNormals(1/sqrt((one(FT) - ratio)^2 + one(FT)), n, FT(2pi/n), trans)
end
function iterate(c::HollowFrustumNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT} 
    if i == 1
        norm = normal_frustum((c.n - 1)*c.Δ, c.trans, c.sinβ)
        (norm, 2) # Lateral - end
    elseif i == 2
        norm = normal_frustum((c.n - 1)*c.Δ, c.trans, c.sinβ)
        (norm, 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 1 # 2:n
        norm = normal_frustum((j - 2)*c.Δ, c.trans, c.sinβ)
        (norm, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n # 2:n
        norm = normal_frustum((j - 2)*c.Δ, c.trans, c.sinβ)
        (norm, i + 1) # Lateral - intermediate
    else 
        nothing
    end
end
length(c::HollowFrustumNormals) = 2c.n
eltype(::Type{HollowFrustumNormals{FT,TT}}) where {FT,TT} = Vec{FT}



function vertex_frustum(α::FT, trans, upper, ratio::FT)::Vec{FT} where FT
    if upper
        sina = sin(α)*ratio
        cosa = cos(α)*ratio
        orig = Z(FT) .+ sina.*Y(FT) .+  cosa.*X(FT)
    else
        sina = sin(α)
        cosa = cos(α)
        orig = sina.*Y(FT) .+  cosa.*X(FT)
    end
    vert = trans(orig)
end


struct HollowFrustumVertices{FT,TT}
    ratio::FT
    n::Int
    Δ::FT
    trans::TT
end
function HollowFrustumVertices(ratio::FT, n, trans) where FT
    @assert eltype(trans.linear) == FT
    HollowFrustumVertices(ratio, n, FT(2*pi/n), trans)
end
function iterate(c::HollowFrustumVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT} 
    if i < c.n + 1
        j = i # 2:n
        vert = vertex_frustum((j - 1)*c.Δ, c.trans, false, c.ratio)
        (vert, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n# 2:n
        vert = vertex_frustum((j - 1)*c.Δ, c.trans, true, c.ratio)
        (vert, i + 1) # Lateral - intermediate
    else 
        nothing
    end
end
length(c::HollowFrustumVertices) = 2c.n
eltype(::Type{HollowFrustumVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowFrustum(;l = 1.0, w = 1.0, h = 1.0, n = 20)

Create a standard hollow frustum with length `l`, width `w`, height `h` and discretized into `2n` triangles (see VPL documentation for details). 
"""
function HollowFrustum(;l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), ratio::FT = one(FT), n::Int = 20) where FT
    trans = LinearMap(SDiagonal(h/FT(2), w/FT(2), l))
    HollowFrustum(ratio, trans, n = n)
end

# Create a HollowFrustum from affine transformation
function HollowFrustum(ratio, trans::AbstractAffineMap; n::Int = 20)
    Primitive(trans, x -> HollowFrustumVertices(ratio, n, x), x -> HollowFrustumNormals(ratio,n,x), 
              () -> HollowFrustumFaces(n))
end

# Create a HollowFrustum from affine transformation and add it in-place to existing mesh
function HollowFrustum!(m::Mesh, ratio, trans::AbstractAffineMap; n::Int = 20) 
    Primitive!(m, trans, x -> HollowFrustumVertices(ratio, n, x), x -> HollowFrustumNormals(ratio,n, x), 
               () -> HollowFrustumFaces(n))
end
        