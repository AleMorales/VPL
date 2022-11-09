using VPL
using Test
include("types.jl")
import .GT


let

# Generate the structure
axiom = GT.A() + (GT.A() + (GT.A() + GT.BCell(1), GT.A() + GT.BCell(2), GT.A() + GT.BCell(3)), 
              GT.A() + GT.A() + GT.A() + GT.BCell(4)) +
        GT.A() + (GT.A() + (GT.A() + GT.BCell(5), GT.A() + GT.BCell(6), GT.A() + GT.BCell(7)) , GT.A() + GT.A() + GT.BCell(8)) +
        GT.A() + (GT.A() + (GT.A() + GT.BCell(9), GT.A() + GT.BCell(10), GT.A() + GT.BCell(11)), GT.A() + GT.BCell(12)) + 
        GT.A() + GT.A() + GT.BCell(13)
graph = Graph(axiom = axiom)           

# Query 1: Retrieve all nodes of type B
Q1 = Query(GT.BCell)
A1 = apply(graph, Q1) # Should return 13 objects of type B
@test length(A1) == 13

#= 
Query 2: Retrieve B(13) only
Criteria: 
    It is 5 A nodes from the root
    The second A node starting from B(13) only has one child
=#
function Q2_fun(n)
    # Condition 1
    check, steps = hasAncestor(n, condition = isRoot)
    steps != 5 && return false
    # Condition 2
    p2 = parent(n, nsteps = 2)
    length(children(p2)) == 1
end

Q2 = Query(GT.BCell, condition = Q2_fun)
A2 = apply(graph, Q2)
@test A2 == [GT.BCell(13)]

#= 
Query 3: Retrieve B(1), B(2) and B(3)
Criteria: 
    They are 3 A nodes from root of graph
    There second A node starting from leaves has 3 children
=#
function Q3_fun(n)
    # Condition 1
    check, steps = hasAncestor(n, condition = isRoot)
    steps != 3 && return false
    # Condition 2
    p2 = parent(n, nsteps = 2)
    length(children(p2)) == 3
end

Q3 = Query(GT.BCell, condition = Q3_fun)
A3 = apply(graph, Q3)
@test isempty(setdiff(A3, [GT.BCell(1), GT.BCell(2), GT.BCell(3)]))

#= 
Query 4: Retrieve B(4)
Criteria: 
    It is 4 A nodes from root of graph
    The second A node starting from leaves has 1 children
    The third A node starting from leaves has 1 children
=#
function Q4_fun(n)
    # Condition 1
    check, steps = hasAncestor(n, condition = isRoot)
    steps != 4 && return false
    # Condition 2
    p2 = parent(n, nsteps = 2)
    length(children(p2)) != 1 && return false
    # Condition 3
    p3 = parent(n, nsteps = 3)
    length(children(p3)) == 1    
end
Q4 = Query(GT.BCell, condition = Q4_fun)
A4 = apply(graph, Q4)
@test A4 == [GT.BCell(4)]


end
