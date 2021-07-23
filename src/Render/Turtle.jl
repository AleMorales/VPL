
# Turtle that stores colors as it traverses the graph
Base.@kwdef mutable struct GLTurtle{C <: Colorant} <: Turtle
    colors::Vector{C} = RGB[]
end

colors(turtle::GLTurtle) = turtle.colors

# Method to store a color in the GLTurtle
feedcolor!(turtle::GLTurtle, color::Colorant) = push!(turtle.colors, color)
feedcolor!(turtle::GLTurtle, node::Node) = nothing
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
