### This file contains public API ###


# Construct primitives using a turtle to define translation and rotation.
# All primitives allow for optionally moving the turtle forward to update its position

"""
    Ellipse!(turtle; length = 1.0, width = 1.0, n = 20, move = false)

Generate an ellipse in front of a turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the ellipse to. 
- `length`: Length of the ellipse. 
- `width`: Width of the ellipse. 
- `n`: Number of triangles of the mesh approximating the ellipse (an integer). 
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A triangle mesh will be generated with `n` triangles that approximates an ellipse.
The ellipse will be generated in front of the turtle, on the plane defined by
the arm and head axes of the turtle. The argument `length` refers to the axis of
the ellipse aligned with the head axis of the turtle, whereas `width` refers to
the orthogonal axis.

When `move = true`, the turtle will be moved forward by a distance equal to `length`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function Ellipse!(turtle::MTurtle{FT}; length = one(FT), width = one(FT), 
                  n = 20, move = false) where FT
    push!(nvertices(turtle), n + 1) 
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (one(FT), width/FT(2), length/FT(2)))
    Ellipse!(turtle.geoms, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

"""
    Rectangle!(turtle; length = 1.0, width = 1.0, move = false)

Generate a rectangle in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the rectangle to. 
- `length`: Length of the rectangle. 
- `width`: Width of the rectangle. 
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A triangle mesh will be generated representing the rectangle.
The rectangle will be generated in front of the turtle, on the plane defined by
the arm and head axes of the turtle. The argument `length` refers to the axis of
the rectangle aligned with the head axis of the turtle, whereas `width` refers to
the orthogonal axis.

When `move = true`, the turtle will be moved forward by a distance equal to `length`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function Rectangle!(turtle::MTurtle{FT}; length::FT = one(FT), width::FT = one(FT), 
                    move = false) where FT
    push!(nvertices(turtle), 4)
    push!(ntriangles(turtle), 2) 
    trans = transform(turtle, (one(FT), width/FT(2), length))
    Rectangle!(turtle.geoms, trans)
    move && f!(turtle, length)
    return nothing
end


"""
    Trapezoid!(turtle; length = 1.0, width = 1.0, ratio = 1.0, move = false)

Generate a trapezoid in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the trapezoid to. 
- `length`: Length of the trapezoid. 
- `width`: Width of the base of the trapezoid. 
- `ratio`: Ratio between the width of the top and base of the trapezoid.
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A triangle mesh will be generated representing the trapezoid.
The trapezoid will be generated in front of the turtle, on the plane defined by
the arm and head axes of the turtle. The argument `length` refers to the axis of
the trapezoid aligned with the head axis of the turtle, whereas `width` refers to
the orthogonal axis.

When `move = true`, the turtle will be moved forward by a distance equal to `length`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function Trapezoid!(turtle::MTurtle{FT}; length::FT = one(FT), width::FT = one(FT), 
                   ratio::FT = one(FT), move = false) where FT
    push!(nvertices(turtle), 4)
    push!(ntriangles(turtle), 2) 
    trans = transform(turtle, (one(FT), width/FT(2), length))
    Trapezoid!(turtle.geoms, trans, ratio)
    move && f!(turtle, length)
    return nothing
end

"""
    HollowCone!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 20, move = false)

Generate a hollow cone in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the hollow cone to. 
- `length`: Length of the ellipse at the base of the hollow cone. 
- `width`: Width of the ellipse at the base of the hollow cone. 
- `height`: Height of the hollow cone. 
- `n`: Number of triangles in the mesh. 
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A mesh will be generated with n triangles that approximate the hollow cone.
The cone will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function HollowCone!(turtle::MTurtle{FT}; length::FT = one(FT), 
                     width::FT = one(FT), height::FT = one(FT), n::Int = 20, 
                     move = false) where FT
    push!(nvertices(turtle), n + 1) 
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    HollowCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

"""
    HollowCube!(turtle; length = 1.0, width = 1.0, height = 1.0, move = false)

Generate a hollow cube in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the hollow cube to. 
- `length`: Length of the rectangle at the base of the hollow cube. 
- `width`: Width of the rectangle at the base of the hollow cube. 
- `height`: Height of the hollow cube. 
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A mesh will be generated of a hollow cube.
The cube will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis 
and `height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function HollowCube!(turtle::MTurtle{FT}; length::FT = one(FT), 
                     width::FT = one(FT), height::FT = one(FT), 
                     move = false) where FT
    push!(nvertices(turtle), 8)
    push!(ntriangles(turtle), 8) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    HollowCube!(turtle.geoms, trans)
    move && f!(turtle, length)
    return nothing
end

"""
    HollowCylinder!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 40, move = false)

Generate a hollow cylinder in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the hollow cylinder to. 
- `length`: Length of the ellipse at the base of the hollow cylinder. 
- `width`: Width of the ellipse at the base of the hollow cylinder. 
- `height`: Height of the hollow cylinder. 
- `n`: Number of triangles in the mesh (must be even). 
- `move`: Whether to move the turtle forward or not (`true` or `false`). 

