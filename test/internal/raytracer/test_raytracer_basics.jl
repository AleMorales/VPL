using VPL
using DataFrames
using StaticArrays
import Random
using Test


let 
    
# Helper function
rel(x, y) = abs(x - y)/abs(x)

function create_tile(nmat)
    soil = Rectangle(O(), Y(1.0), X(1.0))
    triangles = [VPL.RT.Triangle(soil.vertices[face]...) for face in soil.faces]
    ids = nmat == 1 ? [1, 1] : [1,2]
    return triangles, ids
end

function create_material(mat_type, nw, nmat)
    # Choosse the type of material and 1 or 2 wavelengths
    if mat_type == :Lambertian
        material = nw == 1 ? [Lambertian(0.1, 0.1)] : [Lambertian((0.1, 0.3), (0.1, 0.3))]
    elseif mat_type == :Phong
        material = nw == 1 ? [Lambertian(0.1, 0.1)] : [Lambertian((0.1, 0.3), (0.1, 0.3))]
    elseif mat_type == :Sensor
        material = nw == 1 ? [Sensor(1)] : [Sensor(2)]
    elseif mat_type == :Black
        material = nw == 1 ? [Black(1)] : [Black(2)]
    end
    # If we are using two materials create a second copy
    output = nmat == 1 ? material : [material[1], deepcopy(material[1])]
    return output
end

function create_source(source_type, nw, nsource, scene, nrays)
    # Power of the source
    if nw == 1
        power = SVector(1000.0/nrays)
    else
        power = SVector(1000.0/nrays, 500.0/nrays)
    end
    # Lambertian emmiter (for all sources except directional ones)
    lamb = LambertianSource(Y(), X(), .-Z())
    # Type of source
    if source_type == :Directional
        if nsource == 1
            source = [DirectionalSource(scene, 0.0, 0.0, power, nrays)]
        else
            source = [DirectionalSource(scene, θ, 0.0, power, div(nrays,2)) for θ in (0.0, π/4)]
        end
    elseif source_type == :Point
        if nsource == 1
            source = [Source(PointSource(Vec(0.5, 0.5, 1.0)), lamb, power, nrays)]
        else
            source = [Source(PointSource(Vec(d, d, 1.0)), lamb, power, div(nrays,2)) for d in (0.25, 0.75)]
        end
    elseif source_type == :Line
        LS1 = LineSource(Vec(0.0, 0.0, 1.0), Vec(1.0, 1.0, 0.0))
        LS2 = LineSource(Vec(0.0, 1.0, 1.0), Vec(1.0, -1.0, 0.0))
        if nsource == 1
            source = [Source(LS1, lamb, power, nrays)]
        else
            source = [Source((LS1, LS2)[i], lamb, power, div(nrays,2)) for i in 1:2]
        end
    elseif source_type == :Area
        if nsource == 1
            A1 = AreaSource(Rectangle(Z(), Y(1.0), X(1.0)))
            source = [Source(A1, lamb, power, nrays)]
        else
            A2 = [AreaSource(Rectangle(Z(), Y(1.0), X(0.5))), AreaSource(Rectangle(Z() .+ X(0.5), Y(1.0), X(0.5)))]
            source = [Source((A2)[i], lamb, power, div(nrays,2)) for i in 1:2]
        end
    end
end

function create_settings(MT; kwargs...)
    if MT
        RTSettings(parallel = true; kwargs...)
    else
        RTSettings(parallel = false; kwargs...)
    end
end


# Function to arrange a RayTracer object, run it and extract the information
function test_ray_tracer(;mat_type = :Lambertian, nw = 1, nmat = 1, source_type = :Directional, 
                          nsource = 1, MT = false, nrays = 100_000, maxiter = 3, pkill = 0.5,
                          nx = 0, ny = 0, dx = 1.0, dy = 1.0, acceleration = BVH)
    # Simple mesh representing a soil tile
    triangles, ids = create_tile(nmat)
    # Create the material
    materials = create_material(mat_type, nw, nmat)
    scene = RTScene(triangles, ids, materials)
    # Create the source
    source = create_source(source_type, nw, nsource, scene, nrays)
    # Create the settings
    settings = create_settings(MT; maxiter = maxiter, pkill = pkill, nx = nx, ny = ny, dx = dx, dy = dy)
    # Build the ray tracer object
    rtobj = RayTracer(scene, source; settings = settings, acceleration = acceleration)
    # Run the ray tracer and return the power stored in the material(s)
    ntraces = trace!(rtobj)
    return rtobj, [mat.power for mat in materials], ntraces
end

###############################################################################################################
############################################# Sensor - Ray caster #############################################
###############################################################################################################

