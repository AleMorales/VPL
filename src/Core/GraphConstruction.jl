### This file contains public API ###

################################################################################
################  Add/Append methods for graph construction  ###################
################################################################################

#=
Add a new node to the graph (an unique ID is automatically created).
=#
function add!(g::StaticGraph, N::GraphNode)
    ID = generateID()
    g[ID] = N
    return ID
end

#=
Append a node to the node ID in a graph
=#
function append!(g::StaticGraph, ID, n::GraphNode)
    nID = add!(g, n)
    addChild!(g[ID], nID)
    setParent!(g[nID], ID)
    return nID
end

#=
Append a graph to the node ID in a graph. The insertion point of the final graph
is the insertion point of the appended graph
=#
function append!(g::StaticGraph, ID, gn::StaticGraph)
    # Transfer nodes to the receiving graph
    for (key,val) in nodes(gn)
        g[key] = val
    end
    addChild!(g[ID], root(gn))
    setParent!(g[root(gn)], ID)
    return insertion(gn)
end


################################################################################
#######################  StaticGraph construction DSL  ###############################
################################################################################

function +(n1::GraphNode, n2::GraphNode)
    g = StaticGraph(n1)
    nID = append!(g, insertion(g), n2)
    updateInsertion!(g, nID)
    return g
end

"""
    +(n1::Node, n2::Node)

Creates a graph with two nodes where `n1` is the root and `n2` is the insertion point.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + B1(1)
    draw(axiom)
end
```
"""
+(n1::Node, n2::Node) = GraphNode(n1) + GraphNode(n2)


function +(g::StaticGraph, n::GraphNode)
    nID = append!(g, insertion(g), n)
    updateInsertion!(g, nID)
    return g
end

"""
    +(g::StaticGraph, n::Node)

Creates a graph as the result of appending the node `n` to the insertion point of graph `g`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + B1(1)
    axiom = axiom + A1(2)
    draw(axiom)
end
```
"""
+(g::StaticGraph, n::Node) = g + GraphNode(n)

"""
    +(n::Node, g::StaticGraph)

Creates a graph as the result of appending the static graph `g` to the node `n`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + B1(1)
    axiom = A1(2) + axiom
    draw(axiom)
end
```
"""
+(n::Node, g::StaticGraph) = GraphNode(n) + g
+(n::GraphNode, g::StaticGraph) = StaticGraph(n) + g

"""
    +(g1::StaticGraph, g2::StaticGraph)
    
Creates a graph as the result of appending `g2` to the insertion point of `g1`. 
The insertion point of the final graph corresponds to the insertion point of `g2`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom1 = A1(1) + B1(1)
    axiom2 = A1(2) + B1(2)
    axiom = axiom1 + axiom2
    draw(axiom)
end
```
"""
function +(g1::StaticGraph, g2::StaticGraph)
    nID = append!(g1, insertion(g1), g2)
    updateInsertion!(g1, insertion(g2))
    return g1
end


@unroll function +(g::StaticGraph, T::Tuple)
    ins = insertion(g)
    @unroll for el in T
        g += el
        updateInsertion!(g, ins)
    end
    return g
end

+(n::GraphNode, T::Tuple) = StaticGraph(n) + T

"""
    +(g::StaticGraph, T::Tuple)
    +(n::Node, T::Tuple)

Creates a graph as the result of appending a tuple of graphs/nodes `T` to the
insertion point of the graph `g` or node `n`. Each graph/node in `L` becomes a 
branch.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    draw(axiom)
end
```
"""
+(n::Node, T::Tuple) = GraphNode(n) + T
