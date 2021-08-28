using Documenter, PlotlyJSWrapper

makedocs(
         modules=[PlotlyJSWrapper],
         format = Documenter.HTML(
                                  prettyurls = get(ENV, "CI", nothing) == "true",
                                  # assets = ["assets/logo.ico"],
                                 ),
         pages=[
                "Introduction" => "index.md",
                "APIs" => "api.md",
               ],
         repo="https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/{commit}{path}#L{line}",
         sitename="PlotlyJSWrapper.jl",
         authors="Philip Chang",
         assets=String[],
        )

deploydocs(
          repo = "github.com/sgnoohc/PlotlyJSWrapper.jl.git",
          devbranch = "main",
          )
