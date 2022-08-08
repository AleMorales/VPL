# This file defines the API of VPL by creating aliases

module VPL

# Functions and data structures export by VPL
export Node, Graph, Rule, Query, rewrite!, apply, vars, rules, graph,
       data, hasParent, hasAncestor, ancestor, isRoot,
       hasChildren, hasDescendent, children, descendent, isLeaf,
       traverse, traverseDFS, traverseBFS, draw, export_graph, calculate_resolution,
       area, areas, ntriangles, nvertices, loadmesh, savemesh, 
       Mesh, Rectangle, BBox, Ellipse, Ellipsoid, HollowCylinder, SolidCylinder,
       HollowCone, SolidCone, SolidCube, HollowCube, SolidFrustum, HollowFrustum,
       Rectangle!, Ellipse!, Ellipsoid!, HollowCylinder!, SolidCylinder!,
       HollowCone!, SolidCone!, SolidCube!, HollowCube!, SolidFrustum!, HollowFrustum!,
       MTurtle, feedgeom!, head, up, arm, pos, geoms, 
       T, t!, OR, or!, SET, set!, RU, ru!, RA, ra!, RH, rh!, F, f!, 
       O, X, Y, Z,  Vec,
       render, render!, RGB, GLTurtle, feedcolor!, GLScene, export_scene, add!,
       RTScene, RayTracer, RTSettings, trace!, BVH, Naive, Triangle,
       Source, LambertianSource, DirectionalSource, PointSource, LineSource, AreaSource,
       tau, rho, Lambertian, Phong, Sensor, Black

# Abstract type for turtles
abstract type Turtle end

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
const export_graph = Core.export_graph
const calculate_resolution = Core.calculate_resolution
const node_label = Core.node_label

# Geom module
include("Geom/Module_Geom.jl")
import .Geom
const area = Geom.area
const areas = Geom.areas
const Mesh = Geom.Mesh
const ntriangles = Geom.ntriangles
const nvertices = Geom.nvertices
const loadmesh = Geom.loadmesh
const savemesh = Geom.savemesh
const Rectangle = Geom.Rectangle
const SolidCube = Geom.SolidCube
const HollowCube = Geom.HollowCube
const BBox = Geom.BBox
const Ellipse = Geom.Ellipse
const HollowCylinder = Geom.HollowCylinder
const SolidCylinder = Geom.SolidCylinder
const HollowCone = Geom.HollowCone
const SolidCone = Geom.SolidCone
const HollowFrustum = Geom.HollowFrustum
const SolidFrustum = Geom.SolidFrustum
const Ellipsoid = Geom.Ellipsoid
const Rectangle! = Geom.Rectangle!
const SolidCube! = Geom.SolidCube!
const HollowCube! = Geom.HollowCube!
const Ellipse! = Geom.Ellipse!
const HollowCylinder! = Geom.HollowCylinder!
const SolidCylinder! = Geom.SolidCylinder!
const HollowCone! = Geom.HollowCone!
const SolidCone! = Geom.SolidCone!
const HollowFrustum! = Geom.HollowFrustum!
const SolidFrustum! = Geom.SolidFrustum!
const Ellipsoid! = Geom.Ellipsoid!
const T = Geom.T
const t! = Geom.t!
const OR = Geom.OR
const or! = Geom.or!
const SET = Geom.SET
const set! = Geom.set!
const RU = Geom.RU
const ru! = Geom.ru!
const RA = Geom.RA
const ra! = Geom.ra!
const RH = Geom.RH
const rh! = Geom.rh!
const F = Geom.F
const f! = Geom.f!
const feedgeom! = Geom.feedgeom!
const MTurtle = Geom.MTurtle
const Vec = Geom.Vec
const O = Geom.O
const X = Geom.X
const Y = Geom.Y
const Z = Geom.Z
const head = Geom.head
const up = Geom.up
const arm = Geom.arm
const pos = Geom.pos
const geoms = Geom.geoms


# Render module
include("Render/Module_Render.jl")
import .Render
const render = Render.render
const render! = Render.render!
const feedcolor! = Render.feedcolor!
const RGB = Render.RGB
const GLTurtle = Render.GLTurtle
const GLScene = Render.GLScene
const add! = Render.add!
const export_scene = Render.export_scene

# RayTracer module
include("RayTracer/Module_RayTracing.jl")
import .RayTracing as RT
const Triangle = RT.Triangle
const RTScene = RT.RTScene
const RayTracer = RT.RayTracer
const RTSettings = RT.RTSettings
const trace! = RT.trace!
const tau = RT.tau
const rho = RT.rho
const Lambertian = RT.Lambertian
const Phong = RT.Phong
const Sensor = RT.Sensor
const Black = RT.Black
const Naive = RT.Naive
const BVH = RT.BVH
const Source = RT.Source
const LambertianSource = RT.LambertianSource
const PointSource = RT.PointSource
const LineSource = RT.LineSource
const AreaSource = RT.AreaSource
const DirectionalSource = RT.DirectionalSource

end # module
