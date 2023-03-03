import VPL.RayTracing as RT
import VPL
using Test
import LinearAlgebra: ⋅, norm
import Random
using StaticArrays

# Modules needed to test ray tracing of graphs
module sn
    using VPL
    struct E64 <: Node
        length::Float64
        mat::VPL.RayTracing.Black{1}
    end
    struct E32 <: Node
        length::Float32
        mat::VPL.RayTracing.Black{1}
    end
end
import .sn


module btree
    import VPL
    # Meristem
    struct Meristem <: VPL.Node end
    # Node
    struct Node <: VPL.Node end
    # Internode
    mutable struct Internode <: VPL.Node
        length::Float64
        mat::VPL.Lambertian{1}
    end
    # Graph-level variables
    struct treeparams
        growth::Float64
    end
end
import .btree

let

##### Test Ray, Triangle and AABB ##### 

# Simple ray construction (check FT)
o64 = RT.Z(Float64)
dir64 = .-RT.Z(Float64)
r64 = RT.Ray(o64, dir64)
@test r64.o == o64
@test r64.dir == dir64

o32 = RT.Z(Float32)
dir32 = .-RT.Z(Float32)
r32 = RT.Ray(o32, dir32)
@test r32.o == o32
@test r32.dir == dir32

# Simple Triangle construction (check FT)
FT = Float64
t64 = RT.Triangle(RT.O(FT), RT.X(FT), RT.Y(FT))
@test t64.p == RT.O(FT)
@test t64.e1 == RT.X(FT)
@test t64.e2 == RT.Y(FT)
@test t64.n == RT.Z(FT)

FT = Float32
t32 = RT.Triangle(RT.O(FT), RT.X(FT), RT.Y(FT))
@test t32.p == RT.O(FT)
@test t32.e1 == RT.X(FT)
@test t32.e2 == RT.Y(FT)
@test t32.n == RT.Z(FT)

# Simple AABB construction (check FT)
FT = Float64
t64 = RT.Triangle(RT.Z(FT), RT.X(FT), RT.Y(FT))
aabb64 = RT.AABB(t64)
@test all(aabb64.min .≈ zeros(FT,3))
@test all(aabb64.max .≈ ones(FT,3))

FT = Float32
t32 = RT.Triangle(RT.Z(FT), RT.X(FT), RT.Y(FT))
aabb32 = RT.AABB(t32)
@test all(aabb32.min .≈ zeros(FT,3))
@test all(aabb32.max .≈ ones(FT,3))

# Ray triangle intersection - 1
r1 = RT.Ray(RT.Vec(0.1,0.1,1), .-RT.Z())
t1 = RT.Triangle(RT.Vec(0,0,0.5), RT.Vec(1,0,0.5), RT.Vec(0,1,0.5))
i1 = RT.intersect(r1, t1)
@test i1[1]
@test i1[2] ≈ 0.5
@test !i1[3]

# Ray triangle intersection - 2
r2 = RT.Ray(RT.Vec(0.1,0.1,1), .-RT.Z())
t2 = RT.Triangle(RT.Vec(0,0,0.5), RT.Vec(0,1,0.5), RT.Vec(1,0,0.5))
i2 = RT.intersect(r2, t2)
@test i2[1]
@test i2[2] ≈ 0.5
@test i2[3]

# Ray triangle intersection - 3
r3 = RT.Ray(RT.Vec(0.0,0,1), .-RT.Z())
t3 = RT.Triangle(RT.Vec(0,0,0.5), RT.Vec(0,1,0.5), RT.Vec(1,0,0.5))
i3 = RT.intersect(r3, t3)
@test !i3[1]

# Ray triangle intersection - 4
r4 = RT.Ray(RT.Vec(-0.1,-0.1,1), .-RT.Z())
t4 = RT.Triangle(RT.Vec(0,0,0.5), RT.Vec(0,1,0.5), RT.Vec(1,0,0.5))
i4 = RT.intersect(r4, t4)
@test !i4[1]

