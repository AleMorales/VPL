# Triangle
# The triangle is defined in barycentric coordinates to speed up ray-triangle
# intersections.
# The normal vector is also included as well as the index of the material object
# p = A vertex on the triangle
# e1 = An edge of the triangle having p as origin (length = side of triangle)
# e2 = Like e1, but for the other side of the triangle
# n = Normal unit vector (defined by cross product of e1 and e2)
struct Triangle{FT}
    p::Vec{FT}
    e1::Vec{FT}
    e2::Vec{FT}
    n::Vec{FT}
end

"""
    Triangle(p1, p2, p3)

Create a ray tracing `Triangle` object given the three vertices `p1`, `p2` and `p3`.
"""
function Triangle(p1::Vec, p2::Vec, p3::Vec)
    e1 = p2 .- p1
    e2 = p3 .- p1
    Triangle(p1, e1, e2, normalize(cross(e1, e2)))
end

"""
    Triangle(mesh)

Create a vector of ray tracing `Triangle` objects from a `Mesh` object.
"""
function Triangle(mesh::Mesh)
    [Triangle(mesh.vertices[face]...) for face in mesh.faces]
end

# Moller-Trumbore intersection test with early exits
# Returns intersection_test (T/F), intersection_distance, front (T/F)
# The front of the triangle is simply the side the normal uVec points to
# Note: This will fail when the ray hits exactly on the border of the triangle
function intersect(ray::Ray{FT}, t::Triangle{FT}) where FT
    # Check if the ray intercepts the plane containing the triangle
    pvec = ray.dir × t.e2
    det = t.e1 ⋅ pvec
    idet = one(FT)/det
    # Calculate coordinates of point in barycentric coordinates
    tvec = ray.o - t.p
    u = idet*(tvec ⋅ pvec)
    (u <= zero(FT) || u >= one(FT)) && (return (false, zero(FT), true))
    qvec = tvec × t.e1
    v = idet*(ray.dir ⋅ qvec)
    (v <= zero(FT) || u + v >= one(FT)) && (return (false, zero(FT), true))
    # Calculate distance to hit
    d = idet*(t.e2 ⋅ qvec)
    (d <= zero(FT)) && (return (false, zero(FT), true))
    return true, d, det < zero(FT)
end

# Return a local system of coordinates defined by two vectors (third axes is the cross product of these two)
function axes(t::Triangle)
    (normalize(t.e1), normalize(t.n × t.e1), t.n) # e1, e2, n
end

# Sample a point from the parallelogram and then apply reflection
function generate_point(t::Triangle{FT}, rng) where FT 
    u1 = rand(rng, FT)
    u2 = rand(rng, FT)
    if u1 + u2 > FT(1)
        u1 = FT(1) - u1
        u2 = FT(1) - u2
    end
    @. t.p + t.e1*u1 + t.e2*u2
end

# Calculate area of a triangle (the norm of cross product is the area of the parallelogram defined by those vectors)
area(t::Triangle{FT}) where FT = FT(0.5)*norm(t.e1 × t.e2)