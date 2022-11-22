### This file contains public API ###

#= 
Need to document:
    loadmesh
    savemesh
    
=#
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

"""
    loadmesh(filename)

Import a mesh from a file given by `filename`. Supported formats include stl,
ply, obj and msh. By default, this will generate a `Mesh` object that uses
double floating-point precision. However, a lower precision can be specified by
passing the relevant data type as in `loadmesh(filename, Float32)`.
"""
function loadmesh(filename, ::Type{FT} = Float64) where FT
    check_aply = findfirst(".aply",filename)
    if isnothing(check_aply)
        m = FileIO.load(filename, pointtype = GeometryBasics.Point{3, FT}, normaltype = GeometryBasics.Point{3, FT})
    else
        m = FileIO.load(filename, pointtype = GeometryBasics.Point{3, FT})
    end
    Mesh(m)
end

"""
    savemesh(mesh; fileformat = STL_BINARY, filename)

Save a mesh into an external file using a variety of formats.

## Arguments
- `mesh`: Object of type `Mesh`.  
- `fileformat`: Format to store the mesh. This is a keyword argument. 
- `filename`: Name of the file in which to store the mesh. 

## Details
The `fileformat` should take one of the following arguments: `STL_BINARY`,
`STL_ASCII`, `PLY_BINARY`, `PLY_ASCII` or `OBJ`. Note that these names should
not be quoted as strings.

## Return
This function does not return anything, it is executed for its side effect.
"""
function savemesh(mesh; fileformat = STL_BINARY, filename)
    FileIO.save(FileIO.File(FileIO.DataFormat{fileformat}, filename), GLMesh(mesh))
end