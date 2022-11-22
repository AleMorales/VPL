### This file contains public API ###

struct SolidCylinderFaces
    n::Int
end
function iterate(c::SolidCylinderFaces, i::Int = 1) 
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
length(c::SolidCylinderFaces) = 4c.n
eltype(::Type{SolidCylinderFaces}) = Face


struct SolidCylinderNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
    ln::Vec{FT}
    un::Vec{FT}
end

function SolidCylinderNormals(n, trans::AbstractMatrix{FT})  where FT
    SolidCylinderNormals(n, FT(2pi/n), trans, trans*Vec{FT}(0,0,-1), trans*Vec{FT}(1,0,0))
end
function iterate(c::SolidCylinderNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT} 
    if i == 1
        norm = normal_cylinder((c.n - 1)*c.Δ, c.trans)
        (norm, 2) # Lateral - end
    elseif i == 2
        norm = normal_cylinder((c.n - 1)*c.Δ, c.trans)
        (norm, 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 1 # 2:n
        norm = normal_cylinder((j - 2)*c.Δ, c.trans)
        (norm, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n # 2:n
        norm = normal_cylinder((j - 2)*c.Δ, c.trans)
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
length(c::SolidCylinderNormals) = 4c.n
eltype(::Type{SolidCylinderNormals{FT,TT}}) where {FT,TT} = Vec{FT}


struct SolidCylinderVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function SolidCylinderVertices(n, trans)
    FT = eltype(trans.linear)
    SolidCylinderVertices(n, FT(2pi/n), trans)
end
function iterate(c::SolidCylinderVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i == 1
        (c.trans(Vec{FT}(0,0,0)), 2) # Center - lower
    elseif i < c.n + 2
        j = i # 2:n
        vert = vertex_cylinder((j - 2)*c.Δ, c.trans, false)
        (vert, i + 1) # Lateral - intermediate
    elseif i == c.n + 2
        (c.trans(Vec{FT}(0,0,1)), i + 1) # Center - lower
    elseif i < 2c.n + 3
        j = i - c.n - 1# 2:n
        vert = vertex_cylinder((j - 2)*c.Δ, c.trans, true)
        (vert, i + 1) # Lateral - intermediate
    else 
        nothing
    end
end
length(c::SolidCylinderVertices) = 2c.n + 2
eltype(::Type{SolidCylinderVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80)

Create a solid cylinder with dimensions given by `length`, `width` and `height`, 
discretized into `n` triangles (must be even) and standard location and orientation. 
"""
function SolidCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, 
                        n::Int = 80) where FT
    trans = LinearMap(SDiagonal(height/FT(2), width/FT(2), length))
    SolidCylinder(trans, n = n)
end

# Create a SolidCylinder from affine transformation
function SolidCylinder(trans::AbstractAffineMap; n::Int = 80)
    @assert iseven(n)
    n = div(n,4)
    Primitive(trans, x -> SolidCylinderVertices(n, x), 
                     x -> SolidCylinderNormals(n,x), 
                    () -> SolidCylinderFaces(n))
end

# Create a SolidCylinder from affine transformation and add it in-place to existing mesh
function SolidCylinder!(m::Mesh, trans::AbstractAffineMap; n::Int = 80) 
    @assert iseven(n)
    n = div(n,4)
    Primitive!(m, trans, x -> SolidCylinderVertices(n, x), 
                         x -> SolidCylinderNormals(n, x), 
                        () -> SolidCylinderFaces(n))
end