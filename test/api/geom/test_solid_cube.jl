import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard cube primitive
c = VPL.SolidCube(length = 1.0, width = 1.0, height = 1.0);
@test c isa VPL.Mesh
@test VPL.area(c) == 6.0
@test VPL.nvertices(c) == 8
@test VPL.ntriangles(c) == 12
VPL.render(c, wireframe = true, normals = true)

# Check that it works at lower precision
c = VPL.SolidCube(length = 1f0, width = 1f0, height = 1f0);
@test c isa VPL.Mesh
@test VPL.area(c) == 6f0
@test VPL.nvertices(c) == 8
@test VPL.ntriangles(c) == 12
VPL.render(c, wireframe = true, normals = true)


# Mergin two meshes
c2 = VPL.SolidCube(length = 0.5, width = 0.5, height = 3.0);
function foo()
    c2 = VPL.SolidCube(length = 0.5, width = 0.5, height = 3.0)    
    c = VPL.SolidCube(length = 1.0, width = 1.0, height = 1.0)
    VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test VPL.area(m) == VPL.area(c) + VPL.area(c2)
VPL.render(m, wireframe = true, normals = true)

# Create a box using affine maps
scale = LinearMap(SDiagonal(3.0/2, 0.5/2, 0.5));
c3 = VPL.SolidCube(scale);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a box ussing affine maps and add it to an existing mesh
function foo2()
    scale1 = LinearMap(SDiagonal(1/2, 1/2, 1.0))
    scale2 = LinearMap(SDiagonal(3/2, 0.5/2, 0.5))
    m = VPL.Mesh()
    VPL.Geom.SolidCube!(m, scale1)
    VPL.Geom.SolidCube!(m, scale2)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)

# Construct solid cube using a turtle
sc = G.SolidCube(length = 1.0, width = 1.0, height = 1.0);
t = G.Turtle(Float64)
G.SolidCube!(t; length = 1.0, width = 1.0, height = 1.0, move = true) 
@test G.geoms(t) == sc
@test G.pos(t) == G.Vec{Float64}(0,0,1)

t = G.Turtle(Float64)
G.SolidCube!(t; length = 1.0, width = 1.0, height = 1.0, move = false);
@test G.geoms(t) == sc
@test G.pos(t) == G.Vec{Float64}(0,0,0)

end