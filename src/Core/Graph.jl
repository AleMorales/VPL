### This file contains public API (Graph -> Graph) ###

################################################################################
###########################  Graph constructors  ###############################
################################################################################

"""
    Graph(axiom; rules = nothing, vars = nothing)

Creates a dynamic graph defined by the initial node or nodes (`axiom`), one or more rules 
(`rules`), and an object with graph-level variables (`vars`). Rules and graph-level
variables are optional and must be assigned by keyword (see example below). 
Rules must be a `Rule` or tuple of `Rule` objects. 
The `axiom` may be a single object inheriting from `Node` or a subgraph generated 
with the graph construction DSL. 
A copy of the axiom and rules is always made when constructing the graph, but if
object containing graph-level variables is not `mutable`, the user must manually
copy it (with `copy` or `deepcopy`) or else changes within the graph will affect
the original object (and other graphs created from the same object).

# Example
```julia
struct A <: Node end
struct B <: Node end
axiom = A() + B()
no_rules_graph = Graph(axiom)
rule = Rule(A, rhs = x -> A() + B())
rules_graph = Graph(axiom, rules = rule)
```
"""
function Graph(axiom::Union{StaticGraph, Node}; 
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

Returns a tuple with all the graph-rewriting rules stored in the graph

# Example
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

Returns the object storing the graph-level variables

# Example
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
to operate directly with the StaticGraph)
=#
graph(g::Graph) = g.graph

################################################################################
##############################  Show methods  ##################################
################################################################################

#=
  Print humand-friendly description of a Graph
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

# Forward several methods from StaticGraph
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
