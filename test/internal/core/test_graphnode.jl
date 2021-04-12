import VPL
const C = VPL.Core
using Test

let
# Test GraphNode construction
n = C.GraphNode(1)

# Check that this returns the correct type
@test n isa C.GraphNode
@test !isimmutable(n)

# Check deafult constructor
@test ismissing(C.parentID(n))
@test isempty(C.childrenID(n))

# Add connections
C.addChild!(n,1)
@test length(C.childrenID(n)) == 1 && first(C.childrenID(n)) == 1
C.setParent!(n,2)
@test C.parentID(n) == 2

# Create a copy of the node
n2 = copy(n)

# Remove connections
C.removeChild!(n,1)
@test isempty(C.childrenID(n))
C.removeParent!(n)
@test ismissing(C.parentID(n))

# The resulting node should be root and leaf
@test C.isLeaf(n)
@test C.isRoot(n)

# Retrieve data stored inside the node
@test C.data(n) === 1

# Make sure that the copied node was independent
@test C.hasChildren(n2)
@test C.hasParent(n2)

end
