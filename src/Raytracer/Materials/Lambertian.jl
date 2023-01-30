### This file contains public API ###
# Lambertian

#=
  General material that assumes Lambertian transmittance and a combination
of Lambertian and Phong reflectance
=#
struct Lambertian{nw} <: Material
    power::MVector{nw,Float64} #SArray{Tuple{nw},Threads.Atomic{Float64},1,nw}
    τ::SVector{nw,Float64}
    ρ::SVector{nw,Float64}
end

"""
    Lambertian(;τ = 0.0, ρ = 0.0)

Create a `Lambertian` material object from the values of transmittance (`τ`) 
and reflectance (`ρ`). When more than one wavelength is being simulated, a tuple 
of values should be passed for each optical property (as in `τ = (0.1,0.2)`). 
"""
function Lambertian(;τ = 0.0, ρ = 0.0)
    Lambertian(τ, ρ)
end

function Lambertian(τ::Tuple, ρ::Tuple)
    nw = length(τ)
    power = MVector{nw,Float64}(0.0 for _ in 1:nw)
    Lambertian(power, SVector(τ), SVector(ρ))
end

function Lambertian(τ::Real, ρ::Real)
    power = MVector{1,Float64}(0.0)
    Lambertian(power, SVector(τ), SVector(ρ))
end

###############################################################################
################################## API ########################################
###############################################################################

#=
Determine whether the ray beam is transmitted, reflected diffussively or specularly
Calculate the wavelength-weighted reflectance/transmittance of each type of interaction
This function actually performs sampling of angles (required for Phong calculations)
=#
function calculate_interaction(material::Lambertian, power, ray, intersection, rng)
    Φ = 2π * rand(rng)
    θ = acos(sqrt(rand(rng)))
    mode, coef = choose_outcome(material, power, rng)
    return (mode=mode, coef=coef, θ=θ, Φ=Φ)

end

#=
Update the contents of power and transfer that information to material
based on the type of interaction and wavelength-weighted probabilities
=#
function absorb_power!(material::Lambertian, power, interaction)
    @inbounds begin
        for i in eachindex(power)
            material.power[i] += power[i] * (1.0 - interaction.coef[i]) #Threads.atomic_add!(material.power[i], Δpower)
            power[i] *= interaction.coef[i]
        end
        return nothing
    end
end

#=
Generate a new ray using information in intersection and interaction
=#
function generate_ray(material::Lambertian, ray::Ray{FT}, disp::Vec{FT}, intersection, interaction, rng) where {FT}
    # Generate direction from angles
    dir = polar_to_cartesian(intersection.axes, interaction.θ, interaction.Φ)
    # If we are transmitting, flip direction
    interaction.mode == :τ && (dir = .-dir)
    # Generate the new ray
    return Ray(intersection.pint .+ dir .* eps(FT) .* 2, dir)
end


###############################################################################
############################### Internal ######################################
###############################################################################

# These calculations are based on Cieslak et al. (2008)
function choose_outcome(m::Lambertian, power, rng)
    # Calculate probabilities of τ & ρd
    sτ = sum(m.τ .* power)
    sρ = sum(m.ρ .* power)
    pτ = sτ / (sτ + sρ)
    # Choose the outcome randomly and return the weighted
    # reflectance or transmittance
    roll = rand(rng)
    if roll < pτ
        return (mode=:τ, coef=m.τ ./ pτ)
    else
        return (mode=:ρ, coef=m.ρ ./ (1.0 .- pτ))
    end
end