sim_sensor_RC = DataFrame(
                 nsources = repeat(1:2, inner = 2^5),
                 nmats    = repeat(1:2, outer = 2, inner = 2^4),
                 nws      = repeat(1:2, outer = 2^2, inner = 2^3),
                 mts      = repeat([false, true], outer = 2^3, inner = 2^2),
                 stypes   = repeat([:Directional, :Point, :Line, :Area], outer = 2^4));


function test_sim_sensor_RC(r)
    test_ray_tracer(mat_type = :Sensor, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 1, pkill = 1.0, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RC = [test_sim_sensor_RC(sim_sensor_RC[i,:])[2:3] for i in 1:nrow(sim_sensor_RC)];
sim_sensor_RC[:,:power] = getindex.(sims_RC, 1);
sim_sensor_RC[:,:ntraces] = getindex.(sims_RC, 2);

# Analysis using single material and wavelength
sims_1 = filter(r ->  r.nmats == 1 && r.nws == 1, sim_sensor_RC);
sims_1.power1 = [p[1][1] for p in sims_1[:,:power]];

# Check basics: correct number of ray traces and energy budget in the scene
@test all(sim_sensor_RC.ntraces .== 100_000);
@test all(sims_1.power1 .< 1000);

# Check that multithreading gives similar results to single thread
@test all(rel.([p[1][1] for p in filter(r ->  !r.mts, sims_1).power], 
         [p[1][1] for p in filter(r ->  r.mts, sims_1).power]) .< 0.012);

# Check that line and area produce the same result when using one or two sources
f(ns) = r ->  r.nsources == ns && r.stypes in (:Line, :Area)
@test all(rel.([p[1][1] for p in filter(f(1), sims_1).power],
         [p[1][1] for p in filter(f(2), sims_1).power]) .< 0.009)

# Check that directional and point light result in lower power when using 2 sources
f(ns) = r ->  r.nsources == ns && r.stypes in (:Directional, :Point)
@test all([p[1][1] for p in filter(f(1), sims_1).power] .>
         [p[1][1] for p in filter(f(2), sims_1).power]);

# Analysis using single material and two wavelength
sims_2 = filter(r ->  r.nmats == 1 && r.nws == 2, sim_sensor_RC);
sims_2.power1 = [p[1][1] for p in sims_2[:,:power]];
sims_2.power2 = [p[1][2] for p in sims_2[:,:power]];

# Check that the second wavelength has half of the power as expected from source
@test all(sims_2.power1./sims_2.power2 .== 2);

# Check that the first wavelength has the same power as in sim_1
@test all(sims_1.power1 .== sims_2.power1);

# Analysis using two materials and single wavelength
sims_3 = filter(r ->  r.nmats == 2 && r.nws == 1, sim_sensor_RC);
sims_3.power1 = [p[1][1] for p in sims_3[:,:power]];
sims_3.power2 = [p[2][1] for p in sims_3[:,:power]];

# Both materials should get the same power due to symmetry
#maximum(rel.(sims_3.power1, sims_3.power2))
@test all(rel.(sims_3.power1, sims_3.power2) .< 0.025);

sensor_RC_power = vcat(vcat(sim_sensor_RC.power...)...);

###############################################################################################################
############################################## Sensor - Ray trace #############################################
###############################################################################################################

sim_sensor_RT = deepcopy(sim_sensor_RC);

function test_sim_sensor_RT(r)
    test_ray_tracer(mat_type = :Sensor, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 2, pkill = 0.5, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RT = [test_sim_sensor_RT(sim_sensor_RT[i,:])[2:3] for i in 1:nrow(sim_sensor_RT)];
sim_sensor_RT[:,:power] = getindex.(sims_RT, 1);
sim_sensor_RT[:,:ntraces] = getindex.(sims_RT, 2);

# Check that secondary rays were traced once (but not all as the light sources missed some)
@test all(sim_sensor_RT.ntraces .> 100_000 .&& sim_sensor_RT.ntraces .< 200_000);

# Check that the power stored in the material is still the same as in the ray caster
sensor_RT_power = vcat(vcat(sim_sensor_RT.power...)...);
#maximum(rel.(RCpower , RTpower));
all(rel.(sensor_RC_power , sensor_RT_power) .< 0.023);


###############################################################################################################
########################################### Black tile - Ray caster ###########################################
###############################################################################################################

sim_black_RC = deepcopy(sim_sensor_RC);

function test_sim_black_RC(r)
    test_ray_tracer(mat_type = :Black, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 1, pkill = 1.0, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RC = [test_sim_black_RC(sim_black_RC[i,:])[2:3] for i in 1:nrow(sim_black_RC)];
sim_black_RC[:,:power] = getindex.(sims_RC, 1);
sim_black_RC[:,:ntraces] = getindex.(sims_RC, 2);

sensor_RC_power = vcat(vcat(sim_sensor_RC.power...)...);
black_RC_power = vcat(vcat(sim_black_RC.power...)...);
@test all(rel.(sensor_RC_power, black_RC_power) .< 0.023);
@test all(sim_black_RC.ntraces .== 100_000);


###############################################################################################################
########################################### Black tile - Ray tracer ###########################################
###############################################################################################################

sim_black_RT = deepcopy(sim_sensor_RT);

function test_sim_black_RT(r)
    test_ray_tracer(mat_type = :Black, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 2, pkill = 0.5, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RT = [test_sim_black_RT(sim_black_RT[i,:])[2:3] for i in 1:nrow(sim_black_RT)];
sim_black_RT[:,:power] = getindex.(sims_RT, 1);
sim_black_RT[:,:ntraces] = getindex.(sims_RT, 2);

black_RC_power = vcat(vcat(sim_black_RC.power...)...);
black_RT_power = vcat(vcat(sim_black_RT.power...)...);
sensor_RT_power = vcat(vcat(sim_sensor_RT.power...)...);
#maximum(rel.(black_RC_power, black_RT_power));
@test all(black_RC_power .== black_RT_power);
@test all(sensor_RT_power .== black_RT_power);
@test all(sim_black_RT.ntraces .== 100_000);



###############################################################################################################
######################################## Lambertian tile - Ray caster #########################################
###############################################################################################################

sim_lamb_RC = deepcopy(sim_sensor_RC);

function test_sim_lamb_RC(r)
    test_ray_tracer(mat_type = :Lambertian, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 1, pkill = 1.0, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RC = [test_sim_lamb_RC(sim_lamb_RC[i,:])[2:3] for i in 1:nrow(sim_lamb_RC)];
sim_lamb_RC[:,:power] = getindex.(sims_RC, 1);
sim_lamb_RC[:,:ntraces] = getindex.(sims_RC, 2);

# Basic tests
@test all(sim_lamb_RC.ntraces .== 100_000);
lamb_RC_power = vcat(vcat(sim_lamb_RC.power...)...);
@test all(lamb_RC_power .< 1000);

# Basic tests for power interception
@test all(lamb_RC_power .< 1000);
@test all(lamb_RC_power .> 0);

# Check that multithreading gives similar results to single thread
sims_ST = filter(r ->  !r.mts, sim_lamb_RC);
sims_MT = filter(r ->  r.mts, sim_lamb_RC);
sims_ST_power = vcat(vcat(sims_ST.power...)...);
sims_MT_power = vcat(vcat(sims_MT.power...)...);
@test all(rel.(sims_ST_power, sims_MT_power) .< 0.025);


###############################################################################################################
######################################## Lambertian tile - Ray tracer #########################################
###############################################################################################################

sim_lamb_RT = deepcopy(sim_sensor_RT);

function test_sim_lamb_RT(r)
    test_ray_tracer(mat_type = :Lambertian, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 2, pkill = 0.5, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RT = [test_sim_lamb_RT(sim_lamb_RT[i,:])[2:3] for i in 1:nrow(sim_lamb_RT)];
sim_lamb_RT[:,:power] = getindex.(sims_RT, 1);
sim_lamb_RT[:,:ntraces] = getindex.(sims_RT, 2);

# Basic tests
@test all(sim_lamb_RT.ntraces .> 100_000 .&& sim_lamb_RT.ntraces .< 200_000);
lamb_RT_power = vcat(vcat(sim_lamb_RT.power...)...);
@test all(rel.(lamb_RT_power, lamb_RC_power) .< 0.026);

# Check that multithreading gives similar results to single thread
sims_ST = filter(r ->  !r.mts, sim_lamb_RT);
sims_MT = filter(r ->  r.mts, sim_lamb_RT);
sims_ST_power = vcat(vcat(sims_ST.power...)...);
sims_MT_power = vcat(vcat(sims_MT.power...)...);
@test all(rel.(sims_ST_power, sims_MT_power) .< 0.025);


###############################################################################################################
######################################## Phong tile - Ray caster #########################################
###############################################################################################################

sim_phong_RC = deepcopy(sim_sensor_RC);

function test_sim_phong_RC(r)
    test_ray_tracer(mat_type = :Phong, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 1, pkill = 1.0, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RC = [test_sim_phong_RC(sim_phong_RC[i,:])[2:3] for i in 1:nrow(sim_phong_RC)];
sim_phong_RC[:,:power] = getindex.(sims_RC, 1);
sim_phong_RC[:,:ntraces] = getindex.(sims_RC, 2);

# Basic tests
@test all(sim_phong_RC.ntraces .== sim_lamb_RC.ntraces);
phong_RC_power = vcat(vcat(sim_phong_RC.power...)...);
@test all(phong_RC_power .== lamb_RC_power);



###############################################################################################################
######################################## Phong tile - Ray tracer #########################################
###############################################################################################################


sim_phong_RT = deepcopy(sim_sensor_RT)

function test_sim_phong_RT(r)
    test_ray_tracer(mat_type = :Phong, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 2, pkill = 0.5, nx = 0, ny = 0, dx = 1.0, dy = 1.0)
end

sims_RT = [test_sim_phong_RT(sim_phong_RT[i,:])[2:3] for i in 1:nrow(sim_phong_RT)];
sim_phong_RT[:,:power] = getindex.(sims_RT, 1);
sim_phong_RT[:,:ntraces] = getindex.(sims_RT, 2);

# Basic tests
@test all(sim_phong_RT.ntraces .== sim_lamb_RT.ntraces)
phong_RT_power = vcat(vcat(sim_phong_RT.power...)...)
@test all(phong_RT_power .== lamb_RT_power)



###############################################################################################################
######################################### Sensor - Ray trace - cloner #########################################
###############################################################################################################

sim_sensor_RT = DataFrame(
                    nsources = repeat(1:2, inner = 3*2^5),
                    nmats    = repeat(1:2, outer = 2, inner = 3*2^4),
                    nws      = repeat(1:2, outer = 2^2, inner = 3*2^3),
                    mts      = repeat([false, true], outer = 2^3, inner = 3*2^2),
                    stypes   = repeat([:Directional, :Point, :Line, :Area], outer = 2^4, inner = 3),
                    nx       = repeat([0,1,2], outer = 2^6),
                    ny       = repeat([0,1,2], outer = 2^6)) |>
            x -> sort(x, [:nx]);


function test_sim_sensor_RT(r)
    test_ray_tracer(mat_type = :Sensor, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 2, pkill = 0.5, nx = r.nx, ny = r.ny, dx = 1.0, dy = 1.0)
end

# Note: Sometimes this gives a strange error that suggests a problem with node initialization
sims_RT = [test_sim_sensor_RT(sim_sensor_RT[i,:])[2:3] for i in 1:nrow(sim_sensor_RT)];
sim_sensor_RT[:,:power] = getindex.(sims_RT, 1);
sim_sensor_RT[:,:ntraces] = getindex.(sims_RT, 2);

# Check that secondary rays were traced once (but not all as the light sources missed some)
all(sim_sensor_RT.ntraces .> 100_000 .&& sim_sensor_RT.ntraces .< 200_000);

# Check that in all cases (with one exception) the power sensed increases with grid cloner
# The exception is a single, vertical light source which is fully covered with nx = ny = 1
power = vcat(vcat(sim_sensor_RT.power...)...);
@test all(power[145:288] .> power[1:144]);
@test 144 - sum(power[289:end] .> power[145:288]) == 144/8;


###############################################################################################################
################################## Sensor - Ray caster - Naive accceleration ##################################
###############################################################################################################

sim_sensor_RC_Naive = DataFrame(
                 nsources = repeat(1:2, inner = 2^5),
                 nmats    = repeat(1:2, outer = 2, inner = 2^4),
                 nws      = repeat(1:2, outer = 2^2, inner = 2^3),
                 mts      = repeat([false, true], outer = 2^3, inner = 2^2),
                 stypes   = repeat([:Directional, :Point, :Line, :Area], outer = 2^4));


function test_sim_sensor_RC_naive(r)
    test_ray_tracer(mat_type = :Sensor, source_type = r.stypes, nw = r.nws, 
                    nmat = r.nmats, MT = r.mts, nsource = r.nsources, nrays = 100_000,
                    maxiter = 1, pkill = 1.0, nx = 0, ny = 0, dx = 1.0, dy = 1.0, acceleration = Naive)
end

sims_RC = [test_sim_sensor_RC_naive(sim_sensor_RC_Naive[i,:])[2:3] for i in 1:nrow(sim_sensor_RC_Naive)];
sim_sensor_RC_Naive[:,:power] = getindex.(sims_RC, 1);
sim_sensor_RC_Naive[:,:ntraces] = getindex.(sims_RC, 2);

sensor_RC_power = vcat(vcat(sim_sensor_RC.power...)...);
sensor_RC_power_naive = vcat(vcat(sim_sensor_RC_Naive.power...)...);

@test all(sensor_RC_power .== sensor_RC_power_naive)

end