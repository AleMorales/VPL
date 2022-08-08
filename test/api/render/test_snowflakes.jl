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

    # Koch curve
    L = 1.0
    axiom = sn.E(L) + VPL.RU(120.0) + sn.E(L) + VPL.RU(120.0) + sn.E(L)
    function Kochsnowflake(x)
        L = data(x).length
        sn.E(L/3) + RU(-60.0) + sn.E(L/3) + RU(120.0) + sn.E(L/3) + RU(-60.0) + sn.E(L/3)
    end
    rule = Rule(sn.E, rhs = Kochsnowflake)
    Koch = Graph(axiom, rules = Tuple(rule))
    function VPL.feedgeom!(turtle::MTurtle, e::sn.E)
       HollowCylinder!(turtle, l = e.length, w = e.length/10, h = e.length/10, move = true)
       return nothing
    end
    function VPL.feedcolor!(turtle::GLTurtle, e::sn.E)
       feedcolor!(turtle, RGB(rand(), rand(), rand()))
       return nothing
    end
    render(Koch, axes = false)
    rewrite!(Koch)
    render(Koch, axes = false)
end