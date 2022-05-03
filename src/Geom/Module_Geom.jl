module Geom

import StaticArrays: SVector, SMatrix
import GeometryBasics
import Base: ==, ≈, iterate, length, eltype, isapprox
import FileIO
import LinearAlgebra: ×, norm, normalize, Diagonal, cross
import CoordinateTransformations: SDiagonal, LinearMap, AffineMap, AbstractAffineMap, Translation
import Rotations: RotX, RotY, RotZ
import Unrolled: @unroll
import ..VPL: Turtle
import ..VPL.Core: Node, Graph, GraphNode, root, children

"""
    Vec(x, y, z)

3D vector or point with coordinates x, y and z.
"""
const Vec{FT} = SVector{3, FT}

const Face    = SVector{3, Int}

"""
    O()

Returns the origin of the 3D coordinate system as a `Vec` object. By default, the coordinates will be in double 
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `O(Float32)`.
"""
function O(::Type{FT} = Float64) where FT 
    Vec{FT}(0,0,0)
end

"""
    Z()

Returns an unit vector in the direction of the Z axis as a `Vec` object. By default, the coordinates will be in double 
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `Z(Float32)`.
"""
function Z(::Type{FT} = Float64) where FT 
    Vec{FT}(0,0,1)
end

"""
    Z(s)

Returns scaled vector in the direction of the Z axis with length `s` as a `Vec` object using the same floating point precision
as `s`.
"""
function Z(s::FT) where FT 
    Vec{FT}(0,0,s)
end

"""
    Y()

Returns an unit vector in the direction of the Y axis as a `Vec` object. By default, the coordinates will be in double 
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `Y(Float32)`.
"""
function Y(::Type{FT} = Float64) where FT 
    Vec{FT}(0,1,0)
end

"""
    Y(s)

Returns scaled vector in the direction of the Y axis with length `s` as a `Vec` object using the same floating point precision
as `s`.
"""
function Y(s::FT) where FT 
    Vec{FT}(0,s,0)
end

"""
    X()

Returns an unit vector in the direction of the X axis as a `Vec` object. By default, the coordinates will be in double 
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `X(Float32)`.
"""
function X(::Type{FT} = Float64) where FT
    Vec{FT}(1,0,0)
end

"""
    X(s)

Returns scaled vector in the direction of the X axis with length `s` as a `Vec` object using the same floating point precision
as `s`.
"""
function X(s::FT) where FT
    Vec{FT}(s,0,0)
end

# Triangular meshes
include("Mesh/Mesh.jl")
include("Mesh/MeshConstruction.jl")
include("Mesh/MeshIO.jl")

# Primitive constructors
include("Primitives/BBox.jl")
include("Primitives/Generic.jl")
include("Primitives/Rectangle.jl")
include("Primitives/Ellipse.jl")
include("Primitives/SolidCube.jl")
include("Primitives/HollowCube.jl")
include("Primitives/HollowCylinder.jl")
include("Primitives/SolidCylinder.jl")
include("Primitives/HollowCone.jl")
include("Primitives/SolidCone.jl")
include("Primitives/HollowFrustum.jl")
include("Primitives/SolidFrustum.jl")
include("Primitives/Ellipsoid.jl")

# Geometry turtle
include("Turtle/Turtle.jl")
include("Turtle/Movements.jl")
include("Turtle/Transformations.jl")
include("Turtle/Primitives.jl")
include("Turtle/Graphs.jl")

end

# TODO: Add Box, Triangle and finish Ellipsoid