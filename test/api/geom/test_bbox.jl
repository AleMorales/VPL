import VPL
using Test

let

# Standard bbox primitive
b = VPL.BBox(VPL.Geom.Vec(0.0, 0.0, 0.0), VPL.Geom.Vec(1.0, 1.0, 1.0))
@test b isa VPL.Mesh
@test VPL.area(b) == 6.0
@test VPL.nvertices(b) == 8
@test VPL.ntriangles(b) == 12
VPL.render(b, :green, wireframe = true, normals = true)

# Check that it works with lower precision
b = VPL.BBox(VPL.Geom.Vec(0f0, 0f0, 0f0), VPL.Geom.Vec(1f0, 1f0, 1f0))
@test b isa VPL.Mesh
@test VPL.area(b) == 6f0
@test VPL.nvertices(b) == 8
@test VPL.ntriangles(b) == 12
VPL.render(b, :green, wireframe = true, normals = true)

end