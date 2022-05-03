
"""
    GLTurtle()

Create a `GLTurtle()` object that will parse a `Graph` object and store the colors
associated to the different primitives. This type of turtle is automatically created
by calls to `GLScene()` and `render()` but the user may want to separately construct the
geometry and colors and manually combined them into a `GLScene` object for performance reasons.
"""
Base.@kwdef mutable struct GLTurtle{C <: Colorant} <: Turtle
    colors::Vector{C} = RGB[]
end

"""
    colors(turtle)

Extract the array of colors stored inside an `GLTurtle` object
"""
colors(turtle::GLTurtle) = turtle.colors

"""
    feedcolor!(turtle::GLTurtle, color::Colorant)

General purpose method to feed a color to a GL turtle. This should be used inside
user's defined methods to add any color object that inherits from `Colorant` from
the package *Color*, for example, by using `RGB()`.
"""
feedcolor!(turtle::GLTurtle, color::Colorant) = push!(turtle.colors, color)

"""
    feedcolor!(turtle::GLTurtle, node::Node)
    
Default method for `feedcolor!()` that does not do anything. Hence, the user can include nodes
in a graph withour associated colors (the nodes should not generate geometry either).
"""
feedcolor!(turtle::GLTurtle, node::Node) = nothing

"""
    feedcolor!(turtle::GLTurtle, g::Graph)

Process a `Graph` object with a GL turtle and collect the colors defined in the graph, in the same
order in which the 3D mesh is created by the corresponding `feedgeom!()` method.
"""
function feedcolor!(turtle::GLTurtle, g::Graph)
  # Use a LIFO stack to keep track of nodes in traversal
  nodeStack = GraphNode[]
  push!(nodeStack, g[root(g)])
  # Iterate over all nodes in the graph
  while(length(nodeStack) > 0)
      # Always process geometry from the last node
      node = pop!(nodeStack)
      feedcolor!(turtle, node.data)
      # Add the children to the stack (if any) + extra node to reset the turtle
      for child in children(node, g)
          push!(nodeStack, child)
      end
  end
  return nothing
end

@unroll function feedcolor!(turtle::GLTurtle, collection::Tuple)
    @unroll for el in collection
      feedcolor!(turtle, el)
    end
    return nothing
end

"""
    feedcolor!(turtle::GLTurtle, collection::AbstractArray)
    feedcolor!(turtle::GLTurtle, collection::Tuple)

Feed a GL turtle an array or tuple of objects (`collection`) with existing `feedcolor!()` methods.
"""
function feedcolor!(turtle::GLTurtle, collection::AbstractArray)
    for el in collection
      feedcolor!(turtle, el)
    end
    return nothing
end
