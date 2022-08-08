

#=
    Structure that stores all the relevant information concerning the
intersection of a ray with a triangle
=#
struct Intersection{FT}
    pint::Vec{FT}
    axes::NTuple{3, Vec{FT}}
    front::Bool
    id::Int64
end
function Intersection(::Type{FT}) where FT 
    f = zero(FT)
    v = Vec(f, f, f)
    Intersection(v, (v, v, v), false, 0)
end

#=
Methods that need to be implemented for Acceleration types:
    - intersect(a::Acceleration, ray, nodestack) -> return whether there is a hit and Intersection object
=#
abstract type Acceleration{FT} end

include("Naive.jl")
include("BVH.jl")


#=
    A grid cloner creates multiple instances of the scene with a fixed displacement that can be applied to the rays
    This allows approximating an infinite canopy with low overhead
=#

include("cloner.jl")