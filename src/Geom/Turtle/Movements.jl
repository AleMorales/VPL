################################################################################
########################## Turtle's movements  #################################
################################################################################

"""
  t!(turtle::MTurtle, to)
Translate turtle to a new position.
"""
function t!(turtle::MTurtle; to)
    update!(turtle, to = to, head = head(turtle), up = up(turtle), arm = arm(turtle))
end
struct T{FT} <: Node
    to::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::T) = t!(turtle, to = node.to)


"""
  or!(turtle::MTurtle, head, up, arm)
Orient turtle to a new direction by re-defining the local reference system.
"""
function or!(turtle::MTurtle; head, up, arm)
    update!(turtle, head = head, up = up, arm = arm, to = pos(turtle))
end
struct OR{FT} <: Node
    head::Vec{FT}
    up::Vec{FT}
    arm::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::OR) = or!(turtle, head = node.head, up = node.up, arm = node.arm)

"""
  set!(turtle::MTurtle, to, head, up, arm)
Set position and orientation of turtle.
"""
function set!(turtle::MTurtle; to, head, up, arm)
    update!(turtle, head = head, up = up, arm = arm, to = to)
end
Base.@kwdef struct SET{FT} <: Node
    to::Vec{FT}
    head::Vec{FT}
    up::Vec{FT}
    arm::Vec{FT}
end
feedgeom!(turtle::MTurtle, node::SET) = set!(turtle, to = node.to, head = node.head, up = node.up, arm = node.arm)


"""
  ru!(turtle::MTurtle, angle)
Rotate turtle around up axis. Angle must be in hexadecimal degrees and the rotation
is clockwise.
"""
function ru!(turtle, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    h = head(turtle).*c .+ arm(turtle).*s
    a = h × up(turtle)
    update!(turtle, head = h, arm = a, to = pos(turtle), up = up(turtle))
end
struct RU{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RU) = ru!(turtle, node.angle)
  
  
"""
  ra!(turtle::MTurtle, angle)
Rotate turtle around arm axis. Angle must be in hexadecimal degrees and the rotation
is clockwise.
"""
function ra!(turtle::MTurtle, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ head(turtle).*s
    h = u × arm(turtle)
    update!(turtle, head = h, up = u, to = pos(turtle), arm = arm(turtle))
end
struct RA{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RA) = ra!(turtle, node.angle)
  
  
"""
  rh!(turtle::MTurtle, angle)
Rotate turtle around head axis. Angle must be in hexadecimal degrees and the rotation
is clockwise.
"""
function rh!(turtle::MTurtle, angle::FT) where FT
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ arm(turtle).*s
    a = head(turtle) × u
    update!(turtle, arm = a, up = u, to = pos(turtle), head = head(turtle))
end
struct RH{FT} <: Node
    angle::FT
end
feedgeom!(turtle::MTurtle, node::RH) = rh!(turtle, node.angle)
  
  
"""
  f(turtle::MTurtle, dist)
Move turtle forward a given distance.
"""
function f!(turtle::MTurtle, dist)
    to = pos(turtle) .+ head(turtle).*dist
    update!(turtle,  to = to, arm = arm(turtle), up = up(turtle), head = head(turtle))
end
struct F{FT} <: Node
    dist::FT
end
feedgeom!(turtle::MTurtle, node::F) = f!(turtle, node.dist)