
function GR.DiGraph(g::Graph)
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
    node_classes = [split("$(typeof(data(g[id])))", ".")[end] for id in ids]
    labels = ["$(node_classes[i]) - $(ids[i])" for i in 1:n]
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


# Choose which Makie backend to use
function choose_backend(backend)
    if backend == "default"
        GLMakie.activate!()
    elseif backend == "native"
        GLMakie.activate!()
    elseif backend == "web"
        WGLMakie.activate!()     
    elseif backend == "static"
        CairoMakie.activate!()           
    else
        error("Unknown backend, please use of the following: \"default\", \"native\", \"web\" or \"static\"")
    end
end

# Draw a graph using GraphMakie
function draw(g::Graph; display = true, backend = "default")
    # Select backend and activate it
    choose_backend(backend)

    # Create the digraph
    dg, labels, n = GR.DiGraph(g)

    # Generate the visualization
    nlabels_align = [(:left, :bottom) for _ in 1:n]
    f, ax, p = GM.graphplot(dg, 
                layout = NL.Buchheim(),
                nlabels = labels,
                nlabels_distance = 5,
                nlabels_align = nlabels_align,
                tangents=((0,-1),(0,-1)),
                arrow_size = 15,
                node_color = [:black for i in 1:n])

    # Make it look prettier
    GM.hidedecorations!(ax);
    GM.hidespines!(ax);

    # Change relative position of labels
    for v in GR.vertices(dg)
        if isempty(GR.inneighbors(dg, v)) # root
            nlabels_align[v] = (:center,:bottom)
        elseif isempty(GR.outneighbors(dg, v)) #leaf
            nlabels_align[v] = (:center,:top)
        else
            self = p[:node_pos][][v]
            parent = p[:node_pos][][GR.inneighbors(dg, v)[1]]
            if self[1] < parent[1] # left branch
                nlabels_align[v] = (:right,:bottom)
            end
        end
    end
    p.nlabels_align = nlabels_align

    # Return all the objects for further processing if needed
    display && Base.display(f)
    f, ax, p
end