# Construct primitives using a turtle to define translation and rotation.
# All primitives allow for optionally moving the turtle forward to update its position

function Ellipse!(turtle::MTurtle{FT}; l = one(FT), w = one(FT), n = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 1) 
    trans = transform(turtle, (one(FT), w/FT(2), l/FT(2)))
    Ellipse!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function Rectangle!(turtle::MTurtle{FT}; l = one(FT), w = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 4) 
    trans = transform(turtle, (one(FT), w/FT(2), l))
    Rectangle!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

function HollowCone!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 1) 
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function HollowCube!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 8)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCube!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

function HollowCylinder!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function HollowFrustum!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), ratio::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    HollowFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function SolidCone!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), n + 2)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCone!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function SolidCube!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 8)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCube!(turtle.geoms, trans)
    move && f!(turtle, l)
    return nothing
end

function SolidCylinder!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n + 2)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidCylinder!(turtle.geoms, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function SolidFrustum!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), ratio::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    push!(nvertices(turtle), 2n + 2)
    trans = transform(turtle, (h/FT(2), w/FT(2), l))
    SolidFrustum!(turtle.geoms, ratio, trans; n = n)
    move && f!(turtle, l)
    return nothing
end

function Ellipsoid!(turtle::MTurtle{FT}; l::FT = one(FT), w::FT = one(FT), h::FT = one(FT), n::Int = 20, move = false) where FT <: AbstractFloat
    @error "Ellipsoid not implemented yet"
    return nothing
end