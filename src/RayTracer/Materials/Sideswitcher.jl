
# TODO: Incorporate the side switcher into the ray tracer

# Flip axes using mirror image
function flip_side(intersection)
    if axes.front
        return intersection
    else
        new_axes = (e1 = .-axes.e1, e2 = .-axes.e2, n = .-axes.n)
        return (pint = intersection.pint, axes = new_axes, front = axes.front)
    end
end

###############################################################################
######################## A material for each side #############################
###############################################################################

struct TwoSides{F,B} <: SideSwitcher
    front::F
    back::B
end

function choose_side(s::TwoSides, intersection)
    intersection = flip_side(intersection)
    material = ifelse(intersection.front, s.front, s.back)
    return (material = material, intersection = intersection)
end

materials(s::TwoSides) = (s.front, s.back)

###############################################################################
###################### Same material for each side ############################
###############################################################################

struct OneSide{M} <: SideSwitcher
    material::M
end

function choose_side(s::OneSide, intersection)
    intersection = flip_side(intersection)
    return (material = s.material, intersection = intersection)
end

materials(s::OneSide) = s.material