# Ray AABB intersection - 1
r1 = RT.Ray(RT.Vec(0.1,0.1,1), .-RT.Z())
a1 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,1,1.0))
i1 = RT.intersect(r1, a1)
@test i1[1]
@test i1[2] ≈ 0.0

# Ray AABB intersection - 2
r2 = RT.Ray(RT.Vec(0.1,0.1,2), .-RT.Z())
a2 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,1,1.0))
i2 = RT.intersect(r2, a2)
@test i2[1]
@test i2[2] ≈ 1.0

# Ray AABB intersection - 3
r3 = RT.Ray(RT.Vec(0.1,0.1,0.5), .-RT.Z())
a3 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,1,1.0))
i3 = RT.intersect(r3, a3)
@test i3[1]
@test i3[2] ≈ -0.5

# Ray AABB intersection - 4
r4 = RT.Ray(RT.Vec(2.0,0.1,0.5), .-RT.Z())
a4 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,1,1.0))
i4 = RT.intersect(r4, a4)
@test !i4[1]

# Area of a triangle
@test RT.area(t4) ≈ 0.5

# Axes of a triangle
axs = RT.axes(t4)
@test axs[1] ⋅ axs[2] ≈ 0.0
@test axs[1] ⋅ axs[3] ≈ 0.0
@test axs[2] ⋅ axs[3] ≈ 0.0
@test all(norm.(axs) .≈ [1,1,1.0])

# Generate a random point from within a triangle
rng = Random.MersenneTwister(123456789)
p = RT.generate_point(t4,rng)
@test p isa RT.Vec

# Area of an AABB
a1 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,1,1.0))
a2 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(2,2,2.0))
@test RT.area(a1) ≈ 6.0
@test RT.area(a2) ≈ 24.0

# Center of an AABB
@test RT.center(a1) ≈ RT.Vec(0.5,0.5,0.5)
@test RT.center(a2) ≈ RT.Vec(1,1,1.0)

# Longest axis of an AABB
@test RT.longest(RT.AABB(RT.Vec(0.0,0,0), RT.Vec(3,2,1.0))) == 1
@test RT.longest(RT.AABB(RT.Vec(0.0,0,0), RT.Vec(2,3,1.0))) == 2
@test RT.longest(RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,2,3.0))) == 3

# Height of an AABB
@test RT.height(RT.AABB(RT.Vec(0.0,0,0), RT.Vec(3,2,1.0))) ≈ 1.0
@test RT.height(RT.AABB(RT.Vec(0.0,0,0), RT.Vec(1,2,3.0))) ≈ 3.0

# Center point on the top face of an AABB
@test RT.topcenter(a1) ≈ RT.Vec(0.5,0.5,1)

# Extract 8 vertices from an AABB
verts = RT.vertices(a1)
@test length(verts) == 8
@test verts[1] ≈ RT.Vec(0,0,0)

# Test for an empty AABB (basically a point)
a0 = RT.AABB(RT.Vec(0.0,0,0), RT.Vec(0,0,0.0))
RT.isempty(a0)

# AABB around vector of triangles
ta = RT.Triangle(RT.Vec(0,0,0.5), RT.Vec(0,1,0.5), RT.Vec(1,0,0.5))
tb = RT.Triangle(RT.Vec(1,0,0.5), RT.Vec(0,1,0.5), RT.Vec(-1,0,0.5))
aabb = RT.AABB([ta, tb])
@test aabb.min ≈ RT.Vec(-1.0, 0.0, 0.5)
@test aabb.max ≈ RT.Vec(1.0, 1.0, 0.5)

# Merge a list of AABBs
aabb1 = RT.AABB([ta, tb])
aabb2 = RT.AABB([RT.AABB(ta), RT.AABB(tb)])
@test aabb1 == aabb2

##### Test light source geometry ##### 

