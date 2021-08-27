using PlotlyJSWrapper
using FHist

# Creating examples
h1 = Hist1D(randn(1000),-5:0.5:5)
h2 = Hist1D(randn(1000).+1,-5:0.5:5)
h3 = Hist1D((randn(1000).+2)./2,-5:0.5:5)
data = Hist1D(randn(3000),-5:0.5:5)
signal = Hist1D((randn(1000).+10)./3,-5:0.5:5)

# Plotting
plot_stack(
           backgrounds=[h1, h2, h3],
           data=[data],
           signals=[signal],
           options=Dict{Symbol, Any}(
            :xaxistitle => "MyVar<sub>lead-lep</sub> [GeV]",
            :outputname => "plot.pdf",
           )
          )
