using VPL
using DataFrames
using StaticArrays
using Plots
import Random
using Test
using Statistics

# TODO: Random uniform canopy with different leaf angle distributions and angle of incidence

# Creating a canopy of randomly distributed rectangles
# 1. Generate random (x,y,z)
# 2. Generate random inclination and orientation angles (using distributions)
# 3. Create the affine transformation for each leaf and use it to construct them (no need for turtles)

# Create a random leaf
function leaf(x, y, z, inclination, orientation, size)
    r = VPL.Geom.rotatez(orientation) ∘ VPL.Geom.rotatey(inclination)
    t = VPL.Geom.translate(x, y, z)
    s = VPL.Geom.scale(size, size, size)
    transform = t ∘ r ∘ s
    Rectangle(transform)
end

# Create a horizontal sensor at a particular height
function sensor(height, size)
    r = VPL.Geom.rotatey(π/2)
    t = VPL.Geom.translate(0.0, 0.0, height)
    s = VPL.Geom.scale(size, size, size)
    transform = t ∘ r ∘ s
    Rectangle(transform)
end


function random_leaf(x, y, z;angle_distribution = horizontal, leaf_size = 0.1)|
    inclination = angle_distribution()
    orientation = 2π*rand()
    leaf(x, y, z, inclination, orientation, leaf_size)
end

horizontal() = π/2
vertical() = 0.0

# General settings
nleaves = 80_000
leaf_size = 0.05
canopy_size = 14.0
LAI = nleaves*leaf_size^2/canopy_size^2
height = 3.0
I0 = 1000.0
maxiter = 10
pkill   = 0.2
nx = 0
ny = 0
dx = canopy_size
dy = canopy_size
nsensors = 9



#let 
    # Random canopy with an LAI of 1 and horizontal leaf distribution

    # Create canopy
    x = [canopy_size*rand() for i in 1:nleaves];
    y = [canopy_size*rand() for i in 1:nleaves];
    z = [height*rand() for i in 1:nleaves];
    canopy = [random_leaf(x[i], y[i], z[i], leaf_size = leaf_size, angle_distribution = horizontal) for i in 1:nleaves];
    render(Mesh(canopy), :green);

    # Add horizontal sensors
    sensor_height = collect(0.0:height/(nsensors - 1):height)
    sensors = [sensor(height, canopy_size) for height in sensor_height];
    render(Mesh(sensors), :green);

    # Create the ray tracing scene
    materials_leaves = [Black() for i in 1:nleaves];
    mat_ids_leaves = [div(i,2) for i in 2:2nleaves + 1];
    materials_sensors = [Sensor() for i in 1:nsensors];
    mat_ids_sensors = [div(i,2) for i in 2:2nsensors + 1] .+ nleaves;
    scene = RTScene(Mesh(vcat(canopy, sensors)), vcat(mat_ids_leaves, mat_ids_sensors), 
                    vcat(materials_leaves, materials_sensors));

    # Run the raytracer
    nrays = 1_000_000
    circle_radius = canopy_size*sqrt(2)/2
    power = I0*π*circle_radius^2/nrays;
    source =  [DirectionalSource(scene, 0.0, 0.0, power, nrays)];
    settings = RTSettings(parallel = true, maxiter = maxiter, pkill = pkill, nx = nx, ny = ny, dx = dx, dy = dy);
    rtobj = RayTracer(scene, source; settings = settings, acceleration = BVH);
    ntraces = trace!(rtobj)

    # Retrieve absorbed irradiances by the sensors
    Iabs = [materials_sensors[i].power[1] for i in 1:nsensors]./canopy_size.^2
    cumLAI  = sensor_height./height.*LAI
    k = 1.0
    scatter(cumLAI, reverse(Iabs))
    scatter!(cumLAI, I0.*exp.(.-k.*cumLAI))

    # Retrieve absorbed irradiance
    Pabs = [materials[i].power[1] for i in 1:nleaves];
    Iabs = Pabs./leaf_size.^2;
    leaf_class = Int.(floor.(z.*80.0./3.0)) .+ 1;
    ΔLA = [leaf_size^2*sum(leaf_class .== i) for i in unique(leaf_class)];
    cumLAI = cumsum(reverse(ΔLA))./canopy_size.^2;
    nleaf_layer = ΔLA./(leaf_size.^2)
    mu_Iabs = [sum(Pabs[leaf_class .== i]) for i in unique(leaf_class)]./canopy_size^2;
    se_Iabs = [std(Iabs[leaf_class .== i])*ΔLA[i] for i in unique(leaf_class)]./canopy_size^2.0./nleaf_layer;
    se_Iabs./mu_Iabs

    # Incident PAR at the bottom of each layer
    Iinc = I0 .- cumsum(reverse(mu_Iabs))
    k = 1.0
    Iinc_theory = I0.*exp.(-k.*cumLAI)

    plot(cumLAI, log.(Iinc), label = "Ray tracer")
    plot!(cumLAI, log.(Iinc_theory), label = "Beer's law")
    # Random canopy with an LAI of 1 with a spherical distribution

    Iabs_theory = I0.*(exp.(-k.*vcat(0, cumLAI[1:end-1])) - exp.(-k.*cumLAI))
    plot(cumLAI, reverse(mu_Iabs))
    plot!(cumLAI, Iabs_theory)
    plot!(cumLAI, I0.*exp.(-k.*vcat(0, cumLAI[1:end-1])).*ΔLA./canopy_size.^2)

   
    # Create a scene with a series of parallel slabs
    nslabs = 15
    heights = collect(2/nslabs:2/nslabs:2)
    create_slab(h) = Rectangle(Vec(0.0, 0.0, h), Y(1.0), X(1.0));
    parallel_slabs = Mesh([create_slab(h) for h in heights]);
    tri_mat_ids    = [div(i,2) for i in 2:2*nslabs + 1];
    materials      = [Lambertian(0.1, 0.1) for i in 1:nslabs];
    scene          = RTScene(parallel_slabs, tri_mat_ids, materials);

    # Create the source
    nrays = 1_000_000;
    power = 2e3;
    source = [DirectionalSource(scene, 0.0, 0.0, power/1_000_000, nrays)];
    # Create the settings
    maxiter = 3;
    pkill = 0.2;
    nx = 5;
    ny = 5;
    dx = 1.0;
    dy = 1.0;
    settings = RTSettings(parallel = true, maxiter = maxiter, pkill = pkill, nx = nx, ny = ny, dx = dx, dy = dy);
    # Build the ray tracer object
    rtobj = RayTracer(scene, source, settings = settings, acceleration = Naive);
    # Run the ray tracer and return the power stored in the material(s)
    ntraces = trace!(rtobj);
    profiles = [materials[i].power[1] for i in 1:nslabs];
    scatter(heights, profiles)
    K = sqrt(1 - 0.2)
    plot!(reverse(heights), 2000.0.*exp.(-K.*heights))
#end
  

