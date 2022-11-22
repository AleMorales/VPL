import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard Solid cylinder primitive
c = VPL.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40);
@test c isa VPL.Mesh;
@test abs(VPL.area(c)/(2pi + pi/2) - 1.0) < 0.03
@test VPL.nvertices(c) == 22
@test VPL.ntriangles(c) == 40
@test length(c.normals) == 40
VPL.render(c, wireframe = true, normals = true)

# Checking that it works at lower precisions
c = VPL.SolidCylinder(length = 2f0, width = 1f0, height = 1f0, n = 40);
@test c isa VPL.Mesh;
@test abs(VPL.area(c)/(2f0pi + pi/2f0) - 1f0) < 0.03f0;
@test VPL.nvertices(c) == 22
@test VPL.ntriangles(c) == 40
@test length(c.normals) == 40
VPL.render(c, wireframe = true, normals = true)

# Mergin two meshes
c = VPL.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40);
c2 = VPL.SolidCylinder(length = 3.0, width = 0.1, height = 0.2, n = 40);
function foo()
    c = VPL.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
    c2 = VPL.SolidCylinder(length = 3.0, width = 0.1, height = 0.2, n = 40)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 1.6e-14
VPL.render(m, wireframe = true, normals = true)

# Create a Solid cylinder using affine maps
scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0));
c3 = VPL.SolidCylinder(scale, n = 40);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a cylinder ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0))
    m = VPL.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
    VPL.Geom.SolidCylinder!(m, scale, n = 40)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)

# Construct solid cylinder using a turtle
sc = VPL.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40);
t = VPL.MTurtle(Float64)
VPL.SolidCylinder!(t; length = 2.0, width = 1.0, height = 1.0, n = 40, move = true) 
@test VPL.geoms(t) == sc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,2)

t = VPL.MTurtle(Float64)
VPL.SolidCylinder!(t; length = 2.0, width = 1.0, height = 1.0, n = 40, move = false);
@test VPL.geoms(t) == sc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,0)

end