## Details
A mesh will be generated with n triangles that approximate the hollow cylinder.
The cylinder will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function HollowCylinder!(turtle::MTurtle{FT}; length::FT = one(FT), 
                         width::FT = one(FT), height::FT = one(FT), 
                         n::Int = 40, move = false) where FT
    @assert iseven(n)
    push!(nvertices(turtle), n)
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    HollowCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

"""
    HollowFrustum!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 40, move = false)

Generate a hollow frustum in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the hollow frustum to. 
- `length`: Length of the ellipse at the base of the hollow frustum. 
- `width`: Width of the ellipse at the base of the hollow frustum. 
- `height`: Height of the hollow frustum. 
- `n`: Number of triangles in the mesh (must be even). 
- `move`: Whether to move the turtle forward or not (`true` or `false`). 

## Details
A mesh will be generated with n triangles that approximate the hollow frustum.
The frustum will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function HollowFrustum!(turtle::MTurtle{FT}; length::FT = one(FT), 
                        width::FT = one(FT), height::FT = one(FT), 
                        ratio::FT = one(FT), n::Int = 40, 
                        move = false) where FT
    @assert iseven(n)
    push!(nvertices(turtle), n)
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    HollowFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, length)
    return nothing
end


"""
    SolidCone!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 40, move = false)

Generate a solid frustum in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the solid cone to. 
- `length`: Length of the ellipse at the base of the solid cone. 
- `width`: Width of the ellipse at the base of the solid cone. 
- `height`: Height of the solid cone. 
- `n`: Number of triangles in the mesh (must be even). 
- `move`: Whether to move the turtle forward or not (`true` or `false`). 

## Details
A mesh will be generated with n triangles that approximate the solid cone.
The cone will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function SolidCone!(turtle::MTurtle{FT}; length::FT = one(FT), 
                    width::FT = one(FT), height::FT = one(FT), n::Int = 40, 
                    move = false) where FT
    @assert iseven(n)
    push!(nvertices(turtle), n/2 + 2)
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    SolidCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

"""
    SolidCube!(turtle; length = 1.0, width = 1.0, height = 1.0, move = false)

Generate a solid cube in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the solid cube to. 
- `length`: Length of the rectangle at the base of the solid cube. 
- `width`: Width of the rectangle at the base of the solid cube. 
- `height`: Height of the solid cube. 
- `move`: Whether to move the turtle forward or not (`true` or `false`).  

## Details
A mesh will be generated of a solid cube.
The cube will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis 
and `height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function SolidCube!(turtle::MTurtle{FT}; length::FT = one(FT), 
                    width::FT = one(FT), height::FT = one(FT), 
                    move = false) where FT
    push!(nvertices(turtle), 8)
    push!(ntriangles(turtle), 12) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    SolidCube!(turtle.geoms, trans)
    move && f!(turtle, length)
    return nothing
end

"""
    SolidCylinder!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, move = false)

Generate a solid cylinder in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the solid cylinder to. 
- `length`: Length of the ellipse at the base of the solid cylinder. 
- `width`: Width of the ellipse at the base of the solid cylinder. 
- `height`: Height of the solid cylinder. 
- `n`: Number of triangles in the mesh (must be even). 
- `move`: Whether to move the turtle forward or not (`true` or `false`). 

## Details
A mesh will be generated with n triangles that approximate the solid cylinder.
The cylinder will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function SolidCylinder!(turtle::MTurtle{FT}; length::FT = one(FT), 
                        width::FT = one(FT), height::FT = one(FT), 
                        n::Int = 80, move = false) where FT
    @assert iseven(n)
    push!(nvertices(turtle), n/2 + 2)
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    SolidCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

"""
    SolidFrustum!(turtle; length = 1.0, width = 1.0, height = 1.0, n = 80, move = false)

Generate a solid frustum in front of the turtle and feed it to a turtle.

## Arguments
- `turtle`: The turtle that we feed the solid frustum to. 
- `length`: Length of the ellipse at the base of the solid frustum. 
- `width`: Width of the ellipse at the base of the solid frustum. 
- `height`: Height of the solid frustum. 
- `n`: Number of triangles in the mesh (must be even). 
- `move`: Whether to move the turtle forward or not (`true` or `false`). 

## Details
A mesh will be generated with n triangles that approximate the solid frustum.
The frustum will be generated in front of the turtle, with the base on the plane
defined by the arm and up axes of the turtle, centered at the head axis. The
`length` argument refers to the up axis, whereas `width` refers to the arm axis and 
`height` is associated to the head axis.

When `move = true`, the turtle will be moved forward by a distance equal to `height`.

## Return
Returns `nothing` but modifies the `turtle` as a side effect.
"""
function SolidFrustum!(turtle::MTurtle{FT}; length::FT = one(FT), 
                       width::FT = one(FT), height::FT = one(FT), 
                       ratio::FT = one(FT), n::Int = 80, 
                       move = false) where FT
    @assert iseven(n)
    push!(nvertices(turtle), n/2 + 2)
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (height/FT(2), width/FT(2), length))
    SolidFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, length)
    return nothing
end

function Ellipsoid!(turtle::MTurtle{FT}; length::FT = one(FT), 
                    width::FT = one(FT), height::FT = one(FT), 
                    n::Int = 20, move = false) where FT
    @error "Ellipsoid not implemented yet"
    return nothing
end