import VPL
const G = VPL.Geom
using Test
import CoordinateTransformations
import CoordinateTransformations: SDiagonal, LinearMap


let

# Create turtles with different floating point precisions
t64 = G.MTurtle{Float64}()
@test t64 isa G.MTurtle{Float64}
@test G.pos(t64) isa G.Vec{Float64}
@test G.geoms(t64) isa G.Mesh{G.Vec{Float64}}

t32 = G.MTurtle{Float32}()
@test t32 isa G.MTurtle{Float32}
@test G.pos(t32) isa G.Vec{Float32}
@test G.geoms(t32) isa G.Mesh{G.Vec{Float32}}


# Head -> Z axis
# Arm  -> Y axis
# Up   -> X axis


# Translation command
function test_t(t::G.MTurtle{FT}) where FT
    to = G.Vec{FT}(1,1,1)
    nt = deepcopy(t)
    G.t!(nt, to = to)
    @test G.pos(nt)  == to
    @test G.head(nt) == G.head(t)
    @test G.arm(nt)  == G.arm(t)
    @test G.up(nt)   == G.up(t)
end

test_t(G.MTurtle{Float64}())
test_t(G.MTurtle{Float32}())

# Orientation command
function test_or(t::G.MTurtle{FT}) where FT
    arm = G.Vec{FT}(0.5,0.5,0)
    head = G.Vec{FT}(-0.5,0.5,0)
    up = G.Vec{FT}(0,0,1)
    nt = deepcopy(t)
    G.or!(nt, head = head, arm = arm, up = up)
    @test G.pos(nt)  == G.pos(t)
    @test G.head(nt) == head
    @test G.arm(nt)  == arm
    @test G.up(nt)   == up
end

test_or(G.MTurtle{Float64}())
test_or(G.MTurtle{Float32}())

# Set command
function test_set(t::G.MTurtle{FT}) where FT
    to = G.Vec{FT}(1,1,1)
    arm = G.Vec{FT}(0.5,0.5,0)
    head = G.Vec{FT}(-0.5,0.5,0)
    up = G.Vec{FT}(0,0,1)
    nt = deepcopy(t)
    G.set!(nt, to = to, head = head, arm = arm, up = up)
    @test G.pos(nt) == to
    @test G.head(nt) == head
    @test G.arm(nt)  == arm
    @test G.up(nt)   == up
end

test_set(G.MTurtle{Float64}())
test_set(G.MTurtle{Float32}())

# Rotation around "up" direction
function test_ru(t::G.MTurtle{FT}) where FT
    nt = deepcopy(t)
    G.ru!(nt, FT(90))
    @test G.pos(nt) == G.pos(t)
    @test G.head(nt) ≈ G.Y(FT)
    @test G.arm(nt) ≈ .-G.Z(FT)
    @test G.up(nt) == G.up(t)
end

test_ru(G.MTurtle{Float64}())
test_ru(G.MTurtle{Float32}())

function test_ru(t::G.MTurtle{FT}) where FT
    nt = deepcopy(t)
    G.ru!(nt, FT(180))
    @test G.pos(nt) == G.pos(t)
    @test G.head(nt) ≈ .-G.Z(FT)
    @test G.arm(nt) ≈ .-G.Y(FT)
    @test G.up(nt) == G.up(t)
end

test_ru(G.MTurtle{Float64}())
test_ru(G.MTurtle{Float32}())

# Rotation around "arm" direction
function test_ra(t::G.MTurtle{FT}, angle::FT) where FT
    nt = deepcopy(t)
    G.ra!(nt, angle)
    @test G.pos(nt) == G.pos(t)
    @test G.head(nt) ≈ .-G.X(FT)
    @test G.arm(nt) == G.arm(t)
    @test G.up(nt) ≈ G.Z(FT)
end

test_ra(G.MTurtle{Float64}(), 90.0)
test_ra(G.MTurtle{Float32}(), 90f0)

# Rotation around "head" direction
function test_rh(t::G.MTurtle{FT}, angle::FT) where FT
    nt = deepcopy(t)
    G.rh!(nt, angle)
    @test G.pos(nt) == G.pos(t)
    @test G.head(nt) == G.head(t)
    @test G.arm(nt) ≈ .-G.X(FT)
    @test G.up(nt) ≈ G.Y(FT)
end

test_rh(G.MTurtle{Float64}(), 90.0)
test_rh(G.MTurtle{Float32}(), 90f0)


# Move forward
function test_f(t::G.MTurtle{FT}, dist::FT) where FT
    nt = deepcopy(t)
    G.f!(nt, dist)
    @test G.pos(nt) == G.Vec{FT}(0,0,1) 
    @test G.head(nt) == G.head(t)
    @test G.arm(nt)  == G.arm(t)
    @test G.up(nt)   == G.up(t)
end

test_f(G.MTurtle{Float64}(), 1.0)
test_f(G.MTurtle{Float32}(), 1f0)

# Check transformations
trans = G.transform(G.MTurtle{Float64}())
@test trans isa CoordinateTransformations.AffineMap
trans.translation == G.Vec{Float64}(0,0,0)
trans.linear == SDiagonal(1.0,1.0,1.0)


trans = G.transform(G.MTurtle{Float64}(), (2.0, 2.0, 2.0))
@test trans isa CoordinateTransformations.AffineMap
trans.translation == G.Vec{Float64}(0,0,0)
trans.linear == SDiagonal(2.0,2.0,2.0)


end