### This file contains public API ###
# DirectionalSource

"""
    DirectionalSource(box::AABB, θ, Φ, power, nrays)
    DirectionalSource(scene::RTScene, θ, Φ, power, nrays)

Create a Directional source (including geometry and angle components) by providing an axis-aligned
bounding box (`box`) or an `RTScene` object (`scene`) as well as the zenith (`θ`) and azimuth (`Φ`)
angles, the power per ray (as in `Source`) and the number of rays to be generated. See VPL
documentation for details on irradiance sources.
"""
DirectionalSource(box::AABB; θ, Φ, power, nrays) = Source(create_directional(box, θ, Φ), FixedSource(θ, Φ), power, nrays)
DirectionalSource(scene::RTScene; θ, Φ, power, nrays) = Source(create_directional(AABB(scene), θ, Φ), FixedSource(θ, Φ), power, nrays)


# Projection of the ellipsoid that bounds the scene
struct Directional{FT} <: SourceGeometry
    po::Vec{FT}
    rx::Vec{FT}
    ry::Vec{FT}
end

# Create geometry for a directional light source
function create_directional(box::AABB{FT}, θ::FT, Φ::FT) where FT
    # Scaling
    Δx, Δy, Δz = (box.max .- box.min).*sqrt(FT(2))
    s = scale(Δx/2, Δy/2, Δz/2)
    # Rotation
    r = rotatez(-Φ) ∘ rotatex(-θ)
    n = r(Z(FT))
    # Translation
    d = Vec(Δx/2, Δy/2, Δz/2)
    p = (box.max .+ box.min)./2
    t = Translation(p .+ n.*d .+ n)
    # Transformation
    trans = t ∘ r ∘ s
    # Generate the three points of the ellipse
    po = trans(O(FT))
    px = trans(X(FT))
    py = trans(Y(FT))
    rx = px .- po
    ry = py .- po
    # Create the directional source object outside ellipsoid
    Directional(po, rx, ry)
end

# Select a point from the project ellipse as origin of a ray
# Notice the use of sqrt() to account for larger area as one moves away from center
function generate_point(g::Directional{FT}, rng) where FT
    r = sqrt(rand(rng, FT))
    θ = FT(2)*FT(pi)*rand(rng, FT)
    dx = @. r*g.rx*cos(θ)
    dy  = @. r*g.ry*sin(θ)
    @. g.po + dx + dy
end