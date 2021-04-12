################################################################################
############################  StaticGraph traversal  #################################
################################################################################

"""
    traverse(g::Graph, f)

Iterates over all the nodes in the graph (in no particular order) and execute for
each node the function `f` taking as input the data stored in the node.
"""
traverse(g::Graph, f) = traverse(graph(g), f)
function traverse(g::StaticGraph, f)
    for val in values(nodes(g))
        f(data(val))
    end
end

"""
    traverseDFS(g::Graph, f)

Iterates over all the nodes in the graph (depth-first order, starting at the 
root of the graph) and execute for each node the function `f` taking as input the 
data stored in the node.
"""
traverseDFS(g::Graph, f) = traverseDFS(graph(g), f, root(g))

function traverseDFS(g::StaticGraph, f, ID)
    # Use LIFO stack to keep track of nodes in traversal
    nodeStack = Int[]
    push!(nodeStack, ID)
    # Iterate over all nodes in the graph
    while(length(nodeStack) > 0)
        # Always execute f on the last node added
        ID = pop!(nodeStack)
        f(data(g[ID]))
        # Add the children to the stack (if any)
        for childID in childrenID(g[ID])
            push!(nodeStack, childID)
        end
    end
end

"""
    traverseBFS(g::Graph, f)

Iterates over all the nodes in the graph (breadth-first order, starting at the 
root of the graph) and execute for each node the function `f` taking as input the 
data stored in the node.
"""
traverseBFS(g::Graph, f) = traverseBFS(graph(g), f, root(g))

function traverseBFS(g::StaticGraph, f, ID)
    # Use LIFO stack to keep track of nodes in traversal
    nodeStack = Int[]
    prepend!(nodeStack, ID)
    # Iterate over all nodes in the graph
    while(length(nodeStack) > 0)
        # Always execute f on the last node added
        ID = pop!(nodeStack)
        f(data(g[ID]))
        # Add the children to the stack (if any)
        for childID in childrenID(g[ID])
            prepend!(nodeStack, childID)
        end
    end
end