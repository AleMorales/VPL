
"""
    node_label(n::Node, id)

Function that constructs a label for a node to be used by `draw()` when visualizing the graph 
as a network. The default method will create a label from the type of node its unique id. The
user can specialize this method for user-defined data types to customize the label.
"""
function node_label(n::Node, id)
    node_class = split("$(typeof(n))", ".")[end]
    label = "$node_class-$(id)"
    return label
end

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

GR.DiGraph(g::Graph) = GR.DiGraph(g.graph)

# Choose which Makie backend to use
function choose_backend(backend, inline)
    if backend == "native"
        GLMakie.activate!()
        GLMakie.inline!(inline)
    elseif backend == "web"
        WGLMakie.activate!()     
    elseif backend == "vector"
        CairoMakie.activate!()           
    else
        error("Unknown backend, please use of the following: \"default\", \"native\", \"web\" or \"vector\"")
    end
end

"""
    draw(g::StaticGraph; force = false, backend = "native", inline = false)

Visualize a graph as a network using different backends (`native` for OpenGL, `web` for WebGL and `vector` for Cairo
vector graphics, see VPL documentation for details). To force an external window when using the native backend set
`force = true` whereas to force to be inlined use `inline = true`. Details on the behaviour of each backend on different
contexts of code execution can be found in the VPL documentation. For backend `native` or `web`, the user may specify the 
resolution in pixels (by default HD is used).

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

draw(g::Graph; kwargs...) = draw(g.graph; kwargs...)

"""
    export_graph(f, filename)

Export a graph visualization (created by `draw()`) into an external file. Supported formats are
png (if the `native` or `web` backends were used in `draw()`), pdf or svg (if the `vector` backend
was used). The file name should include the extension from which the format will be inferred.
"""
function export_graph(f, filename)
    FileIO.save(filename, f) 
end

"""
    calculate_resolution(width, height; format = "png", dpi = 300)

Calculate the resolution required to achieve a specific `width` and `height` (in cm) of the exported
image, with a particular `dpi` (for png format).
"""
function calculate_resolution(width, height; format = "png", dpi = 300)
    if format == "png"
        res_width = width/2.54*dpi
        res_height = height/2.54*dpi
        (res_width, res_height)
    else
        res_width = width/2.54*72/0.75
        res_height = height/2.54*72/0.75
        (res_width, res_height)
    end
end