# Point source
source64 = RT.PointSource(RT.Vec(0.0, 0.0, 1.0))
@test source64 isa RT.SourceGeometry
@test source64.loc == RT.Vec(0.0, 0.0, 1.0)
@test eltype(source64.loc) == Float64

source32 = RT.PointSource(RT.Vec(0f0, 0f0, 1f0))
@test source32 isa RT.SourceGeometry
@test source32.loc == RT.Vec(0f0, 0f0, 1f0)
@test eltype(source32.loc) == Float32

rng = Random.MersenneTwister(123456789)
@test RT.generate_point(source32, rng) == source32.loc

# Line source
source64 = RT.LineSource(RT.Vec(0.0, 0.0, 1.0), RT.X(Float64))
@test source64 isa RT.SourceGeometry
@test source64.p == RT.Vec(0.0, 0.0, 1.0)
@test source64.line == RT.X(Float64)
@test eltype(source64.p) == Float64

source32 = RT.LineSource(RT.Vec(0f0, 0f0, 1f0),  RT.X(Float32))
@test source32 isa RT.SourceGeometry
@test source32.p == RT.Vec(0f0, 0f0, 1f0)
@test source32.line == RT.X(Float32)
@test eltype(source32.p) == Float32

rng = Random.MersenneTwister(123456789)
for i in 1:10
    local p = RT.generate_point(source32, rng)
    dist = p .- source32.p
    norm(dist) <= norm(source32.line)
    @test dist ⋅ source32.line ≈ norm(dist)*norm(source32.line)
end

# Area source
r = VPL.Rectangle(length = 2.0, width = 2.0);
source = RT.AreaSource(r)
source.tvec isa Vector
@test first(source.tvec) isa RT.Triangle
import StatsBase
@test source.areas isa StatsBase.Weights
@test sum(source.areas) ≈ 2*2

for i in 1:10
    local p = RT.generate_point(source, rng)
    @test p[1] ≈ 0.0
    @test -1.0 <= p[2] <= 1.0
    @test 0.0 <= p[3] <= 2.0
end

r = VPL.Rectangle(length = 3.0, width = 2.5);
source = RT.AreaSource(r)
@test sum(source.areas) ≈ 3*2.5
for i in 1:10
    local p = RT.generate_point(source, rng)
    @test p[1] ≈ 0.0
    @test -1.25 <= p[2] <= 1.25
    @test 0.0 <= p[3] <= 3.0
end

##### Test light source angle ##### 

# Fixed angle source
source = RT.FixedSource(0.0, 0.0)
@test source.dir ≈ RT.Vec(0, 0, -1.0)
@test RT.generate_direction(source, rng) == source.dir

# Lambertian source
source1 = RT.LambertianSource(RT.X(), RT.Y(), RT.Z())
source2 = RT.LambertianSource((RT.X(), RT.Y(), RT.Z()))
@test source1 == source2

for i in 1:10
    local p = RT.generate_direction(source1, rng)
    @test p[3] > 0
end


##### Test light source - Point & Fixed ##### 
geom = RT.PointSource(RT.Vec(0.0, 0.0, 1.0))
angle = RT.FixedSource(0.0, 0.0)

# Single wavelength
source = RT.Source(geom, angle, 1.0, 1_000)
@test source isa RT.Source
@test RT.get_nw(source) == 1
@test RT.generate_point(source, rng) == geom.loc
@test RT.generate_direction(source, rng) == angle.dir
power = [0.0]
ray = RT.shoot_ray!(source, power, rng)
@test power == [1.0]
@test ray.o == geom.loc
@test ray.dir == angle.dir

# Multiple wavelengths
source = RT.Source(geom, angle, (1.0, 2.0), 1_000)
@test source isa RT.Source
@test RT.get_nw(source) == 2
@test RT.generate_point(source, rng) == geom.loc
@test RT.generate_direction(source, rng) == angle.dir
power = [0.0, 1.0]
ray = RT.shoot_ray!(source, power, rng)
@test power == [1.0, 2.0]
@test ray.o == geom.loc
@test ray.dir == angle.dir

