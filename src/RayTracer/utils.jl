
# Interface to generate the SVectors more easily (for the materials)
tau(vals...) = SVector(vals)
rho(vals...) = SVector(vals)

# Get random numbers
runif(rng, ::Val{n}, ::Type{t}) where {n,t} = NTuple{n,t}(rand(rng,t) for i in 1:n)

# Calculate direction unit vector on Cartesian system axes from the 
# angles θ and  Φ
function polar_to_cartesian(axes, θ, Φ)
    e1, e2, n = axes
    dir1 = @. n*cos(θ)
    dir2 = @. e1*cos(Φ)*sin(θ)
    dir3 = @. e2*sin(Φ)*sin(θ)
    dir = @. dir1 + dir2 + dir3
    Vec(normalize(dir))
end

# Project a point (p) onto a plane (defined by point pp and normal pn)
function project(p, pp, pn)
    v = p .- pp
    dist = v ⋅ pn
    p .- dist.*pn
end

# Help write coordinate transformations
translate(x, y, z) = Translation(x, y, z)
rotatex(x) = LinearMap(RotX(x))
rotatey(x) = LinearMap(RotY(x))
rotatez(x) = LinearMap(RotZ(x))


# Given angles θ and Φ, calculate the flipped coordinate system of the plane
# Φ clockwise looking against Z - East is positive
# θ counterclock wise looking against Y - Sunrise is positive
function rotate_coordinates(θ::FT, Φ::FT) where FT
    rot = rotatez(-Φ) ∘ rotatex(-θ)
    (x = .-rot(X(FT)), y = .-rot(Y(FT)), z = .-rot(Z(FT)))
end