import VPL
const G = VPL.Geom
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard ellipse primitive
e = VPL.Ellipse(length = 2.0, width = 2.0, n = 10);
@test e isa VPL.Mesh
@test abs(VPL.area(e)/pi - 1.0) < 0.13
@test VPL.nvertices(e) == 11
@test VPL.ntriangles(e) == 10
@test all(e.normals[1] .== [1.0, 0.0, 0.0])
VPL.render(e, wireframe = true, normals = true)

# Check a different precision works
e = VPL.Ellipse(length = 2f0, width = 2f0, n = 10);
@test e isa VPL.Mesh
@test abs(VPL.area(e)/Float32(pi) - 1f0) < 0.13f0
VPL.render(e, wireframe = true, normals = true)

# Mergin two meshes
e = VPL.Ellipse(length = 2.0, width = 2.0, n = 10);
e2 = VPL.Ellipse(length = 3.0, width = 0.1, n = 10);
function foo()
    e = VPL.Ellipse(length = 2.0, width = 2.0, n = 10)
    e2 = VPL.Ellipse(length = 3.0, width = 0.1, n = 10)
    m = VPL.Mesh([e,e2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(e) + VPL.nvertices(e2)
@test VPL.ntriangles(m) == VPL.ntriangles(e) + VPL.ntriangles(e2)
@test abs(VPL.area(m) - (VPL.area(e) + VPL.area(e2))) < 3e-15
VPL.render(m, wireframe = true, normals = true)

# Create a ellipse using affine maps
scale = LinearMap(SDiagonal(1.0, 0.05, 1.5));
e3 = VPL.Ellipse(scale, n = 10);
@test e3.normals == e2.normals
@test e3.vertices ≈ e2.vertices
@test e3.faces == e2.faces

# Create a ellipse ussing affine maps and add it to an existing mesh
function foo2()
    scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
    m = VPL.Ellipse(length = 2.0, width = 2.0, n = 10)
    VPL.Geom.Ellipse!(m, scale, n = 10)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, wireframe = true, normals = true)


# Construct ellipses using a turtle
e = G.Ellipse(length = 2.0, width = 2.0, n = 10);
t = G.Turtle(Float64)
G.Ellipse!(t; length = 2.0, width = 2.0, n = 10, move = true) 
@test G.geoms(t) == e
@test G.pos(t) == G.Vec{Float64}(0,0,2)

t = G.Turtle(Float64)
G.Ellipse!(t; length = 2.0, width = 2.0, n = 10, move = false);
@test G.geoms(t) == e
@test G.pos(t) == G.Vec{Float64}(0,0,0)

end