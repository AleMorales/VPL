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

const Vec{FT} = SVector{3, FT}
const Face    = SVector{3, Int}

O(::Type{FT} = Float64) where FT = Vec{FT}(0,0,0)
Z(::Type{FT} = Float64) where FT = Vec{FT}(0,0,1)
Z(s::FT) where FT = Vec{FT}(0,0,s)
Y(::Type{FT} = Float64) where FT = Vec{FT}(0,1,0)
Y(s::FT) where FT = Vec{FT}(0,s,0)
X(::Type{FT} = Float64) where FT = Vec{FT}(1,0,0)
X(s::FT) where FT = Vec{FT}(s,0,0)

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