
"""
    RTTurtle()

Create a `RTTurtle()` object that will parse a `Graph` object and store the materials
associated to the different primitives. This type of turtle is automatically created
by calls to `RTScene()` but the user may want to separately construct the geometry and 
materials and manually combine them into a `RTScene` object for performance reasons.
"""
Base.@kwdef mutable struct RTTurtle{M <: Material} <: Turtle
    materials::Vector{M} = Material[]
end

"""
    materials(turtle)

Extract the array of materials stored inside a `RTTurtle` object.
"""
materials(turtle::RTTurtle) = turtle.materials

"""
    feedmaterial!(turtle::RTTurtle, material::Material)

General purpose method to feed a material to a RT turtle. This should be used inside
user's defined methods to add the material object with optical properties associated
to the primitive.
"""
feedmaterial!(turtle::RTTurtle, material::Material) = push!(materials(turtle), material)

"""
    feedmaterial!(turtle::RTTurtle, node::Node)
    
Default method for `feedmaterial!()` that does not do anything. Hence, the user can include nodes
in a graph withour associated colors (the nodes should not generate geometry either).
"""
feedmaterial!(turtle::RTTurtle, node::Node) = nothing

"""
    feedmaterial!(turtle::RTTurtle, g::Graph)

Process a `Graph` object with a RT turtle and collect the materials defined in the graph, in 
the same order in which the 3D mesh is created by the corresponding `feedgeom!()` method.
"""
function feedmaterial!(turtle::RTTurtle, g::Graph)
  # Use a LIFO stack to keep track of nodes in traversal
  nodeStack = GraphNode[]
  push!(nodeStack, g[root(g)])
  # Iterate over all nodes in the graph
  while(length(nodeStack) > 0)
      # Always process geometry from the last node
      node = pop!(nodeStack)
      feedmaterial!(turtle, node.data)
      # Add the children to the stack (if any) + extra node to reset the turtle
      for child in children(node, g)
          push!(nodeStack, child)
      end
  end
  return nothing
end


@unroll function feedmaterial!(turtle::RTTurtle, collection::Tuple)
    @unroll for el in collection
      feedmaterial!(turtle, el)
    end
    return nothing
end

"""
    feedmaterial!(turtle::RTTurtle, collection::AbstractArray)
    feedmaterial!(turtle::RTTurtle, collection::Tuple)

Feed a RT turtle an array or tuple of objects (`collection`) with existing `feedmaterial!()` methods.
"""
function feedmaterial!(turtle::RTTurtle, collection::AbstractArray)
    for el in collection
      feedmaterial!(turtle, el)
    end
    return nothing
end
