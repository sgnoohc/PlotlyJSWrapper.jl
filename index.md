# Wrapper for making HEP analysis plots in Julia

The wrapper takes [FHist](https://github.com/Moelf/FHist.jl) histograms as inputs and uses Plotly as backend.

## Command

```julia
plot_stack(

           # Background histograms
           backgrounds=[h1, h2, h3, h4, h5, h6],
           
           # Data histograms (more than one then plot with different color and multiple ratios)
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

## Options

Full list of options can be found in [```src/options.jl```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/src/options.jl)

# Examples

Complete examples can be found in [```examples```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples)

[```example1.jl```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples/example1/example1.jl) below will produce the following plot

<div style="text-align:center;">
<!-- <iframe src="plot.html" width="520" height="620" frameBorder="0">
</iframe> -->
<iframe id="github-iframe" src="" width="520" height="620" frameBorder="0"></iframe>
<script>
    fetch('https://api.github.com/repos/sgnoohc/PlotlyJSWrapper.jl/contents/examples/example1/plot.html')
        .then(function(response) {
            return response.json();
        }).then(function(data) {
            var iframe = document.getElementById('github-iframe');
            iframe.src = 'data:text/html;base64,' + encodeURIComponent(data['content']);
        });
</script>
</div>
