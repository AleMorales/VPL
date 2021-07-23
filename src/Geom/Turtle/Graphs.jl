
  
#=
feedgeom!(turtle::MTurtle, m::Mesh)
feedgeom!(turtle::MTurtle, node::Node)
feedgeom!(turtle::MTurtle, G::Graph)
feedgeom!(turtle::MTurtle, G::Tuple)
feedgeom!(turtle::MTurtle, G::AbstractArray)

Feed the turtle some geometry to make it nice and plump. `feedgeom!` should be
especialized for each type of node in order to generate the geometry of
a `Graph`. Functions associated to turtle operations and geometry
primitives provide healthy food for the turtle.
=# 
feedgeom!(turtle::MTurtle, m::Mesh) = push!(geoms(turtle), geom)
feedgeom!(turtle::MTurtle, node::Node) = nothing
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

function feedgeom!(turtle::MTurtle, collection::AbstractArray)
    for el in collection
      feedgeom!(turtle, el)
    end
    return nothing
end