### This file contains public API ###

################################################################################
###########################  Constructors  #####################################
################################################################################

"""
    Query(nodetype::DataType; condition = x -> true)

Create a query that matches nodes of type `nodetype` and a `condition`.

## Arguments
- `nodetype::DataType`: Type of node to be matched.  
- `condition`: Function or function-like object that checks if a node should be
selected. It is assigned as a keyword argument.

## Details
If the `nodetype` should refer to a concrete type and match one of the types
stored inside the graph. Abstract types or types that are not contained in the
graph are allowed but the query will never return anything.

The `condition` must be a function or function-like object that takes a 
`Context` as input and returns `true` or `false`. The default `condition` always
return `true` such that the query will

## Return
It returns an object of type `Query`. Use `apply()` to execute the query on a 
dynamic graph.

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
Query(nodetype::DataType; condition = x -> true) = Query{nodetype, typeof(condition)}(condition)

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
