import VPL
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

# Standard cube primitive
c = VPL.HollowCube(l = 1.0, w = 1.0, h = 1.0);
@test c isa VPL.Mesh
@test VPL.area(c) === 4.0
@test VPL.nvertices(c) == 8
@test VPL.ntriangles(c) == 8
VPL.render(c, :green, wireframe = true, normals = true)

# Check a different precision works 
c = VPL.HollowCube(l = 1f0, w = 1f0, h = 1f0);
@test c isa VPL.Mesh
@test VPL.area(c) === 4f0
@test VPL.nvertices(c) == 8
@test VPL.ntriangles(c) == 8
VPL.render(c, :green, wireframe = true, normals = true)

# Mergin two meshes
c2 = VPL.HollowCube(l = 0.5, w = 0.5, h = 3.0);
function foo()
    c2 = VPL.HollowCube(l = 0.5, w = 0.5, h = 3.0)    
    c = VPL.HollowCube(l = 1.0, w = 1.0, h = 1.0)
    VPL.Mesh([c,c2])
end
m = foo();
@test VPL.nvertices(m) == VPL.nvertices(c) + VPL.nvertices(c2)
@test VPL.ntriangles(m) == VPL.ntriangles(c) + VPL.ntriangles(c2)
@test VPL.area(m) == VPL.area(c) + VPL.area(c2)
VPL.render(m, :green, wireframe = true, normals = true)

# Create a box using affine maps
scale = LinearMap(SDiagonal(3/2, 0.5/2, 0.5));
c3 = VPL.HollowCube(scale);
@test c3.normals == c2.normals
@test c3.vertices == c2.vertices
@test c3.faces == c2.faces

# Create a box ussing affine maps and add it to an existing mesh
function foo2()
    scale1 = LinearMap(SDiagonal(0.5, 0.5, 1.0))
    scale2 = LinearMap(SDiagonal(1.5, 0.25, 0.5))
    m = VPL.Mesh()
    VPL.Geom.HollowCube!(m, scale1)
    VPL.Geom.HollowCube!(m, scale2)
    m
end
m2 = foo2();
@test m2.vertices == m.vertices
@test m2.normals == m.normals
@test m2.faces == m.faces
VPL.render(m2, :green, wireframe = true, normals = true)


# Construct hollow cones using a turtle
hc = G.HollowCube(l = 2.0, w = 1.0, h = 1.0);
t = G.MTurtle{Float64}()
G.HollowCube!(t; l = 2.0, w = 1.0, h = 1.0, move = true) 
@test G.geoms(t) == hc
@test G.pos(t) == G.Vec{Float64}(0,0,2)

t = G.MTurtle{Float64}()
G.HollowCube!(t; l = 2.0, w = 1.0, h = 1.0, move = false);
@test G.geoms(t) == hc
@test G.pos(t) == G.Vec{Float64}(0,0,0)

end