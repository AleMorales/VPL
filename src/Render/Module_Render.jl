module Render

import GLMakie, WGLMakie, Makie
import GeometryBasics
import LinearAlgebra: normalize, ×
import ColorTypes: Colorant, RGB, RGBA
import FileIO
import Unrolled: @unroll
import ..Geom
import ..VPL: Turtle
import ..VPL.Core: Node, Graph, GraphNode, root, children

include("Scene.jl")
include("Render.jl")
include("GLMakie.jl")
include("Turtle.jl")


end

# TODO: Sync the interface for saving rendered scenes with export_graph (as described in the documentation)
