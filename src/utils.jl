struct BinInfo
    s::Float64
    se::Float64
    b::Float64
    be::Float64
    d::Float64
    de::Float64
    ibin::Int64
end

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
function build_hist1dtrace(h; witherror=false, datastyle=false, errorsminus=[])
    bin_low_edges = deepcopy(binedges(h)) # bin edges
    bin_centers = deepcopy(bincenters(h)) # bin edges
    bin_contents = deepcopy(bincounts(h))
    errorsminus_ = deepcopy(errorsminus)
    if length(errorsminus_) != 0 && length(errorsminus_) != length(bin_contents)
        println(length(errorsminus_))
        println(length(bin_contents))
        error("[PlotlyJSWrapper] length of errorsminus does not match the histogram nbins!")
    end
    push!(bin_contents, last(bin_contents))
    bin_errors = sqrt.(h.sumw2)
    push!(bin_errors, last(bin_errors))
    if length(errorsminus_) != 0
        push!(errorsminus_, last(errorsminus_))
    end
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
        error_y = if length(errorsminus_) != 0
            new_bin_errors_up = new_bin_errors
            new_bin_errors_dn = errorsminus_
            attr(array=new_bin_errors_up, arrayminus=new_bin_errors_dn, symmetric=false, width=0)
        else
            attr(array=new_bin_errors, width=0)
        end

        attr(array=new_bin_errors, width=0)
        s1 = scatter(y=new_bin_contents,
                     x=new_bin_centers,
                     error_y=error_y,
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
    get_totalunity(total)

Divide the `total` by itself and return a "unity" histogram to be used for
ratio panel for bkg error shade in the ratio panel
"""
function get_totalunity(total)
    output = total / total
    output.hist.weights .= output.hist.weights .|> x->(isnan(x) ? 0 : x)
    output.sumw2 .= output.sumw2 .|> x->(isnan(x) ? 0 : x)
    return output
end

"""
    fit_bkg_to_data!(bkgs, total, data_)

Scales bkgs and total to first data integral
"""
function fit_bkg_to_data!(bkgs, data_)
    # If do fit, scale the background histogram to match the data
    # Check that there is even data to scale it to
    if length(data_) != 0
        # Compute the total with current list of bkgs prior to scaling
        total = sum(bkgs)
        # Compute the total integral
        bkgint = integral(total)
        # If total integral is 0 then throw exception
        if bkgint == 0
            error("[PlotlyJSWrapper scale_background!], Asked to rescale background but background integral = 0!")
            return
        end
        # Compute the data integral
        data_int = integral(data_[1])
        # Compute the data / bkg scale factor
        sf = data_int / bkgint
        # Scale the backgrounds
        bkgs .*= sf
    else
        # If no data, print warning and move on
        @warn "[PlotlyJSWrapper plot_stack()] Asked for :dofit, but there is no data! Skipping..."
    end
end

"""
    get_yrange(total, signals, data_)

Get range of ymin to ymax
"""
function get_yrange(total, signals, data_)
    get_yrange([total, signals..., data_...])
end

"""
    get_yrange(hists)

Get range of ymin to ymax
"""
function get_yrange(hists)
    ymin = [minimum(bincounts(h)-sqrt.(h.sumw2)) for h in hists] |> minimum
    ymax = [maximum(bincounts(h)+sqrt.(h.sumw2)) for h in hists] |> maximum
    (ymin, ymax)
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
end

"""
    add_main_axes_traces!(traces; options)

Add main axes traces to `traces`
"""
function add_main_axes_traces!(traces; options)
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
                                          size=20,
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
    add_ratio_traces!(traces, data, total; options)

Add data / MC ratio traces to `traces`
"""
function add_ratio_traces!(traces, data, total; options)
    data_ = deepcopy(data) # Copy to not modify original
    # Get the asymm error if requested
    errorsminus = if options[:poissonerror]
        d = get_data_with_pearson_err(data_; options=options)
        data_ = d[1]
        d[2] .|> x->x./bincounts(total)
    else
        []
    end
    ratio = data_ ./ total
    # If no ratio plot then nothing to do just move on
    if length(ratio) == 0
        return
    end
    # Ratio trace
    ratio_traces = if options[:poissonerror]
        map((x,y)->build_hist1dtrace(x, datastyle=true, errorsminus=y), ratio, errorsminus)
    else
        ratio .|> x->build_hist1dtrace(x, datastyle=true)
    end
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
    add_ratio_totalerror_traces!(traces, total; options)

Add total ratio error line to `traces`
"""
function add_ratio_totalerror_traces!(traces, total; options)

    # First massage the total histogram into unity with errors being fractional
    totalunity = get_totalunity(total)

    totaltraces = totalunity |> x->build_hist1dtrace(x, witherror=true)
    for totaltrace in totaltraces
        totaltrace.fields[:yaxis] = "y"
        totaltrace.fields[:xaxis] = "x"
    end
    totaltraces[1].fields[:name] = "total"
    totaltraces[2].fields[:name] = string("total ", options[:totalsystlabel][1])
    totaltraces[3].fields[:name] = string("total ", options[:totalsystlabel][2])
    append!(traces, totaltraces)
end

"""
    add_ratio_customsignal_traces!(traces, customsignals; options)

Add customized signals traces for ratio panel to `traces`
"""
function add_ratio_customsignal_traces!(traces, signals_to_use; options)
    signals_traces = signals_to_use .|> x->build_hist1dtrace(x, witherror=true)[1]
    signals_labels = deepcopy(options[:signallabels])
    if length(signals_labels) < length(signals_traces)
        for i in 1:(length(signals_traces)-length(signals_labels))
            push!(signals_labels, "Signal$i")
        end
    end
    for (i, (label, tr)) in enumerate(zip(signals_labels, signals_traces))
        tr.fields[:name] = label
        tr.fields[:line][:color] = colors(options[:signalcolors][i], opacity=1)
        tr.fields[:line][:width] = 2
        tr.fields[:yaxis] = "y"
        tr.fields[:xaxis] = "x"
        tr.fields[:showlegend] = false
        tr.fields[:opacity] = 1
        push!(traces, tr)
    end
    if length(options[:ratiorange]) == 0
        options[:ratiorange] = get_yrange(signals_to_use)
        options[:ratiorange] = [options[:ratiorange][1], 1.2*options[:ratiorange][2]]
    end
end

"""
    add_ratio_signal_traces!(traces, signals, total; options)

Add signals traces above ratio panel's unity line to `traces`
"""
function add_ratio_signal_traces!(traces, signals, total; options)
    signalsratio = (signals .+ total) ./ total
    signals_to_use = deepcopy(signalsratio)
    add_ratio_customsignal_traces!(traces, signals_to_use, options=options)
end

"""
    add_fom_traces!(traces, signals, total, data; options)

Add fom traces to `traces`
if `perbin` then return per bin fom
if `fromleft` starts cutting from left
"""
function add_fom_traces!(traces, signals, total, data; options, perbin=true, fromleft=true)
    # Parse which fom to use
    fom = if options[:fom] == "soverb"
        x->x.s/x.b
    elseif options[:fom] == "soversqrtb"
        x->x.s/sqrt(x.b)
    elseif options[:fom] == "soversqrtsplusb"
        x->x.s/sqrt(x.s+x.b)
    elseif options[:fom] == "llsignif"
        x->sqrt(2*((x.s+x.b)*log(1+x.s/x.b)-x.s))
    elseif options[:fom] == "custom"
        options[:customfom]
    end
    # Copy the signals to use because we will overwrite the content
    signals_to_use = deepcopy(signals)
    # Obtain the total # of bins
    nbs = nbins(total)
    # Copy the data content if the data is provided
    dc = if length(data) > 0
        data[1].hist.weights
    else
        repeat([0.0],nbs)
    end
    de = if length(data) > 0
        sqrt.(data[1].sumw2)
    else
        repeat([0.0],nbs)
    end
    bcs = if perbin
        signals_to_use .|> s->map(fom, BinInfo.(bincounts(s), sqrt.(s.sumw2), bincounts(total), sqrt.(total.sumw2), dc, de, 1:nbins(s)))
    elseif fromleft
        cumtotal = mycumulative(total, forward=false)
        signals_to_use .|> x->mycumulative(x, forward=false) .|> s->map(fom, BinInfo.(bincounts(s), sqrt.(s.sumw2), cumtotal.hist.weights, sqrt.(cumtotal.sumw2), dc, de, 1:nbins(s)))
    else
        cumtotal = mycumulative(total, forward=true)
        signals_to_use .|> x->mycumulative(x, forward=true) .|> s->map(fom, BinInfo.(bincounts(s), sqrt.(s.sumw2), cumtotal.hist.weights, sqrt.(cumtotal.sumw2), dc, de, 1:nbins(s)))
    end
    for (i, bc) in enumerate(bcs)
        signals_to_use[i].hist.weights = bc
        signals_to_use[i].sumw2 .= 0 # remove errors as they don't have a meaning
    end
    add_ratio_customsignal_traces!(traces, signals_to_use, options=options)
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
    data_ = deepcopy(data) # Copy to not modify original
    # Get the asymm error if requested
    errorsminus = if options[:poissonerror]
        d = get_data_with_pearson_err(data_; options=options)
        data_ = d[1]
        d[2]
    else
        []
    end
    # Gather the traces for plotly to plot
    data_traces = if options[:poissonerror]
        map((x,y)->build_hist1dtrace(x, datastyle=true, errorsminus=y), data_, errorsminus)
    else
        data_ .|> x->build_hist1dtrace(x, datastyle=true)
    end
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

"""
    check_conflicting_options(options)

Check conflicting options for few options and give warnings to users.
"""
function check_conflicting_options(options)
    # Check that the options are consistent between fom settings
    val = Int64(options[:showfomperbin]) +
          Int64(options[:showfomfromleft]) +
          Int64(options[:showfomfromright]) +
          Int64(options[:showsignalsinratio])
    if val > 1
        @warn "[PlotlyJSWrapper] Provided more than one showfomperbin, showfomfromleft, showfomfromright, showsignalsinratio!"
        @warn "[PlotlyJSWrapper] Will choose whichever comes first in the above order!"
    end
    # Check that the fom options are allowed
    if typeof(options[:fom]) == String

        if options[:fom] ∉ ["soverb", "soversqrtb", "soversqrtsplusb", "llsignif", "custom"]
            @warn string("[PlotlyJSWrapper] Provided :fom=",options[:fom]," which is not recognized!")
            @warn "[PlotlyJSWrapper] Defaulting to :fom=\"soversqrtb\""
        end
    end
    if options[:fom] == "custom" && isnothing(options[:customfom])
        error("[PlotlyJSWrapper] Provided :fom=\"custom\" yet you have not provided an anonymous function (i.e. lambda) to :customfom option! Please provide a lambda e.g. (s,serror,b,berror,data,dataerror,binindex)->s/sqrt(s+berror^2) to :customfom.")
    end
end

"""
    mycumulative(h::Hist1D; forward=true)

Create a cumulative histogram. If `forward`, start
summing from the left.
"""
function mycumulative(h::Hist1D; forward=true)
    # https://root.cern.ch/doc/master/TH1_8cxx_source.html#l02608
    f = forward ? identity : reverse
    h = deepcopy(h)
    h.hist.weights .= f(cumsum(f(h.hist.weights)))
    h.sumw2 .= f(cumsum(f(h.sumw2)))
    return h
end

@inline function pearson_err(n::Real)
    s = sqrt(n+0.25)
    s+0.5, s-0.5
end

"""
    get_data_with_pearson_err(data_; options)

Return data::Hist1D[], errorsminus::Float64[] where `data` has sumw2 set to
positive error, and `errorsminus` are list of negative errors in vector
"""
function get_data_with_pearson_err(data_; options)
    data = deepcopy(data_)
    errfunc = isnothing(options[:poissonerrorfunc]) ? pearson_err : options[:poissonerrorfunc]
    sumw2s = data .|> bincounts .|> x->(x .|> y->errfunc(y)[1]) .|> x->x^2
    for (d, w2) in zip(data, sumw2s)
        d.sumw2 .= w2
    end
    errorsminus = data_ .|> bincounts .|> x->(x .|> y->errfunc(y)[2])
    (data, errorsminus)
end
