# Plotting HEP style Data / MC Stack Plot

## Basic

Once `FHist` based `Hist1D` objects have been created, one can use `PlotlyJSWrapper` to plot the standard data / MC comparison plots in the following way

```julia
plot_stack(

     # Histograms are FHist.jl's Hist1D type

     # Background histograms
     backgrounds=[h1, h2, h3, h4, h5, h6],
     
     # Data histograms
     data=[data], # can be more than one

     # Signal histograms
     # TODO: Not yet implemented!
     signals=[signal],

     # Option dictionary
     options=Dict{Symbol, Any}(
      :xaxistitle => "Δϕ<sub>jj</sub> [GeV]",
      :outputname => "plot.pdf",
      :backgroundlabels => ["tt̄",
                            "Higgs",
                            "Drell-Yan",
                            "tt̄Z",
                            "ZZ",
                            "VBS WW"],
      :signallabels => ["VVH"],
     )
)
```

All histogram category of `backgrounds`, `data`, and `signals` arguments are array of `Hist1D` of `FHist`.
The `data` also expects a list.
If more than one `Hist1D` is provided for `data` the ratio panel will contain more than one set of points.
The first element of the array will be considered the primary.

The `options` is a `Dict{Symbol, Any}' type of object.
To pass a user specificied options, follow the syntax of the example given above.

## Options

Full list of available options are documented here.

```@autodocs
Modules = [PlotlyJSWrapper]
Pages = ["options.jl"]
```

