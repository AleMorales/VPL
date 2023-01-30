### This file contains public API ###
# Phong

#=
  Modified Phong model taken from Lafortune & Willems (1994)
=#
struct Phong{nw} <: Material
    power::MVector{nw, Float64} #::SArray{Tuple{nw},Threads.Atomic{Float64},1,nw}
    τ::SVector{nw, Float64} # Transmittance
    ρd::SVector{nw, Float64} # Diffuse reflectivity
    ρsmax::SVector{nw, Float64} # Specular reflectivity
    n::Float64 # Specular exponent
end

"""
    Phong(;τ = 0.0, ρd = 0.0, ρsmax = 0.0, n = 2)

Create a `Phong` material object from the values of transmittance (`τ`) diffuse 
reflectance (`ρd`), maximum Phong specular reflectance (`ρsmax`) and `n` is the 
specular exponent that controls the "Phong reflectance lobe". When more than one 
wavelength is being simulated, a tuple of values should be passed for each 
optical property (as in `τ = (0.1, 0.3)`).
"""
function Phong(;τ = 0.0, ρd = 0.0, ρsmax = 0.0, n = 2)
    Phong(τ, ρd, ρsmax, n)
end

function Phong(τ::Number, ρd::Number, ρsmax::Number, n::Number)
    Phong{1}(MVector{1, Float64}(0.0), SVector(τ), SVector(ρd), SVector(ρsmax), n)
end

function Phong(τ::Tuple, ρd::Tuple, ρsmax::Tuple, n::Number)
    @assert length(τ) == length(ρd) == length(ρsmax) "All arguments to Phong() must have the same length"
    nw = length(τ)
    Phong{nw}(MVector{nw, Float64}(0.0 for _ in 1:nw), τ, ρd, ρsmax, n)
end

###############################################################################
################################## API ########################################
###############################################################################

#=
Determine whether the ray beam is transmitted, reflected diffussively or specularly
Calculate the wavelength-weighted reflectance/transmittance of each type of interaction
This function actually performs sampling of angles (required for Phong calculations)
=#
function calculate_interaction(material::Phong, power, ray, intersection, rng)
    Φ = 2*π*rand(rng)
    ρs, θ = calc_specular(material, intersection.axes, rng, ray.dir, Φ)
    mode, coef = choose_outcome(material, ρs, power, rng)
    if mode == ρs
        return (mode = mode, coef = coef, θ = θ, Φ = Φ)
    else
        θ = acos(sqrt(rand(rng)))
        return (mode = mode, coef = coef, θ = θ, Φ = Φ)
    end
end

#=
Update the contents of power and transfer that information to material
based on the type of interaction and wavelength-weighted probabilities
=#
function absorb_power!(material::Phong, power, interaction) 
    @inbounds begin
        for i in eachindex(power)
            Δpower = power[i]*(1.0 - interaction.coef[i])
            material.power[i] += Δpower #Threads.atomic_add!(material.power[i], Δpower)
            power[i] *= interaction.coef[i]
        end
        return nothing
    end
end

#=
Generate a new ray using information in intersection and interaction
=#
function generate_ray(material::Phong, ray, disp::Vec{FT}, intersection, interaction, rng) where FT
    # Generate direction from angles
    dir = polar_to_cartesian(intersection.axes, interaction.θ , interaction.Φ)
    # If we are transmitting, flip dir
    interaction.mode == :τ && (dir = .-dir)
    # Generate the new ray
    return Ray(intersection.pint .+ dir.*eps(FT).*2, dir)
end


###############################################################################
############################### Internal ######################################
###############################################################################

# Generate a reflection angle to calculate ρs.
# Returns ρs as well as the angles that were sampled.
# If the reflection angle is invalid (below surface), ρs = 0 due to clamping
# and therefore the final outcome will be τ or ρd
function calc_specular(m::Phong{nw}, axes, rng, idir, Φ) where nw
    ρ0 = SVector{nw, Float64}(0.0 for _ in 1:nw)
    if m.ρsmax > 0.0
        # Sample an angle from the Phong lobe
        θ  = sample_phong(m, axes, rng, idir, Φ) 
        # Estimator of specular reflectance (Lafortune & Willems, 1994)
        coef = (m.n + 2)/(m.n + 1)*cos(θ)
        ρs = m.ρsmax.*coef
        ρs = clamp.(ρs, ρ0, m.ρsmax)
        return (ρs = ρs, θ = θ)
    else
        return (ρs = ρ0, θ = 0.0)
    end
end

# These calculations are based on Cieslak et al. (2008) adjusted
# to the three possible outcomes in Phong
function choose_outcome(m::Phong, ρs, power, rng)
    # Calculate probabilities of τ, ρd, ρs
    sτ  = sum(m.τ.*power)
    sρd = sum(m.ρd.*power)
    den = sτ + sρd + ρs
    pτ  = sτ/den
    pρd = sρd/den
    pρs = 1 - pτ - pρd
    # Choose the outcome randomly and return the weighted
    # reflectance or transmittance
    roll = rand(rng)
    if roll < pτ
        return (mode = :τ,  coef = m.τ./pτ)
    elseif roll < pτ + pρd
        return (mode = :ρd, coef = m.ρd./pρd)
    else
        return (mode = :ρs, coef = m.ρs./pρs)
    end
end

# Calculate zenith angle of reflected angle by sampling from the specular
# Phong lobe (Lafortune & Willems, 1994)
# Returns sampled Φ and θ
function sample_phong(m::Phong, axes, rng, idir, Φ) 
    # New coordinate system with normal being reflection direction
    e1 = normalize(.-idir)
    e2 = normalize(e1 × axes.n)
    n = normalize(e2 × e1)
    # Calculate zenith angle with respect to reflection direction
    α = acos(rand(rng)^(1/(m.n + 1)))
    # From polar to Cartessian
    dir = polar_to_cartesian((e1 = e1, e2 = e2, n = n ), α, Φ)
    # Calculate θ
    θ = acos(dir ⋅ axes.n)
end
