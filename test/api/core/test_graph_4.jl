using VPL
using Test
include("types.jl")
import .GT


let
# Cell transfer top to bottom
function transferDown(context)
    if hasAncestor(context, x -> data(x) isa GT.ACell)[1]
        return (true, (ancestor(context, x -> data(x) isa GT.ACell), ))
    else
        return (false, ())
    end
end

# Cell transfer bottom to top

function transferUp(context)
    if hasDescendent(context, x -> data(x) isa GT.CCell)
        return (true, (descendent(context, x -> data(x) isa GT.CCell), ))
    else
        return (false, ())
    end
end

ruleDown = Rule(GT.CCell, lhs = transferDown, rhs = (context, anc) ->
                    GT.CCell(data(anc).state), captures = true)
ruleUp = Rule(GT.ACell, lhs = transferUp, rhs = (context, anc) ->
                    GT.ACell(data(anc).state), captures = true)


axiom = GT.ACell(1) + GT.BCell(2) + GT.CCell(3)
pop = Graph(axiom, rules = (ruleDown, ruleUp))
@test apply(pop, Query(GT.ACell))[1].state == 1
@test apply(pop, Query(GT.CCell))[1].state == 3
@test apply(pop, Query(GT.BCell))[1].state == 2

# Rewriting this graph should flip the values of the ACell and CCell
rewrite!(pop)
@test apply(pop, Query(GT.ACell))[1].state == 3
@test apply(pop, Query(GT.CCell))[1].state == 1
@test apply(pop, Query(GT.BCell))[1].state == 2

end
