# Binary tree

In this example we build a 3D representation of a binary tree. Although this will not look like a real plant, this example will help introduce additional features of VPL.

The model requires three types of nodes:

*Meristem*: These are the nodes responsible for growth of new organs in our binary tree. They contain no data or geometry (i.e. they are a point in the 3D structure).  

*Internode*: The structural elements that make the binary tree, which is a simple tree made of sticks.  

*TreeNode*: What is left after a meristem produces a new organ. They contain no data or geometry (so also a point) but are required to keep the branching structure of the tree. Note that we cannot call this data type `Node` as that is a type already defined by VPL.

In a similar fashion to the previous example, internodes are represented by prisms, but unlike before, the length of the prism will change in time, emulating the growth of the tree. For that reason, we need to make the type mutable.

The three types of data are defined as follows:

```julia
using VPL

# Meristem
struct Meristem <: Node end
# TreeNode
struct TreeNode <: Node end
# Internode
mutable struct Internode <: Node
  length::Float64
end
```

As always, the 3D structure and the color of each type of node are implemented with the `feedgeom!` and `feedcolor!` methods. In this case, only the internodes have a 3D representation, so these methods are defined for this type only.

```julia
function VPL.feedgeom!(turtle::MTurtle, i::Internode)
    HollowCube!(turtle, l = i.length, h = i.length/10, w = i.length/10, move = true)
    return nothing
end
function VPL.feedcolor!(turtle::GLTurtle, i::Internode)
    feedcolor!(turtle, RGB(0,1,0))
    return nothing
end
```

The growth rule of our binary tree is simple: meristems are replaced a by tree node and two branches that split at specific angles. Each branch is then composed of an internode and ends in a meristem. The two branches are implemented by enclosing with square brackets and separating by commas (like when you create an array of numbers in Julia). Since a binary tree is actually a 2D structure but we want to have it 3D, we add an extra rotation, such that the new branches growing from the apical meristems are not aligned with the preceding internodes. The key is to imagine the turtle in your head and keep track of the different rotations as it moves through the rule. A concept to keep in mind there is that the position and orientation of the turtle is always the same at the beginning of each branch (i.e. essentially, at each branching point, the turtle splits into two clones that move along the tree independently).

```julia
rule = Rule(Meristem, rhs = mer -> TreeNode() + (RU(-60.0) + Internode(0.1) + RH(90.0) + Meristem(), 
                                                 RU(60.0)  + Internode(0.1) + RH(90.0) + Meristem()))
```

In order to simulate growth of the 3D binary tree, we need to define a parameter describing the relative rate at which each internode elongate in each iteration of the simulation. Graphs in VPL can store an object of any user-defined type that will me made accessible to graph rewriting rules and queries. Such object is useful to store parameters (in which case we make them immutable) or state variables that cannot be associated to any specific organ (in which case we would make the object mutable). For this example, we define a data type `treeparams` that holds the relative growth rate (or growth factor) of the internodes of a tree.

```julia
struct treeparams
    growth::Float64
end
```

A binary tree initializes as a meristem, so the axiom can be constructed simply as:

```julia
axiom = Internode(0.1) + Meristem()
```

And the object for the tree can be constructed as before, by passing the axiom and the graph rewriting rules, but in this case also with the object with growth-related parameters.

```julia
tree = Graph(axiom, Tuple(rule), treeparams(0.5))
```

Note that so far we have not included any code to simulate growth of the internodes. The reason is that, as elongation of internotes does not change the topology of the graph (it simply changes the data stored in certain nodes), this process does not need to be implemented with graph rewriting rules. Instead, we will use a combination of a query (to identify which nodes need to be altered) and direct modification of these nodes. A `Query` object is a like a `Rule` but without a right-hand side. In this case, we just want to identify those nodes of type `Internode`, so we do not need to specify a left-hand side either. Instead, we simply create the query as:

```julia
getInternode = Query(Internode)
```

If we apply the query to a graph using the `apply` function, we will get an array of all the nodes that match the query, allow for direct manipulation of their contents. To help organize the code, we will create a function that simulates growth by multiplying the `length` argument of all internodes in a tree by the `growth` parameter defined in the above:

```julia
function elongate!(tree, query)
    for x in apply(tree, query)
        x.length = x.length*(1.0 + vars(tree).growth)
    end
end
```

Note that we use `vars` on the `Graph` object to extract the object that was stored inside of it. Also, as this function will modify the graph which is passed as input, we append an `!` to the name (this not a special syntax of the language, its just a convention in the Julia community, which is ). Also, in this case, the query object is kept separate from the graph. We could have also store inside the graph like we did for the parameter `grow`. We could also have packaged the graph and the query into another type representing an individual tree. This is entirely up to the user and indicates that a model can be implemented in many differences ways with VPL.

Simulating the growth a tree is a matter of elongating the internodes and applying the rules to create new internodes:

```julia
function growth!(tree, query)
    elongate!(tree, query)
    rewrite!(tree)
end
```

and a simulation for n steps is achieved with a simple loop:

```julia
function simulate(tree, query, nsteps)
    new_tree = deepcopy(tree)
    for i in 1:nsteps
        growth!(new_tree, query)
    end
    return new_tree
end
```

Notice that the `simulate` function creates a copy of the object to avoid overwriting it. If we run the simulation for a couple of steps

```julia
newtree = simulate(tree, getInternode, 2)
```

The binary tree after two iterations has two branches, as expected:

```julia
render(newtree)
```

Notice how the lengths of the prisms representing internodes decreases as the branching order increases, as the internodes are younger (i.e. were generated fewer generations ago). Further steps will generate a structure that is more tree-like.

```julia
newtree = simulate(newtree, getInternode, 10)
render(newtree)
```