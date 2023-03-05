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
    function VPL.feed!(turtle::Turtle, i::btree.Internode, vars)
        # All vertices share the same color
        if turtle.message == :green
            HollowCube!(turtle, length = i.length, height = i.length/10, 
            width = i.length/10, move = true, color = RGB(0,1,0))
        # Each vertex has a different color
        else
            HollowCube!(turtle, length = i.length, height = i.length/10, 
            width = i.length/10, move = true, 
            color = rand(RGB, 8))
        end
        return nothing
    end
    rule = Rule(btree.Meristem, rhs = mer -> btree.Node() + 
                (RU(-60.0) + btree.Internode(0.1) + RH(90.0) + btree.Meristem(), 
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
    render(newtree, message = :green)
    render(newtree, message = :all)
end