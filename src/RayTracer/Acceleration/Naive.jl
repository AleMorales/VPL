
# TODO: Naive should not longer have a global box

# This is effectively providing no acceleration -> the ray will be tested
# against all triangles in the scene
struct Naive{FT} <: Acceleration
    gbox::AABB{FT}
    triangles::Vector{Triangle{FT}}
    id::Vector{Int}
end

# Rule is not actually used but is kept for compatibility with BVH
function Naive(triangles, ids, rule = nothing)
    gbox = AABB(triangles)
    Naive(gbox, triangles, ids)
end

# Return closest hit (if any)
# Nodestack is not actually needed
function intersect(acc::Naive, ray::Ray{FT}, nodestack) where FT
    @inbounds begin
        dmin = Inf
        frontmin = true
        posmin = -1
        for i in eachindex(acc.triangles)
            triangle = acc.triangles[i]
            hit, d, front = intersect(ray, triangle)
            if hit && d <= dmin
                dmin = d
                frontmin = front
                posmin = i
            end
        end
        if posmin == -1
            return false, Intersection(FT)
        else
            triangle = acc.triangles[posmin]
            return true, Intersection(ray.o .+ dmin.*ray.dir, # pint
                                    axes(triangle),         # axes
                                    frontmin,               # front
                                    acc.id[posmin])         # material
        end
    end
end