
# Convert to format used in GeometryBasics
function GLMesh(m::Mesh{VT}) where VT <: Vec{FT} where FT <: AbstractFloat
    verts = convert(Vector{GeometryBasics.Point{3, FT}}, m.vertices)
    facs = convert(Vector{GeometryBasics.TriangleFace{Int}}, m.faces)
    m = GeometryBasics.Mesh(verts, facs)
end

# Convert from format used in GeometryBasics
function Mesh(m::GeometryBasics.Mesh) 
   FT = eltype(m[1][1])
   verts = convert(Vector{SVector{3, FT}}, GeometryBasics.coordinates(m))
   faces = convert(Vector{SVector{3, Int}}, GeometryBasics.faces(m))
   norms = [@inbounds normal(verts[face]...) for face in faces]
   Mesh(verts, norms, faces)
end

# Load a mesh from a file and transform it
# Supports: STL_BINARY, PLY, OBJ, MSH
function loadmesh(filename, ::Type{FT} = Float64) where FT
    check_aply = findfirst(".aply",filename)
    if isnothing(check_aply)
        m = FileIO.load(filename, pointtype = GeometryBasics.Point{3, FT}, normaltype = GeometryBasics.Point{3, FT})
    else
        m = FileIO.load(filename, pointtype = GeometryBasics.Point{3, FT})
    end
    Mesh(m)
end

# Save a mesh to external format after transformation
# Supports: STL_BINARY, STL_ASCII, PLY_BINARY, PLY_ASCII, OBJ
# Note that the file format must be passed as a symbol not as a string!
function savemesh(m, fileformat, filename)
    FileIO.save(FileIO.File(FileIO.DataFormat{fileformat}, filename), GLMesh(m))
end