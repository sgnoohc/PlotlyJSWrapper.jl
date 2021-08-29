## PlotlyJS Wrapper for HEP in Julia

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sgnoohc.github.io/PlotlyJSWrapper.jl/dev/)

The wrapper takes [FHist](https://github.com/Moelf/FHist.jl) histograms as inputs and uses [PlotlyJS](https://github.com/JuliaPlots/PlotlyJS.jl) as backend.
Below is an example *interactive* plot created by the wrapper.
Scroll, click, hover the mouse over the plots to interact.
Click the home button on the top right corner to reset the view.

```@raw html
<div style="text-align:left">
<iframe id="github-iframe" src="" width="520" height="620" frameBorder="0" style="position: absolute; height: 100%; "></iframe>
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
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
```

The above plot was created with this julia script [`example1.jl`](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples/example1/example1.jl).

Below is another example from this julia script [`example3.jl`](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples/example3/example3.jl).

```@raw html
<div style="text-align:left">
<iframe id="github-iframe3" src="" width="520" height="620" frameBorder="0" style="position: absolute; height: 100%; "></iframe>
<script>
    fetch('https://api.github.com/repos/sgnoohc/PlotlyJSWrapper.jl/contents/examples/example3/plot.html')
        .then(function(response) {
            return response.json();
        }).then(function(data) {
            var iframe = document.getElementById('github-iframe3');
            iframe.src = 'data:text/html;base64;charset=utf-8,' + encodeURIComponent(data['content']);
        });
</script>
</div>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
```

See [Plotting HEP style Data / MC Stack Plot](@ref) for more information.

## More Examples

Complete examples can be found in [```examples```](https://github.com/sgnoohc/PlotlyJSWrapper.jl/blob/main/examples)
