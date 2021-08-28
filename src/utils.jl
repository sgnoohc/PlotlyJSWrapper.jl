"""
    build_hist1dtrace(h; witherror=false, datastyle=false)

Create plotly trace representing `Hist1D` data.
There are three different variations.
if datastyle = true, then it returns a single `scatter` trace.
if witherror = true, then it returns an array of 'scatter' traces.
The first trace is the central value, while the following two traces
are the up and down uncertainty bands.
If all extra arguments are false, it returns a single bar histogram.
(i.e. background style)
"""
function build_hist1dtrace(h; witherror=false, datastyle=false)
    bin_low_edges = copy(binedges(h)) # bin edges
    bin_centers = copy(bincenters(h)) # bin edges
    bin_contents = copy(bincounts(h))
    push!(bin_contents, last(bin_contents))
    bin_errors = sqrt.(h.sumw2)
    push!(bin_errors, last(bin_errors))
    traces = GenericTrace{Dict{Symbol, Any}}[]
    if datastyle
        new_bin_contents = Float64[]
        new_bin_centers = Float64[]
        new_bin_errors = Float64[]
        for (y, x, ye) in zip(bin_contents, bin_centers, bin_errors)
            if y != 0
                push!(new_bin_contents, y)
                push!(new_bin_centers, x)
                push!(new_bin_errors, ye)
            end
        end
        s1 = scatter(y=new_bin_contents,
                     x=new_bin_centers,
                     error_y=attr(array=new_bin_errors, width=0),
                     opacity=1,
                     mode="markers",
                     marker_size=7,
                     marker_color="black",
                    )
        return s1
    end
    if witherror
        s1 = scatter(y=bin_contents,
                     x=bin_low_edges,
                     opacity=0.7,
                     mode="lines",
                     line_shape="hv",
                     line_width=0,
                     marker_size=0,
                     fillcolor="blue",
                     fill="tozeroy",
                     showlegend=false,
                    )
    else
        # println(bin_centers)
        # println(bin_contents)
        # println(bin_low_edges)
        s1 = bar(x=bin_centers,
                 y=bin_contents,
                 opacity=1.0,
                 marker_color="black",
                 # marker_line_width=1,
                 # marker_colorbar_color="black",
                )
        return s1
    end
    s2 = scatter(y=bin_contents+bin_errors,
                 x=bin_low_edges,
                 mode="lines",
                 marker_color="#444",
                 line_shape="hv",
                 line_width=0,
                 showlegend=false
                )
    s3 = scatter(y=bin_contents-bin_errors,
                 x=bin_low_edges,
                 mode="lines",
                 marker_color="#444",
                 fillcolor="rgba(68, 68, 68, 0.3)",
                 line_shape="hv",
                 fill="tonexty",
                 line_width=0,
                 showlegend=false
                )
    s1.fields[:line][:width]=1
    s1.fields[:line][:color]="blue"
    s1.fields[:fill]=""
    push!(traces, s1)
    push!(traces, s2)
    push!(traces, s3)
    return traces
end

"""
    fit_bkg_to_data!(bkgs, total, data_)

Scales bkgs and total to first data integral
"""
function fit_bkg_to_data!(bkgs, total, data_)
    # If do fit, scale the background histogram to match the data
    # Check that there is even data to scale it to
    if length(data_) != 0
        # Compute the total integral
        bkgint = integral(total)
        # If total integral is 0 then throw exception
        if bkgint == 0
            error("ERROR [PlotlyJSWrapper scale_background!], Asked to rescale background but background integral = 0!")
            return
        end
        # Compute the data integral
        data_int = integral(data_[1])
        # Compute the data / bkg scale factor
        sf = data_int / bkgint
        # Scale the backgrounds
        bkgs = bkgs .|> x->x*sf
        # Recompute total
        total = sum(bkgs) # Recompute total
    else
        # If no data, print warning and move on
        println("Warning! [PlotlyJSWrapper plot_stack()] Asked for :dofit, but there is no data! Skipping...")
    end
end

"""
    get_ymax(total, signals, data_)

Finds the maximum y point including errors
"""
function get_ymax(total, signals, data_)
    totalmax = maximum(bincounts(total)+sqrt.(total.sumw2))
    datamax = data_ .|> x->maximum(bincounts(x)+sqrt.(x.sumw2))
    sigmax = signals .|> x->maximum(bincounts(x)+sqrt.(x.sumw2))
    maxtocheck = [totalmax]
    length(datamax) != 0 && append!(maxtocheck, datamax)
    length(sigmax) != 0 && append!(maxtocheck, sigmax)
    ymax = maximum(maxtocheck)
end

"""
    get_ymax(total, signals, data_)

Finds the minimum y point including errors
"""
function get_ymin(total, signals, data_)
    totalmin = minimum(bincounts(total)-sqrt.(total.sumw2))
    datamin = data_ .|> x->minimum(bincounts(x)-sqrt.(x.sumw2))
    sigmin = signals .|> x->minimum(bincounts(x)-sqrt.(x.sumw2))
    mintocheck = [totalmin]
    length(datamin) != 0 && append!(mintocheck, datamin)
    length(sigmin) != 0 && append!(mintocheck, sigmin)
    ymin = minimum(mintocheck)
