import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

#let

# Standard triangle primitive
r = VPL.Triangle(length = 2.0, width = 2.0);
@test r isa VPL.Mesh;
@test VPL.area(r) == 2
@test VPL.nvertices(r) == 3
@test VPL.ntriangles(r) == 1
@test all(r.normals[1] .== [1.0, 0.0, 0.0])
VPL.render(r, wireframe = true, normals = true)

# Check that it works with lower precision
r = VPL.Triangle(length = 2f0, width = 2f0);
@test r isa VPL.Mesh;
@test VPL.area(r) == 2f0
@test VPL.nvertices(r) == 3
@test VPL.ntriangles(r) == 1
@test all(r.normals[1] .== [1f0, 0f0, 0f0])
VPL.render(r, wireframe = true, normals = true)

# Merging two meshes
r = VPL.Triangle(length = 2.0, width = 2.0);
r2 = VPL.Triangle(length = 3.0, width = 0.1);
function foo()
    r = VPL.Triangle(length = 2.0, width = 2.0)
    r2 = VPL.Triangle(length = 3.0, width = 0.1)
    m = VPL.Mesh([r,r2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(r) + VPL.nvertices(r2)
@test VPL.ntriangles(m) == VPL.ntriangles(r) + VPL.ntriangles(r2)
@test VPL.area(m) ≈ VPL.area(r) + VPL.area(r2)
VPL.render(m, wireframe = true, normals = true)

# Create a triangle using affine maps
scale = LinearMap(SDiagonal(1.0, 0.1/2, 3.0));
r3 = VPL.Triangle(scale);
@test r3.normals == r2.normals
@test r3.vertices == r2.vertices
@test r3.faces == r2.faces

# Create a triangle ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(1.0, 0.1/2, 3.0))
    m = VPL.Triangle(length = 2.0, width = 2.0)
    VPL.Geom.Triangle!(m, scale)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)


# Construct triangles using a turtle
r = VPL.Triangle(length = 2.0, width = 2.0);
t = VPL.MTurtle(Float64)
VPL.Triangle!(t; length = 2.0, width = 2.0, move = true) 
@test VPL.geoms(t) == r
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,2)

t = VPL.MTurtle(Float64)
VPL.Triangle!(t; length = 2.0, width = 2.0, move = false);
@test VPL.geoms(t) == r
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,0)


#end
