### This file DOES NOT contain public API ###

################################################################################
############################### Constructors ###################################
################################################################################

GraphNode(data) = GraphNode(data, Set{Int}(), missing, -1)

################################################################################
################################## Getters #####################################
################################################################################

data(n::GraphNode) = n.data
parentID(n::GraphNode) = n.parentID
childrenID(n::GraphNode) = n.childrenID
selfID(n::GraphNode) = n.selfID

################################################################################
################################## Setters #####################################
################################################################################

# The methods taking Missing as input are needed to simply operations on root nodes

setParent!(n::GraphNode, id) = n.parentID = id
removeParent!(n::GraphNode) = n.parentID = missing
removeChild!(n::GraphNode, id) = delete!(n.childrenID, id)
addChild!(n::GraphNode, id) = push!(n.childrenID, id)
changeID!(n::GraphNode, id::Int) = n.selfID = id

################################################################################
################################## Queries #####################################
################################################################################

#=
 Check if GraphNode has a parent or a ancestor that fits a query with optional
 recursive search (with maximum depth)
=#
hasParent(n::GraphNode) = !ismissing(n.parentID)
isRoot(n::GraphNode) = !hasParent(n)

function hasAncestor(node::GraphNode, g::Graph, condition, maxlevel::Int,
                     level::Int = 1)                 
    root(g) == selfID(node) && return false, level
    par = parent(node, g)
    if condition(Context(g, par))
        return true, level
    else
        if level < maxlevel
            check, steps = hasAncestor(par, g, condition, maxlevel, level + 1)
            check && return true, steps
        end
    end
    return false, level
end

#=
 Check if GraphNode has a child or a descendent that fits a condition with optional
 recursive search (with maximum depth)
=#
hasChildren(n::GraphNode) = !isempty(n.childrenID)
isLeaf(n::GraphNode) = !hasChildren(n)

function hasDescendent(node::GraphNode, g::Graph, condition, maxlevel::Int,
                       level::Int = 1)
    for child in children(node, g)
        if condition(Context(g, child))
            return true, level
        else
            if level <= maxlevel
                if hasDescendent(child, g, condition, maxlevel, level + 1)[1]
                    return true, level + 1
                end
            end
        end
    end
    return false, 0
end


################################################################################
################################## Retrieve ####################################
################################################################################

#=
 Retrieve the parent GraphNode or an ancestor that fits a query with optional
 recursive search (with maximum depth)
=#
function parent(n::GraphNode, g::Graph, nsteps::Int = 1)
    isRoot(n) && (return missing) 
    if(nsteps == 1)
        g[parentID(n)]
    else
        ancestor(n, g, x -> false, nsteps)
    end
end

# This method is useful for pruning and other static graph operations
function parent(n::GraphNode, g::StaticGraph) 
     g[parentID(n)]
end

function ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int,
                  level::Int = 1)
    isRoot(node) && (return missing)
    par = parent(node, g)
    if condition(Context(g, par))
        return par
    elseif level < maxlevel
        return ancestor(par, g, condition, maxlevel, level + 1)
    end
    return par # A neat trick to select an ancestor nsteps away (used by parent)
end


#=
 Retrieve the children GraphNode or a descendent that fits a condition with optional
 recursive search (with maximum depth)
=#
children(n::GraphNode, g::StaticGraph) = (g[id] for id in childrenID(n))

function descendent(node::GraphNode, g::Graph, condition, maxlevel::Int,
                    level::Int = 1)
    for child in children(node, g)
        if condition(Context(g, child))
            return child
        elseif level <= maxlevel
                return descendent(child, g, condition, maxlevel, level + 1)
        end
    end
    return missing # This means we tested on a leaf node
end


################################################################################
#################################### Copy ######################################
################################################################################

#=
    copy(n::GraphNode)
Creates a new GraphNode with the same contents as `n`. A reference to the data is kept,
but childrenID and parentID are copied. This necessary for rules that reuse a node
on the right hand side
=#
copy(n::GraphNode) = GraphNode(n.data, copy(childrenID(n)), parentID(n), selfID(n))
