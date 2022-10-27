

"""
    feedgeom!(turtle::MTurtle, m::Mesh)

General purpose method to feed a mesh to a turtle. This should be used to add any generated
primitive to the turtle's mesh as they are all implemented as meshes
"""
function feedgeom!(turtle::MTurtle, m::Mesh) 
    push!(geoms(turtle), m)
    push!(nvertices(turtle), nvertices(m))
    push!(ntriangles(turtle), ntriangles(m))
end

"""
    feedgeom!(turtle::MTurtle, node::Node)
    
Default method for `feedgeom!()` that does not do anything. Hence, the user can include nodes
in a graph withour an associated geometry.
"""
feedgeom!(turtle::MTurtle, node::Node) = nothing

# Traverse the graph depth-first starting at the root node and execute the feedgeom!() function at each
# node. The state of the turtle is stored before each branching point by inserting a new SET node. This
# allows resetting the node to the same position and orientation prior to entering each branch.
"""
    feedgeom!(turtle::MTurtle, g::Graph)

Process a `Graph` object with a turtle and generate the corresponding 3D mesh from the turtle movement
operations and geometry primitives or meshes defined in the graph.
"""
function feedgeom!(turtle::MTurtle, g::Graph)
    # Use a LIFO stack to keep track of nodes in traversal
    nodeStack = GraphNode[]
    push!(nodeStack, g[root(g)])
    # Iterate over all nodes in the graph
    while(length(nodeStack) > 0)
        # Always process geometry from the last node
        node = pop!(nodeStack)
        feedgeom!(turtle, node.data)
        # Add the children to the stack (if any) + extra node to reset the turtle
        nchildren = length(children(node, g))
        if nchildren > 0
            if nchildren == 1
                push!(nodeStack, first(children(node, g)))
            else
                for child in children(node, g)
                    push!(nodeStack, GraphNode(SET(to = pos(turtle), head = head(turtle), up = up(turtle), arm = arm(turtle))))
                    push!(nodeStack, child)
                end
            end
        end
    end
    return nothing
end
  
@unroll function feedgeom!(turtle::MTurtle, collection::Tuple)
    @unroll for el in collection
      feedgeom!(turtle, el)
    end
    return nothing
end

"""
    feedgeom!(turtle::MTurtle, collection::AbstractArray)
    feedgeom!(turtle::MTurtle, collection::Tuple)

Feed a turtle an array or tuple of objects (`collection`) with existing `feedgeom!()` methods.
"""
function feedgeom!(turtle::MTurtle, collection::AbstractArray)
    for el in collection
      feedgeom!(turtle, el)
    end
    return nothing
end