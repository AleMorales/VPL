### This file contains public API (apply) ###

################################################################################
###########################  Constructors  #####################################
################################################################################

"""
    Query(nodetype::DataType, query = x -> true)

  Create a query that matches nodes of type `nodetype` and the conditions specified
in the argument `query` (must be a function that returns `true`). It returns an
object of type `Query` that can be applied to a graph with the function `apply`.

# Example
```julia
struct A <: Node end
struct B <: Node end
axiom = A() + B()
graph = Graph(axiom)
query = Query(A)
apply(graph, query)
```
"""
Query(nodetype::DataType, query = x -> true) = Query{nodetype, typeof(query)}(query)

# Helper function for type propagation
nodetype(query::Query{N,Q}) where {N,Q} = N


################################################################################
##############################  Show methods  ##################################
################################################################################

#=
  Print human-friendly description of a query
=#
function show(io::IO, rule::Query{N,Q}) where {N,Q}
  println(io, "Query object for nodes of type ", N)
end

################################################################################
############################  Apply query  #####################################
################################################################################

"""
    apply(g::Graph, query::Query)

Return an array with all the nodes in the graph that match the query supplied by 
the user.

# Example
```julia
struct A <: Node end
struct B <: Node end
axiom = A() + B()
graph = Graph(axiom)
query = Query(A)
apply(graph, query)
```
"""
function apply(g::Graph, query::Query{N,Q})::Vector{N} where {Q,N}
    !hasNodetype(graph(g), N) && (return N[])
    candidates = nodetypes(g)[N]
    output = N[]
    for id in candidates
        if query.query(Context(g, g[id]))
            push!(output, g[id].data::N)
        end
    end
    return output
end
