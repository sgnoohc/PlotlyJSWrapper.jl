using PlotlyJSWrapper
using FHist
using Random
Random.seed!(42)

# Creating example histograms
h1 = Hist1D(randn(3000),-5:0.5:5) * 0.1
h2 = Hist1D(randn(1000).+1,-5:0.5:5) * 0.1
h3 = Hist1D((randn(1000).+2)./2,-5:0.5:5) * 0.1
h4 = Hist1D((randn(2000).-2).*2,-5:0.5:5) * 0.1
h5 = Hist1D(randn(2000).*5,-5:0.5:5) * 0.1
h6 = Hist1D(randn(2000).-0.5,-5:0.5:5) * 0.1
data = Hist1D(randn(900),-5:0.5:5) + Hist1D(randn(200).-3.5,-5:0.5:5) + Hist1D(randn(45).+4,-5:0.5:5)
signal = Hist1D((randn(1000).+10)./3,-5:0.5:5) * 0.1
signal2 = Hist1D((randn(1000).+5)./2,-5:0.5:5) * 0.1
signal3 = Hist1D((randn(1000).-0)./3,-5:0.5:5) * 0.1
signal4 = Hist1D((randn(1000).-10.5)./3,-5:0.5:5) * 0.03

# Plotting
plot_stack(
           backgrounds=[h1, h2, h3, h4, h5, h6],
           data=[data],
           signals=[signal, signal2, signal3, signal4],
           xaxistitle = "Δϕ<sub>jj</sub> [GeV]",
           outputname = "plot.{pdf,png,html}", # Creates all three outputs
           backgroundlabels = ["tt̄", "Higgs", "Drell-Yan", "tt̄Z", "ZZ", "VBS WW"],
           signallabels = ["VVV", "VVH", "VHH", "HHH"],
           stacksignals = true,
           hideratio = false,
           showsignalsinratio = true,
           ratiorange = [0., 2.],
           poissonerror = true,
           poissonerrorfunc = x->[20, 20],
          );
