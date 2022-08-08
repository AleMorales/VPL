
# TODO: Naive should not longer have a global box

# This is effectively providing no acceleration -> the ray will be tested
# against all triangles in the scene
struct Naive{FT} <: Acceleration{FT}
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
function intersect(ray::Ray{FT}, acc::Naive, nodestack, dstack, dmin) where FT
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
            return false, Intersection(FT), dmin
        else
            triangle = acc.triangles[posmin]
            intersection = Intersection(ray.o .+ dmin.*ray.dir, # pint
                                        axes(triangle),         # axes
                                        frontmin,               # front
                                        acc.id[posmin])         # material
            return true, intersection, dmin
        end
    end
end