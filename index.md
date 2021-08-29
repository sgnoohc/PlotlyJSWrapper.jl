# PlotlyJS Wrapper for HEP in Julia

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sgnoohc.github.io/PlotlyJSWrapper.jl/dev/)

The wrapper takes [FHist](https://github.com/Moelf/FHist.jl) histograms as inputs and uses Plotly as backend.
Below is an example <i>interactive</i> plot created by the wrapper.

<div style="text-align:center;width:100%;height:372px;overflow:hidden">
<!-- <iframe src="plot.html" width="520" height="620" frameBorder="0">
</iframe> -->
<iframe id="github-iframe" src="" width="520" height="620" frameBorder="0" style="-webkit-transform:scale(0.6);-webkit-transform-origin: top center;"></iframe>
<script>
    fetch('https://api.github.com/repos/sgnoohc/PlotlyJSWrapper.jl/contents/examples/example1/plot.html')
        .then(function(response) {
            return response.json();
        }).then(function(data) {
            var iframe = document.getElementById('github-iframe');
            iframe.src = 'data:text/html;base64;charset=utf-8,' + encodeURIComponent(data['content']);
        });
</script>
</div>

Below is an example of how it might look

```julia
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

  # Option dictionary
  options=Dict(

   :xaxistitle =>
        "Δϕ<sub>jj</sub> [GeV]",

   :backgroundlabels =>
        ["tt̄",
         "Higgs",
         "Drell-Yan",
         "tt̄Z",
         "ZZ",
         "VBS WW"],

   :signallabels =>
        ["VVV",
         "VVH",
         "VHH",
         "HHH"],

   # Some extra features
   :stacksignals => true,
   :hideratio => false,
   :showsignalsinratio => true,

   # Path to save to
   :outputname => "plot.pdf",
  )
)
```

Full list of options can be found in [```src/options.jl```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/src/options.jl)

# More Examples

Complete examples can be found in [```examples```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples)
