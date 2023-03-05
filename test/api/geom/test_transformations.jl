using VPL
using Test

let

m = Rectangle();
m_area = area(m)

# Scaling
m2 = deepcopy(m);
VPL.scale!(m2, VPL.Vec(1.0, 1.0, 2.0))
area(m2) == 2*m_area

# Rotating around x axis
m3 = deepcopy(m);
VPL.rotatex!(m3, 45.0)
@test all(getindex.(m3.vertices, 1) .≈ getindex.(m.vertices, 1))
@test all(getindex.(m3.vertices, 2) .!== getindex.(m.vertices, 2))
@test all(getindex.(m3.vertices, 3) .!== getindex.(m.vertices, 3))
@test all(m3.normals .≈ m.normals)
VPL.rotatex!(m3, -45.0)
@test all(m3.vertices .≈ m.vertices)

# Rotating around y axis
m3 = deepcopy(m);
VPL.rotatey!(m3, 45.0)
@test all((getindex.(m3.vertices, 1) .!== getindex.(m.vertices, 1)) .== [false, true, true, false])
@test all(getindex.(m3.vertices, 2) .≈ getindex.(m.vertices, 2))
@test all((getindex.(m3.vertices, 3) .!== getindex.(m.vertices, 3)) .== [false, true, true, false])
@test all(m3.normals .!== m.normals)
VPL.rotatey!(m3, -45.0)
@test all(m3.vertices .≈ m.vertices)

# Rotating around z axis
m3 = deepcopy(m);
VPL.rotatez!(m3, 45.0)
@test all((getindex.(m3.vertices, 1) .!== getindex.(m.vertices, 1)))
@test all(getindex.(m3.vertices, 2) .!== getindex.(m.vertices, 2))
@test all(getindex.(m3.vertices, 3) .≈ getindex.(m.vertices, 3))
@test all(m3.normals .!== m.normals)
VPL.rotatez!(m3, -45.0)
@test all(m3.vertices .≈ m.vertices)

# Translating along the x axis
m4 = deepcopy(m);
VPL.translate!(m4, VPL.Vec(2.0, 0.0, 0.0))
@test all((getindex.(m4.vertices, 1) .!== getindex.(m.vertices, 1)))
@test all(getindex.(m4.vertices, 2)  .≈ getindex.(m.vertices, 2))
@test all(getindex.(m4.vertices, 3)  .≈ getindex.(m.vertices, 3))
@test all(m4.normals .≈ m.normals)
VPL.translate!(m4, VPL.Vec(-2.0, 0.0, 0.0))
@test all(m4.vertices .≈ m.vertices)

# Translating along the y axis
m4 = deepcopy(m);
VPL.translate!(m4, VPL.Vec(0.0, 2.0, 0.0))
@test all((getindex.(m4.vertices, 1) .≈ getindex.(m.vertices, 1)))
@test all(getindex.(m4.vertices, 2)  .!== getindex.(m.vertices, 2))
@test all(getindex.(m4.vertices, 3)  .≈ getindex.(m.vertices, 3))
@test all(m4.normals .≈ m.normals)
VPL.translate!(m4, VPL.Vec(0.0, -2.0, 0.0))
@test all(m4.vertices .≈ m.vertices)

# Translating along the z axis
m4 = deepcopy(m);
VPL.translate!(m4, VPL.Vec(0.0, 0.0, 2.0))
@test all((getindex.(m4.vertices, 1) .≈ getindex.(m.vertices, 1)))
@test all(getindex.(m4.vertices, 2)  .≈ getindex.(m.vertices, 2))
@test all(getindex.(m4.vertices, 3)  .!== getindex.(m.vertices, 3))
@test all(m4.normals .≈ m.normals)
VPL.translate!(m4, VPL.Vec(0.0, 0.0, -2.0))
@test all(m4.vertices .≈ m.vertices)

# Transformation via a turtle
t = VPL.Turtle(Float64);
ru!(t, 45.0)
ra!(t, 45.0)
rh!(t, 45.0)
f!(t, 1.0)
Mesh!(t, m; scale = Vec(2.0, 2.0, 2.0))
m5 = deepcopy(m);
VPL.scale!(m5, VPL.Vec(2.0, 2.0, 2.0))
VPL.rotate!(m5, x = t.coords.up, y = t.coords.arm, z = t.coords.head)
VPL.translate!(m5, t.coords.pos)
@test all(m5.vertices .≈ t.geoms.vertices)
@test all(m5.normals .≈ t.geoms.normals)
@test all(m5.faces .≈ t.geoms.faces)

end
