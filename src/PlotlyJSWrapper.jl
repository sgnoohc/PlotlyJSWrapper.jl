module PlotlyJSWrapper

using PlotlyJS
using FHist
using StatsBase

export plot_stack

include("plot_stack.jl")
include("options.jl")
include("utils.jl")
include("colors.jl")

end
