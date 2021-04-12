using VPL
using Test
include("types.jl")
import .GT

let

# Cell transfer top to bottom
function transfer(context)
    if hasParent(context)
        return (true, (parent(context), ))
    else
        return (false, ())
    end
end

rule = Rule(GT.Cell{Int}, lhs = transfer, rhs = (context, father) ->
                    GT.Cell(data(father).state), captures = true)
@test VPL.Core.captures(rule)

axiom = GT.Cell(1) + GT.Cell(0) + GT.Cell(0)
pop = Graph(axiom, rules = rule)

getStates(pop) = [data(n).state for n in values(VPL.Core.nodes(pop))]
@test sum(getStates(pop)) == 1
rewrite!(pop)
@test sum(getStates(pop)) == 2
rewrite!(pop)
@test getStates(pop) == [1,1,1]

# Cell transfer bottom to top
function transferUp(context)
    if hasChildren(context)
        child = first(children(context))
        return (true, (child, ))
    else
        return (false, ())
    end
end

ruleUp = Rule(GT.Cell{Int}, lhs = transferUp,
          rhs = (context, child) -> GT.Cell(data(child).state), captures = true)

axiomUp = GT.Cell(0) + GT.Cell(0) + GT.Cell(1)
pop = Graph(axiomUp, rules = ruleUp)

@test sum(getStates(pop)) == 1
rewrite!(pop)
@test sum(getStates(pop)) == 2
rewrite!(pop)
@test getStates(pop) == [1,1,1]

end
