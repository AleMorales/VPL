import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let


# Standard hollow frustum primitive
c = VPL.HollowFrustum(l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10);
@test c isa VPL.Mesh;
exact_area = (pi + 0.5pi)/2*sqrt(2^2 + 0.25^2);
@test abs(VPL.area(c) - exact_area) < 0.1
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
VPL.render(c, :green, wireframe = true, normals = true)

# Check that it works at lower precision
c = VPL.HollowFrustum(l = 2f0, w = 1f0, h = 1f0, ratio = 0.5f0, n = 10);
@test c isa VPL.Mesh;
exact_area = (pi + 0.5pi)/2*sqrt(2^2 + 0.25^2);
@test abs(VPL.area(c) - exact_area) < 0.1
@test VPL.nvertices(c) == 20
@test VPL.ntriangles(c) == 20
@test length(c.normals) == 20
VPL.render(c, :green, wireframe = true, normals = true)

# Mergin two meshes
c = VPL.HollowFrustum(l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10);
c2 = VPL.HollowFrustum(l = 3.0, w = 0.1, h = 0.2, ratio = 1/10, n = 10);
function foo()
    c = VPL.HollowFrustum(l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10)
    c2 = VPL.HollowFrustum(l = 3.0, w = 0.1, h = 0.2, ratio = 1/10, n = 10)
    m = VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test abs(VPL.area(m) - (VPL.area(c) + VPL.area(c2))) < 1e-15
VPL.render(m, :green, wireframe = true, normals = true)

# Create a hollow frustum using affine maps
scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0));
c3 = VPL.HollowFrustum(1/10,scale, n = 10);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a frustum ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(0.2/2,0.1/2,3.0))
    m = VPL.HollowFrustum(l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10)
    VPL.Geom.HollowFrustum!(m, 1/10,scale, n = 10)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, :green, wireframe = true, normals = true)

# Construct hollow frustums using a turtle
hf = G.HollowFrustum(l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10);
t = G.MTurtle{Float64}()
G.HollowFrustum!(t; l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10, move = true) 
@test G.geoms(t) == hf
@test G.pos(t) == G.Vec{Float64}(0,0,2)

t = G.MTurtle{Float64}()
G.HollowFrustum!(t; l = 2.0, w = 1.0, h = 1.0, ratio = 0.5, n = 10, move = false);
@test G.geoms(t) == hf
@test G.pos(t) == G.Vec{Float64}(0,0,0)

end