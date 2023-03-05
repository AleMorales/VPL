import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard hollow frustum primitive
c = VPL.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20);
@test c isa VPL.Mesh;
exact_area = (pi + 0.5pi)/2*sqrt(2^2 + 0.25^2);
@test abs(VPL.area(c) - exact_area) < 0.1
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
VPL.render(c, wireframe = true, normals = true)

# Check that it works at lower precision
c = VPL.HollowFrustum(length = 2f0, width = 1f0, height = 1f0, ratio = 0.5f0, n = 20);
@test c isa VPL.Mesh;
exact_area = (pi + 0.5pi)/2*sqrt(2^2 + 0.25^2);
@test abs(VPL.area(c) - exact_area) < 0.1
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
VPL.render(c, wireframe = true, normals = true)

# Mergin two meshes
c = VPL.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20);
c2 = VPL.HollowFrustum(length = 3.0, width = 0.1, height = 0.2, ratio = 1/10, n = 20);
function foo()
    c = VPL.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
    c2 = VPL.HollowFrustum(length = 3.0, width = 0.1, height = 0.2, ratio = 1/10, n = 20)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 1e-15
VPL.render(m, wireframe = true, normals = true)

# Create a hollow frustum using affine maps
scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0));
c3 = VPL.HollowFrustum(1/10,scale, n = 20);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a frustum ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0))
    m = VPL.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
    VPL.Geom.HollowFrustum!(m, 1/10, scale, n = 20)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)

# Construct hollow frustums using a turtle
hf = VPL.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20);
t = VPL.Turtle(Float64)
VPL.HollowFrustum!(t; length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20, move = true) 
@test VPL.geoms(t) == hf
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,2)

t = VPL.Turtle(Float64)
VPL.HollowFrustum!(t; length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20, move = false);
@test VPL.geoms(t) == hf
@test VPL.pos(t) == VPL.Vec{Float64}(0,0,0)

end