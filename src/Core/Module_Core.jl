module Core

import Base: copy, length, empty!, append!, +, getindex, setindex!, show, parent,
             Tuple

import Unrolled: @unroll
import Blink

include("Types.jl")
include("GraphNode.jl")
include("Context.jl")
include("StaticGraph.jl")
include("GraphConstruction.jl")
include("GraphRewriting.jl")
include("Graph.jl")
include("Rule.jl")
include("Query.jl")
include("algorithms.jl")
include("Draw.jl")

end