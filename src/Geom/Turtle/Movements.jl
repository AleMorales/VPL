### This file contains public API ###

################################################################################
########################## Turtle's movements  #################################
################################################################################

"""
    t!(turtle; to = O())

Translate a turtle to the new position `to` (a `Vec` object). 
"""
function t!(turtle::MTurtle{FT}; to::Vec{FT} = O(FT)) where FT
    update!(turtle, to = to, head = head(turtle), up = up(turtle), 
                    arm = arm(turtle))
end

"""
    T(to::Vec)

Node that translates a turtle to the new position `to` (a `Vec` object).
"""
struct T{FT} <: Node
    to::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::T) = t!(turtle, to = node.to)


"""
    or!(turtle; head = Z(), up = X(), arm = Y())

Orient a turtle to a new direction by re-defining the local reference system.
The arguments `head`, `up` and `arm` should be of type `Vec`.
"""
function or!(turtle::MTurtle{FT}; head::Vec{FT} = Z(FT), up::Vec{FT} = X(FT), 
             arm::Vec{FT} = Y(FT)) where FT
    update!(turtle, head = head, up = up, arm = arm, to = pos(turtle))
end

"""
    OR(head::Vec, up::Vec, arm::Vec)

Node that orients a turtle to a new direction by re-defining the local reference 
system.
"""
struct OR{FT} <: Node
    head::Vec{FT}
    up::Vec{FT}
    arm::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::OR) = 
                     or!(turtle, head = node.head, up = node.up, arm = node.arm)

"""
    set!(turtle; to = O(), head = Z(), up = X(), arm = Y())

Set position and orientation of a turtle. The arguments `to`, `head`, `up` and 
`arm` should be of type `Vec` and be passed as keyword arguments.
"""
function set!(turtle::MTurtle{FT}; to::Vec{FT} = O(FT), head::Vec{FT} = Z(FT), 
              up::Vec{FT} = X(FT), arm::Vec{FT} = Y(FT)) where FT
    update!(turtle, head = head, up = up, arm = arm, to = to)
end

"""
    SET(to, head, up, arm)

Node that sets the position and orientation of a turtle.
"""
Base.@kwdef struct SET{FT} <: Node
    to::Vec{FT}
    head::Vec{FT}
    up::Vec{FT}
    arm::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::SET) = 
      set!(turtle, to = node.to, head = node.head, up = node.up, arm = node.arm)


"""
    ru!(turtle, angle)

Rotates a turtle around up axis. Angle must be in hexadecimal degrees and the 
rotation is clockwise.
"""
function ru!(turtle::MTurtle{FT}, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    h = head(turtle).*c .+ arm(turtle).*s
    a = h × up(turtle)
    update!(turtle, head = h, arm = a, to = pos(turtle), up = up(turtle))
end

"""
    RU(angle)

Node that rotates a turtle around up axis. Angle must be in hexadecimal degrees 
and the rotation is clockwise.
"""
struct RU{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RU) = ru!(turtle, node.angle)
  
  
"""
    ra!(turtle, angle)

Rotates a turtle around arm axis. Angle must be in hexadecimal degrees and the 
rotation is clockwise.
"""
function ra!(turtle::MTurtle{FT}, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ head(turtle).*s
    h = u × arm(turtle)
    update!(turtle, head = h, up = u, to = pos(turtle), arm = arm(turtle))
end

"""
    RA(angle)

Node that rotates a turtle around arm axis. Angle must be in hexadecimal degrees 
and the rotation is clockwise.
"""
struct RA{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RA) = ra!(turtle, node.angle)
  
  
"""
    rh!(turtle, angle)

Rotate turtle around head axis. Angle must be in hexadecimal degrees and the 
rotation is clockwise.
"""
function rh!(turtle::MTurtle{FT}, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ arm(turtle).*s
    a = head(turtle) × u
    update!(turtle, arm = a, up = u, to = pos(turtle), head = head(turtle))
end

"""
    RH(angle)

Node that rotates a turtle around head axis. Angle must be in hexadecimal 
degrees and the rotation is clockwise.
"""
struct RH{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RH) = rh!(turtle, node.angle)
  
  
"""
    f!(turtle, dist)

Move turtle forward a given distance.
"""
function f!(turtle::MTurtle{FT}, dist::FT) where FT
    to = pos(turtle) .+ head(turtle).*dist
    update!(turtle,  to = to, arm = arm(turtle), up = up(turtle), head = head(turtle))
end

"""
    F(dist)
    
Moves a turtle forward a given distance.
"""
struct F{FT} <: Node
    dist::FT
end
feedgeom!(turtle::MTurtle, node::F) = f!(turtle, node.dist)