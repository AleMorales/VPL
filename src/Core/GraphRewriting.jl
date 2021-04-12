### This file does not contain public API ###

#=
Remove a GraphNode from a graph. Update the insertion and root points if necessary.
Optionally, neighbouring nodes are also updated to ensure a consistent graph
=#
function remove!(g::StaticGraph, ID)
    node = g[ID]
    # Update root, insertion and, optionally, edges from neighbouring nodes
    if length(g) > 1
        # Remove the node from nodes and nodetypes
        removeNodetype!(g, typeof(node.data), ID)
        removeNode!(g, ID)
        return nothing
    else
        empty!(g)
        return nothing
    end
end


#=
Remove a node from a graph and all of its descendants. The root or insertion point of the graph will be
updated if required. The edges from other nodes will always be updated. The
algorith actually starts from the leaf nodes and works its way back to the pruning
node.
=#
function prune!(g::StaticGraph, ID)
    node = g[ID]
    if length(g) == 1 || root(g) == ID
        empty!(g)
        return nothing
    elseif insertion(g) != ID
        for childID in childrenID(node)
            prune!(g, childID)
        end
    end
    # Remove edges from parent
    removeChild!(parent(node, g), ID)
    # Remove the actual node
    remove!(g, ID)
    return nothing
end

#=
Replace a node in a graph by a new node.
=#
function replace!(g::StaticGraph, ID, n::GraphNode)
    old = g[ID]
    # Transfer parents from the old to the new node
    setParent!(n, parentID(old))
    # Transfer children from the old to the new node
    for child in childrenID(old)
        addChild!(n, child)
    end
    # Remove the old node from the graph without updating edges
    remove!(g, ID)
    # Add the new node to the graph with the old ID
    g[ID] = n
    return nothing
end


#=
Replace a node in a graph by a whole new subgraph
The root node of gn inherits the ID and parents of the old node.
The insertion node of gn inherits the children of the old node.
The insertion node of gn will change if the replaced node was the insertion point
=#
function replace!(g::StaticGraph, ID::Int, gn::StaticGraph)

    # Extract node to be replaced and delete it from graph
    old = g[ID]
    remove!(g, ID)

    # Add all the nodes of subgraph to the graph
    for (key,val) in nodes(gn)
        g[key] = val
    end

    # Transfer parents of the old node to the root node of subgraph
    rootID = root(gn)
    if root(g) != ID
        pID = parentID(old)
        setParent!(g[rootID], pID)
        addChild!(g[pID], rootID)
        removeChild!(g[pID], ID)
    else
        updateRoot!(g, rootID)
    end

    # Transfer children of the old node to the insertion node of subgraph and update the children
    insID = insertion(gn)
    for childID in childrenID(old)
        addChild!(g[insID], childID)
        setParent!(g[childID], insID)
    end

    # Change insertion point if the insertion point is being replaced
    insertion(g) == ID && updateInsertion!(g, insID)

    return nothing
end

#=
Replace and append nodetypes into a graph by wrapping it inside a node.
=#
replace!(g::StaticGraph, ID, n::Node) = replace!(g, ID, GraphNode(n))

# Empty replacement means pruning
replace!(G::StaticGraph, ID, n::Nothing) = prune!(G, ID)
