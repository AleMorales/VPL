

# Optionally add wireframe and/or arrows representing normal vectors (for debugging)
function scene_additions!(scene, m, normals, wireframe)
    @inbounds FT = eltype(m[1][1])
    if wireframe
        GLMakie.wireframe!(m, linewidth = FT(1.5))
    end
    if normals
        pos = calc_arrows(m)
        GLMakie.linesegments!(pos, color = :black, linewidth = FT(1.5))
    end
    return scene
end

# Auxilliary functions to create arrows to depict Normals
function calc_arrows(m)
    nt = length(GeometryBasics.faces(m))
    [calc_arrow(i, m) for i in 1:nt]
end
  
@inbounds function calc_arrow(i, m)
    face   = GeometryBasics.faces(m)[i]
    v1, v2, v3  = GeometryBasics.coordinates(m)[face]
    center = (v1 .+ v2 .+ v3)./3
    norm   = normal(v1, v2, v3)
    center => center .+ norm./2
end

function normal(v1, v2, v3)
    e1 = v2 .- v1
    e2 = v3 .- v1
    normalize(e2 × e1)
end