##### Test directional light source ##### 
gbox = RT.AABB(RT.O(), RT.Vec(1.0, 1.0, 1.0))
dsource = RT.DirectionalSource(gbox, θ = 0.0, Φ = 0.0, radiosity = 1.0, nrays = 1_000)
@test dsource isa RT.Source
@test dsource.geom isa RT.Directional

##### Test materials ##### 

# Lambertian material
mat = RT.Lambertian(τ = 0.0, ρ = 0.3)
@test mat isa RT.Material
@test length(VPL.power(mat)) == 1
@test all(VPL.power(mat) .== zeros(1))
power = [1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == [0.3]
@test mode == :ρ
mat.power[1] = 8.0
RT.reset!(mat)
@test mat.power[1] == 0.0

mat = RT.Lambertian(τ = 0.3, ρ = 0.0)
@test mat isa RT.Material
@test length(mat.power) == 1
power = [1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == [0.3]
@test mode == :τ

mat = RT.Lambertian(τ = 0.3, ρ = 0.7)
@test mat isa RT.Material
@test length(mat.power) == 1
power = [1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == [1.0]
@test mode == :ρ || mode == :τ

mat = RT.Lambertian(τ = (0.0, 0.0), ρ = (0.3, 0.3))
@test mat isa RT.Material
@test length(VPL.power(mat)) == 2
@test all(mat.power .== zeros(2))
power = [1.0, 1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == [0.3, 0.3]
@test mode == :ρ
mat.power[1] = 8.0
mat.power[2] = 2.0
RT.reset!(mat)
@test all(mat.power .== zeros(2))

mat = RT.Lambertian(τ = (0.3, 0.3), ρ = (0.0, 0.0))
@test mat isa RT.Material
@test length(mat.power) == 2
power = [1.0, 1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == [0.3, 0.3]
@test mode == :τ

mat = RT.Lambertian(τ = (0.3, 0.7), ρ = (0.7, 0.3))
@test mat isa RT.Material
@test length(mat.power) == 2
power = [1.0, 1.0]
mode, coef = RT.choose_outcome(mat, power, rng)
@test coef == 2*[0.3, 0.7] || coef == 2*[0.7, 0.3]
@test mode == :ρ || mode == :τ

# Phong material
mat = RT.Phong(τ = 0.2, ρd = 0.3, ρsmax = 0.7, n = 2)
@test mat isa RT.Material
mat = RT.Phong(τ = (0.2, 0.2), ρd = (0.3, 0.3), ρsmax = (0.7, 0.7), n = 2)
@test length(mat.τ) == 2

# Black material
mat = RT.Black(1)
@test all(mat.power .== zeros(1))
mat = RT.Black(3)
@test all(mat.power .== zeros(3))

# Sensor material
mat = RT.Sensor(1)
@test all(mat.power .== zeros(1))
mat = RT.Sensor(3)
@test all(mat.power .== zeros(3))


##### Test manual construction of a scene ##### 
r = VPL.Rectangle(length = 2.0, width = 2.0);
ids = [1,1]
mats = [RT.Sensor(1)]
scene = RT.RTScene(mesh = r, ids = ids, materials = mats)
scene1 = deepcopy(scene)
@test scene isa RT.RTScene
@test length(scene.triangles) == 2
@test length(scene.materials) == 1
@test scene.ids == [1,1]

RT.add!(scene, mesh = r, material = RT.Sensor(1))
@test length(scene.triangles) == 4
@test scene.ids == [1,1,2,2]
@test length(scene.materials) == 2

scene2 = RT.RTScene([scene, scene1])
@test length(scene2.triangles) == 6
@test scene2.ids == [1,1,2,2,3,3]
@test length(scene2.materials) == 3

##### Test turtle-based construction of a scene ##### 
# Koch curve @ 64 bits
L = 1.0
axiom = sn.E64(L, RT.Black(1)) + VPL.RU(120.0) + sn.E64(L, RT.Black(1)) + 
        VPL.RU(120.0) + sn.E64(L, RT.Black(1))
function Kochsnowflake(x)
    L = data(x).length
    sn.E64(L/3, RT.Black(1)) + VPL.RU(-60.0) + sn.E64(L/3, RT.Black(1)) + 
    VPL.RU(120.0) + sn.E64(L/3, RT.Black(1)) + VPL.RU(-60.0) + 
    sn.E64(L/3, RT.Black(1))
end
function VPL.feedgeom!(turtle::VPL.MTurtle, e::sn.E64)
    VPL.HollowCylinder!(turtle, length = e.length, width = e.length/10, 
                    height = e.length/10, move = true)
    return nothing
end
function RT.feedmaterial!(turtle::RT.RTTurtle, e::sn.E64)
    VPL.feedmaterial!(turtle, e.mat)
    return nothing
end
rule = VPL.Rule(sn.E64, rhs = Kochsnowflake)
Koch = VPL.Graph(axiom = axiom, rules = Tuple(rule))
scene = RT.RTScene(Koch)
@test length(scene.materials) == 3
@test eltype(scene.materials) == RT.Material # type erasure going on, problem is RTTurtle...
@test length(scene.ids) == length(scene.triangles)
@test maximum(scene.ids) == length(scene.materials)
@test length(scene.triangles) == 120


##### Test intersection of specific rays with Naive acc ##### 

# Intersection of a rectangle from a directional light source downwards
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 1.0, width = 1.0);
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays = RT.trace!(rtobj)

@test nrays == nrays
pow_abs = material[1].power[1]
pow_gen = source.power[1]*source.nrays
@test pow_abs ≈ pow_gen

# Double check orientation of the light source
# VPL.render(rect, axes = false)
# VPL.render!(source)

##### Test intersection code of specific rays with Naive acc + grid cloner ##### 

##### Using black materials #####

# Intersection of a rectangle from a directional light source downwards
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 2.0, width = 1.0)
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1, nx = 3, ny = 3);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
pow_abs = material[1].power[1]
pow_gen = source.power[1]*source.nrays
@test pow_abs ≈ pow_gen

# Double check orientation of the light source
# VPL.render(rect, axes = false)
# VPL.render!(source)

# Intersection of a rectangle from a directional light source that is horizontal
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 2.0, width = 1.0)
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = π/2, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1, nx = 3, ny = 3, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
pow_abs = material[1].power[1]
pow_gen = source.power[1]*source.nrays
@test pow_abs == 0.0

# Double check orientation of the light source
# VPL.render(rect, axes = false)
# VPL.render!(source)

# Intersection of a rectangle from a directional light source that is at an angle
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 2.0, width = 1.0)
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1, nx = 3, ny = 3, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
pow_abs = material[1].power[1]
pow_gen = source.power[1]*source.nrays
@test pow_abs ≈ pow_gen
@test pow_abs/VPL.area(rect) ≈ radiosity

