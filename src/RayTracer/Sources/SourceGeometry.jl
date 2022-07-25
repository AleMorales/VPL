
###############################################################################
############################## Implementations ################################
###############################################################################

"""
    PointSource(vec)

Create a point irradiance source geometry at given 3D location `vec`, defined as vector
of Cartesian coordinates (`Vec(x, y, z)`).
"""
struct PointSource{FT} <: SourceGeometry
    loc::Vec{FT}
end

generate_point(g::PointSource, rng) = g.loc


"""
    LineSource(p, line)

Create a line irradiance source geometry given an origin (`p`) and a segment (`line`) both
specified as vector of Cartesian coordinates (`Vec(x, y, z)`). This will create a
line source between the points `p` and `p .+ line`.
"""
struct LineSource{FT} <: SourceGeometry
    p::Vec{FT}
    line::Vec{FT} # not an unit vector!
end

function generate_point(g::LineSource{FT}, rng) where FT
    @. g.p + rand(rng, FT)*g.line
end


struct AreaSource{FT} <: SourceGeometry 
    tvec::Vector{Triangle{FT}}
    areas::Weights{FT, FT, Vector{FT}}
end

"""
    AreaSource(mesh)

Create an area irradiance source geometry given a triangular mesh.
"""
AreaSource(mesh::Mesh) = AreaSource(Triangle(mesh), Weights(areas(mesh)))

# Select randomly the triangle within the mesh and select randomly a point within the triangle
function generate_point(g::AreaSource, rng)
    t = sample(rng, g.tvec, g.areas)
    generate_point(t, rng)
end