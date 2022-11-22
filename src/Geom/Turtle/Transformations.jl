### This file DOES NOT contains public API ###

################################################################################
########################## Transformations ##################################
################################################################################

# Scaling
function scale(mat)
    LinearMap(mat)
end
function scale(x, y, z)
    mat = SDiagonal(x, y, z)
    scale(mat)
end
function scale(v::Vec)
    mat = SDiagonal(v...)
    scale(mat)
end

# Translation
function translate(x, y, z) 
    Translation(x, y, z)
end
function translate(v::Vec)
    @inbounds translate(v[1], v[2], v[3])
end


# Rotation around x
function rotatex(θ) 
    rotation = RotX(θ)
    LinearMap(rotation)
end

# Rotation around y
function rotatey(θ) 
    rotation = RotY(θ)
    LinearMap(rotation)
end

# Rotation around z
function rotatez(θ) 
    rotation = RotZ(θ)
    LinearMap(rotation)
end

# Rotation to a new Cartesian system
function rotate(x::Vec{FT}, y::Vec{FT}, z::Vec{FT}) where FT
    @inbounds mat = SMatrix{3,3,FT}(x[1], x[2], x[3], 
                                    y[1], y[2], y[3],
                                    z[1], z[2], z[3])
    LinearMap(mat)
end

# Calculate rotation matrix to go from reference turtle to current turtle.
function rot(turtle::MTurtle)
    rotate(up(turtle), arm(turtle), head(turtle))
end
  
# Create an affine map based on turtle position, orientation
function transform(turtle::MTurtle)
    r = rot(turtle)
    t = translate(pos(turtle)...)
    t ∘ r
end

# Create a transform based on turtle position, orientation and
# user-provided scaling factors for each axis.
function transform(turtle::MTurtle, scales)
    s = scale(scales...)
    r = rot(turtle)
    t = translate(pos(turtle)...)
    t ∘ r ∘ s
end