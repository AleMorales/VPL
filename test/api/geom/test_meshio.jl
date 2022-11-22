import VPL
using Test

let

# Binary STL
c = VPL.SolidCube(length = 0.5, width = 2.0, height = 1/3)
VPL.savemesh(c, fileformat = :STL_BINARY, filename = "api/geom/meshes/r.bstl")
c2 = VPL.loadmesh("api/geom/meshes/r.bstl")
@test VPL.area(c) ≈ VPL.area(c2)
@test VPL.ntriangles(c) == VPL.ntriangles(c2)
@test VPL.nvertices(c2) == VPL.ntriangles(c2)*3
@test c.normals == c2.normals
@test VPL.BBox(c) ≈ VPL.BBox(c2)

# ASCII STL
VPL.savemesh(c, fileformat = :STL_ASCII, filename = "api/geom/meshes/r.astl")
c2 = VPL.loadmesh("api/geom/meshes/r.astl")
@test isapprox(VPL.area(c), VPL.area(c2), atol = 4e-7)
@test VPL.ntriangles(c) == VPL.ntriangles(c2)
@test VPL.nvertices(c2) == VPL.ntriangles(c2)*3
@test c.normals ≈ c2.normals
@test isapprox(VPL.BBox(c), VPL.BBox(c2), atol = 4e-7)

# BINARY PLY
VPL.savemesh(c, fileformat = :PLY_BINARY, filename = "api/geom/meshes/r.bply")
# c2 = loadmesh("api/geom/meshes/r.bply")
# (MeshIO does not support Binary PLY formats)

# ASCII PLY
VPL.savemesh(c, fileformat = :PLY_ASCII, filename = "api/geom/meshes/r.aply")
c2 = VPL.loadmesh("api/geom/meshes/r.aply")
@test VPL.area(c) ≈ VPL.area(c2)
@test VPL.ntriangles(c) == VPL.ntriangles(c2)
@test VPL.nvertices(c) == VPL.nvertices(c2)
@test c.normals ≈ c2.normals
@test VPL.BBox(c) ≈ VPL.BBox(c2)

# OBJ
VPL.savemesh(c, fileformat = :OBJ, filename = "api/geom/meshes/r.obj")
c2 = VPL.loadmesh("api/geom/meshes/r.obj")
@test VPL.area(c) ≈ VPL.area(c2)
@test VPL.ntriangles(c) == VPL.ntriangles(c2)
@test VPL.nvertices(c) == VPL.nvertices(c2)
@test c.normals ≈ c2.normals
@test VPL.BBox(c) ≈ VPL.BBox(c2)


end