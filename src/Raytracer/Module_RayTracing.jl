module RayTracing

# Dependencies from Julia's standard library
using LinearAlgebra
import Statistics: quantile, mean
import Base: intersect, length
import Random
import Base.Threads: @threads, nthreads

# External dependencies
import StaticArrays: SVector, SArray, SizedVector, SMatrix, @SVector, MVector, @MVector, SDiagonal
import Unrolled: @unroll
import CoordinateTransformations: compose, Translation, LinearMap, AbstractAffineMap
import Rotations: RotX, RotY, RotZ
import StatsBase: sample, Weights
import ColorTypes: RGBA, RGB
#import Makie: scatter!, linesegments!

# Internal dependencies
# import ..VPL.Render: render!
import ..VPL.Geom: Vec, O, X, Y, Z, geoms, Mesh, areas, Turtle, feed!, 
                   ntriangles, Ellipse, rotate!, translate!, scale, BBox,
                   Scene, vertices, mesh, faces, material_ids, materials
import ..VPL.Core: Node, Graph, GraphNode, root, children
import ..VPL: Turtle, add!, Material

# Helpers and auxilliary functions
include("utils.jl")

# Basic geometry
include("Geometry/Ray.jl")
include("Geometry/Triangle.jl")
include("Geometry/AABB.jl")

# Materials
include("Materials/Material.jl")

# Acceleration structures
include("Acceleration/Acceleration.jl")

# Sources
include("Sources/Source.jl")

# RayTracer
include("RayTracer/RayTracer.jl")


# 3D rendering of elements in the ray tracer
# include("Render.jl")


end # end module