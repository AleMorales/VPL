### This file contains public API ###


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


#Base.@kwdef mutable struct Turtle{FT, UT}
mutable struct Turtle{FT, UT}
    coords::TCoord{FT}# = TCoord{Float64}()
    geoms::Mesh{Vec{FT}}# = Mesh(Float64)
    #nvertices::Vector{Int}# = Int[]
    #ntriangles::Vector{Int}# = Int[]
    material_ids::Vector{Int}# = Int[]
    materials::Vector{Material}# = Material[]
    colors::Vector{Colorant}# = Colorant[] 
    message::UT# = nothing
end


"""
    Turtle(Float64, message)

Create a meshing turtle that can convert a `Graph` into a 3D mesh using 
turtle operators, geometry primitives and methods of `feed!()`. By default, 
the meshing turtle will generate geometry primitives with double floating 
precision (`Float64`) but it is possible to generate a version with lower 
precision as in `Turtle(Float32)`. The argument `message` is any user-defined
object.
"""
function Turtle(::Type{FT} = Float64, message = nothing) where FT 
    Turtle(TCoord{FT}(), Mesh(FT), Int[], Material[], Colorant[], message)#Int[], Int[], Material[], Colorant[], message)
end

# Update coordinate system associated to a turtle
function update!(turtle::Turtle; to, head, up, arm)
    turtle.coords = TCoord(head = head, up = up, arm = arm, pos = to)
    return nothing
end

# Access fields without having to know the internal structure

"""
    head(turtle)

Extract the direction vector (a `Vec` object) of the head of the turtle.
"""
function head(turtle::Turtle)  
    turtle.coords.head
end

"""
    up(turtle)

Extract the direction vector (a `Vec` object) of the back of the turtle.
"""
function up(turtle::Turtle)
    turtle.coords.up
end

"""
    arm(turtle)

Extract the direction vector (a `Vec` object) of the arm of the turtle.
"""
function arm(turtle::Turtle)
    turtle.coords.arm
end

"""
    pos(turtle)

Extract the current position of the turtle (a `Vec` object).
"""
function pos(turtle::Turtle)
    turtle.coords.pos
end

"""
    geoms(turtle)

Extract the 3D mesh generated by the turtle (a `Mesh` object).
"""
function geoms(turtle::Turtle) 
    turtle.geoms
end

"""
    geoms(turtle)

Extract the faces of the 3D mesh generated by the turtle.
"""
function faces(turtle::Turtle) 
    turtle.geoms.faces
end

"""
    nvertices(turtle)
    
Extract the number of vertices in the mesh associated to each geometry 
primitive that was fed to the turtle.
"""
# function nvertices(turtle::Turtle) 
#     turtle.nvertices
# end

"""
    ntriangles(turtle)
    
Extract the number of triangles in the mesh associated to each geometry 
primitive that was fed to the turtle.
"""
# function ntriangles(turtle::Turtle) 
#     turtle.ntriangles
# end

"""
    materials(turtle)
    
Extract the material objects associated to each geometry primitive that was fed
to the turtle.
"""
function materials(turtle::Turtle) 
    turtle.materials
end

# Material ids connecting each triangle to a material object (internal use only)
function material_ids(turtle::Turtle) 
    turtle.material_ids
end

"""
    colors(turtle)
    
Extract the color objects associated to each geometry primitive that was fed
to the turtle.
"""
function colors(turtle::Turtle) 
    turtle.colors
end


# Add material(s) associated to a primitive
function update_material!(turtle, material, nt) 
    if !isnothing(material) 
        matid = length(materials(turtle)) + 1
        # All triangles shared the same material
        if material isa Material
            push!(materials(turtle), material)
            for _ in 1:nt
                push!(material_ids(turtle), matid)
            end
        # Each triangle has its own material
        elseif length(material) == nt
            append!(materials(turtle), material)
            for i in 0:nt-1
                push!(material_ids(turtle), matid + i)
            end
        else
            error("Provided either a material or a vector of materials of length $(nt)")
        end
    end
    return nothing
end

# Add color(s) associated to a primitive
function update_color!(turtle, color, nvertices)
    if !isnothing(color) 
        # All vertices share the same color
        if color isa Colorant
            for _ in 1:nvertices 
                push!(colors(turtle), color) 
            end
        # Each vertex has its own color
        elseif length(color) == nvertices
            append!(colors(turtle), color)
        else
            error("Provided either a color or a vector of colors of length $(nvertices)")
        end
    end
    return nothing
end