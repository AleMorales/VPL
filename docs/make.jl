using Documenter, VPL

makedocs(;
    modules=[VPL],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
        "Introduction" => "index.md",
        "User Manual" => ["manual/VPL.md"],
        "Tutorials" => ["Introduction" => ["tutorials/introduction/01_algae.md"]#,
                        #"Advanced"     => "tutorials/advanced/relational_queries.md"],
                    ],
        "API" => ["Core" => "api/Core.md"],
        "Technical Notes" => []
    ],
    repo="https://github.com/AleMorales/VPL.jl/blob/{commit}{path}#L{line}",
    sitename="VPL.jl",
    authors="Alejandro Morales, Wageningen University and Research",
    assets=String[],
)

deploydocs(;
    repo="github.com/AleMorales/VPL.jl",
)
