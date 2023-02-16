### This file contains public API ###
# DirectionalSource

"""
    DirectionalSource(box::AABB, θ, Φ, radiosity, nrays)
    DirectionalSource(scene::RTScene, θ, Φ, radiosity, nrays)

Create a Directional source (including geometry and angle components) by providing an axis-aligned
bounding box (`box`) or an `RTScene` object (`scene`) as well as the zenith (`θ`) and azimuth (`Φ`)
angles, the radiosity of the source and the number of rays to be generated. 
Directional sources may generate incorrect results in the absence of a grid cloner
that extendes the scenes. This is because the rays are generated from the upper
face of the scene's bounding box. See VPL documentation for details on light sources.
"""
function DirectionalSource(box::AABB; θ, Φ, radiosity, nrays) 
    dir_geom = create_directional(box)
    # Radiosity is assumed to be project onto horizontal plane
    # The code below ensures that we get the right irradiance onto the scene
    power = radiosity*area(dir_geom)# base_area(box) -> from earlier version
    Source(dir_geom, FixedSource(θ, Φ), power/nrays, nrays)
end
function DirectionalSource(scene::RTScene; θ, Φ, radiosity, nrays) 
    box = AABB(scene)
    DirectionalSource(box, θ = θ, Φ = Φ, radiosity = radiosity, nrays = nrays)
end

# # Projection of the ellipsoid that bounds the scene
# struct Directional{FT} <: SourceGeometry
#     po::Vec{FT}
#     rx::Vec{FT}
#     ry::Vec{FT}
# end

# Upper face of the scene's AABB
struct Directional{FT} <: SourceGeometry
    xmin::FT
    xmax::FT
    ymin::FT
    ymax::FT 
    zmax::FT   
end

# Calculate the area of the directional light source
area(d::Directional) = (d.xmax - d.xmin)*(d.ymax - d.ymin)

# Create geometry for a directional light source
function create_directional(box::AABB{FT}) where FT
    @inbounds Directional(box.min[1], box.max[1], box.min[2], box.max[2], box.max[3])
end

# Select a random point from the upper face of the scene's AABB
function generate_point(d::Directional{FT}, rng) where FT
    x = d.xmin + rand(rng, FT)*(d.xmax - d.xmin)
    y = d.ymin + rand(rng, FT)*(d.ymax - d.ymin)
    Vec(x, y, d.zmax + eps(FT))
end

# # Create geometry for a directional light source
# function create_directional(box::AABB{FT}, θ::FT, Φ::FT) where FT
#     # Scaling
#     Δx, Δy, Δz = (box.max .- box.min)
#     Δs = max(Δx, Δy, Δz)*sqrt(FT(2))/2
#     s = scale(Δs, Δs, Δs)
#     # Rotation
#     r = rotatez(-Φ) ∘ rotatex(-θ)
#     n = r(Z(FT))
#     # Translation
#     d = Vec(Δx/2, Δy/2, Δz/2)
#     p = (box.max .+ box.min)./2 .+ Vec(FT(0), FT(0), (box.max[3] - box.min[3])/2)
#     t = Translation(p .+ n.*Δs)
#     # Transformation
#     trans = t ∘ r ∘ s
#     # Generate the three points of the ellipse
#     po = trans(O(FT))
#     px = trans(X(FT))
#     py = trans(Y(FT))
#     rx = px .- po
#     ry = py .- po
#     # Create the directional source object outside ellipsoid
#     Directional(po, rx, ry)
# end

# # Select a point from the project ellipse as origin of a ray
# # Notice the use of sqrt() to account for larger area as one moves away from center
# function generate_point(g::Directional{FT}, rng) where FT
#     r = sqrt(rand(rng, FT))
#     θ = FT(2)*FT(pi)*rand(rng, FT)
#     dx = @. r*g.rx*cos(θ)
#     dy  = @. r*g.ry*sin(θ)
#     @. g.po + dx + dy
# end