# Double check orientation of the light source
# VPL.render(rect, axes = true)
# VPL.render!(source)

##### Using sensors #####

# Intersection of a rectangle from a directional light source downwards
nrays = 100_000
radiosity = 1.0
rect1, rect2, rect3 = collect(
    begin 
        r = VPL.Rectangle(length = 1.5, width = 1.0) 
        VPL.rotatey!(r, -π/2) # To put it in the XY plane
        r
    end
        for i in 1:3)
VPL.translate!(rect2, VPL.Z())
VPL.translate!(rect3, 2.0*VPL.Z())
rectangles = VPL.Mesh([rect1, rect2, rect3])
materials = [RT.Sensor() for i in 1:3]
ids = [1,1,2,2,3,3]
scene = RT.RTScene(mesh = rectangles, ids = ids, materials = materials);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(scene, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);

# Need to make sure maxiter > 1 or it will stop after the first sensor
settings = RT.RTSettings(pkill = 1.0, maxiter = 2, nx = 1, ny = 1, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
pow_abs = [material.power[1] for material in materials]
pow_gen = source.power[1]*source.nrays
@test all(pow_abs .≈ pow_gen)
@test all(pow_abs./VPL.area(rect1) .≈ radiosity)

# VPL.render(rectangles)
# VPL.render!(source)
# VPL.render!(rtobj.grid)

# Intersection of a rectangle from a directional light source at an angle
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 2, nx = 2, ny = 2, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)