end


"""
    get_ymax(total, signals, data_)

Get range of ymin to ymax
"""
function get_yrange(total, signals, data_)
    [get_ymin(total, signals, data_), get_ymax(total, signals, data_)]
end

"""
    add_ratio_axes_traces!(traces; options)

Add ratio axes traces to `traces`
"""
function add_ratio_axes_traces!(traces; options)
    # Dummy traces for ratio panel
    # major ticks
    ratiopanel_majorticks_dummy_trace = scatter()
    ratiopanel_majorticks_dummy_trace.fields[:name] = "ratiopanel_majorticks"
    ratiopanel_majorticks_dummy_trace.fields[:yaxis] = "y"
    ratiopanel_majorticks_dummy_trace.fields[:xaxis] = "x"
    ratiopanel_majorticks_dummy_trace.fields[:name] = options[:ratiotitle]
    ratiopanel_majorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_majorticks_dummy_trace)
    # minor ticks
    ratiopanel_minorticks_dummy_trace = scatter()
    ratiopanel_minorticks_dummy_trace.fields[:name] = "ratiopanel_minorticks"
    ratiopanel_minorticks_dummy_trace.fields[:yaxis] = "y2"
    ratiopanel_minorticks_dummy_trace.fields[:xaxis] = "x2"
    ratiopanel_minorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_minorticks_dummy_trace)
    ratiopanel_unityline_dummy_trace = scatter()
    ratiopanel_unityline_dummy_trace.fields[:name] = "ratiopanel_unityline"
    ratiopanel_unityline_dummy_trace.fields[:yaxis] = "y3"
    ratiopanel_unityline_dummy_trace.fields[:xaxis] = "x3"
    ratiopanel_unityline_dummy_trace.fields[:showlegend] = false
    push!(traces, ratiopanel_unityline_dummy_trace)
    # Dummy traces for main panel
    # major ticks
    mainpanel_majorticks_dummy_trace = scatter()
    mainpanel_majorticks_dummy_trace.fields[:name] = "mainpanel_majorticks"
    mainpanel_majorticks_dummy_trace.fields[:yaxis] = "y4"
    mainpanel_majorticks_dummy_trace.fields[:xaxis] = "x4"
    mainpanel_majorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, mainpanel_majorticks_dummy_trace)
    # minor ticks
    mainpanel_minorticks_dummy_trace = scatter()
    mainpanel_minorticks_dummy_trace.fields[:name] = "mainpanel_minorticks"
    mainpanel_minorticks_dummy_trace.fields[:yaxis] = "y5"
    mainpanel_minorticks_dummy_trace.fields[:xaxis] = "x5"
    mainpanel_minorticks_dummy_trace.fields[:showlegend] = false
    push!(traces, mainpanel_minorticks_dummy_trace)
end

"""
    add_cms_label!(annotations; options)

Add CMS label to `annotations`
"""
function add_cms_label!(annotations; options)
    push!(annotations, attr(
                            xref="paper",
                            yref="paper",
                            xanchor="left",
                            yanchor="bottom",
                            x=0.0,
                            y=1.0,
                            text="<b>CMS</b>",
                            font=attr(
                                      color="black",
                                      size=24,
                                     ),
                            showarrow=false,
                           ))
    if options[:addpreliminarylabel]
        push!(annotations, attr(
                                xref="paper",
                                yref="paper",
                                xanchor="left",
                                yanchor="bottom",
                                x=0.18,
                                y=1.0,
                                text="<i>Preliminary</i>",
                                font=attr(
                                          color="black",
                                          size=14,
                                         ),
                                showarrow=false,
                               ))
    end
end

"""
    add_lumi_label!(annotations; options)

Add luminosity and energy label to `annotations`
"""
function add_lumi_label!(annotations; options)
    lumival = options[:lumivalue]
    comenergy = options[:comenergy]
    push!(annotations, attr(
                            xref="paper",
                            yref="paper",
                            xanchor="right",
                            yanchor="bottom",
                            x=1.0,
                            y=1.0,
                            text="$lumival fb<sup>-1</sup>($comenergy TeV)",
                            font=attr(
                                      color="black",
                                      size=20,
                                     ),
                            showarrow=false,
                           ))
end

"""
    add_ratio_traces!(traces, ratio; options)

Add data / MC ratio traces to `traces`
"""
function add_ratio_traces!(traces, ratio; options)
    # If no ratio plot then nothing to do just move on
    if length(ratio) == 0
        return
    end
    # Ratio trace
    ratio_traces = ratio .|> x->build_hist1dtrace(x, datastyle=true)
    if length(ratio_traces) > length(options[:datacolors])
        println("Warning! There are more data histograms than provided :datacolors!")
    end
    for (i, tr) in enumerate(ratio_traces)
        tr.fields[:yaxis] = "y"
        tr.fields[:xaxis] = "x"
        tr.fields[:name] = "Data/MC"
        tr.fields[:marker][:color] = options[:datacolors][i]
        tr.fields[:showlegend] = false
        push!(traces, tr)
    end
