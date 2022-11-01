
# Fixed angle (to be used with directional light sources)
"""
    FixedSource(dir)
    FixedSource(θ, Φ)

Create a fixed irradiance source by given a vector with the direction of the
rays (dir) or zenith (θ) and azimuth (Φ) angles.
"""
struct FixedSource{FT} <: SourceAngle
    dir::Vec{FT}
end
function FixedSource(θ, Φ)
    FixedSource(rotate_coordinates(θ, Φ).z)
end
generate_direction(a::FixedSource, rng) = a.dir

# Emission of diffuser (to be used with general light sources and for thermal radiation)
"""
    LambertianSource(x, y, z)
    LambertianSource(axes)

Create a Lambertian irradiance source angle by given a local coordinate system as three
separate `Vec` objects representing the axes (x, y, z) or as tuple containing the three
axes. Rays will be generated towards the hemisphere defined by the `z` direction. See VPL
documentation for details on irradiance sources.
"""
struct LambertianSource{FT} <: SourceAngle
    x::Vec{FT}
    y::Vec{FT}
    z::Vec{FT}
end
LambertianSource(axes) = LambertianSource(axes...)

function generate_direction(a::LambertianSource{FT}, rng) where FT
    Φ = FT(2)*FT(π)*rand(rng, FT)
    θ = acos(sqrt(rand(rng, FT)))
    polar_to_cartesian((e1 = a.x, e2 = a.y, n = a.z), θ, Φ)
end





