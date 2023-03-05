using VPL
using Test

module sn
    using VPL
    struct E64 <: Node
        length::Float64
    end
    struct E32 <: Node
        length::Float32
    end
end

let 
    import .sn

    # Koch curve @ 64 bits
    L = 1.0
    axiom = sn.E64(L) + VPL.RU(120.0) + sn.E64(L) + VPL.RU(120.0) + sn.E64(L)
    function Kochsnowflake(x)
        L = data(x).length
        sn.E64(L/3) + RU(-60.0) + sn.E64(L/3) + RU(120.0) + sn.E64(L/3) + 
            RU(-60.0) + sn.E64(L/3)
    end
    rule = Rule(sn.E64, rhs = Kochsnowflake)
    Koch = Graph(axiom = axiom, rules = Tuple(rule))
    function VPL.feedgeom!(turtle::Turtle, e::sn.E64, vars)
       HollowCylinder!(turtle, length = e.length, width = e.length/10, 
                       height = e.length/10, move = true,
                       color = RGB(rand(), rand(), rand()))
       return nothing
    end
    render(Koch, axes = false)
    rewrite!(Koch)
    render(Koch, axes = false)

    # Koch curve @ 32 bits
    L = 1f0
    axiom = sn.E32(L) + VPL.RU(120f0) + sn.E32(L) + VPL.RU(120f0) + sn.E32(L)
    function Kochsnowflake32(x)
        L = data(x).length
        sn.E32(L/3) + RU(-60f0) + sn.E32(L/3) + RU(120f0) + sn.E32(L/3) + 
            RU(-60f0) + sn.E32(L/3)
    end
    rule = Rule(sn.E32, rhs = Kochsnowflake32)
    Koch = Graph(axiom = axiom, rules = Tuple(rule))
    function VPL.feedgeom!(turtle::Turtle, e::sn.E32, vars)
       HollowCylinder!(turtle, length = e.length, width = e.length/10, 
                       height = e.length/10, move = true,
                       color = RGB(rand(), rand(), rand()))
       return nothing
    end
    render(Koch, Float32, axes = false)
    rewrite!(Koch)
    render(Koch, Float32,axes = false)

end