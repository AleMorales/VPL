### This file contains public API ###


################################################################################
################################## Getters #####################################
################################################################################

# Return the node stored in the context (a GraphNode)
node(c::Context) = c.node

"""
    data(c::Context)

Returns the data stored in the node associated to a `Context` object. This needs
to be used inside rules and queries.
"""
data(c::Context) = data(node(c))

# Return the Graph and StaticGraph stored inside the Context object
graph(c::Context) = c.graph
sgraph(c::Context) = graph(c.graph)

"""
    vars(c::Context)

Returns the object storing the graph-level variables in the graph associated to 
a `Context` object. This needs to be used inside rules and queries.
"""
vars(c::Context) = vars(graph(c))

# This is needed to traverse graphs within rules
id(c::Context) = selfID(node(c))

################################################################################
################################## Queries #####################################
################################################################################

"""
    hasParent(c::Context)

Check if the node passed as argument has a parent and return `true` or `false`.
"""
hasParent(c::Context) = hasParent(node(c))

"""
    isRoot(c::Context)

Check if the node passed as argument is the root of the graph (i.e. has no parent) 
and return `true` or `false`.
"""
isRoot(c::Context) = !hasParent(c)

"""
    hasAncestor(c::Context, condition, maxlevel)

Check if the node passed as argument has an ancestor that matches the optional 
condition and and return `true` or `false` and the number of steps taken. 
The `argument` maxlevel is optional and limits the number of steps that the 
algorithm will move through the graph (by default
there is no limitation). The default condition returns `true` for any ancestor 
and it takes an object of type `Context`.
"""
function hasAncestor(c::Context, condition = x -> true, maxlevel::Int = typemax(Int))
    hasAncestor(node(c), graph(c), condition, maxlevel, 1)
end


"""
    hasChildren(c::Context)

Check if the node passed as argument has at least one child and return `true` or `false`.
"""
hasChildren(c::Context) = hasChildren(node(c))

"""
    isLeaf(c::Context)

Check if the node passed as argument is a leaf in the graph (i.e. has no children) 
and return `true` or `false`.
"""
isLeaf(c::Context) = !hasChildren(c)

"""
    hasDescendent(c::Context, condition, maxlevel)

Check if the node passed as argument has a descendent that matches the optional condition 
and return `true` or `false`. The argument `maxlevel` is optional and limits
the number of steps that the algorithm will move through the graph (by default
there is no limitation). The default condition returns `true` for any descendent 
and it takes an object of type `Context`.
"""
function hasDescendent(c::Context, condition = x -> true, maxlevel::Int = typemax(Int))
    hasDescendent(node(c), graph(c), condition, maxlevel, 1)
end

################################################################################
################################## Retrieve ####################################
################################################################################

"""
    parent(c::Context, nsteps::Int)

Returns a `Context` object associated to the parent of the node passed as first
argument (`nsteps = 1`, the default) or an ancestor that is `nsteps` away from
the node passed as first argument.
"""
function parent(c::Context, nsteps::Int = 1)
    Context(graph(c), parent(node(c), graph(c), nsteps))
end

"""
    ancestor(c::Context, condition, maxlevel)

Returns a `Context` object associated to the first ancestor of the node given as 
argument that matches the optional condition. The `argument` maxlevel is optional and limits
the number of steps that the algorithm will move through the graph (by default
there is no limitation). The matched node is returned as a `Context` object.
The default condition returns `true` for any ancestor and it takes an object of
type `Context`.
"""
function ancestor(c::Context, condition = x -> true, maxlevel::Int = typemax(Int))
    anc = ancestor(node(c), graph(c), condition, maxlevel, 1)
    Context(graph(c), anc)
end

"""
    children(c::Context)

Returns a tuple of `Context` objects with all the children of the node given as 
argument.
"""
function children(c::Context)
    Tuple(Context(graph(c), child) for child in children(node(c), graph(c)))
end

"""
    descendent(c::Context, condition, maxlevel)

Returns a `Context` object associated to the first descendent of the node given as 
argument that matches the optional condition. The argument `maxlevel` is optional and limits
the number of steps that the algorithm will move through the graph (by default
there is no limitation). The matched node is returned as a `Context` object.
The default condition returns `true` for any descendent and it takes an object of
type `Context`.
"""
function descendent(c::Context, condition = x -> true, maxlevel::Int = typemax(Int))
    desc = descendent(node(c), graph(c), condition, maxlevel, 1)
    Context(graph(c), desc)
end
