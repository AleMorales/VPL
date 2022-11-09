using VPL
using Test
using Suppressor
include("types.jl")
import .GT

let

### Growth models ###

# Silly model that duplicate cells and updates the values of the cells
function growth(context)
    c = data(context)
    f = vars(context).division
    GT.Cell(c.state*f) + (GT.Cell(c.state*(1//1 - f)),)
end

# Start with single cell and duplicate iteratively
axiom = GT.Cell(10//1)
rule = Rule(GT.Cell{Rational{Int}}, rhs = growth)
printed = @capture_out @show rule
@test printed == "rule = Rule replacing nodes of type Main.GT.Cell{Rational{$(typeof(1))}} without context capturing.\n\n"

# Create organism
organism = Graph(axiom = axiom, rules = rule, vars = GT.G3pars(1//3, 5//4))
printed = @capture_out @show organism
@test printed == "organism = Dynamic graph with 1 nodes of types Main.GT.Cell{Rational{$(typeof(1))}} and 1 rewriting rules.\nDynamic graph variables stored in struct of type Main.GT.G3pars\n\n"


# Growth function
queryCell = Query(GT.Cell{Rational{Int}})
printed = @capture_out @show queryCell
@test printed == "queryCell = Query object for nodes of type Main.GT.Cell{Rational{$(typeof(1))}}\n\n"
function grow!(organism)
    f = vars(organism).growth
    for cell in apply(organism, queryCell)
        cell.state *= f
    end
    rewrite!(organism)
end

# Grow one step
grow!(organism)


# Extract states from the organism using breadth-first traversal
states = Rational{Int}[]
traverseBFS(organism, fun = x -> push!(states, x.state))
@test states == [10//1*5//4*1//3, 10//1*5//4*2//3]

# Extract states from the organism using depth-first traversal
states = Rational{Int}[]
traverseDFS(organism, fun = x -> push!(states, x.state))
@test states == [10//1*5//4*1//3, 10//1*5//4*2//3]

# Extract organism using traversal with arbitrary order
states = Rational{Int}[]
traverse(organism, fun = x -> push!(states, x.state))
@test sum(states) == sum([10//1*5//4*1//3, 10//1*5//4*2//3])

# Second generation
grow!(organism)

# Extract states from the organism using breadth-first traversal
states = Rational{Int}[]
traverseBFS(organism, fun = x -> push!(states, x.state))
@test states == [125//72, 125//36, 125//36, 125//18]

# Extract states from the organism using depth-first traversal
states = Rational{Int}[]
traverseDFS(organism, fun = x -> push!(states, x.state))
@test sort(states) == [125//72, 125//36, 125//36, 125//18]



### Growth & death models ###

function dying(context)
    c = data(context)
    c.state < 1//10
end
function growing(context)
    c = data(context)
    c.state >= 1//10
end
ruleDeath = Rule(GT.Cell{Rational{Int}}, lhs = dying)
ruleGrowth = Rule(GT.Cell{Rational{Int}}, lhs = growing, rhs = growth)

# Create organism
organism = Graph(axiom = axiom, rules = (ruleGrowth, ruleDeath), 
                 vars = GT.G3pars(1//3, 10//9))

# Grow six steps
for i = 1:5
    grow!(organism)
end
# Now everyone dies
grow!(organism)
@test length(organism) == 0

end
