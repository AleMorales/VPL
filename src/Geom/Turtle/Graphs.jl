### This file contains public API ###

"""
    feedgeom!(turtle::MTurtle, m::Mesh)

General purpose method to feed a mesh to a turtle. Note that all primitives 
provided by VPL are implemented as meshes, but this is a generic method for 
meshes that are constructed directly by the user or imported from external
software.
"""
function feedgeom!(turtle::MTurtle, m::Mesh) 
    push!(geoms(turtle), m)
    push!(nvertices(turtle), nvertices(m))
    push!(ntriangles(turtle), ntriangles(m))
end

"""
    feedgeom!(turtle::MTurtle, node::Node)
    
Default method for `feedgeom!()` that does not do anything. This allows the user
to include nodes in a graph without an associated geometry.
"""
feedgeom!(turtle::MTurtle, node::Node) = nothing

#=
# Traverse the graph depth-first starting at the root node and execute the 
feedgeom!() function at each node. The state of the turtle is stored before each
branching point by inserting a new SET node. This allows resetting the turtle to 
the same position and orientation prior to entering each branch.
=#
"""
    feedgeom!(turtle::MTurtle, g::Graph)

Process a `Graph` object with a turtle and generate the corresponding 3D mesh 
from executing the different `feedgeom!()` methods associated to the nodes in 
the graph.
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

Feed a turtle an array or tuple of objects (`collection`) with existing 
`feedgeom!()` methods.
"""
function feedgeom!(turtle::MTurtle, collection::AbstractArray)
    for el in collection
      feedgeom!(turtle, el)
    end
    return nothing
end