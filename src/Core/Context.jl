### This file contains public API ###


################################################################################
################################## Getters #####################################
################################################################################

# Return the node stored in the context (a GraphNode)
node(c::Context) = c.node

"""
    data(c::Context)

Returns the data stored in a node. Intended to be used within a rule or query. 
"""
data(c::Context) = data(node(c))

# Return the Graph and StaticGraph stored inside the Context object
graph(c::Context) = c.graph
sgraph(c::Context) = graph(c.graph)

"""
    vars(c::Context)

Returns the graph-level variables. Intended to be used within a rule or query. 
"""
vars(c::Context) = vars(graph(c))

# This is needed to traverse graphs within rules
id(c::Context) = selfID(node(c))

################################################################################
################################## Queries #####################################
################################################################################

"""
    hasParent(c::Context)

Check if a node has a parent and return `true` or `false`. Intended to be used 
within a rule or query. 
"""
hasParent(c::Context) = hasParent(node(c))

"""
    isRoot(c::Context)

Check if a node is the root of the graph (i.e., has no parent) and return `true` or 
`false`. Intended to be used within a rule or query. 
"""
isRoot(c::Context) = !hasParent(c)

"""
    hasAncestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))

Check if a node has an ancestor that matches the condition. Intended to be used within 
a rule or query. 

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.
- `condition`: An user-defined function that takes a `Context` object as input 
and returns `true` or `false`. It is assigned by the user by keyword.
- `maxlevel::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
This function traverses the graph from the node associated to `c` towards the 
root of the graph until a node is found for which `condition` returns `true`. If
no node meets the condition, then it will return `false`. The defaults values 
for this function are such that the algorithm always returns `true` 
after one step (unless it is applied to the root node) in which case it is 
equivalent to calling `hasParent` on the node.

The number of levels that the algorithm is allowed to traverse is capped by
`maxlevel` (mostly to avoid excessive computation, though the user may want to
specify a meaningful limit based on the topology of the graphs being used).

The function `condition` should take an object of type `Context` as input and
return `true` or `false`.

## Return
Return a tuple with two values a `Bool` and an `Int`, the boolean indicating 
whether the node has an ancestor meeting the condition, the integer indicating 
the number of levels in the graph separating the node an its ancestor.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    function qfun(n)
        hasAncestor(n, condition = x -> data(x).val == 1)[1]
    end
    Q1 = Query(A1, query = qfun)
    R1 = apply(g, Q1)
    Q2 = Query(B1, query = qfun)
    R2 = apply(g, Q2)
    (R1,R2)
end
```
"""
function hasAncestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
    hasAncestor(node(c), graph(c), condition, maxlevel, 1)
end


"""
    hasChildren(c::Context)

Check if a node has at least one child and return `true` or `false`. Intended to be used
within a rule or query. 
"""
hasChildren(c::Context) = hasChildren(node(c))

"""
    isLeaf(c::Context)

Check if a node is a leaf in the graph (i.e., has no children) and return `true` or 
`false`. Intended to be used within a rule or query. 
"""
isLeaf(c::Context) = !hasChildren(c)

"""
    hasDescendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))

Check if a node has a descendent that matches the optional condition. Intended to be used 
within a rule or query. 

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.
- `condition`: An user-defined function that takes a `Context` object as input 
and returns `true` or `false`. It is assigned by the user by keyword.
- `maxlevel::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
This function traverses the graph from the node associated to `c` towards the 
leaves of the graph until a node is found for which `condition` returns `true`. 
If no node meets the condition, then it will return `false`. The defaults values 
for this function are such that the algorithm always returns `true` 
after one step (unless it is applied to a leaf node) in which case it is 
equivalent to calling `hasChildren` on the node.

The number of levels that the algorithm is allowed to traverse is capped by
`maxlevel` (mostly to avoid excessive computation, though the user may want to
specify a meaningful limit based on the topology of the graphs being used).

The function `condition` should take an object of type `Context` as input and
return `true` or `false`.

## Return
Return a tuple with two values a `Bool` and an `Int`, the boolean indicating 
whether the node has an ancestor meeting the condition, the integer indicating 
the number of levels in the graph separating the node an its ancestor.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    function qfun(n)
        hasDescendent(n, condition = x -> data(x).val == 1)[1]
    end
    Q1 = Query(A1, query = qfun)
    R1 = apply(g, Q1)
    Q2 = Query(B1, query = qfun)
    R2 = apply(g, Q2)
    (R1,R2)
end
```
"""
function hasDescendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
    hasDescendent(node(c), graph(c), condition, maxlevel, 1)
end

################################################################################
################################## Retrieve ####################################
################################################################################

"""
    parent(c::Context; nsteps::Int)

Returns the parent of a node that is `nsteps` away towards the root of the graph.
Intended to be used within a rule or query. 

## Details
If `hasParent()` returns `false` for the same node or the algorithm has reached
the root node but `nsteps` have not been reached, then `parent()` will return 
`missing`, otherwise it returns the `Context` associated to the matching node.

## Return
Return a `Context` object or `missing`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    function qfun(n)
        np = parent(n, nsteps = 2)
        !ismissing(np) && data(np).val == 2
    end
    Q1 = Query(A1, query = qfun)
    R1 = apply(g, Q1)
    Q2 = Query(B1, query = qfun)
    R2 = apply(g, Q2)
    (R1,R2)
end
```
"""
function parent(c::Context; nsteps::Int = 1)
    Context(graph(c), parent(node(c), graph(c), nsteps))
end

"""
    ancestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))

Returns the first ancestor of a node that matches the `condition`. Intended to be 
used within a rule or query. 

## Details
If `hasAncestor()` returns `false` for the same node and `condition`, `ancestor()`
will return `missing`, otherwise it returns the `Context` associated to the 
matching node

## Return
Return a `Context` object or `missing`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    function qfun(n)
        na = ancestor(n, condition = x -> (data(x).val == 1))
        if !ismissing(na)
            data(na) isa B1
        else
            false
        end
    end
    Q1 = Query(A1, query = qfun)
    R1 = apply(g, Q1)
    Q2 = Query(B1, query = qfun)
    R2 = apply(g, Q2)
    (R1,R2)
end
```
"""
function ancestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
    anc = ancestor(node(c), graph(c), condition, maxlevel, 1)
    Context(graph(c), anc)
end

"""
    children(c::Context)

Returns all the children of a node as `Context` objects.
"""
function children(c::Context)
    Tuple(Context(graph(c), child) for child in children(node(c), graph(c)))
end

"""
    descendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))

Returns the first descendent of a node that matches the `condition`. Intended to 
be used within a rule or query. 

## Details

If `hasDescendent()` returns `false` for the same node and `condition`, 
`descendent()` will return `missing`, otherwise it returns the `Context` 
associated to the matching node.

## Return
Return a `Context` object or `missing`.

## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    function qfun(n)
        na = descendent(n, condition = x -> (data(x).val == 1))
        if !ismissing(na)
            data(na) isa B1
        else
            false
        end
    end
    Q1 = Query(A1, query = qfun)
    R1 = apply(g, Q1)
    Q2 = Query(B1, query = qfun)
    R2 = apply(g, Q2)
    (R1,R2)
end
```
"""
function descendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
    desc = descendent(node(c), graph(c), condition, maxlevel, 1)
    Context(graph(c), desc)
end
