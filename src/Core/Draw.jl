### This file contains public API ###

"""
    node_label(n::Node, id)

Function to construct a label for a node to be used by `draw()` when visualizing.
The user can specialize this method for user-defined data types to customize the 
labels. By default, the type of data stored in the node and the unique ID of the
node are used as labels.
"""
function node_label(n::Node, id)
    node_class = split("$(typeof(n))", ".")[end]
    label = "$node_class-$(id)"
    return label
end

#=
Translate a static graph in a DiGraph to be used by GraphMakie. Nodes are 
labelled, edges are not. The translation extracts the topological relationships 
among nodes and the result of applying `node_label` to each node.
=#
function GR.DiGraph(g::StaticGraph)
    # Create a DiGraph structure
    n  = length(g)
    dg = GR.DiGraph(n)
    # Connect ids in original graph to new ids but make sure the root
    # node is at the beginning
    ids = nodes(g) |> keys |> collect
    rid = root(g)
    posroot = findfirst(i -> i == rid, ids)
    ids = vcat(rid, ids[1:posroot-1], ids[posroot+1:end])
    map_ids = Dict((ids[i], i) for i in 1:n)
    # Create label for each node (user can modify behavior)
    labels = [node_label(data(g[id]), id) for id in ids]
    # Update the digraph with information collected in the above
    for (key, val) in nodes(g)
        children = childrenID(val)
        if length(children) > 0
            for child in children
                GR.add_edge!(dg, map_ids[key], map_ids[child])
            end
        end
    end
    # Return the DiGraph structure and the associated labels
    return dg, labels, n
end

# Forward the DiGraph method of StaticGraph onto Graph
GR.DiGraph(g::Graph) = GR.DiGraph(g.graph)

# Choose which Makie backend to use for the visualization
# Note November 2022: The inline! option has been turned off in Makie, but a new
# solution may be available in the future
function choose_backend(backend, inline)
    if backend == "native"
        GLMakie.activate!()
#       GLMakie.inline!(inline)
    elseif backend == "web"
        WGLMakie.activate!()     
    elseif backend == "vector"
        CairoMakie.activate!()           
    else
        error("Unknown backend, please use of the following: \"default\", \"native\", \"web\" or \"vector\"")
    end
end

"""
    draw(g::StaticGraph; force = false, backend = "native", inline = false, 
         resolution = (1920, 1080), nlabels_textsize = 15, arrow_size = 15, 
         node_size = 5)

Equivalent to the method `draw(g::Graph; kwargs...)` but  to visualize static 
graphs (e.g., the axiom of a graph).
"""
function draw(g::StaticGraph; force = false, backend = "native", inline = false, resolution = (1920, 1080),
              nlabels_textsize = 15, arrow_size = 15, node_size = 5)

    force && inline && error("Cannot set force and inline to true at the same time")

    # Select backend and activate it
    choose_backend(backend, inline)

    # Create the digraph
    dg, labels, n = GR.DiGraph(g)

    if n == 1
        println("The graph only has one node, so no visualization was made")
        return nothing
    end

    # Generate the visualization
    nlabels_align = [(:left, :bottom) for _ in 1:n]
    f, ax, p = GM.graphplot(dg, 
                layout = NL.Buchheim(),
                nlabels = labels,
                nlabels_distance = 5,
                nlabels_textsize = nlabels_textsize,
                nlabels_align = nlabels_align,
                arrow_size = arrow_size,
                node_size = node_size,
                figure = (resolution = resolution,))

    # Make it look prettier
    GM.hidedecorations!(ax);
    GM.hidespines!(ax);
    ax.aspect = GM.DataAspect()

    # This forces the display of the figure (may be needed in some environments)
    force && display(f)

    # Return the figure object (rely on the context to display it)
    f
end

"""
    draw(g::Graph; force = false, backend = "native", inline = false, 
         resolution = (1920, 1080), nlabels_textsize = 15, arrow_size = 15, 
         node_size = 5)

Visualize a graph as network diagram.

## Arguments
All arguments are assigned by keywords except the graph `g`.  
- `g::Graph`: The graph to be visualized.  
- `force = false`: Force the creation of a new window to store the network 
diagram.  
- `backend = "native"`: The graphics backend to render the network diagram. It
can have the values `"native"`, `"web"` and `"vector"`. See VPL documentation
for details.  
- `inline = false`: Currently this argument does not do anything (will change in
future versions of VPL).  
- `resolution = (1920, 1080)`: The resolution of the image to be rendered, in
pixels (online relevant for native and web backends). Default resolution is HD. 
- `nlabels_textsize = 15`: Customize the size of the labels in the diagram.  
- `arrow_size = 15`: Customize the size of the arrows representing edges in the
diagram.  
- `node_size = 5`: Customize the size of the nodes in the diagram.  

## Details

By default, nodes are labelled with the type of data stored and their unique ID.
See function `node_label()` to customize the label for different types of data.

See `export_graph()` to export the network diagram as a raster or vector image
(depending on the backend). The function `calculate_resolution()` can be useful
to ensure a particular dpi of the exported image (assuming some physical size).

The graphics backend will interact with the environment where the Julia code is
being executed (i.e., terminal, IDE such as VS Code, interactive notebook such
as Jupyter or Pluto). These interactions are all controlled by the graphics 
package Makie that VPL relies on. Some details on the expected behavior specific
to `draw()` can be found in the general VPL documentation as www.virtualplantlab.com

## Return
This function returns a Makie `Figure` object, while producing the visualization
as a side effect.


## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    draw(g)
end
```
"""
function draw(g::Graph; force = false, backend = "native", inline = false, resolution = (1920, 1080),
    nlabels_textsize = 15, arrow_size = 15, node_size = 5)
    draw(g.graph; force = force, backend = backend, inline = inline, resolution = resolution, 
         nlabels_textsize = nlabels_textsize, arrow_size = arrow_size, node_size = node_size)
end

"""
    export_graph(f; filename, kwargs...)

Save a network diagram generated by `draw()` to an external file.

## Arguments
- `f`: Object of type `Figure` return by `draw()`.
- `filename`: Name of the file where the diagram will be stored. The extension 
will be used to determined the format of the image (see example below).

## Details
Internally, `export_graph()` calls the `save()` method from the ImageIO package
and its dependencies. Any keyword argument supported by the relevant save method 
will be passed along by `export_graph()`. For example, exporting diagrams as PNG 
allows defining the compression level as `compression_level` (see PNGFiles 
package for details).

## Return
The function returns nothing but, if successful, it will generate a new file
containing the network diagram in the appropiate format.

## Examples
## Examples
```julia
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    f = draw(g);
    export_graph(f, filename = "test.png")
end
```
"""
function export_graph(f; filename, kwargs...)
    FileIO.save(filename, f; kwargs...) 
end

"""
    calculate_resolution(;width = 1024/300*2.54, height = 768/300*2.54, 
                          format = "raster", dpi = 300)

Calculate the resolution required to achieve a specific `width` and `height` 
(in cm) of the exported image, with a particular `dpi` (for raster formats).
"""
function calculate_resolution(;width = 1024/300*2.54, height = 768/300*2.54, 
                              format = "png", dpi = 300)
    if format == "raster"
        res_width = width/2.54*dpi
        res_height = height/2.54*dpi
        (res_width, res_height)
    else
        res_width = width/2.54*72/0.75
        res_height = height/2.54*72/0.75
        (res_width, res_height)
    end
end