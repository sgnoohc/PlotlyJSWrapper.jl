module PlotlyJSWrapper

using PlotlyJS
using FHist

export hist1d

function create_fhist1d(x, e, bins)
    # Use FHist to create histogram based on provided data
    h = Hist1D(Float64; bins=bins)
    # Decide whether error term is provided or not and create the FHist object
    if isnothing(e)
        # Fill the FHist
        Threads.@threads for i in x
            push!(h, i)
        end
    else
        # If the content and error terms don't match in length throw an exception
        if length(x) != length(e)
            nx = length(x)
            ne = length(e)
            error("hist1d:: provided bin content and error content length do not match up! length(x) = $nx != length(e) = $ne")
        end
        # Fill the FHist
        Threads.@threads for i in 1:length(x)
            push!(h, x[i], e[i])
        end
    end
    return h
end

function hist1d(h::Hist1D) # FHist 1d

    be = binedges(h) # bin edges

    bc = bincounts(h)
    push!(bc, last(bc))

    bc_e = sqrt.(h.sumw2)
    push!(bc_e, last(bc_e))

    traces = GenericTrace{Dict{Symbol, Any}}[]

    s1 = scatter(y=bc,
                 x=be,
                 mode="lines",
                 line_shape="hv",
                 marker_size=0,
                 fillcolor="blue",
                 fill="tozeroy"
                )
    s2 = scatter(y=bc+bc_e,
                 x=be,
                 mode="lines",
                 marker_color="#444",
                 line_shape="hv",
                 line_width=0,
                 showlegend=false
                )
    s3 = scatter(y=bc-bc_e,
                 x=be,
                 mode="lines",
                 marker_color="#444",
                 fillcolor="rgba(68, 68, 68, 0.3)",
                 line_shape="hv",
                 fill="tonexty",
                 line_width=0,
                 showlegend=false
                )

    push!(traces, s1)
    push!(traces, s2)
    push!(traces, s3)
    return traces
end

hist1d(x, bins) = hist1d(x, nothing, bins)

end # module
