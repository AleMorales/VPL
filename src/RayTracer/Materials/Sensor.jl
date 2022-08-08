

#=
  Material that has no effect on the ray and its associated power but accumulates
all the power associated to the ray
=#
struct Sensor{nw} <: Material
    power::MVector{nw, Float64} #::SArray{Tuple{nw},Threads.Atomic{Float64},1,nw}
end

"""
    Sensor(nw::Int)

Create a sensor material object to store power for `nw` wavelengths. See VPL documentation for
details.
"""
Sensor(nw::Int = 1) = Sensor(MVector{nw, Float64}(0.0 for _ in 1:nw)) #Sensor(SArray{Tuple{nw},Threads.Atomic{Float64},1,nw}(Threads.Atomic{Float64}(0.0) for i in 1:nw))

###############################################################################
################################## API ########################################
###############################################################################

#=
    There is actually no interaction with the sensor
=#
function calculate_interaction(material::Sensor, power, ray, intersection, rng)
    return (mode = :sensor, coef = 1.0, θ = 1.0, Φ = 1.0)
end

# TODO: A sensor should always distinguish front and back
#=
    Add all the power to the material but do not affect the power of the ray
=#
@inbounds function absorb_power!(material::Sensor, power, interaction) 
    for i in eachindex(power)
        material.power[i] += power[i] #Threads.atomic_add!(material.power[i], power[i])
    end
    return nothing
end

#=
    Just return the same ray
=#
function generate_ray(material::Sensor, ray::Ray{FT}, disp::Vec{FT}, intersection, interaction, rng) where FT 
    Ray(intersection.pint .- disp .+ ray.dir.*eps(FT).*FT(2), ray.dir, ray.idir, ray.extra)
end