module PlotlyJSWrapper

using PlotlyJS
using FHist

export plot_stack

include("plot_stack.jl")
include("options.jl")
include("utils.jl")

end
