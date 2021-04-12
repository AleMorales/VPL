
# Module Core


```@meta
CurrentModule = VPL.Core
```

## Types

```@docs
Graph
```

```@docs
Rule
```

```@docs
Query
```

```@docs
Node
```

```@docs
Context
```

## Applying rules and queries

```@docs
apply(g::Graph, query::Query)
```

```@docs
rewrite!(g::Graph)
```

## Extracting information

```@docs
vars(g::Graph)
```

```@docs
rules(g::Graph)
```

```@docs
vars(c::Context)
```

```@docs
data(c::Context)
```

## Graph traversal

```@docs
hasParent(c::Context)
```

```@docs
isRoot(c::Context)
```

```@docs
hasAncestor(c::Context, query, maxlevel::Int = typemax(Int))
```

```@docs
parent(c::Context)
```

```@docs
ancestor(c::Context, query, maxlevel::Int = typemax(Int))
```

```@docs
hasChildren(c::Context)
```

```@docs
isLeaf(c::Context)
```

```@docs
hasDescendent(c::Context, query, maxlevel::Int = typemax(Int))
```

```@docs
children(c::Context)
```

```@docs
descendent(c::Context, query, maxlevel::Int = typemax(Int))
```

```@docs
traverse(g::Graph, f)
```

```@docs
traverseDFS(g::Graph, f)
```

```@docs
traverseBFS(g::Graph, f)
```

## Graph visualization

```@docs
draw(g::Graph; name::String = "VPL Graph")
```

```@docs
get_id(key, data)
```


