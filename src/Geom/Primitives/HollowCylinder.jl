### This file contains public API ###

# cylinder_faces_hollow(n) = Face[Tuple(Face(i, i + n + 1, i + n + 2) for i in 2:n)...,
#                                  Tuple(Face(i, i + n + 2, i + 1) for i in 2:n)...,
#                                  Face(n+1, 2nt+2, n+3), Face(n+1,n+3,1)]
                                 
# cylinder_faces(n) = [Tuple(Face(i, i + n + 1, i + n + 2) for i in 2:n)...,
#                       Tuple(Face(i, i + n + 2, i + 1) for i in 2:n)...,
#                       Face(n+1, 2nt+2, n+3), Face(n+1,n+3,1) # sides
#                       Tuple(Face(1, i, i - 1) for i in n+1:-1:3)..., Face(1,2,n+1), # lower Cylinder
#                       Tuple(Face(n + 2, i, i + 1) for i in n + 3:2nt + 1)..., Face(n+2,2nt+2,n+3)] # upper Cylinder


struct HollowCylinderFaces
    n::Int
end
function iterate(c::HollowCylinderFaces, i::Int = 1) 
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
length(c::HollowCylinderFaces) = 2c.n
eltype(::Type{HollowCylinderFaces}) = Face


function normal_cylinder(α, trans::AbstractMatrix{FT}) where FT
    sina = sin(α)
    cosa = cos(α)
    orig = sina.*X(FT) .+  cosa.*Y(FT)
    norm = normalize(trans*orig)
end

struct HollowCylinderNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowCylinderNormals(n, trans::AbstractMatrix{FT})  where FT
    HollowCylinderNormals(n, FT(2pi/n), trans)
end
function iterate(c::HollowCylinderNormals{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
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
    else 
        nothing
    end
end
length(c::HollowCylinderNormals) = 2c.n
eltype(::Type{HollowCylinderNormals{FT,TT}}) where {FT,TT} = Vec{FT}


function vertex_cylinder(α, trans, upper)
    FT = eltype(trans.linear)
    sina = sin(α)
    cosa = cos(α)
    if upper
        orig = Vec{FT}(0,0,1) .+ sina.*Y(FT) .+  cosa.*X(FT)
    else
        orig = sina.*Y(FT) .+  cosa.*X(FT)
    end
    vert = trans(orig)
end


struct HollowCylinderVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowCylinderVertices(n, trans)
    FT = eltype(trans.linear)
    HollowCylinderVertices(n, FT(2pi/n), trans)
end
function iterate(c::HollowCylinderVertices{FT,TT}, i::Int = 1)::Union{Nothing, Tuple{Vec{FT}, Int64}} where {FT,TT}
    if i < c.n + 1
        j = i # 2:n
        vert = vertex_cylinder((j - 1)*c.Δ, c.trans, false)
        (vert, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n# 2:n
        vert = vertex_cylinder((j - 1)*c.Δ, c.trans, true)
        (vert, i + 1) # Lateral - intermediate
    else 
        nothing
    end
end
length(c::HollowCylinderVertices) = 2c.n
eltype(::Type{HollowCylinderVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40)

Create a hollow cylinder with dimensions given by `length`, `width` and `height`,
 discretized into `n` triangles (must be even) and standard location and orientation.
"""
function HollowCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, 
                        n::Int = 40) where FT
    trans = LinearMap(SDiagonal(height/FT(2), width/FT(2), length))
    HollowCylinder(trans, n = n)
end

# Create a HollowCylinder from affine transformation
function HollowCylinder(trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n,2)
    Primitive(trans, x -> HollowCylinderVertices(n, x), 
                     x -> HollowCylinderNormals(n,x), 
                    () -> HollowCylinderFaces(n))
end

# Create a HollowCylinder from affine transformation and add it in-place to existing mesh
function HollowCylinder!(m::Mesh, trans::AbstractAffineMap; n::Int = 40) 
    @assert iseven(n)
    n = div(n,2)
    Primitive!(m, trans, x -> HollowCylinderVertices(n, x), 
                         x -> HollowCylinderNormals(n, x), 
                         () -> HollowCylinderFaces(n))
end
        