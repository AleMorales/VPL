using Documenter, VPL, DocumenterMarkdown

makedocs(;
    modules=[VPL],
    format=Markdown(),#Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
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
