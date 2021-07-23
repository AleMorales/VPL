import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard hollow cone primitive
c = VPL.HollowCone(l = 2.0, w = 1.0, h = 1.0, n = 10);
@test c isa VPL.Mesh
@test abs(VPL.area(c) - sqrt(4 + 0.25)*pi/2) < 0.07
@test VPL.nvertices(c) == 11
@test VPL.ntriangles(c) == 10
@test length(c.normals) == 10
VPL.render(c, :green, wireframe = true, normals = true)

# Check that it works for different floating point precisions
c = VPL.HollowCone(l = 2f0, w = 1f0, h = 1f0, n = 10);
@test c isa VPL.Mesh
@test abs(VPL.area(c) - sqrt(4 + 0.25)*pi/2) < 0.07
@test VPL.nvertices(c) == 11
@test VPL.ntriangles(c) == 10
@test length(c.normals) == 10
VPL.render(c, :green, wireframe = true, normals = true)

# Mergin two meshes
c = VPL.HollowCone(l = 2.0, w = 1.0, h = 1.0, n = 10);
c2 = VPL.HollowCone(l = 3.0, w = 0.1, h = 0.2, n = 10);
function foo()
    c = VPL.HollowCone(l = 2.0, w = 1.0, h = 1.0, n = 10)
    c2 = VPL.HollowCone(l = 3.0, w = 0.1, h = 0.2, n = 10)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 9e-16
VPL.render(m, :green, wireframe = true, normals = true)

# Create a hollow cone using affine maps
scale = LinearMap(SDiagonal(0.1,0.05,3.0));
c3 = VPL.HollowCone(scale, n = 10);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a cone ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.1,0.05,3.0))
    m = VPL.HollowCone(l = 2.0, w = 1.0, h = 1.0, n = 10)
    VPL.Geom.HollowCone!(m, scale, n = 10)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, :green, wireframe = true, normals = true)


# Construct hollow cones using a turtle
hc = G.HollowCone(l = 2.0, w = 1.0, h = 1.0, n = 10);
t = G.MTurtle{Float64}()
G.HollowCone!(t; l = 2.0, w = 1.0, h = 1.0, n = 10, move = true) 
@test G.geoms(t) == hc
@test G.pos(t) == G.Vec{Float64}(0,0,2)

t = G.MTurtle{Float64}()
G.HollowCone!(t; l = 2.0, w = 1.0, h = 1.0, n = 10, move = false);
@test G.geoms(t) == hc
@test G.pos(t) == G.Vec{Float64}(0,0,0)


end