module PlotlyJSWrapper

using PlotlyJS
using FHist

export build_hist1dtrace, make_fhist1d, plot_stack, test

include("utils.jl")

default_options = Dict{Symbol, Any}(
                                    :outputname => "plot.pdf",
                                    :dofit => false,
                                    :ratiotitle => "Data/MC",
                                    :ymaxscale => 1.8,
                                    :yminclipnegative => true,
                                    :yrange => [],
                                    :xrange => [],
                                    :ratiorange => [0, 2],
                                    :xaxistitle => "variable [unit]",
                                    :yaxistitle => "Events",
                                    :addpreliminarylabel => true,
                                    :lumivalue => 137,
                                    :comenergy => 13,
                                    :datacolors => ["black", "red", "blue", "orange", "green", "purple", "gray"],
                                    :backgroundcolors => [4020, 4023, 4021, 4024, 2001, 6004, 11005, 11004, 11003, 11002, 11001, 11000, 11011, 11012, 11013, 11014, 11015, 3001, 3000, 3011, 5001, 5002, 5003, 5004, 5005, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 7011, 7012, 7013, 7014, 7015, 7016, 7017, 9001, 9002, 9003, 9004, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4101, 4102, 4103, 4104, 4201, 4305, 6002, 6003, 6004, 6005, 6006, 6007, 6008,],
                                    :backgroundlabels => [],
                                    :signallabels => [],
                                    :datalabels => ["Data"],
                                   )

function plot_stack(; backgrounds, signals=[], data=[], options::Dict{Symbol, Any}=default_options)

    #__________________________________________________________________________________
    #
    #
    # Preparing user options
    #
    #
    # Take the default options and merge it with given options
    useroptions = deepcopy(default_options)
    merge!(useroptions, options)

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

    # Total background histogram
    total = sum(bkgs)

    #__________________________________________________________________________________
    #
    #
    # Processing FHist's
    #
    #
    useroptions[:dofit] && fit_bkg_to_data!(bkgs, total, data_)

    # Compute the ratio histogram
    ratio = data_ ./ total

    #__________________________________________________________________________________
    #
    #
    # Traces
    #
    #
    # Grand list to hold all the traces to plot
    traces = GenericTrace{Dict{Symbol, Any}}[]
    add_ratio_axes_traces!(traces, options=useroptions)
    add_ratio_traces!(traces, ratio, options=useroptions)
    add_background_traces!(traces, bkgs, options=useroptions)
    add_total_traces!(traces, total, options=useroptions)
    add_data_traces!(traces, data_, options=useroptions)

    #__________________________________________________________________________________
    #
    #
    # Computing `Layout()` related variables
    #
    #
    # Compute the ymax and ymin
    yrange = get_yrange(total, sigs, data_)
    ymin_range = useroptions[:yminclipnegative] && 0.0
    ymax_range = yrange[2] * useroptions[:ymaxscale]
    yrange = [ymin_range, ymax_range]
    if length(useroptions[:yrange]) > 1
        yrange = [useroptions[:yrange][1], useroptions[:yrange][2]]
    end

    # Compute the xrange
    xrange = [binedges(total)[1], binedges(total)[end]]
    if length(useroptions[:xrange]) > 1
        xrange = [useroptions[:xrange][1], useroptions[:xrange][2]]
    end

    # Compute the ratio range
    ratiorange = useroptions[:ratiorange]

    # Compute the layout
    ratiopanelydomain = [0, 0.27]
    mainpanelydomain = [0.32, 1]
    xdomain = [0, 1]

    # Compute the texts to put on the plot
    annotations = []
    add_cms_label!(annotations, options=useroptions)
    add_lumi_label!(annotations, options=useroptions)

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
                    width=500,
                    height=600,

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
                               title=attr(text=string("&nbsp;"^30,useroptions[:xaxistitle]),
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
                                showticklabels=false,
                                matches="x",
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
                                nticks=32,
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
                                nticks=40,
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
    # Get output name
    outputnamewithoutextension = useroptions[:outputname][1:findlast(isequal('.'),useroptions[:outputname])-1]

    # Save HTML
    savefig(p, "$outputnamewithoutextension.html");

    # Do some modification for printing pdf
    p.plot.layout[:legend][:font][:family]="Balto" # For example t\bar{t} the t and \bar{t} gets different font for Arial, when using Balto it agrees

    # Save PDF and PNG
    savefig(p, "$outputnamewithoutextension.pdf", width=500, height=600);
    savefig(p, "$outputnamewithoutextension.png", width=500, height=600);

end

end
