module Core

import Base: copy, length, empty!, append!, +, getindex, setindex!, show, parent,
             Tuple

import Unrolled: @unroll

# External libraries for drawing interactive graph networks
#import Graphs as GR
#import GraphMakie as GM
#import NetworkLayout as NL
#import GLMakie
#import WGLMakie
#import CairoMakie
#import FileIO

include("Types.jl")
include("GraphNode.jl")
include("Context.jl")
include("StaticGraph.jl")
include("GraphConstruction.jl")
include("GraphRewriting.jl")
include("Graph.jl")
include("Rule.jl")
include("Query.jl")
include("Algorithms.jl")
#include("Draw.jl")

end