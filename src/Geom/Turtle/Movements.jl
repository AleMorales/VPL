### This file contains public API ###

################################################################################
########################## Turtle's movements  #################################
################################################################################

"""
    t!(turtle; to = O())

Translate a turtle to the new position `to` (a `Vec` object). 
"""
function t!(turtle::MTurtle{FT,UT}; to::Vec{FT} = O(FT)) where {FT,UT}
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
function or!(turtle::MTurtle{FT,UT}; head::Vec{FT} = Z(FT), up::Vec{FT} = X(FT), 
             arm::Vec{FT} = Y(FT)) where {FT,UT}
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
function set!(turtle::MTurtle{FT,UT}; to::Vec{FT} = O(FT), head::Vec{FT} = Z(FT), 
              up::Vec{FT} = X(FT), arm::Vec{FT} = Y(FT)) where {FT,UT}
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
function ru!(turtle::MTurtle{FT,UT}, angle::FT) where {FT,UT}
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    h = head(turtle).*c .+ arm(turtle).*s
    a = h ?? up(turtle)
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
function ra!(turtle::MTurtle{FT,UT}, angle::FT) where {FT,UT}
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ head(turtle).*s
    h = u ?? arm(turtle)
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
function rh!(turtle::MTurtle{FT,UT}, angle::FT) where {FT,UT}
    angle *= FT(pi)/FT(180)
    c = cos(angle)
    s = sin(angle)
    u = up(turtle).*c .+ arm(turtle).*s
    a = head(turtle) ?? u
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
function f!(turtle::MTurtle{FT,UT}, dist::FT) where {FT,UT}
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


# Taken from https://mathworld.wolfram.com/RodriguesRotationFormula.html
# Returns the matrix for a rotation ?? around vector ??
function rodrigues(??::Vec{FT}, cos??::FT, sin??::FT) where {FT}
    @inbounds begin
        ??x   = ??[1]
        ??y   = ??[2]
        ??z   = ??[3]
        mat = SMatrix{3,3,FT}(cos?? + ??x*??x*(1 - cos??),     # 1,1
                                ??x*??y*(1 - cos??) - ??z*sin??,  # 1,2
                                ??y*sin?? + ??x*??z*(1 - cos??),  # 1,3
                                ??z*sin?? + ??x*??y*(1 - cos??),  # 2,1
                                cos?? +  ??y*??y*(1 - cos??),    # 2,2
                                -??x*sin?? + ??y*??z*(1 - cos??), # 2,3
                                -??y*sin?? + ??x*??z*(1 - cos??), # 3,1
                                ??x*sin?? + ??y*??z*(1 - cos??),  # 3,2
                                cos?? + ??z*??z*(1 - cos??)      # 3,3
                                )
        LinearMap(mat)
    end
end

"""
    rv!(turtle, strength)
    
Rotates the turtle towards the Z axis. The angle of rotation is proportional
to the cosine of the zenith angle of the turtle (i.e., angle between its head 
and the vertical axis) with the absolute value of `strength` being the 
proportion between the two. `strength` should vary between -1 and 1. If 
`strength` is negative, the turtle rotates downwards (i.e., towards negative 
values of Z axis), otherwise upwards.
"""
function rv!(turtle::MTurtle{FT,UT}, strength::FT) where {FT,UT}
    @inbounds begin
        # 1. Create the rotation vector orthogonal to the HZ plane
        H = head(turtle)
        #N = strength > FT(0) ? Z(FT) ?? H : (.-Z(FT)) ?? H
        N = Z(FT) ?? H
        sin????? = norm(N) # Used below
        N = N./sin?????
        # 2. Compute the cosine and sine of the angle of rotation
        # This is achieved by comparing the cos and sin before and 
        # after the rotation (trick below is that the hypotenuse = 1).
        # Also, look at the formula for cos and sin of difference of angles
        cos????? = H[3]
        # Cos law for gravitropism to account for downward branches
        # Notice how the sign of strength determines the new angle
        cos????? =  cos????? + (sign(strength)*FT(1) -  cos?????)*abs(strength)
        sin????? = sqrt(FT(1) - cos?????^2)
        # Compute the cos and sin of the angle of rotation
        cos???? = cos?????*cos????? + sin?????*sin?????
        sin???? = sin?????*cos????? - cos?????*sin?????
        # 3. Create the affine transform with Rodrigues rotation matrix
        trans = rodrigues(N, cos????, sin????)
        # 4. Transform the turtle reference system (does not change norms)
        nhead = trans(head(turtle))
        narm  = trans(arm(turtle))
        nup   = trans(up(turtle))
        # Update the turtle to the new axes
        update!(turtle, to = pos(turtle), head = nhead, arm = narm, up = nup)
    end
end

"""
    RV(strength)
    
Rotates the turtle towards the Z axis. See documentation for `rv!` for details.
"""
struct RV{FT} <: Node
    strength::FT
end
feedgeom!(turtle::MTurtle, node::RV) = rv!(turtle, node.strength)