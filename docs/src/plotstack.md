# Plotting HEP style Data / MC Stack Plot

## Function Call and Arguments

Once `FHist` based `Hist1D` objects have been created, one can use `PlotlyJSWrapper` to plot the standard data / MC comparison plots in the following way

```julia
using PlotlyJSWrapper
using FHist

# Creating example histograms
h1 = Hist1D(randn(3000),-5:0.5:5)
h2 = Hist1D(randn(1000).+1,-5:0.5:5)
h3 = Hist1D((randn(1000).+2)./2,-5:0.5:5)
h4 = Hist1D((randn(2000).-2).*2,-5:0.5:5)
h5 = Hist1D(randn(2000).*5,-5:0.5:5)
h6 = Hist1D(randn(2000).-0.5,-5:0.5:5)
data = Hist1D(randn(9000),-5:0.5:5)
signal = Hist1D((randn(1000).+10)./3,-5:0.5:5)

# Plotting
plot_stack(

  # Hists are FHist's Hist1D

  # Background histograms
  backgrounds=[h1, h2, h3,
               h4, h5, h6],

  # Data histograms
  data=[data],

  # Signal histograms
  signals=[signal, signal2,
           signal3, signal4],

  # Options
  xaxistitle = "Δϕ<sub>jj</sub> [GeV]",
  outputname = "plot.pdf",
  backgroundlabels =
        ["tt̄",
         "Higgs",
         "Drell-Yan",
         "tt̄Z",
         "ZZ",
         "VBS WW"],
  signallabels =
        ["VVV",
         "VVH",
         "VHH",
         "HHH"],
  # Some extra features
  stacksignals = true,
  hideratio = false,
  showsignalsinratio = true,

)
```     

All histogram category of `backgrounds`, `data`, and `signals` arguments are array of `Hist1D` of `FHist`.
The `data` also expects a list.
If more than one `Hist1D` is provided for `data` the ratio panel will contain more than one set of points.
The first element of the array will be considered the primary.

## Options

The extra arguments are all part of `options`.
The options can be also be passed as a `Dict{Symbol, Any}` type of object.
Any defined symbol options can be recognized both as a keyword argument or as a symbol in a dictionary.
i.e. The following two examples function identically.

```julia
plot_stack(
  backgrounds=[h1, h2, h3, h4, h5, h6],
  data=[data],
  signals=[signal, signal2, signal3, signal4],

  # Options
  xaxistitle = "Δϕ<sub>jj</sub> [GeV]",
  outputname = "plot.pdf",
  backgroundlabels = ["tt̄", "Higgs", "Drell-Yan", "tt̄Z", "ZZ", "VBS WW"],
  signallabels = ["VVV", "VVH", "VHH", "HHH"],
  stacksignals = true,
  hideratio = false,
  showsignalsinratio = true,

)
```

```julia
plot_stack(
  backgrounds=[h1, h2, h3, h4, h5, h6],
  data=[data],
  signals=[signal, signal2, signal3, signal4],

  # Options
  options = Dict(
  :xaxistitle => "Δϕ<sub>jj</sub> [GeV]",
  :outputname => "plot.pdf",
  :backgroundlabels => ["tt̄", "Higgs", "Drell-Yan", "tt̄Z", "ZZ", "VBS WW"],
  :signallabels => ["VVV", "VVH", "VHH", "HHH"],
  :stacksignals => true,
  :hideratio => false,
  :showsignalsinratio => true,
  )

)
```

To pass a user specificied options, follow either of the syntax of the examples given above.
When not specificed whatever is defined in the the default options will be used.
The full list of available and default options can be found [`PlotlyJSWrapper.default_options`](@ref).
