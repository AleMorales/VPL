### This file contains public API ###
# BVH
# SAH
# AvgSplit


###############################################################################
############################## Boxed triangles ################################
###############################################################################

# Structure that includes all triangles of a scene, each of them wrapped by an
# AABB and including the center of each AABB
struct BoxedTriangles{FT}
    boxes::Vector{AABB{FT}}
    centers::NTuple{3, Vector{FT}}
    tris::Vector{Triangle{FT}}
    ids::Vector{Int}
end

# Constructor from vector of triangles
function BoxedTriangles(tris::Vector{<:Triangle}, ids::Vector{Int})
    BoxedTriangles(wrap(tris)..., tris, ids)
end

# Constructor from RTScene
function BoxedTriangles(scene::RTScene)
    BoxedTriangles(scene.triangles, scene.ids)
end

# Compute the AABBs and the center for each triangle
function wrap(tris::Vector{Triangle{FT}}) where FT
    #@inbounds begin
    begin
        nt = length(tris)
        boxes = AABB.(tris)
        cx = zeros(FT, nt)
        cy = similar(cx)
        cz = similar(cx)
        for i = 1:nt
            cx[i], cy[i], cz[i] = center(boxes[i])
        end
        return boxes, (cx, cy, cz)
    end
end

###############################################################################
######################### Bounded Volume Hierarchy ############################
###############################################################################

# The tree is stored in a dense array with implicit indexing (i.e., assumes dense tree)
# Using 0-indexing, the first child of an inner node with order i in a tree of
# arity n is given by i*n + 1 (we assume binary tree so n = 2). Since the firt node
# is the global box (which we do not store), index 1 and 2 correspond to the children


# Each node in the acceleration structure (an AABB, flag on whether it is a leaf or not and index for
# the triangle packet)
struct AccNode{FT}
    box::AABB{FT}
    leaf::Bool
    tris::Int
end

"""
    BVH

Construct a Bounding Volume Hierarchy around the triangular meshes to 
accelerate the ray tracer. This should be assigned to the argument `acceleration`
in the `RayTracer` function, in combination with a corresponding `rule`.
"""
struct BVH{FT} <: Acceleration{FT}
    gbox::AABB{FT}
    nodes::GVector{AccNode{FT}}
    tris::Vector{Vector{Triangle{FT}}}
    ids::Vector{Vector{Int}}
end

# Create a bounding volume hierarchy given the triangles in a scene and a rule
function BVH(tris::Vector{Triangle{FT}}, ids::Vector{Int}, rule) where {FT}
    # Fit a tight AABB around each triangle and calculate their centers
    scene = BoxedTriangles(tris, ids)
    # Calculate global AABB as union of all the AABBs in the list
    gbox = AABB(scene.boxes)
    # Indices of triangles to be assigned
    indices = collect(1:length(tris))
    # Create empty BVH structure
    bvh = BVH(gbox, GVector(AccNode{FT}[]), Vector{Triangle{FT}}[], Vector{Int}[])
    # Call the recusive function to add (packets of) nodes and triangles
    addNode!(bvh, scene, gbox, 0, indices, 1, rule)
    return bvh
end

# Recursive function that splits a gbox into N nodes, distributes triangles
# and adds nodes to the list of nodes and triangles
function addNode!(bvh::BVH, scene::BoxedTriangles, parentbox, parentid, indices, level, rule)
    # Distribute triangles among N children and determine whether children are leaves
    children, newindices, childrenboxes, leaves = splitnode(bvh, parentbox, indices, scene, level, rule)
    # If we decide to split the node
    if children
        # Ids of the children in the flattened version of the tree. 
        # First child of a node with order i is given by 2i + 1
        nodesid = Tuple(2*parentid + i for i = 1:2)
        # Add children to nodes
        pushnodes!(bvh, scene, nodesid, childrenboxes, leaves, newindices)
        # Recursion trigerred for children that are inner nodes (depth-first construction)
        c = 0
        for id in nodesid
            c += 1
            node = bvh.nodes[id]
            if !node.leaf
                addNode!(bvh, scene, node.box, id, newindices[c], level + 1, rule)
            end
        end
    else
        parentid == 0 && (parentid = 1) # Special case we should not actually split the global box
        push!(bvh.tris, scene.tris[indices])
        push!(bvh.ids, scene.ids[indices])
        tid = length(bvh.tris)
        bvh.nodes[parentid] = AccNode(parentbox, true, tid)
    end
    return nothing
end


###############################################################################
############################## Node splitting #################################
###############################################################################

