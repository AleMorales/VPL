# Algae growth

In this first example, we learn how to create a `Graph` and update it dynamically with rewriting rules. 

The model described here is based on the non-branching model of [algae growth](https://en.wikipedia.org/wiki/L-system#Example_1:_Algae) proposed by Lindermayer as one of the first L-systems.

First, we need to load the VPL metapackage, which will automatically load all the packages in the VPL ecosystem. 

```julia
using VPL
```

The rewriting rules of the L-system are as follows:

axiom:   A  

rule 1:  A $\rightarrow$ AB  

rule 2:  B $\rightarrow$ A  

In VPL, this L-system would be implemented as a graph where the nodes can be of type A and B and inherit from the abstract type `Nodes`:

```julia
struct A <: Node end
struct B <: Node end
```

Note that in this very example we do not need to store any data or state inside the nodes, so types A and B do not require fields.

The axiom is simply defined as an instance of type of A:

```julia
axiom = A()
```

The rewriting rules are implemented in VPL as objects of type `Rule`. In VPL, a rewriting rule substitutes a node in a graph with a new node or subgraph and is therefore composed of two parts:

1. A condition that is tested against each node in a graph to choose which nodes to rewrite.  
2. A subgraph that will replace each node selected by the condition above.  

In VPL, the condition is split into two components:

1. The type of node to be selected (in this example that would be `A` or `B`).  
2. A function that is applied to each node in the graph (of the specified type) to indicate whether the node should be selected or not. This function is optional (the default is to select every node of the specified type).

The replacement subgraph is specified by a function that takes as input the node selected and returns a subgraph defined as a combination of node objects. Subgraphs (which can also be used as axioms) are created by linearly combining objects that inherit from `Node`. The operation `+` implies a linear relationship between two nodes and `[]` indicates branching.

The implementation of the two rules of algae growth model in VPL is as follows:

```julia
rule1 = Rule(A, rhs = x -> A() + B())
rule2 = Rule(B, rhs = x -> A())
```

Note that in each case, the argument `rhs` is being assigned an anonymous (aka *lambda*) function. This is a function without a name that is defined directly in the assigment to the argument. That is, the Julia expression `x -> A() + B()` is equivalent to the function definition:

```julia
function rule_1(x)
    A() + B()
end
```

For simple rules (especially if the right hand side is just a line of code) it is easier to just define the right hand side of the rule with an anonymous function rather than defining a standalone function with a meaningful name. 

With the axiom and rules we can now create a `Graph` object that represents the algae organism. The first argument is the axiom and the second is a tuple with all the rewriting rules:

```julia
algae = Graph(axiom, (rule1, rule2))
```

We can visualize the graph by using the function `draw`. This will open an external window with an interactive network representation of the current state of the graph (as indicated above, I include below a screenshot of what you should get in your local device).

```julia
draw(algae);
```

You can see that at the moment the graph only contains the axiom, that is, a node of type `A`. If we apply the rewriting rules iteratively, the graph will grow, in this case representing the growth of the algae organism. The rewriting rules are applied on the graph with the function `rewrite!`:

```julia
rewrite!(algae)
```

Since there was only one node of type `A`, the only rule that was applied was `ruleA`, so the graph should now have two nodes of types `A` and `B`, respectively. We can confirm this by drawing the graph.

```julia
draw(algae);
```

Notice that each node in the network representation is labelled with the type of node (`A` or `B` in this case) and a number in parenthesis. This number is a unique identifier associated to each node and it is useful for debugging purposes (this will be explained in more advanced examples).

Applying multiple iterations of rewriting can be achieved with a simple loop:

```julia
for i in 1:4
    rewrite!(algae)
end
draw(algae);
```

The network is rather boring as the system is growing linearly (no branching) but it already illustrates how graphs can grow rapidly in just a few iterations. Remember that the interactive visualization allows adjusting the zoom, which is handy when graphs become large.