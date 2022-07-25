
"""
    DirectionalSource(box::AABB, θ, Φ, power, nrays)
    DirectionalSource(scene::RTScene, θ, Φ, power, nrays)

Create a Directional source (including geometry and angle components) by providing an axis-aligned
bounding box (`box`) or an `RTScene` object (`scene`) as well as the zenith (`θ`) and azimuth (`Φ`)
angles, the power per ray (as in `Source`) and the number of rays to be generated. See VPL
documentation for details on irradiance sources.
"""
DirectionalSource(box::AABB, θ, Φ, power, nrays) = Source(create_directional(box, θ, Φ), FixedSource(θ, Φ), power, nrays)
DirectionalSource(scene::RTScene, θ, Φ, power, nrays) = Source(create_directional(AABB(scene), θ, Φ), FixedSource(θ, Φ), power, nrays)


# Projection of the ellipsoid that bounds the scene
struct Directional{FT} <: SourceGeometry
    p::Vec{FT}
    rₕ::Vec{FT}
    rᵥ::Vec{FT}
end

# Create geometry for a directional light source
function create_directional(box::AABB{FT}, θ::FT, Φ::FT) where FT
    # Dimensions of the axis-aligned bounding ellipsoid
    Δx, Δy, Δz = (box.max .- box.min).*sqrt(FT(2))
    s          = SVector(Δx/2, Δy/2, Δz/2)
    p          = (box.max .+ box.min)./2
    # Normal associated with the direction
    n = polar_to_cartesian((X(FT), Y(FT), Z(FT)), θ, Φ)
    # Radii of projection of unit sphere
    rₕ, rᵥ = project_sphere(n, Φ)
    # Intersection between normal vector and unit sphere
    pᵤ = O(FT) .+ n
    # Scale the radii (projection of axis-aligned bounding ellipsoid)
    rₕ = rₕ.*s
    rᵥ = rᵥ.*s
    # and translate & scale the intersection point
    pᵢ = p .+ pᵤ.*s
    # Create the directional source object outside ellipsoid
    Directional(pᵢ .+ n, rₕ, rᵥ)
end

# Orothgonal radii on projection of unit sphere unto the direction
function project_sphere(n::Vec{FT}, Φ::FT) where FT
    tan2Φ = tan(Φ)^2
    rₕ = SVector(-sqrt(tan2Φ/(1 - tan2Φ)), sqrt(1/(1 - tan2Φ)), zero(FT))
    rᵥ = normalize(cross(n, rₕ))
    return rₕ, rᵥ
end

# Select a point from the project ellipse as origin of a ray
# Notice the use of sqrt() to account for larger area as one moves away from center
function generate_point(g::Directional{FT}, rng) where FT
    r = sqrt(rand(rng, FT))
    θ = FT(2)*FT(pi)*rand(rng, FT)
    rh = @. r*g.rₕ*cos(θ)
    rv  = @. r*g.rᵥ*sin(θ)
    @. g.p + rh + rv
end