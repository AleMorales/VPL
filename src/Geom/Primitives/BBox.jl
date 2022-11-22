### This file contains public API ###

"""
    BBox(m::Mesh)

Build a tight axis-aligned bounding box around a `Mesh` object.
"""
function BBox(m::Mesh{VT}) where VT <: Vec{FT} where FT
    @inbounds xmin, ymin, zmin = m.vertices[1]
    xmax, ymax, zmax = xmin, ymin, zmin 
    for v in m.vertices
        x, y, z  = v
        xmax = max(x, xmax)
        ymax = max(y, ymax)
        zmax = max(z, zmax)
        xmin = min(x, xmin)
        ymin = min(y, ymin)
        zmin = min(z, zmin)
    end
    pmin = Vec{FT}(xmin, ymin, zmin)
    pmax = Vec{FT}(xmax, ymax, zmax)

    BBox(pmin, pmax)

end

"""
    BBox(pmin::Vec, pmax::Vec)

Build an axis-aligned bounding box given the vector of minimum (`pmin`) and 
maximum (`pmax`) coordinates.
"""
function BBox(pmin::Vec{FT}, pmax::Vec{FT}) where FT
    @inbounds begin
        h    = pmax[1] - pmin[1]
        w    = pmax[2] - pmin[2]
        l    = pmax[3] - pmin[3]
        v2 = pmin .+ Vec{FT}(0,w,0)
        v3 = v2   .+ Vec{FT}(h,0,0)
        v4 = v3   .+ Vec{FT}(0,-w,0)
        v5 = pmin .+ Vec{FT}(0,0,l)
        v6 = v5   .+ Vec{FT}(0,w,0)
        v8 = pmax .+ Vec{FT}(0,-w,0)
        BBox(pmin, v2, v3, v4, v5, v6, pmax, v8)
    end
end

# Create the mesh associated to a bbox from the list of vertices
function BBox(v1, v2, v3, v4, v5, v6, v7, v8)
    vertices = [v1, v2, v3, v4, v5, v6, v7, v8]
    faces = [Face(1,4,3), Face(1,3,2), Face(1,5,8), 
             Face(1,8,4), Face(4,8,7), Face(4,7,3),
             Face(3,7,6), Face(3,6,2), Face(2,6,5), 
             Face(2,5,1), Face(5,6,7), Face(5,7,8)]
    normals = create_normals(vertices, faces)
    Mesh(vertices, normals, faces)
end