module PlotlyJSWrapper

using PlotlyJS
using FHist
using StatsBase

export plot_stack, @bins_str

include("plot_stack.jl")
include("options.jl")
include("utils.jl")
include("colors.jl")

end
