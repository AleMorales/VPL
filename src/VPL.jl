# This file defines the API of VPL by creating aliases

module VPL

# Functions and data structures export by VPL
export Node, Graph, Rule, Query, rewrite!, apply, vars, rules, graph,
       data, hasParent, hasAncestor, ancestor, isRoot,
       hasChildren, hasDescendent, children, descendent, isLeaf,
       traverse, traverseDFS, traverseBFS, draw, export_graph, calculate_resolution,
       area, areas, ntriangles, nvertices, loadmesh, savemesh, 
       scale!, rotatex!, rotatey!, rotatez!, rotate!, translate!,
       Mesh, Triangle, Rectangle, Trapezoid, BBox, Ellipse, Ellipsoid, HollowCylinder, SolidCylinder,
       HollowCone, SolidCone, SolidCube, HollowCube, SolidFrustum, HollowFrustum,
       Triangle!, Rectangle!, Trapezoid!, Ellipse!, Ellipsoid!, HollowCylinder!, SolidCylinder!,
       HollowCone!, SolidCone!, SolidCube!, HollowCube!, SolidFrustum!, HollowFrustum!, Mesh!,
       Turtle, feed!, head, up, arm, pos, geoms, materials, colors, mesh, Scene,
       T, t!, OR, or!, SET, set!, RU, ru!, RA, ra!, RH, rh!, F, f!, RV, rv!, 
       O, X, Y, Z,  Vec,
       render, render!, RGB, RGBA, export_scene, add!,
       RayTracer, RTSettings, trace!, Naive, accelerate,
       Source, LambertianSource, DirectionalSource, PointSource, LineSource, AreaSource,
       tau, rho, Lambertian, Phong, Sensor, Black,
       get_nw, FixedSource, reset!, power, BVH, SAH, AvgSplit

# Abstract type for turtles
abstract type Material end

#abstract type Turtle end

# Function to be overloaded by other modules
add!() = error("Method of add! not implemented")

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
const area       = Geom.area
const areas      = Geom.areas
const Mesh       = Geom.Mesh
const ntriangles = Geom.ntriangles
const nvertices  = Geom.nvertices
const loadmesh   = Geom.loadmesh
const savemesh   = Geom.savemesh
const scale!     = Geom.scale!
const rotatex!   = Geom.rotatex!
const rotatey!   = Geom.rotatey!
const rotatez!   = Geom.rotatez!
const rotate!    = Geom.rotate!
const translate! = Geom.translate!
const Triangle   = Geom.Triangle
const Rectangle  = Geom.Rectangle
const Trapezoid  = Geom.Trapezoid
const SolidCube  = Geom.SolidCube
const HollowCube = Geom.HollowCube
const BBox       = Geom.BBox
const Ellipse    = Geom.Ellipse
const HollowCylinder  = Geom.HollowCylinder
const SolidCylinder   = Geom.SolidCylinder
const HollowCone      = Geom.HollowCone
const SolidCone       = Geom.SolidCone
const HollowFrustum   = Geom.HollowFrustum
const SolidFrustum    = Geom.SolidFrustum
const Ellipsoid       = Geom.Ellipsoid
const Triangle!       = Geom.Triangle!
const Rectangle!      = Geom.Rectangle!
const Trapezoid!      = Geom.Trapezoid!
const SolidCube!      = Geom.SolidCube!
const Ellipse!        = Geom.Ellipse!
const HollowCube!     = Geom.HollowCube!
const HollowCylinder! = Geom.HollowCylinder!
const SolidCylinder!  = Geom.SolidCylinder!
const HollowCone!     = Geom.HollowCone!
const SolidCone!      = Geom.SolidCone!
const HollowFrustum!  = Geom.HollowFrustum!
const SolidFrustum!   = Geom.SolidFrustum!
const Ellipsoid!      = Geom.Ellipsoid!
const Mesh!     = Geom.Mesh!
const T         = Geom.T
const t!        = Geom.t!
const OR        = Geom.OR
const or!       = Geom.or!
const SET       = Geom.SET
const set!      = Geom.set!
const RU        = Geom.RU
const ru!       = Geom.ru!
const RA        = Geom.RA
const ra!       = Geom.ra!
const RH        = Geom.RH
const rh!       = Geom.rh!
const F         = Geom.F
const f!        = Geom.f!
const RV        = Geom.RV
const rv!       = Geom.rv!
const feed!     = Geom.feed!
const Turtle    = Geom.Turtle
const materials = Geom.materials
const colors    = Geom.colors
const Scene     = Geom.Scene
const Vec       = Geom.Vec
const O         = Geom.O
const X         = Geom.X
const Y         = Geom.Y
const Z         = Geom.Z
const head      = Geom.head
const up        = Geom.up
const arm       = Geom.arm
const pos       = Geom.pos
const geoms     = Geom.geoms


# Render module
include("Render/Module_Render.jl")
import .Render
const render = Render.render
const render! = Render.render!
const RGB = Render.RGB
const RGBA = Render.RGBA
const export_scene = Render.export_scene


# RayTracer module
include("RayTracer/Module_RayTracing.jl")
import .RayTracing as RT
const accelerate = RT.accelerate
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
const Source = RT.Source
const LambertianSource = RT.LambertianSource
const PointSource = RT.PointSource
const LineSource = RT.LineSource
const AreaSource = RT.AreaSource
const DirectionalSource = RT.DirectionalSource
const get_nw = RT.get_nw
const FixedSource = RT.FixedSource
const reset! = RT.reset!
const power = RT.power
const BVH = RT.BVH
const SAH = RT.SAH
const AvgSplit = RT.AvgSplit

end # module
