"""
    plot_stack(; backgrounds, signals=[], data=[], options...)

Create HEP-style stacked plot with Data/MC ratio in the bottom panel.  

Input arguments, `backgrounds`, `signals`, and `data`, are Arrays of [`FHist.jl`](https://github.com/Moelf/FHist.jl)'s Hist1D.  

See [`default_options`](@ref) for complete list of options.

Example usage:

```julia
plot_stack(
           backgrounds=[h1, h2, h3, h4, h5, h6],
           data=[data],
           signals=[signal], # TODO Not supported yet
           xaxistitle = "Δϕ<sub>jj</sub> [GeV]",
           outputname = "plot.pdf",
           backgroundlabels = ["tt̄", "Higgs", "Drell-Yan", "tt̄Z", "ZZ", "VBS WW"],
           signallabels = ["VVH"],
          )
```

"""
function plot_stack(; backgrounds, signals=Hist1D[], data=Hist1D[], options...)

    #__________________________________________________________________________________
    #
    #
    # Preparing user options
    #
    #
    # Take the default options and merge it with given options
    useroptions = merge(default_options, options)

    # if no data and not special ratio panel style provided set it hideratio = true
    if !isdrawratio(backgrounds, signals, data, useroptions)
        useroptions[:hideratio] = true
    end

    # Check for conflicting options
    check_conflicting_options(useroptions)

    #__________________________________________________________________________________
    #
    #
    # Copying histograms
    #
    #
    # NOTE: data is an array. the first element is the main data

    # Copy in order not to mess up the original histograms
    bkgs = deepcopy(backgrounds)
    sigs = deepcopy(signals)
    data_ = deepcopy(data)

    #__________________________________________________________________________________
    #
    #
    # Processing FHist's
    #
    #
    useroptions[:dofit] && fit_bkg_to_data!(bkgs, data_)

    # Total background histogram
    total = sum(bkgs)

    #__________________________________________________________________________________
    #
    #
    # Traces
    #
    #
    # Grand list to hold all the traces to plot
    traces = GenericTrace{Dict{Symbol, Any}}[]

    # Add the dummy axes traces
    if !useroptions[:hideratio]
        add_ratio_axes_traces!(traces, options=useroptions)
    end
    add_main_axes_traces!(traces, options=useroptions)

    # Add the content traces
    if !useroptions[:hideratio]
        # Show S / B per bin
        if useroptions[:showfomperbin]
            add_fom_traces!(traces, signals, total, data_, options=useroptions, perbin=true)
        elseif useroptions[:showfomfromleft]
            add_fom_traces!(traces, signals, total, data_, options=useroptions, perbin=false, fromleft=true)
        elseif useroptions[:showfomfromright]
            add_fom_traces!(traces, signals, total, data_, options=useroptions, perbin=false, fromleft=false)
        else
            if useroptions[:showsignalsinratio]
                add_ratio_signal_traces!(traces, signals, total, options=useroptions)
            end
            add_ratio_totalerror_traces!(traces, total, options=useroptions)
            add_ratio_traces!(traces, data_, total, options=useroptions)
        end
    end
    add_background_traces!(traces, bkgs, options=useroptions)
    if useroptions[:showtotal]
        add_total_traces!(traces, total, options=useroptions)
    end
    add_signal_traces!(traces, signals, options=useroptions, total=total)
    add_data_traces!(traces, data_, options=useroptions)

    #__________________________________________________________________________________
    #
    #
    # Computing `Layout()` related variables
    #
    #
    # Compute the ymax and ymin
    yrange = get_yrange(total, sigs, data_)
    ymin_range = useroptions[:yminclipnegative] ? 0.0 : -Inf
    ymax_range = yrange[2] * useroptions[:ymaxscale]
    yrange = if length(useroptions[:yrange]) > 1
        [useroptions[:yrange][1], useroptions[:yrange][2]]
    else
        [ymin_range, ymax_range]
    end

    # Compute the xrange
    xrange = if length(useroptions[:xrange]) > 1
        [useroptions[:xrange][1], useroptions[:xrange][2]]
    else
        [binedges(total)[1], binedges(total)[end]]
    end

    # Compute the ratio range
    ratiorange = length(useroptions[:ratiorange]) == 0 ? [0, 2] : useroptions[:ratiorange]

    # Compute the layout
    ratiopanelydomain = [0, 0.27]
    mainpanelydomain = [0.32, 1]
    xdomain = [0, 1]

    # Compute the texts to put on the plot
    annotations = []
    add_cms_label!(annotations, options=useroptions)
    add_lumi_label!(annotations, options=useroptions)

    # Compute the plot size
    width = 500
    height = 600

    # Compute whether to show the xtick marks labels for main panel
    showmainpanelxtick = false

    # Compute the x-axis label
    xaxistitle = string("&nbsp;"^30,useroptions[:xaxistitle])
    mainpanel_xaxistitle = ""
    
    # Recompute the heights and domains if it :hideratio is true
    if useroptions[:hideratio]
        ratiopanelydomain = [0, 0]
        mainpanelydomain = [0, 1]
        height = 460
        showmainpanelxtick = true
        mainpanel_xaxistitle = xaxistitle
    end

    #__________________________________________________________________________________
    #
    #
    # Plot!
    #
    #
    p = plot(
             traces,
             Layout(

                    template="simple_white",
                    autosize=false,
                    width=width,
                    height=height,

                    font=attr( family="Arial", size=24,),

                    margin=attr( l=100, b=100,),

                    legend=attr( orientation="h", font=attr(size=18, color="black", family="Arial"), yanchor="top", y=0.98, xanchor="center", x=0.5, bgcolor="rgba(255,255,255,0.3)", itemwidth=0, tracegroupgap=0, traceorder="grouped"),

                    bargap=0,
                    barmode="stack",

                    # Ratio main axis
                    yaxis =attr(color="black",
                                domain = ratiopanelydomain,
                                linewidth=1,
                                mirror=true,
                                range = ratiorange,
                                showgrid=false,
                                ticklen=5,
                                ticks="outside",
                                nticks=8,
                                zeroline=false,
                                title=attr(
                                           text=useroptions[:ratiotitle],
                                           font=attr(size=useroptions[:ratiotitlesize],),
                                           standoff=1
                                          ),
                               ), 
                    xaxis=attr(color="black",
                               domain=xdomain,
                               linewidth=1,
                               mirror=true,
                               range=xrange,
                               showgrid=false,
                               ticklen=5,
                               ticks="outside",
                               nticks=10,
                               zeroline=false,
                               title=attr(text=xaxistitle,
                                          standoff=1),
                              ),

                    # Ratio tick marks
                    yaxis2=attr(color="black",
                                domain=ratiopanelydomain,
                                linewidth=1,
                                mirror=true,
                                range=ratiorange,
                                showgrid=false,
                                ticklen=2,
                                ticks="outside",
                                nticks=32,
                                zeroline=false,
                                overlaying="y",
                                showticklabels=false,
                                matches="y"),
                    xaxis2=attr(color="black",
                                domain=xdomain,
                                linewidth=1,
                                mirror=true,
                                range=xrange,
                                showgrid=false,
                                ticklen=2,
                                ticks="outside",
                                nticks=40,
                                zeroline=false,
                                overlaying="x",
                                showticklabels=false,
                                matches="x",
                               ),

                    # Ratio tick marks
                    yaxis3=attr(color="black",
                                domain=ratiopanelydomain,
                                linewidth=1,
                                mirror=true,
                                range=ratiorange,
                                showgrid=true,
                                ticklen=2,
                                ticks="outside",
                                nticks=4,
                                zeroline=false,
                                overlaying="y",
                                showticklabels=false,
                                matches="y"),
                    xaxis3=attr(color="black",
                                domain=xdomain,
                                linewidth=1,
                                mirror=true,
                                range=xrange,
                                showgrid=false,
                                ticklen=2,
                                ticks="outside",
                                nticks=40,
                                zeroline=false,
                                overlaying="x",
                                showticklabels=false,
                                matches="x",
                               ),

                    # Main axis
                    yaxis4=attr(color="black",
                                domain=mainpanelydomain,
                                linewidth=1,
                                mirror=true,
                                range=yrange,
                                showgrid=false,
                                ticklen=5,
                                ticks="outside",
                                nticks=8,
                                zeroline=false,
                                anchor="x4",
                                title=attr(text=string("&nbsp;"^25,useroptions[:yaxistitle]),
                                           standoff=1),
                               ),
                    xaxis4=attr(color="black",
                                domain=xdomain,
                                linewidth=1,
                                mirror=true,
                                range=xrange,
                                showgrid=false,
                                ticklen=5,
                                ticks="outside",
                                nticks=10,
                                zeroline=false,
                                anchor="y4",
                                showticklabels=showmainpanelxtick,
                                matches="x",
                                title=attr(text=mainpanel_xaxistitle,
                                           standoff=1),
                               ),

                    # Main tick marks
                    yaxis5=attr(color="black",
                                domain=mainpanelydomain,
                                linewidth=1,
                                mirror=true,
                                range=ratiorange,
                                showgrid=false,
                                ticklen=2,
                                ticks="outside",
                                nticks=40,
                                zeroline=false,
                                anchor="x5",
                                overlaying="y4",
                                showticklabels=false,
                                matches="y4",
                               ),
                    xaxis5=attr(color="black",
                                domain=xdomain,
                                linewidth=1,
                                mirror=true,
                                range=xrange,
                                showgrid=false,
                                ticklen=2,
                                ticks="outside",
                                nticks=50,
                                zeroline=false,
                                anchor="y4",
                                overlaying="x4",
                                showticklabels=false,
                                matches="x",
                               ),

                    annotations=annotations,

                   )
            )

    #__________________________________________________________________________________
    #
    #
    # Save!
    #
    #
    outputname = useroptions[:outputname]
    # glob to regex
    outputname = replace(outputname, r"\{|\,|\}" => s->Dict("{"=>"(","}"=>")",","=>"|")[s])
    if !isempty(outputname)
        outputnamenoext = first(rsplit(outputname, "."; limit=2))
        # all possible output formats
        outputs = ["$outputnamenoext.$ext" for ext in ["html", "pdf", "png", "svg"]]
        # those matching the specified filename (or pattern)
        for output in outputs[occursin.(Regex(outputname), outputs)]
            savefig(p, output, width=width, height=height);
        end
    end
    return p
end
