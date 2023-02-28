### This file contains public API ###
# reset!
# power

# Methods that need to be implemented for Material types:
# choose_interaction(material, power, ray, intersection, rng) -> Choose type of interaction and calculate variable optical properties
# absorb_power!(material, power, interaction)                 -> Transfer from power to material based on type of interaction
# generate_ray(material, ray, intersection, interaction, rng) -> Generate a new ray based on type of interaction

# Intersection should contain the local reference system as unit vectors (e1, e2, n)
# To avoid type instability propagating throughout the code, all these functions
# should return tuples of the same type
abstract type Material end

# Implementations of different types of materials
include("Lambertian.jl")
include("Phong.jl")
include("Sensor.jl")
include("Black.jl")

"""
    reset!(material::Material)

Reset the power stored inside a material back to zero
"""
function reset!(material::Material)
    for i in eachindex(material.power)
        @inbounds material.power[i] = 0.0#.value = 0.0
    end
    return nothing
end
function reset!(materials::Vector{<:Material})
    @threads for mat in materials
        reset!(mat)
    end
end


"""
    power(material::Material)

Extract the power stored inside a material.
"""
function power(material::Material)
    return SVector(Tuple(pow for pow in material.power))
end