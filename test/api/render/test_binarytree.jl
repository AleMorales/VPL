using VPL
using Test

module btree
    import VPL
    # Meristem
    struct Meristem <: VPL.Node end
    # Node
    struct Node <: VPL.Node end
    # Internode
    mutable struct Internode <: VPL.Node
        length::Float64
    end
    # Graph-level variables
    struct treeparams
        growth::Float64
    end
end


let 
    import .btree
    function VPL.feedgeom!(turtle::MTurtle, i::btree.Internode)
        HollowCube!(turtle, l = i.length, h = i.length/10, w = i.length/10, move = true)
        return nothing
    end
    function VPL.feedcolor!(turtle::GLTurtle, i::btree.Internode)
        feedcolor!(turtle, RGB(0,1,0))
        return nothing
    end
    rule = Rule(btree.Meristem, rhs = mer -> btree.Node() + (RU(-60.0) + btree.Internode(0.1) + RH(90.0) + btree.Meristem(), 
                                                   RU(60.0)  + btree.Internode(0.1) + RH(90.0) + btree.Meristem()))
    axiom = btree.Internode(0.1) + btree.Meristem()
    tree = Graph(axiom, Tuple(rule), btree.treeparams(0.5))
    getInternode = Query(btree.Internode)
    function elongate!(tree, query)
        for x in apply(tree, query)
            x.length = x.length*(1.0 + vars(tree).growth)
        end
    end
    function growth!(tree, query)
        elongate!(tree, query)
        rewrite!(tree)
    end
    function simulate(tree, query, nsteps)
        new_tree = deepcopy(tree)
        for i in 1:nsteps
            growth!(new_tree, query)
        end
        return new_tree
    end
    newtree = simulate(tree, getInternode, 2)
    render(newtree)
end