@test nrays_traced == nrays
pow_abs = [material.power[1] for material in materials]
pow_gen = source.power[1]*source.nrays
@test all(pow_abs .≈ pow_gen)
@test all(pow_abs./VPL.area(rect1) .≈ radiosity)

# VPL.render(rectangles)
# VPL.render!(source)
# VPL.render!(rtobj.grid)

##### Using Lambertian #####

# Intersection of a rectangle from a directional light source downwards
nrays = 1_000_000
radiosity = 1.0
rect1, rect2, rect3 = collect(
    begin 
        r = VPL.Rectangle(length = 1.0, width = 1.5) 
        VPL.rotatey!(r, -π/2) # To put it in the XY plane
        r
    end
        for i in 1:3)
VPL.translate!(rect2, VPL.Z())
VPL.translate!(rect3, 2.0*VPL.Z())
rectangles = VPL.Mesh([rect1, rect2, rect3])
materials = [RT.Lambertian(τ = 0.3, ρ = 0.3) for i in 1:3]
ids = [1,1,2,2,3,3]
scene = RT.RTScene(mesh = rectangles, ids = ids, materials = materials);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
# Need to make sure maxiter > 1 or it will stop after the first sensor
settings = RT.RTSettings(pkill = 0.9, maxiter = 4, nx = 1, ny = 1, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)

@test nrays_traced > nrays
pow_abs = [material.power[1] for material in materials]
pow_gen = source.power[1]*source.nrays
@test sum(pow_abs) < pow_gen
@test pow_abs[1] < pow_abs[2] < pow_abs[3]


# Intersection of a rectangle from a directional light source at an angle
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 0.9, maxiter = 4, nx = 2, ny = 2, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj)

@test nrays_traced > nrays
RTirrs = [materials[i].power[1]/VPL.area(rect1) for i in 1:3]
@test all(RTirrs .< [1.0 for i in 1:3])
@test RTirrs[1] < RTirrs[2] < RTirrs[3]
RTirrs_naive = deepcopy(RTirrs) # for comparison with BVH later


##### Test intersection of specific rays with BVH acc ##### 

# Intersection of a rectangle from a directional light source downwards
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 1.0, width = 1.5)
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(scene, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1);
rtobj = RT.RayTracer(scene, source, settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{1}(2, 5));
nrays = RT.trace!(rtobj)

@test nrays == nrays
RTirr = material[1].power[1]./VPL.area(rect)
@test RTirr ≈ radiosity

# VPL.render(rect)
# VPL.render!([source])

##### Test intersection code of specific rays with BVH acc + grid cloner ##### 

# Intersection of a rectangle from a directional light source downwards (black) 
nrays = 100_000
radiosity = 1.0
rect = VPL.Rectangle(length = 3.0, width = 1.0)
VPL.rotatey!(rect, -π/2) # To put it in the XY plane
material = [RT.Black()]
ids = [1,1]
scene = RT.RTScene(mesh = rect, ids = ids, materials = material);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(scene, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 1, nx = 3, ny = 3, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{1}(2, 5));
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
RTirr = material[1].power[1]/VPL.area(rect)
@test RTirr ≈ radiosity

