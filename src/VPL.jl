# This file defines the API of VPL by creating aliases

module VPL

# Functions and data structures export by VPL
export Node, Graph, Rule, Query, rewrite!, apply, vars, rules, graph,
       data, hasParent, hasAncestor, ancestor, isRoot,
       hasChildren, hasDescendent, children, descendent, isLeaf,
       traverse, traverseDFS, traverseBFS, draw
       
# Core module (graph rewriting)
include("Core/Module_Core.jl")
import .Core
const Node = Core.Node 
const Graph = Core.Graph
const Rule = Core.Rule
const Query = Core.Query
const rewrite! = Core.rewrite!
const apply = Core.apply
const vars = Core.vars
const rules = Core.rules
const graph = Core.graph
const data = Core.data
const hasParent = Core.hasParent
const hasAncestor = Core.hasAncestor
const ancestor = Core.ancestor
const isRoot = Core.isRoot
const hasChildren = Core.hasChildren
const hasDescendent = Core.hasDescendent
const children = Core.children
const descendent = Core.descendent
const isLeaf = Core.isLeaf
const traverse = Core.traverse
const traverseDFS = Core.traverseDFS
const traverseBFS = Core.traverseBFS
const draw = Core.draw
const get_id = Core.get_id

end # module
