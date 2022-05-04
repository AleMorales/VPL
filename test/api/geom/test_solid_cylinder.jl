import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard Solid cylinder primitive
c = VPL.SolidCylinder(l = 2.0, w = 1.0, h = 1.0, n = 10);
@test c isa VPL.Mesh;
@test abs(VPL.area(c)/(2pi + pi/2) - 1.0) < 0.03
@test VPL.nvertices(c) == 22
@test VPL.ntriangles(c) == 40
@test length(c.normals) == 40
VPL.render(c, :green, wireframe = true, normals = true)

# Checking that it works at lower precisions
c = VPL.SolidCylinder(l = 2f0, w = 1f0, h = 1f0, n = 10);
@test c isa VPL.Mesh;
@test abs(VPL.area(c)/(2f0pi + pi/2f0) - 1f0) < 0.03f0;
@test VPL.nvertices(c) == 22
@test VPL.ntriangles(c) == 40
@test length(c.normals) == 40
VPL.render(c, :green, wireframe = true, normals = true)



# Mergin two meshes
c = VPL.SolidCylinder(l = 2.0, w = 1.0, h = 1.0, n = 10);
c2 = VPL.SolidCylinder(l = 3.0, w = 0.1, h = 0.2, n = 10);
function foo()
    c = VPL.SolidCylinder(l = 2.0, w = 1.0, h = 1.0, n = 10)
    c2 = VPL.SolidCylinder(l = 3.0, w = 0.1, h = 0.2, n = 10)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 1.6e-14
VPL.render(m, :green, wireframe = true, normals = true)

# Create a Solid cylinder using affine maps
scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0));
c3 = VPL.SolidCylinder(scale,n = 10);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a cylinder ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0))
    m = VPL.SolidCylinder(l = 2.0, w = 1.0, h = 1.0, n = 10)
    VPL.Geom.SolidCylinder!(m, scale,n = 10)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, :green, wireframe = true, normals = true)

# Construct solid cylinder using a turtle
sc = G.SolidCylinder(l = 2.0, w = 1.0, h = 1.0, n = 10);
t = G.MTurtle(Float64)
G.SolidCylinder!(t; l = 2.0, w = 1.0, h = 1.0, n = 10, move = true) 
@test G.geoms(t) == sc
@test G.pos(t) == G.Vec{Float64}(0,0,2)

t = G.MTurtle(Float64)
G.SolidCylinder!(t; l = 2.0, w = 1.0, h = 1.0, n = 10, move = false);
@test G.geoms(t) == sc
@test G.pos(t) == G.Vec{Float64}(0,0,0)

end