end

"""
    add_background_traces!(traces, bkgs; options)

Add background traces to `traces`
"""
function add_background_traces!(traces, bkgs; options)
    # Main data trace
    stack_traces = bkgs .|> build_hist1dtrace
    for stack_trace in stack_traces
        stack_trace.fields[:yaxis] = "y4"
        stack_trace.fields[:xaxis] = "x4"
    end
    # Set the colors of the histograms
    for (tr, c) in zip(stack_traces, repeat(options[:backgroundcolors], 10)) # Not very safe.. but it works for now
        tr.fields[:marker][:color] = colors(c, opacity=1)
    end
    # Set the names of the histograms
    nice_names = deepcopy(options[:backgroundlabels])
    if length(nice_names) < length(stack_traces)
        for i in 1:(length(stack_traces)-length(nice_names))
            push!(nice_names, "trace$i")
        end
    end
    for (tr, n) in zip(stack_traces, nice_names)
        tr.fields[:name] = n
    end
    stack_traces = sort(stack_traces, by=x->sum(x.fields[:y]), rev=false)
    # Set the group to be individual based idx of the bkg
    for (g, tr) in enumerate(stack_traces)
        tr.fields[:legendgroup] = g
    end
    append!(traces, stack_traces)
end

"""
    add_total_traces!(traces, total; options)

Add total background traces to `traces`
"""
function add_total_traces!(traces, total; options)
    totaltraces = total |> x->build_hist1dtrace(x, witherror=true)
    for totaltrace in totaltraces
        totaltrace.fields[:yaxis] = "y4"
        totaltrace.fields[:xaxis] = "x4"
    end
    totaltraces[1].fields[:name] = "total"
    totaltraces[2].fields[:name] = string("total ", options[:totalsystlabel][1])
    totaltraces[3].fields[:name] = string("total ", options[:totalsystlabel][2])
    append!(traces, totaltraces)
    # dummy total histogram for legend
    totallegendtrace = copy(totaltraces[1])
    totallegendtrace.fields[:showlegend] = true
    totallegendtrace.fields[:legendgroup] = -100
    push!(traces, totallegendtrace)
end

"""
    add_data_traces!(traces, data; options)

Add data traces to `traces`
"""
function add_data_traces!(traces, data; options)
    data_traces = data .|> x->build_hist1dtrace(x, datastyle=true)
    data_labels = deepcopy(options[:datalabels])
    if length(data_labels) < length(data_traces)
        for i in 1:(length(data_traces)-length(data_labels))
            push!(data_labels, "Data$i")
        end
    end
    for (i, (label, tr)) in enumerate(zip(data_labels, data_traces))
        tr.fields[:name] = label
        tr.fields[:marker][:color] = options[:datacolors][i]
        tr.fields[:yaxis] = "y4"
        tr.fields[:xaxis] = "x4"
        tr.fields[:legendgroup] = -1 * i
        push!(traces, tr)
    end
end

"""
    add_signal_traces!(traces, signals; options, total)

Add signal traces to `traces`. `total` is passed in case one wants to stack the
signal on top of total background.
"""
function add_signal_traces!(traces, signals; options, total)
    signals_to_use = deepcopy(signals)
    if options[:stacksignals]
        signals_to_use = signals_to_use .|> x->x+total
    end
    signals_traces = signals_to_use .|> x->build_hist1dtrace(x, witherror=true)[1]
    signals_labels = deepcopy(options[:signallabels])
    if length(signals_labels) < length(signals_traces)
        for i in 1:(length(signals_traces)-length(signals_labels))
            push!(signals_labels, "Signal$i")
        end
    end
    for (i, (label, tr)) in enumerate(zip(signals_labels, signals_traces))
        tr.fields[:name] = label
        if options[:stacksignals]
            tr.fields[:line][:color] = colors(options[:signalcolors][i], opacity=1)
            tr.fields[:yaxis] = "y4"
            tr.fields[:xaxis] = "x4"
            tr.fields[:legendgroup] = -1 * i -200
            tr.fields[:showlegend] = false
            tr.fields[:opacity] = 1
            push!(traces, tr)
            total_trace = build_hist1dtrace(total, witherror=true)[1]
            total_trace.fields[:name] = label
            total_trace.fields[:showlegend] = label
            total_trace.fields[:line][:width]=0
            total_trace.fields[:fillcolor]=colors(options[:signalcolors][i], opacity=options[:stackedsignalopacity])
            total_trace.fields[:marker][:color]=colors(options[:signalcolors][i], opacity=1)
            total_trace.fields[:fill]="tonexty"
            total_trace.fields[:yaxis]="y4"
            total_trace.fields[:xaxis]="x4"
            push!(traces, total_trace)
        else
            tr.fields[:line][:color] = colors(options[:signalcolors][i], opacity=1)
            tr.fields[:line][:width] = 2
            tr.fields[:yaxis] = "y4"
            tr.fields[:xaxis] = "x4"
            tr.fields[:legendgroup] = -1 * i -200
            tr.fields[:showlegend] = true
            tr.fields[:opacity] = 1
            push!(traces, tr)
        end
    end
end
