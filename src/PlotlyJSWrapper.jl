module PlotlyJSWrapper

using PlotlyJS

export hist1d

function hist1d(x, bins)
    bins = StepRangeLen(bins)
    lowedge = bins.ref.hi
    step = bins.step.hi
    highedge = lowedge + step * (bins.len-1)
    histogram(x=x,
              opacity=0.75,
              xbins=attr(start=lowedge, size=step),
              xbins_end=highedge
             )
end

end # module
