import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard hollow cone primitive
c = VPL.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10);
@test c isa VPL.Mesh
@test abs(VPL.area(c) - sqrt(4 + 0.25)*pi/2) < 0.07
@test VPL.nvertices(c) == 11
@test VPL.ntriangles(c) == 10
@test length(c.normals) == 10
VPL.render(c, wireframe = true, normals = true)

# Check that it works for different floating point precisions
c = VPL.HollowCone(length = 2f0, width = 1f0, height = 1f0, n = 10);
@test c isa VPL.Mesh
@test abs(VPL.area(c) - sqrt(4 + 0.25)*pi/2) < 0.07
@test VPL.nvertices(c) == 11
@test VPL.ntriangles(c) == 10
@test length(c.normals) == 10
VPL.render(c, wireframe = true, normals = true)

# Merging two meshes
c = VPL.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10);
c2 = VPL.HollowCone(length = 3.0, width = 0.1, height = 0.2, n = 10);
function foo()
    c = VPL.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
    c2 = VPL.HollowCone(length = 3.0, width = 0.1, height = 0.2, n = 10)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 9e-16
VPL.render(m, wireframe = true, normals = true)

# Create a hollow cone using affine maps
scale = LinearMap(SDiagonal(0.1,0.05,3.0));
c3 = VPL.HollowCone(scale, n = 10);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a cone ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.1,0.05,3.0))
    m = VPL.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
    VPL.Geom.HollowCone!(m, scale, n = 10)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)


# Construct hollow cones using a turtle
hc = VPL.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10);
t = VPL.MTurtle(Float64)
VPL.HollowCone!(t; length = 2.0, width = 1.0, height = 1.0, n = 10, move = true) 
@test VPL.geoms(t) == hc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,2)

t = VPL.MTurtle(Float64)
VPL.HollowCone!(t; length = 2.0, width = 1.0, height = 1.0, n = 10, move = false);
@test VPL.geoms(t) == hc
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,0)


end