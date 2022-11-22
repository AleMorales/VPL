### This file contains public API ###

"""
    Node

Abstract type from which every node in a graph should inherit. This allows using
the graph construction DSL.

# Example
```julia
let
  struct bar <: Node
    x::Int
  end
  b1 = bar(1)
  b2 = bar(2)
  b1 + b2
end
```
"""
abstract type Node end

#=
  GraphNode{T}

Data structure that wraps the contents of a node and includes references to the
ids of the parent and children node and the node itself. These IDs are used to
traverse the graph and guide relational queries. The type parameter `T` corresponds
to the type of data stored in the node (defined by the user). User do not  build 
build `GraphNode` objects directly, this is always handled by VPL when creating
or modifying a graph.
=#
mutable struct GraphNode{T}
  data::T
  childrenID::Set{Int}
  parentID::Union{Int, Missing}
  selfID::Int
end


"""
    Context
  
Data structure than links a node to the rest of the graph.

## Fields
- `graph`: Dynamic graph that contains the node.  
- `node`: Node inside the graph. 

## Details
A `Context` object wraps references to a node and its associated graph. The
purpose of this structure is to be able to test relationships among nodes within
a graph (from with a query or rule), as well as access the data stored in a node
(with `data()`) or the graph (with `vars()`).

Users do not build `Context` objects directly but they are provided by VPL as 
inputs to the user-defined functions inside rules and queries. 
"""
mutable struct Context{N, G}
  graph::G
  node::N
end

# Special constructor to propagate missing nodes
Context(graph, node::Missing) = missing

#=
  StaticGraph

Data structure to store a collection of nodes that are related to each other 
though a graph. Unlike objects of type `Graph`, a `StaticGraph` does not contain
rules or graph-level variables.

Users do not build `StaticGraph` objects directly but rather they are created by
VPL through the graph construction DSL (see User Manual for details).
=#
mutable struct StaticGraph
    nodes::Dict{Int, Any}
    nodetypes::Dict{DataType, Set{Int}}
    root::Int
    insertion::Int
end


# Docstring is included in the constructor in Graph.jl
#=
  Data structure to store a graph plus rules to rewrite it and graph-level variables
  All rules are stored in a dictionary which keys are the unique identifiers of the rules
  The field vars contains a struct with variables that are accesible in queries and production rules
=#
mutable struct Graph{T, S <: Tuple}
    graph::StaticGraph
    rules::S
    vars::T
end

function Graph(graph::StaticGraph, rules, vars)
  Graph(graph, rules, vars)
end

# Docstring is included in the constructor in Rule.jl
#=
  Data structure to store a node replacement rule for graph rewriting.
  N is the type of node to be replaced
=#
mutable struct Rule{N, C, LHST, RHST}
  lhs::LHST
  rhs::RHST
  matched::Vector{Int}
  contexts::Vector{Tuple}
end


# Docstring is included in the constructor in Query.jl
#=
  Data structure to store a graph query
=#
struct Query{N,Q}
  query::Q
end
