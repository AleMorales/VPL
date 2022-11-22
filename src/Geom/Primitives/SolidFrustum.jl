### This file contains public API ###

struct SolidFrustumFaces
    n::Int
end
function iterate(c::SolidFrustumFaces, i::Int = 1) 
    if i == 1
        (Face(c.n + 1, c.n + 3, 2), 2) # Lateral - end
    elseif i == 2
        (Face(c.n + 1, 2c.n + 2, c.n + 3), 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 1
        (Face(j, j + c.n + 1, j + c.n + 2), i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n
        (Face(j, j + c.n + 2, j + 1), i + 1) # Lateral - intermediate
    elseif i < 3c.n
        j = i - 2c.n + 2
        (Face(1, j - 1, j), i + 1) # Lower base - intermediate
    elseif i == 3c.n 
        (Face(1, c.n + 1, 2), i + 1) # Lower base - end
    elseif i < 4c.n
        j = i - 2c.n + 2
        (Face(c.n + 2, j + 1, j), i + 1) # Upper base - intermediate
    elseif i == 4c.n
        (Face(c.n + 2, c.n + 3, 2c.n + 2), i + 1) # Upper base - end
    else 
        nothing
    end
end
length(c::SolidFrustumFaces) = 4c.n
eltype(::Type{SolidFrustumFaces}) = Face


struct SolidFrustumNormals{FT,TT}
    sinβ::FT
    n::Int
    Δ::FT
    trans::TT
    ln::Vec{FT}
    un::Vec{FT}
end
function SolidFrustumNormals(ratio::FT, n, trans::AbstractMatrix{FT}) where FT 
    SolidFrustumNormals(1/sqrt((one(FT) - ratio)^2 + one(FT)), n, FT(2pi/n), trans,
                        trans*Vec{FT}(0,0,-1), trans*Vec{FT}(1,0,0))
end

function iterate(c::SolidFrustumNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
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
    elseif i < 3c.n
        (c.ln, i + 1) # Lower base - intermediate
    elseif i == 3c.n 
        (c.ln, i + 1) # Lower base - end
    elseif i < 4c.n
        j = i - 2c.n + 2
        (c.un, i + 1) # Upper base - intermediate
    elseif i == 4c.n
        (c.un, i + 1) # Upper base - end
    else 
        nothing
    end
end
length(c::SolidFrustumNormals) = 4c.n
eltype(::Type{SolidFrustumNormals{FT,TT}}) where {FT,TT} = Vec{FT}


struct SolidFrustumVertices{FT,TT}
    ratio::FT
    n::Int
    Δ::FT
    trans::TT
end
function SolidFrustumVertices(ratio::FT, n, trans) where FT
    @assert eltype(trans.linear) == FT
    SolidFrustumVertices(ratio, n, FT(2*pi/n), trans)
end
function iterate(c::SolidFrustumVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i == 1
         (c.trans(Vec{FT}(0,0,0)), 2) # Center - lower
    elseif i < c.n + 2
        j = i # 2:n
        vert = vertex_frustum((j - 2)*c.Δ, c.trans, false, c.ratio)
        (vert, i + 1) # Lateral - intermediate
    elseif i == c.n + 2
        (c.trans(Vec{FT}(0,0,1)), c.n + 3) # Center - lower
    elseif i < 2c.n + 3
        j = i - c.n - 1# 2:n
        vert = vertex_frustum((j - 2)*c.Δ, c.trans, true, c.ratio)
        (vert, i + 1) # Lateral - intermediate
    else 
        nothing
    end
end

length(c::SolidFrustumVertices) = 2c.n + 2
eltype(::Type{SolidFrustumVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40)

Create a solid frustum with dimensions given by `length`, `width` and `height`, 
discretized into `n` triangles and standard location and orientation. 
"""
function SolidFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, 
                       ratio::FT = 1.0, n::Int = 40) where FT
    trans = LinearMap(SDiagonal(height/FT(2), width/FT(2), length))
    SolidFrustum(ratio, trans, n = n)
end

# Create a SolidFrustum from affine transformation
function SolidFrustum(ratio, trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n,4)
    Primitive(trans, x -> SolidFrustumVertices(ratio, n, x), 
                     x -> SolidFrustumNormals(ratio,n,x), 
                    () -> SolidFrustumFaces(n))
end

# Create a SolidFrustum from affine transformation and add it in-place to existing mesh
function SolidFrustum!(m::Mesh, ratio, trans::AbstractAffineMap; n::Int = 40) 
    @assert iseven(n)
    n = div(n,4)
    Primitive!(m, trans, x -> SolidFrustumVertices(ratio, n, x), 
                         x -> SolidFrustumNormals(ratio,n, x), 
                        () -> SolidFrustumFaces(n))
end