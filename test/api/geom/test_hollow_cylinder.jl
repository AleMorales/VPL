import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let


# Standard hollow cylinder primitive
c = VPL.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20);
@test c isa VPL.Mesh
@test abs(VPL.area(c)/pi - 2.0) < 0.04
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
#VPL.render(c, wireframe = true, normals = true)

# Check that it works with lower precision
c = VPL.HollowCylinder(length = 2f0, width = 1f0, height = 1f0, n = 20);
@test c isa VPL.Mesh
@test abs(VPL.area(c)/pi - 2f0) < 0.04f0
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
#VPL.render(c, wireframe = true, normals = true)

# Merging two meshes
c = VPL.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20);
c2 = VPL.HollowCylinder(length = 3.0, width = 0.1, height = 0.2, n = 20);
function foo()
    c = VPL.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20);
    c2 = VPL.HollowCylinder(length = 3.0, width = 0.1, height = 0.2, n = 20);
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 3.6e-15
#VPL.render(m, wireframe = true, normals = true)

# Create a hollow cylinder using affine maps
scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0));
c3 = VPL.HollowCylinder(scale,n = 20);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a cylinder ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0))
    m = VPL.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20)
    VPL.Geom.HollowCylinder!(m, scale, n = 20)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
#VPL.render(m2, wireframe = true, normals = true)

# Construct hollow cones using a turtle
hc = VPL.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20);
t = VPL.Turtle(Float64)
VPL.HollowCylinder!(t; length = 2.0, width = 1.0, height = 1.0, n = 20, move = true) 
@test VPL.geoms(t) == hc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,2)

t = VPL.Turtle(Float64)
VPL.HollowCylinder!(t; length = 2.0, width = 1.0, height = 1.0, n = 20, move = false);
@test VPL.geoms(t) == hc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,0)


end