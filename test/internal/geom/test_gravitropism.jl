using VPL
using Test
using LinearAlgebra

let 
    # RA of 45° (upward gravitropism)
t = VPL.MTurtle(Float64)
ra!(t, 45.0)
tb = head(t)
rv!(t, 0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
@test cosαb ≈ cos(π/4)
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (1 - cosαb)/2
@test ta[3] ≈ tb[3] + (1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)

# RA of 45° (downward gravitropism)
t = VPL.MTurtle(Float64)
ra!(t, 45.0)
tb = head(t)
rv!(t, -0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
@test cosαb ≈ cos(π/4)
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (-1 - cosαb)/2
@test ta[3] ≈ tb[3] + (-1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)


# RA of 120° (i.e., what if it is pointing downwards?)
t = MTurtle(Float64)
ra!(t, 120.0)
tb = head(t)
rv!(t, 0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
@test cosαb ≈ cos(120*pi/180)
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (1 - cosαb)/2
@test ta[3] ≈ tb[3] + (1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)

# RA of 120° (i.e., what if it is pointing downwards? -> moving downwards)
t = MTurtle(Float64)
ra!(t, 120.0)
tb = head(t)
rv!(t, -0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
@test cosαb ≈ cos(120*pi/180)
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (-1 - cosαb)/2
@test ta[3] ≈ tb[3] + (-1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)

# RA of 45°, RU of -25°, RH of 10°
t = MTurtle(Float64)
ra!(t, 45.0)
ru!(t, -25.0)
rh!(t, 10.0)
tb = head(t)
rv!(t, 0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (1 - cosαb)/2
@test ta[3] ≈ tb[3] + (1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)


# RA of 45°, RU of -25°, RH of 10° (downwards)
t = MTurtle(Float64)
ra!(t, 45.0)
ru!(t, -25.0)
rh!(t, 10.0)
tb = head(t)
rv!(t, -0.5)
ta = head(t)
@test norm(tb) ≈ 1
@test norm(ta) ≈ 1
cosαb = tb ⋅ Z()
cosαa = ta ⋅ Z()
@test cosαa ≈ cosαb + (-1 - cosαb)/2
@test ta[3] ≈ tb[3] + (-1 - tb[3])/2
@test abs(head(t) ⋅ arm(t)) < eps(Float64)
@test abs(head(t) ⋅ up(t)) < eps(Float64)
@test abs(up(t) ⋅ arm(t)) < eps(Float64)
    
end