# Intersection of a rectangle from a directional light source downwards (sensor)
nrays = 100_000
radiosity = 1.0
rect1, rect2, rect3 = collect(
    begin 
        r = VPL.Rectangle(length = 1.5, width = 1.0) 
        VPL.rotatey!(r, -π/2) # To put it in the XY plane
        r
    end
        for i in 1:3)
VPL.translate!(rect2, VPL.Z())
VPL.translate!(rect3, 2.0*VPL.Z())
rectangles = VPL.Mesh([rect1, rect2, rect3])
materials = [RT.Sensor() for i in 1:3]
ids = [1,1,2,2,3,3]
scene = RT.RTScene(mesh = rectangles, ids = ids, materials = materials);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = 0.0, Φ = 0.0, radiosity = radiosity, nrays = nrays);
# Need to make sure maxiter > 1 or it will stop after the first sensor
settings = RT.RTSettings(pkill = 1.0, maxiter = 2, nx = 1, ny = 1, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{1}(2, 5));
nrays_traced = RT.trace!(rtobj)
@test nrays_traced == nrays
RTirrs = [materials[i].power[1]/VPL.area(rect1) for i in 1:3]
@test RTirrs ≈ [1.0 for i in 1:3]

# Intersection of a rectangle from a directional light source at an angle (sensor)
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = 1.0, nrays = nrays);
settings = RT.RTSettings(pkill = 1.0, maxiter = 2, nx = 2, ny = 2, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{1}(2, 5));
nrays_traced = RT.trace!(rtobj)

@test nrays_traced == nrays
RTirrs = [materials[i].power[1]/VPL.area(rect1) for i in 1:3]
@test RTirrs ≈ [1.0 for i in 1:3]


# Intersection of a rectangle from a directional light source at an angle (Lambertian)
nrays = 1_000_000
radiosity = 1.0
rect1, rect2, rect3 = collect(
    begin 
        r = VPL.Rectangle(length = 2.0, width = 1.0) 
        VPL.rotatey!(r, -π/2) # To put it in the XY plane
        r
    end
        for i in 1:3)
VPL.translate!(rect2, VPL.Z())
VPL.translate!(rect3, 2.0*VPL.Z())
rectangles = VPL.Mesh([rect1, rect2, rect3])
materials = [RT.Lambertian(τ = 0.3, ρ = 0.3) for i in 1:3]
ids = [1,1,2,2,3,3]
scene = RT.RTScene(mesh = rectangles, ids = ids, materials = materials);
gbox = RT.AABB(scene);
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = radiosity, nrays = nrays);
settings = RT.RTSettings(pkill = 0.9, maxiter = 4, nx = 4, ny = 4, dx = 1.0, dy = 1.0);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{1}(2, 5));
nrays_traced = RT.trace!(rtobj)

@test nrays_traced > nrays
RTirrs = [materials[i].power[1]/VPL.area(rect1) for i in 1:3]
@test all(RTirrs .< [1.0 for i in 1:3])
@test RTirrs[1] < RTirrs[2] < RTirrs[3]

# Should yield the same results as the naive acceleration structure!
@test all(abs.(RTirrs .- RTirrs_naive) .< 0.02)

##### Ray trace binary tree ##### 

function VPL.feedgeom!(turtle::VPL.MTurtle, i::btree.Internode)
    VPL.HollowCube!(turtle, length = i.length, height = i.length/10, width = i.length/10, move = true)
    return nothing
end
function VPL.feedcolor!(turtle::VPL.GLTurtle, i::btree.Internode)
    VPL.feedcolor!(turtle, VPL.RGB(0,1,0))
    return nothing
end
function RT.feedmaterial!(turtle::RT.RTTurtle, i::btree.Internode)
    VPL.feedmaterial!(turtle, i.mat)
    return nothing
