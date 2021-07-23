
# Make sure the turtle has this orientation, to be compatible with Makie
# Up   -> X axis
# Arm  -> Y axis
# Head -> Z axis

Base.@kwdef struct TCoord{FT}
    head::Vec{FT} = Z(FT)
    up::Vec{FT}   = X(FT)
    arm::Vec{FT}  = Y(FT)
    pos::Vec{FT}  = Vec{FT}(0,0,0)
end


Base.@kwdef mutable struct MTurtle{FT} <: Turtle
    coords::TCoord{FT} = TCoord{FT}()
    geoms::Mesh{Vec{FT}} = Mesh(FT)
    nvertices::Vector{Int} = Int[]
end

# Update coordinate system associated to a turtle
function update!(turtle::MTurtle; to, head, up, arm)
    turtle.coords = TCoord(head = head, up = up, arm = arm, pos = to)
    return nothing
end

# Access fields without having to know the internal structure
head(turtle::MTurtle)  = turtle.coords.head
up(turtle::MTurtle)    = turtle.coords.up
arm(turtle::MTurtle)   = turtle.coords.arm
pos(turtle::MTurtle)   = turtle.coords.pos
geoms(turtle::MTurtle) = turtle.geoms
nvertices(turtle::MTurtle) = turtle.nvertices