# Split the box along an axis using surface area heuristics
# Return vector with indices in each children and whether they are leaves or not
# and the bounding boxes.
function splitnode(bvh::BVH{FT}, box, indices, scene, level, rule) where {FT}
    # Calculate split position according to rule
    axis, childrenboxes, newindices = split(bvh, box, indices, scene, rule)
    # Special case when the node should not be split according to rule
    axis == 0 && (return false, newindices, childrenboxes, (false, false))
    # If a split should be made, check whether the children should be leaves 
    # or not based on maximum tree size
    if level + 1 >= rule.maxL
        leaves = (true, true)
    else
        leaves = Tuple(length(newindices[i]) <= rule.minN ? true : false for i = 1:2)
    end
    return true, newindices, childrenboxes, leaves
end


# Distribute triangles into the children depending on the position of AABB centers 
# relative to the split plane
function distribute(axis, split, indices, scene)
    #@inbounds begin
    begin
        newindices = (Int[], Int[])
        for id in indices
            if scene.centers[axis][id] < split
                push!(newindices[1], id)
            else
                push!(newindices[2], id)
            end
        end
        return newindices
    end
end

###############################################################################
############################ Average Longest Axis #############################
###############################################################################

"""
    AvgSplit(minN, maxL)

Rule to be used in `RayTracer` when `acceleration = BVH`. It will divide each
node along the longest axis through the mean coordinate value. The rule is 
parameterized by the minimum number of triangles in a leaf node (`minN`) and the
maximum depth of the tree (`maxL`).
"""
struct AvgSplit 
    minN::Int # Minimum number of triangles in a leaf node
    maxL::Int # Maximum depth of the tree
end

# Split a node using a simple average rule
function split(bvh::BVH{FT}, box, indices, scene, rule::AvgSplit) where FT
    #@inbounds begin
    begin
        # Choose the axis that is longest
        axis = findmax(box.max .- box.min)[2]
        pos  = sum(scene.centers[axis][indices])/length(indices)
        # Distribute triangles between the two children
        newindices = distribute(axis, pos, indices, scene)
        # Sometimes all centers have the same axis coordinate so we cannot cut through there
        any(length.(newindices) .== 0) && (return Inf, (scene.boxes[1], scene.boxes[1]), newindices)
        # Compute the new boxes
        A = AABB(scene.boxes, newindices[1])
        B = AABB(scene.boxes, newindices[2])
        # Return axis that was split, the AABBs of the children nodes and the indices for the triangles
        # contained within the two children
        return axis, (A,B), newindices
    end
end

###############################################################################
########################## Surface Area Heuristics ############################
###############################################################################

# SAH rule that cuts nodes along quantiles
"""
    SAH{K}(minN, maxL)

Rule to be used in `RayTracer` when `acceleration = BVH`. It will divide each
node at the axis and location using the Surface Area Heuristics. To speed up the
construction, only `K` cuts will be tested per axis. These cuts will correspond
to the quantiles along each axis. The rule is parameterized by the minimum 
number of triangles in a leaf node (`minN`) and the maximum depth of the tree 
(`maxL`).
"""
struct SAH{K}
    minN::Int # Minimum number of triangles in a leaf node
    maxL::Int # Maximum depth of the tree
end

nsplits(::SAH{K}) where K = K

# Split a node using a SAH rule
function split(bvh::BVH{FT}, box, indices, scene, rule::SAH{K}) where {FT, K}
    #@inbounds begin
    begin
        # Compute baseline for partial SAH cost
        best_cost = area(box)*length(indices)
        best_axis = 0
        best_pos = zero(FT)
        best_childrenboxes = (box, box)
        # TODO: Can we avoid allocating newindices all the time (problem is that the length of vectors will vary)
        best_newindices = (Int[], Int[])
        # Presort centers along the three axes
        # TODO: Can pre-allocate the array holding sorted centers??
        scenters = Tuple(sort(scene.centers[i][indices]) for i in 1:3)
        # Loop over all possible splits, compute SAH and update the best option so far if needed
        for i in 1:3K
            axis, pos = split_box(rule, scenters, i)
            costs = sah_cost(axis, pos, indices, scene)
            if costs[1] < best_cost
                best_cost   = costs[1]
                best_axis   = axis
                best_pos    = pos
                best_childrenboxes = (costs[2], costs[3])
                best_newindices = costs[4]
            end
        end
        return best_axis, best_childrenboxes, best_newindices
    end
end

# Calculat the ith split according to the rule (assume quantile cuts)
function split_box(rule::SAH{K}, scenters, i) where K
    axis = div(i - 1, K) + 1
    iax = i - (axis - 1)*K
    pos = quantile(scenters[axis], iax/(K + 1), sorted = true)
    return axis, pos
end

