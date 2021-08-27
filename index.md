## PlotlyJSWrapper for making High Energy Physics analysis plots in Julia

The wrapper takes [FHist](https://github.com/Moelf/FHist.jl) histograms as inputs and uses Plotly as backend.

## The command

```julia
plot_stack(

           # Background histograms
           backgrounds=[h1, h2, h3, h4, h5, h6],
           
           # Data histograms (can be multiple and will show up as different color data and multiple ratios)
           data=[data],

           # Signal histograms (TODO Not yet implemented!)
           signals=[signal],

           # Option dictionary
           options=Dict{Symbol, Any}(
            :xaxistitle => "Δϕ<sub>jj</sub> [GeV]",
            :outputname => "plot.pdf",
            :backgroundlabels => ["tt̄", "Higgs", "Drell-Yan", "tt̄Z", "ZZ", "VBS WW"],
            :signallabels => ["VVH"],
           )
          )
```

## The options

Full list of options can be found in [```src/options.jl```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/src/options.jl)

## The examples

Complete examples can be found in [```examples```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples)

### The example1

[```example1.jl```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples/example1.jl) below will produce the following plot

<iframe src="_includes/plot.html" width="100%" height="500" style="border:1px solid black;">  </iframe>
