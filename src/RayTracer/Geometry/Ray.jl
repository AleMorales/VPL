# Ray
# o = Origin of the Ray
# dir = Direction unit vector
# idir = Inverse of dir (precalculation for ray - triangle intersection)
# extra = - o * idir (precalculation for ray - aabb intersection)
struct Ray{FT}
    o::Vec{FT}
    dir::Vec{FT}
    idir::Vec{FT}
    extra::Vec{FT}
end

# Construct Ray from point of origin and direction
function Ray(o::Vec{FT}, dir::Vec{FT}) where FT
    idir = one(FT)./dir
    Ray(o, dir, idir, .-o.*idir)
end