# Compute partial SAH cost and all other variables derived from a split
function sah_cost(axis, pos, indices, scene)
    #@inbounds begin
    begin
        # Distribute triangles between the two children
        newindices = distribute(axis, pos, indices, scene)
        # Sometimes all centers have the same axis coordinate so we cannot cut through there
        any(length.(newindices) .== 0) && (return Inf, scene.boxes[1], scene.boxes[1], newindices)
        # Compute the SA and SB
        A = AABB(scene.boxes, newindices[1])
        B = AABB(scene.boxes, newindices[2])
        # Partial SAH cost
        SA = area(A)
        NA = length(newindices[1])
        SB = area(B)
        NB = length(newindices[2])
        return SA*NA + SB*NB, A, B, newindices
    end
end


###############################################################################
############################# BVH construction ################################
###############################################################################

# Create acceleration nodes and push them onto the array representation of the tree
function pushnodes!(bvh::BVH, scene, nodesid,  childrenbox, leaves, newindices)
    #@inbounds 
    for i in 1:2
        if leaves[i]
            push!(bvh.tris, scene.tris[newindices[i]])
            push!(bvh.ids, scene.ids[newindices[i]])
            tid = length(bvh.tris)
            bvh.nodes[nodesid[i]] = AccNode(childrenbox[i], true, tid)
        else
            bvh.nodes[nodesid[i]] = AccNode(childrenbox[i], false, 0)
        end
    end
    return nothing
end



###############################################################################
############################### BVH traversal #################################
###############################################################################

# Return closest hit (if any)
function Base.intersect(ray::Ray{FT}, acc::BVH, nodestack, dstack, dmin) where FT
    #@inbounds begin
    begin
        # Initialize statistics of minimum
        frontmin = true
        tri_id = (-1, -1)
        # Check the first two boxes to start the process
        for i in 1:2
            hit, d = intersect(ray, acc.nodes[i], dmin)
            hit && push!(nodestack, i)
            hit && push!(dstack, d)
        end
        # TODO: Since we traverse depth-first, we should store distance to AABB intersection in a stack to avoid unnecessary work
        # Depth-first traversal using LIFO stack
        while(length(nodestack) > 0)
            nodecur = pop!(nodestack)
            node = acc.nodes[nodecur]
            dnode = pop!(dstack)
            # If the node is a leaf go through triangles and update closest hit
            if node.leaf && dnode < dmin + eps(FT)
                # Bug that needs to be fixed (is it a problem in the creation of the BVH or the tracing?)
                if node.tris > length(acc.tris)
                    @error "I reached a leaf node that points to non-existing triangles: $nodecur"
                    nodestack = Int[]
                    break
                end
                tris = acc.tris[node.tris]
                for i in eachindex(tris)
                    hit, d, front = intersect(ray, tris[i])
                    if hit && d <= dmin
                        dmin = d
                        frontmin = front
                        tri_id = (node.tris, i)
                    end
                end
            # If the node is inner, compute the index of the first child and update nodestack
            elseif !node.leaf
                childid = 2*nodecur + 1
                # Bug that needs to be fixed (is it a problem in the creation of the BVH or the tracing?)
                if childid > length(acc.nodes)
                    @error "I reached a node that should be a leaf as it points to non-existent children: $nodecur"
                    break
                end
                update!(nodestack, dstack, childid, ray, acc, dmin)
            end
        end
        # Create Intersection object as required by material object
        if tri_id[1] == -1
            return false, Intersection(FT), dmin
        else
            triangle = acc.tris[tri_id[1]][tri_id[2]]
            intersection = Intersection(ray.o .+ dmin.*ray.dir, # pint
                                        axes(triangle),           # axes
                                        frontmin,                 # front
                                        acc.ids[tri_id[1]][tri_id[2]])  # id of material
            return true, intersection, dmin
        end
    end

end


# Check intersection with two children and store them in the nodestack
function update!(nodestack, dstack, i, ray, acc::BVH, dmin)
    # Intersect the two nodes
    hit1, d1 = intersect(ray, acc.nodes[i], dmin)
    hit2, d2 = intersect(ray, acc.nodes[i+1], dmin)
    # If both nodes are hit, store them in the order of hit
    if hit1 && hit2
        first, second, d1, d2 = ifelse(d1 < d2, (i, i + 1, d1, d2), (i + 1, i, d2, d1))
        push!(nodestack, first)
        push!(nodestack, second)
        # TODO: Avoid redundant operation on d1 and d2 when sorting?
        push!(dstack, d1)
        push!(dstack, d2)
    # If only one (or none) of the nodes are hit
    else
        hit1 && push!(nodestack, i)
        hit2 && push!(nodestack, i + 1)
        hit1 && push!(dstack, d1)
        hit2 && push!(dstack, d2)
    end
    return nothing
end

# Intersect a node in the tree and compare against dmin
function Base.intersect(ray::Ray, node::AccNode, dmin)
    hit, tmin = intersect(ray, node.box)
    hit && tmin < dmin, tmin
end