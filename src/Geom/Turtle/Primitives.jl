# Construct primitives using a turtle to define translation and rotation.
# All primitives allow for optionally moving the turtle forward to update its position
"""
    Ellipse!(turtle; l = 1.0, w = 1.0, n = 20, move = false)

Generate an ellipse with length `l` (along the `head` of the turtle) and width `w` (along the `arm` of the turtle)
in front of the turtle and optionally move the turtle forward to the opposite side of the generated rectangle (see
VPL documentation for for more details). The ellipse will be converted into a mesh with `n` triangles.
"""
function Ellipse!(turtle::MTurtle{FT}; l = one(FT), w = one(FT), n = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 1) 
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (one(FT), w/FT(2), l/FT(2)))
    Ellipse!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    Rectangle!(turtle; l = 1.0, w = 1.0, move = false)

Generate a rectangle with length `l` (along the `head` of the turtle) and width `w` (along the `arm` of the turtle)
in front of the turtle and optionally move the turtle forward to the opposite side of the generated rectangle (see
VPL documentation for for more details).
"""
function Rectangle!(turtle::MTurtle{FT}; l = one(FT), w = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 4)
    push!(ntriangles(turtle), 2) 
    trans = transform(turtle, (one(FT), w/FT(2), l))
    Rectangle!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

"""
    HollowCone!(turtle; l = 1.0, w = 1.0, h = 1.0, n = 20, move = false)

Generate a hollow cone with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated hollow cone (see VPL documentation for for more details). The hollow cone will be converted into a mesh 
with `n` triangles.
"""
function HollowCone!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 1) 
    push!(ntriangles(turtle), n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    HollowCube!(turtle; l = 1.0, w = 1.0, h = 1.0, move = false)

Generate a hollow cube with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated hollow cube (see VPL documentation for for more details).
"""
function HollowCube!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 8)
    push!(ntriangles(turtle), 8) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCube!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

"""
    HollowCylinder!(turtle; l = 1.0, w = 1.0, h = 1.0, n = 20, move = false)

Generate a hollow cylinder with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated hollow cylinder (see VPL documentation for for more details). The hollow cylinder will be converted into 
a mesh with `2n` triangles.
"""
function HollowCylinder!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n)
    push!(ntriangles(turtle), 2n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    HollowFrustum!(turtle; l = 1.0, w = 1.0, h = 1.0, ratio =  1.0, n = 20, move = false)

Generate a hollow frustum with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated hollow frustum (see VPL documentation for for more details). The hollow frustum will be converted into 
a mesh with `2n` triangles.
"""
function HollowFrustum!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), ratio::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n)
    push!(ntriangles(turtle), 2n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    SolidCone!(turtle; l = 1.0, w = 1.0, h = 1.0, n = 20, move = false)

Generate a solid cone with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated solid cone (see VPL documentation for for more details). The solid cone will be converted into a mesh 
with `2n` triangles.
"""
function SolidCone!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 2)
    push!(ntriangles(turtle), 2n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    SolidCube!(turtle; l = 1.0, w = 1.0, h = 1.0, move = false)

Generate a solid cube with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated solid cube (see VPL documentation for for more details).
"""
function SolidCube!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 8)
    push!(ntriangles(turtle), 12) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCube!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

"""
    SolidCylinder!(turtle; l = 1.0, w = 1.0, h = 1.0, n = 20, move = false)

Generate a solid cylinder with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated solid cylinder (see VPL documentation for for more details). The solid cylinder will be converted into 
a mesh with `4n` triangles.
"""
function SolidCylinder!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n + 2)
    push!(ntriangles(turtle), 4n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

"""
    SolidFrustum!(turtle; l = 1.0, w = 1.0, h = 1.0, ratio 1.0, n = 20, move = false)

Generate a solid frustum  of a given `ratio` with length `l` (along the `up` direction of the turtle), width `w` (along the `arm` of the turtle)
and height `h` (along the `head` of the turtle) in front of the turtle and optionally move the turtle forward to the opposite 
side of the generated solid frustum (see VPL documentation for for more details). The solid frustum will be converted into 
a mesh with `4n` triangles.
"""
function SolidFrustum!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), ratio::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n + 2)
    push!(ntriangles(turtle), 4n) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function Ellipsoid!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    @error "Ellipsoid not implemented yet"
    return nothing
end