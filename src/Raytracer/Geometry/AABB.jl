### This file DOES NOT contain public API ###

# Axis-aligned bounding box defined by two opposite vertices that determine the
# minimum and maximum coordinates of the box
struct AABB{FT}
    min::Vec{FT}
    max::Vec{FT}
end

# Ray - AABB intersection
# Returns whether an intersection with a ray occurs and the point of intersection
function Base.intersect(ray::Ray{FT}, box::AABB{FT}, tcur::FT = zero(FT)) where FT
    @inbounds begin
        t1 = (box.min .- ray.o).*ray.idir
        t2 = (box.max .- ray.o).*ray.idir
        vtmax = max.(t1, t2)
        vtmin = min.(t1, t2)
        tmax = min(vtmax[3], min(vtmax[1], vtmax[2]))
        tmin = max(vtmin[3], max(vtmin[1], vtmin[2]))
        return tmax > max(tcur, tmin), tmin
    end
 end

# Calculate the area of an AABB
function area(b::AABB{FT}) where FT
    @inbounds begin
        dx = b.max[1] - b.min[1]
        dy = b.max[2] - b.min[2]
        dz = b.max[3] - b.min[3]
        FT(2)*(dx*dy + dy*dz + dz*dx)
    end
end

# Createa an AABB around a single triangle
function AABB(t::Triangle{FT}) where FT
    p2 = t.p .+ t.e1
    p3 = t.p .+ t.e2
    mn = min.(min.(t.p, p2), p3)
    mx = max.(max.(t.p, p2), p3) .+ Vec(10*eps(FT) for i in 1:3)
    AABB(mn, mx)
end

# Createa an AABB around a vector of triangles
function AABB(vt::Vector{<:Triangle})
    @inbounds begin
        out = AABB(vt[1])
        if length(vt) > 1
            for i in 2:length(vt)
                out = AABB(out, AABB(vt[i]))
            end
        end
        return out
    end
end

# Merge two AABBs
function AABB(box1::AABB, box2::AABB)
    @inbounds begin
        gmin = min.(box1.min, box2.min)
        gmax = max.(box1.max, box2.max)
        return AABB(gmin, gmax)
    end
end


# Calculate an AABB that surrounds tightly a list of AABBs
function AABB(boxes::Vector{<: AABB})
    @inbounds begin
        gmin = boxes[1].min
        gmax = boxes[1].max
        for i = 2:length(boxes)
            b = boxes[i]
            gmin = min.(gmin, b.min)
            gmax = max.(gmax, b.max)
        end
        return AABB(gmin, gmax)
    end
end

# Calculate an AABB that surrounds tightly a list of AABBs when indices are given separately
function AABB(boxes::Vector{<: AABB}, indices::Vector{<: Int})
    #@inbounds begin
    begin
        gmin = boxes[indices[1]].min
        gmax = boxes[indices[1]].max
        for i in indices
            b = boxes[i]
            gmin = min.(gmin, b.min)
            gmax = max.(gmax, b.max)
        end
        return AABB(gmin, gmax)
    end
end

# Utilities for AABB
function longest(box::AABB)
    @inbounds begin
        lon = 1
        len = box.max[1] - box.min[1]
        for i = 2:3
            nlen = box.max[i] - box.min[i]
            nlen > len && (lon = i; len = nlen)
        end
        return lon
    end
end

center(b::AABB{FT}) where FT = (b.min .+ b.max)./FT(2)

function height(b::AABB) 
    @inbounds b.max[3] - b.min[3]
end

function topcenter(b::AABB{FT}) where FT 
   h = height(b)
   c = center(b)
   c .+ h.*Z(FT)./FT(2)
end

# First four are in the lower plane, the others are in the upper plane
function vertices(b::AABB{FT}) where FT
    @inbounds begin
        f0 = zero(FT)
        Δ = b.max .- b.min
        (v1 = b.min, 
         v2 = b.min .+ Vec(Δ[1],f0,f0),
         v3 = b.min .+ Vec(f0,Δ[2],f0),
         v4 = b.max .- Vec(f0,f0,Δ[3]),
         v5 = b.min .+ Vec(f0,f0,Δ[3]),
         v7 = b.max .- Vec(f0,Δ[2],f0),
         v6 = b.max .- Vec(Δ[1],f0,f0),
         v8 = b.max)
    end
end

# Check if a box is actually a point 
Base.isempty(box::AABB{FT}) where FT = box.min ≈ Vec{FT}(0,0,0) && box.max == Vec{FT}(0,0,0)

# Base area of a box (plane XY)
base_area(box::AABB) = (box.max[1] - box.min[1])*(box.max[2] - box.min[2])