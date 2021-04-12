### This file does not contain public API ###

#=
 Generate unique IDs for Nodes in graphs to avoid ID clashes when merging graphs
 This should be done in a thread-safe manner.
 This is required because graphs are created on right hand side of rules and then
 appended to an existing graph
=#
let ID = Threads.Atomic{Int}(0)
    global generateID
    global resetID
    function generateID()
        Threads.atomic_add!(ID,1) + 1
    end
    function resetID()
        ID = Threads.Atomic{Int}(0)
    end
end

################################################################################
########################  StaticGraph constructors  ############################
################################################################################

#=
    Facilitate construction of static graphs without having to use the DSL
=#
StaticGraph() = StaticGraph(Dict{Int, Any}(), Dict{DataType, Set{Int}}(), -1, -1)
function StaticGraph(n::GraphNode)
    ID = generateID()
    changeID!(n, ID)
    nlocal = copy(n)
    g = StaticGraph(Dict{Int, Any}(ID => nlocal), Dict(typeof(nlocal.data) =>  Set{Int}(ID)), ID, ID)
    return g
end
StaticGraph(n::Node) = StaticGraph(GraphNode(n))
StaticGraph(s::StaticGraph) = s

################################################################################
################################ Properties ####################################
################################################################################

#=
Nodetypes
=#
nodetypes(g) = g.nodetypes
hasNodetype(g::StaticGraph, T) = haskey(g.nodetypes, T)
function addNodetype!(g::StaticGraph, T, ID)
    !hasNodetype(g, T) && (g.nodetypes[T] = Set{Int}())
    push!(g.nodetypes[T], ID)
end
function removeNodetype!(g::StaticGraph, T, ID)
    delete!(g.nodetypes[T], ID)
end

#=
Root
=#
root(g::StaticGraph) = g.root
updateRoot!(g, ID) = g.root = ID
rootNode(g) = g[g.root]

#=
Insertion
=#
insertion(g::StaticGraph) = g.insertion
updateInsertion!(g, ID) = g.insertion = ID
insertionNode(g) = g[g.insertion]

#=
GraphNode
=#
nodes(g) = g.nodes
hasNode(g::StaticGraph, ID) = haskey(g.nodes, ID)
length(g::StaticGraph) = length(g.nodes)
removeNode!(g::StaticGraph, ID) = delete!(g.nodes, ID)

#=
  Extracting and adding a node to a graph
  When adding a node to a graph:
    Update the nodetypes list if the GraphNode introduces a new data type into the graph
    Copy the node rather than keeping a reference to it (the user data is not copied)
=#
getindex(g::StaticGraph, ID::Int) = g.nodes[ID]
function setindex!(g::StaticGraph, n::GraphNode{T}, ID) where T
    cn = copy(n)
    g.nodes[ID] = cn
    changeID!(cn, ID)
    addNodetype!(g, T, ID)
    return nothing
end

# Empty a graph
function empty!(g::StaticGraph)
    empty!(g.nodes)
    empty!(g.nodetypes)
    return nothing
end
