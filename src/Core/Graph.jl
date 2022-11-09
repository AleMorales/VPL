### This file contains public API ###

################################################################################
###########################  Graph constructors  ###############################
################################################################################

"""
    Graph(;axiom, rules = nothing, vars = nothing)

Create a dynamic graph from an axiom, one or more rules and, optionally, 
graph-level variables.

## Arguments
- `axiom`: A single object inheriting from `Node` or a subgraph generated  with 
the graph construction DSL. It should represent the initial state of the dynamic
graph. 
- `rules`:  A single `Rule` object or a tuple of `Rule` objects (optional). It 
should include all graph-rewriting rules of the graph. 
- `vars`: A single object of any user-defined type (optional). This will be the 
graph-level variable accessible from any rule or query applied to the graph.
- `FT`: Floating-point precision to be used when generating the 3D geometry 
associated to a graph. 

## Details
All arguments are assigned by keyword. The axiom and rules are deep-copied when 
creating the graph but the graph-level variables (if a copy is needed due to
mutability, the user needs to care of that).

## Return
An object of type `Graph` representing a dynamic graph. Printing this object
results in a human-readable description of the type of data stored in the graph.

## Examples
```julia
let
    struct A0 <: Node end
    struct B0 <: Node end
    axiom = A0() + B0()
    no_rules_graph = Graph(axiom = axiom)
    rule = Rule(A, rhs = x -> A0() + B0())
    rules_graph = Graph(axiom = axiom, rules = rule)
end
```
"""
function Graph(;axiom::Union{StaticGraph, Node},
               rules::Union{Nothing, Tuple, Rule} = nothing, 
               vars = nothing) 
  if rules isa Nothing
    Graph(StaticGraph(deepcopy(axiom)), (), deepcopy(vars))
  else
    Graph(StaticGraph(deepcopy(axiom)), deepcopy(Tuple(rules)), deepcopy(vars))
  end
end

################################################################################
##############################  Properties  ###############################
################################################################################

"""
    rules(g::Graph)

Returns a tuple with all the graph-rewriting rules stored in a dynamic graph

## Examples
```julia
struct A <: Node end
struct B <: Node end
axiom = A() + B()
rule = Rule(A, rhs = x -> A() + B())
rules_graph = Graph(axiom, rules = rule)
rules(rules_graph)
```
"""
rules(g::Graph) = g.rules

"""
  vars(g::Graph)

Returns the graph-level variables.

## Example
```julia
struct A <: Node end
axiom = A()
graph = Graph(axiom, vars = 2)
vars(graph)
```
"""
vars(g::Graph) = g.vars

#= 
Returns the StaticGraph stored inside the Graph object (users are not supposed
to interact directly with the StaticGraph)
=#
graph(g::Graph) = g.graph

################################################################################
##############################  Show methods  ##################################
################################################################################

#=
  Print humand-friendly description of a Graph. Users will not call this one
  explictly, it is used by Julia to determine what happens when the object is
  printed.
=#
function show(io::IO, g::Graph)
   nrules = length(g.rules)
   nnodes = length(g.graph)
   nodetypes = collect(keys(g.graph.nodetypes))
   vars = typeof(g.vars)
   println(io, "Dynamic graph with ", nnodes, " nodes of types ", join(nodetypes, ','), " and ", nrules, " rewriting rules.")
   if vars != Nothing
     println(io, "Dynamic graph variables stored in struct of type ", vars)
   end
  return nothing
end

################################################################################
##############################  Forward methods  ###############################
################################################################################

# Forward several methods from StaticGraph to Graph
macro forwardgraph(method)
   esc(:($method(g::Graph) = $method(graph(g))))
end

@forwardgraph length
@forwardgraph nodetypes
@forwardgraph root
@forwardgraph rootNode
@forwardgraph insertion
@forwardgraph insertionNode
@forwardgraph nodes
@forwardgraph empty!

getindex(g::Graph, ID::Int) = getindex(graph(g), ID)
children(n::GraphNode, g::Graph) = children(n, graph(g))
