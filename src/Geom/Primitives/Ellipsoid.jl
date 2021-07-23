function equal_solid_angles(n)
    # Distribution sectors along zenith angles
    Δθ = π/2/n
    uθₗ = 0.0:Δθ:π/2 - Δθ
    uθᵤ = Δθ:Δθ:π/2

    # Calculate number of azimuth sectors and ΔΦ per zenith ring 
    fac = cos.(uθₗ) - cos.(uθᵤ)
    n2 = n*n
    ns = round.(fac./sum(fac).*n2)
    sum(ns) != n2 && (ns[end] = ns[end] + n2 - sum(ns))
    ΔΦs = 2π./ns

    # Generate coordinates of all sectors
    c = 1
    θₗ  = Vector{Float32}(undef, n2)
    θᵤ = Vector{Float32}(undef, n2)
    Φₗ  = Vector{Float32}(undef, n2)
    Φᵤ = Vector{Float32}(undef, n2)
    for i in 1:n
        ΔΦ = ΔΦs[i]
        for j in 1:ns[i]
            θₗ[c]  = Δθ*(i - 1)
            θᵤ[c] = Δθ*i
            Φₗ[c]  = ΔΦ*(j - 1)
            Φᵤ[c] = ΔΦ*j
            c += 1
        end
    end

    (θₗ, θᵤ, Φₗ, Φᵤ,ns)
end

# Every combination of theta and phi angles yields a vertex
# Then the vertex are mapped to the other hemisphere
# This means that we cannot have vertices at theta = 0

# Step 1: Turn the function above into an interator that generates
# vertices in both hemispheres (following a reasonable ordering)

# Step 2: Create the rules to connect these vertices into triangles

# Step 3: Create the normals to each face (average theta and phi??)


# Scaled ellipsoid
function Ellipsoid(l::Number, w::Number, h::Number, n::Number)
    @error "Ellipsoid not implemented yet"
end

# Create a ellipsoid from affine transformation
function Ellipsoid(trans::AbstractAffineMap, nt::Number)
    @error "Ellipsoid not implemented yet"
end

# Create a ellipsoid from affine transformation and add it in-place to existing mesh
function Ellipsoid(m::Mesh, trans::AbstractAffineMap, nt::Int) 
    @error "Ellipsoid not implemented yet"
end
        