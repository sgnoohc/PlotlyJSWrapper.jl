var documenterSearchIndex = {"docs":
[{"location":"api/#API-Documentation","page":"APIs","title":"API Documentation","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"Modules = [PlotlyJSWrapper]\nPages = [\"plot_stack.jl\", \"options.jl\"]","category":"page"},{"location":"api/#PlotlyJSWrapper.plot_stack-Tuple{}","page":"APIs","title":"PlotlyJSWrapper.plot_stack","text":"plot_stack(; backgrounds, signals=[], data=[], options...)\n\nCreate HEP-style stacked plot with Data/MC ratio in the bottom panel.  \n\nInput arguments, backgrounds, signals, and data, are Arrays of FHist.jl's Hist1D.  \n\nSee default_options for complete list of options.\n\nExample usage:\n\nplot_stack(\n           backgrounds=[h1, h2, h3, h4, h5, h6],\n           data=[data],\n           signals=[signal], # TODO Not supported yet\n           xaxistitle = \"Δϕ<sub>jj</sub> [GeV]\",\n           outputname = \"plot.pdf\",\n           backgroundlabels = [\"tt̄\", \"Higgs\", \"Drell-Yan\", \"tt̄Z\", \"ZZ\", \"VBS WW\"],\n           signallabels = [\"VVH\"],\n          )\n\n\n\n\n\n","category":"method"},{"location":"api/#PlotlyJSWrapper.default_options","page":"APIs","title":"PlotlyJSWrapper.default_options","text":"default_options = Dict{Symbol, Any}\n\nDefault options of all the togglable options are documented here.\n\nOutput file name\n\n:outputname => \"plot.pdf\", # TODO create output dir if not exist\n\nAxes and labeling\n\n:ratiotitle => \"Data/MC\"\n:xaxistitle => \"variable [unit]\"\n:yaxistitle => \"Events\"\n\nAxes scale and ranges\n\n:yrange => []\n:xrange => []\n:ratiorange => [0, 2]\n:yminclipnegative => true, # Clip minimum at 0\n:ymaxscale => 1.8 # Multiplicative factor to ymax points across all histograms\n\nLegend labels\n\n:backgroundlabels => []\n:signallabels => []\n:datalabels => [\"Data\"]\n\nHistogram colors\n\n:datacolors => [\"black\", \"red\", \"blue\", \"orange\", \"green\", \"purple\", \"gray\"]\n:backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, ... , (many more)]\n:signalcolors => repeat([8001, 8002, 8003, 8004],10)\n:stackedsignalopacity => 0.6 # Set the opacity of stacked signal fill\n\nColor indexs are defined in src/colors.jl.\n\nLHC Experiment related labels\n\n# Currently only \"CMS\" label implemented\n:addpreliminarylabel => true\n:lumivalue => 137\n:comenergy => 13\n\nExtra labels settings\n\n:totalsystlabel => [\"+1σ\", \"-1σ\"]\n\nExtra operations\n\n:dofit => false # Scales all background such that integral is same as `data[1]` histogram\n:stacksignals => false # Stacks signals on top of total background\n:showsignalsinratio => false # Show signals above unity line in ratio panel\n:hideratio => false # Hide the ratio panel below\n\n\n\n\n\n","category":"constant"},{"location":"plotstack/#Plotting-HEP-style-Data-/-MC-Stack-Plot","page":"Plotting HEP's Stacked Plot","title":"Plotting HEP style Data / MC Stack Plot","text":"","category":"section"},{"location":"plotstack/#Function-Call-and-Arguments","page":"Plotting HEP's Stacked Plot","title":"Function Call and Arguments","text":"","category":"section"},{"location":"plotstack/","page":"Plotting HEP's Stacked Plot","title":"Plotting HEP's Stacked Plot","text":"Once FHist based Hist1D objects have been created, one can use PlotlyJSWrapper to plot the standard data / MC comparison plots in the following way","category":"page"},{"location":"plotstack/","page":"Plotting HEP's Stacked Plot","title":"Plotting HEP's Stacked Plot","text":"plot_stack(\n\n     # Histograms are FHist.jl's Hist1D type\n\n     # Background histograms\n     backgrounds=[h1, h2, h3, h4, h5, h6],\n     \n     # Data histograms\n     data=[data], # can be more than one\n\n     # Signal histograms\n     # TODO: Not yet implemented!\n     signals=[signal],\n\n     # Option dictionary\n     options=Dict{Symbol, Any}(\n      :xaxistitle => \"Δϕ<sub>jj</sub> [GeV]\",\n      :outputname => \"plot.pdf\",\n      :backgroundlabels => [\"tt̄\",\n                            \"Higgs\",\n                            \"Drell-Yan\",\n                            \"tt̄Z\",\n                            \"ZZ\",\n                            \"VBS WW\"],\n      :signallabels => [\"VVH\"],\n     )\n)","category":"page"},{"location":"plotstack/","page":"Plotting HEP's Stacked Plot","title":"Plotting HEP's Stacked Plot","text":"All histogram category of backgrounds, data, and signals arguments are array of Hist1D of FHist. The data also expects a list. If more than one Hist1D is provided for data the ratio panel will contain more than one set of points. The first element of the array will be considered the primary.","category":"page"},{"location":"plotstack/#Options","page":"Plotting HEP's Stacked Plot","title":"Options","text":"","category":"section"},{"location":"plotstack/","page":"Plotting HEP's Stacked Plot","title":"Plotting HEP's Stacked Plot","text":"The options is a Dict{Symbol, Any} type of object. To pass a user specificied options, follow the syntax of the example given above. When not specificed whatever is defined in the the default options will be used. The full list of available and default options can be found PlotlyJSWrapper.default_options.","category":"page"},{"location":"#PlotlyJS-Wrapper-for-HEP-in-Julia","page":"Introduction","title":"PlotlyJS Wrapper for HEP in Julia","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"(Image: Dev)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"The wrapper takes FHist histograms as inputs and uses PlotlyJS as backend. Below is an example interactive plot created by the wrapper. Scroll, click, hover the mouse over the plots to interact. Click the home button on the top right corner to reset the view.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"<div style=\"text-align:left\">\n<iframe id=\"github-iframe\" src=\"\" width=\"520\" height=\"620\" frameBorder=\"0\" style=\"position: absolute; height: 100%; \"></iframe>\n<script>\n    fetch('https://api.github.com/repos/sgnoohc/PlotlyJSWrapper.jl/contents/examples/example1/plot.html')\n        .then(function(response) {\n            return response.json();\n        }).then(function(data) {\n            var iframe = document.getElementById('github-iframe');\n            iframe.src = 'data:text/html;base64;charset=utf-8,' + encodeURIComponent(data['content']);\n        });\n</script>\n</div>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>\n</br>","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"The above plot was created with this julia script example1.jl.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"See Plotting HEP style Data / MC Stack Plot for more information.","category":"page"},{"location":"#More-Examples","page":"Introduction","title":"More Examples","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Complete examples can be found in examples","category":"page"}]
}