end
rule = VPL.Rule(btree.Meristem, rhs = mer -> btree.Node() + 
            (VPL.RU(-60.0) + btree.Internode(0.1, RT.Lambertian(τ = 0.0, ρ = 0.3)) + 
                             VPL.RH(90.0) + btree.Meristem(), 
             VPL.RU(60.0)  + btree.Internode(0.1, RT.Lambertian(τ = 0.0, ρ = 0.3)) + 
                             VPL.RH(90.0) + btree.Meristem()))
axiom = btree.Internode(0.1, RT.Lambertian(τ = 0.0, ρ = 0.3)) + btree.Meristem()
tree = VPL.Graph(axiom, Tuple(rule), btree.treeparams(0.5))
getInternode = VPL.Query(btree.Internode)
function elongate!(tree, query)
    for x in VPL.apply(tree, query)
        x.length = x.length*(1.0 + VPL.vars(tree).growth)
    end
end
function growth!(tree, query)
    elongate!(tree, query)
    VPL.rewrite!(tree)
end
function simulate(tree, query, nsteps)
    new_tree = deepcopy(tree)
    for i in 1:nsteps
        growth!(new_tree, query)
    end
    return new_tree
end
function getpower(tree, query)
    powers = Float64[]
    for x in VPL.apply(tree, query)
        push!(powers, x.mat.power[1])
    end
    return powers
end

newtree = simulate(tree, getInternode, 4)

# Ray trace the tree with a single directional light source
nrays = 1_000_000
scene = RT.RTScene(newtree);
gbox = RT.AABB(scene)
source = RT.DirectionalSource(gbox, θ = π/4, Φ = 0.0, radiosity = 1.0, nrays = nrays);
# Tracing with BVH acceleration structure
settings = RT.RTSettings(pkill = 0.9, maxiter = 4, nx = 5, ny = 5, dx = 1.0, 
                         dy = 1.0, parallel = true);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.BVH,
                     rule = RT.SAH{6}(5, 10));
nrays_traced = RT.trace!(rtobj)
powers_bvh = getpower(newtree, getInternode);
# Tracing with Naive acceleration structure
settings = RT.RTSettings(pkill = 0.9, maxiter = 4, nx = 5, ny = 5, dx = 1.0, 
                         dy = 1.0, parallel = true);
rtobj = RT.RayTracer(scene, [source], settings = settings, acceleration = RT.Naive);
nrays_traced = RT.trace!(rtobj);
powers_naive = getpower(newtree, getInternode);

# For low number of rays the results are the same for the Naive and BVH 
# acceleration structures, but for large number of rays the results diverge
# This divergence does not seem to decrease with the number of rays. It may 
# depend on the scene itself though?
@test maximum(abs.((powers_bvh .- powers_naive)./powers_naive)) < 0.005
@test abs(sum(powers_bvh) - sum(powers_naive))/sum(powers_bvh) < 1e-5



# Simple test to make sure that rays are always generated from above the scene
r = VPL.Rectangle(length = 2.0, width = 1.0) 
VPL.rotatey!(r, -π/2) # To put it in the XY plane
VPL.translate!(r, VPL.Vec(0.0, 0.5, 0.0))
r2 = deepcopy(r)
VPL.translate!(r2, VPL.Vec(0.0, 0.0, -1.0))
materials = [VPL.Black(), VPL.Black()]
ids = [1,1, 2, 2]
scene = VPL.RTScene(mesh = VPL.Mesh([r,r2]), ids = ids, materials = materials)
sources = RT.DirectionalSource(scene, θ = π/2*0.99, Φ = 0.0, radiosity = 1.0, nrays = nrays);
power_out = sources.power*sources.nrays               
#VPL.render(VPL.Mesh([r,r2]))
#VPL.render!(sources)
settings = VPL.RTSettings(nx = 15, ny = 15, dx = 2.0, dy = 1.0, parallel = true)
rtobj = VPL.RayTracer(scene, sources, settings = settings);
nrays_traced = VPL.trace!(rtobj)
@test materials[1].power[1]/power_out[1] ≈ 1.0
@test materials[2].power[1]/power_out[1] ≈ 0.0


end