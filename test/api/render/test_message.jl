using VPL
using Test

module sn
    using VPL
    struct E <: Node
        length::Float64
    end
end

let 
    import .sn

    L = 1.0
    axiom = sn.E(L) + VPL.RU(120.0) + sn.E(L) + VPL.RU(120.0) + sn.E(L)
    function Kochsnowflake(x)
        L = data(x).length
        sn.E(L/3) + RU(-60.0) + sn.E(L/3) + RU(120.0) + sn.E(L/3) + 
            RU(-60.0) + sn.E(L/3)
    end
    rule = Rule(sn.E, rhs = Kochsnowflake)
    Koch = Graph(axiom = axiom, rules = Tuple(rule))
    function VPL.feedgeom!(turtle::MTurtle, e::sn.E)
       if turtle.message == "Random cylinders" 
        HollowCylinder!(turtle, length = e.length, width = e.length/10, 
                        height = e.length/10, move = true)
       else
        HollowCube!(turtle, length = e.length, width = e.length/10, 
                    height = e.length/10, move = true)
       end
       return nothing
    end
    function VPL.feedcolor!(turtle::GLTurtle, e::sn.E)
        if turtle.message == "Random cylinders" 
            feedcolor!(turtle, RGB(rand(), rand(), rand()))
        else
            feedcolor!(turtle, RGB(1, 0, 0))
        end
       return nothing
    end

    # Switch to different rendering based on the message
    render(Koch, axes = false, message = "Random cylinders")
    render(Koch, axes = false, message = "Other")

end