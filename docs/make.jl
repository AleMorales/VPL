using Documenter, VPL

makedocs(;
    modules=[VPL],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
        "Introduction" => "index.md",
        "User Manual" => ["manual/VPL.md"],
        "Tutorials" => ["tutorials/algae.md",
                        #"tutorials/cellular_growth.md", # in development (see dev)
                        "tutorials/relational_queries.md"
                        "tutorials/snowflakes.md"
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
